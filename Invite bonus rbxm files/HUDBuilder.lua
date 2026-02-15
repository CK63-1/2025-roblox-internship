local HUDBuilder = {}

function HUDBuilder.CreateHUD()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StatsHUD"
	screenGui.ResetOnSpawn = false

	local frame = Instance.new("Frame")
	frame.Name = "TopRightFrame"
	frame.Parent = screenGui
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 1 
	frame.BorderSizePixel = 0

	frame.AnchorPoint = Vector2.new(1, 0)
	frame.Position = UDim2.new(0.98, 0, 0.05, 0)
	frame.Size = UDim2.new(0.35, 0, 0.2, 0) 

	local layout = Instance.new("UIListLayout")
	layout.Parent = frame
	layout.Padding = UDim.new(0, 5)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right 
	layout.VerticalAlignment = Enum.VerticalAlignment.Top

	local function createLabel(name, text)
		local label = Instance.new("TextLabel")
		label.Name = name
		label.Parent = frame
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0.25, 0) 

		label.FontFace = Font.fromName("PressStart2P")
		label.Text = text
		label.TextColor3 = Color3.new(1, 1, 1) 
		label.TextScaled = true
		label.TextXAlignment = Enum.TextXAlignment.Right

		local stroke = Instance.new("UIStroke")
		stroke.Parent = label
		stroke.Color = Color3.new(0, 0, 0) 
		stroke.Thickness = 2.5
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

		return label
	end

	createLabel("MatchStateLabel", "Match Waiting...")
	createLabel("MoneyLabel", "$0.00")
	createLabel("ExpLabel", "Level 1: 0 EXP")

	return screenGui
end

return HUDBuilder