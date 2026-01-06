## Bang

A small transpiler for a syntactic skin over [Lua](https://www.lua.org), written in Lua.

```lua
-- example.bang
range = fn(a, limit, step)
  init = limit and a or 1
  limit or= a
  step or= 1
  assert(step != 0)
  it_index, it = 1, init
  return fn()
    if step > 0 and it <= limit or step < 0 and it >= limit
      a, b = it_index, it
      it += step
      it_index += 1
      return a, b!!!

fact = fn(n)
  if n <= 1 return n
  else return n * fact(n - 1)!!

fizzbuzz = fn()
  for range(fact(4))
    result = ""
    if it % 3 == 0  result ..= "Fizz"!
    if it % 5 == 0  result ..= "Buzz"!
    if #result == 0 result ..= tostring(it)!
    print(result)!!

fizzbuzz()

-- $ lua bang.lua -l example.bang
local example = {}
example._M = example
example.range = function(a, limit, step)
  local init = limit and a or 1
  limit = limit or (a)
  step = step or (1)
  assert(step ~= 0)
  local it_index, it = 1, init
  return function()
    if step > 0 and it <= limit or step < 0 and it >= limit then
      local a, b = it_index, it
      it = it + (step)
      it_index = it_index + (1)
      return a, b
    end
  end
end
example.fact = function(n)
  if n <= 1 then
    return n
  else
    return n * example.fact(n - 1)
  end
end
example.fizzbuzz = function()
  for it_index, it in example.range(example.fact(4)) do
    local result = ""
    if it % 3 == 0 then
      result = result .. ("Fizz")
    end
    if it % 5 == 0 then
      result = result .. ("Buzz")
    end
    if #result == 0 then
      result = result .. (tostring(it))
    end
    print(result)
  end
end
example.fizzbuzz()
return example
```

## Differences from Lua

- Block terminator is `!` instead of `end`.
- Arrays (`[1, 2, 3]`) are distinct from tables (`{x, y=z, ["w"]=5}`).
- Variables are locally namespaced (`x` => `module_name.x`).
- Modules return their local namespace (`return module_name`).
- Functions (`fn`) are expressions only, not statements.
- Assignment operators are C-like (`x += y` => `x = x + (y)`), and include `and=`/`or=`/`..=`.
- Implicit variables `it` and `it_index` are used in `for` loops.
- Range based `for` loops do not exist.
- Table indexing uses a period (`t.[index]` => `t[index]`).
- Module scope variables can be reassigned (`_M.index = value`).
- Keywords `do` and `then` are not used for control flow.
- Keyword `elseif` is shortened to `elif`.
- Operator "not equal" is `!=`.

## License

```
MIT License

Copyright (c) Dawson Frakes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
