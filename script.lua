local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Config = {
	Cooldown = 2,
	CanUse = true,
	Color = Color3.fromRGB(0, 0, 0)
}

local CurrentDroppedBomb = nil

local function BuildC4(visible)
	local Main = Instance.new("Part")
	Main.Name = "Handle"
	
	if visible then
		Main.Size = Vector3.new(0.85, 2.30, 0.68)
	else
		Main.Size = Vector3.new(0.1, 0.1, 0.1)
	end
	
	Main.Color = Config.Color
	Main.Material = Enum.Material.Metal
	Main.Reflectance = 0
	Main.CanCollide = true
	Main.Transparency = visible and 0 or 1
	Main.Anchored = false
	return Main
end

-- Explosão igual do vídeo (estrelas amarelas + corações rosas)
local function PlayCuteExplosion(position)
	local holder = Instance.new("Part")
	holder.Size = Vector3.new(0.1, 0.1, 0.1)
	holder.Transparency = 1
	holder.Anchored = true
	holder.CanCollide = false
	holder.CFrame = CFrame.new(position)
	holder.Parent = workspace

	-- Estrelas amarelas (igual do vídeo)
	local stars = Instance.new("ParticleEmitter")
	stars.Name = "Stars"
	stars.Texture = "rbxassetid://6772783963"
	stars.Color = ColorSequence.new(Color3.fromRGB(255, 220, 60)) -- amarelo dourado do vídeo
	stars.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(0.4, 0.85),
		NumberSequenceKeypoint.new(1, 0.25)
	})
	stars.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.65, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	stars.Lifetime = NumberRange.new(0.8, 1.2)
	stars.Speed = NumberRange.new(3.5, 8)
	stars.SpreadAngle = Vector2.new(180, 180)
	stars.Rotation = NumberRange.new(0, 360)
	stars.RotSpeed = NumberRange.new(-80, 80)
	stars.LightEmission = 0.7
	stars.Rate = 0
	stars.Parent = holder

	-- Corações rosas (igual do vídeo)
	local hearts = Instance.new("ParticleEmitter")
	hearts.Name = "Hearts"
	hearts.Texture = "rbxassetid://5857851618"
	hearts.Color = ColorSequence.new(Color3.fromRGB(255, 110, 170))
	hearts.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.45),
		NumberSequenceKeypoint.new(0.4, 0.75),
		NumberSequenceKeypoint.new(1, 0.2)
	})
	hearts.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.65, 0.15),
		NumberSequenceKeypoint.new(1, 1)
	})
	hearts.Lifetime = NumberRange.new(0.9, 1.3)
	hearts.Speed = NumberRange.new(2.5, 6.5)
	hearts.SpreadAngle = Vector2.new(160, 160)
	hearts.Rotation = NumberRange.new(-25, 25)
	hearts.RotSpeed = NumberRange.new(-35, 35)
	hearts.LightEmission = 0.45
	hearts.Rate = 0
	hearts.Parent = holder

	-- Quantidade parecida com o vídeo
	stars:Emit(22)
	hearts:Emit(16)

	Debris:AddItem(holder, 1.5)
end

-- Limpa menu antigo
pcall(function()
	if PlayerGui:FindFirstChild("C4_Final_Menu") then
		PlayerGui.C4_Final_Menu:Destroy()
	end
end)

-- GUI
local sg = Instance.new("ScreenGui")
sg.Name = "C4_Final_Menu"
sg.ResetOnSpawn = false
sg.Parent = PlayerGui

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 60, 0, 40)
toggle.Position = UDim2.new(0, 10, 0.5, 0)
toggle.Text = "MENU"
toggle.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.Draggable = true
toggle.Parent = sg

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 320)
frame.Position = UDim2.new(0.5, -115, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.BorderSizePixel = 0
title.Text = "CONFIG BOMBA"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Active = true
title.Parent = frame

local dragging = false
local dragStart, startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Size = UDim2.new(0.9, 0, 0, 18)
cooldownLabel.Position = UDim2.new(0.05, 0, 0, 42)
cooldownLabel.BackgroundTransparency = 1
cooldownLabel.Text = "Cooldown (segundos):"
cooldownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
cooldownLabel.Font = Enum.Font.Gotham
cooldownLabel.TextSize = 13
cooldownLabel.TextXAlignment = Enum.TextXAlignment.Left
cooldownLabel.Parent = frame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.9, 0, 0, 28)
inputBox.Position = UDim2.new(0.05, 0, 0, 62)
inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
inputBox.Text = tostring(Config.Cooldown)
inputBox.PlaceholderText = "Ex: 2"
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
inputBox.ClearTextOnFocus = false
inputBox.BorderSizePixel = 0
inputBox.Parent = frame

local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(0.9, 0, 0, 18)
colorLabel.Position = UDim2.new(0.05, 0, 0, 100)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "Cor da bomba:"
colorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextSize = 13
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.Parent = frame

