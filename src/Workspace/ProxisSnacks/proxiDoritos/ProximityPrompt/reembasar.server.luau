local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaSnackReal"}
local Cantidad = game.Workspace.Stands.EstanteDoritos:FindFirstChild("Cantidad")
local estantedorito = workspace.Stands:WaitForChild("EstanteDoritos")

local function actualizarContador()
	local contadorGUI = workspace.Stands.EstanteDoritos.aviso.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(estantedorito.Cantidad.Value) .. "/10"
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

				if Cantidad then
					Cantidad.Value = 10
					actualizarContador()

			
				end
			end
		end
	end
end)
