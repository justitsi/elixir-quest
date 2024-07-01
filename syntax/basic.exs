# how to print vars
hello = "hello world"
IO.puts(hello)

# check out arithmetic
a = 5
b = 4
c = a + b
IO.puts(c)

# does it have template strings? - no it has _interpolation_ - weird name, huh?
IO.puts("The sum of A and B is #{c}")

# lets check out the order of operations
# Note: variables are not immutable like in erlang
# Note: cannot increment with +=
a = a + 72 / (3 * 3)
IO.puts("A is #{a} and should be #{13}")

# how to make functions
increment = fn n -> n + 1 end
# calling functions with <fun_name>.(args)
a = increment.(a)
IO.puts("A is #{a} and should be #{14}")

# func with multiple args
add = fn a, b -> a + b end
a = add.(a, 14)
IO.puts("A is #{a} and should be #{28}")

# func with multiple statements
# multiple return values packed in array for simplicity
quadratic = fn a, b, c ->
  sub_expr = :math.sqrt(:math.pow(b, 2) - 4 * a * c)
  x1 = (-b + sub_expr) / (2 * a)
  x2 = (-b - sub_expr) / (2 * a)
  # this implicit return is weird
  [x1, x2]
end

# why do I call my functions with fun.(...) and pre-build functions with fun(...) (no extra dot)?
answers = quadratic.(2, 5, 3)

# IO.puts("Answers are #{answers}") -> doesn't work!
# works - but why is inspect needed?
IO.puts("Answers are #{inspect(answers)}")

# how to use lists/collections properly
list =  Enum.to_list(2..4)
IO.puts("Initial list is #{inspect(list)}")

# prepend - two different ways
list = [1] ++ list
list = [0 | list]

IO.puts("Update 1 to list is #{inspect(list)}")

# append - only one way?
list = list ++ [5]

IO.puts("Update 2 to list is #{inspect(list)}")
