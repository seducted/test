local Library = (function()

local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local HttpService = game:GetService('HttpService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService');
local TweenService = game:GetService('TweenService');
local SoundService = game:GetService('SoundService');
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local function IsPrimaryPress(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch;
end;

local function IsPressActive(Input)
    if Input.UserInputType == Enum.UserInputType.Touch then
        return Input.UserInputState ~= Enum.UserInputState.End
            and Input.UserInputState ~= Enum.UserInputState.Cancel;
    end;
    return InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1);
end;

local function GetPointerPosition(Input)
    if Input and Input.UserInputType == Enum.UserInputType.Touch then
        return Vector2.new(Input.Position.X, Input.Position.Y);
    end;
    return Vector2.new(Mouse.X, Mouse.Y);
end;

local IsTouchDevice = InputService.TouchEnabled and not InputService.MouseEnabled;

local ProtectGui = function() end;

local ScreenGui = Instance.new('ScreenGui');
ProtectGui(ScreenGui);

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;

local Toggles = {};
local Options = {};



local BaseGroupbox;

local ENUM_UI_FONT_ENTRIES = {
    { 'Legacy', 'Legacy' },
    { 'Arial', 'Arial' },
    { 'Arial Bold', 'ArialBold' },
    { 'Arimo', 'Arimo' },
    { 'Arimo Bold', 'ArimoBold' },
    { 'Gotham', 'Gotham' },
    { 'Gotham Medium', 'GothamMedium' },
    { 'Gotham Bold', 'GothamBold' },
    { 'Gotham Black', 'GothamBlack' },
    { 'Roboto', 'Roboto' },
    { 'Roboto Mono', 'RobotoMono' },
    { 'Roboto Condensed', 'RobotoCondensed' },
    { 'Source Sans', 'SourceSans' },
    { 'Source Sans Bold', 'SourceSansBold' },
    { 'Source Sans Semibold', 'SourceSansSemibold' },
    { 'Source Sans Light', 'SourceSansLight' },
    { 'Source Sans Italic', 'SourceSansItalic' },
    { 'Ubuntu', 'Ubuntu' },
    { 'Bangers', 'Bangers' },
    { 'Arcade', 'Arcade' },
    { 'Code', 'Code' },
    { 'Creepster', 'Creepster' },
    { 'Builder Sans', 'BuilderSans' },
    { 'Builder Sans Medium', 'BuilderSansMedium' },
    { 'Builder Sans Bold', 'BuilderSansBold' },
    { 'Builder Sans ExtraBold', 'BuilderSansExtraBold' },
    { 'SciFi', 'SciFi' },
    { 'Highway', 'Highway' },
    { 'Cartoon', 'Cartoon' },
    { 'Fantasy', 'Fantasy' },
    { 'Fondamento', 'Fondamento' },
    { 'Garamond', 'Garamond' },
    { 'Bodoni', 'Bodoni' },
    { 'Merriweather', 'Merriweather' },
    { 'Oswald', 'Oswald' },
    { 'Patrick Hand', 'PatrickHand' },
    { 'Permanent Marker', 'PermanentMarker' },
    { 'Special Elite', 'SpecialElite' },
    { 'Titillium Web', 'TitilliumWeb' },
    { 'Nunito', 'Nunito' },
    { 'Jura', 'Jura' },
    { 'Michroma', 'Michroma' },
    { 'Antique', 'Antique' },
    { 'Amatic SC', 'AmaticSC' },
    { 'Denk One', 'DenkOne' },
    { 'Josefin Sans', 'JosefinSans' },
    { 'Kalam', 'Kalam' },
    { 'Luckiest Guy', 'LuckiestGuy' },
    { 'Sarpanch', 'Sarpanch' },
};

local ENUM_UI_FONTS = {};
for _, entry in ENUM_UI_FONT_ENTRIES do
    local displayName, enumName = entry[1], entry[2];
    if not ENUM_UI_FONTS[displayName] then
        local ok, enumFont = pcall(function()
            return Enum.Font[enumName];
        end);
        if ok and enumFont then
            ENUM_UI_FONTS[displayName] = enumFont;
        end;
    end;
end;

local CUSTOM_UI_FONTS = {};
local function resolveEnumFontFace(enumFont)
    local ok, face = pcall(Font.fromEnum, enumFont);
    if ok and face then
        return face, enumFont;
    end;

    return nil, enumFont;
end;

local DefaultUIFont = 'Builder Sans ExtraBold';
local InitialFontFace, InitialEnumFont = resolveEnumFontFace(Enum.Font.BuilderSansExtraBold);
if not InitialFontFace then
    InitialFontFace = loadCustomFontFace('XP Tahoma', CUSTOM_UI_FONTS['XP Tahoma'])
        or select(1, resolveEnumFontFace(Enum.Font.Code));
    InitialEnumFont = Enum.Font.Code;
end;

local Library = {
    Registry = {};
    RegistryMap = {};

    HudRegistry = {};

    FontColor = Color3.fromHex("e0d4d6");
    MainColor = Color3.fromHex("121212");
    BackgroundColor = Color3.fromHex("0a0a0a");
    AccentColor = Color3.fromHex("a65d67");
    OutlineColor = Color3.new(0, 0, 0);
    SelectedTabColor = Color3.fromHex("0a0a0a");
    GradientColor = Color3.fromHex("6b3038");
    ShadowColor = Color3.new(0, 0, 0);
    ShadowSize = 0;
    ShadowOffset = 0;
    RiskColor = Color3.fromRGB(255, 50, 50),

    Black = Color3.new(0, 0, 0);
    Font = InitialEnumFont or Enum.Font.BuilderSansExtraBold;
    FontFace = InitialFontFace;
    CurrentUIFont = DefaultUIFont;
    FontCache = {};
    EnumUIFonts = ENUM_UI_FONTS;
    CustomUIFonts = CUSTOM_UI_FONTS;

    OverlayGlowEnabled = false;
    OverlayGlowColor = Color3.fromHex('a65d67');

    OpenedFrames = {};
    DependencyBoxes = {};
    Overlays = {};
    EnemyPlayers = {};
    AllCloseOverlays = false;
    MenuOpen = true;
    NotificationSpot = 'Top Right';
    NotificationAnimation = 'Slide Right to Left';
    ToggleSoundEnabled = true;
    NotificationSoundEnabled = true;
    SliderSoundEnabled = true;
    ToggleSoundVolume = 1;
    ToggleSoundSpeed = 1;
    NotificationSoundVolume = 1;
    NotificationSoundSpeed = 1;
    SliderSoundVolume = 1;
    SliderSoundSpeed = 1;
    MobileOverlayScale = 0.55;
    MobilePickerScale = 0.6;
    ZIndexBase = nil;
    OverlayZIndexBase = nil;
    GradientLabels = {};
    AccentTitleLabels = {};
    PopupZIndexCache = setmetatable({}, { __mode = 'k' });

    Signals = {};
    ScreenGui = ScreenGui;
};

local RainbowStep = 0;
local Hue = 0;
local RainbowAccum = 0;

table.insert(Library.Signals, RenderStepped:Connect(function(Delta)
    RainbowAccum += Delta;
    if RainbowAccum < 0.05 then
        return
    end;

    Hue = Hue + (RainbowAccum * 0.15);
    RainbowAccum = 0;

    if Hue > 1 then
        Hue = 0;
    end;

    Library.CurrentRainbowHue = Hue;
    Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
end));

local function GetPlayersString()
    local PlayerList = Players:GetPlayers();

    for i = 1, #PlayerList do
        PlayerList[i] = PlayerList[i].Name;
    end;

    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);

    return PlayerList;
end;

local function GetTeamsString()
    local TeamList = Teams:GetTeams();

    for i = 1, #TeamList do
        TeamList[i] = TeamList[i].Name;
    end;

    table.sort(TeamList, function(str1, str2) return str1 < str2 end);

    return TeamList;
end;

function Library:SafeCallback(f, ...)
    if (not f) then
        return;
    end;

    if not Library.NotifyOnError then
        return f(...);
    end;

    local success, event = pcall(f, ...);

    if not success then
        local _, i = event:find(":%d+: ");

        if not i then
            return Library:Notify(event);
        end;

        return Library:Notify(event:sub(i + 1), 3);
    end;
end;

Library.UDim2OffsetToString = function(udim2)
    return string.format('%d, %d', udim2.X.Offset, udim2.Y.Offset);
end;
Library.StringToUDim2Offset = function(str)
    local x, y = str:match('([^,]+),%s*([^,]+)');

    return UDim2.fromOffset(tonumber(x), tonumber(y));
end;

function Library:AttemptSave()
    if Library.SaveManager then
        Library.SaveManager:Save();
    end;
end;

function Library:Create(Class, Properties)
    local _Instance = Class;

    if type(Class) == 'string' then
        _Instance = Instance.new(Class);
    end;

    if Properties and type(Properties.ZIndex) == 'number' and Library.OverlayZIndexBase and Properties.ZIndex < 100 then
        Properties.ZIndex = Library.OverlayZIndexBase + Properties.ZIndex;
    end;

    for Property, Value in next, Properties do
        _Instance[Property] = Value;
    end;

    if Library.FontFace and (_Instance:IsA('TextLabel') or _Instance:IsA('TextButton') or _Instance:IsA('TextBox')) then
        if not Properties or not Properties.FontFace then
            pcall(function()
                _Instance.FontFace = Library.FontFace;
            end);
        end;
    elseif (_Instance:IsA('TextLabel') or _Instance:IsA('TextButton') or _Instance:IsA('TextBox')) and (not Properties or not Properties.Font) then
        _Instance.Font = Library.Font;
    end;

    return _Instance;
end;

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1;

    Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0);
        Thickness = 1;
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = Inst;
    });
end;

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Font = Library.Font;
        Text = '';
        TextColor3 = Library.FontColor;
        TextSize = 13;
        TextStrokeTransparency = 0;
    });

    Library:ApplyTextStroke(_Instance);

    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
    }, IsHud);

    return Library:Create(_Instance, Properties);
end;

function Library:MakeDraggable(Instance, Cutoff)
    Instance.Active = true;
    local CutoffHeight = Cutoff or 40;

    local Dragging = false;
    local DragInput = nil;
    local DragPreview = nil;
    local DragStart = nil;
    local StartPos = nil;

    Instance.InputBegan:Connect(function(Input)
        if not IsPrimaryPress(Input) then return end;

        if Dragging then return end;

        local Pointer = GetPointerPosition(Input);

        if (Pointer.Y - Instance.AbsolutePosition.Y) > CutoffHeight then return end;

        if DragPreview then
            DragPreview:Destroy();
            DragPreview = nil;
        end;

        Dragging = true;
        DragInput = Input;
        DragStart = Pointer;
        StartPos = Instance.Position;

        DragPreview = Library:Create("Frame", {
            BackgroundColor3 = Library.AccentColor,
            BackgroundTransparency = 0.75,
            BorderColor3 = Library.AccentColor,
            BorderSizePixel = 5,
            Position = StartPos,
            Size = Instance.Size,
            AnchorPoint = Instance.AnchorPoint,
            ZIndex = 9999,
            Parent = Library.ScreenGui,
        });
    end);

    InputService.InputChanged:Connect(function(Input)
        if not Dragging or not DragPreview then return end;

        if Input == DragInput or (Input.UserInputType == Enum.UserInputType.MouseMovement and DragInput.UserInputType == Enum.UserInputType.MouseButton1) then
            local Current = GetPointerPosition(Input);
            local Delta = Current - DragStart;

            DragPreview.Position = UDim2.new(
                StartPos.X.Scale,
                StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale,
                StartPos.Y.Offset + Delta.Y
            );
        end;
    end));

    InputService.InputEnded:Connect(function(Input)
        if not Dragging or not DragPreview then return end;

        if Input == DragInput or (Input.UserInputType == Enum.UserInputType.MouseButton1 and DragInput.UserInputType == Enum.UserInputType.MouseButton1) then
            Dragging = false;
            DragInput = nil;

            Instance.Position = DragPreview.Position;

            DragPreview:Destroy();
            DragPreview = nil;
        end;
    end);
end;

function Library:AddToolTip(InfoStr, HoverInstance)
    local X, Y = Library:GetTextBounds(InfoStr, Library.Font, 14);
    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,

        Size = UDim2.fromOffset(X + 5, Y + 4),
        ZIndex = 100,
        Parent = Library.ScreenGui,

        Visible = false,
    });

    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(3, 1),
        Size = UDim2.fromOffset(X, Y);
        TextSize = 14;
        Text = InfoStr,
        TextColor3 = Library.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1,

        Parent = Tooltip;
    });

    Library:AddToRegistry(Tooltip, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    Library:AddToRegistry(Label, {
        TextColor3 = 'FontColor',
    });

    local IsHovering = false;

    HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then
            return
        end;

        IsHovering = true;

        Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12);
        Tooltip.Visible = true;

        while IsHovering do
            RunService.Heartbeat:Wait();
            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12);
        end;
    end);

    HoverInstance.MouseLeave:Connect(function()
        IsHovering = false;
        Tooltip.Visible = false;
    end);
end;

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    local activeTweens = {};

    HighlightInstance.MouseEnter:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, Properties do
            local targetValue = Library[ColorIdx] or ColorIdx;
            if typeof(targetValue) == "Color3" then
                if activeTweens[Property] then activeTweens[Property]:Cancel() end;
                local tween = TweenService:Create(Instance, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    [Property] = targetValue
                });
                activeTweens[Property] = tween;
                tween:Play();
            else
                Instance[Property] = targetValue;
            end;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end);

    HighlightInstance.MouseLeave:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, PropertiesDefault do
            local targetValue = Library[ColorIdx] or ColorIdx;
            if typeof(targetValue) == "Color3" then
                if activeTweens[Property] then activeTweens[Property]:Cancel() end;
                local tween = TweenService:Create(Instance, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    [Property] = targetValue
                });
                activeTweens[Property] = tween;
                tween:Play();
            else
                Instance[Property] = targetValue;
            end;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end);
end;

function Library:MouseIsOverOpenedFrame()
    for Frame, _ in next, Library.OpenedFrames do
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
            and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

            return true;
        end;
    end;
end;

function Library:IsMouseOverFrame(Frame)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

    if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

        return true;
    end;
end;

function Library:UpdateDependencyBoxes()
    for _, Depbox in next, Library.DependencyBoxes do
        Depbox:Update();
    end;
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetTextBounds(Text, Font, Size, Resolution)
    function RemoveTags(str)
        str = str:gsub('<br%s*/>', '\n');

        return (str:gsub('<[^<>]->', ''));
    end;

    local CleanText = RemoveTags(Text);
    local Bounds = TextService:GetTextSize(CleanText, Size, Font, Resolution or Vector2.new(1920, 1080));

    return Bounds.X, Bounds.Y;
end;

function Library:ScanCustomUIFonts()
    return {};
end;
function Library:GetUIFontNames()
    local names = {};
    local seen = {};

    local function add(name)
        if name and not seen[name] then
            seen[name] = true;
            table.insert(names, name);
        end;
    end;

    for name in CUSTOM_UI_FONTS do
        add(name);
    end;

    for name in ENUM_UI_FONTS do
        add(name);
    end;

    for name in self:ScanCustomUIFonts() do
        add(name);
    end;

    table.sort(names, function(a, b)
        local aCustom = CUSTOM_UI_FONTS[a] ~= nil;
        local bCustom = CUSTOM_UI_FONTS[b] ~= nil;
        if aCustom ~= bCustom then
            return aCustom;
        end;
        return a < b;
    end);

    return names;
end;

function Library:LoadUIFont(name)
    if self.FontCache[name] then
        return self.FontCache[name].FontFace, self.FontCache[name].Font;
    end;

    local enumFont = ENUM_UI_FONTS[name];
    if enumFont then
        local face = select(1, resolveEnumFontFace(enumFont));
        self.FontCache[name] = { FontFace = face, Font = enumFont };
        return face, enumFont;
    end;

    local fallback = ENUM_UI_FONTS[DefaultUIFont] or Enum.Font.BuilderSans;
    local face = select(1, resolveEnumFontFace(fallback));
    self.FontCache[name] = { FontFace = face, Font = fallback };
    return face, fallback;
end;
function Library:ApplyFontToAll()
    for _, inst in ScreenGui:GetDescendants() do
        if inst:IsA('TextLabel') or inst:IsA('TextButton') or inst:IsA('TextBox') then
            if self.FontFace then
                pcall(function()
                    inst.FontFace = self.FontFace;
                end);
            else
                inst.Font = self.Font;
            end;
        end;
    end;

    if self.LastWatermarkText then
        self:SetWatermark(self.LastWatermarkText);
    end;

    self:UpdateKeybindOverlaySize();
    self:UpdateWindowTabLayout();
end;

function Library:UpdateWindowTabLayout()
    if Library.MainWindow and Library.MainWindow.UpdateTabLayout then
        Library.MainWindow:UpdateTabLayout();
    end;
end;

function Library:SetUIFont(name)
    if not name or name == '' then
        return
    end;

    local face, enumFont = self:LoadUIFont(name);
    self.FontFace = face;
    self.Font = enumFont or Enum.Font.Code;
    self.CurrentUIFont = name;
    self:ApplyFontToAll();
end;

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end;

function Library:GetLighterColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S * 0.8, math.min(V * 1.2, 1));
end;

Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);
Library.AccentColorLight = Library:GetLighterColor(Library.AccentColor);

function Library:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1;
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    };

    table.insert(Library.Registry, Data);
    Library.RegistryMap[Instance] = Data;

    if IsHud then
        table.insert(Library.HudRegistry, Data);
    end;
end;

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance];

    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx);
            end;
        end;

        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx);
            end;
        end;

        Library.RegistryMap[Instance] = nil;
    end;
end;

function Library:IsGuiShown(GuiObject)
    if not GuiObject or not GuiObject:IsA('GuiObject') then
        return true;
    end;

    local current = GuiObject;
    while current and current ~= ScreenGui do
        if current:IsA('GuiObject') and not current.Visible then
            return false;
        end;
        current = current.Parent;
    end;

    return true;
end;

function Library:RefreshThemedControls()
    if Toggles then
        for _, toggle in Toggles do
            if toggle.UpdateColors then
                toggle:UpdateColors();
            elseif toggle.Display then
                toggle:Display();
            end;
        end;
    end;

    if Options then
        for _, option in Options do
            if option.Type == 'Slider' and option.UpdateColors then
                option:UpdateColors();
            elseif option.Type == 'Dropdown' and option.Display then
                option:Display();
            end;
        end;
    end;
end;

function Library:UpdateColorsUsingRegistry()
    Library.ThemeUpdating = true;

    for Idx, Object in next, Library.Registry do
        if Object.Instance and Object.Instance.Parent then
            for Property, ColorIdx in next, Object.Properties do
                if type(ColorIdx) == 'string' then
                    Object.Instance[Property] = Library[ColorIdx];
                elseif type(ColorIdx) == 'function' then
                    Object.Instance[Property] = ColorIdx();
                end;
            end;
        end;
    end;

    if Library.UpdateTitle then
        Library.UpdateTitle();
    end;

    Library:UpdateShadows();
    Library:UpdateScrollBars();

    if Library.LastWatermarkText and Library.WatermarkText then
        Library:SetAccentTitle(Library.WatermarkText, Library.LastWatermarkText, Library.WatermarkAccentPart or '.lol');
    end;

    for _, overlay in next, Library.Overlays do
        if overlay.UpdateTitle then
            overlay.UpdateTitle();
        end;
    end;

    Library:UpdateAllGradientTexts();
    Library:UpdateAllAccentTitles();
    Library:UpdateFooter();
    Library:RefreshThemedControls();
    Library:UpdateOverlayGlows();
    Library.ThemeUpdating = false;
end;

function Library:CreateOverlayGlowLayers(Parent, ZIndex)
    local Layers = {};
    local Thickness = 8;
    local InnerTransparency = 0.42;
    local CornerSpan = Thickness * 2;

    local Holder = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = false;
        Size = UDim2.fromScale(1, 1);
        Position = UDim2.fromScale(0, 0);
        Visible = Library.OverlayGlowEnabled;
        ZIndex = math.max((ZIndex or 1) - 2, 0);
        Parent = Parent;
    });

    table.insert(Layers, Holder);

    local function OutwardFade(FromEdge)
        local Inner = InnerTransparency;

        if FromEdge then
            return NumberSequence.new({
                NumberSequenceKeypoint.new(0, Inner);
                NumberSequenceKeypoint.new(0.3, 0.58);
                NumberSequenceKeypoint.new(0.65, 0.78);
                NumberSequenceKeypoint.new(1, 1);
            });
        end;

        return NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1);
            NumberSequenceKeypoint.new(0.35, 0.78);
            NumberSequenceKeypoint.new(0.7, 0.58);
            NumberSequenceKeypoint.new(1, Inner);
        });
    end;

    local function AddEdge(Size, Position, GradientRotation, FromEdge)
        local Edge = Library:Create('Frame', {
            BackgroundColor3 = Library.OverlayGlowColor;
            BorderSizePixel = 0;
            Position = Position;
            Size = Size;
            ZIndex = Holder.ZIndex;
            Parent = Holder;
        });

        Library:Create('UIGradient', {
            Rotation = GradientRotation;
            Color = ColorSequence.new(Library.OverlayGlowColor);
            Transparency = OutwardFade(FromEdge);
            Parent = Edge;
        });

        Library:AddToRegistry(Edge, {
            BackgroundColor3 = 'OverlayGlowColor';
        }, true);

        table.insert(Layers, Edge);
    end;

    local function AddQuarterCorner(ClipAnchor, ClipPosition, CircleAnchor, GradientRotation)
        local Clip = Library:Create('Frame', {
            AnchorPoint = ClipAnchor;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ClipsDescendants = true;
            Position = ClipPosition;
            Size = UDim2.fromOffset(Thickness, Thickness);
            ZIndex = Holder.ZIndex;
            Parent = Holder;
        });

        local OffsetX = CircleAnchor.X == 1 and Thickness or -Thickness;
        local OffsetY = CircleAnchor.Y == 1 and Thickness or -Thickness;

        local Circle = Library:Create('Frame', {
            AnchorPoint = CircleAnchor;
            BackgroundColor3 = Library.OverlayGlowColor;
            BorderSizePixel = 0;
            Position = UDim2.new(CircleAnchor.X, OffsetX, CircleAnchor.Y, OffsetY);
            Size = UDim2.fromOffset(CornerSpan, CornerSpan);
            ZIndex = Holder.ZIndex;
            Parent = Clip;
        });

        Library:Create('UICorner', {
            CornerRadius = UDim.new(1, 0);
            Parent = Circle;
        });

        Library:Create('UIGradient', {
            Rotation = GradientRotation;
            Color = ColorSequence.new(Library.OverlayGlowColor);
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, InnerTransparency);
                NumberSequenceKeypoint.new(0.35, 0.55);
                NumberSequenceKeypoint.new(0.65, 0.78);
                NumberSequenceKeypoint.new(1, 1);
            });
            Parent = Circle;
        });

        Library:AddToRegistry(Circle, {
            BackgroundColor3 = 'OverlayGlowColor';
        }, true);

        table.insert(Layers, Clip);
        table.insert(Layers, Circle);
    end;

    AddEdge(UDim2.new(1, 0, 0, Thickness), UDim2.new(0, 0, 0, -Thickness), 270, true);
    AddEdge(UDim2.new(1, 0, 0, Thickness), UDim2.new(0, 0, 1, 0), 270, false);
    AddEdge(UDim2.new(0, Thickness, 1, 0), UDim2.new(0, -Thickness, 0, 0), 0, false);
    AddEdge(UDim2.new(0, Thickness, 1, 0), UDim2.new(1, 0, 0, 0), 0, true);

    AddQuarterCorner(Vector2.new(1, 1), UDim2.new(0, 0, 0, 0), Vector2.new(1, 1), 225);
    AddQuarterCorner(Vector2.new(0, 1), UDim2.new(1, 0, 0, 0), Vector2.new(0, 1), 315);
    AddQuarterCorner(Vector2.new(1, 0), UDim2.new(0, 0, 1, 0), Vector2.new(1, 0), 135);
    AddQuarterCorner(Vector2.new(0, 0), UDim2.new(1, 0, 1, 0), Vector2.new(0, 0), 45);

    return Layers;
