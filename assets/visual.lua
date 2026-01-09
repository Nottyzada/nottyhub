--Direitos de Notty0001
local Library={}
Library.DefaultTitle="standard"

local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local Camera=Workspace.CurrentCamera
local Theme={Background=Color3.fromRGB(15,12,20),Sidebar=Color3.fromRGB(20,15,25),Accent=Color3.fromRGB(180,130,255),DarkAccent=Color3.fromRGB(80,50,120),Text=Color3.fromRGB(240,230,255),TextSecondary=Color3.fromRGB(160,140,180),Border=Color3.fromRGB(45,35,60),Button=Color3.fromRGB(25,20,35)}
local Config={MinimizeKey=Enum.KeyCode.LeftAlt,AutoSave=false,AntiLag=false}
local isSliding,isBinding=false,false
local dragging,dragInput,dragStart,startPos
local activeNotifications={}
local notificationQueue={}
local isProcessing=false
local lastNotifTime={}

local function GenerateRandomName()
	local chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local name=""
	for i=1,math.random(15,25) do
		local rand=math.random(1,#chars)
		name=name..string.sub(chars,rand,rand)
	end
	return name
end

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name=GenerateRandomName()
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=player:WaitForChild("PlayerGui")

local MainFrame=Instance.new("Frame")
MainFrame.Name=GenerateRandomName()
MainFrame.Size=UDim2.new(0,580,0,420)
MainFrame.Position=UDim2.new(0.5,-290,0.5,-210)
MainFrame.BackgroundColor3=Theme.Background
MainFrame.BorderSizePixel=0
MainFrame.Visible=false
MainFrame.ClipsDescendants=true
MainFrame.Parent=ScreenGui

local MainStroke=Instance.new("UIStroke")
MainStroke.Color=Theme.Accent
MainStroke.Thickness=1.5
MainStroke.Parent=MainFrame
local Sidebar=Instance.new("Frame")
Sidebar.Name="Sidebar"
Sidebar.Size=UDim2.new(0,160,1,0)
Sidebar.BackgroundColor3=Theme.Sidebar
Sidebar.BorderSizePixel=0
Sidebar.Parent=MainFrame
local SidebarBorder=Instance.new("Frame")
SidebarBorder.Size=UDim2.new(0,1,1,0)
SidebarBorder.Position=UDim2.new(1,0,0,0)
SidebarBorder.BackgroundColor3=Theme.Accent
SidebarBorder.BorderSizePixel=0
SidebarBorder.Parent=Sidebar
local LogoArea=Instance.new("Frame")
LogoArea.Name="LogoArea"
LogoArea.Size=UDim2.new(1,0,0,100)
LogoArea.BackgroundTransparency=1
LogoArea.Parent=Sidebar
local LogoIcon=Instance.new("ImageLabel")
LogoIcon.Size=UDim2.new(0,60,0,60)
LogoIcon.Position=UDim2.new(0.5,-30,0,10)
LogoIcon.BackgroundTransparency=1
LogoIcon.Image="rbxassetid://105576438063815"
LogoIcon.ImageColor3=Theme.Accent
LogoIcon.Parent=LogoArea
local LogoTitle=Instance.new("TextLabel")
LogoTitle.Size=UDim2.new(1,0,0,30)
LogoTitle.Position=UDim2.new(0,0,0,70)
LogoTitle.BackgroundTransparency=1
LogoTitle.Text="NOTTY HUB"
LogoTitle.TextColor3=Theme.Accent
LogoTitle.TextSize=16
LogoTitle.Font=Enum.Font.GothamBold
LogoTitle.Parent=LogoArea
local NavContainer=Instance.new("ScrollingFrame")
NavContainer.Name="NavContainer"
NavContainer.Size=UDim2.new(1,-10,1,-180)
NavContainer.Position=UDim2.new(0,5,0,100)
NavContainer.BackgroundTransparency=1
NavContainer.BorderSizePixel=0
NavContainer.ScrollBarThickness=0
NavContainer.Parent=Sidebar
local NavLayout=Instance.new("UIListLayout")
NavLayout.Padding=UDim.new(0,4)
NavLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
NavLayout.Parent=NavContainer
local FixedBottom=Instance.new("Frame")
FixedBottom.Name="FixedBottom"
FixedBottom.Size=UDim2.new(1,-10,0,70)
FixedBottom.Position=UDim2.new(0,5,1,-75)
FixedBottom.BackgroundTransparency=1
FixedBottom.Parent=Sidebar
local FixedLayout=Instance.new("UIListLayout")
FixedLayout.Padding=UDim.new(0,4)
FixedLayout.VerticalAlignment=Enum.VerticalAlignment.Bottom
FixedLayout.Parent=FixedBottom
local PagesContainer=Instance.new("Frame")
PagesContainer.Name="PagesContainer"
PagesContainer.Size=UDim2.new(1,-170,1,-40)
PagesContainer.Position=UDim2.new(0,170,0,40)
PagesContainer.BackgroundTransparency=1
PagesContainer.Parent=MainFrame
local TopBar=Instance.new("Frame")
TopBar.Name="TopBar"
TopBar.Size=UDim2.new(1,-160,0,40)
TopBar.Position=UDim2.new(0,160,0,0)
TopBar.BackgroundTransparency=1
TopBar.Parent=MainFrame
local TopTitle=Instance.new("TextLabel")
TopTitle.Size=UDim2.new(1,-110,1,0)
TopTitle.Position=UDim2.new(0,10,0,0)
TopTitle.BackgroundTransparency=1
TopTitle.Text=Library.DefaultTitle.." | Notty0001"
TopTitle.TextColor3=Theme.TextSecondary
TopTitle.TextSize=12
TopTitle.Font=Enum.Font.Gotham
TopTitle.TextXAlignment=Enum.TextXAlignment.Left
TopTitle.Parent=TopBar
local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,30,0,30)
CloseBtn.Position=UDim2.new(1,-35,0,5)
CloseBtn.BackgroundColor3=Theme.Button
CloseBtn.Text="X"
CloseBtn.TextColor3=Theme.Accent
CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.Parent=TopBar
Instance.new("UIStroke",CloseBtn).Color=Theme.Accent
local MinimizeBtn=Instance.new("TextButton")
MinimizeBtn.Size=UDim2.new(0,30,0,30)
MinimizeBtn.Position=UDim2.new(1,-70,0,5)
MinimizeBtn.BackgroundColor3=Theme.Button
MinimizeBtn.Text="-"
MinimizeBtn.TextColor3=Theme.Accent
MinimizeBtn.Font=Enum.Font.GothamBold
MinimizeBtn.Parent=TopBar
Instance.new("UIStroke",MinimizeBtn).Color=Theme.Accent
local MinimizedNotice=Instance.new("TextLabel")
MinimizedNotice.Size=UDim2.new(0,280,0,30)
MinimizedNotice.Position=UDim2.new(0.5,-140,0,-40)
MinimizedNotice.BackgroundColor3=Theme.Sidebar
MinimizedNotice.Text="Pressione "..Config.MinimizeKey.Name.." para reabrir"
MinimizedNotice.TextColor3=Theme.Accent
MinimizedNotice.Font=Enum.Font.GothamBold
MinimizedNotice.TextSize=12
MinimizedNotice.Visible=false
MinimizedNotice.Parent=ScreenGui
Instance.new("UIStroke",MinimizedNotice).Color=Theme.Accent
local ConfirmModal=Instance.new("Frame")
ConfirmModal.Size=UDim2.new(0,250,0,120)
ConfirmModal.Position=UDim2.new(0.5,-125,0.5,-60)
ConfirmModal.BackgroundColor3=Theme.Sidebar
ConfirmModal.Visible=false
ConfirmModal.ZIndex=100
ConfirmModal.Parent=ScreenGui
Instance.new("UIStroke",ConfirmModal).Color=Theme.Accent
local ModalText=Instance.new("TextLabel")
ModalText.Size=UDim2.new(1,0,0,60)
ModalText.BackgroundTransparency=1
ModalText.Text="Deseja realmente fechar o painel?"
ModalText.TextColor3=Theme.Text
ModalText.Font=Enum.Font.GothamMedium
ModalText.TextSize=14
ModalText.Parent=ConfirmModal
local ConfirmBtn=Instance.new("TextButton")
ConfirmBtn.Size=UDim2.new(0,100,0,35)
ConfirmBtn.Position=UDim2.new(0,20,0,70)
ConfirmBtn.BackgroundColor3=Theme.Accent
ConfirmBtn.Text="Confirmar"
ConfirmBtn.TextColor3=Theme.Text
ConfirmBtn.Parent=ConfirmModal
local CancelBtn=Instance.new("TextButton")
CancelBtn.Size=UDim2.new(0,100,0,35)
CancelBtn.Position=UDim2.new(1,-120,0,70)
CancelBtn.BackgroundColor3=Theme.Button
CancelBtn.Text="Cancelar"
CancelBtn.TextColor3=Theme.Text
CancelBtn.Parent=ConfirmModal
local NotifyFolder=Instance.new("Folder",ScreenGui)
NotifyFolder.Name=GenerateRandomName()
local function SelectTab(tab)
	if not tab then return end
	for _,p in pairs(PagesContainer:GetChildren()) do 
		p.Visible=false 
	end
	for _,b in pairs(NavContainer:GetChildren()) do 
		if b:IsA("TextButton") then 
			b.TextColor3=Theme.TextSecondary
			b.ImageLabel.ImageColor3=Theme.TextSecondary
			local indicator = b:FindFirstChild("Frame")
			if indicator then
				TweenService:Create(indicator,TweenInfo.new(0.3),{Size=UDim2.new(0,2,0,0),Position=UDim2.new(0,0,0.5,0)}):Play()
			end
		end 
	end
	for _,b in pairs(FixedBottom:GetChildren()) do 
		if b:IsA("TextButton") then 
			b.TextColor3=Theme.TextSecondary 
			b.ImageLabel.ImageColor3=Theme.TextSecondary
			local indicator = b:FindFirstChild("Frame")
			if indicator then
				TweenService:Create(indicator,TweenInfo.new(0.3),{Size=UDim2.new(0,2,0,0),Position=UDim2.new(-0.03,0,0.5,0)}):Play()
			end
		end 
	end
	if tab.Page then
		tab.Page.Visible=true
	end

	if tab.TabButton then
		tab.TabButton.TextColor3=Theme.Accent
	end

	if tab.TabIndicator then
		TweenService:Create(tab.TabIndicator,TweenInfo.new(0.3),{Size=UDim2.new(0,2,0,20),Position=UDim2.new(-0.03,0,0.5,-10)}):Play()
	end
