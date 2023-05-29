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
    use "windwp/nvim-ts-autotag"
    use "ggandor/leap.nvim"
    use "tpope/vim-repeat"
    use "nvim-pack/nvim-spectre"
    use 'nvim-tree/nvim-web-devicons'
    use 'JoosepAlviste/nvim-ts-context-commentstring'
end)

require('leap').add_default_mappings()
require'nvim-web-devicons'.setup()
require 'nvim-treesitter.configs'.setup {
    ensure_installed = "all",
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
    },
    autotag = {
        enable = true
    },
    context_commentstring = {
        enable = true,
    },
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require('lspconfig')
local luasnip = require 'luasnip'
local cmp = require 'cmp'

local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
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
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
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

local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
})

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
vim.opt.signcolumn = 'no'
vim.o.ruler = false
vim.o.laststatus = 0
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
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gd', telescopeb.lsp_definitions, opts)
        vim.keymap.set('n', 'gr', telescopeb.lsp_references, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set({ 'n', 'v' }, 'L', function () vim.diagnostic.open_float(0, {scope="line"}) end, opts)
    end,
})

-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_bufsettings = "noma nomod nu nobl nowrap ro"

-- Colorscheme
vim.cmd("colorscheme tokyonight-night")
vim.cmd("hi NormalNC ctermbg=NONE guibg=NONE")
vim.cmd("hi Normal ctermbg=NONE guibg=NONE")
vim.cmd("autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>")

-- Tmux
vim.cmd('autocmd BufEnter * call system("tmux rename-window " . expand("%"))')
vim.cmd('autocmd VimLeave * call system("tmux rename-window zsh")')

-- Keymaps
vim.keymap.set("n", "<C-e>", function() vim.cmd("Ex") end)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set('n', '<C-s>', telescopeb.git_status, {})
vim.keymap.set('n', '<C-p>', telescopeb.git_files, {})
vim.keymap.set('n', '<C-k>', telescopeb.oldfiles, {})
vim.keymap.set('n', '<C-f>', telescopeb.live_grep, {})
vim.keymap.set('n', '<C-h>', telescopeb.help_tags, {})
vim.keymap.set('n', '<C-b>', 
function() 
    telescopeb.diagnostics {
        severity = "error"
    }
end
, {})
vim.keymap.set('n', '<leader>w', vim.cmd.w, {})
vim.keymap.set("n", "<leader>s", telescopeb.git_stash, {})
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").open()<CR>', {
    desc = "Open Spectre"
})

-- Filter diagnostics
local ignore = {
    ["Pyright"] = {
        '^".+" is unknown import symbol$',
    }
}

function filter(arr, func)
	local new_index = 1
	local size_orig = #arr
	for old_index, v in ipairs(arr) do
		if func(v, old_index) then
			arr[new_index] = v
			new_index = new_index + 1
		end
	end
	for i = new_index, size_orig do arr[i] = nil end
end

function filter_diagnostics(diagnostic)
    for source, messages in pairs(ignore) do
        if source == diagnostic.source then
            for i, message in ipairs(messages) do
                if string.match(diagnostic.message, message) then
                    return false     
                end
            end
        end
    end
	return true
end

function custom_on_publish_diagnostics(a, params, client_id, c, config)
	filter(params.diagnostics, filter_diagnostics)
	vim.lsp.diagnostic.on_publish_diagnostics(a, params, client_id, c, config)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	custom_on_publish_diagnostics, {
        update_in_insert = true,
        underline = false
    })

-- Snippets
-- You can check file type with 
-- print(vim.inspect(require("luasnip").get_snippet_filetypes()))`) 
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

local function copy(args)
	return args[1]
end

ls.add_snippets("all", {}, { key = "all" })

ls.add_snippets("python", {
	s("def", {
		t("def "),
		i(1, "name"),
		t("("),
		i(2, "args"),
		t({ "):", "\t" }),
		i(3, "pass"),
	}),
}, {
    key = "python"
})

ls.add_snippets("typescriptreact", {
	s("rfc", {
		t("type "),
        f(copy, 1),
        t({"Props = {}","", "export function "}),
        i(1, "Component"),
        t("({}: "),
        f(copy, 1),
        t({"Props) {", "\t"}),
        i(2, "return"),
        t({ "", "}", ""}),
	}),
}, {
    key = "typescriptreact"
})

