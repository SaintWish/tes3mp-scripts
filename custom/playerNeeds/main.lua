--Created by Saint Wish/Wishbone - https://github.com/SaintWish
--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSE
local config = require("custom/playerNeeds/config")

local playerNeeds = {}
local usersObj = {}

----------------
-- Object creation
----------------
local playerMeta = {}
playerMeta.__index = playerMeta

function playerNeeds.createPlayer(pid)
  local PLAYER = {}
  setmetatable(PLAYER, playerMeta)

  if usersObj[pid] == nil then
    PLAYER.pid = pid
    PLAYER.name = tostring(Players[pid].name)

    PLAYER.hTimer = nil
    PLAYER.tTimer = nil
    PLAYER.fTimer = nil
    PLAYER.rTimer = nil

    PLAYER.data = {}
    PLAYER.data.hunger = 100
    PLAYER.data.thirst = 100
    PLAYER.data.fatigue = 100

    return PLAYER
  else
    return nil
  end
end

----------------
-- Script Functions
----------------
function playerNeeds.log(message, logType)
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
  elseif logType == "debug" and config.debug then
    message = "[PLAYER-NEEDS]DBG: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)

  else
    playerNeeds.log("INVALID LOG CALL", "error")
    message = "[PLAYER-NEEDS](invalid): " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  end
end

function playerNeeds.initPlayer(pid)
  playerNeeds.log("Calling player init for pid "..pid, "debug")

  if config.enabled == true then
    local ply = playerNeeds.createPlayer(pid)
    ply:loadData()
    ply:hungerLogic(true)
    ply:thirstLogic(true)
    ply:fatigueLogic(true)
    ply:update()

    playerNeeds.log("Created player object for player "..ply.name, "normal")
  end
end

--Make sure the player is the same one, otherwise don't pass
function playerNeeds.PlyIsValid(pid, name)
  if Players[pid] then
    if Players[pid].name == name then
      return true
    else
      return false
    end

  else
    return false
  end
end

--Should affect player's health
function playerNeeds.initHungerDebuff(oldName, pid)
  if playerNeeds.PlyIsValid(pid, oldName) then
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
end

--Should affect player's magicka
function playerNeeds.initThirstDebuff(oldName, pid)
  if playerNeeds.PlyIsValid(pid, oldName) then
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
end

--Should affect player's fatigue
function playerNeeds.initFatigueDebuff(oldName, pid)
  if playerNeeds.PlyIsValid(pid, oldName) then
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
end

function playerNeedsCallback(oldName, type, pid)
  playerNeeds.log("Timer callback running", "debug")

  if playerNeeds.PlyIsValid(pid, oldName) then
    if type == "hunger" then
      usersObj[pid]:hungerLogic()
    elseif type == "thirst" then
      usersObj[pid]:thirstLogic()
    elseif type == "fatigue" then
      usersObj[pid]:fatigueLogic()
    elseif type == "rest" then
      usersObj[pid].data.fatigue = 100
      usersObj[pid]:cleanSpell("plyneeds_debuff_02")
    else
      playerNeeds.log("Timer callback: unknown type used!", "error")
    end
  else
    playerNeeds.log("Timer callback: player no longer valid.")
  end
end

----------------
-- Player Functions
----------------
function playerMeta:systemMessage(message)
  if playerNeeds.PlyIsValid(self.pid, self.name) then
    message = config.prefixColor .. config.prefix ..": " .. config.msgColor .. message .. "\n"
    tes3mp.SendMessage(self.pid, message, false)
  end
end

function playerMeta:loadData()
  if not config.enabled then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    local data = Players[self.pid].data.customVariables.plyneeds
    if data ~= nil then
      playerNeeds.log("Loading data for "..self.name)
      self.data = data
    else
      playerNeeds.log("No data found for "..self.name)
    end
  end
end

function playerMeta:reset()
  if not config.enabled then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Resetting player data for "..self.name, "debug")

    self.data.hunger = 100
    self.data.thirst = 100
    self.data.fatigue = 100
    self:cleanSpell("plyneeds_debuff_00")
    self:cleanSpell("plyneeds_debuff_01")
    self:cleanSpell("plyneeds_debuff_02")

    self:hungerTick()
    self:thirstTick()
    self:fatigueTick()

  else
    playerNeeds.log("Player no longer valid for "..self.name, "debug")
  end
