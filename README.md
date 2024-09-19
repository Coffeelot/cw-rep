# cw-rep

- A database held skill/XP system for qb (optimized from mz-skills)
- Full backwards compatibility with mz-skills exports (no need to upgrade all your scripts using mz skills)
- Supports QB menu and OX menu
- Only updates database every X minutes rather than on-update

> All credit to MrZainRP for [mz-skills](https://github.com/MrZainRP/mz-skills) which this is based on. Great script.

> Something cw-rep DOES NOT have: GTAs standard character skills

> QB menu is supported... but probably won't recieve many updates or fixes unless critical, and might have limited functionality compared to OX

# Links and stuff
### ⭐ Check out our [Tebex store](https://cw-scripts.tebex.io/category/2523396) for some cheap scripts ⭐

### [More free scripts](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈

**Support, updates and script previews**: [Join The discord!](https://discord.gg/FJY4mtjaKr)

If you want to support what we do, you can buy us a coffee here:

[![Buy Us a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/cwscriptbois )


# Installation
- Download the resource and drop it to your resource folder. Make sure the folder is named `cw-rep`
- If you're installing from scratch: Import the SQL file to your server's database (i.e. run the sql file and make sure the database runs)
- If you are changing from mz-skills: 
    - Make sure to update the cw-rep skills in the Config to match mz-skills if you want to keep the names you have
    - Remove the mz-skills folder
- Add ``start cw-rep`` to your server.cfg (or simply make sure cw-rep is in your [qb] folder)

> CW-rep has a new (optimized) database format compared to mz-skills, but this conversion is done while the script is being used. This might cause some older unused characters to still have the old format until used

## Setup

You'll probably want to do some setup for this script, so make sure to familiarize yourself with the config. There are some minor differences between this and mz, but the script should be able to rewrite your mz-skills database data into cw-rep on the fly as long as the names in `Config.Skills` match.

You can define skills like this:
```lua
    lockpicking = { -- if you want to use names with spaces you'll need to type it as "['Lockicking Skill'] = {" for example
        icon = 'fas fa-unlock', -- icon that shows in the menu
        label = 'Lockpicking' -- Label that is displayed in the menu (defaults to name of the skill, just like mz skills if this is not defined)
        skipNotify = true -- Will not notify player when skill up/down if Config.ShowNotificationOnSkillGain is set to true
    },
```
> Find icon names [here](https://fontawesome.com/v5/search?m=free)

> Note: cw rep does not come with the same default skills/rep as mz-skills so you will need to update the config 

If you want a skill that also sends the player notifications at certain levels you can define them like this:
```lua
    lockpicking = { -- if you want to use names with spaces you'll need to type it as "['Lockicking Skill'] = {" for example
        icon = 'fas fa-unlock', -- icon that shows in the menu
        label = 'Lockpicking' -- Label that is displayed in the menu (defaults to name of the skill, just like mz skills if this is not defined)
        messages = {
            { notify = true, level = 50, message = "You're not horrible with that lockpick anymore" },
            { notify = true, level = 100, message = "You start feeling better with that lockpick in your hand" },
            { notify = true, level = 200, message = "You're getting good with a lockpick" },
            { notify = true, level = 300, message = "You feel like you're nailing lockpicking now" },
            { notify = true, level = 350, message = "No tumbler will go untouched. You're like the Lockpicking Lawyer!" },
        }
    },
```
The important thing here is the `notify = true` because without that you'll instead be sending emails! Email notifications are great for job reputation or area reputation for example. Here's how to define one with emails:

```lua
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
```
## Skill levels
Default Skill levels are defined in `Config.DefaultLevels` and you can customize these to your liking, but you can also make custom levels for each individual skill, for example the streetreputation:
```lua
    streetreputation = {
        icon = 'fas fa-mask',
        skillLevels = {
            { title = "Unknown", from = 00, to = 1000 },
            { title = "Rookie", from = 1000, to = 2000 },
            { title = "Hustler", from = 2000, to = 3000 },
            { title = "Crimer", from = 3000, to = 4000 },
            { title = "Urban Enforcer", from = 5000, to = 6000 },
            { title = "Renagade", from = 6000, to = 7000 },
            { title = "Underboss", from = 8000, to = 9000 },
            { title = "Boss", from = 9000, to = 10000 }, 
        }
    },
```
> title is optional

As you can see, you should also include a sender and a subject here.

You can also find these examples in the Config.

# Using cw-rep
## Clientside

### To Update a skill please use the following export:
```lua
    exports["cw-rep"]:updateSkill(skillName, amount)
```
For example, to update "Searching" from bin-diving (as used with mz-bins)
```lua
    exports["cw-rep"]:updateSkill("Searching", 1)
```
You can randomise the amount of skill gained, for example: 
 ```lua
    local searchgain = math.random(1, 3)
    exports["cw-rep"]:updateSkill("Searching", searchgain)
```
### The export to check to see if a skill is equal or greater than a particular value is as follows:
```lua
    exports["cw-rep"]:checkSkill(skill, val)
```

You can use this to lock content behind a particular level, for example:
```lua
exports["cw-rep"]:checkSkill("Searching", 100, function(hasskill)
    if hasskill then
        TriggerEvent('mz-bins:client:Reward')
    else
        QBCore.Functions.Notify('You need at least 100XP in Searching to do this.', "error", 3500)
    end
end)
```
Or as an alternative this:
```lua
    local hasSkill = exports["cw-rep"]:playerHasEnoughSkill("Searching", 100)
    if hasSkill then
        -- do thing
    end
```

> The two above work sorta the same, just different ways to get the same result

### The export to obtain a player's current skill to interact with other scripts is as follows:
```lua
    exports["cw-rep"]:getCurrentSkill(skill)
```
> This one differs from mz-skills in that it directly returns the value. In Mz-skills you'd have to do `.Current` to get the value. If you use `GetCurrentSkill` (big G) it returns the same way as mz-skills used to do

### To get the the level, rather than the skill amount/xp:
```lua
    exports["cw-rep"]:getCurrentLevel(skill)
```

Example: 
```lua
    local xp = exports["cw-rep"]:getCurrentSkill('crafting')
    local level = exports["cw-rep"]:getCurrentLevel('crafting')
    print('You are level ', level, ' in crafting. Your XP is', xp)
```
### If you want info of a skill (what's defined in the config: label for example)
```lua
    exports["cw-rep"]:getSkillInfo(skill)
```

Example usage: 
```lua
    local skillInfo = exports["cw-rep"]:getSkillInfo('gun_crafting')
    print('Label of gun_crafting is', skillInfo.label)
    print('Icon of gun_crafting is', skillInfo.icon)
```

### To get a list of all of a players skills with names and labels:
```lua
    exports["cw-rep"]:getAllSkillsAndLevel()
```

Example usage:
```lua
    local allSkillsForThisPlayer = exports['cw-rep']:getAllSkillsAndLevel()
    print(json.encode(allSkillsForThisPlayer,{indent=true}))
    print('My skill in lockpicking is', allSkillsForThisPlayer['lockpicking'].current)
    print('My level in lockpicking is', allSkillsForThisPlayer['lockpicking'].level)
```
> This will be a list similar to the Config.Skills but with `name` and `current` skill level added to it for easy access. 


### If you want to listen to changes of a players skills
```lua
RegisterNetEvent('cw-rep:client:repWasUpdated', function(skills)
    print('new skills', json.encode(skills, {indent=true})) -- remove this line after you know how `skills` look
    -- Add code to do something with this info
end)
```

## Serverside
To Update a skill please use the following export:
```lua
    exports["cw-rep"]:updateSkill(source, skillName, amount)
```
> `source` should obviously be the player source
An example of how to use this would be:
```lua
    exports["cw-rep"]:updateSkill(source, 'lockpicking', 10)
```
The export to check to get player skills:
```lua
    exports["cw-rep"]:fetchSkills(source)
```
An example of how to use this would be:
```lua
    local playerSkills = exports["cw-rep"]:fetchSkills(source)
    print('Player with source',source, ' lockpicking skills:',playerSkills.lockpicking)
```

> `source` should obviously be the player source

## Radial Menu
For radial menu access to "skills" command add this to qb-radialmenu/config.lua somewhere that looks fitting:
```lua
    [3] = {
        id = 'skills',
        title = 'Check Skills',
        icon = 'triangle-exclamation',
        type = 'client',
        event = 'cw-rep:client:CheckSkills',
        shouldClose = true,
    },
```

> 

# Previews
## Ox 
<p align="center">
    <img src="https://media.discordapp.net/attachments/1016069642495729715/1227702266119852132/image.png?ex=66295dd5&is=6616e8d5&hm=544bbf052da18b79839863217e8cee7fb700f8971ee1f2b388c448f62d534325&=&format=webp&quality=lossless"/>
</p>
