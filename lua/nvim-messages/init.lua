local M = {}

M.setup = function()
  print('hello from nvim-messages.init.lua')
end

M.workchat = function()
  local messagesApp = require('nvim-messages.WorkChat').new()
  require('nvim-messages.telescope').show_chats(messagesApp)
end

M.mockchat = function()
  local messagesApp = require('nvim-messages.MockChat').new()
  require('nvim-messages.telescope').show_chats(messagesApp)
end

M.imessage = function()
  local messagesApp = require('nvim-messages.IMessageChat').new()
  require('nvim-messages.telescope').show_chats(messagesApp)
end

return M
