--====================================================
-- ESP DEBUG HUB
-- LocalScript
-- StarterPlayer > StarterPlayerScripts
--====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

local debrisFolder = workspace:WaitForChild("Debris")
local itemsDroppedFolder = workspace:WaitForChild("ItemsDropped")

--====================================================
-- CONFIG
--====================================================

local MAX_DISTANCE = 400

local settings = {
	Enemy = false,
	Item = false,
	Trap = false,
	Dropped = false,
	Fullbright = false
}

local tracked = {}

--====================================================
-- LIGHTING ORIGINAL
--====================================================

local originalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogStart = Lighting.FogStart,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient
}

--====================================================
-- ATMOSPHERE ORIGINAL
--====================================================

local atmosphereSettings = {}

local function saveAtmosphere(atmosphere)

	if atmosphereSettings[atmosphere] then
		return
	end

	atmosphereSettings[atmosphere] = {
		Density = atmosphere.Density,
		Offset = atmosphere.Offset,
		Color = atmosphere.Color,
		Decay = atmosphere.Decay,
		Glare = atmosphere.Glare,
		Haze = atmosphere.Haze
	}

end

for _, object in ipairs(Lighting:GetChildren()) do
	if object:IsA("Atmosphere") then
		saveAtmosphere(object)
	end
end

Lighting.ChildAdded:Connect(function(object)

	if object:IsA("Atmosphere") then
		saveAtmosphere(object)
	end

end)

--====================================================
-- GUI
--====================================================

local gui = Instance.new("ScreenGui")
gui.Name = "DebugESP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--====================================================
-- BOTÃO PRINCIPAL
--====================================================

local openButton = Instance.new("TextButton")

openButton.Name = "OpenButton"
openButton.Size = UDim2.fromOffset(125, 38)
openButton.Position = UDim2.new(1, -140, 0, 55)

openButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Text = "⚡ ESP HUB"
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 12

openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 10)
openCorner.Parent = openButton

--====================================================
-- PAINEL COMPACTO
--====================================================

local frame = Instance.new("Frame")

frame.Name = "MainFrame"

-- PAINEL MENOR
frame.Size = UDim2.fromOffset(200, 245)

frame.Position = UDim2.new(1, -210, 0, 100)

frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.Visible = false

frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(0, 170, 255)
frameStroke.Thickness = 1.2
frameStroke.Parent = frame

local padding = Instance.new("UIPadding")

padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)

padding.Parent = frame

local layout = Instance.new("UIListLayout")

-- ESPAÇAMENTO MENOR
layout.Padding = UDim.new(0, 5)

layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

layout.Parent = frame

--====================================================
-- DRAG
--====================================================

local function makeDraggable(object)

	local dragging = false
	local dragStart
	local startPosition

	object.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then

			dragging = true
			dragStart = input.Position
			startPosition = object.Position

		end

	end)

	object.InputEnded:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then

			dragging = false

		end

	end)

	UserInputService.InputChanged:Connect(function(input)

		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseMovement then

			return

		end

		local delta = input.Position - dragStart

		object.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,

			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)

	end)

end

makeDraggable(openButton)
makeDraggable(frame)

--====================================================
-- BOTÕES
--====================================================

local function createButton(name, color, callback)

	local button = Instance.new("TextButton")

	-- BOTÃO MENOR
	button.Size = UDim2.fromOffset(175, 32)

	button.BackgroundColor3 =
		Color3.fromRGB(35, 35, 35)

	button.TextColor3 =
		Color3.new(1, 1, 1)

	button.Text =
		name .. " : OFF"

	button.Font =
		Enum.Font.GothamBold

	-- FONTE MENOR
	button.TextSize = 11

	button.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	button.Activated:Connect(function()

		local state = callback()

		if state then

			button.Text =
				name .. " : ON"

			button.BackgroundColor3 =
				color

		else

			button.Text =
				name .. " : OFF"

			button.BackgroundColor3 =
				Color3.fromRGB(35, 35, 35)

		end

	end)

	return button

end

--====================================================
-- ESP INIMIGOS
--====================================================

createButton(
	"👹 ESP INIMIGOS",
	Color3.fromRGB(200, 40, 40),

	function()

		settings.Enemy =
			not settings.Enemy

		return settings.Enemy

	end
)

--====================================================
-- ESP ITENS
--====================================================

createButton(
	"📦 ESP ITENS",
	Color3.fromRGB(0, 120, 255),

	function()

		settings.Item =
			not settings.Item

		return settings.Item

	end
)

--====================================================
-- ESP ARMADILHAS
--====================================================

createButton(
	"⚠️ ESP ARMADILHAS",
	Color3.fromRGB(255, 140, 0),

	function()

		settings.Trap =
			not settings.Trap

		return settings.Trap

	end
)

--====================================================
-- ESP DROPPED
--====================================================

createButton(
	"📦 ESP DROPPED",
	Color3.fromRGB(150, 80, 255),

	function()

		settings.Dropped =
			not settings.Dropped

		return settings.Dropped

	end
)