end;

function Library:UpdateOverlayGlow(Overlay)
    if not Overlay or not Overlay.GlowLayers then
        return
    end;

    local Visible;
    if Overlay == Library.MainWindow then
        Visible = Library.OverlayGlowEnabled
            and Overlay.Outer
            and Overlay.Outer.Visible;
    else
        Visible = Overlay.Visible ~= false and Library.OverlayGlowEnabled;
    end;

    local GlowColor = Library.OverlayGlowColor;
    local ColorSequenceValue = ColorSequence.new(GlowColor);

    for _, Layer in Overlay.GlowLayers do
        Layer.Visible = Visible;

        if Layer:IsA('Frame') then
            local Gradient = Layer:FindFirstChildOfClass('UIGradient');
            if Gradient then
                Layer.BackgroundColor3 = GlowColor;
                Gradient.Color = ColorSequenceValue;
            end;
        end;
    end;
end;

function Library:UpdateOverlayGlows()
    for _, Overlay in Library.Overlays do
        Library:UpdateOverlayGlow(Overlay);
    end;

    if Library.MainWindow then
        Library:UpdateOverlayGlow(Library.MainWindow);
    end;
end;

function Library:SetOverlayGlowEnabled(Enabled)
    Library.OverlayGlowEnabled = not not Enabled;
    Library:UpdateOverlayGlows();
end;

function Library:SetOverlayGlowColor(Color)
    Library.OverlayGlowColor = Color;
    Library:UpdateOverlayGlows();
end;

function Library:GetGradientSequence()
    local White = Color3.new(1, 1, 1);
    local Accent = Library.AccentColor;

    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, White),
        ColorSequenceKeypoint.new(0.35, White:Lerp(Accent, 0.4)),
        ColorSequenceKeypoint.new(0.65, White:Lerp(Accent, 0.75)),
        ColorSequenceKeypoint.new(1, Accent),
    });
end;

function Library:RegisterGradientLabel(Label)
    for _, existing in next, Library.GradientLabels do
        if existing == Label then
            return
        end;
    end;
    table.insert(Library.GradientLabels, Label);
end;

function Library:SetGradientText(Label, Text)
    if not Label then return end;

    for idx = #Library.AccentTitleLabels, 1, -1 do
        if Library.AccentTitleLabels[idx].Label == Label then
            table.remove(Library.AccentTitleLabels, idx);
        end;
    end;

    Label.RichText = false;
    Label.Text = Text or '';
    Label.TextColor3 = Color3.new(1, 1, 1);

    local gradient = Label:FindFirstChild('ElisiumTextGradient');
    if not gradient then
        gradient = Library:Create('UIGradient', {
            Name = 'ElisiumTextGradient';
            Parent = Label;
        });
        Library:RegisterGradientLabel(Label);
    end;

    gradient.Color = Library:GetGradientSequence();
    gradient.Rotation = 0;
end;

function Library:UpdateAllGradientTexts()
    local sequence = Library:GetGradientSequence();

    for idx = #Library.GradientLabels, 1, -1 do
        local label = Library.GradientLabels[idx];
        if not label or not label.Parent then
            table.remove(Library.GradientLabels, idx);
        else
            local gradient = label:FindFirstChild('ElisiumTextGradient');
            if gradient then
                gradient.Color = sequence;
            end;
        end;
    end;
end;

function Library:FormatAccentTitle(Title, AccentPart)
    Title = Title or '';
    AccentPart = AccentPart or '';

    if AccentPart == '' or not string.find(Title, AccentPart, 1, true) then
        return Title;
    end;

    local startIndex = string.find(Title, AccentPart, 1, true);
    local before = string.sub(Title, 1, startIndex - 1);
    local after = string.sub(Title, startIndex + #AccentPart);
    local accentHex = Library.AccentColor:ToHex();

    return string.format(
        '<font color="#ffffff">%s</font><font color="#%s">%s</font><font color="#ffffff">%s</font>',
        before,
        accentHex,
        AccentPart,
        after
    );
end;

function Library:RegisterAccentTitleLabel(Label, Title, AccentPart)
    for _, entry in next, Library.AccentTitleLabels do
        if entry.Label == Label then
            entry.Title = Title;
            entry.AccentPart = AccentPart;
            return
        end;
    end;

    table.insert(Library.AccentTitleLabels, {
        Label = Label;
        Title = Title;
        AccentPart = AccentPart;
    });
end;

function Library:SetAccentTitle(Label, Title, AccentPart)
    if not Label then
        return
    end;

    Title = Title or '';
    AccentPart = AccentPart or '';

    local gradient = Label:FindFirstChild('ElisiumTextGradient');
    if gradient then
        gradient:Destroy();
    end;

    for idx = #Library.GradientLabels, 1, -1 do
        if Library.GradientLabels[idx] == Label then
            table.remove(Library.GradientLabels, idx);
        end;
    end;

    Label.RichText = true;
    Label.TextColor3 = Color3.new(1, 1, 1);
    Label.Text = Library:FormatAccentTitle(Title, AccentPart);
    Library:RegisterAccentTitleLabel(Label, Title, AccentPart);
end;

function Library:UpdateAllAccentTitles()
    for idx = #Library.AccentTitleLabels, 1, -1 do
        local entry = Library.AccentTitleLabels[idx];
        if not entry.Label or not entry.Label.Parent then
            table.remove(Library.AccentTitleLabels, idx);
        else
            entry.Label.RichText = true;
            entry.Label.Text = Library:FormatAccentTitle(entry.Title, entry.AccentPart);
        end;
    end;
end;

function Library:ApplyPopupZIndex(Root, OriginZIndex)
    if not Root then
        return Library:GetPopupZIndex(0);
    end;

    local base = Library:GetPopupZIndex(0);
    OriginZIndex = OriginZIndex or Root.ZIndex or 15;

    local cache = Library.PopupZIndexCache[Root];
    if not cache then
        cache = {
            OriginZ = OriginZIndex;
            OriginalZ = {};
        };
        Library.PopupZIndexCache[Root] = cache;
    else
        cache.OriginZ = OriginZIndex;
    end;

    local delta = base - cache.OriginZ;

    local function Apply(instance)
        if not instance:IsA('GuiObject') then
            return
        end;

        if cache.OriginalZ[instance] == nil then
            cache.OriginalZ[instance] = instance.ZIndex;
        end;

        instance.ZIndex = cache.OriginalZ[instance] + delta;
    end;

    Apply(Root);

    for _, descendant in Root:GetDescendants() do
        Apply(descendant);
    end;

    return base;
end;

function Library:CreateTabBottomGlow(Parent, Options)
    Options = Options or {};

    local GlowHeight = Options.GlowHeight or 18;
    local LineHeight = Options.LineHeight or 2;
    local ZIndex = Options.ZIndex or 1;

    local TabGlow = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 1);
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 1, 0);
        Size = UDim2.new(1, 0, 0, GlowHeight);
        Visible = false;
        ZIndex = ZIndex;
        Parent = Parent;
    });

    Library:AddToRegistry(TabGlow, {
        BackgroundColor3 = 'AccentColor';
    });

    Library:Create('UIGradient', {
        Rotation = 90;
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.38);
            NumberSequenceKeypoint.new(0.3, 0.62);
            NumberSequenceKeypoint.new(0.65, 0.86);
            NumberSequenceKeypoint.new(1, 1);
        });
        Parent = TabGlow;
    });

    local TabLine = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 1);
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 1, 0);
        Size = UDim2.new(1, 0, 0, LineHeight);
        Visible = false;
        ZIndex = ZIndex + 2;
        Parent = Parent;
    });

    Library:AddToRegistry(TabLine, {
        BackgroundColor3 = 'AccentColor';
    });

    return TabGlow, TabLine;
end;

function Library:SetTabGlowVisible(TabGlow, TabLine, Visible)
    if TabGlow then
        TabGlow.Visible = Visible;
    end;

    if TabLine then
        TabLine.Visible = Visible;
    end;
end;

function Library:ApplyWindowShadow() end;

function Library:LinkWindowShadow() end;

function Library:LinkWindowShadow() end;

function Library:UpdateMenuBlur()
    local lighting = game:GetService('Lighting');
    local blur = lighting:FindFirstChild('ElisiumMenuBlur');
    local enabled = Toggles and Toggles.MenuBlurToggle and Toggles.MenuBlurToggle.Value;
    local shouldBlur = enabled and Library.MenuOpen;

    if shouldBlur then
        if not blur then
            blur = Instance.new('BlurEffect');
            blur.Name = 'ElisiumMenuBlur';
            blur.Size = 12;
            blur.Parent = lighting;
        end;
    elseif blur then
        blur:Destroy();
    end;
end;

function Library:UpdateFooter()
    if not Library.FooterLeft or not Library.FooterRight then
        return
    end;

    local username = Library.AnonymousMode and 'anonymous' or LocalPlayer.Name;
    local placeName = Library.PlaceName or 'Baseplate';
    local greyHex = '828282';
    local accentHex = Library.AccentColor:ToHex();

    Library.FooterLeft.RichText = true;
    Library.FooterLeft.TextTransparency = 0;
    Library.FooterLeft.Text = string.format(
        '<font color="#%s">welcome back, </font><font color="#%s">%s</font>',
        greyHex,
        accentHex,
        username
    );

    Library.FooterRight.RichText = true;
    Library.FooterRight.TextTransparency = 0;
    Library.FooterRight.Text = string.format(
        '<font color="#%s">[ </font><font color="#%s">%s</font><font color="#%s"> ]</font>',
        greyHex,
        accentHex,
        placeName,
        greyHex
    );
end;

function Library:GetKeybindRowZBase()
    if Library.KeybindOverlay and Library.KeybindOverlay.Outer then
        return Library.KeybindOverlay.Outer.ZIndex + 12;
    end;

    return 225;
end;

function Library:GetPopupZIndex(Offset)
    Offset = Offset or 0;
    local Z = 250 + Offset;

    if Library.KeybindOverlay and Library.KeybindOverlay.ZIndexBase then
        Z = math.max(Z, Library.KeybindOverlay.ZIndexBase + 50 + Offset);
    end;

    for _, Overlay in Library.Overlays do
        if Overlay and Overlay.ZIndexBase then
            Z = math.max(Z, Overlay.ZIndexBase + 50 + Offset);
        end;
    end;

    return Z;
end;

function Library:SyncKeybindRowsZIndex()
    if not Library.KeybindContainer then
        return
    end;

    local base = Library:GetKeybindRowZBase();

    for _, row in Library.KeybindContainer:GetChildren() do
        if row:IsA('Frame') then
            row.ZIndex = base;

            for _, child in row:GetChildren() do
                if child:IsA('TextLabel') then
                    child.ZIndex = base + 3;
                    child.TextTransparency = 0;
                elseif child:IsA('Frame') then
                    child.ZIndex = base + 3;

                    local valueLabel = child:FindFirstChildWhichIsA('TextLabel');
                    if valueLabel then
                        valueLabel.ZIndex = base + 5;
                        valueLabel.TextTransparency = 0;
                        valueLabel.TextColor3 = Color3.new(1, 1, 1);
                    end;
                end;
            end;
        end;
    end;

    Library.KeybindContainer.ZIndex = base;
end;

function Library:UpdateKeybindOverlaySize()
    if not Library.KeybindContainer or Library._UpdatingKeybindOverlaySize then
        return
    end;

    Library._UpdatingKeybindOverlaySize = true;

    Library:SyncKeybindRowsZIndex();

    local rowHeight = 0;
    local maxWidth = 170;
    local activeCount = 0;

    for _, row in Library.KeybindContainer:GetChildren() do
        if row:IsA('Frame') and row.Visible then
            activeCount += 1;
            rowHeight += 24;
            local nameLabel = row:FindFirstChildWhichIsA('TextLabel');
            local keyBox = row:FindFirstChildWhichIsA('Frame');
            if nameLabel and keyBox then
                local valueLabel = keyBox:FindFirstChildWhichIsA('TextLabel');
                local keyText = valueLabel and valueLabel.Text or '';
                local rowWidth = Library:GetTextBounds(nameLabel.Text, Library.Font, 13)
                    + Library:GetTextBounds(keyText, Library.Font, 12)
                    + 28;
                maxWidth = math.max(maxWidth, rowWidth);
            end;
        end;
    end;

    local compact = activeCount == 0;
    Library.KeybindOverlayCompact = compact;

    if compact then
        rowHeight = 0;
    else
        rowHeight = math.max(rowHeight, 22);
    end;

    local contentHeight = compact and 0 or math.max(rowHeight + 8, 22);

    Library.KeybindContainer.Size = UDim2.new(1, -12, 0, rowHeight);

    if Library.KeybindOverlay and Library.KeybindOverlay.Outer then
        local overlay = Library.KeybindOverlay;
        local overlayWidth = math.max(maxWidth + 24, 196);
        local targetSize;

        if overlay.ContentOuter then
            overlay.ContentOuter.Visible = not compact;
            overlay.ContentOuter.Size = UDim2.new(1, -12, 0, contentHeight);
        end;

        if overlay.ContentInner then
            overlay.ContentInner.Size = UDim2.new(1, -2, 1, -2);
        end;

        if overlay.Container then
            overlay.Container.Visible = false;
        end;

        if compact then
            targetSize = UDim2.fromOffset(overlayWidth, 32);
        else
            targetSize = UDim2.fromOffset(overlayWidth, 26 + contentHeight + 6);
        end;

        if Library.KeybindOverlayTween then
            Library.KeybindOverlayTween:Cancel();
        end;

        Library.KeybindOverlayTween = TweenService:Create(overlay.Outer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = targetSize,
        });
        Library.KeybindOverlayTween:Play();
    end;

    Library._UpdatingKeybindOverlaySize = false;
end;

function Library:GetUIScaleFactor(Instance)
    local current = Instance;
    while current and current ~= ScreenGui do
        local scale = current:FindFirstChildOfClass('UIScale');
        if scale then
            return scale.Scale;
        end;
        current = current.Parent;
    end;
    return 1;
end;

function Library:UpdateShadows() end;

function Library:UpdateScrollBars()
    for _, desc in ScreenGui:GetDescendants() do
        if desc:IsA('ScrollingFrame') then
            desc.ScrollBarImageColor3 = Library.AccentColor;
        end;
    end;
end;

function Library:SetAllCloseEnabled(Enabled)
    Library.AllCloseOverlays = not not Enabled;
    if Library.AllCloseOverlays then
        Library:SyncOverlaysWithMenu(Library.MenuOpen);
    end;
end;

function Library:SyncOverlaysWithMenu(MenuVisible)
    for _, overlay in Library.Overlays do
        if overlay.SetVisible then
            if MenuVisible then
                if Library.AllCloseOverlays then
                    overlay:SetVisible(true);
                end;
            else
                overlay:SetVisible(false);
            end;
        elseif overlay.Outer then
            if MenuVisible then
                if Library.AllCloseOverlays then
                    overlay.Outer.Visible = true;
                    overlay.Visible = true;
                end;
            else
                overlay.Outer.Visible = false;
                overlay.Visible = false;
            end;
        end;
    end;
end;

function Library:BindHoldButton(Button, StepCallback)
    if not Button or not StepCallback then return end;

    local holding = false;

    local function stop()
        holding = false;
        Library:StopSliderSound();
    end;

    Button.MouseButton1Down:Connect(function()
        holding = true;
        StepCallback();
        task.spawn(function()
            task.wait(0.35);
            while holding and Button.Parent do
                StepCallback();
                task.wait(0.06);
            end;
        end);
    end);

    Button.MouseButton1Up:Connect(stop);
    Button.MouseLeave:Connect(stop);
end;

function Library:CreateOverlayWindow(Config)
    Config = Config or {};

    local Title = Config.Title or 'Overlay';
    local Size = typeof(Config.Size) == 'UDim2' and Config.Size or UDim2.fromOffset(260, 300);
    local Position = typeof(Config.Position) == 'UDim2' and Config.Position or UDim2.fromOffset(100, 100);
    local ZIndex = Config.ZIndex or 150;
    local Visible = Config.Visible == true;
    local AccentPart = Config.AccentPart;
    local ZIndexBase = ZIndex + 10;
    local PreviousOverlayBase = Library.OverlayZIndexBase;

    Library.OverlayZIndexBase = ZIndexBase;

    local Overlay = {
        Visible = Visible;
        Tabs = {};
        Groupboxes = {};
        ZIndexBase = ZIndexBase;
    };

    local Outer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = false;
        Position = Position;
        Size = Size;
        Visible = Visible;
        ZIndex = ZIndex;
        Parent = ScreenGui;
    });

    local OverlayScaleFactor = 1;
    if IsTouchDevice then
        OverlayScaleFactor = Library.MobileOverlayScale or 0.55;
        Library:Create('UIScale', {
            Scale = OverlayScaleFactor;
            Parent = Outer;
        });

        task.delay(0.1, function()
            if not Outer.Parent then
                return
            end;

            local screen = ScreenGui.AbsoluteSize;
            if screen.X <= 0 or screen.Y <= 0 then
                return
            end;

            local maxX = math.max(screen.X - Outer.AbsoluteSize.X, 0);
            local maxY = math.max(screen.Y - Outer.AbsoluteSize.Y, 0);
            local x = math.clamp(Outer.Position.X.Offset, 0, maxX);
            local y = math.clamp(Outer.Position.Y.Offset, 0, maxY);

            if x ~= Outer.Position.X.Offset or y ~= Outer.Position.Y.Offset then
                Outer.Position = UDim2.fromOffset(x, y);
            end;
        end);
    end;

    Overlay.GlowLayers = nil;

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderSizePixel = 0;
        ClipsDescendants = false;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = ZIndex + 1;
        Parent = Outer;
    });

    Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor' });

    Overlay.GlowLayers = Library:CreateOverlayGlowLayers(Inner, ZIndex);

    local TopAccent = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = ZIndex + 5;
        Parent = Inner;
    });

    Library:AddToRegistry(TopAccent, { BackgroundColor3 = 'AccentColor' });

    local TitleLabel = Library:CreateLabel({
        Position = UDim2.new(0, 8, 0, 4);
        Size = UDim2.new(1, -16, 0, 20);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = ZIndex + 2;
        Parent = Inner;
    });

    local function UpdateOverlayTitle()
        if AccentPart and AccentPart ~= '' then
            Library:SetAccentTitle(TitleLabel, Title, AccentPart);
        else
            Library:SetGradientText(TitleLabel, Title);
        end;
    end;

    local ContentOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        ClipsDescendants = true;
        Position = UDim2.new(0, 6, 0, 26);
        Size = UDim2.new(1, -12, 0, 0);
        ZIndex = ZIndex + 1;
        Parent = Inner;
    });

    Library:AddToRegistry(ContentOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    local ContentInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = ZIndex + 2;
        Parent = ContentOuter;
    });

    Library:AddToRegistry(ContentInner, { BackgroundColor3 = 'BackgroundColor' });

    local Container = Library:Create('ScrollingFrame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Position = UDim2.new(0, 4, 0, 4);
        Size = UDim2.new(1, -8, 1, -8);
        CanvasSize = UDim2.new(0, 0, 0, 0);
        ScrollBarThickness = 3;
        ScrollBarImageColor3 = Library.AccentColor;
        BottomImage = '';
        TopImage = '';
        ZIndex = ZIndex + 3;
        Parent = ContentInner;
    });

    Library:AddToRegistry(Container, {
        ScrollBarImageColor3 = 'AccentColor';
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 6);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Container;
    });

    Container:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        if Overlay.Resize then
            Overlay:Resize();
        end;
    end);

    function Overlay:Resize()
        local listLayout = Container:FindFirstChildOfClass('UIListLayout');
        if not listLayout then
            return
        end;

        local contentH = math.ceil(listLayout.AbsoluteContentSize.Y / OverlayScaleFactor);
        if contentH <= 0 then
            return
        end;

        local chromeTop = 26;
        local chromeBottom = 6;
        local containerPadding = 8;
        local width = Outer.Size.X.Offset;

        Container.Size = UDim2.new(1, -8, 0, contentH);
        Container.CanvasSize = UDim2.fromOffset(0, contentH);
        ContentOuter.Size = UDim2.new(1, -12, 0, contentH + containerPadding);

        local height = chromeTop + contentH + containerPadding + chromeBottom;
        Outer.Size = UDim2.fromOffset(width, math.max(height, 56));
    end;

    Library:MakeDraggable(Outer, 28);

    function Overlay:SetVisible(Bool)
        Overlay.Visible = not not Bool;
        Outer.Visible = Overlay.Visible;
        Library:UpdateOverlayGlow(Overlay);
    end;

    function Overlay:Show()
        Overlay:SetVisible(true);
    end;

    function Overlay:Hide()
        Overlay:SetVisible(false);
    end;

    function Overlay:Toggle()
        Overlay:SetVisible(not Overlay.Visible);
    end;

    function Overlay:SetTitle(NewTitle, NewAccentPart)
        Title = NewTitle or Title;
        AccentPart = NewAccentPart or AccentPart;
        UpdateOverlayTitle();
    end;

    function Overlay:AddGroupbox(Info)
        local Groupbox = {};
        local boxName = Info.Name or 'Section';

        local BoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, -4, 0, 0);
            ZIndex = ZIndex + 4;
            Parent = Container;
        });

        Library:AddToRegistry(BoxOuter, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local BoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, -2, 1, -2);
            Position = UDim2.new(0, 1, 0, 1);
            ZIndex = ZIndex + 5;
            Parent = BoxOuter;
        });

        Library:AddToRegistry(BoxInner, { BackgroundColor3 = 'BackgroundColor' });

        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = ZIndex + 6;
            Parent = BoxInner;
        });

        Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor' });

        Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 16);
            Position = UDim2.new(0, 4, 0, 2);
            TextSize = 13;
            Text = boxName;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = ZIndex + 6;
            Parent = BoxInner;
        });

        local GroupContainer = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 6, 0, 18);
            Size = UDim2.new(1, -10, 0, 0);
            ZIndex = ZIndex + 5;
            Parent = BoxInner;
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = GroupContainer;
        });

        local GroupListLayout = GroupContainer:FindFirstChildOfClass('UIListLayout');
        if GroupListLayout then
            GroupListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Groupbox:Resize();
            end);
        end;

        function Groupbox:Resize()
            local listLayout = GroupContainer:FindFirstChildOfClass('UIListLayout');
            local SizeY = listLayout and math.ceil(listLayout.AbsoluteContentSize.Y / OverlayScaleFactor) or 0;
            GroupContainer.Size = UDim2.new(1, -10, 0, SizeY);
            BoxOuter.Size = UDim2.new(1, -4, 0, 18 + SizeY + 4);
            task.defer(function()
                if Overlay.Resize then
                    Overlay:Resize();
                end;
            end);
        end;

        Groupbox.Container = GroupContainer;
        Groupbox.ContentBaseZIndex = ZIndex + 10;
        setmetatable(Groupbox, BaseGroupbox);
        Groupbox:AddBlank(3);
        Groupbox:Resize();

        Overlay.Groupboxes[boxName] = Groupbox;
        return Groupbox;
    end;

    Overlay.Outer = Outer;
    Overlay.Inner = Inner;
    Overlay.Container = Container;
    Overlay.ContentOuter = ContentOuter;
    Overlay.ContentInner = ContentInner;
    Overlay.TitleLabel = TitleLabel;
    Overlay.UpdateTitle = UpdateOverlayTitle;
    UpdateOverlayTitle();

    table.insert(Library.Overlays, Overlay);
    task.defer(function()
        Overlay:Resize();
    end);

    Library.OverlayZIndexBase = PreviousOverlayBase;

    return Overlay;
