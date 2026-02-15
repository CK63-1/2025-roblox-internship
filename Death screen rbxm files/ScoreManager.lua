local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PointsStore = DataStoreService:GetDataStore("PlayerPoints_V1")

local ScoreManager = {}

local Events = ReplicatedStorage:FindFirstChild("Events")
if not Events then 
	Events = Instance.new("Folder")
	Events.Name = "Events"
	Events.Parent = ReplicatedStorage 
end

-- Create the specific remote this module needs
local UpdatePoints = Events:FindFirstChild("UpdatePoints") or Instance.new("RemoteEvent", Events)
UpdatePoints.Name = "UpdatePoints"

-- Track score gained ONLY in the current life
local roundScores = {} 
-- Track total persistent points
local sessionTotalScores = {}

function ScoreManager:Init()
	-- Load Data on Join
	Players.PlayerAdded:Connect(function(player)
		local key = "User_" .. player.UserId
		local success, savedPoints = pcall(function() return PointsStore:GetAsync(key) end)

		if success then
			sessionTotalScores[player.UserId] = savedPoints or 0
		else
			sessionTotalScores[player.UserId] = 0
			warn("Failed to load points for " .. player.Name)
		end

		roundScores[player.UserId] = 0

		-- Update Client Top-Right UI
		self:UpdateClient(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local key = "User_" .. player.UserId
		if sessionTotalScores[player.UserId] then
			pcall(function() PointsStore:SetAsync(key, sessionTotalScores[player.UserId]) end)
		end
		sessionTotalScores[player.UserId] = nil
		roundScores[player.UserId] = nil
	end)
end

function ScoreManager:AddPoints(player, amount)
	if not player then return end

	-- Add to persistent total
	sessionTotalScores[player.UserId] = (sessionTotalScores[player.UserId] or 0) + amount

	-- Add to current life round score
	roundScores[player.UserId] = (roundScores[player.UserId] or 0) + amount

	self:UpdateClient(player)
end

function ScoreManager:ResetPoints(player)
	sessionTotalScores[player.UserId] = 0
	roundScores[player.UserId] = 0
	self:UpdateClient(player)
end

function ScoreManager:GetRoundScore(player)
	return roundScores[player.UserId] or 0
end

function ScoreManager:ResetRoundScore(player)
	roundScores[player.UserId] = 0
end

function ScoreManager:UpdateClient(player)
	-- Use the variable defined at the top
	if UpdatePoints then
		UpdatePoints:FireClient(player, sessionTotalScores[player.UserId])
	end
end

return ScoreManager