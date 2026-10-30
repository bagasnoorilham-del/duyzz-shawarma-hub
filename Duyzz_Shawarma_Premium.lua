-- ==============================================================================
-- 🚀 DUYZZ'S DIGITAL WORKS | SHAWARMA ANOMALIES HUB (PREMIUM SINGLE-FILE)
-- 👤 Developer : Bagas (Duyzz)
-- 🔑 Key       : duyzzwork
-- 📅 Version   : 2.5.0 (Enterprise Edition)
-- ==============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- 🛠️ 1. GLOBAL CONFIGURATION & STATES
-- ==========================================
local DuyzzConfig = {
    Watermark = "Duyzz's Digital Works",
    WebhookURL = "",
    Delays = {
        AutoServe = 0.5,
        AutoReject = 0.8,
        ESPUpdate = 1
    },
    Colors = {
        Normal = Color3.fromRGB(16, 185, 129), -- Emerald Green
        Anomaly = Color3.fromRGB(239, 68, 68), -- Crimson Red
        Item = Color3.fromRGB(59, 130, 246)    -- Royal Blue
    },
    Toggles = {
        -- Security
        AntiAFK = true,
        -- Kitchen
        AutoCook = false,
        AutoServe = false,
        AutoReject = false,
        AutoCollectCash = false,
        -- Visuals
        ESPNormal = false,
        ESPAnomaly = false,
        FullBright = false,
        -- Player Mods
        WalkSpeedToggle = false,
        JumpPowerToggle = false,
        NoClip = false,
        InfiniteJump = false
    },
    Values = {
        WalkSpeed = 16,
        JumpPower = 50
    }
}

-- ==========================================
-- 🛡️ 2. SECURITY & UTILITIES (CORE)
-- ==========================================
local Utils = {}

-- Bypass Anti-AFK (Biar lu bisa ditinggal tidur)
LocalPlayer.Idled:Connect(function()
    if DuyzzConfig.Toggles.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
        print("[DuyzzHub] Anti-AFK Triggered. Char aman dari kick.")
    end
end)

-- Eksekusi ProximityPrompt (Tombol Tap E/Tap Layar) secara instan
function Utils.TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    
    local oldDist = prompt.MaxActivationDistance
    local oldLos = prompt.RequiresLineOfSight
    
    prompt.MaxActivationDistance = math.huge
    prompt.RequiresLineOfSight = false
    
    if fireproximityprompt then
        fireproximityprompt(prompt, 1, true)
    else
        -- Fallback buat executor yang kurang OP
        prompt:InputHoldBegin()
        task.wait(0.1)
        prompt:InputHoldEnd()
    end
    
    prompt.MaxActivationDistance = oldDist
    prompt.RequiresLineOfSight = oldLos
end

-- Algoritma Deteksi Monster / Anomali Tingkat Lanjut
function Utils.IsAnomaly(entity)
    if not entity or not entity:IsA("Model") then return false end
    
    -- Cek Nama Model (Brute Force Check)
    local nameLower = string.lower(entity.Name)
    local badWords = {"anomaly", "monster", "fake", "hollow", "creature", "evil", "demon", "unknown"}
    for _, word in ipairs(badWords) do
        if string.find(nameLower, word) then return true end
    end
    
    -- Cek Value & Attributes Tersembunyi
    local isAnomVal = entity:FindFirstChild("IsAnomaly") or entity:FindFirstChild("Anomaly") or entity:FindFirstChild("Fake")
    if isAnomVal and (isAnomVal.Value == true or isAnomVal.Value == 1) then return true end
    if entity:GetAttribute("IsAnomaly") == true or entity:GetAttribute("Monster") == true then return true end
    
    return false
end

-- ==========================================
-- 👁️ 3. VISUALS & ESP SYSTEM
-- ==========================================
local function CreateESP(target, color, tag, name)
    if not target or target:FindFirstChild(tag) then return end
    
    -- Highlight (Kotak Nyala)
    local hl = Instance.new("Highlight")
    hl.Name = tag
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = target
    
    -- Billboard UI (Teks Nama di Atas Kepala)
    local head = target:FindFirstChild("Head") or target:FindFirstChildWhichIsA("BasePart")
    if head then
        local bg = Instance.new("BillboardGui")
        bg.Name = tag .. "_Text"
        bg.Parent = target
        bg.Adornee = head
        bg.Size = UDim2.new(0, 100, 0, 40)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.AlwaysOnTop = true
        
        local txt = Instance.new("TextLabel")
        txt.Parent = bg
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = name or target.Name
        txt.TextColor3 = color
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextScaled = true
    end
end

local function ClearESP(target, tag)
    if not target then return end
    if target:FindFirstChild(tag) then target[tag]:Destroy() end
    if target:FindFirstChild(tag .. "_Text") then target[tag .. "_Text"]:Destroy() end
end

