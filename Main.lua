--// Froggy Hub - Sniper 1000 (Auto-Flicker Glitch + Bypasses)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    Enabled = false,
    Size = 1000
}

local originalData = {}
local originalShopTouches = {}
local shieldedPlayersParts = {}
local honeypotParts = {}

-- UI Básica
local gui = Instance.new("ScreenGui")
gui.Name = "FroggySniperExact"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(260, 100)
main.Position = UDim2.fromOffset(20, 20)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 50, 50) 
stroke.Thickness = 2

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 1)
title.BackgroundTransparency = 1
title.Text = "SNIPER 1000 (AUTO-FLICKER)"
title.TextColor3 = Color3.fromRGB(255, 50, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = titleBar

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 40)
btn.Position = UDim2.fromOffset(10, 40)
btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.Text = "ACTIVAR: OFF"
btn.ZIndex = 5
btn.Parent = main
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
titleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Lógica del Handle
local function getHandle(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    return tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
end

local function expandSword(tool)
    local handle = getHandle(tool)
    if not handle then return end

    if not originalData[handle] then
        originalData[handle] = { Size = handle.Size, Transparency = handle.Transparency, CanCollide = handle.CanCollide, Massless = handle.Massless, CanTouch = handle.CanTouch }
    end

    handle.Size = Vector3.new(Config.Size, Config.Size, Config.Size)
    handle.Transparency = 1 
    handle.CanCollide = false 
    handle.Massless = true
    handle.CanTouch = true
end

local function restoreSword(tool)
    local handle = getHandle(tool)
    if not handle or not originalData[handle] then return end
    
    local data = originalData[handle]
    handle.Size = data.Size
    handle.Transparency = data.Transparency
    handle.CanCollide = data.CanCollide
    handle.Massless = data.Massless
    handle.CanTouch = data.CanTouch
    originalData[handle] = nil
end

-- 🔥 1. BLOQUEAR COMPRAS Y UI
if getrawmetatable and newcclosure then
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if Config.Enabled and (method == "PromptProductPurchase" or method == "PromptGamePassPurchase" or method == "PromptPurchase") then
            return nil 
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

local function blockShopsAndPlates()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
            
            if name:find("shop") or name:find("buy") or name:find("gacha") or name:find("store") or name:find("robux") 
            or name:find("plate") or name:find("pad") or name:find("statue") or name:find("element")
            or parentName:find("shop") or parentName:find("gacha") or parentName:find("plate") then
                
                if not originalShopTouches[obj] then
                    originalShopTouches[obj] = obj.CanTouch
                    obj.CanTouch = false 
                end
            end
        end
    end
end

local function restoreShops()
    for part, canTouch in pairs(originalShopTouches) do
        if part and part.Parent then part.CanTouch = canTouch end
    end
    originalShopTouches = {}
end

local allowedGuis = { "Chat", "PlayerList", "Backpack", "Health", "FroggySniperExact", "FroggyHub", "FroggyRivalsDesign", "TouchGui", "CoreGui" }

local function hideUIFriendly(guiObj)
    if not Config.Enabled then return end
    if guiObj:IsA("ScreenGui") then
        local isAllowed = false
        for _, allowed in ipairs(allowedGuis) do
            if guiObj.Name:find(allowed) then isAllowed = true break end
        end
        
        if not isAllowed then
            for _, obj in ipairs(guiObj:GetDescendants()) do
                if obj:IsA("GuiObject") then
                    obj.BackgroundTransparency = 1
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then obj.TextTransparency = 1
                    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then obj.ImageTransparency = 1 end
                end
            end
        end
    end
end

PlayerGui.ChildAdded:Connect(hideUIFriendly)

-- 🔥 2. IGNORAR ESCUDOS DE JUGADORES
local function manageShields()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hasShield = p.Character:FindFirstChildOfClass("ForceField") or (p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid:FindFirstChildOfClass("ForceField"))
            
            if hasShield then
                if not shieldedPlayersParts[p] then shieldedPlayersParts[p] = {} end
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not shieldedPlayersParts[p][part] then
                            shieldedPlayersParts[p][part] = { CanTouch = part.CanTouch, CanQuery = part.CanQuery }
                            part.CanTouch = false
                            part.CanQuery = false
                        end
                    end
                end
            else
                if shieldedPlayersParts[p] then
                    for part, data in pairs(shieldedPlayersParts[p]) do
                        if part and part.Parent then
                            part.CanTouch = data.CanTouch
                            part.CanQuery = data.CanQuery
                        end
                    end
                    shieldedPlayersParts[p] = nil
                end
            end
        end
    end
end

-- 🔥 3. IGNORAR HONEYPOTS
local function manageHoneypots()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            
            if name:find("anticheat") or name:find("anti-cheat") or name:find("ac_npc") or name:find("honeypot") or name:find("trap") or name:find("bait") then
                if obj:IsA("BasePart") then
                    if not honeypotParts[obj] then
                        honeypotParts[obj] = { CanTouch = obj.CanTouch, CanQuery = obj.CanQuery }
                        obj.CanTouch = false
                        obj.CanQuery = false
                    end
                else
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not honeypotParts[part] then
                                honeypotParts[part] = { CanTouch = part.CanTouch, CanQuery = part.CanQuery }
                                part.CanTouch = false
                                part.CanQuery = false
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 🔥 4. EL BUCLE DEL AUTO-FLICKER (El truco de daño)
task.spawn(function()
    while task.wait() do
        if Config.Enabled then
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                -- Prender (Expandir)
                expandSword(tool)
                task.wait(0.25) -- Mantener gigante por un cuarto de segundo
                
                -- Apagar (Restaurar)
                restoreSword(tool)
                task.wait(0.25) -- Mantener normal por un cuarto de segundo (Total: 2 ciclos por segundo)
            else
                task.wait(0.1)
            end
        else
            task.wait(0.1)
        end
    end
end)

-- Bucle de Mantenimiento (Solo Bypasses y físicas)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")

    -- Asegurar que no esté anclado
    if root and root.Anchored then root.Anchored = false end
    if hum and hum.PlatformStand then hum.PlatformStand = false end

    if not tool then return end

    if Config.Enabled then
        manageShields()
        manageHoneypots()
    else
        -- Asegurarnos de restaurar si se apaga en medio del ciclo
        local handle = getHandle(tool)
        if handle and originalData[handle] then
            restoreSword(tool)
        end
        for p, parts in pairs(shieldedPlayersParts) do
            for part, data in pairs(parts) do
                if part and part.Parent then
                    part.CanTouch = data.CanTouch
                    part.CanQuery = data.CanQuery
                end
            end
        end
        shieldedPlayersParts = {}
        
        for part, data in pairs(honeypotParts) do
            if part and part.Parent then
                part.CanTouch = data.CanTouch
                part.CanQuery = data.CanQuery
            end
        end
        honeypotParts = {}
    end
end)

btn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    btn.Text = "ACTIVAR: " .. (Config.Enabled and "ON" or "OFF")
    btn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(110, 220, 90) or Color3.fromRGB(180, 50, 50)
    
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    
    if Config.Enabled then
        blockShopsAndPlates() 
    else
        restoreShops() 
        if tool then restoreSword(tool) end
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    restoreShops()
end)
