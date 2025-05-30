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
-- Recursively collect local variable names in the current function scope
local function get_function_args_and_locals(node, bufnr)
  local args = {}
  local locals = {}

  -- Traverse up to find the function definition
  while node and node:type() ~= 'function_definition' and node:type() ~= 'lambda' do
    node = node:parent()
  end

  if node then
    -- Get function arguments
    for child in node:iter_children() do
      if child:type() == 'parameters' then
        for param in child:iter_children() do
          if param:type() == 'identifier' then
            local name = vim.treesitter.get_node_text(param, bufnr)
            args[name] = true
          end
        end
      end
    end

    -- Recursively collect local variables (simple assignment targets)
    local function collect_locals(n)
      if n:type() == 'assignment' then
        local target = n:child(0)
        if target and target:type() == 'identifier' then
          local name = vim.treesitter.get_node_text(target, bufnr)
          locals[name] = true
        end
      end
      for i = 0, n:child_count() - 1 do
        collect_locals(n:child(i))
      end
    end
    collect_locals(node)
  end

  return args, locals
end

local function insert_func_params_with_locals()
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  row = row - 1 -- 0-based

  -- Get the line up to the cursor
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  local before_cursor = line:sub(1, col)

  -- Find the function/class name before the cursor (handles dotted names)
  local name = before_cursor:match '([%w_%.]+)%s*%($'
  if not name then
    vim.notify('No function/class call detected before cursor', vim.log.levels.WARN)
    return
  end

  -- Prepare params for LSP signature help
  local params = vim.lsp.util.make_position_params()
  -- Request signature help from LSP
  vim.lsp.buf_request_all(bufnr, 'textDocument/signatureHelp', params, function(results)
    for _, result in pairs(results) do
      local sig = result.result
      if sig and sig.signatures and sig.signatures[1] then
        local label = sig.signatures[1].label
        -- Extract parameter list from the label
        local param_str = label:match '%((.*)%)'
        if not param_str then
          vim.notify('Could not parse signature label: ' .. label, vim.log.levels.WARN)
          return
        end

        -- Find the call node at the cursor for scope analysis
        local root = vim.treesitter.get_parser(bufnr, 'python'):parse()[1]:root()
        local node = root:descendant_for_range(row, col, row, col)
        while node and node:type() ~= 'call' do
          node = node:parent()
        end

        local args, locals = get_function_args_and_locals(node, bufnr)

        -- Split parameters, handle default values and *args/**kwargs
        local params_out = {}
        for param in param_str:gmatch '[^,]+' do
          local pname = param:match '^%s*([%w_]+)'
          if pname and pname ~= 'self' and pname ~= 'cls' then
            if args[pname] or locals[pname] then
              table.insert(params_out, pname .. '=' .. pname)
            else
              table.insert(params_out, pname .. '=...')
            end
          end
        end

        -- Insert at cursor
        if #params_out > 0 then
          local to_insert = table.concat(params_out, ', ')
          vim.api.nvim_put({ to_insert }, 'c', false, true)
        else
          vim.notify('No parameters found', vim.log.levels.INFO)
        end
        return
      end
    end
    vim.notify('No signature help available', vim.log.levels.WARN)
  end)
end

vim.keymap.set('i', '<C-i>', insert_func_params_with_locals, { buffer = true, desc = 'Insert function/class parameters' })

-- Keys
vim.keymap.set('i', '{', add_f_to_string, { buffer = true })
vim.api.nvim_create_user_command('InsertPyFuncPrintStatement', insert_print_statement, {})
vim.keymap.set('n', '<leader>cp', ':InsertPyFuncPrintStatement<CR>', { desc = 'Insert Print Statement' })
