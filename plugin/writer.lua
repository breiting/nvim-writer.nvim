-- Autoload setup

vim.api.nvim_create_user_command("WriterReview", function()
	require("writer.review").review_yanked_text()
end, {})

-- Mapping: <leader>ll
vim.keymap.set("n", "<leader>ll", function()
	require("writer.review").review_yanked_text()
end, { desc = "Writer: GPT-Überarbeitung von Text", noremap = true, silent = true })
