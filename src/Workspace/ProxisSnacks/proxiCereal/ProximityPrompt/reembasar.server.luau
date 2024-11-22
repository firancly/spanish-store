local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaSnackReal"}
local cantidadpapel = workspace.Stands:WaitForChild("EstanteriaCereal")

local function actualizarContador()
	local contadorGUI = workspace.Stands.EstanteriaCereal.aviso2.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadpapel.CantidadCereal.Value) .. "/12"
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
				local CantidadVasos = game.Workspace.Stands.EstanteriaCereal:FindFirstChild("CantidadCereal")

				if CantidadVasos then
					CantidadVasos.Value = 12
					actualizarContador()

			
				end
			end
		end
	end
end)
