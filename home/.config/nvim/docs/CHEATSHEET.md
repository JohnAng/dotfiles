# Neovim Cheatsheet — Angel's Setup

> Open anytime with **`<leader>?`** (Space + ?)
> Fuzzy search over ALL active keymaps: **`<leader>sk`**
> Dynamic which-key popup: press **`<leader>`** and wait

---

## 📚 VIM DEFAULTS — Motions (built-in, no plugin)

### Basic cursor movement
| Key | Action |
|-----|--------|
| `h` `j` `k` `l` | Left / Down / Up / Right |
| `w` / `W` | Next word (word / WORD) |
| `b` / `B` | Previous word |
| `e` / `E` | End of current word |
| `ge` | End of previous word |
| `0` | Start of line (col 1) |
| `^` | First non-blank char of line |
| **`$`** | **End of line** |
| `g_` | Last non-blank char |
| `gg` | Start of file |
| `G` | End of file |
| `{n}G` / `:{n}` | Go to line n |
| `%` | Match bracket / tag |
| `H` `M` `L` | Top / middle / bottom of screen |
| `zz` / `zt` / `zb` | Center / top / bottom cursor |
| `Ctrl+u` / `Ctrl+d` | ½ page up/down (smooth via snacks) |
| `Ctrl+b` / `Ctrl+f` | Full page up/down (smooth) |
| `Ctrl+o` / `Ctrl+i` | Jump list back / forward |

### Search & jumps
| Key | Action |
|-----|--------|
| `/{pattern}` | Search forward |
| `?{pattern}` | Search backward |
| `n` / `N` | Next / previous match (centered) |
| `*` / `#` | Search word under cursor forward/back |
| `f{c}` / `F{c}` | Go to next/previous char on the line |
| `t{c}` / `T{c}` | Same but BEFORE the char (till) |
| `;` / `,` | Repeat last f/t/F/T |
| `s` (flash) | Jump anywhere on screen (2 chars) |
| `S` (flash) | Jump via treesitter nodes |

### Editing (insert / change / delete)
| Key | Action |
|-----|--------|
| `i` / `I` | Insert at position / start of line |
| `a` / `A` | Append after / end of line |
| `o` / `O` | New line below / above (with auto indent) |
| `r{c}` | Replace 1 char |
| `R` | Replace mode |
| `c{motion}` | Change (delete + insert) |
| `cc` / `C` | Change line / to end |
| `d{motion}` | Delete |
| `dd` / `D` | Delete line / to end |
| `x` / `X` | Delete char forward/backward |
| `y{motion}` | Yank (copy) |
| `yy` / `Y` | Yank line |
| `p` / `P` | Paste after / before |
| `.` | **Repeat last command** (dot-repeat) |
| `u` / `Ctrl+r` | Undo / Redo |
| `>{motion}` / `<{motion}` | Indent / dedent |
| `=` / `==` | Auto-format (motion / line) |
| **`gcc`** | **Toggle comment on line** (nvim 0.10+ built-in) |
| **`gc{motion}`** | **Toggle comment with motion** (e.g. `gcap` for paragraph) |

