defmodule Deck do
  require(Card)
  @valid_ranks ["9", "J", "Q", "K", "10", "A"]
  @valid_suits ["C", "D", "H", "S"]

  defstruct cards: []

  def new() do
    new_cards =
      Enum.map(@valid_suits, fn suit ->
        Enum.map(@valid_ranks, fn rank ->
          %Card{r: rank, s: suit, pnts: Card.getPoints(rank)}
        end)
      end)

    new_cards = List.flatten(new_cards)
    new_cards = Enum.reverse(new_cards)

    %Deck{cards: new_cards}
  end

  def shuffle(deck) do
    new_cards = Enum.shuffle(deck.cards)
    %Deck{deck | cards: new_cards}
  end

  def takeFromTop(deck, count) do
    top_cards = []

    if count > 0 do
      if count >= length(deck.cards) do
        {%Deck{cards: []}, deck.cards}
      else
        # get top cards
        top_cards =
          Enum.map(Enum.to_list(0..(count - 1)), fn i ->
            Enum.at(deck.cards, i)
          end)

        # keep only cards not in hand
        new_cards =
          Enum.map(Enum.to_list(count..(length(deck.cards) - 1)), fn i ->
            Enum.at(deck.cards, i)
          end)

        deck = %Deck{deck | cards: new_cards}
        {deck, top_cards}
      end
    else
      {deck, top_cards}
    end
  end

  def addToTop(deck, cards) do
    # check for duplicates
    if length(cards) > 0 do
      valid =
        Enum.reduce_while(deck.cards, true, fn deck_card, _ ->
          valid_tmp =
            Enum.reduce_while(cards, true, fn add_card, _ ->
              if deck_card.r == add_card.r and deck_card.s == add_card.s do
                {:halt, false}
              else
                {:cont, true}
              end
            end)

          if valid_tmp do
            {:cont, true}
          else
            {:halt, false}
          end
        end)

      if valid do
        new_cards = [cards | deck.cards]
        new_cards = List.flatten(new_cards)
        %Deck{deck | cards: new_cards}
      else
        {:error, "Duplicate card found in deck and cards"}
      end
    else
      deck
    end
  end

  def split(deck, card_index) do
    if card_index >= 0 and card_index < length(deck.cards) do
      part1 = Enum.slice(deck.cards, 0, card_index)
      part2 = Enum.slice(deck.cards, card_index, length(deck.cards))
      new_cards = part2 ++ part1
      %Deck{deck | cards: new_cards}
    else
      {:error, "Split index needs to satisfy 0 <= card_index < length(deck.cards)"}
    end
  end

  # seriously why is this not a built in func
  def indexOf(arr, elem) do
    if not Enum.any?(arr, fn tmp -> tmp == elem end) do
      nil
    else
      Enum.with_index(arr) |> Enum.find(fn {char, index} -> char == elem end) |> elem(1)
    end
  end

  def sortCards(cards) do
    Enum.sort(cards, fn c1, c2 ->
      # get suit indexes
      c1_s_i = indexOf(@valid_suits, c1.s)
      c2_s_i = indexOf(@valid_suits, c2.s)

      if c1_s_i == c2_s_i do
        c1_r_i = indexOf(@valid_ranks, c1.r)
        c2_r_i = indexOf(@valid_ranks, c2.r)

        cond do
          c1_r_i >= c2_r_i -> false
          c1_r_i < c2_r_i -> true
        end
      else
        cond do
          c1_s_i > c2_s_i -> false
          c1_s_i < c2_s_i -> true
        end
      end
    end)
  end
end
