-- 编译函数
local function VIM_LATEX_COMPILE()
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
local function VIM_LATEX_VIEW()
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

-- lazygit
function lazygit()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
		if name == "lazygit" then
			return
		end
	end
	vim.cmd("terminal lazygit")
	local current_buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_name(current_buf, "lazygit")
	vim.schedule(function()
		vim.cmd("startinsert")
	end)
end

-- 单文件提交
function file_git_commit()
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

-- opencode
function opencode()
	local target_buf_name = "opencode_terminal"
	local bufnr = nil
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(b):find(target_buf_name) then
			bufnr = b
			break
		end
	end
	if bufnr and vim.api.nvim_buf_is_loaded(bufnr) then
		local win = vim.fn.bufwinid(bufnr)
		if win ~= -1 then
			if #vim.api.nvim_list_wins() > 1 then
				vim.api.nvim_win_hide(win)
			else
				vim.cmd("quit")
			end
		else
			vim.cmd("botright vsplit")
			vim.api.nvim_win_set_buf(0, bufnr)
			pcall(function()
				require("stickybuf").pin()
			end)
			vim.schedule(function()
				vim.cmd("startinsert")
			end)
		end
	else
		vim.cmd("botright vsplit | terminal opencode")
		bufnr = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_name(bufnr, target_buf_name)
		vim.bo[bufnr].buflisted = false
		vim.bo[bufnr].bufhidden = "hide"
		vim.wo.winfixwidth = true
		pcall(function()
			require("stickybuf").pin()
		end)
		vim.schedule(function()
			vim.cmd("startinsert")
		end)
	end
end

return {
	{ "latex compile", VIM_LATEX_COMPILE },
	{ "latex view", VIM_LATEX_VIEW },
	{ "lazygit", lazygit },
	{ "git resume", "Telescope git_bcommits" },
	{ "git submit", file_git_commit },
	{ "opencode", opencode },
}