end;

function Library:CreateOverlayOpener(Items, ParentContainer, Groupbox)
    local Opener = {};
    local ContentZ = (Groupbox and Groupbox.ContentBaseZIndex or 10);

    local List = Library:Create('Frame', {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.Y;
        Size = UDim2.new(1, 0, 0, 0);
        ZIndex = ContentZ + 6;
        Parent = ParentContainer;
    });

    local OpenerLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = List;
    });

    for _, item in next, Items do
        local Row = Library:Create('TextButton', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            AutoButtonColor = false;
            Size = UDim2.new(1, -4, 0, 22);
            Text = '';
            ZIndex = ContentZ + 7;
            Parent = List;
        });

        Library:AddToRegistry(Row, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local displayText = item.Text or item.Name or 'Open';

        local RowLabel = Library:CreateLabel({
            Size = UDim2.new(1, -8, 1, 0);
            Position = UDim2.new(0, 6, 0, 0);
            Text = displayText;
            TextSize = 13;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = ContentZ + 8;
            Parent = Row;
        });

        Library:SetGradientText(RowLabel, displayText);

        Library:OnHighlight(Row, Row,
            { BackgroundColor3 = 'SelectedTabColor', BorderColor3 = 'AccentColor' },
            { BackgroundColor3 = 'MainColor', BorderColor3 = 'OutlineColor' }
        );

        Row.MouseButton1Click:Connect(function()
            if item.Overlay and item.Overlay.Toggle then
                item.Overlay:Toggle();
            elseif type(item.Callback) == 'function' then
                Library:SafeCallback(item.Callback);
            end;
        end);
    end;

    Opener.Frame = List;

    if Groupbox and Groupbox.Resize then
        Groupbox:Resize();
        OpenerLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Groupbox:Resize();
        end);
        task.defer(function()
            Groupbox:Resize();
        end);
    end;

    return Opener;
end;

function Library:CreatePlayerListOverlay(Config)
    Config = Config or {};
    local Overlay = Library:CreateOverlayWindow({
        Title = 'Player List';
        AccentPart = 'List';
        Size = UDim2.fromOffset(320, 392);
        Position = Config.Position or UDim2.fromOffset(40, 80);
        Visible = Config.Visible;
        ZIndex = Config.ZIndex or 160;
    });

    local Groupbox = Overlay:AddGroupbox({ Name = 'Players' });
    local PZ = Overlay.ZIndexBase + 15;

    Groupbox:AddInput('PlayerListSearch', {
        Text = 'Search';
        NoLabel = true;
        Default = '';
        Placeholder = 'Search...';
        Finished = false;
        ClearOnFocus = false;
    });

    local ListHolder = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, -4, 0, 220);
        ClipsDescendants = true;
        ZIndex = PZ;
        Parent = Groupbox.Container;
    });

    Library:AddToRegistry(ListHolder, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    local PlayerScroll = Library:Create('ScrollingFrame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Size = UDim2.new(1, 0, 1, 0);
        CanvasSize = UDim2.new(0, 0, 0, 0);
        ScrollBarThickness = 3;
        ScrollBarImageColor3 = Library.AccentColor;
        BottomImage = '';
        TopImage = '';
        ZIndex = PZ + 1;
        Parent = ListHolder;
    });

    Library:AddToRegistry(PlayerScroll, {
        ScrollBarImageColor3 = 'AccentColor';
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        SortOrder = Enum.SortOrder.LayoutOrder;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
        Parent = PlayerScroll;
    });

    local SelectedPanel = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, -4, 0, 82);
        ClipsDescendants = true;
        ZIndex = PZ;
        Parent = Groupbox.Container;
    });

    Library:AddToRegistry(SelectedPanel, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    local Avatar = Library:Create('ImageLabel', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 6);
        Size = UDim2.fromOffset(64, 64);
        ZIndex = PZ + 1;
        Parent = SelectedPanel;
    });

    Library:AddToRegistry(Avatar, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    local TeleportBtn = Library:Create('TextButton', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 80, 0, 6);
        Size = UDim2.fromOffset(88, 28);
        Text = 'Teleport';
        TextColor3 = Library.FontColor;
        TextSize = 13;
        AutoButtonColor = false;
        ZIndex = PZ + 1;
        Parent = SelectedPanel;
    });

    Library:AddToRegistry(TeleportBtn, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
        TextColor3 = 'FontColor';
    });

    local SpectateBtn = Library:Create('TextButton', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 80, 0, 38);
        Size = UDim2.fromOffset(88, 28);
        Text = 'Spectate';
        TextColor3 = Library.FontColor;
        TextSize = 13;
        AutoButtonColor = false;
        ZIndex = PZ + 1;
        Parent = SelectedPanel;
    });

    Library:AddToRegistry(SpectateBtn, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
        TextColor3 = 'FontColor';
    });

    local SelectedName = Library:CreateLabel({
        Position = UDim2.new(0, 176, 0, 6);
        Size = UDim2.new(1, -182, 0, 16);
        Text = 'No player selected';
        TextSize = 13;
        TextTruncate = Enum.TextTruncate.AtEnd;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = PZ + 2;
        Parent = SelectedPanel;
    });

    Groupbox:AddDropdown('PlayerListStatus', {
        Values = { 'Enemy', 'Friendly', 'Neutral' };
        Default = 1;
    });

    if Options.PlayerListStatus and Options.PlayerListStatus.Outer then
        local StatusOuter = Options.PlayerListStatus.Outer;
        StatusOuter.Parent = SelectedPanel;
        StatusOuter.Position = UDim2.new(0, 176, 0, 28);
        StatusOuter.Size = UDim2.new(1, -182, 0, 20);
        StatusOuter.ZIndex = PZ + 2;
    end;

    Groupbox:Resize();

    local selectedPlayer;
    local playerButtons = {};
    local enemyPlayers = {};
    local clientGrey = Color3.fromRGB(140, 140, 140);
    local enemyRed = Color3.fromRGB(255, 80, 80);
    local statusUpdating = false;

    local function SelectPlayer(player)
        selectedPlayer = player;
        if player then
            SelectedName.Text = player.Name;
            if enemyPlayers[player] then
                SelectedName.TextColor3 = enemyRed;
            elseif player == LocalPlayer then
                SelectedName.TextColor3 = clientGrey;
            else
                SelectedName.TextColor3 = Library.FontColor;
            end;

            if Options.PlayerListStatus then
                local status = enemyPlayers[player] and 'Enemy' or 'Friendly';
                if Options.PlayerListStatus.Value ~= status then
                    statusUpdating = true;
                    Options.PlayerListStatus:SetValue(status);
                    statusUpdating = false;
                end;
            end;

            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48);
            end);
            Avatar.Image = ok and thumb or '';
        else
            SelectedName.Text = 'No player selected';
            SelectedName.TextColor3 = Library.FontColor;
            Avatar.Image = '';
        end;
    end;

    local refreshPending = false;

    local function RefreshPlayers()
        if refreshPending then
            return
        end;

        refreshPending = true;
        task.defer(function()
            refreshPending = false;
            if not PlayerScroll.Parent then
                return
            end;

            for _, btn in playerButtons do
                btn:Destroy();
            end;
            table.clear(playerButtons);

            local filter = string.lower(Options.PlayerListSearch and Options.PlayerListSearch.Value or '');
            local layoutOrder = 0;

            for _, player in Players:GetPlayers() do
                local isLocal = player == LocalPlayer;
                local displayName = isLocal and (player.Name .. ' (Client)') or player.Name;
                if filter == '' or string.find(string.lower(displayName), filter, 1, true) then
                    layoutOrder += 1;
                    local isEnemy = enemyPlayers[player];
                    local Btn = Library:Create('TextButton', {
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1, -8, 0, 22);
                        Text = displayName;
                        TextColor3 = isEnemy and enemyRed or (isLocal and clientGrey or (player == selectedPlayer and Library.AccentColor or Library.FontColor));
                        TextSize = 13;
                        Font = Library.Font;
                        TextXAlignment = Enum.TextXAlignment.Center;
                        LayoutOrder = layoutOrder;
                        AutoButtonColor = false;
                        ZIndex = PZ + 3;
                        Parent = PlayerScroll;
                    });

                    Btn.MouseButton1Click:Connect(function()
                        SelectPlayer(player);
                        RefreshPlayers();
                    end);

                    playerButtons[#playerButtons + 1] = Btn;
                end;
            end;

            PlayerScroll.CanvasSize = UDim2.fromOffset(0, math.max(layoutOrder * 26, 26));
            Groupbox:Resize();
        end);
    end;

    if Options.PlayerListSearch then
        Options.PlayerListSearch:OnChanged(RefreshPlayers);
    end;

    if Options.PlayerListStatus then
        Options.PlayerListStatus:OnChanged(function()
            if statusUpdating then
                return
            end;

            if selectedPlayer then
                enemyPlayers[selectedPlayer] = Options.PlayerListStatus.Value == 'Enemy';
                if enemyPlayers[selectedPlayer] then
                    SelectedName.TextColor3 = enemyRed;
                elseif selectedPlayer == LocalPlayer then
                    SelectedName.TextColor3 = clientGrey;
                else
                    SelectedName.TextColor3 = Library.FontColor;
                end;
                RefreshPlayers();
            end;
        end);
    end;

    Players.PlayerAdded:Connect(RefreshPlayers);
    Players.PlayerRemoving:Connect(function(player)
        enemyPlayers[player] = nil;
        if selectedPlayer == player then
            SelectPlayer(nil);
        end;
        RefreshPlayers();
    end);

    TeleportBtn.MouseButton1Click:Connect(function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild('HumanoidRootPart') then
            local char = LocalPlayer.Character;
            if char and char:FindFirstChild('HumanoidRootPart') then
                char.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame;
            end;
        end;
    end);

    local spectating;
    local savedMinZoom, savedMaxZoom, savedCameraMode;

    local function StopSpectating()
        if not spectating then
            return
        end;

        spectating = nil;
        SpectateBtn.Text = 'Spectate';

        if savedMinZoom ~= nil then
            LocalPlayer.CameraMinZoomDistance = savedMinZoom;
            LocalPlayer.CameraMaxZoomDistance = savedMaxZoom;
            LocalPlayer.CameraMode = savedCameraMode;
            savedMinZoom, savedMaxZoom, savedCameraMode = nil, nil, nil;
        end;

        local camera = workspace.CurrentCamera;
        if camera then
            local char = LocalPlayer.Character;
            local hum = char and char:FindFirstChildOfClass('Humanoid');
            if hum then
                camera.CameraSubject = hum;
            end;
            camera.CameraType = Enum.CameraType.Custom;
        end;
    end;

    Library:GiveSignal(RunService.RenderStepped:Connect(function()
        if not spectating then
            return
        end;

        if not spectating.Parent then
            StopSpectating();
            return
        end;

        local targetCharacter = spectating.Character;
        local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass('Humanoid');
        local camera = workspace.CurrentCamera;
        if not targetHumanoid or not camera then
            return
        end;

        if camera.CameraSubject ~= targetHumanoid then
            camera.CameraSubject = targetHumanoid;
        end;
        if camera.CameraType ~= Enum.CameraType.Custom then
            camera.CameraType = Enum.CameraType.Custom;
        end;
    end));

    SpectateBtn.MouseButton1Click:Connect(function()
        if spectating then
            StopSpectating();
            return
        end;

        if not selectedPlayer or selectedPlayer == LocalPlayer then
            return
        end;

        local targetCharacter = selectedPlayer.Character;
        local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass('Humanoid');
        if not targetHumanoid then
            return
        end;

        savedMinZoom = LocalPlayer.CameraMinZoomDistance;
        savedMaxZoom = LocalPlayer.CameraMaxZoomDistance;
        savedCameraMode = LocalPlayer.CameraMode;

        LocalPlayer.CameraMode = Enum.CameraMode.Classic;
        LocalPlayer.CameraMinZoomDistance = 0.5;
        LocalPlayer.CameraMaxZoomDistance = 128;

        spectating = selectedPlayer;
        SpectateBtn.Text = 'Unspectate';

        local camera = workspace.CurrentCamera;
        if camera then
            camera.CameraSubject = targetHumanoid;
            camera.CameraType = Enum.CameraType.Custom;
        end;
    end);

    RefreshPlayers();
    task.defer(function()
        Groupbox:Resize();
        Overlay:Resize();
    end);
    Overlay.RefreshPlayers = RefreshPlayers;
    Overlay.SelectPlayer = SelectPlayer;
    Library.EnemyPlayers = enemyPlayers;
    Overlay.EnemyPlayers = enemyPlayers;
    return Overlay;
end;

function Library:CreateESPPreviewOverlay(Config)
    Config = Config or {};
    local Overlay = Library:CreateOverlayWindow({
        Title = 'ESP Preview';
        Size = UDim2.fromOffset(200, 254);
        Position = Config.Position or UDim2.fromOffset(940, 80);
        Visible = Config.Visible;
        ZIndex = Config.ZIndex or 160;
    });

    local Groupbox = Overlay:AddGroupbox({ Name = 'Preview' });

    local PreviewHolder = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, -4, 0, 210);
        ClipsDescendants = true;
        ZIndex = 8;
        Parent = Groupbox.Container;
    });

    Library:AddToRegistry(PreviewHolder, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    local Viewport = Library:Create('ViewportFrame', {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25);
        BorderColor3 = Color3.fromRGB(70, 70, 70);
        BorderSizePixel = 1;
        Size = UDim2.new(1, -2, 1, -2);
        Position = UDim2.new(0, 1, 0, 1);
        Ambient = Color3.fromRGB(200, 200, 200);
        LightColor = Color3.fromRGB(255, 255, 255);
        LightDirection = Vector3.new(-1, -1, -1);
        ZIndex = 9;
        Parent = PreviewHolder;
    });

    local worldModel = Instance.new('WorldModel');
    worldModel.Parent = Viewport;

    local camera = Instance.new('Camera');
    camera.Parent = Viewport;
    Viewport.CurrentCamera = camera;

    local clone;
    local previewOk = pcall(function()
        clone = Players:CreateHumanoidModelFromDescriptionAsync(
            Players:GetHumanoidDescriptionFromUserIdAsync(1),
            Enum.HumanoidRigType.R15
        );
    end);

    if not previewOk or not clone then
        pcall(function()
            clone = Players:CreateHumanoidModelFromDescription(
                Players:GetHumanoidDescriptionFromUserId(1),
                Enum.HumanoidRigType.R15
            );
        end);
    end;

    if clone then
        for _, obj in clone:GetDescendants() do
            if obj:IsA('LocalScript') or obj:IsA('Script') then
                obj:Destroy();
            end;
        end;
        clone.Parent = worldModel;

        local root = clone:WaitForChild('HumanoidRootPart');
        local target = root.Position + Vector3.new(0, -0.34, 0);
        local radius = 5.4;
        local height = 1;
        local angle = 0;
        local speed = math.rad(30);

        local previewAccum = 0;
        local previewStep = IsTouchDevice and 0.12 or 0.05;
        Library:GiveSignal(RunService.RenderStepped:Connect(function(dt)
            if not Overlay.Visible or not Overlay.Outer or not Overlay.Outer.Visible then
                return
            end;

            previewAccum += dt;
            if previewAccum < previewStep then
                return
            end;

            angle += speed * previewAccum;
            previewAccum = 0;
            local offset = Vector3.new(
                math.sin(angle) * radius,
                height,
                math.cos(angle) * radius
            );
            camera.CFrame = CFrame.lookAt(target + offset, target);
        end));
    end;

    local Box = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderColor3 = Library.AccentColor;
        BorderSizePixel = 1;
        Position = UDim2.new(0.3, 0, 0.1, 0);
        Size = UDim2.new(0.4, 0, 0.78, 0);
        ZIndex = 12;
        Parent = PreviewHolder;
    });

    Library:AddToRegistry(Box, { BorderColor3 = 'AccentColor' });

    local HealthBarBg = Library:Create('Frame', {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40);
        BorderSizePixel = 0;
        Position = UDim2.new(0.22, 0, 0.1, 0);
        Size = UDim2.new(0, 3, 0.78, 0);
        ZIndex = 12;
        Parent = PreviewHolder;
    });

    Library:Create('Frame', {
        BackgroundColor3 = Color3.fromRGB(80, 220, 80);
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 13;
        Parent = HealthBarBg;
    });

    Library:CreateLabel({
        Position = UDim2.new(0.16, 0, 0.42, 0);
        Size = UDim2.new(0, 20, 0, 14);
        Text = '100';
        TextSize = 11;
        TextXAlignment = Enum.TextXAlignment.Center;
        ZIndex = 13;
        Parent = PreviewHolder;
    });

    Library:CreateLabel({
        Position = UDim2.new(0.5, 0, 0.02, 0);
        Size = UDim2.new(0.5, 0, 0, 14);
        Text = 'dummy';
        TextColor3 = Color3.fromRGB(180, 120, 255);
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Center;
        ZIndex = 13;
        Parent = PreviewHolder;
    });

    Library:CreateLabel({
        Position = UDim2.new(0.72, 0, 0.4, 0);
        Size = UDim2.new(0.26, 0, 0, 14);
        Text = 'standing';
        TextColor3 = Color3.fromRGB(80, 220, 255);
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 13;
        Parent = PreviewHolder;
    });

    Library:CreateLabel({
        Position = UDim2.new(0.3, 0, 0.9, 0);
        Size = UDim2.new(0.2, 0, 0, 14);
        Text = '12st';
        TextColor3 = Color3.fromRGB(255, 80, 80);
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 13;
        Parent = PreviewHolder;
    });

    Library:CreateLabel({
        Position = UDim2.new(0.52, 0, 0.9, 0);
        Size = UDim2.new(0.3, 0, 0, 14);
        Text = 'preview';
        TextColor3 = Color3.fromRGB(80, 220, 120);
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 13;
        Parent = PreviewHolder;
    });

    Overlay.Viewport = Viewport;
    Overlay.Box = Box;
    Groupbox:Resize();
    return Overlay;
end;

