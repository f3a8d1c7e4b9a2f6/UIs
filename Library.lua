if not game:IsLoaded() then
    game.Loaded:Wait()
end

if setfpscap then
    setfpscap(math.huge)
end

local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

local Services = setmetatable({}, { ---. credits to infinite yield!
    __index = function(self, name)
        local service
        local success, err = pcall(function()
            service = game:GetService(name)
        end)
        if success and service then
            rawset(self, name, service)
            return service
        else
            warn("[Services] Service not available: " .. tostring(name))
            local dummy = {}
            rawset(self, name, dummy)
            return dummy
        end
    end
})

local CoreGui: CoreGui = Services.CoreGui
local Lighting: Lighting = Services.Lighting
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local SoundService: SoundService = Services.SoundService
local UserInputService: UserInputService = Services.UserInputService
local TextService: TextService = Services.TextService
local Teams: Teams = Services.Teams
local TweenService: TweenService = Services.TweenService
local Workspace: Workspace = Services.Workspace
local Mouse = Players.LocalPlayer:GetMouse()
    
local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() 
    return CoreGui 
end

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}

local Library = {
    LocalPlayer = LocalPlayer,
    DevicePlatform = nil,
    IsMobile = false,

    ScreenGui = nil,
    MainFrame = nil,

    ActiveTab = nil,
    Tabs = {},
    TabOrder = {},

    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    Notifications = {},

    ToggleKeybind = Enum.KeyCode.RightControl,
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    Toggled = false,
    Unloaded = false,

    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    NotifySide = "Right",
    ShowCustomCursor = true,
    CustomCursorId = 4827658474,
    CustomCursorSize = 65,
    CustomCursorAnchorPoint = Vector2.new(0.08, 0.05),
    SmoothDragging = true,
    ForceCheckbox = false,
    ShowToggleFrameInKeybinds = true,
    HideGroupboxOutlines = false,
    GroupboxTransparency = 0,
    ChangeGroupboxOutlineSize = false,
    GroupboxOutlineSize = 2,
    SnowMouseEnabled = false,
    SnowMouseConnection = nil,
    SnowMouseLayer = nil,
    SnowMouseParticles = {},
    NotifyOnError = false,

    CantDragForced = false,

    Signals = {},
    UnloadSignals = {},

    MinSize = Vector2.new(480, 360),
    BaseMinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 4,

    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(255, 65, 65),
        MainColor = Color3.fromRGB(255, 65, 65),
        AccentColor = Color3.fromRGB(255, 65, 65),
        OutlineColor = Color3.fromRGB(255, 65, 65),
        FontColor = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.Code),

        Red = Color3.fromRGB(255, 50, 50),
        Dark = Color3.new(0, 0, 0),
        White = Color3.new(1, 1, 1),
    },

    Registry = {},
    DPIRegistry = {},
    BoxOutlineHolders = {},
    GroupboxBackgrounds = {},
    RainbowColorPickers = {},
    RainbowColorPickerConnection = nil,
    RefreshScaledLayouts = nil,
    ScaledLayoutRefreshQueued = false,
    IsResizingWindow = false,
    PendingScaledLayoutRefresh = false,

    CustomImageState = {
        Mode = "Background",
        AssetId = "6057464206",
        Transparency = 0.78,
        Enabled = false,
        Backing = nil,
        Label = nil,
    },
}

if RunService:IsStudio() then 
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.MinSize = Vector2.new(480, 240)
        Library.BaseMinSize = Library.MinSize
    else
        Library.IsMobile = false
        Library.MinSize = Vector2.new(480, 360)
        Library.BaseMinSize = Library.MinSize
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)
    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.MinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
    Library.BaseMinSize = Library.MinSize
end

local Templates = {
    --// UI \\-
    Frame = {
        BorderSizePixel = 0,

        BackgroundTransparency = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },
    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 600), ---720, 600
        IconSize = UDim2.fromOffset(30, 30),
        AutoShow = true,
        Center = true,
        Resizable = true,
        CornerRadius = 9,
        NotifySide = "Right",
        ShowCustomCursor = false,
        Font = Enum.Font.Jura,
        ToggleKeybind = Enum.KeyCode.RightControl,
        MobileButtonsSide = "Left",
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Beta = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Step = nil,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        Multi = false,
        MaxVisibleDropdownItems = 8,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",
        Default = "None",
        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),
        UsePaintIcon = false,
        Icon = "",

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}

--// Basic Functions \\--
local function ApplyDPIScale(Dimension, ExtraOffset)
    if typeof(Dimension) == "UDim" then
        return UDim.new(Dimension.Scale, Dimension.Offset * Library.DPIScale)
    end

    if ExtraOffset then
        return UDim2.new(
            Dimension.X.Scale,
            (Dimension.X.Offset * Library.DPIScale) + (ExtraOffset[1] * Library.DPIScale),
            Dimension.Y.Scale,
            (Dimension.Y.Offset * Library.DPIScale) + (ExtraOffset[2] * Library.DPIScale)
        )
    end

    return UDim2.new(
        Dimension.X.Scale,
        Dimension.X.Offset * Library.DPIScale,
        Dimension.Y.Scale,
        Dimension.Y.Offset * Library.DPIScale
    )
end
local function ApplyTextScale(TextSize)
    return TextSize * Library.DPIScale
end
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)
    return Bindable.Event:Wait()
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return (
        Input.UserInputType == Enum.UserInputType.MouseButton1
            or IncludeM2 and Input.UserInputType == Enum.UserInputType.MouseButton2
            or Input.UserInputType == Enum.UserInputType.Touch
    ) and Input.UserInputState == Enum.UserInputState.Begin
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in pairs(Table) do
        Size += 1
    end

    return Size
end
local function StopTween(Tween: TweenBase)
    if not (Tween and Tween.PlaybackState == Enum.PlaybackState.Playing) then
        return
    end

    Tween:Cancel()
end
local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateKeybindFrame()
    if not Library.KeybindFrame then
        return
    end

    local XSize = 0
    if Library.KeybindTitle then
        local TitleX = Library:GetTextBounds(Library.KeybindTitle.Text, Library.KeybindTitle.FontFace, Library.KeybindTitle.TextSize)
        XSize = math.max(XSize, TitleX)
    end

    for _, KeybindToggle in pairs(Library.KeybindToggles) do
        if not KeybindToggle.Holder.Visible then
            continue
        end

        local FullSize = KeybindToggle.FullWidth or (KeybindToggle.Label.Size.X.Offset + KeybindToggle.Label.Position.X.Offset)
        if FullSize > XSize then
            XSize = FullSize
        end
    end

    Library.KeybindFrame.Size = UDim2.fromOffset(math.max(138 * Library.DPIScale, XSize + 28 * Library.DPIScale), 0)
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in pairs(Library.Registry) do
        for Property, ColorIdx in pairs(Properties) do
            if typeof(ColorIdx) == "string" then
                Instance[Property] = Library.Scheme[ColorIdx]
            elseif typeof(ColorIdx) == "function" then
                Instance[Property] = ColorIdx()
            end
        end
    end
end

function Library:UpdateDPI(Instance, Properties)
    if not Library.DPIRegistry[Instance] then
        return
    end

    for Property, Value in pairs(Properties) do
        Library.DPIRegistry[Instance][Property] = Value and Value or nil
    end
end

function Library.RefreshScaledLayouts()
    for _, Option in pairs(Options) do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
        elseif Option.Type == "KeyPicker" then
            Option:Update()
        elseif Option.Type == "ColorPicker" and Option.Display then
            Option:Display()
        elseif Option.Type == "Slider" and Option.Display then
            Option:Display()
        end
    end

    for _, Toggle in pairs(Toggles) do
        if Toggle.RefreshAccessoryLayout then
            Toggle:RefreshAccessoryLayout()
        elseif Toggle.RefreshRiskyIconPosition then
            Toggle:RefreshRiskyIconPosition()
        end
    end

    for _, Tab in pairs(Library.Tabs) do
        if Tab.IsKeyTab then
            continue
        end

        Tab:Resize(true)
        for _, Groupbox in pairs(Tab.Groupboxes) do
            Groupbox:Resize()
        end
        for _, Tabbox in pairs(Tab.Tabboxes) do
            if Tabbox.RefreshNavigation then
                Tabbox:RefreshNavigation()
            end
            for _, SubTab in pairs(Tabbox.Tabs) do
                SubTab:Resize()
            end
        end
    end

    Library:UpdateKeybindFrame()
    for _, Notification in pairs(Library.Notifications) do
        Notification:Resize()
    end
end

function Library:QueueScaledLayoutRefresh()
    if Library.Unloaded then
        return
    end

    local Refresh = Library.RefreshScaledLayouts
    if not Refresh then
        return
    end

    if Library.IsResizingWindow then
        Library.PendingScaledLayoutRefresh = true
        return
    end

    Refresh()
    if Library.ScaledLayoutRefreshQueued then
        return
    end

    Library.ScaledLayoutRefreshQueued = true
    task.defer(Refresh)
    task.spawn(function()
        RunService.RenderStepped:Wait()
        Library.ScaledLayoutRefreshQueued = false
        if Library.Unloaded then
            return
        end

        Refresh()
    end)
end

function Library:SetDPIScale(DPIScale: any)
    local ParsedDPI = DPIScale
    if typeof(ParsedDPI) == "string" then
        ParsedDPI = tonumber((ParsedDPI:gsub("%%", "")))
    end
    if not ParsedDPI then
        return
    end

    local PreviousMainCenter
    if Library.MainFrame then
        PreviousMainCenter = Library.MainFrame.AbsolutePosition + (Library.MainFrame.AbsoluteSize / 2)
    end

    Library.DPIScale = ParsedDPI / 100
    Library.MinSize = Library.BaseMinSize * Library.DPIScale

    for Instance, Properties in pairs(Library.DPIRegistry) do
        for Property, Value in pairs(Properties) do
            if Property == "DPIExclude" or Property == "DPIOffset" then
                continue
            elseif Property == "TextSize" then
                Instance[Property] = ApplyTextScale(Value)
            else
                local DPIOffset = Properties["DPIOffset"] or {}
                Instance[Property] = ApplyDPIScale(Value, DPIOffset[Property])
            end
        end
    end

    if PreviousMainCenter and Library.MainFrame then
        local ViewportSize = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(0, 0)
        local MainSize = Library.MainFrame.AbsoluteSize
        local MaxPosition = Vector2.new(
            math.max(0, ViewportSize.X - MainSize.X),
            math.max(0, ViewportSize.Y - MainSize.Y)
        )
        local NewPosition = Vector2.new(
            math.clamp(PreviousMainCenter.X - (MainSize.X / 2), 0, MaxPosition.X),
            math.clamp(PreviousMainCenter.Y - (MainSize.Y / 2), 0, MaxPosition.Y)
        )

        Library.MainFrame.Position = UDim2.fromOffset(NewPosition.X, NewPosition.Y)
    end

    for _, Tab in pairs(Library.Tabs) do
        if Tab.IsKeyTab then
            continue
        end

        Tab:Resize(true)
        for _, Groupbox in pairs(Tab.Groupboxes) do
            Groupbox:Resize()
        end
        for _, Tabbox in pairs(Tab.Tabboxes) do
            for _, SubTab in pairs(Tabbox.Tabs) do
                SubTab:Resize()
            end
        end
    end

    for _, Option in pairs(Options) do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
        elseif Option.Type == "KeyPicker" then
            Option:Update()
        end
    end

    Library:UpdateKeybindFrame()
    for _, Notification in pairs(Library.Notifications) do
        Notification:Resize()
    end

    Library:QueueScaledLayoutRefresh()
end

local acrylicBlurEnabled = false
local acrylicBlurModel: Part? = nil
local acrylicDepthOfField: DepthOfFieldEffect? = nil
local acrylicDepthDefaults = {}
local acrylicDepthDefaultsLoaded = false
local acrylicBlurDistance = 0.001
local acrylicUpdateConnections = {}

local function MapRange(Value, InMin, InMax, OutMin, OutMax)
    return (Value - InMin) * (OutMax - OutMin) / (InMax - InMin) + OutMin
end

local function ViewportPointToWorld(Camera: Camera, Point: Vector2, Distance: number)
    local UnitRay = Camera:ScreenPointToRay(Point.X, Point.Y)
    return UnitRay.Origin + UnitRay.Direction * Distance
end

local function GetAcrylicOffset()
    local camera = Workspace.CurrentCamera
    if not camera then
        return 8
    end
    return MapRange(camera.ViewportSize.Y, 0, 2560, 8, 56)
end

local function ClearAcrylicConnections()
    for i = #acrylicUpdateConnections, 1, -1 do
        local c = table.remove(acrylicUpdateConnections, i)
        pcall(function()
            c:Disconnect()
        end)
    end
end

local function EnsureAcrylicModel()
    if acrylicBlurModel and acrylicBlurModel.Parent then
        return acrylicBlurModel
    end

    local camera = Workspace.CurrentCamera
    if not camera then
        return nil
    end

    local part = Instance.new("Part")
    part.Name = "ZalStoreAcrylicBlurPart"
    part.Color = Color3.new(0, 0, 0)
    part.Material = Enum.Material.Glass
    part.Size = Vector3.new(1, 1, 0)
    part.Anchored = true
    part.CanCollide = false
    part.Locked = true
    part.CastShadow = false
    part.Transparency = 1
    part.Parent = camera

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Brick
    mesh.Offset = Vector3.new(0, 0, -0.000001)
    mesh.Parent = part

    acrylicBlurModel = part
    return acrylicBlurModel
end

local function UpdateAcrylicBlur()
    local model = EnsureAcrylicModel()
    if not model then
        return
    end

    local mainFrame = Library.MainFrame
    if not acrylicBlurEnabled or not mainFrame or not mainFrame.Visible then
        model.Transparency = 1
        return
    end

    local camera = Workspace.CurrentCamera
    if not camera then
        model.Transparency = 1
        return
    end
    if model.Parent ~= camera then
        model.Parent = camera
    end

    local offset = math.clamp(GetAcrylicOffset(), 8, 56)
    local size = mainFrame.AbsoluteSize - Vector2.new(offset, offset)
    local position = mainFrame.AbsolutePosition + Vector2.new(offset * 0.5, offset * 0.5)
    if size.X <= 1 or size.Y <= 1 then
        model.Transparency = 1
        return
    end

    local topLeft = position
    local topRight = position + Vector2.new(size.X, 0)
    local bottomRight = position + size

    local topLeft3D = ViewportPointToWorld(camera, topLeft, acrylicBlurDistance)
    local topRight3D = ViewportPointToWorld(camera, topRight, acrylicBlurDistance)
    local bottomRight3D = ViewportPointToWorld(camera, bottomRight, acrylicBlurDistance)

    local width = (topRight3D - topLeft3D).Magnitude
    local height = (topRight3D - bottomRight3D).Magnitude

    model.CFrame = CFrame.fromMatrix(
        (topLeft3D + bottomRight3D) / 2,
        camera.CFrame.XVector,
        camera.CFrame.YVector,
        camera.CFrame.ZVector
    )
    local mesh = model:FindFirstChildOfClass("SpecialMesh")
    if mesh then
        mesh.Scale = Vector3.new(width, height, 0)
    end
    model.Transparency = 0.98
end

local function EnsureAcrylicDepthDefaults()
    if acrylicDepthDefaultsLoaded then
        return
    end
    acrylicDepthDefaultsLoaded = true

    local function register(container)
        if not container then
            return
        end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("DepthOfFieldEffect") then
                acrylicDepthDefaults[child] = child.Enabled
            end
        end
    end

    register(Lighting)
    register(Workspace.CurrentCamera)
end

local function EnableAcrylicDepthOfField()
    EnsureAcrylicDepthDefaults()
    for effect, _ in pairs(acrylicDepthDefaults) do
        if effect and effect.Parent then
            effect.Enabled = false
        end
    end

    if not acrylicDepthOfField or not acrylicDepthOfField.Parent then
        acrylicDepthOfField = Instance.new("DepthOfFieldEffect")
        acrylicDepthOfField.Name = "ZalStoreAcrylicDOF"
        acrylicDepthOfField.FarIntensity = 0
        acrylicDepthOfField.InFocusRadius = 0.1
        acrylicDepthOfField.NearIntensity = 1
    end
    acrylicDepthOfField.Parent = Lighting
end

local function DisableAcrylicDepthOfField()
    if acrylicDepthOfField then
        acrylicDepthOfField.Parent = nil
    end
    for effect, wasEnabled in pairs(acrylicDepthDefaults) do
        if effect and effect.Parent then
            effect.Enabled = wasEnabled == true
        end
    end
end

local function SetAcrylicBlurEnabled(enabled)
    acrylicBlurEnabled = enabled == true
    if acrylicBlurEnabled then
        EnableAcrylicDepthOfField()
        ClearAcrylicConnections()

        local camera = Workspace.CurrentCamera
        local mainFrame = Library.MainFrame
        if camera then
            table.insert(acrylicUpdateConnections, camera:GetPropertyChangedSignal("CFrame"):Connect(UpdateAcrylicBlur))
            table.insert(acrylicUpdateConnections, camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateAcrylicBlur))
            table.insert(acrylicUpdateConnections, camera:GetPropertyChangedSignal("FieldOfView"):Connect(UpdateAcrylicBlur))
        end
        if mainFrame then
            table.insert(acrylicUpdateConnections, mainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateAcrylicBlur))
            table.insert(acrylicUpdateConnections, mainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateAcrylicBlur))
            table.insert(acrylicUpdateConnections, mainFrame:GetPropertyChangedSignal("Visible"):Connect(UpdateAcrylicBlur))
        end
        UpdateAcrylicBlur()
    else
        ClearAcrylicConnections()
        DisableAcrylicDepthOfField()
        if acrylicBlurModel then
            acrylicBlurModel:Destroy()
            acrylicBlurModel = nil
        end
    end
end

function Library:SetTransparency(Value: number)
    Value = math.clamp(Value or 0, 0, 1)
    Library.MenuTransparency = Value
    Library._TransparencyCache = Library._TransparencyCache or {}
    local Cache = Library._TransparencyCache

    local function ApplyToObject(Obj: Instance?)
        if not Obj or not Obj:IsA("GuiObject") or Obj:GetAttribute("ExcludeMenuTransparency") or Obj.BackgroundTransparency >= 1 then
            return
        end

        if Value == 0 then
            local Original = Cache[Obj]
            if Original ~= nil then
                Obj.BackgroundTransparency = Original
                Cache[Obj] = nil
            end
        else
            if Cache[Obj] == nil then
                Cache[Obj] = Obj.BackgroundTransparency
            end
            Obj.BackgroundTransparency = Value
        end
    end

    local function ApplyToRoot(Root: Instance?)
        if not Root then
            return
        end

        ApplyToObject(Root)
        for _, Obj in ipairs(Root:GetDescendants()) do
            ApplyToObject(Obj)
        end
    end

    local Main = Library.ScreenGui and Library.ScreenGui:FindFirstChild("Main")
    ApplyToRoot(Main)
    ApplyToRoot(Library.KeybindFrame)
    SetAcrylicBlurEnabled(Value > 0)

    for _, Toggle in pairs(Library.Toggles) do
        if Toggle and Toggle.Display then
            Toggle:Display()
        end
    end

    for _, Option in pairs(Library.Options) do
        if Option then
            if Option.UpdateColors then
                Option:UpdateColors()
            end
            if Option.Display then
                Option:Display()
            end
        end
    end

    if Library.ApplyBoxOutlineVisibility then
        Library:ApplyBoxOutlineVisibility()
    end

    if Library.ApplyGroupboxTransparency then
        Library:ApplyGroupboxTransparency()
    end

    for _, Tab in pairs(Library.Tabs) do
        if Tab and Tab.Tabboxes then
            for _, Tabbox in pairs(Tab.Tabboxes) do
                if Tabbox.RefreshTabButtons then
                    Tabbox:RefreshTabButtons()
                end
            end
        end
    end
end

function Library:GiveSignal(Connection: RBXScriptConnection)
    table.insert(Library.Signals, Connection)
    return Connection
end

local FetchIcons, Icons = pcall(function()
    return loadstring(
        game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")
    )()
end)
function Library:GetIcon(IconName: string)
    if not FetchIcons then
        return
    end
    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end
    return Icon
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in pairs(Template) do
        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}
    local DPIProperties = Library.DPIRegistry[Instance] or {}

    local DPIExclude = DPIProperties["DPIExclude"] or Table["DPIExclude"] or {}
    local DPIOffset = DPIProperties["DPIOffset"] or Table["DPIOffset"] or {}

    for k, v in pairs(Table) do
        if k == "DPIExclude" or k == "DPIOffset" then
            continue
        elseif Library.Scheme[v] or typeof(v) == "function" then
            ThemeProperties[k] = v
            Instance[k] = Library.Scheme[v] or v()
            continue
        elseif ThemeProperties[k] then
            ThemeProperties[k] = nil
        end

        if not DPIExclude[k] then
            if k == "Position" or k == "Size" or k:match("Padding") then
                DPIProperties[k] = v
                v = ApplyDPIScale(v, DPIOffset[k])
            elseif k == "TextSize" then
                DPIProperties[k] = v
                v = ApplyTextScale(v)
            end
        end

        Instance[k] = v
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
    if GetTableSize(DPIProperties) > 0 then
        DPIProperties["DPIExclude"] = DPIExclude
        DPIProperties["DPIOffset"] = DPIOffset
        Library.DPIRegistry[Instance] = DPIProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
end

--// Main Instances \\-
local function ParentUI(UI: Instance)
    pcall(protectgui, UI);

    if not pcall(function()
            UI.Parent = gethui()
        end) then
        UI.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local ScreenGui = New("ScreenGui", {
    Name = "F9Console",
    DisplayOrder = 999,
    ResetOnSpawn = false,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui
ScreenGui.DescendantRemoving:Connect(function(Instance)
    Library:RemoveFromRegistry(Instance)
    Library.DPIRegistry[Instance] = nil
    Library.BoxOutlineHolders[Instance] = nil
    Library.GroupboxBackgrounds[Instance] = nil
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Cursor
local Cursor
local CursorThicknessLayers = {}
do
    Cursor = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.4, 0.4),
        BackgroundTransparency = 1,
        ImageColor3 = "AccentColor",
        Image = "rbxassetid://4827658474",
        Size = UDim2.fromOffset(Library.CustomCursorSize, Library.CustomCursorSize),
        Visible = false,
        ZIndex = 999,
        Parent = ScreenGui,
    })

    for _ = 1, 4 do
        table.insert(CursorThicknessLayers, New("ImageLabel", {
            AnchorPoint = Vector2.new(0.4, 0.4),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.new(1, 1, 1),
            Image = Cursor.Image,
            Size = Cursor.Size,
            Visible = false,
            ZIndex = 998,
            Parent = ScreenGui,
        }))
    end
end
--// Notification
local NotificationArea
local NotificationList
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        Parent = ScreenGui,
    })
    NotificationList = New("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 6),
        Parent = NotificationArea,
    })
end
--// Lib Functions \\--
function Library:CustomImage(State)
    local CustomImageState = self.CustomImageState

    if type(State) == "boolean" then
        CustomImageState.Enabled = State
    elseif type(State) == "table" then
        if State.Enabled ~= nil then
            CustomImageState.Enabled = State.Enabled
        end
        if State.Mode ~= nil then
            CustomImageState.Mode = State.Mode
        end
        if State.AssetId ~= nil then
            CustomImageState.AssetId = State.AssetId
        end
        if State.Transparency ~= nil then
            CustomImageState.Transparency = State.Transparency
        end
    end

    local mainFrame = self.MainFrame
    if not mainFrame then
        return CustomImageState
    end

    local imageParent = self.CustomImageLayer or mainFrame
    imageParent.Position = UDim2.fromOffset(0, 0)
    imageParent.Size = UDim2.fromScale(1, 1)
    if imageParent:IsA("GuiObject") then
        imageParent.BackgroundTransparency = 1
        imageParent.ZIndex = 1
    end

    if not CustomImageState.Backing then
        CustomImageState.Backing = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Name = "CustomImageBacking",
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = imageParent,
        })
        CustomImageState.Backing:SetAttribute("ExcludeMenuTransparency", true)
        New("UICorner", {
            CornerRadius = UDim.new(0, self.CornerRadius - 1),
            Parent = CustomImageState.Backing,
        })
    elseif CustomImageState.Backing.Parent ~= imageParent then
        CustomImageState.Backing.Parent = imageParent
    end

    if not CustomImageState.Label then
        CustomImageState.Label = New("ImageLabel", {
            BackgroundTransparency = 1,
            Name = "CustomImageBackground",
            Position = UDim2.fromOffset(0, 0),
            ScaleType = Enum.ScaleType.Crop,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = imageParent,
        })
        CustomImageState.Label:SetAttribute("ExcludeMenuTransparency", true)
        New("UICorner", {
            CornerRadius = UDim.new(0, self.CornerRadius - 1),
            Parent = CustomImageState.Label,
        })
    elseif CustomImageState.Label.Parent ~= imageParent then
        CustomImageState.Label.Parent = imageParent
    end

    local cleanId = tostring(CustomImageState.AssetId or ""):match("%d+")
    if not cleanId then
        cleanId = "6057464206"
    end

    CustomImageState.Label.Image = "rbxassetid://" .. cleanId
    CustomImageState.Label.Visible = CustomImageState.Enabled
    CustomImageState.Label.Position = UDim2.fromOffset(0, 0)
    CustomImageState.Label.Size = UDim2.fromScale(1, 1)
    CustomImageState.Backing.BackgroundTransparency = 1
    CustomImageState.Backing.Visible = false
    CustomImageState.Backing.Position = UDim2.fromOffset(0, 0)
    CustomImageState.Backing.Size = UDim2.fromScale(1, 1)

    if CustomImageState.Enabled and CustomImageState.Mode == "Background" then
        CustomImageState.Backing.ZIndex = 1
        CustomImageState.Label.ZIndex = 1
    else
        CustomImageState.Label.ZIndex = 50
    end
    CustomImageState.Label.ImageTransparency = CustomImageState.Transparency

    return CustomImageState
end

