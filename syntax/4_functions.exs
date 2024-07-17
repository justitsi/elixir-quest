# simple piping together functions
sum_all = fn enum ->
  acc = 0
  Enum.reduce(enum, acc, fn acc, x -> acc + x end)
end

sqrt_all = fn enum ->
  Enum.map(enum, fn x -> :math.sqrt(x) end)
end

generateEnum = fn size ->
  Enum.to_list(1..size)
end

IO.puts(generateEnum.(10) |> sqrt_all.() |> sum_all.())

# pipe together more complex functions
is_palindrome = fn word ->
  # add two to account for leading and trailing white space when converting string to array
  len_orig = String.length(word) + 2

  len =
    if rem(len_orig, 2) == 0 do
      len_orig / 2
    else
      (len_orig - 1) / 2
    end

  len = trunc(len)
  indexes = Enum.to_list(0..(len - 1))

  word = String.split(word, "")

  Enum.reduce(indexes, true, fn x, match ->
    char1 = Enum.at(word, x)
    char2 = Enum.at(word, len_orig - (x + 1))

    if match == true do
      if char1 === char2 do
        match
      else
        false
      end
    else
      false
    end
  end)
end

# using & shorthand
get_words =
  &Enum.map(String.split(&1, " "), fn word ->
    word = String.downcase(word)
  end)

words = "Hello, how are you feeling today oWo eje heheh Lol"

Enum.map(get_words.(words), fn word ->
  status = is_palindrome.(word)
  IO.puts("#{word} palindrome: #{status}")
end)

# multiple returns
mult_returns = fn x, y ->
  {y, x}
end

{z, q} = mult_returns.([1, 2, 3], [4, 5, 6])

IO.puts("#{inspect(z)} - #{inspect(q)}")
