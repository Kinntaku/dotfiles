-- 关闭 modeline
vim.opt.modeline = false
vim.o.modelines = 0

-- 没准用neovide
if vim.g.neovide then
	vim.o.guifont = "JetBrainsMono Nerd Font,JetBrains Mono:h14"
end

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

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.notify = function(msg, log_level, _opts)
	if msg:find("require('lspconfig')") then
		return
	end
end
-- Setup lazy.nvim

local lsp_servers_install = {
	"lua-language-server", -- Lua
	"clangd",            -- c/cpp
	"pyright",           -- python
	"vtsls",             -- js/ts
	"html-lsp",          -- html/xml/urdf
	"css-lsp",           -- css
	"texlab",            -- tex
	"bash-language-server", -- shell
	"taplo",             -- toml
	"yaml-language-server", -- yaml
	"json-lsp",          -- json
}

local lsp_servers = {
	"lua_ls",
	"clangd",
	"pyright",
	"vtsls",
	"html",
	"cssls",
	"texlab",
	"bashls",
	"taplo",
	"yamlls",
	"jsonls",
}

local formatters = {
	"stylua",    -- lua
	"clang-format", -- c/cpp
	"black",     -- python
	"prettier",  -- html/css/js/json/yaml
	"shfmt",     -- shell
	"xmlformatter", -- xml/urdf
}

require("lazy").setup({
	spec = {
		{
			-- flash 跳转
			"folke/flash.nvim",
			event = "VeryLazy",
			opts = {},
			keys = {
				{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			},
		},
		{
			-- 括号连线
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
			-- 快速注释
			"numToStr/Comment.nvim",
			opts = {},
			lazy = false,
		},
		{
			-- 主题
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
			-- 会话恢复
			"rmagatti/auto-session",
			lazy = false,
			opts = {
				suppressed_dirs = { "~/", "~/Documents", "~/Downloads", "/" },
			},
		},
		{
			-- 状态栏
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = {},
		},
		{
			-- 光标移动
			"sphamba/smear-cursor.nvim",
			cond = not vim.g.neovide,

			opts = {
				smear_between_buffers = true,
				smear_between_neighbor_lines = true,
				scroll_buffer_space = true,
				legacy_computing_symbols_support = false,
				smear_insert_mode = true,
			},
		},
		{
			-- 文件树
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
			-- 标签栏
			"akinsho/bufferline.nvim",
			event = "VeryLazy",
			dependencies = "nvim-tree/nvim-web-devicons",
			opts = {
				options = {
					indicator = { style = "underline" },
					close_command = "Sbd %d"
				},
			},
			keys = {
				{ "L", "<cmd>BufferLineCycleNext<CR>" },
				{ "H", "<cmd>BufferLineCyclePrev<CR>" },
			},
		},
		{
			-- git 标志
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
			-- 搜索
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
			-- 防止某些buffer被替换掉
			"stevearc/stickybuf.nvim",
			opts = {},
		},
		{
			-- 终端
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
			-- 输入法切换
			"keaising/im-select.nvim",
			opts = {
				default_im_select = "keyboard-us",
			},
		},
		{
			-- 语法高亮
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
			-- lsp/format 安装
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			dependencies = { "williamboman/mason.nvim" },
			opts = {
				ensure_installed = vim.list_extend(lsp_servers_install, formatters),
				auto_update = false,
				run_on_start = true,
			},
		},
		{
			-- 格式化
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
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			},
		},
		{
			-- lsp
			"neovim/nvim-lspconfig",
			dependencies = {
				"williamboman/mason.nvim",
				"williamboman/mason-lspconfig.nvim",
				"hrsh7th/cmp-nvim-lsp",
			},
			config = function()
				require("mason").setup()

				local lspconfig = require("lspconfig")

				for _, server in ipairs(lsp_servers) do
					if server ~= "clangd" then
						lspconfig[server].setup({})
					end
				end

				require('lspconfig').clangd.setup({
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--query-driver=/usr/bin/arm-none-eabi-*"
					},
				})
			end,
		},
		{
			-- 代码提示
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"L3MON4D3/LuaSnip",
				"saadparwaiz1/cmp_luasnip",
			},
			config = function()
				local cmp = require("cmp")
				local luasnip = require("luasnip")
				luasnip.setup({
					history = true,
					updateevents = "TextChanged,TextChangedI",
				})
				cmp.setup({
					ghost_text = true,
					snippet = {
						expand = function(args)
							require("luasnip").lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						["<C-CR>"] = cmp.mapping.confirm({ select = true }),
						['<C-l>'] = cmp.mapping(function(fallback)
							if luasnip.expand_or_jumpable() then
								luasnip.expand_or_jump()
							else
								fallback()
							end
						end, { 'i', 's' }),

						['<C-h>'] = cmp.mapping(function(fallback)
							if luasnip.jumpable(-1) then
								luasnip.jump(-1)
							else
								fallback()
							end
						end, { 'i', 's' }),
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
					}, {
						{ name = "buffer" },
						{ name = "path" },
					}),
					performance = {
						max_view_entries = 10,
					},
				})
			end,
		},
		{
			-- 自动括号
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = function()
				require("nvim-autopairs").setup({
					check_ts = true,
					ts_config = {
						lua = { "string" },
						javascript = { "template_string" },
						java = false,
					},
				})
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				local cmp = require("cmp")
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end,
		},
		{
			-- markdown 渲染
			"MeanderingProgrammer/render-markdown.nvim",
			dependencies = { "nvim-mini/mini.nvim" },
			opts = {
				completions = { lsp = { enabled = true } },
				render_modes = { "n", "c", "i", "v", "V" },
				code = {
					enabled = true, -- 开启代码块渲染
				},
			},
		},
	},
})

