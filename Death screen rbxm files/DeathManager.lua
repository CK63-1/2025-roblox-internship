local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")
local DeathConfig = require(Common:WaitForChild("DeathConfig"))
local ScoreManager = require(ServerScriptService:WaitForChild("ScoreManager"))

local DeathManager = {}

local Events = ReplicatedStorage:FindFirstChild("Events")
if not Events then Events = Instance.new("Folder"); Events.Name = "Events"; Events.Parent = ReplicatedStorage end

local ShowDeathScreen = Events:FindFirstChild("ShowDeathScreen") or Instance.new("RemoteEvent", Events)
ShowDeathScreen.Name = "ShowDeathScreen"

local RespawnPlayer = Events:FindFirstChild("RespawnPlayer") or Instance.new("RemoteEvent", Events)
RespawnPlayer.Name = "RespawnPlayer"

local function ReloadCharacter(player)
	local success, err = pcall(function()
		local description = Players:GetHumanoidDescriptionFromUserIdAsync(player.UserId)
		player:LoadCharacterWithHumanoidDescription(description)
	end)
	if not success then player:LoadCharacter() end
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	local player = Players:GetPlayerFromCharacter(character)

	humanoid.Died:Connect(function()
		local message = player.Name .. " succumbed to magic"

		local creator = humanoid:FindFirstChild("creator")
		if creator and creator.Value then
			message = player.Name .. " was slain by " .. creator.Value.Name
		elseif character.PrimaryPart and character.PrimaryPart.Position.Y < -50 then
			message = player.Name .. " fell off the map"
		end

		local override = character:GetAttribute("DeathReason")
		if override then message = override end

		if DeathConfig.Instant_respawn then
			task.wait(0.3)
			ReloadCharacter(player)
			ScoreManager:ResetRoundScore(player)
		else
			local roundScore = ScoreManager:GetRoundScore(player)
			ScoreManager:ResetRoundScore(player)

			-- Pass countdown setting to client
			ShowDeathScreen:FireClient(player, message, roundScore, DeathConfig.Respawn_countdown)
		end
	end)
end

function DeathManager:Init()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(onCharacterAdded)

		-- FIX: Since we disabled AutoLoads, we must spawn the player manually when they join
		player:LoadCharacterAsync()
	end)

	RespawnPlayer.OnServerEvent:Connect(function(player)
		ReloadCharacter(player)
	end)
end

function DeathManager:KillPlayer(player, reasonType)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		local msg = player.Name .. " succumbed to magic"
		if reasonType == "fast" then msg = player.Name .. " wasn't fast enough" end
		char:SetAttribute("DeathReason", msg)
		char.Humanoid.Health = 0
	end
end

return DeathManager