local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RewardConfig = require(ReplicatedStorage.Common.RewardConfig)
local DailyStore = DataStoreService:GetDataStore("DailyRewardSystem_V7_Visuals") 

local DailyRewardManager = {}
local sessionStartTimes = {}

local function getPlayerKey(player) return "User_" .. player.UserId end

local function getBlankData()
	return {
		LastClaim = 0,
		Streak = 0, 
		TotalTimePlayed = 0,
		Inventory = { Gold = 0, Items = {} },
		Missions = {
			Daily = { LastCompleted = 0, LastClaimed = 0 },
			Weekly = { Progress = 0, LastWeeklyClaim = 0 }
		}
	}
end

Players.PlayerAdded:Connect(function(player) sessionStartTimes[player.UserId] = os.time() end)
Players.PlayerRemoving:Connect(function(player) sessionStartTimes[player.UserId] = nil end)

function DailyRewardManager:GetLoginStatus(player)
	local key = getPlayerKey(player)
	local success, data = pcall(function() return DailyStore:GetAsync(key) end)
	if not success or not data then data = getBlankData() end
	if not data.Missions then data.Missions = getBlankData().Missions end -- Backfill

	-- Playtime
	local currentSession = 0
	if sessionStartTimes[player.UserId] then
		currentSession = os.time() - sessionStartTimes[player.UserId]
	end
	local realTotalTime = (data.TotalTimePlayed or 0) + currentSession

	-- Streak
	local timeSince = os.time() - (data.LastClaim or 0)
	local status = "Claimed"
	local currentDay = (data.Streak or 0) % 7 + 1

	if timeSince >= RewardConfig.DAY_IN_SECONDS then
		status = "Claimable"
		if timeSince >= RewardConfig.GRACE_PERIOD_SECONDS and (data.LastClaim or 0) ~= 0 then
			currentDay = 1 -- Reset visuals
		end
	end

	return status, currentDay, data, realTotalTime
end
function DailyRewardManager:ClaimReward(player)
	local key = getPlayerKey(player)
	local rewardGiven, finalData

	local success, _ = pcall(function()
		DailyStore:UpdateAsync(key, function(oldData)
			oldData = oldData or getBlankData()
			if not oldData.Missions then oldData.Missions = getBlankData().Missions end

			local now = os.time()

			-- Update time
			if sessionStartTimes[player.UserId] then
				oldData.TotalTimePlayed = (oldData.TotalTimePlayed or 0) + (now - sessionStartTimes[player.UserId])
				sessionStartTimes[player.UserId] = now
			end

			local timeSince = now - (oldData.LastClaim or 0)
			if timeSince < RewardConfig.DAY_IN_SECONDS then return nil end

			-- Streak Logic
			local newStreak = (oldData.Streak or 0)
			if timeSince >= RewardConfig.GRACE_PERIOD_SECONDS and oldData.LastClaim ~= 0 then
				newStreak = 1 
			else
				newStreak = (newStreak % 7) + 1
			end

			local reward = RewardConfig.DAILY_REWARDS[newStreak]
			rewardGiven = reward

			oldData.LastClaim = now
			oldData.Streak = newStreak
			oldData.Inventory.Gold = (oldData.Inventory.Gold or 0) + (reward.Gold or 0)
			if reward.Bonus then table.insert(oldData.Inventory.Items, reward.Bonus) end

			finalData = oldData
			return oldData
		end)
	end)

	return success, rewardGiven, finalData
end

function DailyRewardManager:CompleteDailyMission(player)
	local key = getPlayerKey(player)
	local success, _ = pcall(function()
		DailyStore:UpdateAsync(key, function(data)
			data = data or getBlankData()
			if not data.Missions then data.Missions = getBlankData().Missions end
			-- Simply mark completed now
			data.Missions.Daily.LastCompleted = os.time()
			return data
		end)
	end)
	return success
end

