local computadora = script.Parent
local nombreEquipo = "EMPAQUETADOR"
local nombresHerramienta = {"CajaCongelada", "CajaCongeladaReal"} 
local valor = script.Parent.Parent.Parent.Valor  
local cantidad = workspace:WaitForChild("CajaRefri")
local estanteria = script.Parent.Parent.Parent  

local function actualizarContador()
	local contadorGUI = workspace.CajaRefri["ui"].SurfaceGui.TextLabel  
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
			caja.Transparency = (i <= cantidad.Valor.Value) and 0 or 1
		end
	end
end

local function reiniciarAnimaciones(jugador)
	local personaje = jugador.Character
	if personaje then
		local humanoid = personaje:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local animator = humanoid:FindFirstChildOfClass("Animator")
			if animator then
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					track:Stop()
				end
			end
		end
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

				valor.Value = valor.Value + 1

				actualizarCajasVisibles()  
				actualizarContador()  

				reiniciarAnimaciones(jugador)
			end
		end
	end
end)
