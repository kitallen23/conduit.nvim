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
function M.prompt(prompt)
  prompt = require("cue.context").inject(prompt)
  local notify = require("cue.config").opts.notify
  if prompt and prompt ~= "" then
    vim.fn.setreg('+', prompt)
    if notify then
      vim.notify("Prompt copied to clipboard")
    end
  end
end

M.ask = function(default)
  require("cue.input").input(
    default, function(value)
      if value and value ~= "" then
        M.prompt(value)
      end
    end
  )
end

return M
