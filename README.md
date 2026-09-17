# Elisium UI Library

A standalone extraction of the embedded **Elisium** Roblox UI library from the supplied source. The library provides windows, tabs, groupboxes, tabboxes, toggles, sliders, range sliders, dropdowns, inputs, key pickers, color pickers, buttons, notifications, theming, overlays, and related UI helpers.

> **Important:** This is an executor-oriented Roblox UI library, not a normal Roblox Studio `ModuleScript`. The original library uses executor-specific APIs for some optional features (for example `getgenv`, `cloneref`, filesystem APIs, custom fonts/assets, and GUI protection). See [Compatibility](#compatibility).

## Repository layout

```text
Elisium-UI-Library/
├── Elisium.lua             # The extracted UI library
├── README.md               # Quick start and overview
├── LICENSE                 # MIT license for this repository packaging
├── docs/
│   └── API.md              # API reference and configuration notes
└── examples/
    └── Basic.lua           # Minimal UI example
```

## Quick start

The library returns a `Library` object. Create a window, add tabs, then add groupboxes and controls.

```lua
local Library = loadstring(readfile("Elisium.lua"))()

local Window = Library:CreateWindow({
    Title = "My UI",
    Center = true,
    AutoShow = true,
    Size = UDim2.fromOffset(520, 420),
})

local Main = Window:AddTab("Main")
local Box = Main:AddLeftGroupbox("Example")

Box:AddLabel("Hello from Elisium")

Box:AddToggle("ExampleToggle", {
    Text = "Enable feature",
    Default = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end,
})

Box:AddSlider("ExampleSlider", {
    Text = "Amount",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        print("Slider:", Value)
    end,
})
```

If your environment supports loading the file from a URL, the same returned `Library` object can be used after your own approved source-loading mechanism fetches `Elisium.lua`.

## Core flow

The normal structure is:

```text
Library
└── Window
    └── Tab
        ├── Left Groupbox
        │   └── Controls
        └── Right Groupbox
            └── Controls
```

For example:

```lua
local Window = Library:CreateWindow("My UI", true)
local Tab = Window:AddTab("Main")
local Groupbox = Tab:AddLeftGroupbox("Settings")
```

## Controls

The groupbox API includes:

- `AddLabel`
- `AddButton`
- `AddInput`
- `AddToggle`
- `AddSlider`
- `AddRangeSlider`
- `AddDropdown`
- `AddKeyPicker`
- `AddColorPicker`
- `AddDivider`
- `AddBlank`
- `AddDependencyBox`

See [`docs/API.md`](docs/API.md) for signatures and options taken from the source.

## Global state

The library exposes:

```lua
Library.Toggles
Library.Options
```

Controls registered with an index can therefore be accessed later:

```lua
Library.Toggles.ExampleToggle:SetValue(true)
print(Library.Toggles.ExampleToggle.Value)
```

Exact members vary by control type; consult the API reference before relying on a method.

## Cleanup

When the UI is no longer needed:

```lua
Library:Unload()
```

You can also register cleanup logic with:

```lua
Library:OnUnload(function()
    print("Elisium unloaded")
end)
```

## Compatibility

The extracted source references the following Roblox/executor facilities:

### Roblox APIs

- `game:GetService(...)`
- `Players.LocalPlayer`
- `UserInputService`
- `RunService`
- Roblox GUI instances and enums

### Optional executor/environment APIs used by the source

- `getgenv`
- `cloneref`
- `protectgui` / `syn.protect_gui`
- `writefile`, `readfile`, `isfile`, `isfolder`, `makefolder`
- `getcustomasset`
- `identifyexecutor` / `getexecutorname`
- `setclipboard`

Several of these are guarded with `pcall`/existence checks, so not every feature requires every API. The source is kept intact rather than rewritten into a Studio-only library.

## Customization

The library exposes theme-related values such as:

```lua
Library.AccentColor
Library.MainColor
Library.BackgroundColor
Library.OutlineColor
Library.FontColor
```

The source also contains font helpers, gradient/accent title helpers, notifications, watermark controls, overlay helpers, and window sizing functions. See the API reference for the available public methods.

## Notes about this release

- `Elisium.lua` is the extracted embedded library supplied in the original source; the implementation was not rewritten into a different UI framework.
- The companion `ThemeManager` from the original source was **not** included because it was outside the embedded `Library` block that was extracted.
- The library contains some source-specific persistence and overlay functionality. If you want a clean public library intended for Roblox Studio, a separate compatibility rewrite would be preferable rather than silently changing this extracted implementation.
