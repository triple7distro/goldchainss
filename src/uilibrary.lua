-- ImGui-Inspired UI Library for Roblox Executors
-- A modular, extensible UI framework

local UI_LIBRARY = {}
UI_LIBRARY.__index = UI_LIBRARY

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local COLORS = {
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

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    if properties then
        for prop, value in pairs(properties) do
            instance[prop] = value
        end
    end
    return instance
end

local function ApplyTheme(instance, theme)
    if not theme then return end
    if instance:IsA("Frame") or instance:IsA("TextButton") or instance:IsA("TextBox") or instance:IsA("ScrollingFrame") then
        if theme.BackgroundColor then
            instance.BackgroundColor3 = theme.BackgroundColor
        end
        if theme.BorderColor then
            instance.BorderColor3 = theme.BorderColor
        end
    end
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        if theme.TextColor then
            instance.TextColor3 = theme.TextColor
        end
    end
    if instance:IsA("UIStroke") then
        if theme.BorderColor then
            instance.Color = theme.BorderColor
        end
    end
end

-- Window Creation
function UI_LIBRARY.new(options)
    local self = setmetatable({}, UI_LIBRARY)
    
    options = options or {}
    self.Title = options.Title or "UI Library"
    self.Width = options.Width or 600
    self.Height = options.Height or 400
    self.Theme = options.Theme or COLORS
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsMinimized = false
    self.IsDragging = false
    self.DragStart = nil
    self.StartPos = nil
    
    -- Main ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "ImGuiLibrary",
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Window Frame
    self.MainFrame = Create("Frame", {
        Name = "MainWindow",
        Parent = self.ScreenGui,
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -self.Width/2, 0.5, -self.Height/2),
        Size = UDim2.new(0, self.Width, 0, self.Height),
        ClipsDescendants = true
    })
    
    -- Rounded corners
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.MainFrame
    })
    
    -- Shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1
    })
    
    -- Title Bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    local titleBarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.TitleBar
    })
    
    -- Fix title bar bottom corners
    local titleBarFix = Create("Frame", {
        Name = "Fix",
        Parent = self.TitleBar,
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8)
    })
    
    -- Title Label
    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = self.Title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Minimize Button
    self.MinimizeBtn = Create("TextButton", {
        Name = "Minimize",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = self.Theme.Text,
        TextSize = 18
    })
    
    -- Close Button
    self.CloseBtn = Create("TextButton", {
        Name = "Close",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = self.Theme.Error,
        TextSize = 20
    })
    
    -- Tab Container
    self.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = self.MainFrame,
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 140, 1, -35)
    })
    
    local tabContainerCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.TabContainer
    })
    
    -- Fix tab container top corners
    local tabContainerFix = Create("Frame", {
        Name = "Fix",
        Parent = self.TabContainer,
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 8)
    })
    
    -- Tab Buttons Layout
    self.TabButtonsLayout = Create("UIListLayout", {
        Parent = self.TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })
    
    self.TabButtonsPadding = Create("UIPadding", {
        Parent = self.TabContainer,
        PaddingLeft = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })
    
    -- Content Container
    self.ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, 35),
        Size = UDim2.new(1, -140, 1, -35),
        ClipsDescendants = true
    })
    
    -- Setup dragging
    self:SetupDragging()
    self:SetupControls()
    
    return self
end

