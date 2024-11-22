 --[[
         Yeicxb System 
                 .     '     
              _________
           _ /_|_____|_\ _
             '. \   / .'
               '.\ /.'
                 '.'

            ///////////\\
           ////       \\\\
          ////         \\\\
         ////___________\\\\
        '"""""""""""""""""'

         Sistema por Yeicxb
]]

local productosRecolectados = {}

local posiciones = workspace:WaitForChild("Posiciones") 
local isProcessing = false
local colaDeNPCs = {}
local npc = script.Parent
local pathfindingService = game:GetService("PathfindingService")
local cajero = workspace.CajeroHit
local hitq = workspace.PuertaPrincipal.HitBox2
local stands = workspace.Stands:GetChildren()
local itemsDuplicados = game.ReplicatedStorage:WaitForChild("itemsDuplicados")

-----------------------------------------------------------------------------
local productosDisponibles = {
	"Desodorante", "Galon", "Vasitos", "Papel", "Bebida", 
	"Gaseosa", "Prime", "Takis", "Cereal", "Doritos", 
	"Carne", "Tarjetas" , "Snapple" , "Nutrileche", 
	"fiji" , "Oreo" , "Vaselina" , "chips"
}

local function asignarProductosAleatorios()
	local cantidadDeProductos = math.random(1, 5) 
	local productosAsignados = {}

	while #productosAsignados < cantidadDeProductos do
		local productoAleatorio = productosDisponibles[math.random(1, #productosDisponibles)]

		if not table.find(productosAsignados, productoAleatorio) then
			table.insert(productosAsignados, productoAleatorio)
		end
	end

	if #productosAsignados == 0 then
		local productoAleatorio = productosDisponibles[math.random(1, #productosDisponibles)]
		table.insert(productosAsignados, productoAleatorio)
	end

	return productosAsignados
end

local listaDeCompras = asignarProductosAleatorios()

---------------------------------------------------------------------


local tiendaAbierta = true
local humanoid = npc:FindFirstChildOfClass("Humanoid")

-----------------------------------------------------------------


local walkAnim = Instance.new("Animation")
local walkingAnimId = "rbxassetid://107953179942800"
walkAnim.AnimationId = walkingAnimId
local walkAnimTrack = humanoid:LoadAnimation(walkAnim)
humanoid.WalkSpeed = 8
local caja = workspace:WaitForChild("Caja")
local valorCola = caja:WaitForChild("Cola")
-------------------------------------------------------------------
local physicsService = game:GetService('PhysicsService')

local groupNameNPC = "NPCs"
local groupNameProtecciones = "protecciones"
local groupNameVidrio = "Vidrios"

local successNPC, collisionGroupIdNPC = pcall(function()
	return physicsService:GetCollisionGroupId(groupNameNPC)
end)

if not successNPC then
	physicsService:CreateCollisionGroup(groupNameNPC)
end

local successProtecciones, collisionGroupIdProtecciones = pcall(function()
	return physicsService:GetCollisionGroupId(groupNameProtecciones)
end)

if not successProtecciones then
	physicsService:CreateCollisionGroup(groupNameProtecciones)
end

local successVidrio, collisionGroupIdVidrio = pcall(function()
	return physicsService:GetCollisionGroupId(groupNameVidrio)
end)

if not successVidrio then
	physicsService:CreateCollisionGroup(groupNameVidrio)
end

physicsService:CollisionGroupSetCollidable(groupNameNPC, 'Default', false)
physicsService:CollisionGroupSetCollidable(groupNameNPC, groupNameNPC, false)
physicsService:CollisionGroupSetCollidable(groupNameNPC, groupNameProtecciones, true)
physicsService:CollisionGroupSetCollidable(groupNameNPC, groupNameVidrio, false) 

local function setNPCCollisionGroup(npc)
	for _, part in ipairs(npc:GetDescendants()) do
		if part:IsA('BasePart') and part.Name ~= "HumanoidRootPart" then
			physicsService:SetPartCollisionGroup(part, groupNameNPC)
		end
	end
end

setNPCCollisionGroup(npc)

local function setProteccionesCollisionGroup()
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA('BasePart') and part.Name == "protecciones" then
			physicsService:SetPartCollisionGroup(part, groupNameProtecciones)
		end
	end
end

setProteccionesCollisionGroup()

local function setVidrioCollisionGroup()
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA('BasePart') and part.Name == "Vidrio" then
			physicsService:SetPartCollisionGroup(part, groupNameVidrio)
		end
	end
end

setVidrioCollisionGroup()



----------------------------------------------------------------------

local cantidadDoritos = workspace.Stands:WaitForChild("EstanteDoritos")
local cantidadcereal = workspace.Stands:WaitForChild("EstanteriaCereal")
local cantidadpapitas = workspace.Stands:WaitForChild("EstanteriaPapitas")
local cantidadcarne = workspace.Stands:WaitForChild("EstanteriaCarne")
local cantidadpapel = workspace.Stands:WaitForChild("EstanteriaPapel")
local neveragaseosa = workspace.Stands:WaitForChild("NeveraGaseosa")
local neveraprime = workspace.Stands:WaitForChild("NeveraPrime")
local cantidadvasos = workspace.Stands:WaitForChild("EstanteriaVasos")
local cantidadgalones = workspace.Stands:WaitForChild("EstanteriaGalones")
local cantidaddeso = workspace.Stands:WaitForChild("EstanteriaDesodorante")
local cantidadvariedad = workspace.Stands:WaitForChild("NeveraVariedad")
local cantidadtarjeta = workspace.Stands:WaitForChild("EstanteriaTarjetas")

local cantidadfiji = workspace.Stands:WaitForChild("NeveraAgua")
local cantidadleche =  workspace.Stands:WaitForChild("NeveraLeche")

local cantidadsnaple =  workspace.Stands:WaitForChild("EstanteriaJugo")
local cantidadvase =  workspace.Stands:WaitForChild("EstanteriaVaselina")
local cantidadOreo =  workspace.Stands:WaitForChild("EstanteriaOreo")

local cantidadchips = workspace.Stands:WaitForChild("EstanteriaChips")




------------------------------------------------------------------------------------------------------


local function actualizarContador()
	local contadorDoritosGUI = workspace.Stands.EstanteDoritos.aviso.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadDoritos.Cantidad.Value) .. "/10"
	end
end

local function actualizarContadorCereal()
	local contadorDoritosGUI = workspace.Stands.EstanteriaCereal.aviso2.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadcereal.CantidadCereal.Value) .. "/12"
	end
end

local function actualizarContadorPapitas()
	local contadorDoritosGUI = workspace.Stands.EstanteriaPapitas.aviso3.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadpapitas.CantidadPapitas.Value) .. "/15"
	end
end

local function actualizarContadorCarne()
	local contadorDoritosGUI = workspace.Stands.EstanteriaCarne.aviso4.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadcarne.CantidadCarne.Value) .. "/12"
	end
