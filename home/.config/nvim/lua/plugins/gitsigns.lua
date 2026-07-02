--- @docstring
--- Super fast git decorations and Hunk management workflow.
return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },

    -- @docstring
    -- Inline Git Blame Engine (VS Code GitLens equivalent)
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 300, -- Debounce rendering to prevent visual flickering during fast scrolls
      virt_text_pos = 'eol', -- Renders at the End Of Line
    },

    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end

      -- Navigation
      map('n', ']h', function()
        if vim.wo.diff then return ']h' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, 'Next Hunk')

      map('n', '[h', function()
        if vim.wo.diff then return '[h' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, 'Prev Hunk')

      -- Actions (Under the <leader>h namespace we reserved)
      map('n', '<leader>hp', gs.preview_hunk, 'Preview Git Hunk')
      map('n', '<leader>hr', gs.reset_hunk, 'Reset Git Hunk')
      map('n', '<leader>hs', gs.stage_hunk, 'Stage Git Hunk')
      map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo Stage Hunk')
    end,
  },
}