function Library:CreateClosestPlayerOverlay(Config)
    Config = Config or {};
    local Overlay = Library:CreateOverlayWindow({
        Title = 'Closest Player';
        AccentPart = 'Player';
        Size = UDim2.fromOffset(196, 56);
        Position = Config.Position or UDim2.fromOffset(40, 580);
        Visible = Config.Visible;
        ZIndex = Config.ZIndex or 165;
    });

    local Z = Overlay.ZIndexBase + 5;
    local AvatarSize = 48;
    local ColumnGap = 6;
    local NameHeight = 14;
    local DistanceHeight = 13;
    local HealthTextHeight = 12;
    local HealthBarHeight = 8;
    local RowGap = 2;
    local HealthBlockHeight = HealthTextHeight + RowGap + HealthBarHeight;
    local InfoHeight = NameHeight + RowGap + DistanceHeight + RowGap + HealthBlockHeight;
    local PanelHeight = math.max(AvatarSize, InfoHeight);

    local Panel = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 0, PanelHeight);
        ZIndex = Z;
        Parent = Overlay.Container;
    });

    local Avatar = Library:Create('ImageLabel', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, math.floor((PanelHeight - AvatarSize) / 2));
        Size = UDim2.fromOffset(AvatarSize, AvatarSize);
        ZIndex = Z + 1;
        Parent = Panel;
    });

    Library:AddToRegistry(Avatar, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    local InfoColumn = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, AvatarSize + ColumnGap, 0, 0);
        Size = UDim2.new(1, -(AvatarSize + ColumnGap), 0, InfoHeight);
        ZIndex = Z + 1;
        Parent = Panel;
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, RowGap);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = InfoColumn;
    });

    local NameLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, NameHeight);
        LayoutOrder = 1;
        Text = 'None';
        TextSize = 13;
        TextTruncate = Enum.TextTruncate.AtEnd;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
        ZIndex = Z + 2;
        Parent = InfoColumn;
    });

    local DistanceLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, DistanceHeight);
        LayoutOrder = 2;
        Text = '—st';
        TextSize = 12;
        TextTransparency = 0.15;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
        ZIndex = Z + 2;
        Parent = InfoColumn;
    });

    Library:AddToRegistry(DistanceLabel, {
        TextColor3 = 'AccentColor';
    }, true);

    local HealthBlock = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 0, HealthBlockHeight);
        LayoutOrder = 3;
        ZIndex = Z + 2;
        Parent = InfoColumn;
    });

    local HealthLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, HealthTextHeight);
        Text = '0';
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Right;
        TextYAlignment = Enum.TextYAlignment.Center;
        ZIndex = Z + 3;
        Parent = HealthBlock;
    });

    local HealthBarOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 1, -HealthBarHeight);
        Size = UDim2.new(1, 0, 0, HealthBarHeight);
        ClipsDescendants = true;
        ZIndex = Z + 3;
        Parent = HealthBlock;
    });

    Library:AddToRegistry(HealthBarOuter, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    local HealthBarFill = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(0, 0, 1, 0);
        ZIndex = Z + 4;
        Parent = HealthBarOuter;
    });

    Library:AddToRegistry(HealthBarFill, {
        BackgroundColor3 = 'AccentColor';
    });

    local trackedThumbId;
    local healthTween;
    local refreshAccum = 0;

    local function FitOverlay()
        local nameWidth = select(1, Library:GetTextBounds(NameLabel.Text, Library.Font, 13));
        local width = math.ceil(nameWidth + AvatarSize + ColumnGap + 24);
        width = math.clamp(width, 180, 280);

        Panel.Size = UDim2.new(1, -4, 0, PanelHeight);
        Overlay.Container.Size = UDim2.new(1, -8, 0, PanelHeight);
        Overlay.Container.CanvasSize = UDim2.fromOffset(0, PanelHeight);

        if Overlay.ContentOuter then
            Overlay.ContentOuter.Size = UDim2.new(1, -12, 0, PanelHeight + 8);
        end;

        Overlay.Outer.Size = UDim2.fromOffset(width, 26 + PanelHeight + 8 + 6);
    end;

    function Overlay:Resize()
        FitOverlay();
    end;

    local function SetHealth(ratio, healthValue)
        ratio = math.clamp(ratio, 0, 1);
        HealthLabel.Text = tostring(math.floor(healthValue + 0.5));

        if healthTween then
            healthTween:Cancel();
        end;

        healthTween = TweenService:Create(HealthBarFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(ratio, 0, 1, 0);
        });
        healthTween:Play();
    end;

    local function ClearTarget()
        trackedThumbId = nil;
        Avatar.Image = '';
        NameLabel.Text = 'None';
        DistanceLabel.Text = '—st';
        SetHealth(0, 0);
        FitOverlay();
    end;

    local function UpdateAvatar(player)
        if not player or trackedThumbId == player.UserId then
            return
        end;

        trackedThumbId = player.UserId;
        local userId = player.UserId;

        task.spawn(function()
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48);
            end);

            if trackedThumbId == userId then
                Avatar.Image = ok and thumb or '';
            end;
        end);
    end;

    local function GetClosestPlayer()
        local localChar = LocalPlayer.Character;
        local localRoot = localChar and localChar:FindFirstChild('HumanoidRootPart');
        if not localRoot then
            return nil;
        end;

        local closestPlayer;
        local closestDistance = math.huge;

        for _, player in Players:GetPlayers() do
            if player ~= LocalPlayer then
                local character = player.Character;
                local root = character and character:FindFirstChild('HumanoidRootPart');
                if root then
                    local distance = (root.Position - localRoot.Position).Magnitude;
                    if distance < closestDistance then
                        closestDistance = distance;
                        closestPlayer = player;
                    end;
                end;
            end;
        end;

        return closestPlayer, closestDistance;
    end;

    function Overlay:Refresh()
        if not Overlay.Visible or not Overlay.Outer or not Overlay.Outer.Visible then
            return
        end;

        local player, distance = GetClosestPlayer();
        if not player then
            ClearTarget();
            return
        end;

        NameLabel.Text = player.DisplayName;
        DistanceLabel.Text = string.format('%dst', math.floor(distance + 0.5));
        UpdateAvatar(player);

        local humanoid = player.Character and player.Character:FindFirstChildOfClass('Humanoid');
        if humanoid and humanoid.MaxHealth > 0 then
            SetHealth(humanoid.Health / humanoid.MaxHealth, humanoid.Health);
        else
            SetHealth(0, 0);
        end;

        FitOverlay();
    end;

    Library:GiveSignal(RunService.Heartbeat:Connect(function(Delta)
        if not Overlay.Visible or not Overlay.Outer or not Overlay.Outer.Visible then
            return
        end;

        refreshAccum += Delta;
        if refreshAccum < 0.1 then
            return
        end;

        refreshAccum = 0;
        Overlay:Refresh();
    end));

    Library.ClosestPlayerOverlay = Overlay;

    task.defer(function()
        Overlay:Refresh();
        FitOverlay();
    end);

    return Overlay;
end;

function Library:CreateKeybindsOverlay(Config)
    Config = Config or {};
    local Overlay = Library:CreateOverlayWindow({
        Title = 'Keybinds';
        Size = UDim2.fromOffset(196, 86);
        Position = Config.Position or UDim2.fromOffset(40, 490);
        Visible = Config.Visible;
        ZIndex = Config.ZIndex or 170;
    });

    if Library.KeybindContainer then
        if Overlay.Container then
            Overlay.Container.Visible = false;
        end;

        Library.KeybindContainer.Parent = Overlay.ContentInner or Overlay.Inner;
        Library.KeybindContainer.Visible = true;
        Library.KeybindContainer.Position = UDim2.new(0, 6, 0, 4);
        Library.KeybindContainer.Size = UDim2.new(1, -12, 0, 0);
        Library.KeybindContainer.ZIndex = Overlay.Outer.ZIndex + 12;
        Library:SyncKeybindRowsZIndex();

        for _, option in Options do
            if type(option) == 'table' and option.Type == 'KeyPicker' and option.Update then
                option:Update();
            end;
        end;
    end;

    function Overlay:SetVisible(Bool)
        Overlay.Visible = not not Bool;
        Overlay.Outer.Visible = Overlay.Visible;
        Library:UpdateOverlayGlow(Overlay);
    end;

    Library.KeybindOverlay = Overlay;
    Library.KeybindTitleLabel = Overlay.TitleLabel;

    function Overlay:Resize()
        if Library.KeybindOverlayCompact or Library._UpdatingKeybindOverlaySize then
            return
        end;

        Library:UpdateKeybindOverlaySize();
    end;

    task.defer(function()
        Library:UpdateKeybindOverlaySize();
    end);
    return Overlay;
end;

function Library:CreateRadarOverlay(Config)
    Config = Config or {};

    local MapSize = Config.MapSize or 176;
    local Range = Config.Range or 120;
    local SampleGrid = Config.SampleGrid or (IsTouchDevice and 28 or 44);
    local FramePad = Config.FramePad or 12;
    local BlipPixel = Config.BlipPixel or 3;
    local ContentSize = MapSize + FramePad * 2;
    local OuterWidth = ContentSize + 12;
    local OuterHeight = 26 + ContentSize + 8;

    local Overlay = Library:CreateOverlayWindow({
        Title = 'Radar';
        AccentPart = 'ar';
        Size = UDim2.fromOffset(OuterWidth, OuterHeight);
        Position = Config.Position or UDim2.fromOffset(40, 40);
        Visible = Config.Visible;
        ZIndex = Config.ZIndex or 160;
    });

    local ListLayout = Overlay.Container:FindFirstChildOfClass('UIListLayout');
    if ListLayout then
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
        ListLayout.Padding = UDim.new(0, 0);
    end;

    Overlay.Container.ScrollBarThickness = 0;
    Overlay.Container.ScrollingEnabled = false;
    Overlay.Container.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right;

    local Z = Overlay.ZIndexBase + 15;

    local Panel = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.fromOffset(ContentSize, ContentSize);
        ZIndex = Z;
        Parent = Overlay.Container;
    });

    local MapOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.fromOffset(MapSize, MapSize);
        ClipsDescendants = true;
        ZIndex = Z + 1;
        Parent = Panel;
    });

    Library:AddToRegistry(MapOuter, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    local MapCanvas = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundColor3 = Color3.fromRGB(10, 10, 12);
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.new(1, -4, 1, -4);
        ZIndex = Z + 2;
        Parent = MapOuter;
    });

    local MapImage = Library:Create('ImageLabel', {
        BackgroundColor3 = Color3.fromRGB(10, 10, 12);
        BorderSizePixel = 0;
        Size = UDim2.fromScale(1, 1);
        ZIndex = Z + 2;
        Parent = MapCanvas;
    });

    local PixelGrid = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.fromScale(1, 1);
        ZIndex = Z + 2;
        Visible = false;
        Parent = MapCanvas;
    });

    local PixelFrames = table.create(SampleGrid * SampleGrid);

    local function LayoutPixelGrid()
        local CanvasX = math.max(MapCanvas.AbsoluteSize.X, MapSize - 4);
        local CanvasY = math.max(MapCanvas.AbsoluteSize.Y, MapSize - 4);
        local PixelW = CanvasX / SampleGrid;
        local PixelH = CanvasY / SampleGrid;

        for row = 0, SampleGrid - 1 do
            for col = 0, SampleGrid - 1 do
                local Index = row * SampleGrid + col + 1;
                local Pixel = PixelFrames[Index];
                if Pixel then
                    Pixel.Position = UDim2.fromOffset(col * PixelW, row * PixelH);
                    Pixel.Size = UDim2.fromOffset(PixelW, PixelH);
                end;
            end;
        end;
    end;

    for row = 0, SampleGrid - 1 do
        for col = 0, SampleGrid - 1 do
            local Pixel = Library:Create('Frame', {
                BackgroundColor3 = Color3.fromRGB(10, 10, 12);
                BorderSizePixel = 0;
                ZIndex = Z + 2;
                Parent = PixelGrid;
            });
            table.insert(PixelFrames, Pixel);
        end;
    end;

    local CrosshairH = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundColor3 = Library.OutlineColor;
        BackgroundTransparency = 0.65;
        BorderSizePixel = 0;
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.new(1, 0, 0, 1);
        ZIndex = Z + 3;
        Parent = MapCanvas;
    });

    local CrosshairV = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundColor3 = Library.OutlineColor;
        BackgroundTransparency = 0.65;
        BorderSizePixel = 0;
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.new(0, 1, 1, 0);
        ZIndex = Z + 3;
        Parent = MapCanvas;
    });

    Library:AddToRegistry(CrosshairH, { BackgroundColor3 = 'OutlineColor' });
    Library:AddToRegistry(CrosshairV, { BackgroundColor3 = 'OutlineColor' });

    local BlipContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.fromScale(1, 1);
        ZIndex = Z + 5;
        Parent = MapCanvas;
    });

    local MaxBlips = Config.MaxBlips or 32;
    local BlipPool = table.create(MaxBlips);
    local EnemyColor = Color3.fromRGB(255, 48, 48);

    for Index = 1, MaxBlips do
        BlipPool[Index] = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundColor3 = EnemyColor;
            BorderSizePixel = 0;
            Position = UDim2.fromScale(0.5, 0.5);
            Size = UDim2.fromOffset(BlipPixel, BlipPixel);
            Visible = false;
            ZIndex = Z + 6;
            Parent = BlipContainer;
        });
        Library:Create('UICorner', {
            CornerRadius = UDim.new(1, 0);
            Parent = BlipPool[Index];
        });
    end;

    local ArrowHolder = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.fromOffset(16, 16);
        ZIndex = Z + 7;
        Parent = MapCanvas;
    });

    local Arrow = Library:CreateLabel({
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.fromOffset(16, 16);
        Text = '▲';
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Center;
        TextYAlignment = Enum.TextYAlignment.Center;
        ZIndex = Z + 8;
        Parent = ArrowHolder;
    }, true);

    Library:AddToRegistry(Arrow, {
        TextColor3 = 'AccentColor';
    }, true);

    local CenterDot = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.fromScale(0.5, 0.5);
        Size = UDim2.fromOffset(3, 3);
        ZIndex = Z + 8;
        Parent = MapCanvas;
    });

    Library:AddToRegistry(CenterDot, {
        BackgroundColor3 = 'AccentColor';
    });

    local RayParams = RaycastParams.new();
    RayParams.FilterType = Enum.RaycastFilterType.Exclude;

    local EditableImage;
    local UseEditableImage = false;

    pcall(function()
        local AssetService = game:GetService('AssetService');
        EditableImage = AssetService:CreateEditableImage(Vector2.new(SampleGrid, SampleGrid));
        MapImage.Image = EditableImage;
        UseEditableImage = true;
        PixelGrid.Visible = false;
    end);

    if not UseEditableImage then
        pcall(function()
            EditableImage = Instance.new('EditableImage');
            EditableImage.Size = Vector2.new(SampleGrid, SampleGrid);
            MapImage.Image = EditableImage;
            UseEditableImage = true;
            PixelGrid.Visible = false;
        end);
    end;

    if not UseEditableImage then
        PixelGrid.Visible = true;
        MapImage.Visible = false;
        task.defer(LayoutPixelGrid);
    end;

    local function GetRaycastFilter()
        local Filter = {};

        for _, Player in Players:GetPlayers() do
            if Player.Character then
                table.insert(Filter, Player.Character);
            end;
        end;

        return Filter;
    end;

    local function GetHitColor(Result)
        if not Result then
            return Color3.fromRGB(10, 10, 12);
        end;

        if Result.Instance == workspace.Terrain then
            return workspace.Terrain:GetMaterialColor(Result.Material);
        end;

        local Part = Result.Instance;
        if Part:IsA('BasePart') then
            return Part.Color;
        end;

        return Color3.fromRGB(10, 10, 12);
    end;

    local function IsEnemyPlayer(Player)
        if Player == LocalPlayer then
            return false;
        end;

        if Library.EnemyPlayers and Library.EnemyPlayers[Player] then
            return true;
        end;

        if type(Config.IsEnemy) == 'function' then
            return not not Config.IsEnemy(Player);
        end;

        local MyTeam = LocalPlayer.Team;
        local TheirTeam = Player.Team;
        if MyTeam and TheirTeam then
            return MyTeam ~= TheirTeam;
        end;

        return true;
    end;

    local function WorldToRadarNorm(Origin, WorldPos)
        local Offset = WorldPos - Origin;
        local NormX = Offset.X / Range;
        local NormZ = Offset.Z / Range;
        local DistSq = NormX * NormX + NormZ * NormZ;

        if DistSq > 1 then
            local Dist = math.sqrt(DistSq);
            NormX /= Dist;
            NormZ /= Dist;
        end;

        return NormX, NormZ;
    end;

    local function FitOverlay()
        Panel.Size = UDim2.fromOffset(ContentSize, ContentSize);
        Overlay.Container.Size = UDim2.new(1, -8, 0, ContentSize);
        Overlay.Container.CanvasSize = UDim2.fromOffset(0, ContentSize);

        if Overlay.ContentOuter then
            Overlay.ContentOuter.Size = UDim2.new(1, -12, 0, ContentSize + 8);
        end;

        Overlay.Outer.Size = UDim2.fromOffset(OuterWidth, OuterHeight);
        LayoutPixelGrid();
    end;

    function Overlay:Resize()
        FitOverlay();
    end;

    local terrainAccum = 0;
    local terrainInterval = 1;

    local function UpdateTerrain()
        local Character = LocalPlayer.Character;
        local Root = Character and Character:FindFirstChild('HumanoidRootPart');
        if not Root then
            return
        end;

        RayParams.FilterDescendantsInstances = GetRaycastFilter();

        local Origin = Root.Position;
        local HalfGrid = SampleGrid / 2;
        local Step = (Range * 2) / SampleGrid;

        for row = 0, SampleGrid - 1 do
            for col = 0, SampleGrid - 1 do
                local OffsetX = (col - HalfGrid + 0.5) * Step;
                local OffsetZ = (row - HalfGrid + 0.5) * Step;
                local SamplePos = Origin + Vector3.new(OffsetX, 0, OffsetZ);
                local RayOrigin = SamplePos + Vector3.new(0, 512, 0);
                local Result = workspace:Raycast(RayOrigin, Vector3.new(0, -1024, 0), RayParams);
                local Color = GetHitColor(Result);

                if UseEditableImage and EditableImage then
                    pcall(function()
                        EditableImage:SetRGB(col, row, Color);
                    end);
                else
                    local Pixel = PixelFrames[row * SampleGrid + col + 1];
                    if Pixel then
                        Pixel.BackgroundColor3 = Color;
                    end;
                end;
            end;
        end;
    end;

    local UpdateBlips = function(Root, Camera)
        local Origin = Root.Position;
        local BlipIndex = 0;

        for _, Player in Players:GetPlayers() do
            if Player ~= LocalPlayer and IsEnemyPlayer(Player) then
                local Character = Player.Character;
                local OtherRoot = Character and Character:FindFirstChild('HumanoidRootPart');
                if OtherRoot then
                    BlipIndex += 1;
                    local Blip = BlipPool[BlipIndex];
                    if Blip then
                        local NormX, NormZ = WorldToRadarNorm(Origin, OtherRoot.Position);

                        Blip.BackgroundColor3 = EnemyColor;
                        Blip.Size = UDim2.fromOffset(BlipPixel, BlipPixel);
                        Blip.Position = UDim2.fromScale(NormX * 0.5 + 0.5, NormZ * 0.5 + 0.5);
                        Blip.Visible = true;
                    end;
                end;
            end;
        end;

        for Index = BlipIndex + 1, MaxBlips do
            local Blip = BlipPool[Index];
            if Blip then
                Blip.Visible = false;
            end;
        end;

        local Look = Camera.CFrame.LookVector;
        ArrowHolder.Rotation = math.deg(math.atan2(Look.X, -Look.Z));
    end);

    local UpdateRadar = function(Delta)
        if not Overlay.Visible then
            return
        end;

        local Character = LocalPlayer.Character;
        local Root = Character and Character:FindFirstChild('HumanoidRootPart');
        local Camera = workspace.CurrentCamera;
        if not Root or not Camera then
            for Index = 1, MaxBlips do
                BlipPool[Index].Visible = false;
            end;
            return
        end;

        terrainAccum += Delta;
        if terrainAccum >= terrainInterval then
            terrainAccum = 0;
            UpdateTerrain();
        end;

        UpdateBlips(Root, Camera);
    end);

    function Overlay:SetVisible(Bool)
        Overlay.Visible = not not Bool;
        Overlay.Outer.Visible = Overlay.Visible;
        Library:UpdateOverlayGlow(Overlay);
    end;

    Overlay._RadarUpdate = RunService.RenderStepped:Connect(UpdateRadar);
    Library:GiveSignal(Overlay._RadarUpdate);

    Library.RadarOverlay = Overlay;

    task.defer(function()
        FitOverlay();
        UpdateTerrain();
    end);

    return Overlay;
end;

function Library:CreateVelocityGraphOverlay(Config)
    Config = Config or {};

    local BoxWidth = Config.Width or 200;
    local BoxHeight = Config.Height or 80;
    local LabelHeight = 16;
    local LabelGap = 4;
    local ContentHeight = LabelHeight + LabelGap + BoxHeight;
    local OuterWidth = BoxWidth + 24;
    local OuterHeight = 26 + ContentHeight + 14;

    local Overlay = Library:CreateOverlayWindow({
        Title = 'Velocity';
        AccentPart = 'ity';
        Size = UDim2.fromOffset(OuterWidth, OuterHeight);
        Position = Config.Position or UDim2.new(0.5, -OuterWidth / 2, 1, -240);
        Visible = Config.Visible;
        ZIndex = Config.ZIndex or 155;
    });

    local Z = Overlay.ZIndexBase + 15;

    local Content = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 0, ContentHeight);
        ZIndex = Z;
        Parent = Overlay.Container;
    });

    local SpeedLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, LabelHeight);
        Text = 'SPEED: 0';
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Center;
        ZIndex = Z + 2;
        Parent = Content;
    });

    local GraphArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Position = UDim2.new(0, 0, 0, LabelHeight + LabelGap);
        Size = UDim2.new(1, 0, 0, BoxHeight);
        ZIndex = Z + 1;
        Parent = Content;
    });

    local GraphState = {
        Lines = {};
        LastY = BoxHeight - 2;
        LinePool = {};
        MaxLines = BoxWidth;
    };

    for Index = 1, GraphState.MaxLines do
        GraphState.LinePool[Index] = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundColor3 = Color3.fromRGB(220, 220, 220);
            BorderSizePixel = 0;
            Visible = false;
            ZIndex = Z + 3;
            Parent = GraphArea;
        });
    end;

    local function FitOverlay()
        Content.Size = UDim2.new(1, -4, 0, ContentHeight);
        Overlay.Container.Size = UDim2.new(1, -8, 0, ContentHeight);
        Overlay.Container.CanvasSize = UDim2.fromOffset(0, ContentHeight);

        if Overlay.ContentOuter then
            Overlay.ContentOuter.Size = UDim2.new(1, -12, 0, ContentHeight + 8);
        end;

        Overlay.Outer.Size = UDim2.fromOffset(OuterWidth, OuterHeight);
    end;

    function Overlay:Resize()
        FitOverlay();
    end;

    local function SetGraphVisible(Visible)
        for _, Segment in GraphState.LinePool do
            Segment.Visible = Visible;
        end;
    end;

    local function PlaceSegment(Segment, XFrom, YFrom, XTo, YTo, Transparency)
        local DeltaX = XTo - XFrom;
        local DeltaY = YTo - YFrom;
        local Length = math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY);

        if Length < 0.35 then
            Segment.Visible = false;
            return
        end;

        local Angle = math.deg(math.atan2(DeltaY, DeltaX));
        local MidY = (YFrom + YTo) * 0.5;

        Segment.Size = UDim2.fromOffset(Length, 1.2);
        Segment.Position = UDim2.fromOffset(XFrom, MidY);
        Segment.Rotation = Angle;
        Segment.BackgroundTransparency = Transparency;
        Segment.Visible = true;
    end;

    local UpdateGraph = function()
        if not Overlay.Visible or not Overlay.Outer or not Overlay.Outer.Visible then
            SetGraphVisible(false);
            return
        end;

        local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart');
        if not Root then
            SetGraphVisible(false);
            return
        end;

        local GraphWidth = math.max(math.floor(GraphArea.AbsoluteSize.X + 0.5), BoxWidth);
        local GraphBaseY = BoxHeight;

        local Velocity = Root.AssemblyLinearVelocity;
        local Vel = (Vector3.new(Velocity.X * 1.25, 0, Velocity.Z * 1.25)).Magnitude * 14;

        local Unit = GraphBaseY - (Vel / 7.5);
        Unit = math.clamp(Unit, 2, GraphBaseY - 2);

        SpeedLabel.Text = string.format('SPEED: %d', math.floor(Vel));

        if #GraphState.Lines >= GraphWidth then
            table.remove(GraphState.Lines, 1);
        end;

        for _, Line in GraphState.Lines do
            Line.XFrom -= 1;
            Line.XTo -= 1;
        end;

        table.insert(GraphState.Lines, {
            XFrom = GraphWidth - 1;
            YFrom = GraphState.LastY;
            XTo = GraphWidth;
            YTo = Unit;
        });

        GraphState.LastY = Unit;

        local Count = #GraphState.Lines;
        for Index, Line in GraphState.Lines do
            local AgeFromRight = Count - Index;
            local Transparency = math.clamp(AgeFromRight / 50, 0, 1) * 0.55;
            PlaceSegment(GraphState.LinePool[Index], Line.XFrom, Line.YFrom, Line.XTo, Line.YTo, Transparency);
        end;

        for Index = Count + 1, GraphState.MaxLines do
            local Segment = GraphState.LinePool[Index];
            if Segment then
                Segment.Visible = false;
            end;
        end;
    end);

    function Overlay:SetVisible(Bool)
        Overlay.Visible = not not Bool;
        Overlay.Outer.Visible = Overlay.Visible;
        Library:UpdateOverlayGlow(Overlay);

        if not Overlay.Visible then
            SetGraphVisible(false);
        end;
    end;

    function Overlay:CleanupDrawings()
        SetGraphVisible(false);
        table.clear(GraphState.Lines);
        GraphState.LastY = BoxHeight - 2;
    end;

    Overlay._GraphUpdate = RunService.RenderStepped:Connect(UpdateGraph);
    Library:GiveSignal(Overlay._GraphUpdate);

    Library.VelocityGraphOverlay = Overlay;

    task.defer(function()
        FitOverlay();
    end);

    return Overlay;
