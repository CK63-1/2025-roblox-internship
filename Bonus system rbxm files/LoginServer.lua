local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local DailyRewardManagerModule = ServerScriptService:WaitForChild("DailyRewardManager", 10)

if not DailyRewardManagerModule then
	error("CRITICAL ERROR: Could not find 'DailyRewardManager'. Please check the file name!")
end

local DailyRewardManager = require(DailyRewardManagerModule)
local RewardConfig = require(ReplicatedStorage.Common.RewardConfig)

local Events = ReplicatedStorage:FindFirstChild("Events") 
if not Events then Events = Instance.new("Folder"); Events.Name = "Events"; Events.Parent = ReplicatedStorage end

local function getRemote(name)
	local remote = Events:FindFirstChild(name)
	if not remote then remote = Instance.new("RemoteEvent"); remote.Name = name; remote.Parent = Events end
	return remote
end

local RequestLoginStatus = getRemote("RequestLoginStatus")
local SendLoginStatus = getRemote("SendLoginStatus")
local ClaimReward = getRemote("ClaimReward")
local ClaimDailyMission = getRemote("ClaimDailyMission")
local ClaimWeeklyMission = getRemote("ClaimWeeklyMission")


local function sendUpdate(player, statusOverride)
	local status, dayIndex, data, totalTime = DailyRewardManager:GetLoginStatus(player)
	local rewardData = RewardConfig.DAILY_REWARDS[dayIndex] or RewardConfig.DAILY_REWARDS[1]

	if statusOverride then status = statusOverride end

	SendLoginStatus:FireClient(player, status, dayIndex, rewardData, totalTime, data)
end

RequestLoginStatus.OnServerEvent:Connect(function(player)
	sendUpdate(player)
end)

ClaimReward.OnServerEvent:Connect(function(player)
	local success, _, updatedData = DailyRewardManager:ClaimReward(player)
	if success and updatedData then
		local nextDayIndex = (updatedData.Streak % 7) + 1
		local nextRewardData = RewardConfig.DAILY_REWARDS[nextDayIndex]
		local totalTime = updatedData.TotalTimePlayed

		SendLoginStatus:FireClient(player, "Claimed", nextDayIndex, nextRewardData, totalTime, updatedData)
	end
end)

ClaimDailyMission.OnServerEvent:Connect(function(player)
	local success, _, updatedData = DailyRewardManager:ClaimDailyMission(player)
	if success and updatedData then
		sendUpdate(player) 
	end
end)

ClaimWeeklyMission.OnServerEvent:Connect(function(player)
	local success, _, updatedData = DailyRewardManager:ClaimWeeklyMission(player)
	if success and updatedData then
		sendUpdate(player) 
	end
end)
