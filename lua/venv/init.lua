local M = {}

--- @class VenvOptions
local defaults = {
    search_path = { "~/.venvs", "." },
}

--- @type VenvOptions
M.options = {}

local utils = require "venv.utils"

function M.setup(options)
    M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
    vim.api.nvim_create_user_command("Venv", function(fopts)
        local venv_path = fopts.args
        utils.venv_activate(venv_path)
    end, {
        desc = "Switch python venv",
        nargs = 1,
        complete = function(_, _)
            return utils.venv_list(M.options.search_path)
        end,
    })

    vim.api.nvim_create_user_command("VenvInfo", function(_)
        print(vim.inspect(utils.venv_info()))
    end, {
        desc = "Print venv info",
    })
end

return M
