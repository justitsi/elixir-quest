defmodule Greeter do
  def hello do
    "Hello there, new guy"
  end

  def hello(name) do
    "Hello, " <> name
  end

  def apply_alternate(list, base, fun1, fun2) do
    Enum.map(list, fn i ->
      if rem(i, 2) == 0 do
        fun1.(base, i)
      else
        fun2.(base, i)
      end
    end)
  end
end



IO.puts(Greeter.hello("Itso"))
IO.puts(Greeter.hello())


# try passing anonymous functions as params
# use short-hand declaration for functions
multiply = &(&1*&2)
subtract = &(&1-&2)
list = Enum.to_list(0..100)
res = Greeter.apply_alternate(list, 2, multiply, subtract)
IO.puts(inspect(res))
