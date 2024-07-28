defmodule Round do
  require Deck

  defstruct p_hands: [[], []],
            p_piles: [%Deck{}, %Deck{}],
            p_premiums: [[], []],
            p_turn: 0,
            trump_suit: nil,
            deck: nil,
            deck_closed: false,
            deck_closer: nil,
            placed_cards: [nil, nil],
            winner: nil

  def new(deck, starting_p_index) do
    last_card = Enum.at(deck.cards, -1)
    # need to deal cards to players on start
    # take out all (12) cards to be dealt
    {deck_new, cards_to_deal} = Deck.take_from_top(deck, 12)
    # deal order is 3 cards to p_1 -> 3 cards to p_2 -> 3 cards to p_1 -> 3 cards to p_2
    [a, b, c, d] = Enum.chunk_every(cards_to_deal, 3)
    p_hands = [a ++ c, b ++ d]

    # need to reverse hands dealt in case p2 is starting
    p_hands =
      cond do
        starting_p_index == 1 -> Enum.reverse(p_hands)
        starting_p_index == 0 -> p_hands
      end

    %Round{
      p_hands: p_hands,
      p_turn: starting_p_index,
      trump_suit: last_card.s,
      deck: deck_new
    }
  end

  def get_player_card_options(round) do
    player_cards = Enum.at(round.p_hands, round.p_turn)

    options =
      if Enum.all?(round.placed_cards, fn x -> x == nil end) do
        # if there are no placed cards this means that anything can be placed by the current player
        player_cards
      else
        # there is a card on the table so need to see whether we need to respond or can give anything
        if round.deck_closed or length(round.deck.cards) == 0 do
          placedCard = Enum.find(round.placed_cards, nil, fn x -> x != nil end)

          # if there are placed cards need to check if player can respond
          cards_s = Enum.filter(player_cards, fn card -> card.s == placedCard.s end)

          if length(cards_s) > 0 do
            cards_s
          else
            cards_t = Enum.filter(player_cards, fn card -> card.s == round.trump_suit end)
            # if player doesn't have requested suit they should trump
            # if player cannot trump they can give anything in their hand
            cond do
              length(cards_t) > 0 -> cards_t
              length(cards_t) == 0 -> player_cards
            end
          end
        else
          # if there are cards in the deck and it is not closed players can give whatever
          player_cards
        end
      end

    # provide empty card list to the player who does not have the current turn
    cond do
      round.p_turn == 0 -> [options, []]
      round.p_turn == 1 -> [[], options]
    end
  end

  def get_player_premium_options(round) do
    player_cards = Enum.at(round.p_hands, round.p_turn) |> Deck.sort_cards()

    options =
      if Enum.any?(player_cards, fn card -> card.r == "Q" end) and
           Enum.any?(player_cards, fn card -> card.r == "K" end) do
        q_cards = Enum.filter(player_cards, fn card -> card.r == "Q" end)

        Enum.map(q_cards, fn q_card ->
          k_card = Enum.find(player_cards, fn card -> card.r == "K" and card.s == q_card.s end)

          cond do
            k_card == nil -> nil
            k_card != nil -> %{cards: [q_card, k_card], pnts: 0}
          end
        end)
      else
        []
      end

    # cleanup results - remove nils and set points
    options =
      Enum.filter(options, fn entry -> entry != nil end)
      |> Enum.map(fn option ->
        cond do
          Enum.at(option.cards, 0).s == round.trump_suit -> %{option | pnts: 40}
          Enum.at(option.cards, 0).s != round.trump_suit -> %{option | pnts: 20}
        end
      end)

    # provide empty card list to the player who does not have the current turn
    cond do
      round.p_turn == 0 -> [options, []]
      round.p_turn == 1 -> [[], options]
    end
  end

  def get_player_other_options(round) do
    # can only perform game actions when there are no cards on the 'table'
    if Enum.all?(round.placed_cards, fn entry -> entry == nil end) do
      # end game early
      options =
        cond do
          Enum.at(get_player_scores(round), round.p_turn) > 66 -> [:end_round]
          Enum.at(get_player_scores(round), round.p_turn) <= 66 -> []
        end

      # close deck
      options =
        cond do
          length(round.deck.cards) > 2 -> [:close_deck] ++ options
          length(round.deck.cards) <= 2 -> options
        end

      # swap trump card (last in deck)
      player_cards = Enum.at(round.p_hands, round.p_turn)

      options =
        if Enum.any?(player_cards, fn card -> card.r == "9" and card.s == round.trump_suit end) and
             length(round.deck.cards) > 2 do
          [:swap_card] ++ options
        else
          options
        end

      cond do
        round.p_turn == 0 -> [options, []]
        round.p_turn == 1 -> [[], options]
      end
    else
      [[], []]
    end
  end

  def perform_player_move(_round, _p_index, _move_type) do
    nil
  end

  def get_player_scores(round) do
    Enum.map(Enum.to_list(0..1), fn p_index ->
      p_pile = Enum.at(round.p_piles, p_index).cards
      p_premium = Enum.at(round.p_premiums, p_index)

      score = Enum.reduce(p_pile, 0, fn card, acc -> card.pnts + acc end)
      Enum.reduce(p_premium, score, fn premium, acc -> premium.pnts + acc end)
    end)
  end

  def get_player_final_scores(round) do
    p_scores = get_player_scores(round)

    # only one player won and game is normal (non-early-closed)
    if round.deck_closer == nil do
      if Enum.all?(p_scores, fn score -> score > 66 end) do
        [1, 1]
      else
        Enum.map(p_scores, fn score ->
          cond do
            score < 33 -> 0
            score >= 33 and score <= 66 -> 1
            score > 66 -> 2
          end
        end)
      end
    else
      Enum.map(0..1, fn p_index ->
        p_score = Enum.at(p_scores, p_index)
        other_p_score = Enum.at(p_scores, rem(p_index + 1, 2))

        if round.deck_closer == p_index do
          cond do
            other_p_score >= p_score or p_score <= 66 -> 0
            p_score > 66 and other_p_score < 66 and other_p_score >= 33 -> 2
            p_score > 66 and other_p_score < 33 -> 3
          end
        else
          cond do
            other_p_score <= 66 or p_score > 66 -> 3
            p_score >= 33 and other_p_score > 66 -> 1
            p_score < 33 and other_p_score > 66 -> 0
          end
        end
      end)
    end
  end
end
