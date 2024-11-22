local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaVariedadReal"}
local CantidadVasos = game.Workspace.Stands.EstanteriaJugo:FindFirstChild("CantidadJugo")
local cantidadjugo = workspace.Stands:WaitForChild("EstanteriaJugo")

local function actualizarContadorVaso()
	local contadorGUI = workspace.Stands.EstanteriaJugo.avisosnaple.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadjugo.CantidadJugo.Value) .. "/10"
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
					CantidadVasos.Value = 10
					actualizarContadorVaso()


				end
			end
		end
	end
end)
