local function add_f_to_string()
  vim.api.nvim_feedkeys('{', 'n', true)

  local add_f = function(node)
    local sr, sc, er, _ = node:range()
    local string_start_content = vim.treesitter.get_node_text(node, 0)
    if not string.find(string_start_content, 'f') then
      vim.api.nvim_buf_set_text(0, sr, sc, er, sc, { 'f' })
    end
  end
  local function find_string_start(node)
    for child in node:iter_children() do
      if child:type() == 'string_start' then
        return child
      else
        local child_result = find_string_start(child)
        if child_result then
          return child_result
        end
      end
    end
    return nil
  end

  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  r = r - 1
  c = c - 1

  local current_node = vim.treesitter.get_parser(0, 'python'):parse()[1]:root():descendant_for_range(r, c, r, c)
  if not current_node then
    return
  end
  if current_node:type() == 'ERROR' then
    local string_start_in_err = find_string_start(current_node)
    if string_start_in_err then
      add_f(string_start_in_err)
    end
  end
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

-- Function to recursively get all identifier nodes from a parameters node
local function get_identifiers_from_parameters(parameters_node, identifiers)
  identifiers = identifiers or {} -- Initialize the identifiers list if it's nil

  if not parameters_node then
    return identifiers
  end

  for i = 0, parameters_node:child_count() - 1 do
    local child = parameters_node:child(i)

    if child:type() == 'identifier' then
      table.insert(identifiers, child)
    elseif child:type() == 'type' then
      break
    elseif child:child_count() > 0 then -- Recursively process non-leaf nodes
      get_identifiers_from_parameters(child, identifiers)
    end
  end

  return identifiers
end
-- Function to insert a print statement with function name and arguments
local function insert_print_statement()
  -- Get the current buffer
  local buf = vim.api.nvim_get_current_buf()

  -- Get the current cursor position
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

  -- Use treesitter to find the nearest function definition
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local node = ts_utils.get_node_at_cursor()

  -- Traverse up the tree to find the function definition node
  while node and node:type() ~= 'function_definition' and node:type() ~= 'method_definition' do
    node = node:parent()
  end

  if not node then
    vim.notify('No function definition found near the cursor.', vim.log.levels.WARN)
    return
  end

  -- Extract the function name
  local function_name_node = node:child(0) -- Usually the identifier
  if node:type() == 'method_definition' or node:type() == 'function_definition' then
    function_name_node = node:child(1) -- For methods, the name is the second child
  end

  if function_name_node == nil then
    vim.notify('No function name found', vim.log.levels.WARN)
    return
  end
  local function_name = vim.treesitter.get_node_text(function_name_node, buf)

  -- Extract the parameters
  local parameters = {}
  -- Iterate through the children of the function definition node
  for i = 0, node:child_count() - 1 do
    local child = node:child(i)
    -- Check if the child is a parameter list (this might vary depending on the language)
    if child:type() == 'parameters' or child:type() == 'parameter_list' then -- Adjust these types as needed for your language
      -- Recursively get all identifier nodes from the parameters node
      local identifier_nodes = get_identifiers_from_parameters(child)

      -- Extract the parameter names from the identifier nodes
      for _, identifier_node in ipairs(identifier_nodes) do
        local param_name = vim.treesitter.get_node_text(identifier_node, buf)
        table.insert(parameters, param_name)
      end

      break -- Stop searching after finding the parameter list
    end
  end

  -- Construct the print statement
  local print_statement = 'print(f"' .. function_name .. '('

  local arg_strings = {}
  for _, param in ipairs(parameters) do
    table.insert(arg_strings, '{' .. param .. '=}')
  end

  print_statement = print_statement .. table.concat(arg_strings, ', ') .. ')")'

  -- Insert the print statement into the buffer
  vim.api.nvim_buf_set_lines(buf, row - 1, row - 1, false, { print_statement })

  -- Move the cursor to the next line
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end

-- Keys
vim.keymap.set('i', '{', add_f_to_string, { buffer = true })
vim.api.nvim_create_user_command('InsertPyFuncPrintStatement', insert_print_statement, {})
vim.keymap.set('n', '<leader>cp', ':InsertPyFuncPrintStatement<CR>', { desc = 'Insert Print Statement' })
