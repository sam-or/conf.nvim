local function add_f_to_string()
  vim.api.nvim_feedkeys('{', 'n', true)

  local current_node = vim.treesitter.get_node()

  if not current_node then
    return
  end

  if current_node:type() == 'string_content' then
    local string_start_node = current_node:prev_named_sibling()
    if string_start_node and string_start_node:type() == 'string_start' then
      local sr, sc, er, ec = string_start_node:range()
      local string_start_content = vim.api.nvim_buf_get_text(0, sr, sc, er, ec, {})[1]
      if not string.find(string_start_content, 'f') then
        vim.print "f'd the string"
        vim.api.nvim_buf_set_text(0, sr, sc, er, sc, { 'f' })
      end
    end
  end
end

vim.keymap.set('i', '{', add_f_to_string, { buffer = true })
