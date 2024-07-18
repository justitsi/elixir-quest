defmodule Player do
  require(Deck)
  defstruct name: ""

  def new (p_name) do
    %Player{name: p_name}
  end
end
