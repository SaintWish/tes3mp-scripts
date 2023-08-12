local rpchatConfig = require("custom/rpchat/config")
local config = {}

config.debug = true

--The distance other players can hear eachother when they roll.
config.rollChatDist = rpchatConfig.talkDist

--Critical config options
config.critBonus = 3 --How much bonus should a person get for achieving a critical hit
config.critChance = 5 --The percentage of a critical hit chance.

--Level options
config.maxLevel = 24 --The max level a player can have in a skill.
config.startPoints = 18 --The amount of free perk points players start with.
config.bonusPerPoint = 2 --skill level/bonusAmount = bonus amount
config.hpPerPoint = 5 --how many points it cost for a single health point.

--Message options
config.prefix = "[RP-Rolls]"
config.prefixColor = color.CadetBlue
config.plyColor = color.BlueViolet
config.msgColor = color.White
config.setColor = color.Cyan
config.auxColor = color.LightCyan

--What skills are allowed to have a critical chance roll.
config.critAllowed = {
  ["handtohand"] = true,
  ["axe"] = true,
  ["longblade"] = true,
  ["bluntweapon"] = true,
  ["shortblade"] = true,
  ["marksman"] = true
}

--The lookup table for skills. This determines what stuff can be leveled by the player.
config.skill = {
  ["block"] = "Block",
  ["alchemy"] = "Alchemy",
  ["restoration"] = "Restoration",
  ["conjuration"] = "Conjuration",
  ["marksman"] = "Marksman",
  ["handtohand"] = "Hand to Hand",
  ["shortblade"] = "Short Blade",
  ["heavyarmor"] = "Heavy Armor",
  ["bluntweapon"] = "Bluntweapon",
  ["alteration"] = "Alteration",
  ["enchant"] = "Enchant",
  ["sneak"] = "Sneak",
  ["lightarmor"] = "Light Armor",
  ["athletics"] = "Athletics",
  ["armorer"] = "Armorer",
  ["speechcraft"] = "Speechcraft",
  ["axe"] = "Axe",
  ["security"] = "Security",
  ["acrobatics"] = "Acrobatics",
  ["destruction"] = "Destruction",
  ["longblade"] = "Long Blade",
  ["illusion"] = "Illusion",
  ["mysticism"] = "Mysticism",
  ["spear"] = "Spear",
  ["mediumarmor"] = "Medium Armor",
  ["mercantile"] = "Mercantile",
  ["unarmored"] = "Unarmored",
  ["endurance"] = "Endurance",
}

return config
