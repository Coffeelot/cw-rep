local QBCore = exports['qb-core']:GetCoreObject()

local oxmenu = exports.ox_menu

local function createSkillMenu()
    skillMenu = {}
    skillMenu[#skillMenu + 1] = {
        isHeader = true,
        header = 'Skills',
        isMenuHeader = true,
        icon = 'fas fa-chart-simple'
    }

    for k,currentValue in pairs(mySkills) do
        print(json.encode(k, {indent=true}))
        local skillData = Config.Skills[k]
        if not skillData.hide then
            if currentValue <= 100 then
                SkillLevel = 'Level 0 (Unskilled)'
            elseif currentValue > 100 and currentValue <= 200 then
                SkillLevel = 'Level 1 (Beginner)'
            elseif currentValue > 200 and currentValue <= 400 then
                SkillLevel = 'Level 2 (Amateur)'
            elseif currentValue > 400 and currentValue <= 800 then
                SkillLevel = 'Level 3 (Intermediate)'
            elseif currentValue > 800 and currentValue <= 1600 then
                SkillLevel = 'Level 4 (Competent)'
            elseif currentValue > 1600 and currentValue <= 3200 then
                SkillLevel = 'Level 5 (Skilled)'
            elseif currentValue > 3200 and currentValue <= 6400 then
                SkillLevel = 'Level 6 (Adept)'
            elseif currentValue > 6400 and currentValue <= 12800 then
                SkillLevel = 'Level 7 (Master)'
            elseif currentValue > 12800 then
                SkillLevel = 'Level 8 (Proficient)'
            else 
                SkillLevel = 'Unknown'
            end
            skillMenu[#skillMenu + 1] = {
                header = skillData.label or k,
                txt = '( '..SkillLevel..' ) Total XP ( '..round1(currentValue)..' )',
                icon = skillData.icon or nil,
                params = {
                    args = {
                        v
                    }
                }
            }
        end
    end
    exports['qb-menu']:openMenu(skillMenu)
end

local function createSkillMenuOX()
    local options = {}
    local sortedSkills = {}
    
    local keys = {}
    for key in pairs(mySkills) do
        table.insert(keys, key)
    end
    -- Sort keys
    table.sort(keys)
    -- Iterate over sorted keys and access corresponding values
    for _, key in ipairs(keys) do
        if not Config.Skills[key].hide then
            local currentValue = mySkills[key]
            local SkillLevel
            local min = 0
            local max = 0
            if currentValue <= 100 then
                SkillLevel = 'Level 0 - XP: '..math.round(currentValue)
                min = 0
                max = 100
            elseif currentValue > 100 and currentValue <= 200 then
                SkillLevel = 'Level 1 - XP: '..math.round(currentValue)
                min = 100
                max = 200
            elseif currentValue > 200 and currentValue <= 400 then
                SkillLevel = 'Level 2 - XP: '..math.round(currentValue)
                min = 200
                max = 400
            elseif currentValue > 400 and currentValue <= 800 then
                SkillLevel = 'Level 3 - XP: '..math.round(currentValue)
                min = 400
                max = 800
            elseif currentValue > 800 and currentValue <= 1600 then
                SkillLevel = 'Level 4 - XP: '..math.round(currentValue)
                min = 800
                max = 1600
            elseif currentValue > 1600 and currentValue <= 3200 then
                SkillLevel = 'Level 5 - XP: '..math.round(currentValue)
                min = 1600
                max = 3200
            elseif currentValue > 3200 and currentValue <= 6400 then
                SkillLevel = 'Level 6 - XP: '..math.round(currentValue)
                min = 3200
                max = 6400
            elseif currentValue > 6400 and currentValue <= 12800 then
                SkillLevel = 'Level 7 - XP: '..math.round(currentValue)
                min = 6400
                max = 12800
            elseif currentValue > 12800 then
                SkillLevel = 'Level 8 - XP: '..math.round(currentValue)
                min = 12800
                max = 1000000
            else 
                SkillLevel = 'Unknown'
            end
    
            -- Calculate progress bar percentage
           
            local label = key
            if Config.Skills[key] and Config.Skills[key].label then
                label = Config.Skills[key].label
            end
            local icon = Config.GenericIcon
            if Config.Skills[key] and Config.Skills[key].icon then
                icon = Config.Skills[key].icon
            end
    
            options[#options + 1] = {
                title = label .. ' (' .. SkillLevel .. ')',
                description = '( '..SkillLevel..' ) Total XP ( '..math.round(currentValue)..' )',
                icon = icon,
                args = {
                    currentValue = currentValue
                },
                progress = math.floor((currentValue - min) / (max - min) * 100),
                colorScheme = Config.XPBarColour,
            }
        end
    end

    lib.registerContext({
        id = 'skill_menu',
        title = Config.SkillsTitle,
        options = options
    }, function(selected)
        print('Selected: ' .. selected)
    end)

    lib.showContext('skill_menu')
end

RegisterCommand(Config.Skillmenu, function()
    if Config.TypeCommand and Config.UseOxMenu then
        createSkillMenuOX()
    elseif Config.TypeCommand then
        createSkillMenu()
    else 
        Wait(10)
    end
end)
        
RegisterNetEvent("mz-skills:client:CheckSkills", function()
    if Config.UseOxMenu then
        createSkillMenuOX()
    elseif not Config.TypeCommand then
        createSkillMenu()
    else 
        Wait(10)
    end
end)
