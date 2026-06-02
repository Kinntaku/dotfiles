-- 编译函数
local function LATEX_COMPILE()
	local file_dir = vim.fn.expand("%:p:h")
	local file_name = vim.fn.expand("%:t")
	print("Compiling")
	local prepare_cmd =
		string.format("podman exec -w '%s' texlive-container sh -c 'mkdir -p tmp && chmod 777 tmp'", file_dir)
	vim.fn.system(prepare_cmd)
	local cmd = {
		"podman",
		"exec",
		"-w",
		file_dir,
		"texlive-container",
		"latexmk",
		"-xelatex",
		"-synctex=1",
		"-file-line-error",
		"-interaction=nonstopmode",
		"-outdir=tmp",
		file_name,
	}
	vim.fn.jobstart(cmd, {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				print("Success")
			else
				print("Fail")
			end
		end,
	})
end

-- 预览函数
local function LATEX_VIEW()
	local file_path = vim.fn.expand("%:p")
	local file_dir = vim.fn.expand("%:p:h")
	local job_name = vim.fn.expand("%:t:r")
	local pdf_path = file_dir .. "/tmp/" .. job_name .. ".pdf"

	if vim.fn.filereadable(pdf_path) == 0 then
		print("PDF not found")
		return
	end

	local line = vim.fn.line(".")
	local col = vim.fn.col(".")

	vim.fn.jobstart({
		"zathura",
		"--synctex-forward",
		string.format("%d:%d:%s", line, col, file_path),
		pdf_path,
	}, { detach = true })
end

-- 执行指令
function TERMINAL_CMD(cmd)
	if not cmd or cmd == "" then
		return
	end
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
		if name == cmd then
			vim.api.nvim_set_current_buf(buf)
			vim.schedule(function()
				vim.cmd("startinsert")
			end)
			return
		end
	end
	vim.cmd("terminal " .. cmd)
	local current_buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_name(current_buf, cmd)
	vim.schedule(function()
		vim.cmd("startinsert")
	end)
end

-- 单文件提交
function FILE_COMMIT()
	local file = vim.fn.expand("%:.")
	if file == "" then
		return
	end
	local msg = vim.fn.input("commit: ")
	if msg == "" then
		print("\nNo commit message")
		return
	end
	vim.fn.system(string.format("git add %q", file))
	vim.fn.system(string.format("git commit %q -m %q", file, file .. "=" .. msg))
	print("\nSublmit" .. file)
end

-- 使用chromium打开
local function CHROMIUM_OPEN()
	local file_path = vim.fn.expand("%:p")
	if file_path == "" then
		return
	end

	vim.fn.jobstart({ "chromium", file_path }, { detach = true })
end

return {
	{ "latex compile", LATEX_COMPILE },
	{ "latex view",    LATEX_VIEW },
	{
		"lazygit",
		function()
			TERMINAL_CMD("lazygit")
		end,
	},
	{ "git resume",       "Telescope git_bcommits" },
	{ "refresh sessions", "SessionSave" },
	{ "git submit",       FILE_COMMIT },
	{
		"opencode",
		function()
			TERMINAL_CMD("opencode")
		end,
	},
	{ "chromium open", CHROMIUM_OPEN },
	{
		"open sessions",
		function()
			pcall(function()
				require("telescope").extensions["session-lens"].search_session()
			end)
		end,
	},
}
