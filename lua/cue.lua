local M = {}

--- Process a prompt with context injection and copy to clipboard.
--- This function takes a raw prompt string, injects context placeholders
--- (like @buffer, @cursor, @diagnostics) with actual editor state,
--- and copies the final prompt to the system clipboard ('+' register).
---
---@param prompt string The raw prompt string containing context placeholders
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

---Input a prompt to copy to the '+' register.
--- - Highlights `opts.contexts` in the input.
---@param default? string Text to prefill the input with.
function M.ask(default)
  require("cue.input").input(
    default, function(value)
      if value and value ~= "" then
        M.prompt(value)
      end
    end
  )
end

return M
