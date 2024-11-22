local UInueva = script.Parent.Parent.Parent.FrameDepositos
local ui2 = script.Parent.Parent.Parent.Frame
local confirmarButton = script.Parent
local UI = script.Parent.Parent.Parent.CONFIRM
local uiboton = script.Parent.Parent


confirmarButton.MouseButton1Click:Connect(function()

	UI.Visible = true
	ui2.Visible = true
	UInueva.Visible = false
	uiboton.Visible = false

end)