end

local function actualizarContadorPapel()
	local contadorDoritosGUI = workspace.Stands.EstanteriaPapel.aviso5.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadpapel.CantidadPapel.Value) .. "/20"
	end
end
local function actualizarContadorGaseosa()
	local contadorDoritosGUI = workspace.Stands.NeveraGaseosa.aviso6.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(neveragaseosa.CantidadGaseosas.Value) .. "/36"
	end
end
local function actualizarContadorvasitos()
	local contadorDoritosGUI = workspace.Stands.EstanteriaVasos.aviso7.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadvasos.CantidadVasos.Value) .. "/24"
	end
end
local function actualizarContadoPrime()
	local contadorDoritosGUI = workspace.Stands.NeveraPrime.aviso8.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(neveraprime.CantidadPrime.Value) .. "/36"
	end
end

local function actualizarContadorGalones()
	local contadorDoritosGUI = workspace.Stands.EstanteriaGalones.aviso9.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadgalones.CantidadGalon.Value) .. "/20"
	end
end
local function actualizarContadorDeso()
	local contadorDoritosGUI = workspace.Stands.EstanteriaDesodorante.aviso10.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidaddeso.CantidadDeso.Value) .. "/36"
	end
end
local function actualizarContadorVariedad()
	local contadorDoritosGUI = workspace.Stands.NeveraVariedad.aviso11.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadvariedad.CantidadVariedad.Value) .. "/30"
	end
end

local function actualizarContadorTarjeta()
	local contadorDoritosGUI = workspace.Stands.EstanteriaTarjetas.aviso12.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadtarjeta.CantidadTarjeta.Value) .. "/5"
	end
end
local function actualizarContadorLeche()
	local contadorDoritosGUI = workspace.Stands.NeveraLeche.avisoleshe.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadleche.CantidadLeches.Value) .. "/12"
	end
end
local function actualizarContadorAgua()
	local contadorDoritosGUI = workspace.Stands.NeveraAgua.avisoagua.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadfiji.CantidadAgua.Value) .. "/15"
	end
end

local function actualizarContadorOreo()
	local contadorDoritosGUI = workspace.Stands.EstanteriaOreo.avisoorito.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadOreo.CantidadOreo.Value) .. "/12"
	end
