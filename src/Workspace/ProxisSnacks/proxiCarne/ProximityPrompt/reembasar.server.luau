local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaSnackReal"}
local Cantidad = game.Workspace.Stands.EstanteriaCarne:FindFirstChild("CantidadCarne")
local cantidadgal = workspace.Stands:WaitForChild("EstanteriaCarne")

local function actualizarContador()
	local contadorGUI = workspace.Stands.EstanteriaCarne.aviso4.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadgal.CantidadCarne.Value) .. "/12"
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
					Cantidad.Value = 12
					actualizarContador()

			
				end
			end
		end
	end
end)
