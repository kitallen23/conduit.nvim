-- main module file
local module = require("cue.module")

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

---@return string
M.hello = function()
  local message = module.my_first_function(M.config.opt)
  print(message)
  return message
end

return M
