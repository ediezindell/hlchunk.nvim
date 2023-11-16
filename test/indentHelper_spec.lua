package.path = package.path .. ";../lua/?.lua"

local luaunit = require("luaunit")
local indentHelper = require("hlchunk.utils.indentHelper")

TestIndentHelper = {}

function TestIndentHelper:testCalc()
    local testCaseList = {
        { blankLine = (" "):rep(12), leftcol = 5, sw = 4, render_char_num = 1, offset = 3 },
        { blankLine = (" "):rep(12), leftcol = 4, sw = 4, render_char_num = 2, offset = 0 },
        { blankLine = (" "):rep(12), leftcol = 9, sw = 4, render_char_num = 0, offset = 3 },
        { blankLine = (" "):rep(4), leftcol = 0, sw = 4, render_char_num = 1, offset = 0 },
        { blankLine = (" "):rep(4), leftcol = 1, sw = 4, render_char_num = 0, offset = 3 },
        { blankLine = (" "):rep(7), leftcol = 2, sw = 4, render_char_num = 1, offset = 2 },
        { blankLine = (" "):rep(7), leftcol = 4, sw = 4, render_char_num = 1, offset = 0 },
        { blankLine = (" "):rep(7), leftcol = 5, sw = 4, render_char_num = 0, offset = 2 },
        { blankLine = (" "):rep(4), leftcol = 4, sw = 4, render_char_num = 0, offset = 0 },
        { blankLine = (" "):rep(4), leftcol = 5, sw = 4, render_char_num = 0, offset = 0 },
    }
    local blankLine, leftcol
    local sw = 4
    local render_char_num, offset

    for _, testCase in ipairs(testCaseList) do
        blankLine = testCase.blankLine
        leftcol = testCase.leftcol
        render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
        luaunit.assertEquals(render_char_num, testCase.render_char_num)
        luaunit.assertEquals(offset, testCase.offset)
    end
end

os.exit(luaunit.LuaUnit.run())
