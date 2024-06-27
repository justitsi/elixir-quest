# Learning  notes

Random, unsorted thoughts I've had while working on this project:

- Cannot interchange `'` and `"` like in Python/JS
- No braces are used (even for func params)
- When searching for `elixir template string` on google, found HexDocs:
    - it was the third result! And this is _not_ good because it was by far the most helpful (other options wanted a library which is a turn-off for first-time user)
    - `elixirforum.com` and `stackoverflow.com` came up before it but showed a library solution (`EEx`) instead of a simple language feature (historical reasons?)
- formatter is _really_ good
    - Adds nil where needed for me
- Arrays are confusing/different than JS and Python where you can just pass them and show them no questions asked (see ##Error 1)
- Was using a list not an array; When triying to convert got ##Error 2

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