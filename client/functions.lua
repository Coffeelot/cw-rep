local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

function notify(message, type)
    QBCore.Functions.Notify(message, type)
end

function getLevel(currentSkill, skillName)
    local level = 0
    if not skillName then print('^1 The skill name you sent in was not defined') return end
    if not currentSkill then 
        if useDebug then print('^1 Attempting to get level for a skill with no xp, defaulting to 0') end 
        currentSkill = 0  
    end
    if Config.Skills[skillName] == nil then print('^1 SKILL IS NOT DEFINED IN CONFIG', skillName) end

    local levels = Config.Skills[skillName].skillLevels or Config.DefaultLevels
    local levelLimits = levels[1]
    for index, levelData in ipairs(levels) do
        if currentSkill > levelData.from and currentSkill <= levelData.to then
            -- if levelData.title then return levelData.title, levelData end
            return level, levelData
        end
        if currentSkill > levelData.to then
            level = level+1
            levelLimits = levelData
        end
    end
    -- if #levels == level then
    --     level = 'Max'
    -- end
    -- if levelLimits.title then return levelLimits.title, levelLimits end
    return level, levelLimits
end

local getCurrentSkill = function(skill)
    if useDebug then print('Fetching skill', skill) end
    if not mySkills[skill] then print("^1Skill " .. skill .. " does not exist") end
    if useDebug then print('Skill level', mySkills[skill]) end
    return mySkills[skill]
end exports('getCurrentSkill', getCurrentSkill)

function round(num)
    return math.floor(num)
end

function round1(num)
    return math.floor(num+1)
end

local function handleNotification(skill, prevAmount, newAmount)
    if tonumber(newAmount) < tonumber(prevAmount) then return end
    if Config.Skills[skill].messages then -- check if messages exists
        for i, messageObj in pairs(Config.Skills[skill].messages) do
            if tonumber(prevAmount) < messageObj.level and tonumber(newAmount) >= messageObj.level then
                if messageObj.notify then
                    notify(messageObj.message,'success')
                else
                    local sender = messageObj.sender
                    local message = messageObj.message
                    local subject = messageObj.subject
                    local citizenid = QBCore.Functions.GetPlayerData().citizenid
                    TriggerServerEvent('cw-rep:server:triggerEmail', citizenid, sender, subject, message)
                end
            end
        end
    end
end

-- RegisterCommand('tskills', function(_, input)
--     handleNotification(input[1], input[2], input[3])
-- end)

function updateSkill(skill, amount)
    if useDebug then print('Updating', skill, amount) end
    if not Config.Skills[skill] then
        print("^1Skill " .. skill .. " does not exist")
        return
    end
    local SkillAmount = mySkills[skill]
    if SkillAmount == nil then
        SkillAmount = 0
    end
    if SkillAmount + tonumber(amount) < 0 then
        mySkills[skill] = 0
    elseif SkillAmount + tonumber(amount) > Config.GenericMaxAmount then
        mySkills[skill] = Config.GenericMaxAmount
    elseif Config.Skills[skill].maxLevel and Config.Skills[skill].maxLevel < SkillAmount + tonumber(amount) then
        return
    else
        mySkills[skill] = SkillAmount + tonumber(amount)
    end
    if Config.ShowNotificationOnSkillGain and not Config.Skills[skill].skipNotify then 
        notify(Config.SkillGainMessage(skill, amount)) 
    end
    handleNotification(skill, SkillAmount, SkillAmount+tonumber(amount))
    TriggerEvent('cw-rep:client:repWasUpdated', mySkills)
	TriggerServerEvent("cw-rep:server:update", json.encode(mySkills))
end exports('updateSkill', updateSkill)

function fetchSkills()
    QBCore.Functions.TriggerCallback("cw-rep:server:fetchStatus", function(data)
        if useDebug then print('Skills:', json.encode(data, {indent=true})) end
		mySkills = data
    end)
end exports('fetchSkills', fetchSkills)

local function getCurrentLevel(skill)
    if useDebug then print('Fetching level for ', skill) end
    if Config.Skills[skill] then
        if mySkills[skill] then
            if useDebug then print('skill', mySkills[skill]) end
            if useDebug then print('level', json.encode(getLevel(mySkills[skill], skill), {indent=true})) end
            return getLevel(mySkills[skill], skill)
        else
            print("^1Attempting to find user data for skill that does not exist in your skill data. Could not find:", skill)
        end
    else
        print("^1Attempting to find level for a skill that does not exist in your Config. Could not find:", skill)
        return 0
    end
end exports('getCurrentLevel', getCurrentLevel)

local function getSkillInfo(skill)
    if Config.Skills[skill] then
       return Config.Skills[skill]
    else
        print("^1Attempting to find label for a skill that does not exist in your Config. Could not find:", skill)
        return nil
    end
end exports('getSkillInfo', getSkillInfo)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(2000)
    if useDebug then print('Fetching skills for player') end
    fetchSkills()
end)

if useDebug then 
    AddEventHandler('onResourceStart', function (resource)
        if resource ~= GetCurrentResourceName() then return end
            if useDebug then print('Fetching skills for player') end
        fetchSkills()
     end)
end

local function playerHasEnoughSkill(skill, value)
    if mySkills[skill] then
        if mySkills[skill] >= tonumber(value) then
            return true
        else
            return false
        end
    else
        print("Skill " .. skill .. " doesn't exist")
        return false
    end
end exports('playerHasEnoughSkill', playerHasEnoughSkill)

local function checkSkill (skill, value, cb)
    cb(playerHasEnoughSkill(skill,value))
end exports('checkSkill', checkSkill)

local function getAllSkillsAndLevel()
    local skillsWithName = {}
    for name, skill in pairs(Config.Skills) do
        local thisSkill = skill
        thisSkill.name = name
        thisSkill.current = mySkills[name]
        thisSkill.level = getLevel(thisSkill.current, name)
        skillsWithName[name] = thisSkill
    end
    return skillsWithName
end exports('getAllSkillsAndLevel', getAllSkillsAndLevel)


-- mz skills bridge
GetCurrentSkill = function(skill)
    return { Current = getCurrentSkill(skill) }
end exports('GetCurrentSkill', GetCurrentSkill)

UpdateSkill = function(skill, amount)
    return updateSkill(skill, amount)
end exports('UpdateSkill', UpdateSkill)

CheckSkill = function(skill, value, cb)
    return cb(playerHasEnoughSkill(skill, value))
end exports('CheckSkill', CheckSkill)

local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_mz-skills_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

exportHandler('GetCurrentSkill', function(skill)
    return { Current = getCurrentSkill(skill) }
end)

exportHandler('UpdateSkill', function(skill, amount)
    updateSkill(skill, amount)
end)

exportHandler('CheckSkill', function(skill, value, cb)
    return cb(playerHasEnoughSkill(skill, value))
end)

