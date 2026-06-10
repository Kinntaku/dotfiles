-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo(
			{ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } },
			true,
			{}
		)
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
if vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
	vim.cmd("cd " .. vim.fn.argv(0))
end
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)

-- Setup lazy.nvim

local lsp_servers_install = {
	"lua-language-server", -- Lua
	"clangd", -- c/cpp
	"pyright", -- python
	"vtsls", -- js/ts
	"html-lsp", -- html/xml/urd
	"css-lsp", -- css
	"texlab", -- tex
	"bash-language-server", -- shell
	"taplo", -- toml
	"yaml-language-server", -- yaml
	"json-lsp", -- json
	"tinymist",
}

local formatters = {
	"stylua", -- lua
	"clang-format", -- c/cpp
	"black", -- python
	"prettier", -- html/css/js/json/yaml
	"shfmt", -- shell
	"xmlformatter", -- xml/urdf
	"typstyle",
}

local servers = {
	{ name = "lua_ls", cmd = { "lua-language-server" }, filetypes = { "lua" } },
	{ name = "clangd", cmd = { "clangd" }, filetypes = { "c", "cpp" } },
	{ name = "pyright", cmd = { "pyright-langserver", "--stdio" }, filetypes = { "python" } },
	{ name = "rust_analyzer", cmd = { "rust-analyzer" }, filetypes = { "rust" } },
	{ name = "vtsls", cmd = { "vtsls", "--stdio" }, filetypes = { "javascript", "typescript" } },
	{ name = "html", cmd = { "vscode-html-language-server", "--stdio" }, filetypes = { "html" } },
	{ name = "cssls", cmd = { "vscode-css-language-server", "--stdio" }, filetypes = { "css" } },
	{ name = "texlab", cmd = { "texlab" }, filetypes = { "tex" } },
	{ name = "bashls", cmd = { "bash-language-server", "start" }, filetypes = { "sh" } },
	{ name = "taplo", cmd = { "taplo", "lsp", "stdio" }, filetypes = { "toml" } },
	{ name = "yamlls", cmd = { "yaml-language-server", "--stdio" }, filetypes = { "yaml" } },
	{ name = "jsonls", cmd = { "vscode-json-language-server", "--stdio" }, filetypes = { "json" } },
	{ name = "tinymist", cmd = { "tinymist" }, filetypes = { "typst" } },
}

