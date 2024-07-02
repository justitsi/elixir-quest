# create enum
main = fn ->

  chunk_size = 100
  chunk_cnt = 30

  checkIsSquared = fn x ->
    tmp = trunc(:math.sqrt(x))
    :math.pow(tmp, 2) == x
  end

  createRange = fn n ->
    tmp = Enum.to_list((n * chunk_size + 1)..((n + 1) * chunk_size))
    Enum.filter(tmp, checkIsSquared)
  end


  chunks = Enum.to_list(0..chunk_cnt-1) # uses inclusive range
  chunks = Enum.map(chunks, createRange)
  # IO.puts("Chunks are #{inspect(chunks)}")

  list = List.flatten(chunks)
  IO.puts("List is #{inspect(list)}")

  # multiple = Enum.reduce(list, 1, fn(x, acc) -> x * acc end)
  # IO.puts("Multiple is #{multiple}")
end

# main.()
{time_in_microsec, _} =
  :timer.tc(fn -> main.() end)

IO.puts("Exec time is #{time_in_microsec}")
