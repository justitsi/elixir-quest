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
    IO.puts("#{inspect(last_card)}")

    # need to deal cards to players on start
    # deal order is 3 cards to p_1 -> 3 cards to p_2 -> 3 cards to p_1 -> 3 cards to p_2
    hand1 = []
    hand2 = []

    {deck_new, cards_1_1} = Deck.takeFromTop(deck, 3)
    {deck_new, cards_2_1} = Deck.takeFromTop(deck, 3)
    {deck_new, cards_1_2} = Deck.takeFromTop(deck, 3)
    {deck_new, cards_2_2} = Deck.takeFromTop(deck, 3)
    hand1 = List.flatten([cards_1_1, cards_1_2])
    hand2 = List.flatten([cards_2_1, cards_2_2])

    %Round{
      p_hands: [hand1, hand2],
      p_turn: starting_p_index,
      trump_suit: last_card.s,
      deck: deck_new
    }
  end

  def getPlayerOptions(round) do
    if (round.p_turn == 0) do

    else
      []
    end
  end

  def performPlayerMove(_round, _p_index, _move_type) do
    nil
  end

  def getPlayerScore(_round, _p_index) do
    nil
  end
end
