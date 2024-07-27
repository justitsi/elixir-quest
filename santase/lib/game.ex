defmodule Game do
  require(Deck)
  require(Round)

  defstruct players: [], deck: nil, rounds: []

  def new(p1_name, p2_name) do
    deck = Deck.new()
    %Game{players: [Player.new(p1_name), Player.new(p2_name)], deck: deck}
  end

  def start_new_round(game) do
    round = Round.new(game.deck, get_next_round_starting_player(game))
    %Game{game | rounds: [round], deck: nil}
  end

  def get_player_options(game) do
    current_round = get_current_round(game)
    %{
      card_options: Round.get_player_card_options(current_round),
      premium_options: Round.get_player_premium_options(current_round),
      other_options: Round.get_player_other_options(current_round),
      p_turn: Enum.at(game.players, current_round.p_turn)
    }
  end

  def get_current_round(game) do
    Enum.at(game.rounds, 0)
  end

  def get_next_round_starting_player(game) do
    if length(game.rounds) == 0 do
      0
    else
      # TODO: make this return the winner of the last round
      1
    end
  end
end