end

function playerMeta:destroy()
  if not config.enabled then
    return
  end

  playerNeeds.log("Destroying player data for "..self.name, "debug")

  if self.hTimer then
    --tes3mp.FreeTimer(self.hTimer)
    tes3mp.StopTimer(self.hTimer)
  end

  if self.tTimer then
    --tes3mp.FreeTimer(self.tTimer)
    tes3mp.StopTimer(self.tTimer)
  end

  if self.fTimer then
    --tes3mp.FreeTimer(self.fTimer)
    tes3mp.StopTimer(self.fTimer)
  end

  if self.rTimer then
    --tes3mp.FreeTimer(self.rTimer)
    tes3mp.StopTimer(self.rTimer)
  end
end

function playerMeta:hungerTick()
  if not config.hunger then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Running hunger tick for player "..self.name, "debug")

    if not self.hTimer then
      self.hTimer = tes3mp.CreateTimerEx("playerNeedsCallback", config.hungerTimer, "ssi", self.name, "hunger", self.pid)
      playerNeeds.log("Starting hunger timer for player " .. self.name, "debug")
      tes3mp.StartTimer(self.hTimer)
    else
      playerNeeds.log("Restarting hunger timer for player " .. self.name, "debug")
      tes3mp.RestartTimer(self.hTimer, config.hungerTimer)
    end

    self:update()
  end
end

function playerMeta:thirstTick()
  if not config.thirst then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Running thirst tick for player "..self.name, "debug")

    if not self.tTimer then
      self.tTimer = tes3mp.CreateTimerEx("playerNeedsCallback", config.thirstTimer, "ssi", self.name, "thirst", self.pid)
      playerNeeds.log("Starting thirst timer for player " .. self.name, "debug")
      tes3mp.StartTimer(self.tTimer)
    else
      playerNeeds.log("Restarting thirst timer for player " .. self.name, "debug")
      tes3mp.RestartTimer(self.tTimer, config.thirstTimer)
    end
  end
end

function playerMeta:fatigueTick()
  if not config.fatigue then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Running fatigue tick for player "..self.name, "debug")

    if not self.fTimer then
      self.fTimer = tes3mp.CreateTimerEx("playerNeedsCallback", config.fatigueTimer, "ssi", self.name, "fatigue", self.pid)
      playerNeeds.log("Starting fatigue timer for player " .. self.name, "debug")
      tes3mp.StartTimer(self.fTimer)
    else
      playerNeeds.log("Restarting fatigue timer for player " .. self.name, "debug")
      tes3mp.RestartTimer(self.fTimer, config.fatigueTimer)
    end
  end
end

function playerMeta:applyDebuff(type)
  if not config.debuff then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Applying "..type.." debuff for "..self.name)

    if type == "hunger" then
      playerNeeds.initHungerDebuff(self.name, self.pid)
    elseif type == "thirst" then
      playerNeeds.initThirstDebuff(self.name, self.pid)
    elseif type == "fatigue" then
      playerNeeds.initFatigueDebuff(self.name, self.pid)
    end
  end
end

function playerMeta:cleanSpell(spellName)
  if not config.debuff then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Removing "..spellName.." debuff for "..self.name, "debug")

    if tableHelper.containsValue(Players[self.pid].data.spellbook, spellName) then
      local recordStore = RecordStores["spell"]
      recordStore:RemoveLinkToPlayer(spellName, Players[self.pid])
      tableHelper.removeValue(Players[self.pid].data.spellbook, spellName)
      Players[self.pid]:RemoveLinkToRecord("spell", spellName)
      recordStore:Save()

      tes3mp.ClearSpellbookChanges(self.pid)
      tes3mp.SetSpellbookChangesAction(self.pid, enumerations.spellbook.REMOVE)
      tes3mp.AddSpell(self.pid, spellName)
      tes3mp.SendSpellbookChanges(self.pid)

    else
      playerNeeds.log("Unable to get "..spellName.." debuff for player "..self.name, "debug")
    end
  end