function Library:ClearSnowMouse()
    if Library.SnowMouseConnection then
        Library.SnowMouseConnection:Disconnect()
        Library.SnowMouseConnection = nil
    end

    for Particle in pairs(Library.SnowMouseParticles) do
        if Particle and Particle.Parent then
            Particle:Destroy()
        end
        Library.SnowMouseParticles[Particle] = nil
    end

    if Library.SnowMouseLayer then
        Library.SnowMouseLayer.Visible = false
    end
end

function Library:EmitSnowMouseParticle(Position: Vector2)
    if not Library.SnowMouseLayer then
        Library.SnowMouseLayer = New("Frame", {
            BackgroundTransparency = 1,
            Name = "SnowMouseLayer",
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(1, 1),
            ZIndex = 997,
            Parent = ScreenGui,
        })
    end

    Library.SnowMouseLayer.Visible = true

    local Size = math.random(3, 6)
    local StartX = Position.X + math.random(-10, 10)
    local StartY = Position.Y + math.random(-8, 8)
    local Particle = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(245, 250, 255),
        BackgroundTransparency = math.random(0, 25) / 100,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(StartX, StartY),
        Size = UDim2.fromOffset(Size, Size),
        ZIndex = 997,
        Parent = Library.SnowMouseLayer,
    })
    Particle:SetAttribute("ExcludeMenuTransparency", true)

    New("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = Particle,
    })

    Library.SnowMouseParticles[Particle] = true

    local Duration = math.random(55, 90) / 100
    local EndPosition = UDim2.fromOffset(StartX + math.random(-18, 18), StartY + math.random(22, 42))
    local Tween = TweenService:Create(Particle, TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
        Position = EndPosition,
        Size = UDim2.fromOffset(math.max(1, Size - 2), math.max(1, Size - 2)),
    })

    Tween.Completed:Connect(function()
        Library.SnowMouseParticles[Particle] = nil
        if Particle and Particle.Parent then
            Particle:Destroy()
        end
    end)

    Tween:Play()
end

function Library:SetSnowMouse(Enabled: boolean)
    Library.SnowMouseEnabled = Enabled == true

    if not Library.SnowMouseEnabled then
        Library:ClearSnowMouse()
        return
    end

    if Library.SnowMouseConnection then
        Library.SnowMouseConnection:Disconnect()
        Library.SnowMouseConnection = nil
    end

    local EmitTimer = 0
    Library.SnowMouseConnection = RunService.RenderStepped:Connect(function(DeltaTime)
        if not Library.SnowMouseEnabled then
            Library:ClearSnowMouse()
            return
        end

        EmitTimer += DeltaTime
        if EmitTimer < 0.035 then
            return
        end
        EmitTimer = 0

        local MousePosition = UserInputService:GetMouseLocation()
        Library:EmitSnowMouseParticle(Vector2.new(MousePosition.X, MousePosition.Y - 36))
    end)
end

function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:UseCursor(CursorId)
    if CursorId == nil or CursorId == "" then
        return
    end

    local ParsedCursorId = tostring(CursorId):gsub("rbxassetid://", "")
    Library.CustomCursorId = ParsedCursorId

    if Cursor then
        Cursor.Image = "rbxassetid://" .. ParsedCursorId
    end

    for _, Layer in ipairs(CursorThicknessLayers) do
        Layer.Image = "rbxassetid://" .. ParsedCursorId
    end
end

function Library:SetCursorSize(Size)
    if Size == nil then
        return
    end

    local ParsedSize = math.max(1, tonumber(Size) or Library.CustomCursorSize or 65)
    Library.CustomCursorSize = ParsedSize

    if Cursor then
        Cursor.Size = UDim2.fromOffset(ParsedSize, ParsedSize)
    end

    for _, Layer in ipairs(CursorThicknessLayers) do
        Layer.Size = UDim2.fromOffset(ParsedSize, ParsedSize)
    end
end

function Library:SetCursorThickness(Thickness)
    if Thickness == nil then
        return
    end

    Library.CustomCursorThickness = math.max(0, tonumber(Thickness) or 0)
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size
    Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32

    local Bounds = TextService:GetTextBoundsAsync(Params)
    return Bounds.X, Bounds.Y
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Success, Response = pcall(Func, ...)
    if Success then
        return Response
    end

    local Traceback = debug.traceback():gsub("\n", " ")
    local _, i = Traceback:find(":%d+ ")
    Traceback = Traceback:sub(i + 1):gsub(" :", ":")

    task.defer(error, Response .. " - " .. Traceback)
    if Library.NotifyOnError then
        Library:Notify(Response)
    end
end

function Library:MakeDraggable(UI: GuiObject, DragFrame: GuiObject, IgnoreToggled: boolean?, IsMainWindow: boolean?)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local DragTween
    DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            StopTween(DragTween)
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)
    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            StopTween(DragTween)
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            local NewPosition = UDim2.new(
                FramePos.X.Scale,
                FramePos.X.Offset + Delta.X,
                FramePos.Y.Scale,
                FramePos.Y.Offset + Delta.Y
            )

            if Library.SmoothDragging then
                StopTween(DragTween)
                DragTween = TweenService:Create(UI, TweenInfo.new(0.111, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = NewPosition,
                })
                DragTween:Play()
            else
                UI.Position = NewPosition
            end
        end
    end))
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: ((boolean?) -> ())?)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed
    local CallbackQueued = false
    local PendingSize
    local SizeQueued = false

    local function QueueResizeCallback(IsFinal: boolean?)
        if not Callback then
            return
        end

        if IsFinal then
            CallbackQueued = false
            Library:SafeCallback(Callback, true)
            return
        end

        if CallbackQueued then
            return
        end

        CallbackQueued = true
        task.spawn(function()
            RunService.RenderStepped:Wait()
            CallbackQueued = false
            if Dragging and not Library.Unloaded and UI.Visible and ScreenGui and ScreenGui.Parent then
                Library:SafeCallback(Callback, false)
            end
        end)
    end

    local function QueueResizeApply(IsFinal: boolean?)
        if IsFinal then
            SizeQueued = false
            if PendingSize then
                UI.Size = PendingSize
                PendingSize = nil
            end
            QueueResizeCallback(true)
            return
        end

        if SizeQueued then
            return
        end

        SizeQueued = true
        task.spawn(function()
            RunService.RenderStepped:Wait()
            SizeQueued = false
            if not Dragging or Library.Unloaded or not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
                return
            end

            if PendingSize then
                UI.Size = PendingSize
                PendingSize = nil
            end
            QueueResizeCallback(false)
        end)
    end

    DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true
        Library.IsResizingWindow = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            Library.IsResizingWindow = false
            Library.PendingScaledLayoutRefresh = false
            QueueResizeApply(true)
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)
    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            local WasDragging = Dragging
            Dragging = false
            Library.IsResizingWindow = false
            Library.PendingScaledLayoutRefresh = false
            if WasDragging then
                QueueResizeApply(true)
            end
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            PendingSize = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            QueueResizeApply(false)
        end
    end))
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = Info.Color or "OutlineColor",
        Position = Info.Position,
        Size = Info.Size,
        Parent = Frame,
    })

    return Line
end

function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    local Holder = New("Frame", {
        Name = "OutlineHolder",
        BackgroundColor3 = "Dark",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        Name = "Outline",
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder
end

function Library:ApplyBoxOutlineVisibility()
    local Hidden = Library.HideGroupboxOutlines == true
    local VisibleTransparency = (Library.MenuTransparency and Library.MenuTransparency > 0) and Library.MenuTransparency or 0

    for Holder in pairs(Library.BoxOutlineHolders) do
        if not Holder or not Holder.Parent then
            Library.BoxOutlineHolders[Holder] = nil
            continue
        end

        Holder.BackgroundTransparency = Hidden and 1 or VisibleTransparency

        local Outline = Holder:FindFirstChild("Outline")
        if Outline and Outline:IsA("GuiObject") then
            Outline.BackgroundTransparency = Hidden and 1 or VisibleTransparency
        end
    end
end

function Library:ApplyBoxOutlineSize()
    local Size = Library.ChangeGroupboxOutlineSize and Library.GroupboxOutlineSize or 2
    Size = math.clamp(tonumber(Size) or 2, 1, 12)

    for Holder in pairs(Library.BoxOutlineHolders) do
        if not Holder or not Holder.Parent then
            Library.BoxOutlineHolders[Holder] = nil
            continue
        end

        Holder.Position = UDim2.fromOffset(-Size, -Size)
        Library:UpdateDPI(Holder, {
            Position = UDim2.fromOffset(-Size, -Size),
            Size = false,
        })

        local Outline = Holder:FindFirstChild("Outline")
        if Outline and Outline:IsA("GuiObject") then
            Outline.Position = UDim2.fromOffset(1, 1)
            Outline.Size = UDim2.new(1, -2, 1, -2)
            Library:UpdateDPI(Outline, {
                Position = UDim2.fromOffset(1, 1),
                Size = UDim2.new(1, -2, 1, -2),
            })
        end

        for _, Child in ipairs(Holder:GetChildren()) do
            if Child ~= Outline and Child:IsA("GuiObject") then
                Child.Position = UDim2.fromOffset(Size, Size)
                Child.Size = UDim2.new(1, -(Size * 2), 1, -(Size * 2))
                Library:UpdateDPI(Child, {
                    Position = UDim2.fromOffset(Size, Size),
                    Size = UDim2.new(1, -(Size * 2), 1, -(Size * 2)),
                })
            end
        end
    end
end

function Library:GetBoxOutlineSize()
    local Size = Library.ChangeGroupboxOutlineSize and Library.GroupboxOutlineSize or 2
    return math.clamp(tonumber(Size) or 2, 1, 12)
end

function Library:RefreshBoxOutlineLayouts()
    for _, Tab in pairs(Library.Tabs) do
        if Tab.Groupboxes then
            for _, Groupbox in pairs(Tab.Groupboxes) do
                if Groupbox.Resize then
                    Groupbox:Resize()
                end
            end
        end

        if Tab.Tabboxes then
            for _, Tabbox in pairs(Tab.Tabboxes) do
                if Tabbox.ActiveTab and Tabbox.ActiveTab.Resize then
                    Tabbox.ActiveTab:Resize()
                end
            end
        end

        if Tab.Resize then
            Tab:Resize()
        end
    end
end

function Library:GetBoxOutlineSizeExtra()
    return math.max(0, (Library:GetBoxOutlineSize() - 2) * 2)
end

function Library:RegisterBoxOutline(Holder: GuiObject)
    if not Holder then
        return
    end

    Library.BoxOutlineHolders[Holder] = true
    Library:ApplyBoxOutlineVisibility()
    Library:ApplyBoxOutlineSize()
end

function Library:SetGroupboxOutlinesHidden(Hidden: boolean)
    Library.HideGroupboxOutlines = Hidden == true
    Library:ApplyBoxOutlineVisibility()
    Library:ApplyGroupboxTransparency()
end

function Library:ApplyGroupboxTransparency()
    local Transparency = Library.HideGroupboxOutlines and (Library.GroupboxTransparency or 0) or 0

    for Holder in pairs(Library.GroupboxBackgrounds) do
        if not Holder or not Holder.Parent then
            Library.GroupboxBackgrounds[Holder] = nil
            continue
        end

        Holder.BackgroundTransparency = Transparency
    end
end

function Library:RegisterGroupboxBackground(Holder: GuiObject)
    if not Holder then
        return
    end

    Library.GroupboxBackgrounds[Holder] = true
    Library:ApplyGroupboxTransparency()
    Library:ApplyBoxOutlineSize()
end

function Library:SetGroupboxTransparency(Value: number)
    Library.GroupboxTransparency = math.clamp(tonumber(Value) or 0, 0, 1)
    Library:ApplyGroupboxTransparency()
end

function Library:SetGroupboxOutlineSizeEnabled(Enabled: boolean)
    Library.ChangeGroupboxOutlineSize = Enabled == true
    Library:ApplyBoxOutlineSize()
    Library:RefreshBoxOutlineLayouts()
end

function Library:SetGroupboxOutlineSize(Value: number)
    Library.GroupboxOutlineSize = math.clamp(tonumber(Value) or 2, 1, 12)
    Library:ApplyBoxOutlineSize()
    Library:RefreshBoxOutlineLayouts()
end

function Library:AddDraggableButton(Text: string, Func)
    local Table = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 10,
        Parent = ScreenGui,

        DPIExclude = {
            Position = true,
        },
    })
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius - 1),
        Parent = Button,
    })
    Library:MakeOutline(Button, Library.CornerRadius, 9)

    Table.Button = Button
    Button.MouseButton1Click:Connect(function()
        Library:SafeCallback(Func, Table)
    end)
    Library:MakeDraggable(Button, Button, true)

    function Table:SetText(NewText: string)
        local X, Y = Library:GetTextBounds(NewText, Library.Scheme.Font, 16)

        Button.Text = NewText
        Button.Size = UDim2.fromOffset(X * Library.DPIScale * 2, Y * Library.DPIScale * 2)
        Library:UpdateDPI(Button, {
            Size = UDim2.fromOffset(X * 2, Y * 2),
        })
    end
    Table:SetText(Text)

    return Table
end

function Library:AddDraggableMenu(Name: string)
    local Background = Library:MakeOutline(ScreenGui, Library.CornerRadius, 10)
    Background.AutomaticSize = Enum.AutomaticSize.Y
    Background.Position = UDim2.fromOffset(6, 6)
    Background.Size = UDim2.fromOffset(0, 0)
    Library:UpdateDPI(Background, {
        Position = false,
        Size = false,
    })

    local Holder = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BackgroundTransparency = 0.04,
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        Parent = Background,
    })
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius + 1),
        Parent = Holder,
    })
    Library:MakeLine(Holder, {
        Color = "OutlineColor",
        Position = UDim2.fromOffset(9, 32),
        Size = UDim2.new(1, -18, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Text = Name,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Background, Label, true)
    return Background, Container, Label
end

--// Context Menu \\--
local CurrentMenu
function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?
)
    local Menu
    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = List == 2 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = Color3.fromRGB(225, 225, 225),
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = 10,
            Parent = ScreenGui,

            DPIExclude = {
                Position = true,
            },
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 10,
            Parent = ScreenGui,

            DPIExclude = {
                Position = true,
            },
        })
    end

    local Table = {
        Active = false,
        Holder = Holder,
        Menu = Menu,
        List = nil,
        Signal = nil,

        Size = Size,
    }

    if List then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    function Table:Open()
        if CurrentMenu == Table then
            return
        elseif CurrentMenu and not (Library:MouseIsOverFrame(CurrentMenu.Menu, Holder.AbsolutePosition) or Library:MouseIsOverFrame(CurrentMenu.Holder, Holder.AbsolutePosition)) then
            CurrentMenu:Close()
        end

        Table.ParentMenu = CurrentMenu
        CurrentMenu = Table
        Table.Active = true

        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset()[2])
            )
        else
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset[2])
            )
        end
        if typeof(Table.Size) == "function" then
            Menu.Size = Table.Size()
        else
            Menu.Size = ApplyDPIScale(Table.Size)
        end
        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        Menu.Visible = true

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset()[2])
                )
            else
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset[2])
                )
            end
        end)
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end
        Menu.Visible = false

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end
        Table.Active = false
        CurrentMenu = Table.ParentMenu
        Table.ParentMenu = nil
        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    if IsClickInput(Input, true) then
        local Location = Input.Position

        if
            CurrentMenu
            and not (
                Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
                    or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
            )
        then
            CurrentMenu:Close()
        end
    end
end))
--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    BackgroundColor3 = "BackgroundColor",
    BorderColor3 = "OutlineColor",
    BorderSizePixel = 1,
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 20,
    Parent = ScreenGui,
})
TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    local X, Y = Library:GetTextBounds(
        TooltipLabel.Text,
        TooltipLabel.FontFace,
        TooltipLabel.TextSize,
        workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 4
    )

    TooltipLabel.Size = UDim2.fromOffset(X + 8 * Library.DPIScale, Y + 4 * Library.DPIScale)
    Library:UpdateDPI(TooltipLabel, {
        Size = UDim2.fromOffset(X, Y),
        DPIOffset = {
            Size = { 8, 4 },
        },
    })
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Visible = true

        while
            Library.Toggled
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + (Library.ShowCustomCursor and 8 or 14),
                Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    table.insert(TooltipTable.Signals, HoverInstance.MouseEnter:Connect(DoHover))
    table.insert(TooltipTable.Signals, HoverInstance.MouseMoved:Connect(DoHover))
    table.insert(
        TooltipTable.Signals,
        HoverInstance.MouseLeave:Connect(function()
            if CurrentHoverInstance ~= HoverInstance then
                return
            end

            TooltipLabel.Visible = false
            CurrentHoverInstance = nil
        end)
    )

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            Connection:Disconnect()
        end

        if CurrentHoverInstance == HoverInstance then
            TooltipLabel.Visible = false
            CurrentHoverInstance = nil
        end
    end

    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

function Library:UpdateRainbowColorPickers(DeltaTime)
    if Library.Unloaded then
        return
    end

    local hasActivePicker = false
    for picker in pairs(Library.RainbowColorPickers) do
        if picker.Rainbow then
            hasActivePicker = true
            picker.Hue = (picker.Hue + ((DeltaTime or 0) * 0.18)) % 1
            picker:Update()
        end
    end

    if hasActivePicker then
        if not Library.RainbowColorPickerConnection then
            Library.RainbowColorPickerConnection = RunService.RenderStepped:Connect(function(dt)
                Library:UpdateRainbowColorPickers(dt)
            end)
        end
    elseif Library.RainbowColorPickerConnection then
        Library.RainbowColorPickerConnection:Disconnect()
        Library.RainbowColorPickerConnection = nil
    end
end

function Library:Unload()
    Library:SetSnowMouse(false)

    if Library.RainbowColorPickerConnection then
        Library.RainbowColorPickerConnection:Disconnect()
        Library.RainbowColorPickerConnection = nil
    end

    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)
        Connection:Disconnect()
    end

    for _, Callback in pairs(Library.UnloadSignals) do
        Library:SafeCallback(Callback)
    end

    SetAcrylicBlurEnabled(false)
    Library.Unloaded = true
    ScreenGui:Destroy()
    getgenv().Library = nil
end

local CheckIcon = Library:GetIcon("check")
local ArrowIcon = Library:GetIcon("chevron-up")
local ResizeIcon = Library:GetIcon("move-diagonal-2")
local KeyIcon = Library:GetIcon("key")
local WarningIcon = Library:GetIcon("triangle-alert")
local InfoIcon = Library:GetIcon("info")
local SettingsIcon = Library:GetIcon("settings")
local BetaIconColor = Color3.fromRGB(205, 170, 255)

