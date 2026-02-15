local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DeathConfig = require(ReplicatedStorage.Common.DeathConfig)
local ScoreManager = require(ServerScriptService.ScoreManager)
local DeathManager = require(ServerScriptService.DeathManager)

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		local args = string.split(msg, " ")
		local cmd = string.lower(args[1])

		if cmd == "/points" then
			-- Adds 10 points
			ScoreManager:AddPoints(player, 10)
			print("Debug: Added 10 points")

		elseif cmd == "/resetpoints" then
			ScoreManager:ResetPoints(player)
			print("Debug: Reset points")

		elseif cmd == "/instant" then
			-- Usage: /instant true OR /instant false
			if args[2] == "true" then
				DeathConfig.Instant_respawn = true
				print("Debug: Instant Respawn ON")
			else
				DeathConfig.Instant_respawn = false
				print("Debug: Instant Respawn OFF")
			end

		elseif cmd == "/countdown" then
			-- Usage: /countdown true OR /countdown false
			if args[2] == "true" then
				DeathConfig.Respawn_countdown = true
				print("Debug: Countdown ON")
			else
				DeathConfig.Respawn_countdown = false
				print("Debug: Countdown OFF")
			end

		elseif cmd == "/kill" then
			-- Usage: /kill fast OR /kill magic
			local type = args[2]
			DeathManager:KillPlayer(player, type)
		end
	end)
end)