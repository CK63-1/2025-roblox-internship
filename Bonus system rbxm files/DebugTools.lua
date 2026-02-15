local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Connect to Manager
local DailyRewardManager = require(ServerScriptService:WaitForChild("DailyRewardManager"))
local Events = ReplicatedStorage:WaitForChild("Events")
local RequestLoginStatus = Events:WaitForChild("RequestLoginStatus")

-- Refresh function
local function refreshClient(player)
	task.wait(0.5) 
	local DebugRefresh = ReplicatedStorage:FindFirstChild("DebugRefresh")
	if DebugRefresh then DebugRefresh:FireClient(player) end
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		local cmd = string.lower(msg)

		if cmd == "/adddaylogin" then
			DailyRewardManager:Debug_AddDayLogin(player)
			print(player.Name .. ": Added 1 Day (Login/Missions reset)")
			refreshClient(player)

		elseif cmd == "/addhourelapsed" then
			DailyRewardManager:Debug_AddHourElapsed(player)
			print(player.Name .. ": Added 1 Hour Playtime")
			refreshClient(player)

		elseif cmd == "/resettime" then
			DailyRewardManager:Debug_ResetTime(player)
			print(player.Name .. ": Reset All Timers")
			refreshClient(player)

		elseif cmd == "/resetinventory" then
			DailyRewardManager:Debug_ResetInventory(player)
			print(player.Name .. ": Wiped Inventory")
			refreshClient(player)

		elseif cmd == "/completedailymission" then
			DailyRewardManager:Debug_CompleteDaily(player)
			print(player.Name .. ": Force Completed Daily Mission")
			refreshClient(player)

		elseif cmd == "/checkinventory" then
			local inv = DailyRewardManager:Debug_GetInventory(player)
			print("====================================")
			print("INVENTORY CHECK FOR: " .. player.Name)
			print("Gold: " .. (inv.Gold or 0))

			local itemString = "None"
			if inv.Items and #inv.Items > 0 then
				itemString = table.concat(inv.Items, ", ")
			end
			print("Items: " .. itemString)
			print("====================================")
		end
	end)
end)