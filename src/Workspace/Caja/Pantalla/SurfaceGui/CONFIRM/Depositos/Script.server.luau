local UInueva = script.Parent.Parent.Parent.FrameDepositos
local ui2 = script.Parent.Parent.Parent.Frame
local confirmarButton = script.Parent
local UI = script.Parent.Parent
local uiboton = script.Parent.Parent.Parent.CONFIRMDEPOSITOS


confirmarButton.MouseButton1Click:Connect(function()

UI.Visible = false
ui2.Visible = false
UInueva.Visible = true
uiboton.Visible = true

end)