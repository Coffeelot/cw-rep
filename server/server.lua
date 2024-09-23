local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

local playerSkillsCache = {}
local playersWithChanges = {}

local function formatResults(results) 
    local playerSkills = {}
    for skill, data in pairs(Config.Skills) do
        if results and results[skill] and type(results[skill]) == 'table' then
            playerSkills[skill] = results[skill].Current or 0
        else
            playerSkills[skill] = results[skill] or 0
        end
    end
    return playerSkills
end

local function getDefault()
    if useDebug then print('Player had no data in DB. Fetching default skills') end
    local playerSkills = {}
    for skill, data in pairs(Config.Skills) do
        playerSkills[skill] = 0
    end
    return playerSkills
end

local function updateSkillsInDb(citizenid, data)
    if useDebug then print('Updating REP database', json.encode(data, {indent=true})) end
    MySQL.query('UPDATE players SET skills = @skills WHERE citizenid = @citizenid', {
       ['@skills'] = data,
       ['@citizenid'] = citizenid
    })
end

local function fetchSkillsFromDb(source)
    if useDebug then print('fetching for', source) end
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local status = MySQL.scalar.await('SELECT skills FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid})
        if useDebug then print('result', json.encode(status, {indent=true})) end
        if status ~= nil then
            return formatResults(json.decode(status))
        else
            local data = getDefault()
            updateSkillsInDb(Player.PlayerData.citizenid, json.encode(data))
            return data
        end
    else
        if useDebug then print("^1Player did not exist") end
        return nil
    end
end

local function updateCachedSkills(source, skill, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    if not playerSkillsCache[citizenid] then
        playerSkillsCache[citizenid] = fetchSkillsFromDb(source)
    end

    playerSkillsCache[citizenid][skill] = (playerSkillsCache[citizenid][skill] or 0) + amount
    playersWithChanges[citizenid] = true
end

local function batchUpdateDatabase()
	if useDebug then print('Batch Updating. changes:', json.encode(playersWithChanges, {indent=true})) end
    for citizenid, _ in pairs(playersWithChanges) do
        if playerSkillsCache[citizenid] then
            updateSkillsInDb(citizenid, json.encode(playerSkillsCache[citizenid]))
        end
    end
    playersWithChanges = {}
end

QBCore.Functions.CreateCallback('cw-rep:server:fetchStatus', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(nil); return end

    local citizenid = Player.PlayerData.citizenid
    if not playerSkillsCache[citizenid] then
        playerSkillsCache[citizenid] = fetchSkillsFromDb(source)
    end
    
    if useDebug then print('result', json.encode(playerSkillsCache[citizenid], {indent=true})) end
    cb(playerSkillsCache[citizenid])
end)

RegisterServerEvent('cw-rep:server:update', function (data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    playerSkillsCache[citizenid] = json.decode(data)
    playersWithChanges[citizenid] = true
end)

RegisterNetEvent('cw-rep:server:triggerEmail', function(citizenid, sender, subject, message)
    SetTimeout(math.random(Config.EmailWaitTimes.min, Config.EmailWaitTimes.max), function()
        TriggerEvent('qb-phone:server:sendNewMail', {
            sender = sender,
            subject = subject,
            message = message,
        }, citizenid)
    end)
end)

local function updateSkill(source, skill, amount)
    if useDebug then print('Updating skill', skill, amount, 'for', source) end
    updateCachedSkills(source, skill, amount)
    TriggerClientEvent('cw-rep:client:updateSkills', source, skill, amount)
end exports('updateSkill', updateSkill)

local function fetchSkills(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end

    local citizenid = Player.PlayerData.citizenid
    if not playerSkillsCache[citizenid] then
        playerSkillsCache[citizenid] = fetchSkillsFromDb(source)
    end
    return playerSkillsCache[citizenid]
end exports('fetchSkills', fetchSkills)

QBCore.Commands.Add('giveskill', "Skill up... or down", { { name = 'player id', help = 'the id of the player' },{ name = 'skill name', help = '"Food Delivery" for example' }, { name = 'skill amount', help = 'add - for negative' } }, true, function(source, args)
    print('command: Updating skill for ', args[1], args[2], args[3])
    updateSkill(tonumber(args[1]), args[2], tonumber(args[3]))
end, "admin")

QBCore.Commands.Add('fetchSkills', "Print skills for player with source", { { name = 'source', help = 'the id of the player' },}, true, function(source, args)
    print('command: Fetching skill for ', args[1])
    local skills = fetchSkills(tonumber(args[1]))
    print('^2 Player lockpicking skills:', skills.lockpicking)
end, "admin")

-- Force a database update when the resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    print('The resource ' .. resourceName .. ' is stopping.')
    batchUpdateDatabase()
end)

CreateThread(function()
    while true do
        Wait(Config.MinutesBetweenUpdates*60*1000)
        batchUpdateDatabase()
    end
end)