-- Loop Scanner ESP
task.spawn(function()
    while task.wait(DuyzzConfig.Delays.ESPUpdate) do
        for _, obj in pairs(workspace:GetDescendants()) do
            -- Filter NPC/Pemain
            if obj:IsA("Model") and (obj:FindFirstChild("Humanoid") or obj:FindFirstChild("Head")) and obj ~= LocalPlayer.Character then
                if Utils.IsAnomaly(obj) then
                    if DuyzzConfig.Toggles.ESPAnomaly then
                        CreateESP(obj, DuyzzConfig.Colors.Anomaly, "Duyzz_AnomalyESP", "⚠️ ANOMALI")
                    else
                        ClearESP(obj, "Duyzz_AnomalyESP")
                    end
                else
                    if DuyzzConfig.Toggles.ESPNormal then
                        CreateESP(obj, DuyzzConfig.Colors.Normal, "Duyzz_NormalESP", "✅ ORANG NORMAL")
                    else
                        ClearESP(obj, "Duyzz_NormalESP")
                    end
                end
            end
        end
    end
end)

-- FullBright (Night Vision)
task.spawn(function()
    while task.wait(0.5) do
        if DuyzzConfig.Toggles.FullBright then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
            Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
        end
    end
end)

-- ==========================================
-- 🍔 4. AUTO FARM & KITCHEN SYSTEM
-- ==========================================
task.spawn(function()
    while task.wait(DuyzzConfig.Delays.AutoServe) do
        pcall(function()
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local act = string.lower(prompt.ActionText .. prompt.Name)
                    
                    -- A. Auto Cook & Prepare
                    if DuyzzConfig.Toggles.AutoCook then
                        if string.find(act, "cook") or string.find(act, "cut") or string.find(act, "take") or string.find(act, "wrap") or string.find(act, "shawarma") or string.find(act, "prepare") then
                            Utils.TriggerPrompt(prompt)
                            task.wait(0.05)
                        end
                    end
                    
                    -- B. Auto Serve Normal People
                    if DuyzzConfig.Toggles.AutoServe then
                        if string.find(act, "give") or string.find(act, "serve") or string.find(act, "kasih") then
                            local customer = prompt:FindFirstAncestorOfClass("Model")
                            if customer and not Utils.IsAnomaly(customer) then
                                Utils.TriggerPrompt(prompt)
                            end
                        end
                    end
                    
                    -- C. Auto Reject Anomaly / Tutup Tirai
                    if DuyzzConfig.Toggles.AutoReject then
                        if string.find(act, "close") or string.find(act, "reject") or string.find(act, "shut") or string.find(act, "tutup") then
                            for _, anom in pairs(workspace:GetDescendants()) do
                                if anom:IsA("Model") and Utils.IsAnomaly(anom) then
                                    local dist = (anom:GetPivot().Position - prompt.Parent.Position).Magnitude
                                    if dist < 20 then -- Jarak deteksi bahaya 20 studs
                                        Utils.TriggerPrompt(prompt)
                                        task.wait(1)
                                    end
                                end
                            end
                        end
                    end
                    
                    -- D. Auto Collect Uang / Tips
                    if DuyzzConfig.Toggles.AutoCollectCash then
                        if string.find(act, "collect") or string.find(act, "cash") or string.find(act, "tip") then
                            Utils.TriggerPrompt(prompt)
                        end
                    end
                    
                end
            end
        end)
    end
end)

-- ==========================================
-- 🏃 5. LOCAL PLAYER MODS (CHEATS)
-- ==========================================
-- WalkSpeed & JumpPower Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            if DuyzzConfig.Toggles.WalkSpeedToggle then
                char.Humanoid.WalkSpeed = DuyzzConfig.Values.WalkSpeed
            end
            if DuyzzConfig.Toggles.JumpPowerToggle then
                char.Humanoid.JumpPower = DuyzzConfig.Values.JumpPower
                char.Humanoid.UseJumpPower = true
            end
        end
    end)
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if DuyzzConfig.Toggles.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if DuyzzConfig.Toggles.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ==========================================
-- 🎨 6. RAYFIELD UI INTEGRATION
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = DuyzzConfig.Watermark .. " | Shawarma",
   LoadingTitle = "Memuat Modul Enterprise...",
   LoadingSubtitle = "by Duyzz x Xyaza",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DuyzzHub",
      FileName = "ShawarmaConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "Duyzz Hub - Otentikasi",
      Subtitle = "Masukkan Lisensi Khusus",
      Note = "Key lu: duyzzwork",
      FileName = "DuyzzShawarmaKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"duyzzwork"}
   }
})

-- ==========================================
-- 📑 7. TAB CREATION
-- ==========================================
local DashboardTab = Window:CreateTab("🚀 Dashboard", 4483362458)
local KitchenTab = Window:CreateTab("🍔 Auto Kitchen", 4483345998)
local VisualTab = Window:CreateTab("👁️ Visuals & ESP", 4483362458)
local PlayerTab = Window:CreateTab("🏃 Player Mods", 4483345998)

