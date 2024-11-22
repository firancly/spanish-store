local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")

local Settings = require(ReplicatedStorage:WaitForChild("Paycheck"):WaitForChild("Settings"))

local Main = script.Parent.Parent.Interface.Main
local Information = Main.Information
local Amount = Main.Amount
local Evento_Notificacion = ReplicatedStorage:WaitForChild("Global_Events"):WaitForChild("Notification_Event")

local Debounce = false

local function AddComma(Int)
	local Left, Num, Right = string.match(Int, "^(%D*%d)(%d*)(.-)$")
	return Left .. Num:reverse():gsub("(%d%d%d)", "%1,"):reverse() .. Right
end

local function TypeWrite(Object, Text)
	for i = 1, #Text, 1 do
		Object.Text = string.sub(Text, 1, i)
		wait(0.06)
	end
end

local function Setup()
	Main:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Linear", 0.5, true)
	Main.BankName.Text = Settings.Paycheck_Config.Bank_Name
	Main.CodeText.Text = math.random(100, 999)
	Information.Background.PlayerName.Text = Player.Name
	Debounce = false 
end

local function Exit()
	if not Debounce then
		Debounce = true
		TypeWrite(Main.Signed, Player.Name)
		task.wait(0.5)
		Main:TweenPosition(UDim2.new(0.5, 0, -0.2, 0), "Out", "Linear", 0.5, true)
	end
end

-- // Cheque functions
local function ProcessPaycheck(amount, reason)
	Information.Background.Reason.Text = reason
	local sueldoValue = Player:WaitForChild("leaderstats"):WaitForChild("Sueldo")
	Amount.Background.Amount.Text = AddComma(amount) .. ".00"
	sueldoValue.Value = sueldoValue.Value + amount
end

local function Regular_Paycheck()
	local amount = Settings.Paycheck_Config.Regular_Paycheck
	if Settings.Paycheck_Config.Gamepass_Enabled and MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Settings.Paycheck_Config.Gamepass_Id) then
		amount *= Settings.Paycheck_Config.Gamepass_Multiplier
	end
	ProcessPaycheck(amount, Settings.Paycheck_Config.Regular_Reason)
end
Evento_Notificacion.OnClientEvent:Connect(function(mensaje, duracion, color)
	Regular_Paycheck()

	Setup() 
end)
local function Increased_Paycheck()
	local amount = Settings.Paycheck_Config.Increased_Paycheck
	if Settings.Paycheck_Config.Gamepass_Enabled and MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Settings.Paycheck_Config.Gamepass_Id) then
		amount *= Settings.Paycheck_Config.Gamepass_Multiplier
	end
	ProcessPaycheck(amount, Settings.Paycheck_Config.Increased_Reason)
end



Main.WithdrawButton.MouseButton1Click:Connect(function()
	Exit()

end)
