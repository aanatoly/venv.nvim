local M = {}

local function sort_unique(tbl)
    table.sort(tbl)

    local new_tbl = {}
    local last_val = nil

    for _, v in ipairs(tbl) do
        if v ~= last_val then
            table.insert(new_tbl, v)
            last_val = v
        end
    end

    return new_tbl
end

local function realpath(path)
    return vim.loop.fs_realpath(path)
end

local function repl_pfx(paths)
    local cwd = realpath(vim.fn.getcwd())
    local home = realpath(vim.env.HOME)

    local rc = {}
    for _, path in ipairs(paths) do
        if string.sub(path, 1, #cwd) == cwd then
            table.insert(rc, string.sub(path, #cwd + 2, #path))
        elseif string.sub(path, 1, #home) == home then
            table.insert(rc, "~/" .. string.sub(path, #home + 2, #path))
        else
            table.insert(rc, path)
        end
    end
    return rc
end

local function venv_find(path)
    path = realpath(vim.fn.expand(path))
    if path == nil then
        return {}
    end

    local name = "pyvenv.cfg"
    local command = {
        "find",
        path,
        "-mindepth",
        "1",
        "-maxdepth",
        "5",
        "-name",
        name,
        "-type",
        "f",
    }

    local files = vim.fn.systemlist(command)

    if vim.v.shell_error ~= 0 then
        print("Error running find command: " .. table.concat(command, " "))
        return {}
    end

    local rc = {}
    for _, arg in ipairs(files) do
        table.insert(rc, string.sub(arg, 1, #arg - #name - 1))
    end
    return rc
end

function M.venv_list(paths)
    local rc = {}
    for _, path in ipairs(paths) do
        for _, venv in ipairs(repl_pfx(venv_find(path))) do
            table.insert(rc, venv)
        end
    end
    return sort_unique(rc)
end

function M.venv_activate(venv_path)
    if vim.fn.isdirectory(venv_path) == 0 then
        print("Invalid venv path: " .. venv_path)
        return
    end

    vim.env.VIRTUAL_ENV = venv_path
    vim.env.PATH = venv_path .. "/bin:" .. vim.env.PATH
    print("Activated virtual environment: " .. venv_path)
    vim.cmd "LspRestart"
end

function M.venv_info()
    local path = vim.env.VIRTUAL_ENV
    if path == nil then
        return {}
    end
    local rc = { ["path"] = path }
    local txt = ""

    -- TODO: error handling
    txt = vim.fn.system { path .. "/bin/python", "--version" }
    txt = string.match(txt, "%d+%.[^%s]+")
    rc["python"] = txt

    local cmd = path
        .. "/bin/pip --no-python-version-warning --disable-pip-version-check"
        .. " list --format=freeze"
    txt = vim.fn.system(cmd)
    local pkgs = {}
    local pkgs_no = 0
    for k, v in string.gmatch(txt, "([%w%-]+)==([^\n]+)") do
        pkgs[k] = v
        pkgs_no = pkgs_no + 1
    end

    rc["packages_num"] = pkgs_no
    rc["wheels"] = {}
    local wheels = { "wheel", "pip", "setuptools" }
    for _, w in ipairs(wheels) do
        rc["wheels"][w] = pkgs[w]
    end
    return rc
end

return M
