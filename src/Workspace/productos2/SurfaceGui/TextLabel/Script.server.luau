local textLabel = script.Parent
local productos = script.Parent.Parent.Parent 
local numValue = productos:WaitForChild("Num") 

local function updateTextLabel()
	textLabel.Text = tostring(numValue.Value)
end

numValue.Changed:Connect(updateTextLabel)

updateTextLabel()
