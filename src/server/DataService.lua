local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("GameConfig"))

local STORE_KEY = "PlayerData_v1"
local store = DataStoreService:GetDataStore(STORE_KEY)

local DataService = {}
local cache = {}

local function defaultProfile()
	return {
		coins = GameConfig.STARTING_COINS,
		brainrots = {},
		totalStolen = 0,
		totalEarned = 0,
	}
end

local function safeLoad(userId)
	if RunService:IsStudio() then
		return defaultProfile()
	end
	local ok, data = pcall(function()
		return store:GetAsync("u_" .. userId)
	end)
	if ok and typeof(data) == "table" then
		data.coins = tonumber(data.coins) or GameConfig.STARTING_COINS
		data.brainrots = data.brainrots or {}
		return data
	end
	return defaultProfile()
end

local function safeSave(userId, data)
	if RunService:IsStudio() then
		return
	end
	pcall(function()
		store:SetAsync("u_" .. userId, data)
	end)
end

function DataService.Load(player)
	local data = safeLoad(player.UserId)
	cache[player.UserId] = data
	return data
end

function DataService.Get(player)
	return cache[player.UserId]
end

function DataService.Save(player)
	local data = cache[player.UserId]
	if data then
		safeSave(player.UserId, data)
	end
end

function DataService.Release(player)
	DataService.Save(player)
	cache[player.UserId] = nil
end

Players.PlayerRemoving:Connect(function(player)
	DataService.Release(player)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DataService.Save(player)
	end
end)

return DataService
