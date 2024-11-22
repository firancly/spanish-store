local St = game:GetService("StarterGui")
local toolToDuplicate = St:WaitForChild("CajaCongelada")
local proximityPrompt = script.Parent

proximityPrompt.Triggered:Connect(function(player)
	local carro = workspace:WaitForChild("CamionRefri") 
	if player and player:FindFirstChild("Backpack") then
		if not player.Backpack:FindFirstChild(toolToDuplicate.Name) then
			local toolClone = toolToDuplicate:Clone()
			toolClone.Parent = player.Backpack

			if carro then
				carro:Destroy()
			end
		end
	end
end)