-- 配置
vim.opt.clipboard = "unnamedplus" -- 剪贴板
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.number = true             -- 显示当前行的真实行号
vim.opt.relativenumber = true     -- 开启相对行号
vim.opt.tabstop = 4               -- tab 相关
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.splitright = true -- 垂直分屏在右侧
vim.opt.splitbelow = true -- 水平分屏在下方

-- 按键
vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown toggle<CR>")

-- 调整缩进
vim.keymap.set("v", "<", "<gv", { remap = false })
vim.keymap.set("v", ">", ">gv", { remap = false })

-- 清除缓冲区
vim.keymap.set({ "n", "v", "i" }, "<C-f>", "<cmd>noh<CR>")

-- 切换自动换行
vim.keymap.set("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
end)

-- 插行不编辑
-- vim.keymap.set('n', 'o', 'o<Esc>', { remap = false })
-- vim.keymap.set('n', 'O', 'O<Esc>', { remap = false })

-- 行首行尾
vim.keymap.set({ "n", "v" }, "-", "g^")
vim.keymap.set({ "n", "v" }, "=", "g$")

-- buffer 位置切换
vim.keymap.set({ "n", "v", "i" }, "<A-h>", "<Cmd>wincmd h<CR>")
vim.keymap.set({ "n", "v", "i" }, "<A-j>", "<Cmd>wincmd j<CR>")
vim.keymap.set({ "n", "v", "i" }, "<A-k>", "<Cmd>wincmd k<CR>")
vim.keymap.set({ "n", "v", "i" }, "<A-l>", "<Cmd>wincmd l<CR>")
vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<A-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<A-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<A-l>", [[<C-\><C-n><C-w>l]])

-- 关闭窗口
vim.keymap.set({ "n", "v", "i" }, "<A-Q>", "<cmd>close<CR>")
vim.keymap.set("t", "<A-Q>", [[<C-\><C-n><cmd>close<CR>]])

-- 分屏
vim.keymap.set({ "n", "v", "i" }, "<A-v>", "<cmd>vs<CR>")
vim.keymap.set("t", "<A-v>", [[<C-\><C-n><Cmd>vs<CR>]])

-- 删除 buffer
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
	if not vim.api.nvim_buf_is_valid(bufnr) then return end
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

vim.keymap.set({ "n", "v", "i", "t" }, "<A-q>", function()
	safe_delete_buffer()
end)

-- 数字切换buffer
for i = 1, 9 do
	vim.keymap.set({ "n", "v", "i", "t" }, '<M-' .. i .. '>', function()
		local buffers = vim.fn.getbufinfo({ buflisted = 1 })
		if buffers[i] then
			vim.api.nvim_set_current_buf(buffers[i].bufnr)
		end
	end)
end

-- 上下改为对于视觉行
vim.keymap.set({ "n", "v" }, "j", "gj")
vim.keymap.set({ "n", "v" }, "k", "gk")
vim.keymap.set("i", "<Down>", "<C-o>gj")
vim.keymap.set("i", "<Up>", "<C-o>gk")
vim.keymap.set({ "n", "v" }, "<Down>", "gj")
vim.keymap.set({ "n", "v" }, "<Up>", "gk")

-- 移动位置
vim.keymap.set({ "n", "v" }, "<A-w>", "<C-u>zz")
vim.keymap.set({ "n", "v" }, "<A-s>", "<C-d>zz")
vim.keymap.set({ "n", "v" }, "<A-a>", "10zh")
vim.keymap.set({ "n", "v" }, "<A-d>", "10zl")

-- 删除不进剪贴板
vim.keymap.set({ "n", "v" }, "<A-e>", '"_d')
vim.keymap.set({ "n", "v" }, "dd", '"_dd')
vim.keymap.set({ "n", "v" }, "D", '"_D')

-- 退出终端
vim.keymap.set("t", "<S-Esc>", [[<C-\><C-n>]])

-- 错误检查
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

-- 打开文件路径
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

-- 自定义 Telescope 面板

-- 运行函数
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

-- opencode 相关

-- 获取相对路径
local function get_relative_file_path()
	return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
end

-- 获取行范围
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

-- 复制相对路径
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	local content = "@" .. get_relative_file_path()
	vim.fn.setreg("+", content)
end, { noremap = true, silent = true })

-- 复制行范围
vim.keymap.set({ "n", "v" }, "<leader>cl", function()
	local content = "@" .. get_relative_file_path() .. " " .. get_line_range_str()
	vim.fn.setreg("+", content)
end, { noremap = true, silent = true })

-- 自动化

-- 终端自动进入插入模式
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

-- 自动开启折叠
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		if vim.bo.buftype == "" then
			vim.schedule(function()
				vim.o.foldmethod = "expr"
				vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.o.foldlevel = 99
			end)
		end
	end,
})

-- 禁止编辑二进制
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

-- 启动监听
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

-- 自动保存
vim.api.nvim_create_autocmd({ "BufWritePre", "InsertLeave", "TextChanged" }, {
	pattern = "*",
	callback = function()
		-- 文件有修改, 有实体路径, 是文件缓冲区
		if vim.bo.modified and vim.fn.empty(vim.fn.expand("%:t")) ~= 1 and vim.bo.buftype == "" then
			vim.cmd("write")
		end
	end,
})

-- sessions
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
