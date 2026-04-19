local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local BrainrotDatabase = require(Shared:WaitForChild("BrainrotDatabase"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local DataService = require(script:WaitForChild("DataService"))
local PlotService = require(script:WaitForChild("PlotService"))
local BrainrotService = require(script:WaitForChild("BrainrotService"))
local EconomyService = require(script:WaitForChild("EconomyService"))
local StealService = require(script:WaitForChild("StealService"))

local rollCooldowns = {}

PlotService.Init()
EconomyService.Init()

local function buildGround()
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate then baseplate:Destroy() end
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(1200, 2, 600)
	ground.Position = Vector3.new(GameConfig.PLOT_COUNT * (GameConfig.PLOT_SIZE.X + GameConfig.PLOT_SPACING) / 2, 0, 0)
	ground.Anchored = true
	ground.Material = Enum.Material.Grass
	ground.Color = Color3.fromRGB(80, 160, 80)
	ground.TopSurface = Enum.SurfaceType.Smooth
	ground.Parent = Workspace
end

buildGround()

local function teleportToPlot(character, plot)
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if root then
		root.CFrame = CFrame.new(plot.spawn.Position + Vector3.new(0, 4, 0))
	end
end

local function onPlayerAdded(player)
	DataService.Load(player)
	local plot = PlotService.AssignPlot(player)
	if plot then
		player.RespawnLocation = plot.spawn

		player.CharacterAdded:Connect(function(character)
			teleportToPlot(character, plot)
		end)
		if player.Character then
			task.spawn(teleportToPlot, player.Character, plot)
		end

		local data = DataService.Get(player)
		for _, saved in ipairs(data.brainrots or {}) do
			local pedestal = plot.pedestals[saved.slot]
			if pedestal and not pedestal:GetAttribute("OccupiedBy") then
				local entry = BrainrotDatabase.GetById(saved.id)
				if entry then
					BrainrotService.Spawn(entry, pedestal)
				end
			end
		end
	end

	task.wait(1)
	EconomyService.PushState(player)
end

local function saveBrainrots(player)
	local plot = PlotService.GetPlot(player)
	local data = DataService.Get(player)
	if not plot or not data then return end
	local list = {}
	for i, pedestal in ipairs(plot.pedestals) do
		local uid = pedestal:GetAttribute("OccupiedBy")
		if uid then
			local model = BrainrotService.FindModelOnPedestal(pedestal)
			if model then
				table.insert(list, {
					slot = i,
					id = model:GetAttribute("BrainrotId"),
				})
			end
		end
	end
	data.brainrots = list
end

local function onPlayerRemoving(player)
	saveBrainrots(player)
	local plot = PlotService.GetPlot(player)
	if plot then
		for _, pedestal in ipairs(plot.pedestals) do
			BrainrotService.Remove(pedestal)
		end
	end
	PlotService.ReleasePlot(player)
	rollCooldowns[player] = nil
	DataService.Save(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

Remotes.Get("RollBrainrot").OnServerEvent:Connect(function(player)
	local now = os.clock()
	if (now - (rollCooldowns[player] or 0)) < GameConfig.ROLL_COOLDOWN then
		return
	end
	rollCooldowns[player] = now

	local plot = PlotService.GetPlot(player)
	if not plot then return end
	local pedestal = PlotService.FindEmptyPedestal(plot)
	if not pedestal then
		Remotes.Get("ShowNotification"):FireClient(player, "Your plot is full!", Color3.fromRGB(255, 180, 120))
		return
	end
	if not EconomyService.SpendCoins(player, GameConfig.ROLL_COST) then
		Remotes.Get("ShowNotification"):FireClient(player, "Not enough coins!", Color3.fromRGB(255, 120, 120))
		return
	end
	local entry = BrainrotService.RandomRoll()
	BrainrotService.Spawn(entry, pedestal)
	Remotes.Get("RollResult"):FireClient(player, {
		name = entry.name,
		rarity = entry.rarity,
		income = entry.income,
	})
	EconomyService.PushState(player)
end)

Remotes.Get("PurchaseLock").OnServerEvent:Connect(function(player)
	StealService.PurchaseLock(player)
end)

Remotes.Get("StartSteal").OnServerEvent:Connect(function(player, uid)
	if typeof(uid) ~= "string" then return end
	StealService.StartSteal(player, uid)
end)

Remotes.Get("CancelSteal").OnServerEvent:Connect(function(player)
	StealService.CancelSteal(player)
end)
