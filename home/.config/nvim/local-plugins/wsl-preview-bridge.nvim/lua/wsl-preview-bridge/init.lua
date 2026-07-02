--- @module 'wsl-preview-bridge'
--- @description Universal WSL-to-Windows media and preview bridge.
--- @author Angel
--- @license MIT

local M = {}

M.config = {
	browser_path = nil,
	focus_delay_ms = 500,
	sync_group = true,
}

local explorers = { NvimTree = true, ["neo-tree"] = true, oil = true, netrw = true }

local function is_wsl()
	local output = vim.fn.system("uname -r")
	return string.find(string.lower(output), "wsl") ~= nil
end

local function get_default_browser()
	local program_files = "/mnt/c/Program Files"
	local brave = program_files .. "/BraveSoftware/Brave-Browser/Application/brave.exe"
	if vim.fn.executable(brave) == 1 then
		return "brave.exe"
	end
	return program_files .. "/Microsoft/Edge/Application/msedge.exe"
end

local function get_cursor_path()
	local ft = vim.bo.filetype
	if ft == "NvimTree" then
		return require("nvim-tree.lib").get_node_at_cursor().absolute_path
	end
	if ft == "neo-tree" then
		local state = require("neo-tree.sources.manager").get_state("filesystem")
		return state.tree:get_node().path
	end
	if ft == "oil" then
		return require("oil").get_current_dir() .. require("oil").get_cursor_entry().name
	end
	if ft == "netrw" then
		return vim.b.netrw_curdir .. "/" .. vim.fn.expand("<cfile>")
	end
	return vim.fn.expand("<cfile>")
end

