local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local kickStoneRemote = game.ReplicatedStorage:WaitForChild("KickStone")
local vim = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local Module = {}

-- [ESTADO DO MÓDULO]
Module.Flags = {
    AutoFarm = false,
    AutoUpgrade = {
        Backpack = false,
        CutSpeed = false,
        PickaxeSpeed = false,
        StoneMultiplier = false,
        CutterMultiplier = false,
        PlaceMultiplier = false
    },
    Meta = {
        Modo = nil,
        Valor = 50000
    }
}

local Theme = {
    Background = Color3.fromRGB(15, 12, 20),
    Sidebar = Color3.fromRGB(20, 15, 25),
    Accent = Color3.fromRGB(180, 130, 255),
    Text = Color3.fromRGB(240, 230, 255)
}

local minePosition = Vector3.new(51.139, 4.57, -9.209)
local globalOrientation = CFrame.Angles(0, math.rad(-90), 0)
local tolerance = 2

local limits = player:WaitForChild("Limits")
local mults = player:WaitForChild("Mults")
local stones = player:FindFirstChild("Stones") or (player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Stones"))
local bricks = player:FindFirstChild("Bricks") or (player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Bricks"))
local playerTBP = player:WaitForChild("TBP")

local UPGRADE_DATA = {
    Backpack = {folder = limits, mult = 1.5, start = 2, price = 10, pricemult = 1.5, max = 15000},
    CutSpeed = {folder = limits, mult = 0.8, start = 1.5, price = 20, pricemult = 1.8, min = 0},
    PickaxeSpeed = {folder = limits, mult = 1.3, start = 1, price = 20, pricemult = 1.6, max = 25},
    StoneMultiplier = {folder = mults, mult = 2, start = 1, price = 10000, pricemult = 3, max = 3},
    CutterMultiplier = {folder = mults, mult = 2, start = 1, price = 12000, pricemult = 3, max = 3},
    PlaceMultiplier = {folder = mults, mult = 2, start = 1, price = 8000, pricemult = 3, max = 3}
}

-- [SISTEMA DE AVISO]
local avisoDado = player:FindFirstChild("AvisoDado")
if not avisoDado then
    avisoDado = Instance.new("BoolValue")
    avisoDado.Name = "AvisoDado"
    avisoDado.Value = false
    avisoDado.Parent = player
end

local avisoGui = nil

function Module:CriarAviso(titulo, mensagem)
    if avisoDado.Value then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NottyAvisoGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    avisoGui = screenGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 65)
    frame.Position = UDim2.new(1, 50, 0.85, 0)
    frame.BackgroundColor3 = Theme.Sidebar
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Accent
    stroke.Thickness = 1.5
    stroke.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titulo
    titleLabel.TextColor3 = Theme.Accent
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 25)
    msgLabel.Position = UDim2.new(0, 10, 0, 32)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = mensagem
    msgLabel.TextColor3 = Theme.Text
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 12
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -290, 0.85, 0)
    }):Play()
end

function Module:FecharAviso()
    if avisoGui and not avisoDado.Value then
        avisoDado.Value = true
        local frame = avisoGui:FindFirstChildOfClass("Frame")
        if frame then
            local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 50, 0.85, 0)
            })
            tween:Play()
            tween.Completed:Connect(function()
                avisoGui:Destroy()
                avisoGui = nil
            end)
        end
    end
end

-- [FUNÇÕES INTERNAS]
local function setMovement(enabled)
    if enabled then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    else
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    end
end

local function getUpgradePrice(typeName)
    local data = UPGRADE_DATA[typeName]
    local currentVal = data.folder:GetAttribute(typeName) or data.start
    local level = math.max(0, math.floor(math.log(currentVal / data.start) / math.log(data.mult) + 0.5))
    return math.floor(data.price * (data.pricemult ^ level))
end

local function performUpgrade(typeName)
    local data = UPGRADE_DATA[typeName]
    local currentVal = data.folder:GetAttribute(typeName) or data.start
    -- Removida a trava de Max/Min para permitir upgrades contínuos enquanto o jogo permitir
    -- if (data.max and currentVal >= data.max) or (data.min and currentVal <= data.min) then return false end
    
    local price = getUpgradePrice(typeName)
    if math.floor(playerTBP.Value) >= price then
        local upgradePart = workspace:WaitForChild("Upgrades"):FindFirstChild(typeName)
        if upgradePart and upgradePart:FindFirstChild("Use") then
            local prompt = upgradePart.Use
            local oldPos = humanoidRootPart.CFrame
            humanoidRootPart.CFrame = upgradePart.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.3)
            fireproximityprompt(prompt)
            task.wait(0.3)
            humanoidRootPart.CFrame = oldPos
            return true
        end
    end
    return false
