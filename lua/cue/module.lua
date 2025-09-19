---@class CueCustomModule
---@field my_first_function fun(greeting: string): string
local M = {}

---@param greeting string
---@return string
M.my_first_function = function(greeting)
  return greeting
end

return M
