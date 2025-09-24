# conduit.nvim

A tool-agnostic Neovim plugin designed to make working with terminal-based AI coding assistants as seamless as possible. Generate AI prompts with relevant editor context and copy them to system clipboard for use with any AI CLI tool.

Based on [opencode.nvim](https://github.com/NickvanDyke/opencode.nvim) but with a tool-agnostic design.

***Note:** This plugin works standalone but is greatly enhanced when used with [snacks.nvim](https://github.com/folke/snacks.nvim) for an improved input experience.*

## Features

- **Tool-agnostic design** - Works with any terminal-based AI coding assistant (Claude Code, opencode, Codex, etc.)
- **Interactive prompt input** with completions, syntax highlighting, and normal-mode support
- **Built-in prompt library** with ability to define custom prompts
- **Automatic context injection** including:
  - Buffer content with line numbers
  - Visual selections
  - Cursor position
  - Diagnostics
  - File paths
- **Seamless workflow** - Generate prompts in Neovim, paste into your AI tool of choice
- **Sensible defaults** with granular configuration options

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "kitallen23/conduit.nvim",
  config = function()
    -- TODO
  end,
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "kitallen23/conduit.nvim",
  config = function()
    -- TODO
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

## Configuration

```lua
-- TODO
```

## Credits

This project was bootstrapped from [ellisonleao/nvim-plugin-template](https://github.com/ellisonleao/nvim-plugin-template).

The core functionality is based on [NickvanDyke/opencode.nvim](https://github.com/NickvanDyke/opencode.nvim). Much of the code was adapted from that project.

## License

MIT
