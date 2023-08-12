--Created by Saint Wish/Wishbone - https://github.com/SaintWish
--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSE
local config = require("custom/rpRolls/config")
local rpRolls = {}
rpRolls.gui = {
  ["skillCard"] = 32501,
  ["skillSelect"] = 32502,
  ["skillLevel"] = 32503
}
rpRolls.types = {}

function rpRolls.log(logType, message, ...)
  local message = string.format(message, ...)

	if logType == nil or logType == "normal" then
		message = "[RP-ROLLS]: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "error" then
		message = "[RP-ROLLS]ERR: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "warning" then
		message = "[RP-ROLLS]WARN: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "notice" then
		message = "[RP-ROLLS]NOTE: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "debug" then
		if config.debug then
			message = "[RP-ROLLS]DBG: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		end

	else
		rpRolls.log("error", "INVALID LOG CALL")
		message = "[RP-ROLLS](invalid): " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	end
end

function rpRolls.isCritHit(pid, type, roll)
  if not config.critAllowed[type] then
    return false
  end

  local rand = math.random(1, 100)

  if roll == 20 then
    return true
  elseif roll > 1 then
    if rand <= config.critChance then
      return true
    end
  else
    return false
  end

  return false
end

-- Check function to make sure people can't go over their points available.
function rpRolls.checkPoints(pid, points)
  local maxPoints = Players[pid].data.customVariables.rpRolls.points
  local newPoints = maxPoints - points

  if newPoints < 0 then
    return false
  else
    return true
  end
end

function rpRolls.changeSkillLevel(pid, skill, addLevel)
  if rpRolls.checkPoints(pid, addLevel) then
    local newLevel = Players[pid].data.customVariables.rpRolls[skill] + addLevel
    rpRolls.setSkillLevel(pid, skill, newLevel)
    return true
  end

  return false
end

function rpRolls.setSkillLevel(pid, skill, level)
  if Players[pid].data.customVariables.rpRolls[skill] and tonumber(level) then
    if level <= config.maxLevel then
      Players[pid].data.customVariables.rpRolls[skill] = level
    else
      --Make the skill max level if they go over max.
      Players[pid].data.customVariables.rpRolls[skill] = config.maxLevel
    end
  end
end

--[[
function rpRolls.getAttrBonus(pid, attr)
  local plySkills = Players[pid].data.customVariables.rpRolls
  local attributes = {
    ["strength"] = (plySkills["acrobatics"] + plySkills["armorer"] + plySkills["axe"] + plySkills["bluntweapon"] + plySkills["longblade"]),
    ["agility"] = (plySkills["block"] + plySkills["lightarmor"] + plySkills["marksman"] + plySkills["sneak"]),
    ["speed"] = (plySkills["athletics"] + plySkills["handtohand"] + plySkills["shortblade"] + plySkills["unarmored"]),
    ["personality"] = (plySkills["illusion"] + plySkills["mercantile"] + plySkills["speechcraft"]),
    ["intelligence"] = (plySkills["alchemy"] + plySkills["conjuration"] + plySkills["enchant"] + plySkills["security"]),
    ["willpower"] = (plySkills["alteration"] + plySkills["destruction"] + plySkills["mysticism"] + plySkills["restoration"]),
  }

  if attributes[attr] then
    return math.floor(attributes[attr] / 3)
  end
  return 0
end
]]--

function rpRolls.getPlyName(pid)
  if Players[pid].data.customVariables.rpchat.nick ~= nil then
    return Players[pid].data.customVariables.rpchat.nick
  else
    return Players[pid].accountName
  end
end

function rpRolls.getSkillBonus(pid, skill)
  return math.floor(Players[pid].data.customVariables.rpRolls[skill] / config.bonusPerPoint)
end

function rpRolls.getAttrBonus(pid, attr)
  local plySkills = Players[pid].data.customVariables.rpRolls

  local attributes = {
    ["strength"] = (plySkills["acrobatics"] + plySkills["armorer"] + plySkills["axe"] + plySkills["bluntweapon"] + plySkills["longblade"]),
    ["agility"] = (plySkills["block"] + plySkills["lightarmor"] + plySkills["marksman"] + plySkills["sneak"]),
    ["speed"] = (plySkills["athletics"] + plySkills["handtohand"] + plySkills["shortblade"] + plySkills["unarmored"]),
    ["personality"] = (plySkills["illusion"] + plySkills["mercantile"] + plySkills["speechcraft"]),
    ["intelligence"] = (plySkills["alchemy"] + plySkills["conjuration"] + plySkills["enchant"] + plySkills["security"]),
    ["willpower"] = (plySkills["alteration"] + plySkills["destruction"] + plySkills["mysticism"] + plySkills["restoration"]),
  }

  if not attributes[attr] then
    return false
  end

  return math.floor(attributes[attr] / config.bonusPerPoint)