### Text objects (usage: `d` `c` `y` + text object)
| Key | Object |
|-----|--------|
| `iw` / `aw` | Word (inner / around) |
| `is` / `as` | Sentence |
| `ip` / `ap` | Paragraph |
| `i(` `i)` `ib` | Inside parentheses |
| `i{` `i}` `iB` | Inside braces |
| `i[` `i]` | Inside [] |
| `i<` `i>` | Inside <> |
| `i"` `i'` `` i` `` | Inside quotes |
| `it` / `at` | Inside / around XML/HTML tag |
| `if` / `af` | Function (via mini.ai + treesitter) |
| `ic` / `ac` | Class |

### Visual mode
| Key | Action |
|-----|--------|
| `v` | Character-wise visual |
| `V` | Line-wise visual |
| `Ctrl+v` | Block visual (rectangular) |
| `gv` | Re-select last visual |
| `o` (in visual) | Swap selection endpoint |

### Registers & marks
| Key | Action |
|-----|--------|
| `"{a-z}y` | Yank into register a-z |
| `"{a-z}p` | Paste from register |
| `"+y` / `"+p` | System clipboard (WSL bridged) |
| `"_d` | Delete into "void" register (does not overwrite yank) |
| `:reg` | List all registers |
| `m{a-z}` | Set mark |
| `` `a `` | Go to mark a |
| `''` | Go to previous position |

### Windows / buffers / tabs
| Key | Action |
|-----|--------|
| `:split` / `<C-w>s` | Horizontal split |
| `:vsplit` / `<C-w>v` | Vertical split |
| `Ctrl+w h/j/k/l` | Move between windows (or Ctrl+h/j/k/l via tmux-navigator) |
| `Ctrl+w =` | Equalize windows |
| `Ctrl+w q` / `:q` | Close window |
| `:bn` / `:bp` | Next/prev buffer |
| `:tabnew` / `gt` / `gT` | Tab operations |

---

## 🎯 CUSTOM KEYMAPS (your own + from plugins)

### Leader = `<Space>`

### General
| Key | Action |
|-----|--------|
| `<Esc>` | Clear search highlights |
| `<leader>a` | Select all (`ggVG`) |
| `<leader>?` | **Open this cheatsheet** |
| `<leader><leader>` | Buffer picker (Telescope) |
| `gK` | Man page for word under cursor |
| `J` (normal) | Join lines (cursor stays put) |
| `<M-j>` / `<M-k>` | Move line down / up (mini.move) |
| `<M-h>` / `<M-l>` | Move line left / right |
| `p` (visual) | Paste without overwriting yank register |
| `<` / `>` (visual) | Indent / dedent + keep selection |
| `n` / `N` | Next / previous search (centered) |

### `<leader>s` — [S]earch (Telescope + Grug-far)
| Key | Action |
|-----|--------|
| `<leader>sf` | Search Files |
| `<leader>sg` | Live Grep |
| `<leader>sw` | Grep word under cursor |
| `<leader>sh` | Help tags |
| `<leader>sk` | **Search Keymaps (all active)** |
| `<leader>sn` | Search Neovim config |
| `<leader>ss` | Telescope pickers |
| `<leader>sd` | Diagnostics |
| `<leader>sr` | **Search & Replace (global · GrugFar)** |
| `<leader>sR` | Search Resume (last picker) |
| `<leader>s.` | Recent files |
| `<leader>sc` | Commands |
| `<leader>st` | Search TODOs |
| `<leader>sy` | Search Yank history |

### `<leader>u` — [U]I / Toggle
| Key | Action |
|-----|--------|
| `<leader>uu` | Toggle UndoTree |
| `<leader>uf` | Toggle Auto-format on save (buffer) |
| `<leader>uF` | Toggle Auto-format (global) |
| `<leader>uh` | Toggle LSP Inlay Hints |
| `<leader>uc` | Toggle CSV View |
| `<leader>ui` | Toggle Indent guides |
| `<leader>us` | Toggle Spelling |
| `<leader>uw` | Toggle Wrap |
| `<leader>ul` | Toggle Line numbers |
| `<leader>ud` | Toggle Diagnostics |
| `<leader>uT` | Toggle Treesitter |
| `<leader>un` | Show notification history |

### `<leader>b` — [B]uffer
| Key | Action |
|-----|--------|
| `Shift+H` / `Shift+L` | Prev / Next buffer |
| `[b` / `]b` | Prev / Next buffer |
| `<leader>bd` | Delete buffer (keep window) |
| `<leader>bD` | Force delete buffer |
| `<leader>bp` | Pin buffer |
| `<leader>bc` | Pick buffer to close |
| `<leader>bo` | Close other buffers |
| `<leader>br` | Close buffers to right |
| `<leader>bl` | Close buffers to left |

### `<leader>t` — [T]est (Neotest + Coverage)
| Key | Action |
|-----|--------|
| `<leader>tr` | Run nearest test |
| `<leader>tf` | Run tests in file |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Test output panel |
| `<leader>tv` | Toggle coverage |
| `<leader>tl` | Load coverage |

### `<leader>T` — [T]erminal (toggleterm)
| Key | Action |
|-----|--------|
| `<C-\>` | Toggle float terminal (primary) |
| `<leader>Tf` | Float terminal |
| `<leader>Th` | Horizontal terminal |
| `<leader>Tv` | Vertical terminal |

### `<leader>g` — [G]it
| Key | Action |
|-----|--------|
| `<leader>gs` | Neogit status |
| `<leader>gd` | Diffview workspace |
| `<leader>gc` | Diffview close |
| `<leader>gg` | **LazyGit float** (via snacks) |
| `<leader>gl` | LazyGit log (cwd) |

### `<leader>h` — Git [H]unks (gitsigns)
| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / prev hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hu` | Undo stage |