-- Dragging functionality
function UI_LIBRARY:SetupDragging()
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = true
            self.DragStart = input.Position
            self.StartPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.IsDragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if self.IsDragging then
                local delta = input.Position - self.DragStart
                self.MainFrame.Position = UDim2.new(
                    self.StartPos.X.Scale,
                    self.StartPos.X.Offset + delta.X,
                    self.StartPos.Y.Scale,
                    self.StartPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end

-- Window controls
function UI_LIBRARY:SetupControls()
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    self.MinimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
end

function UI_LIBRARY:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    local targetSize = self.IsMinimized 
        and UDim2.new(0, self.Width, 0, 35) 
        or UDim2.new(0, self.Width, 0, self.Height)
    
    local tween = TweenService:Create(self.MainFrame, TWEEN_INFO, {Size = targetSize})
    tween:Play()
    
    self.MinimizeBtn.Text = self.IsMinimized and "+" or "-"
    self.ContentContainer.Visible = not self.IsMinimized
    self.TabContainer.Visible = not self.IsMinimized
end

-- Tab Creation
function UI_LIBRARY:AddTab(name, icon)
    local tab = {}
    tab.Name = name
    tab.Icon = icon
    tab.Elements = {}
    
    -- Tab Button
    tab.Button = Create("TextButton", {
        Name = name .. "Tab",
        Parent = self.TabContainer,
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.Gotham,
        Text = icon and (icon .. " " .. name) or name,
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    })
    
    local buttonCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tab.Button
    })
    
    -- Tab Content
    tab.Content = Create("ScrollingFrame", {
        Name = name .. "Content",
        Parent = self.ContentContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Border,
        Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local contentLayout = Create("UIListLayout", {
        Parent = tab.Content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    local contentPadding = Create("UIPadding", {
        Parent = tab.Content,
        PaddingLeft = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12)
    })
    
    -- Tab button click handler
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            TweenService:Create(tab.Button, TWEEN_INFO, {BackgroundTransparency = 0.8}):Play()
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            TweenService:Create(tab.Button, TWEEN_INFO, {BackgroundTransparency = 1}):Play()
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end
    
    -- Element creation functions for this tab
    function tab:AddLabel(text)
        return UI_LIBRARY.CreateLabel(self.Content, text, self.Library.Theme)
    end
    
    function tab:AddButton(text, callback)
        return UI_LIBRARY.CreateButton(self.Content, text, callback, self.Library.Theme)
    end
    
    function tab:AddToggle(text, default, callback)
        return UI_LIBRARY.CreateToggle(self.Content, text, default, callback, self.Library.Theme)
    end
    
    function tab:AddSlider(text, min, max, default, callback)
        return UI_LIBRARY.CreateSlider(self.Content, text, min, max, default, callback, self.Library.Theme)
    end
    
    function tab:AddTextbox(text, placeholder, callback)
        return UI_LIBRARY.CreateTextbox(self.Content, text, placeholder, callback, self.Library.Theme)
    end
    
    function tab:AddDropdown(text, options, callback)
        return UI_LIBRARY.CreateDropdown(self.Content, text, options, callback, self.Library.Theme)
    end
    
    function tab:AddKeybind(text, default, callback)
        return UI_LIBRARY.CreateKeybind(self.Content, text, default, callback, self.Library.Theme)
    end
    
    function tab:AddColorpicker(text, default, callback)
        return UI_LIBRARY.CreateColorpicker(self.Content, text, default, callback, self.Library.Theme)
    end
    
    function tab:AddSection(text)
        return UI_LIBRARY.CreateSection(self.Content, text, self.Library.Theme)
    end
    
    function tab:AddSeparator()
        return UI_LIBRARY.CreateSeparator(self.Content, self.Library.Theme)
    end
    
    tab.Library = self
    
    return tab
end

function UI_LIBRARY:SwitchTab(tab)
    if self.ActiveTab == tab then return end
    
    -- Hide current tab
    if self.ActiveTab then
        self.ActiveTab.Content.Visible = false
        TweenService:Create(self.ActiveTab.Button, TWEEN_INFO, {
            BackgroundColor3 = self.Theme.Background,
            BackgroundTransparency = 1,
            TextColor3 = self.Theme.TextSecondary
        }):Play()
    end
    
    -- Show new tab
    self.ActiveTab = tab
    tab.Content.Visible = true
    TweenService:Create(tab.Button, TWEEN_INFO, {
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 0,
        TextColor3 = self.Theme.Text
    }):Play()
end

-- Element Creation Functions

function UI_LIBRARY.CreateLabel(parent, text, theme)
    local frame = Create("Frame", {
        Name = "Label",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20)
    })
    
    local label = Create("TextLabel", {
        Name = "Text",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    local element = {
        Frame = frame,
        Label = label,
        SetText = function(self, newText)
            label.Text = newText
        end
    }
    
    return element
end

function UI_LIBRARY.CreateButton(parent, text, callback, theme)
    local button = Create("TextButton", {
        Name = "Button",
        Parent = parent,
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = theme.Text,
        TextSize = 13,
        AutoButtonColor = false
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = button
    })
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TWEEN_INFO, {BackgroundColor3 = theme.Accent:Lerp(Color3.new(1,1,1), 0.1)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TWEEN_INFO, {BackgroundColor3 = theme.Accent}):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 30)}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 32)}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    local element = {
        Button = button,
        SetText = function(self, newText)
            button.Text = newText
        end,
        SetCallback = function(self, newCallback)
            callback = newCallback
        end
    }
    
    return element
