local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.BaseMod.BaseConf")

local api = vim.api

---@type BaseMod
local BaseMod = class(function(self, meta, conf)
    self.meta = meta
        or {
            name = "",
            augroupName = "",
            hlBaseName = "",
            nsId = api.nvim_create_namespace(""),
            hlNameList = {},
        } --[[@as MetaInfo]]
    self.conf = conf or (BaseConf())
end)

function BaseMod:enable()
    local ok, info = pcall(function()
        self.conf.enable = true
        self:setHl()
        self:render()
        self:createAutocmd()
        self:createUsercmd()
    end)
    if not ok then
        self:notify(tostring(info))
    end
end

function BaseMod:disable()
    local ok, info = pcall(function()
        self.conf.enable = false
        for _, bufnr in pairs(api.nvim_list_bufs()) do
            -- TODO: need change BaseMod:clear function
            api.nvim_buf_clear_namespace(bufnr, self.meta.nsId, 0, -1)
        end
        self:clearAutocmd()
    end)
    if not ok then
        self:notify(tostring(info))
    end
end

function BaseMod:render(range)
    if (not self.conf.enable) or self.conf.excludeFiletypes[vim.bo.ft] then
        return
    end
    self:clear(range)
end

function BaseMod:clear(range)
    local start = range and range.start or 0
    local finish = range and range.finish or -1

    -- TODO: needed?
    if self.meta.nsId ~= -1 then
        api.nvim_buf_clear_namespace(0, self.meta.nsId, start, finish)
    end
end

function BaseMod:createUsercmd()
    -- TODO: update the name case
    api.nvim_create_user_command("EnableHL" .. self.meta.name, function()
        self:enable()
    end, {})
    api.nvim_create_user_command("DisableHL" .. self.meta.name, function()
        self:disable()
    end, {})
end

function BaseMod:createAutocmd()
    api.nvim_create_augroup(self.meta.augroupName, { clear = true })

    api.nvim_create_autocmd({ "ColorScheme" }, {
        group = self.meta.augroupName,
        pattern = "*",
        callback = function()
            self:setHl()
        end,
    })
end

function BaseMod:clearAutocmd()
    api.nvim_del_augroup_by_name(self.meta.augroupName)
end

function BaseMod:setHl()
    local hl_conf = self.conf.style
    self.meta.hlNameList = {}

    -- such as style = "#abcabc"
    if type(hl_conf) == "string" then
        api.nvim_set_hl(0, self.meta.hlBaseName .. "1", { fg = hl_conf })
        self.meta.hlNameList = { self.meta.hlBaseName .. "1" }
        return
    end

    for idx, val in ipairs(hl_conf) do
        local value_type = type(val)
        if value_type == "table" then
            if type(val.fg) == "function" or type(val.bg) == "function" then
                --[[
                such as style = {
                    { fg = fg1cb, bg = bg1cb },
                    { fg = "#abcabc", bg = "#cdefef"},
                }
                --]]
                local value_tmp = vim.deepcopy(val)
                value_tmp.fg = type(val.fg) == "function" and val.fg() or val.fg
                value_tmp.bg = type(val.bg) == "function" and val.bg() or val.bg
                api.nvim_set_hl(0, self.meta.hlBaseName .. idx, value_tmp)
            else
                --[[
                such as style = {
                    { fg = "#abcabc", bg = "#cdefef" },
                    { fg = "#abcabc", bg = "#cdefef" },
                }
                --]]
                api.nvim_set_hl(0, self.meta.hlBaseName .. idx, val)
            end
        elseif value_type == "string" then
            -- such as style = {"#abcabc", "#cdefef"}
            api.nvim_set_hl(0, self.meta.hlBaseName .. idx, { fg = val })
        end
        table.insert(self.meta.hlNameList, self.meta.hlBaseName .. idx)
    end
end

function BaseMod:clearHl()
    -- TODO:
end

function BaseMod:notify(...)
    if self.conf.notify then
        vim.notify(...)
    end
end

return BaseMod