end

function playerMeta:rest()
  if not config.fatigue then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    local cell = tes3mp.GetCell(self.pid)
    playerNeeds.log("Resting in cell "..cell.." player "..self.name, "debug")

    if self.data.fatigue > config.lowRange then
      self:systemMessage("You are not tired enough to sleep!")
      return
    end

    if self.rLock == false then
      if tableHelper.containsValue(basicNeedsConfig.restingCells, cell) then
        self.rLock = true
        local timer = tes3mp.CreateTimerEx("playerNeedsCallback", config.restTimer, "ssi", self.name, "rest", self.pid)
        tes3mp.StartTimer(timer)
      else
        self:systemMessage("You are unable to rest here!")
        return
      end

    else
      self:systemMessage("You are already resting!")
      return
    end
  end
end

function playerMeta:statusCmd()
  if not config.enabled then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    if config.hunger then
      self:systemMessage("Your hunger is at: "..tostring(self.data.hunger).."%")
    end

    if config.thirst then
      self:systemMessage("Your thirst is at: "..tostring(self.data.thirst).."%")
    end

    if config.fatigue then
      self:systemMessage("Your fatigue is at: "..tostring(self.data.fatigue).."%")
    end
  end
end

function playerMeta:ingest(itemRefID)
  if not config.enabled or not config.hunger or not config.thirst then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Ingesting item "..itemRefID.." player "..self.name, "debug")


    if config.foodItems[itemRefID] then
      if self.data.hunger >= 90 then
        self:systemMessage("You can not eat anymore.")
        return
      end

      local newVal = self.data.hunger + config.foodItems[itemRefID]

      self.data.hunger = newVal
      if newVal > config.lowRange then
        self:systemMessage("You are no longer feeling as hungry. ("..self.data.hunger.."%)")
        self:cleanSpell("plyneeds_debuff_00")
      elseif newVal > 100 then
        self.data.hunger = 100
      end

      return
    end

    if config.drinkItems[itemRefID] then
      if self.data.thirst >= 90 then
        self:systemMessage("You can not drink anymore.")
        return
      end

      local newVal = self.data.thirst + config.drinkItems[itemRefID]

      self.data.thirst = newVal
      if newVal > config.lowRange then
        self:systemMessage("You are no longer feeling as thirsty. ("..self.data.thirst.."%)")
        self:cleanSpell("plyneeds_debuff_01")
      elseif newVal > 100 then
        self.data.thirst = 100
      end

      return
    end
  end
end

function playerMeta:update()
  if not config.enabled then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Updating player for "..self.name, "debug")
    usersObj[self.pid] = self
    Players[self.pid].data.customVariables.plyneeds = self.data
  end
end

function playerMeta:hungerLogic(new)
  if not config.enabled or not config.hunger then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Running hunger logic for "..self.name, "debug")

    local newVal = self.data.hunger
    if not new then
      newVal = self.data.hunger - config.hungerDecrement
    end

    if self.data.hunger <= -100 and self.data.hunger < 0 then
       self.data.hunger = -100
    end

    --Starving
    if self.data.hunger <= config.lowRange then
      self.data.hunger = newVal
      self:systemMessage("You are hungry, you need to eat something! ("..self.data.hunger.."%)")
      self:applyDebuff("hunger")

    elseif self.data.hunger == config.midRange then
      self.data.hunger = newVal
      self:systemMessage("You are beginning to feel hungry. ("..self.data.hunger.."%)")

    else
      self.data.hunger = newVal
      --self:systemMessage("Your hunger is now at "..self.data.hunger.."%")
    end

    playerNeeds.log("Player "..self.name.." hunger is at "..self.data.hunger)
    self:hungerTick()
  end
end

