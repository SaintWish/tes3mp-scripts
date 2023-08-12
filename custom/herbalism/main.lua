--Created by Saint Wish/Wishbone - https://github.com/SaintWish
--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSE
--Based off of rnate's GraphicHerbalism script https://github.com/rnate/TES3MP-GraphicHerbalism-Outdated
local config = require("custom/herbalism/config")

local herbalism = {}
herbalism.pickData = {}

function herbalism.saveData()
  herbalism.log("debug", "Saving herbalism world data.")
  jsonInterface.save(config.saveFile, herbalism.pickData)
end

function herbalism.loadData()
  return jsonInterface.load(config.saveFile)
end

function herbalism.log(logType, message, ...)
  local message = string.format(message, ...)

  if logType == nil or logType == "normal" then
    message = "[HERBALISM]: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "error" then
    message = "[HERBALISM]ERR: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "warning" then
    message = "[HERBALISM]WARN: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "notice" then
    message = "[HERBALISM]NOTE: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "debug" then
    if config.debug then
      message = "[HERBALISM]DBG: " .. message
      tes3mp.LogMessage(enumerations.log.INFO, message)
    end

  else
    herbalism.log("INVALID LOG CALL", "error")
    message = "[HERBALISM](invalid): " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  end
end

function herbalism.isPickable(plantRefID)
  for k,_ in pairs(config.plantList) do
    if string.match(plantRefID, k) then
      return true
    end
  end

  return false
end

function herbalism.getIngredient(plantRefID)
  local ingred = {}
  local count = 0
  local chance = 0
  ingred.count = 0

  for k,v in pairs(config.plantList) do
    if string.match(plantRefID, k) then
      ingred.refID = k
      ingred.name = v["name"]
      count = v["count"]
      chance = v["chance"]
    end
  end

  for i=1, count, 1 do
    if math.random() > chance then
      ingred.count = ingred.count+1
    end
  end

  return ingred
end

function herbalism.giveIngredients(pid, plantRefID)
  local ingred = herbalism.getIngredient(plantRefID)
  herbalism.log("debug", "found ingredient %s amount %i", ingred.name, ingred.count)

  if ingred.count > 0 then
    inventoryHelper.addItem(Players[pid].data.inventory, ingred.refID, ingred.count, -1, -1, "")

    local item = {}
    item.refId = ingred.refID
		item.charge = -1
		item.enchantmentCharge = -1
		item.count = ingred.count
		item.soul = ""

    Players[pid]:LoadItemChanges({item}, enumerations.inventory.ADD)
    herbalism.log("debug", "gave player %i ingredient %s", pid, ingred.name)

    local message = ""
    if ingred.count > 1 then
      message = "You harvested %d %ss."

      local lastLetter = string.sub(ingred.name, -1)
			if lastLetter == "s" then
				ingred.name = ingred.name .. "'" --if it ends in s, change to s'
				message = "You harvested %d %s."
			end
    else
      message = "You harvested %d %s."
    end

    tes3mp.MessageBox(pid, -1, string.format(message, ingred.count, ingred.name))
    tes3mp.PlaySpeech(pid, "Fx/item/item.wav")
  else
    tes3mp.MessageBox(pid, -1, "You failed to harvest anything useful.")
    tes3mp.PlaySpeech(pid, "Fx/item/blunt.wav")
  end
end

function herbalism.handlePlant(pid, cellDesc, objRefID, uniqueIndex)
  herbalism.log("debug", "Player %i activated plant object: %s (%s) in cell %s", pid, objRefID, uniqueIndex, cellDesc)

  if herbalism.pickData[cellDesc] == nil then
    herbalism.pickData[cellDesc] = {}
    herbalism.log("debug", "pickData celldesc nil")
  end

  if herbalism.pickData[cellDesc][uniqueIndex] == nil then
		herbalism.pickData[cellDesc][uniqueIndex] = {}
    herbalism.log("debug", "pickData celldesc uniqueindex nil")
	end

  herbalism.pickData[cellDesc][uniqueIndex].plantRefID = objRefID
  herbalism.pickData[cellDesc][uniqueIndex].daysPassed = WorldInstance.data.time.daysPassed
  herbalism.pickData[cellDesc][uniqueIndex].hour = math.floor(WorldInstance.data.time.hour)

	logicHandler.RunConsoleCommandOnObject(pid, "Disable", cellDesc, uniqueIndex)
  herbalism.log("debug", "giving ingredients to player %i", pid)
  --herbalism.giveIngredients(pid, objRefID)

  herbalism.saveData()
