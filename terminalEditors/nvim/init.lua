-- -----------------------------------------------------------------------------
-- 1. LEADER KEY
-- -----------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- -----------------------------------------------------------------------------
-- 2. CORE NEOCIM OPTIONS
-- -----------------------------------------------------------------------------
local opt = vim.opt -- for conciseness

-- General
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.termguicolors = true

-- Numbers
opt.number = true
opt.relativenumber = true
opt.cursorline = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Appearance
opt.wrap = true
opt.breakindent = true
opt.scrolloff = 8 -- Keep cursor away from top/bottom edge

-- Transparent Background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" }) -- For floating windows
vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2d2a2e" }) -- Subtle cursor line highlight

-- Whitespace Characters
opt.list = true
opt.listchars = {
  eol = '↵',
  tab = '→ ',
  space = '·',
  trail = '•',
}

-- -----------------------------------------------------------------------------
-- 3. GLOBAL KEYMAPS
-- -----------------------------------------------------------------------------
local keymap = vim.keymap
local keymap_opts = { noremap = true, silent = true }

-- File Explorer
keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', keymap_opts)

-- Telescope Fuzzy Finder
keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = "Find Files" })
keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = "Live Grep" })
keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = "Find Buffers" })
keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = "Help Tags" })

-- Gitsigns
keymap.set('n', '<leader>gp', '<cmd>Gitsigns preview_hunk_inline<CR>', { desc = "Preview Hunk" })
keymap.set('n', '<leader>gt', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = "Toggle Blame" })

-- Spectre Search and Replace
keymap.set('n', '<leader>S', '<cmd>Spectre<CR>', { desc = "Open Spectre" })
keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = "Search Word" })
keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Search Selection" })
keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({path = "%:p"})<CR>', { desc = "Search in File" })

-- -----------------------------------------------------------------------------
-- 4. PLUGIN MANAGER (LAZY.NVIM)
-- -----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  ---------------------
  -- Core & UI
  ---------------------
  { 'nvim-lua/plenary.nvim' }, -- A dependency for many plugins

  {
    'folke/tokyonight.nvim',
    lazy = false, -- Load this colorscheme on startup
    priority = 1000, -- Make sure it's loaded before other plugins
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy', -- Load on a delayed event after startup
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'tokyonight',
        section_separators = { '', '' },
        component_separators = { '|', '|' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { { 'filename', path = 1, shorting_rule = 'absolute' } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },

  {
    'nvim-tree/nvim-tree.lua',
    cmd = 'NvimTreeToggle', -- Load only when you run the command
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      view = { side = 'right', width = 30 },
      update_cwd = true,
      hijack_netrw = true,
    },
  },

  ---------------------
  -- Fuzzy Finding
  ---------------------
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  ---------------------
  -- Git Integration
  ---------------------
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  ---------------------
  -- Search & Replace
  ---------------------
  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  ---------------------
  -- LSP & Completion
  ---------------------
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      -- THIS IS WHERE THE LSP.LUA CONTENT GOES --
      local lspconfig = require('lspconfig')
      local mason = require('mason')
      local mason_lspconfig = require('mason-lspconfig')

      local on_attach = function(client, bufnr)
        local map = vim.keymap.set
        local opts = { noremap = true, silent = true, buffer = bufnr }

        map('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts)
        map('n', 'K', vim.lsp.buf.hover, opts)
        map('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts)
        map('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
        map('n', '<leader>D', '<cmd>Telescope lsp_type_definitions<CR>', opts)
        map('n', '<leader>rn', vim.lsp.buf.rename, opts)
        map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        map('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
      end

      mason.setup()

      mason_lspconfig.setup({
        ensure_installed = {
          'clangd',
          'pyright',
          'lua_ls',
        },
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,
      })
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'zbirenbaum/copilot-cmp',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'copilot' },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  ---------------------
  -- GitHub Copilot
  ---------------------
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<C-l>", -- Ctrl+L to accept suggestion
            dismiss = "<C-h>",
          },
        },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function ()
      require("copilot_cmp").setup()
    end
  },
})

-- -----------------------------------------------------------------------------
-- 5. SET THE COLOR SCHEME
-- -----------------------------------------------------------------------------
vim.cmd.colorscheme('tokyonight')