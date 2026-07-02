### Layer 1: The Core (Vim Native Grammar & Overrides)
These are the foundations. If you don't learn them, the editor will fight you.

| Key / Combo | Action | Mode |
| :--- | :--- | :--- |
| `i` / `a` | Insert before cursor / Append after cursor | Normal |
| `I` / `A` | Insert at first char of line / Append at end | Normal |
| `o` / `O` | Open a new line below / above | Normal |
| `w` / `b` / `e` | Next word / Previous word / End of word | Normal |
| `0` / `^` / `$` | Start of line / First non-blank / End of line | Normal |
| `c` + `[motion]` | Change (delete and auto-enter Insert) | Normal |
| `d` + `[motion]` | Delete (cut) | Normal |
| `y` / `p` / `P` | Yank (copy) / Paste after / Paste before | Normal |
| **`p`** (Custom) | **Void Paste** (paste without clobbering the clipboard) | **Visual** |
| **`J` / `K`** (Custom) | **Block Move** (move selected block down/up) | **Visual** |
| **`>` / `<`** (Custom) | **Continuous Shift** (indent/dedent, keeps selection) | **Visual** |
| `<C-u>` / `<C-d>` | Scroll Up/Down **(centered)** | Normal |
| `n` / `N` | Next/Previous Search **(centered)** | Normal |
| `<Esc>` | Cancel search (clear highlights) | Normal |

---

### Layer 2: Workspace & I/O (System Navigation)
How you move around the project in $O(1)$ time.

| Key / Combo | Action | System (Plugin) |
| :--- | :--- | :--- |
| `<leader>sf` | Search Files | Telescope |
| `<leader>sg` | Live Grep (code search) | Telescope |
| `<leader>sw` | Search word under cursor | Telescope |
| `<leader>s.` | Recent files | Telescope |
| `<leader>sn` | Search inside Neovim config files | Telescope |
| `<leader>ha` | Add current file to **Harpoon** | Harpoon |
| `<leader>hl` / `<leader>ht` | Open Harpoon list / Show via Telescope | Harpoon |
| `<leader>1` to `<leader>4` | Instant jump to Harpoon slot 1, 2, 3, 4 | Harpoon |
| `\` | Open/close side Explorer | Neo-tree |
| `-` | Edit the current directory as text | Oil |
| `s` / `S` | Instant jump / Scope selection on screen | Flash |
| `<C-h/j/k/l>` | Navigate between Vim splits & Tmux panes | Tmux Navigator |
| `<leader>qs` / `<leader>ql` | Save/Restore Session (project state) | Persistence |

---

### Layer 3: Intelligence & AST (The IDE brain)
Here you talk to the Language Servers (LSP) and the parser (Treesitter).

| Key / Combo | Action | System |
| :--- | :--- | :--- |
| `gd` / `gr` | Go to Definition / References | LSP + Telescope |
| `gI` / `gy` | Go to Implementation / Type | LSP + Telescope |
| `K` | Hover documentation (Javadoc/Docstring) | LSP |
| `grn` | **Rename** symbol across the entire scope | LSP |
| `<leader>ca` | **Code Actions** (suggestions, imports, quick fixes) | LSP |
| `<leader>xx` | Open panel with **all project errors** | Trouble |
| `<leader>cs` | Open file outline (tree of vars/functions) | Trouble |
| `[x` / `]x` | Jump to previous / next error | Trouble |
| `<leader>e` | Show error message in floating window | LSP |
| `<C-Space>` | Incremental scope selection (word -> arg -> function) | Treesitter |

---

### Layer 4: Editing & Refactoring (The Surgeon)
Bulk modification and code generation tools.

| Key / Combo | Action | System |
| :--- | :--- | :--- |
| `<leader>cr` | **Refactoring menu** (Extract Method/Var, Inline) | Refactoring |
| `<leader>f` | Format file | Conform |
| `<leader>tf` | Toggle Format-on-Save | Conform |
| `<leader>cj` | Split/Join table or params | TreeSJ |
| `<leader>cd` | Auto-generate Docstring/Javadoc for function | Neogen |
| `<leader>sr` | **Global Search & Replace** across the project | Grug-far |
| `<leader>st` | Find all `TODO:` and `FIXME:` in the code | Todo-Comments |

---

### Layer 5: Enterprise Modules (C++, Java, Web, Data)
Standalone subsystems that replace external programs.

#### A. Version Control (Git)
| Key / Combo | Action | System |
| :--- | :--- | :--- |
| `]h` / `[h` | Next / previous code hunk | Gitsigns |
| `<leader>hp` | Preview hunk | Gitsigns |
| `<leader>hr` / `<leader>hs` | Reset / Stage the current hunk | Gitsigns |
| `<leader>gs` | Open full Git UI (Commit/Push/Pull) | Neogit |
| `<leader>gd` / `<leader>gc` | Show Git Diff (whole project) / Close Diff | Diffview |

#### B. Debugging (DAP) & Testing
| Key / Combo | Action | System |
| :--- | :--- | :--- |
| `<F5>` | Start / Continue Debugger | DAP |
| `<F10>` / `<F11>` / `<F12>`| Step Over / Step Into / Step Out | DAP |
| `<leader>b` / `<leader>B` | Set breakpoint / Conditional breakpoint | DAP |
| `<leader>du` | Toggle Debugger UI | DAP UI |
| `<leader>tr` / `<leader>tf` | Run nearest test / Run all tests in file | Neotest |
| `<leader>to` | Open test results panel | Neotest |
| `<leader>tv` | Toggle green/red test coverage gutter lines | Coverage |

#### C. Build & Data Analytics (CMake, HTTP, SQL)
| Key / Combo | Action | System |
| :--- | :--- | :--- |
| `<leader>cmg` / `<leader>cmb`| Generate / Build project | CMake Tools |
| `<leader>R` | Run HTTP request (in `.http` files) | Kulala |
| `<leader>db` | Open Database side menu (SQL/Postgres) | Dadbod UI |
| `<leader>tc` | Toggle CSV file view as a spreadsheet | CSVView |

---
