https://raw.githubusercontent.com/KieurOo/Arsenal.Lua/refs/heads/main/ArsenalFile.Lua

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local Debris          = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local LOADSTRING_URL = "https://raw.githubusercontent.com/KieurOo/YohoArsenal/refs/heads/main/Lua.Arsenal"


local BUTTON_DIAMETER = 64
local TOP_MARGIN = 12
local DROP_TIME = 0.45
local BOUNCE_TIME = 0.22
local PREFETCH_TIMEOUT = 5
local NOTIF_FADE_TIME = 0.35
local NOTIF_LIFETIME = 5

local isPC = UserInputService.KeyboardEnabled
local isMobile = UserInputService.TouchEnabled and not isPC


local function safeSetFont(obj, fontCandidate, fallback)
    fallback = fallback or Enum.Font.Gotham
    local ok = pcall(function()
        if typeof(fontCandidate) == "EnumItem" then
            obj.Font = fontCandidate
        elseif type(fontCandidate) == "string" then
            local enumItem = Enum.Font[fontCandidate]
            if enumItem then
                obj.Font = enumItem
            else
                error("invalid-font-string")
            end
        else
            error("invalid-font-candidate")
        end
    end)
    if not ok then
        obj.Font = fallback
    end
end


local function http_get(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 0 then return true, res end

    if syn and syn.request then
        local ok2, r2 = pcall(function() return syn.request({Url = url, Method = "GET"}) end)
        if ok2 and r2 and r2.Body and #r2.Body > 0 then return true, r2.Body end
    end

    if request then
        local ok3, r3 = pcall(function() return request({Url = url, Method = "GET"}) end)
        if ok3 and r3 and r3.Body and #r3.Body > 0 then return true, r3.Body end
    end

    if http_request then
        local ok4, r4 = pcall(function() return http_request({Url = url, Method = "GET"}) end)
        if ok4 and r4 and r4.Body and #r4.Body > 0 then return true, r4.Body end
    end

    return false, "No HTTP method succeeded or returned empty."
end


local controller = Instance.new("ScreenGui")
controller.Name = "ChoppaTopRoundController"
controller.ResetOnSpawn = false
controller.Parent = playerGui
controller.Enabled = true


local btn = Instance.new("ImageButton")
btn.Name = "ChoppaTopButton"
btn.Size = UDim2.new(0, BUTTON_DIAMETER, 0, BUTTON_DIAMETER)
btn.AnchorPoint = Vector2.new(0.5, 0) -- center X, top Y
btn.Position = UDim2.new(0.5, 0, 0, -BUTTON_DIAMETER - 24)
btn.BackgroundTransparency = 0
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 47)
btn.BorderSizePixel = 0
btn.AutoButtonColor = false
btn.Parent = controller

local btnCorner = Instance.new("UICorner", btn)
btnCorner.CornerRadius = UDim.new(1, 0)

local gradient = Instance.new("UIGradient", btn)
gradient.Rotation = 90
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(68, 68, 74)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(38, 38, 44))
}
gradient.Transparency = NumberSequence.new(0)

local stroke = Instance.new("UIStroke", btn)
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(90, 90, 100)
stroke.Transparency = 0.7

local accent = Instance.new("Frame", btn)
accent.Name = "Accent"
accent.AnchorPoint = Vector2.new(0.5, 0.5)
accent.Position = UDim2.new(0.5, 0, 0.46, 0)
accent.Size = UDim2.new(0, 36, 0, 36)
accent.BackgroundColor3 = Color3.fromRGB(150, 110, 255)
accent.BorderSizePixel = 0
local acCorner = Instance.new("UICorner", accent)
acCorner.CornerRadius = UDim.new(1, 0)

local icon = Instance.new("TextLabel", accent)
icon.Size = UDim2.new(1, 0, 1, 0)
icon.BackgroundTransparency = 1
safeSetFont(icon, Enum.Font.GothamBold)
icon.Text = "⚙"
icon.TextSize = 20
icon.TextColor3 = Color3.fromRGB(20,20,20)
icon.TextScaled = false


