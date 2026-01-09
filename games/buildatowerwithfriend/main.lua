--Direitos de Notty0001
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

local successModule, AutoFarmModule = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/Nottyzada/nottyhub/refs/heads/main/games/buildatowerwithfriend/functions/autofarm.lua"))()
end)

if not successModule or not AutoFarmModule then
	error("Falha ao carregar o modulo de AutoFarm: " .. tostring(AutoFarmModule))
end

local MarketPlaceService = game:GetService("MarketplaceService")
local placeName = MarketPlaceService:GetProductInfo(game.PlaceId).Name

Library:SetTitle(placeName)

local function TeleportToTower()
end

local function CollectRewards()
end

local function ResetCharacter()
end

local AutoFarmTab = Library:CreateTab("AutoFarm", false, "rbxassetid://123456789")
AutoFarmTab:AddSection("Controles de AutoFarm")

AutoFarmTab:AddToggle("Ativar AutoFarm", "autofarm_enabled", function(state)
	AutoFarmModule.Enabled = state
	if state then
		AutoFarmModule:Start()
	else
		AutoFarmModule:Stop()
	end
end)

AutoFarmTab:AddKeybind("Atalho AutoFarm", "autofarm_keybind", function()
	AutoFarmModule.Enabled = not AutoFarmModule.Enabled
	if AutoFarmModule.Enabled then
		AutoFarmModule:Start()
	else
		AutoFarmModule:Stop()
	end
end)

AutoFarmTab:AddSlider("Velocidade de Farm", 1, 100, 50, function(value)
	AutoFarmModule:UpdateSpeed(value)
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
