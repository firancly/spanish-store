 --[[
        👑 Yeicxb System © 👑
                 .     '     ,
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

        👑 Sistema por Yeicxb 👑
]]
local posiciones = workspace:WaitForChild("Posiciones") 
local isProcessing = false
local colaDeNPCs = {}
local npc = script.Parent
local pathfindingService = game:GetService("PathfindingService")
local cajero = workspace.CajeroHit
local hitq = workspace.PuertaPrincipal.HitBox2
local stands = workspace.Stands:GetChildren()
local listaDeCompras = {"Gaseosa"}
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





------------------------------------------------------------------------------------------------------


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
		print("No se pudo calcular un camino válido.")
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
			for i = 1, 8 do
				local posKey = "Pos" .. i 
				local pos = bools:FindFirstChild(posKey)

				if pos and not pos.Value then
					npc.HumanoidRootPart.CFrame = game.Workspace.Posiciones:FindFirstChild(posKey).CFrame
					pos.Value = true 


					break 
				end
			end
			wait(0.5) 
		else
			print("No se pudo calcular un camino válido.")
		end
	end
end




-------------------------------------------------------------------------
local replicatedStorage = game:GetService("ReplicatedStorage")
local itemsDuplicados = replicatedStorage:WaitForChild("itemsDuplicados")

local productosDuplicados = workspace:FindFirstChild("Productos")

local productosRecolectados = {}


local humanoid = npc:FindFirstChildOfClass("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local animacionCompra = Instance.new("Animation")
animacionCompra.AnimationId = "rbxassetid://115184381574114" 
local animTrack = animator:LoadAnimation(animacionCompra)




local function realizarCompra()
	for _, item in pairs(listaDeCompras) do
		for _, stand in pairs(stands) do
			local producto = stand:FindFirstChild(item)

			if producto then
				if stand.PrimaryPart then
					moverHacia(stand.PrimaryPart.Position)
					animTrack:Play()

					animTrack.Stopped:Wait()	

					if item == "Doritos" and cantidadDoritos.Cantidad.Value > 0 then
						cantidadDoritos.Cantidad.Value = cantidadDoritos.Cantidad.Value - 1 
						actualizarContador()  
					end
					if item == "Cereal" and cantidadcereal.CantidadCereal.Value > 0 then
						cantidadcereal.CantidadCereal.Value = cantidadcereal.CantidadCereal.Value - 1 
						actualizarContadorCereal()  
					end
					if item == "Takis" and cantidadpapitas.CantidadPapitas.Value > 0 then
						cantidadpapitas.CantidadPapitas.Value = cantidadpapitas.CantidadPapitas.Value - 1 
						actualizarContadorPapitas()  
					end
					if item == "Carne" and cantidadcarne.CantidadCarne.Value > 0 then
						cantidadcarne.CantidadCarne.Value = cantidadcarne.CantidadCarne.Value - 1 
						actualizarContadorCarne()  
					end
					if item == "Papel" and cantidadpapel.CantidadPapel.Value > 0 then
						cantidadpapel.CantidadPapel.Value = cantidadpapel.CantidadPapel.Value - 1 
						actualizarContadorPapel()  
					end
					if item == "Gaseosa" and neveragaseosa.CantidadGaseosas.Value > 0 then
						neveragaseosa.CantidadGaseosas.Value = neveragaseosa.CantidadGaseosas.Value - 1 
						actualizarContadorGaseosa()  
					end

					table.insert(productosRecolectados, item)
					producto:Destroy()
			
				end
				break
			end
		end
	end
end

------------------------------------------------------------------------
local function removerDeCola()
	valorCola.Value = 0
	game.Workspace.Bools.Cajero.Value = false

end

local productos = game.Workspace:FindFirstChild("productos")
local confirmarButton = game.Workspace.Caja.Pantalla.SurfaceGui.CONFIRM:FindFirstChild("confirmar")
local numValue = productos:FindFirstChild("Num")

local function actualizarYVerificarSalida()
	local salidaPosicion = workspace:FindFirstChild("PuertaPrincipal"):FindFirstChild("HitBox2")

	if salidaPosicion then
		removerDeCola()
		moverHacia(salidaPosicion.Position)
		npc:Destroy()
	end
end




local function moverProductosAlCajero()
	local offset = Vector3.new(0.4, 0, 0)
	local contador = 0

	for _, item in pairs(productosRecolectados) do
		local productoDuplicado = itemsDuplicados:FindFirstChild(item)
		if productoDuplicado then
			local productosDuplicados2 = workspace:FindFirstChild("productos")
			local remote = game.ReplicatedStorage.Confirmar

			local productoClonado = productoDuplicado:Clone()
			productoClonado.Parent = productosDuplicados2

			productoClonado.Position = productosDuplicados2.Position + offset * contador
			productoClonado.Name = item 

			local numValue = productosDuplicados2:FindFirstChild("Num")
			if numValue then
				numValue.Value = numValue.Value + 1 

				numValue.Changed:Connect(function()

				end)
				remote.OnServerEvent:Connect(function()
					local bools = game.Workspace.Bools 
					if 	bools.Cajero.Value == true then
						actualizarYVerificarSalida()

					end


				end)


			end

			contador = contador + 1
		end
	end
end

local function agregarACola()

	valorCola.Value = 1  
	moverHacia2(cajero.Position)
	npc.HumanoidRootPart.CFrame = CFrame.new(npc.HumanoidRootPart.Position, npc.HumanoidRootPart.Position + Vector3.new(0, 0, -1))
	task.wait(1)

	moverProductosAlCajero()

end

local function esperarHastaQueEsteDisponible()
	while valorCola.Value > 0 do
		wait(0.5)
	end

	agregarACola()

end



--------------------------------------------------

local function comprarEnTienda()


	moverHacia2(hitq.Position)
	task.wait(0.1)

	realizarCompra()
	task.wait(0.1)
	moverHaciaCajero(cajero.Position)
	task.wait(0.1)

	esperarHastaQueEsteDisponible()
	task.wait(0.1)


end


comprarEnTienda()