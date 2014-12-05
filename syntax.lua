local lpeg = require "lpeg"

local function literal(l)
   return {"lit", l}
end

local function is_literal(ast)
   return ast[1] == "lit"
end

local function replicator(f, r)
   if r == "*" then
      return {r, f}
   else
      return f
   end
end

local function is_replicator(ast)
   return ast[1] == "*"
end

local function sequence(x, y, ...)
   if x == nil then
      return {"seq", {}}
   elseif y == nil then
      return x
   else
      return {"seq", {x, y, ...}}
   end
end

local function is_sequence(ast)
   return ast[1] == "seq"
end

local function alternate(x, y, ...)
   if y == nil then
      return x
   else
      return {"alt", x, alternate(y, ...)}
   end
end

local function is_alternate(ast)
   return ast[1] == "alt"
end

local function map(f, x, ...)
   if x == nil then
      return
   else
      return f(x), map(f, ...)
   end
end

local function concat(x, ...)
   if x == nil then
      return ""
   else
      return x .. concat(...)
   end
end

local function show(ast)
   if is_literal(ast) then
      return ast[2]
   elseif is_sequence(ast) then
      return concat(map(show, unpack(ast[2])))
   elseif is_alternate(ast) then
      return "(" .. show(ast[2]) .. "|" .. show(ast[3]) .. ")"
   elseif is_replicator(ast) then
      return "(" .. show(ast[2]) .. ")" .. ast[1]
   else
      return ""
   end
end

local Open = lpeg.P"("
local Close = lpeg.P")"
local Bar = lpeg.P"|"
local Star = lpeg.P"*"

local V = lpeg.V
local G = lpeg.P{
   "Alt",
   Alt = V"Seq" * (Bar * V"Seq")^0 / alternate,
   Seq = ((V"Factor" * V"Rep") / replicator)^0 / sequence,
   Rep = lpeg.C(Star^-1),
   Factor = Open * V"Alt" * Close + V"Lit",
   Lit = lpeg.C(lpeg.R(" #", "%'", ",-", "/>", "@Z", "_z", "~~")) / literal,
}

local function parse(s)
   return lpeg.match(G, s)
end

return {
   show = show,
   parse = parse,
}
