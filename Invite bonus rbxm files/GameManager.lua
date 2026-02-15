local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load Logic Module
local GameLogic = require(ServerScriptService.GameLogic)

Players.PlayerAdded:Connect(function(player)
	-- Initialize Session
	GameLogic.InitializePlayer(player)

	-- Listen for Commands
	player.Chatted:Connect(function(message)
		local msg = string.lower(message)

		if msg == "/matchstart" then
			GameLogic.StartMatch(player)
		elseif msg == "/matchend" then
			GameLogic.EndMatch(player)
		elseif msg == "/action" then
			GameLogic.PerformAction(player)
		elseif msg == "/reset" then
			GameLogic.ResetData(player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	GameLogic.RemovePlayer(player)
end)