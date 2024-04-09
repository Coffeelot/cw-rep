local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

local getCurrentSkill = function(skill)
    if useDebug then print('Fetching skill', skill) end
    if not mySkills[skill] then print("^1Skill " .. skill .. " does not exist") end
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
                    QBCore.Functions.Notify(messageObj.message,'success')
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
    handleNotification(skill, SkillAmount, SkillAmount+tonumber(amount))
	TriggerServerEvent("cw-rep:server:update", json.encode(mySkills))
end exports('updateSkill', updateSkill)

function fetchSkills()
    QBCore.Functions.TriggerCallback("cw-rep:server:fetchStatus", function(data)
        if useDebug then print('Skills:', json.encode(data, {indent=true})) end
		mySkills = data
    end)
end exports('fetchSkills', fetchSkills)

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
