-- Theme Manager for Roblox Executor UI Library
-- Handles theme customization, switching, and persistence

local ThemeManager = {}
ThemeManager.__index = ThemeManager

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Predefined themes
local THEMES = {
    Default = {
        Background = Color3.fromRGB(25, 25, 30),
        BackgroundSecondary = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(88, 101, 242),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(50, 50, 55),
        Success = Color3.fromRGB(46, 204, 113),
        Error = Color3.fromRGB(231, 76, 60),
        Warning = Color3.fromRGB(241, 196, 15)
    },
    
    Dark = {
        Background = Color3.fromRGB(18, 18, 22),
        BackgroundSecondary = Color3.fromRGB(28, 28, 32),
        Accent = Color3.fromRGB(114, 137, 218),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 150),
        Border = Color3.fromRGB(40, 40, 45),
        Success = Color3.fromRGB(46, 204, 113),
        Error = Color3.fromRGB(231, 76, 60),
        Warning = Color3.fromRGB(241, 196, 15)
    },
    
    Midnight = {
        Background = Color3.fromRGB(15, 15, 25),
        BackgroundSecondary = Color3.fromRGB(25, 25, 40),
        Accent = Color3.fromRGB(100, 80, 200),
        Text = Color3.fromRGB(240, 240, 255),
        TextSecondary = Color3.fromRGB(160, 160, 180),
        Border = Color3.fromRGB(40, 40, 60),
        Success = Color3.fromRGB(50, 220, 130),
        Error = Color3.fromRGB(255, 80, 80),
        Warning = Color3.fromRGB(255, 200, 50)
    },
    
    Ocean = {
        Background = Color3.fromRGB(20, 30, 40),
        BackgroundSecondary = Color3.fromRGB(30, 45, 60),
        Accent = Color3.fromRGB(0, 150, 200),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(160, 180, 200),
        Border = Color3.fromRGB(40, 55, 70),
        Success = Color3.fromRGB(50, 220, 150),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 220, 80)
    },
    
    Forest = {
        Background = Color3.fromRGB(20, 35, 25),
        BackgroundSecondary = Color3.fromRGB(30, 50, 35),
        Accent = Color3.fromRGB(60, 180, 100),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(160, 190, 170),
        Border = Color3.fromRGB(40, 65, 45),
        Success = Color3.fromRGB(80, 230, 140),
        Error = Color3.fromRGB(230, 100, 100),
        Warning = Color3.fromRGB(240, 200, 80)
    },
    
    Sunset = {
        Background = Color3.fromRGB(40, 25, 30),
        BackgroundSecondary = Color3.fromRGB(55, 35, 40),
        Accent = Color3.fromRGB(255, 120, 80),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 170, 160),
        Border = Color3.fromRGB(70, 45, 50),
        Success = Color3.fromRGB(100, 230, 130),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 100)
    },
    
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        BackgroundSecondary = Color3.fromRGB(220, 220, 230),
        Accent = Color3.fromRGB(66, 133, 244),
        Text = Color3.fromRGB(50, 50, 50),
        TextSecondary = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(200, 200, 210),
        Success = Color3.fromRGB(40, 180, 100),
        Error = Color3.fromRGB(220, 60, 60),
        Warning = Color3.fromRGB(230, 180, 40)
    },
    
    Cyberpunk = {
        Background = Color3.fromRGB(10, 10, 15),
        BackgroundSecondary = Color3.fromRGB(20, 20, 30),
        Accent = Color3.fromRGB(255, 0, 128),
        Text = Color3.fromRGB(0, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 180),
        Border = Color3.fromRGB(50, 50, 80),
        Success = Color3.fromRGB(0, 255, 128),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 255, 0)
    },
    
    Monokai = {
        Background = Color3.fromRGB(39, 40, 34),
        BackgroundSecondary = Color3.fromRGB(50, 52, 44),
        Accent = Color3.fromRGB(102, 217, 239),
        Text = Color3.fromRGB(248, 248, 242),
        TextSecondary = Color3.fromRGB(117, 113, 94),
        Border = Color3.fromRGB(62, 63, 58),
        Success = Color3.fromRGB(166, 226, 46),
        Error = Color3.fromRGB(249, 38, 114),
        Warning = Color3.fromRGB(253, 151, 31)
    },
    
    Dracula = {
        Background = Color3.fromRGB(40, 42, 54),
        BackgroundSecondary = Color3.fromRGB(68, 71, 90),
        Accent = Color3.fromRGB(189, 147, 249),
        Text = Color3.fromRGB(248, 248, 242),
        TextSecondary = Color3.fromRGB(98, 114, 164),
        Border = Color3.fromRGB(68, 71, 90),
        Success = Color3.fromRGB(80, 250, 123),
        Error = Color3.fromRGB(255, 85, 85),
        Warning = Color3.fromRGB(241, 250, 140)
    }
}

