local ServicioTween = game:GetService("TweenService")

local bisagra = script.Parent.Hinge
local prompt = script.Parent.Base.ProximityPrompt

local objetivoAbrir = {CFrame = bisagra.CFrame * CFrame.Angles(0, math.rad(-90), 0)}
local objetivoCerrar = {CFrame = bisagra.CFrame}

local informacionTween = TweenInfo.new(1)
local tweenAbrir = ServicioTween:Create(bisagra, informacionTween, objetivoAbrir)
local tweenCerrar = ServicioTween:Create(bisagra, informacionTween, objetivoCerrar)

local estaAbierto = false

prompt.Triggered:Connect(function()
	if estaAbierto then
		tweenCerrar:Play()
	else
		tweenAbrir:Play()
	end
	estaAbierto = not estaAbierto
end)
