-- Save Manager for Roblox Executor UI Library
-- Handles configuration saving/loading with JSON encoding

local SaveManager = {}
SaveManager.__index = SaveManager

local HttpService = game:GetService("HttpService")

-- Configuration
local DEFAULT_CONFIG = {
    AutoSave = true,
    AutoSaveInterval = 60, -- seconds
    ConfigFolder = "UI_Library_Configs",
    DefaultConfigName = "default"
}

function SaveManager.new(options)
    local self = setmetatable({}, SaveManager)
    
    options = options or {}
    self.Config = {}
    self.Options = {}
    self.CurrentConfig = options.DefaultConfigName or DEFAULT_CONFIG.DefaultConfigName
    self.ConfigFolder = options.ConfigFolder or DEFAULT_CONFIG.ConfigFolder
    self.AutoSave = options.AutoSave ~= false
    self.AutoSaveInterval = options.AutoSaveInterval or DEFAULT_CONFIG.AutoSaveInterval
    self.Callbacks = {}
    
    -- Create config folder if it doesn't exist (executor-dependent)
    self:EnsureFolderExists()
    
    -- Start auto-save if enabled
    if self.AutoSave then
        self:StartAutoSave()
    end
    
    return self
end

function SaveManager:EnsureFolderExists()
    -- This will vary by executor, common methods:
    -- Synapse X: makefolder()
    -- KRNL/Script-Ware: makefolder()
    -- Fluxus: createfolder()
    
    local success, err = pcall(function()
        if makefolder then
            makefolder(self.ConfigFolder)
        elseif createfolder then
            createfolder(self.ConfigFolder)
        end
    end)
    
    if not success then
        warn("[SaveManager] Could not create config folder: " .. tostring(err))
    end
end

function SaveManager:GetConfigPath(configName)
    return self.ConfigFolder .. "/" .. (configName or self.CurrentConfig) .. ".json"
end

function SaveManager:SetLibrary(library)
    self.Library = library
    return self
end

function SaveManager:SetFolder(folder)
    self.ConfigFolder = folder
    self:EnsureFolderExists()
    return self
end

function SaveManager:IgnoreIndexes(list)
    self.IgnoredIndexes = list or {}
    return self
end

-- Register an option/element with the save manager
function SaveManager:RegisterOption(index, element, elementType, defaultValue)
    self.Options[index] = {
        Element = element,
        Type = elementType,
        Default = defaultValue,
        Index = index
    }
    
    return self
end

-- Build configuration from registered options
function SaveManager:BuildConfig()
    local config = {
        _meta = {
            version = "1.0",
            created = os.time(),
            game = game.PlaceId
        }
    }
    
    for index, option in pairs(self.Options) do
        local value = nil
        
        if option.Type == "toggle" then
            value = option.Element:GetValue()
        elseif option.Type == "slider" then
            value = option.Element:GetValue()
        elseif option.Type == "textbox" then
            value = option.Element:GetText()
        elseif option.Type == "dropdown" then
            value = option.Element:GetSelected()
        elseif option.Type == "colorpicker" then
            local color = option.Element:GetColor()
            value = {r = color.R * 255, g = color.G * 255, b = color.B * 255}
        elseif option.Type == "keybind" then
            local key = option.Element:GetKey()
            value = key.Name
        end
        
        if value ~= nil then
            config[index] = value
        end
    end
    
    return config
end

-- Save configuration to file
function SaveManager:Save(configName)
    configName = configName or self.CurrentConfig
    self.CurrentConfig = configName
    
    local config = self:BuildConfig()
    local json = HttpService:JSONEncode(config)
    local path = self:GetConfigPath(configName)
    
    local success, err = pcall(function()
        if writefile then
            writefile(path, json)
        elseif savefile then
            savefile(path, json)
        else
            error("No file write function available")
        end
    end)
    
    if success then
        self:FireCallback("save", configName, config)
        return true
    else
        warn("[SaveManager] Failed to save config: " .. tostring(err))
        return false
    end
end

-- Load configuration from file
function SaveManager:Load(configName)
    configName = configName or self.CurrentConfig
    local path = self:GetConfigPath(configName)
    
    local success, result = pcall(function()
        if readfile then
            return readfile(path)
        elseif loadfile then
            return loadfile(path)
        else
            error("No file read function available")
        end
    end)
    
    if not success or not result then
        warn("[SaveManager] Failed to load config: " .. tostring(result))
        return false
    end
    
    local decodeSuccess, config = pcall(function()
        return HttpService:JSONDecode(result)
    end)
    
    if not decodeSuccess then
        warn("[SaveManager] Failed to decode config: " .. tostring(config))
        return false
    end
    
    -- Apply loaded values to options
    for index, value in pairs(config) do
        if index ~= "_meta" and self.Options[index] then
            local option = self.Options[index]
            
            if option.Type == "toggle" then
                option.Element:SetValue(value)
            elseif option.Type == "slider" then
                option.Element:SetValue(value)
            elseif option.Type == "textbox" then
                option.Element:SetText(value)
            elseif option.Type == "dropdown" then
                -- Dropdown values are strings
                -- Element needs to support setting selected option
            elseif option.Type == "colorpicker" then
                if typeof(value) == "table" then
                    local color = Color3.fromRGB(value.r or 255, value.g or 255, value.b or 255)
                    option.Element:SetColor(color)
                end
            elseif option.Type == "keybind" then
                -- Keybind loading would need special handling
            end
        end
    end
    
    self.CurrentConfig = configName
    self:FireCallback("load", configName, config)
    return true
