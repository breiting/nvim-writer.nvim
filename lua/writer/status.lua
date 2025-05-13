local M = {
	_running = false,
}

function M.set_running(state)
	M._running = state
end

function M.statusline()
	if M._running then
		return "[✍ GPT läuft...]"
	else
		return ""
	end
end

return M
