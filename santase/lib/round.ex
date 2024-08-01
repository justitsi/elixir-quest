defmodule Round do
  defstruct p_hands: {[], []},
            p_piles: {%Deck{}, %Deck{}},
            p_premiums: {[], []},
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

    p_hands = List.to_tuple(p_hands)

    %Round{
      p_hands: p_hands,
      p_turn: starting_p_index,
      trump_suit: last_card.s,
      deck: deck_new
    }
  end

  def get_player_card_options(round) do
    # player_cards = Enum.at(round.p_hands, round.p_turn)
    player_cards = elem(round.p_hands, round.p_turn)

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
    player_cards = elem(round.p_hands, round.p_turn) |> Deck.sort_cards()
    player_premiums = elem(round.p_premiums, round.p_turn)

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

    # cleanup results - check if premium has not already been played by this player
    # and then remove nils and set points
    options =
      Enum.map(options, fn option ->
        announced =
          Enum.find(player_premiums, fn premium -> option.cards == premium.cards end)

        cond do
          announced == nil -> option
          announced -> nil
        end
      end)
      |> Enum.filter(fn entry -> entry != nil end)
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
      player_cards = elem(round.p_hands, round.p_turn)

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

  # this function checks if player move is legal and performs it
  # it does not tick-over round state in response to player actions
  def perform_player_move(round, p_index, move_type, move_data) do
    if p_index != round.p_turn do
      {:error, "Player does not have turn"}
    else
      if move_type == :card_play do
        card =
          Enum.at(get_player_card_options(round), p_index)
          |> Enum.find(fn card -> card.s == move_data.s and card.r == move_data.r end)

        if card != nil do
          # need to remove card and place it on table
          new_p_hand =
            elem(round.p_hands, p_index)
            |> Enum.filter(fn hand_card -> hand_card != card end)

          new_p_hands =
            cond do
              p_index == 0 -> {new_p_hand, elem(round.p_hands, 1)}
              p_index == 1 -> {elem(round.p_hands, 0), new_p_hand}
            end

          new_placed_cards = List.replace_at(round.placed_cards, p_index, card)
          # return updated round data
          %Round{round | placed_cards: new_placed_cards, p_hands: new_p_hands}
        else
          {:error, "Player cannot place this card"}
        end
      else
        if move_type == :premium_play do
          # need to check premium is available to play
          premium =
            Enum.at(get_player_premium_options(round), p_index)
            |> Enum.find(fn premium -> premium == move_data end)

          if premium != nil do
            # add premium to player premiums and return updated round info
            new_p_premium = [premium | elem(round.p_premiums, p_index)]

            new_p_premiums =
              cond do
                p_index == 0 -> {new_p_premium, elem(round.p_premiums, 1)}
                p_index == 1 -> {elem(round.p_premiums, 0), new_p_premium}
              end

            %Round{round | p_premiums: new_p_premiums}
          else
            {:error, "Player cannot announce this premium"}
          end
        else
          if move_type == :other_play do
            # need to check premium is available to play
            option =
              Enum.at(get_player_other_options(round), p_index)
              |> Enum.find(fn option -> option == move_data end)

            if option != nil do
              round =
                if option == :close_deck do
                  %Round{round | deck_closed: true, deck_closer: p_index}
                else
                  round
                end

              round =
                if option == :swap_card do
                  # get deck last card
                  last_deck_card = Enum.at(round.deck.cards, -1)

                  # delete 9 trumps from player's hand and add last_deck_card in its place
                  new_p_hand =
                    elem(round.p_hands, p_index)
                    |> Enum.filter(fn hand_card ->
                      hand_card.r != "9" and hand_card.s != round.trump_suit
                    end)

                  new_p_hand = [last_deck_card | new_p_hand]

                  new_p_hands =
                    cond do
                      p_index == 0 -> {new_p_hand, elem(round.p_hands, 1)}
                      p_index == 1 -> {elem(round.p_hands, 0), new_p_hand}
                    end

                  # now place a new 9 of trumps at end of round.deck.cards
                  new_deck_cards =
                    List.replace_at(round.deck.cards, -1, %Card{
                      r: "9",
                      s: round.trump_suit,
                      pnts: 0
                    })

                  new_deck = %Deck{round.deck | cards: new_deck_cards}

                  %Round{round | deck: new_deck, p_hands: new_p_hands}
                else
                  round
                end

              round =
                if option == :end_round do
                  %Round{round | winner: p_index, p_turn: -1}
                else
                  round
                end

              round
            else
              {:error, "Player cannot announce this game option"}
            end
          else
            {:error,
             "Move type unknown, known types are :card_play, :premium_play and :other_play"}
          end
        end
      end
    end
  end

  def get_player_scores(round) do
    Enum.map(Enum.to_list(0..1), fn p_index ->
      p_pile = elem(round.p_piles, p_index).cards
      p_premium = elem(round.p_premiums, p_index)

      # both premiums and cards have a pnts field to be reduced
      Enum.reduce(p_pile ++ p_premium, 0, fn entry, acc -> entry.pnts + acc end)
    end)
  end

  def get_player_final_scores(round) do
    p_scores = get_player_scores(round)

    if round.deck_closer == nil do
      # both player won - give them equal score of 1
      if Enum.all?(p_scores, fn score -> score > 66 end) do
        [1, 1]
        # only one player won and game is normal (non-early-closed)
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
      # early closed game - scores of players influence each other
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