end

-- Check if a config exists
function SaveManager:ConfigExists(configName)
    local path = self:GetConfigPath(configName)
    
    local success, result = pcall(function()
        if isfile then
            return isfile(path)
        elseif fileexists then
            return fileexists(path)
        else
            -- Fallback: try to read and check for error
            readfile(path)
            return true
        end
    end)
    
    return success and result == true
end

-- Delete a config
function SaveManager:Delete(configName)
    local path = self:GetConfigPath(configName)
    
    local success, err = pcall(function()
        if delfile then
            delfile(path)
        elseif deletefile then
            deletefile(path)
        else
            error("No file delete function available")
        end
    end)
    
    if success then
        self:FireCallback("delete", configName)
        return true
    else
        warn("[SaveManager] Failed to delete config: " .. tostring(err))
        return false
    end
end

-- List all available configs
function SaveManager:ListConfigs()
    local configs = {}
    
    local success, result = pcall(function()
        if listfiles then
            local files = listfiles(self.ConfigFolder)
            for _, file in pairs(files) do
                if file:match("%.json$") then
                    local configName = file:match("([^/\\]+)%.json$")
                    if configName then
                        table.insert(configs, configName)
                    end
                end
            end
        end
        return configs
    end)
    
    if success then
        return result
    else
        warn("[SaveManager] Failed to list configs: " .. tostring(result))
        return {}
    end
end

-- Reset all options to defaults
function SaveManager:ResetToDefaults()
    for index, option in pairs(self.Options) do
        if option.Type == "toggle" then
            option.Element:SetValue(option.Default or false)
        elseif option.Type == "slider" then
            option.Element:SetValue(option.Default or 0)
        elseif option.Type == "textbox" then
            option.Element:SetText(option.Default or "")
        elseif option.Type == "dropdown" then
            -- Reset to first option or default
        elseif option.Type == "colorpicker" then
            option.Element:SetColor(option.Default or Color3.fromRGB(255, 255, 255))
        end
    end
    
    self:FireCallback("reset")
end

-- Auto-save functionality
function SaveManager:StartAutoSave()
    if self.AutoSaveConnection then
        self.AutoSaveConnection:Disconnect()
    end
    
    self.AutoSaveConnection = task.spawn(function()
        while self.AutoSave do
            task.wait(self.AutoSaveInterval)
            if self.AutoSave then
                self:Save()
            end
        end
    end)
end

function SaveManager:StopAutoSave()
    self.AutoSave = false
end

-- Callback system
function SaveManager:On(event, callback)
    if not self.Callbacks[event] then
        self.Callbacks[event] = {}
    end
    table.insert(self.Callbacks[event], callback)
    return self
end

function SaveManager:FireCallback(event, ...)
    if self.Callbacks[event] then
        for _, callback in pairs(self.Callbacks[event]) do
            local success, err = pcall(callback, ...)
            if not success then
                warn("[SaveManager] Callback error: " .. tostring(err))
            end
        end
    end
end

-- Export config as string (for sharing)
function SaveManager:Export(configName)
    configName = configName or self.CurrentConfig
    local path = self:GetConfigPath(configName)
    
    local success, result = pcall(function()
        if readfile then
            return readfile(path)
        end
        return nil
    end)
    
    if success and result then
        -- Encode to base64 if available
        if to_base64 then
            return to_base64(result)
        elseif base64_encode then
            return base64_encode(result)
        end
        return result
    end
    
    return nil
end

-- Import config from string
function SaveManager:Import(configName, data)
    -- Decode from base64 if available
    local json = data
    if from_base64 then
        json = from_base64(data)
    elseif base64_decode then
        json = base64_decode(data)
    end
    
    -- Validate JSON
    local success, config = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    
    if not success then
        return false, "Invalid config data"
    end
    
    -- Save to file
    local path = self:GetConfigPath(configName)
    local writeSuccess, err = pcall(function()
        if writefile then
            writefile(path, json)
        elseif savefile then
            savefile(path, json)
        end
    end)
    
    if writeSuccess then
        return true
    else
        return false, tostring(err)
    end
end

-- Create UI elements for save management
function SaveManager:CreateUI(parent, theme)
    local UI = {}
    
    -- Create a section or frame for save management
    -- This would integrate with the UI library
    
    -- Config name input
    -- Save button
    -- Load dropdown
    -- Delete button
    -- Auto-save toggle
    -- Export/Import buttons
    
    return UI
end

-- Universal config migration
function SaveManager:Migrate(oldFolder, newFolder)
    local success, err = pcall(function()
        if not listfiles then return end
        
        local files = listfiles(oldFolder)
        for _, file in pairs(files) do
            if file:match("%.json$") then
                local content = readfile(file)
                local filename = file:match("([^/\\]+)$")
                writefile(newFolder .. "/" .. filename, content)
            end
        end
    end)
    
    return success
end

return SaveManager
