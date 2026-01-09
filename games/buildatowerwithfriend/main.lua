-- Direitos de Notty0001
local success, Library = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/Nottyzada/nottyhub/refs/heads/main/assets/visual.lua"))()
end)

if not success or not Library then
	warn("Erro ao carregar o Core do GitHub: " .. tostring(Library))
	local rs = game:GetService("ReplicatedStorage"):FindFirstChild("HubPadrao")
	if rs then
		Library = require(rs)
	else
		error("Nao foi possivel carregar a Library. Verifique o link do GitHub ou o arquivo local.")
	end
end

-- Carregar o módulo de AutoFarm CORRETAMENTE
local AutoFarmModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nottyzada/nottyhub/refs/heads/main/modules/autofarm.lua"))()

local MarketPlaceService = game:GetService("MarketplaceService")
local placeName = MarketPlaceService:GetProductInfo(game.PlaceId).Name

Library:SetTitle(placeName)

local function TeleportToTower()
end

local function CollectRewards()
end

local function ResetCharacter()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	if player.Character then
		player.Character:BreakJoints()
	end
end

local AutoFarmTab = Library:CreateTab("AutoFarm", false, "rbxassetid://123456789")
AutoFarmTab:AddSection("Controles de AutoFarm")

-- Toggle para ligar/desligar o AutoFarm
AutoFarmTab:AddToggle("Ativar AutoFarm", "autofarm_enabled", function(state)
	if state then
		AutoFarmModule:Start()
	else
		AutoFarmModule:Stop()
	end
end)

AutoFarmTab:AddKeybind("Atalho AutoFarm", "autofarm_keybind", function()
	local currentState = AutoFarmModule.Enabled or false
	if not currentState then
		AutoFarmModule:Start()
	else
		AutoFarmModule:Stop()
	end
end)

AutoFarmTab:AddSlider("Velocidade de Farm", 1, 100, 50, function(value)
	if AutoFarmModule.UpdateSpeed then
		AutoFarmModule:UpdateSpeed(value)
	end
end)

local TeleportTab = Library:CreateTab("Teleportes", false, "rbxassetid://123456789")
TeleportTab:AddSection("Locais")

TeleportTab:AddButton("Teleportar para Torre", function()
	TeleportToTower()
end)

local UtilsTab = Library:CreateTab("Utilidades", false, "rbxassetid://123456789")
UtilsTab:AddSection("Ações Diversas")

UtilsTab:AddButton("Coletar Recompensas", function()
	CollectRewards()
end)

UtilsTab:AddButton("Resetar Personagem", function()
	ResetCharacter()
end)

Library:Init()
Library:Notify("AutoFarm", "Script e Módulo Remoto carregados!", 5)