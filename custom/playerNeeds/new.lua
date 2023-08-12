--Created by Saint Wish/Wishbone - https://github.com/SaintWish
--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSE
local config = require("custom/playerNeeds/config")
local BasePlayer = require("player.base")
local plyClass = class("PlayerNeeds", BasePlayer)

local playerNeeds = {}
local timers = {}

----------------
-- Script Functions
----------------
function playerNeeds.log(logType, message, ...)
  local message = string.format(message, ...)

  if logType == nil or logType == "normal" then
    message = "[PLAYER-NEEDS]: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "error" then
    message = "[PLAYER-NEEDS]ERR: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "warning" then
    message = "[PLAYER-NEEDS]WARN: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "notice" then
    message = "[PLAYER-NEEDS]NOTE: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "debug" then
    if config.debug then
      message = "[PLAYER-NEEDS]DBG: " .. message
      tes3mp.LogMessage(enumerations.log.INFO, message)
    end

  else
    playerNeeds.log("INVALID LOG CALL", "error")
    message = "[PLAYER-NEEDS](invalid): " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  end
end

--Timer callback function
function playerNeedsCallback(type, pid)
  playerNeeds.log("debug", "Timer callback running")
end

--Should affect player's health
function playerNeeds.initHungerDebuff()
  local recordStore = RecordStores["spell"]
	local id = "plyneeds_debuff_00"
	local recordTable = {
		name = "Starvation",
		subtype = 2,
		effects = {{
			id = 18,
			attribute = -1,
			skill = -1,
			rangeType = 0,
			area = 0,
			magnitudeMin = 5,
			magnitudeMax = 5
		}}
	}
	recordStore.data.generatedRecords[id] = recordTable
	recordStore:Save()
end

--Should affect player's magicka
function playerNeeds.initThirstDebuff()
  local recordStore = RecordStores["spell"]
	local id = "plyneeds_debuff_01"
	local recordTable = {
		name = "Deydration",
		subtype = 2,
		effects = {{
			id = 19,
			attribute = -1,
			skill = -1,
			rangeType = 0,
			area = 0,
			magnitudeMin = 5,
			magnitudeMax = 5
		}}
	}
	recordStore.data.generatedRecords[id] = recordTable
	recordStore:Save()
end

--Should affect player's fatigue
function playerNeeds.initFatigueDebuff()
  local recordStore = RecordStores["spell"]
	local id = "plyneeds_debuff_02"
	local recordTable = {
		name = "Exhaustion",
		subtype = 2,
		effects = {{
			id = 20,
			attribute = -1,
			skill = -1,
			rangeType = 0,
			area = 0,
			magnitudeMin = 5,
			magnitudeMax = 5
		}}
	}
	recordStore.data.generatedRecords[id] = recordTable
	recordStore:Save()
end

function playerNeeds.ingestItem(pid, itemID)
  if not config.enabled then
    return
  end

  playerNeeds.log("debug", "Ingesting item %s player %s", itemID, self.accountName)
  local newVal

  if config.foodItems[itemID] and config.hunger then
    if Players[pid].data.customVariables.plyneeds.hunger >= 90 then
      playerNeeds.systemMessage(pid, "You can not eat anymore.")
      return
    end

    newVal = Players[pid].data.customVariables.plyneeds.hunger + config.foodItems[itemID]
    Players[pid].data.customVariables.plyneeds.hunger = newVal

    if newVal > config.lowRange then
      playerNeeds.systemMessage(pid, "You are no longer feeling as hungry. (%i%%)", newVal)
      Players[pid]:removeNeedsDebuff("plyneeds_debuff_00")
    elseif newVal > 100 then
      Players[pid].data.customVariables.plyneeds.hunger = 100
    end
  end

  if config.drinkItems[itemID] and config.thirst then
    if Players[pid].data.customVariables.plyneeds.hunger >= 90 then
      playerNeeds.systemMessage(pid, "You can not drink anymore.")
      return
    end

    newVal = Players[pid].data.customVariables.plyneeds.thirst + config.drinkItems[itemID]
    Players[pid].data.customVariables.plyneeds.thirst = newVal

    if newVal > config.lowRange then
      playerNeeds.systemMessage(pid, "You are no longer feeling as thirsty. (%i%%)", newVal)
      Players[pid]:removeNeedsDebuff("plyneeds_debuff_01")
    elseif newVal > 100 then
      Players[pid].data.customVariables.plyneeds.thirst = 100
    end
  end
end

