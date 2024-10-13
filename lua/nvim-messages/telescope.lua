local M = {}

-- Make a telescope picker
-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md
--

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values

-- Update the threads_finder function to accept messagesApp as a parameter
local function threads_finder(messagesApp)
  return finders.new_table({
    results = messagesApp:get_threads(),
    entry_maker = function(thread)
      local merged_string = (thread.display_name or '') .. ':' .. (thread.text or '')
      merged_string = merged_string:gsub('[\n\r]', ' '):gsub('%s+', ' ')
      return {
        value = thread,
        display = merged_string,
        ordinal = merged_string,
      }
    end,
  })
end

-- Define highlight groups (you might want to put this in your init.lua or a separate file)
local function setup_highlight_groups()
  local groups = {
    ChatName1 = { fg = '#90EE90' }, -- Light Green
    ChatName2 = { fg = '#ADD8E6' }, -- Light Blue
    ChatName3 = { fg = '#FFA07A' }, -- Light Salmon
    ChatName4 = { fg = '#DDA0DD' }, -- Plum
    ChatName5 = { fg = '#FFB6C1' }, -- Light Pink
    ChatNameSelf = { fg = '#FFFF00', bold = true }, -- Yellow (bold)
    -- Add more as needed
  }
  for group_name, attributes in pairs(groups) do
    vim.api.nvim_set_hl(0, group_name, attributes)
  end
end

-- Call this function when your plugin loads
setup_highlight_groups()

local self = 'Igor'

local function apply_highlights(bufnr, lines)
  local ns_id = vim.api.nvim_create_namespace('chat_highlights')
  local name_groups = {}
  local group_index = 1
  local max_groups = 5 -- Matches the number of ChatName groups we defined

  for i, line in ipairs(lines) do
    local name = line:match('^(%S+):')
    if name then
      if name == self then
        name_groups[name] = 'ChatNameSelf'
      elseif not name_groups[name] then
        name_groups[name] = 'ChatName' .. group_index
        group_index = (group_index % max_groups) + 1
      end
      local start, finish = line:find(name)
      if start then
        vim.api.nvim_buf_add_highlight(bufnr, ns_id, name_groups[name], i - 1, start - 1, finish)
      end
    end
  end
end

local function thread_preview(messagesApp)
  local previewers = require('telescope.previewers')
  return previewers.new_buffer_previewer({
    title = 'Thread Preview',
    define_preview = function(self, entry, _status)
      local thread = entry.value
      local preview_lines = {}
      local messages = messagesApp:get_messages(thread.id)
      -- if messages isn't a table, make it a blank table
      if type(messages) ~= 'table' then
        messages = {}
      end

      for _, message in ipairs(messages) do
        local first_name = (message.user_name or ''):match('^(%S+)')
        local merged_string = first_name .. ': ' .. (message.text or '')
        merged_string = merged_string:gsub('[\n\r]', ' '):gsub('%s+', ' ')
        table.insert(preview_lines, merged_string)
      end

      for _, e in ipairs(thread) do
        table.insert(preview_lines, e)
      end
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
      apply_highlights(self.state.bufnr, preview_lines)
    end,
  })
end

-- Modify the chat_pickers function to pass messagesApp to thread_preview
local function chat_pickers(opts, messagesApp)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'Chats',
      previewer = thread_preview(messagesApp),
      finder = threads_finder(messagesApp),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local thread = selection.value

          -- Create a new buffer
          local buf = vim.api.nvim_create_buf(true, true)
          vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
          vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
          vim.api.nvim_buf_set_name(buf, 'Thread: ' .. thread.display_name)

          -- Get messages for the selected thread
          local messages = messagesApp:get_messages(thread.id)
          local buf_lines = {}
          for _, message in ipairs(messages) do
            local first_name = (message.user_name or ''):match('^(%S+)')
            local merged_string = first_name .. ': ' .. (message.text or '')
            merged_string = merged_string:gsub('[\n\r]', ' '):gsub('%s+', ' ')
            table.insert(buf_lines, merged_string)
          end

          -- Reverse the order of lines before setting them in the buffer.
          local reversed_buf_lines = {}
          for i = #buf_lines, 1, -1 do
            table.insert(reversed_buf_lines, buf_lines[i])
          end

          -- Set the buffer contents
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, reversed_buf_lines)

          -- Open the buffer in a new window
          vim.api.nvim_command('new')
          vim.api.nvim_win_set_buf(0, buf)

          apply_highlights(buf, reversed_buf_lines)

          -- Jump to the bottom line
          vim.api.nvim_command('normal! G')
        end)

        return true
      end,
    })
    :find()
end

--for i, thread in ipairs(GetThreads()) do
---- print(i, thread)
--end

--local colors = { "red", "green", "blue" }
--print (colors)
--for i, thread in ipairs(colors) do
--print(i, thread)
--end

local l = {
  layout_strategy = 'vertical',
  layout_config = {
    vertical = {
      prompt_position = 'top',
      mirror = true,
      preview_height = 0.5, -- Adjust this value to set the height of the preview window
    },
    preview_cutoff = 1, -- Ensures the preview window is always shown
  },
}

-- Modify the exported function to accept messagesApp as a parameter
M.show_chats = function(messagesApp, opts)
  opts = opts
    or {
      layout_strategy = 'vertical',
      layout_config = {
        vertical = {
          prompt_position = 'top',
          mirror = true,
          preview_height = 0.5,
        },
        preview_cutoff = 1,
      },
    }
  chat_pickers(opts, messagesApp)
end

return M
