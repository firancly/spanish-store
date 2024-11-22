local Player = game.Players.LocalPlayer
local Event = game.ReplicatedStorage:WaitForChild("MostrarProxis")
local folder = game.Workspace:WaitForChild("ProxisAseo")

Event.OnClientEvent:Connect(function()
	if Player.TeamColor == BrickColor.new("Shamrock") then
		folder.proxiDeso.ProximityPrompt.Enabled = true
		folder.proxiGalon.ProximityPrompt.Enabled = true
		folder.proxipapel.ProximityPrompt.Enabled = true
		folder.proxivasos.ProximityPrompt.Enabled = true

	end
end)