end

local function equipPickaxe()
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("pickaxe") then
                humanoid:EquipTool(item)
                return item
            end
        end
    end
    return character:FindFirstChildWhichIsA("Tool")
end

-- [FUNÇÕES PÚBLICAS DE CONTROLE]
function Module:SetAutoFarm(state)
    Module.Flags.AutoFarm = state
    if state then
        task.spawn(function()
            while Module.Flags.AutoFarm do
                -- Check Upgrades
                for name, enabled in pairs(Module.Flags.AutoUpgrade) do
                    if enabled then performUpgrade(name) end
                end
                
                -- Meta Check
                local metaModo = Module.Flags.Meta.Modo
                local metaValor = Module.Flags.Meta.Valor
                
                if metaModo == "Torre" and math.floor(playerTBP.Value) >= metaValor then
                    Module:SetAutoFarm(false)
                    break
                elseif metaModo == "Coins" and player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Coins") and player.leaderstats.Coins.Value >= metaValor then
                    Module:SetAutoFarm(false)
                    break
                elseif metaModo == "Tijolos" and player:FindFirstChild("TBP_Placed") and player.TBP_Placed.Value >= metaValor then
                    -- Nota: Assumindo que TBP_Placed ou similar rastreia tijolos colocados
                    Module:SetAutoFarm(false)
                    break
                end
                
                -- Farm Logic
                local targetLimit = math.floor(tonumber(limits:GetAttribute("Backpack")) or 255)
                local totalOccupied = math.floor(stones.Value) + math.floor(bricks.Value)
                
                if totalOccupied < targetLimit then
                    humanoidRootPart.CFrame = CFrame.new(minePosition) * globalOrientation
                    setMovement(false)
                    task.wait(0.5)
                    equipPickaxe()
                    while Module.Flags.AutoFarm and (math.floor(stones.Value) + math.floor(bricks.Value)) < targetLimit do
                        if (humanoidRootPart.Position - minePosition).Magnitude > tolerance then
                            humanoidRootPart.CFrame = CFrame.new(minePosition) * globalOrientation
                        end
                        humanoid.Jump = false
                        kickStoneRemote:InvokeServer(true)
                        task.wait(0.05)
                        kickStoneRemote:InvokeServer(false)
                        task.wait(0.1)
                    end
                    setMovement(true)
                end
                
                -- Process Bricks
                if math.floor(stones.Value) > 0 then
                    local sawsFolder = workspace:FindFirstChild("Saws") and workspace.Saws:FindFirstChild("Saws")
                    local sawModel = sawsFolder and sawsFolder:FindFirstChildWhichIsA("Model")
                    if sawModel and sawModel:FindFirstChild("Use") and sawModel.Use:FindFirstChild("UsePP") then
                        local usePart = sawModel.Use
                        local prompt = usePart.UsePP
                        humanoidRootPart.CFrame = usePart.CFrame * globalOrientation
                        setMovement(false)
                        task.wait(0.5)
                        prompt:InputHoldBegin()
                        while Module.Flags.AutoFarm and math.floor(stones.Value) > 0 do
                            task.wait(0.5)
                            prompt:InputHoldBegin()
                            humanoid.Jump = false
                        end
                        prompt:InputHoldEnd()
                        setMovement(true)
                        Module:FecharAviso()
                    end
                end
                
                -- Build
                if math.floor(bricks.Value) > 0 then
                    vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    while Module.Flags.AutoFarm and math.floor(bricks.Value) > 0 do
                        local baseFolder = workspace:FindFirstChild("Floors") and workspace.Floors:FindFirstChild("Base")
                        local exampleFolder = baseFolder and baseFolder:FindFirstChild("Example")
                        local targetPart = nil
                        if exampleFolder then
                            for _, part in pairs(exampleFolder:GetChildren()) do
                                if part:IsA("BasePart") then targetPart = part break end
                            end
                        end
                        if targetPart then
                            humanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                            local startAmount = math.floor(bricks.Value)
                            local timeout = 0
                            while Module.Flags.AutoFarm and math.floor(bricks.Value) == startAmount and timeout < 0.5 do
                                vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                                task.wait(0.05)
                                timeout = timeout + 0.05
                            end
                        else
                            task.wait(1)
                        end
                    end
                    vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                end
                task.wait(1)
            end
        end)
    end
end

function Module:SetUpgrade(upgradeName, state)
    if Module.Flags.AutoUpgrade[upgradeName] ~= nil then
        Module.Flags.AutoUpgrade[upgradeName] = state
    end
end

function Module:SetMeta(modo, valor)
    Module.Flags.Meta.Modo = modo
    Module.Flags.Meta.Valor = valor or 50000
end

return Module
