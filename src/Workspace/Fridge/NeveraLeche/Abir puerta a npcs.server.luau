
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
 
local ServicioTween = game:GetService("TweenService")
local bisagra = script.Parent.Hinge
local puerta = script.Parent.Base
local hitbox = script.Parent.HitBox  

local objetivoAbrir = {CFrame = bisagra.CFrame * CFrame.Angles(0, math.rad(-90), 0)}
local objetivoCerrar = {CFrame = bisagra.CFrame}
local informacionTween = TweenInfo.new(1)
local tweenAbrir = ServicioTween:Create(bisagra, informacionTween, objetivoAbrir)
local tweenCerrar = ServicioTween:Create(bisagra, informacionTween, objetivoCerrar)

local estaAbierto = false
local tiempoCierre = 5
local temporizador

local function alternarPuerta(abrir)
	if abrir then
		tweenAbrir:Play()
	else
		tweenCerrar:Play()
	end
	estaAbierto = abrir
end

local function iniciarContadorCierre()
	if temporizador then
		temporizador:Disconnect()
	end
	temporizador = game:GetService("RunService").Heartbeat:Connect(function()
		if tick() - tiempoUltimaEntrada > tiempoCierre then
			alternarPuerta(false) 
			temporizador:Disconnect()
		end
	end)
end

hitbox.Touched:Connect(function(hit)
	local character = hit.Parent
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid and not game.Players:GetPlayerFromCharacter(character) then
		if not estaAbierto then
			alternarPuerta(true)  
		end
		tiempoUltimaEntrada = tick()  
		iniciarContadorCierre() 
	end
end)