-- --- DASHBOARD TAB ---
DashboardTab:CreateSection("Status Sistem")
DashboardTab:CreateLabel("Status: ONLINE ✅")
DashboardTab:CreateLabel("Bypass Anti-Cheat: AKTIF 🛡️")
DashboardTab:CreateToggle({
   Name = "Anti-AFK (Bypass Kick Server)",
   CurrentValue = true,
   Flag = "AntiAFK",
   Callback = function(Value) DuyzzConfig.Toggles.AntiAFK = Value end,
})

-- --- KITCHEN TAB (AUTO FARM) ---
KitchenTab:CreateSection("Interaksi Dapur")
KitchenTab:CreateToggle({
   Name = "Auto Siapin Bahan & Masak (Cook/Wrap)",
   CurrentValue = false,
   Flag = "AutoCook",
   Callback = function(Value) DuyzzConfig.Toggles.AutoCook = Value end,
})
KitchenTab:CreateToggle({
   Name = "Auto Layani Pelanggan Normal (Safe Serve)",
   CurrentValue = false,
   Flag = "AutoServe",
   Callback = function(Value) DuyzzConfig.Toggles.AutoServe = Value end,
})
KitchenTab:CreateSection("Sistem Keamanan Kios")
KitchenTab:CreateToggle({
   Name = "Auto Tolak/Tutup Tirai Pas Ada Monster",
   CurrentValue = false,
   Flag = "AutoReject",
   Callback = function(Value) DuyzzConfig.Toggles.AutoReject = Value end,
})
KitchenTab:CreateToggle({
   Name = "Auto Ambil Uang / Tips (Auto Cash)",
   CurrentValue = false,
   Flag = "AutoCollectCash",
   Callback = function(Value) DuyzzConfig.Toggles.AutoCollectCash = Value end,
})

-- --- VISUALS TAB ---
VisualTab:CreateSection("Sistem Radar Entitas")
VisualTab:CreateToggle({
   Name = "ESP Monster / Anomali (Radar Merah)",
   CurrentValue = false,
   Flag = "ESPAnomaly",
   Callback = function(Value)
       DuyzzConfig.Toggles.ESPAnomaly = Value
       if not Value then
           for _, obj in pairs(workspace:GetDescendants()) do ClearESP(obj, "Duyzz_AnomalyESP") end
       end
   end,
})
VisualTab:CreateToggle({
   Name = "ESP Orang Normal (Radar Emerald)",
   CurrentValue = false,
   Flag = "ESPNormal",
   Callback = function(Value)
       DuyzzConfig.Toggles.ESPNormal = Value
       if not Value then
           for _, obj in pairs(workspace:GetDescendants()) do ClearESP(obj, "Duyzz_NormalESP") end
       end
   end,
})
VisualTab:CreateSection("Penerangan Map")
VisualTab:CreateToggle({
   Name = "FullBright (Mode Terang/Night Vision)",
   CurrentValue = false,
   Flag = "FullBright",
   Callback = function(Value) DuyzzConfig.Toggles.FullBright = Value end,
})

-- --- PLAYER MODS TAB ---
PlayerTab:CreateSection("Manipulasi Karakter")
PlayerTab:CreateToggle({
   Name = "Aktifkan WalkSpeed",
   CurrentValue = false,
   Flag = "WSToggle",
   Callback = function(Value) DuyzzConfig.Toggles.WalkSpeedToggle = Value end,
})
PlayerTab:CreateSlider({
   Name = "Kecepatan Lari",
   Range = {16, 120},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WSSlider",
   Callback = function(Value) DuyzzConfig.Values.WalkSpeed = Value end,
})
PlayerTab:CreateToggle({
   Name = "Aktifkan JumpPower",
   CurrentValue = false,
   Flag = "JPToggle",
   Callback = function(Value) DuyzzConfig.Toggles.JumpPowerToggle = Value end,
})
PlayerTab:CreateSlider({
   Name = "Kekuatan Lompat",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JPSlider",
   Callback = function(Value) DuyzzConfig.Values.JumpPower = Value end,
})
PlayerTab:CreateSection("Super Powers")
PlayerTab:CreateToggle({
   Name = "NoClip (Tembus Tembok)",
   CurrentValue = false,
   Flag = "NoClipToggle",
   Callback = function(Value) DuyzzConfig.Toggles.NoClip = Value end,
})
PlayerTab:CreateToggle({
   Name = "Infinite Jump (Lompat di Udara)",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value) DuyzzConfig.Toggles.InfiniteJump = Value end,
})

-- ==========================================
-- 🎉 8. STARTUP NOTIFICATION
-- ==========================================
Rayfield:Notify({
   Title = "Hub Berhasil Dimuat!",
   Content = "Selamat datang di Duyzz Shawarma Hub Enterprise. Script udah siap tempur!",
   Duration = 6,
   Image = 4483362458,
})