end;

function Library:WrapKeybindOverlay(Config)
    return Library:CreateKeybindsOverlay(Config or {});
end;

function Library:GiveSignal(Signal)
    table.insert(Library.Signals, Signal);
end;

function Library:Unload()
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx);
        Connection:Disconnect();
    end;

    if Library.OnUnload then
        Library.OnUnload();
    end;

    if Library.VelocityGraphOverlay and Library.VelocityGraphOverlay.CleanupDrawings then
        Library.VelocityGraphOverlay:CleanupDrawings();
    end;

    ScreenGui:Destroy();
end;

function Library:OnUnload(Callback)
    Library.OnUnload = Callback;
end;

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance);
    end;
end));

local BaseAddons = {};

do
    local Funcs = {};

    function Funcs:AddColorPicker(Idx, Info)
        local ToggleLabel = self.TextLabel;

        assert(Info.Default, 'AddColorPicker: Missing default value.');

        local ColorPicker = {
            Value = Info.Default;
            Transparency = Info.Transparency or 0;
            Type = 'ColorPicker';
            Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end;
        };

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color3.toHSV(Color);

            ColorPicker.Hue = H;
            ColorPicker.Sat = S;
            ColorPicker.Vib = V;
        end;

        ColorPicker:SetHSVFromRGB(ColorPicker.Value);

        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = Library.AccentColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = IsTouchDevice and UDim2.new(0, 18, 0, 10) or UDim2.new(0, 28, 0, 14);
            ZIndex = ToggleLabel.ZIndex + 1;
            Parent = ToggleLabel;
        });

        Library:AddToRegistry(DisplayFrame, { BorderColor3 = 'AccentColor' });

        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color';
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
            Size = UDim2.fromOffset(230, 226);
            Visible = false;
            ZIndex = 15;
            Parent = ScreenGui,
        });

        Library:MakeDraggable(PickerFrameOuter, 20);

        if IsTouchDevice then
            Library:Create('UIScale', {
                Scale = Library.MobilePickerScale or Library.MobileOverlayScale or 0.55;
                Parent = PickerFrameOuter;
            });
        end;

        local PickerFrameInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });

        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local TitleLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 20);
            Position = UDim2.new(0, 5, 0, 2);
            TextXAlignment = Enum.TextXAlignment.Left;
            Text = ColorPicker.Title;
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local FlagLabel = Library:CreateLabel({
            Size = UDim2.new(1, -10, 0, 20);
            Position = UDim2.new(0, 5, 0, 2);
            TextXAlignment = Enum.TextXAlignment.Right;
            Text = "flagname";
            TextColor3 = Color3.fromRGB(80, 80, 80);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local Divider = Library:Create('Frame', {
            BackgroundColor3 = Library.OutlineColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 1);
            Position = UDim2.new(0, 0, 0, 22);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local SatVibMapOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 25);
            Size = UDim2.new(1, -8, 0, 110);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local SatVibMapInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = SatVibMapOuter;
        });

        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapInner;
        });

        local CursorOuter = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.new(0, 6, 0, 6);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ImageColor3 = Color3.new(0, 0, 0);
            ZIndex = 19;
            Parent = SatVibMap;
        });

        local CursorInner = Library:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
            Position = UDim2.new(0, 1, 0, 1);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ZIndex = 20;
            Parent = CursorOuter;
        });

        local HueSelectorOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 140);
            Size = UDim2.new(1, -8, 0, 10);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local HueSelectorInner = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = HueSelectorOuter;
        });

        local HueCursor = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0.5, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 2, 1, 0);
            ZIndex = 18;
            Parent = HueSelectorInner;
        });

        local InputWidth = 47;
        local InputHeight = 18;
        local InputSpacing = 4;

        local function CreateInputBox(posX, width, placeholder)
            local BoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.new(0, posX, 0, 155);
                Size = UDim2.new(0, width, 0, InputHeight);
                ZIndex = 18;
                Parent = PickerFrameInner;
            });
            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 18;
                Parent = BoxOuter;
            });
            local TextBox = Library:Create('TextBox', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Font = Library.Font;
                PlaceholderColor3 = Color3.fromRGB(120, 120, 120);
                PlaceholderText = placeholder;
                Text = "";
                TextColor3 = Library.FontColor;
                TextSize = 13;
                TextStrokeTransparency = 0;
                TextXAlignment = Enum.TextXAlignment.Center;
                ZIndex = 20;
                Parent = BoxInner;
            });
            Library:ApplyTextStroke(TextBox);
            Library:AddToRegistry(BoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
            Library:AddToRegistry(TextBox, { TextColor3 = 'FontColor' });
            return TextBox;
        end;

        local RBox = CreateInputBox(4, 48, "R");
        local GBox = CreateInputBox(4 + 48 + 4, 48, "G");
        local BBox = CreateInputBox(4 + 48*2 + 8, 48, "B");
        local HexBox = CreateInputBox(4 + 48*3 + 12, 66, "HEX");

        local function CreateButton(posX, width, text)
            local BtnOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.new(0, posX, 0, 177);
                Size = UDim2.new(0, width, 0, 18);
                ZIndex = 18;
                Parent = PickerFrameInner;
            });
            local BtnInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 18;
                Parent = BtnOuter;
            });
            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 13;
                Text = text;
                ZIndex = 20;
                Parent = BtnInner;
            });
            Library:OnHighlight(BtnOuter, BtnOuter,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );
            Library:AddToRegistry(BtnInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
            return BtnOuter;
        end;

        local CopyBtn = CreateButton(4, 109, "Copy");
        local PasteBtn = CreateButton(4 + 109 + 4, 109, "Paste");

        local ConfirmBtnOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 199);
            Size = UDim2.new(1, -8, 0, 18);
            ZIndex = 18;
            Parent = PickerFrameInner;
        });
        local ConfirmBtnInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = ConfirmBtnOuter;
        });
        local ConfirmLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13;
            Text = "Confirm";
            ZIndex = 20;
            Parent = ConfirmBtnInner;
        });
        Library:OnHighlight(ConfirmBtnOuter, ConfirmBtnOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );
        ConfirmBtnOuter.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) then
                ColorPicker:Hide();
            end;
        end);
        Library:AddToRegistry(ConfirmBtnInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });

        local ContextMenu = {}
        do
            ContextMenu.Options = {};
            ContextMenu.Container = Library:Create('Frame', {
                BorderColor3 = Color3.new(),
                ZIndex = 14,
                Visible = false,
                Parent = ScreenGui
            });

            ContextMenu.Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            });

            Library:Create('UIListLayout', {
                Name = 'Layout',
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            });

            Library:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            });

            local function updateMenuPosition()
                ContextMenu.Container.Position = UDim2.fromOffset(
                    (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
                    DisplayFrame.AbsolutePosition.Y + 1
                );
            end;

            local function updateMenuSize()
                local menuWidth = 60;
                for i, label in next, ContextMenu.Inner:GetChildren() do
                    if label:IsA('TextLabel') then
                        menuWidth = math.max(menuWidth, label.TextBounds.X);
                    end;
                end;

                ContextMenu.Container.Size = UDim2.fromOffset(
                    menuWidth + 8,
                    ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
                );
            end;

            DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition);
            ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize);

            task.spawn(updateMenuPosition);
            task.spawn(updateMenuSize);

            Library:AddToRegistry(ContextMenu.Inner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            function ContextMenu:Show()
                self.Container.Visible = true;
            end;

            function ContextMenu:Hide()
                self.Container.Visible = false;
            end;

            function ContextMenu:AddOption(Str, Callback)
                if type(Callback) ~= 'function' then
                    Callback = function() end;
                end;

                local Button = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = 13;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    TextXAlignment = Enum.TextXAlignment.Left,
                });

                Library:OnHighlight(Button, Button,
                    { TextColor3 = 'AccentColor' },
                    { TextColor3 = 'FontColor' }
                );

                Button.InputBegan:Connect(function(Input)
                    if not IsPrimaryPress(Input) then
                        return
                    end;

                    Callback();
                end);
            end;

            ContextMenu:AddOption('Copy color', function()
                Library.ColorClipboard = ColorPicker.Value;
                Library:Notify('Copied color!', 2);
            end);

            ContextMenu:AddOption('Paste color', function()
                if not Library.ColorClipboard then
                    return Library:Notify('You have not copied a color!', 2);
                end;
                ColorPicker:SetValueRGB(Library.ColorClipboard);
            end);

            ContextMenu:AddOption('Copy HEX', function()
                pcall(setclipboard, ColorPicker.Value:ToHex());
                Library:Notify('Copied hex code to clipboard!', 2);
            end);

            ContextMenu:AddOption('Copy RGB', function()
                pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '));
                Library:Notify('Copied RGB values to clipboard!', 2);
            end);

        end;

        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
        Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });

        local SequenceTable = {};

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;

        local HueSelectorGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 0;
            Parent = HueSelectorInner;
        });

        local function onRGBFocusLost()
            local r = tonumber(RBox.Text) or 255;
            local g = tonumber(GBox.Text) or 255;
            local b = tonumber(BBox.Text) or 255;
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b));
            ColorPicker:Display();
        end;
        RBox.FocusLost:Connect(onRGBFocusLost);
        GBox.FocusLost:Connect(onRGBFocusLost);
        BBox.FocusLost:Connect(onRGBFocusLost);

        HexBox.FocusLost:Connect(function()
            local success, result = pcall(Color3.fromHex, HexBox.Text);
            if success and typeof(result) == 'Color3' then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result);
            end;
            ColorPicker:Display();
        end);

        CopyBtn.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) then
                Library.ColorClipboard = ColorPicker.Value;
                Library:Notify('Copied color!', 2);
            end;
        end);

        PasteBtn.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) then
                if Library.ColorClipboard then
                    ColorPicker:SetValueRGB(Library.ColorClipboard);
                else
                    Library:Notify('No color copied!', 2);
                end;
            end;
        end);

        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            Library:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value;
                BackgroundTransparency = ColorPicker.Transparency;
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            });

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(ColorPicker.Hue, 0, 0, 0);

            RBox.Text = tostring(math.floor(ColorPicker.Value.R * 255));
            GBox.Text = tostring(math.floor(ColorPicker.Value.G * 255));
            BBox.Text = tostring(math.floor(ColorPicker.Value.B * 255));
            HexBox.Text = ColorPicker.Value:ToHex();

            if not Library.ThemeUpdating then
                Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
                Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
            end;
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Func(ColorPicker.Value);
        end;

        function ColorPicker:Show()
            for Frame, Val in next, Library.OpenedFrames do
                if Frame.Name == 'Color' then
                    Frame.Visible = false;
                    Library.OpenedFrames[Frame] = nil;
                end;
            end;

            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
            Library:ApplyPopupZIndex(PickerFrameOuter, 15);
            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;
        end;

        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false;
            Library.OpenedFrames[PickerFrameOuter] = nil;
        end;

        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        SatVibMap.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) then
                while IsPressActive(Input) do
                    local Pos = GetPointerPosition(Input);
                    local MinX = SatVibMap.AbsolutePosition.X;
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                    local MouseX = math.clamp(Pos.X, MinX, MaxX);

                    local MinY = SatVibMap.AbsolutePosition.Y;
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                    local MouseY = math.clamp(Pos.Y, MinY, MaxY);

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        HueSelectorInner.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) then
                while IsPressActive(Input) do
                    local Pos = GetPointerPosition(Input);
                    local MinX = HueSelectorInner.AbsolutePosition.X;
                    local MaxX = MinX + HueSelectorInner.AbsoluteSize.X;
                    local MouseX = math.clamp(Pos.X, MinX, MaxX);

                    ColorPicker.Hue = ((MouseX - MinX) / (MaxX - MinX));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        DisplayFrame.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) and not Library:MouseIsOverOpenedFrame() then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide();
                else
                    ContextMenu:Hide();
                    ColorPicker:Show();
                end;
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ContextMenu:Show();
                ColorPicker:Hide();
            end;
        end);

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) then
                local Pos = GetPointerPosition(Input);
                local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;

                if Pos.X < AbsPos.X or Pos.X > AbsPos.X + AbsSize.X
                    or Pos.Y < (AbsPos.Y - 20 - 1) or Pos.Y > AbsPos.Y + AbsSize.Y then

                    ColorPicker:Hide();
                end;

                if not Library:IsMouseOverFrame(ContextMenu.Container) then
                    ContextMenu:Hide();
                end;
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
                if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
                    ContextMenu:Hide();
                end;
            end;
        end));

        ColorPicker:Display();
        ColorPicker.DisplayFrame = DisplayFrame;

        if type(ColorPicker)=="table" and ColorPicker.SetVisible==nil then ColorPicker.SetVisible=function() end end;
        Options[Idx] = ColorPicker;

        return self;
    end;

    function Funcs:AddKeyPicker(Idx, Info)
        local ParentObj = self;
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;

        assert(Info.Default, 'AddKeyPicker: Missing default value.');

        local KeyPicker = {
            Value = Info.Default;
            Toggled = false;
            Mode = Info.Mode or 'Toggle';
            Type = 'KeyPicker';
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;

            SyncToggleState = Info.SyncToggleState or false;
        };

        if KeyPicker.SyncToggleState then
            Info.Modes = { 'Toggle' };
            Info.Mode = 'Toggle';

            if ParentObj.Type == 'Toggle' then
                KeyPicker.Toggled = not not ParentObj.Value;
            end;
        end;

        local PickOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(0, 28, 0, 15);
            ZIndex = ToggleLabel.ZIndex + 1;
            Parent = ToggleLabel;
        });

        local PickInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = ToggleLabel.ZIndex + 2;
            Parent = PickOuter;
        });

        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 1, 0);
            Position = UDim2.new(0, 2, 0, 0);
            TextSize = 12;
            TextColor3 = Color3.new(1, 1, 1);
            Text = Info.Default == 'None' and '( - )' or Info.Default;
            ZIndex = ToggleLabel.ZIndex + 3;
            Parent = PickInner;
        });

        local function UpdateDisplayWidth(text)
            local display = text == 'None' and '( - )' or text;
            DisplayLabel.Text = display;
            local textWidth = Library:GetTextBounds(display, Library.Font, 13);
            PickOuter.Size = UDim2.new(0, textWidth + 6, 0, 15);
        end;
        UpdateDisplayWidth(Info.Default);

        local ModeSelectOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
            Size = UDim2.new(0, 60, 0, 45 + 2);
            Visible = false;
            ZIndex = Library:GetPopupZIndex(0);
            Parent = ScreenGui;
        });

        ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
        end);

        local ModeSelectInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = Library:GetPopupZIndex(1);
            Parent = ModeSelectOuter;
        });

        Library:AddToRegistry(ModeSelectInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        });

        local rowBase = Library:GetKeybindRowZBase();

        local KeybindRow = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, -4, 0, 22);
            Visible = false;
            ZIndex = rowBase;
            Parent = Library.KeybindContainer;
        });

        local NameLabel = Library:CreateLabel({
            Text = Info.Text or '';
            TextXAlignment = Enum.TextXAlignment.Left;
            Size = UDim2.new(1, -84, 1, 0);
            TextSize = 13;
            TextColor3 = Color3.new(1, 1, 1);
            ZIndex = rowBase + 3;
            Parent = KeybindRow;
        }, true);

        Library:SetGradientText(NameLabel, Info.Text or '');

        local KeyBox = Library:Create('Frame', {
            AnchorPoint = Vector2.new(1, 0.5);
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Position = UDim2.new(1, 0, 0.5, 0);
            Size = UDim2.fromOffset(52, 18);
            ZIndex = rowBase + 3;
            Parent = KeybindRow;
        });

        Library:AddToRegistry(KeyBox, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        }, true);

        local ValueLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 1, 0);
            Position = UDim2.new(0, 2, 0, 0);
            TextSize = 12;
            TextColor3 = Color3.new(1, 1, 1);
            TextXAlignment = Enum.TextXAlignment.Center;
            ZIndex = rowBase + 5;
            Parent = KeyBox;
        }, true);

        KeyPicker.KeybindRow = KeybindRow;
        KeyPicker.NameLabel = NameLabel;
        KeyPicker.KeyBox = KeyBox;

        local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' };
        local ModeButtons = {};

        for Idx, Mode in next, Modes do
            local ModeButton = {};

            local Label = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = Mode;
                ZIndex = Library:GetPopupZIndex(2);
                Parent = ModeSelectInner;
            });

            function ModeButton:Select()
                for _, Button in next, ModeButtons do
                    Button:Deselect();
                end;

                KeyPicker.Mode = Mode;

                Label.TextColor3 = Library.AccentColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';

                ModeSelectOuter.Visible = false;
            end;

            function ModeButton:Deselect()
                KeyPicker.Mode = nil;

                Label.TextColor3 = Library.FontColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
            end;

            Label.InputBegan:Connect(function(Input)
                if IsPrimaryPress(Input) then
                    ModeButton:Select();
                    Library:AttemptSave();
                end;
            end);

            if Mode == KeyPicker.Mode then
                ModeButton:Select();
            end;

            ModeButtons[Mode] = ModeButton;
        end;

        function KeyPicker:Update()
            if Info.NoUI then
                return;
            end;

            local State = KeyPicker:GetState();
            local keyText = KeyPicker.Value == 'None' and '-' or KeyPicker.Value;

            NameLabel.Text = Info.Text or '';
            ValueLabel.Text = keyText;
            ValueLabel.TextColor3 = Color3.new(1, 1, 1);
            ValueLabel.TextTransparency = 0;
            Library:SetGradientText(NameLabel, Info.Text or '');

            local textWidth = Library:GetTextBounds(keyText, Library.Font, 12);
            KeyBox.Size = UDim2.fromOffset(math.max(textWidth + 10, 36), 18);

            PickOuter.ZIndex = ToggleLabel.ZIndex + 1;
            PickInner.ZIndex = ToggleLabel.ZIndex + 2;
            DisplayLabel.ZIndex = ToggleLabel.ZIndex + 3;

            KeybindRow.Visible = State;
            Library:SyncKeybindRowsZIndex();
            Library:UpdateKeybindOverlaySize();
        end;

        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then
                return true;
            elseif KeyPicker.Mode == 'Hold' then
                if KeyPicker.Value == 'None' then
                    return false;
                end;

                local Key = KeyPicker.Value;

                if Key == 'MB1' or Key == 'MB2' then
                    return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                        or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                else
                    return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                end;
            else
                return KeyPicker.Toggled;
            end;
        end;

        function KeyPicker:SetValue(Data)
            local Key, Mode = Data[1], Data[2];
            UpdateDisplayWidth(Key);
            ModeButtons[Mode]:Select();
            KeyPicker:Update();
        end;

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback;
        end;

        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback;
            Callback(KeyPicker.Value);
        end;

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker);
        end;

        function KeyPicker:DoClick()
            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                ParentObj:SetValue(not ParentObj.Value);
            end;

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled);
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled);
        end;

        local Picking = false;

        PickOuter.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) and not Library:MouseIsOverOpenedFrame() then
                Picking = true;

                UpdateDisplayWidth('');

                local Break;
                local Text = '';

                task.spawn(function()
                    while (not Break) do
                        if Text == '...' then
                            Text = '';
                        end;

                        Text = Text .. '.';
                        UpdateDisplayWidth(Text);

                        wait(0.4);
                    end;
                end);

                wait(0.2);

                local Event;
                Event = InputService.InputBegan:Connect(function(Input)
                    local Key;

                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = Input.KeyCode.Name;
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Key = 'MB1';
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = 'MB2';
                    end;

                    if Key == 'Escape' or Key == 'Backspace' then
                        Key = 'None';
                    end;

                    Break = true;
                    Picking = false;

                    UpdateDisplayWidth(Key);
                    KeyPicker.Value = Key;

                    Library:SafeCallback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType);
                    Library:SafeCallback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType);

                    Library:AttemptSave();

                    Event:Disconnect();
                end);
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ModeSelectOuter.Visible = true;
            end;
        end);

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Toggle' then
                    local Key = KeyPicker.Value;

                    if Key == 'MB1' or Key == 'MB2' then
                        if Key == 'MB1' and IsPrimaryPress(Input)
                        or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeyPicker.Toggled = not KeyPicker.Toggled;
                            KeyPicker:DoClick();
                        end;
                    elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode.Name == Key then
                            KeyPicker.Toggled = not KeyPicker.Toggled;
                            KeyPicker:DoClick();
                        end;
                    end;
                end;

                KeyPicker:Update();
            end;

            if IsPrimaryPress(Input) then
                local Pos = GetPointerPosition(Input);
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

                if Pos.X < AbsPos.X or Pos.X > AbsPos.X + AbsSize.X
                    or Pos.Y < (AbsPos.Y - 20 - 1) or Pos.Y > AbsPos.Y + AbsSize.Y then

                    ModeSelectOuter.Visible = false;
                end;
            end;
        end));

        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if (not Picking) then
                KeyPicker:Update();
            end;
        end));

        KeyPicker:Update();

        if type(KeyPicker)=="table" and KeyPicker.SetVisible==nil then KeyPicker.SetVisible=function() end end;
        Options[Idx] = KeyPicker;

        return self;
    end;

    BaseAddons.__index = Funcs;
    BaseAddons.__namecall = function(Table, Key, ...)
        return Funcs[Key](Table, ...);
    end;