end

function UI_LIBRARY.CreateToggle(parent, text, default, callback, theme)
    default = default or false
    
    local frame = Create("Frame", {
        Name = "Toggle",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32)
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleBg = Create("Frame", {
        Name = "Background",
        Parent = frame,
        BackgroundColor3 = default and theme.Accent or theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -44, 0.5, -10),
        Size = UDim2.new(0, 44, 0, 20)
    })
    
    local bgCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleBg
    })
    
    local toggleCircle = Create("Frame", {
        Name = "Circle",
        Parent = toggleBg,
        BackgroundColor3 = theme.Text,
        BorderSizePixel = 0,
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16)
    })
    
    local circleCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleCircle
    })
    
    local enabled = default
    
    local function updateToggle()
        enabled = not enabled
        TweenService:Create(toggleBg, TWEEN_INFO, {
            BackgroundColor3 = enabled and theme.Accent or theme.BackgroundSecondary
        }):Play()
        TweenService:Create(toggleCircle, TWEEN_INFO, {
            Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        
        if callback then
            callback(enabled)
        end
    end
    
    local clickArea = Create("TextButton", {
        Name = "ClickArea",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    
    clickArea.MouseButton1Click:Connect(updateToggle)
    
    local element = {
        Frame = frame,
        GetValue = function() return enabled end,
        SetValue = function(self, value)
            if enabled ~= value then
                updateToggle()
            end
        end,
        SetCallback = function(self, newCallback)
            callback = newCallback
        end
    }
    
    return element
end

function UI_LIBRARY.CreateSlider(parent, text, min, max, default, callback, theme)
    min = min or 0
    max = max or 100
    default = default or min
    
    local frame = Create("Frame", {
        Name = "Slider",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50)
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 0, 20),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = Create("TextLabel", {
        Name = "Value",
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 0),
        Size = UDim2.new(0, 50, 0, 20),
        Font = Enum.Font.Gotham,
        Text = tostring(default),
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local sliderBg = Create("Frame", {
        Name = "Background",
        Parent = frame,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 6)
    })
    
    local bgCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderBg
    })
    
    local sliderFill = Create("Frame", {
        Name = "Fill",
        Parent = sliderBg,
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    })
    
    local fillCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderFill
    })
    
    local sliderThumb = Create("Frame", {
        Name = "Thumb",
        Parent = sliderBg,
        BackgroundColor3 = theme.Text,
        BorderSizePixel = 0,
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        ZIndex = 2
    })
    
    local thumbCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderThumb
    })
    
    local value = default
    local dragging = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = min + (pos * (max - min))
        
        if max - min <= 1 then
            value = math.round(value * 100) / 100
        else
            value = math.round(value)
        end
        
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderThumb.Position = UDim2.new(pos, -6, 0.5, -6)
        valueLabel.Text = tostring(value)
        
        if callback then
            callback(value)
        end
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    local element = {
        Frame = frame,
        GetValue = function() return value end,
        SetValue = function(self, newValue)
            value = math.clamp(newValue, min, max)
            local pos = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            sliderThumb.Position = UDim2.new(pos, -6, 0.5, -6)
            valueLabel.Text = tostring(value)
        end,
        SetCallback = function(self, newCallback)
            callback = newCallback
        end
    }
    
    return element