-- Convert Color3 to table for serialization
local function Color3ToTable(color)
    return {
        R = math.round(color.R * 255),
        G = math.round(color.G * 255),
        B = math.round(color.B * 255)
    }
end

-- Convert table to Color3
local function TableToColor3(tbl)
    return Color3.fromRGB(tbl.R or 255, tbl.G or 255, tbl.B or 255)
end

-- Serialize theme for saving
local function SerializeTheme(theme)
    local serialized = {}
    for key, value in pairs(theme) do
        if typeof(value) == "Color3" then
            serialized[key] = Color3ToTable(value)
        else
            serialized[key] = value
        end
    end
    return serialized
end

-- Deserialize theme from loading
local function DeserializeTheme(serialized)
    local theme = {}
    for key, value in pairs(serialized) do
        if typeof(value) == "table" and value.R and value.G and value.B then
            theme[key] = TableToColor3(value)
        else
            theme[key] = value
        end
    end
    return theme
end

function ThemeManager.new(options)
    local self = setmetatable({}, ThemeManager)
    
    options = options or {}
    self.Themes = {}
    self.CurrentTheme = "Default"
    self.Library = nil
    self.Callbacks = {}
    self.AutoApply = options.AutoApply ~= false
    self.SaveFolder = options.SaveFolder or "UI_Library_Themes"
    
    -- Copy predefined themes
    for name, theme in pairs(THEMES) do
        self.Themes[name] = self:CopyTheme(theme)
    end
    
    -- Load custom themes
    self:LoadCustomThemes()
    
    return self
end

function ThemeManager:SetLibrary(library)
    self.Library = library
    return self
end

function ThemeManager:CopyTheme(theme)
    local copy = {}
    for k, v in pairs(theme) do
        copy[k] = v
    end
    return copy
end

-- Get theme by name
function ThemeManager:GetTheme(name)
    return self.Themes[name or self.CurrentTheme]
end

-- Get current theme
function ThemeManager:GetCurrentTheme()
    return self:GetTheme(self.CurrentTheme)
end

-- Get current theme name
function ThemeManager:GetCurrentThemeName()
    return self.CurrentTheme
end

-- Apply theme to UI
function ThemeManager:ApplyTheme(themeName)
    themeName = themeName or self.CurrentTheme
    local theme = self.Themes[themeName]
    
    if not theme then
        warn("[ThemeManager] Theme '" .. tostring(themeName) .. "' not found")
        return false
    end
    
    self.CurrentTheme = themeName
    
    -- Apply to library if set
    if self.Library then
        self.Library:SetTheme(theme)
    end
    
    -- Fire callbacks
    self:FireCallback("apply", themeName, theme)
    
    -- Save as current
    self:SaveCurrentTheme()
    
    return true
end

