defmodule Round do
  require Deck

  defstruct p_hands: [[], []],
            p_piles: [%Deck{}, %Deck{}],
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
    {deck_new, cards_to_deal} = Deck.takeFromTop(deck, 12)
    # deal order is 3 cards to p_1 -> 3 cards to p_2 -> 3 cards to p_1 -> 3 cards to p_2
    [a, b, c, d] = Enum.chunk_every(cards_to_deal, 3)
    p_hands = [a ++ c, b ++ d]

    # need to reverse hands dealt in case p2 is starting
    p_hands =
      if starting_p_index > 0 do
        Enum.reverse(p_hands)
      else
        p_hands
      end

    %Round{
      p_hands: p_hands,
      p_turn: starting_p_index,
      trump_suit: last_card.s,
      deck: deck_new
    }
  end

  def getPlayerCardOptions(round) do
    playerCards = Enum.at(round.p_hands, round.p_turn)

    options =
      if Enum.all?(round.placed_cards, fn x -> x == nil end) do
        # if there are no placed cards this means that anything can be placed by the current player
        playerCards
      else
        # there is a card on the table so need to see whether we need to respond or can give anything
        if round.deck_closed or length(round.deck.cards) == 0 do
          placedCard = Enum.find(round.placed_cards, nil, fn x -> x != nil end)
          # if there are placed cards need to check if player can respond
          if Enum.any?(playerCards, fn card -> card.s == placedCard.s end) do
            Enum.filter(playerCards, fn card -> card.s == placedCard.s end)
          else
            # if player doesn't have requested suit they should trump
            if Enum.any?(playerCards, fn card -> card.s == round.trump_suit end) do
              Enum.filter(playerCards, fn card -> card.s == round.trump_suit end)
            else
              # if player cannot trump they can give anything in their hand
              playerCards
            end
          end
        else
          # if there are cards in the deck and it is not closed players can give whatever
          playerCards
        end
      end

    # provide empty card list to the player who does not have the current turn
    if round.p_turn == 0 do
      [options, []]
    else
      [[], options]
    end
  end

  def getPlayerPremiumOptions(_round) do
    [[], []]
  end

  def getPlayerOtherOptions(_round) do
    [[], []]
    # close deck
    # end game early
    # swap trump card (last in deck)
  end

  def performPlayerMove(_round, _p_index, _move_type) do
    nil
  end

  def getPlayerScores(_round) do
    nil
  end
end
