fib_num = 10

# recursive fibonacci finder
fib = fn
  _, x = 0 -> 0
  _, x = 1 -> 1
  cb, x -> cb.(cb, x - 1) + cb.(cb, x - 2)
end

# this is very ugly
# have to pass function reference as param as it is anonymous func
res_rec = fib.(fib, fib_num)
IO.puts("Fib number at #{fib_num} is #{res_rec}")

# now do this with case rather than pattern matching
fib_case = fn cb, x ->
  case {x} do
    {0} -> 0
    {1} -> 1
    _ -> cb.(cb, x - 1) + cb.(cb, x - 2)
  end
end

res_case = fib_case.(fib_case, fib_num)
IO.puts("Case implementation result #{res_case}")

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

res_if = fib_if.(fib_if, fib_num)
IO.puts("if-else implementation result #{res_if}")
