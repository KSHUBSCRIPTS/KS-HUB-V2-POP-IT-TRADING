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
local spyTarget = { Text = "" }

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)

local Remotes = {
    BuyItemCash = RemoteEvents and RemoteEvents:FindFirstChild("BuyItemCash"),
    Equip       = RemoteEvents and RemoteEvents:FindFirstChild("Equip"),
    Drop        = RemoteEvents and RemoteEvents:FindFirstChild("Drop"),
    Sell        = RemoteEvents and RemoteEvents:FindFirstChild("Sell"),
    RequestCode = RemoteEvents and RemoteEvents:FindFirstChild("RequestCode"),
    Jumped      = RemoteEvents and RemoteEvents:FindFirstChild("Jumped"),
}

local CodeDatabase = {
    "blockybrains", "topcrop", "ububla", "mamboitaliano", "itsfrenchforcoupdetat",
    "thecheese", "jokesonu", "hackthemainframe", "chunkychocolate", "luckoirsh",
    "swingbattabatta", "landdownunder", "lov3bug", "wuggyhugs", "o-d-n-a-r",
    "thetrades", "winterarc", "feliznavidad", "farmergray", "babyitscoldoutside",
    "gobblegobble", "saltisspicy", "tedsonvaca", "feelinsprunki", "mralladdinsir",
    "dingdong", "ur2slow", "iamsteve", "elontruck", "fineanddandy",
    "pureimagination", "uvebeengnomed!", "gotanygrapes?", "quickswap",
    "smileforthecamera", "Secretrecipe", "veryimportant", "pizzatime!!",
    "R-A-N-D-O", "pizzeria", "catnap", "Doodle", "firstnaf", "kingofthepirates",
    "steprightup!", "jumpinjaks", "BoingBoing!", "funkimunkii", "FantasticPlastic",
    "whonewit?", "Kreekcraft", "12345", "b5nb5n", "stoked", "categg",
    "doilookpretty", "pingu", "miaminights", "letsgetweird", "heartburn", "ewww",
    "holasoyd0ra", "b4nb4n", "Itsalive!", "metacarpus", "kawa11", "m3rry",
    "meoooow", "thursday", "candy", "fifi", "youspinme", "yodome", "aredsword",
    "daegg", "halloweenie", "callmemaybe", "knocknock", "lachancla", "popit1year",
    "knock-knock", "whaaaaaa", "pepto", "lasagna", "******", "throne", "1337",
    "m0dn4r", "madregate", "Juego", "baila", "fotito", "pÃ¡jaro", "100k", "gub",
    "lightemup", "wth", "pineapple", "portal", "r41nb0w", "farmer", "code",
    "upupup", "90sec", "noclip", "trippy", "naughtyornice", "kitty", "popit!",
    "stuffi", "armor?", "sugar", "cupid", "no", "tako", "éž­ç‚®", "Tony", "Loot",
    "buff", "2022", "ice", "chance", "juaniday2021", "sus", "quidditch",
    "spooky21", "crystal", "eeek", "squid", "gummy", "pizzatimepizzaria",
    "catnapped", "NEWFRIENDS", "XOXLOVE", "TRADEFUN", "like80k", "trade2022",
    "fifa", "cute", "inazuma", "??",
}

local function getMatchedItemName(input)
    return input
end

local function fuzzyMatch(str, target)
    return string.find(string.lower(str), string.lower(target)) ~= nil
end

local function ResolvePlayer(query)
    if not query or query == "" then return nil end
    local lowered = string.lower(query)
    local playerList = Players:GetPlayers()
    for _, p in ipairs(playerList) do
        if string.lower(p.Name) == lowered then return p end
    end
    for _, p in ipairs(playerList) do
        if string.lower(p.DisplayName) == lowered then return p end
    end
    for _, p in ipairs(playerList) do
        if string.find(string.lower(p.Name), lowered, 1, true) then return p end
    end
    for _, p in ipairs(playerList) do
        if string.find(string.lower(p.DisplayName), lowered, 1, true) then return p end
    end
    return nil
end

local function GetPlayerInventory(playerName)
    local target = ResolvePlayer(playerName)
    if not target then return nil, "Player not found" end
    local items = target:FindFirstChild("Items")
    if not items or #items:GetChildren() == 0 then
        return target, "No items found"
    end
    local inventory = {}
    for _, child in ipairs(items:GetChildren()) do
        table.insert(inventory, {
            Name  = child.Name,
            Value = tostring(child.Value),
        })
    end
    return target, inventory
end

local homeTab = window:CreateTab({
    Name = "Home",
    Icon = 93364949241311
})

homeTab:CreateToggle({
    Name = "X-Ray",
    CurrentValue = false,
    Callback = function(value)
        local xray = player:FindFirstChild("XRay")
        if xray then
            xray.Value = value
        end
    end,
})

homeTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        task.spawn(function()
            local redeemed = 0
            for _, code in ipairs(CodeDatabase) do
                if Remotes.RequestCode then
                    Remotes.RequestCode:FireServer(code)
                    redeemed = redeemed + 1
                end
                task.wait(0.5)
            end
        end)
    end,
})

homeTab:CreateInput({
    Name = "Target Player",
    CurrentValue = "",
    PlaceholderText = "Enter player name...",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        spyTarget.Text = value
    end,
})

homeTab:CreateButton({
    Name = "View Inventory",
    Callback = function()
        if spyTarget.Text == "" then return end

        local target, result = GetPlayerInventory(spyTarget.Text)

        if not target then return end

        if type(result) == "string" then
            print(target.DisplayName .. ": " .. result)
            return
        end

        local lines = { target.DisplayName .. "'s Inventory:" }
        for i, item in ipairs(result) do
            table.insert(lines, "  " .. item.Name .. " = " .. item.Value)
            if i >= 25 then
                table.insert(lines, "  ... and " .. (#result - 25) .. " more items.")
                break
            end
        end

        print(table.concat(lines, "\n"))
    end,
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
        print("Item mis Ã  jour :", value)
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
        local function GetOwner(instance)
            local ownerAttr = instance:GetAttribute("Owner")
            if ownerAttr then return ownerAttr end
            local ownerObj = instance:FindFirstChild("Owner")
            if ownerObj then
                local val = ownerObj.Value
                if typeof(val) == "Instance" then
                    return val
                elseif typeof(val) == "string" then
                    return Players:FindFirstChild(val) or val
                end
            end
            return nil
        end

        local dropped = workspace:FindFirstChild("Dropped")
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if not dropped or not rootPart then return end

        for _, child in pairs(dropped:GetChildren()) do
            local owner = GetOwner(child)
            if owner == player or owner == player.Name then
                local handle = child:FindFirstChild("Handle")
                    or child:FindFirstChildWhichIsA("BasePart")
                    or child

                if handle and handle:IsA("BasePart") then
                    firetouchinterest(rootPart, handle, 0)
                    task.wait(0.0002)
                    firetouchinterest(rootPart, handle, 1)
                end
            end
        end

        task.wait(0.3)
        local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if remoteEventsFolder then
            local jumpedEvent = remoteEventsFolder:FindFirstChild("Jumped")
            if jumpedEvent then
                jumpedEvent:FireServer()
            end
        end
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
            print("ThÃ¨me / Couleur sÃ©lectionnÃ© :", Option)
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
