# conduit.nvim

A tool-agnostic Neovim plugin designed to make working with terminal-based AI coding assistants as seamless as possible. Generate AI prompts with relevant editor context and copy them to system clipboard for use with any AI CLI tool.

Based on [opencode.nvim](https://github.com/NickvanDyke/opencode.nvim) but with a tool-agnostic design.

***Note:** This plugin works standalone but is greatly enhanced when used with [snacks.nvim](https://github.com/folke/snacks.nvim) and [blink.nvim](https://github.com/Saghen/blink.cmp) for an improved input experience.*

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

  vim.keymap.set('n', '<leader>ai', function() require('conduit').ask() end, { desc = 'Generate conduit prompt' })
  vim.keymap.set('n', '<leader>ac', function() require('conduit').ask('@cursor: ') end, { desc = 'Generate conduit prompt at cursor' })
  vim.keymap.set('v', '<leader>ai', function() require('conduit').ask('@selection: ') end, { desc = 'Generate conduit prompt about selection' })
  vim.keymap.set({ 'n', 'v' }, '<leader>ap', function() require('conduit').select_prompt() end, { desc = 'Select conduit prompt' })
  vim.keymap.set('n', '<leader>ad', function() require('conduit').select_prompt('fix_line') end, { desc = 'Get diagnostic prompt' })
end
}
```

## Usage

Call the functions directly or map it to a key combination:

```vim
-- Call directly
:lua require('conduit').ask() -- Open a blank prompt input
:lua require('conduit').ask('@cursor: ') -- Open the prompt input with a pre-filled value
:lua require('conduit').select_prompt() -- Open the prompt picker
:lua require('conduit').select_prompt('review_buffer') -- Reference a prompt to instantly select the prompt & put it on your clipboard
```

```lua
-- Or map to a key combination (example)
vim.keymap.set('n', '<leader>ai', function() require('conduit').ask('@cursor: ') end, { desc = 'Generate conduit prompt' })
vim.keymap.set('v', '<leader>ai', function() require('conduit').ask('@selection: ') end, { desc = 'Generate conduit prompt about selection' })
vim.keymap.set({ 'n', 'v' }, '<leader>ap', function() require('conduit').select_prompt() end, { desc = 'Select conduit prompt' })
```

### Workflow

1. Call `:lua require("conduit").ask()` (or use your mapped key) in Neovim to generate a prompt with relevant context
2. The prompt is automatically copied to your system clipboard (the `+` register)
3. Switch to your terminal and paste into any AI coding assistant
4. Get context-aware assistance without manual copy-pasting of code snippets

Works seamlessly with tools like:
- Claude Code
- Aider
- opencode
- OpenAI Codex
- Any other terminal-based AI coding tool

## API

| Function    | Description |
|-------------|-------------|
| `ask`     | Input a prompt to send to the `+` register. Highlights and completes contexts. |
| `select_prompt`  | Open the prompt picker, or pass a prompt key to skip the picker |

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

Configure the plugin by setting `vim.g.conduit_opts`. See the full config and its defaults [here](./lua/conduit/config.lua).

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