end

function rpRolls.getPlyLevel(pid)
  return math.floor((Players[pid].data.customVariables.rpRolls.maxpoints / 10) + Players[pid].data.customVariables.rpRolls.rpr)
end

function rpRolls.updateHealth(pid)
  local plyRolls = Players[pid].data.customVariables.rpRolls
  Players[pid].data.customVariables.rpRolls.health = math.floor(3 + (plyRolls.endurance / config.hpPerPoint))
end

function rpRolls.systemMessage(pid, message, ...)
  local msg = string.format(message, ...)
  local fMsg = config.prefixColor .. config.prefix .. ": " .. config.msgColor .. msg .. "\n"

  tes3mp.SendMessage(pid, fMsg, false)
end

function rpRolls.localMessage(pid, message)
  rpRolls.log("debug", "Doing local message")

	local originX = tes3mp.GetPosX(pid)
	local originY = tes3mp.GetPosY(pid)

  for ply,_ in pairs(Players) do
  	local plyX = tes3mp.GetPosX(ply)
  	local plyY = tes3mp.GetPosY(ply)
  	local plyDist = math.sqrt((originX - plyX) * (originX - plyX) + (originY - plyY) * (originY - plyY))

  	if plyDist <= config.rollChatDist then
      rpRolls.log("debug", "test2")
  		tes3mp.SendMessage(ply, config.prefixColor.."[ROLL] "..config.msgColor..message.."\n", false)
  	end
  end
end

rpRolls.types["attr"] = function(pid, attr)
  local plySkills = Players[pid].data.customVariables.rpRolls
  local sBonus = rpRolls.getAttrBonus(pid, attr)

  if not sBonus then
    rpRolls.systemMessage(pid, "Invalid attribute.")
    return
  end

  local rand = math.random(1, 20)
  local msgFmt

  --Critical fails
  if rand == 1 then
    sBonus = 0
  end

  rpRolls.log("debug", "%s has rolled %i for attribute %s", Players[pid].accountName, rand, attr)
  local message = {config.plyColor,"%s ",config.msgColor,"rolled a ",color.Yellow,"%i ",config.msgColor,"with a bonus of ",color.Orange,"+%i",config.msgColor,", for attribute ",config.setColor,"%s ",color.Orange,"(=%i)"}
  local msgFmt = string.format(table.concat(message, ""), rpRolls.getPlyName(pid), rand, sBonus, attr:gsub("^%l", string.upper), sBonus+rand)

  rpRolls.localMessage(pid, msgFmt)
end

rpRolls.types["skill"] = function(pid, skill)
  if not config.skill[skill] then
    rpRolls.systemMessage(pid, "Invalid skill.")
    return
  end

  local rand = math.random(1, 20)
  local message = {}
  local msgFmt

  local sBonus = rpRolls.getSkillBonus(pid, skill)

  --Critical fails
  if rand == 1 then
    sBonus = 0
  end

  if rpRolls.isCritHit(pid, skill, rand) then
    rpRolls.log("debug", "%s has rolled %i for skill %s with a critical hit", Players[pid].accountName, rand, skill)

    message = {config.plyColor,"%s ",config.msgColor,"rolled a ",color.Yellow,"%i ",config.msgColor,"with a bonus of ",color.Orange,"+%i ",config.msgColor,"with a critical hit of ",color.Orange,"%i",config.msgColor,", for skill ",config.setColor,"%s ",color.Orange,"(=%i)"}
    msgFmt = string.format(table.concat(message, ""), rpRolls.getPlyName(pid), rand, sBonus, config.critBonus, config.skill[skill], (sBonus+rand)+config.critBonus)

  else
    rpRolls.log("debug", "%s has rolled %i for skill %s", Players[pid].accountName, rand, skill)

    message = {config.plyColor,"%s ",config.msgColor,"rolled a ",color.Yellow,"%i ",config.msgColor,"with a bonus of ",color.Orange,"+%i",config.msgColor,", for skill ",config.setColor,"%s ",color.Orange,"(=%i)"}
    msgFmt = string.format(table.concat(message, ""), rpRolls.getPlyName(pid), rand, sBonus, config.skill[skill], sBonus+rand)
  end

  rpRolls.localMessage(pid, msgFmt)
