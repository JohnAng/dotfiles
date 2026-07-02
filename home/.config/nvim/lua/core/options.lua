--- @docstring
--- Core editor display, behavior, and formatting options.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- ==========================================
-- UI / DISPLAY
-- ==========================================
vim.o.termguicolors = true -- 24-bit RGB (Windows Terminal ≥ 1.16, undercurl support)
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.cursorline = true
vim.o.cursorlineopt = 'number' -- Line number only, not the whole line (cleaner)
vim.o.signcolumn = 'yes'
vim.o.scrolloff = 10
vim.o.sidescrolloff = 8
vim.o.list = false
vim.o.showbreak = '↪ '
vim.o.wrap = false -- No soft-wrap for code
vim.o.linebreak = true -- If wrap gets enabled somewhere, break at words

-- ==========================================
-- INDENTATION & TEXT EDITING
-- ==========================================
vim.o.breakindent = true
vim.o.autoindent = true
-- IMPORTANT: smartindent OFF because it conflicts with treesitter indent
-- and causes "jumps to start of line" bugs in Python, JSX, YAML etc.
vim.o.smartindent = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftround = true -- > and < round to a multiple of shiftwidth
vim.opt.iskeyword:append '-' -- Words with '-' treated as one (useful in CSS/HTML)
vim.opt.formatoptions:remove { 'c', 'r', 'o' } -- No auto comment continuation on Enter/o/O

-- ==========================================
-- SEARCH
-- ==========================================
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'
vim.o.hlsearch = true

-- ==========================================
-- FILES / UNDO / TIMING
-- ==========================================
vim.o.undofile = true
vim.o.undolevels = 10000
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.confirm = true

-- ==========================================
-- SPLITS
-- ==========================================
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = 'screen'

-- ==========================================
-- COMPLETION UX
-- ==========================================
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.shortmess:append 'c' -- Less noise from ins-completion messages
vim.opt.pumheight = 10 -- Popup menu with more than 10 items becomes scrollable

-- ==========================================
-- CLIPBOARD (WSL-aware)
-- ==========================================
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

if vim.fn.has 'wsl' == 1 then
  -- Prefer win32yank if available (10x faster than PowerShell)
  if vim.fn.executable 'win32yank.exe' == 1 then
    vim.g.clipboard = {
      name = 'win32yank',
      copy = {
        ['+'] = 'win32yank.exe -i --crlf',
        ['*'] = 'win32yank.exe -i --crlf',
      },
      paste = {
        ['+'] = 'win32yank.exe -o --lf',
        ['*'] = 'win32yank.exe -o --lf',
      },
      cache_enabled = 0,
    }
  else
    vim.g.clipboard = {
      name = 'WslClipboard',
      copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe -NoProfile -Command [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ['*'] = 'powershell.exe -NoProfile -Command [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 0,
    }
  end
end
