local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoginControllerModule = ReplicatedStorage:WaitForChild("Common"):WaitForChild("LoginController")
local LoginController = require(LoginControllerModule)

LoginController.Init()