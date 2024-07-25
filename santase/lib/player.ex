defmodule Player do
  require(Deck)
  defstruct name: "", id: 0

  def new (p_name) do
    %Player{name: p_name}
  end
end