end;

BaseGroupbox = {};

do
    local Funcs = {};

    local function Z(Groupbox, Layer)
        return (Groupbox.ContentBaseZIndex or 10) + Layer;
    end;

    function Funcs:AddBlank(Size)
        local Groupbox = self;
        local Container = Groupbox.Container;

        Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            ZIndex = Z(Groupbox, 1);
            Parent = Container;
        });
    end;

    function Funcs:AddLabel(Text, DoesWrap)
        local Label = {};

        local Groupbox = self;
        local Container = Groupbox.Container;

        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15);
            TextSize = 14;
            Text = Text;
            TextWrapped = DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = Z(self, 5);
            Parent = Container;
        });

        if DoesWrap then
            local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)));
            TextLabel.Size = UDim2.new(1, -4, 0, Y);
        else
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TextLabel;
            });
        end;

        Label.TextLabel = TextLabel;
        Label.Container = Container;

        function Label:SetText(Text)
            TextLabel.Text = Text;

            if DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)));
                TextLabel.Size = UDim2.new(1, -4, 0, Y);
            end;

            Groupbox:Resize();
        end;

        if (not DoesWrap) then
            setmetatable(Label, BaseAddons);
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Label;
    end;

    function Funcs:AddButton(...)
        local Button = {};
        local function ProcessButtonParams(Class, Obj, ...)
            local Props = select(1, ...);
            if type(Props) == 'table' then
                Obj.Text = Props.Text;
                Obj.Func = Props.Func;
                Obj.DoubleClick = Props.DoubleClick;
                Obj.Tooltip = Props.Tooltip;
            else
                Obj.Text = select(1, ...);
                Obj.Func = select(2, ...);
            end;

            assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');
        end;

        ProcessButtonParams('Button', Button, ...);

        local Groupbox = self;
        local Container = Groupbox.Container;

        local function CreateBaseButton(Button)
            local Outer = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 20);
                ZIndex = Z(self, 5);
            });

            local Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = Z(self, 6);
                Parent = Outer;
            });

            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 14;
                Text = Button.Text;
                ZIndex = Z(self, 6);
                Parent = Inner;
            });

            Library:Create('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = Inner;
            });

            Library:AddToRegistry(Outer, {
                BorderColor3 = 'Black';
            });

            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            Library:OnHighlight(Outer, Outer,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            return Outer, Inner, Label;
        end;

        local function InitEvents(Button)
            local function WaitForEvent(event, timeout, validator)
                local bindable = Instance.new('BindableEvent');
                local connection = event:Once(function(...)

                    if type(validator) == 'function' and validator(...) then
                        bindable:Fire(true);
                    else
                        bindable:Fire(false);
                    end;
                end);
                task.delay(timeout, function()
                    connection:disconnect();
                    bindable:Fire(false);
                end);
                return bindable.Event:Wait();
            end;

            local function ValidateClick(Input)
                if Library:MouseIsOverOpenedFrame() then
                    return false;
                end;

                return Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch;
            end;

            Button.Outer.InputBegan:Connect(function(Input)
                if not ValidateClick(Input) then return end;
                if Button.Locked then return end;

                if Button.DoubleClick then
                    Library:RemoveFromRegistry(Button.Label);
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'AccentColor' });

                    Button.Label.TextColor3 = Library.AccentColor;
                    Button.Label.Text = 'Are you sure?';
                    Button.Locked = true;

                    local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick);

                    Library:RemoveFromRegistry(Button.Label);
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' });

                    Button.Label.TextColor3 = Library.FontColor;
                    Button.Label.Text = Button.Text;
                    task.defer(rawset, Button, 'Locked', false);

                    if clicked then
                        Library:SafeCallback(Button.Func);
                    end;

                    return
                end;

                Library:SafeCallback(Button.Func);
            end);
        end;

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button);
        Button.Outer.Parent = Container;

        InitEvents(Button);

        function Button:AddTooltip(tooltip)
            if type(tooltip) == 'string' then
                Library:AddToolTip(tooltip, self.Outer);
            end;
            return self;
        end;

        function Button:SetText(text)
            self.Text = text;
            self.Label.Text = text;
            return self;
        end;

        function Button:AddButton(...)
            local SubButton = {};

            ProcessButtonParams('SubButton', SubButton, ...);

            self.Outer.Size = UDim2.new(0.5, -2, 0, 20);

            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton);

            SubButton.Outer.Position = UDim2.new(1, 3, 0, 0);
            SubButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X - 2, self.Outer.AbsoluteSize.Y);
            SubButton.Outer.Parent = self.Outer;

            function SubButton:AddTooltip(tooltip)
                if type(tooltip) == 'string' then
                    Library:AddToolTip(tooltip, self.Outer);
                end;
                return SubButton;
            end;

            function SubButton:SetText(text)
                self.Text = text;
                self.Label.Text = text;
                return self;
            end;

            if type(SubButton.Tooltip) == 'string' then
                SubButton:AddTooltip(SubButton.Tooltip);
            end;

            InitEvents(SubButton);
            return SubButton;
        end;

        if type(Button.Tooltip) == 'string' then
            Button:AddTooltip(Button.Tooltip);
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Button;
    end;

    function Funcs:AddDivider()
        local Groupbox = self;
        local Container = self.Container;

        local Divider = {
            Type = 'Divider',
        };

        Groupbox:AddBlank(2);
        local DividerOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 5);
            ZIndex = Z(self, 5);
            Parent = Container;
        });

        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = Z(self, 6);
            Parent = DividerOuter;
        });

        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black';
        });

        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Groupbox:AddBlank(9);
        Groupbox:Resize();
    end;

    function Funcs:AddInput(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.');

        local Textbox = {
            Value = Info.Default or '';
            Numeric = Info.Numeric or false;
            Finished = Info.Finished or false;
            Type = 'Input';
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        if not Info.NoLabel then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = Z(self, 5);
                Parent = Container;
            });

            Groupbox:AddBlank(1);
        end;

        local TextBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = Z(self, 5);
            Parent = Container;
        });

        local TextBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = Z(self, 6);
            Parent = TextBoxOuter;
        });

        Library:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:OnHighlight(TextBoxOuter, TextBoxOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, TextBoxOuter);
        end;

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = TextBoxInner;
        });

        local Container = Library:Create('Frame', {
            BackgroundTransparency = 1;

            Position = UDim2.new(0, 5, 0, 2);
            Size = UDim2.new(1, -10, 1, -4);

            ZIndex = Z(self, 7);
            Parent = TextBoxInner;
        });

        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1;

            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),

            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(120, 120, 120);
            PlaceholderText = Info.Placeholder or '';

            Text = Info.Default or '';
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 1;
            TextTransparency = 1;
            ClearTextOnFocus = false;
            TextXAlignment = Enum.TextXAlignment.Left;

            ZIndex = Z(self, 7);
            Parent = Container;
        });

        local TextOverlay = Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),
            Font = Library.Font;
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = Z(self, 7);
            Parent = Container;
        });

        Box:GetPropertyChangedSignal('Position'):Connect(function()
            TextOverlay.Position = Box.Position;
        end);

        local CustomCaret = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(0, 2, 1, -4);
            Position = UDim2.fromOffset(2, 2);
            ZIndex = Z(self, 9);
            Visible = false;
            Parent = Container;
        });

        Library:AddToRegistry(CustomCaret, {
            BackgroundColor3 = 'AccentColor';
        });

        local CaretBlinkTween;
        local CaretBlinkConnection;
        local LastTextLength = #(Info.Default or '');
        local TextAnimTween;

        local function StopCaretBlink()
            if CaretBlinkTween then
                CaretBlinkTween:Cancel();
                CaretBlinkTween = nil;
            end;

            if CaretBlinkConnection then
                CaretBlinkConnection:Disconnect();
                CaretBlinkConnection = nil;
            end;

            CustomCaret.BackgroundTransparency = 0;
        end;

        local function StartCaretBlink()
            StopCaretBlink();

            CaretBlinkConnection = RunService.RenderStepped:Connect(function()
                if not Box:IsFocused() then
                    StopCaretBlink();
                end;
            end));

            local function Blink()
                if not Box:IsFocused() then
                    return
                end;

                CaretBlinkTween = TweenService:Create(CustomCaret, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    BackgroundTransparency = 0.55,
                });

                CaretBlinkTween:Play();
                CaretBlinkTween.Completed:Connect(function()
                    if Box:IsFocused() then
                        CaretBlinkTween = TweenService:Create(CustomCaret, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                            BackgroundTransparency = 0,
                        });
                        CaretBlinkTween:Play();
                        CaretBlinkTween.Completed:Connect(Blink);
                    end;
                end);
            end;

            Blink();
        end;

        local function PlayTextEntryAnimation()
            if TextAnimTween then
                TextAnimTween:Cancel();
            end;

            TextOverlay.TextTransparency = 0.45;
            TextOverlay.Position = UDim2.new(Box.Position.X.Scale, Box.Position.X.Offset, 0, -2);

            TextAnimTween = TweenService:Create(TextOverlay, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                TextTransparency = 0,
                Position = Box.Position,
            });
            TextAnimTween:Play();
        end;

        function Textbox:SetValue(Text)
            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength);
            end;

            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value;
                end;
            end;

            Textbox.Value = Text;
            Box.Text = Text;
            LastTextLength = #Text;

            Library:SafeCallback(Textbox.Callback, Textbox.Value);
            Library:SafeCallback(Textbox.Changed, Textbox.Value);
        end;

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end);
        else
            Box:GetPropertyChangedSignal('Text'):Connect(function()
                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end);
        end;

        local function Update()
            local PADDING = 2;
            local reveal = Container.AbsoluteSize.X;

            if Box.Text == "" then
                TextOverlay.Text = Box.PlaceholderText;
                TextOverlay.TextColor3 = Box.PlaceholderColor3;
            else
                TextOverlay.Text = Box.Text;
                TextOverlay.TextColor3 = Library.FontColor;
            end;

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                TweenService:Create(Box, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, PADDING, 0, 0)
                }):Play();
            else
                local cursor = Box.CursorPosition;
                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor-1);
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X;
                    local currentCursorPos = Box.Position.X.Offset + width;

                    local targetX = Box.Position.X.Offset;
                    if currentCursorPos < PADDING then
                        targetX = PADDING-width;
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        targetX = reveal-width-PADDING-1;
                    end;

                    TweenService:Create(Box, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.fromOffset(targetX, 0)
                    }):Play();
                end;
            end;

            if Box:IsFocused() then
                CustomCaret.Visible = true;
                local cursor = Box.CursorPosition;
                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor-1);
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X;
                    local caretTargetX = Box.Position.X.Offset + width + 1;
                    TweenService:Create(CustomCaret, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.fromOffset(math.clamp(caretTargetX, PADDING, reveal - PADDING), 2)
                    }):Play();
                else
                    CustomCaret.Visible = false;
                end;
            else
                CustomCaret.Visible = false;
                StopCaretBlink();
            end;
        end;

        local function OnTextChanged()
            local newLength = #Box.Text;
            if Box:IsFocused() and newLength > LastTextLength then
                PlayTextEntryAnimation();
            end;
            LastTextLength = newLength;
            Update();
        end;

        task.spawn(Update);

        Box:GetPropertyChangedSignal('Text'):Connect(OnTextChanged);
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update);
        Box.FocusLost:Connect(function()
            StopCaretBlink();
            Update();
        end);
        Box.Focused:Connect(function()
            StartCaretBlink();
            Update();
        end);

        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor';
        });

        function Textbox:OnChanged(Func)
            Textbox.Changed = Func;
            Func(Textbox.Value);
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        if type(Textbox)=="table" and Textbox.SetVisible==nil then Textbox.SetVisible=function() end end;
        Options[Idx] = Textbox;

        return Textbox;
    end;

    function Funcs:AddToggle(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.');

        local Toggle = {
            Value = Info.Default or false;
            Type = 'Toggle';

            Callback = Info.Callback or function(Value) end;
            Addons = {},
            Risky = Info.Risky,
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local ToggleOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 13, 0, 13);
            ZIndex = Z(self, 5);
            Parent = Container;
        });

        Library:AddToRegistry(ToggleOuter, {
            BorderColor3 = 'Black';
        });

        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = Z(self, 6);
            Parent = ToggleOuter;
        });

        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local ToggleLabel = Library:CreateLabel({
            Size = UDim2.new(0, 216, 1, 0);
            Position = UDim2.new(1, 6, 0, 0);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = Z(self, 6);
            Parent = ToggleInner;
        });

        local function UpdateToggleLabelWidth()
            local available = Container.AbsoluteSize.X / Library:GetUIScaleFactor(Container) - (ToggleOuter.Size.X.Offset + 6) - 4;
            ToggleLabel.Size = UDim2.new(0, math.max(available, 60), 1, 0);
        end;

        Container:GetPropertyChangedSignal('AbsoluteSize'):Connect(UpdateToggleLabelWidth);
        task.spawn(UpdateToggleLabelWidth);

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ToggleLabel;
        });

        local ToggleRegion = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 170, 1, 0);
            ZIndex = Z(self, 8);
            Parent = ToggleOuter;
        });

        Library:OnHighlight(ToggleRegion, ToggleOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        function Toggle:UpdateColors()
            Toggle:Display();
        end;

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, ToggleRegion);
        end;

        function Toggle:Display()
            if Toggle.BgTween then Toggle.BgTween:Cancel() end;
            if Toggle.BorderTween then Toggle.BorderTween:Cancel() end;

            local targetBg = Toggle.Value and Library.AccentColor or Library.MainColor;
            local targetBorder = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

            local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
            Toggle.BgTween = TweenService:Create(ToggleInner, tweenInfo, { BackgroundColor3 = targetBg });
            Toggle.BorderTween = TweenService:Create(ToggleInner, tweenInfo, { BorderColor3 = targetBorder });

            Toggle.BgTween:Play();
            Toggle.BorderTween:Play();

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
        end;

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func;
            Func(Toggle.Value);
        end;

        function Toggle:SetValue(Bool)
            Bool = (not not Bool);

            Toggle.Value = Bool;
            Toggle:Display();

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool;
                    Addon:Update();
                end;
            end;

            Library:SafeCallback(Toggle.Callback, Toggle.Value);
            Library:SafeCallback(Toggle.Changed, Toggle.Value);
            Library:UpdateDependencyBoxes();
        end;

        ToggleRegion.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) and not Library:MouseIsOverOpenedFrame() then
                Library:PlayToggleSound();
                Toggle:SetValue(not Toggle.Value);
                Library:AttemptSave();
            end;
        end);

        if Toggle.Risky then
            Library:RemoveFromRegistry(ToggleLabel);
            ToggleLabel.TextColor3 = Library.RiskColor;
            Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' });
        end;

        Toggle:Display();
        Groupbox:AddBlank(Info.BlankSize or 5 + 2);
        Groupbox:Resize();

        Toggle.TextLabel = ToggleLabel;
        Toggle.Container = Container;
        setmetatable(Toggle, BaseAddons);

        if type(Toggle)=="table" and Toggle.SetVisible==nil then Toggle.SetVisible=function() end end;
        Toggles[Idx] = Toggle;

        Library:UpdateDependencyBoxes();

        return Toggle;
    end;

    function Funcs:AddSlider(Idx, Info)
        assert(Info.Default, 'AddSlider: Missing default value.');
        assert(Info.Text, 'AddSlider: Missing slider text.');
        assert(Info.Min, 'AddSlider: Missing minimum value.');
        assert(Info.Max, 'AddSlider: Missing maximum value.');
        assert(Info.Rounding, 'AddSlider: Missing rounding value.');

        local Slider = {
            Value = Info.Default;
            Min = Info.Min;
            Max = Info.Max;
            Rounding = math.clamp(Info.Rounding or 0, 0, 3);
            Type = 'Slider';
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        if not Info.Compact then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = Z(self, 5);
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end;

        local SliderContainer = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, -4, 0, 13);
            ZIndex = Z(self, 5);
            Parent = Container;
        });

        local DecrementBtn = Library:Create('TextButton', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, -1);
            Size = UDim2.new(0, 12, 1, 0);
            Font = Library.Font;
            Text = "-";
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextYAlignment = Enum.TextYAlignment.Center;
            ZIndex = Z(self, 8);
            Parent = SliderContainer;
        });

        local IncrementBtn = Library:Create('TextButton', {
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -12, 0, -1);
            Size = UDim2.new(0, 12, 1, 0);
            Font = Library.Font;
            Text = "+";
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextYAlignment = Enum.TextYAlignment.Center;
            ZIndex = Z(self, 8);
            Parent = SliderContainer;
        });

        Library:OnHighlight(DecrementBtn, DecrementBtn,
            { TextColor3 = 'AccentColor' },
            { TextColor3 = 'FontColor' }
        );

        Library:OnHighlight(IncrementBtn, IncrementBtn,
            { TextColor3 = 'AccentColor' },
            { TextColor3 = 'FontColor' }
        );

        local SliderOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 16, 0, 0);
            Size = UDim2.new(1, -32, 0, 13);
            ZIndex = Z(self, 5);
            Parent = SliderContainer;
        });

        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black';
        });

        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = Z(self, 6);
            Parent = SliderOuter;
        });

        function Slider:GetBarWidth()
            return math.max(SliderInner.AbsoluteSize.X, 1);
        end;

        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderColor3 = Library.AccentColorDark;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = Z(self, 7);
            Parent = SliderInner;
        });

        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor';
            BorderColor3 = 'AccentColorDark';
        });

        local HideBorderRight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(1, 0, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = Z(self, 8);
            Parent = Fill;
        });

        Library:AddToRegistry(HideBorderRight, {
            BackgroundColor3 = 'AccentColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            Text = 'Infinite';
            ZIndex = Z(self, 9);
            Parent = SliderInner;
        });

        Library:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, SliderOuter);
        end;

        function Slider:UpdateColors()
            Fill.BackgroundColor3 = Library.AccentColor;
            Fill.BorderColor3 = Library.AccentColorDark;
        end;

        function Slider:Display()
            local Suffix = Info.Suffix or "";

            if Info.Compact then
                DisplayLabel.Text = Info.Text .. ": " .. Slider.Value .. Suffix;
            elseif Info.HideMax then
                DisplayLabel.Text = tostring(Slider.Value) .. Suffix;
            else
                DisplayLabel.Text = ("%s/%s"):format(Slider.Value .. Suffix, Slider.Max .. Suffix);
            end;

            local Width = Slider:GetBarWidth();

            local X = math.clamp(
                math.round(
                    Library:MapValue(
                        Slider.Value,
                        Slider.Min,
                        Slider.Max,
                        0,
                        Width
                    )
                ),
                0,
                Width
            );

            if Slider.Tween then
                Slider.Tween:Cancel();
            end;

            Slider.Tween = TweenService:Create(
                Fill,
                TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(0, X, 1, 0)
                }
            );

            Slider.Tween:Play();

            HideBorderRight.Visible = X > 0 and X < Width;
        end;

        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Func(Slider.Value);
        end;

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value + 0.5);
            end;

            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value));
        end;

        function Slider:GetValueFromXOffset(X)
            return Round(
                Library:MapValue(
                    X,
                    0,
                    Slider:GetBarWidth(),
                    Slider.Min,
                    Slider.Max
                )
            );
        end;

        function Slider:SetValue(Str)
            local Num = tonumber(Str);

            if (not Num) then
                return;
            end;

            Num = math.clamp(Num, Slider.Min, Slider.Max);

            Slider.Value = Round(Num);
            Slider:Display();

            Library:SafeCallback(Slider.Callback, Slider.Value);
            Library:SafeCallback(Slider.Changed, Slider.Value);
        end;

        SliderInner.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) and not Library:MouseIsOverOpenedFrame() then
                local mPos = GetPointerPosition(Input).X;
                local gPos = Fill.Size.X.Offset;
                local Diff = mPos - (Fill.AbsolutePosition.X + gPos);

                while IsPressActive(Input) do
                    local nMPos = GetPointerPosition(Input).X;
                    local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider:GetBarWidth());

                    local nValue = Slider:GetValueFromXOffset(nX);
                    local OldValue = Slider.Value;
                    Slider.Value = nValue;

                    Slider:Display();

                    if nValue ~= OldValue then
                        Library:PlaySliderSound();
                        Library:SafeCallback(Slider.Callback, Slider.Value);
                        Library:SafeCallback(Slider.Changed, Slider.Value);
                    end;

                    RenderStepped:Wait();
                end;

                Library:StopSliderSound();
                Library:AttemptSave();
            end;
        end);

        Library:BindHoldButton(DecrementBtn, function()
            local step = 10 ^ -Slider.Rounding;
            local OldValue = Slider.Value;
            Slider:SetValue(Slider.Value - step);
            if Slider.Value ~= OldValue then
                Library:PlaySliderSound();
            end;
            Library:AttemptSave();
        end);

        Library:BindHoldButton(IncrementBtn, function()
            local step = 10 ^ -Slider.Rounding;
            local OldValue = Slider.Value;
            Slider:SetValue(Slider.Value + step);
            if Slider.Value ~= OldValue then
                Library:PlaySliderSound();
            end;
            Library:AttemptSave();
        end);

        SliderInner:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            Slider:Display();
        end);

        Slider:Display();
        Groupbox:AddBlank(Info.BlankSize or 6);
        Groupbox:Resize();

        if type(Slider)=="table" and Slider.SetVisible==nil then Slider.SetVisible=function() end end;
        Options[Idx] = Slider;

        return Slider;
    end;

    function Funcs:AddRangeSlider(Idx, Info)
        assert(Info.DefaultLower, 'AddRangeSlider: Missing default lower value.');
        assert(Info.DefaultUpper, 'AddRangeSlider: Missing default upper value.');
        assert(Info.Text, 'AddRangeSlider: Missing slider text.');
        assert(Info.Min, 'AddRangeSlider: Missing minimum value.');
        assert(Info.Max, 'AddRangeSlider: Missing maximum value.');
        assert(Info.Rounding, 'AddRangeSlider: Missing rounding value.');

        local Slider = {
            ValueLower = Info.DefaultLower;
            ValueUpper = Info.DefaultUpper;
            Min = Info.Min;
            Max = Info.Max;
            Rounding = math.clamp(Info.Rounding or 0, 0, 3);
            MaxSize = 200;
            Type = 'RangeSlider';
            Callback = Info.Callback or function(Lower, Upper) end;
        };

        Slider.Value = { Slider.ValueLower, Slider.ValueUpper };

        local Groupbox = self;
        local Container = Groupbox.Container;

        if not Info.Compact then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = Z(self, 5);
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end;

        local SliderContainer = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, -4, 0, 13);
            ZIndex = Z(self, 5);
            Parent = Container;
        });

        local SliderOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 0);
            Size = UDim2.new(1, -8, 0, 13);
            ZIndex = Z(self, 5);
            Parent = SliderContainer;
        });

        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black';
        });

        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = Z(self, 6);
            Parent = SliderOuter;
        });

        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            ZIndex = Z(self, 7);
            Parent = SliderInner;
        });

        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor';
        });

        local HeadLower = Library:Create('Frame', {
            BackgroundColor3 = Color3.fromRGB(200, 200, 200);
            BorderColor3 = Color3.fromRGB(0, 0, 0);
            Size = UDim2.new(0, 3, 1, 2);
            Position = UDim2.new(0, 0, 0, -1);
            ZIndex = Z(self, 8);
            Parent = SliderInner;
        });

        local HeadUpper = Library:Create('Frame', {
            BackgroundColor3 = Color3.fromRGB(200, 200, 200);
            BorderColor3 = Color3.fromRGB(0, 0, 0);
            Size = UDim2.new(0, 3, 1, 2);
            Position = UDim2.new(0, 0, 0, -1);
            ZIndex = Z(self, 8);
            Parent = SliderInner;
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            ZIndex = Z(self, 9);
            Parent = SliderInner;
        });

        Library:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, SliderOuter);
        end;

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value + 0.5);
            end;
            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value));
        end;

        function Slider:Display()
            local Suffix = Info.Suffix or '';
            DisplayLabel.Text = string.format('%s%s - %s%s', tostring(Slider.ValueLower), Suffix, tostring(Slider.ValueUpper), Suffix);

            local barWidth = SliderInner.AbsoluteSize.X > 0 and SliderInner.AbsoluteSize.X or 222;
            local xLower = Library:MapValue(Slider.ValueLower, Slider.Min, Slider.Max, 0, barWidth);
            local xUpper = Library:MapValue(Slider.ValueUpper, Slider.Min, Slider.Max, 0, barWidth);

            if Slider.TweenFill then Slider.TweenFill:Cancel() end;
            if Slider.TweenHeadLower then Slider.TweenHeadLower:Cancel() end;
            if Slider.TweenHeadUpper then Slider.TweenHeadUpper:Cancel() end;

            local tInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
            Slider.TweenFill = TweenService:Create(Fill, tInfo, {
                Position = UDim2.new(0, xLower, 0, 0),
                Size = UDim2.new(0, xUpper - xLower, 1, 0)
            });
            Slider.TweenHeadLower = TweenService:Create(HeadLower, tInfo, {
                Position = UDim2.new(0, xLower - 1, 0, -1)
            });
            Slider.TweenHeadUpper = TweenService:Create(HeadUpper, tInfo, {
                Position = UDim2.new(0, xUpper - 1, 0, -1)
            });

            Slider.TweenFill:Play();
            Slider.TweenHeadLower:Play();
            Slider.TweenHeadUpper:Play();
        end;

        function Slider:UpdateColors()
            Fill.BackgroundColor3 = Library.AccentColor;
        end;

        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Func(Slider.ValueLower, Slider.ValueUpper);
        end;

        function Slider:GetValueFromXOffset(X)
            local barWidth = SliderInner.AbsoluteSize.X > 0 and SliderInner.AbsoluteSize.X or 222;
            return Round(Library:MapValue(X, 0, barWidth, Slider.Min, Slider.Max));
        end;

        function Slider:SetValue(Lower, Upper)
            local numLower = tonumber(Lower) or Slider.ValueLower;
            local numUpper = tonumber(Upper) or Slider.ValueUpper;

            numLower = math.clamp(numLower, Slider.Min, Slider.Max);
            numUpper = math.clamp(numUpper, Slider.Min, Slider.Max);

            if numLower > numUpper then
                numLower = numUpper;
            end;

            Slider.ValueLower = Round(numLower);
            Slider.ValueUpper = Round(numUpper);
            Slider.Value = { Slider.ValueLower, Slider.ValueUpper };

            Slider:Display();

            Library:SafeCallback(Slider.Callback, Slider.ValueLower, Slider.ValueUpper);
            Library:SafeCallback(Slider.Changed, Slider.ValueLower, Slider.ValueUpper);
        end;

        SliderInner.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) and not Library:MouseIsOverOpenedFrame() then
                local relativeX = GetPointerPosition(Input).X - SliderInner.AbsolutePosition.X;
                local clickValue = Slider:GetValueFromXOffset(relativeX);

                local distToLower = math.abs(clickValue - Slider.ValueLower);
                local distToUpper = math.abs(clickValue - Slider.ValueUpper);
                local activeHead = (distToLower < distToUpper) and "Lower" or "Upper";

                while IsPressActive(Input) do
                    local curRelativeX = math.clamp(GetPointerPosition(Input).X - SliderInner.AbsolutePosition.X, 0, SliderInner.AbsoluteSize.X > 0 and SliderInner.AbsoluteSize.X or 222);
                    local curVal = Slider:GetValueFromXOffset(curRelativeX);

                    local oldLower = Slider.ValueLower;
                    local oldUpper = Slider.ValueUpper;

                    if activeHead == "Lower" then
                        curVal = math.clamp(curVal, Slider.Min, Slider.ValueUpper);
                        Slider.ValueLower = curVal;
                    else
                        curVal = math.clamp(curVal, Slider.ValueLower, Slider.Max);
                        Slider.ValueUpper = curVal;
                    end;

                    Slider.Value = { Slider.ValueLower, Slider.ValueUpper };
                    Slider:Display();

                    if Slider.ValueLower ~= oldLower or Slider.ValueUpper ~= oldUpper then
                        Library:PlaySliderSound();
                        Library:SafeCallback(Slider.Callback, Slider.ValueLower, Slider.ValueUpper);
                        Library:SafeCallback(Slider.Changed, Slider.ValueLower, Slider.ValueUpper);
                    end;

                    RenderStepped:Wait();
                end;

                Library:StopSliderSound();
                Library:AttemptSave();
            end;
        end);

        SliderInner:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            Slider:Display();
        end);

        Slider:Display();
        Groupbox:AddBlank(Info.BlankSize or 6);
        Groupbox:Resize();

        if type(Slider)=="table" and Slider.SetVisible==nil then Slider.SetVisible=function() end end;
        Options[Idx] = Slider;

        return Slider;
    end;

    function Funcs:AddDropdown(Idx, Info)
        if Info.SpecialType == 'Player' then
            Info.Values = GetPlayersString();
            Info.AllowNull = true;
        elseif Info.SpecialType == 'Team' then
            Info.Values = GetTeamsString();
            Info.AllowNull = true;
        end;

        assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
        assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.');

        if (not Info.Text) then
            Info.Compact = true;
        end;

        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            Multi = Info.Multi;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType;
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local RelativeOffset = 0;

        if not Info.Compact then
            local DropdownLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = Z(self, 5);
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end;

        for _, Element in next, Container:GetChildren() do
            if not Element:IsA('UIListLayout') then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
            end;
        end;

        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = Z(self, 5);
            Parent = Container;
        });

        Library:AddToRegistry(DropdownOuter, {
            BorderColor3 = 'Black';
        });

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = Z(self, 6);
            Parent = DropdownOuter;
        });

        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = DropdownInner;
        });

        local DropdownArrow = Library:CreateLabel({
            AnchorPoint = Vector2.new(1, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -5, 0.5, 0);
            Size = UDim2.new(0, 12, 1, 0);
            Text = '+';
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Right;
            ZIndex = Z(self, 8);
            Parent = DropdownInner;
        });

        local ItemList = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -20, 1, 0);
            TextSize = 14;
            Text = '--';
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = Z(self, 7);
            Parent = DropdownInner;
        });

        Library:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, DropdownOuter);
        end;

        local MAX_DROPDOWN_ITEMS = 8;

        local ListOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });

        local function RecalculateListPosition()
            ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1);
        end;

        local function RecalculateListSize(YSize)
            local height = YSize or (MAX_DROPDOWN_ITEMS * 20 + 2);
            Dropdown.ListHeight = height;
            if ListOuter.Visible then
                ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, height);
            end;
        end;

        RecalculateListPosition();
        RecalculateListSize();

        DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);

        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListOuter;
        });

        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListInner;

            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.AccentColor,
        });

        Library:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = 'AccentColor'
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        function Dropdown:Display()
            local Values = Dropdown.Values;
            local Str = '';

            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Value .. ', ';
                    end;
                end;

                Str = Str:sub(1, #Str - 2);
            else
                Str = Dropdown.Value or '';
            end;

            ItemList.Text = (Str == '' and '...' or Str);
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value);
                end;

                return T;
            else
                return Dropdown.Value and 1 or 0;
            end;
        end;

        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values;
            local Buttons = {};

            for _, Element in next, Scrolling:GetChildren() do
                if not Element:IsA('UIListLayout') then
                    Element:Destroy();
                end;
            end;

            local Count = 0;

            for Idx, Value in next, Values do
                local Table = {};

                Count = Count + 1;

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Middle;
                    Size = UDim2.new(1, -1, 0, 20);
                    ZIndex = 23;
                    Active = true,
                    Parent = Scrolling;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                    BorderColor3 = 'OutlineColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, -6, 1, 0);
                    Position = UDim2.new(0, 6, 0, 0);
                    TextSize = 14;
                    Text = Value;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 25;
                    Parent = Button;
                });

                Library:OnHighlight(Button, Button,
                    { BorderColor3 = 'AccentColor', ZIndex = 24 },
                    { BorderColor3 = 'OutlineColor', ZIndex = 23 }
                );

                local Selected;

                if Info.Multi then
                    Selected = Dropdown.Value[Value];
                else
                    Selected = Dropdown.Value == Value;
                end;

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value];
                    else
                        Selected = Dropdown.Value == Value;
                    end;

                    ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor;
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor';
                end;

                ButtonLabel.InputBegan:Connect(function(Input)
                    if IsPrimaryPress(Input) then
                        local Try = not Selected;

                        if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                        else
                            if Info.Multi then
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value[Value] = true;
                                else
                                    Dropdown.Value[Value] = nil;
                                end;
                            else
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value = Value;
                                else
                                    Dropdown.Value = nil;
                                end;

                                for _, OtherButton in next, Buttons do
                                    OtherButton:UpdateButton();
                                end;
                            end;

                            Table:UpdateButton();
                            Dropdown:Display();

                            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
                            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);

                            Library:UpdateDependencyBoxes();

                            Library:AttemptSave();
                        end;
                    end;
                end);

                Table:UpdateButton();
                Dropdown:Display();

                Buttons[Button] = Table;
            end;

            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1);

            local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1;
            RecalculateListSize(Y);
        end;

        function Dropdown:SetValues(NewValues)
            if NewValues then
                Dropdown.Values = NewValues;
            end;

            Dropdown:BuildDropdownList();
        end;

        function Dropdown:OpenDropdown()
            if Dropdown.Tween then Dropdown.Tween:Cancel() end;

            RecalculateListPosition();
            Library:ApplyPopupZIndex(ListOuter, 20);
            ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, 0);
            ListOuter.Visible = true;
            ListOuter.ClipsDescendants = false;
            ListInner.ClipsDescendants = false;
            Library.OpenedFrames[ListOuter] = true;

            Dropdown.Tween = TweenService:Create(ListOuter, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, Dropdown.ListHeight or 162)
            });
            DropdownArrow.Text = '-';

            Dropdown.Tween:Play();
        end;

        function Dropdown:CloseDropdown()
            if Dropdown.Tween then Dropdown.Tween:Cancel() end;

            Dropdown.Tween = TweenService:Create(ListOuter, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, 0)
            });
            DropdownArrow.Text = '+';

            local connection;
            connection = Dropdown.Tween.Completed:Connect(function()
                ListOuter.Visible = false;
                Library.OpenedFrames[ListOuter] = nil;
                connection:Disconnect();
            end);

            Dropdown.Tween:Play();
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Func(Dropdown.Value);
        end;

        function Dropdown:SetValue(Val)
            local previousValue = Dropdown.Value;

            if Dropdown.Multi then
                local nTable = {};

                for Value, Bool in next, Val do
                    if table.find(Dropdown.Values, Value) then
                        nTable[Value] = true;
                    end;
                end;

                Dropdown.Value = nTable;
            else
                if (not Val) then
                    Dropdown.Value = nil;
                elseif table.find(Dropdown.Values, Val) then
                    Dropdown.Value = Val;
                end;
            end;

            if Dropdown.Value == previousValue then
                Dropdown:Display();
                return;
            end;

            Dropdown:BuildDropdownList();

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
        end;

        DropdownOuter.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) and not Library:MouseIsOverOpenedFrame() then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown();
                else
                    Dropdown:OpenDropdown();
                end;
            end;
        end);

        InputService.InputBegan:Connect(function(Input)
            if IsPrimaryPress(Input) then
                local Pos = GetPointerPosition(Input);
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;

                if Pos.X < AbsPos.X or Pos.X > AbsPos.X + AbsSize.X
                    or Pos.Y < (AbsPos.Y - 20 - 1) or Pos.Y > AbsPos.Y + AbsSize.Y then

                    Dropdown:CloseDropdown();
                end;
            end;
        end);

        Dropdown:BuildDropdownList();
        Dropdown:Display();

        local Defaults = {};

        if type(Info.Default) == 'string' then
            local Idx = table.find(Dropdown.Values, Info.Default);
            if Idx then
                table.insert(Defaults, Idx);
            end;
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Idx = table.find(Dropdown.Values, Value);
                if Idx then
                    table.insert(Defaults, Idx);
                end;
            end;
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default);
        end;

        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i];
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true;
                else
                    Dropdown.Value = Dropdown.Values[Index];
                end;

                if (not Info.Multi) then break end;
            end;

            Dropdown:BuildDropdownList();
            Dropdown:Display();
        end;

        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        if type(Dropdown)=="table" and Dropdown.SetVisible==nil then Dropdown.SetVisible=function() end end;
        Options[Idx] = Dropdown;
        Dropdown.Outer = DropdownOuter;
        Dropdown.ListOuter = ListOuter;

        Library:UpdateDependencyBoxes();

        return Dropdown;
    end;

    function Funcs:AddDependencyBox()
        local Depbox = {Dependencies = {}};
        local Groupbox = self;
        local Container = Groupbox.Container;
        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = Container,
        });
        local Frame = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = true,
            Parent = Holder,
        });
        local Layout = Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Frame,
        });

        function Depbox:Resize()
            Holder.Size = NewUDim2(1, 0, 0, Layout.AbsoluteContentSize.Y);

            Groupbox:Resize();
        end;

        Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Depbox:Resize();
        end);
        Holder:GetPropertyChangedSignal('Visible'):Connect(function()
            Depbox:Resize();
        end);

        function Depbox:Update()
            for _, Dependency in next, Depbox.Dependencies do
                local Elem = Dependency[1];
                local Expected = Dependency[2];
                local CurrentValue = Elem.Value;

                if CurrentValue == nil then
                    Holder.Visible = false;

                    Depbox:Resize();

                    return
                end;
                if CurrentValue ~= Expected then
                    Holder.Visible = false;

                    Depbox:Resize();

                    return
                end;
            end;

            Holder.Visible = true;

            Depbox:Resize();
        end;
        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in next, Dependencies do
                assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.');
                assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.');
                assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.');
            end;

            Depbox.Dependencies = Dependencies;

            Depbox:Update();
        end;

        Depbox.Container = Frame;

        setmetatable(Depbox, BaseGroupbox);
        table.insert(Library.DependencyBoxes, Depbox);

        return Depbox;
    end;

    BaseGroupbox.__index = Funcs;
    BaseGroupbox.__namecall = function(Table, Key, ...)
        local Method = rawget(Table, Key) or Funcs[Key];
        return Method(Table, ...);
    end;
