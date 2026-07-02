--- @docstring
--- Global keymaps for general functionality, window management, and data extraction.

local map = vim.keymap.set

-- ==========================================
-- GENERAL / NAVIGATION
-- ==========================================
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
map('n', '<leader>a', 'gg<S-v>G', { desc = 'Select all text' })

--- @docstring
--- <leader>? : Open CHEATSHEET in floating window (covers defaults + custom + plugins).
map('n', '<leader>?', function()
  local path = vim.fn.stdpath 'config' .. '/docs/CHEATSHEET.md'
  local buf = vim.fn.bufnr(path, false)
  if buf == -1 then
    buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buf, path)
    vim.api.nvim_buf_call(buf, function() vim.cmd('silent! edit ' .. vim.fn.fnameescape(path)) end)
  end
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  local width = math.min(120, math.floor(vim.o.columns * 0.9))
  local height = math.floor(vim.o.lines * 0.9)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Keybindings Cheatsheet ',
    title_pos = 'center',
  })
  vim.wo.wrap = false
  vim.wo.conceallevel = 2
  vim.wo.foldenable = false
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end, { desc = 'Open Cheatsheet (all keybinds)' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--- @docstring
--- Search Centering: Keep the cursor in the middle of the screen when jumping between search results.
map('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search result (centered)' })

--- @docstring
--- Open Man Page for the word under the cursor using native Unix tools.
map('n', 'gK', function()
  local word = vim.fn.expand '<cword>'
  vim.cmd('Man ' .. word)
end, { desc = 'Open Man Page for word under cursor' })

-- ==========================================
-- TEXT EDITING / MANIPULATION
-- ==========================================
--- @docstring
--- Cursor Stabilization: Keep cursor strictly in place when joining lines.
map('n', 'J', 'mzJ`z', { desc = 'Join lines without moving cursor' })

--- @docstring
--- Continuous Visual Indentation: Keep selection active after shifting.
map('v', '<', '<gv', { desc = 'Dedent line and keep selection' })
map('v', '>', '>gv', { desc = 'Indent line and keep selection' })

-- Block Movement: now provided by mini.move (Alt+j/k/h/l)
-- Advantage: works in normal mode too, keeps selection, dot-repeatable.

--- @docstring
--- The Void Paste: Prevent replacing clipboard when pasting over selected text.
map('x', 'p', '"_dP', { desc = 'Paste without overwriting register' })

-- ==========================================
-- DIAGNOSTICS & DATA EXTRACTION
-- ==========================================
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic error messages' })
map('n', '<leader>xq', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })

