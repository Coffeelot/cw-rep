local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

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
	local playerSkills = {}
	for skill, data in pairs(Config.Skills) do
		playerSkills[skill] = 0
	end
	return playerSkills
end

local function updateSkillsInDb(src, data)
	local Player = QBCore.Functions.GetPlayer(src)
	MySQL.query('UPDATE players SET skills = @skills WHERE citizenid = @citizenid', {
	   ['@skills'] = data,
	   ['@citizenid'] = Player.PlayerData.citizenid
   })
end

local function fetchSkillsFromDb(source)
	if useDebug then print('fetching for', source) end
	local Player = QBCore.Functions.GetPlayer(source)
	if Player then
		local status = MySQL.scalar.await('SELECT skills FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid})
		if status ~= nil then
			return formatResults(json.decode(status))
		else
			local data = getDefault()
			updateSkillsInDb(source, json.encode(data))
			return data
		end
	else
		if useDebug then print("^1Player did not exist") end
		return nil
	end
end

QBCore.Functions.CreateCallback('cw-rep:server:fetchStatus', function(source, cb)
	local res = fetchSkillsFromDb(source)
	if useDebug then print('result', json.encode(res, {indent=true})) end
	cb(res)
end)

RegisterServerEvent('cw-rep:server:update', function (data)
	updateSkillsInDb(source, data)
end)

RegisterNetEvent('cw-rep:server:triggerEmail', function(citizenid, sender, subject, message)
	print()
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
	TriggerClientEvent('cw-rep:client:updateSkills', source, skill, amount)
end exports('updateSkill', updateSkill)

local function fetchSkills(source)
	return fetchSkillsFromDb(source)
end exports('fetchSkills', fetchSkills)

exports('updateSkill', updateSkill)

QBCore.Commands.Add('giveskill', "Skill up... or down", { { name = 'player id', help = 'the id of the player' },{ name = 'skill name', help = '"Food Delivery" for example' }, { name = 'skill amount', help = 'add - for negative' } }, true, function(source, args)
	print('Updating skill for ', args[1], args[2], args[3])
	TriggerClientEvent('cw-rep:client:updateSkills', args[1], args[2], args[3])
end, "admin")

QBCore.Commands.Add('fetchSkills', "Print skills for player with source", { { name = 'source', help = 'the id of the player' },}, true, function(source, args)
	print('Fetching skill for ', args[1])
	local skills = fetchSkills(tonumber(args[1]))
	print('^2 Player lockpicking skills:', skills.lockpicking)
end, "admin")

