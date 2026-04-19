local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local HUD = require(script:WaitForChild("HUD"))
local ShopUI = require(script:WaitForChild("ShopUI"))
local StealPrompt = require(script:WaitForChild("StealPrompt"))
local Notifications = require(script:WaitForChild("Notifications"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local hud = HUD.new(screenGui)
ShopUI.new(screenGui)
StealPrompt.new(screenGui)
Notifications.new(screenGui)

Remotes.Get("UpdateState").OnClientEvent:Connect(function(state)
	hud:Update(state)
end)