end

local function actualizarContadorjugo()
	local contadorDoritosGUI = workspace.Stands.EstanteriaJugo.avisosnaple.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadsnaple.CantidadJugo.Value) .. "/10"
	end
end
local function actualizarContadorVaselina()
	local contadorDoritosGUI = workspace.Stands.EstanteriaVaselina.avisovase.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadvase.CantidadVase.Value) .. "/25"
	end
end


local function actualizarContadorChips()
	local contadorDoritosGUI = workspace.Stands.EstanteriaChips.avisochips.SurfaceGui.TextLabel  
	if contadorDoritosGUI then
		contadorDoritosGUI.Text = tostring(cantidadchips.CantidadChip.Value) .. "/20"
	end
end





------------------------------------------------------------------------------------------------------
local productos = game.Workspace:FindFirstChild("productos")
local confirmarButton = game.Workspace.Caja.Pantalla.SurfaceGui.CONFIRM:FindFirstChild("confirmar")
local numValue = productos:FindFirstChild("Num")
local despachao = game.Workspace.Caja:WaitForChild("Despachado")
local function removerDeCola()
	valorCola.Value = 0
	game.Workspace.Bools.Cajero.Value = false

end



local function moverHacia2(posicion)
	local path = pathfindingService:CreatePath({
		AgentRadius = 1,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45,
	})

	path:ComputeAsync(npc.HumanoidRootPart.Position, posicion)

	if humanoid then
		walkAnimTrack:Play()
	end

	humanoid:MoveTo(posicion)

	humanoid.MoveToFinished:Wait()

	walkAnimTrack:Stop()
end

local function moverHacia(posicion)
	local path = pathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45,
	})

	path:ComputeAsync(npc.HumanoidRootPart.Position, posicion)

	if path.Status == Enum.PathStatus.Success then
		if humanoid then
			walkAnimTrack:Play()
		end

		local waypoints = path:GetWaypoints()
		for _, waypoint in ipairs(waypoints) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end

		walkAnimTrack:Stop()
	else
		print("No se pudo calcular un camino valido.")
	end
end



local function actualizarYVerificarSalida()
	despachao.Changed:Connect(function()
		if despachao.Value then
			local salidaPosicion = workspace:FindFirstChild("PuertaPrincipal"):FindFirstChild("HitBox2")

			if salidaPosicion then
				despachao.Value = false
				removerDeCola()
				moverHacia(salidaPosicion.Position)
				npc:Destroy()
			end
		end
	end)
end






local function moverProductosAlCajero()
	local offset = Vector3.new(0.4, 0, 0)
	local contador = 0

	for _, item in pairs(productosRecolectados) do
		local productosDuplicados = itemsDuplicados:GetChildren() 
		local productosConNombreIgual = {}

		for _, producto in pairs(productosDuplicados) do
			if producto.Name == item then
				table.insert(productosConNombreIgual, producto)
			end
		end

		if #productosConNombreIgual > 0 then
			local productoSeleccionado = productosConNombreIgual[math.random(1, #productosConNombreIgual)]
			local productoClonado = productoSeleccionado:Clone()
			local productosDuplicados2 = workspace:FindFirstChild("productos")
			local remote = game.ReplicatedStorage.Confirmar

			productoClonado.Parent = productosDuplicados2
			productoClonado.Position = productosDuplicados2.Position + offset * contador
			productoClonado.Name = item

			local numValue = productosDuplicados2:FindFirstChild("Num")
			if numValue then
				numValue.Value = numValue.Value + 1

				numValue.Changed:Connect(function()
					actualizarYVerificarSalida()
				end)
			end

			contador = contador + 1
		end
	end
end

----------------------------------------------------------------------
local function agregarACola()

	valorCola.Value = 1  
	moverHacia2(cajero.Position)
	npc.HumanoidRootPart.CFrame = CFrame.new(npc.HumanoidRootPart.Position, npc.HumanoidRootPart.Position + Vector3.new(0, 0, -1))
	task.wait(1)

	moverProductosAlCajero()

end

local function esperarHastaQueEsteDisponible()
	if valorCola.Value > 0 then
		local connection
		connection = valorCola:GetPropertyChangedSignal("Value"):Connect(function()
			if valorCola.Value == 0 then
				connection:Disconnect() 
				agregarACola()
			end
		end)
	else
		agregarACola()
	end
end
----------------------------------------------------------------------



local function moverHaciaCajero(posicion)
	local path = pathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45,
	})

	path:ComputeAsync(npc.HumanoidRootPart.Position, posicion)

	if path.Status == Enum.PathStatus.Success then
		if humanoid then
			walkAnimTrack:Play()
		end

		local waypoints = path:GetWaypoints()
		for _, waypoint in ipairs(waypoints) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end

		walkAnimTrack:Stop()
		wait(0.1)
		local bools = game.Workspace.Bools
		bools.Cajero.Value = true

		if valorCola.Value == 1 then
			for i = 1, 7 do
				local posKey = "Pos" .. i
				local pos = bools:FindFirstChild(posKey)

				if pos and not pos.Value then
					npc.HumanoidRootPart.CFrame = game.Workspace.Posiciones:FindFirstChild(posKey).CFrame
					pos.Value = true

					local initialPosition = npc.HumanoidRootPart.Position
					local connection
					connection = game:GetService("RunService").Heartbeat:Connect(function()
						if (npc.HumanoidRootPart.Position - initialPosition).Magnitude > 1 then
							pos.Value = false
							connection:Disconnect()  
						end
					end)

					break
				end
			end

			wait(0.5)
			
		end
	end
	esperarHastaQueEsteDisponible()

