local bang = {}

function bang.is_space(c) return c == ' ' or c == '\t' or c == '\n' or c == '\r' end
function bang.is_alpha(c) return 'a' <= c:lower() and c:lower() <= 'z' end
function bang.is_digit(c) return '0' <= c and c <= '9' end
function bang.is_alnum(c) return bang.is_alpha(c) or bang.is_digit(c) end
function bang.is_punct(c) return c == '.' or c == ':' or c == ',' or c == '=' or c == '#' or c == '!' or c == '(' or c == ')' or c == '[' or c == ']' or c == '{' or c == '}' or c == '<' or c == '>' or c == '+' or c == '-' or c == '*' or c == '/' or c == '%' or c == '&' or c == '|' or c == '~' or c == '^' end

bang.TokenKind = {}
bang.TokenKind.END_OF_INPUT = 128
bang.TokenKind.IDENTIFIER = 129
bang.TokenKind.NUMBER = 130
bang.TokenKind.STRING = 131
bang.TokenKind.DOTDOT = 148
bang.TokenKind.COLONCOLON = 149
bang.TokenKind.LTEQ = 150
bang.TokenKind.GTEQ = 151
bang.TokenKind.EQEQ = 152
bang.TokenKind.BANGEQ = 153
bang.TokenKind.PLUSEQ = 154
bang.TokenKind.DASHEQ = 155
bang.TokenKind.STAREQ = 156
bang.TokenKind.SLASHEQ = 157
bang.TokenKind.PERCENTEQ = 158
bang.TokenKind.AMPEQ = 159
bang.TokenKind.PIPEEQ = 160
bang.TokenKind.LTLT = 161
bang.TokenKind.GTGT = 162
bang.TokenKind.DOTDOTEQ = 171
bang.TokenKind.LTLTEQ = 172
bang.TokenKind.GTGTEQ = 173
bang.TokenKind.DOTDOTDOT = 174
bang.TokenKind.ANDEQ = 175
bang.TokenKind.OREQ = 176
bang.TokenKind.CARETEQ = 177
bang.TokenKind.KW_while = 192
bang.TokenKind.KW_true = 193
bang.TokenKind.KW_false = 194
bang.TokenKind.KW_nil = 195
bang.TokenKind.KW_return = 196
bang.TokenKind.KW_fn = 197
bang.TokenKind.KW_if = 198
bang.TokenKind.KW_elif = 199
bang.TokenKind.KW_else = 200
bang.TokenKind.KW_and = 201
bang.TokenKind.KW_or = 202
bang.TokenKind.KW_not = 203
bang.TokenKind.KW_for = 204
bang.TokenKind.KW_do = 205
bang.TokenKind.KW_break = 206
bang.TokenKind.KW_goto = 207

