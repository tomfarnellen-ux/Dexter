local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local UIStyle = require(script.Parent:WaitForChild("UIStyle"))

local LocalPlayer = Players.LocalPlayer
local PROMPT_RANGE = 10

local StealPrompt = {}

local function isOwnPlot(pedestal)
	local plot = pedestal and pedestal.Parent
	if not plot or not plot.Name:match("^Plot_") then return false end
	local signLabel = plot:FindFirstChild("Sign") and plot.Sign:FindFirstChildWhichIsA("BillboardGui")
	if not signLabel then return false end
	local text = signLabel:FindFirstChildWhichIsA("TextLabel")
	if not text then return false end
	return text.Text:find(LocalPlayer.DisplayName, 1, true) ~= nil
end

local function findClosestStealTarget()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return nil end

	local best, bestDist
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if not isOwnPlot(plot:FindFirstChild("Pedestal_1")) then
			for _, pedestal in ipairs(plot:GetChildren()) do
				if pedestal.Name:match("^Pedestal_") and pedestal:GetAttribute("OccupiedBy") then
					local dist = (pedestal.Position - root.Position).Magnitude
					if dist <= PROMPT_RANGE and (not bestDist or dist < bestDist) then
						bestDist = dist
						best = pedestal
					end
				end
			end
		end
	end
	return best
end

function StealPrompt.new(screenGui)
	local self = {}

	local frame = Instance.new("Frame")
	frame.Name = "StealPrompt"
	frame.Size = UDim2.new(0, 320, 0, 120)
	frame.Position = UDim2.new(0.5, 0, 0.82, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = UIStyle.Panel
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = screenGui
	UIStyle.Corner(frame, 14)
	UIStyle.Stroke(frame, UIStyle.Accent, 3)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 36)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = UIStyle.TextPrimary
	label.TextSize = 20
	label.Text = "Hold E to Steal"
	label.Parent = frame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -20, 0, 18)
	bar.Position = UDim2.new(0, 10, 1, -34)
	bar.BackgroundColor3 = UIStyle.PanelLight
	bar.BorderSizePixel = 0
	bar.Parent = frame
	UIStyle.Corner(bar, 8)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = UIStyle.Accent
	fill.BorderSizePixel = 0
	fill.Parent = bar
	UIStyle.Corner(fill, 8)

	local hint = Instance.new("TextLabel")
	hint.Size = UDim2.new(1, -20, 0, 24)
	hint.Position = UDim2.new(0, 10, 0, 48)
	hint.BackgroundTransparency = 1
	hint.Font = Enum.Font.GothamMedium
	hint.TextColor3 = UIStyle.TextMuted
	hint.TextSize = 14
	hint.Text = ""
	hint.Parent = frame

	local activeTarget, holdStart

	local function updateLoop()
		local target = findClosestStealTarget()
		if target then
			frame.Visible = true
			local model = target:FindFirstChildWhichIsA("Model")
			if model then
				label.Text = "Hold E: Steal " .. model.Name
				hint.Text = model:GetAttribute("Rarity") or ""
				hint.TextColor3 = GameConfig.RARITY_COLORS[model:GetAttribute("Rarity")] or UIStyle.TextMuted
			end
			if activeTarget and activeTarget ~= target then
				activeTarget = nil
				holdStart = nil
				fill.Size = UDim2.new(0, 0, 1, 0)
			end
			if holdStart and activeTarget == target then
				local progress = math.clamp((os.clock() - holdStart) / GameConfig.STEAL_HOLD_TIME, 0, 1)
				fill.Size = UDim2.new(progress, 0, 1, 0)
			end
		else
			frame.Visible = false
			if activeTarget then
				activeTarget = nil
				holdStart = nil
				fill.Size = UDim2.new(0, 0, 1, 0)
				Remotes.Get("CancelSteal"):FireServer()
			end
		end
	end

	RunService.RenderStepped:Connect(updateLoop)

	local function onAction(_, state)
		if state == Enum.UserInputState.Begin then
			local target = findClosestStealTarget()
			if not target then return end
			local model = target:FindFirstChildWhichIsA("Model")
			local uid = model and model:GetAttribute("UID")
			if not uid then return end
			activeTarget = target
			holdStart = os.clock()
			Remotes.Get("StartSteal"):FireServer(uid)
		elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
			if activeTarget then
				Remotes.Get("CancelSteal"):FireServer()
			end
			activeTarget = nil
			holdStart = nil
			fill.Size = UDim2.new(0, 0, 1, 0)
		end
	end

	ContextActionService:BindAction(
		"StealBrainrot",
		onAction,
		true,
		Enum.KeyCode.E,
		Enum.KeyCode.ButtonX
	)
	ContextActionService:SetTitle("StealBrainrot", "Steal")

	return self
end

return StealPrompt