local notif = Instance.new("Frame", controller)
notif.Name = "TopNotif"
notif.AnchorPoint = Vector2.new(0.5, 0)
notif.Size = UDim2.new(0, 340, 0, 44)
notif.Position = UDim2.new(0.5, 0, 0, TOP_MARGIN + BUTTON_DIAMETER + 6)
notif.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
notif.BorderSizePixel = 0
notif.BackgroundTransparency = 1
local notifCorner = Instance.new("UICorner", notif)
notifCorner.CornerRadius = UDim.new(0, 10)

local notifText = Instance.new("TextLabel", notif)
notifText.Size = UDim2.new(1, -20, 1, -12)
notifText.Position = UDim2.new(0, 10, 0, 6)
notifText.BackgroundTransparency = 1
safeSetFont(notifText, Enum.Font.Gotham)
notifText.TextSize = 14
notifText.TextColor3 = Color3.fromRGB(220,220,220)
notifText.Text = "Prefetching script..."
notifText.TextXAlignment = Enum.TextXAlignment.Left
notifText.TextTransparency = 1

local bar = Instance.new("Frame", notif)
bar.Size = UDim2.new(1, -20, 0, 6)
bar.Position = UDim2.new(0, 10, 1, -8)
bar.AnchorPoint = Vector2.new(0, 1)
bar.BackgroundColor3 = Color3.fromRGB(18,18,18)
bar.BorderSizePixel = 0

local fill = Instance.new("Frame", bar)
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
local fillCorner = Instance.new("UICorner", fill)
fillCorner.CornerRadius = UDim.new(0, 4)


local pcNotif = Instance.new("Frame", controller)
pcNotif.Name = "PCNotSupported"
pcNotif.Size = UDim2.new(0, 300, 0, 56)
pcNotif.AnchorPoint = Vector2.new(0.5, 0)
pcNotif.Position = UDim2.new(0.5, 0, 0, TOP_MARGIN + BUTTON_DIAMETER + 6)
pcNotif.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
pcNotif.BorderSizePixel = 0
pcNotif.Visible = false
local pcCorner = Instance.new("UICorner", pcNotif)
pcCorner.CornerRadius = UDim.new(0, 10)

local pcText = Instance.new("TextLabel", pcNotif)
pcText.Size = UDim2.new(1, -20, 1, -16)
pcText.Position = UDim2.new(0, 10, 0, 8)
pcText.BackgroundTransparency = 1
safeSetFont(pcText, Enum.Font.Gotham)
pcText.TextSize = 14
pcText.TextColor3 = Color3.fromRGB(240,240,240)
pcText.Text = "This feature doesn't support PC players."
pcText.TextXAlignment = Enum.TextXAlignment.Center


local preGuis = {}
for _, v in ipairs(playerGui:GetChildren()) do preGuis[v] = true end

local managed = {}
local hidden = false

local cached_body = nil
local cached_fn = nil
local prefetchDone = false
local remote_status = "idle"

local function runLoadedFunction(fn)
    local okRun, runErr = pcall(function()
        local co = coroutine.create(function() pcall(fn) end)
        coroutine.resume(co)
    end)
    return okRun, runErr
end

local function collectNewGuiItems()
    for _, v in ipairs(playerGui:GetChildren()) do
        if not preGuis[v] then
            if v:IsA("ScreenGui") or v:IsA("Folder") or v:IsA("Frame") then
                table.insert(managed, v)
            end
        end
    end
    if #managed == 0 then
        for _, v in ipairs(playerGui:GetChildren()) do
            if v:IsA("ScreenGui") and string.find(string.lower(v.Name or ""), "arsenal") then
                table.insert(managed, v)
            end
        end
    end
end


