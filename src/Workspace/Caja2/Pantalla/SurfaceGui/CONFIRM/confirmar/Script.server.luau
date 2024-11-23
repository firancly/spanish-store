local surfaceGui = script.Parent.Parent.Parent.Frame
local confirmarButton = script.Parent
local productos = game.Workspace:FindFirstChild("productSpot2")
local numValue = productos:FindFirstChild("Num")
local despachao = game.Workspace.Caja2:WaitForChild("Despachado")

local cooldownTime = 2
local isCooldown = false 
local idSonido = "rbxassetid://4612383453"
local sonido = Instance.new("Sound")
sonido.SoundId = idSonido  
sonido.Parent = script.Parent  

confirmarButton.MouseButton1Click:Connect(function()
	if isCooldown then
		return
	end

	isCooldown = true
	confirmarButton.Text = "Procesando..."

	if numValue.Value == 0 then
		local productosProcesados = 0
		for _, child in ipairs(surfaceGui:GetChildren()) do
			if child:IsA("TextLabel") and child.Name ~= "OXXO" then
				child:Destroy()
				productosProcesados = productosProcesados + 1  
				sonido:Play()
				despachao.Value = true
			end
		end

		--for _, jugador in ipairs(game.Players:GetPlayers()) do
		--	local oxxo = jugador.leaderstats and jugador.leaderstats:FindFirstChild("OXXO")
		--	if oxxo then
		--		oxxo.Value = oxxo.Value + (productosProcesados * 10) 
		--	end
		--end

	else
		confirmarButton.Text = "NO SE HAN PROCESADO TODOS LOS PRODUCTOS"
		wait(2)
		confirmarButton.Text = "CONFIRMAR"
	end

	wait(cooldownTime)
	isCooldown = false
	confirmarButton.Text = "CONFIRMAR"
end)