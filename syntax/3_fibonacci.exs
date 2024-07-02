fib_num = 40

# recursive fibonacci finder
# have to pass function reference as param as it is anonymous func
fib = fn
  _, x = 0 -> 0
  _, x = 1 -> 1
  cb, x -> cb.(cb, x - 1) + cb.(cb, x - 2)
end

# now do this with case rather than pattern matching
fib_case = fn cb, x ->
  case {x} do
    {0} -> 0
    {1} -> 1
    _ -> cb.(cb, x - 1) + cb.(cb, x - 2)
  end
end

# now do this with if-else rather than case
fib_if = fn cb, x ->
  if x > 1 do
    cb.(cb, x - 1) + cb.(cb, x - 2)
  else
    if x == 1 do
      1
    else
      0
    end
  end
end

# try to do this with map data structure
fib_loop = fn num ->

  # init map for first two numbers
  fib_map = %{1 => 1, 2 => 1}
  nums = Enum.to_list(3..num)

  # reduce over indexes that need to be checked
  # use fib_map to store results between iterations
  fib_map =
    Enum.reduce(nums, fib_map, fn num, fib_map ->
      value = fib_map[num - 1] + fib_map[num - 2]
      fib_map = Map.put(fib_map, num, value)
    end)

  fib_map
end

IO.puts("Fibonacci number to find at #{fib_num}")

{time_in_microsec, res_rec} = :timer.tc(fn -> fib.(fib, fib_num) end)
IO.puts("(#{time_in_microsec} us) Recursive implementation #{res_rec}")

{time_in_microsec, res_map} = :timer.tc(fn -> fib_loop.(fib_num) end)
IO.puts("(#{time_in_microsec} us) Reduce map implementation: #{res_map[fib_num]}")