function M.toggle_media(target, mode)
	if not is_wsl() or not target or target == "" then
		return
	end

	local is_url = target:match("^http") or target:match("^www")
	local win_target = is_url and target
		or vim.fn.system("wslpath -w " .. vim.fn.shellescape(target)):gsub("[\n\r]", "")
	local browser = M.config.browser_path or get_default_browser()

	local ps_code = string.format(
		[[
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class Win32Bridge {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hAfter, int x, int y, int cx, int cy, uint f);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
}
'@

$term = [Win32Bridge]::GetForegroundWindow()
$existing = Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -match 'NvimMediaBridge'}

if ($existing) {
    $existing | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    [Win32Bridge]::ShowWindow($term, 3)
    exit
}

Add-Type -AssemblyName System.Windows.Forms
$area = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$half = [Math]::Floor($area.Width / 2)

[Win32Bridge]::ShowWindow($term, 9)
[Win32Bridge]::SetWindowPos($term, [IntPtr]::Zero, $area.X, $area.Y, $half, $area.Height, 0x0040)

$targetUrl = '%s'
$browserExe = '%s'
$syncGroup = $%s
$runMode = '%s'

$chromiumFlags = "--disable-background-timer-throttling --disable-renderer-backgrounding --disable-backgrounding-occluded-windows"
$args = "--app=`"$targetUrl`" --no-first-run --no-default-browser-check $chromiumFlags --window-position=$($area.X + $half),$($area.Y) --window-size=$half,$($area.Height) --user-data-dir=$env:TEMP\NvimMediaBridge"

Start-Process $browserExe -ArgumentList $args

Start-Sleep -Milliseconds %d
[Win32Bridge]::SetForegroundWindow($term)

$browserHwnd = [IntPtr]::Zero
$SWP_NOACTIVATE_NOMOVE_NOSIZE = 0x0013
$lastFg = [IntPtr]::Zero

while ($true) {
    $alive = Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -match 'NvimMediaBridge'}
    if (-not $alive) { break }

    if ($browserHwnd -eq [IntPtr]::Zero) {
        foreach ($p in $alive) {
            $tmp = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
            if ($tmp -and $tmp.MainWindowHandle -ne [IntPtr]::Zero) {
                if ([Win32Bridge]::IsWindowVisible($tmp.MainWindowHandle)) {
                    $browserHwnd = $tmp.MainWindowHandle
                    break
                }
            }
        }
    }

    $fg = [Win32Bridge]::GetForegroundWindow()
    
    if ($fg -ne $lastFg) {
        if ($syncGroup -and $browserHwnd -ne [IntPtr]::Zero) {
            if ($fg -eq $term) {
                # Neovim has focus. Just keep browser behind.
                [Win32Bridge]::SetWindowPos($browserHwnd, $term, 0, 0, 0, 0, $SWP_NOACTIVATE_NOMOVE_NOSIZE)
            } elseif ($fg -eq $browserHwnd) {
                # ATOMIC FIX: Browser hijacked focus. 
                # 1. Force Restore Terminal if minimized
                [Win32Bridge]::ShowWindow($term, 9)
                # 2. Re-grab focus to Terminal immediately
                [Win32Bridge]::SetForegroundWindow($term)
                # 3. Re-tile after focus is back to terminal
                Start-Sleep -Milliseconds 50
                [Win32Bridge]::SetWindowPos($browserHwnd, $term, 0, 0, 0, 0, $SWP_NOACTIVATE_NOMOVE_NOSIZE)
            }
        }
        $lastFg = $fg
    }
    Start-Sleep -Milliseconds 300
}

[Win32Bridge]::ShowWindow($term, 3)
]],
		win_target,
		browser,
		tostring(M.config.sync_group),
		mode,
		M.config.focus_delay_ms
	)

	local tmp_file = "/tmp/wsl_preview_bridge.ps1"
	local f = io.open(tmp_file, "w")
	if f then
		f:write(ps_code)
		f:close()
	end

	local win_ps_path = vim.fn.system("wslpath -w " .. tmp_file):gsub("[\n\r]", "")
	vim.fn.jobstart(
		{ "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", win_ps_path },
		{ detach = true }
	)
end

function M.smart_dispatch()
	local ft = vim.bo.filetype
	if ft == "markdown" then
		vim.cmd("MarkdownPreviewToggle")
		return
	end
	if explorers[ft] then
		local path = get_cursor_path()
		if not path or path == "" then
			return
		end
		if path:match("%.md$") then
			vim.cmd("edit " .. vim.fn.fnameescape(path))
			vim.cmd("MarkdownPreviewToggle")
		else
			M.toggle_media(path, "media")
		end
		return
	end
	local cfile = vim.fn.expand("<cfile>")
	if cfile and cfile ~= "" then
		M.toggle_media(cfile, "media")
	end
end

function M.gx_dispatch()
	local ft = vim.bo.filetype
	local path = explorers[ft] and get_cursor_path() or vim.fn.expand("<cfile>")
	if path and path ~= "" then
		M.toggle_media(path, "media")
	end
end

function M.remote_control(key)
	local keys = { down = "{PGDN}", up = "{PGUP}", next = "^{TAB}", prev = "^+{TAB}", close = "^{w}" }
	local ps_code = string.format(
		[[
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class RC {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
}
'@
$term = [RC]::GetForegroundWindow()
$wmi = Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -match 'NvimMediaBridge'}
$targetHwnd = [IntPtr]::Zero

if ($wmi) {
    foreach ($p in $wmi) {
        $proc = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
        if ($proc -and $proc.MainWindowHandle -ne [IntPtr]::Zero) {
            if ([RC]::IsWindowVisible($proc.MainWindowHandle)) {
                $targetHwnd = $proc.MainWindowHandle
                break
            }
        }
    }
}

if ($targetHwnd -ne [IntPtr]::Zero) {
    [RC]::SetForegroundWindow($targetHwnd)
    Start-Sleep -Milliseconds 50
    $ws = New-Object -ComObject WScript.Shell
    $ws.SendKeys('%s')
    Start-Sleep -Milliseconds 50
    [RC]::SetForegroundWindow($term)
}
]],
		keys[key]
	)
	vim.fn.jobstart({ "powershell.exe", "-NoProfile", "-Command", ps_code })
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	_G.WslPreviewBridgeMD = function(url)
		M.toggle_media(url, "markdown")
	end
	vim.cmd([[
    function! WslPreviewVimBridge(url)
      call v:lua.WslPreviewBridgeMD(a:url)
    endfunction
  ]])
	vim.g.mkdp_browserfunc = "WslPreviewVimBridge"

	local opts_map = { noremap = true, silent = true }

	vim.keymap.set("n", "<leader>mp", M.smart_dispatch, opts_map)
	vim.keymap.set("n", "gx", M.gx_dispatch, opts_map)

	vim.keymap.set("n", "<leader>md", function()
		M.remote_control("down")
	end, opts_map)
	vim.keymap.set("n", "<leader>mu", function()
		M.remote_control("up")
	end, opts_map)
	vim.keymap.set("n", "<leader>mn", function()
		M.remote_control("next")
	end, opts_map)
	vim.keymap.set("n", "<leader>mb", function()
		M.remote_control("prev")
	end, opts_map)
	vim.keymap.set("n", "<leader>mc", function()
		M.remote_control("close")
	end, opts_map)

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			local kill_cmd =
				"Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -match 'NvimMediaBridge'} | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"
			vim.fn.system({ "powershell.exe", "-NoProfile", "-Command", kill_cmd })
		end,
	})
end

return M
