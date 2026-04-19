local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local DataService = require(script.Parent:WaitForChild("DataService"))
local PlotService = require(script.Parent:WaitForChild("PlotService"))

local EconomyService = {}

local lastTick = 0
local updateRemote = Remotes.Get("UpdateState")

local function computeIncome(player)
	local plot = PlotService.GetPlot(player)
	if not plot then
		return 0
	end
	local total = 0
	for _, pedestal in ipairs(plot.pedestals) do
		local occupant = pedestal:GetAttribute("OccupiedBy")
		if occupant then
			for _, child in ipairs(pedestal:GetChildren()) do
				if child:IsA("Model") and child:GetAttribute("UID") == occupant then
					total = total + (child:GetAttribute("Income") or 0)
					break
				end
			end
		end
	end
	return total
end

function EconomyService.AddCoins(player, amount)
	local data = DataService.Get(player)
	if not data then return end
	data.coins = math.max(0, math.floor(data.coins + amount))
	if amount > 0 then
		data.totalEarned = (data.totalEarned or 0) + amount
	end
	EconomyService.PushState(player)
end

function EconomyService.SpendCoins(player, amount)
	local data = DataService.Get(player)
	if not data or data.coins < amount then
		return false
	end
	data.coins = data.coins - amount
	EconomyService.PushState(player)
	return true
end

function EconomyService.PushState(player)
	local data = DataService.Get(player)
	if not data then return end
	local plot = PlotService.GetPlot(player)
	updateRemote:FireClient(player, {
		coins = data.coins,
		income = computeIncome(player),
		plotIndex = plot and plot.index or nil,
		totalStolen = data.totalStolen or 0,
		totalEarned = data.totalEarned or 0,
	})
end

function EconomyService.Init()
	RunService.Heartbeat:Connect(function(dt)
		lastTick = lastTick + dt
		if lastTick < GameConfig.INCOME_TICK then return end
		lastTick = 0
		for _, player in ipairs(Players:GetPlayers()) do
			local data = DataService.Get(player)
			if data then
				local income = computeIncome(player)
				if income > 0 then
					data.coins = data.coins + income
					data.totalEarned = (data.totalEarned or 0) + income
					EconomyService.PushState(player)
				end
			end
		end
	end)
end

return EconomyService
