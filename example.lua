-- Example Script for ImGui-Inspired UI Library
-- Demonstrates all features of the UI Library, SaveManager, and ThemeManager

-- Load modules (adjust paths as needed for your executor)
local UI_LIBRARY = loadstring(readfile("uilibrary.lua"))()
local SaveManager = loadstring(readfile("savemanager.lua"))()
local ThemeManager = loadstring(readfile("thememanager.lua"))()

-- ============================================
-- CREATE MAIN WINDOW
-- ============================================
local Window = UI_LIBRARY.new({
    Title = "My Awesome Script",
    Width = 700,
    Height = 500,
    Theme = {
        Background = Color3.fromRGB(25, 25, 30),
        BackgroundSecondary = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(88, 101, 242),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(50, 50, 55),
        Success = Color3.fromRGB(46, 204, 113),
        Error = Color3.fromRGB(231, 76, 60),
        Warning = Color3.fromRGB(241, 196, 15)
    }
})

-- ============================================
-- SETUP SAVE MANAGER
-- ============================================
local SaveMgr = SaveManager.new({
    ConfigFolder = "MyScriptConfigs",
    AutoSave = true,
    AutoSaveInterval = 120 -- Save every 2 minutes
}):SetLibrary(Window)

-- ============================================
-- SETUP THEME MANAGER
-- ============================================
local ThemeMgr = ThemeManager.new({
    SaveFolder = "MyScriptThemes",
    AutoApply = true
}):SetLibrary(Window)

-- Apply theme if one was saved
ThemeMgr:ApplyTheme(ThemeMgr:GetCurrentThemeName())

-- ============================================
-- MAIN TAB - CORE FEATURES
-- ============================================
local MainTab = Window:AddTab("Main", "⚡")

MainTab:AddSection("Player Modifications")