end

function UI_LIBRARY.CreateTextbox(parent, text, placeholder, callback, theme)
    local frame = Create("Frame", {
        Name = "Textbox",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 55)
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local textboxBg = Create("Frame", {
        Name = "Background",
        Parent = frame,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    local bgCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = textboxBg
    })
    
    local textbox = Create("TextBox", {
        Name = "Input",
        Parent = textboxBg,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.Gotham,
        PlaceholderText = placeholder or "Enter text...",
        PlaceholderColor3 = theme.TextSecondary,
        Text = "",
        TextColor3 = theme.Text,
        TextSize = 13,
        ClearTextOnFocus = false
    })
    
    textbox.Focused:Connect(function()
        TweenService:Create(textboxBg, TWEEN_INFO, {BackgroundColor3 = theme.Accent:Lerp(theme.BackgroundSecondary, 0.9)}):Play()
    end)
    
    textbox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(textboxBg, TWEEN_INFO, {BackgroundColor3 = theme.BackgroundSecondary}):Play()
        if callback and (enterPressed or true) then
            callback(textbox.Text)
        end
    end)
    
    local element = {
        Frame = frame,
        Textbox = textbox,
        GetText = function() return textbox.Text end,
        SetText = function(self, newText)
            textbox.Text = newText
        end,
        SetCallback = function(self, newCallback)
            callback = newCallback
        end
    }
    
    return element
end

function UI_LIBRARY.CreateDropdown(parent, text, options, callback, theme)
    options = options or {}
    
    local frame = Create("Frame", {
        Name = "Dropdown",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 55),
        ClipsDescendants = false
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdownBtn = Create("TextButton", {
        Name = "DropdownButton",
        Parent = frame,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.Gotham,
        Text = options[1] or "Select...",
        TextColor3 = theme.Text,
        TextSize = 13,
        AutoButtonColor = false
    })
    
    local btnCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdownBtn
    })
    
    local arrow = Create("TextLabel", {
        Name = "Arrow",
        Parent = dropdownBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "▼",
        TextColor3 = theme.TextSecondary,
        TextSize = 10
    })
    
    local dropdownFrame = Create("Frame", {
        Name = "DropdownFrame",
        Parent = frame,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ZIndex = 10
    })
    
    local frameCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdownFrame
    })
    
    local scrollFrame = Create("ScrollingFrame", {
        Name = "ScrollFrame",
        Parent = dropdownFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 10
    })
    
    local listLayout = Create("UIListLayout", {
        Parent = scrollFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    local listPadding = Create("UIPadding", {
        Parent = scrollFrame,
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4)
    })
    
    local isOpen = false
    local selected = options[1]
    
    local function refreshOptions()
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, option in pairs(options) do
            local optionBtn = Create("TextButton", {
                Name = option,
                Parent = scrollFrame,
                BackgroundColor3 = theme.Background,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 26),
                Font = Enum.Font.Gotham,
                Text = option,
                TextColor3 = theme.Text,
                TextSize = 12,
                ZIndex = 10,
                AutoButtonColor = false
            })
            
            local optCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = optionBtn
            })
            
            optionBtn.MouseEnter:Connect(function()
                TweenService:Create(optionBtn, TWEEN_INFO, {BackgroundTransparency = 0.5}):Play()
            end)
            
            optionBtn.MouseLeave:Connect(function()
                TweenService:Create(optionBtn, TWEEN_INFO, {BackgroundTransparency = 1}):Play()
            end)
            
            optionBtn.MouseButton1Click:Connect(function()
                selected = option
                dropdownBtn.Text = option
                isOpen = false
                dropdownFrame.Visible = false
                frame.Size = UDim2.new(1, 0, 0, 55)
                arrow.Text = "▼"
                
                if callback then
                    callback(option)
                end
            end)
        end
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
    end
    
    refreshOptions()
    
    dropdownBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownFrame.Visible = isOpen
        
        if isOpen then
            frame.Size = UDim2.new(1, 0, 0, math.min(55 + #options * 30 + 10, 200))
            dropdownFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 30 + 8, 140))
            arrow.Text = "▲"
        else
            frame.Size = UDim2.new(1, 0, 0, 55)
            arrow.Text = "▼"
        end
    end)
    
    local element = {
        Frame = frame,
        GetSelected = function() return selected end,
        SetOptions = function(self, newOptions)
            options = newOptions
            refreshOptions()
        end,
        SetCallback = function(self, newCallback)
            callback = newCallback
        end
    }
    
    return element
