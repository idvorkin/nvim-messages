local MessagesApp = {}
MessagesApp.__index = MessagesApp

function MessagesApp.new()
  return setmetatable({}, MessagesApp)
end

function MessagesApp:get_threads()
  error('get_threads must be implemented by subclass')
end

function MessagesApp:get_messages(thread_id)
  error('get_messages must be implemented by subclass')
end

return MessagesApp
