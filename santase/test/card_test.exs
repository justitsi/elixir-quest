defmodule CardTest do
  use ExUnit.Case
  doctest Card

  require(Card)
  @deck_ranks [["9", 0], ["J", 3], ["Q", 4], ["K", 5], ["10", 10], ["A", 11]]

  test "sets card point value" do
    Enum.map(@deck_ranks, fn entry ->
      assert Card.getPoints(Enum.at(entry, 0)) == Enum.at(entry, 1)
    end)
  end

  test "unregistered rank falls through to zero" do
    assert Card.getPoints("7") == 0
    assert Card.getPoints("8") == 0
    assert Card.getPoints("Z") == 0
    assert Card.getPoints("ZzZzzZzzZ") == 0
  end
end
