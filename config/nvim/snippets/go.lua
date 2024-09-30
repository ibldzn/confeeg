local luasnip = require("luasnip")
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node

return {
  s({ trig = "main", name = "main", dscr = "Create main package with main function" }, {
    t({ "package main", "", "" }),
    t({ "func main() {", "\t" }),
    i(0, { "" }),
    t({ "", "}" }),
  }),

  s({ trig = "ifew", name = "If Err Wrapped", dscr = "Insert a if err not nil statement with wrapped error" }, {
    t({ "if err != nil {", "\t" }),
    t({ 'return fmt.Errorf("failed to ' }),
    i(1, "message"),
    t(': %w", err)'),
    t({ "", "}" }),
  }),

  s({ trig = "ife", name = "If Err", dscr = "Insert a basic if err not nil statement" }, {
    t({ "if err != nil {", "\t" }),
    i(0, { "" }),
    t({ "", "}" }),
  }),
}
