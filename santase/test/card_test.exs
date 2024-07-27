defmodule CardTest do
  use ExUnit.Case
  doctest Card

  @deck_ranks [["9", 0], ["J", 3], ["Q", 4], ["K", 5], ["10", 10], ["A", 11]]

  test "sets card point value" do
    Enum.map(@deck_ranks, fn entry ->
      assert Card.get_points(Enum.at(entry, 0)) == Enum.at(entry, 1)
    end)
  end

  test "unregistered rank falls through to nil" do
    assert Card.get_points("7") == nil
    assert Card.get_points("8") == nil
    assert Card.get_points("Z") == nil
    assert Card.get_points("ZzZzzZzzZ") == nil
  end
end
