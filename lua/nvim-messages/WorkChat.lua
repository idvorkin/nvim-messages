local sqlite = require('sqlite')
local MessagesApp = require('nvim-messages.messages_app')

local WorkChatMessagesApp = setmetatable({}, { __index = MessagesApp })

WorkChatMessagesApp.__index = WorkChatMessagesApp

function WorkChatMessagesApp.new()
  local self = setmetatable(MessagesApp.new(), WorkChatMessagesApp)
  self.workchat_db_path = '~/work.db'
  if not vim.fn.filereadable(self.workchat_db_path) then
    error('work.db does not exist at ' .. self.workchat_db_path .. ' link it to your workchat db')
  end
  self.db = sqlite({
    uri = self.workchat_db_path,
  })
  self.db:open()
  return self
end

function WorkChatMessagesApp:get_threads()
  local query_top_message_per_thread = [[
        SELECT (coalesce(T.thread_name, STN.thread_name, CPTN.thread_name)) AS display_name ,
            (coalesce(T.thread_name, STN.thread_name, CPTN.thread_name)) AS name ,
            cast( T.thread_key as  text) as id,
            datetime(T.last_activity_timestamp_ms/1000 + strftime("%s", "1970-01-01") ,"unixepoch","localtime")
               as last_activity,
            datetime(T.last_read_watermark_timestamp_ms/1000 + strftime("%s", "1970-01-01") ,"unixepoch","localtime")
               as last_read,
            T.snippet as text

        FROM threads AS T
        LEFT OUTER JOIN _cached_participant_thread_info AS CPTN ON CPTN.thread_key = T.thread_key
        LEFT OUTER JOIN _self_thread_name AS STN ON STN.thread_key = T.thread_key
        ORDER BY last_activity DESC
        LIMIT 1000
    ]]

  return self.db:eval(query_top_message_per_thread)
end

function WorkChatMessagesApp:get_messages(thread_id)
  local query_top_message_per_thread = [[
        SELECT
        user.name as user_name,
        datetime(m.timestamp_ms/1000 + strftime("%s", "1970-01-01") ,"unixepoch","localtime") as time,
        m.text
        from messages m
        JOIN user_contact_info AS user ON m.sender_id = user.contact_id
        LEFT OUTER JOIN _cached_participant_thread_info AS CPTN ON CPTN.thread_key = m.thread_key
        LEFT OUTER JOIN _self_thread_name AS STN ON STN.thread_key = m.thread_key
        LEFT OUTER JOIN threads AS T ON T.thread_key = m.thread_key
        where CPTN.thread_name='Igor Dvorkin'
        or T.thread_key=']] .. thread_id .. [['
        AND m.text <> ''
        order by m.timestamp_ms DESC
        LIMIT 1000
    ]]

  return self.db:eval(query_top_message_per_thread)
end

return WorkChatMessagesApp
