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
          theme = 'powerline', -- Change lualine theme here
          section_separators = {'', ''},
          component_separators = {'|', '|'},
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch'},
          lualine_c = {{'filename', path = 1}}, -- Use fullpath here
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

  -- Add spectre (For global search and replace)
  use 'nvim-pack/nvim-spectre'

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
      }
    end
  }
  -- Add nvim-lspconfig for LSP support
    use {
      'neovim/nvim-lspconfig',
      config = function()
        local capabilities = require('cmp_nvim_lsp').default_capabilities() -- Get capabilities from cmp-nvim-lsp

        local on_attach = function(client, bufnr)
            -- Add common keymaps, like gd (go to definition), K (hover), etc.
             local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
             local opts = { noremap=true, silent=true }
                buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
                buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
                buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
                buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
                buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
                buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        end
	
	-- C/C++
        require('lspconfig').clangd.setup {
          capabilities = capabilities,
          on_attach = on_attach
        }

        -- Python
        require('lspconfig').pyright.setup {
          capabilities = capabilities,
          on_attach = on_attach
        }

        -- Add more language servers here
      end
    }

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
        mapping = cmp.mapping.preset.insert({ -- Use a preset for common mappings
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-n>'] = cmp.mapping.complete(), -- Changed to C-n.  More reliable.
          ['<C-e>'] = cmp.mapping.abort(),   -- Use abort() directly
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)  -- Example of a more complex mapping
              if cmp.visible() then
                  cmp.select_next_item()
              elseif require('luasnip').expand_or_jumpable() then
                  vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
              else
                  fallback()
              end
          end, { 'i', 's' }), -- i = insert mode, s = select mode
          ['<S-Tab>'] = cmp.mapping(function(fallback) -- Shift-tab example
              if cmp.visible() then
                  cmp.select_prev_item()
              elseif require('luasnip').jumpable(-1) then
                  vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
              else
                  fallback()
              end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },  -- Add buffer completions here
          { name = 'path' }, -- add path completions
        }
      })
    end
  }

  -- Add an autocommand to compile packer whenever the init.lua file is saved
    vim.cmd([[
      augroup packer_user_config
        autocmd!
        autocmd BufWritePost init.lua lua if pcall(vim.cmd, 'source ' .. vim.fn.expand('<afile>')) then require('packer').sync() end
	autocmd BufNewFile,BufRead Jenkinsfile setf groovy
      augroup end
    ]])
end)


-- Set key mappings for :Spectre
vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").open()<CR>', {
  desc = "Open Spectre"
})
vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word"
})
vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current selection"
})
vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({path = "%:p"})<CR>', {
    desc = "Search in current file"
})

-- Set key mappings for :Gitsigns
vim.keymap.set("n", "<leader>gp", "<cmd>lua require('gitsigns').preview_hunk_inline()<CR>")
vim.keymap.set("n", "<leader>gt", "<cmd>lua require('gitsigns').toggle_current_line_blame()<CR>")

-- Set key mappings for :Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", {})

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
-- vim.opt.statusline = '%F' -- For normal VIM

-- Set the background to be transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NonText", { bg = "none" })

-- Set whitespace
vim.opt.list = true
vim.opt.listchars = {
  eol = '↵',	-- Symbol for newline
  tab = '→ ',	-- Symbol for tab
  space = '·',	-- Symbol for a regular space
  trail = '•',	-- Symbol for trailing spaces
}
vim.api.nvim_set_hl(0, "Whitespace", { fg = "#777777" })

-- Set cursor color
vim.api.nvim_set_hl(0, "Cursor", { fg = "#B3FF00", bg = "#ff00aa" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#49115b" })
