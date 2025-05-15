vim.keymap.set("n", "<leader>ww", function()
	require("writer").toggle_writer_mode()
end, { desc = "Toggle writer mode" })

-- conservative
vim.keymap.set("v", "<leader>l1", function()
	vim.cmd('normal! "vy')
	vim.schedule(function()
		require("writer").correct_visual_selection(0.2)
	end)
end, { desc = "GPT correction L1", silent = true })

-- medium
vim.keymap.set("v", "<leader>l2", function()
	vim.cmd('normal! "vy')
	vim.schedule(function()
		require("writer").correct_visual_selection(0.4)
	end)
end, { desc = "GPT correction L2", silent = true })

-- creative
vim.keymap.set("v", "<leader>l3", function()
	vim.cmd('normal! "vy')
	vim.schedule(function()
		require("writer").correct_visual_selection(0.7)
	end)
end, { desc = "GPT correction L3", silent = true })
