defmodule Game do
  require(Deck)
  require(Round)

  defstruct players: [], deck: nil, rounds: []

  def new(p1_name, p2_name) do
    deck = Deck.new()
    %Game{players: [Player.new(p1_name), Player.new(p2_name)], deck: deck}
  end

  def startNewRound(game) do
    round = Round.new(game.deck, getNextRoundStartingPlayer(game))
    %Game{game | rounds: [round], deck: nil}
  end

  def getPlayerOptions(game) do
    current_round = getCurrentRound(game)
    %{
      card_options: Round.getPlayerCardOptions(current_round),
      premium_options: Round.getPlayerPremiumOptions(current_round),
      p_turn: current_round.p_turn
    }
  end

  def getCurrentRound(game) do
    Enum.at(game.rounds, 0)
  end

  def getNextRoundStartingPlayer(game) do
    if length(game.rounds) == 0 do
      0
    else
      # TODO: make this return the winner of the last round
      1
    end
  end
end