-- Create a new theme
function ThemeManager:CreateTheme(name, baseTheme, overrides)
    if self.Themes[name] then
        warn("[ThemeManager] Theme '" .. name .. "' already exists, overwriting")
    end
    
    local base = baseTheme and self.Themes[baseTheme] or THEMES.Default
    local newTheme = self:CopyTheme(base)
    
    if overrides then
        for key, value in pairs(overrides) do
            if typeof(value) == "table" and value.R and value.G and value.B then
                newTheme[key] = TableToColor3(value)
            else
                newTheme[key] = value
            end
        end
    end
    
    self.Themes[name] = newTheme
    self:FireCallback("create", name, newTheme)
    
    return newTheme
end

-- Delete a custom theme
function ThemeManager:DeleteTheme(name)
    if THEMES[name] then
        warn("[ThemeManager] Cannot delete built-in theme '" .. name .. "'")
        return false
    end
    
    if not self.Themes[name] then
        warn("[ThemeManager] Theme '" .. name .. "' not found")
        return false
    end
    
    self.Themes[name] = nil
    
    -- Delete saved file
    pcall(function()
        if delfile then
            delfile(self.SaveFolder .. "/" .. name .. ".json")
        end
    end)
    
    self:FireCallback("delete", name)
    
    -- Switch to default if current was deleted
    if self.CurrentTheme == name then
        self:ApplyTheme("Default")
    end
    
    return true
end

-- List all available themes
function ThemeManager:ListThemes()
    local list = {}
    for name, _ in pairs(self.Themes) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

-- List built-in themes
function ThemeManager:ListBuiltInThemes()
    local list = {}
    for name, _ in pairs(THEMES) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

-- List custom themes
function ThemeManager:ListCustomThemes()
    local builtIn = self:ListBuiltInThemes()
    local builtInSet = {}
    for _, name in pairs(builtIn) do
        builtInSet[name] = true
    end
    
    local custom = {}
    for name, _ in pairs(self.Themes) do
        if not builtInSet[name] then
            table.insert(custom, name)
        end
    end
    table.sort(custom)
    return custom
end

-- Get theme preview colors (for UI)
function ThemeManager:GetThemePreview(name)
    local theme = self.Themes[name]
    if not theme then return nil end
    
    return {
        Background = theme.Background,
        Accent = theme.Accent,
        Text = theme.Text
    }
end

-- Update specific color in current theme
function ThemeManager:UpdateColor(key, color)
    local theme = self.Themes[self.CurrentTheme]
    if not theme then return false end
    
    theme[key] = color
    
    -- Re-apply
    if self.AutoApply then
        self:ApplyTheme(self.CurrentTheme)
    end
    
    self:FireCallback("update", key, color)
    
    return true
end

-- Save custom themes to files
function ThemeManager:SaveCustomThemes()
    local customThemes = self:ListCustomThemes()
    
    -- Ensure folder exists
    pcall(function()
        if makefolder then
            makefolder(self.SaveFolder)
        elseif createfolder then
            createfolder(self.SaveFolder)
        end
    end)
    
    for _, name in pairs(customThemes) do
        local theme = self.Themes[name]
        local serialized = SerializeTheme(theme)
        local json = HttpService:JSONEncode({
            name = name,
            theme = serialized
        })
        
        pcall(function()
            if writefile then
                writefile(self.SaveFolder .. "/" .. name .. ".json", json)
            end
        end)
    end
end

-- Load custom themes from files
function ThemeManager:LoadCustomThemes()
    local success, result = pcall(function()
        if not listfiles then return end
        
        local files = listfiles(self.SaveFolder)
        for _, file in pairs(files) do
            if file:match("%.json$") then
                local content = readfile(file)
                local success, data = pcall(function()
                    return HttpService:JSONDecode(content)
                end)
                
                if success and data and data.name and data.theme then
                    self.Themes[data.name] = DeserializeTheme(data.theme)
                end
            end
        end
    end)
    
    -- Load current theme preference
    pcall(function()
        if isfile and isfile(self.SaveFolder .. "/current.txt") then
            local current = readfile(self.SaveFolder .. "/current.txt")
            if current and self.Themes[current] then
                self.CurrentTheme = current
            end
        end
    end)
end

