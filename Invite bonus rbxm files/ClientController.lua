local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local HUDBuilder = require(ReplicatedStorage:WaitForChild("HUDBuilder"))

--backup
local updateHUDEvent = ReplicatedStorage:WaitForChild("UpdateHUD")
local updateMatchStateEvent = ReplicatedStorage:WaitForChild("UpdateMatchState")

local playerGui = player:WaitForChild("PlayerGui")
local gui = HUDBuilder.CreateHUD()
gui.Parent = playerGui

local frame = gui:WaitForChild("TopRightFrame")
local matchStateLabel = frame:WaitForChild("MatchStateLabel")
local moneyLabel = frame:WaitForChild("MoneyLabel")
local expLabel = frame:WaitForChild("ExpLabel")

local function roundUp2dp(num)
	return math.ceil(num * 100) / 100
end

updateHUDEvent.OnClientEvent:Connect(function(money, exp, multiplier, level)
	moneyLabel.Text = string.format("$%.2f", money)

	local displayExp = roundUp2dp(exp)
	local bonusText = ""

	if multiplier > 1.0 then
		local pct = math.round((multiplier - 1) * 100)
		bonusText = " (+" .. pct .. "% Friend Bonus!)"
	end

	expLabel.Text = string.format("Level %d: %.1f EXP%s", level, displayExp, bonusText)
end)

