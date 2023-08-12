--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSE
local config = require("custom/rpchat/config")

local rpchat = {}
local messageHandlers = {}

function rpchat.initPlayer(pid)
	local name = Players[pid].name
	
	if not Players[pid].data.customVariables then
    Players[pid].data.customVariables = {}
  end
	
	if not Players[pid].data.customVariables.rpchat then
		Players[pid].data.customVariables.rpchat = {
			["name"] = rpchat.correctName(name),
			["color"] = color.White,
		}
	end
end

function rpchat.log(logType, message, ...)
	local message = string.format(message, ...)

	if logType == "normal" then
		message = "[RP-CHAT]: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "error" then
		message = "[RP-CHAT]ERR: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "warning" then
		message = "[RP-CHAT]WARN: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "notice" then
		message = "[RP-CHAT]NOTE: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "debug" then
		if config.debug then
			message = "[RP-CHAT]DBG: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		end
	end
end

function rpchat.format(message)
	message = message:gsub("^%l", string.upper)

	if message:sub(-1) ~= "%p" then
		message = message .. "."
	end

	return message
end

function rpchat.formatP(message)
	if message:sub(-1) ~= "%p" then
		message = message .. "."
	end
	
	return message
end

function rpchat.correctName(playerName)
	playerName = playerName:gsub("^%l", string.upper)
	rpchat.log("debug", "Name %s has been corrected.", playerName)
	
	return playerName
end

function rpchat.verifyColor(colorString)
	if string.len(colorString) == 6 then
		if tonumber(colorString, 16) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function rpchat.setColor(pid, newColor, originPID)
	if rpchat.verifyColor(newColor) then
		local name = Players[pid].name
		newColor = "#" .. newColor

		Players[pid].data.customVariables.rpchat.color = newColor
		rpchat.log("debug", "COLOR FOR %s CHANGED TO %s", name, tostring(newColor))
	else
		rpchat.systemMessage(originPID, "Invalid color, please use hex color codes.")
	end
end

function rpchat.getColor(pid)
	return Players[pid].data.customVariables.rpchat.color
end

function rpchat.getName(pid, rp)
	rp = rp or true

	if rp == true then
		if Players[pid].data.customVariables.rpchat.nick ~= nil then
			return config.colors.nickname .. Players[pid].data.customVariables.rpchat.nick
		else
			return Players[pid].data.customVariables.rpchat.name
		end

	else
		return Players[pid].data.customVariables.rpchat.name
	end
end

messageHandlers["local"] = function(pid, message, pColor)
	message = pColor .. rpchat.getName(pid) .. color.White .. ": \"" .. rpchat.format(message) .. "\"\n"
	rpchat.localMessageDist(pid, message, config.talkDist)
end

messageHandlers["ooc"] = function(pid, message, pColor)
	message = config.colors.ooc  .. "[OOC] " .. pColor .. Players[pid].name .. color.White .. ": " .. rpchat.format(message) .. "\n"
	tes3mp.SendMessage(pid, message, true)
end

messageHandlers["looc"] = function(pid, message, pColor)
	message = config.colors.looc .. "[LOOC] " .. pColor .. Players[pid].name .. color.White .. ": " .. rpchat.format(message) .. "\n"
	rpchat.localMessage(pid, message)
end

messageHandlers["emote"] = function(pid, message, pColor)
	message = config.colors.emote .. "[ACTION] " .. pColor .. rpchat.getName(pid) .. color.White .. " " .. rpchat.formatP(message) .. "\n"
	rpchat.localMessageDist(pid, message, config.talkDist)
end

messageHandlers["whisper"] = function(pid, message, pColor)
	message = config.colors.whisper .. "[WHISPER] " .. pColor .. rpchat.getName(pid) .. color.White .. ": \"" .. rpchat.format(message) .. "\"\n"
	rpchat.localMessageDist(pid, message, config.whisperDist)
end

messageHandlers["shout"] = function(pid, message, pColor)
	message = config.colors.shout .. "[SHOUT] " .. pColor .. rpchat.getName(pid) .. color.White .. ": \"" .. rpchat.format(message) .. "\"\n"
	rpchat.localMessageDist(pid, message, config.shoutDist)
end

function rpchat.messageHandler(pid, message, messageType)
	local pColor = rpchat.getColor(pid)
	local messageType = messageType or "local"
	if pColor == nil then pColor = color.White end

	rpchat.log("debug", "PLAYER COLOR IS %s", tostring(pColor))
	rpchat.log("normal", "%s(%s): %s - %s", Players[pid].name, rpchat.getName(pid), message, messageType)
	messageHandlers[messageType](pid, message, pColor)
end

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function rpchat.localMessage(pid, message)
	local cellDesc = Players[pid].data.location.cell
	print(dump(LoadedCells[cellDesc].visitors))
	
	for _,ply in pairs(LoadedCells[cellDesc].visitors) do
		rpchat.log("debug", "PLAYER ID IN CELL %s %i", cellDesc, ply)
		if Players[ply].data.location.cell == cellDesc then
			tes3mp.SendMessage(ply, message, false)
		end
	end
end