local AddToggleConfigMenu
local BaseAddons = {}
do
    local Funcs = {}
    local RiskWarningText = "Using this feature may resort to an <u>auto ban</u> or a <u>manual ban</u> if reported or detected by the games <u>anticheat</u>"
    local BetaWarningText = "This feature may cause bugs or other issues because it is still in beta."

    function Library:ShowRiskWarning()
        local MainFrame = Library.MainFrame
        if not MainFrame then
            return
        end

        local Existing = MainFrame:FindFirstChild("RiskWarningPopup")
        if Existing then
            Existing.Visible = true
            return
        end

        local Overlay = New("TextButton", {
            Name = "RiskWarningPopup",
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutoButtonColor = false,
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.35,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            Text = "",
            ZIndex = 20,
            Parent = MainFrame,
        })

        local Popup = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(320, 140),
            ZIndex = 21,
            Parent = Overlay,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Popup,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Popup,
        })

        local Title = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 10),
            Size = UDim2.new(1, -28, 0, 20),
            Text = "Risky Feature",
            TextColor3 = "Red",
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 22,
            Parent = Popup,
        })

        local Message = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 38),
            Size = UDim2.new(1, -28, 0, 54),
            Text = RiskWarningText,
            RichText = true,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 22,
            Parent = Popup,
        })

        local CloseButton = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.new(0.5, 0, 1, -12),
            Size = UDim2.fromOffset(110, 28),
            Text = "Close",
            TextSize = 14,
            ZIndex = 22,
            Parent = Popup,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = CloseButton,
        })

        Library.Registry[Popup] = Library.Registry[Popup] or {}
        Library.Registry[Popup].BackgroundColor3 = "BackgroundColor"
        Library.Registry[Title] = Library.Registry[Title] or {}
        Library.Registry[Title].TextColor3 = "Red"
        Library.Registry[Message] = Library.Registry[Message] or {}
        Library.Registry[Message].TextColor3 = "FontColor"
        Library.Registry[CloseButton] = Library.Registry[CloseButton] or {}
        Library.Registry[CloseButton].BackgroundColor3 = "MainColor"
        Library.Registry[CloseButton].TextColor3 = "FontColor"

        local function HidePopup()
            Overlay.Visible = false
        end

        Overlay.MouseButton1Click:Connect(HidePopup)
        Popup.InputBegan:Connect(function() end)
        CloseButton.MouseButton1Click:Connect(HidePopup)
    end

    function Library:BindRiskyWarning(IconButton)
        if not IconButton then
            return
        end

        IconButton.MouseButton1Click:Connect(function()
            Library.SuppressNextRiskyToggleClick = true
            Library:ShowRiskWarning()
        end)
    end

    function Library:ShowBetaWarning()
        local MainFrame = Library.MainFrame
        if not MainFrame then
            return
        end

        local Existing = MainFrame:FindFirstChild("BetaWarningPopup")
        if Existing then
            Existing.Visible = true
            return
        end

        local Overlay = New("TextButton", {
            Name = "BetaWarningPopup",
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutoButtonColor = false,
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.35,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            Text = "",
            ZIndex = 20,
            Parent = MainFrame,
        })

        local Popup = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(320, 140),
            ZIndex = 21,
            Parent = Overlay,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Popup,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Popup,
        })

        local Title = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 10),
            Size = UDim2.new(1, -28, 0, 20),
            Text = "Beta Feature",
            TextColor3 = BetaIconColor,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 22,
            Parent = Popup,
        })

        local Message = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 38),
            Size = UDim2.new(1, -28, 0, 54),
            Text = BetaWarningText,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 22,
            Parent = Popup,
        })

        local CloseButton = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.new(0.5, 0, 1, -12),
            Size = UDim2.fromOffset(110, 28),
            Text = "Close",
            TextSize = 14,
            ZIndex = 22,
            Parent = Popup,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = CloseButton,
        })

        Library.Registry[Popup] = Library.Registry[Popup] or {}
        Library.Registry[Popup].BackgroundColor3 = "BackgroundColor"
        Library.Registry[Message] = Library.Registry[Message] or {}
        Library.Registry[Message].TextColor3 = "FontColor"
        Library.Registry[CloseButton] = Library.Registry[CloseButton] or {}
        Library.Registry[CloseButton].BackgroundColor3 = "MainColor"
        Library.Registry[CloseButton].TextColor3 = "FontColor"

        local function HidePopup()
            Overlay.Visible = false
        end

        Overlay.MouseButton1Click:Connect(HidePopup)
        Popup.InputBegan:Connect(function() end)
        CloseButton.MouseButton1Click:Connect(HidePopup)
    end

    function Library:BindBetaWarning(IconButton)
        if not IconButton then
            return
        end

        IconButton.MouseButton1Click:Connect(function()
            Library.SuppressNextRiskyToggleClick = true
            Library:ShowBetaWarning()
        end)
    end

    local function AddToggleConfigMenuAddon(ParentObj, ConfigInfo)
        if not ParentObj or ParentObj.ConfigMenu or typeof(ConfigInfo) ~= "table" then
            return ParentObj
        end

        local Config = {
            Type = "Config",
            AccessoryWidth = 18 * Library.DPIScale,
        }

        local GearButton = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            ZIndex = 4,
            Parent = ParentObj.KeyPickerParent or ParentObj.Holder,
        })
        Config.Button = GearButton

        local GearImage = New("ImageLabel", {
            Image = SettingsIcon and SettingsIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = SettingsIcon and SettingsIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = SettingsIcon and SettingsIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.45,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            ZIndex = GearButton.ZIndex + 1,
            Parent = GearButton,
        })

        local MenuWidth = ConfigInfo.Width or 214
        local MenuPadding = ConfigInfo.Padding or 8
        local Menu = Library:AddContextMenu(
            GearButton,
            function()
                return UDim2.fromOffset(MenuWidth * Library.DPIScale, 0)
            end,
            function()
                return { -MenuWidth * Library.DPIScale + GearButton.AbsoluteSize.X, GearButton.AbsoluteSize.Y + 2 }
            end,
            1
        )
        Menu.List.Padding = UDim.new(0, 6)

        New("UIPadding", {
            PaddingBottom = UDim.new(0, MenuPadding),
            PaddingLeft = UDim.new(0, MenuPadding),
            PaddingRight = UDim.new(0, MenuPadding),
            PaddingTop = UDim.new(0, MenuPadding),
            Parent = Menu.Menu,
        })

        local Title = ConfigInfo.Title or ConfigInfo.Name
        if typeof(Title) == "string" and Title ~= "" then
            local TitleLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = string.upper(Title),
                TextSize = 14,
                TextTransparency = 0.05,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Menu.Menu,
            })
            Library.Registry[TitleLabel] = Library.Registry[TitleLabel] or {}
            Library.Registry[TitleLabel].TextColor3 = "FontColor"
        end

        local ConfigGroupbox = {
            Container = Menu.Menu,
            Elements = {},
            IsConfigMenu = true,
            ConfigMenuWidth = menuWidth,
            ConfigMenuPadding = menuPadding,
        }

        function ConfigGroupbox:Resize()
            task.defer(function()
                if not Menu.Menu or not Menu.Menu.Parent then
                    return
                end

                local contentY = Menu.List.AbsoluteContentSize.Y + (MenuPadding * 2 * Library.DPIScale)
                Menu:SetSize(UDim2.fromOffset(MenuWidth * Library.DPIScale, math.max(40 * Library.DPIScale, contentY)))
            end)
        end
        ConfigGroupbox.AddToggle = Funcs.AddToggle
        ConfigGroupbox.AddCheckbox = Funcs.AddCheckbox
        ConfigGroupbox.AddSlider = Funcs.AddSlider
        ConfigGroupbox.AddDropdown = Funcs.AddDropdown
        ConfigGroupbox.AddInput = Funcs.AddInput

        local Items = ConfigInfo.Items or ConfigInfo.Controls or ConfigInfo
        local function AddConfigItem(Item, Index)
            if typeof(Item) ~= "table" then
                return
            end

            local ItemType = tostring(Item.Type or Item.Kind or "Toggle"):lower()
            local Idx = Item.Idx or Item.Index or Item.Name or Item.Text or ((ParentObj.Text or "Toggle") .. "Config" .. tostring(Index or 1))

            if ItemType == "slider" then
                Funcs.AddSlider(ConfigGroupbox, Idx, Item)
            elseif ItemType == "dropdown" then
                Funcs.AddDropdown(ConfigGroupbox, Idx, Item)
            elseif ItemType == "input" then
                Funcs.AddInput(ConfigGroupbox, Idx, Item)
            elseif ItemType == "checkbox" then
                Funcs.AddCheckbox(ConfigGroupbox, Idx, Item)
            else
                Funcs.AddToggle(ConfigGroupbox, Idx, Item)
            end
        end

        if Items.Type or Items.Kind then
            AddConfigItem(Items, 1)
        else
            for Index, Item in ipairs(Items) do
                AddConfigItem(Item, Index)
            end
        end

        GearButton.MouseEnter:Connect(function()
            GearImage.ImageTransparency = 0.15
        end)
        GearButton.MouseLeave:Connect(function()
            GearImage.ImageTransparency = 0.45
        end)
        GearButton.MouseButton1Click:Connect(function()
            Menu:Toggle()
        end)

        ParentObj.ConfigMenu = Menu
        ParentObj.ConfigGroupbox = ConfigGroupbox
        ParentObj.ConfigButton = GearButton

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, Config)
        end
        if ParentObj.RefreshAccessoryLayout then
            ParentObj:RefreshAccessoryLayout()
        end

        ConfigGroupbox:Resize()
        return ParentObj
    end

    function Funcs:AddConfig(ConfigInfo, Items)
        if typeof(ConfigInfo) == "string" then
            ConfigInfo = {
                Title = ConfigInfo,
                Items = Items,
            }
        end

        return AddToggleConfigMenu(self, ConfigInfo)
    end

    function Funcs:AddKeyPicker(Idx, Info)
    Info = Library:Validate(Info, Templates.KeyPicker)
    local ParentObj = self
    local ToggleLabel = ParentObj.TextLabel
    Info.Modes = Info.Modes or { "Toggle", "Hold", "Always" }

    local KeyPicker = {
        Text = Info.Text,
        Value = Info.Default,
        Toggled = false,
        Mode = Info.Mode,
        SyncToggleState = Info.SyncToggleState,
        Callback = Info.Callback,
        ChangedCallback = Info.ChangedCallback,
        Changed = Info.Changed,
        Clicked = Info.Clicked,
        Type = "KeyPicker",
    }

    local function IsUnboundKeybind()
        return KeyPicker.Value == nil
            or KeyPicker.Value == ""
            or KeyPicker.Value == "None"
            or KeyPicker.Value == "Unknown"
    end

    local function HasActiveKeybind()
        return not IsUnboundKeybind()
    end

    local function GetKeybindFeatureText()
        local Text = tostring(KeyPicker.Text or "")
        Text = Text:gsub("%s+[Kk]eybind$", "")
        Text = Text:gsub("%s+[Kk]ey$", "")
        return Text ~= "" and Text or "Feature"
    end

    if KeyPicker.SyncToggleState then
        Info.Modes = { "Toggle" }
        Info.Mode = "Toggle"
    end

    local Picker = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(18, 18),
        Text = KeyPicker.Value or "None",
        TextSize = 14,
        Parent = ToggleLabel,
    })
    New("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = Picker,
    })
    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Picker,
    })

    if ParentObj.KeyPickerParent then
        Picker.AnchorPoint = Vector2.new(1, 0)
        Picker.Parent = ParentObj.KeyPickerParent
        if ParentObj.RowStyle == "Checkbox" then
            Picker.ZIndex = 3
        end
    end

    local BeginPickingKey
    local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
    do
        local Holder = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            BackgroundTransparency = 0.55,
            Size = UDim2.new(1, 0, 0, 22),
            Text = "",
            Visible = not Info.NoUI,
            Parent = Library.KeybindContainer,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Transparency = 0.25,
            Parent = Holder,
        })

        local KeyBadge = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.25,
            Position = UDim2.fromOffset(7, 4),
            Size = UDim2.fromOffset(24, 14),
            Text = "",
            TextSize = 12,
            TextTransparency = 0.1,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = Holder,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = KeyBadge,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Transparency = 0.15,
            Parent = KeyBadge,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(37, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.22,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
            DPIExclude = { Size = true },
        })

        local ModeBadge = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 2)
            end,
            BackgroundTransparency = 0.25,
            Position = UDim2.fromOffset(0, 4),
            Size = UDim2.fromOffset(52, 14),
            Text = "",
            TextSize = 11,
            TextTransparency = 0.18,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = Holder,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = ModeBadge,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Transparency = 0.15,
            Parent = ModeBadge,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(14, 14),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Position = UDim2.fromOffset(6, 4),
            Parent = Holder,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = Checkbox,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = New("ImageLabel", {
            Image = CheckIcon and CheckIcon.Url or "",
            ImageColor3 = "AccentColor",
            ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })

        function KeybindsToggle:Display(State)
            Label.TextColor3 = State and Library.Scheme.AccentColor or Library.Scheme.FontColor
            Label.TextTransparency = State and 0 or 0.22
            KeyBadge.TextColor3 = State and Library.Scheme.AccentColor or Library.Scheme.FontColor
            ModeBadge.TextColor3 = State and Library.Scheme.AccentColor or Library.Scheme.FontColor
            Holder.BackgroundTransparency = State and 0.42 or 0.55
            Library.Registry[Label] = Library.Registry[Label] or {}
            Library.Registry[Label].TextColor3 = State and "AccentColor" or "FontColor"
            Library.Registry[KeyBadge] = Library.Registry[KeyBadge] or {}
            Library.Registry[KeyBadge].TextColor3 = State and "AccentColor" or "FontColor"
            Library.Registry[ModeBadge] = Library.Registry[ModeBadge] or {}
            Library.Registry[ModeBadge].TextColor3 = State and "AccentColor" or "FontColor"
            CheckImage.ImageTransparency = State and 0 or 1
        end

        function KeybindsToggle:SetInfo(Key, Feature, Mode)
            local KeyText = tostring(Key or "None")
            local FeatureText = tostring(Feature or "Feature")
            local ModeText = tostring(Mode or ""):upper()
            local StartX = KeybindsToggle.Normal and 7 * Library.DPIScale or 26 * Library.DPIScale
            local KeyX = Library:GetTextBounds(KeyText, KeyBadge.FontFace, KeyBadge.TextSize)
            local ModeX = Library:GetTextBounds(ModeText, ModeBadge.FontFace, ModeBadge.TextSize)
            local KeyWidth = math.max(24 * Library.DPIScale, KeyX + 12 * Library.DPIScale)
            local ModeWidth = ModeText ~= "" and math.max(44 * Library.DPIScale, ModeX + 14 * Library.DPIScale) or 0
            local LabelX = StartX + KeyWidth + 6 * Library.DPIScale
            local ModeBadgeX = ModeText ~= "" and -(ModeWidth + 7 * Library.DPIScale) or 0
            local LabelRightPadding = ModeText ~= "" and (ModeWidth + 16 * Library.DPIScale) or 7 * Library.DPIScale

            KeyBadge.Text = KeyText
            KeyBadge.Position = UDim2.fromOffset(StartX, 4 * Library.DPIScale)
            KeyBadge.Size = UDim2.fromOffset(KeyWidth, 14 * Library.DPIScale)

            Label.Text = FeatureText
            Label.Position = UDim2.fromOffset(LabelX, 0)
            Label.Size = UDim2.new(1, -(LabelX + LabelRightPadding), 1, 0)

            ModeBadge.Text = ModeText
            ModeBadge.Visible = ModeText ~= ""
            ModeBadge.Position = UDim2.new(1, ModeBadgeX, 0, 4 * Library.DPIScale)
            ModeBadge.Size = UDim2.fromOffset(ModeWidth, 14 * Library.DPIScale)
            KeybindsToggle.FullWidth = LabelX
                + Library:GetTextBounds(FeatureText, Label.FontFace, Label.TextSize)
                + LabelRightPadding
        end

        function KeybindsToggle:SetVisibility(Visibility)
            Holder.Visible = Visibility
        end

        function KeybindsToggle:SetNormal(Normal)
            KeybindsToggle.Normal = Normal
            Holder.Active = not Normal
            Checkbox.Visible = not Normal
        end

        Holder.MouseButton1Click:Connect(function()
            if KeybindsToggle.Normal then
                return
            end
            KeyPicker.Toggled = not KeyPicker.Toggled
            KeyPicker:DoClick()
        end)

        KeyBadge.MouseButton1Click:Connect(function()
            if BeginPickingKey then
                BeginPickingKey()
            end
        end)

        KeybindsToggle.Holder = Holder
        KeybindsToggle.KeyBadge = KeyBadge
        KeybindsToggle.Label = Label
        KeybindsToggle.ModeBadge = ModeBadge
        KeybindsToggle.Checkbox = Checkbox
        KeybindsToggle.Loaded = true
        table.insert(Library.KeybindToggles, KeybindsToggle)
    end

    local MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
        return { Picker.AbsoluteSize.X + 1.5, 0.5 }
    end, 1)

    KeyPicker.Menu = MenuTable

    local ModeButtons = {}
    local KeybindModeButtons = {}
    local KeybindModeMenu

    if KeybindsToggle.ModeBadge then
        KeybindModeMenu = Library:AddContextMenu(KeybindsToggle.ModeBadge, UDim2.fromOffset(68, 0), function()
            return { 0, KeybindsToggle.ModeBadge.AbsoluteSize.Y + 2 }
        end, 1)
        KeybindsToggle.ModeMenu = KeybindModeMenu
        KeybindsToggle.ModeBadge.MouseButton1Click:Connect(function()
            KeybindModeMenu:Toggle()
        end)
    end

    local function SetModeButtonState(Button, Selected)
        Button.BackgroundTransparency = Selected and 0.2 or 1
        Button.TextTransparency = Selected and 0 or 0.5
        Button.TextColor3 = Selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    end

    local function RefreshModeButtons()
        for Mode, ModeButton in pairs(ModeButtons) do
            ModeButton:SetSelected(KeyPicker.Mode == Mode)
        end
        for Mode, ModeButton in pairs(KeybindModeButtons) do
            ModeButton:SetSelected(KeyPicker.Mode == Mode)
        end
    end

    local function SelectMode(Mode, MenuToClose)
        KeyPicker.Mode = Mode
        RefreshModeButtons()
        if MenuToClose then
            MenuToClose:Close()
        end
        if KeyPicker.Update then
            KeyPicker:Update()
        end
    end

    local function CreateModeButton(Mode, Menu, Store)
        local ModeButton = {}

        local Button = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Text = Mode,
            TextSize = 14,
            TextTransparency = 0.5,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Parent = Menu.Menu,
        })

        function ModeButton:SetSelected(Selected)
            SetModeButtonState(Button, Selected)
        end

        Button.MouseButton1Click:Connect(function()
            SelectMode(Mode, Menu)
        end)

        Store[Mode] = ModeButton
    end

    local AllModes = { "Toggle", "Hold" }
    for _, Mode in pairs(AllModes) do
        CreateModeButton(Mode, MenuTable, ModeButtons)
        if KeybindModeMenu then
            CreateModeButton(Mode, KeybindModeMenu, KeybindModeButtons)
        end
    end
    RefreshModeButtons()


    function KeyPicker:Display()
        if Library.Unloaded then
            return
        end
        local DisplayValue = KeyPicker.Value or "None"
        local X, Y = Library:GetTextBounds(DisplayValue, Picker.FontFace, Picker.TextSize)
        local Width = math.max(32 * Library.DPIScale, X + 16 * Library.DPIScale)
        Picker.Text = DisplayValue
        Picker.Size = UDim2.fromOffset(Width, Y + 4 * Library.DPIScale)
        KeyPicker.AccessoryWidth = Width
        if ParentObj.KeyPickerParent then
            if ParentObj.RefreshAccessoryLayout then
                ParentObj:RefreshAccessoryLayout()
            end
        end
    end

    function KeyPicker:Update()
        KeyPicker:Display()
        if Info.NoUI then
            return
        end
        if not HasActiveKeybind() then
            if KeybindsToggle.Loaded then
                KeybindsToggle:SetVisibility(false)
            end
            Library:UpdateKeybindFrame()
            return
        end
        if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
            KeybindsToggle:SetVisibility(false)
            Library:UpdateKeybindFrame()
            return
        end
        local State = KeyPicker:GetState()
        local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"
        if KeybindsToggle.Loaded then
            if ShowToggle then
                KeybindsToggle:SetNormal(false)
            else
                KeybindsToggle:SetNormal(true)
            end
            KeybindsToggle:SetInfo(KeyPicker.Value, GetKeybindFeatureText(), KeyPicker.Mode)
            KeybindsToggle:SetVisibility(true)
            KeybindsToggle:Display(State)
        end
        Library:UpdateKeybindFrame()
    end

    function KeyPicker:GetState()
        if KeyPicker.Mode == "Always" then
            return true
        elseif KeyPicker.Mode == "Hold" then
            local Key = KeyPicker.Value
            if Key == "None" then
                return false
            end
            if Key == "MB1" or Key == "MB2" then
                return Key == "MB1" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                or Key == "MB2" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            end
            return UserInputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]) and not UserInputService:GetFocusedTextBox()
        else
            return KeyPicker.Toggled
        end
    end

    local function IsKeybindInput(Input)
        local Key = KeyPicker.Value
        if Key == "MB1" then
            return Input.UserInputType == Enum.UserInputType.MouseButton1
        elseif Key == "MB2" then
            return Input.UserInputType == Enum.UserInputType.MouseButton2
        end

        return Input.KeyCode ~= Enum.KeyCode.Unknown and Input.KeyCode.Name == Key
    end

    function KeyPicker:OnChanged(Func)
        KeyPicker.Changed = Func
    end

    function KeyPicker:OnClick(Func)
        KeyPicker.Clicked = Func
    end

    function KeyPicker:DoClick()
        if ParentObj.Type == "Toggle" and KeyPicker.SyncToggleState then
            ParentObj:SetValue(KeyPicker.Toggled)
        end
        Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
        Library:SafeCallback(KeyPicker.Changed, KeyPicker.Toggled)
    end

    function KeyPicker:SetValue(Data)
        local Key, Mode = Data[1], Data[2]
        KeyPicker.Value = Key
        if ModeButtons[Mode] then
            SelectMode(Mode)
        end
        KeyPicker:Update()
    end

    function KeyPicker:SetText(Text)
        KeyPicker.Text = Text
        KeyPicker:Update()
    end

    local Picking = false
    BeginPickingKey = function()
        if Picking then
            return
        end

        Picking = true
        Picker.Text = "..."
        Picker.Size = UDim2.fromOffset(29 * Library.DPIScale, 18 * Library.DPIScale)
        if KeybindsToggle.KeyBadge then
            KeybindsToggle.KeyBadge.Text = "..."
        end

        local Input = UserInputService.InputBegan:Wait()
        local Key = "None"

        if Input.KeyCode and Input.KeyCode ~= Enum.KeyCode.Unknown then
            if Input.KeyCode == Enum.KeyCode.Escape then
                Key = "None"
            elseif Input.KeyCode == Enum.KeyCode.Backspace then
                Key = "None"
            else
                Key = Input.KeyCode.Name
            end
        elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Key = "MB1"
        elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
            Key = "MB2"
        else
            Key = Input.UserInputType.Name
        end

        KeyPicker.Value = Key
        KeyPicker:Update()

        local CallbackValue = Input.KeyCode ~= Enum.KeyCode.Unknown and Input.KeyCode or Input.UserInputType
        Library:SafeCallback(KeyPicker.ChangedCallback, CallbackValue)
        Library:SafeCallback(KeyPicker.Changed, CallbackValue)

        RunService.RenderStepped:Wait()
        Picking = false
    end

    Picker.MouseButton1Click:Connect(BeginPickingKey)


    Picker.MouseButton2Click:Connect(MenuTable.Toggle)

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input)
    if KeyPicker.Mode == "Always"
    or IsUnboundKeybind()
    or Picking
    or UserInputService:GetFocusedTextBox() then
        return
    end

    if KeyPicker.Mode == "Toggle" then
        if IsKeybindInput(Input) then
            KeyPicker.Toggled = not KeyPicker.Toggled
            KeyPicker:DoClick()
        end

    elseif KeyPicker.Mode == "Hold" then
        if IsKeybindInput(Input) then
            KeyPicker.Toggled = true
            KeyPicker:DoClick()
        end
    end

    KeyPicker:Update()
end))


    Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
        if IsUnboundKeybind() or Picking or UserInputService:GetFocusedTextBox() then
            return
        end

        if KeyPicker.Mode == "Hold" and IsKeybindInput(Input) then
            KeyPicker.Toggled = false
            KeyPicker:DoClick()
        end

        KeyPicker:Update()
    end))

    KeyPicker:Update()

    KeyPicker.Button = Picker

    if ParentObj.Addons then
        table.insert(ParentObj.Addons, KeyPicker)
    end

    if ParentObj.KeyPickerParent then
        ParentObj.KeyPickerButton = Picker
        Library:GiveSignal(ParentObj.KeyPickerParent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            KeyPicker:Update()
        end))
        if ParentObj.RefreshAccessoryLayout then
            ParentObj:RefreshAccessoryLayout()
        end
    end

    Options[Idx] = KeyPicker
    return self
end


    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        Info = Library:Validate(Info, Templates.ColorPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel
        local AccessoryParent = ParentObj.KeyPickerParent or ToggleLabel

        local ColorPicker = {
            Value = Info.Default,
            Transparency = Info.Transparency or 0,
            Rainbow = false,
            RainbowRestoreHSV = nil,
            RainbowRestoreTransparency = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()
        local PaintIconName = typeof(Info.Icon) == "string" and Info.Icon ~= "" and Info.Icon or "palette"
        local PaintIcon = Info.UsePaintIcon and (Library:GetIcon(PaintIconName) or Library:GetIcon("palette")) or nil

        local Holder = New("TextButton", {
            AnchorPoint = ParentObj.KeyPickerParent and Vector2.new(1, 0) or Vector2.zero,
            BackgroundColor3 = Info.UsePaintIcon and Library.Scheme.BackgroundColor or ColorPicker.Value,
            BackgroundTransparency = Info.UsePaintIcon and 1 or 0,
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value),
            BorderSizePixel = Info.UsePaintIcon and 0 or 1,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = AccessoryParent,
        })
        ColorPicker.Button = Holder
        ColorPicker.AccessoryWidth = 18 * Library.DPIScale
        local HolderTransparency = New("ImageLabel", {
            Image = "rbxassetid://139785960036434",
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Size = UDim2.fromScale(1, 1),
            TileSize = UDim2.fromOffset(9, 9),
            Visible = not Info.UsePaintIcon,
            Parent = Holder,
        })
        local PaintIconImage = New("ImageLabel", {
            Image = PaintIcon and PaintIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = PaintIcon and PaintIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = PaintIcon and PaintIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.45,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Visible = Info.UsePaintIcon and PaintIcon ~= nil,
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = HolderTransparency,
        })

        --// Color Menu \\--
        local ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(Info.Transparency and 256 or 234, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1
        )
        ColorMenu.List.Padding = UDim.new(0, 8)
        ColorPicker.ColorMenu = ColorMenu

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ColorMenu.Menu,
        })

        if typeof(Info.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = Info.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ColorMenu.Menu,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 200),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = "rbxassetid://4155801252",
            Size = UDim2.fromOffset(200, 200),
            Parent = ColorHolder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = SatVipMap,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "White",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "Dark",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(16, 200),
            Text = "",
            Parent = ColorHolder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = HueSelector,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "White",
            BorderColor3 = "Dark",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = "rbxassetid://139785960036434",
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(16, 200),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, 3),
                Parent = TransparencySelector,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, 3),
                Parent = TransparencyColor,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "White",
                BorderColor3 = "Dark",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = HueBox,
        })

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = RgbBox,
        })

        local RainbowToggle = New("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Text = "",
            Parent = ColorMenu.Menu,
        })

        local RainbowLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -52, 1, 0),
            Text = "Rainbow",
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = RainbowToggle,
        })

        local RainbowSwitch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            Position = UDim2.new(1, -1, 0.5, 0),
            Size = UDim2.fromOffset(40, 18),
            Parent = RainbowToggle,
        })
        RainbowSwitch:SetAttribute("ExcludeMenuTransparency", true)

        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = RainbowSwitch,
        })

        local RainbowSwitchStroke = New("UIStroke", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 1,
            Parent = RainbowSwitch,
        })

        local RainbowKnob = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 32, 165),
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.fromOffset(14, 14),
            Parent = RainbowSwitch,
        })
        RainbowKnob:SetAttribute("ExcludeMenuTransparency", true)

        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = RainbowKnob,
        })

        local RainbowToggleTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local LastRainbowVisualState = nil

        local function UpdateRainbowToggleVisual(Instant)
            local enabled = ColorPicker.Rainbow
            local trackColor = enabled and Library.Scheme.AccentColor or Color3.fromRGB(10, 10, 10)
            local knobColor = enabled and Library.Scheme.White or Color3.fromRGB(0, 32, 165)
            local knobPosition = enabled and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2)

            RainbowLabel.TextTransparency = enabled and 0 or 0.4

            if Instant or LastRainbowVisualState == nil or LastRainbowVisualState == enabled then
                RainbowSwitch.BackgroundColor3 = trackColor
                RainbowKnob.BackgroundColor3 = knobColor
                RainbowKnob.Position = knobPosition
            else
                TweenService:Create(RainbowSwitch, RainbowToggleTweenInfo, {
                    BackgroundColor3 = trackColor,
                }):Play()
                TweenService:Create(RainbowKnob, RainbowToggleTweenInfo, {
                    BackgroundColor3 = knobColor,
                    Position = knobPosition,
                }):Play()
            end

            RainbowSwitchStroke.Transparency = 1
            LastRainbowVisualState = enabled
        end

        --// Context Menu \\--
        local ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1)
        ColorPicker.ContextMenu = ContextMenu
        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                Button.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end)
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            CreateButton("Paste color", function()
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)
                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// End \\--

        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then 
                return 
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            Holder.BackgroundColor3 = Info.UsePaintIcon and Library.Scheme.BackgroundColor or ColorPicker.Value
            Holder.BackgroundTransparency = Info.UsePaintIcon and 1 or 0
            Holder.BorderColor3 = Info.UsePaintIcon and Library.Scheme.OutlineColor or Library:GetDarkerColor(ColorPicker.Value)
            Holder.BorderSizePixel = Info.UsePaintIcon and 0 or 1
            HolderTransparency.ImageTransparency = Info.UsePaintIcon and 1 or (1 - ColorPicker.Transparency)
            HolderTransparency.Visible = not Info.UsePaintIcon
            if PaintIconImage then
                PaintIconImage.Visible = Info.UsePaintIcon and PaintIcon ~= nil
                PaintIconImage.ImageColor3 = Library.Scheme.FontColor
            end

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")

            UpdateRainbowToggleVisual(true)
            ColorPicker.AccessoryWidth = math.max(18 * Library.DPIScale, Holder.AbsoluteSize.X, Holder.Size.X.Offset)

            if ParentObj.KeyPickerParent and ParentObj.RefreshAccessoryLayout then
                ParentObj:RefreshAccessoryLayout()
            end
        end

        function ColorPicker:Update()
            ColorPicker:Display()

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Display()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Display()
        end

        function ColorPicker:SetRainbow(State)
            if State == ColorPicker.Rainbow then
                return
            end

            if State then
                ColorPicker.RainbowRestoreHSV = { ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib }
                ColorPicker.RainbowRestoreTransparency = ColorPicker.Transparency
            elseif ColorPicker.RainbowRestoreHSV then
                ColorPicker.Hue = ColorPicker.RainbowRestoreHSV[1]
                ColorPicker.Sat = ColorPicker.RainbowRestoreHSV[2]
                ColorPicker.Vib = ColorPicker.RainbowRestoreHSV[3]
                ColorPicker.Transparency = ColorPicker.RainbowRestoreTransparency or ColorPicker.Transparency
                ColorPicker.RainbowRestoreHSV = nil
                ColorPicker.RainbowRestoreTransparency = nil
            end

            ColorPicker.Rainbow = State
            UpdateRainbowToggleVisual(false)

            if State then
                Library.RainbowColorPickers[ColorPicker] = true
            else
                Library.RainbowColorPickers[ColorPicker] = nil
            end

            ColorPicker:Update()
            Library:UpdateRainbowColorPickers()
        end

        Holder.MouseButton1Click:Connect(ColorMenu.Toggle)
        Holder.MouseButton2Click:Connect(ContextMenu.Toggle)
        RainbowToggle.MouseButton1Click:Connect(function()
            ColorPicker:SetRainbow(not ColorPicker.Rainbow)
        end)

        SatVipMap.MouseButton1Down:Connect(function()
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end)
        HueSelector.MouseButton1Down:Connect(function()
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end)
        if TransparencySelector then
            TransparencySelector.MouseButton1Down:Connect(function()
                while
                    UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch)
                do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end)
        end

        HueBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end)
        RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end)

        ColorPicker:Display()

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, ColorPicker)
        end

        if ParentObj.KeyPickerParent then
            ParentObj.ColorPickerButtons = ParentObj.ColorPickerButtons or {}
            table.insert(ParentObj.ColorPickerButtons, Holder)

            if ParentObj.RefreshAccessoryLayout then
                ParentObj:RefreshAccessoryLayout()
            end
        end

        Library:OnUnload(function()
            Library.RainbowColorPickers[ColorPicker] = nil
        end)

        Options[Idx] = ColorPicker

        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

