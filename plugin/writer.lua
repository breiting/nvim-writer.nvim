vim.keymap.set("n", "<leader>ww", function()
	require("writer").toggle_writer_mode()
end, { desc = "Toggle writer mode" })

vim.keymap.set("v", "<leader>ll", function()
	-- Yank current selection into register "
	vim.cmd('normal! "vy')
	vim.schedule(function()
		require("writer").correct_visual_selection()
	end)
end, { desc = "GPT correction", silent = true })
