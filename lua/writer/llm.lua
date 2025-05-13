local Job = require("plenary.job")

local M = {}

local function get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local lines = vim.fn.getline(start_pos[2], end_pos[2])
	if #lines == 0 then
		return ""
	end

	lines[1] = string.sub(lines[1], start_pos[3], -1)
	lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])

	return table.concat(lines, "\n"), end_pos[2]
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

			local output = table.concat(j:result(), "")
			local decoded = vim.fn.json_decode(output)
			local reply = decoded.choices[1].message.content

			vim.schedule(function()
				vim.api.nvim_buf_set_lines(0, end_line, end_line, false, vim.split(reply, "\n"))
				vim.notify("✅ Done", vim.log.levels.INFO)
			end)
		end,
	}):start()
end

return M