-- Speed Modifier
local SpeedSlider = MainTab:AddSlider("Walk Speed", 16, 200, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
SaveMgr:RegisterOption("walkspeed", SpeedSlider, "slider", 16)

-- Jump Power
local JumpSlider = MainTab:AddSlider("Jump Power", 50, 300, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)
SaveMgr:RegisterOption("jumppower", JumpSlider, "slider", 50)

MainTab:AddSeparator()
MainTab:AddSection("Visuals")

-- ESP Toggle
local ESPToggle = MainTab:AddToggle("Player ESP", false, function(enabled)
    if enabled then
        -- ESP Logic here
        print("ESP Enabled")
        Window:Notify("ESP", "Player ESP has been enabled", 3, "success")
    else
        print("ESP Disabled")
    end
end)
SaveMgr:RegisterOption("esp_enabled", ESPToggle, "toggle", false)

-- Fullbright
local FullbrightToggle = MainTab:AddToggle("Fullbright", false, function(enabled)
    if enabled then
        game.Lighting.Brightness = 2
        game.Lighting.GlobalShadows = false
    else
        game.Lighting.Brightness = 1
        game.Lighting.GlobalShadows = true
    end
end)
SaveMgr:RegisterOption("fullbright", FullbrightToggle, "toggle", false)

-- ESP Color
local ESPColor = MainTab:AddColorpicker("ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    print("ESP Color changed:", color)
end)
SaveMgr:RegisterOption("esp_color", ESPColor, "colorpicker", Color3.fromRGB(255, 0, 0))

MainTab:AddSeparator()

-- Execute Button
MainTab:AddButton("Print Player Info", function()
    local player = game.Players.LocalPlayer
    print("Player:", player.Name)
    print("UserId:", player.UserId)
    print("Health:", player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health or "N/A")
    Window:Notify("Info", "Player information printed to console", 3, "info")
end)

-- ============================================
-- TELEPORT TAB
-- ============================================
local TPTab = Window:AddTab("Teleport", "📍")

TPTab:AddSection("Quick Teleports")

-- Teleport to player textbox
local TPTarget = TPTab:AddTextbox("Target Player", "Enter username...", function(text)
    local target = game.Players:FindFirstChild(text)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        Window:Notify("Teleport", "Teleported to " .. text, 3, "success")
    else
        Window:Notify("Error", "Player not found!", 3, "error")
    end
end)

TPTab:AddSeparator()

-- Location Dropdown
local locations = {"Spawn", "Shop", "Boss Arena", "Secret Room", "Roof"}
local TPLocation = TPTab:AddDropdown("Select Location", locations, function(selected)
    print("Selected location:", selected)
    -- Implement actual teleport coordinates here
    Window:Notify("Teleport", "Teleporting to " .. selected .. "...", 2, "info")
end)
SaveMgr:RegisterOption("tp_location", TPLocation, "dropdown", "Spawn")

TPTab:AddButton("Teleport to Location", function()
    local selected = TPLocation:GetSelected()
    print("Teleporting to:", selected)
end)

-- ============================================
-- SETTINGS TAB - SAVE/LOAD/THEMES
-- ============================================
local SettingsTab = Window:AddTab("Settings", "⚙️")

SettingsTab:AddSection("Configuration")

-- Config Name Input
local ConfigName = SettingsTab:AddTextbox("Config Name", "default", function(text)
    -- Just stores the name, doesn't save yet
end)

SettingsTab:AddButton("Save Config", function()
    local name = ConfigName:GetText()
    local success = SaveMgr:Save(name)
    if success then
        Window:Notify("Config Saved", "Configuration saved as '" .. name .. "'", 3, "success")
    else
        Window:Notify("Error", "Failed to save config!", 3, "error")
    end
end)

SettingsTab:AddButton("Load Config", function()
    local name = ConfigName:GetText()
    local success = SaveMgr:Load(name)
    if success then
        Window:Notify("Config Loaded", "Configuration '" .. name .. "' loaded", 3, "success")
    else
        Window:Notify("Error", "Config not found!", 3, "error")
    end
end)

SettingsTab:AddButton("Reset to Defaults", function()
    SaveMgr:ResetToDefaults()
    Window:Notify("Reset", "All settings reset to defaults", 3, "warning")
end)

SettingsTab:AddSeparator()
SettingsTab:AddSection("Theme Customization")

-- Theme Dropdown
local themeList = ThemeMgr:ListThemes()
local ThemeDropdown = SettingsTab:AddDropdown("Select Theme", themeList, function(selected)
    ThemeMgr:ApplyTheme(selected)
    Window:Notify("Theme Changed", "Applied theme: " .. selected, 3, "info")
end)

-- Rainbow Effect Toggle
local RainbowToggle = SettingsTab:AddToggle("Rainbow Accent", false, function(enabled)
    if enabled then
        -- Start rainbow effect
        _G.RainbowConnection = ThemeMgr:CreateRainbowEffect(0.5)
    else
        if _G.RainbowConnection then
            _G.RainbowConnection:Disconnect()
            _G.RainbowConnection = nil
        end
        -- Re-apply current theme to reset
        ThemeMgr:ApplyTheme()
    end
end)

SettingsTab:AddSeparator()
SettingsTab:AddSection("Keybinds")

-- Menu Toggle Keybind
local MenuKeybind = SettingsTab:AddKeybind("Toggle Menu", Enum.KeyCode.RightShift, function(key)
    Window.MainFrame.Visible = not Window.MainFrame.Visible
end)

-- Quick Noclip Keybind
SettingsTab:AddKeybind("Quick Noclip", Enum.KeyCode.N, function()
    print("Noclip toggled!")
    -- Noclip logic here
end)

SettingsTab:AddSeparator()
SettingsTab:AddSection("Miscellaneous")

-- FPS Display Toggle
local FPSToggle = SettingsTab:AddToggle("Show FPS", false, function(enabled)
    if enabled then
        -- Create FPS counter
        _G.FPSLabel = Instance.new("TextLabel")
        _G.FPSLabel.Name = "FPSCounter"
        _G.FPSLabel.Size = UDim2.new(0, 100, 0, 25)
        _G.FPSLabel.Position = UDim2.new(0, 10, 0, 10)
        _G.FPSLabel.BackgroundTransparency = 1
        _G.FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.FPSLabel.TextStrokeTransparency = 0.5
        _G.FPSLabel.Font = Enum.Font.GothamBold
        _G.FPSLabel.TextSize = 14
        _G.FPSLabel.Parent = Window.ScreenGui
        
        -- FPS counter loop
        task.spawn(function()
            while _G.FPSLabel and _G.FPSLabel.Parent do
                local fps = math.round(1 / game:GetService("RunService").RenderStepped:Wait())
                _G.FPSLabel.Text = "FPS: " .. fps
                task.wait(0.5)
            end
        end)
    else
        if _G.FPSLabel then
            _G.FPSLabel:Destroy()
            _G.FPSLabel = nil
        end
    end
end)

SettingsTab:AddButton("Copy Discord Invite", function()
    if setclipboard then
        setclipboard("discord.gg/example")
        Window:Notify("Copied!", "Discord invite copied to clipboard", 3, "success")
    end
end)

SettingsTab:AddButton("Destroy UI", function()
    Window:Destroy()
    if _G.RainbowConnection then
        _G.RainbowConnection:Disconnect()
    end
    if _G.FPSLabel then
        _G.FPSLabel:Destroy()
    end
end)

-- ============================================
-- ABOUT TAB
-- ============================================
local AboutTab = Window:AddTab("About", "ℹ️")

AboutTab:AddLabel("My Awesome Script v1.0")
AboutTab:AddLabel("Made by: YourName")
AboutTab:AddLabel("")
AboutTab:AddLabel("Features:")
AboutTab:AddLabel("• Player ESP & Visuals")
AboutTab:AddLabel("• Teleport System")
AboutTab:AddLabel("• WalkSpeed & JumpPower")
AboutTab:AddLabel("• Theme Customization")
AboutTab:AddLabel("• Config Save/Load")
AboutTab:AddLabel("")
AboutTab:AddLabel("Executor Compatibility:")
AboutTab:AddLabel("• Synapse X")
AboutTab:AddLabel("• KRNL")
AboutTab:AddLabel("• Script-Ware")
AboutTab:AddLabel("• Fluxus")
AboutTab:AddLabel("& more...")

-- ============================================
-- INITIALIZATION
-- ============================================

-- Try to load default config on startup
if SaveMgr:ConfigExists("default") then
    SaveMgr:Load("default")
    Window:Notify("Auto-Load", "Loaded default configuration", 3, "info")
else
    Window:Notify("Welcome!", "Script loaded successfully", 3, "success")
end

-- ============================================
-- GAME SPECIFIC EXAMPLES (Uncomment as needed)
-- ============================================

--[[
-- Arsenal Example
local ArsenalTab = Window:AddTab("Arsenal", "🔫")
ArsenalTab:AddToggle("Silent Aim", false, function(v) end)
ArsenalTab:AddToggle("No Recoil", false, function(v) end)
ArsenalTab:AddToggle("Infinite Ammo", false, function(v) end)
ArsenalTab:AddDropdown("Aim Part", {"Head", "Torso", "Random"}, function(v) end)
--]]

--[[
-- Blox Fruits Example
local BloxTab = Window:AddTab("Blox Fruits", "🍎")
BloxTab:AddToggle("Auto Farm", false, function(v) end)
BloxTab:AddToggle("Auto Quest", false, function(v) end)
BloxTab:AddDropdown("Select Weapon", {"Sword", "Fruit", "Fighting Style"}, function(v) end)
BloxTab:AddSlider("Farm Distance", 10, 100, 20, function(v) end)
--]]

--[[
-- Doors Example
local DoorsTab = Window:AddTab("Doors", "🚪")
DoorsTab:AddToggle("ESP Entities", false, function(v) end)
DoorsTab:AddToggle("ESP Items", false, function(v) end)
DoorsTab:AddToggle("No Screech", false, function(v) end)
DoorsTab:AddToggle("Instant Interact", false, function(v) end)
--]]

print("UI Library Example Script Loaded!")
print("Available configs:", table.concat(SaveMgr:ListConfigs(), ", "))
print("Current theme:", ThemeMgr:GetCurrentThemeName())
