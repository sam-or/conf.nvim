local function add_f_to_string()
  vim.api.nvim_feedkeys('{', 'n', true)
  local add_f = function(node)
    local sr, sc, er, ec = node:range()
    local string_start_content = vim.treesitter.get_node_text(node, 0)
    if not string.find(string_start_content, 'f') then
      vim.print "f'd the string"
      vim.api.nvim_buf_set_text(0, sr, sc, er, sc, { 'f' })
    end
  end

  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  r = r - 1
  c = c - 1

  local current_node = vim.treesitter.get_parser(0, 'python'):parse()[1]:root():descendant_for_range(r, c, r, c)
  if not current_node then
    return
  end
  Snacks.debug.inspect(current_node:type(), current_node:parent():type(), current_node:parent():parent():type(), current_node:parent():parent():parent():type())

  if current_node:type() == 'string_start' then
    add_f(current_node)
  end
  if current_node:type() == 'string_content' or current_node:type() == 'string_end' then
    local string_start_node = current_node:prev_named_sibling()
    if string_start_node and string_start_node:type() == 'string_start' then
      add_f(string_start_node)
      return
    end
  end
end

vim.keymap.set('i', '{', add_f_to_string, { buffer = true })
