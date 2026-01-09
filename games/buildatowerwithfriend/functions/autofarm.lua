--Direitos de Notty0001
local AutoFarm = {}

local KickStone = game.ReplicatedStorage:WaitForChild("KickStone")
local RunService = game:GetService("RunService")

AutoFarm.Enabled = false
AutoFarm.Speed = 50
local farmConnection = nil

local function Log(msg)
	print("[AutoFarm Logic]: " .. tostring(msg))
end

function AutoFarm:Start()
	if farmConnection then farmConnection:Disconnect() end
	Log("Iniciando loop de mineracao...")

	farmConnection = RunService.Heartbeat:Connect(function()
		if self.Enabled then
			pcall(function()
				KickStone:InvokeServer(true)
				task.wait(1 / (self.Speed / 10))
				KickStone:InvokeServer(false)
			end)
		else
			self:Stop()
		end
	end)
end

function AutoFarm:Stop()
	Log("Parando loop de mineracao.")
	if farmConnection then
		farmConnection:Disconnect()
		farmConnection = nil
	end
	pcall(function() KickStone:InvokeServer(false) end)
end

function AutoFarm:SetEnabled(state)
	self.Enabled = state
	Log("Estado alterado para: " .. (state and "Ativado" or "Desativado"))
	if state then
		self:Start()
	else
		self:Stop()
	end
end

function AutoFarm:SetSpeed(value)
	self.Speed = value
	Log("Velocidade de farm alterada para: " .. value)
end

return AutoFarm
