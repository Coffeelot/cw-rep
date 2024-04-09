local QBCore = exports['qb-core']:GetCoreObject()

mySkills = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if Config.LoseSkillsOverTime then
	    Citizen.CreateThread(function()
            while true do
                if LocalPlayer.state.isLoggedIn then
                    local seconds = Config.UpdateFrequency * 1000
                    Wait(seconds)
                    for skill, value in pairs(Config.Skills) do
                        updateSkill(skill, -1)
                    end
                    TriggerServerEvent("cw-rep:server:update", json.encode(mySkills))
                else
                    Wait(1000)
                end
            end
        end)
    end
end)

RegisterNetEvent('cw-rep:client:updateSkills', function(skill, amount)
    updateSkill(skill, amount)
end)
