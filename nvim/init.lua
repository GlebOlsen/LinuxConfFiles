-- Set the leader key to space
vim.g.mapleader = ' '

-- Initialize packer.nvim
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Add lualine.nvim
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'auto',
          section_separators = {'', ''},
          component_separators = {'|', '|'},
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        }
      }
    end
  }
  -- Add gitsigns.nvim
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup {}
    end
  }

  -- Add telescope.nvim
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = "which_key"
            }
          }
        }
      }
    end
  }

  -- Add nvim-spectre
  use {
    'windwp/nvim-spectre',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('spectre').setup()
    end
  }

  -- Add nvim-tree.lua
  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require'nvim-tree'.setup {
        view = {
          side = 'right',
          width = 30,
        },
        hijack_netrw = true,
        update_cwd = true,
        filters = {
          custom = {},  -- Empty custom filters to show all files and directories
          dotfiles = false,  -- Optionally show dotfiles
          git_ignored = false,  -- Show files and directories ignored by Git
        }
      }
    end
  }

  -- Add nvim-lspconfig for LSP support
--  use {
--    'neovim/nvim-lspconfig',
--    config = function()
--      require('lspconfig').volar.setup {} -- this is example for vue
--    end
--  }

  -- Add nvim-cmp for autocompletion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip'
    },
    config = function()
      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })
    end
  }

  -- Add an autocommand to compile packer whenever the init.lua file is saved
  vim.cmd([[
    augroup packer_user_config
      autocmd!
      autocmd BufWritePost init.lua source <afile> | PackerCompile
    augroup end
  ]])
end)

-- Set key mappings for :Gitsigns
vim.keymap.set("n", "<leader>gp", function() require('gitsigns').preview_hunk_inline() end, {})
vim.keymap.set("n", "<leader>gt", function() require('gitsigns').toggle_current_line_blame() end, {})

-- Set key mappings for :Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", {noremap = true, silent = true})

-- Set key mappings for :Spectre
vim.api.nvim_set_keymap('n', '<leader>sr', "<cmd>lua require('spectre').open()<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>sw', "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '<leader>sw', "<cmd>lua require('spectre').open_visual()<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>sp', "<cmd>lua require('spectre').open_file_search()<cr>", {noremap = true, silent = true})

-- Set key mappings for :NvimTree
vim.api.nvim_set_keymap('n', '<leader>e', ":NvimTreeToggle<CR>", {noremap = true, silent = true})

-- Other configuration settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.statusline = '%F'

vim.cmd [[highlight CursorLine guibg=#49115b]]

