local Job = require("plenary.job")

local M = {}

local function get_visual_selection()
	local mode = vim.fn.visualmode()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line = start_pos[2]
	local start_col = start_pos[3]
	local end_line = end_pos[2]
	local end_col = end_pos[3]

	local lines = vim.fn.getline(start_line, end_line)

	if mode == "V" then
		-- Linewise mode
		return table.concat(lines, "\n"), end_line
	elseif mode == "\22" then
		-- Block mode (CTRL-V) – optional, not implemented
		vim.notify("Block mode currently not supported", vim.log.levels.WARN)
		return "", end_line
	else
		-- Characterwise
		if #lines == 0 then
			return "", end_line
		end

		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
		return table.concat(lines, "\n"), end_line
	end
end

function M.fix_selection()
	local selected_text, end_line = get_visual_selection()
	if selected_text == "" then
		vim.notify("No text selected.", vim.log.levels.WARN)
		return
	end

	local api_key = os.getenv("OPENAI_API_KEY")
	if not api_key then
		vim.notify("Missing OPENAI_API_KEY", vim.log.levels.ERROR)
		return
	end

	local request_body = vim.fn.json_encode({
		model = "gpt-4o-mini",
		messages = {
			{
				role = "system",
				content =
				"Du bist ein professioneller Lektor. Verbessere den folgenden deutschen Text in Grammatik, Rechtschreibung und Stil und sorge für einen guten Lesefluss.",
			},
			{
				role = "user",
				content = selected_text,
			},
		},
		temperature = 0.4,
	})

	-- require("writer.status").set_running(true)
	vim.notify("✍ GPT läuft...", vim.log.levels.INFO, { title = "nvim-writer" })

	Job:new({
		command = "curl",
		args = {
			"-s",
			"-H",
			"Content-Type: application/json",
			"-H",
			"Authorization: Bearer " .. api_key,
			"-d",
			request_body,
			"https://api.openai.com/v1/chat/completions",
		},
		on_exit = function(j, return_val)
			if return_val ~= 0 then
				vim.schedule(function()
					vim.notify("OpenAI API Call failed", vim.log.levels.ERROR)
				end)
				return
			end

			vim.schedule(function()
				local output = table.concat(j:result(), "")
				local ok, decoded = pcall(vim.fn.json_decode, output)
				if not ok or not decoded or not decoded.choices then
					vim.notify("❌ Problem processing API result", vim.log.levels.ERROR)
					-- require("writer.status").set_running(false)
					return
				end

				local reply = decoded.choices[1].message.content
				vim.api.nvim_buf_set_lines(0, end_line, end_line, false, vim.split(reply, "\n"))
				vim.notify("✅ Done", vim.log.levels.INFO)
				-- require("writer.status").set_running(false)
			end)
		end,
	}):start()
end

return M
