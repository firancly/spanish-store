local computadora = script.Parent
local nombreEquipo = "EMPAQUETADOR"
local nombreHerramienta = "CajaVariedad"
local valor = script.Parent.Parent.Parent.Valor  
local cantidad = workspace:WaitForChild("CajaVariedad")
local estanteria = script.Parent.Parent.Parent  
local St = game:GetService("StarterGui")

local function actualizarContador()
	local contadorGUI = workspace.CajaVariedad:FindFirstChild("ui") and workspace.CajaVariedad.ui:FindFirstChild("SurfaceGui") and workspace.CajaVariedad.ui.SurfaceGui:FindFirstChild("TextLabel")
	if contadorGUI then
		contadorGUI.Text = tostring(cantidad.Valor.Value) .. "/6"
	end
end

local function actualizarCajasVisibles()
	local cajas = {
		estanteria:FindFirstChild("CajaPreparada1"),
		estanteria:FindFirstChild("CajaPreparada2"),
		estanteria:FindFirstChild("CajaPreparada3"),
		estanteria:FindFirstChild("CajaPreparada4"),
		estanteria:FindFirstChild("CajaPreparada5"),
		estanteria:FindFirstChild("CajaPreparada6")
	}

	for i, caja in ipairs(cajas) do
		if caja then
			caja.Transparency = (i > valor.Value) and 1 or 0
		end
	end
end

script.Parent.Triggered:Connect(function(jugador)
	if jugador.Team and jugador.Team.Name == nombreEquipo then
		local personaje = jugador.Character
		local toolToDuplicate = St:WaitForChild("CajaVariedadReal")

		if personaje then
			if valor.Value > 0 then
				valor.Value = valor.Value - 1
				local toolClone = toolToDuplicate:Clone()
				toolClone.Parent = jugador.Backpack

				actualizarContador()
				actualizarCajasVisibles()

		
			end
		end
	end
end)
