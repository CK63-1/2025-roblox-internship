local Players = game:GetService("Players")

local BonusSystem = {}
local mockFriends = {} 
local FRIEND_BONUS_PCT = 0.04 -- 4%
local MAX_FRIENDS_CAP = 5

function BonusSystem.GetMultiplier(player)
	if not player then return 1.0 end

	local userId = player.UserId
	local realFriends = 0

	-- In a production game, cache this result so you don't call GetFriendsAsync/IsFriendsWith constantly
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local success, isFriend = pcall(function()
				return player:IsFriendsWith(otherPlayer.UserId)
			end)
			if success and isFriend then
				realFriends += 1
			end
		end
	end

	local fakeFriends = mockFriends[userId] or 0
	local totalFriends = realFriends + fakeFriends
	local friendsCalculated = math.min(totalFriends, MAX_FRIENDS_CAP)

	return 1.0 + (friendsCalculated * FRIEND_BONUS_PCT)
end

-- Debug helpers
function BonusSystem.AddFakeFriend(player)
	local id = player.UserId
	mockFriends[id] = (mockFriends[id] or 0) + 1
	print("BonusSystem: Added fake friend for " .. player.Name)
end

function BonusSystem.RemoveFakeFriend(player)
	local id = player.UserId
	if mockFriends[id] and mockFriends[id] > 0 then
		mockFriends[id] = mockFriends[id] - 1
		print("BonusSystem: Removed fake friend for " .. player.Name)
	end
end

return BonusSystem