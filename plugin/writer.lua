vim.keymap.set("n", "<leader>ww", function()
	require("writer").toggle_writer_mode()
end, { desc = "Toggle Writer Mode" })

vim.keymap.set("n", "<leader>ll", function()
	require("writer.chatgpt").rewrite_selection_with_gpt()
end, { desc = "Korrektur durch ChatGPT" })
