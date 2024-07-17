defmodule Card do
  @deck_ranks [["9", 0], ["J", 3], ["Q", 4], ["K", 5], ["10", 10], ["A", 11]]

  defstruct r: -1, s: -1, pnts: 0

  def getPoints(rank) do
    Enum.reduce_while(@deck_ranks, 0, fn entry, _ ->
      if rank == Enum.at(entry, 0) do
        {:halt, Enum.at(entry, 1)}
      else
        {:cont, 0}
      end
    end)
  end
end
