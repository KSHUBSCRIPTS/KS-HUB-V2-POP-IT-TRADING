local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local window = Rayfield:CreateWindow({
    Name = "KS HUB V2",
    LoadingTitle = "KS HUB V2",
    LoadingSubtitle = "Pop it trading",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "KSHubV2",
        FileName = "Config"
    }
})

local autoBuyEnabled = false
local autoSellEnabled = false
local autoDropEnabled = false
local autoBuyLenayEnabled = false
local autoBuyXoxEnabled = false

local autoItemBox = { Text = "" }
local scamItemBox = { Text = "" }

local function getMatchedItemName(input)
    return input
end

local function fuzzyMatch(str, target)
    return string.find(string.lower(str), string.lower(target)) ~= nil
end

local homeTab = window:CreateTab({
    Name = "Home",
    Icon = 93364949241311
})

local autoTab = window:CreateTab({
    Name = "Auto",
    Icon = 93364949241311
})

autoTab:CreateInput({
    Name = "Enter Item",
    PlaceholderText = "Tape ton texte ici...",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        autoItemBox.Text = value
        print("Item mis à jour :", value)
    end,
})

autoTab:CreateToggle({
    Name = "Auto Buy",
    CurrentValue = false,
    Callback = function(value)
        autoBuyEnabled = value
    end,
})

autoTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(value)
        autoSellEnabled = value
    end,
})

autoTab:CreateToggle({
    Name = "Auto Drop",
    CurrentValue = false,
    Callback = function(value)
        autoDropEnabled = value
    end,
})

local scamTab = window:CreateTab({
    Name = "Scam",
    Icon = 93364949241311
})

scamTab:CreateInput({
    Name = "Enter Item",
    PlaceholderText = "Enter ton item...",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        scamItemBox.Text = value
        print("Scam item :", scamItemBox.Text)
    end,
})

scamTab:CreateButton({
    Name = "Fake Jump",
    Callback = function()
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end,
})

scamTab:CreateButton({
    Name = "Grab My Item",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local character = player.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if not hrp or not humanoid then return end

                local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
                local searchName = scamItemBox.Text ~= "" and scamItemBox.Text or autoItemBox.Text
                local targetName = searchName ~= "" and getMatchedItemName(searchName) or ""

                local equipEvent = remoteEvents and remoteEvents:FindFirstChild("Equip")
                local dropEvent = remoteEvents and remoteEvents:FindFirstChild("Drop")
                if targetName ~= "" then
                    if equipEvent then pcall(function() equipEvent:FireServer(targetName) end) end
                    task.wait(0.05)
                    if dropEvent then pcall(function() dropEvent:FireServer(targetName) end) end
                    task.wait(0.2)
                end

                for _, obj in ipairs(workspace:GetDescendants()) do
                    if (obj:IsA("Tool") or obj:IsA("Model")) and not obj:GetAttribute("IsKSHubFake") then
                        local matchesTarget = (targetName == "" and obj:IsA("Tool")) or (targetName ~= "" and fuzzyMatch(obj.Name, targetName))

                        if matchesTarget then
                            local primaryPart = obj:IsA("Tool") and (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")) or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))

                            if primaryPart then
                                local dist = (primaryPart.Position - hrp.Position).Magnitude
                                if dist < 500 then
                                    for _, part in ipairs(obj:GetDescendants()) do
                                        if part:IsA("BasePart") then
                                            part.CanCollide = false
                                            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                            part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                        end
                                    end

                                    if obj:IsA("Model") and obj.PrimaryPart then
                                        obj:SetPrimaryPartCFrame(hrp.CFrame)
                                    else
                                        primaryPart.CFrame = hrp.CFrame
                                    end

                                    if firetouchinterest then
                                        pcall(function()
                                            firetouchinterest(hrp, primaryPart, 0)
                                            task.wait(0.01)
                                            firetouchinterest(hrp, primaryPart, 1)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end

                task.wait(0.1)
                for _, tool in ipairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        pcall(function() humanoid:EquipTool(tool) end)
                    end
                end

                task.wait(0.05)
                pcall(function()
                    if humanoid then
                        humanoid.Jump = true
                    end
                    local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
                    if remoteEventsFolder then
                        local jumpedEvent = remoteEventsFolder:FindFirstChild("Jumped")
                        if jumpedEvent then
                            jumpedEvent:FireServer()
                        end
                    end
                end)
            end)
        end)
    end,
})

