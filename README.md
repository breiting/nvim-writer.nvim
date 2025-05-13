# `nvim-writer.nvim`

This is a neovim plugin for people who wants to use neovim for writing their books.

## Usage

tbd

## Installation

Please use your favorite plugin manager, I am using `lazy.vim` with the following configuration.
All `config` parameters are optional, and are initialized with defaults.

```
return {
  {
    "breiting/nvim-writer.nvim",
    config = function()
      local writer = require("nvim-writer")
      writer.config.target_path = "~/Documents/images/"
      writer.config.pattern = "%Y-%m-%d_%H-%M-%S"
    end,
  },
}
```
