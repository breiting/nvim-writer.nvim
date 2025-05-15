local M = {}

function M.enable_writer_mode()
	vim.wo.wrap = true
	vim.wo.linebreak = true
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.signcolumn = "no"
	vim.wo.colorcolumn = ""
	vim.cmd("setlocal spell spelllang=de")
	vim.cmd("ZenMode")
end

function M.disable_writer_mode()
	vim.cmd("ZenMode")
	vim.wo.wrap = false
	vim.wo.linebreak = false
	vim.wo.number = true
	vim.wo.relativenumber = true
	vim.wo.signcolumn = "yes"
	vim.wo.colorcolumn = "100"
	vim.cmd("setlocal nospell")
end

function M.toggle_writer_mode()
	M._enabled = not M._enabled
	if M._enabled then
		M.enable_writer_mode()
		vim.notify("✍️ Writer Modeactivated", vim.log.levels.INFO)
	else
		M.disable_writer_mode()
		vim.notify("💤 Writer Mode deactivated", vim.log.levels.INFO)
	end
end

return M