end

function UI_LIBRARY.CreateKeybind(parent, text, default, callback, theme)
    default = default or Enum.KeyCode.Unknown
    
    local frame = Create("Frame", {
        Name = "Keybind",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32)
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local keybindBtn = Create("TextButton", {
        Name = "KeybindButton",
        Parent = frame,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -70, 0.5, -12),
        Size = UDim2.new(0, 70, 0, 24),
        Font = Enum.Font.Gotham,
        Text = default ~= Enum.KeyCode.Unknown and default.Name or "None",
        TextColor3 = theme.Text,
        TextSize = 11,
        AutoButtonColor = false
    })
    
    local btnCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = keybindBtn
    })
    
    local listening = false
    local currentKey = default
    
    keybindBtn.MouseButton1Click:Connect(function()
        listening = not listening
        keybindBtn.Text = listening and "..." or (currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None")
        
        if listening then
            TweenService:Create(keybindBtn, TWEEN_INFO, {BackgroundColor3 = theme.Accent}):Play()
        else
            TweenService:Create(keybindBtn, TWEEN_INFO, {BackgroundColor3 = theme.BackgroundSecondary}):Play()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keybindBtn.Text = currentKey.Name
                listening = false
                TweenService:Create(keybindBtn, TWEEN_INFO, {BackgroundColor3 = theme.BackgroundSecondary}):Play()
                
                if callback then
                    callback(currentKey)
                end
            end
        elseif input.KeyCode == currentKey and not gameProcessed then
            if callback then
                callback(currentKey)
            end
        end
    end)
    
    local element = {
        Frame = frame,
        GetKey = function() return currentKey end,
        SetCallback = function(self, newCallback)
            callback = newCallback
        end
    }
    
    return element
end

function UI_LIBRARY.CreateColorpicker(parent, text, default, callback, theme)
    default = default or Color3.fromRGB(255, 255, 255)
    
    local frame = Create("Frame", {
        Name = "Colorpicker",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32)
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local colorDisplay = Create("TextButton", {
        Name = "ColorDisplay",
        Parent = frame,
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -32, 0.5, -12),
        Size = UDim2.new(0, 32, 0, 24),
        Text = ""
    })
    
    local displayCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = colorDisplay
    })
    
    local displayStroke = Create("UIStroke", {
        Color = theme.Border,
        Thickness = 1,
        Parent = colorDisplay
    })
    
    local pickerFrame = Create("Frame", {
        Name = "PickerFrame",
        Parent = frame,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(1, 0, 0, 180),
        Visible = false,
        ZIndex = 10
    })
    
    local pickerCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = pickerFrame
    })
    
    local isOpen = false
    local currentColor = default
    
    -- Simple color picker with preset colors
    local presetColors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 128, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(128, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 128),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(0, 128, 255),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(128, 0, 255),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(255, 0, 128),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(128, 128, 128),
        Color3.fromRGB(0, 0, 0),
        theme.Accent
    }
    
    local gridLayout = Create("UIGridLayout", {
        Parent = pickerFrame,
        CellSize = UDim2.new(0, 36, 0, 28),
        CellPadding = UDim2.new(0, 6, 0, 6),
        StartCorner = Enum.StartCorner.TopLeft,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local gridPadding = Create("UIPadding", {
        Parent = pickerFrame,
        PaddingLeft = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })
    
    for _, color in pairs(presetColors) do
        local colorBtn = Create("TextButton", {
            Name = "ColorBtn",
            Parent = pickerFrame,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 10
        })
        
        local btnCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = colorBtn
        })
        
        local btnStroke = Create("UIStroke", {
            Color = theme.Border,
            Thickness = 1,
            Parent = colorBtn
        })
        
        colorBtn.MouseButton1Click:Connect(function()
            currentColor = color
            colorDisplay.BackgroundColor3 = color
            isOpen = false
            pickerFrame.Visible = false
            frame.Size = UDim2.new(1, 0, 0, 32)
            
            if callback then
                callback(color)
            end
        end)
    end
    
    colorDisplay.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        pickerFrame.Visible = isOpen
        frame.Size = isOpen and UDim2.new(1, 0, 0, 220) or UDim2.new(1, 0, 0, 32)
    end)
    
    local element = {
        Frame = frame,
        GetColor = function() return currentColor end,
        SetColor = function(self, color)
            currentColor = color
            colorDisplay.BackgroundColor3 = color
        end,
        SetCallback = function(self, newCallback)
            callback = newCallback
        end
    }
    
    return element