require("lazy").setup({
	spec = {
		{
			-- cursor jump
			"folke/flash.nvim",
			event = "VeryLazy",
			opts = {},
			keys = {
				{
					"`",
					mode = { "n", "x", "o" },
					function()
						require("flash").jump()
					end,
					desc = "Flash",
				},
			},
		},
		{
			-- rainbow indent line
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			config = function()
				local highlight = {
					"RainbowRed",
					"RainbowYellow",
					"RainbowBlue",
					"RainbowOrange",
					"RainbowGreen",
					"RainbowViolet",
					"RainbowCyan",
				}

				local hooks = require("ibl.hooks")
				hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
					vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
					vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
					vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
					vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
					vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
					vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
					vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
				end)

				require("ibl").setup({ indent = { highlight = highlight } })
			end,
		},
		{
			"echasnovski/mini.comment",
			lazy = false,
			opts = {},
		},
		{
			-- theme
			"sainnhe/everforest",
			lazy = false,
			priority = 1000,
			config = function()
				vim.g.everforest_background = "hard"
				vim.g.everforest_enable_italic = true
				vim.cmd.colorscheme("everforest")
			end,
		},
		{
			-- auto recover sessions
			"rmagatti/auto-session",
			lazy = false,
			opts = {
				suppressed_dirs = { "~/", "~/Documents", "~/Downloads", "/" },
			},
		},
		{
			-- satus bar
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = {},
		},
		{
			-- file tree
			"nvim-tree/nvim-tree.lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			lazy = false,
			opts = {
				filters = { dotfiles = false },
				git = { ignore = false },
				actions = { change_dir = { enable = false } },
				renderer = { root_folder_label = false },
			},
			keys = {
				{ "<C-b>", "<cmd>NvimTreeToggle<CR>" },
			},
		},
		{
			-- buffer tab
			"akinsho/bufferline.nvim",
			event = "VeryLazy",
			dependencies = "nvim-tree/nvim-web-devicons",
			opts = {
				options = {
					indicator = { style = "underline" },
					close_command = "Sbd %d",
				},
			},
		},
		{
			-- git sign beside number line
			"lewis6991/gitsigns.nvim",
			opts = {
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")
					vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { buffer = bufnr })
					vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { buffer = bufnr })
					vim.keymap.set("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end, { buffer = bufnr, desc = "Jump to next git hunk" })

					vim.keymap.set("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end, { buffer = bufnr, desc = "Jump to previous git hunk" })
				end,
			},
		},
		{
			-- search
			"nvim-telescope/telescope.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			},
			keys = {
				{
					"<A-f>",
					function()
						require("telescope.builtin").find_files({ no_ignore = true, hidden = true })
					end,
				},
				{
					"<A-S-f>",
					function()
						require("telescope.builtin").live_grep({ additional_args = { "--no-ignore", "--hidden" } })
					end,
				},
			},
		},
		{
			-- buffer cant be cover
			"stevearc/stickybuf.nvim",
			opts = {},
		},
		{
			-- terminale
			"akinsho/toggleterm.nvim",
			lazy = false,
			opts = {
				open_mapping = [[<C-`>]],
			},
			keys = {
				{ "<A-t>", "<Cmd>TermSelect<CR>" },
			},
			config = function(_, opts)
				require("toggleterm").setup(opts)({
					direction = "horizontal",
				})
			end,
		},
		{
			-- highlight
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			branch = "main",
			build = ":TSUpdate",
			config = function()
				require("nvim-treesitter.configs").setup({
					ensure_installed = {
						"c",
						"cpp",
						"python",
						"html",
						"css",
						"javascript",
						"markdown",
						"markdown_inline",
						"lua",
						"bash",
						"toml",
						"yaml",
						"json",
						"xml",
						"typst",
						-- "latex" -- 不能自动安装, 会报错, 需要手动编译安装
					},
					highlight = {
						enable = true,
					},
					indent = {
						enable = true,
					},
					sync_install = false,
					auto_install = false,
				})
			end,
		},
		{
			-- masson
			"williamboman/mason.nvim",
			opts = {},
		},
		{
			-- lsp/format install
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			dependencies = { "williamboman/mason.nvim" },
			opts = {
				ensure_installed = vim.list_extend(lsp_servers_install, formatters),
				auto_update = false,
				run_on_start = true,
			},
		},
		{
			-- formatter
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "black" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					javascript = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					toml = { "taplo" },
					sh = { "shfmt" },
					xml = { "xmlformatter" },
					urdf = { "xmlformatter" },
					typ = { "typstyle" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			},
		},
		{
			-- code completion
			"saghen/blink.cmp",
			version = "*",
			opts = {
				keymap = {
					["<C-CR>"] = { "accept", "fallback" },
				},
			},
		},
		{
			-- markdown render
			"MeanderingProgrammer/render-markdown.nvim",
			dependencies = { "nvim-mini/mini.nvim" },
			opts = {
				completions = { lsp = { enabled = true } },
				render_modes = { "n", "c", "i", "v", "V" },
				code = {
					enabled = true,
				},
			},
		},
		{
			-- auto pair
			"echasnovski/mini.pairs",
			opts = {},
		},
	},
})

-- settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.modeline = false
vim.o.modelines = 0
vim.env.PATH = "/home/kinntaku/.nvm/versions/node/v24.13.0/bin:" .. vim.env.PATH
vim.opt.clipboard = "unnamedplus"
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.linebreak = true
vim.opt.autoread = true
vim.opt.updatetime = 100

-- fold settings
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldcolumn = "1"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- disable notify
vim.notify = function(msg, log_level, _opts)
	if msg:find("require('lspconfig')") then
		return
	end
end

-- lsp设置
for _, server in ipairs(servers) do
	vim.lsp.config(server.name, {
		cmd = server.cmd,
		filetypes = server.filetypes,
		root_markers = { ".git", "go.mod", "package.json", "pyproject.toml" },
	})
	vim.lsp.enable(server.name)
end

-- functional keybindings

-- open diagnostic panel
vim.keymap.set("n", "<leader>e", function()
	vim.diagnostic.open_float()
end)

-- toggle markdown renden
vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown toggle<CR>")

-- toggle auto enetr
vim.keymap.set("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
end)

-- rebindings

-- window & tab
vim.keymap.set({ "n", "v", "i" }, "<A-h>", "<Cmd>wincmd h<CR>")
vim.keymap.set({ "n", "v", "i" }, "<A-j>", "<Cmd>wincmd j<CR>")
vim.keymap.set({ "n", "v", "i" }, "<A-k>", "<Cmd>wincmd k<CR>")
vim.keymap.set({ "n", "v", "i" }, "<A-l>", "<Cmd>wincmd l<CR>")
vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<A-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<A-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<A-l>", [[<C-\><C-n><C-w>l]])
vim.keymap.set("n", "<leader>nt", ":tab split<CR>")
vim.keymap.set("n", "<leader>ct", ":tabclose<CR>")
vim.keymap.set({ "n", "v", "i" }, "<A-Q>", "<Cmd>tabnext<CR>")
vim.keymap.set({ "n", "v", "i" }, "<A-E>", "<Cmd>tabprevious<CR>")
vim.keymap.set("t", "<A-E>", "<C-\\><C-n><Cmd>tabnext<CR>")
vim.keymap.set("t", "<A-Q>", "<C-\\><C-n><Cmd>tabprevious<CR>")
vim.keymap.set({ "n", "v", "i" }, "<M-g>", "<Cmd>vertical resize -5<CR>")
vim.keymap.set({ "n", "v", "i" }, "<M-b>", "<Cmd>vertical resize +5<CR>")
vim.keymap.set({ "n", "v", "i" }, "<M-G>", "<Cmd>resize +5<CR>")
vim.keymap.set({ "n", "v", "i" }, "<M-B>", "<Cmd>resize -5<CR>")
vim.keymap.set("t", "<M-g>", [[<C-\><C-n><Cmd>vertical resize -5<CR>a]])
vim.keymap.set("t", "<M-b>", [[<C-\><C-n><Cmd>vertical resize +5<CR>a]])
vim.keymap.set("t", "<M-G>", [[<C-\><C-n><Cmd>resize +5<CR>a]])
vim.keymap.set("t", "<M-B>", [[<C-\><C-n><Cmd>resize -5<CR>a]]) -- 关闭窗口
vim.keymap.set({ "n", "v", "i" }, "<A-C>", "<cmd>close<CR>")
vim.keymap.set("t", "<A-C>", [[<C-\><C-n><cmd>close<CR>]])
vim.keymap.set({ "n", "v", "i" }, "<A-v>", "<cmd>vs<CR>")
vim.keymap.set("t", "<A-v>", [[<C-\><C-n><Cmd>vs<CR>]])
vim.keymap.set({ "n", "v", "i" }, "<A-V>", ":split<CR>")
vim.keymap.set({ "n", "i", "v", "t" }, "<A-e>", "<cmd>BufferLineCycleNext<CR>", {})
vim.keymap.set({ "n", "i", "v", "t" }, "<A-q>", "<cmd>BufferLineCyclePrev<CR>", {})

-- move cursor
vim.keymap.set({ "n", "v" }, "j", "gj")
vim.keymap.set({ "n", "v" }, "k", "gk")
vim.keymap.set("i", "<Down>", "<C-o>gj")
vim.keymap.set("i", "<Up>", "<C-o>gk")
vim.keymap.set({ "n", "v" }, "<Down>", "gj")
vim.keymap.set({ "n", "v" }, "<Up>", "gk")

-- move view
vim.keymap.set({ "n", "v" }, "<A-w>", "<C-u>zz")
vim.keymap.set({ "n", "v" }, "<A-s>", "<C-d>zz")
vim.keymap.set({ "n", "v" }, "<A-a>", "10zh")
vim.keymap.set({ "n", "v" }, "<A-d>", "10zl")

-- delete without copy
vim.keymap.set({ "n", "v" }, "d", '"_d')
vim.keymap.set("n", "dd", '"_dd')
vim.keymap.set("n", "D", '"_D')

-- exit terminal
vim.keymap.set("t", "<S-Esc>", [[<C-\><C-n>]])

-- line head & end
vim.keymap.set({ "n", "v" }, "-", "g^")
vim.keymap.set({ "n", "v" }, "=", "g$")

-- change indent
vim.keymap.set("v", "<", "<gv", { remap = false })
vim.keymap.set("v", ">", ">gv", { remap = false })

-- clean noh
vim.keymap.set({ "n", "v", "i" }, "<C-f>", "<cmd>noh<CR>")

-- complex keybings

-- delete buffer
local function safe_delete_buffer(opts_or_bufnr)
	local bufnr = nil
	if type(opts_or_bufnr) == "table" then
		if opts_or_bufnr.args and opts_or_bufnr.args ~= "" then
			bufnr = tonumber(opts_or_bufnr.args)
		end
	elseif type(opts_or_bufnr) == "number" then
		bufnr = opts_or_bufnr
	end
	if not bufnr then
		bufnr = vim.api.nvim_get_current_buf()
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	if vim.bo[bufnr].filetype == "NvimTree" then
		vim.cmd("q")
		return
	end
	if bufnr == vim.api.nvim_get_current_buf() then
		vim.cmd("BufferLineCyclePrev")
	else
		local current_buf = vim.api.nvim_get_current_buf()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == bufnr then
				vim.api.nvim_win_set_buf(win, current_buf)
			end
		end
	end
	pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end

vim.api.nvim_create_user_command("Sbd", safe_delete_buffer, { nargs = "?", force = true })

vim.keymap.set({ "n", "v", "i", "t" }, "<A-c>", function()
	safe_delete_buffer()
end)

-- change buffer
for i = 1, 9 do
	vim.keymap.set({ "n", "v", "i", "t" }, "<M-" .. i .. ">", function()
		local buffers = vim.fn.getbufinfo({ buflisted = 1 })
		if buffers[i] then
			vim.api.nvim_set_current_buf(buffers[i].bufnr)
		end
	end)
end

-- open path in expoler
vim.keymap.set("n", "<leader>of", function()
	local path = nil
	if vim.bo.filetype == "NvimTree" then
		local ok, api = pcall(require, "nvim-tree.api")
		if ok then
			local node = api.tree.get_node_under_cursor()
			if node then
				path = node.type == "directory" and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
			end
		end
	end
	if not path then
		local bufnr = vim.api.nvim_get_current_buf()
		local bufname = vim.api.nvim_buf_get_name(bufnr)

		if bufname ~= "" then
			path = vim.fn.fnamemodify(bufname, ":p:h")
		else
			path = vim.fn.getcwd()
		end
	end
	local cmd = "thunar"
	vim.fn.jobstart({ cmd, path })
end)

-- custom panel

local function RUN_MY_COMMANDS()
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	require("telescope.pickers")
		.new({}, {
			prompt_title = "COMMAND",
			previewer = false,
			finder = require("telescope.finders").new_table({
				results = require("commands_list"),
				entry_maker = function(e)
					return { value = e, display = e[1], ordinal = e[1] }
				end,
			}),
			sorter = require("telescope.config").values.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					local cmd_or_func = selection.value[2]
					if type(cmd_or_func) == "function" then
						cmd_or_func()
					else
						vim.cmd(cmd_or_func)
					end
				end)
				return true
			end,
		})
		:find()
end

vim.keymap.set("n", "<leader>a", RUN_MY_COMMANDS)

-- opencode

-- get relative file path
local function get_relative_file_path()
	return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
end

-- get range of selected lines
local function get_line_range_str()
	local mode = vim.fn.mode()
	local start_line, end_line

	if mode == "v" or mode == "V" or mode == "\22" then
		start_line = vim.fn.line("'<")
		end_line = vim.fn.line("'>")
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
	else
		local pos = vim.api.nvim_win_get_cursor(0)
		start_line = pos[1]
		end_line = pos[1]
	end
	return string.format("L%d-L%d", start_line, end_line)
end

-- copy relative file
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	local content = "@" .. get_relative_file_path()
	vim.fn.setreg("+", content)
end, { noremap = true, silent = true })

-- copy lines
vim.keymap.set({ "n", "v" }, "<leader>cl", function()
	local content = "@" .. get_relative_file_path() .. ":" .. get_line_range_str()
	vim.fn.setreg("+", content)
end, { noremap = true, silent = true })

-- automatics

-- enter instert mode when wnter terminal
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	pattern = { "term://*", "opencode", "lazygit" },
	callback = function()
		vim.schedule(function()
			if vim.bo.buftype == "terminal" then
				vim.cmd("startinsert")
			end
		end)
	end,
})

-- forbid editing binary file
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	callback = function()
		local f = io.open(vim.api.nvim_buf_get_name(0), "rb")
		if f then
			local data = f:read(1024)
			f:close()
			if data and data:find("%z") then
				vim.bo.readonly = true
				vim.bo.modifiable = false
			end
		end
	end,
})

-- start sock listen
vim.api.nvim_create_autocmd("FileType", {
	pattern = "tex",
	callback = function()
		local sock_path = "/tmp/nvim.sock"
		local stat = vim.uv.fs_stat(sock_path)
		if not stat then
			pcall(vim.fn.serverstart, sock_path)
		end
	end,
})

-- auto save
vim.api.nvim_create_autocmd({ "BufWritePre", "InsertLeave", "TextChanged" }, {
	pattern = "*",
	callback = function()
		if vim.bo.modified and vim.fn.empty(vim.fn.expand("%:t")) ~= 1 and vim.bo.buftype == "" then
			vim.cmd("write")
		end
	end,
})

-- auto recover sessions
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local buf_name = vim.api.nvim_buf_get_name(0)
		local is_empty_buf = (buf_name == "") and (vim.bo.filetype == "")
		if is_empty_buf and #vim.fn.argv() == 0 then
			vim.defer_fn(function()
				pcall(function()
					require("telescope").extensions["session-lens"].search_session()
				end)
			end, 50)
		end
	end,
})

-- ime change

local config = {
	default_im = "keyboard-us",
	poll_interval = 100,
}

vim.g.my_saved_im_state = config.default_im

local function get_current_im()
	local handle = io.popen("fcitx5-remote -n 2>/dev/null")
	if not handle then
		return config.default_im
	end
	local result = handle:read("*a")
	handle:close()
	return vim.trim(result or config.default_im)
end

local function set_im(mode)
	if mode == "en" then
		os.execute("fcitx5-remote -c 2>/dev/null")
	elseif mode == "zh" then
		os.execute("fcitx5-remote -o 2>/dev/null")
	end
end

local im_timer = vim.loop.new_timer()
local is_focused = true

local function violent_enforce_english()
	if not is_focused then
		return
	end

	local mode = vim.api.nvim_get_mode().mode

	if mode ~= "i" and mode ~= "t" and mode ~= "c" then
		if get_current_im() ~= config.default_im then
			set_im("en")
		end
	end
end

im_timer:start(0, config.poll_interval, vim.schedule_wrap(violent_enforce_english))

local im_group = vim.api.nvim_create_augroup("MyIMSelectGroup", { clear = true })

vim.api.nvim_create_autocmd("FocusGained", {
	group = im_group,
	callback = function()
		is_focused = true
		local mode = vim.api.nvim_get_mode().mode
		if mode ~= "i" and mode ~= "t" and mode ~= "c" then
			set_im("en")
		end
	end,
})

vim.api.nvim_create_autocmd("FocusLost", {
	group = im_group,
	callback = function()
		is_focused = false
	end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave", "TermLeave" }, {
	group = im_group,
	callback = function()
		if is_focused then
			vim.g.my_saved_im_state = get_current_im()
			vim.defer_fn(function()
				set_im("en")
			end, 10)
		end
	end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter", "TermEnter" }, {
	group = im_group,
	callback = function()
		if is_focused and vim.g.my_saved_im_state ~= config.default_im then
			set_im("zh")
		end
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = im_group,
	callback = function()
		if im_timer then
			im_timer:stop()
			im_timer:close()
		end
	end,
})
