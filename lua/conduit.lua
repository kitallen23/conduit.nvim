local M = {}

--- Process a prompt with context injection and copy to clipboard.
--- This function takes a raw prompt string, injects context placeholders
--- (like @buffer, @cursor, @diagnostics) with actual editor state,
--- and copies the final prompt to the system clipboard ('+' register).
---
---@param prompt string The raw prompt string containing context placeholders
function M.prompt(prompt)
  prompt = require("conduit.context").inject(prompt)
  local notify = require("conduit.config").opts.notify
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
  require("conduit.input").input(
    default, function(value)
      if value and value ~= "" then
        M.prompt(value)
      end
    end
  )
end

---Select a prompt from `opts.prompts` to copy to the '+' register.
---Filters prompts based on visual mode: shows only @selection prompts when text is selected,
---and only non-@selection prompts when no text is selected.
function M.select_prompt()
  ---@type conduit.Prompt[]
  local prompts = vim.tbl_filter(function(prompt)
    local is_visual = vim.fn.mode():match("[vV\22]")
    -- WARNING: Technically depends on user using built-in `@selection` context by name...
    local does_prompt_use_visual = prompt.prompt:match("@selection")
    if is_visual then
      return does_prompt_use_visual
    else
      return not does_prompt_use_visual
    end
  end, vim.tbl_values(require("conduit.config").opts.prompts))

  vim.ui.select(
    prompts,
    {
      prompt = "Prompt conduit: ",
      ---@param item conduit.Prompt
      format_item = function(item)
        return item.description
      end,
      border = "single"
    },
    ---@param choice conduit.Prompt
    function(choice)
      if choice then
        M.prompt(choice.prompt)
      end
    end
  )
end

return M