end;

function Library:UpdateNotificationArea()
    local area = Library.NotificationArea;
    local layout = Library.NotificationListLayout;
    if not area or not layout then
        return
    end;

    local margin = 12;
    local spot = Library.NotificationSpot or 'Top Right';

    if spot == 'Top Left' then
        area.AnchorPoint = Vector2.new(0, 0);
        area.Position = UDim2.new(0, margin, 0, margin);
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
        layout.VerticalAlignment = Enum.VerticalAlignment.Top;
    elseif spot == 'Bottom Right' then
        area.AnchorPoint = Vector2.new(1, 1);
        area.Position = UDim2.new(1, -margin, 1, -margin);
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right;
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom;
    elseif spot == 'Bottom Left' then
        area.AnchorPoint = Vector2.new(0, 1);
        area.Position = UDim2.new(0, margin, 1, -margin);
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom;
    elseif spot == 'Center' then
        area.AnchorPoint = Vector2.new(0.5, 0.5);
        area.Position = UDim2.new(0.5, 0, 0.5, 0);
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
        layout.VerticalAlignment = Enum.VerticalAlignment.Center;
    else
        area.AnchorPoint = Vector2.new(1, 0);
        area.Position = UDim2.new(1, -margin, 0, margin);
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right;
        layout.VerticalAlignment = Enum.VerticalAlignment.Top;
    end;
end;

function Library:SetNotificationSpot(Spot)
    Library.NotificationSpot = Spot;
    Library:UpdateNotificationArea();
end;

function Library:SetNotificationAnimation(Animation)
    Library.NotificationAnimation = Animation;
end;

function Library:PlayNotificationEnter(NotifyInner, TotalW)
    local animation = Library.NotificationAnimation or 'Slide Right to Left';
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

    NotifyInner.AnchorPoint = Vector2.new(0, 0);
    NotifyInner.Position = UDim2.fromOffset(0, 0);
    NotifyInner.Size = UDim2.new(1, 0, 1, 0);

    if animation == 'Slide Left to Right' then
        NotifyInner.Position = UDim2.fromOffset(-TotalW, 0);
        TweenService:Create(NotifyInner, tweenInfo, {
            Position = UDim2.fromOffset(0, 0),
        }):Play();
    elseif animation == 'Middle Outwards' then
        NotifyInner.AnchorPoint = Vector2.new(0.5, 0.5);
        NotifyInner.Position = UDim2.new(0.5, 0, 0.5, 0);
        NotifyInner.Size = UDim2.new(0, 0, 1, 0);
        TweenService:Create(NotifyInner, tweenInfo, {
            Size = UDim2.new(1, 0, 1, 0),
        }):Play();
    else
        NotifyInner.Position = UDim2.fromOffset(TotalW, 0);
        TweenService:Create(NotifyInner, tweenInfo, {
            Position = UDim2.fromOffset(0, 0),
        }):Play();
    end;
end;

function Library:PlayNotificationExit(NotifyInner, TotalW, Callback)
    local animation = Library.NotificationAnimation or 'Slide Right to Left';
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
    local tween;

    if animation == 'Slide Left to Right' then
        tween = TweenService:Create(NotifyInner, tweenInfo, {
            Position = UDim2.fromOffset(TotalW, 0),
        });
    elseif animation == 'Middle Outwards' then
        NotifyInner.AnchorPoint = Vector2.new(0.5, 0.5);
        NotifyInner.Position = UDim2.new(0.5, 0, 0.5, 0);
        tween = TweenService:Create(NotifyInner, tweenInfo, {
            Size = UDim2.new(0, 0, 1, 0),
        });
    else
        tween = TweenService:Create(NotifyInner, tweenInfo, {
            Position = UDim2.fromOffset(-TotalW, 0),
        });
    end;

    tween.Completed:Connect(function()
        if Callback then
            Callback();
        end;
    end);
    tween:Play();
end

do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        AnchorPoint = Vector2.new(1, 0);
        Position = UDim2.new(1, -12, 0, 12);
        Size = UDim2.new(0, 480, 1, -24);
        ZIndex = 100;
        Parent = ScreenGui;
    });

    Library.NotificationListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, 6);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        VerticalAlignment = Enum.VerticalAlignment.Top;
        Parent = Library.NotificationArea;
    });

    Library.NotificationIndex = 0;
    Library:UpdateNotificationArea();

    local WatermarkOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0);
        BorderSizePixel = 0;
        Position = UDim2.new(0.5, 0, 0, 15);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    });

    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    });

    Library:AddToRegistry(WatermarkInner, {
        BackgroundColor3 = 'MainColor';
    });

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 202;
        Parent = WatermarkInner;
    });

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });

    local AccentLine = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 0, 1);
        ZIndex = 205;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(AccentLine, {
        BackgroundColor3 = 'AccentColor';
    });

    local WatermarkLabel = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -10, 1, -1);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Center;
        ZIndex = 203;
        Parent = InnerFrame;
    });

    Library.Watermark = WatermarkOuter;
    Library.WatermarkText = WatermarkLabel;
    Library:MakeDraggable(Library.Watermark);

    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 0, 0);
        Visible = false;
        ZIndex = 200;
        Parent = ScreenGui;
    });

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = KeybindContainer;
    });

    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5),
        Parent = KeybindContainer,
    });

    Library.KeybindContainer = KeybindContainer;
