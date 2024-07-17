defmodule Santase do
  require(Deck)

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
    deck = Deck.new()
    # IO.puts(inspect(deck))
    # deck = Deck.shuffle(deck)
    # IO.puts("\n")
    # IO.puts(inspect(deck))
    # IO.puts("\n")

    # IO.puts(length(deck.cards))

    {deck, top_cards} = Deck.takeFromTop(deck, 3)

    # IO.puts("#{length(deck.cards)}, #{length(top_cards)}")

    # IO.puts("#{inspect(top_cards)}")
    # IO.puts("\n")
    # IO.puts(inspect(deck))
    # IO.puts("\n")
    # IO.puts(inspect(deck.cards))

    deck = Deck.addToTop(deck, top_cards)
    IO.puts(inspect(deck))
    IO.puts("\n")

    deck = Deck.addToTop(deck, top_cards)
    IO.puts(inspect(deck))

    Supervisor.start_link [], strategy: :one_for_one
  end
end
