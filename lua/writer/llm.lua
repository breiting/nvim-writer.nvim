local Job = require("plenary.job")

local M = {}

function M.review_yanked()
	local text = vim.fn.getreg('"')
	if not text or text == "" then
		vim.notify("Zwischenablage ist leer", vim.log.levels.WARN)
		return
	end

	-- Sofort Fenster anzeigen mit Originaltext
	require("writer.ui").open_review_window(text, nil)

	-- Dann API Call
	local api_key = os.getenv("OPENAI_API_KEY")
	if not api_key then
		vim.notify("Fehlender OPENAI_API_KEY", vim.log.levels.ERROR)
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
					vim.notify("Fehler bei OpenAI Anfrage", vim.log.levels.ERROR)
				end)
				return
			end

			vim.schedule(function()
				local output = table.concat(j:result(), "")
				local ok, decoded = pcall(vim.fn.json_decode, output)
				if not ok or not decoded then
					vim.notify("Fehler beim Parsen der Antwort", vim.log.levels.ERROR)
					return
				end

				local reply = decoded.choices[1].message.content
				require("writer.ui").open_review_window(text, reply)
			end)
		end,
	}):start()
end

return M
