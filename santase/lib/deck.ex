defmodule Deck do
  @valid_ranks ~w(9 J Q K 10 A)
  @valid_suits ~w(C D H S)

  @suit_weights @valid_suits |> Enum.with_index() |> Map.new()
  @rank_weights @valid_ranks |> Enum.with_index() |> Map.new()

  defstruct cards: []

  def new() do
    new_cards =
      for suit <- @valid_suits, rank <- @valid_ranks do
        %Card{r: rank, s: suit, pnts: Card.get_points(rank)}
      end
      |> List.flatten()
      |> Enum.reverse()

    %Deck{cards: new_cards}
  end

  def shuffle(deck), do: %Deck{deck | cards: Enum.shuffle(deck.cards)}

  def take_from_top(deck, count) do
    {top_cards, new_cards} = Enum.split(deck.cards, count)
    {%Deck{deck | cards: new_cards}, top_cards}
  end

  def add_to_top(deck, cards) do
    # check for duplicates
    combined_list = cards ++ deck.cards
    unique_list = Enum.uniq(combined_list)
    valid = length(combined_list) == length(unique_list)

    cond do
      valid == true -> %Deck{deck | cards: combined_list}
      valid == false -> {:error, "Duplicate card found in deck and cards"}
    end
  end

  def split(deck, card_index) when card_index >= 0 and card_index < length(deck.cards) do
    {part1, part2} = Enum.split(deck.cards, card_index)
    %Deck{deck | cards: part2 ++ part1}
  end

  def split(_, _),
    do: {:error, "Split index needs to satisfy 0 <= card_index < length(deck.cards)"}

  def index_of(arr, elem) do
    if not Enum.any?(arr, fn tmp -> tmp == elem end) do
      nil
    else
      Enum.with_index(arr) |> Enum.find(fn {char, _index} -> char == elem end) |> elem(1)
    end
  end

  # determines if card2 is stronger than card1, assumes card2 was placed after card1
  def is_stronger(card1, card2, trump_suit) do
    # if both cards are of same suit need to perform full checks
    if card1.s == card2.s do
      card1_index = index_of(@valid_ranks, card1.r)
      card2_index = index_of(@valid_ranks, card2.r)

      cond do
        card1_index < card2_index -> true
        card1_index > card2_index -> false
        card1_index == card2_index -> {:error, "Duplicate cards"}
      end
    else
      # check if either player is trumping
      if card1.s == trump_suit or card2.s == trump_suit do
        cond do
          card1.s == trump_suit and card2.s != trump_suit -> false
          card1.s != trump_suit and card2.s == trump_suit -> true
        end
      else
        # if no one is trumping and player2 did not respond to player1 then p1 wins
        false
      end
    end
  end

  # wrapper for is_stronger that allows for setting which player (0 or 1) played first
  def is_stronger_with_first(cards_list, p_started, t_suit)
      when p_started == 0 or p_started == 1 do
    is_stronger(
      Enum.at(cards_list, rem(p_started, 2)),
      Enum.at(cards_list, rem(p_started + 1, 2)),
      t_suit
    )
  end

  # Use sort_by to build a tuple and sort it naturally
  def sort_cards(cards) do
    Enum.sort_by(cards, fn card -> {@suit_weights[card.s], @rank_weights[card.r]} end)
  end
end