local nftTab = window:CreateTab({
    Name = "NFT",
    Icon = 93364949241311
})

nftTab:CreateButton({
    Name = "Buy Lenay",
    Callback = function()
        pcall(function()
            local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
            if remoteEvents and remoteEvents:FindFirstChild("BuyItemCash") then
                remoteEvents.BuyItemCash:FireServer("Lenay", 0, 1)
            end
        end)
    end,
})

nftTab:CreateToggle({
    Name = "Auto Buy Lenay",
    CurrentValue = false,
    Callback = function(value)
        autoBuyLenayEnabled = value
    end,
})

nftTab:CreateButton({
    Name = "Buy xox",
    Callback = function()
        pcall(function()
            local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
            if remoteEvents and remoteEvents:FindFirstChild("BuyItemCash") then
                remoteEvents.BuyItemCash:FireServer("XOX", 0, 1)
            end
        end)
    end,
})

nftTab:CreateToggle({
    Name = "Auto Buy xox",
    CurrentValue = false,
    Callback = function(value)
        autoBuyXoxEnabled = value
    end,
})

local settingsTab = window:CreateTab({
    Name = "Settings",
    Icon = 93364949241311
})

settingsTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        pcall(function()
            local servers = {}
            local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
            local data = HttpService:JSONDecode(req)
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(servers, server.id)
                    end
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], player)
            else
                TeleportService:Teleport(game.PlaceId, player)
            end
        end)
    end,
})

settingsTab:CreateDropdown({
    Name = "Hub Theme / Color",
    Options = {
        "Default", 
        "DarkBlue", 
        "Ocean", 
        "Amethyst", 
        "Green", 
        "Red / Crimson", 
        "Purple / Violet", 
        "Pink / Rose", 
        "Yellow / Gold", 
        "Orange / Sunset", 
        "Cyan / Neon", 
        "Light", 
        "Dark / AMOLED"
    },
    CurrentOption = "Default",
    Callback = function(Option)
        pcall(function()
            print("Thème / Couleur sélectionné :", Option)
        end)
    end,
})

task.spawn(function()
    while true do
        if autoBuyEnabled and autoItemBox.Text ~= "" then
            pcall(function()
                local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
                if remoteEvents then
                    local buyEvent = remoteEvents:FindFirstChild("BuyItemCash")
                    if buyEvent then
                        local resolvedName = getMatchedItemName(autoItemBox.Text)
                        buyEvent:FireServer(resolvedName)
                    end
                end
            end)
            task.wait(0.2)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if autoBuyLenayEnabled then
            pcall(function()
                local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
                if remoteEvents and remoteEvents:FindFirstChild("BuyItemCash") then
                    remoteEvents.BuyItemCash:FireServer("Lenay", 0, 1)
                end
            end)
            task.wait(0.2)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if autoBuyXoxEnabled then
            pcall(function()
                local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
                if remoteEvents and remoteEvents:FindFirstChild("BuyItemCash") then
                    remoteEvents.BuyItemCash:FireServer("XOX", 0, 1)
                end
            end)
            task.wait(0.2)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if autoSellEnabled then
            pcall(function()
                local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
                local equipEvent = remoteEvents and remoteEvents:FindFirstChild("Equip")
                local sellEvent = remoteEvents and remoteEvents:FindFirstChild("Sell")
                local itemName = autoItemBox.Text ~= "" and getMatchedItemName(autoItemBox.Text) or "Bee"

                if equipEvent then
                    equipEvent:FireServer(itemName)
                end
                task.wait(0.05)
                if sellEvent then
                    sellEvent:FireServer(itemName)
                end
            end)
            task.wait(0.2)
        else
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while true do
        if autoDropEnabled then
            pcall(function()
                local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
                local equipEvent = remoteEvents and remoteEvents:FindFirstChild("Equip")
                local dropEvent = remoteEvents and remoteEvents:FindFirstChild("Drop")
                local itemName = autoItemBox.Text ~= "" and getMatchedItemName(autoItemBox.Text) or "Bee"

                if equipEvent then
                    equipEvent:FireServer(itemName)
                end
                task.wait(0.05)
                if dropEvent then
                    dropEvent:FireServer(itemName)
                end
            end)
            task.wait(0.15)
        else
            task.wait(0.1)
        end
    end
end)
