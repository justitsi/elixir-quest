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