end
local function processQueue()
	if isProcessing or #notificationQueue==0 then return end
	isProcessing=true
	local data=table.remove(notificationQueue,1)
	local title,info,duration=data.title,data.info,data.duration
	local TWEEN_INFO=TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
	local START_POSITION=UDim2.new(1.5,0,0.85,0)
	local TARGET_POSITION=UDim2.new(1,-290,0.85,0)
	local VERTICAL_OFFSET=68
	local newNotify=Instance.new("Frame")
	newNotify.Size=UDim2.new(0,280,0,65)
	newNotify.BackgroundColor3=Theme.Sidebar
	newNotify.Position=START_POSITION
	newNotify.BorderSizePixel=0
	newNotify.Parent=NotifyFolder
	local NStroke=Instance.new("UIStroke",newNotify)
	NStroke.Color=Theme.Accent
	NStroke.Thickness=1.5
	local T=Instance.new("TextLabel")
	T.Size=UDim2.new(1,-20,0,25)
	T.Position=UDim2.new(0,10,0,8)
	T.BackgroundTransparency=1
	T.Text=title
	T.TextColor3=Theme.Accent
	T.Font=Enum.Font.GothamBold
	T.TextSize=14
	T.TextXAlignment=Enum.TextXAlignment.Left
	T.Parent=newNotify
	local D=Instance.new("TextLabel")
	D.Size=UDim2.new(1,-20,0,25)
	D.Position=UDim2.new(0,10,0,32)
	D.BackgroundTransparency=1
	D.Text=info
	D.TextColor3=Theme.Text
	D.Font=Enum.Font.Gotham
	D.TextSize=12
	D.TextXAlignment=Enum.TextXAlignment.Left
	D.Parent=newNotify
	for i=#activeNotifications,1,-1 do
		local notify=activeNotifications[i]
		if notify and notify.Parent then
			local currentPos=notify.Position
			local newPos=UDim2.new(currentPos.X.Scale,currentPos.X.Offset,currentPos.Y.Scale,currentPos.Y.Offset-VERTICAL_OFFSET)
			TweenService:Create(notify,TWEEN_INFO,{Position=newPos}):Play()
		else
			table.remove(activeNotifications,i)
		end
	end
	table.insert(activeNotifications,1,newNotify)
	local entranceTween=TweenService:Create(newNotify,TWEEN_INFO,{Position=TARGET_POSITION})
	entranceTween:Play()
	entranceTween.Completed:Wait()
	isProcessing=false
	task.delay(duration,function()
		if newNotify and newNotify.Parent then
			local exitTween=TweenService:Create(newNotify,TWEEN_INFO,{Position=START_POSITION})
			exitTween:Play()
			exitTween.Completed:Connect(function()
				for i,notify in ipairs(activeNotifications) do
					if notify==newNotify then
						table.remove(activeNotifications,i)
						break
					end
				end
				newNotify:Destroy()
			end)
		end
	end)
	processQueue()