function playerNeeds.systemMessage(pid, message, ...)
  local message = config.prefixColor..config.prefix ..": "..config.msgColor..string.format(message, ...).."\n"
  tes3mp.SendMessage(pid, message, false)
end
----------------
-- Player Object Functions
----------------
function plyClass:__init(pid, playerName)
  BasePlayer:__init(self, pid, playerName)
  self.data.customVariables.plyneeds = {}
  self.data.customVariables.plyneeds.hunger = 100
  self.data.customVariables.plyneeds.thirst = 100
  self.data.customVariables.plyneeds.fatigue = 100

  self:doHungerLogic(true)
  self:doThirstLogic(true)
  self:doFatigueLogic(true)
end

function plyClass:resetNeeds()
  playerNeeds.log("debug", "Resetting player data for %s", self.accountName)

  self.data.customVariables.plyneeds.hunger = 100
  self.data.customVariables.plyneeds.hunger = 100
  self.data.customVariables.plyneeds.hunger = 100

  self:doHungerTick()
  self:doThirstTick()
  self:doFatigueTick()
end

function plyClass:doHungerTick()
  if not config.hunger then
    return
  end

  playerNeeds.log("debug", "Running hunger tick for player %s", self.accountName)

  if not timers[self.pid].hTimer then
    timers[self.pid].hTimer = tes3mp.CreateTimerEx("playerNeedsCallback", config.hungerTimer, "ssi", self.accountName, "hunger", self.pid)
    playerNeeds.log("debug", "Starting hunger timer for player %s", self.accountName)
    tes3mp.StartTimer(timer[self.pid].hTimer)
  else
    playerNeeds.log("debug", "Restarting hunger timer for player %s", self.accountName)
    tes3mp.RestartTimer(timer[self.pid].hTimer, config.hungerTimer)
  end
end

function plyClass:doThirstTick()
  if not config.thirst then
    return
  end

  playerNeeds.log("debug", "Running thirst tick for player %s", self.accountName)

  if not timers[self.pid].tTimer then
    timers[self.pid].tTimer = tes3mp.CreateTimerEx("playerNeedsCallback", config.thirstTimer, "ssi", self.accountName, "thirst", self.pid)
    playerNeeds.log("debug", "Starting thirst timer for player %s", self.accountName)
    tes3mp.StartTimer(timer[self.pid].tTimer)
  else
    playerNeeds.log("debug", "Restarting thirst timer for player %s", self.accountName)
    tes3mp.RestartTimer(timer[self.pid].tTimer, config.thirstTimer)
  end
end

function plyClass:doFatigueTick()
  if not config.fatigue then
    return
  end

  playerNeeds.log("debug", "Running fatigue tick for player %s", self.accountName)

  if not timers[self.pid].fTimer then
    timers[self.pid].fTimer = tes3mp.CreateTimerEx("playerNeedsCallback", config.fatigueTimer, "ssi", self.accountName, "fatigue", self.pid)
    playerNeeds.log("debug", "Starting fatigue timer for player %s", self.accountName)
    tes3mp.StartTimer(timer[self.pid].fTimer)
  else
    playerNeeds.log("debug", "Restarting fatigue timer for player %s", self.accountName)
    tes3mp.RestartTimer(timer[self.pid].fTimer, config.fatigueTimer)
  end
end

function plyClass:doHungerLogic(new)
  if not config.enabled or not config.hunger then
    return
  end

  playerNeeds.log("debug", "Running hunger logic for %s", self.accountName)

  local hunger = self.data.customVariables.plyneeds.hunger
  if new then
    if hunger <= config.lowRange then
      playerNeeds.systemMessage(self.pid, "You are hungry, you need to eat something! (%i%%)", hunger)
      self:applyNeedsDebuff("hunger")

    elseif hunger == config.hungerMidCount then
      playerNeeds.systemMessage(self.pid, "You are beginning to feel hungry. (%i%%)", hunger)

    else
      playerNeeds.systemMessage(self.pid, "Your hunger is now at %i%%", hunger)
    end

  else
    local newVal = self.data.customVariables.plyneeds.hunger - config.hungerDecrement
    if hunger <= config.lowRange then
      self.data.customVariables.plyneeds.hunger = newVal
      playerNeeds.systemMessage(self.pid, "You are hungry, you need to eat something! (%i%%)", self.data.customVariables.plyneeds.hunger)
      self:applyNeedsDebuff("hunger")

    elseif hunger == config.hungerMidCount then
      self.data.customVariables.plyneeds.hunger = newVal
      playerNeeds.systemMessage(self.pid, "You are beginning to feel hungry. (%i%%)", self.data.customVariables.plyneeds.hunger)

    else
      self.data.customVariables.plyneeds.hunger = newVal
      playerNeeds.systemMessage(self.pid, "Your hunger is now at %i%%", self.data.customVariables.plyneeds.hunger)
    end

    if self.data.customVariables.plyneeds.hunger < -100 then
      self.data.customVariables.plyneeds.hunger = -100
    end
  end

  playerNeeds.log("normal", "Player %s hunger is at %i", self.accountName, self.data.customVariables.plyneeds.hunger)