local colors = {
	{Name = "Verde", Color = Color3.fromRGB(0, 200, 0)},
	{Name = "Vermelho", Color = Color3.fromRGB(220, 30, 30)},
	{Name = "Preto", Color = Color3.fromRGB(0, 0, 0)},
	{Name = "Branco", Color = Color3.fromRGB(255, 255, 255)},
	{Name = "Azul", Color = Color3.fromRGB(30, 100, 255)},
	{Name = "Roxo", Color = Color3.fromRGB(150, 50, 255)},
	{Name = "Rosa", Color = Color3.fromRGB(255, 100, 180)},
}

local selectedColorBtn = nil

for i, data in ipairs(colors) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.42, 0, 0, 28)
	local row = math.ceil(i / 2)
	local col = (i % 2 == 1) and 0 or 1
	btn.Position = UDim2.new(0.05 + col * 0.48, 0, 0, 125 + (row - 1) * 34)
	btn.BackgroundColor3 = data.Color
	btn.Text = data.Name
	btn.TextColor3 = (data.Name == "Preto" or data.Name == "Azul" or data.Name == "Roxo") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.BorderSizePixel = 0
	btn.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 0)
	stroke.Thickness = 0
	stroke.Parent = btn

	btn.MouseButton1Click:Connect(function()
		Config.Color = data.Color
		if selectedColorBtn then
			local old = selectedColorBtn:FindFirstChildOfClass("UIStroke")
			if old then old.Thickness = 0 end
		end
		stroke.Thickness = 2.5
		selectedColorBtn = btn
	end)

	if data.Name == "Preto" then
		stroke.Thickness = 2.5
		selectedColorBtn = btn
	end
end

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.9, 0, 0, 34)
saveBtn.Position = UDim2.new(0.05, 0, 1, -48)
saveBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
saveBtn.Text = "SALVAR"
saveBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 15
saveBtn.BorderSizePixel = 0
saveBtn.Parent = frame

toggle.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

saveBtn.MouseButton1Click:Connect(function()
	Config.Cooldown = tonumber(inputBox.Text) or 2
	frame.Visible = false
end)

-- ==================== TOOL ====================
local function GiveTool()
	local backpack = Player:FindFirstChild("Backpack") or Player:WaitForChild("Backpack", 3)
	if not backpack then return end

	local Tool = Instance.new("Tool")
	Tool.Name = "Bomb"
	Tool.RequiresHandle = false
	Tool.CanBeDropped = false

	local handle = BuildC4(false)
	handle.Parent = Tool

	local animConnection

	Tool.Equipped:Connect(function()
		local char = Player.Character
		if not char then return end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		if animConnection then animConnection:Disconnect() end

		animConnection = RunService.Heartbeat:Connect(function()
			if not Tool or not Tool.Parent then
				if animConnection then animConnection:Disconnect() end
				return
			end
			for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
				local n = track.Name:lower()
				if n:find("tool") or n:find("hold") or n:find("none") then
					track:Stop(0)
				end
			end
		end)
	end)

	Tool.Unequipped:Connect(function()
		if animConnection then
			animConnection:Disconnect()
			animConnection = nil
		end
	end)

	Tool.Activated:Connect(function()
		if not Config.CanUse then return end
		local char = Player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		Config.CanUse = false

		if CurrentDroppedBomb then
			CurrentDroppedBomb:Destroy()
			CurrentDroppedBomb = nil
		end

		local d_handle = BuildC4(true)
		local spawnPos = hrp.Position + Vector3.new(0, -3.15, 0)

		d_handle.CFrame = CFrame.new(spawnPos)
		d_handle.Parent = workspace
		CurrentDroppedBomb = d_handle

		local gyro = Instance.new("BodyGyro")
		gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
		gyro.P = 4000
		gyro.CFrame = CFrame.new(spawnPos)
		gyro.Parent = d_handle

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(0, 1e5, 0)
		bv.Velocity = Vector3.new(0, -28, 0)
		bv.Parent = d_handle
		Debris:AddItem(bv, 0.11)

		task.spawn(function()
			task.wait(0.06)
			if d_handle and d_handle.Parent and gyro and gyro.Parent then
				gyro.CFrame = CFrame.new(d_handle.Position) * CFrame.Angles(math.rad(90), 0, 0)
			end
		end)

		task.wait(Config.Cooldown)

		if CurrentDroppedBomb and CurrentDroppedBomb.Parent then
			local pos = CurrentDroppedBomb.Position
			CurrentDroppedBomb:Destroy()
			CurrentDroppedBomb = nil
			PlayCuteExplosion(pos)
		end

		Config.CanUse = true
	end)

	Tool.Parent = backpack
end

task.spawn(function()
	task.wait(0.3)
	GiveTool()
end)

Player.CharacterAdded:Connect(function()
	task.wait(1)
	GiveTool()
end)
