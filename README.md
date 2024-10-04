# venv.nvim

neovim plugin to switch python virtual environemnts

It provides completetion with venvs found in `search_path`.

## Installation

Installation with `lazy`

```lua
{
    "aanatoly/venv.nvim",
    cmd = { "Venv", "VenvInfo" },
    opts = { search_path = { "~/.venvs", "." } }
}
```

## Usage
Switch to specific venv
```
:Venv som/dir
```
Selct venv from menu, press Tab instead of argument
```
:Venv [TAB]
```
Print venv info
```
VenvInfo
```
