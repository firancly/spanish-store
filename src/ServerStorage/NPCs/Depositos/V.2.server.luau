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
local posiciones = workspace:WaitForChild("Posiciones") 
local isProcessing = false
local colaDeNPCs = {}
local npc = script.Parent
local pathfindingService = game:GetService("PathfindingService")
local cajero = workspace.CajeroHit
local hitq = workspace.PuertaPrincipal.HitBox2
local stands = workspace.Stands:GetChildren()
local bancos = {"Banco Nacional", "Banco Central", "Banxico"}
local grosero = script.Parent:WaitForChild("Grosero")  

local insultos = {
	"Chinga tu 🤬!",
	"¡Estás bien tontin!😤",
	"¡Eres un 😡!",
	"¡Pinche lelo!"
}

-----------------------------------------------------------------------------

local listaDeCompras = "Deposito"

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

local EstanteDeposito = workspace.Stands:WaitForChild("EstanteriaDinero")
local bancoSeleccionado = ""

------------------------------------------------------------------------------------------------------

local function anunciarBancoEnChat()
	bancoSeleccionado = bancos[math.random(1, #bancos)]
	game:GetService("Chat"):Chat(npc.Head, "Banco: " .. bancoSeleccionado)
	local bancoSeleccionadoValue = workspace.Caja:FindFirstChild("BancoSeleccionado")
	if bancoSeleccionadoValue then
		bancoSeleccionadoValue.Value = bancoSeleccionado

	end
end
local function decirInsulto()
	local insultoAleatorio = insultos[math.random(1, #insultos)]  
	game:GetService("Chat"):Chat(npc.Head, insultoAleatorio)  
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
	
	end
end


local function removerDeCola()
	valorCola.Value = 0
	game.Workspace.Bools.Cajero.Value = false

end



local itemsDuplicados = game.ReplicatedStorage:WaitForChild("itemsDuplicados")

local productos = game.Workspace:FindFirstChild("productos")
local confirmarButton = game.Workspace.Caja.Pantalla.SurfaceGui.CONFIRM:FindFirstChild("confirmar")
local numValue = productos:FindFirstChild("Num")
local despachao = game.Workspace.Caja:WaitForChild("Despachado")

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
	local offset = Vector3.new(0.8, 0, 0) 
	local productosDuplicados2 = workspace:FindFirstChild("productos") 
	local numValue = productosDuplicados2:FindFirstChild("Num")
	local contador = 0

	local productoBase = itemsDuplicados:FindFirstChild("Deposito")  

	if productoBase then
		for i = 1, 1 do  
			local productoClonado = productoBase:Clone()
			productoClonado.Parent = productosDuplicados2
			productoClonado.Position = productosDuplicados2.Position + offset * contador
			productoClonado.Name = "Deposito"

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
	while valorCola.Value > 0 do
		wait(0.5)
	end

	agregarACola()

end

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
		anunciarBancoEnChat()


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
		
		end
	end
	esperarHastaQueEsteDisponible()
end

-------------------------------------------------------------------------
local replicatedStorage = game:GetService("ReplicatedStorage")

local productosDuplicados = workspace:FindFirstChild("Productos")

local productosRecolectados = {}
local humanoid = npc:FindFirstChildOfClass("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local animacionCompra = Instance.new("Animation")
animacionCompra.AnimationId = "rbxassetid://115184381574114" 
local animTrack = animator:LoadAnimation(animacionCompra)


------------------------------------------------------------------------
local function realizarCompra()
	for _, stand in ipairs(stands) do
		local producto = stand:FindFirstChild("Deposito")

		if producto and stand.PrimaryPart then
			moverHacia(stand.PrimaryPart.Position)

			animTrack:Play()
			animTrack.Stopped:Wait() 

			producto:Destroy()
			break 
		end
	end
end
grosero.Changed:Connect(function()
	if grosero.Value then  
		decirInsulto() 
		despachao.Value = true
		actualizarYVerificarSalida()

		grosero.Value = false  
	end
end)

--------------------------------------------------

local function comprarEnTienda()


	moverHacia2(hitq.Position)
	task.wait(0.1)

	realizarCompra()
	task.wait(0.1)
	moverHaciaCajero(cajero.Position)
	task.wait(0.1)

	


end


comprarEnTienda()