function rpchat.localMessageDist(pid, message, dist)
	local originX = tes3mp.GetPosX(pid)
	local originY = tes3mp.GetPosY(pid)

	rpchat.log("debug", "PLAYER POSITION IS %f, %f", originX, originY)

	for ply,_ in pairs(Players) do
		local plyX = tes3mp.GetPosX(ply)
		local plyY = tes3mp.GetPosY(ply)
		local plyDist = math.sqrt((originX - plyX) * (originX - plyX) + (originY - plyY) * (originY - plyY))

		if plyDist <= dist then
			tes3mp.SendMessage(ply, message, false)
		end
	end
end

function rpchat.systemMessage(pid, message, ...)
	local msg = string.format(message, ...)
	local fMsg = color.Cyan .. "[RP-CHAT]: " .. color.White .. msg .. "\n"
	rpchat.log("debug", "MESSAGE FORMATTED %s", msg)

	tes3mp.SendMessage(pid, fMsg, false)
end

function rpchat.globalMessage(pid, message, ...)
	local msg = string.format(message, ...)
	local fMsg = color.Cyan .. "[RP-CHAT]: " .. color.White .. msg .. "\n"
	rpchat.log("debug", "MESSAGE FORMATTED %s", msg)

	tes3mp.SendMessage(pid, fMsg, true)
end

function rpchat.commandHandler(pid, cmd)
	if cmd[2] ~= nil then
		if cmd[2] == "color" and Players[pid].data.settings.staffRank > 0 then
			if cmd[3] ~= nil and logicHandler.CheckPlayerValidity(pid, cmd[3]) then
				if cmd[4] ~= nil then
					local target = tonumber(cmd[3])
					local newColor = cmd[4]

					rpchat.setColor(target, newColor, pid)
					rpchat.systemMessage(pid, "You have changed %s name color to "..Players[target].data.customVariables.rpchat.color.."color", Players[target].name)
				else
					local target = tonumber(cmd[3])
					local oldColor = Players[target].data.customVariables.rpchat.color or #fff
					rpchat.systemMessage(pid, "%s's name color is set to "..oldColor.."color", Players[target].name)
				end
			else
				rpchat.systemMessage(pid, "Invalid PID.")
			end

		elseif cmd[2] == "toggleooc" and Players[pid].data.settings.staffRank > 0 then
			if cmd[3] == "false" then
				config.toggleOOC = false
				rpchat.globalMessage(pid, "OOC has been turned off by staff.")
			elseif cmd[3] == "true" then
				config.toggleOOC = true
				rpchat.globalMessage(pid, "OOC has been turned on by staff.")
			else
				rpchat.systemMessage(pid, "Argument has to be true/false. (OOC is set to %s)", tostring(config.toggleOOC))
			end

		else
			rpchat.systemMessage(pid, "Invalid command.")
		end

	else
		rpchat.systemMessage(pid, "Invalid command.")
	end
end

function rpchat.nickname(pid, cmd)
	local nick = ""

	if config.enableNicks then
		if cmd[2] ~= nil then
			for index, value in pairs(cmd) do
				if index > 1 and index <= 2 then
					nick = nick .. value
				elseif index > 2 then
					nick = nick .. " " .. value
				end
			end

			if nick:len() >= config.nickMinLen and nick:len() <= config.nickMaxLen then
				Players[pid].data.customVariables.rpchat.nick = nick
				rpchat.systemMessage(pid, "Your nickname as been set to: %s", nick)
			else
				rpchat.systemMessage(pid, "That nickname is incorrect. The max length allowed is %i", config.nickMaxLen)
			end
		else
			Players[pid].data.customVariables.rpchat.nick = nil
			rpchat.systemMessage(pid, "Your nickname as been reset.")
		end

	else
		rpchat.systemMessage(pid, "Nicknames are disabled.")
	end
end

function rpchat.ooc(pid, cmd)
	if config.toggleOOC == false and Players[pid].data.settings.staffRank <= 0 then
		rpchat.systemMessage(pid, "OOC has been disabled by staff.")
		return
	end

	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "ooc")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.looc(pid, cmd)
	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "looc")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.emote(pid, cmd)
	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "emote")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.shout(pid, cmd)
	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "shout")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.whisper(pid, cmd)
	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "whisper")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.loginHandler(eventStatus, pid)
	rpchat.initPlayer(pid)
end

customEventHooks.registerHandler("OnPlayerFinishLogin", rpchat.loginHandler)
customEventHooks.registerHandler("OnPlayerEndCharGen", rpchat.loginHandler)

customEventHooks.registerValidator("OnPlayerSendMessage", function(event, pid, message)
	if message:sub(1,1) ~= "/" then
		rpchat.messageHandler(pid, message)
		return customEventHooks.makeEventStatus(false, nil)
	end
end)

customCommandHooks.registerCommand("rpchat", rpchat.commandHandler)
customCommandHooks.registerCommand("nick", rpchat.nickname)
customCommandHooks.registerCommand("ooc", rpchat.ooc)
customCommandHooks.registerCommand("/", rpchat.ooc)
customCommandHooks.registerCommand("looc", rpchat.looc)
customCommandHooks.registerCommand("//", rpchat.looc)
customCommandHooks.registerCommand("me", rpchat.emote)
customCommandHooks.registerCommand("s", rpchat.shout)
customCommandHooks.registerCommand("yell", rpchat.shout)
customCommandHooks.registerCommand("w", rpchat.whisper)

return rpchat