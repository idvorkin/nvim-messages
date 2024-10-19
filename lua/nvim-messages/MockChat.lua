local MessagesApp = require('nvim-messages.messages_app')

---@class MockChat : MessagesApp
local MockChat = setmetatable({}, { __index = MessagesApp })
MockChat.__index = MockChat

function MockChat.new()
  local self = setmetatable(MessagesApp.new(), MockChat)

  ---@type Thread[]
  self.threads = {
    {
      id = 'thread1',
      name = 'John Doe',
      display_name = 'John Doe',
      text = "Hey, how's it going?",
      last_activity = os.date('%Y-%m-%d %H:%M:%S', os.time() - 3600),
      last_read = os.date('%Y-%m-%d %H:%M:%S', os.time() - 3500),
    },
    {
      id = 'thread2',
      name = 'Jane Smith',
      display_name = 'Jane Smith',
      text = "Don't forget about the meeting tomorrow!",
      last_activity = os.date('%Y-%m-%d %H:%M:%S', os.time() - 7200),
      last_read = os.date('%Y-%m-%d %H:%M:%S', os.time() - 7100),
    },
    {
      id = 'thread3',
      name = 'Neovim Team',
      display_name = 'Neovim Team',
      text = 'New plugin release: nvim-messages',
      last_activity = os.date('%Y-%m-%d %H:%M:%S', os.time() - 86400),
      last_read = os.date('%Y-%m-%d %H:%M:%S', os.time() - 86300),
    },
  }

  ---@type table<string, Message[]>
  self.messages = {
    thread1 = {
      {
        user_name = 'John Doe',
        text = "Hey, how's it going?",
        time = os.date('%Y-%m-%d %H:%M:%S', os.time() - 3600),
      },
      {
        user_name = 'You',
        text = "Hi John! I'm doing well, thanks. How about you?",
        time = os.date('%Y-%m-%d %H:%M:%S', os.time() - 3540),
      },
    },
    thread2 = {
      {
        user_name = 'Jane Smith',
        text = "Don't forget about the meeting tomorrow!",
        time = os.date('%Y-%m-%d %H:%M:%S', os.time() - 7200),
      },
      {
        user_name = 'You',
        text = 'Thanks for the reminder. What time was it again?',
        time = os.date('%Y-%m-%d %H:%M:%S', os.time() - 7140),
      },
    },
    thread3 = {
      {
        user_name = 'Neovim Team',
        text = 'New plugin release: nvim-messages',
        time = os.date('%Y-%m-%d %H:%M:%S', os.time() - 86400),
      },
      {
        user_name = 'You',
        text = "Awesome! Can't wait to try it out.",
        time = os.date('%Y-%m-%d %H:%M:%S', os.time() - 86340),
      },
    },
  }
  return self
end

---@return Thread[]
function MockChat:get_threads()
  return self.threads
end

---@param thread_id string
---@return Message[]
function MockChat:get_messages(thread_id)
  return self.messages[thread_id] or {}
end

return MockChat
