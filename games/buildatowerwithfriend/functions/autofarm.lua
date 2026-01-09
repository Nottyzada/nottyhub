--Direitos de Notty0001
local AutoFarm = {}

local KickStone = game.ReplicatedStorage:WaitForChild("KickStone")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

AutoFarm.Enabled = false
AutoFarm.Speed = 50
AutoFarm.StonePosition = Vector3.new(0, 0, 0) -- Posição padrão das pedras
local farmConnection = nil
local player = Players.LocalPlayer
local character = nil
local humanoidRootPart = nil

local function Log(msg)
	print("[AutoFarm Logic]: " .. tostring(msg))
end

local function getToolFromBackpack(toolName)
	if player and player.Backpack then
		for _, item in pairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") and item.Name:lower():find("pickaxe") then
				return item
			end
		end
	end
	return nil
end

local function equipPickaxe()
	if not character then
		character = player.Character or player.CharacterAdded:Wait()
	end
	
	-- Verifica se já está equipada
	for _, item in pairs(character:GetChildren()) do
		if item:IsA("Tool") and item.Name:lower():find("pickaxe") then
			return true
		end
	end
	
	-- Tenta pegar da mochila
	local pickaxe = getToolFromBackpack("pickaxe")
	if pickaxe then
		pcall(function()
			player.Character.Humanoid:EquipTool(pickaxe)
			Log("Picareta equipada: " .. pickaxe.Name)
			return true
		end)
	end
	
	return false
end

local function goToStoneLocation()
	if not character then
		character = player.Character or player.CharacterAdded:Wait()
	end
	
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")
	
	-- Encontra a posição das pedras
	local stones = Workspace:FindFirstChild("Stone")
	if stones then
		-- Pega a primeira pedra encontrada
		for _, stone in pairs(stones:GetChildren()) do
			if stone:IsA("BasePart") then
				AutoFarm.StonePosition = stone.Position
				break
			end
		end
		
		-- Move o personagem até as pedras
		humanoid:MoveTo(AutoFarm.StonePosition)
		
		-- Espera chegar perto
		local maxWaitTime = 5
		local startTime = tick()
		
		while (humanoidRootPart.Position - AutoFarm.StonePosition).Magnitude > 5 and tick() - startTime < maxWaitTime do
			RunService.Heartbeat:Wait()
		end
		
		-- Olha na direção das pedras
		if stones:GetChildren()[1] then
			local stone = stones:GetChildren()[1]
			if stone:IsA("BasePart") then
				-- Calcula direção para olhar
				local lookVector = (stone.Position - humanoidRootPart.Position).Unit
				humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, 
					humanoidRootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
				Log("Olhando para a pedra na posição: " .. tostring(stone.Position))
			end
		end
		
		return true
	end
	
	Log("Não foi encontrado Workspace.Stone")
	return false
end

function AutoFarm:Start()
	if farmConnection then farmConnection:Disconnect() end
	Log("Iniciando loop de mineracao...")
	
	-- Prepara o personagem
	character = player.Character or player.CharacterAdded:Wait()
	
	-- Tenta equipar a picareta
	if not equipPickaxe() then
		Log("Aviso: Nenhuma picareta encontrada na mochila!")
	end
	
	-- Vai até as pedras
	goToStoneLocation()
	
	farmConnection = RunService.Heartbeat:Connect(function()
		if self.Enabled then
			pcall(function()
				-- Verifica se ainda tem picareta equipada
				if not equipPickaxe() then
					Log("Picareta não encontrada! Parando farm...")
					self:SetEnabled(false)
					return
				end
				
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

-- Conecta eventos para quando o personagem morre/respaw
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	Log("Novo personagem detectado")
	if AutoFarm.Enabled then
		-- Espera um pouco e reconecta
		task.wait(2)
		if AutoFarm.Enabled then
			Log("Reiniciando farm após respawn...")
			self:Start()
		end
	end
end)

return AutoFarm