local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- FIX: Disable Roblox's default 5-second auto-respawn
-- This gives us 100% control over when the player respawns
Players.CharacterAutoLoads = false

local ScoreManager = require(ServerScriptService:WaitForChild("ScoreManager"))
local DeathManager = require(ServerScriptService:WaitForChild("DeathManager"))

ScoreManager:Init()
DeathManager:Init()

print("💀 Death System Loaded")