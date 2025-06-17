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
local function add_missing_kwarg_names()
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  row = row - 1 -- 0-based

  -- Find the call node at the cursor
  local parser = vim.treesitter.get_parser(bufnr, 'python')
  local root = parser:parse()[1]:root()
  local node = root:descendant_for_range(row, col, row, col)
  while node and node:type() ~= 'call' do
    node = node:parent()
  end
  if not node then
    vim.notify('No function/class call found at cursor', vim.log.levels.WARN)
    return
  end

  -- Get the function/class name text
  local function get_func_name(n)
    -- For call: (function ( arguments ))
    local child = n:child(0)
    if child:type() == 'attribute' then
      -- e.g. foo.bar()
      return vim.treesitter.get_node_text(child, bufnr)
    elseif child:type() == 'identifier' then
      return vim.treesitter.get_node_text(child, bufnr)
    elseif child:type() == 'call' then
      return get_func_name(child)
    end
    return nil
  end

  local func_name = get_func_name(node)
  if not func_name then
    vim.notify('Could not determine function/class name', vim.log.levels.WARN)
    return
  end

  -- Get argument nodes
  local arglist_node = node:field('arguments')[1]
  if not arglist_node then
    vim.notify('No arguments found in call', vim.log.levels.WARN)
    return
  end

  -- Gather argument nodes and their text
  local args = {}
  for i = 0, arglist_node:child_count() - 1 do
    local arg = arglist_node:child(i)
    -- skip commas
    if arg:type() ~= ',' then
      table.insert(args, { node = arg, text = vim.treesitter.get_node_text(arg, bufnr) })
    end
  end

  -- Use LSP to get the parameter names
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request_all(bufnr, 'textDocument/signatureHelp', params, function(results)
    for _, result in pairs(results) do
      local sig = result.result
      if sig and sig.signatures and sig.signatures[1] then
        local label = sig.signatures[1].label
        -- Extract parameter list from the signature label
        local param_str = label:match '%((.*)%)'
        if not param_str then
          vim.notify('Could not parse signature label: ' .. label, vim.log.levels.WARN)
          return
        end

        -- Split parameters, handle default values and *args/**kwargs
        local param_names = {}
        for param in vim.split(param_str, ',', true) do
          -- Remove type annotations and default values
          local pname = param:match '^%s*([%w_]+)'
          if pname and pname ~= 'self' and pname ~= 'cls' then
            table.insert(param_names, pname)
          end
        end

        -- For each argument, check if it already has a keyword
        local new_args = {}
        local arg_idx = 1
        for i, param_name in ipairs(param_names) do
          local arg = args[arg_idx]
          if not arg then
            break
          end
          local is_kw = arg.text:find '^%s*[%w_]+%s*='
          if is_kw then
            table.insert(new_args, arg.text)
          else
            table.insert(new_args, param_name .. '=' .. arg.text)
          end
          arg_idx = arg_idx + 1
        end

        -- If there are remaining arguments (e.g. kwargs), just append them as is
        for i = arg_idx, #args do
          table.insert(new_args, args[i].text)
        end

        -- Replace the argument list in the buffer
        local start_row, start_col, end_row, end_col = arglist_node:range()
        local before = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]:sub(1, start_col)
        local after = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1]:sub(end_col + 1)
        local replacement = before .. table.concat(new_args, ', ') .. after
        vim.api.nvim_buf_set_lines(bufnr, start_row, start_row + 1, false, { replacement })

        -- Move cursor to after the argument list
        vim.api.nvim_win_set_cursor(win, { end_row + 1, end_col })
        return
      end
    end
    vim.notify('No signature help available', vim.log.levels.WARN)
  end)
end

function insert_inlay_hints()
  -- Get the current buffer
  local buf = vim.api.nvim_get_current_buf()

  local range
  if vim.tbl_contains({ 'v', 'V', '\22' }, vim.fn.mode()) then
    local s_pos = vim.fn.getpos 'v'
    local e_pos = vim.fn.getpos '.'

    local s_row, s_col = s_pos[2], s_pos[3]
    local e_row, e_col = e_pos[2], e_pos[3]

    if s_row > e_row or (s_row == e_row and s_col > e_col) then
      s_row, e_row = e_row, s_row
      s_col, e_col = e_col, s_col
    end

    range = {
      start = { line = s_row - 1, character = 0 },
      ['end'] = { line = e_row + 1, character = 0 },
    }
  else
    local current_line, _ = unpack(vim.api.nvim_win_get_cursor(0))
    range = {
      start = { line = current_line - 1, character = 0 },
      ['end'] = { line = current_line, character = 0 },
    }
  end

  vim.print(range)

  local hints = vim.lsp.inlay_hint.get {
    bufnr = 0, -- 0 for current buffer
    range = range,
  }
  vim.print(hints)
  for _, hint in pairs(hints) do
    vim.lsp.util.apply_text_edits(hint.inlay_hint.textEdits, buf, 'utf-8')
  end
end

-- Keys
vim.keymap.set('i', '{', add_f_to_string, { buffer = true, desc = 'Auto add f to string' })
vim.api.nvim_create_user_command('InsertPyFuncPrintStatement', insert_print_statement, {})
vim.keymap.set('n', '<leader>id', ':InsertPyFuncPrintStatement<CR>', { desc = '[I]nsert [D]ebug Statement' })
vim.keymap.set('n', '<leader>ip', insert_func_params_with_locals, { buffer = true, desc = '[I]nsert function/class [p]arameters' })
vim.keymap.set('n', '<leader>ih', insert_inlay_hints, { buffer = true, desc = '[I]nsert inlay [h]ints' })
vim.keymap.set('v', '<leader>ih', insert_inlay_hints, { buffer = true, desc = '[I]nsert inlay [h]ints' })