function playerMeta:thirstLogic(new)
  if not config.enabled or not config.thirst then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Running thirst logic for "..self.name, "debug")

    local newVal = self.data.thirst
    if not new then
      newVal = self.data.thirst - config.thirstDecrement
    end

    --Thirsty
    if self.data.thirst <= -100 and self.data.thirst < 0 then
       self.data.thirst = -100
    end

    if self.data.thirst <= config.lowRange then
      self.data.thirst = newVal
      self:systemMessage("You are thirsty, you need to drink something! ("..self.data.thirst.."%)")
      self:applyDebuff("thirst")

    elseif self.data.thirst == config.midRange then
      self.data.thirst = newVal
      self:systemMessage("You are beginning to feel thirsty. ("..self.data.thirst.."%)")

    else
      self.data.thirst = newVal
      --self:systemMessage("Your thirst is now at "..self.data.thirst.."%")
    end

    playerNeeds.log("Player "..self.name.." thirst is at "..self.data.thirst)
    self:thirstTick()
  end
end

function playerMeta:fatigueLogic(new)
  if not config.enabled or not config.fatigue then
    return
  end

  if playerNeeds.PlyIsValid(self.pid, self.name) then
    playerNeeds.log("Running fatigue logic for "..self.name, "debug")

    local newVal = self.data.fatigue
    if not new then
      newVal = self.data.fatigue - config.fatigueDecrement
    end

    if self.data.fatigue <= -100 and self.data.fatigue < 0 then
       self.data.fatigue = -100
    end

    --Sleepy
    if self.data.fatigue <= config.lowRange then
      self.data.fatigue = newVal
      self:systemMessage("You are tired, you should sleep! (type /rest) ("..self.data.fatigue.."%)")
      self:applyDebuff("fatigue")

    elseif self.data.fatigue == config.midCount then
      self.data.fatigue = newVal
      self:systemMessage("You are beginning to feel tired. ("..self.data.fatigue.."%)")

    else
      self.data.fatigue = newVal
      --self:systemMessage("Your fatigue is now at "..self.data.fatigue.."%")
    end

    playerNeeds.log("Player "..self.name.." fatigue is at "..self.data.fatigue)
    self:fatigueTick()
  end
end

----------------
-- Hooks
----------------
function playerNeeds.loginHandler(eventStatus, pid)
  playerNeeds.initPlayer(pid)
end

customEventHooks.registerHandler("OnPlayerFinishLogin", playerNeeds.loginHandler)
customEventHooks.registerHandler("OnPlayerEndCharGen", playerNeeds.loginHandler)

customEventHooks.registerHandler("OnPlayerResurrect", function(eventStatus, pid)
  playerNeeds.log(pid)

  if usersObj[pid] then
    usersObj[pid]:reset()
  end
end)

customEventHooks.registerHandler("OnPlayerItemUse", function(eventStatus, pid, itemID)
  if usersObj[pid] then
    usersObj[pid]:ingest(itemID)
  end
end)

customEventHooks.registerHandler("OnPlayerDisconnect", function(eventStatus, pid)
  if usersObj[pid] then
    usersObj[pid]:destroy()
    usersObj[pid] = nil
  end
end)

customCommandHooks.registerCommand("rest", function(pid)
  if usersObj[pid] then
    usersObj[pid]:rest()
  end
end)

customCommandHooks.registerCommand("plyneeds", function(pid)
  if usersObj[pid] then
    usersObj[pid]:statusCmd()
  end
end)

customCommandHooks.registerCommand("enableneeds", function(pid, args)
  if Players[pid]:IsAdmin() then
    if args[2] == "false" then
      config.enabled = false
      tes3mp.SendMessage(pid, config.prefixColor .. config.prefix ..": " .. config.msgColor .. "Player needs has been disabled.\n", true)
    elseif args[2] == "true" then
      config.enabled = true
      tes3mp.SendMessage(pid, "Player needs has been enabled.\n", true)
      tes3mp.SendMessage(pid, config.prefixColor .. config.prefix ..": " .. config.msgColor .. "Player needs has been enabled.\n", true)
    else
      local msg = string.format("Argument has to be true/false. (Player needs is set to %s)\n", tostring(config.enabled))
      tes3mp.SendMessage(pid, config.prefixColor .. config.prefix ..": " .. config.msgColor .. msg, false)
    end
  end
end)

return playerNeeds