-- Save current theme preference
function ThemeManager:SaveCurrentTheme()
    pcall(function()
        if writefile then
            writefile(self.SaveFolder .. "/current.txt", self.CurrentTheme)
        end
    end)
end

-- Export theme as string
function ThemeManager:ExportTheme(name)
    local theme = self.Themes[name]
    if not theme then return nil end
    
    local serialized = SerializeTheme(theme)
    local json = HttpService:JSONEncode(serialized)
    
    -- Base64 encode if available
    if to_base64 then
        return to_base64(json)
    elseif base64_encode then
        return base64_encode(json)
    end
    
    return json
end

-- Import theme from string
function ThemeManager:ImportTheme(name, data)
    if self.Themes[name] and THEMES[name] then
        return false, "Cannot overwrite built-in theme"
    end
    
    -- Decode base64 if available
    local json = data
    if from_base64 then
        json = from_base64(data)
    elseif base64_decode then
        json = base64_decode(data)
    end
    
    local success, serialized = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    
    if not success then
        return false, "Invalid theme data"
    end
    
    self.Themes[name] = DeserializeTheme(serialized)
    self:SaveCustomThemes()
    
    self:FireCallback("import", name, self.Themes[name])
    
    return true
end

-- Create rainbow/animated accent effect
function ThemeManager:CreateRainbowEffect(speed)
    speed = speed or 1
    
    local connection = RunService.RenderStepped:Connect(function(deltaTime)
        local hue = (tick() * speed) % 1
        local color = Color3.fromHSV(hue, 0.8, 1)
        
        if self.Library then
            self.Library.Theme.Accent = color
            -- Apply to all accent-colored elements
        end
    end)
    
    return connection
end

-- Callback system
function ThemeManager:On(event, callback)
    if not self.Callbacks[event] then
        self.Callbacks[event] = {}
    end
    table.insert(self.Callbacks[event], callback)
    return self
end

function ThemeManager:FireCallback(event, ...)
    if self.Callbacks[event] then
        for _, callback in pairs(self.Callbacks[event]) do
            local success, err = pcall(callback, ...)
            if not success then
                warn("[ThemeManager] Callback error: " .. tostring(err))
            end
        end
    end
end

-- Reset to default theme
function ThemeManager:Reset()
    self:ApplyTheme("Default")
end

-- Create theme editor UI (returns elements that can be added to a tab)
function ThemeManager:CreateEditorUI(tab, options)
    options = options or {}
    
    local editor = {}
    
    -- Theme selector dropdown
    editor.ThemeSelector = tab:AddDropdown("Theme", self:ListThemes(), function(selected)
        self:ApplyTheme(selected)
    end)
    
    -- Save current as custom
    tab:AddButton("Save Current as Custom", function()
        -- Open text input for name
    end)
    
    -- Color pickers for each theme property
    local themeKeys = {
        "Background",
        "BackgroundSecondary", 
        "Accent",
        "Text",
        "TextSecondary",
        "Border",
        "Success",
        "Error",
        "Warning"
    }
    
    editor.ColorPickers = {}
    for _, key in pairs(themeKeys) do
        editor.ColorPickers[key] = tab:AddColorpicker(key, Color3.fromRGB(255, 255, 255), function(color)
            self:UpdateColor(key, color)
        end)
    end
    
    -- Export/Import buttons
    tab:AddButton("Export Theme", function()
        local exported = self:ExportTheme(self.CurrentTheme)
        if exported then
            setclipboard(exported)
            -- Show notification
        end
    end)
    
    tab:AddTextbox("Import Theme", "Paste theme code here", function(text)
        local name = "Imported_" .. tostring(math.random(1000, 9999))
        local success, err = self:ImportTheme(name, text)
        if success then
            self:ApplyTheme(name)
            -- Update dropdown
        end
    end)
    
    return editor
end

-- Get raw themes table (for advanced usage)
function ThemeManager:GetThemesTable()
    return self.Themes
end

-- Set raw themes table
function ThemeManager:SetThemesTable(themes)
    self.Themes = themes
end

return ThemeManager
