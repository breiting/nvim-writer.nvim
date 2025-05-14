local M = {}

local review_buf = nil
local gpt_buf = nil
local win_id = nil

function M.close_review()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		vim.api.nvim_win_close(win_id, true)
	end
	win_id = nil
	review_buf = nil
	gpt_buf = nil
end

function M.open_review_window(original_text, gpt_text)
	-- Höhe/Breite relativ zur UI
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.6)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Neues schwebendes Fenster
	review_buf = vim.api.nvim_create_buf(false, true)
	gpt_buf = vim.api.nvim_create_buf(false, true)

	win_id = vim.api.nvim_open_win(review_buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})

	-- Setze Layout mit zwei vertikalen Splits
	vim.api.nvim_buf_set_lines(review_buf, 0, -1, false, vim.split(original_text, "\n"))
	vim.api.nvim_buf_set_option(review_buf, "modifiable", false)
	vim.api.nvim_buf_set_option(review_buf, "filetype", "text")

	vim.cmd("split")
	local gpt_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(gpt_win, gpt_buf)
	vim.api.nvim_buf_set_lines(gpt_buf, 0, -1, false, vim.split(gpt_text or "⏳ GPT wird geladen...", "\n"))
	vim.api.nvim_buf_set_option(gpt_buf, "filetype", "text")

	-- Mappe "y" im GPT-Bereich: yank + schließen
	vim.keymap.set("n", "y", function()
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		vim.fn.setreg('"', table.concat(lines, "\n"))
		vim.notify("📋 Neuer Text wurde in die Zwischenablage kopiert.")
		M.close_review()
	end, { buffer = gpt_buf, noremap = true, silent = true })
end

return M
