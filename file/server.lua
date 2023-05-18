local prefix = "Mek91-AMA: "
local titleSelect = ""

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local player = source
    local identifiers = playerInfo(player)

    deferrals.defer()
    deferrals.update(MEK91_AMA.CheckingSteam)

    if identifiers.steam == nil and MEK91_AMA.SteamCheck then
        webhookSender(player, true)
        deferrals.update(MEK91_AMA.IfSteamIsNotAvailableKickMessage)
    else
        deferrals.done()
    end
end)

Citizen.CreateThread(function()
    while true do
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local playerLicense = playerInfo(playerId)
            for _, otherId in ipairs(players) do
                if otherId ~= playerId then
                    local otherLicense = playerInfo(otherId)
                    if playerLicense.license == otherLicense.license then
                        webhookSender(otherId, false)
                        DropPlayer(playerId, prefix ..MEK91_AMA.KickMessageIfMultipleAccounts)
                        DropPlayer(otherId, prefix ..MEK91_AMA.KickMessageIfMultipleAccounts)
                    end
                end
            end
        end
        Citizen.Wait(1000 * MEK91_AMA.MultiAccountCheck)
    end
end)

function webhookSender(playerID, steam)
    local identifiers = playerInfo(playerID)

    if steam then
        titleSelect = MEK91_AMA.DiscordWebhookSteamNotFound
    else
        titleSelect = MEK91_AMA.DiscordWebhookTitle
    end

    if identifiers.name == nil and identifiers.steam == nil and identifiers.discord == nil and identifiers.license == nil and identifiers.xbl == nil and identifiers.live == nil and identifiers.ip == nil then
        return
    end
    
    local msg = {
        {
            ["color"] = MEK91_AMA.DiscordColor,
            ["title"] = prefix ..titleSelect,
            ["url"] = "https://youtube.com/@mek91",
            ['author'] = {
                ['name'] = 'Mek91 Anti Multi Account', 
                ['icon_url'] = 'https://cdn.discordapp.com/attachments/1084868011871183008/1084868083233075240/mekMiniLogo.png'
            },
            ["fields"] = {
                {["name"] = "Name", ["value"] = identifiers.name or "N/A", ["inline"] = false},
                {["name"] = "Steam", ["value"] = identifiers.steam or "N/A", ["inline"] = false},
                {["name"] = "Discord", ["value"] = identifiers.discord and ("<@!"..identifiers.discord:gsub("discord:", "")..">\n" .. identifiers.discord:gsub("discord:", "")) or "N/A", ["inline"] = false},
                {["name"] = "License", ["value"] = identifiers.license or "N/A", ["inline"] = false},
                {["name"] = "Xbox", ["value"] = identifiers.xbl or "N/A", ["inline"] = false},
                {["name"] = "Live", ["value"] = identifiers.live or "N/A", ["inline"] = false},
                {["name"] = "Player IP", ["value"] = identifiers.ip or "N/A", ["inline"] = false},
            },
            ["footer"] = {["text"] = "dev. 'Mek91#9959 | youtube.com/@mek91"},
            ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    PerformHttpRequest(MEK91_AMA.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = MEK91_AMA.DiscordWebhookName, avatar_url = MEK91_AMA.DiscordWebhookAvatarUrl, embeds = msg}), { ['Content-Type'] = 'application/json' })
end

function playerInfo(playerID)
    local identifiers = {}

    for i = 0, GetNumPlayerIdentifiers(playerID) - 1 do
        local id = GetPlayerIdentifier(playerID, i)

        if string.find(id, "steam") then
            identifiers['steam'] = id
        elseif string.find(id, "discord") then
            identifiers['discord'] = id
        elseif string.find(id, "license") then
            identifiers['license'] = id
        elseif string.find(id, "xbl") then
            identifiers['xbl'] = id
        elseif string.find(id, "live") then
            identifiers['live'] = id
        end
    end

    local playerName = GetPlayerName(playerID)
    if playerName ~= nil then
        identifiers['name'] = playerName
    end

    local ip = GetPlayerEndpoint(playerID)
    if ip ~= nil then
        identifiers['ip'] = ip
    end

    return identifiers
end