local BaseGroupbox = {}
do
    local Funcs = {}

    AddToggleConfigMenu = function(ParentObj, ConfigInfo)
        if not ParentObj or ParentObj.ConfigMenu or typeof(ConfigInfo) ~= "table" then
            return ParentObj
        end

        local Config = {
            Type = "Config",
            AccessoryWidth = 18 * Library.DPIScale,
        }

        local GearButton = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            ZIndex = 4,
            Parent = ParentObj.KeyPickerParent or ParentObj.Holder,
        })
        Config.Button = GearButton

        local GearImage = New("ImageLabel", {
            Image = SettingsIcon and SettingsIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = SettingsIcon and SettingsIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = SettingsIcon and SettingsIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.45,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            ZIndex = GearButton.ZIndex + 1,
            Parent = GearButton,
        })

        local menuWidth = ConfigInfo.Width or 214
        local menuPadding = ConfigInfo.Padding or 8
        local Menu = Library:AddContextMenu(
            GearButton,
            function()
                return UDim2.fromOffset(menuWidth * Library.DPIScale, 0)
            end,
            function()
                return { -menuWidth * Library.DPIScale + GearButton.AbsoluteSize.X, GearButton.AbsoluteSize.Y + 2 }
            end,
            1
        )
        Menu.List.Padding = UDim.new(0, 6)

        New("UIPadding", {
            PaddingBottom = UDim.new(0, menuPadding),
            PaddingLeft = UDim.new(0, menuPadding),
            PaddingRight = UDim.new(0, menuPadding),
            PaddingTop = UDim.new(0, menuPadding),
            Parent = Menu.Menu,
        })

        local title = ConfigInfo.Title or ConfigInfo.Name
        if typeof(title) == "string" and title ~= "" then
            local TitleLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                LayoutOrder = -100,
                Size = UDim2.new(1, 0, 0, 16),
                Text = string.upper(title),
                TextSize = 14,
                TextTransparency = 0.05,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Menu.Menu,
            })
            Library.Registry[TitleLabel] = Library.Registry[TitleLabel] or {}
            Library.Registry[TitleLabel].TextColor3 = "FontColor"

            local TitleUnderlineHolder = New("Frame", {
                BackgroundTransparency = 1,
                LayoutOrder = -99,
                Size = UDim2.new(1, 0, 0, 8),
                Parent = Menu.Menu,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = "AccentColor",
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0, 2),
                Size = UDim2.fromOffset(72, 1),
                Parent = TitleUnderlineHolder,
            })
        end

        local ConfigGroupbox = {
            Container = Menu.Menu,
            Elements = {},
            IsConfigMenu = true,
        }

        local function RefreshConfigLayouts()
            for _, Element in ipairs(ConfigGroupbox.Elements) do
                if Element.RefreshAccessoryLayout then
                    Element:RefreshAccessoryLayout()
                elseif Element.RefreshRiskyIconPosition then
                    Element:RefreshRiskyIconPosition()
                end
                if Element.Display then
                    Element:Display()
                end
            end
        end

        local function QueueConfigLayoutRefresh()
            task.spawn(function()
                RunService.RenderStepped:Wait()
                RefreshConfigLayouts()
                RunService.RenderStepped:Wait()
                RefreshConfigLayouts()
            end)
        end

        function ConfigGroupbox:Resize()
            task.defer(function()
                if not Menu.Menu or not Menu.Menu.Parent then
                    return
                end

                local contentY = Menu.List.AbsoluteContentSize.Y + (menuPadding * 2 * Library.DPIScale)
                Menu:SetSize(UDim2.fromOffset(menuWidth * Library.DPIScale, math.max(40 * Library.DPIScale, contentY)))
                QueueConfigLayoutRefresh()
            end)
        end

        local items = ConfigInfo.Items or ConfigInfo.Controls or ConfigInfo
        local function AddConfigItem(item, index)
            if typeof(item) ~= "table" then
                return
            end

            local itemType = tostring(item.Type or item.Kind or "Toggle"):lower()
            local idx = item.Idx or item.Index or item.Name or item.Text or ((ParentObj.Text or "Toggle") .. "Config" .. tostring(index or 1))

            if itemType == "slider" then
                local Control = Funcs.AddSlider(ConfigGroupbox, idx, item)
                if Control and Control.Holder then
                    Control.Holder.LayoutOrder = index or 1
                end
            elseif itemType == "dropdown" then
                local Control = Funcs.AddDropdown(ConfigGroupbox, idx, item)
                if Control and Control.Holder then
                    Control.Holder.LayoutOrder = index or 1
                end
            elseif itemType == "input" then
                local Control = Funcs.AddInput(ConfigGroupbox, idx, item)
                if Control and Control.Holder then
                    Control.Holder.LayoutOrder = index or 1
                end
            elseif itemType == "checkbox" then
                local Control = Funcs.AddCheckbox(ConfigGroupbox, idx, item)
                if Control and Control.Holder then
                    Control.Holder.LayoutOrder = index or 1
                    Control.Holder.Size = UDim2.new(1, 0, 0, 21)
                end
            else
                local Control = Funcs.AddToggle(ConfigGroupbox, idx, item)
                if Control and Control.Holder then
                    Control.Holder.LayoutOrder = index or 1
                end
            end
        end

        if items.Type or items.Kind then
            AddConfigItem(items, 1)
        else
            for index, item in ipairs(items) do
                AddConfigItem(item, index)
            end
        end

        GearButton.MouseEnter:Connect(function()
            GearImage.ImageTransparency = 0.15
        end)
        GearButton.MouseLeave:Connect(function()
            GearImage.ImageTransparency = 0.45
        end)
        GearButton.MouseButton1Click:Connect(function()
            Menu:Toggle()
            QueueConfigLayoutRefresh()
        end)

        ParentObj.ConfigMenu = Menu
        ParentObj.ConfigGroupbox = ConfigGroupbox
        ParentObj.ConfigButton = GearButton

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, Config)
        end
        if ParentObj.RefreshAccessoryLayout then
            ParentObj:RefreshAccessoryLayout()
        end

        ConfigGroupbox:Resize()
        return ParentObj
    end

    function Funcs:AddDivider()
        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 7),
            Parent = Container,
        })

        New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = "OutlineColor",
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 1),
            Parent = Holder,
        })

        Groupbox:Resize()

        table.insert(Groupbox.Elements, {
            Holder = Holder,
            Type = "Divider",
        })
    end

    function Funcs:AddLabel(...)
        local Data = {}

        local function NormalizeIcon(Icon)
            if typeof(Icon) == "string" and Icon ~= "" then
                return Icon
            end

            return nil
        end

        local function NormalizeIconSide(IconSide, HasIcon)
            if not HasIcon then
                return nil
            end

            if IconSide == "Left" or IconSide == "Right" then
                return IconSide
            end

            return "Right"
        end

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Icon = NormalizeIcon(Params.Icon)
            Data.IconSide = NormalizeIconSide(Params.IconSide, Data.Icon ~= nil)
            Data.Visible = Params.Visible or true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = select(3, ...) or 14
            Data.Icon = NormalizeIcon(select(4, ...))
            Data.IconSide = NormalizeIconSide(select(5, ...), Data.Icon ~= nil)
            Data.Visible = true
            Data.Idx = select(6, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Text = Data.Text,
            DoesWrap = Data.DoesWrap,
            Icon = Data.Icon,
            IconSide = Data.IconSide,
            IconData = Data.Icon and Library:GetIcon(Data.Icon) or nil,

            Visible = Data.Visible,
            Type = "Label",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Visible = Label.Visible,
            Parent = Container,
        })

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Parent = Holder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = TextLabel,
        })
        local IconImage
        local IconInset = 20

        local function ApplyLabelLayout()
            if IconImage then
                IconImage:Destroy()
                IconImage = nil
            end

            TextLabel.Position = UDim2.fromOffset(0, 0)
            TextLabel.Size = UDim2.new(1, 0, 1, 0)

            if not Label.IconData then
                return
            end

            IconImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Image = Label.IconData.Url,
                ImageColor3 = "FontColor",
                ImageRectOffset = Label.IconData.ImageRectOffset,
                ImageRectSize = Label.IconData.ImageRectSize,
                Size = UDim2.fromOffset(14, 14),
                Visible = Label.Visible,
                Parent = Holder,
            })

            if Label.IconSide == "Left" then
                TextLabel.Position = UDim2.fromOffset(IconInset, 0)
                TextLabel.Size = UDim2.new(1, -IconInset, 1, 0)
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, 0, 0.5, 0)
            else
                TextLabel.Size = UDim2.new(1, -IconInset, 1, 0)
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 0, 0.5, 0)
            end
        end

        local function UpdateWrappedSize()
            if Label.DoesWrap then
                local _, Y =
                    Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
                Holder.Size = UDim2.new(1, 0, 0, Y + 4 * Library.DPIScale)
            else
                Holder.Size = UDim2.new(1, 0, 0, 18)
            end
        end

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            Holder.Visible = Label.Visible
            TextLabel.Visible = Label.Visible
            if IconImage then
                IconImage.Visible = Label.Visible
            end
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            UpdateWrappedSize()
            Groupbox:Resize()
        end

        function Label:SetIcon(Icon: string, IconSide: string?)
            Label.Icon = NormalizeIcon(Icon)
            Label.IconSide = NormalizeIconSide(IconSide, Label.Icon ~= nil)
            Label.IconData = Label.Icon and Library:GetIcon(Label.Icon) or nil
            ApplyLabelLayout()
            UpdateWrappedSize()
            Groupbox:Resize()
        end

        ApplyLabelLayout()
        UpdateWrappedSize()

        if Data.DoesWrap then
            local Last = Holder.AbsoluteSize

            Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if Holder.AbsoluteSize == Last then
                    return
                end

                UpdateWrappedSize()

                Last = Holder.AbsoluteSize
                Groupbox:Resize()
            end)
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = Holder
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        return Label
    end

    function Funcs:AddButton(...)
    local function GetInfo(...)
        local Info = {}
        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second
            Info.Text = Params.Text or ""
            Info.Func = Params.Func or function() end
            Info.DoubleClick = Params.DoubleClick
            Info.Tooltip = Params.Tooltip
            Info.DisabledTooltip = Params.DisabledTooltip
            Info.Icon = Params.Icon
            Info.Risky = Params.Risky or false
            Info.Disabled = Params.Disabled or false
            Info.Visible = Params.Visible or true
            Info.Idx = typeof(Second) == "table" and First or nil
        else
            Info.Text = First or ""
            Info.Func = Second or function() end
            Info.DoubleClick = false
            Info.Tooltip = nil
            Info.DisabledTooltip = nil
            Info.Icon = nil
            Info.Risky = false
            Info.Disabled = false
            Info.Visible = true
            Info.Idx = select(3, ...) or nil
        end
        return Info
    end

    local Info = GetInfo(...)
    local Groupbox = self
    local Container = Groupbox.Container
    local Button = {
        Text = Info.Text,
        Func = Info.Func,
        DoubleClick = Info.DoubleClick,
        Tooltip = Info.Tooltip,
        DisabledTooltip = Info.DisabledTooltip,
        Icon = Info.Icon,
        IconData = Library:GetIcon(Info.Icon),
        TooltipTable = nil,
        Risky = Info.Risky,
        Disabled = Info.Disabled,
        Visible = Info.Visible,
        Tween = nil,
        Type = "Button",
        Groupbox = Groupbox,
    }
    local Holder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = Container,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Padding = UDim.new(0, 9),
        Parent = Holder,
    })
    
    local function CreateButton(Button)
        local Base = New("TextButton", {
            Active = not Button.Disabled,
            BackgroundColor3 = Library.Scheme.BackgroundColor,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.4,
            Visible = Button.Visible,
            Parent = Holder,
        })
        local Content = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, -12, 1, 0),
            Parent = Base,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = Content,
        })
        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            Text = Button.Text,
            TextSize = 14,
            TextTransparency = Button.Disabled and 0.8 or 0.4,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Content,
        })
        local IconImage
        if Button.IconData then
            IconImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Image = Button.IconData.Url,
                ImageColor3 = Button.Risky and "Red" or "FontColor",
                ImageRectOffset = Button.IconData.ImageRectOffset,
                ImageRectSize = Button.IconData.ImageRectSize,
                ImageTransparency = Button.Disabled and 0.8 or 0.4,
                Size = UDim2.fromOffset(14, 14),
                Visible = Button.Visible,
                Parent = Content,
            })
        end
        local Stroke = New("UIStroke", {
            Color = "OutlineColor",
            Transparency = Button.Disabled and 0.5 or 0,
            Parent = Base,
        })
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = Base
        Button.Content = Content
        Button.TextLabel = TextLabel
        return Base, Stroke, IconImage
    end

    local function UpdateButtonIconPosition(Button)
        if Button.TextLabel then
            Button.TextLabel.Text = Button.Text
            Button.TextLabel.TextColor3 = Button.Risky and Library.Scheme.Red or Library.Scheme.FontColor
            Button.TextLabel.TextTransparency = Button.Disabled and 0.8 or 0.4
            local contentWidth = Button.Content and Button.Content.AbsoluteSize.X or 0
            local iconReserve = Button.IconImage and (20 * Library.DPIScale) or 0
            local maxTextWidth = math.max(0, contentWidth - iconReserve)
            local textWidth = Library:GetTextBounds(Button.Text, Button.TextLabel.FontFace, Button.TextLabel.TextSize)
            Button.TextLabel.Size = UDim2.new(0, math.min(textWidth + 2, maxTextWidth), 1, 0)
        end
        if Button.IconImage then
            Button.IconImage.Visible = Button.Base.Visible and Button.IconData ~= nil
        end
    end

    local function SetButtonIcon(Button, Icon)
        Button.Icon = Icon
        Button.IconData = Library:GetIcon(Icon)

        if not Button.IconData then
            if Button.IconImage then
                Button.IconImage:Destroy()
                Button.IconImage = nil
            end
            return
        end

        if not Button.IconImage then
            Button.IconImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = Button.Risky and "Red" or "FontColor",
                ImageTransparency = Button.Disabled and 0.8 or 0.4,
                Size = UDim2.fromOffset(14, 14),
                Parent = Button.Content or Button.Base,
            })
        end

        Button.IconImage.Image = Button.IconData.Url
        Button.IconImage.ImageRectOffset = Button.IconData.ImageRectOffset
        Button.IconImage.ImageRectSize = Button.IconData.ImageRectSize
        UpdateButtonIconPosition(Button)
    end

    local function InitEvents(Button)
        UpdateButtonIconPosition(Button)
        if Button.Content then
            Library:GiveSignal(Button.Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                UpdateButtonIconPosition(Button)
            end))
        end
        if Button.TextLabel then
            Library:GiveSignal(Button.TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                UpdateButtonIconPosition(Button)
            end))
        end
        Library:GiveSignal(Button.Base:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            UpdateButtonIconPosition(Button)
        end))
        Button.Base.MouseEnter:Connect(function()
            if Button.Disabled then return end
            if Button.TextLabel then
                Button.Tween = TweenService:Create(Button.TextLabel, Library.TweenInfo, {TextTransparency = 0})
                Button.Tween:Play()
            end
            if Button.IconImage then
                TweenService:Create(Button.IconImage, Library.TweenInfo, {ImageTransparency = 0}):Play()
            end
        end)
        Button.Base.MouseLeave:Connect(function()
            if Button.Disabled then return end
            if Button.TextLabel then
                Button.Tween = TweenService:Create(Button.TextLabel, Library.TweenInfo, {TextTransparency = 0.4})
                Button.Tween:Play()
            end
            if Button.IconImage then
                TweenService:Create(Button.IconImage, Library.TweenInfo, {ImageTransparency = 0.4}):Play()
            end
        end)
        local clickani
        Button.Base.MouseButton1Click:Connect(function()
            if Button.Disabled or Button.Locked then return end
            if clickani then
                clickani:Cancel()
                Button.Base.BackgroundColor3 = Library.Scheme.BackgroundColor
            end
            local flashColor = Library.Scheme.BackgroundColor:Lerp(Color3.new(1, 1, 1), 0.15)
            Button.Base.BackgroundColor3 = flashColor
            clickani = TweenService:Create(Button.Base, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Library.Scheme.BackgroundColor,
            })
            clickani:Play()
            if Button.DoubleClick then
                Button.Locked = true
                local PreviousText = Button.Text
                Button.Text = "Are you sure?"
                UpdateButtonIconPosition(Button)
                if Button.TextLabel then
                    Button.TextLabel.TextColor3 = Library.Scheme.AccentColor
                end
                local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)
                Button.Text = PreviousText
                UpdateButtonIconPosition(Button)
                if Button.TextLabel then
                    Button.TextLabel.TextColor3 = Button.Risky and Library.Scheme.Red or Library.Scheme.FontColor
                end
                if Clicked then
                    Library:SafeCallback(Button.Func)
                end
                RunService.RenderStepped:Wait()
                Button.Locked = false
                return
            end
            Library:SafeCallback(Button.Func)
        end)
    end
    Button.Base, Button.Stroke, Button.IconImage = CreateButton(Button)
    InitEvents(Button)

    function Button:AddButton(...)
        local Info = GetInfo(...)
        local SubButton = {
            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,
            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            Icon = Info.Icon,
            IconData = Library:GetIcon(Info.Icon),
            TooltipTable = nil,
            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Tween = nil,
            Type = "SubButton",
        }

        Button.SubButton = SubButton
        SubButton.Base, SubButton.Stroke, SubButton.IconImage = CreateButton(SubButton)
        InitEvents(SubButton)
        function SubButton:UpdateColors()
            if Library.Unloaded then return end
            StopTween(SubButton.Tween)
            SubButton.Base.BackgroundColor3 = Library.Scheme.BackgroundColor
            SubButton.Base.TextTransparency = SubButton.Disabled and 0.8 or 0.4
            if SubButton.TextLabel then
                SubButton.TextLabel.TextTransparency = SubButton.Disabled and 0.8 or 0.4
            end
            if SubButton.IconImage then
                SubButton.IconImage.ImageTransparency = SubButton.Disabled and 0.8 or 0.4
            end
            SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0
            Library.Registry[SubButton.Base].BackgroundColor3 = "BackgroundColor"
        end
        function SubButton:SetDisabled(Disabled)
            SubButton.Disabled = Disabled
            if SubButton.TooltipTable then
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end
            SubButton.Base.Active = not SubButton.Disabled
            SubButton:UpdateColors()
        end
        function SubButton:SetVisible(Visible)
            SubButton.Visible = Visible
            SubButton.Base.Visible = SubButton.Visible
            Groupbox:Resize()
        end
        function SubButton:SetText(Text)
            SubButton.Text = Text
            UpdateButtonIconPosition(SubButton)
        end
        function SubButton:SetIcon(Icon)
            SetButtonIcon(SubButton, Icon)
        end
        if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
            SubButton.TooltipTable = Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
            SubButton.TooltipTable.Disabled = SubButton.Disabled
        end
        if SubButton.Risky then
            if SubButton.TextLabel then
                SubButton.TextLabel.TextColor3 = Library.Scheme.Red
            end
        end
        SubButton:UpdateColors()
        if Info.Idx then
            Buttons[Info.Idx] = SubButton
        else
            table.insert(Buttons, SubButton)
        end
        return SubButton
    end

    function Button:UpdateColors()
        if Library.Unloaded then return end
            StopTween(Button.Tween)
            Button.Base.BackgroundColor3 = Library.Scheme.BackgroundColor
            Button.Base.TextTransparency = Button.Disabled and 0.8 or 0.4
        if Button.TextLabel then
            Button.TextLabel.TextTransparency = Button.Disabled and 0.8 or 0.4
        end
        if Button.IconImage then
            Button.IconImage.ImageTransparency = Button.Disabled and 0.8 or 0.4
        end
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0
            Library.Registry[Button.Base].BackgroundColor3 = "BackgroundColor"
    end
    function Button:SetDisabled(Disabled)
        Button.Disabled = Disabled
        if Button.TooltipTable then
            Button.TooltipTable.Disabled = Button.Disabled
        end
        Button.Base.Active = not Button.Disabled
        Button:UpdateColors()
    end
    function Button:SetVisible(Visible)
        Button.Visible = Visible
        Holder.Visible = Button.Visible
        Groupbox:Resize()
    end
    function Button:SetText(Text)
        Button.Text = Text
        UpdateButtonIconPosition(Button)
    end
    function Button:SetIcon(Icon)
        SetButtonIcon(Button, Icon)
    end

    function Button:Delete()
        if self.Base and self.Base.Parent then
            self.Base:Destroy()
        end
        if self.Stroke and self.Stroke.Parent then
            self.Stroke:Destroy()
        end
        if self.IconImage and self.IconImage.Parent then
            self.IconImage:Destroy()
        end
        if self.Holder and self.Holder.Parent then
            self.Holder:Destroy()
        end
        if self.TooltipTable and self.TooltipTable.Destroy then
            self.TooltipTable:Destroy()
        end
        if self.Groupbox and self.Groupbox.Elements then
            for i, elem in ipairs(self.Groupbox.Elements) do
                if elem == self then
                    table.remove(self.Groupbox.Elements, i)
                    break
                end
            end
        end
        for i, btn in ipairs(Buttons) do
            if btn == self then
                table.remove(Buttons, i)
                break
            end
        end
        Buttons[self.Text] = nil
    end
    if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
        Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
        Button.TooltipTable.Disabled = Button.Disabled
    end
    if Button.Risky then
        if Button.TextLabel then
            Button.TextLabel.TextColor3 = Library.Scheme.Red
        end
    end
    Button:UpdateColors()
    Groupbox:Resize()
    Button.Holder = Holder
    table.insert(Groupbox.Elements, Button)
    if Info.Idx then
        Buttons[Info.Idx] = Button
    else
        table.insert(Buttons, Button)
    end
    Buttons[Info.Text] = Button
    return Button
