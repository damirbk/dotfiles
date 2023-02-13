-- General
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- vim.cmd([[
-- let g:clipboard = {
-- 	\	'name': 'myClipboard',
-- 	\	'copy': {
-- 	\		'+': ['tmux', 'load-buffer', '-'],
-- 	\		'*': ['tmux', 'load-buffer', '-'],
-- 	\	},
-- 	\	'paste': {
-- 	\		'+': ['tmux', 'save-buffer', '-'],
-- 	\		'*': ['tmux', 'save-buffer', '-'],
-- 	\	},
-- 	\	'cache_enabled': 1,
-- 	\}
-- ]])
vim.opt.clipboard = 'unnamedplus'
-- vim.opt.tabstop = 4
-- vim.opt.softtabstop = 4
-- vim.opt.shiftwidth = 4
-- vim.opt.expandtab = true
-- vim.opt.autoindent = true
-- vim.opt.copyindent = true

-- python venv path
vim.cmd("let g:python3_host_prog = $HOME . '/Envs/venv-nvim/bin/python'")

-- vim-plug
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = function() pcall(vim.cmd, 'TSUpdate') end })
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.1' })
Plug('averms/black-nvim', { ['do'] = function() pcall(vim.cmd, 'UpdateRemotePlugins') end })
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tjdevries/colorbuddy.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'
Plug 'ishan9299/nvim-solarized-lua'

vim.call('plug#end')

-- lsp-config keymappings
-- See: https://github.com/neovim/nvim-lspconfig/tree/54eb2a070a4f389b1be0f98070f81d23e2b1a715#suggested-configuration
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap=true, silent=true, buffer=bufnr }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wl', function()
	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- nvim-treesitter
require'nvim-treesitter.configs'.setup {
	ensure_installed = { "c", "lua", "vim", "help", "python", "dockerfile", "dot", "markdown", "yaml", "comment" },
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true
	}
}

-- mason
require("mason").setup()

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
	automatic_installation = true,
	ensure_installed = {
		-- "groovyls",
		"pyright",
		"ruff_lsp",
		"sumneko_lua",
		"yamlls",
	}
})
mason_lspconfig.setup_handlers({
	function (server_name)
		require("lspconfig")[server_name].setup({
			on_attach = on_attach,
		})
	end
})

-- lspconfig
local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config
lsp_defaults.capabilities = vim.tbl_deep_extend(
	'force',
	lsp_defaults.capabilities,
	require('cmp_nvim_lsp').default_capabilities()
)

-- Configure `ruff-lsp`.
local configs = require 'lspconfig.configs'
if not configs.ruff_lsp then
	configs.ruff_lsp = {
		default_config = {
			cmd = { 'ruff-lsp' },
			filetypes = { 'python' },
			root_dir = require('lspconfig').util.find_git_ancestor,
			init_options = {
				settings = {
					  args = { line_length = 99 }
				}
			}
		}
	}
end

lspconfig.sumneko_lua.setup {
	settings = {
		Lua = {
			diagnostics = {
				globals = { 'vim' }
			}
		}
	}
}

-- autocompletion
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

local cmp = require'cmp'

cmp.setup({
	snippet = {
		expand = function(args)
		vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	window = {

	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' },
	}, {
		{ name = 'buffer' }
	})
})

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

local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig['sumneko_lua'].setup {
	capabilities = capabilities
}
lspconfig['pyright'].setup {
	capabilities = capabilities
}

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- black
vim.cmd([[
nnoremap <buffer><silent> <c-q> <cmd>call Black()<cr>
inoremap <buffer><silent> <c-q> <cmd>call Black()<cr>
let g:black#settings = {
    \ 'fast': 1,
    \ 'line_length': 100
\}
]])
-- nvim-tree
vim.opt.termguicolors = true
require("nvim-tree").setup()

-- nvim-solarized
vim.cmd('set background=light')
vim.cmd('colorscheme solarized')

-- lualine
require("lualine").setup {
	options = { theme = 'solarized_light' }
}

