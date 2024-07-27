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
    combined_list = List.flatten([cards ++ deck.cards])
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

  # Use sort_by to build a tuple and sort it naturally
  def sort_cards(cards) do
    Enum.sort_by(cards, fn card -> {@suit_weights[card.s], @rank_weights[card.r]} end)
  end
end
