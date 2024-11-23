local surfaceGui = script.Parent.Parent.Parent.Frame
local confirmarButton = script.Parent
local productos = game.Workspace:FindFirstChild("Caja")
local numValue = productos:FindFirstChild("BancoSeleccionado")
local despachao = game.Workspace.Caja:WaitForChild("Despachado")

local cooldownTime = 2
local isCooldown = false
local FRAMEDEPOS = script.Parent.Parent.Parent.FrameDepositos
local products = game.Workspace.productSpot1

confirmarButton.MouseButton1Click:Connect(function()
	if isCooldown then
		return
	end

	isCooldown = true

	local bancoSeleccionado = numValue.Value
	local bancoValido = false

	if bancoSeleccionado == "Banco Nacional" and FRAMEDEPOS["Banco Nacional"].UIStroke.Enabled == true then
		bancoValido = true
		despachao.Value = true
		for _, child in ipairs(products:GetChildren()) do
			if child:IsA("BasePart") then
				child:Destroy()
			end
		end
		for _, jugador in ipairs(game.Players:GetPlayers()) do
			local oxxo = jugador:FindFirstChild("leaderstats") and jugador.leaderstats:FindFirstChild("OXXO")
			if oxxo then
				oxxo.Value = oxxo.Value + 50
			end
		end
	elseif bancoSeleccionado == "Banxico" and FRAMEDEPOS["Banxico"].UIStroke.Enabled == true then
		bancoValido = true
		despachao.Value = true
		for _, jugador in ipairs(game.Players:GetPlayers()) do
			local oxxo = jugador:FindFirstChild("leaderstats") and jugador.leaderstats:FindFirstChild("OXXO")
			if oxxo then
				oxxo.Value = oxxo.Value + 50
			end
		end
		for _, child in ipairs(products:GetChildren()) do
			if child:IsA("BasePart") then
				child:Destroy()
			end
		end
	end

	if bancoValido then
		numValue.Value = ""
		confirmarButton.Text = "PROCESANDO..."
		wait(2)
		confirmarButton.Text = "CONFIRMAR"
	else
		confirmarButton.Text = "BANCO EQUIVOCADO"
		local npc = game.Workspace:FindFirstChild("Depositos")
		if npc then
			local grosero = npc:FindFirstChild("Grosero")
			grosero.Value = true
			wait(0.8)
			despachao.Value = true
		end
		wait(2)
		confirmarButton.Text = "CONFIRMAR"
	end

	wait(cooldownTime)
	isCooldown = false
end)