--- @docstring
--- DRY Function for extracting diagnostics based on scope (0 = Buffer, nil = Project)
local function extract_warnings(scope_bufnr, scope_name)
  local warnings = vim.diagnostic.get(scope_bufnr, { severity = vim.diagnostic.severity.WARN })

  if #warnings == 0 then
    vim.notify('No LSP warnings found in ' .. scope_name .. '.', vim.log.levels.INFO)
    return
  end

  local output = {}
  table.insert(output, '--- LSP Warnings Report (' .. scope_name .. ') ---')

  for _, diag in ipairs(warnings) do
    local file_name = scope_bufnr == nil and (vim.fn.fnamemodify(vim.api.nvim_buf_get_name(diag.bufnr), ':.') .. ': ') or ''
    local line_text = string.format('%sLine %d: %s', file_name, diag.lnum + 1, diag.message)
    table.insert(output, line_text)
  end

  vim.fn.setreg('+', table.concat(output, '\n'))
  vim.notify(string.format('Successfully copied %d warnings to clipboard!', #warnings), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('CopyBufferWarnings', function() extract_warnings(0, 'Buffer') end, { desc = 'Copy Buffer Warnings' })
vim.api.nvim_create_user_command('CopyProjectWarnings', function() extract_warnings(nil, 'Project') end, { desc = 'Copy Project Warnings' })

map('n', '<leader>xw', '<cmd>CopyBufferWarnings<cr>', { desc = 'Copy Buffer Warnings to Clipboard' })
map('n', '<leader>xW', '<cmd>CopyProjectWarnings<cr>', { desc = 'Copy Project Warnings to Clipboard' })

-- ==========================================
-- THEME PICKER (TOP 10 DARK — pro-used)
-- ==========================================
--- Curated top-30 dark themes. Refreshed pro-favorites (2024–2025).
local TOP_DARK_THEMES = {
  -- ── Tokyo family ──────────────────────────────────────────────
  { name = 'tokyonight-night',  label = '  1. Tokyo Night · Night    · folke, LazyVim default' },
  { name = 'tokyonight-moon',   label = '  2. Tokyo Night · Moon     · soft nocturnal' },
  { name = 'tokyonight-storm',  label = '  3. Tokyo Night · Storm    · stormier blue' },
  { name = 'tokyodark',         label = '  4. Tokyodark              · deeper tokyo-inspired' },
  -- ── Kanagawa (Japanese-inspired) ──────────────────────────────
  { name = 'kanagawa-dragon',   label = '  5. Kanagawa · Dragon      · dramatic senior-dev fav' },
  { name = 'kanagawa-wave',     label = '  6. Kanagawa · Wave        · smoother kanagawa' },
  -- ── Nightfox family (EdenEast) ────────────────────────────────
  { name = 'nightfox',          label = '  7. Nightfox               · EdenEast flagship' },
  { name = 'carbonfox',         label = '  8. Carbonfox              · deep monotone' },
  { name = 'duskfox',           label = '  9. Duskfox                · purple-dusk tones' },
  { name = 'nordfox',           label = ' 10. Nordfox                · nord palette' },
  { name = 'terafox',           label = ' 11. Terafox                · warm earth tones' },
  -- ── Nord-inspired blends ──────────────────────────────────────
  { name = 'onenord',           label = ' 12. OneNord                · Nord + OneDark blend' },
  { name = 'nightfly',          label = ' 13. Nightfly               · bluz71, blue accent' },
  { name = 'moonfly',           label = ' 14. Moonfly                · bluz71 sister, subtle' },
  -- ── Modern / trendy 2024 ──────────────────────────────────────
  { name = 'poimandres',        label = ' 15. Poimandres             · cyberpunk-ish deep' },
  { name = 'vague',             label = ' 16. Vague                  · minimal 2024, muted' },
  { name = 'oxocarbon',         label = ' 17. Oxocarbon              · IBM Carbon inspired' },
  -- ── Warm / calm classics ──────────────────────────────────────
  { name = 'predawn',           label = ' 18. Predawn                · Jamie Wilson, warm cult classic' },
  { name = 'bamboo',            label = ' 19. Bamboo                 · fresh green, calm' },
  { name = 'iceberg',           label = ' 20. Iceberg                · cult classic, blueish' },
  { name = 'melange',           label = ' 21. Melange                · warm dark, refined' },
  -- ── Classic revival ───────────────────────────────────────────
  { name = 'sonokai',           label = ' 22. Sonokai                · sainnhe, monokai-esque' },
  { name = 'edge',              label = ' 23. Edge                   · sainnhe, clean editor' },
  { name = 'onedark',           label = ' 24. OneDark                · Atom classic revived' },
  { name = 'doom-one',          label = ' 25. Doom One               · Doom Emacs classic' },
  { name = 'ayu-mirage',        label = ' 26. Ayu Mirage             · calm blue-gray' },
  -- ── Accessible / IDE-familiar ─────────────────────────────────
  { name = 'modus_vivendi',     label = ' 27. Modus Vivendi          · WCAG AAA accessible' },
  { name = 'vscode',            label = ' 28. VSCode Dark            · for VS Code refugees' },
}

local function save_theme(name)
  local filepath = vim.fn.stdpath 'config' .. '/lua/core/saved_theme.lua'
  local file = io.open(filepath, 'w')
  if file then
    file:write(string.format('return %q\n', name))
    file:close()
  end
end

--- Top 10 dark themes picker (curated)
vim.keymap.set('n', '<leader>fc', function()
  vim.ui.select(TOP_DARK_THEMES, {
    prompt = 'Pick a dark theme (top-used by pros):',
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice then return end
    local ok, err = pcall(vim.cmd.colorscheme, choice.name)
    if not ok then
      vim.notify('Failed: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end
    save_theme(choice.name)
    vim.notify(('Theme changed -> %s (persistent)'):format(choice.name), vim.log.levels.INFO)
  end)
end, { desc = 'Find [C]olorscheme (top-30 dark, curated)' })

--- Preview all installed themes with live preview (Telescope)
vim.keymap.set('n', '<leader>fC', function()
  require('telescope.builtin').colorscheme {
    enable_preview = true,
    attach_mappings = function(prompt_bufnr)
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection == nil then return end
        vim.cmd.colorscheme(selection[1])
        save_theme(selection[1])
        vim.notify('Theme changed -> ' .. selection[1] .. ' (persistent)', vim.log.levels.INFO)
      end)
      return true
    end,
  }
end, { desc = 'Find [C]olorscheme (all installed · preview)' })
