-- Plugins
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'folke/tokyonight.nvim'
    use 'tpope/vim-commentary'
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
    use 'saadparwaiz1/cmp_luasnip'
    use 'L3MON4D3/LuaSnip'
    use 'nvim-lua/plenary.nvim'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use 'nvim-telescope/telescope.nvim'
    use {
      "ahmedkhalf/project.nvim",
      config = function()
        require("project_nvim").setup {}
      end
    }
    use 'tpope/vim-fugitive'
    use 'williamboman/mason.nvim'
    use 'jose-elias-alvarez/null-ls.nvim'
    use 'jay-babu/mason-null-ls.nvim'
end)

require 'nvim-treesitter.configs'.setup {
    ensure_installed = "all",
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
    },
}


local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require('lspconfig')
local luasnip = require 'luasnip'
local cmp = require 'cmp'

local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' } -- 'lua-ls' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        capabilities = capabilities,
    }
end


cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
        ['<C-d>'] = cmp.mapping.scroll_docs(4),  -- Down
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})


vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})

local telescopeb = require('telescope.builtin')
require('telescope').setup{
    defaults = {
        layout_strategy = 'horizontal',
        layout_config = {
            height = 0.95, 
            width = 0.95,
            preview_width = 0.6
        },
    },
}

require("mason").setup()
require("mason-null-ls").setup({
    ensure_installed = {
        "prettierd"
    },
    automatic_installation = false,
    handlers = {},
})
require("null-ls").setup({
    sources = {
        -- Anything not supported by mason.
    }
})

-- Defaults
vim.o.signcolumn = 'no'
vim.o.laststatus = false
vim.g.mapleader = " "
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_bufsettings = "noma nomod nu nobl nowrap ro"

-- Colorscheme
vim.cmd("colorscheme tokyonight-moon")
vim.cmd("hi NormalNC ctermbg=NONE guibg=NONE")
vim.cmd("hi Normal ctermbg=NONE guibg=NONE")
vim.cmd("autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>")

-- Keymaps
vim.keymap.set("n", "<C-e>", function() vim.cmd("Ex") end)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '<C-s>', telescopeb.git_status, {})
vim.keymap.set('n', '<C-p>', telescopeb.git_files, {})
vim.keymap.set('n', '<C-v>', telescopeb.oldfiles, {})
vim.keymap.set('n', '<C-f>', telescopeb.live_grep, {})
vim.keymap.set('n', '<C-h>', telescopeb.help_tags, {})
vim.keymap.set('n', '<leader>w', vim.cmd.w, {})

