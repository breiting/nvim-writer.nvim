local Job = require("plenary.job")
local M = {}

local gpt_buf = nil
local win_id = nil

function M.close()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		vim.api.nvim_win_close(win_id, true)
	end
	win_id = nil
	gpt_buf = nil
end

function M.review_yanked_text()
	local text = vim.fn.getreg('"')
	if not text or text == "" then
		vim.notify("Zwischenablage ist leer", vim.log.levels.WARN)
		return
	end

	vim.notify("✍ GPT wird gefragt...", vim.log.levels.INFO)

	local api_key = os.getenv("OPENAI_API_KEY")
	if not api_key then
		vim.notify("❌ OPENAI_API_KEY fehlt", vim.log.levels.ERROR)
		return
	end

	local request_body = vim.fn.json_encode({
		model = "gpt-4o-mini",
		messages = {
			{
				role = "system",
				content =
				"Du bist ein erfahrener Lektor und wissenschaftlicher Autor. Überarbeite den folgenden deutschen Text stilistisch, mach ihn klarer, strukturierter und präziser. Formuliere natürlich und sachlich, achte auf gute Übergänge. Verwende keine Emojis, keine Umgangssprache. Gib nur den überarbeiteten Text zurück – ohne weitere Kommentare.",
			},
			{
				role = "user",
				content = text,
			},
		},
		temperature = 0.7,
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
			vim.schedule(function()
				local output = table.concat(j:result(), "")
				local ok, decoded = pcall(vim.fn.json_decode, output)
				if not ok or not decoded then
					vim.notify("❌ Fehler beim Parsen der Antwort", vim.log.levels.ERROR)
					return
				end

				if decoded.error then
					vim.notify("❌ OpenAI: " .. decoded.error.message, vim.log.levels.ERROR)
					return
				end

				local reply = decoded.choices and decoded.choices[1] and decoded.choices[1].message.content
				if not reply then
					vim.notify("❌ GPT-Antwort war leer", vim.log.levels.ERROR)
					return
				end

				-- Zeige Floating Window mit GPT-Text
				gpt_buf = vim.api.nvim_create_buf(false, true)
				local width = math.floor(vim.o.columns * 0.8)
				local height = math.floor(vim.o.lines * 0.6)
				local row = math.floor((vim.o.lines - height) / 2)
				local col = math.floor((vim.o.columns - width) / 2)

				win_id = vim.api.nvim_open_win(gpt_buf, true, {
					relative = "editor",
					row = row,
					col = col,
					width = width,
					height = height,
					style = "minimal",
					border = "rounded",
				})

				vim.api.nvim_buf_set_lines(gpt_buf, 0, -1, false, vim.split(reply, "\n"))
				vim.bo[gpt_buf].filetype = "text"

				-- Mappe "y" im Buffer: Yank + Fenster schließen
				vim.keymap.set("n", "y", function()
					local lines = vim.api.nvim_buf_get_lines(gpt_buf, 0, -1, false)
					vim.fn.setreg('"', table.concat(lines, "\n"))
					vim.notify("📋 GPT-Text in Zwischenablage")
					M.close()
				end, { buffer = gpt_buf, noremap = true, silent = true })
			end)
		end,
	}):start()
end

return M
