local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage:WaitForChild("Common")
local DeathController = require(Common:WaitForChild("DeathController"))

DeathController.Init()