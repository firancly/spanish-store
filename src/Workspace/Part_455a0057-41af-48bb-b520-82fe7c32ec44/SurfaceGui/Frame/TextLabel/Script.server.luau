local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

script.Parent.Text = "OXXO:0$"

local function formatValue(value)
	return string.format("%0.0f", value):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function updateOxxoValue(value)
	local formattedValue = formatValue(value)
	script.Parent.Text = "OXXO: " .. formattedValue .. "$"
end

game.Workspace.TiendaStats.Oxxo.Changed:Connect(function()
	local oxxoValue = game.Workspace.TiendaStats.Oxxo.Value
	updateOxxoValue(oxxoValue)
end)
