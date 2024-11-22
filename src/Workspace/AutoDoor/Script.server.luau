local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Debounce = false
local Door = script.Parent 
local DoorLeft = Door.Izquierda  
local DoorRight = Door.Derecha 
local VidrioLeft = DoorLeft.Vidrio 
local VidrioRight = DoorRight.Vidrio 

local ClosedPositionLeft = DoorLeft.CFrame
local ClosedPositionRight = DoorRight.CFrame
local ClosedPositionVidrioLeft = VidrioLeft.CFrame 
local ClosedPositionVidrioRight = VidrioRight.CFrame  

local OpenPositionLeft = ClosedPositionLeft * CFrame.new(-3, 0, 0)
local OpenPositionRight = ClosedPositionRight * CFrame.new(3, 0, 0)
local OpenPositionVidrioLeft = ClosedPositionVidrioLeft * CFrame.new(-3, 0, 0)
local OpenPositionVidrioRight = ClosedPositionVidrioRight * CFrame.new(3, 0, 0)

local TweenInfoOpenClose = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local function AbrirPuertica()
	local TweenOpenLeft = TweenService:Create(DoorLeft, TweenInfoOpenClose, {CFrame = OpenPositionLeft})
	local TweenOpenRight = TweenService:Create(DoorRight, TweenInfoOpenClose, {CFrame = OpenPositionRight})
	local TweenOpenVidrioLeft = TweenService:Create(VidrioLeft, TweenInfoOpenClose, {CFrame = OpenPositionVidrioLeft})
	local TweenOpenVidrioRight = TweenService:Create(VidrioRight, TweenInfoOpenClose, {CFrame = OpenPositionVidrioRight})

	TweenOpenLeft:Play()
	TweenOpenRight:Play()
	TweenOpenVidrioLeft:Play()
	TweenOpenVidrioRight:Play()
end

local function CerrarPuertica()
	local TweenCloseLeft = TweenService:Create(DoorLeft, TweenInfoOpenClose, {CFrame = ClosedPositionLeft})
	local TweenCloseRight = TweenService:Create(DoorRight, TweenInfoOpenClose, {CFrame = ClosedPositionRight})
	local TweenCloseVidrioLeft = TweenService:Create(VidrioLeft, TweenInfoOpenClose, {CFrame = ClosedPositionVidrioLeft})
	local TweenCloseVidrioRight = TweenService:Create(VidrioRight, TweenInfoOpenClose, {CFrame = ClosedPositionVidrioRight})

	TweenCloseLeft:Play()
	TweenCloseRight:Play()
	TweenCloseVidrioLeft:Play()
	TweenCloseVidrioRight:Play()
end

local function onTouched(Object)
	local character = Object.Parent
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then 
		if not Debounce then
			Debounce = true
			AbrirPuertica()
			task.wait(3) 
			CerrarPuertica()
			Debounce = false
		end
	end
end

workspace.AutoDoor.HitBox.Touched:Connect(onTouched)
workspace.AutoDoor.HitBox2.Touched:Connect(onTouched)
