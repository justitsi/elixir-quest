# Learning  notes

Random, unsorted thoughts I've had while working on this project:

- Cannot interchange `'` and `"` like in Python/JS
- No braces are used (even for func params)
- When searching for `elixir template string` on google, found HexDocs:
    - it was the third result! And this is _not_ good because it was by far the most helpful (other options wanted a library which is a turn-off for first-time user)
    - `elixirforum.com` and `stackoverflow.com` came up before it but showed a library solution (`EEx`) instead of a simple language feature (historical reasons?)
- formatter is _really_ good
    - Adds nil where needed for me in empty functions
- Arrays are confusing/different than JS and Python where you can just pass them and show them no questions asked (see ##Error 1)
- Was using a list not an array; When triying to convert got ##Error 2
- List concatenation and subtraction operators are really cool
- Finding lack of for/while loops slightly problematic, but I can see the benefit of not having loops managed by the programmer; This is a high level language for a specific use which is not math and memory tricks :P
- Wrote a small benchmark (`/syntax/enums.exs`) and did not see any performance difference between `.ex` and `.exs` files.
- Tutorials on pattern matching (on hexdocs and elixirschool) only show how to use it in interpreter; Had read joyofelixir.com and this (elixirforum post)[https://elixirforum.com/t/recursive-anonymous-functions/18421/3] to figure out how to do anonymous function recursion with pattern matching
- Recursion seems to be _quite_ slow
- Annoying that string to_lowercase and to_uppercase are called something else - what else is named weird?
- So far I find myself writing a map function when I should be writing a reduction quite often - maybe some more explanation/training on that would be helpful (judging learning elixir)

## Error 1
when printing by index:
```
** (ArgumentError) the Access module does not support accessing lists by index, got: 0
```
when printing all of it:
```
    ** (ArgumentError) cannot convert the given list to a string.
        To be converted to a string, a list must either be empty or only
    contain the following elements:

    * strings
    * integers representing Unicode code points
    * a list containing one of these three elements
```

## Error 2
```
** (UndefinedFunctionError) function Arrays.new/1 is undefined (module Arrays is not available)
    Arrays.new([-1.0, -1.5])
    syntax/basic.exs:38: (file)
```