--====================================================
-- LIMPAR DROPPED
--====================================================

createButton(
	"🧹 LIMPAR DROPPED",
	Color3.fromRGB(100, 60, 150),

	function()

		for object in pairs(tracked) do

			if object:IsDescendantOf(
				itemsDroppedFolder
			) then

				removeESP(object)

			end

		end

		settings.Dropped = false

		return false

	end
)

--====================================================
-- FULLBRIGHT + NOFOG
--====================================================

createButton(
	"💡 FULLBRIGHT + NOFOG",
	Color3.fromRGB(255, 190, 0),

	function()

		settings.Fullbright =
			not settings.Fullbright

		return settings.Fullbright

	end
)

--====================================================
-- ABRIR / FECHAR
--====================================================

openButton.Activated:Connect(function()

	frame.Visible =
		not frame.Visible

end)

--====================================================
-- FULLBRIGHT + NOFOG
--====================================================

RunService.RenderStepped:Connect(function()

	if settings.Fullbright then

		Lighting.Brightness = 5
		Lighting.ClockTime = 14

		Lighting.GlobalShadows = false

		Lighting.Ambient =
			Color3.new(1, 1, 1)

		Lighting.OutdoorAmbient =
			Color3.new(1, 1, 1)

		Lighting.FogStart = 0
		Lighting.FogEnd = 1000000

		for _, effect in ipairs(
			Lighting:GetChildren()
		) do

			if effect:IsA("Atmosphere") then

				effect.Density = 0
				effect.Haze = 0
				effect.Glare = 0
				effect.Offset = 0

			end

		end

	else

		Lighting.Brightness =
			originalLighting.Brightness

		Lighting.ClockTime =
			originalLighting.ClockTime

		Lighting.FogStart =
			originalLighting.FogStart

		Lighting.FogEnd =
			originalLighting.FogEnd

		Lighting.GlobalShadows =
			originalLighting.GlobalShadows

		Lighting.Ambient =
			originalLighting.Ambient

		Lighting.OutdoorAmbient =
			originalLighting.OutdoorAmbient

		for effect, values in pairs(
			atmosphereSettings
		) do

			if effect and effect.Parent then

				effect.Density =
					values.Density

				effect.Offset =
					values.Offset

				effect.Color =
					values.Color

				effect.Decay =
					values.Decay

				effect.Glare =
					values.Glare

				effect.Haze =
					values.Haze

			end

		end

	end

end)

--====================================================
-- ENCONTRAR PARTE
--====================================================

local function getPart(object)

	if object:IsA("BasePart") then
		return object
	end

	return object:FindFirstChild(
		"HumanoidRootPart",
		true
	)
	or object:FindFirstChild(
		"Head",
		true
	)
	or object:FindFirstChildWhichIsA(
		"BasePart",
		true
	)

end

--====================================================
-- DISTÂNCIA
--====================================================

local function isNear(object)

	local character =
		player.Character

	if not character then
		return false
	end

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		return false
	end

	local part =
		getPart(object)

	if not part then
		return false
	end

	return (
		root.Position - part.Position
	).Magnitude <= MAX_DISTANCE

end

--====================================================
-- TIPO
--====================================================

local function getType(object)

	if object:FindFirstChildOfClass(
		"Humanoid"
	) then

		return "Enemy"

	end

	local name =
		string.lower(object.Name)

	if string.find(
		name,
		"trap"
	)
	or string.find(
		name,
		"armadilha"
	)
	or string.find(
		name,
		"spike"
	) then

		return "Trap"

	end

	return "Item"

end

--====================================================
-- FORMATAR VALOR
--====================================================

local function formatValue(value)

	if value == nil then
		return nil
	end

	if typeof(value) == "number" then

		if value % 1 == 0 then

			return tostring(
				math.floor(value)
			)

		end

	end

	return tostring(value)

end

--====================================================
-- TEXTO DO ITEM
--====================================================

local function updateItemText(
	object,
	label
)

	if not object.Parent
		or not label.Parent then

		return

	end

	local lines = {}

	table.insert(
		lines,
		object.Name
	)

	local sellValue =
		object:GetAttribute(
			"SellValue"
		)

	local fuelValue =
		object:GetAttribute(
			"FuelValue"
		)

	if sellValue ~= nil then

		table.insert(
			lines,
			"Sell: $" ..
			formatValue(
				sellValue
			)
		)

	end

	if fuelValue ~= nil then

		table.insert(
			lines,
			"Fuel: " ..
			formatValue(
				fuelValue
			)
		)

	end

	label.Text =
		table.concat(
			lines,
			"\n"
		)

end

--====================================================
-- COR
--====================================================

local function getColor(
	object,
	objectType
)

	if objectType == "Enemy" then

		return Color3.fromRGB(
			255,
			0,
			0
		)

	end

	if objectType == "Trap" then

		return Color3.fromRGB(
			255,
			140,
			0
		)

	end

	local sellValue =
		object:GetAttribute(
			"SellValue"
		)

	local fuelValue =
		object:GetAttribute(
			"FuelValue"
		)

	-- SEM SELL E SEM FUEL
	-- = ROXO

	if sellValue == nil
		and fuelValue == nil then

		return Color3.fromRGB(
			170,
			0,
			255
		)

	end

	-- COM SELL OU FUEL
	-- = AZUL

	return Color3.fromRGB(
		0,
		170,
		255
	)

