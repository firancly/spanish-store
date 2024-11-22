local frame = script.Parent  
local buttons = {frame["Banco Nacional"], frame["Banco Central"], frame.Banxico} 

local function activateButton(selectedButton)
	for _, button in ipairs(buttons) do
		local uiStroke = button:FindFirstChild("UIStroke")
		local boolValue = button:FindFirstChild("Activado")

		if button == selectedButton then
			if uiStroke then uiStroke.Enabled = true end
			if boolValue then boolValue.Value = true end
		else
			if uiStroke then uiStroke.Enabled = false end
			if boolValue then boolValue.Value = false end
		end
	end
end

for _, button in ipairs(buttons) do
	button.MouseButton1Click:Connect(function()
		activateButton(button)
	end)
end
