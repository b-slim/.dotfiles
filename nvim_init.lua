-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key — space is easier to hit than backslash
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Increase timeout so multi-key sequences don't drop
vim.opt.timeoutlen = 500

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.conceallevel = 2

-- Plugins
require("lazy").setup({
  -- vim-markdown: folding, TOC, syntax for markdown
  {
    "preservim/vim-markdown",
    ft = "markdown",
    dependencies = { "godlygeek/tabular" },
    init = function()
      vim.g.vim_markdown_folding_level = 2
      vim.g.vim_markdown_toc_autofit = 1
      vim.g.vim_markdown_conceal = 2
      vim.g.vim_markdown_conceal_code_blocks = 0
      vim.g.vim_markdown_strikethrough = 1
      vim.g.vim_markdown_new_list_item_indent = 2
    end,
  },

  -- render-markdown: inline rendering of headings, tables, checkboxes, code blocks
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      heading = {
        enabled = true,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "☐ " },
        checked = { icon = "✔ " },
      },
      code = {
        enabled = true,
        sign = false,
        width = "block",
      },
    },
  },

  -- Outline sidebar — shows headings as a navigable tree
  {
    "hedyhli/outline.nvim",
    ft = "markdown",
    opts = {
      outline_window = { position = "right", width = 30 },
      symbols = { filter = { "String" } },
      preview_window = { auto_preview = true },
    },
    keys = {
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline sidebar" },
    },
  },

  -- treesitter for markdown parsing (required by render-markdown)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup({
          ensure_installed = { "markdown", "markdown_inline" },
          highlight = { enable = true },
        })
      end
    end,
  },
})

-- Keymaps for markdown navigation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local opts = { buffer = true, silent = true }
    -- Toggle TOC
    vim.keymap.set("n", "<leader>t", ":Toc<CR>", opts)
    -- Fold all sections
    vim.keymap.set("n", "<leader>fa", "zM", opts)
    -- Unfold all sections
    vim.keymap.set("n", "<leader>fo", "zR", opts)
    -- Toggle fold under cursor
    vim.keymap.set("n", "<leader>ff", "za", opts)
    -- Open one fold under cursor
    vim.keymap.set("n", "<leader>fu", "zo", opts)
    -- Open all nested folds under cursor
    vim.keymap.set("n", "<leader>fU", "zO", opts)
    -- Fold to level 1 (only top headings open)
    vim.keymap.set("n", "<leader>f1", ":set foldlevel=1<CR>", opts)
    -- Fold to level 2
    vim.keymap.set("n", "<leader>f2", ":set foldlevel=2<CR>", opts)
    -- Fold to level 3
    vim.keymap.set("n", "<leader>f3", ":set foldlevel=3<CR>", opts)
    -- Toggle TOC sidebar (outline.nvim)
    vim.keymap.set("n", "<leader>o", ":Outline<CR>", opts)
    -- Jump to next/previous header
    vim.keymap.set("n", "]]", [[/^##\+\s<CR>:noh<CR>]], opts)
    vim.keymap.set("n", "[[", [[?^##\+\s<CR>:noh<CR>]], opts)
    -- Open URL under cursor in browser
    vim.keymap.set("n", "gx", function()
      local url = vim.fn.expand("<cWORD>")
      url = url:match("https?://[%w_.~!*'();:@&=+$,/?#%%%-]+") or url:match("http?://[%w_.~!*'();:@&=+$,/?#%%%-]+")
      if url then
        local cmd = vim.fn.has("macunix") == 1 and "open" or "xdg-open"
        vim.fn.system({ cmd, url })
      end
    end, opts)
    -- Toggle render-markdown
    vim.keymap.set("n", "<leader>mr", ":RenderMarkdown toggle<CR>", opts)

    -- Statusline with shortcut hints for markdown
    vim.opt_local.statusline = table.concat({
      " %f%m",
      "%=",
      " ,t:Toc | ,o:Sidebar | ,ff:Toggle | ,fa:FoldAll | ,fo:OpenAll | ]]:Next | [[:Prev | gx:URL | ,mr:Render",
      " | %l:%c ",
    })
  end,
})
