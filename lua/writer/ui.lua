local M = {}

function M.enable_focus_mode()
	vim.cmd("setlocal wrap")
	vim.cmd("setlocal linebreak")
	vim.cmd("setlocal breakindent")
	vim.cmd("setlocal showbreak=↪\\ ")
	vim.cmd("setlocal colorcolumn=100")

	-- Fensterbreite auf 100 Zeichen zentrieren
	vim.cmd("vertical resize 100")
end

return M
