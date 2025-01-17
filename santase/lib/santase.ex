defmodule Santase do
  require(Game)

  @moduledoc """
  Documentation for `Santase`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Santase.hello()
      :world

  """
  def hello do
    :world
  end

  def start(_type, _args) do
      game = Game.new("p1", "p2")
      # IO.puts("#{inspect(game)} \n")

      game = Game.start_new_round(game)
      # IO.puts("#{inspect(game)}")

      options = Game.get_player_options(game)
      IO.puts("#{inspect(options)}")



    Supervisor.start_link [], strategy: :one_for_one
  end
end
