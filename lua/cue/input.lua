local M = {}

---@param default? string
---@param on_confirm fun(value: string|nil)
function M.input(default, on_confirm)
  vim.ui.input(
  -- vim.tbl_deep_extend("force", require("cue.config").opts.input, {
    vim.tbl_deep_extend("force", {}, {
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
  local placeholders = vim.tbl_keys(require("cue.config").opts.contexts)
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

return M
