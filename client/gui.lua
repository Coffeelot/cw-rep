local function getXpText(currentXp, nextLevel)
    if currentXp > nextLevel then return 'XP: '..tostring(currentXp) end
    return 'XP: '..currentXp..'/'..nextLevel
end

local function levelIsVerified(level)
    if Config.HideSkillsWithZeroLevels then
        return level > 0
    end
    return true
end

local function createSkillMenu()
    local skillMenu = {}
    skillMenu[#skillMenu + 1] = {
        isHeader = true,
        header = 'Skills',
        isMenuHeader = true,
        icon = 'fas fa-chart-simple'
    }

    for k,currentValue in pairs(mySkills) do
        local skillData = Config.Skills[k]
        local label = k
        if Config.Skills[k] and Config.Skills[k].label then
            label = Config.Skills[k].label
        end
        if not skillData.hide then
            local level, levelData = getLevel(currentValue, k)
            if levelIsVerified(level) then
                skillMenu[#skillMenu + 1] = {
                    header = label .. ' (Level: ' .. level .. ')',
                    txt = getXpText(currentValue, levelData.to),
                    icon = skillData.icon or nil,
                    params = {
                        args = {
                            v
                        }
                    }
                }
            end
        end
    end
    exports['qb-menu']:openMenu(skillMenu)
end

local function createSkillMenuOX()
    local options = {}
    local sortedSkills = {}
    
    local keys = {}
    

    for key in pairs(Config.Skills) do
        table.insert(keys, key)
    end
    -- Sort keys
    table.sort(keys)
    -- Iterate over sorted keys and access corresponding values
    for _, key in ipairs(keys) do
        if not Config.Skills[key].hide then
            local currentValue = mySkills[key] or 0

            local level, levelData = getLevel(tonumber(currentValue), key)
            -- Calculate progress bar percentage
           
            local label = key
            if Config.Skills[key] and Config.Skills[key].label then
                label = Config.Skills[key].label
            end
            local icon = Config.GenericIcon
            if Config.Skills[key] and Config.Skills[key].icon then
                icon = Config.Skills[key].icon
            end
            if levelIsVerified(level) then
                options[#options + 1] = {
                    title = label .. ' (Level: ' .. level .. ')',
                    description = getXpText(currentValue, levelData.to),
                    icon = icon,
                    args = {
                        currentValue = currentValue
                    },
                    progress = math.floor((currentValue - levelData.from) / (levelData.to - levelData.from) * 100),
                    colorScheme = Config.XPBarColour,
                }
            end
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
    if mySkills == nil then return end
    if Config.TypeCommand and Config.UseOxMenu then
        createSkillMenuOX()
    elseif Config.TypeCommand then
        createSkillMenu()
    else 
        Wait(10)
    end
end, false)
        
RegisterNetEvent("cw-rep:client:CheckSkills", function()
    if Config.UseOxMenu then
        createSkillMenuOX()
    else
        createSkillMenu()
    end
end)