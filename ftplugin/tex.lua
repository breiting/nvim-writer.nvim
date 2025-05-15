vim.opt_local.wrap = true         -- Enable soft wrap
vim.opt_local.linebreak = true    -- Make sure that words are not wrapped
vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = "100" -- Visual indication of break

vim.opt_local.spell = true
vim.opt_local.spelllang = { "de" }

-- Currently not enabled, because I find it disturbing
-- vim.opt_local.breakindent = true  -- Indent if lines got wraped
-- vim.opt_local.showbreak = "↪ " -- Zeichen für Zeilenumbruch-Anzeige

-- Makes sure to navigate with j/k in wrap mode
vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })
