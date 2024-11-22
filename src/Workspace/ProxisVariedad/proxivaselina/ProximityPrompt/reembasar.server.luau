local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaVariedadReal"}
local CantidadVasos = game.Workspace.Stands.EstanteriaVaselina:FindFirstChild("CantidadVase")
local cantidadvase = workspace.Stands:WaitForChild("EstanteriaVaselina")

local function actualizarContadorVaso()
	local contadorGUI = workspace.Stands.EstanteriaVaselina.avisovase.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadvase.CantidadVase.Value) .. "/25"
	end
end

script.Parent.Triggered:Connect(function(jugador)
	if jugador.Team and jugador.Team.Name == nombreEquipo then
		local personaje = jugador.Character
		if personaje then
			local herramientaEnMano = nil
			for _, nombre in ipairs(nombresHerramienta) do
				herramientaEnMano = personaje:FindFirstChild(nombre)
				if herramientaEnMano then
					break
				end
			end

			if herramientaEnMano then
				herramientaEnMano:Destroy()

				if CantidadVasos then
					CantidadVasos.Value = 25
					actualizarContadorVaso()

			
				end
			end
		end
	end
end)
