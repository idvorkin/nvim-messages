# nvim-messages

<img width="1487" alt="image" src="https://github.com/user-attachments/assets/60f66d69-a71e-4e06-a94e-3f01d89e0326">

A plugin designed to let you read messages from messaging apps, supports iMessage, and WorkChat, should be extendable to any messaging app.

**NOTES:**

- This is my first plugin, so bear with me, better yet, send PRs
- iMessage is still being implemented - see [IMessageChat.lua](lua/nvim-messages/IMessageChat.lua)
- Reading messages is much easier than sending messages, so I'm starting there. Again, send PRs
- UX is hard, so I'm starting with a telescope extension.
  - I can imagine we get to a [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) like interface, send a PR

## Usage

Launch Via Telescope For your chat provider

```lua
-- I'm still learning to set up the telescope providers correctly
command! WorkChat :lua require('nvim-messages').workchat()
command! MockChat :lua require('nvim-messages').mockchat()
command! IMessageChat :lua require('nvim-messages').imessage()
```

## Installation

Install via lazy

```lua
{
    "idvorkin/nvim-messages.nvim",
    requires = {
        {
            "kkharji/sqlite.lua",
            "nvim-telescope/telescope.nvim",
        },
    },
},
```

If you have a custom SQLite location, you need to specify it. For me:

```lua
local sqlite_path = "/Users/idvorkin/homebrew/opt/sqlite/lib/libsqlite3.dylib"
if vim.loop.fs_stat(sqlite_path) then
    vim.g.sqlite_clib_path = sqlite_path
end
```

If you use WorkChat, you need to have a symlink in your home directory to ~/work.db (hacky will clean up later)

```bash
ln -s ~/Library/Application\ Support/Workplace/msys_path.db ~/work.db
```

## Acknowledgements

- Inspired by [Langchain Chat Loaders](https://python.langchain.com/docs/integrations/chat_loaders/)
- Started via [nvim-plugin-template](https://github.com/nvimdev/nvim-plugin-template)

## Development

- Develop a Neovim plugin: https://m4xshen.dev/posts/develop-a-neovim-plugin-in-lua
- Neovim best practices: https://github.com/nvim-neorocks/nvim-best-practices
- A nice [video](https://www.youtube.com/watch?v=yN04HCeOjmo&ab_channel=Cloud-NativeCorner) on how to structure a plugin, with [slides](https://github.com/Piotr1215/youtube/blob/main/nvim-plugins/slides.md)

To see this template in action, take a look at my other plugins.

## License MIT
