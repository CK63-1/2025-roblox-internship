local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Dependencies
local BonusSystem = require(ReplicatedStorage:WaitForChild("BonusSystem"))

-- Events
local updateHUDEvent = ReplicatedStorage:WaitForChild("UpdateHUD")
local updateMatchStateEvent = ReplicatedStorage:WaitForChild("UpdateMatchState")

local GameLogic = {}
local sessionData = {} 

local BASE_MONEY = 10.00
local BASE_EXP = 15.0

local function updateClient(player)
	if not sessionData[player.UserId] then return end
	local data = sessionData[player.UserId]

	local multiplier = BonusSystem.GetMultiplier(player)
	updateHUDEvent:FireClient(player, data.Money, data.EXP, multiplier, data.Level)

	local stateText = data.MatchActive and "Match Started" or "Match Waiting..."
	updateMatchStateEvent:FireClient(player, stateText)
end

-- PUBLIC API

function GameLogic.InitializePlayer(player)
	sessionData[player.UserId] = {
		Money = 0,
		EXP = 0,
		Level = 1,
		MatchActive = false,
		MatchStartTime = 0
	}
	updateClient(player)
end

function GameLogic.RemovePlayer(player)
	sessionData[player.UserId] = nil
end

function GameLogic.StartMatch(player)
	local data = sessionData[player.UserId]
	if not data then return end

	if not data.MatchActive then
		data.MatchActive = true
		data.MatchStartTime = os.time()

		print(string.format("[ANALYTICS] match_start: %d | User: %s", data.MatchStartTime, player.Name))

		updateClient(player)
	end
end

function GameLogic.EndMatch(player)
	local data = sessionData[player.UserId]
	if not data then return end

	if data.MatchActive then
		data.MatchActive = false
		local mult = BonusSystem.GetMultiplier(player)

		local endTime = os.time()
		local startTime = data.MatchStartTime or endTime
		local duration = endTime - startTime

		print(string.format("[ANALYTICS] match_end: %d | match_duration: %ds | User: %s", endTime, duration, player.Name))

		data.Money += (BASE_MONEY * mult)
		data.EXP += (BASE_EXP * mult)

		if data.EXP >= 45 then 
			data.Level += 1 
			data.EXP = 0 
		end

		updateClient(player)
	end
end

function GameLogic.PerformAction(player)
	local data = sessionData[player.UserId]
	if not data then return end

	if data.MatchActive then
		data.EXP += 5
		updateClient(player)
	end
end

function GameLogic.ResetData(player)
	GameLogic.InitializePlayer(player)
end

return GameLogic