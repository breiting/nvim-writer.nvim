vim.keymap.set("n", "<leader>ww", function()
	require("writer").toggle_writer_mode()
end, { desc = "Toggle writer mode" })

vim.keymap.set("v", "<leader>ll", function()
	-- Yank current selection into register "
	vim.cmd('normal! "vy')
	vim.schedule(function()
		local input = vim.fn.getreg('"')
		require("writer").correct_with_gpt(input, function(corrected)
			-- Jetzt kannst du hier selbst entscheiden, was passiert:
			vim.fn.setreg('"', corrected) -- ins Register
			vim.notify(corrected, vim.log.levels.INFO)
			-- oder z. B. in Buffer einfügen:
			vim.api.nvim_put(vim.split(corrected, "\n"), "l", true, true)
		end)
	end)
end, { desc = "GPT correction", silent = true })
