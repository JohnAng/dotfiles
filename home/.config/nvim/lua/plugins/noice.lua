--- @docstring
--- Noice — stripped config: only centered cmdline + LSP hover UI.
--- Notifications/messages: delegated to snacks.notifier (no nvim-notify dependency).
return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    -- nvim-notify removed: snacks.notifier replaces it
  },
  opts = {
    cmdline = {
      enabled = true,
      view = 'cmdline_popup', -- Centered floating cmdline (noice's main value)
    },
    messages = {
      enabled = true,
      view = 'notify',
      view_error = 'notify',
      view_warn = 'notify',
      view_history = 'messages',
      view_search = 'virtualtext',
    },
    popupmenu = {
      enabled = true,
      backend = 'nui',
    },
    lsp = {
      -- Enhanced markdown rendering in LSP hover / signature help
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
      progress = { enabled = false }, -- fidget/snacks handles it
      hover = { enabled = true },
      signature = { enabled = true },
      message = { enabled = true },
    },
    notify = {
      -- Delegate to snacks.notifier (loaded before noice)
      enabled = true,
    },
    presets = {
      bottom_search = true,
      command_palette = true, -- Centered cmdline + popupmenu combo
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = true, -- Clean border on hover popups
    },
    routes = {
      -- Skip annoying "written" messages
      { filter = { event = 'msg_show', find = 'written' }, opts = { skip = true } },
      -- Skip search hit BOTTOM/TOP spam
      { filter = { event = 'msg_show', kind = 'search_count' }, opts = { skip = true } },
    },
  },
}
