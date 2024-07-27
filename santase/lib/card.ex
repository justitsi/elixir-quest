defmodule Card do
  @deck_ranks %{"9" => 0, "J" => 3, "Q" => 4, "K" => 5, "10" => 10, "A" => 11}
  defstruct r: -1, s: -1, pnts: nil

  def get_points(rank), do: @deck_ranks[rank]
end