end
function Library:Notify(title,info,duration)
	local content=title..info
	local now=tick()
	if lastNotifTime[content] and now-lastNotifTime[content]<2 then return end
	lastNotifTime[content]=now
	table.insert(notificationQueue,{title=title,info=info,duration=duration or 5})
	processQueue()
end
function Library:SaveConfig()
	local data=HttpService:JSONEncode({MinimizeKey=Config.MinimizeKey.Name,AutoSave=Config.AutoSave,AntiLag=Config.AntiLag})
	if writefile then writefile("NottyHub_Config.json",data) end
	Library:Notify("Sistema","Configuracoes salvas!",2)
end
function Library:LoadConfig()
	if isfile and isfile("NottyHub_Config.json") then
		local data=readfile("NottyHub_Config.json")
		local success,decoded=pcall(HttpService.JSONDecode,HttpService,data)
		if success then
			if decoded.MinimizeKey then Config.MinimizeKey=Enum.KeyCode[decoded.MinimizeKey] end
			Config.AutoSave=decoded.AutoSave or false
			Config.AntiLag=decoded.AntiLag or false
		end
	end
end
function Library:CreateTab(name, isFixed, iconId)
	local TabBtn = Instance.new("TextButton")
	TabBtn.Size = UDim2.new(1, 0, 0, 32)
	TabBtn.BackgroundColor3 = Theme.Button
	TabBtn.BackgroundTransparency = 1
	TabBtn.Text = name
	TabBtn.TextColor3 = Theme.TextSecondary
	TabBtn.Font = Enum.Font.GothamMedium
	TabBtn.TextSize = 13
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left -- Alinha o texto à esquerda para dar espaço ao ícone
	TabBtn.Parent = isFixed and FixedBottom or NavContainer

	-- Adiciona Padding para o texto não ficar em cima do ícone
	local TabPadding = Instance.new("UIPadding")
	TabPadding.PaddingLeft = UDim.new(0, 35)
	TabPadding.Parent = TabBtn

	-- Cria o ícone da aba
	local TabIcon = Instance.new("ImageLabel")
	TabIcon.Size = UDim2.new(0, 20, 0, 20)
	TabIcon.Position = UDim2.new(0, -28, 0.5, -10) -- Posicionado à esquerda dentro do padding
	TabIcon.BackgroundTransparency = 1
	TabIcon.Image = iconId and ("rbxassetid://" .. tostring(iconId)) or ""
	TabIcon.ImageColor3 = Theme.TextSecondary
	TabIcon.Parent = TabBtn

	local TabIndicator = Instance.new("Frame")
	TabIndicator.Size = UDim2.new(0, 2, 0, 0)
	TabIndicator.Position = UDim2.new(0, -35, -0.03, 0) -- Ajustado para a nova posição com padding
	TabIndicator.BackgroundColor3 = Theme.Accent
	TabIndicator.BorderSizePixel = 0
	TabIndicator.Parent = TabBtn

	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 2
	Page.ScrollBarImageColor3 = Theme.Accent
	Page.Visible = false
	Page.Parent = PagesContainer

	local PageLayout = Instance.new("UIListLayout")
	PageLayout.Padding = UDim.new(0, 6)
	PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	PageLayout.Parent = Page
	PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
		Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10) 
	end)

	local elementCount = 0

	TabBtn.MouseButton1Click:Connect(function()
		SelectTab({
			TabButton = TabBtn,
			TabIndicator = TabIndicator,
			Page = Page
		})
		for _, btn in pairs(TabBtn.Parent:GetChildren()) do
			if btn:IsA("TextButton") then
				local icon = btn:FindFirstChildOfClass("ImageLabel")
			end
		end
		TabIcon.ImageColor3 = Theme.Accent
	end)

	local TabFunctions = {}
	TabFunctions.TabButton = TabBtn
	TabFunctions.TabIndicator = TabIndicator
	TabFunctions.Page = Page

	function TabFunctions:AddSection(text)
		elementCount=elementCount+1
		local SecLabel=Instance.new("TextLabel")
		SecLabel.Size=UDim2.new(1,-10,0,25)
		SecLabel.BackgroundTransparency=1
		SecLabel.Text=text
		SecLabel.TextColor3=Theme.Accent
		SecLabel.Font=Enum.Font.GothamBold
		SecLabel.TextSize=12
		SecLabel.TextXAlignment=Enum.TextXAlignment.Left
		SecLabel.LayoutOrder=elementCount
		SecLabel.Parent=Page
	end
	function TabFunctions:AddButton(text,callback)
		elementCount=elementCount+1
		local Btn=Instance.new("TextButton")
		Btn.Size=UDim2.new(1,-10,0,35)
		Btn.BackgroundColor3=Theme.Button
		Btn.Text=text
		Btn.TextColor3=Theme.Text
		Btn.Font=Enum.Font.GothamMedium
		Btn.TextSize=13
		Btn.LayoutOrder=elementCount
		Btn.Parent=Page
		Instance.new("UIStroke",Btn).Color=Theme.Border
		Btn.MouseButton1Click:Connect(function()
			TweenService:Create(Btn,TweenInfo.new(0.1),{BackgroundColor3=Theme.Accent}):Play()
			task.wait(0.1)
			TweenService:Create(Btn,TweenInfo.new(0.1),{BackgroundColor3=Theme.Button}):Play()
			if callback then pcall(callback) end
		end)
	end
	function TabFunctions:AddIconButton(text,iconId,callback)
		elementCount=elementCount+1
		local Btn=Instance.new("TextButton")
		Btn.Size=UDim2.new(1,-10,0,40)
		Btn.BackgroundColor3=Theme.Button
		Btn.Text=text
		Btn.TextColor3=Theme.Text
		Btn.Font=Enum.Font.GothamMedium
		Btn.TextSize=13
		Btn.TextXAlignment=Enum.TextXAlignment.Left
		Btn.LayoutOrder=elementCount
		Btn.Parent=Page
		Instance.new("UIStroke",Btn).Color=Theme.Border
		local Pad=Instance.new("UIPadding",Btn)
		Pad.PaddingLeft=UDim.new(0,40)
		local Icon=Instance.new("ImageLabel")
		Icon.Size=UDim2.new(0,24,0,24)
		Icon.Position=UDim2.new(0,-30,0.5,-12)
		Icon.BackgroundTransparency=1
		Icon.Image=tostring(iconId)
		Icon.Parent=Btn
		Btn.MouseButton1Click:Connect(function()
			TweenService:Create(Btn,TweenInfo.new(0.1),{BackgroundColor3=Theme.Accent}):Play()
			task.wait(0.1)
			TweenService:Create(Btn,TweenInfo.new(0.1),{BackgroundColor3=Theme.Button}):Play()
			if callback then pcall(callback) end
		end)
	end
	function TabFunctions:AddToggle(text,configKey,callback)
		elementCount=elementCount+1
		local ToggleFrame=Instance.new("Frame")
		ToggleFrame.Size=UDim2.new(1,-10,0,35)
		ToggleFrame.BackgroundColor3=Theme.Button
		ToggleFrame.LayoutOrder=elementCount
		ToggleFrame.BorderSizePixel=0
		ToggleFrame.Parent=Page
		Instance.new("UIStroke",ToggleFrame).Color=Theme.Border
		local Label=Instance.new("TextLabel")
		Label.Size=UDim2.new(1,-50,1,0)
		Label.Position=UDim2.new(0,10,0,0)
		Label.BackgroundTransparency=1
		Label.Text=text
		Label.TextColor3=Theme.Text
		Label.Font=Enum.Font.GothamMedium
		Label.TextSize=13
		Label.TextXAlignment=Enum.TextXAlignment.Left
		Label.Parent=ToggleFrame
		local Box=Instance.new("Frame")
		Box.Size=UDim2.new(0,20,0,20)
		Box.Position=UDim2.new(1,-30,0.5,-10)
		Box.BackgroundColor3=Theme.Background
		Box.BorderSizePixel=0
		Box.Parent=ToggleFrame
		Instance.new("UIStroke",Box).Color=Theme.Accent
		local Inner=Instance.new("Frame")
		Inner.Size=UDim2.new(0,0,0,0)
		Inner.Position=UDim2.new(0.5,0,0.5,0)
		Inner.BackgroundColor3=Theme.Accent
		Inner.BorderSizePixel=0
		Inner.Parent=Box
		local state=false
		if configKey and Config[configKey]~=nil then state=Config[configKey] end
		local function update()
			TweenService:Create(Inner,TweenInfo.new(0.2),{Size=state and UDim2.new(1,-4,1,-4) or UDim2.new(0,0,0,0),Position=state and UDim2.new(0,2,0,2) or UDim2.new(0.5,0,0.5,0)}):Play()
			if configKey then Config[configKey]=state end
			if callback then pcall(callback,state) end
			if Config.AutoSave then Library:SaveConfig() end
		end
		ToggleFrame.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then state=not state update() end end)
		update()
	end
	function TabFunctions:AddSlider(text,min,max,default,callback)
		elementCount=elementCount+1
		local SliderFrame=Instance.new("Frame")
		SliderFrame.Size=UDim2.new(1,-10,0,50)
		SliderFrame.BackgroundColor3=Theme.Button
		SliderFrame.LayoutOrder=elementCount
		SliderFrame.BorderSizePixel=0
		SliderFrame.Parent=Page
		Instance.new("UIStroke",SliderFrame).Color=Theme.Border
		local Label=Instance.new("TextLabel")
		Label.Size=UDim2.new(1,-60,0,25)
		Label.Position=UDim2.new(0,10,0,5)
		Label.BackgroundTransparency=1
		Label.Text=text
		Label.TextColor3=Theme.Text
		Label.Font=Enum.Font.GothamMedium
		Label.TextSize=13
		Label.TextXAlignment=Enum.TextXAlignment.Left
		Label.Parent=SliderFrame
		local ValueLabel=Instance.new("TextLabel")
		ValueLabel.Size=UDim2.new(0,40,0,25)
		ValueLabel.Position=UDim2.new(1,-50,0,5)
		ValueLabel.BackgroundTransparency=1
		ValueLabel.Text=tostring(default)
		ValueLabel.TextColor3=Theme.Accent
		ValueLabel.Font=Enum.Font.GothamBold
		ValueLabel.TextSize=13
		ValueLabel.Parent=SliderFrame
		local Bar=Instance.new("Frame")
		Bar.Size=UDim2.new(1,-30,0,6)
		Bar.Position=UDim2.new(0,15,0,35)
		Bar.BackgroundColor3=Theme.Background
		Bar.BorderSizePixel=0
		Bar.Parent=SliderFrame
		local Fill=Instance.new("Frame")
		Fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
		Fill.BackgroundColor3=Theme.Accent
		Fill.BorderSizePixel=0
		Fill.Parent=Bar
		local Knob=Instance.new("Frame")
		Knob.Size=UDim2.new(0,12,0,12)
		Knob.Position=UDim2.new((default-min)/(max-min),-6,0.5,-6)
		Knob.BackgroundColor3=Theme.Text
		Knob.BorderSizePixel=0
		Knob.Parent=Bar
		Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
		Instance.new("UIStroke",Knob).Color=Theme.Accent
		local currentVal=default
		local sliding=false
		local function update(input)
			local inputPos=input.Position.X
			local barPos=Bar.AbsolutePosition.X
			local barSize=Bar.AbsoluteSize.X
			local pos=math.clamp((inputPos-barPos)/barSize,0,1)
			currentVal=math.floor(min+(max-min)*pos)
			Fill.Size=UDim2.new(pos,0,1,0)
			Knob.Position=UDim2.new(pos,-6,0.5,-6)
			ValueLabel.Text=tostring(currentVal)
			if callback then pcall(callback,currentVal) end
		end
		Bar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then sliding=true isSliding=true update(input) end end)
		UserInputService.InputChanged:Connect(function(input) if sliding and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then update(input) end end)
		UserInputService.InputEnded:Connect(function(input) if (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) and sliding then sliding=false isSliding=false end end)
	end
	function TabFunctions:AddTextBox(text,placeholder,callback)
		elementCount=elementCount+1
		local BoxFrame=Instance.new("Frame")
		BoxFrame.Size=UDim2.new(1,-10,0,55)
		BoxFrame.BackgroundColor3=Theme.Button
		BoxFrame.LayoutOrder=elementCount
		BoxFrame.Parent=Page
		Instance.new("UIStroke",BoxFrame).Color=Theme.Border
		local Label=Instance.new("TextLabel")
		Label.Size=UDim2.new(1,-20,0,25)
		Label.Position=UDim2.new(0,10,0,5)
		Label.BackgroundTransparency=1
		Label.Text=text
		Label.TextColor3=Theme.Text
		Label.Font=Enum.Font.GothamMedium
		Label.TextSize=13
		Label.TextXAlignment=Enum.TextXAlignment.Left
		Label.Parent=BoxFrame
		local Input=Instance.new("TextBox")
		Input.Size=UDim2.new(1,-20,0,20)
		Input.Position=UDim2.new(0,10,0,30)
		Input.BackgroundColor3=Theme.Background
		Input.Text=""
		Input.PlaceholderText=placeholder
		Input.TextColor3=Theme.Text
		Input.PlaceholderColor3=Theme.TextSecondary
		Input.Font=Enum.Font.Gotham
		Input.TextSize=12
		Input.BorderSizePixel=0
		Input.Parent=BoxFrame
		Input.FocusLost:Connect(function(enter) if enter then pcall(callback,Input.Text) end end)
	end
	function TabFunctions:AddKeybind(text,configKey,callback)
		elementCount=elementCount+1
		local BindFrame=Instance.new("Frame")
		BindFrame.Size=UDim2.new(1,-10,0,35)
		BindFrame.BackgroundColor3=Theme.Button
		BindFrame.LayoutOrder=elementCount
		BindFrame.BorderSizePixel=0
		BindFrame.Parent=Page
		Instance.new("UIStroke",BindFrame).Color=Theme.Border
		local Label=Instance.new("TextLabel")
		Label.Size=UDim2.new(1,-80,1,0)
		Label.Position=UDim2.new(0,10,0,0)
		Label.BackgroundTransparency=1
		Label.Text=text
		Label.TextColor3=Theme.Text
		Label.Font=Enum.Font.GothamMedium
		Label.TextSize=13
		Label.TextXAlignment=Enum.TextXAlignment.Left
		Label.Parent=BindFrame
		local BindBtn=Instance.new("TextButton")
		BindBtn.Size=UDim2.new(0,70,0,25)
		BindBtn.Position=UDim2.new(1,-75,0.5,-12)
		BindBtn.BackgroundColor3=Theme.Background
		BindBtn.Text=Config[configKey] and Config[configKey].Name or "None"
		BindBtn.TextColor3=Theme.Accent
		BindBtn.Font=Enum.Font.GothamBold
		BindBtn.TextSize=11
		BindBtn.BorderSizePixel=0
		BindBtn.Parent=BindFrame
		BindBtn.MouseButton1Click:Connect(function()
			isBinding=true
			BindBtn.Text="..."
			local connection
			connection=UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType==Enum.UserInputType.Keyboard then
					Config[configKey]=input.KeyCode
					BindBtn.Text=input.KeyCode.Name
					task.wait(0.1)
					isBinding=false
					if configKey=="MinimizeKey" then MinimizedNotice.Text="Pressione "..input.KeyCode.Name.." para reabrir" end
					if callback then pcall(callback,input.KeyCode) end
					if Config.AutoSave then Library:SaveConfig() end
					connection:Disconnect()
				end
			end)
		end)
	end
	function TabFunctions:AddProfile()
		elementCount=elementCount+1
		local ProfileFrame=Instance.new("Frame")
		ProfileFrame.Size=UDim2.new(1,-10,0,160)
		ProfileFrame.BackgroundColor3=Theme.Button
		ProfileFrame.LayoutOrder=elementCount
		ProfileFrame.BorderSizePixel=0
		ProfileFrame.Parent=Page
		Instance.new("UIStroke",ProfileFrame).Color=Theme.Border
		local Viewport=Instance.new("ViewportFrame")
		Viewport.Size=UDim2.new(0,130,0,130)
		Viewport.Position=UDim2.new(0,10,0,15)
		Viewport.BackgroundTransparency=1
		Viewport.Parent=ProfileFrame
		local InfoArea=Instance.new("Frame")
		InfoArea.Size=UDim2.new(1,-150,1,-20)
		InfoArea.Position=UDim2.new(0,145,0,10)
		InfoArea.BackgroundTransparency=1
		InfoArea.Parent=ProfileFrame
		local function AddInfo(label,value,pos)
			local Lbl=Instance.new("TextLabel")
			Lbl.Size=UDim2.new(1,0,0,20)
			Lbl.Position=UDim2.new(0,0,0,pos)
			Lbl.BackgroundTransparency=1
			Lbl.Text=label..": "..value
			Lbl.TextColor3=Theme.Text
			Lbl.Font=Enum.Font.GothamMedium
			Lbl.TextSize=12
			Lbl.TextXAlignment=Enum.TextXAlignment.Left
			Lbl.Parent=InfoArea
		end
		AddInfo("Display",player.DisplayName,0)
		AddInfo("Username","@"..player.Name,25)
		AddInfo("ID",player.UserId,50)
		AddInfo("Account Age",tostring(player.AccountAge).." dias",75)
		AddInfo("Status","Ativo",100)
		task.spawn(function() local player = game.Players.LocalPlayer local worldModel = Instance.new("WorldModel") worldModel.Parent = Viewport local char = player.Character or player.CharacterAdded:Wait() local success, description = pcall(function() return game.Players:GetHumanoidDescriptionFromUserId(player.UserId) end) if success and description then local clone = game.Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R6) clone.Name = "ViewportClone" clone.Parent = worldModel local hrp = clone:WaitForChild("HumanoidRootPart") local humanoid = clone:WaitForChild("Humanoid") local cam = Instance.new("Camera") cam.FieldOfView = 30 cam.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 10 + Vector3.new(0, 1, 0), hrp.Position + Vector3.new(0, 1, 0)) cam.Parent = Viewport Viewport.CurrentCamera = cam task.wait(0.1) local animation = Instance.new("Animation") animation.AnimationId = "rbxassetid://0" local track repeat track = humanoid:LoadAnimation(animation) task.wait() until track ~= nil track.Looped = true track.Priority = Enum.AnimationPriority.Action track:Play() track.TimePosition = 0 else warn("Erro ao carregar aparencia do jogador.") end end)


	end
	return TabFunctions
