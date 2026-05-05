# GoldChains UI Library

An ImGui-inspired UI library for Roblox executors with a modern, clean design.

![Version](https://img.shields.io/badge/version-1.0-blue)
![Roblox](https://img.shields.io/badge/platform-roblox-red)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- 🎨 **10 Built-in Themes** - Default, Dark, Midnight, Ocean, Forest, Sunset, Light, Cyberpunk, Monokai, Dracula
- 💾 **Save Manager** - Automatic configuration saving/loading with JSON persistence
- 🎯 **Theme Manager** - Custom theme creation, import/export, and live switching
- ⚡ **Smooth Animations** - Tween-based UI transitions
- 🔧 **Fully Modular** - Use only what you need
- 📱 **Drag & Resize** - Draggable windows with minimize support

## Components

| Component | Description |
|-----------|-------------|
| `Window` | Main container with title bar, tabs, and controls |
| `Tab` | Organized sections within the window |
| `Toggle` | On/off switches with smooth animations |
| `Slider` | Value selectors with customizable ranges |
| `Button` | Clickable actions with hover effects |
| `Textbox` | Text input fields with placeholders |
| `Dropdown` | Option selectors with scrollable lists |
| `Keybind` | Key input capture for hotkeys |
| `Colorpicker` | Color selection with preset palette |
| `Label` | Static text display |
| `Section` | Visual grouping headers |
| `Separator` | Horizontal dividing lines |

## Quick Start

```lua
-- Load the library
local UI_LIBRARY = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/goldchainss/main/src/uilibrary.lua"))()

-- Create a window
local Window = UI_LIBRARY.new({
    Title = "My Script",
    Width = 600,
    Height = 400
})

-- Add a tab
local MainTab = Window:AddTab("Main", "⚡")

-- Add elements
MainTab:AddToggle("ESP", false, function(enabled)
    print("ESP:", enabled)
end)

MainTab:AddSlider("Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

MainTab:AddButton("Click Me", function()
    print("Button clicked!")
end)
```

## File Structure

```
goldchainss/
├── README.md
├── LICENSE
├── src/
│   ├── uilibrary.lua      -- Main UI library
│   ├── savemanager.lua    -- Configuration persistence
│   └── thememanager.lua   -- Theme system
└── examples/
    └── example.lua        -- Full usage demonstration
```

## Save Manager

```lua
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/goldchainss/main/src/savemanager.lua"))()

local SaveMgr = SaveManager.new({
    ConfigFolder = "MyScriptConfigs",
    AutoSave = true,
    AutoSaveInterval = 120
}):SetLibrary(Window)

-- Register elements for auto-saving
SaveMgr:RegisterOption("esp_enabled", ESPToggle, "toggle", false)
SaveMgr:RegisterOption("walkspeed", SpeedSlider, "slider", 16)

-- Manual save/load
SaveMgr:Save("myconfig")
SaveMgr:Load("myconfig")
```

## Theme Manager

```lua
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/goldchainss/main/src/thememanager.lua"))()

local ThemeMgr = ThemeManager.new():SetLibrary(Window)

-- Apply a theme
ThemeMgr:ApplyTheme("Dark")
ThemeMgr:ApplyTheme("Cyberpunk")

-- Create custom theme
ThemeMgr:CreateTheme("MyTheme", "Default", {
    Accent = {R = 255, G = 100, B = 100}
})

-- Rainbow accent effect
ThemeMgr:CreateRainbowEffect(0.5)
```

## Available Themes

| Theme | Preview |
|-------|---------|
| Default | Blurple accent on dark gray |
| Dark | Muted grays with soft accent |
| Midnight | Deep purple-tinted dark |
| Ocean | Blue-green underwater feel |
| Forest | Natural green tones |
| Sunset | Warm orange-red accent |
| Light | Clean light theme |
| Cyberpunk | Neon cyan/magenta on black |
| Monokai | Code editor inspired |
| Dracula | Popular dark theme |

## Executor Compatibility

- ✅ Synapse X
- ✅ KRNL
- ✅ Script-Ware
- ✅ Fluxus
- ✅ Electron
- ✅ Oxygen U
- ✅ Most modern executors

## API Reference

### Window Methods

| Method | Description |
|--------|-------------|
| `Window.new(options)` | Create a new window |
| `Window:AddTab(name, icon)` | Add a tab to the window |
| `Window:SetTheme(theme)` | Apply a color theme |
| `Window:Notify(title, msg, duration, type)` | Show notification |
| `Window:Show()` / `Window:Hide()` | Toggle visibility |
| `Window:Destroy()` | Remove the UI |

### Element Methods

| Element | Get/Set Methods |
|---------|-----------------|
| Toggle | `GetValue()`, `SetValue(bool)` |
| Slider | `GetValue()`, `SetValue(number)` |
| Textbox | `GetText()`, `SetText(string)` |
| Dropdown | `GetSelected()`, `SetOptions(table)` |
| Colorpicker | `GetColor()`, `SetColor(Color3)` |
| Keybind | `GetKey()` |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Credits

Created for the Roblox scripting community.

Inspired by Dear ImGui design patterns.
