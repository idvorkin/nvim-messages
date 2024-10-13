local M = {}
local vim = vim

-- Function to show a message
function M.show_message(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify(msg, level)
end

-- Function to set up the plugin
function M.setup(opts)
  opts = opts or {}
  -- Add any setup logic here
  print('nvim-messages plugin setup')
end

-- Return the module
return M
