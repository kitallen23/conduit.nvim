local M = {}

--- Create an interactive input prompt with syntax highlighting for context placeholders.
--- This function wraps vim.ui.input with the plugin's configured input options,
--- merging them with a default value. The input will highlight context placeholders
--- like @buffer, @cursor, @diagnostics based on the plugin configuration.
---
---@param default? string Optional text to prefill the input field
---@param on_confirm fun(value: string|nil) Callback function called when input is confirmed or cancelled
function M.input(default, on_confirm)
  vim.ui.input(
    vim.tbl_deep_extend("force", require("conduit.config").opts.input, {
      default = default,
    }),
    on_confirm
  )
end

---Highlights context placeholders in the input string.
---See `:help input()-highlight`.
---@param input string
---@return table[]
function M.highlight(input)
  local placeholders = vim.tbl_keys(require("conduit.config").opts.contexts)
  local hls = {}

  for _, placeholder in ipairs(placeholders) do
    local init = 1
    while true do
      local start_pos, end_pos = input:find(placeholder, init, true)
      if not start_pos then
        break
      end
      table.insert(hls, {
        start_pos - 1,
        end_pos,
        "@lsp.type.enum",
      })
      init = end_pos + 1
    end
  end

  -- Must occur in-order or neovim will error
  table.sort(hls, function(a, b)
    return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
  end)

  return hls
end

---Highlights context placeholders in the given buffer's first line.
---@param buf number
function M.highlight_buffer(buf)
  local input = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
  local hls = M.highlight(input)

  local ns_id = vim.api.nvim_create_namespace("opencode_placeholders")
  vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

  for _, hl in ipairs(hls) do
    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, hl[1], {
      end_col = hl[2],
      hl_group = hl[3],
    })
  end
end

return M
