-- writer.lua

-- Minimaler Start: keine Standard-Plugins, kein LSP
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Keine Zeilennummern, keine Zeichenränder
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.statusline = ""
vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.cmdheight = 1
vim.opt.ruler = false
vim.opt.cursorline = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.colorcolumn = ""
vim.opt.foldcolumn = "0"

-- Schönes Schreiben
vim.opt.linebreak = true
vim.opt.wrap = true
vim.opt.spell = true
vim.opt.spelllang = { "de", "en" } -- Passe ggf. an
vim.opt.textwidth = 0              -- kein automatischer Wrap

-- Optische Reduktion
vim.opt.list = true
vim.opt.listchars:append({ eol = "↵" })
vim.opt.fillchars:append({ eob = " " })

-- Optisch angenehmes Theme
vim.cmd("colorscheme default") -- Oder solarized/gruvbox etc., wenn du möchtest

-- Wörterzähler für Statusline
local function update_statusline()
	local wc = vim.fn.wordcount()
	local count = wc["words"] or 0
	vim.opt.statusline = " Wörter: " .. count .. " "
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		update_statusline()
	end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter", "CursorHold" }, {
	callback = function()
		update_statusline()
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		-- remove all format options in order to prevent from auto-wrap and inserting CR
		vim.opt.formatoptions = vim.opt.formatoptions - "t" - "a" - "c" - "r" - "o"
		vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
		vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })
	end,
})
