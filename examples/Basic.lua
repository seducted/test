-- Basic Elisium UI example
-- Run in an environment compatible with the library.

local Library = loadstring(readfile("Elisium.lua"))()

local Window = Library:CreateWindow({
    Title = "Example UI",
    Center = true,
    AutoShow = true,
    Size = UDim2.fromOffset(520, 420),
})

local Main = Window:AddTab("Main")
local Left = Main:AddLeftGroupbox("Controls")
local Right = Main:AddRightGroupbox("Other")

Left:AddLabel("Elisium UI Library")

Left:AddToggle("Enabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value)
        print("Enabled:", Value)
    end,
})

Left:AddSlider("Amount", {
    Text = "Amount",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        print("Amount:", Value)
    end,
})

Right:AddDropdown("Mode", {
    Text = "Mode",
    Values = { "One", "Two", "Three" },
    Default = "One",
    Callback = function(Value)
        print("Mode:", Value)
    end,
})

Right:AddButton("Notify", function()
    Library:Notify("Hello from Elisium", 3)
end)
