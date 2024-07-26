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

    Enum.each(Enum.to_list(0..length(deck.cards)), fn i ->
      {deck_tmp, top_cards} = Deck.takeFromTop(deck, i)

      # check got number of cards requested
      assert length(top_cards) == i

      # check no cards got deleted
      assert length(top_cards) + length(deck_tmp.cards) == length(deck.cards)

      # check cards taken are actually the first ones
      if i > 0 do
        Enum.each(0..(i - 1), fn j ->
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
    deck_full = Deck.new()
    cards_to_take = 5
    {deck, cards} = Deck.takeFromTop(deck_full, cards_to_take)

    # check adding cards correctly
    deck = Deck.addToTop(deck, cards)
    assert length(deck.cards) == length(deck_full.cards)

    # check adding zero cards
    deck = Deck.addToTop(deck, [])
    assert length(deck.cards) == length(deck_full.cards)

    # check adding duplicate cards fails
    deck = Deck.addToTop(deck, cards)
    assert deck |> elem(0) == :error
  end

  test "[split] splitting deck correctly reorders cards" do
    deck_full = Deck.new()

    Enum.each(Enum.to_list(1..(length(deck_full.cards) - 1)), fn i ->
      # check splitting correctly
      deck = Deck.split(deck_full, i)
      # check no cards went missing
      assert length(deck.cards) == length(deck_full.cards)
      # check first part of deck is still in order
      Enum.each(Enum.to_list(i..(length(deck_full.cards) - 1)), fn j ->
        # IO.puts("#{j}  maps to #{j - i}")
        original_card = Enum.at(deck_full.cards, j)
        new_pos_card = Enum.at(deck.cards, j - i)

        assert original_card.r == new_pos_card.r
        assert original_card.s == new_pos_card.s
      end)

      # check second part of deck is still in order
      Enum.each(Enum.to_list(0..(i - 1)), fn j ->
        # IO.puts("#{j}  maps to #{length(deck_full.cards) - i + j}")
        original_card = Enum.at(deck_full.cards, j)
        new_pos_card = Enum.at(deck.cards, length(deck_full.cards) - i + j)

        assert original_card.r == new_pos_card.r
        assert original_card.s == new_pos_card.s
      end)
    end)

    # check bad index handling
    deck = Deck.split(deck_full, -1)
    assert deck |> elem(0) == :error

    deck = Deck.split(deck_full, length(deck_full.cards))
    assert deck |> elem(0) == :error

    deck = Deck.split(deck_full, length(deck_full.cards) + 1)
    assert deck |> elem(0) == :error
  end

  test "[indexOf] check gets index in list correctly" do
    to_test = Enum.to_list(1..11)

    # check retrieves element index correctly
    Enum.each(to_test, fn elem ->
      assert Deck.indexOf(to_test, elem) == elem - 1
    end)

    # check handling of non-existed elements
    assert Deck.indexOf(to_test, -1) == nil
    assert Deck.indexOf(to_test, 20) == nil
  end

  test "[sortCards] check provided cards are sorted correctly" do
    deck = Deck.new() |> Deck.shuffle()

    checkPairs = fn pair ->
      if (length(pair) == 2) do
        card1 = Enum.at(pair, 0)
        card2 = Enum.at(pair, 1)

        # check cards are sorted correctly in suit order
        assert Deck.indexOf(@valid_suits, card1.s) <= Deck.indexOf(@valid_suits, card2.s)

        # check cards are sorted correctly within suit
        if (card1.s == card2.s) do
          assert Deck.indexOf(@valid_ranks, card1.r) <= Deck.indexOf(@valid_ranks, card2.r)
        end
      end
    end

    Enum.each(1..length(deck.cards), fn card_cnt ->
      {_, top_cards} = Deck.takeFromTop(deck, card_cnt)
      sorted_cards = Deck.sortCards(top_cards)
      # make sure no cards disappeared
      assert length(sorted_cards) == length(top_cards)

      # check cards are in order in pairs
      chunks = Enum.chunk_every(sorted_cards, 2)
      Enum.each(chunks, checkPairs)

      # remove first card in list in order to shift array by one
      # this allows to check the rest of the card pairings
      chunks = Enum.chunk_every(Enum.drop(sorted_cards, 1), 2)
      Enum.each(chunks, checkPairs)
    end)
  end
end
