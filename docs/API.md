# Elisium API Reference

This reference documents the public API visible in the extracted `Elisium.lua` source. It intentionally follows the source rather than inventing a new API.

## `Library:CreateWindow(...)`

Two calling forms are supported by the source.

### Simple form

```lua
local Window = Library:CreateWindow("My UI", true)
```

- Argument 1: title string
- Argument 2: `AutoShow` boolean

### Configuration form

```lua
local Window = Library:CreateWindow({
    Title = "My UI",
    AutoShow = true,
    Center = true,
    Size = UDim2.fromOffset(520, 420),
    Position = UDim2.fromOffset(175, 50),
    TabPadding = 10,
    MenuFadeTime = 0.2,
})
```

The source defaults `Size` to `460 × 400`, `Position` to `(175, 50)`, `TabPadding` to `10`, and `MenuFadeTime` to `0.2` when those values are not supplied.

`Center = true` changes the window to a centered `AnchorPoint`/position.

## Window methods

### `Window:AddTab(Name)`

Creates and returns a tab.

```lua
local Main = Window:AddTab("Main")
```

### `Window:SetWindowTitle(Title, NewAccentPart)`

Changes the window title. The optional second argument controls the accent portion used by the title formatter.

```lua
Window:SetWindowTitle("My UI", ".lol")
```

### `Window:SetLayoutOrder(Position)`

This method belongs to tabs, not windows. See the Tab section below.

## Tab methods

### `Tab:AddGroupbox(Info)`

```lua
local Box = Tab:AddGroupbox({
    Side = 1,
    Name = "Settings",
})
```

`Side = 1` places the groupbox on the left; `Side = 2` places it on the right.

### `Tab:AddLeftGroupbox(Name)`

```lua
local Box = Tab:AddLeftGroupbox("Settings")
```

### `Tab:AddRightGroupbox(Name)`

```lua
local Box = Tab:AddRightGroupbox("Settings")
```

### `Tab:AddTabbox(Info)`

Creates a nested tabbox. The source accepts a side value similar to groupboxes.

### `Tab:AddLeftTabbox(Name)` / `Tab:AddRightTabbox(Name)`

Convenience methods for placing a tabbox on the left or right.

### `Tab:SetLayoutOrder(Position)`

Changes the tab's layout order.

### `Tab:ShowTab()` / `Tab:HideTab()`

Shows or hides the tab content and updates its active visual state.

## Groupbox controls

Controls are generally created with an index plus an options table.

### `AddLabel(Text, DoesWrap)`

```lua
Box:AddLabel("Hello")
```

### `AddBlank(Size)`

Adds vertical spacing.

```lua
Box:AddBlank(5)
```

### `AddDivider()`

Adds a divider.

### `AddButton(...)`

Creates a button. The source supports a callback configuration and also exposes `Button:AddButton(...)` for nested buttons.

A common form is:

```lua
Box:AddButton("Click me", function()
    print("clicked")
end)
```

Because the source accepts multiple button argument forms, inspect the `AddButton` implementation if you need an uncommon signature.

### `AddInput(Idx, Info)`

```lua
Box:AddInput("NameInput", {
    Text = "Name",
    Default = "Player",
    Callback = function(Value)
        print(Value)
    end,
})
```

The returned input supports `SetValue` and `OnChanged`.

### `AddToggle(Idx, Info)`

```lua
local Toggle = Box:AddToggle("Enabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value)
        print(Value)
    end,
})
```

Important options present in the source include:

- `Text`
- `Default`
- `Callback`
- `Risky`
- `BlankSize`

The source also supports attaching a key picker and color picker to controls.

### `AddSlider(Idx, Info)`

```lua
local Slider = Box:AddSlider("Amount", {
    Text = "Amount",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        print(Value)
    end,
})
```

Required source fields:

- `Default`
- `Text`
- `Min`
- `Max`
- `Rounding`

Additional source option:

- `Compact`

### `AddRangeSlider(Idx, Info)`

Creates a two-ended range slider. Its callback receives lower and upper values.

```lua
Box:AddRangeSlider("Range", {
    Text = "Range",
    Default = {10, 50},
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Lower, Upper)
        print(Lower, Upper)
    end,
})
```

The exact accepted default/table fields should be checked against the source implementation if using advanced range-slider options.

### `AddDropdown(Idx, Info)`

```lua
Box:AddDropdown("Mode", {
    Text = "Mode",
    Values = {"One", "Two", "Three"},
    Default = "One",
    Callback = function(Value)
        print(Value)
    end,
})
```

Source options include:

- `Values`
- `Default`
- `AllowNull`
- `Multi`
- `Text`
- `Compact`
- `SpecialType`

`SpecialType = "Player"` and `SpecialType = "Team"` are handled specially by the source.

### `AddKeyPicker(Idx, Info)`

```lua
Box:AddKeyPicker("Key", {
    Default = "F",
    Mode = "Toggle",
    Callback = function(Value)
        print(Value)
    end,
})
```

Source options include:

- `Default` (required)
- `Mode`
- `Callback`
- `ChangedCallback`
- `SyncToggleState`
- `Modes`

### `AddColorPicker(Idx, Info)`

```lua
Box:AddColorPicker("Color", {
    Title = "Color",
    Default = Color3.fromRGB(255, 255, 255),
    Transparency = 0,
    Callback = function(Color)
        print(Color)
    end,
})
```

`Default` is required by the source.

### `AddDependencyBox()`

Creates a dependency container that can be shown/hidden based on other controls. The library updates dependency boxes through `Library:UpdateDependencyBoxes()`.

## Control state

Indexed controls are stored in:

```lua
Library.Toggles[Index]
Library.Options[Index]
```

For example:

```lua
local Toggle = Library.Toggles.Enabled
print(Toggle.Value)
Toggle:SetValue(true)
```

The exact state fields depend on the control type.

## Library helpers

The extracted source exposes the following notable public methods.

### Lifecycle

```lua
Library:Unload()
Library:OnUnload(Callback)
Library:GiveSignal(Signal)
```

### Notifications

```lua
Library:Notify("Hello", 3)
Library:SetNotificationSpot(Spot)
Library:SetNotificationAnimation(Animation)
```

### Watermark

```lua
Library:SetWatermark("My UI")
Library:SetWatermarkVisibility(true)
```

### Window size

```lua
local Width, Height = Library:GetWindowSize()
Library:SetWindowSize(600, 450)
```

The source enforces a minimum window size of `340 × 300`.

### Theme / appearance

```lua
Library:SetUIFont(Name)
Library:LoadUIFont(Name)
Library:ApplyFontToAll()
Library:UpdateColorsUsingRegistry()
Library:SetOverlayGlowEnabled(true)
Library:SetOverlayGlowColor(Color3.fromRGB(255, 255, 255))
```

Theme color fields include `AccentColor`, `MainColor`, `BackgroundColor`, `OutlineColor`, `FontColor`, and related derived colors.

## Important implementation note

This is documentation for the extracted source, not a promise that every executor exposes every optional API used by the original implementation. For a Studio-native library, the source should be ported to a normal `ModuleScript` architecture and executor-specific calls should be removed or abstracted behind a compatibility layer.