function bang.token_at(s, p)
  while true do
    while p <= #s and bang.is_space(s:sub(p, p)) do p = p + 1 end
    if p + 1 <= #s and s:sub(p, p + 1) == "--" then
      while p <= #s and s:sub(p, p) ~= '\n' do p = p + 1 end
      goto continue
    end
    do break end
    ::continue::
  end
  if p > #s then return {kind=bang.TokenKind.END_OF_INPUT, offset=p, length=0} end
  local start = p
  if p + 3 <= #s and s:sub(p, p + 3) == "and=" then return {kind=bang.TokenKind.ANDEQ, offset=start, length=4} end
  if p + 2 <= #s and s:sub(p, p + 2) == "or=" then return {kind=bang.TokenKind.OREQ, offset=start, length=3} end
  if bang.is_alpha(s:sub(p, p)) or s:sub(p, p) == '_' then
    while p <= #s and (bang.is_alnum(s:sub(p, p)) or s:sub(p, p) == '_') do p = p + 1 end
    local test = s:sub(start, p - 1)
    if test == "while" then return {kind=bang.TokenKind.KW_while, offset=start, length=#test} end
    if test == "true" then return {kind=bang.TokenKind.KW_true, offset=start, length=#test} end
    if test == "false" then return {kind=bang.TokenKind.KW_false, offset=start, length=#test} end
    if test == "nil" then return {kind=bang.TokenKind.KW_nil, offset=start, length=#test} end
    if test == "return" then return {kind=bang.TokenKind.KW_return, offset=start, length=#test} end
    if test == "fn" then return {kind=bang.TokenKind.KW_fn, offset=start, length=#test} end
    if test == "if" then return {kind=bang.TokenKind.KW_if, offset=start, length=#test} end
    if test == "elif" then return {kind=bang.TokenKind.KW_elif, offset=start, length=#test} end
    if test == "else" then return {kind=bang.TokenKind.KW_else, offset=start, length=#test} end
    if test == "and" then return {kind=bang.TokenKind.KW_and, offset=start, length=#test} end
    if test == "or" then return {kind=bang.TokenKind.KW_or, offset=start, length=#test} end
    if test == "not" then return {kind=bang.TokenKind.KW_not, offset=start, length=#test} end
    if test == "for" then return {kind=bang.TokenKind.KW_for, offset=start, length=#test} end
    if test == "do" then return {kind=bang.TokenKind.KW_do, offset=start, length=#test} end
    if test == "break" then return {kind=bang.TokenKind.KW_break, offset=start, length=#test} end
    if test == "goto" then return {kind=bang.TokenKind.KW_goto, offset=start, length=#test} end
    return {kind=bang.TokenKind.IDENTIFIER, offset=start, length=p - start}
  end
  if bang.is_digit(s:sub(p, p)) then
    while p <= #s and bang.is_digit(s:sub(p, p)) do p = p + 1 end
    return {kind=bang.TokenKind.NUMBER, offset=start, length=p - start}
  end
  if s:sub(p, p) == '"' then
    p = p + 1
    while p <= #s and (((p - 2 < 0 or s:sub(p - 2, p - 2) ~= '\\') and s:sub(p - 1, p - 1)) == '\\' or s:sub(p, p) ~= '"') and s:sub(p, p) ~= '\n' do p = p + 1 end
    if p > #s or s:sub(p, p) ~= '"' then error("unterminated string literal.") end
    p = p + 1
    return {kind=bang.TokenKind.STRING, offset=start, length=p - start}
  end
  if p + 1 <= #s and s:sub(p, p + 1) == "[[" then
    while p + 1 <= #s and s:sub(p, p + 1) ~= "]]" do p = p + 1 end
    if p + 1 > #s then error("unterminated string literal.") end
    p = p + 2
    return {kind=bang.TokenKind.STRING, offset=start, length=p - start}
  end
  if p + 2 <= #s then
    if s:sub(p, p + 2) == "..=" then return {kind=bang.TokenKind.DOTDOTEQ, offset=start, length=3} end
    if s:sub(p, p + 2) == "<<=" then return {kind=bang.TokenKind.LTLTEQ, offset=start, length=3} end
    if s:sub(p, p + 2) == ">>=" then return {kind=bang.TokenKind.GTGTEQ, offset=start, length=3} end
    if s:sub(p, p + 2) == "..." then return {kind=bang.TokenKind.DOTDOTDOT, offset=start, length=3} end
  end
  if p + 1 <= #s then
    if s:sub(p, p + 1) == "<=" then return {kind=bang.TokenKind.LTEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == ">=" then return {kind=bang.TokenKind.GTEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "==" then return {kind=bang.TokenKind.EQEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "!=" then return {kind=bang.TokenKind.BANGEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "+=" then return {kind=bang.TokenKind.PLUSEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "-=" then return {kind=bang.TokenKind.DASHEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "*=" then return {kind=bang.TokenKind.STAREQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "/=" then return {kind=bang.TokenKind.SLASHEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "%=" then return {kind=bang.TokenKind.PERCENTEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "&=" then return {kind=bang.TokenKind.AMPEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "|=" then return {kind=bang.TokenKind.PIPEEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "^=" then return {kind=bang.TokenKind.CARETEQ, offset=start, length=2} end
    if s:sub(p, p + 1) == "<<" then return {kind=bang.TokenKind.LTLT, offset=start, length=2} end
    if s:sub(p, p + 1) == ">>" then return {kind=bang.TokenKind.GTGT, offset=start, length=2} end
    if s:sub(p, p + 1) == ".." then return {kind=bang.TokenKind.DOTDOT, offset=start, length=2} end
    if s:sub(p, p + 1) == "::" then return {kind=bang.TokenKind.COLONCOLON, offset=start, length=2} end
  end
  if bang.is_punct(s:sub(p, p)) then return {kind=s:byte(p), offset=start, length=1} end
  error("unknown token entrant '"..s:sub(p, p).."'.")
end

function bang.print_all_tokens(src)
  local pos = 1
  while true do
    local token = bang.token_at(src, pos)
    if token.kind == bang.TokenKind.END_OF_INPUT then break end
    pos = token.offset + token.length
    print(token.kind, src:sub(token.offset, token.offset + token.length - 1))
  end
end

bang.PRECEDENCE = {}
for i = 1, 256 do table.insert(bang.PRECEDENCE, 0) end
bang.PRECEDENCE[bang.TokenKind.PLUSEQ] = 1
bang.PRECEDENCE[bang.TokenKind.DASHEQ] = 1
bang.PRECEDENCE[bang.TokenKind.STAREQ] = 1
bang.PRECEDENCE[bang.TokenKind.SLASHEQ] = 1
bang.PRECEDENCE[bang.TokenKind.PERCENTEQ] = 1
bang.PRECEDENCE[bang.TokenKind.AMPEQ] = 1
bang.PRECEDENCE[bang.TokenKind.PIPEEQ] = 1
bang.PRECEDENCE[bang.TokenKind.CARETEQ] = 1
bang.PRECEDENCE[bang.TokenKind.LTLTEQ] = 1
bang.PRECEDENCE[bang.TokenKind.GTGTEQ] = 1
bang.PRECEDENCE[bang.TokenKind.DOTDOTEQ] = 1
bang.PRECEDENCE[bang.TokenKind.ANDEQ] = 1
bang.PRECEDENCE[bang.TokenKind.OREQ] = 1
bang.PRECEDENCE[bang.TokenKind.KW_or] = 2
bang.PRECEDENCE[bang.TokenKind.KW_and] = 3
bang.PRECEDENCE[string.byte('<')] = 4
bang.PRECEDENCE[string.byte('>')] = 4
bang.PRECEDENCE[bang.TokenKind.LTEQ] = 4
bang.PRECEDENCE[bang.TokenKind.GTEQ] = 4
bang.PRECEDENCE[bang.TokenKind.EQEQ] = 4
bang.PRECEDENCE[bang.TokenKind.BANGEQ] = 4
bang.PRECEDENCE[string.byte('|')] = 5
bang.PRECEDENCE[string.byte('&')] = 6
bang.PRECEDENCE[bang.TokenKind.LTLT] = 7
bang.PRECEDENCE[bang.TokenKind.GTGT] = 7
bang.PRECEDENCE[bang.TokenKind.DOTDOT] = 8
bang.PRECEDENCE[string.byte('+')] = 9
bang.PRECEDENCE[string.byte('-')] = 9
bang.PRECEDENCE[string.byte('*')] = 10
bang.PRECEDENCE[string.byte('/')] = 10
bang.PRECEDENCE[string.byte('%')] = 10
bang.PRECEDENCE[string.byte('^')] = 11

bang.ASSIGNS = {}
bang.ASSIGNS["+="] = true
bang.ASSIGNS["-="] = true
bang.ASSIGNS["*="] = true
bang.ASSIGNS["/="] = true
bang.ASSIGNS["%="] = true
bang.ASSIGNS["&="] = true
bang.ASSIGNS["|="] = true
bang.ASSIGNS["^="] = true
bang.ASSIGNS["<<="] = true
bang.ASSIGNS[">>="] = true
bang.ASSIGNS["..="] = true
bang.ASSIGNS["and="] = true
bang.ASSIGNS["or="] = true

function bang.peek(P, n)
  n = n or 1
  assert(n > 0)
  local token = nil
  local p = P.pos
  for i = 1, n do
    token = bang.token_at(P.src, p)
    p = token.offset + token.length
  end
  assert(token ~= nil)
  return token
end

function bang.eat(P, expect)
  local token = bang.token_at(P.src, P.pos)
  if expect ~= token.kind then error("expected "..expect..", got "..token.kind..".") end
  P.pos = token.offset + token.length
  return token
end

function bang.parse_leaf(P)
  local result = nil
  if bang.peek(P).kind == bang.TokenKind.IDENTIFIER then
    local token = bang.eat(P, bang.TokenKind.IDENTIFIER)
    result = {tag="ast", kind="ref", ref=P.src:sub(token.offset, token.offset + token.length - 1)}
  elseif bang.peek(P).kind == bang.TokenKind.NUMBER then
    local token = bang.eat(P, bang.TokenKind.NUMBER)
    result = {tag="ast", kind="num", num=P.src:sub(token.offset, token.offset + token.length - 1)}
  elseif bang.peek(P).kind == bang.TokenKind.STRING then
    local token = bang.eat(P, bang.TokenKind.STRING)
    result = {tag="ast", kind="str", str=P.src:sub(token.offset, token.offset + token.length - 1)}
  elseif bang.peek(P).kind == bang.TokenKind.KW_true then
    local token = bang.eat(P, bang.TokenKind.KW_true)
    result = {tag="ast", kind="bool", bool=true}
  elseif bang.peek(P).kind == bang.TokenKind.KW_false then
    local token = bang.eat(P, bang.TokenKind.KW_false)
    result = {tag="ast", kind="bool", bool=false}
  elseif bang.peek(P).kind == bang.TokenKind.KW_nil then
    local token = bang.eat(P, bang.TokenKind.KW_nil)
    result = {tag="ast", kind="nil"}
  elseif bang.peek(P).kind == bang.TokenKind.COLONCOLON then
    bang.eat(P, bang.TokenKind.COLONCOLON)
    local token = bang.eat(P, bang.TokenKind.IDENTIFIER)
    bang.eat(P, bang.TokenKind.COLONCOLON)
    result = {tag="ast", kind="label", label=P.src:sub(token.offset, token.offset + token.length - 1)}
  elseif bang.peek(P).kind == bang.TokenKind.DOTDOTDOT then
    local token = bang.eat(P, bang.TokenKind.DOTDOTDOT)
    result = {tag="ast", kind="varargs"}
  elseif bang.peek(P).kind == string.byte('#') then
    bang.eat(P, string.byte('#'))
    local expr = bang.parse_expr(P)
    result = {tag="ast", kind="unaryop", op="#", expr=expr}
  elseif bang.peek(P).kind == string.byte('-') then
    bang.eat(P, string.byte('-'))
    local expr = bang.parse_expr(P)
    result = {tag="ast", kind="unaryop", op="-", expr=expr}
  elseif bang.peek(P).kind == bang.TokenKind.KW_not then
    bang.eat(P, bang.TokenKind.KW_not)
    local expr = bang.parse_expr(P)
    result = {tag="ast", kind="unaryop", op="not", expr=expr}
  elseif bang.peek(P).kind == string.byte('(') then
    bang.eat(P, string.byte('('))
    result = bang.parse_expr(P)
    bang.eat(P, string.byte(')'))
  elseif bang.peek(P).kind == string.byte('[') then
    bang.eat(P, string.byte('['))
    local args = {}
    while bang.peek(P).kind ~= string.byte(']') do
      table.insert(args, bang.parse_expr(P))
      if bang.peek(P).kind == string.byte(',') then bang.eat(P, string.byte(','))
      else break end
    end
    bang.eat(P, string.byte(']'))
    result = {tag="ast", kind="array", args=args}
  elseif bang.peek(P).kind == string.byte('{') then
    bang.eat(P, string.byte('{'))
    local args = {}
    while bang.peek(P).kind ~= string.byte('}') do
      if bang.peek(P).kind == bang.TokenKind.IDENTIFIER and (bang.peek(P, 2).kind == string.byte(',') or bang.peek(P, 2).kind == string.byte('}')) then
        local token = bang.eat(P, bang.TokenKind.IDENTIFIER)
        local name = {tag="ast", kind="str", str='"'..P.src:sub(token.offset, token.offset + token.length - 1)..'"'}
        local value = {tag="ast", kind="ref", ref=P.src:sub(token.offset, token.offset + token.length - 1)}
        table.insert(args, {name, value})
      elseif bang.peek(P).kind == bang.TokenKind.IDENTIFIER and bang.peek(P, 2).kind == string.byte('=') then
        local token = bang.eat(P, bang.TokenKind.IDENTIFIER)
        local name = {tag="ast", kind="str", str='"'..P.src:sub(token.offset, token.offset + token.length - 1)..'"'}
        bang.eat(P, string.byte('='))
        local value = bang.parse_expr(P)
        table.insert(args, {name, value})
      elseif bang.peek(P).kind == string.byte('[') then
        bang.eat(P, string.byte('['))
        local name = bang.parse_expr(P)
        bang.eat(P, string.byte(']'))
        bang.eat(P, string.byte('='))
        local value = bang.parse_expr(P)
        table.insert(args, {name, value})
      else
        local name = bang.parse_expr(P)
        bang.eat(P, string.byte('='))
        local value = bang.parse_expr(P)
        table.insert(args, {name, value})
      end
      if bang.peek(P).kind == string.byte(',') then bang.eat(P, string.byte(','))
      else break end
    end
    bang.eat(P, string.byte('}'))
    result = {tag="ast", kind="table", args=args}
  elseif bang.peek(P).kind == bang.TokenKind.KW_fn then
    bang.eat(P, bang.TokenKind.KW_fn)
    bang.eat(P, string.byte('('))
    local params = {}
    while bang.peek(P).kind ~= string.byte(')') do
      local token = bang.eat(P, bang.TokenKind.IDENTIFIER)
      table.insert(params, P.src:sub(token.offset, token.offset + token.length - 1))
      if bang.peek(P).kind == string.byte(',') then bang.eat(P, string.byte(','))
      else break end
    end
    bang.eat(P, string.byte(')'))
    local body = {}
    while bang.peek(P).kind ~= string.byte('!') do
      table.insert(body, bang.parse_stat(P))
    end
    bang.eat(P, string.byte('!'))
    result = {tag="ast", kind="fn", params=params, body=body}
  end
  if result == nil then error("unknown expression entrant "..bang.peek(P).kind..".") end
  while true do
    if bang.peek(P).kind == string.byte('.') then
      bang.eat(P, string.byte('.'))
      local token = bang.eat(P, bang.TokenKind.IDENTIFIER)
      result = {tag="ast", kind="field", expr=result, field=P.src:sub(token.offset, token.offset + token.length - 1)}
      goto continue
    end
    if bang.peek(P).kind == string.byte(':') then
      bang.eat(P, string.byte(':'))
      local token = bang.eat(P, bang.TokenKind.IDENTIFIER)
      result = {tag="ast", kind="method", expr=result, method=P.src:sub(token.offset, token.offset + token.length - 1)}
      goto continue
    end
    if bang.peek(P).kind == string.byte('(') then
      bang.eat(P, string.byte('('))
      local args = {}
      while bang.peek(P).kind ~= string.byte(')') do
        table.insert(args, bang.parse_expr(P))
        if bang.peek(P).kind == string.byte(',') then bang.eat(P, string.byte(','))
        else break end
      end
      bang.eat(P, string.byte(')'))
      result = {tag="ast", kind="call", expr=result, args=args}
      goto continue
    end
    if bang.peek(P).kind == string.byte('{') or bang.peek(P).kind == string.byte('[') or bang.peek(P).kind == bang.TokenKind.STRING then
      local args = {bang.parse_expr(P)}
      result = {tag="ast", kind="call", expr=result, args=args}
      goto continue
    end
    if bang.peek(P).kind == string.byte('[') then
      bang.eat(P, string.byte('['))
      local index = bang.parse_expr(P)
      bang.eat(P, string.byte(']'))
      result = {tag="ast", kind="index", expr=result, index=index}
      goto continue
    end
    do break end
    ::continue::
  end
  return result
end

function bang.parse_expr(P, min_prec)
  min_prec = min_prec or 0
  local left = bang.parse_leaf(P)
  while bang.PRECEDENCE[bang.peek(P).kind] > min_prec - ((bang.peek(P).kind == bang.TokenKind.DOTDOT or bang.peek(P).kind == string.byte('^')) and 1 or 0) do
    local op = bang.eat(P, bang.peek(P).kind)
    local right = bang.parse_expr(P, bang.PRECEDENCE[op.kind])
    left = {tag="ast", kind="binop", left=left, op=P.src:sub(op.offset, op.offset + op.length - 1), right=right}
  end
  return left
end

function bang.parse_stat(P)
  if bang.peek(P).kind == bang.TokenKind.KW_while then
    bang.eat(P, bang.TokenKind.KW_while)
    local cond = bang.parse_expr(P)
    local body = {}
    while bang.peek(P).kind ~= string.byte('!') do
      table.insert(body, bang.parse_stat(P))
    end
    bang.eat(P, string.byte('!'))
    return {tag="ast", kind="while", cond=cond, body=body}
  elseif bang.peek(P).kind == bang.TokenKind.KW_break then
    bang.eat(P, bang.TokenKind.KW_break)
    return {tag="ast", kind="break"}
  elseif bang.peek(P).kind == bang.TokenKind.KW_goto then
    bang.eat(P, bang.TokenKind.KW_goto)
    local token = bang.eat(P, bang.TokenKind.IDENTIFIER)
    return {tag="ast", kind="goto", label=P.src:sub(token.offset, token.offset + token.length - 1)}
  elseif bang.peek(P).kind == bang.TokenKind.KW_do then
    bang.eat(P, bang.TokenKind.KW_do)
    local body = {}
    while bang.peek(P).kind ~= string.byte('!') do
      table.insert(body, bang.parse_stat(P))
    end
    bang.eat(P, string.byte('!'))
    return {tag="ast", kind="do", body=body}
  elseif bang.peek(P).kind == bang.TokenKind.KW_for then
    bang.eat(P, bang.TokenKind.KW_for)
    local iter = bang.parse_expr(P)
    local body = {}
    while bang.peek(P).kind ~= string.byte('!') do
      table.insert(body, bang.parse_stat(P))
    end
    bang.eat(P, string.byte('!'))
    return {tag="ast", kind="for", iter=iter, body=body}
  elseif bang.peek(P).kind == bang.TokenKind.KW_if or bang.peek(P).kind == bang.TokenKind.KW_elif then
    local kind = bang.peek(P).kind
    bang.eat(P, kind)
    local cond = bang.parse_expr(P)
    local body = {}
    while bang.peek(P).kind ~= bang.TokenKind.KW_elif and bang.peek(P).kind ~= bang.TokenKind.KW_else and bang.peek(P).kind ~= string.byte('!') do
      table.insert(body, bang.parse_stat(P))
    end
    local else_body = {}
    if bang.peek(P).kind == bang.TokenKind.KW_elif then
      table.insert(else_body, bang.parse_stat(P))
    elseif bang.peek(P).kind == bang.TokenKind.KW_else then
      bang.eat(P, bang.TokenKind.KW_else)
      while bang.peek(P).kind ~= string.byte('!') do
        table.insert(else_body, bang.parse_stat(P))
      end
      bang.eat(P, string.byte('!'))
    else
      bang.eat(P, string.byte('!'))
    end
    return {tag="ast", kind="if", cond=cond, body=body, else_body=else_body}
  elseif bang.peek(P).kind == bang.TokenKind.KW_return then
    bang.eat(P, bang.TokenKind.KW_return)
    local exprs = {}
    while true do
      table.insert(exprs, bang.parse_expr(P))
      if bang.peek(P).kind == string.byte(',') then bang.eat(P, string.byte(','))
      else break end
    end
    return {tag="ast", kind="return", exprs=exprs}
  else
    local result = bang.parse_expr(P)
    if bang.peek(P).kind == string.byte(',') or bang.peek(P).kind == string.byte('=') then
      local targets = {result}
      while bang.peek(P).kind == string.byte(',') do
        bang.eat(P, string.byte(','))
        table.insert(targets, bang.parse_expr(P))
      end
      bang.eat(P, string.byte('='))
      local values = {bang.parse_expr(P)}
      while bang.peek(P).kind == string.byte(',') do
        bang.eat(P, string.byte(','))
        table.insert(values, bang.parse_expr(P))
      end
      result = {tag="ast", kind="assign", targets=targets, values=values}
    end
    return result
  end
end

function bang.parse(src)
  local P = {src=src, pos=1}
  local body = {}
  while bang.peek(P).kind ~= bang.TokenKind.END_OF_INPUT do
    table.insert(body, bang.parse_stat(P))
  end
  return {tag="ast", kind="module", body=body}
end

function bang.ast_to_lua(S, node)
  local function push_level()
    local save = {}
    for k, v in pairs(S.env) do save[k] = v end
    S.level = S.level + 1
    return save
  end
  local function pop_level(save)
    S.level = S.level - 1
    S.env = {}
    for k, v in pairs(save) do S.env[k] = v end
  end

  assert(node.tag == "ast")
  if node.kind == "module" then
    local result = ""
    result = result.."local "..S.name.." = {}\n"
    for i, node2 in ipairs(node.body) do
      result = result..bang.ast_to_lua(S, node2).."\n"
    end
    result = result.."return "..S.name.."\n"
    return result
  elseif node.kind == "assign" then
    local result = ""
    if S.level > 0 and node.targets[1].kind == "ref" and S.env[node.targets[1].ref] == nil then
      for i, target in ipairs(node.targets) do
        assert(target.kind == "ref")
        S.env[target.ref] = true
      end
      result = result.."local "
    end
    for i, target in ipairs(node.targets) do
      if i ~= 1 then result = result..", " end
      result = result..bang.ast_to_lua(S, target)
    end
    result = result.." = "
    for i, value in ipairs(node.values) do
      if i ~= 1 then result = result..", " end
      result = result..bang.ast_to_lua(S, value)
    end
    return result
  elseif node.kind == "binop" then
    local result = ""
    if bang.ASSIGNS[node.op] ~= nil then
      result = result..bang.ast_to_lua(S, node.left)
      result = result.." = "
      result = result..bang.ast_to_lua(S, node.left)
      result = result.." "..node.op:sub(1, -2).." ("
      result = result..bang.ast_to_lua(S, node.right)
      result = result..")"
    else
      local left_wrap = node.left.kind == "binop" and bang.PRECEDENCE[bang.token_at(node.left.op, 1).kind] < bang.PRECEDENCE[bang.token_at(node.op, 1).kind]
      local right_wrap = node.right.kind == "binop" and bang.PRECEDENCE[bang.token_at(node.right.op, 1).kind] < bang.PRECEDENCE[bang.token_at(node.op, 1).kind]
      if left_wrap then result = result.."(" end
      result = result..bang.ast_to_lua(S, node.left)
      if left_wrap then result = result..")" end
      result = result.." "..(node.op ~= "!=" and node.op or "~=").." "
      if right_wrap then result = result.."(" end
      result = result..bang.ast_to_lua(S, node.right)
      if right_wrap then result = result..")" end
    end
    return result
  elseif node.kind == "call" then
    local result = ""
    result = result..bang.ast_to_lua(S, node.expr).."("
    for i, arg in ipairs(node.args) do
      if i ~= 1 then result = result..", " end
      result = result..bang.ast_to_lua(S, arg)
    end
    result = result..")"
    return result
  elseif node.kind == "ref" then
    if S.env[node.ref] ~= nil then
      return node.ref
    else
      return S.name.."."..node.ref
    end
  elseif node.kind == "num" then
    return node.num
  elseif node.kind == "str" then
    return node.str
  elseif node.kind == "bool" then
    return node.bool and "true" or "false"
  elseif node.kind == "nil" then
    return "nil"
  elseif node.kind == "label" then
    return "::"..node.label.."::"
  elseif node.kind == "varargs" then
    return "..."
  elseif node.kind == "field" then
    return bang.ast_to_lua(S, node.expr).."."..node.field
  elseif node.kind == "method" then
    return bang.ast_to_lua(S, node.expr)..":"..node.method
  elseif node.kind == "array" then
    local result = ""
    result = result.."{"
    for i, arg in ipairs(node.args) do
      if i ~= 1 then result = result..", " end
      result = result..bang.ast_to_lua(S, arg)
    end
    result = result.."}"
    return result
  elseif node.kind == "table" then
    local result = ""
    result = result.."{"
    for i, arg in ipairs(node.args) do
      if i ~= 1 then result = result..", " end
      result = result.."["..bang.ast_to_lua(S, arg[1]).."]="..bang.ast_to_lua(S, arg[2])
    end
    result = result.."}"
    return result
  elseif node.kind == "index" then
    local result = ""
    result = result..bang.ast_to_lua(S, node.expr)
    result = result.."["
    result = result..bang.ast_to_lua(S, node.index)
    result = result.."]"
    return result
  elseif node.kind == "while" then
    local result = "while "
    result = result..bang.ast_to_lua(S, node.cond).." do\n"
    local save = push_level()
    for i, node2 in ipairs(node.body) do
      for i=1, S.level do result = result.."  " end
      result = result..bang.ast_to_lua(S, node2).."\n"
    end
    pop_level(save)
    for i=1, S.level do result = result.."  " end
    result = result.."end"
    return result
  elseif node.kind == "do" then
    local result = "do\n"
    local save = push_level()
    for i, node2 in ipairs(node.body) do
      for i=1, S.level do result = result.."  " end
      result = result..bang.ast_to_lua(S, node2).."\n"
    end
    pop_level(save)
    for i=1, S.level do result = result.."  " end
    result = result.."end"
    return result
  elseif node.kind == "for" then
    local result = "for it_index, it in "
    result = result..bang.ast_to_lua(S, node.iter).." do\n"
    local save = push_level()
    S.env["it_index"], S.env["it"] = true, true
    for i, node2 in ipairs(node.body) do
      for i=1, S.level do result = result.."  " end
      result = result..bang.ast_to_lua(S, node2).."\n"
    end
    pop_level(save)
    for i=1, S.level do result = result.."  " end
    result = result.."end"
    return result
  elseif node.kind == "fn" then
    local result = "function("
    for i, param in ipairs(node.params) do
      if i ~= 1 then result = result..", " end
      result = result..param
    end
    result = result..")\n"
    local save = push_level()
    for i, param in ipairs(node.params) do
      S.env[param] = true
    end
    for i, node2 in ipairs(node.body) do
      for i=1, S.level do result = result.."  " end
      result = result..bang.ast_to_lua(S, node2).."\n"
    end
    pop_level(save)
    for i=1, S.level do result = result.."  " end
    result = result.."end"
    return result
  elseif node.kind == "if" then
    local result = "if "..bang.ast_to_lua(S, node.cond).." then\n"
    local save = push_level()
    for i, node2 in ipairs(node.body) do
      for i=1, S.level do result = result.."  " end
      result = result..bang.ast_to_lua(S, node2).."\n"
    end
    pop_level(save)
    for i=1, S.level do result = result.."  " end
    if #node.else_body ~= 0 then
      result = result.."else\n"
      local save = push_level()
      for i, node2 in ipairs(node.else_body) do
        for i=1, S.level do result = result.."  " end
        result = result..bang.ast_to_lua(S, node2).."\n"
      end
      pop_level(save)
      for i=1, S.level do result = result.."  " end
    end
    result = result.."end"
    return result
  elseif node.kind == "return" then
    local result = "return "
    for i, expr in ipairs(node.exprs) do
      if i ~= 1 then result = result..", " end
      result = result..bang.ast_to_lua(S, expr)
    end
    return result
  elseif node.kind == "unaryop" then
    return node.op..(node.op == "not" and " " or "")..bang.ast_to_lua(S, node.expr)
  elseif node.kind == "break" then
    return "break"
  elseif node.kind == "goto" then
    return "goto "..node.label
  else
    error(node.kind.." unimplemented")
  end
end

local args = {...}
if args[1] ~= "bang" then
  local path = args[1]
  local print_lua = false
  if args[1] == "-l" then
    print_lua = true
    path = args[2]
  end
  if path == nil then error("please tell me which file to interpret.") end
  local f = io.open(path, "r")
  if f == nil then error("failed to open '"..path.."'.") end
  local src = f:read("*all")
  f:close()
  local m = bang.parse(src)
  local S = {name=path:sub(1, -6), level=0, env={
    -- globals
    _G=true, _VERSION=true, assert=true, collectgarbage=true,
    dofile=true, error=true, getmetatable=true, ipairs=true,
    load=true, loadfile=true, next=true, pairs=true, pcall=true,
    print=true, rawequal=true, rawget=true, rawlen=true, rawset=true,
    require=true, select=true, setmetatable=true, tonumber=true,
    tostring=true, type=true, xpcall=true,
    -- modules
    bit32=true, coroutine=true, debug=true, io=true, math=true,
    os=true, package=true, string=true, table=true,
  }}
  local luacode = bang.ast_to_lua(S, m)
  if print_lua then
    io.stdout:write(luacode)
  else
    local luamod, message = load(luacode)
    if luamod == nil then error(message) end
    local pargs = {}
    for i=2, #args do
      table.insert(pargs, args[i])
    end
    local unpack = unpack or table.unpack
    local success
    success, message = pcall(luamod, unpack(pargs))
    if not success then error(message) end
  end
end

return bang