end;

function Library:SetWatermarkVisibility(Bool)
    Library.Watermark.Visible = Bool;
end;

function Library:SetWatermark(Text)
    local rawText = Text or '';
    Library.LastWatermarkText = rawText;

    local X, Y = Library:GetTextBounds(rawText, Library.Font, 14);
    Library.Watermark.Size = UDim2.new(0, X + 16, 0, (Y * 1.5) + 3);
    Library:SetAccentTitle(Library.WatermarkText, rawText, Library.WatermarkAccentPart or '.lol');
end;

local elisium_wm = { ping = true, executor = false, fps = true, time = true };
task.spawn(function()
    local fps = 60;
    local execName = nil;

    local function getPing()
        local ok, v = pcall(function()
            return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue();
        end);
        if ok and v then return math.floor(v + 0.5) end;
        return 0;
    end;

    local function getExecutor() return ''; end;

    RunService.RenderStepped:Connect(function(dt)
        if dt and dt > 0 then
            local instant = 1 / dt;
            fps = fps + (instant - fps) * 0.1;
        end;
    end));

    while task.wait(0.5) do
        if Library.Watermark and Library.Watermark.Visible then
            local wm = elisium_wm;
            local parts = { "Elisium.lol" };
            if wm.fps ~= false then
                parts[#parts + 1] = string.format("%d fps", math.floor(fps + 0.5));
            end;
            if wm.ping ~= false then
                parts[#parts + 1] = string.format("%d ms", getPing());
            end;
            if wm.executor then
                local ex = getExecutor();
                if ex ~= "" then parts[#parts + 1] = ex end;
            end;
            if wm.time ~= false then
                parts[#parts + 1] = os.date("%X");
            end;
            Library:SetWatermark(table.concat(parts, " | "));
        end;
    end;
end);

local SOUND_URLS = {
    Toggle = 'https://raw.githubusercontent.com/xhafodev/UI/main/pop%20UI%20sound.mp3',
    Notification = 'https://raw.githubusercontent.com/xhafodev/UI/main/notify.mp3',
    Slider = 'https://raw.githubusercontent.com/xhafodev/UI/main/slider.mp3',
};

function Library:EnsureSoundFile(Folder, FileName, Url)
    return nil;
end;

function Library:ApplySoundSettings(Settings)
    self.ToggleSoundEnabled = Settings.ToggleSoundEnabled ~= false;
    self.NotificationSoundEnabled = Settings.NotificationSoundEnabled ~= false;
    self.SliderSoundEnabled = Settings.SliderSoundEnabled ~= false;
    self.ToggleSoundVolume = math.clamp(tonumber(Settings.ToggleSoundVolume) or 1, 0, 1);
    self.ToggleSoundSpeed = math.clamp(tonumber(Settings.ToggleSoundSpeed) or 1, 0.25, 3);
    self.NotificationSoundVolume = math.clamp(tonumber(Settings.NotificationSoundVolume) or 1, 0, 1);
    self.NotificationSoundSpeed = math.clamp(tonumber(Settings.NotificationSoundSpeed) or 1, 0.25, 3);
    self.SliderSoundVolume = math.clamp(tonumber(Settings.SliderSoundVolume) or 1, 0, 1);
    self.SliderSoundSpeed = math.clamp(tonumber(Settings.SliderSoundSpeed) or 1, 0.25, 3);
end;

function Library:SaveSoundSettings()
    return;
end;

function Library:InitSoundSettings(Folder)
    local Settings = {
        ToggleSoundEnabled = true;
        NotificationSoundEnabled = true;
        SliderSoundEnabled = true;
        ToggleSoundVolume = 1;
        ToggleSoundSpeed = 1;
        NotificationSoundVolume = 1;
        NotificationSoundSpeed = 1;
        SliderSoundVolume = 1;
        SliderSoundSpeed = 1;
    };
    self.SoundSettingsFolder = Folder or 'elisium';
    self:ApplySoundSettings(Settings);
    self:InitSoundAssets();
end;

function Library:InitSoundAssets()
    self.ToggleSound = nil;
    self.NotificationSound = nil;
    self.SliderSound = nil;
end;

function Library:CreateWindow(...)
    local Arguments = { ... };
    local Config = { AnchorPoint = Vector2.zero };

    if type(...) == 'table' then
        Config = ...;
    else
        Config.Title = Arguments[1];
        Config.AutoShow = Arguments[2] or false;
    end;

    if type(Config.Title) ~= 'string' then Config.Title = 'No title' end;
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 10 end;
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end;

    if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end;
    if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(460, 400) end

    do
        local saved = Library._SavedWindowSize;
        if type(saved) == 'table' and tonumber(saved[1]) and tonumber(saved[2]) then
            Config.Size = UDim2.fromOffset(tonumber(saved[1]), tonumber(saved[2]));
        end;
    end;

    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5);
        Config.Position = UDim2.fromScale(0.5, 0.5);
    end;

    local Window = {
        Tabs = {};
    };

    Library.OverlayZIndexBase = nil;

    local Outer = Library:Create('Frame', {
        AnchorPoint = Config.AnchorPoint,
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = false;
        Position = Config.Position,
        Size = Config.Size,
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
    });

    Window.Outer = Outer;
    Library.MainWindow = Window;

    Library:MakeDraggable(Outer, 25);

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderSizePixel = 0;
        ClipsDescendants = false;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = Outer;
    });

    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
    });

    do
        local UIS = game:GetService('UserInputService');
        local MINW, MINH = 340, 300;
        Library.MainWindowOuter = Outer;
        local function persistSize()
            local s = Outer.AbsoluteSize;
            Library._SavedWindowSize = { math.floor(s.X), math.floor(s.Y) };
        end;
        function Library:GetWindowSize()
            local s = Outer.AbsoluteSize;
            return math.floor(s.X), math.floor(s.Y);
        end;
        function Library:SetWindowSize(x, y)
            x, y = tonumber(x), tonumber(y);
            if not (x and y) then return end;
            Outer.Size = UDim2.fromOffset(math.max(MINW, x), math.max(MINH, y));
            persistSize();
        end;

        local Handle = Library:Create('TextButton', {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -3, 1, -3),
            Size = UDim2.fromOffset(20, 20),
            BackgroundTransparency = 1,
            Text = '',
            AutoButtonColor = false,
            ZIndex = 60,
            Parent = Outer,
        });
        for i = 1, 3 do
            local grip = Library:Create('Frame', {
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, 0, 1, -(i - 1) * 4),
                Size = UDim2.fromOffset(4 + (i - 1) * 5, 2),
                BackgroundColor3 = Library.AccentColor,
                BorderSizePixel = 0,
                ZIndex = 61,
                Parent = Handle,
            });
            Library:AddToRegistry(grip, { BackgroundColor3 = 'AccentColor' });
        end;

        local resizing, startPos, startSize = false, nil, nil;
        Handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true;
                startPos = UIS:GetMouseLocation();
                startSize = Outer.AbsoluteSize;
            end;
        end);
        Library:GiveSignal(UIS.InputChanged:Connect(function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local cur = UIS:GetMouseLocation();
                local w = math.max(MINW, startSize.X + (cur.X - startPos.X));
                local h = math.max(MINH, startSize.Y + (cur.Y - startPos.Y));
                Outer.Size = UDim2.fromOffset(w, h);
            end;
        end));
        Library:GiveSignal(UIS.InputEnded:Connect(function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                resizing = false;
                persistSize();
            end;
        end));
    end;

    Window.ZIndexBase = 10;
    Window.GlowLayers = Library:CreateOverlayGlowLayers(Inner, 1);

    local AnimatedTopBar = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 5;
        Parent = Inner;
    });

    Library:AddToRegistry(AnimatedTopBar, {
        BackgroundColor3 = 'AccentColor';
    });

    local WindowLabel = Library:CreateLabel({
        Position = UDim2.new(0, 8, 0, 4);
        Size = UDim2.new(1, -16, 0, 22);
        Text = "";
        TextSize = 15;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 6;
        Parent = Inner;
    });

    local AccentPart = Config.AccentPart or '.lol';

    local function UpdateTitle()
        local rawTitle = Config.Title or "Elisium.lol";
        Library:SetAccentTitle(WindowLabel, rawTitle, AccentPart);
    end;

    Library.UpdateTitle = UpdateTitle;
    UpdateTitle();

    local MainSectionOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        ClipsDescendants = true;
        Position = UDim2.new(0, 8, 0, 30);
        Size = UDim2.new(1, -16, 1, -52);
        ZIndex = 1;
        Parent = Inner;
    });

    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = MainSectionOuter;
    });

    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor';
    });

    local TabArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        ClipsDescendants = false;
        Position = UDim2.new(0, 12, 0, 6);
        Size = UDim2.new(1, -24, 0, 22);
        ZIndex = 1;
        Parent = MainSectionInner;
    });

    Window.TabArea = TabArea;
    Window.TabPadding = Config.TabPadding;
    Window.TabEntries = {};
    Window.TabTextSize = 16;

    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, Config.TabPadding);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TabArea;
    });

    Window.TabListLayout = TabListLayout;

    function Window:UpdateTabLayout()
        if not self.TabArea or not self.TabEntries then
            return
        end;

        local Count = #self.TabEntries;
        if Count == 0 then
            return
        end;

        local AreaWidth = self.TabArea.AbsoluteSize.X;
        if AreaWidth <= 0 then
            return
        end;

        local Padding = self.TabPadding or 10;
        local SidePadding = 12;
        local BaseTextSize = self.TabTextSize or 16;
        local MinTextSize = 11;

        local TotalPadding = Padding * (Count - 1);
        local EqualWidth = math.max(24, math.floor((AreaWidth - TotalPadding) / Count));
        local AvailableTextWidth = EqualWidth - SidePadding * 2;

        local function LongestTextWidth(Size)
            local Longest = 0;
            for _, Entry in self.TabEntries do
                local Width = select(1, Library:GetTextBounds(Entry.Name, Library.Font, Size));
                Longest = math.max(Longest, Width);
            end;
            return Longest;
        end;

        local TextSize = BaseTextSize;
        if LongestTextWidth(TextSize) > AvailableTextWidth then
            for Size = BaseTextSize, MinTextSize, -1 do
                TextSize = Size;
                if LongestTextWidth(Size) <= AvailableTextWidth then
                    break;
                end;
            end;
        end;

        for _, Entry in self.TabEntries do
            Entry.Label.TextSize = TextSize;
            Entry.Button.Size = UDim2.new(0, EqualWidth, 1, 0);
        end;
    end;

    TabArea:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
        Window:UpdateTabLayout();
    end);

    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        ClipsDescendants = true;
        Position = UDim2.new(0, 8, 0, 32);
        Size = UDim2.new(1, -16, 1, -40);
        ZIndex = 3;
        Parent = MainSectionInner;
    });

    local placeName = 'Baseplate';
    pcall(function()
        placeName = game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name;
    end);

    Library.PlaceName = placeName;
    Library.AnonymousMode = false;

    local FooterLeft = Library:CreateLabel({
        Position = UDim2.new(0, 10, 1, -18);
        Size = UDim2.new(0.5, -10, 0, 14);
        Text = '';
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 6;
        Parent = Inner;
    });

    local FooterRight = Library:CreateLabel({
        Position = UDim2.new(0.5, 0, 1, -18);
        Size = UDim2.new(0.5, -10, 0, 14);
        Text = '';
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Right;
        ZIndex = 6;
        Parent = Inner;
    });

    Library.FooterLeft = FooterLeft;
    Library.FooterRight = FooterRight;
    Library:UpdateFooter();

    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    function Window:SetWindowTitle(Title, NewAccentPart)
        Config.Title = Title;
        if NewAccentPart then
            Config.AccentPart = NewAccentPart;
            AccentPart = NewAccentPart;
        end;
        UpdateTitle();
    end;

    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {};
            Tabboxes = {};
        };

        local defaultLayoutOrder = 100;
        if Name == 'Main' then
            defaultLayoutOrder = 1;
        elseif Name == 'Misc' then
            defaultLayoutOrder = 500;
        elseif Name:lower():find('setting') then
            defaultLayoutOrder = 1000;
        end;

        local TabButton = Library:Create('TextButton', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            AutoButtonColor = false;
            Size = UDim2.new(0, 0, 1, 0);
            Text = '';
            ZIndex = 2;
            LayoutOrder = defaultLayoutOrder;
            Parent = TabArea;
        });

        local TabButtonLabel = Library:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            Text = Name;
            TextSize = Window.TabTextSize or 16;
            TextColor3 = Color3.new(1, 1, 1);
            TextTransparency = 0.35;
            ZIndex = 3;
            Parent = TabButton;
        });

        Tab.TabButton = TabButton;
        Tab.TabButtonLabel = TabButtonLabel;
        Tab.Name = Name;

        table.insert(Window.TabEntries, {
            Name = Name;
            Button = TabButton;
            Label = TabButtonLabel;
        });

        task.defer(function()
            Window:UpdateTabLayout();
        end);

        local TabGlow, TabUnderline = Library:CreateTabBottomGlow(TabButton, {
            GlowHeight = 18;
            LineHeight = 2;
            ZIndex = 1;
        });

        Tab.TabGlow = TabGlow;
        Tab.TabUnderline = TabUnderline;

        local TabFrame = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            Visible = false;
            ZIndex = 4;
            Parent = TabContainer;
        });

        local LeftSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ClipsDescendants = true;
            Position = UDim2.new(0, 8 - 1, 0, 8 - 1);
            Size = UDim2.new(0.5, -12 + 2, 1, -16);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 3;
            ScrollBarImageColor3 = Library.AccentColor;
            ZIndex = 5;
            Parent = TabFrame;
        });

        local RightSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ClipsDescendants = true;
            Position = UDim2.new(0.5, 4 + 1, 0, 8 - 1);
            Size = UDim2.new(0.5, -12 + 2, 1, -16);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 3;
            ScrollBarImageColor3 = Library.AccentColor;
            ZIndex = 5;
            Parent = TabFrame;
        });

        Library:AddToRegistry(LeftSide, { ScrollBarImageColor3 = 'AccentColor' });
        Library:AddToRegistry(RightSide, { ScrollBarImageColor3 = 'AccentColor' });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = LeftSide;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = RightSide;
        });

        for _, Side in next, { LeftSide, RightSide } do
            Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y + 8);
            end);
        end;

        function Tab:ShowTab()
            for _, Tab in next, Window.Tabs do
                Tab:HideTab();
            end;

            Library:SetTabGlowVisible(TabGlow, TabUnderline, true);
            TabButtonLabel.TextTransparency = 0;
            TabFrame.Visible = true;

            for _, Groupbox in next, Tab.Groupboxes do
                if Groupbox.Resize then
                    Groupbox:Resize();
                end;
            end;
        end;

        function Tab:HideTab()
            Library:SetTabGlowVisible(TabGlow, TabUnderline, false);
            TabButtonLabel.TextTransparency = 0.35;
            TabFrame.Visible = false;
        end;

        function Tab:SetLayoutOrder(Position)
            TabButton.LayoutOrder = Position;
            TabListLayout:ApplyLayout();
        end;

        function Tab:AddGroupbox(Info)
            local Groupbox = {};
            local PreviousOverlayBase = Library.OverlayZIndexBase;
            Library.OverlayZIndexBase = nil;

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 507 + 2);
                ZIndex = 6;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 7;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 8;
                Parent = BoxInner;
            });

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            });

            local GroupboxLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 18);
                Position = UDim2.new(0, 4, 0, 2);
                TextSize = 14;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 9;
                Parent = BoxInner;
            });

            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 6, 0, 20);
                Size = UDim2.new(1, -8, 1, -20);
                ZIndex = 10;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Container;
            });

            local ListLayout = Container:FindFirstChildOfClass('UIListLayout');

            function Groupbox:Resize()
                local Size = 0;
                local SumSize = 0;
                local ChildCount = 0;

                for _, Element in next, Groupbox.Container:GetChildren() do
                    if (not Element:IsA('UIListLayout')) and Element.Visible then
                        ChildCount += 1;
                        SumSize += Element.Size.Y.Offset;
                    end;
                end;

                if ListLayout and ChildCount > 1 then
                    SumSize += ListLayout.Padding.Offset * (ChildCount - 1);
                end;

                if ListLayout then
                    Size = ListLayout.AbsoluteContentSize.Y;
                end;

                Size = math.max(Size, SumSize);

                BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 4);
            end;

            if ListLayout then
                ListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                    Groupbox:Resize();
                end);
            end;

            Groupbox.Container = Container;
            Groupbox.ContentBaseZIndex = 10;
            setmetatable(Groupbox, BaseGroupbox);

            Groupbox:AddBlank(3);
            Groupbox:Resize();

            Tab.Groupboxes[Info.Name] = Groupbox;

            Library.OverlayZIndexBase = PreviousOverlayBase;
            return Groupbox;
        end;

        function Tab:AddLeftGroupbox(Name)
            return Tab:AddGroupbox({ Side = 1; Name = Name; });
        end;

        function Tab:AddRightGroupbox(Name)
            return Tab:AddGroupbox({ Side = 2; Name = Name; });
        end;

        function Tab:AddTabbox(Info)
            local Tabbox = {
                Tabs = {};
            };

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 0);
                ZIndex = 6;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 7;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 0);
                Size = UDim2.new(1, 0, 0, 18);
                ZIndex = 8;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabboxButtons;
            });

            function Tabbox:AddTab(Name)
                local Tab = {};

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 6;
                    Parent = TabboxButtons;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    TextSize = 14;
                    Text = Name;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    ZIndex = 7;
                    Parent = Button;
                });

                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, 0);
                    Size = UDim2.new(1, 0, 0, 1);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });

                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor';
                });

                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 6, 0, 20);
                    Size = UDim2.new(1, -8, 1, -20);
                    ZIndex = 10;
                    Visible = false;
                    Parent = BoxInner;
                });

                local TabUnderline = Library:Create('Frame', {
                    BackgroundColor3 = Library.AccentColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 0, 0);
                    Size = UDim2.new(1, 0, 0, 2);
                    Visible = false;
                    ZIndex = 10;
                    Parent = Button;
                });

                Library:AddToRegistry(TabUnderline, {
                    BackgroundColor3 = 'AccentColor';
                });

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Container;
                });

                function Tab:Show()
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide();
                    end;

                    Container.Visible = true;
                    Block.Visible = true;
                    TabUnderline.Visible = true;

                    Button.BackgroundColor3 = Library.BackgroundColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';

                    Tab:Resize();
                end;

                function Tab:Hide()
                    Container.Visible = false;
                    Block.Visible = false;
                    TabUnderline.Visible = false;

                    Button.BackgroundColor3 = Library.MainColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                end;

                function Tab:Resize()
                    local TabCount = 0;

                    for _, Tab in next, Tabbox.Tabs do
                        TabCount = TabCount + 1;
                    end;

                    for _, Button in next, TabboxButtons:GetChildren() do
                        if not Button:IsA('UIListLayout') then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
                        end;
                    end;

                    if (not Container.Visible) then
                        return;
                    end;

                    local Size = 0;

                    for _, Element in next, Tab.Container:GetChildren() do
                        if (not Element:IsA('UIListLayout')) and Element.Visible then
                            Size = Size + Element.Size.Y.Offset;
                        end;
                    end;

                    BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
                end;

                Button.InputBegan:Connect(function(Input)
                    if IsPrimaryPress(Input) and not Library:MouseIsOverOpenedFrame() then
                        Tab:Show();
                        Tab:Resize();
                    end;
                end);

                Tab.Container = Container;
                Tabbox.Tabs[Name] = Tab;

                setmetatable(Tab, BaseGroupbox);
                Tab.ContentBaseZIndex = 10;

                Tab:AddBlank(3);
                Tab:Resize();

                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show();
                end;

                return Tab;
            end;

            Tab.Tabboxes[Info.Name or ''] = Tabbox;

            return Tabbox;
        end;

        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 1; });
        end;

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 2; });
        end;

        TabButton.MouseButton1Click:Connect(function()
            Tab:ShowTab();
        end);

        if #TabContainer:GetChildren() == 1 then
            Tab:ShowTab();
        end;

        Window.Tabs[Name] = Tab;
        return Tab;
    end;

    local ModalElement = Library:Create('TextButton', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 0, 0, 0);
        Visible = true;
        Text = '';
        Modal = false;
        Parent = ScreenGui;
    });

    local TransparencyCache = {};
    local Toggled = false;

    function Library:Toggle()
        Toggled = not Toggled;

        Library.MenuOpen = Toggled;
        ModalElement.Modal = Toggled;

        Outer.Visible = Toggled;

        Library:SyncOverlaysWithMenu(Toggled);
        Library:UpdateMenuBlur();
        Library:UpdateOverlayGlow(Library.MainWindow);

        if Library.OnToggle then
            task.spawn(Library.OnToggle, Toggled);
        end;
    end;

    Library.MenuBindPickers = Library.MenuBindPickers or {};

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
        local pressed;
        if Input.UserInputType == Enum.UserInputType.Keyboard then
            pressed = Input.KeyCode.Name;
        elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
            pressed = 'MB1';
        elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
            pressed = 'MB2';
        end;

        if not pressed then
            return
        end;

        local pickers = Library.MenuBindPickers or {};
        local bound = false;
        for _, picker in eli_ipairs(pickers) do
            if picker and picker.Value and picker.Value ~= 'None' then
                bound = true;
                if picker.Value == pressed then
                    task.spawn(Library.Toggle);
                    return
                end;
            end;
        end;

        if not bound and Input.KeyCode == Enum.KeyCode.RightShift then
            task.spawn(Library.Toggle);
        end;
    end));

    if Config.AutoShow then
        task.spawn(function()
            Library:Toggle();
            Library:UpdateMenuBlur();
        end);
    end;

    Window.Holder = Outer;

    return Window;
end;

local function OnPlayerChange()
    local PlayerList = GetPlayersString();

    for _, Value in next, Options do
        if Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
            Value:SetValues(PlayerList);
        end;
    end;
end;

Players.PlayerAdded:Connect(OnPlayerChange);
Players.PlayerRemoving:Connect(OnPlayerChange);

Library.Toggles = Toggles;
Library.Options = Options;


return Library;
end)();
