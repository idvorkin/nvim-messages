---@class Thread
---@field display_name string
---@field name string
---@field id string
---@field last_activity string
---@field last_read string
---@field text string

---@class Message
---@field user_name string
---@field time string
---@field text string

local MessagesApp = {}
MessagesApp.__index = MessagesApp

function MessagesApp.new()
  return setmetatable({}, MessagesApp)
end

---@return Thread[]
function MessagesApp:get_threads() -- luacheck: no unused args
  error('get_threads must be implemented by subclass')
end

---@param thread_id string
---@return Message[]
function MessagesApp:get_messages(thread_id) -- luacheck: no unused args
  error('get_messages must be implemented by subclass')
end

return MessagesApp
