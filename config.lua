Config = {}
Config.Debug = true                        -- Set to "true" to print debugging messages

Config.UpdateFrequency = 60*60                -- Seconds interval between removing values (no need to touch this)
Config.UseOxMenu = true                     -- set to "true" to use ox_lib menu instead of qb-menu
Config.SkillsTitle = "Skills & Rep"            -- Change this to label your skill system as you see fit.
Config.TypeCommand = true                   -- Set to "false" to disable the "/skills" command (or whatever word you set in the next function)
Config.Skillmenu = "skills"                 -- phrase typed to display skills menu (check readme.md to set to commit to radial menu)

-- Config.EmailWaitTimes = { min = 45000, max =  300000 }
Config.SendUpdateEmails = true -- if true, send emails when hitting the correct levels (if available)
Config.EmailWaitTimes = { min = 4500, max =  7000 }

Config.GenericMaxAmount = 10000 -- the max skill level. Can be overrided by adding maxLevel to any skill
Config.GenericIcon = 'fas fa-book'

Config.Skills = {
    taxi = {
        label = 'Taxi',
        icon = 'fas fa-taxi',
    },
    househeft = {
        label = 'Housetheft',
        icon = 'fas fa-house',
    },
    pizza = {
        label = 'Pizza',
        icon = 'fas fa-house',
    },
    containers = {
        icon = 'fas fa-house',
    },
    streetreputation = {
        icon = 'fas fa-mask',
    },
    scrapping = {
        icon = 'fas fa-cannabis',
    },
    delivery = {
        icon = 'fas fa-truck-arrow-right',
    },
    fishing = {
        icon = 'fas fa-fish-fins',
    },
    garbage = {
        icon = 'fas fa-trash-can',
    },
    hotdog = {
        icon = 'fas fa-hotdog',
    },
    drugSales = {
        icon = 'fas fa-pills',
    },
    hotwiring = {
        icon = 'fas fa-car',
    },
    lockpicking = {
        icon = 'fas fa-unlock',
        label = 'Lockpicking',
        maxLevel = 350,
        messages = {
            { notify = true, level = 50, message = "You're not horrible with that lockpick anymore" },
            { notify = true, level = 100, message = "You start feeling better with that lockpick in your hand" },
            { notify = true, level = 200, message = "You're getting good with a lockpick" },
            { notify = true, level = 300, message = "You feel like you're nailing lockpicking now" },
            { notify = true, level = 350, message = "No tumbler will go untouched. You're like the Lockpicking Lawyer!" },
        }
    },
    foodelivery = {
        icon = 'fas fa-star',
        label = 'Food delivery job rep',
        messages = {
            { level = 50, message = "You're doing a great job", sender = "FeedStars HR", subject = "FeedStars" },
            { level = 100, message = "We just wanted to tell you that we love you! ❤", sender = "FeedStars HR", subject = "FeedStars" },
            { level = 220, message = "Keep up that delivering! ❤", sender = "FeedStars HR", subject = "FeedStars" },
            { level = 300, message = "You're a real Food STAR! ⭐", sender = "FeedStars HR", subject = "FeedStars" },
            { level = 500, message = "Do you even have a life?? Employee of the year!", sender = "FeedStars HR", subject = "FeedStars" },
        }
    },
    -- AREAS
    areagroove = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areafudge = {
        hide = true,
        icon = 'fas fa-globe',
    },
    arealittleseoul = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areavinewood = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areaforumdr = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areajamestown = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areavespbeach = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areavespdocks = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areauniversity = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areastabcity = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areahippiecamp = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areahobocamppaleto = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areagrapeseed = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areasandytown = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areasouthcity = {
        hide = true,
        icon = 'fas fa-globe',
    },
    areanorthcity = {
        hide = true,
        icon = 'fas fa-globe',
    }
}