end

rpRolls.types["d20"] = function(pid, type)
  local rand = math.random(1, 20)
  local bonus = 0

  local message = {config.plyColor,"%s ",config.msgColor,"rolled a ",color.Yellow,"%i ",config.msgColor,"with a bonus of ",color.Orange,"+%i ",config.msgColor,"with a d20."}
  local msgFmt = string.format(table.concat(message, ""), rpRolls.getPlyName(pid), rand, bonus)

  rpRolls.localMessage(pid, msgFmt)
end

function rpRolls.doRoll(pid, roll, type)
  rpRolls.log("debug", "Ran doRoll with args %i, %s, %s", pid, roll, type)
  if rpRolls.types[roll] then
    rpRolls.types[roll](pid, type)
  else
    rpRolls.log("debug", "%s is a invalid roll type", roll)
    rpRolls.systemMessage(pid, "Invalid roll type. Has to be skill/attr/d20")
    return
  end
end

function rpRolls.levelSkillGui(pid)
  local list = "* CLOSE *\n"

  -- for k,v in pairs(config.skill) do
  --
  -- end

  tes3mp.ListBox(pid, rpRolls.gui.skillLevel, config.msgColor.."Select what you want to level"..color.Default, list)
end

function rpRolls.showSkillList(pid, target)
  local plySkills = Players[target].data.customVariables.rpRolls
  local targetName = rpRolls.getPlyName(target)
  local sBonus = function(skill)
    return rpRolls.getSkillBonus(target, skill)
  end

  rpRolls.updateHealth(target)

  local title = config.plyColor..targetName..config.msgColor.."'s Skill Card"
  local list = {config.auxColor,"Health: ",config.msgColor,plySkills["health"],"\n",
  config.auxColor,"RPR: ",config.msgColor,plySkills["rpr"],"\n",
  config.auxColor,"Points: ",config.msgColor,plySkills["points"],"/",plySkills["maxpoints"],"\n\n",
  config.setColor,"Axe: ",config.msgColor,plySkills["axe"],color.Orange," +",sBonus("axe"),"\n",
  config.setColor,"Block: ",config.msgColor,plySkills["block"],color.Orange," +",sBonus("block"),"\n",
  config.setColor,"Blunt Weapon: ",config.msgColor,plySkills["bluntweapon"],color.Orange," +",sBonus("bluntweapon"),"\n",
  config.setColor,"Hand to Hand: ",config.msgColor,plySkills["handtohand"],color.Orange," +",sBonus("handtohand"),"\n",
  config.setColor,"Long Blade: ",config.msgColor,plySkills["longblade"],color.Orange," +",sBonus("longblade"),"\n",
  config.setColor,"Marksman: ",config.msgColor,plySkills["marksman"],color.Orange," +",sBonus("marksman"),"\n",
  config.setColor,"Short Blade: ",config.msgColor,plySkills["shortblade"],color.Orange," +",sBonus("shortblade"),"\n",
  config.setColor,"Spear: ",config.msgColor,plySkills["spear"],color.Orange," +",sBonus("spear"),"\n\n",
  config.setColor,"Alchemy: ",config.msgColor,plySkills["alchemy"],color.Orange," +",sBonus("alchemy"),"\n",
  config.setColor,"Alteration: ",config.msgColor,plySkills["alteration"],color.Orange," +",sBonus("alteration"),"\n",
  config.setColor,"Conjuration: ",config.msgColor,plySkills["conjuration"],color.Orange," +",sBonus("conjuration"),"\n",
  config.setColor,"Destruction: ",config.msgColor,plySkills["destruction"],color.Orange," +",sBonus("destruction"),"\n",
  config.setColor,"Enchant: ",config.msgColor,plySkills["enchant"],color.Orange," +",sBonus("enchant"),"\n",
  config.setColor,"Illusion: ",config.msgColor,plySkills["illusion"],color.Orange," +",sBonus("illusion"),"\n",
  config.setColor,"Mysticism: ",config.msgColor,plySkills["mysticism"],color.Orange," +",sBonus("mysticism"),"\n",
  config.setColor,"Restoration: ",config.msgColor,plySkills["restoration"],color.Orange," +",sBonus("restoration"),"\n\n",
  config.setColor,"Unarmored: ",config.msgColor,plySkills["unarmored"],color.Orange," +",sBonus("unarmored"),"\n",
  config.setColor,"Light Armor: ",config.msgColor,plySkills["lightarmor"],color.Orange," +",sBonus("lightarmor"),"\n",
  config.setColor,"Medium Armor: ",config.msgColor,plySkills["mediumarmor"],color.Orange," +",sBonus("mediumarmor"),"\n",
  config.setColor,"Heavy Armor: ",config.msgColor,plySkills["heavyarmor"],color.Orange," +",sBonus("heavyarmor"),"\n\n",
  config.setColor,"Mercantile: ",config.msgColor,plySkills["mercantile"],color.Orange," +",sBonus("mercantile"),"\n",
  config.setColor,"Speechcraft: ",config.msgColor,plySkills["speechcraft"],color.Orange," +",sBonus("speechcraft"),"\n\n",
  config.setColor,"Endurance: ",config.msgColor,plySkills["endurance"],color.Orange," +",sBonus("endurance"),"\n",
  config.setColor,"Security: ",config.msgColor,plySkills["security"],color.Orange," +",sBonus("security"),"\n",
  config.setColor,"Armorer: ",config.msgColor,plySkills["armorer"],color.Orange," +",sBonus("armorer"),"\n",
  config.setColor,"Sneak: ",config.msgColor,plySkills["sneak"],color.Orange," +",sBonus("sneak"),"\n\n"}

  tes3mp.ListBox(pid, rpRolls.gui.skillCard, title, table.concat(list, ""))
