local syntax = require "syntax"
nop = {"nop"}

local function char(c)
   return {"char", c}
end

local function jump(x)
   return {"jump", x}
end

local function split(x,y)
   return {"split", x, y}
end

local function gate(n)
   return {"gate", n}
end

local function compile(ast)
   local insts = {}
   local gates = 0
   local function construct(ast)
      if ast[1] == "lit" then
         table.insert(insts, char(string.byte(ast[2])))
      elseif ast[1] == "seq" then
         for k, v in ipairs(ast[2]) do
            construct(v)
         end
      elseif ast[1] == "alt" then
         local s = #insts + 1
         table.insert(insts, nop)
         local l1 = #insts + 1
         construct(ast[2])
         local j = #insts + 1
         table.insert(insts, nop)
         local l2 = #insts + 1
         construct(ast[3])
         local l3 = #insts + 1
         table.insert(insts, gate(gates))
         gates = gates + 1
         
         insts[s] = split(l1, l2)
         insts[j] = jump(l3)
      elseif ast[1] == "*" then
         local l1 = #insts + 1
         table.insert(insts, gate(gates))
         gates = gates + 1
         local s = #insts + 1
         table.insert(insts, nop)
         local l2 = #insts + 1
         construct(ast[2])
         table.insert(insts, jump(l1))
         local l3 = #insts + 1
         
         insts[s] = split(l2, l3)
      end
   end
   construct(ast)
   return insts, gates
end

return {
   compile = compile
}