local function tryLoadRemoteAndCollect()
    notifText.Text = "Loading remote..."
    TweenService:Create(fill, TweenInfo.new(NOTIF_LIFETIME, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play() -- just visual

    if cached_body then
        local fn, loadErr = loadstring(cached_body)
        if not fn then
            notifText.Text = "Cached loadstring error: "..tostring(loadErr)
            return false, loadErr
        end
        local okRun, runErr = runLoadedFunction(fn)
        if not okRun then
            notifText.Text = "Remote runtime error: "..tostring(runErr)
            return false, runErr
        end
        task.wait(0.08)
        collectNewGuiItems()
        notifText.Text = "Loaded — found "..tostring(#managed).." gui(s)"
        return true
    end

    local ok, bodyOrErr = http_get(LOADSTRING_URL)
    if not ok then
        notifText.Text = "Fetch failed: "..tostring(bodyOrErr)
        return false, bodyOrErr
    end
    cached_body = bodyOrErr
    local fn, loadErr = loadstring(bodyOrErr)
    if not fn then
        notifText.Text = "Loadstring error: "..tostring(loadErr)
        return false, loadErr
    end
    local okRun, runErr = runLoadedFunction(fn)
    if not okRun then
        notifText.Text = "Remote runtime error: "..tostring(runErr)
        return false, runErr
    end
    task.wait(0.08)
    collectNewGuiItems()
    notifText.Text = "Loaded — found "..tostring(#managed).." gui(s)"
    return true
end


local function showTempNotif(text, duration)
    duration = duration or NOTIF_LIFETIME
    notifText.Text = text
    notif.BackgroundTransparency = 0
    fill.Size = UDim2.new(0, 0, 1, 0)
    -- fade after duration
    task.delay(duration, function()
        pcall(function()
            TweenService:Create(notif, TweenInfo.new(NOTIF_FADE_TIME), {BackgroundTransparency = 1}):Play()
            TweenService:Create(notifText, TweenInfo.new(NOTIF_FADE_TIME), {TextTransparency = 1}):Play()
            TweenService:Create(fill, TweenInfo.new(NOTIF_FADE_TIME), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            task.wait(NOTIF_FADE_TIME + 0.02)
            if notif and notif.Parent then notif:Destroy() end
        end)
    end)
end


local function prefetch()
    local ok, bodyOrErr = http_get(LOADSTRING_URL)
    if not ok then
        remote_status = "failed"
        cached_body = nil
    else
        cached_body = bodyOrErr
        local okLoad = pcall(function() cached_fn = loadstring(bodyOrErr) end)
        if not okLoad or not cached_fn then
            remote_status = "failed"
            cached_fn = nil
        else
            remote_status = "ready"
        end
    end
    prefetchDone = true
end


local function animateDropToTop()
    local targetY = TOP_MARGIN
    TweenService:Create(btn, TweenInfo.new(DROP_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, targetY)}):Play()
    task.delay(DROP_TIME, function()
        local up = TweenService:Create(btn, TweenInfo.new(BOUNCE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, targetY - 8)})
        local down = TweenService:Create(btn, TweenInfo.new(BOUNCE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, targetY)})
        up:Play()
        up.Completed:Wait()
        down:Play()
    end)
end


remote_status = "prefetching"
animateDropToTop()
task.spawn(prefetch)


notif.BackgroundTransparency = 0
notifText.TextTransparency = 0


task.spawn(function()
    local startTick = tick()
    while not prefetchDone and (tick() - startTick < PREFETCH_TIMEOUT) do
        local progress = math.clamp((tick() - startTick) / PREFETCH_TIMEOUT, 0, 1)
        fill.Size = UDim2.new(progress, 0, 1, 0)
        task.wait(0.04)
    end
    if prefetchDone then
        fill.Size = UDim2.new(1, 0, 1, 0)
    end
    if remote_status == "ready" then
        notifText.Text = "Auto-loading..."
        local ok, err = tryLoadRemoteAndCollect()
        if ok then
            notifText.Text = "Auto-loaded — found "..tostring(#managed).." gui(s). Press K to toggle."
        else
            notifText.Text = "Auto-load failed: "..tostring(err)..". Press K/tap to retry."
            cached_body = nil
            cached_fn = nil
            remote_status = "failed"
        end
    elseif prefetchDone and remote_status ~= "ready" then
        notifText.Text = "Prefetch failed — will attempt on tap/K"
    else
        notifText.Text = "No response yet — will attempt on tap/K"
    end
end)


task.delay(NOTIF_LIFETIME, function()
    if notif and notif.Parent then
        TweenService:Create(notif, TweenInfo.new(NOTIF_FADE_TIME), {BackgroundTransparency = 1}):Play()
        TweenService:Create(notifText, TweenInfo.new(NOTIF_FADE_TIME), {TextTransparency = 1}):Play()
        TweenService:Create(fill, TweenInfo.new(NOTIF_FADE_TIME), {Size = UDim2.new(0, 0, 1, 0)}):Play()
        task.wait(NOTIF_FADE_TIME + 0.02)
        if notif and notif.Parent then notif:Destroy() end
    end
end)

-- PC-not-supported popup (for clicks only)
local function showPCNotSupported()
    if not pcNotif or not pcNotif.Parent then pcNotif.Parent = controller end
    pcNotif.Visible = true
    pcNotif.BackgroundTransparency = 1
    pcText.TextTransparency = 1
    TweenService:Create(pcNotif, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
    TweenService:Create(pcText, TweenInfo.new(0.18), {TextTransparency = 0}):Play()
    task.delay(3, function()
        if pcNotif and pcNotif.Parent then
            TweenService:Create(pcNotif, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
            TweenService:Create(pcText, TweenInfo.new(0.18), {TextTransparency = 1}):Play()
            task.wait(0.18)
            if pcNotif and pcNotif.Parent then pcNotif:Destroy() end
        end
    end)
end


btn.MouseButton1Click:Connect(function()
    btn.Active = false
    TweenService:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {Size = UDim2.new(0, BUTTON_DIAMETER - 6, 0, BUTTON_DIAMETER - 6)}):Play()
    task.wait(0.07)
    TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Size = UDim2.new(0, BUTTON_DIAMETER, 0, BUTTON_DIAMETER)}):Play()

    if isPC then
        showPCNotSupported()
        btn.Active = true
        return
    end

    if #managed == 0 then
        local ok, err = tryLoadRemoteAndCollect()
        if not ok then
            showTempNotif("Load failed: "..tostring(err), 4)
            btn.Active = true
            return
        end
    end

    hidden = not hidden
    for _, gui in ipairs(managed) do
        if gui and gui.Parent then
            if gui:IsA("ScreenGui") then
                gui.Enabled = not hidden
            elseif gui:IsA("GuiObject") then
                gui.Visible = not hidden
            end
        end
    end

    local pulse = TweenService:Create(accent, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {BackgroundColor3 = hidden and Color3.fromRGB(200,80,90) or Color3.fromRGB(150,110,255)})
    pulse:Play()
    pulse.Completed:Connect(function()
        TweenService:Create(accent, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(150,110,255)}):Play()
    end)

    btn.Active = true
end)


btn.MouseButton2Click:Connect(function()
    for _, v in ipairs(playerGui:GetChildren()) do
        local already = false
        for _, m in ipairs(managed) do if m == v then already = true break end end
        if not already and (v:IsA("ScreenGui") or v:IsA("Folder") or v:IsA("Frame")) then
            table.insert(managed, v)
        end
    end
    TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.2}):Play()
    task.wait(0.12)
    TweenService:Create(stroke, TweenInfo.new(0.18), {Transparency = 0.7}):Play()
end)


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        -- ensure loaded
        if #managed == 0 then
            local ok, err = tryLoadRemoteAndCollect()
            if not ok then
                showTempNotif("Load failed: "..tostring(err), 4)
                return
            end
        end


        hidden = not hidden
        for _, gui in ipairs(managed) do
            if gui and gui.Parent then
                if gui:IsA("ScreenGui") then
                    gui.Enabled = not hidden
                elseif gui:IsA("GuiObject") then
                    gui.Visible = not hidden
                end
            end
        end


        local pulse = TweenService:Create(accent, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {BackgroundColor3 = hidden and Color3.fromRGB(200,80,90) or Color3.fromRGB(150,110,255)})
        pulse:Play()
        pulse.Completed:Connect(function()
            TweenService:Create(accent, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(150,110,255)}):Play()
        end)
    end
end)

print("CHOPPA: top round button script loaded. K toggles on all platforms; button click blocked on PC.")