end

function plyClass:doThirstLogic(new)
  if not config.enabled or not config.thirst then
    return
  end

  playerNeeds.log("debug", "Running thirst logic for %s", self.accountName)

  local thirst = self.data.customVariables.plyneeds.thirst
  if new then
    if thirst <= config.lowRange then
      playerNeeds.systemMessage(self.pid, "You are thirsty, you need to drink something! (%i%%)", thirst)
      self:applyNeedsDebuff("thirst")

    elseif thirst == config.thirstMidCount then
      playerNeeds.systemMessage(self.pid, "You are beginning to feel thirsty. (%i%%)", thirst)

    else
      playerNeeds.systemMessage(self.pid, "Your thirst is now at %i%%", thirst)
    end

  else
    local newVal = self.data.customVariables.plyneeds.thirst - config.thirstDecrement
    if thirst <= config.lowRange then
      self.data.customVariables.plyneeds.thirst = newVal
      playerNeeds.systemMessage(self.pid, "You are thirsty, you need to drink something! (%i%%)", self.data.customVariables.plyneeds.thirst)
      self:applyNeedsDebuff("thirst")

    elseif thirst == config.thirstMidCount then
      self.data.customVariables.plyneeds.thirst = newVal
      playerNeeds.systemMessage(self.pid, "You are beginning to feel thirsty. (%i%%)", self.data.customVariables.plyneeds.thirst)

    else
      self.data.customVariables.plyneeds.thirst = newVal
      playerNeeds.systemMessage(self.pid, "Your thirst is now at %i%%", self.data.customVariables.plyneeds.thirst)
    end

    if self.data.customVariables.plyneeds.thirst < -100 then
      self.data.customVariables.plyneeds.thirst = -100
    end
  end

  playerNeeds.log("normal", "Player %s thirst is at %i", self.accountName, self.data.customVariables.plyneeds.thirst)
end

function plyClass:doFatigueLogic(new)
  if not config.enabled or not config.fatigue then
    return
  end

  playerNeeds.log("debug", "Running fatigue logic for %s", self.accountName)

  local hunger = self.data.customVariables.plyneeds.fatigue
  if new then
    if fatigue <= config.lowRange then
      playerNeeds.systemMessage(self.pid, "You are tired, you need to rest! (%i%%)", fatigue)
      self:applyNeedsDebuff("fatigue")

    elseif fatigue == config.fatigueMidCount then
      playerNeeds.systemMessage(self.pid, "You are beginning to feel tired. (%i%%)", fatigue)

    else
      playerNeeds.systemMessage(self.pid, "Your fatigue is now at %i%%", fatigue)
    end

  else
    local newVal = self.data.customVariables.plyneeds.fatigue - config.fatigueDecrement
    if fatigue <= config.lowRange then
      self.data.customVariables.plyneeds.fatigue = newVal
      playerNeeds.systemMessage(self.pid, "You are tired, you need to rest! (%i%%)", self.data.customVariables.plyneeds.fatigue)
      self:applyNeedsDebuff("fatigue")

    elseif fatigue == config.fatigueMidCount then
      self.data.customVariables.plyneeds.fatigue = newVal
      playerNeeds.systemMessage(self.pid, "You are beginning to feel tired. (%i%%)", self.data.customVariables.plyneeds.fatigue)

    else
      self.data.customVariables.plyneeds.fatigue = newVal
      playerNeeds.systemMessage(self.pid, "Your fatigue is now at %i%%", self.data.customVariables.plyneeds.fatigue)
    end

    if self.data.customVariables.plyneeds.fatigue < -100 then
      self.data.customVariables.plyneeds.fatigue = -100
    end
  end

  playerNeeds.log("normal", "Player %s fatigue is at %i", self.accountName, self.data.customVariables.plyneeds.fatigue)
end

