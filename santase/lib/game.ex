defmodule Game do
  require(Deck)
  require(Round)

  defstruct players: [], deck: nil, rounds: []

  def new(p1_name, p2_name) do
    deck = Deck.new()
    %Game{players: [Player.new(p1_name), Player.new(p2_name)], deck: deck}
  end

  def startNewRound(game) do
    if length(game.rounds) == 0 do
      round = Round.new(game.deck, 0)
      %Game{game | rounds: [round], deck: nil}
    else
      # need to handle checking if previous round is finished before creating new one
    end
  end
end