end


-------------------------------------------------------------------------
local replicatedStorage = game:GetService("ReplicatedStorage")

local productosDuplicados = workspace:FindFirstChild("Productos")

local humanoid = npc:FindFirstChildOfClass("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local animacionCompra = Instance.new("Animation")
animacionCompra.AnimationId = "rbxassetid://115184381574114" 
local animTrack = animator:LoadAnimation(animacionCompra)



local function realizarCompra()
	local itemsConfig = {
		Doritos = { cantidad = cantidadDoritos.Cantidad, actualizar = actualizarContador },
		Cereal = { cantidad = cantidadcereal.CantidadCereal, actualizar = actualizarContadorCereal },
		Takis = { cantidad = cantidadpapitas.CantidadPapitas, actualizar = actualizarContadorPapitas },
		Carne = { cantidad = cantidadcarne.CantidadCarne, actualizar = actualizarContadorCarne },
		Papel = { cantidad = cantidadpapel.CantidadPapel, actualizar = actualizarContadorPapel },
		Gaseosa = { cantidad = neveragaseosa.CantidadGaseosas, actualizar = actualizarContadorGaseosa },
		Prime = { cantidad = neveraprime.CantidadPrime, actualizar = actualizarContadoPrime },
		Vasitos = { cantidad = cantidadvasos.CantidadVasos, actualizar = actualizarContadorvasitos },
		Galon = { cantidad = cantidadgalones.CantidadGalon, actualizar = actualizarContadorGalones },
		Desodorante = { cantidad = cantidaddeso.CantidadDeso, actualizar = actualizarContadorDeso },
		Bebida = { cantidad = cantidadvariedad.CantidadVariedad, actualizar = actualizarContadorVariedad },
		Tarjeta = { cantidad = cantidadtarjeta.CantidadTarjeta, actualizar = actualizarContadorTarjeta },
		fiji = { cantidad = cantidadfiji.CantidadAgua, actualizar = actualizarContadorAgua },
		Vaselina = { cantidad = cantidadvase.CantidadVase, actualizar = actualizarContadorVaselina },
		Oreo = { cantidad = cantidadOreo.CantidadOreo, actualizar = actualizarContadorOreo },
		Nutrileche = { cantidad = cantidadleche.CantidadLeches, actualizar = actualizarContadorLeche },
		Snapple = { cantidad = cantidadsnaple.CantidadJugo, actualizar = actualizarContadorjugo },
		chips = { cantidad = cantidadchips.CantidadChip, actualizar = actualizarContadorChips },

	}

	for _, item in pairs(listaDeCompras) do
		for _, stand in pairs(stands) do
			local producto = stand:FindFirstChild(item)

			if producto and stand.PrimaryPart then
				moverHacia(stand.PrimaryPart.Position)
				animTrack:Play()
				animTrack.Stopped:Wait()

				local config = itemsConfig[item]
				if config and config.cantidad.Value > 0 then
					config.cantidad.Value = config.cantidad.Value - 1
					config.actualizar()
					table.insert(productosRecolectados, item)

					producto:Destroy()
				end
				break
			end
		end
	end

end

------------------------------------------------------------------------


local function comprarEnTienda()


	moverHacia2(hitq.Position)
	task.wait(0.1)

	realizarCompra()
	task.wait(0.5)
	moverHaciaCajero(cajero.Position)

	task.wait(0.1)
	

	


end


comprarEnTienda()