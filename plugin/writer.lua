-- Autoload setup
vim.api.nvim_create_user_command("WriterFix", function()
	require("writer.llm").fix_selection()
end, { range = true })

vim.api.nvim_create_user_command("WriterFocus", function()
	require("writer.ui").enable_focus_mode()
end, {})

-- Optional: Visual Mode Mapping
vim.keymap.set("v", "<leader>wf", function()
	require("writer.llm").fix_selection()
end, { desc = "LLM: improve text", noremap = true, silent = true })