### `<leader>d` — [D]ebug (nvim-dap)
| Key | Action |
|-----|--------|
| `<F5>` / `<leader>dc` | Continue / Start |
| `<F10>` | Step Over |
| `<F11>` | Step Into |
| `<F12>` | Step Out |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>du` | Toggle DAP UI |
| `<leader>dr` | REPL |
| `<leader>dl` | Run last |
| `<leader>dt` | Terminate |

### `<leader>c` — [C]ode / Refactor
| Key | Action |
|-----|--------|
| `<leader>ca` | LSP code action |
| `<leader>cd` | Generate docstring (neogen) |
| `<leader>cr` | Refactoring menu |
| `<leader>cj` | Split / join code block |
| `<leader>cs` | Symbols (Trouble) |
| `<leader>co` | (Java) Organize imports |
| `<leader>cv` | (Java) Extract variable |
| `<leader>cM` | (Java) Extract method |

### `<leader>r` — [R]un Code
| Key | Action |
|-----|--------|
| `<leader>rr` | Run current code |
| `<leader>rc` | Close runner |

### `<leader>x` — Diagnostics / Trouble
| Key | Action |
|-----|--------|
| `<leader>xx` | Trouble project diagnostics |
| `<leader>xX` | Trouble buffer diagnostics |
| `<leader>xq` | Diagnostic quickfix |
| `<leader>xw` | Copy buffer warnings -> clipboard |
| `<leader>xW` | Copy project warnings -> clipboard |
| `]x` / `[x` | Next / prev diagnostic |
| `<leader>e` | Show diagnostic float |

### `<leader>q` — Session ([Q]uit)
| Key | Action |
|-----|--------|
| `<leader>qs` | Restore session |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Don't save current session |

### `<leader>f` — [F]ormat / [F]ind Colorscheme
| Key | Action |
|-----|--------|
| `<leader>f` | **Format buffer** (LSP + conform) |
| `<leader>fc` | **Pick colorscheme (top-30 dark)** |
| `<leader>fC` | Pick colorscheme (ALL with preview) |

### `<leader>D` — [D]atabase (Dadbod)
| Key | Action |
|-----|--------|
| `<leader>Du` | DB UI toggle |
| `<leader>Df` | DB find buffer |
| `<leader>Da` | DB add connection |

### `<leader>R` — REST (Kulala) *(only in .http files)*
| Key | Action |
|-----|--------|
| `<leader>R` | Run HTTP request |
| `<leader>Rt` | Toggle headers/body |

### Harpoon
| Key | Action |
|-----|--------|
| `<leader>ha` | Add file to harpoon |
| `<leader>hl` | Harpoon menu |
| `<leader>ht` | Harpoon via Telescope |
| `<leader>1` — `<leader>4` | Jump to harpoon slot 1–4 |

### Pro workflows (snacks)
| Key | Action |
|-----|--------|
| `<leader>z` | **Zen mode** |
| `<leader>Z` | Zoom current split |
| `<leader>.` | **Scratch buffer toggle** |
| `<leader>S` | Select scratch buffer |

### Yank ring (yanky)
| Key | Action |
|-----|--------|
| `y` / `p` / `P` | Yanky wrapped |
| `Ctrl+n` / `Ctrl+p` | **Cycle through yank history** (after paste) |
| `<leader>sy` | Search yank history |

### LSP (in-buffer keymaps)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | LSP references |
| `gI` | Go to implementation |
| `gy` | Type definition |
| `grD` | Go to declaration |
| `grn` | LSP rename |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>uh` | Toggle inlay hints |

### Surround (mini.surround — 'S' prefix)
| Key | Action |
|-----|--------|
| `Sa{motion}{char}` | **A**dd surround (e.g. `Saiw)` -> surround word with `()`) |
| `Sd{char}` | **D**elete surround |
| `Sr{old}{new}` | **R**eplace surround |
| `Sf{char}` / `SF{char}` | **F**ind surround right / left |
| `Sh` | **H**ighlight surround |

### File explorers
| Key | Action |
|-----|--------|
| `\` | Toggle Neo-tree |
| `-` | **Oil (parent dir, buffer-mode edit)** |

### Miscellaneous
| Key | Action |
|-----|--------|
| `<leader>gK` | Man page for word |
| `<C-h/j/k/l>` | Window navigation (tmux-navigator) |
| `q` (in help/qf/trouble) | Close buffer |
| `<Esc><Esc>` (in terminal) | Exit terminal mode |

---

## 🎨 Theme picker
- **`<leader>fc`** → **Top-30 dark themes** (curated pro list with 5 families: Tokyo Night, Kanagawa, Nightfox, Nord blends, modern 2024 picks + classics)
- **`<leader>fC`** → All installed with Telescope preview
- The selected theme is persisted to `lua/core/saved_theme.lua`

## 🔍 How to find a keybind I don't remember

1. **`<leader>?`** — this cheatsheet (covers everything)
2. **`<leader>sk`** — Telescope fuzzy search over all **active** keymaps (type what you want — e.g. "end" for end-of-line)
3. **Press `<leader>` and wait** — which-key popup shows all available prefixes
4. **`:help {topic}`** — e.g. `:help $` for vim built-ins
5. **`:help index`** — full vim keybind index

## 📝 Snippets (LuaSnip + friendly-snippets)
In insert mode, type a trigger (e.g. `func`, `if`, `for`) and press `<Tab>`. ~500 ready-to-use snippets are installed for: JS/TS/Python/HTML/CSS/React/Vue/etc.
