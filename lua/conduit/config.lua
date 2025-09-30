local M = {}

---Your `conduit.nvim` configuration.
---@type conduit.Opts|nil
vim.g.conduit_opts = vim.g.conduit_opts

---@class conduit.Opts
---
---Completion sources to automatically register in the `ask` input with [blink.cmp](https://github.com/Saghen/blink.cmp) (if available).
---Only possible when using [snacks.input](https://github.com/folke/snacks.nvim/blob/main/docs/input.md).
---@field auto_register_cmp_sources? string[]
---
---A prefix that's automatically added to the start of file paths
---@field filePrefix? string
---
---Set to false to disable notifications
---@field notify? boolean
---
---Contexts to inject into prompts, keyed by their placeholder.
---@field contexts? table<string, conduit.Context>
---
---Prompts to select from.
---@field prompts? table<string, conduit.Prompt>
---
---Input options for `ask` — see [snacks.input](https://github.com/folke/snacks.nvim/blob/main/docs/input.md) (if enabled).
---@diagnostic disable-next-line: undefined-doc-name
---@field input? snacks.input.Opts
local defaults = {
  file_prefix = "@",
  notify = true,
  auto_register_cmp_sources = { "conduit" },
  contexts = {
    ---@class conduit.Context
    ---@field description string Description of the context. Shown in completion docs.
    ---@field value fun(): string|nil Function that returns the text that will replace the placeholder.
    ["@buffer"] = { description = "Current buffer", value = require("conduit.context").buffer },
    ["@buffers"] = { description = "Open buffers", value = require("conduit.context").buffers },
    ["@cursor"] = { description = "Cursor position", value = require("conduit.context").cursor_position },
    ["@selection"] = { description = "Selected text", value = require("conduit.context").visual_selection },
    ["@visible"] = { description = "Visible text", value = require("conduit.context").visible_text },
    ["@diagnostic"] = {
      description = "Current line diagnostics",
      value = function()
        return require("conduit.context").diagnostics(true)
      end,
    },
    ["@diagnostics"] = { description = "Current buffer diagnostics", value = require("conduit.context").diagnostics },
    ["@quickfix"] = { description = "Quickfix list", value = require("conduit.context").quickfix },
    ["@diff"] = { description = "Git diff", value = require("conduit.context").git_diff },
    ["@hunk"] = { description = "Git diff hunk", value = require("conduit.context").git_diff_hunk },
  },
  prompts = {
    ---@class conduit.Prompt
    ---@field description string Description of the prompt. Shown in selection menu.
    ---@field prompt string The prompt to send to `conduit`, with placeholders for context like `@cursor`, `@buffer`, etc.
    explain = {
      description = "Explain code near cursor",
      prompt = "Explain @cursor and its context",
    },
    document = {
      description = "Document selection",
      prompt = "Add documentation comments for @selection",
    },
    fix = {
      description = "Fix diagnostics",
      prompt = "Fix these @diagnostics",
    },
    fix_line = {
      description = "Fix line diagnostic",
      prompt = "Fix this @diagnostic",
    },
    optimize = {
      description = "Optimize selection",
      prompt = "Optimize @selection for performance and readability",
    },
    test = {
      description = "Add tests for selection",
      prompt = "Add tests for @selection",
    },
    review_buffer = {
      description = "Review buffer",
      prompt = "Review @buffer for correctness and readability",
    },
    review_hunk_diff = {
      description = "Review git hunk diff",
      prompt = "Review the following git diff for correctness and readability:\n@hunk",
    },
  },
  input = {
    prompt = "Prompt conduit: ",
    highlight = require("conduit.input").highlight,
    -- Options below here only apply to [snacks.input](https://github.com/folke/snacks.nvim/blob/main/docs/input.md).
    icon = "󰊠 ",
    -- completion = "customlist,v:lua.require'conduit.cmp.omni'",
    completion = "customlist,v:lua.require'conduit.cmp.omni'",
    expand = true,
    win = {
      title_pos = "left",
      relative = "cursor",
      height = 1,
      row = -3, -- Row above the cursor
      col = 0,  -- Align with the cursor
      b = {
        -- Enable `blink.cmp` completion
        completion = true,
      },
      bo = {
        -- Custom filetype to enable `blink.cmp` source on
        filetype = "conduit_ask",
      },
      on_buf = function(win)
        -- Wait as long as possible to check for `blink.cmp` loaded - many users lazy-load on `InsertEnter`.
        -- And OptionSet :runtimepath didn't seem to fire for lazy.nvim.
        vim.api.nvim_create_autocmd("InsertEnter", {
          once = true,
          buffer = win.buf,
          callback = function()
            if package.loaded["blink.cmp"] then
              require("conduit.cmp.blink").setup(require("conduit.config").opts.auto_register_cmp_sources)
            end
          end,
        })

        -- `snacks.input` doesn't seem to actually call `opts.highlight`... so highlight its buffer ourselves
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter" }, {
          group = vim.api.nvim_create_augroup("ConduitAskHighlight", { clear = true }),
          buffer = win.buf,
          callback = function(args)
            require("conduit.input").highlight_buffer(args.buf)
          end,
        })
      end,
    },
  },
}

---@module 'snacks'

---Plugin options, lazily merged from `defaults` and `vim.g.conduit_opts`.
---@type conduit.Opts
M.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.g.conduit_opts or {})

return M
