local M = {}

local api_key = os.getenv("OPENAI_API_KEY")
local Job = require("plenary.job")

-- Config
local model = "gpt-4o-mini"

function M.enable_writer_mode()
	vim.wo.wrap = true
	vim.wo.linebreak = true
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.signcolumn = "no"
	vim.wo.colorcolumn = ""
	vim.cmd("setlocal spell spelllang=de")
	vim.cmd("ZenMode")
end

function M.disable_writer_mode()
	vim.cmd("ZenMode")
	vim.wo.wrap = false
	vim.wo.linebreak = false
	vim.wo.number = true
	vim.wo.relativenumber = true
	vim.wo.signcolumn = "yes"
	vim.wo.colorcolumn = "100"
	vim.cmd("setlocal nospell")
end

function M.toggle_writer_mode()
	M._enabled = not M._enabled
	if M._enabled then
		M.enable_writer_mode()
		vim.notify("✍️ Write mode activated", vim.log.levels.INFO)
	else
		M.disable_writer_mode()
		vim.notify("💤 Writer mode deactivated", vim.log.levels.INFO)
	end
end

--- GPT-based text correction with a specific temperature.
---
--- The `temperature` parameter controls the creativity of the response:
---   - Low (e.g., 0.2) → precise, conservative
---   - Medium (e.g., 0.4) → balanced
---   - Higher (e.g., 0.7) → more stylistically free
---
--- @param input_text string the text which should be corrected
--- @param temperature number the temperature for the GPT response (range: 0.0–1.0)
--- @param on_done fun(corrected_text: string) the callback function for the result
---
function M.correct_with_gpt(input_text, temperature, on_done)
	if not input_text or input_text == "" then
		vim.notify("❌ No text available", vim.log.levels.WARN)
		return
	end

	vim.notify("⏳ GPT-correction " .. temperature .. "started ...", vim.log.levels.INFO)

	local body = vim.fn.json_encode({
		model = model,
		temperature = temperature,
		messages = {
			{
				role = "system",
				content =
				"Du bist ein erfahrener Lektor und wissenschaftlicher Autor. Überarbeite den folgenden deutschen Text stilistisch, mach ihn klarer, strukturierter und präziser. Formuliere natürlich und sachlich, achte auf gute Übergänge. Verwende keine Emojis, keine Umgangssprache. Gib nur den überarbeiteten Text zurück – ohne weitere Kommentare.",
			},
			{
				role = "user",
				content = input_text,
			},
		},
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
			body,
			"https://api.openai.com/v1/chat/completions",
		},
		on_exit = function(j, return_val)
			vim.schedule(function()
				if return_val ~= 0 then
					vim.schedule(function()
						vim.notify("❌ Error in API", vim.log.levels.ERROR)
					end)
					return
				end

				local result = table.concat(j:result(), "\n")
				local data = vim.fn.json_decode(result)
				local content = data.choices and data.choices[1].message.content or "⚠️ No response"
				on_done(content)
			end)
		end,
	}):start()
end

--- Corrects the current visual selection, and inserts the corrected text below the current selection.
---
--- The `temperature` parameter controls the creativity of the response:
---   - Low (e.g., 0.2) → precise, conservative
---   - Medium (e.g., 0.4) → balanced
---   - Higher (e.g., 0.7) → more stylistically free
---
--- @param temperature number the temperature for the GPT response (range: 0.0–1.0)
---
function M.correct_visual_selection(temperature)
	local end_pos = vim.fn.getpos("'>")

	vim.cmd('normal! "vy')

	local input = vim.fn.getreg('"')
	if input == "" then
		vim.notify("⚠️ No text selected", vim.log.levels.WARN)
		return
	end

	M.correct_with_gpt(input, temperature, function(corrected)
		-- ESC to leave visual mode
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

		-- take insert point after selection
		local line_nr = end_pos[2]

		-- add splitter and corrected text
		local lines_to_insert = vim.split("---\n" .. corrected, "\n", { plain = true })

		vim.api.nvim_buf_set_lines(0, line_nr, line_nr, false, lines_to_insert)

		vim.notify("✅ GPT correction done", vim.log.levels.INFO)
	end)
end

return M
