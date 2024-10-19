-- based on code at
-- https://github.com/langchain-ai/langchain/blob/master/libs/community/langchain_community/chat_loaders/imessage.py

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

---@return Thread[]
function IMessageChat:get_threads()
  -- NOTE: last_read isn't implemented correctly yet
  local query_top_message_per_thread = [[
    SELECT
      chat.ROWID as id,
      COALESCE(NULLIF(chat.display_name, ''), chat.chat_identifier) as display_name,
      COALESCE(NULLIF(chat.display_name, ''), chat.chat_identifier) as name,
      MAX(message.date) as lasttime,
      "2010-10-10 10:10:10" as last_read,
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

---@param chat_id string
---@return Message[]
function IMessageChat:get_messages(chat_id)
  local query_messages = [[
    SELECT
      CASE
        WHEN message.is_from_me = 1 THEN 'Me'
        ELSE COALESCE(handle.id, 'Unknown')
      END as user_name,
      message.date as time,
      message.text,
      message.attributedBody,
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
    if (not row.text or row.text == '') and row.attributedBody then
      row.text = self:parse_attributed_body(row.attributedBody)
    end
    row.attributedBody = nil -- Remove this field after parsing
  end
  return results
end

function IMessageChat:convert_apple_time(nanoseconds)
  -- Convert nanoseconds since 2001-01-01 to Unix timestamp
  -- TODO debug and fix this function (likely always broken)
  local seconds = nanoseconds / 1e9
  local unix_timestamp = seconds + 978307200 -- Seconds between 1970-01-01 and 2001-01-01
  return os.date('%Y-%m-%d %H:%M:%S', unix_timestamp)
end

-- Not working yet
-- based on  https://github.com/langchain-ai/langchain/pull/13634/commits/1152da66fd5965b21b148c0b6df39629461d9819

function IMessageChat:parse_attributed_body(attributed_body)
  if not attributed_body then
    return nil
  end

  -- Convert the binary data to a Lua string
  local content = tostring(attributed_body)

  -- Find the position of "NSString"
  local ns_pos = content:find('NSString')
  if not ns_pos then
    return nil
  end

  -- Skip "NSString" and 5 more bytes
  local start = ns_pos + 13

  -- Read the length
  local length = content:byte(start)
  start = start + 1

  if length == 0x81 then
    -- For longer messages, length is stored in the next two bytes
    length = (content:byte(start) * 256) + content:byte(start + 1)
    start = start + 2
  end

  -- Extract and return the actual message content
  return content:sub(start, start + length - 1)
end

return IMessageChat
