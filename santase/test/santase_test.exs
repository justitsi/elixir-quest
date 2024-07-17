defmodule SantaseTest do
  use ExUnit.Case
  doctest Santase

  test "greets the world" do
    assert Santase.hello() == :world
  end
end