end

function UI_LIBRARY.CreateSection(parent, text, theme)
    local frame = Create("Frame", {
        Name = "Section",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = theme.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    return {
        Frame = frame,
        SetText = function(self, newText)
            label.Text = newText
        end
    }
end

function UI_LIBRARY.CreateSeparator(parent, theme)
    local frame = Create("Frame", {
        Name = "Separator",
        Parent = parent,
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1)
    })
    
    return {
        Frame = frame
    }
end

-- Window utility functions
function UI_LIBRARY:SetTheme(newTheme)
    self.Theme = newTheme
    -- Apply theme to all elements (simplified - would need recursive traversal in full implementation)
end

function UI_LIBRARY:SetPosition(position)
    self.MainFrame.Position = position
end

function UI_LIBRARY:SetSize(size)
    self.Width = size.X.Offset
    self.Height = size.Y.Offset
    self.MainFrame.Size = size
end

function UI_LIBRARY:Show()
    self.MainFrame.Visible = true
end

function UI_LIBRARY:Hide()
    self.MainFrame.Visible = false
end

function UI_LIBRARY:Destroy()
    self.ScreenGui:Destroy()
    setmetatable(self, nil)
end

-- Notification system
function UI_LIBRARY:Notify(title, message, duration, type)
    duration = duration or 3
    type = type or "info"
    
    local notifyColors = {
        info = self.Theme.Accent,
        success = self.Theme.Success,
        error = self.Theme.Error,
        warning = self.Theme.Warning
    }
    
    local notifyFrame = Create("Frame", {
        Name = "Notification",
        Parent = self.ScreenGui,
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 320, 1, -80),
        Size = UDim2.new(0, 280, 0, 60),
        ZIndex = 100
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notifyFrame
    })
    
    local indicator = Create("Frame", {
        Name = "Indicator",
        Parent = notifyFrame,
        BackgroundColor3 = notifyColors[type] or self.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 4, 1, 0)
    })
    
    local indicatorCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = indicator
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = notifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -28, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local messageLabel = Create("TextLabel", {
        Name = "Message",
        Parent = notifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 30),
        Size = UDim2.new(1, -28, 0, 24),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    -- Animate in
    TweenService:Create(notifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -300, 1, -80)
    }):Play()
    
    -- Auto dismiss
    task.delay(duration, function()
        TweenService:Create(notifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 320, 1, -80)
        }):Play()
        
        task.delay(0.3, function()
            notifyFrame:Destroy()
        end)
    end)
end

return UI_LIBRARY
