--- @docstring
--- Autocommands for visual feedback and auto-saving mechanics.

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
  desc = 'Auto save modified buffers',
  group = vim.api.nvim_create_augroup('custom-autosave', { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    -- Skip if: readonly, non-modifiable, unnamed, special buftypes, or known "non-file" filetypes
    if not vim.bo[buf].modified then return end
    if vim.bo[buf].readonly or not vim.bo[buf].modifiable then return end
    if vim.bo[buf].buftype ~= '' then return end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == '' then return end
    -- Skip filetypes that MUST NOT be silently saved
    local skip_ft = { gitcommit = true, gitrebase = true, hgcommit = true, ['grug-far'] = true, oil = true }
    if skip_ft[vim.bo[buf].filetype] then return end
    pcall(vim.api.nvim_buf_call, buf, function() vim.cmd 'silent! write' end)
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Restore cursor to last position',
  group = vim.api.nvim_create_augroup('last-cursor-pos', { clear = true }),
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Auto-create parent directories on save',
  group = vim.api.nvim_create_augroup('auto-mkdir', { clear = true }),
  callback = function(ev)
    if ev.match:match '^%w+://' then return end
    local dir = vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ':p:h')
    vim.fn.mkdir(dir, 'p')
  end,
})

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,
  jump = { float = true },
}
--- @docstring
--- QoL: Close temporary/utility buffers effortlessly by pressing 'q'.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close temporary buffers with <q>',
  group = vim.api.nvim_create_augroup('close-with-q', { clear = true }),
  pattern = { 'help', 'lspinfo', 'notify', 'qf', 'query', 'checkhealth', 'grug-far' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

--- @docstring
--- UX: Automatically equalize/resize splits when the host terminal window is resized.
vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Automatically resize splits',
  group = vim.api.nvim_create_augroup('resize-splits', { clear = true }),
  callback = function() vim.cmd 'tabdo wincmd =' end,
})