end

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
  if not Players[pid].data.customVariables.rpRolls or Players[pid].data.customVariables.rpRolls.points == nil then
    rpRolls.log("normal", "Missing correct table, repairing.")
    Players[pid].data.customVariables.rpRolls = {
      ["rpr"] = 0,
      ["health"] = 3,
      ["maxpoints"] = config.startPoints,
      ["points"] = config.startPoints,
      ["block"] = 0,
      ["alchemy"] = 0,
      ["restoration"] = 0,
      ["conjuration"] = 0,
      ["marksman"] = 0,
      ["handtohand"] = 0,
      ["shortblade"] = 0,
      ["heavyarmor"] = 0,
      ["bluntweapon"] = 0,
      ["alteration"] = 0,
      ["enchant"] = 0,
      ["sneak"] = 0,
      ["lightarmor"] = 0,
      ["athletics"] = 0,
      ["armorer"] = 0,
      ["speechcraft"] = 0,
      ["axe"] = 0,
      ["security"] = 0,
      ["acrobatics"] = 0,
      ["destruction"] = 0,
      ["longblade"] = 0,
      ["illusion"] = 0,
      ["mysticism"] = 0,
      ["spear"] = 0,
      ["mediumarmor"] = 0,
      ["mercantile"] = 0,
      ["unarmored"] = 0,
      ["endurance"] = 0
    }
  end

  math.randomseed(os.time()) --Create a new seed for the random each time a player joins for best results.
end)

customCommandHooks.registerCommand("roll", function(pid, args)
  if not args[2] then
    rpRolls.systemMessage(pid, "/roll <type> <set>\nEx. /roll skill unarmored")
    return
  end

  rpRolls.doRoll(pid, args[2], args[3])
end)

customCommandHooks.registerCommand("skills", function(pid, args)
  local target = tonumber(args[2])
  if not target then target = pid end

  if not Players[target] then
    rpRolls.systemMessage(pid, "There's no player online by that ID")
    return
  end

  rpRolls.showSkillList(pid, target)
end)

--/levelskill skill amount
customCommandHooks.registerCommand("levelskill", function(pid, args)
  local skill = args[2]
  local points = args[3]

  if not points or not skill then
    rpRolls.systemMessage(pid, "/levelskill <skill> <points>\nYou have %i points available.", Players[pid].data.customVariables.rpRolls.points)
    return
  end

  if config.skill[skill] then
    if rpRolls.changeSkillLevel(pid, skill, points) then
      rpRolls.systemMessage(pid, "You have leveled"..config.setColor.." %s "..color.Default.."by %i points", config.skill[skill], points)
      Players[pid].data.customVariables.rpRolls.points = Players[pid].data.customVariables.rpRolls.points - points
    else
      rpRolls.systemMessage(pid, "You only have %i available points.", Players[pid].data.customVariables.rpRolls.points)
    end

    return

  else
    rpRolls.systemMessage(pid, "Invalid skill.")
    return
  end
end)