end
local function ToggleUI()
	if isBinding then return end
	local isOpening=not MainFrame.Visible
	if isOpening then
		MainFrame.Visible=true
		MainFrame.Size=UDim2.new(0,0,0,0)
		MainFrame.Position=UDim2.new(0.5,0,0.5,0)
		MinimizedNotice.Visible=false
		TweenService:Create(MainFrame,TweenInfo.new(1,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,580,0,420),Position=UDim2.new(0.5,-290,0.5,-210)}):Play()
	else
		local t=TweenService:Create(MainFrame,TweenInfo.new(0.8,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)})
		t:Play()
		t.Completed:Wait()
		MainFrame.Visible=false
		MinimizedNotice.Visible=true
		MinimizedNotice.Position=UDim2.new(0.5,-140,0,-40)
		TweenService:Create(MinimizedNotice,TweenInfo.new(0.6,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-140,0,20)}):Play()
	end
end
function Library:SetTitle(newTitle)
	Library.DefaultTitle = newTitle
	TopTitle.Text = Library.DefaultTitle.. " | Notty0001"
end
MinimizeBtn.MouseButton1Click:Connect(ToggleUI)
UserInputService.InputBegan:Connect(function(input,gpe) if not gpe and input.KeyCode==Config.MinimizeKey then ToggleUI() end end)
CloseBtn.MouseButton1Click:Connect(function() ConfirmModal.Visible=true end)
CancelBtn.MouseButton1Click:Connect(function() ConfirmModal.Visible=false end)
ConfirmBtn.MouseButton1Click:Connect(function()
	Library:Notify("Sistema","Voce desativou o HUB.",5)
	task.wait(0.5)
	ScreenGui:Destroy()
end)
MainFrame.InputBegan:Connect(function(input) if (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) and not isSliding then dragging=true dragStart=input.Position startPos=MainFrame.Position end end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
UserInputService.InputChanged:Connect(function(input) if input==dragInput and dragging and not isSliding then local delta=input.Position-dragStart MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
Library:LoadConfig()
local CreditsTab=Library:CreateTab("Credits",true,"81803422841075")
local SettingsTab=Library:CreateTab("Settings",true,"102981058663914")
SettingsTab:AddProfile()
SettingsTab:AddSection("Interface Options")
SettingsTab:AddKeybind("Minimize Key","MinimizeKey")
SettingsTab:AddToggle("Anti-Lag Mode","AntiLag")
SettingsTab:AddToggle("Auto-Save Config","AutoSave")
SettingsTab:AddButton("Save Config Manually",function() Library:SaveConfig() end)
CreditsTab:AddSection("Developer")
CreditsTab:AddIconButton("Notty0001","rbxthumb://type=AvatarHeadShot&id=1103812140&w=420&h=420",function()Library:Notify("Info","Desenvolvido por Notty0001",2)end)
CreditsTab:AddSection("About")
CreditsTab:AddButton("Thanks for using Notty Hub!",function() end)
CreditsTab:AddButton("Join our Discord",function() Library:Notify("Discord","Link do Discord no perfil!",2) end)
local Modules={}
function Library:RegisterModule(name,callback) Modules[name]=callback end
function Library:LoadModule(name,tab) if Modules[name] then pcall(Modules[name],tab) end end
function Library:Init()
	task.spawn(function()
		MainFrame.Visible=true
		MainFrame.Size=UDim2.new(0,0,0,0)
		MainFrame.Position=UDim2.new(0.5,0,0.5,0)
		local openTween=TweenService:Create(MainFrame,TweenInfo.new(1.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,580,0,420),Position=UDim2.new(0.5,-290,0.5,-210)})
		openTween:Play()
		openTween.Completed:Wait()
		SelectTab(CreditsTab)
		task.wait(0.3)
		Library:Notify("Bem-vindo","Notty Hub Core carregado!",4)
	end)
end
return Library