end


    function Funcs:AddCheckbox(Idx, Info)
    Info = Library:Validate(Info, Templates.Toggle)

    local Groupbox = self
    local Container = Groupbox.Container

    local Toggle = {
        Text = Info.Text,
        Value = Info.Default,
        Tooltip = Info.Tooltip,
        DisabledTooltip = Info.DisabledTooltip,
        TooltipTable = nil,
        Callback = Info.Callback,
        Changed = Info.Changed,
        Risky = Info.Risky,
        Beta = Info.Beta,
        Disabled = Info.Disabled,
        Visible = Info.Visible,
        Addons = {},
        Type = "Toggle",
        RowStyle = "Checkbox",
    }
    local function GetDisplayText()
        return Toggle.Text
    end
    local function GetClippedDisplayText(Text, Width, FontFace, TextSize)
        Text = tostring(Text or "")
        Width = math.max(0, Width or 0)

        if Width <= 0 or Text == "" then
            return ""
        end

        if Library:GetTextBounds(Text, FontFace, TextSize) <= Width then
            return Text
        end

        local Ellipsis = "...."
        if Library:GetTextBounds(Ellipsis, FontFace, TextSize) > Width then
            return ""
        end

        local Low, High = 0, #Text
        while Low < High do
            local Mid = math.ceil((Low + High) / 2)
            local Candidate = Text:sub(1, Mid) .. Ellipsis
            if Library:GetTextBounds(Candidate, FontFace, TextSize) <= Width then
                Low = Mid
            else
                High = Mid - 1
            end
        end

        return Text:sub(1, Low) .. Ellipsis
    end

    local Button = New("TextButton", {
        Active = not Toggle.Disabled,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Text = "",
        Visible = Toggle.Visible,
        Parent = Container,
    })

    local LabelClip = New("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(26, 0),
        Size = UDim2.new(1, -26, 1, 0),
        ZIndex = Button.ZIndex + 1,
        Parent = Button,
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        Text = GetDisplayText(),
        TextSize = 14,
        TextTransparency = 0.4,
        TextTruncate = Enum.TextTruncate.None,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = LabelClip.ZIndex + 1,
        Parent = LabelClip,
    })
    local WarningImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Image = "",
        ImageColor3 = Color3.fromRGB(255, 170, 60),
        ImageRectOffset = Vector2.zero,
        ImageRectSize = Vector2.zero,
        Position = UDim2.new(1, -24, 0, 9),
        Size = UDim2.fromOffset(14, 14),
        Visible = false,
        ZIndex = Button.ZIndex + 2,
        Parent = Button,
    })
    local WarningButton = New("TextButton", {
        AnchorPoint = WarningImage.AnchorPoint,
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = WarningImage.Position,
        Size = WarningImage.Size,
        Text = "",
        Visible = WarningImage.Visible,
        ZIndex = WarningImage.ZIndex + 1,
        Parent = Button,
    })

    local function RefreshCheckboxAccessories()
        local accessoryIcon = Toggle.Beta and InfoIcon or (Toggle.Risky and WarningIcon or nil)
        local accessoryVisible = accessoryIcon ~= nil
        local accessoryWidth = accessoryVisible and math.max(14 * Library.DPIScale, WarningImage.AbsoluteSize.X, WarningImage.Size.X.Offset) or 0
        local labelInset = 26 * Library.DPIScale
        local gap = 6 * Library.DPIScale
        local stack = {}
        local totalWidth = 0

        if accessoryVisible then
            WarningImage.Image = accessoryIcon.Url or ""
            WarningImage.ImageColor3 = Toggle.Beta and BetaIconColor or Color3.fromRGB(255, 170, 60)
            WarningImage.ImageRectOffset = accessoryIcon.ImageRectOffset or Vector2.zero
            WarningImage.ImageRectSize = accessoryIcon.ImageRectSize or Vector2.zero
            table.insert(stack, {
                Button = WarningImage,
                Overlay = WarningButton,
                Width = accessoryWidth,
                Y = 2 * Library.DPIScale,
            })
            totalWidth = totalWidth + accessoryWidth
        end

        for i = 1, #Toggle.Addons do
            local addon = Toggle.Addons[i]
            local button = addon and addon.Button
            if button and (addon.Type == "KeyPicker" or addon.Type == "ColorPicker" or addon.Type == "Config") then
                local width = math.max(addon.AccessoryWidth or 0, button.AbsoluteSize.X, button.Size.X.Offset)
                table.insert(stack, {
                    Button = button,
                    Width = width,
                    Y = 0,
                })
                totalWidth = totalWidth + width
            end
        end

        local gapWidth = math.max(0, (#stack - 1) * gap)
        local stackWidth = totalWidth + gapWidth
        local buttonWidth = Button.AbsoluteSize.X
        if Groupbox.IsConfigMenu then
            local menuWidth = (Groupbox.ConfigMenuWidth or 214) * Library.DPIScale
            local menuPadding = (Groupbox.ConfigMenuPadding or 8) * 2 * Library.DPIScale
            buttonWidth = math.max(buttonWidth, menuWidth - menuPadding)
        end
        local cursorX = buttonWidth - stackWidth

        WarningImage.Visible = accessoryVisible
        WarningButton.Visible = accessoryVisible

        for i = 1, #stack do
            local item = stack[i]
            item.Button.AnchorPoint = Vector2.zero
            item.Button.Position = UDim2.fromOffset(cursorX, item.Y)
            if item.Overlay then
                item.Overlay.AnchorPoint = Vector2.zero
                item.Overlay.Position = item.Button.Position
            end
            cursorX = cursorX + item.Width + gap
        end

        local accessoryGap = stackWidth > 0 and 6 * Library.DPIScale or 0
        local labelWidth = math.max(1, buttonWidth - labelInset - stackWidth - accessoryGap)
        local displayText = Groupbox.IsConfigMenu
            and tostring(GetDisplayText() or "")
            or GetClippedDisplayText(GetDisplayText(), labelWidth, Label.FontFace, Label.TextSize)
        local textWidth = math.ceil(Library:GetTextBounds(displayText, Label.FontFace, Label.TextSize)) + 2
        Label.Text = displayText
        LabelClip.Size = UDim2.new(0, labelWidth, 1, 0)
        Label.Size = UDim2.new(0, math.max(labelWidth, textWidth), 1, 0)
        if Groupbox.IsConfigMenu then
            LabelClip.ClipsDescendants = false
            LabelClip.Position = UDim2.fromOffset(26 * Library.DPIScale, 0)
            LabelClip.Size = UDim2.new(0, labelWidth, 1, 0)
            Label.Size = UDim2.new(0, labelWidth, 1, 0)
        end
    end

    local function UpdateRiskyIconPosition()
        RefreshCheckboxAccessories()
    end

    UpdateRiskyIconPosition()
    Library:GiveSignal(Button:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateRiskyIconPosition))
    if Toggle.Beta then
        Library:BindBetaWarning(WarningButton)
    elseif Toggle.Risky then
        Library:BindRiskyWarning(WarningButton)
    end
    Toggle.RefreshAccessoryLayout = RefreshCheckboxAccessories

    local Checkbox = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Parent = Button,
    })
    Checkbox:SetAttribute("ExcludeMenuTransparency", true)

    New("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = Checkbox,
    })

    local CheckboxStroke = New("UIStroke", {
        Color = "OutlineColor",
        Parent = Checkbox,
    })

    local CheckImage = New("ImageLabel", {
        Image = CheckIcon and CheckIcon.Url or "",
        ImageColor3 = "AccentColor",
        ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
        ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
        ImageTransparency = 1,
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        Parent = Checkbox,
    })
    CheckImage:SetAttribute("ExcludeMenuTransparency", true)

    function Toggle:UpdateColors()
        Toggle:Display()
        UpdateRiskyIconPosition()
    end

    function Toggle:Display()
        if Library.Unloaded then
            return
        end

        local toggleTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

        if Toggle.Disabled then
            Label.TextTransparency = 0.8
            CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1
            Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
            Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"
            return
        end

        TweenService:Create(Label, toggleTweenInfo, {TextTransparency = Toggle.Value and 0 or 0.4}):Play()
        TweenService:Create(CheckImage, toggleTweenInfo, {ImageTransparency = Toggle.Value and 0 or 1}):Play()

        Checkbox.BackgroundColor3 = Library.Scheme.MainColor
        Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
    end

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
    end

    function Toggle:SetValue(Value)
        if Toggle.Disabled then
            return
        end

        Toggle.Value = Value
        Toggle:Display()

        for _, Addon in pairs(Toggle.Addons) do
            if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                Addon.Toggled = Toggle.Value
                Addon:Update()
            end
        end

        Library:SafeCallback(Toggle.Callback, Toggle.Value)
        Library:SafeCallback(Toggle.Changed, Toggle.Value)
    end

    function Toggle:SetDisabled(Disabled)
        Toggle.Disabled = Disabled

        if Toggle.TooltipTable then
            Toggle.TooltipTable.Disabled = Disabled
        end

        for _, Addon in pairs(Toggle.Addons) do
            if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                Addon:Update()
            end
        end

        Button.Active = not Disabled
        Toggle:Display()
    end

    function Toggle:SetVisible(Visible)
        Toggle.Visible = Visible
        Button.Visible = Visible
        Groupbox:Resize()
    end

    function Toggle:SetText(Text)
        Toggle.Text = Text
        RefreshCheckboxAccessories()
    end

    Button.MouseButton1Click:Connect(function()
        if Library.SuppressNextRiskyToggleClick then
            Library.SuppressNextRiskyToggleClick = false
            return
        end
        if Toggle.Disabled then
            return
        end
        Toggle:SetValue(not Toggle.Value)
    end)

    if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
        Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
        Toggle.TooltipTable.Disabled = Toggle.Disabled
    end

    if Toggle.Risky then
        Label.TextColor3 = Library.Scheme.Red
        Library.Registry[Label].TextColor3 = "Red"
    end

    Toggle:Display()
    Groupbox:Resize()

    Toggle.TextLabel = Label
    Toggle.Container = Container
    Toggle.Holder = Button
    Toggle.Groupbox = Groupbox
    Toggle.KeyPickerParent = Button

    setmetatable(Toggle, BaseAddons)
    AddToggleConfigMenu(Toggle, Info.Config or Info.Configs)

    table.insert(Groupbox.Elements, Toggle)
    Toggles[Idx] = Toggle

    function Toggle:Delete()
        if Toggle.Holder and Toggle.Holder.Parent then
            Toggle.Holder:Destroy()
        end

        if Toggle.TooltipTable and Toggle.TooltipTable.Destroy then
            Toggle.TooltipTable:Destroy()
        end
        if Toggle.ConfigMenu and Toggle.ConfigMenu.Menu then
            Toggle.ConfigMenu.Menu:Destroy()
        end

        for i, v in ipairs(Groupbox.Elements) do
            if v == Toggle then
                table.remove(Groupbox.Elements, i)
                break
            end
        end

        Toggles[Idx] = nil

        Groupbox:Resize()
    end

    return Toggle
end


    function Funcs:AddToggle(Idx, Info)
    if Library.ForceCheckbox then
        return Funcs.AddCheckbox(self, Idx, Info)
    end

    Info = Library:Validate(Info, Templates.Toggle)

    local Groupbox = self
    local Container = Groupbox.Container

    local Toggle = {
        Text = Info.Text,
        Value = Info.Default,
        Tooltip = Info.Tooltip,
        DisabledTooltip = Info.DisabledTooltip,
        TooltipTable = nil,
        Callback = Info.Callback,
        Changed = Info.Changed,
        Risky = Info.Risky,
        Beta = Info.Beta,
        Disabled = Info.Disabled,
        Visible = Info.Visible,
        Addons = {},
        Type = "Toggle",
        RowStyle = "Switch",
    }
    local function GetDisplayText()
        return Toggle.Text
    end
    local function GetClippedDisplayText(Text, Width, FontFace, TextSize)
        Text = tostring(Text or "")
        Width = math.max(0, Width or 0)

        if Width <= 0 or Text == "" then
            return ""
        end

        if Library:GetTextBounds(Text, FontFace, TextSize) <= Width then
            return Text
        end

        local Ellipsis = "...."
        if Library:GetTextBounds(Ellipsis, FontFace, TextSize) > Width then
            return ""
        end

        local Low, High = 0, #Text
        while Low < High do
            local Mid = math.ceil((Low + High) / 2)
            local Candidate = Text:sub(1, Mid) .. Ellipsis
            if Library:GetTextBounds(Candidate, FontFace, TextSize) <= Width then
                Low = Mid
            else
                High = Mid - 1
            end
        end

        return Text:sub(1, Low) .. Ellipsis
    end


    local Button = New("TextButton", {
        Active = not Toggle.Disabled,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Text = "",
        Visible = Toggle.Visible,
        Parent = Container,
    })

    local LabelClip = New("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(1, -68, 1, 0),
        Parent = Button,
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        Text = GetDisplayText(),
        TextSize = 14,
        TextTransparency = 0.4,
        TextTruncate = Enum.TextTruncate.None,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = LabelClip,
    })
    local WarningImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Image = "",
        ImageColor3 = Color3.fromRGB(255, 170, 60),
        ImageRectOffset = Vector2.zero,
        ImageRectSize = Vector2.zero,
        Position = UDim2.new(1, -50, 0, 9),
        Size = UDim2.fromOffset(14, 14),
        Visible = false,
        Parent = Button,
    })
    local WarningButton = New("TextButton", {
        AnchorPoint = WarningImage.AnchorPoint,
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = WarningImage.Position,
        Size = WarningImage.Size,
        Text = "",
        Visible = WarningImage.Visible,
        ZIndex = (WarningImage.ZIndex or 1) + 1,
        Parent = Button,
    })

    local function RefreshToggleAccessories()
        local switchLeftInset = 39 * Library.DPIScale
        local accessoryIcon = Toggle.Beta and InfoIcon or (Toggle.Risky and WarningIcon or nil)
        local accessoryVisible = accessoryIcon ~= nil
        local accessoryWidth = accessoryVisible and math.max(14 * Library.DPIScale, WarningImage.AbsoluteSize.X, WarningImage.Size.X.Offset) or 0
        local gap = 6 * Library.DPIScale
        local stack = {}
        local totalWidth = 0

        if accessoryVisible then
            WarningImage.Image = accessoryIcon.Url or ""
            WarningImage.ImageColor3 = Toggle.Beta and BetaIconColor or Color3.fromRGB(255, 170, 60)
            WarningImage.ImageRectOffset = accessoryIcon.ImageRectOffset or Vector2.zero
            WarningImage.ImageRectSize = accessoryIcon.ImageRectSize or Vector2.zero
            table.insert(stack, {
                Button = WarningImage,
                Overlay = WarningButton,
                Width = accessoryWidth,
                Y = 2 * Library.DPIScale,
            })
            totalWidth = totalWidth + accessoryWidth
        end

        for i = 1, #Toggle.Addons do
            local addon = Toggle.Addons[i]
            local button = addon and addon.Button
            if button and (addon.Type == "KeyPicker" or addon.Type == "ColorPicker" or addon.Type == "Config") then
                local width = math.max(addon.AccessoryWidth or 0, button.AbsoluteSize.X, button.Size.X.Offset)
                table.insert(stack, {
                    Button = button,
                    Width = width,
                    Y = 0,
                })
                totalWidth = totalWidth + width
            end
        end

        local gapWidth = math.max(0, (#stack - 1) * gap)
        local stackWidth = totalWidth + gapWidth
        local buttonWidth = Button.AbsoluteSize.X
        if Groupbox.IsConfigMenu then
            local menuWidth = (Groupbox.ConfigMenuWidth or 214) * Library.DPIScale
            local menuPadding = (Groupbox.ConfigMenuPadding or 8) * 2 * Library.DPIScale
            buttonWidth = math.max(buttonWidth, menuWidth - menuPadding)
        end
        local cursorX = buttonWidth - switchLeftInset - stackWidth

        WarningImage.Visible = accessoryVisible
        WarningButton.Visible = accessoryVisible

        for i = 1, #stack do
            local item = stack[i]
            item.Button.AnchorPoint = Vector2.zero
            item.Button.Position = UDim2.fromOffset(cursorX, item.Y)
            if item.Overlay then
                item.Overlay.AnchorPoint = Vector2.zero
                item.Overlay.Position = item.Button.Position
            end
            cursorX = cursorX + item.Width + gap
        end

        local accessoryGap = stackWidth > 0 and 6 * Library.DPIScale or 0
        local labelWidth = math.max(1, buttonWidth - switchLeftInset - stackWidth - accessoryGap)
        local displayText = GetClippedDisplayText(GetDisplayText(), labelWidth, Label.FontFace, Label.TextSize)
        local textWidth = math.ceil(Library:GetTextBounds(displayText, Label.FontFace, Label.TextSize)) + 2
        Label.Text = displayText
        LabelClip.Size = UDim2.new(0, labelWidth, 1, 0)
        Label.Size = UDim2.new(0, math.max(labelWidth, textWidth), 1, 0)
    end

    local function UpdateRiskyIconPosition()
        RefreshToggleAccessories()
    end

    UpdateRiskyIconPosition()
    Library:GiveSignal(Button:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateRiskyIconPosition))
    if Toggle.Beta then
        Library:BindBetaWarning(WarningButton)
    elseif Toggle.Risky then
        Library:BindRiskyWarning(WarningButton)
    end

    local Switch = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.new(1, 4, 0, -1),
        Size = UDim2.fromOffset(38, 18),
        Parent = Button,
    })
    Switch:SetAttribute("ExcludeMenuTransparency", true)

    New("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = Switch,
    })

    New("UIPadding", {
        PaddingBottom = UDim.new(0, 3),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 3),
        Parent = Switch,
    })

    local SwitchStroke = New("UIStroke", {
        Color = "OutlineColor",
        Parent = Switch,
    })

    local Ball = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Parent = Switch,
    })
    Ball:SetAttribute("ExcludeMenuTransparency", true)

    New("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = Ball,
    })

    function Toggle:UpdateColors()
        Toggle:Display()
        UpdateRiskyIconPosition()
    end

    function Toggle:Display()
        if Library.Unloaded then
            return
        end

        local Offset = Toggle.Value and 1 or 0
        local t = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
        SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

        local enabledFillColor = Toggle.Value
            and Library:GetBetterColor(Library.Scheme.BackgroundColor, 3)
            or Library.Scheme.BackgroundColor

        Switch.BackgroundColor3 = enabledFillColor
        SwitchStroke.Color = Library.Scheme.OutlineColor

        Library.Registry[Switch].BackgroundColor3 = function()
            return Toggle.Value
                and Library:GetBetterColor(Library.Scheme.BackgroundColor, 3)
                or Library.Scheme.BackgroundColor
        end
        Library.Registry[SwitchStroke].Color = "OutlineColor"

        if Toggle.Disabled then
            Label.TextTransparency = 0.8

            Ball.AnchorPoint = Vector2.new(Offset, 0)
            Ball.Position = UDim2.fromScale(Offset, 0)

            TweenService:Create(Ball, t, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
                Transparency = 0.8,
            }):Play()

            Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.AccentColor)
            Library.Registry[Ball].BackgroundColor3 = function()
                return Library:GetDarkerColor(Library.Scheme.AccentColor)
            end

            return
        end

        TweenService:Create(Label, t, {
            TextTransparency = Toggle.Value and 0 or 0.7,
        }):Play()

        TweenService:Create(Ball, t, {
            AnchorPoint = Vector2.new(Offset, 0),
            Position = UDim2.fromScale(Offset, 0),
            Transparency = Toggle.Value and 0 or 0.6,
        }):Play()

        Ball.BackgroundColor3 = Toggle.Value
            and Library:GetBetterColor(Library.Scheme.AccentColor, 4)
            or Library:GetDarkerColor(Library.Scheme.AccentColor)
        Library.Registry[Ball].BackgroundColor3 = function()
            return Toggle.Value
                and Library:GetBetterColor(Library.Scheme.AccentColor, 4)
                or Library:GetDarkerColor(Library.Scheme.AccentColor)
        end
    end

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
    end

    function Toggle:SetValue(Value)
        if Toggle.Disabled then
            return
        end

        Toggle.Value = Value
        Toggle:Display()

        for _, Addon in pairs(Toggle.Addons) do
            if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                Addon.Toggled = Toggle.Value
                Addon:Update()
            end
        end

        Library:SafeCallback(Toggle.Callback, Toggle.Value)
        Library:SafeCallback(Toggle.Changed, Toggle.Value)
    end

    function Toggle:SetDisabled(Disabled)
        Toggle.Disabled = Disabled

        if Toggle.TooltipTable then
            Toggle.TooltipTable.Disabled = Disabled
        end

        for _, Addon in pairs(Toggle.Addons) do
            if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                Addon:Update()
            end
        end

        Button.Active = not Disabled
        Toggle:Display()
    end

    function Toggle:SetVisible(Visible)
        Toggle.Visible = Visible
        Button.Visible = Visible
        Groupbox:Resize()
    end

    function Toggle:SetText(Text)
        Toggle.Text = Text
        RefreshToggleAccessories()
    end

    Button.MouseButton1Click:Connect(function()
        if Library.SuppressNextRiskyToggleClick then
            Library.SuppressNextRiskyToggleClick = false
            return
        end
        if Toggle.Disabled then
            return
        end
        Toggle:SetValue(not Toggle.Value)
    end)

    if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
        Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
        Toggle.TooltipTable.Disabled = Toggle.Disabled
    end

    if Toggle.Risky then
        Label.TextColor3 = Library.Scheme.Red
        Library.Registry[Label].TextColor3 = "Red"
    end

    Toggle:Display()
    Groupbox:Resize()

    Toggle.TextLabel = Label
    Toggle.Container = Container
    Toggle.Holder = Button
    Toggle.Groupbox = Groupbox
    Toggle.WarningImage = WarningImage
    Toggle.WarningButton = WarningButton
    Toggle.RefreshRiskyIconPosition = UpdateRiskyIconPosition
    Toggle.RefreshAccessoryLayout = RefreshToggleAccessories
    Toggle.KeyPickerParent = Button

    setmetatable(Toggle, BaseAddons)
    AddToggleConfigMenu(Toggle, Info.Config or Info.Configs)

    table.insert(Groupbox.Elements, Toggle)
    Toggles[Idx] = Toggle

    function Toggle:Delete()
        if Toggle.Holder and Toggle.Holder.Parent then
            Toggle.Holder:Destroy()
        end

        if Toggle.TooltipTable and Toggle.TooltipTable.Destroy then
            Toggle.TooltipTable:Destroy()
        end
        if Toggle.ConfigMenu and Toggle.ConfigMenu.Menu then
            Toggle.ConfigMenu.Menu:Destroy()
        end

        for i, elem in ipairs(Groupbox.Elements) do
            if elem == Toggle then
                table.remove(Groupbox.Elements, i)
                break
            end
        end

        Toggles[Idx] = nil
        Groupbox:Resize()
    end

    return Toggle
