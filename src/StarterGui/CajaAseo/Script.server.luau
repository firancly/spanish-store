local hum = nil
local holdAnim = nil
local destroying = false

script.Parent.Equipped:Connect(function()
	hum = script.Parent.Parent:WaitForChild("Humanoid")

	for _, v in pairs(hum:GetPlayingAnimationTracks()) do
		if v.Name == "Idle" then
			v:Stop()
		end
	end

	holdAnim = hum:LoadAnimation(script.Parent.Idle)
	holdAnim:Play()
end)

script.Parent.Unequipped:Connect(function()
	if not destroying then
		if holdAnim then holdAnim:Stop() end
	end

	for _, v in pairs(hum:GetPlayingAnimationTracks()) do
		if v.Name == "Idle" then
			v:Stop()
		end
	end
end)

script.Parent.Destroying:Connect(function()
		holdAnim:Stop()
	
end)
