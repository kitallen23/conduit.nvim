# conduit.nvim

A tool-agnostic Neovim plugin designed to make working with terminal-based AI coding assistants as seamless as possible. Generate AI prompts with relevant editor context and copy them to system clipboard for use with any AI CLI tool.

Based on [opencode.nvim](https://github.com/NickvanDyke/opencode.nvim) but with a tool-agnostic design.

***Note:** This plugin works standalone but is greatly enhanced when used with [snacks.nvim](https://github.com/folke/snacks.nvim) for an improved input experience.*

## Demo

https://github.com/user-attachments/assets/019be1d9-f16b-4596-b474-45ab2ae1fe8e

## Features

- **Tool-agnostic design** - Works with any terminal-based AI coding assistant (Claude Code, opencode, Codex, etc.)
- **Interactive prompt input** with completions, syntax highlighting, and normal-mode support
- **Built-in prompt library** with ability to define custom prompts
- **Automatic context injection** including:
  - Buffer content with line numbers
  - Visual selections
  - Cursor position
  - ... and many more; see [Context](#context) below
- **Seamless workflow** - Generate prompts in Neovim, paste into your AI tool of choice
- **Sensible defaults** with granular configuration options

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "kitallen23/conduit.nvim"
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "kitallen23/conduit.nvim",
}
```

Example minimal setup with keymaps
```lua
config = function()
  vim.g.conduit_opts = {
    -- Put your options here
  }

  vim.keymap.set('n', '<leader>ai', function() require('conduit').ask('@cursor: ') end, { desc = 'Generate conduit prompt' })
  vim.keymap.set('v', '<leader>ai', function() require('conduit').ask('@selection: ') end, { desc = 'Generate conduit prompt about selection' })
  vim.keymap.set({ 'n', 'v' }, '<leader>ap', function() require('conduit').select() end, { desc = 'Select conduit prompt' })
end
}
```

## Usage

Call the Lua function directly or map it to a key combination:

```lua
-- Call directly
:lua require('conduit').ask()

-- Or map to a key combination (example)
vim.keymap.set('n', '<leader>ai', function() require('conduit').ask('@cursor: ') end, { desc = 'Generate conduit prompt' })
vim.keymap.set('v', '<leader>ai', function() require('conduit').ask('@selection: ') end, { desc = 'Generate conduit prompt about selection' })
vim.keymap.set({ 'n', 'v' }, '<leader>ap', function() require('conduit').select() end, { desc = 'Select conduit prompt' })
```

### Workflow

1. Call `:lua require("conduit").ask()` (or use your mapped key) in Neovim to generate a prompt with relevant context
2. The prompt is automatically copied to your system clipboard
3. Switch to your terminal and paste into any AI coding assistant
4. Get context-aware assistance without manual copy-pasting of code snippets

Works seamlessly with tools like:
- Claude Code
- Aider
- opencode
- OpenAI Codex
- Any other terminal-based AI coding tool

## Context

When your prompt contains placeholders, `conduit.nvim` replaces them with context before sending:

| Placeholder | Context |
| - | - |
| `@buffer` | Current buffer |
| `@buffers` | Open buffers |
| `@cursor` | Cursor position |
| `@selection` | Selected text |
| `@visible` | Visible text |
| `@diagnostic` | Current line diagnostics |
| `@diagnostics` | Current buffer diagnostics |
| `@quickfix` | Quickfix list |
| `@diff` | Git diff |
| `@hunk` | Git diff hunk |

Add custom contexts to `opts.contexts`.

## Configuration

Configure the plugin by setting `vim.g.conduit_opts`. Here's the complete default configuration:

```lua
vim.g.conduit_opts = {
  file_prefix = "@", -- This prefix will be put in front of any file paths
  notify = true, -- Enable or disable notifications
  auto_register_cmp_sources = { "conduit" },
  contexts = { -- Default contexts
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
  prompts = { -- Default prompts
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
    -- Options below here only apply to snacks.input
    icon = "󰊠 ",
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
```

You can override any of these options by setting `vim.g.conduit_opts` to a partial configuration. For example:

```lua
vim.g.conduit_opts = {
  notify = false,  -- Disable notifications
  prompts = {
    custom = { -- Add a custom prompt
      description = "My custom prompt",
      prompt = "Do something with @selection",
    },
    optimize = false -- Set a default prompt to false to disable it
  },
}
```

## Credits

This project was bootstrapped from [ellisonleao/nvim-plugin-template](https://github.com/ellisonleao/nvim-plugin-template).

The core functionality is based on [NickvanDyke/opencode.nvim](https://github.com/NickvanDyke/opencode.nvim). Much of the code was adapted from that project.

## License

MIT
