# `nvim-writer.nvim`

This is a neovim plugin for people who wants to use neovim for writing their books.

## Usage

With `<leader>-ww` you will enter the zen-mode with distraction free writing. With `<leader>-lx` the text which is currently
selected will be corrected by ChatGPT and the corrected text will be inserted below. The `x` can be:

- 1 for conservative
- 2 for medium
- 3 for creative

and affects the temperature value. E.g. `<leader>-l1` will correct the selected text conservative with temperature 0.2.

## Installation

Please use your favorite plugin manager, I am using `lazy.vim` with the following configuration.
All `config` parameters are optional, and are initialized with defaults.

```
return {
  {
    "breiting/nvim-writer.nvim",
    dependencies = {
      "folke/zen-mode.nvim",
      "nvim-lua/plenary.nvim",
    },
  },
}
```
