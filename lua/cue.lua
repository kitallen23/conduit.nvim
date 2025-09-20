---@class Config
---@field opt string Your config option
local config = {
  opt = "Hello!",
}

---@class CueModule
---@field config Config
---@field setup fun(args: Config?)
---@field hello fun(): string
local M = {}

---@type Config
M.config = config

---@param args Config?
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

---@param prompt string
function M.copy(prompt)
  vim.notify(prompt)
end

M.ask = function(default)
  require("cue.input").input(
    default, function(value)
      if value and value ~= "" then
        M.copy(value)
      end
    end
  )
end

return M