customCommandHooks.registerCommand("level", function(pid, args)
  rpRolls.systemMessage(pid, "Your current level is %i", rpRolls.getPlyLevel(pid))
end)

customCommandHooks.registerCommand("sethp", function(pid, args)
  if Players[pid]:IsAdmin() then
    if not args[2] or not args[3] then
      rpRolls.systemMessage(pid, "Incorrect usage.")
      return
    end

    local target = tonumber(args[2])
    local amount = tonumber(args[3])

    if not Players[target] then
      rpRolls.systemMessage(pid, "There's no player online by that ID")
      return
    end

    if target and not amount then
      rpRolls.systemMessage(pid, "%s's Health is set to %i", Players[target].accountName, Players[target].data.customVariables.rpRolls.health)
      return
    end

    if target and amount then
      if type(amount) == "number" then
        Players[target].data.customVariables.rpRolls.health = amount
        rpRolls.systemMessage(pid, "You have set %s's Health to %i", Players[target].accountName, Players[target].data.customVariables.rpRolls.health)
        if pid ~= target then
          rpRolls.systemMessage(target, "Your Health has been set to %i", Players[target].data.customVariables.rpRolls.health)
        end
      end

      return
    end
  end
end)

customCommandHooks.registerCommand("setrpr", function(pid, args)
  if Players[pid]:IsAdmin() then
    if not args[2] or not args[3] then
      rpRolls.systemMessage(pid, "Incorrect usage.")
      return
    end

    local target = tonumber(args[2])
    local amount = tonumber(args[3])

    if not Players[target] then
      rpRolls.systemMessage(pid, "There's no player online by that ID")
      return
    end

    if target and not amount then
      rpRolls.systemMessage(pid, "%s's RPR is set to %i", Players[target].accountName, Players[target].data.customVariables.rpRolls.rpr)
      return
    end

    if target and amount then
      if type(amount) == "number" then
        Players[target].data.customVariables.rpRolls.rpr = amount
        rpRolls.systemMessage(pid, "You have set %s's RPR to %i", Players[target].accountName, Players[target].data.customVariables.rpRolls.rpr)
        if pid ~= target then
          rpRolls.systemMessage(target, "Your RPR has been set to %i", Players[target].data.customVariables.rpRolls.rpr)
        end
      end

      return
    end
  end
end)

customCommandHooks.registerCommand("setpoints", function(pid, args)
  if Players[pid]:IsAdmin() then
    if not args[2] or not args[3] then
      rpRolls.systemMessage(pid, "Incorrect usage.")
      return
    end

    local target = tonumber(args[2])
    local amount = tonumber(args[3])

    if not Players[target] then
      rpRolls.systemMessage(pid, "There's no player online by that ID")
      return
    end

    if target and not amount then
      rpRolls.systemMessage(pid, "%s's available points is currently at %i", Players[target].accountName, Players[target].data.customVariables.rpRolls.points)
      return
    end

    if target and amount then
      if type(amount) == "number" then
        Players[target].data.customVariables.rpRolls.points = amount
        Players[target].data.customVariables.rpRolls.maxpoints = amount

        rpRolls.systemMessage(pid, "You have set %s's points to %i", Players[target].accountName, Players[target].data.customVariables.rpRolls.points)

        if pid ~= target then
          rpRolls.systemMessage(target, "Your points has been set to %i", Players[target].data.customVariables.rpRolls.points)
        end
      end

      return
    end
  end
end)

