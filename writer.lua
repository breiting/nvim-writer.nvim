-- writer.lua

-- No plugins, no LSP (minimal mode)
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

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
vim.opt.clipboard = "unnamedplus" -- Sync clipboard between OS and neovim

-- Nice writing experience
vim.opt.linebreak = true
vim.opt.wrap = true
vim.opt.spell = true
vim.opt.spelllang = { "de", "en" }
vim.opt.textwidth = 0 -- no automatic line wrapping

-- Optical reduction
vim.opt.list = true
vim.opt.listchars:append({ eol = "↵" })
vim.opt.fillchars:append({ eob = " " })

-- Default color scheme
vim.cmd("colorscheme default")

-- Only word count in statusline
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
	pattern = "*",
	callback = function()
		vim.o.colorcolumn = ""
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

vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
]])