end

-- function herbalism.resetMissingPlants(pid, cellDesc)
--   tes3mp.ClearObjectList()
--   tes3mp.SetObjectListPid(pid)
--   tes3mp.SetObjectListCell(cellDesc)
--
--   herbalism.log("debug", "resetMissingPlants called with args %i, %s", pid, cellDesc)
--   for i=0, tes3mp.GetObjectListSize()-1 do
--     print(i)
--     objectRefID = tes3mp.GetObjectRefId(i)
--     uniqueIndex = tes3mp.GetObjectRefNum(i) .. "-" .. tes3mp.GetObjectMpNum(i)
--
--     if not tes3mp.IsObjectPlayer(i) and herbalism.isPickable(objectRefID) then
--       herbalism.log("debug", "Is plant")
--       if herbalism.pickData[cellDesc][uniqueIndex] == nil then
--         herbalism.log("debug", "Reset plant")
--         logicHandler.RunConsoleCommandOnObject(pid, "Enable", cellDesc, uniqueIndex)
--       end
--     end
--   end
-- end

customEventHooks.registerHandler("OnServerPostInit", function()
  herbalism.pickData = herbalism.loadData() or {}
end)

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDesc)
  for i=0, tes3mp.GetObjectListSize()-1 do
    if not tes3mp.IsObjectPlayer(i) and tes3mp.DoesObjectHavePlayerActivating(i) then
      objectRefID = tes3mp.GetObjectRefId(i)
      objectUniqueIndex = tes3mp.GetObjectRefNum(i) .. "-" .. tes3mp.GetObjectMpNum(i)

      if herbalism.isPickable(objectRefID) then
        herbalism.handlePlant(pid, cellDesc, objectRefID, objectUniqueIndex)
      end
    end
  end
end)

customEventHooks.registerHandler("OnCellLoad", function(eventStatus, pid, cellDesc)
  if herbalism.pickData[cellDesc] ~= nil then
    local deletedCount = 0
    local loopCount = 0
    local worldTime = WorldInstance.data.time
    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(cellDesc)

    for k,v in pairs(herbalism.pickData[cellDesc]) do
      loopCount = loopCount+1

      if (worldTime.daysPassed - v["daysPassed"] == config.growthDays) and
      (math.floor(worldTime.hour) - v["hour"] >= 0) or
      (worldTime.daysPassed - v["daysPassed"] >= config.growthDays+1) then
        if LoadedCells[cellDesc].data.objectData[k] ~= nil then
          herbalism.log("debug", "Plants have been reset!")
          logicHandler.RunConsoleCommandOnObject(pid, "Enable", cellDesc, k)

          local objectData = {}
          objectData.refId = v["plantRefID"]
          objectData.state = true

          herbalism.log("debug", "1")
          packetBuilder.AddObjectState(k, objectData)
          herbalism.log("debug", "2")
          LoadedCells[cellDesc].data.objectData[k].state = true
          herbalism.log("debug", "3")
          tes3mp.SendObjectState()

          herbalism.pickData[cellDesc][k] = nil
          deletedCount = deletedCount+1
        else
          herbalism.pickData[cellDesc][k] = nil
          deletedCount = deletedCount+1
        end
      end
    end

    if loopCount == deletedCount then
      herbalism.pickData[cellDesc] = nil
    end

    if deletedCount > 0 then
      --herbalism.saveData()
    end
  end
end)

-- customCommandHooks.registerCommand("resetplants", function(pid, cmd)
--   if Players[pid]:IsAdmin() then
--     herbalism.log("debug", "Ran command")
--     local cellDesc = tes3mp.GetCell(pid)
--     herbalism.resetMissingPlants(pid, cellDesc)
--     tes3mp.SendMessage(pid, "Missing plants from herbalism list has been reset.", false)
--   end
-- end)

return herbalism
