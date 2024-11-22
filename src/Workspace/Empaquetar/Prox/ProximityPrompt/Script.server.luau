local computadora = script.Parent 
local teamName = "EMPAQUETADOR" 

script.Parent.Parent.ProximityPrompt.Triggered:Connect(function(player)
	if player.Team and player.Team.Name == teamName then
		player:FindFirstChild("PlayerGui"):FindFirstChild("EmpaquetadorUI").Enabled = not player:FindFirstChild("PlayerGui"):FindFirstChild("EmpaquetadorUI").Enabled

	end
end)
