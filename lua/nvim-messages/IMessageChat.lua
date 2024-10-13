local M = {}
-- based on code at  https://github.com/langchain-ai/langchain/blob/master/libs/community/langchain_community/chat_loaders/imessage.py

local sqlite = require('sqlite')
local MessagesApp = require('nvim-messages.messages_app')

local IMessageChat = setmetatable({}, { __index = MessagesApp })
IMessageChat.__index = IMessageChat

function IMessageChat.new()
  local self = setmetatable(MessagesApp.new(), IMessageChat)
  self.imessage_db_path = vim.fn.expand('~/Library/Messages/chat.db')
  if not vim.fn.filereadable(self.imessage_db_path) then
    error('chat.db does not exist at ' .. self.imessage_db_path)
  end
  self.db = sqlite({
    uri = self.imessage_db_path,
  })
  self.db:open()
  return self
end

function IMessageChat:get_threads()
  local query_top_message_per_thread = [[
    SELECT 
      chat.ROWID as id,
      COALESCE(NULLIF(chat.display_name, ''), chat.chat_identifier) as display_name,
      COALESCE(NULLIF(chat.display_name, ''), chat.chat_identifier) as name,
      MAX(message.date) as lasttime,
      message.text as text
    FROM chat
    JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
    JOIN message ON chat_message_join.message_id = message.ROWID
    LEFT JOIN handle ON message.handle_id = handle.ROWID
    GROUP BY chat.ROWID
    ORDER BY lasttime DESC
    LIMIT 1000
  ]]

  local results = self.db:eval(query_top_message_per_thread)
  for _, row in ipairs(results) do
    row.lasttime = self:convert_apple_time(row.lasttime)
  end
  return results
end

function IMessageChat:get_messages(chat_id)
  local query_messages = [[
    SELECT
      CASE 
        WHEN message.is_from_me = 1 THEN 'Me'
        ELSE COALESCE(handle.id, 'Unknown')
      END as user_name,
      message.date as time,
      message.text,
      message.is_from_me
    FROM message
    JOIN chat_message_join ON message.ROWID = chat_message_join.message_id
    LEFT JOIN handle ON message.handle_id = handle.ROWID
    WHERE chat_message_join.chat_id = ?
    ORDER BY message.date DESC
    LIMIT 1000
  ]]

  local results = self.db:eval(query_messages, { chat_id })
  for _, row in ipairs(results) do
    row.time = self:convert_apple_time(row.time)
  end
  return results
end

function IMessageChat:convert_apple_time(nanoseconds)
  -- Convert nanoseconds since 2001-01-01 to Unix timestamp
  local seconds = nanoseconds / 1e9
  local unix_timestamp = seconds + 978307200 -- Seconds between 1970-01-01 and 2001-01-01
  return os.date('%Y-%m-%d %H:%M:%S', unix_timestamp)
end

return IMessageChat
