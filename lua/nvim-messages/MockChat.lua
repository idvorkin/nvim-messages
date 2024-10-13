local MessagesApp = require('nvim-messages.messages_app')

local MockChat = setmetatable({}, { __index = MessagesApp })
MockChat.__index = MockChat

function MockChat.new()
  local self = setmetatable(MessagesApp.new(), MockChat)
  self.threads = {
    {
      id = 'thread1',
      name = 'John Doe',
      display_name = 'John Doe',
      text = "Hey, how's it going?",
      time = os.time() - 3600,
    },
    {
      id = 'thread2',
      name = 'Jane Smith',
      display_name = 'Jane Smith',
      text = "Don't forget about the meeting tomorrow!",
      timestamp = os.time() - 7200,
    },
    {
      id = 'thread3',
      name = 'Neovim Team',
      display_name = 'Neovim Team',
      text = 'New plugin release: nvim-messages',
      time = os.time() - 86400,
    },
  }

  self.messages = {
    thread1 = {
      {
        id = 'msg1',
        user_name = 'John Doe',
        text = "Hey, how's it going?",
        time = os.time() - 3600,
      },
      {
        id = 'msg2',
        user_name = 'You',
        text = "Hi John! I'm doing well, thanks. How about you?",
        time = os.time() - 3540,
      },
    },
    thread2 = {
      {
        id = 'msg3',
        user_name = 'Jane Smith',
        text = "Don't forget about the meeting tomorrow!",
        time = os.time() - 7200,
      },
      {
        id = 'msg4',
        user_name = 'You',
        text = 'Thanks for the reminder. What time was it again?',
        time = os.time() - 7140,
      },
    },
    thread3 = {
      {
        id = 'msg5',
        user_name = 'Neovim Team',
        text = 'New plugin release: nvim-messages',
        time = os.time() - 86400,
      },
      {
        id = 'msg6',
        user_name = 'You',
        text = "Awesome! Can't wait to try it out.",
        time = os.time() - 86340,
      },
    },
  }
  return self
end

function MockChat:get_threads()
  return self.threads
end

function MockChat:get_messages(thread_id)
  return self.messages[thread_id] or {}
end

return MockChat