end

    function Funcs:AddInput(Idx, Info)
        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Text = Info.Text,
            Value = Info.Default,
            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Input",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:SetValue(Text)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #Text > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            Input.Value = Text
            Box.Text = Text

            if not Input.Disabled then
                Library:SafeCallback(Input.Callback, Input.Value)
                Library:SafeCallback(Input.Changed, Input.Value)
            end
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        if Input.Finished then
            Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    return
                end

                Input:SetValue(Box.Text)
            end)
        else
            Box:GetPropertyChangedSignal("Text"):Connect(function()
                Input:SetValue(Box.Text)
            end)
        end

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        table.insert(Groupbox.Elements, Input)

        Options[Idx] = Input

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        Info = Library:Validate(Info, Templates.Slider)
    
        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Text = Info.Text,
            Value = Info.Default,
            Min = Info.Min,
            Max = Info.Max,
            Prefix = Info.Prefix,
            Suffix = Info.Suffix or "%",
            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,
            Callback = Info.Callback,
            Changed = Info.Changed,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Type = "Slider",
        }
    
        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 38),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local HeaderRow = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 16),
            Parent = Holder,
        })
    
        local SliderLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -48, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = Slider.Text,
            TextSize = 14,
            TextColor3 = "FontColor",
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Code,
            Parent = HeaderRow,
        })

        local TextBox = New("TextBox", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 88, 1, 0),
            Font = Enum.Font.Code,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = tostring(Slider.Value) .. Slider.Suffix,
            ClearTextOnFocus = true,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = HeaderRow,
        })

        local ControlRow = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 19),
            Size = UDim2.new(1, 0, 0, 16),
            Parent = Holder,
        })

        local MinusButton = New("TextButton", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.5, -3),
            Size = UDim2.fromOffset(18, 16),
            Text = "-",
            TextSize = 15,
            TextTransparency = 0.25,
            Parent = ControlRow,
        })

        local PlusButton = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0.5, -3),
            Size = UDim2.fromOffset(18, 16),
            Text = "+",
            TextSize = 15,
            TextTransparency = 0.25,
            Parent = ControlRow,
        })
    
        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            Position = UDim2.new(0, 24, 0.5, -2),
            Size = UDim2.new(1, -48, 0, 4),
            Text = "",
            AutoButtonColor = false,
            ZIndex = Holder.ZIndex + 1,
            Parent = ControlRow,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = Bar
        })
    
        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })
        Fill:SetAttribute("ExcludeMenuTransparency", true)
    
        local Dot = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.fromOffset(10, 10),
            Position = UDim2.new(0, 0, 0.5, 0),
            ZIndex = Bar.ZIndex + 2,
            Parent = Bar,
        })
        Dot:SetAttribute("ExcludeMenuTransparency", true)
    
        New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})
        New("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Bar})
    
        function Slider:UpdateColors()
            if Library.Unloaded then return end
            local disabledTrackColor = Library:GetBetterColor(Library.Scheme.MainColor, 1)
            local disabledFillColor = Library:GetBetterColor(Library.Scheme.MainColor, -1)
            local disabledDotColor = Library:GetBetterColor(Library.Scheme.FontColor, -5)
            SliderLabel.TextTransparency = Slider.Disabled and 0.6 or 0
            Fill.BackgroundColor3 = Slider.Disabled and disabledFillColor or Library.Scheme.AccentColor
            Dot.BackgroundColor3 = Slider.Disabled and disabledDotColor or Color3.fromRGB(255, 255, 255)
            Dot.BackgroundTransparency = Slider.Disabled and 0.4 or 0
            TextBox.TextTransparency = Slider.Disabled and 0.6 or 0
            MinusButton.TextTransparency = Slider.Disabled and 0.7 or 0.25
            PlusButton.TextTransparency = Slider.Disabled and 0.7 or 0.25
            Bar.BackgroundColor3 = Slider.Disabled and disabledTrackColor or Library.Scheme.MainColor
            --Bar.AutoButtonColor = not Slider.Disabled
        end
    
        function Slider:Display()
            if Library.Unloaded then return end
            TextBox.Text = tostring(Slider.Prefix or "") .. tostring(Slider.Value) .. tostring(Slider.Suffix)
            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            TweenService:Create(Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale(X, 1)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(X, 0, 0.5, 0)}):Play()
        end
    
        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end
    
        local function Round(Value)
            if Info.Rounding == 0 then return math.floor(Value) end
            return tonumber(string.format("%." .. (Info.Rounding or 2) .. "f", Value))
        end
    
        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max must be greater than min.")
            Slider.Value = math.clamp(Slider.Value, Slider.Min, Value)
            Slider.Max = Value
            Slider:Display()
        end
    
        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min must be less than max.")
            Slider.Value = math.clamp(Slider.Value, Value, Slider.Max)
            Slider.Min = Value
            Slider:Display()
        end
    
        function Slider:SetValue(Str)
            if Slider.Disabled then return end
            local Num = tonumber(Str)
            if not Num then return end
            Num = Round(Num)
            Num = math.clamp(Num, Slider.Min, Slider.Max)
            Slider.Value = Num
            Slider:Display()
            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end
    
        function Slider:SetDisabled(Disabled)
            Slider.Disabled = Disabled
            if Slider.TooltipTable then Slider.TooltipTable.Disabled = Slider.Disabled end
            Bar.Active = not Slider.Disabled
            MinusButton.Active = not Slider.Disabled
            PlusButton.Active = not Slider.Disabled
            TextBox.ClearTextOnFocus = not Slider.Disabled
            Slider:UpdateColors()
        end
    
        function Slider:SetVisible(Visible)
            Slider.Visible = Visible
            Holder.Visible = Visible
            Groupbox:Resize()
        end
    
        function Slider:SetText(Text)
            Slider.Text = Text
            SliderLabel.Text = Text
        end
    
        function Slider:SetPrefix(Prefix)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        local function GetStep()
            if Info.Step then
                return tonumber(Info.Step) or 1
            end
            if Info.Rounding and Info.Rounding > 0 then
                return 1 / (10 ^ Info.Rounding)
            end
            return 1
        end

        local HoldStepToken = 0

        local function StepSlider(Direction)
            if Slider.Disabled then return end
            Slider:SetValue(Slider.Value + (GetStep() * Direction))
        end

        local function StartHoldStep(Direction)
            if Slider.Disabled then return end
            HoldStepToken += 1
            local token = HoldStepToken
            StepSlider(Direction)

            task.delay(0.35, function()
                while token == HoldStepToken and not Slider.Disabled do
                    StepSlider(Direction)
                    task.wait(0.06)
                end
            end)
        end

        local function StopHoldStep()
            HoldStepToken += 1
        end
    
        function Slider:SetSuffix(Suffix)
            Slider.Suffix = Suffix
            Slider:Display()
        end
    
        Bar.MouseButton1Down:Connect(function()
            if Slider.Disabled then return end
            for _, Side in pairs(Library.ActiveTab.Sides) do Side.ScrollingEnabled = false end
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) do
                local Location = Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local Old = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale))
                Slider:Display()
                if Slider.Value ~= Old then
                    Library:SafeCallback(Slider.Callback, Slider.Value)
                    Library:SafeCallback(Slider.Changed, Slider.Value)
                end
                RunService.RenderStepped:Wait()
            end
            for _, Side in pairs(Library.ActiveTab.Sides) do Side.ScrollingEnabled = true end
        end)
    
        Dot.InputBegan:Connect(function(input)
            if Slider.Disabled then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                for _, Side in pairs(Library.ActiveTab.Sides) do Side.ScrollingEnabled = false end
                
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    local mousePos = UserInputService:GetMouseLocation()
                    local Location = mousePos.X
                    local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local Old = Slider.Value
                    Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale))
                    Slider:Display()
                    if Slider.Value ~= Old then
                        Library:SafeCallback(Slider.Callback, Slider.Value)
                        Library:SafeCallback(Slider.Changed, Slider.Value)
                    end
                end)
        
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        connection:Disconnect()
                        for _, Side in pairs(Library.ActiveTab.Sides) do Side.ScrollingEnabled = true end
                    end
                end)
            end
        end)

        MinusButton.MouseButton1Down:Connect(function()
            StartHoldStep(-1)
        end)

        PlusButton.MouseButton1Down:Connect(function()
            StartHoldStep(1)
        end)

        MinusButton.MouseLeave:Connect(StopHoldStep)
        PlusButton.MouseLeave:Connect(StopHoldStep)

        MinusButton.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                StopHoldStep()
            end
        end)

        PlusButton.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                StopHoldStep()
            end
        end)

        Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                StopHoldStep()
            end
        end))

        MinusButton.TouchLongPress:Connect(function(_, State)
            if State == Enum.UserInputState.Begin then
                StartHoldStep(-1)
            elseif State == Enum.UserInputState.End then
                StopHoldStep()
            end
        end)

        PlusButton.TouchLongPress:Connect(function(_, State)
            if State == Enum.UserInputState.Begin then
                StartHoldStep(1)
            elseif State == Enum.UserInputState.End then
                StopHoldStep()
            end
        end)

        TextBox.FocusLost:Connect(function()
            if Slider.Disabled then return end
            local text = TextBox.Text:gsub("%%", ""):gsub("%s+", "")
            Slider:SetValue(text)
        end)
    
        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end
    
        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()
    
        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)
    
        Options[Idx] = Slider
    
        return Slider
    end
    
    
    ---end

    function Funcs:AddDropdown(Idx, Info)
        Info = Library:Validate(Info, Templates.Dropdown)

        local Groupbox = self
        local Container = Groupbox.Container

        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end
        local Dropdown = {
            Text = typeof(Info.Text) == "string" and Info.Text or nil,
            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,

            SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Dropdown",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 21),
            Visible = Dropdown.Visible,
            Parent = Container,
        })
    
        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Dropdown.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not Info.Text,
            Parent = Holder,
        })

        local Display = New("TextButton", {
            Active = not Dropdown.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = "---",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4),
            Parent = Display,
        })

        local ArrowImage = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Image = ArrowIcon and ArrowIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = ArrowIcon and ArrowIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = ArrowIcon and ArrowIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Parent = Display,
        })

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = Display,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SearchBox,
            })
        end

        local MenuTable = Library:AddContextMenu(
            Display,
            function()
                return UDim2.fromOffset(Display.AbsoluteSize.X, 0)
            end,
            function()
                return { 0.5, Display.AbsoluteSize.Y + 1.5 }
            end,
            2,
            function(Active: boolean)
                Display.TextTransparency = (Active and SearchBox) and 1 or 0
                ArrowImage.ImageTransparency = Active and 0 or 0.5
                ArrowImage.Rotation = Active and 180 or 0
                if SearchBox then
                    SearchBox.Text = ""
                    SearchBox.Visible = Active
                end
            end
        )
        Dropdown.Menu = MenuTable
        Library:UpdateDPI(MenuTable.Menu, {
            Position = false,
            Size = false,
        })

        function Dropdown:RecalculateListSize(Count)
            local Y = math.clamp(
                (Count or GetTableSize(Dropdown.Values)) * (21 * Library.DPIScale),
                0,
                Info.MaxVisibleDropdownItems * (21 * Library.DPIScale)
            )

            MenuTable:SetSize(function()
                return UDim2.fromOffset(Display.AbsoluteSize.X, Y)
            end)
        end

        function Dropdown:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
            Display.TextTransparency = Dropdown.Disabled and 0.8 or 0
            ArrowImage.ImageTransparency = Dropdown.Disabled and 0.8 or MenuTable.Active and 0 or 0.5
        end

        function Dropdown:Display()
            if Library.Unloaded then
                return
            end

            local Str = ""

            if Info.Multi then
                for _, Value in pairs(Dropdown.Values) do
                    if Dropdown.Value[Value] then
                        Str = Str
                            .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(Value)) or tostring(Value))
                            .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                Str = Dropdown.Value and tostring(Dropdown.Value) or ""
                if Str ~= "" and Info.FormatDisplayValue then
                    Str = tostring(Info.FormatDisplayValue(Str))
                end
            end

            if #Str > 25 then
                Str = Str:sub(1, 22) .. "..."
            end

            Display.Text = (Str == "" and "---" or Str)
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func
        end

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local Table = {}

                for Value, _ in pairs(Dropdown.Value) do
                    table.insert(Table, Value)
                end

                return Table
            end

            return Dropdown.Value and 1 or 0
        end

        local Buttons = {}
        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues

            for Button, _ in pairs(Buttons) do
                Button:Destroy()
            end
            table.clear(Buttons)

            local Count = 0
            for _, Value in pairs(Values) do
                if SearchBox and not tostring(Value):lower():match(SearchBox.Text:lower()) then
                    continue
                end

                Count += 1
                local IsDisabled = table.find(DisabledValues, Value)
                local Table = {}

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    LayoutOrder = IsDisabled and 1 or 0,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = tostring(Value),
                    TextSize = 14,
                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = MenuTable.Menu,
                })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    Parent = Button,
                })

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Value]
                else
                    Selected = Dropdown.Value == Value
                end

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value]
                    else
                        Selected = Dropdown.Value == Value
                    end

                    Button.BackgroundTransparency = Selected and 0 or 1
                    Button.TextTransparency = IsDisabled and 0.8 or Selected and 0 or 0.5
                end

                if not IsDisabled then
                    Button.MouseButton1Click:Connect(function()
                        local Try = not Selected

                        if not (Dropdown:GetActiveValues() == 1 and not Try and not Info.AllowNull) then
                            Selected = Try
                            if Info.Multi then
                                Dropdown.Value[Value] = Selected and true or nil
                            else
                                Dropdown.Value = Selected and Value or nil
                            end

                            for _, OtherButton in pairs(Buttons) do
                                OtherButton:UpdateButton()
                            end
                        end

                        Table:UpdateButton()
                        Dropdown:Display()

                        Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                        Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
                    end)
                end

                Table:UpdateButton()
                Dropdown:Display()

                Buttons[Button] = Table
            end

            Dropdown:RecalculateListSize(Count)
        end

        function Dropdown:SetValue(Value)
            if Info.Multi then
                local Table = {}

                for Val, Active in pairs(Value or {}) do
                    if Active and table.find(Dropdown.Values, Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if table.find(Dropdown.Values, Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:Display()
            for _, Button in pairs(Buttons) do
                Button:UpdateButton()
            end

            if not Dropdown.Disabled then
                Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
            end
        end

        function Dropdown:SetValues(Values)
            Dropdown.Values = Values
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValues(Values)
            if typeof(Values) == "table" then
                for _, val in pairs(Values) do
                    table.insert(Dropdown.Values, val)
                end
            elseif typeof(Values) == "string" then
                table.insert(Dropdown.Values, Values)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(DisabledValues)
            Dropdown.DisabledValues = DisabledValues
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in pairs(DisabledValues) do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabled(Disabled: boolean)
            Dropdown.Disabled = Disabled

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable.Disabled = Dropdown.Disabled
            end

            MenuTable:Close()
            Display.Active = not Dropdown.Disabled
            Dropdown:UpdateColors()
        end

        function Dropdown:SetVisible(Visible: boolean)
            Dropdown.Visible = Visible

            Holder.Visible = Dropdown.Visible
            Groupbox:Resize()
        end

        function Dropdown:SetText(Text: string)
            Dropdown.Text = Text
            Holder.Size = UDim2.new(1, 0, 0, (Text and 39 or 21) * Library.DPIScale)

            Label.Text = Text and Text or ""
            Label.Visible = not not Text
        end

        Display.MouseButton1Click:Connect(function()
            if Dropdown.Disabled then
                return
            end

            MenuTable:Toggle()
        end)

        if SearchBox then
            SearchBox:GetPropertyChangedSignal("Text"):Connect(Dropdown.BuildDropdownList)
        end

        local Defaults = {}
        if typeof(Info.Default) == "string" then
            local Index = table.find(Dropdown.Values, Info.Default)
            if Index then
                table.insert(Defaults, Index)
            end
        elseif typeof(Info.Default) == "table" then
            for _, Value in next, Info.Default do
                local Index = table.find(Dropdown.Values, Value)
                if Index then
                    table.insert(Defaults, Index)
                end
            end
        elseif Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end
        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true
                else
                    Dropdown.Value = Dropdown.Values[Index]
                end

                if not Info.Multi then
                    break
                end
            end
        end

        if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, Display)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end

        Dropdown:UpdateColors()
        Dropdown:Display()
        Dropdown:BuildDropdownList()
        Groupbox:Resize()

        Dropdown.Holder = Holder
        table.insert(Groupbox.Elements, Dropdown)

        Options[Idx] = Dropdown

        return Dropdown
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()
end

function Library:SetNotifySide(Side: string)
    Library.NotifySide = Side

    if Side:lower() == "left" then
        NotificationArea.AnchorPoint = Vector2.new(0, 0)
        NotificationArea.Position = UDim2.fromOffset(6, 6)
        NotificationList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    else
        NotificationArea.AnchorPoint = Vector2.new(1, 0)
        NotificationArea.Position = UDim2.new(1, -6, 0, 6)
        NotificationList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    end
end

function Library:Notify(...)
    local Data = {}
    local Info = select(1, ...)

    if typeof(Info) == "table" then
        Data.Title = tostring(Info.Title)
        Data.Description = tostring(Info.Description)
        Data.Time = Info.Time or 5
        Data.SoundId = Info.SoundId
        Data.Steps = Info.Steps
    else
        Data.Description = tostring(Info)
        Data.Time = select(2, ...) or 5
        Data.SoundId = select(3, ...)
    end

    local FakeBackground = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Visible = false,
        Parent = NotificationArea,

        DPIExclude = {
            Size = true,
        },
    })

    local Background = Library:MakeOutline(FakeBackground, Library.CornerRadius, 5)
    Background.AutomaticSize = Enum.AutomaticSize.Y
    Background.Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -6, 0, -2) or UDim2.new(1, 6, 0, -2)
    Background.Size = UDim2.fromScale(1, 0)
    Library:UpdateDPI(Background, {
        Position = false,
        Size = false,
    })

    local Holder = New("Frame", {
        BackgroundColor3 = "MainColor",
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        Parent = Background,
    })
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius - 1),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = Holder,
    })

    local Title
    local Desc
    local TitleX = 0
    local DescX = 0

    local TimerFill

    if Data.Title then
        Title = New("TextLabel", {
            BackgroundTransparency = 1,
            Text = Data.Title,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Holder,

            DPIExclude = {
                Size = true,
            },
        })
    end
    if Data.Description then
        Desc = New("TextLabel", {
            BackgroundTransparency = 1,
            Text = Data.Description,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Holder,

            DPIExclude = {
                Size = true,
            },
        })
    end

    function Data:Resize()
        if Title then
            local X, Y = Library:GetTextBounds(
                Title.Text,
                Title.FontFace,
                Title.TextSize,
                NotificationArea.AbsoluteSize.X - (24 * Library.DPIScale)
            )
            Title.Size = UDim2.fromOffset(math.ceil(X), Y)
            TitleX = X
        end

        if Desc then
            local X, Y = Library:GetTextBounds(
                Desc.Text,
                Desc.FontFace,
                Desc.TextSize,
                NotificationArea.AbsoluteSize.X - (24 * Library.DPIScale)
            )
            Desc.Size = UDim2.fromOffset(math.ceil(X), Y)
            DescX = X
        end

        FakeBackground.Size = UDim2.fromOffset((TitleX > DescX and TitleX or DescX) + (24 * Library.DPIScale), 0)
    end

    function Data:ChangeTitle(NewText)
        if Title then
            Data.Title = tostring(NewText)
            Title.Text = Data.Title
            Data:Resize()
        end
    end

    function Data:ChangeDescription(NewText)
        if Desc then
            Data.Description = tostring(NewText)
            Desc.Text = Data.Description
            Data:Resize()
        end
    end

    function Data:ChangeStep(NewStep)
        if TimerFill and Data.Steps then
            NewStep = math.clamp(NewStep or 0, 0, Data.Steps)
            TimerFill.Size = UDim2.fromScale(NewStep / Data.Steps, 1)
        end
    end

    Data:Resize()

    local TimerHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = typeof(Data.Time) ~= "Instance" or typeof(Data.Steps) == "number",
        Parent = Holder,
    })
    local TimerBar = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = TimerHolder,
    })
    TimerFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size = UDim2.fromScale(1, 1),
        Parent = TimerBar,
    })
    
    if typeof(Data.Time) == "Instance" then
        TimerFill.Size = UDim2.fromScale(0, 1)
    end
    if Data.SoundId then
        New("Sound", {
            SoundId = "rbxassetid://" .. tostring(Data.SoundId):gsub("rbxassetid://", ""),
            Volume = 3,
            PlayOnRemove = true,
            Parent = SoundService,
        }):Destroy()
    end

    Library.Notifications[FakeBackground] = Data
    
    FakeBackground.Visible = true
    TweenService:Create(Background, Library.NotifyTweenInfo, {
        Position = UDim2.fromOffset(-2, -2),
    }):Play()

    task.delay(Library.NotifyTweenInfo.Time, function()
        if typeof(Data.Time) == "Instance" then
            Data.Time.Destroying:Wait()
        else
            TweenService
                :Create(TimerFill, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    Size = UDim2.fromScale(0, 1),
                })
                :Play()
            task.wait(Data.Time)
        end

        TweenService:Create(Background, Library.NotifyTweenInfo, {
            Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -6, 0, -2) or UDim2.new(1, 6, 0, -2),
        }):Play()
        task.delay(Library.NotifyTweenInfo.Time, function()
            Library.Notifications[FakeBackground] = nil
            FakeBackground:Destroy()
        end)
    end)

    return Data
end

