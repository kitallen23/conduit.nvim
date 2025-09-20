local M = {}

---Your `cue.nvim` configuration.
---@type cue.Opts|nil
vim.g.cue_opts = vim.g.cue_opts

---@class cue.Opts
---
---Contexts to inject into prompts, keyed by their placeholder.
---@field contexts? table<string, cue.Context>
---
---Prompts to select from.
---@field prompts? table<string, cue.Prompt>
---
---Input options for `ask` — see [snacks.input](https://github.com/folke/snacks.nvim/blob/main/docs/input.md) (if enabled).
---@field input? snacks.input.Opts
local defaults = {
  contexts = {
    ---@class cue.Context
    ---@field description string Description of the context. Shown in completion docs.
    ---@field value fun(): string|nil Function that returns the text that will replace the placeholder.
    -- TODO: Fix / implement these
    -- ["@buffer"] = { description = "Current buffer", value = require("opencode.context").buffer },
    -- ["@buffers"] = { description = "Open buffers", value = require("opencode.context").buffers },
    ["@cursor"] = { description = "Cursor position", value = require("cue.context").cursor_position },
    -- ["@selection"] = { description = "Selected text", value = require("opencode.context").visual_selection },
    -- ["@visible"] = { description = "Visible text", value = require("opencode.context").visible_text },
    -- ["@diagnostic"] = {
    --   description = "Current line diagnostics",
    --   value = function()
    --     return require("opencode.context").diagnostics(true)
    --   end,
    -- },
    -- ["@diagnostics"] = { description = "Current buffer diagnostics", value = require("opencode.context").diagnostics },
    -- ["@quickfix"] = { description = "Quickfix list", value = require("opencode.context").quickfix },
    -- ["@diff"] = { description = "Git diff", value = require("opencode.context").git_diff },
    -- ["@grapple"] = { description = "Grapple tags", value = require("opencode.context").grapple_tags },
  },
  prompts = {
    ---@class cue.Prompt
    ---@field description string Description of the prompt. Shown in selection menu.
    ---@field prompt string The prompt to send to `cue`, with placeholders for context like `@cursor`, `@buffer`, etc.
    explain = {
      description = "Explain code near cursor",
      prompt = "Explain @cursor and its context",
    },
    fix = {
      description = "Fix diagnostics",
      prompt = "Fix these @diagnostics",
    },
    optimize = {
      description = "Optimize selection",
      prompt = "Optimize @selection for performance and readability",
    },
    document = {
      description = "Document selection",
      prompt = "Add documentation comments for @selection",
    },
    test = {
      description = "Add tests for selection",
      prompt = "Add tests for @selection",
    },
    review_buffer = {
      description = "Review buffer",
      prompt = "Review @buffer for correctness and readability",
    },
    review_diff = {
      description = "Review git diff",
      prompt = "Review the following git diff for correctness and readability:\n@diff",
    },
  },
  input = {
    prompt = "Ask cue: ",
    highlight = require("cue.input").highlight,
    -- Options below here only apply to [snacks.input](https://github.com/folke/snacks.nvim/blob/main/docs/input.md).
    icon = "󰊠 ",
    win = {
      title_pos = "left",
      relative = "cursor",
      row = -3, -- Row above the cursor
      col = 0,  -- Align with the cursor
      b = {
        -- Enable `blink.cmp` completion
        completion = true,
      },
      bo = {
        -- Custom filetype to enable `blink.cmp` source on
        filetype = "cue_ask",
      },
      on_buf = function(win)
        -- `snacks.input` doesn't seem to actually call `opts.highlight`... so highlight its buffer ourselves
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter" }, {
          group = vim.api.nvim_create_augroup("CueAskHighlight", { clear = true }),
          buffer = win.buf,
          callback = function(args)
            require("cue.input").highlight_buffer(args.buf)
          end,
        })
      end,
    },
  },
}

---@module 'snacks'

---Plugin options, lazily merged from `defaults` and `vim.g.cue_opts`.
---@type cue.Opts
M.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.g.cue_opts or {})

return M