function DailyRewardManager:ClaimDailyMission(player)
	local key = getPlayerKey(player)
	local reward, finalData
	pcall(function()
		DailyStore:UpdateAsync(key, function(data)
			data = data or getBlankData()
			if not data.Missions then data.Missions = getBlankData().Missions end

			-- Verify
			local now = os.time()
			if (now - data.Missions.Daily.LastCompleted) > RewardConfig.DAY_IN_SECONDS then return nil end -- Not done today
			if (now - data.Missions.Daily.LastClaimed) < RewardConfig.DAY_IN_SECONDS then return nil end -- Already claimed

			data.Missions.Daily.LastClaimed = now
			data.Missions.Weekly.Progress = (data.Missions.Weekly.Progress or 0) + 1

			reward = RewardConfig.MISSION_REWARDS.DAILY
			data.Inventory.Gold = (data.Inventory.Gold or 0) + reward.Gold
			finalData = data
			return data
		end)
	end)
	return reward ~= nil, reward, finalData
end

function DailyRewardManager:ClaimWeeklyMission(player)
	local key = getPlayerKey(player)
	local reward, finalData
	pcall(function()
		DailyStore:UpdateAsync(key, function(data)
			data = data or getBlankData()
			if not data.Missions then data.Missions = getBlankData().Missions end

			if data.Missions.Weekly.Progress < RewardConfig.WEEKLY_TARGET then return nil end
			-- (Day 7 logic simplified for brevity: allow claim if progress met)

			data.Missions.Weekly.Progress = 0
			data.Missions.Weekly.LastWeeklyClaim = os.time()

			reward = RewardConfig.MISSION_REWARDS.WEEKLY
			data.Inventory.Gold = (data.Inventory.Gold or 0) + reward.Gold
			table.insert(data.Inventory.Items, reward.Item)
			finalData = data
			return data
		end)
	end)
	return reward ~= nil, reward, finalData
end


function DailyRewardManager:Debug_AddDayLogin(player)
	local key = getPlayerKey(player)
	pcall(function()
		DailyStore:UpdateAsync(key, function(data)
			data = data or getBlankData()
			data.LastClaim = os.time() - (RewardConfig.DAY_IN_SECONDS + 60)
			if data.Missions then
				data.Missions.Daily.LastCompleted = 0
				data.Missions.Daily.LastClaimed = 0
			end
			return data
		end)
	end)
end

function DailyRewardManager:Debug_AddHourElapsed(player)
	local key = getPlayerKey(player)
	pcall(function()
		DailyStore:UpdateAsync(key, function(data)
			data = data or getBlankData()
			data.TotalTimePlayed = (data.TotalTimePlayed or 0) + 3600
			return data
		end)
	end)
end

function DailyRewardManager:Debug_ResetTime(player)
	local key = getPlayerKey(player)
	sessionStartTimes[player.UserId] = os.time()
	pcall(function()
		DailyStore:UpdateAsync(key, function(data)
			data = data or getBlankData()
			data.LastClaim = 0
			data.Streak = 0
			data.TotalTimePlayed = 0
			data.Missions.Daily.LastCompleted = 0
			data.Missions.Daily.LastClaimed = 0
			data.Missions.Weekly.Progress = 0
			return data
		end)
	end)
end

function DailyRewardManager:Debug_ResetInventory(player)
	local key = getPlayerKey(player)
	pcall(function()
		DailyStore:UpdateAsync(key, function(data)
			data = data or getBlankData()
			data.Inventory = { Gold = 0, Items = {} }
			return data
		end)
	end)
end

function DailyRewardManager:Debug_CompleteDaily(player)
	return self:CompleteDailyMission(player)
end

function DailyRewardManager:Debug_GetInventory(player)
	local key = getPlayerKey(player)
	local data = nil
	pcall(function()
		data = DailyStore:GetAsync(key)
	end)

	if data and data.Inventory then
		return data.Inventory
	else
		return { Gold = 0, Items = {} }
	end
end

return DailyRewardManager