customCommandHooks.registerCommand("addpoints", function(pid, args)
  if Players[pid]:IsAdmin() then
    if not args[2] or not args[3] then
      rpRolls.systemMessage(pid, "Incorrect usage.")
      return
    end

    local target = tonumber(args[2])
    local amount = tonumber(args[3])

    if not Players[target] then
      rpRolls.systemMessage(pid, "There's no player online by that ID")
      return
    end

    if target and not amount then
      rpRolls.systemMessage(pid, "%s's available points is currently at %i", Players[target].accountName, Players[target].data.customVariables.rpRolls.points)
      return
    end

    if target and amount then
      if type(amount) == "number" then
        Players[target].data.customVariables.rpRolls.points = Players[target].data.customVariables.rpRolls.points + amount
        Players[target].data.customVariables.rpRolls.maxpoints = Players[target].data.customVariables.rpRolls.maxpoints + amount

        rpRolls.systemMessage(pid, "You have added %i to %s's available points (%i)", amount, Players[target].accountName, Players[target].data.customVariables.rpRolls.points)

        if pid ~= target then
          rpRolls.systemMessage(target, "You have unspent points!")
        end
      end

      return
    end
  end
end)

customCommandHooks.registerCommand("resetskill", function(pid, args)
  if Players[pid]:IsAdmin() then
    if not args[2] then
      rpRolls.systemMessage(pid, "Incorrect usage.")
      return
    end

    if not Players[target] then
      rpRolls.systemMessage(pid, "There's no player online by that ID")
      return
    end

    if target then
      local plyMaxPoints = Players[target].data.customVariables.rpRolls.maxpoints or config.startPoints
      Players[target].data.customVariables.rpRolls = {
        ["rpr"] = 0,
        ["health"] = 3,
        ["points"] = plyMaxPoints,
        ["block"] = 0,
        ["alchemy"] = 0,
        ["restoration"] = 0,
        ["conjuration"] = 0,
        ["marksman"] = 0,
        ["handtohand"] = 0,
        ["shortblade"] = 0,
        ["heavyarmor"] = 0,
        ["bluntweapon"] = 0,
        ["alteration"] = 0,
        ["enchant"] = 0,
        ["sneak"] = 0,
        ["lightarmor"] = 0,
        ["athletics"] = 0,
        ["armorer"] = 0,
        ["speechcraft"] = 0,
        ["axe"] = 0,
        ["security"] = 0,
        ["acrobatics"] = 0,
        ["destruction"] = 0,
        ["longblade"] = 0,
        ["illusion"] = 0,
        ["mysticism"] = 0,
        ["spear"] = 0,
        ["mediumarmor"] = 0,
        ["mercantile"] = 0,
        ["unarmored"] = 0,
        ["endurance"] = 0
      }

      rpRolls.systemMessage(pid, "You have reset %s's levels.", Players[target].accountName)

      if pid ~= target then
        rpRolls.systemMessage(target, "Your levels have been reset!")
      end

      return
    end
  end
end)

customCommandHooks.registerCommand("wipeskill", function(pid, args)
  if Players[pid]:IsAdmin() then
    if not args[2] then
      rpRolls.systemMessage(pid, "Incorrect usage.")
      return
    end

    if not Players[target] then
      rpRolls.systemMessage(pid, "There's no player online by that ID")
      return
    end

    if target then
      local plyMaxPoints = Players[target].data.customVariables.rpRolls.maxpoints or 80
      Players[target].data.customVariables.rpRolls = {
        ["rpr"] = 0,
        ["health"] = 3,
        ["points"] = config.startPoints,
        ["block"] = 0,
        ["alchemy"] = 0,
        ["restoration"] = 0,
        ["conjuration"] = 0,
        ["marksman"] = 0,
        ["handtohand"] = 0,
        ["shortblade"] = 0,
        ["heavyarmor"] = 0,
        ["bluntweapon"] = 0,
        ["alteration"] = 0,
        ["enchant"] = 0,
        ["sneak"] = 0,
        ["lightarmor"] = 0,
        ["athletics"] = 0,
        ["armorer"] = 0,
        ["speechcraft"] = 0,
        ["axe"] = 0,
        ["security"] = 0,
        ["acrobatics"] = 0,
        ["destruction"] = 0,
        ["longblade"] = 0,
        ["illusion"] = 0,
        ["mysticism"] = 0,
        ["spear"] = 0,
        ["mediumarmor"] = 0,
        ["mercantile"] = 0,
        ["unarmored"] = 0,
        ["endurance"] = 0
      }

      rpRolls.systemMessage(pid, "You have wiped %s's levels.", Players[target].accountName)

      if pid ~= target then
        rpRolls.systemMessage(target, "Your levels have been wiped!")
      end

      return
    end
  end
end)

return rpRolls
