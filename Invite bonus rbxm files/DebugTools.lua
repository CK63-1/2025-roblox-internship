local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- Added ReplicatedStorage service

local BonusSystem = require(ReplicatedStorage:WaitForChild("BonusSystem"))

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		local msg = string.lower(message)

		if msg == "/addfriend" then
			BonusSystem.AddFakeFriend(player)
		elseif msg == "/removefriend" then
			BonusSystem.RemoveFakeFriend(player)
		end
	end)
end)