end

--====================================================
-- CRIAR ESP
--====================================================

local function createESP(object)

	if tracked[object] then
		return
	end

	local objectType =
		getType(object)

	local part =
		getPart(object)

	if not part then
		return
	end

	local color =
		getColor(
			object,
			objectType
		)

	-- HIGHLIGHT

	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"DebugESPHighlight"

	highlight.Adornee =
		object

	highlight.FillColor =
		color

	highlight.FillTransparency =
		0.5

	highlight.OutlineColor =
		Color3.new(
			1,
			1,
			1
		)

	highlight.OutlineTransparency =
		0

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent =
		object

	-- BILLBOARD

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"DebugESPText"

	billboard.Adornee =
		part

	billboard.Size =
		UDim2.fromOffset(
			220,
			80
		)

	billboard.StudsOffset =
		Vector3.new(
			0,
			3,
			0
		)

	billboard.AlwaysOnTop =
		true

	billboard.MaxDistance =
		MAX_DISTANCE

	billboard.Parent =
		gui

	-- LABEL

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.fromScale(
			1,
			1
		)

	label.BackgroundTransparency =
		1

	label.TextColor3 =
		color

	label.TextStrokeColor3 =
		Color3.new(
			0,
			0,
			0
		)

	label.TextStrokeTransparency =
		0.2

	label.Font =
		Enum.Font.GothamBold

	label.TextSize =
		14

	label.TextWrapped =
		true

	label.TextYAlignment =
		Enum.TextYAlignment.Center

	label.Parent =
		billboard

	-- INIMIGO

	local healthConnection

	if objectType == "Enemy" then

		local humanoid =
			object:FindFirstChildOfClass(
				"Humanoid"
			)

		if humanoid then

			local function updateHealth()

				if label.Parent then

					label.Text =
						object.Name ..
						"\nHP: " ..
						math.floor(
							humanoid.Health
						)

				end

			end

			updateHealth()

			healthConnection =
				humanoid.HealthChanged:Connect(
					updateHealth
				)

		else

			label.Text =
				object.Name

		end

	else

		-- ITEM / DROPPED

		updateItemText(
			object,
			label
		)

	end

	-- ATTRIBUTES

	local sellConnection
	local fuelConnection

	if objectType == "Item" then

		sellConnection =
			object:GetAttributeChangedSignal(
				"SellValue"
			):Connect(function()

				updateItemText(
					object,
					label
				)

			end)

		fuelConnection =
			object:GetAttributeChangedSignal(
				"FuelValue"
			):Connect(function()

				updateItemText(
					object,
					label
				)

			end)

	end

	tracked[object] = {

		highlight = highlight,
		billboard = billboard,
		label = label,

		healthConnection =
			healthConnection,

		sellConnection =
			sellConnection,

		fuelConnection =
			fuelConnection

	}

end

--====================================================
-- REMOVER ESP
--====================================================

function removeESP(object)

	local data =
		tracked[object]

	if not data then
		return
	end

	if data.healthConnection then
		data.healthConnection:Disconnect()
	end

	if data.sellConnection then
		data.sellConnection:Disconnect()
	end

	if data.fuelConnection then
		data.fuelConnection:Disconnect()
	end

	if data.highlight then
		data.highlight:Destroy()
	end

	if data.billboard then
		data.billboard:Destroy()
	end

	tracked[object] = nil

end

--====================================================
-- ATUALIZAR ESP
--====================================================

local function updateExistingESP(object)

	local data =
		tracked[object]

	if not data then
		return
	end

	local objectType =
		getType(object)

	local newColor =
		getColor(
			object,
			objectType
		)

	if data.highlight then

		data.highlight.FillColor =
			newColor

	end

	if data.label then

		data.label.TextColor3 =
			newColor

	end

	if objectType == "Item" then

		updateItemText(
			object,
			data.label
		)

	end

end

--====================================================
-- DEBRIS
--====================================================

local function processDebris()

	for _, object in ipairs(
		debrisFolder:GetChildren()
	) do

		local objectType =
			getType(object)

		if settings[objectType]
			and isNear(object) then

			createESP(object)
			updateExistingESP(object)

		else

			removeESP(object)

		end

	end

end

--====================================================
-- ITEMS DROPPED
--====================================================

local function processDropped()

	for _, object in ipairs(
		itemsDroppedFolder:GetChildren()
	) do

		if settings.Dropped
			and isNear(object) then

			createESP(object)
			updateExistingESP(object)

		else

			removeESP(object)

		end

	end

end

--====================================================
-- LOOP
--====================================================

RunService.Heartbeat:Connect(function()

	processDebris()

	processDropped()

	for object in pairs(tracked) do

		if not object.Parent then
			removeESP(object)
		end

	end

end)

--====================================================
-- FIM
--====================================================