function plyClass:applyNeedsDebuff(type)
  if not config.debuff then
    return
  end

  playerNeeds.log("normal", "Applying %s debuff for %s", type, self.accountName)

  if type == "hunger" then
    tes3mp.AddSpell(self.pid, "plyneeds_debuff_00")
  elseif type == "thirst" then
    tes3mp.AddSpell(self.pid, "plyneeds_debuff_01")
  elseif type == "fatigue" then
    tes3mp.AddSpell(self.pid, "plyneeds_debuff_02")
  end
end

function plyClass:removeNeedsDebuff(spellName)
  if not config.debuff then
    return
  end

  playerNeeds.log("normal", "Removing %s debuff for %s", type, self.accountName)

  if tableHelper.containsValue(self.data.spellbook, spellName) then
    local recordStore = RecordStores["spell"]
    recordStore:RemoveLinkToPlayer(spellName, Players[self.pid])
    tableHelper.removeValue(self.data.spellbook, spellName)
    self:RemoveLinkToRecord("spell", spellName)
    recordStore:Save()

    tes3mp.ClearSpellbookChanges(self.pid)
    tes3mp.SetSpellbookChangesAction(self.pid, enumerations.spellbook.REMOVE)
    tes3mp.AddSpell(self.pid, spellName)
    tes3mp.SendSpellbookChanges(self.pid)

  else
    playerNeeds.log("debug", "Unable to get %s debuff for player %s", spellName, self.accountName)
  end
end

----------------
-- Hooks
----------------
function playerNeeds.loginHandler(eventStatus, pid)
  if config.enabled == true then
    plyClass:__init(pid, Players[pid].data.login.name)

    playerNeeds.log("normal", "Started logic for player %s", Players[pid].name)
  end
end

customEventHooks.registerHandler("OnServerPostInit", function()
  playerNeeds.initHungerDebuff()
  playerNeeds.initThirstDebuff()
  playerNeeds.initFatigueDebuff()
end)

--customEventHooks.registerHandler("OnPlayerFinishLogin", playerNeeds.loginHandler)
customEventHooks.registerHandler("OnPlayerAuthentified", playerNeeds.loginHandler)
customEventHooks.registerHandler("OnPlayerEndCharGen", playerNeeds.loginHandler)

customEventHooks.registerHandler("OnPlayerResurrect", function(eventStatus, pid)
  Players[pid]:resetNeeds()
end)

customEventHooks.registerHandler("OnPlayerItemUse", function(eventStatus, pid, itemID)
  playerNeeds.ingestItem(pid, itemID)
end)

customEventHooks.registerHandler("OnPlayerDisconnect", function(eventStatus, pid)
  if not config.enabled then
    return
  end

  playerNeeds.log("debug", "Stopping player timers for %i", pid)

  if timers[pid].hTimer then
    tes3mp.StopTimer(timers[pid].hTimer)
  end

  if timers[pid].tTimer then
    tes3mp.StopTimer(timers[pid].tTimer)
  end

  if timers[pid].fTimer then
    tes3mp.StopTimer(timers[pid].fTimer)
  end

  if timers[pid].rTimer then
    --tes3mp.FreeTimer(self.rTimer)
    tes3mp.StopTimer(timers[pid].rTimer)
  end
end)

----------------
-- Commands
----------------
customCommandHooks.registerCommand("enableneeds", function(pid, args)
  if Players[pid]:IsAdmin() then
    if args[2] == "false" then
      config.enabled = false
      tes3mp.SendMessage(pid, config.prefixColor .. config.prefix ..": " .. config.msgColor .. "Player needs has been disabled.\n", true)
    elseif args[2] == "true" then
      config.enabled = true
      tes3mp.SendMessage(pid, config.prefixColor .. config.prefix ..": " .. config.msgColor .. "Player needs has been enabled.\n", true)
    else
      playerNeeds.systemMessage(pid, "Argument has to be true/false. (Player needs is set to %s)", tostring(config.enabled))
    end
  end
end)

customCommandHooks.registerCommand("plyneeds", function(pid, args)
  if not config.enabled then
    return
  end

  if config.hunger then
    playerNeeds.systemMessage(pid, "Your hunger is at: %i%%", Players[pid].data.customVariables.plyneeds.hunger)
  end

  if config.thirst then
    playerNeeds.systemMessage(pid, "Your thirst is at: %i%%", Players[pid].data.customVariables.plyneeds.thirst)
  end

  if config.fatigue then
    playerNeeds.systemMessage(pid, "Your fatigue is at: %i%%", Players[pid].data.customVariables.plyneeds.fatigue)
  end
end)