function Library:CreateWindow(WindowInfo)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.MinSize = Vector2.new(math.min(Library.MinSize.X, MaxX), math.min(Library.MinSize.Y, MaxY))
    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font)
    end

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind

    local MainFrame
    local TitleHolder
    local TopBarLine
    local SearchBox
    local ResizeButton
    local Tabs
    local TabsHeader
    local TabsPrevButton
    local TabsNextButton
    local TabsListLayout
    local TabsSidebarShell
    local TabsSidebarHeader
    local TabsSidebarTitleFrame
    local TabsSidebarPrefixLabel
    local TabsSidebarSuffixHolder
    local TabsSidebarSuffixLabel
    local TabsSidebarUnderline
    local TabsSidebarHeaderLine
    local TabsSidebarDivider
    local TabsSidebarPanel
    local Container
    local TabSectionScale = 0.2
    Library.UseSidebarTabs = Library.UseSidebarTabs or false
    do
        Library.KeybindFrame, Library.KeybindContainer, Library.KeybindTitle = Library:AddDraggableMenu("Keybinds")
        Library.KeybindTitle.TextXAlignment = Enum.TextXAlignment.Center
        Library.KeybindTitle.Position = UDim2.fromOffset(0, 0)
        Library.KeybindTitle.Size = UDim2.new(1, 0, 0, 32)
        local KeybindTitlePadding = Library.KeybindTitle:FindFirstChildOfClass("UIPadding")
        if KeybindTitlePadding then
            KeybindTitlePadding.PaddingLeft = UDim.new(0, 32)
            KeybindTitlePadding.PaddingRight = UDim.new(0, 32)
        end
        local KeybindTitleIcon = Library:GetIcon("keyboard")
        if KeybindTitleIcon then
            New("ImageLabel", {
                Name = "KeybindTitleIcon",
                AnchorPoint = Vector2.new(0, 0.5),
                Image = KeybindTitleIcon.Url,
                ImageColor3 = Color3.fromRGB(165, 165, 165),
                ImageRectOffset = KeybindTitleIcon.ImageRectOffset,
                ImageRectSize = KeybindTitleIcon.ImageRectSize,
                Position = UDim2.fromOffset(10, 16),
                Size = UDim2.fromOffset(15, 15),
                Parent = Library.KeybindTitle.Parent,
            })
        end
        Library.KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        Library.KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        Library.KeybindFrame.Visible = false
        Library:UpdateDPI(Library.KeybindFrame, {
            Position = false,
            Size = false,
        })

        MainFrame = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            BackgroundTransparency = 0,
            Name = "Main",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        
            DPIExclude = {
                Position = true,
            },
        })        
        Library.MainFrame = MainFrame
        Library:GiveSignal(MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            Library:QueueScaledLayoutRefresh()
        end))
        New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius - 1),
            Parent = MainFrame,
        })
        New("UIStroke", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 3,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = MainFrame,
        })
        Library.CustomImageLayer = New("Frame", {
            BackgroundTransparency = 1,
            Name = "CustomImageLayer",
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(1, 1),
            ZIndex = 1,
            Parent = MainFrame,
        })
        Library.CustomImageLayer:SetAttribute("ExcludeMenuTransparency", true)
        New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius - 1),
            Parent = Library.CustomImageLayer,
        })
        --[[
    for i = 1, 1 do 
    local Shadow = New("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.71,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Position = UDim2.fromOffset(-14, -14),
        Size = UDim2.new(1, 26, 1, 26),
        ZIndex = 0,
        Parent = MainFrame,
    })
end
]]
        do
            local Lines = {
                {
                    Position = UDim2.fromOffset(0, 48),
                    Size = UDim2.new(1, 0, 0, 1),
                },
                {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, -14),
                    Size = UDim2.new(1, 0, 0, 1),
                },
            }
            for Index, Info in ipairs(Lines) do
                local Line = Library:MakeLine(MainFrame, Info)
                if Index == 1 then
                    TopBarLine = Line
                end
            end
            Library:MakeOutline(MainFrame, WindowInfo.CornerRadius, 0)
        end

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        --// Top Bar \\-
        local TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true)

        --// Title - Custom Logo
        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(TabSectionScale, 1),
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            Parent = TitleHolder,
        })

        if WindowInfo.Icon then
            New("ImageLabel", {
                Image = tonumber(WindowInfo.Icon) and "rbxassetid://" .. WindowInfo.Icon or WindowInfo.Icon,
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
        end

        --// SETTING LOGO - UBAH DISINI \\--
        local PrefixText = "Zal"      -- Ganti sesuai keinginan
        local SuffixText = "Store"    -- Ganti sesuai keinginan
        local TitleFont = Font.fromEnum(Enum.Font.GothamBold)
        
        -- Ukuran font (atur manual)
        local textSize = 20  -- Bisa diubah ke 22, 24, dll
        
        -- Hitung lebar teks
        local PrefixWidth = Library:GetTextBounds(PrefixText, TitleFont, textSize)
        local SuffixWidth = Library:GetTextBounds(SuffixText, TitleFont, textSize)
        
        -- Buat frame utama
        local TitleFrame = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, PrefixWidth + SuffixWidth, 1, 0),
            Parent = TitleHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = TitleFrame,
        })

        -- Prefix (warna accent)
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, PrefixWidth, 1, 0),
            FontFace = TitleFont,
            Text = PrefixText,
            TextSize = textSize,
            TextColor3 = "AccentColor",
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = TitleFrame,
        })

        -- Suffix (warna putih + underline)
        local SuffixHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, SuffixWidth, 1, 0),
            Parent = TitleFrame,
        })
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            FontFace = TitleFont,
            Text = SuffixText,
            TextSize = textSize,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = SuffixHolder,
        })
        New("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = "AccentColor",
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 1, -8),
            Size = UDim2.new(1, -2, 0, 2),
            Parent = SuffixHolder,
        })

        --// Search Box
        if getgenv().Usesearchbar == nil then
            getgenv().Usesearchbar = true
        end
        SearchBox = New("TextBox", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = "MainColor",
            PlaceholderText = "Search",
            Visible = getgenv().Usesearchbar,
            Position = UDim2.new(TabSectionScale, 8, 0.5, 0),
            Size = UDim2.new(1 - TabSectionScale, -57, 1, -16),
            TextScaled = true,
            Parent = TopBar,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = SearchBox,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = SearchBox,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            New("ImageLabel", {
                Image = SearchIcon.Url,
                ImageColor3 = "AccentColor",
                ImageRectOffset = SearchIcon.ImageRectOffset,
                ImageRectSize = SearchIcon.ImageRectSize,
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
        end

        function Library:SetSearchBarVisible(Visible)
            getgenv().Usesearchbar = Visible == true
            SearchBox.Visible = getgenv().Usesearchbar

            if not getgenv().Usesearchbar then
                SearchBox.Text = ""
            end
        end

        local MoveIcon = Library:GetIcon("move") ----add this back if mobile users start having issues
        if MoveIcon then
            New("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Image = MoveIcon.Url,
                Visible = false,
                ImageColor3 = "OutlineColor",
                ImageRectOffset = MoveIcon.ImageRectOffset,
                ImageRectSize = MoveIcon.ImageRectSize,
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(28, 28),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = TopBar,
            })
        end

        --// Bottom Bar \\--
        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 14),
            Parent = MainFrame,
        })
        Library:AddToRegistry(BottomBar, {
            BackgroundColor3 = "MainColor",
        })
        do
            local Cover = Library:MakeCover(BottomBar, "Top")
            Cover.BackgroundColor3 = Library.Scheme.MainColor
            Library:AddToRegistry(Cover, {
                BackgroundColor3 = "MainColor",
            })
        end
        New("UICorner", {
            CornerRadius = UDim.new(0, WindowInfo.CornerRadius - 1),
            Parent = BottomBar,
        })

        --// Footer
        local StatusHolder = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0, 90, 1, 0),
            Parent = BottomBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = StatusHolder,
        })

        local StatusDot = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 255, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(5, 5),
            Parent = StatusHolder,
        })

        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = StatusDot,
        })

        local StatusGlow = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(80, 255, 80),
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(10, 10),
            ZIndex = StatusDot.ZIndex - 1,
            Parent = StatusDot,
        })

        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = StatusGlow,
        })

        task.spawn(function()
            while StatusDot.Parent and not Library.Unloaded do
                TweenService:Create(StatusDot, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(120, 255, 120),
                    BackgroundTransparency = 0.35,
                }):Play()
                TweenService:Create(StatusGlow, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.28,
                    Size = UDim2.fromOffset(14, 14),
                }):Play()
                task.wait(0.85)

                TweenService:Create(StatusDot, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(0, 255, 0),
                    BackgroundTransparency = 0,
                }):Play()
                TweenService:Create(StatusGlow, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.6,
                    Size = UDim2.fromOffset(10, 10),
                }):Play()
                task.wait(0.85)
            end
        end)

        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 50, 1, 0),
            Text = "Online",
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = StatusHolder,
        })

        local FooterLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = WindowInfo.Footer,
            TextSize = 14,
            TextTransparency = 0.1,
            RichText = true,
            ZIndex = BottomBar.ZIndex + 1,
            Parent = BottomBar,
        })
        Library.Registry[FooterLabel] = {
            TextColor3 = "FontColor",
            Text = function()
                local footerText = WindowInfo.Footer or getgenv().IntScriptName or ""
                footerText = tostring(footerText)

                --// Strip any embedded rich-text colors so the footer follows the theme
                footerText = footerText:gsub("<font.->", ""):gsub("</font>", "")

                local AccentHex = Library.Scheme.AccentColor:ToHex()
                local FontHex = Library.Scheme.FontColor:ToHex()

                --// Only the "Store" word uses the accent color; everything else uses the font color
                footerText = footerText:gsub(
                    "Store",
                    string.format("<font color=\"#%s\">Store</font>", AccentHex)
                )

                return string.format(
                    "<font color=\"#%s\">%s</font>",
                    FontHex,
                    footerText
                )
            end
        }

        --// Resize Button
        local ResizeContentHidden = false
        local function SetResizeContentHidden(Hidden: boolean)
            if not Container then
                return
            end

            if Hidden then
                if ResizeContentHidden then
                    return
                end

                ResizeContentHidden = true
                Container.Visible = false
                return
            end

            if not ResizeContentHidden then
                return
            end

            ResizeContentHidden = false
            Container.Visible = true
        end

        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = BottomBar,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function(IsFinalResize)
                if IsFinalResize then
                    SetResizeContentHidden(false)
                    if Library.RefreshWindowTabsLayout then
                        Library.RefreshWindowTabsLayout()
                    end
                    for _, Tab in pairs(Library.Tabs) do
                        Tab:Resize(true)
                    end
                    Library:QueueScaledLayoutRefresh()
                    return
                end

                SetResizeContentHidden(true)
            end)
        end

        New("ImageLabel", {
            Image = ResizeIcon and ResizeIcon.Url or "",
            ImageColor3 = "AccentColor",
            ImageRectOffset = ResizeIcon and ResizeIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = ResizeIcon and ResizeIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = ResizeButton,
        })

        --// Tabs \\--
        TabsHeader = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 52),
            Size = UDim2.new(1, -20, 0, 34),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TabsHeader, false, true)

        TabsPrevButton = New("TextButton", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, -4),
            Size = UDim2.fromOffset(32, 34),
            Text = "<",
            TextSize = 26,
            TextTransparency = 0.3,
            Visible = false,
            Parent = TabsHeader,
        })

        TabsNextButton = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, -4),
            Size = UDim2.fromOffset(32, 34),
            Text = ">",
            TextSize = 26,
            TextTransparency = 0.3,
            Visible = false,
            Parent = TabsHeader,
        })

        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.X,
            Size = UDim2.new(1, 0, 0, 34),
            Parent = TabsHeader,
        })
        Library:MakeDraggable(MainFrame, Tabs, false, true)

        TabsListLayout = New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding = UDim.new(0, 10),
            Parent = Tabs,
        })

        TabsSidebarShell = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromOffset(190, 300),
            Visible = false,
            Parent = MainFrame,
        })
        TabsSidebarHeader = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 0, 48),
            Parent = TabsSidebarShell,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            Parent = TabsSidebarHeader,
        })
        TabsSidebarTitleFrame = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, -12, 1, 0),
            Parent = TabsSidebarHeader,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = TabsSidebarTitleFrame,
        })
        TabsSidebarPrefixLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font.fromEnum(Enum.Font.GothamBold),
            Text = PrefixText,
            TextSize = textSize,
            TextColor3 = "AccentColor",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, 22),
            Parent = TabsSidebarTitleFrame,
        })
        TabsSidebarSuffixHolder = New("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, 22),
            Parent = TabsSidebarTitleFrame,
        })
        TabsSidebarSuffixLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            FontFace = Font.fromEnum(Enum.Font.GothamBold),
            Text = SuffixText,
            TextSize = textSize,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = TabsSidebarSuffixHolder,
        })
        TabsSidebarUnderline = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = "AccentColor",
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 1, 0),
            Size = UDim2.new(1, -2, 0, 2),
            Parent = TabsSidebarSuffixHolder,
        })
        TabsSidebarHeaderLine = Library:MakeLine(TabsSidebarShell, {
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 1),
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, math.max(8, WindowInfo.CornerRadius - 4)),
            Parent = TabsSidebarShell,
        })
        New("UIStroke", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 1,
            Transparency = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = TabsSidebarShell,
        })
        TabsSidebarDivider = Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(190, 48),
            Size = UDim2.new(0, 1, 1, -68),
        })
        TabsSidebarPanel = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 50),
            Size = UDim2.new(1, 0, 1, -50),
            Visible = true,
            Parent = TabsSidebarShell,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = TabsSidebarPanel,
        })

        local function RefreshSidebarShellPosition()
            if not TabsSidebarShell or not MainFrame then
                return
            end

            local sidebarWidth = math.floor(190 * Library.DPIScale)
            local mainSize = MainFrame.AbsoluteSize
            TabsSidebarShell.Position = UDim2.fromOffset(0, 0)
            TabsSidebarShell.Size = UDim2.fromOffset(sidebarWidth, mainSize.Y)
            if TabsSidebarDivider then
                TabsSidebarDivider.Position = UDim2.fromOffset(sidebarWidth, 48 * Library.DPIScale)
                TabsSidebarDivider.Size = UDim2.new(0, 1, 1, -68 * Library.DPIScale)
            end
        end

        local ActiveTabLayoutQueued = false
        local function RefreshActiveTabAfterLayout()
            if ActiveTabLayoutQueued then
                return
            end

            ActiveTabLayoutQueued = true
            task.defer(function()
                ActiveTabLayoutQueued = false
                if Library.ActiveTab and Library.ActiveTab.Resize then
                    Library.ActiveTab:Resize(not Library.IsResizingWindow)
                end
                Library:QueueScaledLayoutRefresh()
            end)
        end

        local function RefreshTabsNavigation()
            if Library.UseSidebarTabs then
                TabsHeader.Visible = false
                TabsSidebarShell.Visible = true
                if TabsSidebarDivider then
                    TabsSidebarDivider.Visible = true
                end
                RefreshSidebarShellPosition()
                Tabs.Parent = TabsSidebarPanel
                Tabs.Position = UDim2.fromOffset(0, 0)
                Tabs.Size = UDim2.new(1, 0, 1, 0)
                Tabs.ScrollingDirection = Enum.ScrollingDirection.Y
                Tabs.AutomaticCanvasSize = Enum.AutomaticSize.Y
                Tabs.CanvasSize = UDim2.fromScale(0, 0)
                Tabs.ScrollBarThickness = 0
                Tabs.CanvasPosition = Vector2.new(0, 0)
                TabsListLayout.FillDirection = Enum.FillDirection.Vertical
                TabsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                TabsListLayout.Padding = UDim.new(0, 6)
                TabsPrevButton.Visible = false
                TabsNextButton.Visible = false
                if Container then
                    local sidebarWidth = math.floor(190 * Library.DPIScale)
                    local contentGap = math.floor(10 * Library.DPIScale)
                    local contentTop = math.floor(58 * Library.DPIScale)
                    local contentBottom = math.floor(72 * Library.DPIScale)
                    Container.Position = UDim2.fromOffset(sidebarWidth + contentGap, contentTop)
                    Container.Size = UDim2.new(1, -(sidebarWidth + contentGap), 1, -contentBottom)
                    RefreshActiveTabAfterLayout()
                end

                for _, TabObj in ipairs(Library.TabOrder) do
                    if TabObj and TabObj.Button then
                        local button = TabObj.Button
                        local tabContent = button:FindFirstChildOfClass("Frame")
                        local tabUnderline = button:FindFirstChildOfClass("Frame")
                        if TabObj.ButtonPadding then
                            TabObj.ButtonPadding.PaddingLeft = UDim.new(0, 12)
                        end
                        button.Size = UDim2.new(1, 0, 0, 36)
                        if tabContent then
                            tabContent.Size = UDim2.new(1, -14, 1, 0)
                            tabContent.AutomaticSize = Enum.AutomaticSize.None
                        end
                        if tabUnderline then
                            tabUnderline.AnchorPoint = Vector2.new(0, 0)
                            tabUnderline.Position = UDim2.fromOffset(-5, 8)
                            tabUnderline.Size = UDim2.new(0, 2, 0, 0)
                        end
                    end
                end
                return
            end

                TabsHeader.Visible = true
                TabsSidebarShell.Visible = false
                if TabsSidebarDivider then
                    TabsSidebarDivider.Visible = false
                end
                Tabs.Parent = TabsHeader
            Tabs.ScrollingDirection = Enum.ScrollingDirection.X
            Tabs.AutomaticCanvasSize = Enum.AutomaticSize.X
            TabsListLayout.FillDirection = Enum.FillDirection.Horizontal
            TabsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            TabsListLayout.Padding = UDim.new(0, 10)
                if Container then
                    Container.Position = UDim2.fromOffset(0, 88)
                    Container.Size = UDim2.new(1, 0, 1, -102)
                    RefreshActiveTabAfterLayout()
                end

            for _, TabObj in ipairs(Library.TabOrder) do
                if TabObj and TabObj.Button then
                    local button = TabObj.Button
                    local tabContent = button:FindFirstChildOfClass("Frame")
                    local tabUnderline = button:FindFirstChildOfClass("Frame")
                    if TabObj.ButtonPadding then
                        TabObj.ButtonPadding.PaddingLeft = UDim.new(0, 3)
                    end
                    if TabObj.DefaultTopButtonSize then
                        button.Size = TabObj.DefaultTopButtonSize
                    end
                    if tabContent then
                        tabContent.Size = UDim2.fromOffset(0, 22)
                        tabContent.AutomaticSize = Enum.AutomaticSize.X
                    end
                    if tabUnderline then
                        tabUnderline.AnchorPoint = Vector2.new(0, 1)
                        tabUnderline.Position = UDim2.new(0, 0, 1, 2)
                    end
                end
            end

            local contentX = TabsListLayout.AbsoluteContentSize.X
            local frameX = Tabs.AbsoluteSize.X
            local hasOverflow = contentX > TabsHeader.AbsoluteSize.X
            local buttonWidth = 32 * Library.DPIScale
            local tabsHeight = 34 * Library.DPIScale

            TabsPrevButton.Visible = hasOverflow
            TabsNextButton.Visible = hasOverflow

            if hasOverflow then
                Tabs.Position = UDim2.fromOffset(buttonWidth, 0)
                Tabs.Size = UDim2.new(1, -(buttonWidth * 2), 0, tabsHeight)
                Tabs.CanvasSize = UDim2.new(0, contentX, 0, tabsHeight)
            else
                Tabs.Position = UDim2.fromOffset(0, 0)
                Tabs.Size = UDim2.new(1, 0, 0, tabsHeight)
                Tabs.CanvasSize = UDim2.new(0, math.max(contentX, frameX), 0, tabsHeight)
                Tabs.CanvasPosition = Vector2.new(0, 0)
            end
        end

        local TabsNavigationQueued = false
        local function QueueRefreshTabsNavigation()
            if Library.IsResizingWindow then
                return
            end

            if TabsNavigationQueued then
                return
            end

            TabsNavigationQueued = true
            task.spawn(function()
                RunService.RenderStepped:Wait()
                TabsNavigationQueued = false
                if Library.Unloaded then
                    return
                end

                RefreshTabsNavigation()
            end)
        end

        Library.RefreshWindowTabsLayout = QueueRefreshTabsNavigation

        TabsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(QueueRefreshTabsNavigation)
        Tabs:GetPropertyChangedSignal("AbsoluteSize"):Connect(QueueRefreshTabsNavigation)
        TabsHeader:GetPropertyChangedSignal("AbsoluteSize"):Connect(QueueRefreshTabsNavigation)
        TabsSidebarPanel:GetPropertyChangedSignal("AbsoluteSize"):Connect(QueueRefreshTabsNavigation)
        TabsSidebarShell:GetPropertyChangedSignal("AbsoluteSize"):Connect(QueueRefreshTabsNavigation)
        MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if Library.UseSidebarTabs then
                RefreshSidebarShellPosition()
            end
        end)
        MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            if Library.UseSidebarTabs and not Library.IsResizingWindow then
                RefreshSidebarShellPosition()
            end
        end)

        ScrollTabIntoView = function(TabObject)
            if not TabObject or not TabObject.Button then
                return
            end

            if Library.UseSidebarTabs then
                local buttonY = TabObject.Button.AbsolutePosition.Y - Tabs.AbsolutePosition.Y + Tabs.CanvasPosition.Y
                local buttonHeight = TabObject.Button.AbsoluteSize.Y
                local topBound = Tabs.CanvasPosition.Y
                local bottomBound = topBound + Tabs.AbsoluteSize.Y

                if buttonY < topBound then
                    Tabs.CanvasPosition = Vector2.new(0, math.max(0, buttonY))
                elseif buttonY + buttonHeight > bottomBound then
                    local maxY = math.max(0, Tabs.CanvasSize.Y.Offset - Tabs.AbsoluteSize.Y)
                    Tabs.CanvasPosition = Vector2.new(0, math.min(maxY, buttonY + buttonHeight - Tabs.AbsoluteSize.Y))
                end
                return
            end

            local buttonX = TabObject.Button.AbsolutePosition.X - Tabs.AbsolutePosition.X + Tabs.CanvasPosition.X
            local buttonWidth = TabObject.Button.AbsoluteSize.X
            local leftBound = Tabs.CanvasPosition.X
            local rightBound = leftBound + Tabs.AbsoluteSize.X

            if buttonX < leftBound then
                Tabs.CanvasPosition = Vector2.new(math.max(0, buttonX), 0)
            elseif buttonX + buttonWidth > rightBound then
                local maxX = math.max(0, Tabs.CanvasSize.X.Offset - Tabs.AbsoluteSize.X)
                Tabs.CanvasPosition = Vector2.new(math.min(maxX, buttonX + buttonWidth - Tabs.AbsoluteSize.X), 0)
            end
        end

        ShowRelativeWindowTab = function(Direction)
            local activeIndex = table.find(Library.TabOrder, Library.ActiveTab)
            if not activeIndex then
                return
            end

            local targetTab = Library.TabOrder[activeIndex + Direction]
            if targetTab then
                targetTab:Show()
                ScrollTabIntoView(targetTab)
            end
        end

        TabsPrevButton.MouseButton1Click:Connect(function()
            ShowRelativeWindowTab(-1)
        end)

        TabsNextButton.MouseButton1Click:Connect(function()
            ShowRelativeWindowTab(1)
        end)

        RefreshTabsNavigation()

        --// Container \\--
        Container = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            ClipsDescendants = true,
            Name = "Container",
            Position = UDim2.fromOffset(0, 88),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -102),
            Parent = MainFrame,
        })
        Library.ContentContainer = Container

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
            Parent = Container,
        })

        if Library.RefreshWindowTabsLayout then
            Library.RefreshWindowTabsLayout()
        end
    end

    --// Window Table \\--
    local Window = {}

    function Window:AddTab(Name: string, Icon)
        local TabButton: TextButton
        local TabButtonPadding
        local TabLabel
        local TabIcon
        local TabUnderline
        local defaultTopButtonSize
        local inactiveTabIconColor = Color3.fromRGB(120, 120, 120)
    
        local TabContainer
        local TabLeft
        local TabRight
        local TabMiddle
    
        local WarningBox
        local WarningTitle
        local WarningText
    
        Icon = Library:GetIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 32),
                Text = "",
                Parent = Tabs,
            })
            Library:MakeDraggable(MainFrame, TabButton, false, true)
            New("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = TabButton,
            })
    
            TabButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 3),
                PaddingRight = UDim.new(0, 3),
                PaddingTop = UDim.new(0, 3),
                Parent = TabButton,
            })

            local TabContent = New("Frame", {
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromOffset(0, 22),
                Parent = TabButton,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 4),
                Parent = TabContent,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    Image = Icon.Url,
                    ImageColor3 = inactiveTabIconColor,
                    ImageRectOffset = Icon.ImageRectOffset,
                    ImageRectSize = Icon.ImageRectSize,
                    ImageTransparency = 0.5,
                    Size = UDim2.fromOffset(12, 12),
                    BackgroundTransparency = 1,
                    Parent = TabContent,
                })
            end

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromOffset(0, 22),
                Text = Name,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabContent,
            })

            TabUnderline = New("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(0, 0, 0, 1),
                Parent = TabLabel,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, 1),
                Parent = TabUnderline,
            })

            local contentWidth = TabLabel.TextBounds.X
            if TabIcon then
                contentWidth = contentWidth + TabIcon.Size.X.Offset + 4
            end
            defaultTopButtonSize = UDim2.fromOffset(contentWidth + 6, 32)
            TabButton.Size = defaultTopButtonSize
            Library:UpdateDPI(TabButton, {
                Size = TabButton.Size,
            })

            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
    
            TabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
    
                TabLeft.Size = UDim2.new(0, math.floor(TabContainer.AbsoluteSize.X / 2) - 3, 1, 0)
                Library:UpdateDPI(TabLeft, { Size = TabLeft.Size })
            end
    
            TabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarThickness = 0,
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
    
                TabRight.Size = UDim2.new(0, math.floor(TabContainer.AbsoluteSize.X / 2) - 3, 1, 0)
                Library:UpdateDPI(TabRight, { Size = TabRight.Size })
            end
    
            TabMiddle = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = TabMiddle,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabMiddle,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabMiddle,
                })
            end
    
            WarningBox = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(127, 0, 0),
                BorderColor3 = Color3.fromRGB(255, 50, 50),
                BorderMode = Enum.BorderMode.Inset,
                BorderSizePixel = 1,
                Position = UDim2.fromOffset(0, 6),
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBox,
            })
    
            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = "",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBox,
            })
            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })
    
            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.fromScale(1, 0),
                Text = "",
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = WarningBox,
            })
            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "Dark",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

    local Tab = {
        Groupboxes = {},
        Tabboxes = {},
        Sides = {
            TabLeft,
            TabRight,
            TabMiddle,
        },
        SideContent = {
            Left = 0,
            Middle = 0,
            Right = 0,
        },
        ActiveSide = "Auto",
    }

    function Tab:UpdateWarningBox(Info)
        if typeof(Info.Visible) == "boolean" then
            WarningBox.Visible = Info.Visible
            Tab:Resize()
        end

        if typeof(Info.Title) == "string" then
            WarningTitle.Text = Info.Title
        end

        if typeof(Info.Text) == "string" then
            local _, Y = Library:GetTextBounds(
                Info.Text,
                Library.Scheme.Font,
                WarningText.TextSize,
                WarningText.AbsoluteSize.X
            )

            WarningText.Size = UDim2.new(1, 0, 0, Y)
            WarningText.Text = Info.Text
            Library:UpdateDPI(WarningText, { Size = WarningText.Size })
            Tab:Resize()
        end
    end

    function Tab:Resize(ResizeWarningBox: boolean?)
        if ResizeWarningBox then
            local _, Y = Library:GetTextBounds(
                WarningText.Text,
                Library.Scheme.Font,
                WarningText.TextSize,
                WarningText.AbsoluteSize.X
            )

            WarningText.Size = UDim2.new(1, 0, 0, Y)
            Library:UpdateDPI(WarningText, { Size = WarningText.Size })
        end

        local Offset = WarningBox.Visible and WarningBox.AbsoluteSize.Y + 6 or 0

        local layoutMode = self.ActiveSide
        if layoutMode == "Auto" then
            layoutMode = self.SideContent.Middle > 0 and "All" or "Dual"
        end

        self.ResolvedLayoutMode = layoutMode

        if layoutMode == "Middle" then
            TabLeft.Visible = false
            TabRight.Visible = false
            TabMiddle.Visible = true

            TabMiddle.Position = UDim2.new(0, 0, 0, Offset)
            TabMiddle.Size = UDim2.new(1, 0, 1, -Offset)
            Library:UpdateDPI(TabMiddle, {
                Position = TabMiddle.Position,
                Size = TabMiddle.Size,
            })
        elseif layoutMode == "All" then
            local columnSpacing = 6
            local columnWidth = math.floor((TabContainer.AbsoluteSize.X - (columnSpacing * 2)) / 3)

            TabLeft.Visible = true
            TabMiddle.Visible = true
            TabRight.Visible = true

            TabLeft.Position = UDim2.new(0, 0, 0, Offset)
            TabLeft.Size = UDim2.new(0, columnWidth, 1, -Offset)
            Library:UpdateDPI(TabLeft, {
                Position = TabLeft.Position,
                Size = TabLeft.Size,
            })

            TabMiddle.Position = UDim2.new(0, columnWidth + columnSpacing, 0, Offset)
            TabMiddle.Size = UDim2.new(0, columnWidth, 1, -Offset)
            Library:UpdateDPI(TabMiddle, {
                Position = TabMiddle.Position,
                Size = TabMiddle.Size,
            })

            TabRight.AnchorPoint = Vector2.new(0, 0)
            TabRight.Position = UDim2.new(0, (columnWidth + columnSpacing) * 2, 0, Offset)
            TabRight.Size = UDim2.new(0, columnWidth, 1, -Offset)
            Library:UpdateDPI(TabRight, {
                Position = TabRight.Position,
                Size = TabRight.Size,
            })
        else
            TabMiddle.Visible = false
            if layoutMode == "Left" then
                TabLeft.Visible = true
                TabRight.Visible = false
            elseif layoutMode == "Right" then
                TabLeft.Visible = false
                TabRight.Visible = true
            else
                TabLeft.Visible = true
                TabRight.Visible = true
            end

            local halfWidth = math.floor(TabContainer.AbsoluteSize.X / 2) - 3

            TabLeft.AnchorPoint = Vector2.new(0, 0)
            TabLeft.Position = UDim2.new(0, 0, 0, Offset)
            TabLeft.Size = UDim2.new(0, halfWidth, 1, -Offset)
            Library:UpdateDPI(TabLeft, {
                Position = TabLeft.Position,
                Size = TabLeft.Size,
            })

            TabRight.AnchorPoint = Vector2.new(1, 0)
            TabRight.Position = UDim2.new(1, 0, 0, Offset)
            TabRight.Size = UDim2.new(0, halfWidth, 1, -Offset)
            Library:UpdateDPI(TabRight, {
                Position = TabRight.Position,
                Size = TabRight.Size,
            })
        end

        for _, Tabbox in pairs(self.Tabboxes) do
            if Tabbox.RefreshNavigation then
                Tabbox:RefreshNavigation()
            end
        end
    end

    function Tab:SetActiveSide(sideName)
        assert(
            sideName == "Left" or sideName == "Right" or sideName == "Middle" or sideName == "All" or sideName == "Auto",
            "Invalid side name"
        )
        self.ActiveSide = sideName
        self:Resize(true)
    end

    function Tab:AddGroupbox(Info)
    local Icon = Info.Icon and Library:GetIcon(Info.Icon)

    local ParentFrame
    if Info.Side == "Left" then
        ParentFrame = TabLeft
    elseif Info.Side == "Right" then
        ParentFrame = TabRight
    elseif Info.Side == "Middle" then
        ParentFrame = TabMiddle
    else
        error("Invalid Side for Groupbox: " .. tostring(Info.Side))
    end

    local Background = Library:MakeOutline(ParentFrame, WindowInfo.CornerRadius)
    Library:RegisterBoxOutline(Background)
    Background.Size = UDim2.fromScale(1, 0)
    Library:UpdateDPI(Background, { Size = false })

    local GroupboxHolder = New("Frame", {
        BackgroundColor3 = getgenv().Backgroundcolor or "BackgroundColor",
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        Parent = Background,
    })
    Library:RegisterGroupboxBackground(GroupboxHolder)

    New("UICorner", {
        CornerRadius = UDim.new(0, WindowInfo.CornerRadius - 1),
        Parent = GroupboxHolder,
    })

    local titleTextWidth = Library:GetTextBounds(Info.Name, Library.Scheme.Font, 15)
    local iconWidth = Icon and 18 or 0
    local iconSpacing = Icon and 6 or 0
    local titleWidth = math.clamp(titleTextWidth + iconWidth + iconSpacing + 18, 56, math.max(56, GroupboxHolder.AbsoluteSize.X - 36))
    local lineInset = 20
    local titleGap = titleWidth / 2
    local lineY = 28
    local titleContentWidth = titleTextWidth + iconWidth + iconSpacing

    Library:MakeLine(GroupboxHolder, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(0.5, -titleGap, 0, lineY),
        Size = UDim2.new(0.5, -(lineInset + titleGap), 0, 1),
    })

    Library:MakeLine(GroupboxHolder, {
        Position = UDim2.new(0.5, titleGap, 0, lineY),
        Size = UDim2.new(0.5, -(lineInset + titleGap), 0, 1),
    })

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 6),
        Size = UDim2.fromOffset(titleContentWidth, 18),
        Parent = GroupboxHolder,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, iconSpacing),
        Parent = TitleHolder,
    })

    if Icon then
        New("ImageLabel", {
            Image = Icon.Url,
            ImageColor3 = "AccentColor",
            ImageRectOffset = Icon.ImageRectOffset,
            ImageRectSize = Icon.ImageRectSize,
            ImageTransparency = 0.5,
            Size = UDim2.fromOffset(18, 18),
            BackgroundTransparency = 1,
            Parent = TitleHolder,
        })
    end

    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(titleTextWidth, 18),
        Text = Info.Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = TitleHolder,
    })

    local FoldIcon = Library:GetIcon("chevron-down")
    local FoldButton = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0, 6),
        Size = UDim2.fromOffset(24, 24),
        Text = FoldIcon and "" or "v",
        TextSize = 16,
        TextTransparency = 0.94,
        ZIndex = 3,
        Parent = GroupboxHolder,
    })
    local FoldImage
    if FoldIcon then
        FoldImage = New("ImageLabel", {
            Image = FoldIcon.Url,
            ImageColor3 = "FontColor",
            ImageRectOffset = FoldIcon.ImageRectOffset,
            ImageRectSize = FoldIcon.ImageRectSize,
            ImageTransparency = 0.94,
            Position = UDim2.fromOffset(4, 4),
            Size = UDim2.new(1, -8, 1, -8),
            ZIndex = FoldButton.ZIndex + 1,
            Parent = FoldButton,
        })
    end


    local GroupboxContainer = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 44),
        Size = UDim2.new(1, 0, 1, -44),
        Parent = GroupboxHolder,
    })

    local GroupboxList = New("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = GroupboxContainer,
    })

    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = GroupboxContainer,
    })

    local Groupbox = {
        Holder = Background,
        Container = GroupboxContainer,
        List = GroupboxList,
        Elements = {},
        Collapsed = false,
    }

    function Groupbox:SetCollapsed(Collapsed)
        self.Collapsed = Collapsed
        GroupboxContainer.Visible = not Collapsed
        FoldButton.Text = FoldIcon and "" or (Collapsed and ">" or "v")
        if FoldImage then
            FoldImage.Rotation = Collapsed and -90 or 0
        end
        self:Resize()
        Tab:Resize()
    end

    function Groupbox:Resize(full)
        local top = (44 + 7 + 7) * Library.DPIScale
        local size = (self.Collapsed and (44 * Library.DPIScale) or (self.List.AbsoluteContentSize.Y + top)) + Library:GetBoxOutlineSizeExtra()
        if full then
            Background.Size = UDim2.new(1, 0, 0.8, size)
        else
            Background.Size = UDim2.new(1, 0, 0, size)
        end
    end

    FoldButton.MouseButton1Click:Connect(function()
        Groupbox:SetCollapsed(not Groupbox.Collapsed)
    end)

    GroupboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Groupbox:Resize()
    end)

    setmetatable(Groupbox, BaseGroupbox)
    Groupbox:Resize()
    Tab.Groupboxes[Info.Name] = Groupbox
    Tab.SideContent[Info.Side] = (Tab.SideContent[Info.Side] or 0) + 1
    Tab:Resize()

    return Groupbox
end

function Tab:AddLeftGroupbox(Name, Icon)
    return Tab:AddGroupbox({ Side = "Left", Name = Name, Icon = Icon })
end

function Tab:AddRightGroupbox(Name, Icon)
    return Tab:AddGroupbox({ Side = "Right", Name = Name, Icon = Icon })
end

function Tab:AddMiddleGroupbox(Name, Icon)
    return Tab:AddGroupbox({ Side = "Middle", Name = Name, Icon = Icon })
