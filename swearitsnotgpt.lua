-- Roblox UI Library
-- A comprehensive UI library for creating modern Roblox interfaces

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Main Library Object
function UILibrary.new()
    local self = setmetatable({}, UILibrary)
    self.ScreenGui = nil
    self.MainFrame = nil
    self.CurrentTab = nil
    self.Tabs = {}
    return self
end

-- Create Main Window
function UILibrary:CreateWindow(config)
    config = config or {}
    local title = config.Title or "UI Library"
    local size = config.Size or UDim2.new(0, 500, 0, 400)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = size
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.MainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Title Text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -50)
    tabContainer.Position = UDim2.new(0, 10, 0, 45)
    tabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = self.MainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    self.TabContainer = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -145, 1, -50)
    contentContainer.Position = UDim2.new(0, 135, 0, 45)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = self.MainFrame
    
    self.ContentContainer = contentContainer
    
    -- Make draggable
    self:MakeDraggable(self.MainFrame, titleBar)
    
    return self
end

-- Make Frame Draggable
function UILibrary:MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create Tab
function UILibrary:CreateTab(name)
    local tab = {}
    
    -- Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name
    tabButton.Size = UDim2.new(1, -10, 0, 35)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = self.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    -- Tab Content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.Visible = false
    tabContent.Parent = self.ContentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = tabContent
    
    tab.Button = tabButton
    tab.Content = tabContent
    
    -- Tab switching
    tabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        end
        tabContent.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        self.CurrentTab = tab
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        tabContent.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        self.CurrentTab = tab
    end
    
    -- Tab methods
    function tab:AddButton(config)
        config = config or {}
        local text = config.Text or "Button"
        local callback = config.Callback or function() end
        
        local button = Instance.new("TextButton")
        button.Name = text
        button.Size = UDim2.new(1, -10, 0, 35)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.Parent = tabContent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        
        return button
    end
    
    function tab:AddToggle(config)
        config = config or {}
        local text = config.Text or "Toggle"
        local default = config.Default or false
        local callback = config.Callback or function() end
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = text
        toggleFrame.Size = UDim2.new(1, -10, 0, 35)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = tabContent
        
        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 6)
        tCorner.Parent = toggleFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 40, 0, 20)
        toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
        toggleButton.BackgroundColor3 = default and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = ""
        toggleButton.Parent = toggleFrame
        
        local tBtnCorner = Instance.new("UICorner")
        tBtnCorner.CornerRadius = UDim.new(1, 0)
        tBtnCorner.Parent = toggleButton
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BorderSizePixel = 0
        indicator.Parent = toggleButton
        
        local iCorner = Instance.new("UICorner")
        iCorner.CornerRadius = UDim.new(1, 0)
        iCorner.Parent = indicator
        
        local toggled = default
        
        toggleButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = toggled and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
            }):Play()
            
            TweenService:Create(indicator, TweenInfo.new(0.2), {
                Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            
            callback(toggled)
        end)
        
        return toggleFrame
    end
    
    function tab:AddSlider(config)
        config = config or {}
        local text = config.Text or "Slider"
        local min = config.Min or 0
        local max = config.Max or 100
        local default = config.Default or 50
        local callback = config.Callback or function() end
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = text
        sliderFrame.Size = UDim2.new(1, -10, 0, 50)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = tabContent
        
        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(0, 6)
        sCorner.Parent = sliderFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50, 0, 20)
        valueLabel.Position = UDim2.new(1, -60, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.Parent = sliderFrame
        
        local sliderBack = Instance.new("Frame")
        sliderBack.Size = UDim2.new(1, -20, 0, 6)
        sliderBack.Position = UDim2.new(0, 10, 1, -15)
        sliderBack.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        sliderBack.BorderSizePixel = 0
        sliderBack.Parent = sliderFrame
        
        local sbCorner = Instance.new("UICorner")
        sbCorner.CornerRadius = UDim.new(1, 0)
        sbCorner.Parent = sliderBack
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBack
        
        local sfCorner = Instance.new("UICorner")
        sfCorner.CornerRadius = UDim.new(1, 0)
        sfCorner.Parent = sliderFill
        
        local dragging = false
        
        sliderBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        sliderBack.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = tostring(value)
                callback(value)
            end
        end)
        
        return sliderFrame
    end
    
    function tab:AddTextbox(config)
        config = config or {}
        local text = config.Text or "Textbox"
        local placeholder = config.Placeholder or "Enter text..."
        local callback = config.Callback or function() end
        
        local textboxFrame = Instance.new("Frame")
        textboxFrame.Name = text
        textboxFrame.Size = UDim2.new(1, -10, 0, 50)
        textboxFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        textboxFrame.BorderSizePixel = 0
        textboxFrame.Parent = tabContent
        
        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 6)
        tbCorner.Parent = textboxFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = textboxFrame
        
        local textbox = Instance.new("TextBox")
        textbox.Size = UDim2.new(1, -20, 0, 20)
        textbox.Position = UDim2.new(0, 10, 1, -25)
        textbox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        textbox.BorderSizePixel = 0
        textbox.Text = ""
        textbox.PlaceholderText = placeholder
        textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
        textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        textbox.TextSize = 12
        textbox.Font = Enum.Font.Gotham
        textbox.Parent = textboxFrame
        
        local tbxCorner = Instance.new("UICorner")
        tbxCorner.CornerRadius = UDim.new(0, 4)
        tbxCorner.Parent = textbox
        
        textbox.FocusLost:Connect(function()
            callback(textbox.Text)
        end)
        
        return textboxFrame
    end
    
    function tab:AddLabel(text)
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -10, 0, 25)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = tabContent
        
        return label
    end
    
    return tab
end

return UILibrary
