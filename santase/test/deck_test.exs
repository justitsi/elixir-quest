defmodule DeckTest do
  use ExUnit.Case
  doctest Deck

  require(Deck)
  @valid_ranks ["9", "J", "Q", "K", "10", "A"]
  @valid_suits ["C", "D", "H", "S"]

  test "[new] new deck generation" do
    deck = Deck.new()

    assert length(deck.cards) == length(@valid_ranks) * length(@valid_suits)

    # generate list of all possible cards to check generated deck contents
    cards_tmp =
      Enum.map(@valid_ranks, fn rank ->
        Enum.map(@valid_suits, fn suit ->
          {rank, suit}
        end)
      end)

    cards_tmp = List.flatten(cards_tmp)

    Enum.map(deck.cards, fn card ->
      rank_entry = List.keyfind(cards_tmp, card.r, 0, -1)
      assert rank_entry != -1
      assert rank_entry |> elem(0) == card.r

      suit_entry = List.keyfind(cards_tmp, card.s, 1, -1)
      assert suit_entry != -1
      assert suit_entry |> elem(1) == card.s
    end)
  end

  test "[takeFromTop] taking cards from top removes them from deck" do
    deck = Deck.new()

    Enum.map(Enum.to_list(0..length(deck.cards)), fn i ->
      {deck_tmp, top_cards} = Deck.takeFromTop(deck, i)

      # check got number of cards requested
      assert length(top_cards) == i

      # check no cards got deleted
      assert length(top_cards) + length(deck_tmp.cards) == length(deck.cards)

      # check cards taken are actually the first ones
      if i > 0 do
        Enum.each(0..i-1, fn j ->
          card_top_tmp = Enum.at(top_cards, j)
          card_deck_tmp = Enum.at(deck.cards, j)

          assert card_top_tmp.r == card_deck_tmp.r
          assert card_top_tmp.s == card_deck_tmp.s
          assert card_top_tmp.pnts == card_deck_tmp.pnts
        end)
      end
    end)

    # check handling of requesting more than available cards
    {deck_tmp, top_cards} = Deck.takeFromTop(deck, length(deck.cards) + 1)
    assert length(top_cards) == length(deck.cards)
    assert length(deck_tmp.cards) == 0
  end

  test "[addToTop] adding cards to deck returns them correctly" do
    deck = Deck.new()

    # check adding cards correctly



    # check adding zero cards


    # check adding duplicate cards
  end
end
