--Created by Saint Wish/Wishbone - https://github.com/SaintWish
--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSENSE
local config = require("custom/playerUtils/config")
local cConfig = require("config")

local playerUtils = {}
playerUtils.deleteChars = {}

function playerUtils.log(logType, message, ...)
	local message = string.format(message, ...)

	if logType == nil or logType == "normal" then
		message = "[PLAYER-UTILS]: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "error" then
		message = "[PLAYER-UTILS]ERR: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "warning" then
		message = "[PLAYER-UTILS]WARN: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "notice" then
		message = "[PLAYER-UTILS]NOTE: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "debug" then
		if config.debug then
			message = "[PLAYER-UTILS]DBG: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		end

	else
		playerUtils.log("INVALID LOG CALL", "error")
		message = "[PLAYER-UTILS](invalid): " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	end
end

function playerUtils.systemMessage(pid, prefix, message, ...)
  local msg = string.format(message, ...)
	local fMsg = config.prefixColor .. prefix .. ": " .. config.msgColor .. msg .. "\n"
	playerUtils.log("debug", "MESSAGE FORMATTED %s", msg)

	tes3mp.SendMessage(pid, fMsg, false)
end

function playerUtils.teleportPlayer(pid, cell, position)
	tes3mp.SetCell(pid, cell)
	tes3mp.SetPos(pid, position[1], position[2], position[3])
	tes3mp.SendCell(pid)
	tes3mp.SendPos(pid)
end

function playerUtils.stuckCmd(pid, args)
  local cooldown = Players[pid].data.customVariables.plyUtils.stuck

  if cooldown == 0 or cooldown < os.time() then
    playerUtils.log("debug", "Player %s used /stuck", Players[pid].name)

    Players[pid].data.customVariables.plyUtils.stuck = os.time() + config.stuckCooldown
    Players[pid]:LoadCell()
  	Players[pid]:Save()

    playerUtils.systemMessage(pid, "[STUCK]", "You have been unstuck.")
  else
    local timeLeft = cooldown - os.time()
    playerUtils.log("debug", "Player %s could not use /stuck, %i seconds left", Players[pid].name, timeLeft)
    playerUtils.systemMessage(pid, "[STUCK]", "You can unstuck again in %i seconds.", timeLeft)
  end
end

function playerUtils.hubCmd(pid, args)
	if Players[pid].data.location.cell == "DoR Hub" then
		return
	end

	playerUtils.log("debug", "Player %s used /hub", Players[pid].name)

	local oldCell = Players[pid].data.location.cell
	local oldPos = {Players[pid].data.location.posX, Players[pid].data.location.posY, Players[pid].data.location.posZ}
	Players[pid].data.customVariables.plyUtils.ret.cell = oldCell
	Players[pid].data.customVariables.plyUtils.ret.rpos = oldPos

	playerUtils.teleportPlayer(pid, config.hubCell, config.hubPos)
	playerUtils.systemMessage(pid, "[TP]", "You have been teleported to the hub, You can use /return to return.")
end

function playerUtils.returnCmd(pid, args)
	local retCell = Players[pid].data.customVariables.plyUtils.ret.cell
	local retPos = Players[pid].data.customVariables.plyUtils.ret.rpos

	if retCell == nil then
		playerUtils.systemMessage(pid, "[TP]", "You are unable to return.")
		return

	else
		playerUtils.log("debug", "Player %s used /return", Players[pid].name)

		playerUtils.teleportPlayer(pid, retCell, retPos)
		playerUtils.systemMessage(pid, "[TP]", "You have been returned to your original spot.")

		--Prevent players from using the teleport system to exploit to avoid traveling.
		Players[pid].data.customVariables.plyUtils.ret.cell = nil
	end
end

function playerUtils.deleteCmd(pid, args)
	local accountName = Players[pid].accountName

	if playerUtils.deleteChars[pid] then
		playerUtils.systemMessage(pid, "[CHAR]", "Your character is no longer marked for deletion.")
		playerUtils.deleteChars[pid] = nil
	else
		playerUtils.systemMessage(pid, "[CHAR]", "Your character as been marked for deletion. Type this command again to undo.")
		playerUtils.deleteChars[pid] = accountName
	end
end

customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
  for _,v in pairs(config.startItems) do
    local itemStruct = {refId = v[1], count = v[2], charge = v[3]}
    table.insert(Players[pid].data.inventory, itemStruct)
  end

  Players[pid]:LoadInventory()
  Players[pid]:LoadEquipment()
end)

customEventHooks.registerHandler("OnPlayerFinishLogin", function(eventStatus, pid)
  if not Players[pid].data.customVariables.plyUtils then
    Players[pid].data.customVariables.plyUtils = {
			["stuck"] = 0,
			["ret"] = {
				["cell"] = nil,
				["rpos"] = {0,0,0},
			},
    }

	else
		if not Players[pid].data.customVariables.plyUtils.ret then
			Players[pid].data.customVariables.plyUtils.ret = {
				["cell"] = nil,
				["rpos"] = {0,0,0},
			}
		end
  end
end)

customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
	if not Players[pid].data.customVariables.plyUtils then
    Players[pid].data.customVariables.plyUtils = {
			["stuck"] = 0,
			["ret"] = {
				["cell"] = nil,
				["rpos"] = {0,0,0},
			},
    }
	end

	--Teleport the player to the hub as soon possible for new characters.
	playerUtils.teleportPlayer(pid, config.hubCell, config.hubPos)
end)

customEventHooks.registerHandler("OnPlayerResurrect", function(eventStatus, pid)
	--Teleport player hub when they respawn.
	playerUtils.teleportPlayer(pid, config.hubCell, config.hubPos)
end)

customEventHooks.registerHandler("OnPlayerDisconnect", function(eventStatus, pid)
  if playerUtils.deleteChars[pid] then
		playerUtils.log("normal", "Deleting player file for %s", playerUtils.deleteChars[pid])
		os.remove(cConfig.dataPath.."/player/"..playerUtils.deleteChars[pid]..".json")
		playerUtils.deleteChars[pid] = nil
	end
end)

customCommandHooks.registerCommand("stuck", playerUtils.stuckCmd)
customCommandHooks.registerCommand("hub", playerUtils.hubCmd)
customCommandHooks.registerCommand("return", playerUtils.returnCmd)
customCommandHooks.registerCommand("delete", playerUtils.deleteCmd)

return playerUtils
