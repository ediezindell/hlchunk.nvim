local hlchunk = {}

hlchunk.setup = function(userConf)
    require("hlchunk.utils.string")
    for mod_name, mod_conf in pairs(userConf) do
        if mod_conf.enable then
            local mod_path = "hlchunk.mods." .. mod_name
            local Mod = require(mod_path)
            ---@type BaseMod
            local mod = Mod()
            mod.conf = vim.tbl_deep_extend("force", mod.conf, mod_conf or {})
            -- vim.notify(vim.inspect(mod))
            mod:enable()
            -- vim.notify(vim.inspect(mod))
        end
    end
end

return hlchunk