end

    function Tab:AddTabbox(Info)
    local Parent
    local sideName = "Left"
    if Info.Side == 1 then
        Parent = TabLeft
        sideName = "Left"
    elseif Info.Side == 2 then
        Parent = TabRight
        sideName = "Right"
    elseif Info.Side == 3 then
        Parent = TabMiddle
        sideName = "Middle"
    else
        Parent = TabLeft
    end

    local Background = Library:MakeOutline(Parent, WindowInfo.CornerRadius)
    Library:RegisterBoxOutline(Background)
    Background.Size = UDim2.fromScale(1, 0)
    Library:UpdateDPI(Background, {Size = false})

    local TabboxHolder = New("Frame", {
        BackgroundColor3 = getgenv().Backgroundcolor or "BackgroundColor",
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        Parent = Background,
    })
    Library:RegisterGroupboxBackground(TabboxHolder)

    New("UICorner", {
        CornerRadius = UDim.new(0, WindowInfo.CornerRadius - 1),
        Parent = TabboxHolder,
    })

    local TabboxHeader = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34 * Library.DPIScale),
        Parent = TabboxHolder,
    })

    local PrevButton = New("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.fromOffset(48, 34),
        Transparency = 0.7,
        Text = "<",
        TextSize = 30,
        Visible = false,
        Parent = TabboxHeader,
    })

    local NextButton = New("TextButton", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 0),
        Size = UDim2.fromOffset(48, 34),
        Transparency = 0.7,
        Text = ">",
        TextSize = 30,
        Visible = false,
        Parent = TabboxHeader,
    })

    local TabboxButtons = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34 * Library.DPIScale),
        CanvasSize = UDim2.new(0, 0, 0, 34 * Library.DPIScale),
        ScrollBarThickness = 5,
        ScrollBarImageTransparency = 0.2,
        ScrollBarImageColor3 = "AccentColor",
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = TabboxHeader,
    })

    local FoldIcon = Library:GetIcon("chevron-down")
    local FoldButton = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -4, 0, 5 * Library.DPIScale),
        Size = UDim2.fromOffset(24 * Library.DPIScale, 24 * Library.DPIScale),
        Text = FoldIcon and "" or "v",
        TextSize = 16,
        TextTransparency = 0.94,
        ZIndex = 5,
        Parent = TabboxHeader,
    })
    local FoldImage
    if FoldIcon then
        FoldImage = New("ImageLabel", {
            Image = FoldIcon.Url,
            ImageColor3 = "FontColor",
            ImageRectOffset = FoldIcon.ImageRectOffset,
            ImageRectSize = FoldIcon.ImageRectSize,
            ImageTransparency = 0.94,
            Position = UDim2.fromOffset(4 * Library.DPIScale, 4 * Library.DPIScale),
            Size = UDim2.new(1, -8 * Library.DPIScale, 1, -8 * Library.DPIScale),
            ZIndex = FoldButton.ZIndex + 1,
            Parent = FoldButton,
        })
    end

    local listLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = TabboxButtons,
    })

    local function RefreshTabboxButtonsCanvas()
        local headerHeight = 34 * Library.DPIScale
        local contentX = listLayout.AbsoluteContentSize.X
        local frameX = TabboxButtons.AbsoluteSize.X
        if contentX > frameX then
            TabboxButtons.CanvasSize = UDim2.new(0, contentX, 0, headerHeight)
            TabboxButtons.ScrollBarThickness = 5
        else
            TabboxButtons.CanvasSize = UDim2.new(0, frameX, 0, headerHeight)
            TabboxButtons.CanvasPosition = Vector2.new(0, 0)
            TabboxButtons.ScrollBarThickness = 0
        end
    end

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshTabboxButtonsCanvas)
    TabboxButtons:GetPropertyChangedSignal("AbsoluteSize"):Connect(RefreshTabboxButtonsCanvas)

    local Tabbox = {
        ActiveTab = nil,
        Holder = Background,
        Tabs = {},
        IsMiddleTabbox = Info.Side == 3,
        Collapsed = false,
    }

    function Tabbox:SetCollapsed(Collapsed)
        self.Collapsed = Collapsed
        FoldButton.Text = FoldIcon and "" or (Collapsed and ">" or "v")
        if FoldImage then
            FoldImage.Rotation = Collapsed and -90 or 0
        end
        if self.ActiveTab then
            self.ActiveTab.Container.Visible = not Collapsed
            self.ActiveTab:Resize()
        end
        self:RefreshNavigation()
        Tab:Resize()
    end

    function Tabbox:ShouldShowNavigation()
        return self.IsMiddleTabbox and Tab.ResolvedLayoutMode == "Middle"
    end

    function Tabbox:ScrollTabIntoView(InnerTab)
        if not InnerTab or not InnerTab.ButtonHolder then
            return
        end

        local frameWidth = TabboxButtons.AbsoluteSize.X
        local buttonWidth = InnerTab.ButtonHolder.AbsoluteSize.X
        if frameWidth <= 0 or buttonWidth <= 0 then
            return
        end

        local buttonX = InnerTab.ButtonHolder.AbsolutePosition.X - TabboxButtons.AbsolutePosition.X + TabboxButtons.CanvasPosition.X
        local leftBound = TabboxButtons.CanvasPosition.X
        local rightBound = leftBound + frameWidth

        if buttonX < leftBound then
            TabboxButtons.CanvasPosition = Vector2.new(math.max(0, buttonX), 0)
        elseif buttonX + buttonWidth > rightBound then
            local maxX = math.max(0, TabboxButtons.CanvasSize.X.Offset - frameWidth)
            TabboxButtons.CanvasPosition = Vector2.new(math.min(maxX, buttonX + buttonWidth - frameWidth), 0)
        end
    end

    function Tabbox:RefreshNavigation()
        local showNavigation = self:ShouldShowNavigation()
        local headerHeight = 34 * Library.DPIScale
        local navWidth = 56 * Library.DPIScale
        TabboxButtons.Visible = true
        PrevButton.Visible = showNavigation
        NextButton.Visible = showNavigation
        TabboxHeader.Size = UDim2.new(1, 0, 0, headerHeight)
        PrevButton.Size = UDim2.fromOffset(48 * Library.DPIScale, headerHeight)
        NextButton.Size = UDim2.fromOffset(48 * Library.DPIScale, headerHeight)
        PrevButton.Position = UDim2.fromOffset(8 * Library.DPIScale, 0)
        NextButton.Position = UDim2.new(1, -8 * Library.DPIScale, 0, 0)

        if showNavigation then
            TabboxButtons.Position = UDim2.fromOffset(navWidth, 0)
            TabboxButtons.Size = UDim2.new(1, -((navWidth * 2) + 28 * Library.DPIScale), 0, headerHeight)
        else
            TabboxButtons.Position = UDim2.fromOffset(0, 0)
            TabboxButtons.Size = UDim2.new(1, -28 * Library.DPIScale, 0, headerHeight)
        end
        RefreshTabboxButtonsCanvas()
        self:ScrollTabIntoView(self.ActiveTab)
    end

    function Tabbox:ShowRelativeTab(Direction)
        if not self.ActiveTab then
            return
        end

        local visibleTabs = {}
        for _, InnerTab in ipairs(self.Tabs) do
            if InnerTab.ButtonHolder.Visible then
                table.insert(visibleTabs, InnerTab)
            end
        end

        local activeIndex = table.find(visibleTabs, self.ActiveTab)
        if not activeIndex then
            return
        end

        local targetTab = visibleTabs[activeIndex + Direction]
        if targetTab then
            targetTab:Show()
            self:ScrollTabIntoView(targetTab)
        end
    end

    function Tabbox:RefreshTabButtons()
        for _, InnerTab in ipairs(self.Tabs) do
            local Button = InnerTab.ButtonHolder
            if not Button then
                continue
            end

            local ButtonRegistry = Library.Registry[Button] or {}
            Library.Registry[Button] = ButtonRegistry

            if InnerTab == self.ActiveTab then
                Button.BackgroundColor3 = Library.Scheme.BackgroundColor
                Button.BackgroundTransparency = 1
                Button.TextColor3 = Library.Scheme.AccentColor
                Button.TextTransparency = 0
                ButtonRegistry.BackgroundColor3 = "BackgroundColor"
                ButtonRegistry.TextColor3 = "AccentColor"
                if InnerTab.Line then
                    InnerTab.Line.Visible = true
                end
            else
                Button.BackgroundColor3 = Library.Scheme.BackgroundColor
                Button.BackgroundTransparency = 1
                Button.TextColor3 = Library.Scheme.FontColor
                Button.TextTransparency = 0.5
                ButtonRegistry.BackgroundColor3 = "BackgroundColor"
                ButtonRegistry.TextColor3 = "FontColor"
                if InnerTab.Line then
                    InnerTab.Line.Visible = false
                end
            end
        end
    end

    function Tabbox:AddTab(Name)
        local headerHeight = 34 * Library.DPIScale
        local Button = New("TextButton", {
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 34),
            Text = Name,
            TextSize = 15,
            TextTransparency = 0.5,
            Parent = TabboxButtons,
        })
        Button:SetAttribute("ExcludeMenuTransparency", true)

        local textWidth = Library:GetTextBounds(Name, Button.FontFace, 15)
        local baseButtonSize = UDim2.fromOffset((textWidth / Library.DPIScale) + 20, 34)
        Button.Size = ApplyDPIScale(baseButtonSize)
        Library:UpdateDPI(Button, {
            Size = baseButtonSize,
        })

        local Line = Library:MakeLine(Button, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -2 * Library.DPIScale),
            Size = UDim2.new(1, 0, 0, 2 * Library.DPIScale),
        })
        Line.BackgroundColor3 = Library.Scheme.AccentColor
        Library.Registry[Line].BackgroundColor3 = "AccentColor"
        Line.Visible = false

        local Container = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, headerHeight + Library.DPIScale),
            Size = UDim2.new(1, 0, 1, -(headerHeight + Library.DPIScale)),
            Visible = false,
            Parent = TabboxHolder,
        })

        local List = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = Container,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 7),
            PaddingLeft = UDim.new(0, 7),
            PaddingRight = UDim.new(0, 7),
            PaddingTop = UDim.new(0, 7),
            Parent = Container,
        })

        local Tab = {Name = Name, ButtonHolder = Button, Container = Container, Elements = {}, List = List, Line = Line}

        function Tab:Show()
            if Tabbox.ActiveTab then
                Tabbox.ActiveTab:Hide()
            end
            Button.BackgroundColor3 = Library.Scheme.BackgroundColor
            Library.Registry[Button].BackgroundColor3 = "BackgroundColor"
            Button.BackgroundTransparency = 1
            Button.TextColor3 = Library.Scheme.AccentColor
            Library.Registry[Button].TextColor3 = "AccentColor"
            Button.TextTransparency = 0
            Line.Visible = true
            Container.Visible = not Tabbox.Collapsed
            Tabbox.ActiveTab = Tab
            Tab:Resize()
            Tabbox:ScrollTabIntoView(Tab)
        end

        function Tab:Hide()
            local inactiveTabboxColor = "BackgroundColor"
            Button.BackgroundColor3 = Library.Scheme[inactiveTabboxColor]
            Library.Registry[Button].BackgroundColor3 = inactiveTabboxColor
            Button.BackgroundTransparency = 1
            Button.TextColor3 = Library.Scheme.FontColor
            Library.Registry[Button].TextColor3 = "FontColor"
            Button.TextTransparency = 0.5
            Line.Visible = false
            Container.Visible = false
        end

        function Tab:Resize(full)
            if Tabbox.ActiveTab ~= Tab then return end
            local top = (35 + 7 + 7) * Library.DPIScale
            local size = (Tabbox.Collapsed and (41 * Library.DPIScale) or (List.AbsoluteContentSize.Y + top)) + Library:GetBoxOutlineSizeExtra()
            if full then
                Background.Size = UDim2.new(1, 0, 0.8, size)
            else
                Background.Size = UDim2.new(1, 0, 0, size)
            end
        end

        List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab:Resize()
        end)

        Tabbox:RefreshNavigation()

        Button.MouseButton1Click:Connect(function()
            Tab:Show()
        end)

        if not Tabbox.ActiveTab then
            Tab:Show()
        end

        setmetatable(Tab, BaseGroupbox)
        table.insert(Tabbox.Tabs, Tab)

        return Tab
    end

    PrevButton.MouseButton1Click:Connect(function()
        Tabbox:ShowRelativeTab(-1)
    end)

    NextButton.MouseButton1Click:Connect(function()
        Tabbox:ShowRelativeTab(1)
    end)

    FoldButton.MouseButton1Click:Connect(function()
        Tabbox:SetCollapsed(not Tabbox.Collapsed)
    end)

    Tabbox:RefreshNavigation()

    if Info.Name then
        Tab.Tabboxes[Info.Name] = Tabbox
    else
        table.insert(Tab.Tabboxes, Tabbox)
    end
    Tab.SideContent[sideName] = (Tab.SideContent[sideName] or 0) + 1
    Tab:Resize()

    return Tabbox
end


function Tab:AddLeftTabbox(Name, Icon)
    return Tab:AddTabbox({ Side = 1, Name = Name, Icon = Icon })
end

function Tab:AddRightTabbox(Name, Icon)
    return Tab:AddTabbox({ Side = 2, Name = Name, Icon = Icon })
end

function Tab:AddMiddleTabbox(Name, Icon)
    return Tab:AddTabbox({ Side = 3, Name = Name, Icon = Icon })
end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
            TweenService:Create(TabUnderline, Library.TweenInfo, {
                BackgroundTransparency = 0,
                Size = UDim2.new(1, 0, 0, 1),
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageColor3 = Library.Scheme.AccentColor,
                    ImageTransparency = 0,
                }):Play()
            end
            TabContainer.Visible = true

            Library.ActiveTab = Tab
            ScrollTabIntoView(Tab)
            Tab:Resize(true)
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
            TweenService:Create(TabUnderline, Library.TweenInfo, {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageColor3 = inactiveTabIconColor,
                    ImageTransparency = 0.5,
                }):Play()
            end
            TabContainer.Visible = false

            Library.ActiveTab = nil
        end

        Library.Registry[TabUnderline].BackgroundColor3 = "AccentColor"
        if TabIcon then
            Library.Registry[TabIcon] = Library.Registry[TabIcon] or {}
            Library.Registry[TabIcon].ImageColor3 = function()
                return Library.ActiveTab == Tab and Library.Scheme.AccentColor or inactiveTabIconColor
            end
        end

        --// Execution \\--
        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Library.Tabs[Name] = Tab
        Tab.Button = TabButton
        Tab.ButtonPadding = TabButtonPadding
        Tab.DefaultTopButtonSize = defaultTopButtonSize
        table.insert(Library.TabOrder, Tab)
        if Library.RefreshWindowTabsLayout then
            Library.RefreshWindowTabsLayout()
        end

        return Tab
    end

    function Window:AddKeyTab(Name)
        local TabButton: TextButton
        local TabLabel
        local TabIcon
        local TabUnderline

        local TabContainer

        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                Parent = Tabs,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 11),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 11),
                Parent = TabButton,
            })

            TabUnderline = New("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 30, 1, 12),
                Size = UDim2.new(0, 0, 0, 2),
                Parent = TabButton,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, 2),
                Parent = TabUnderline,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabButton,
            })

            if KeyIcon then
                TabIcon = New("ImageLabel", {
                    Image = KeyIcon.Url,
                    ImageColor3 = "AccentColor",
                    ImageRectOffset = KeyIcon.ImageRectOffset,
                    ImageRectSize = KeyIcon.ImageRectSize,
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    Parent = TabButton,
                })
            end

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Elements = {},
            IsKeyTab = true,
        }

        function Tab:AddKeyBox(...)
            local Data = {}

            local First = select(1, ...)

            if typeof(First) == "function" then
                Data.Callback = First
            else
                Data.ExpectedKey = First
                Data.Callback = select(2, ...)
            end

            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0, 21),
                Parent = TabContainer,
            })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                Parent = Holder,
            })

            Button.MouseButton1Click:Connect(function()
                if Data.ExpectedKey and Box.Text ~= Data.ExpectedKey then
                    Data.Callback(false, Box.Text)
                    return
                end

                Data.Callback(true, Box.Text)
            end)
        end

        function Tab:Resize() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        local function GetUnderlineWidth()
            return math.clamp(TabLabel.TextBounds.X + 10, 38, 140)
        end

        function Tab:Show()
            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
            TweenService:Create(TabUnderline, Library.TweenInfo, {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, GetUnderlineWidth(), 0, 2),
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end
            TabContainer.Visible = true

            Library.ActiveTab = Tab
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
            TweenService:Create(TabUnderline, Library.TweenInfo, {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end
            TabContainer.Visible = false

            Library.ActiveTab = nil
        end

        Library.Registry[TabUnderline].BackgroundColor3 = "AccentColor"

        --// Execution \\--
        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Library:Toggle(Value: boolean?)
        if typeof(Value) == "boolean" then
            Library.Toggled = Value
        else
            Library.Toggled = not Library.Toggled
        end

        MainFrame.Visible = Library.Toggled
        ModalElement.Modal = Library.Toggled

        if Library.Toggled and not Library.IsMobile then
            local OldMouseIconEnabled = UserInputService.MouseIconEnabled
            pcall(function()
                RunService:UnbindFromRenderStep("ShowCursor")
            end)
            RunService:BindToRenderStep("ShowCursor", Enum.RenderPriority.Last.Value, function()
                UserInputService.MouseIconEnabled = not Library.ShowCustomCursor

                local CursorThickness = Library.CustomCursorThickness or 0
                local CursorX, CursorY = Mouse.X, Mouse.Y
                local LayerOffsets = {
                    Vector2.new(-CursorThickness, 0),
                    Vector2.new(CursorThickness, 0),
                    Vector2.new(0, -CursorThickness),
                    Vector2.new(0, CursorThickness),
                }

                Cursor.Position = UDim2.fromOffset(CursorX, CursorY)
                Cursor.Visible = Library.ShowCustomCursor

                for Index, Layer in ipairs(CursorThicknessLayers) do
                    local Offset = LayerOffsets[Index] or Vector2.zero
                    Layer.Position = UDim2.fromOffset(CursorX + Offset.X, CursorY + Offset.Y)
                    Layer.Visible = Library.ShowCustomCursor and CursorThickness > 0
                end

                if not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
                    UserInputService.MouseIconEnabled = OldMouseIconEnabled
                    Cursor.Visible = false
                    for _, Layer in ipairs(CursorThicknessLayers) do
                        Layer.Visible = false
                    end
                    RunService:UnbindFromRenderStep("ShowCursor")
                end
            end)
        elseif not Library.Toggled then
            TooltipLabel.Visible = false
            for _, Option in pairs(Library.Options) do
                if Option.Type == "ColorPicker" then
                    Option.ColorMenu:Close()
                    Option.ContextMenu:Close()
                elseif Option.Type == "Dropdown" or Option.Type == "KeyPicker" then
                    Option.Menu:Close()
                end
            end
        end
    end

    if WindowInfo.AutoShow then
        task.spawn(Library.Toggle)
    end

    if Library.IsMobile then
        local ToggleButton = Library:AddDraggableButton("Toggle", function()
            Library:Toggle()
        end)

        local LockButton = Library:AddDraggableButton("Lock", function(self)
            Library.CantDragForced = not Library.CantDragForced
            self:SetText(Library.CantDragForced and "Unlock" or "Lock")
        end)

        if WindowInfo.MobileButtonsSide == "Right" then
            ToggleButton.Button.Position = UDim2.new(1, -6, 0, 6)
            ToggleButton.Button.AnchorPoint = Vector2.new(1, 0)

            LockButton.Button.Position = UDim2.new(1, -6, 0, 46)
            LockButton.Button.AnchorPoint = Vector2.new(1, 0)
        else
            LockButton.Button.Position = UDim2.fromOffset(6, 46)
        end
    end

    --// Execution \\--
    local function ResetElementInfo(ElementInfo)
        ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    local function GetElementSearchScore(ElementInfo, Search)
        if not ElementInfo or ElementInfo.Type == "Divider" then
            return 0
        end

        local function AddText(Texts, Value)
            if typeof(Value) == "string" and Value ~= "" then
                table.insert(Texts, Value)
            end
        end

        local Texts = {}
        AddText(Texts, ElementInfo.Text)
        AddText(Texts, ElementInfo.Name)
        AddText(Texts, ElementInfo.Idx)
        AddText(Texts, ElementInfo.Base and ElementInfo.Base.Text)
        AddText(Texts, ElementInfo.TextLabel and ElementInfo.TextLabel.Text)
        AddText(Texts, ElementInfo.SubButton and ElementInfo.SubButton.Text)
        AddText(Texts, ElementInfo.SubButton and ElementInfo.SubButton.Base and ElementInfo.SubButton.Base.Text)

        local BestScore = 0
        for _, Text in pairs(Texts) do
            local Lower = Text:lower()
            if Lower == Search then
                BestScore = math.max(BestScore, 400)
            elseif Lower:find(Search, 1, true) == 1 then
                BestScore = math.max(BestScore, 300)
            elseif Lower:find(" " .. Search, 1, true) then
                BestScore = math.max(BestScore, 200)
            elseif Lower:find(Search, 1, true) then
                BestScore = math.max(BestScore, 100)
            end
        end

        return BestScore
    end

    local function ElementMatchesSearch(ElementInfo, Search)
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            return false, 0
        end

        local Visible = false
        local BestScore = GetElementSearchScore(ElementInfo, Search)
        if BestScore > 0 then
            Visible = true
        elseif ElementInfo.SubButton then
            ElementInfo.SubButton.Base.Visible = false
            ElementInfo.Base.Visible = false
        end

        ElementInfo.Holder.Visible = Visible
        return Visible, BestScore
    end

    local function ResetTab(Tab)
        for _, Groupbox in pairs(Tab.Groupboxes) do
            for _, ElementInfo in pairs(Groupbox.Elements) do
                ResetElementInfo(ElementInfo)
            end

            Groupbox:Resize()
            Groupbox.Holder.Visible = true
        end

        for _, Tabbox in pairs(Tab.Tabboxes) do
            for _, InnerTab in pairs(Tabbox.Tabs) do
                for _, ElementInfo in pairs(InnerTab.Elements) do
                    ResetElementInfo(ElementInfo)
                end

                InnerTab.ButtonHolder.Visible = true
            end

            if Tabbox.ActiveTab then
                Tabbox.ActiveTab:Resize()
            end
            Tabbox.Holder.Visible = true
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local Search = SearchBox.Text:lower()

        for _, Tab in pairs(Library.Tabs) do
            ResetTab(Tab)
        end

        if Trim(Search) == "" or (Library.ActiveTab and Library.ActiveTab.IsKeyTab) then
            return
        end

        local ActiveTabAtSearchStart = Library.ActiveTab
        local BestMatchedTab
        local BestMatchedTabScore = -1
        local ActiveTabScore = -1
        local BestExactTab

        for _, Tab in pairs(Library.Tabs) do
            local TabVisibleElements = 0
            local TabBestScore = 0

            for _, Groupbox in pairs(Tab.Groupboxes) do
                local VisibleElements = 0
                for _, ElementInfo in pairs(Groupbox.Elements) do
                    local Visible, MatchScore = ElementMatchesSearch(ElementInfo, Search)
                    if Visible then
                        VisibleElements += 1
                        TabVisibleElements += 1
                        TabBestScore = math.max(TabBestScore, MatchScore)
                    end
                end

                if VisibleElements > 0 then
                    Groupbox:Resize()
                end
                Groupbox.Holder.Visible = VisibleElements > 0
            end

            for _, Tabbox in pairs(Tab.Tabboxes) do
                local VisibleTabs = 0
                local VisibleElements = {}

                for _, InnerTab in pairs(Tabbox.Tabs) do
                    VisibleElements[InnerTab] = 0
                    for _, ElementInfo in pairs(InnerTab.Elements) do
                        local Visible, MatchScore = ElementMatchesSearch(ElementInfo, Search)
                        if Visible then
                            VisibleElements[InnerTab] += 1
                            TabVisibleElements += 1
                            TabBestScore = math.max(TabBestScore, MatchScore)
                        end
                    end
                end

                for InnerTab, Visible in pairs(VisibleElements) do
                    InnerTab.ButtonHolder.Visible = Visible > 0
                    if Visible > 0 then
                        VisibleTabs += 1
                        if Tabbox.ActiveTab == InnerTab then
                            InnerTab:Resize()
                        end
                    end
                end

                Tabbox.Holder.Visible = VisibleTabs > 0
            end

            if TabVisibleElements > 0 and TabBestScore > BestMatchedTabScore then
                BestMatchedTab = Tab
                BestMatchedTabScore = TabBestScore
            end
            if TabVisibleElements > 0 and TabBestScore >= 400 and not BestExactTab then
                BestExactTab = Tab
            end
            if ActiveTabAtSearchStart == Tab then
                ActiveTabScore = TabBestScore
            end
        end

        local TargetTab = BestMatchedTab
        if #Search < 2 and ActiveTabAtSearchStart and ActiveTabScore > 0 then
            TargetTab = ActiveTabAtSearchStart
        elseif BestExactTab and ActiveTabScore < 400 then
            TargetTab = BestExactTab
        elseif ActiveTabAtSearchStart and ActiveTabScore > 0 then
            TargetTab = ActiveTabAtSearchStart
        end

        if TargetTab and Library.ActiveTab ~= TargetTab then
            TargetTab:Show()
        end

        if TargetTab then
            for _, Tabbox in pairs(TargetTab.Tabboxes) do
                local MatchedInnerTab
                local MatchedInnerTabScore = -1
                for _, InnerTab in pairs(Tabbox.Tabs) do
                    local InnerTabScore = 0
                    for _, ElementInfo in pairs(InnerTab.Elements) do
                        InnerTabScore = math.max(InnerTabScore, GetElementSearchScore(ElementInfo, Search))
                    end

                    if InnerTabScore > MatchedInnerTabScore then
                        MatchedInnerTab = InnerTab
                        MatchedInnerTabScore = InnerTabScore
                    end
                end

                if MatchedInnerTab and MatchedInnerTabScore > 0 and Tabbox.ActiveTab ~= MatchedInnerTab then
                    MatchedInnerTab:Show()
                end
            end
        end
    end)

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if UserInputService:GetFocusedTextBox() then
            return
        end

        if
            (
                typeof(Library.ToggleKeybind) == "table"
                    and Library.ToggleKeybind.Type == "KeyPicker"
                    and Input.KeyCode.Name == Library.ToggleKeybind.Value
            ) or Input.KeyCode == Library.ToggleKeybind
        then
            Library.Toggle()
        end
    end))

    return Window
end

local function OnPlayerChange()
    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)

    for _, Dropdown in pairs(Options) do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end
local function OnTeamChange()
    local TeamList = GetTeams()

    for _, Dropdown in pairs(Options) do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

getgenv().Library = Library
return Library
