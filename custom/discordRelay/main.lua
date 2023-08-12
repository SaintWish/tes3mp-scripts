--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSE
local discordRelay = {}
local config = require("custom/discordRelay/config")
local rpchatConfig

--Load rpchat config if rpchat is enabled.
if config.use_rpchat then
  rpchatConfig = require("custom/rpchat/config")
end

local https = require("ssl.https")
local json = require("dkjson") 
if doesModuleExist("cjson") then
    json = require("cjson")
    json.encode_sparse_array(true)
    json.encode_invalid_numbers("null")
    json.encode_empty_table_as_object(false)
    json.decode_null_as_lightuserdata(false)
end

local function GetPlayerName(pid)
  local accountName = Players[pid].name

  if config.use_tes3mp_getName then
    accountName = tes3mp.GetName(pid)
  end

  if config.use_rpchat and Players[pid].data.customVariables.rpchat then
    return Players[pid].data.customVariables.rpchat.name.."("..accountName..")"
  end
  
  return accountName
end

function discordRelay.Log(logType, message, ...)
	local message = string.format(message, ...)

	if logType == "normal" or logType == "info" then
		message = "[DISCORDRELAY]: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "error" then
		message = "[DISCORDRELAY]ERR: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "warning" then
		message = "[DISCORDRELAY]WARN: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "notice" then
		message = "[DISCORDRELAY]NOTE: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "debug" then
		if config.debug then
			message = "[DISCORDRELAY]DBG: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		end
	end
end

function discordRelay.DiscordCheckMessage(code)
  if not (code == 204) then
    discordRelay.Log("error", "Failed to send message, Responce was %s", code)
    return false
  else
    return true
  end
end

function discordRelay.DiscordSendMessage(type, sender, message, ...)
  local message = string.format(message, ...)
  local prefix

  if config.discord.webhook_url == "" then
    return
  end

  if message == "" then
    return
  end

  if type == "ooc" then
    prefix = "**(OOC)**"
    message = message:gsub("//", "")
  elseif type == "looc" then
    prefix = "**(LOOC)**"
    message = message:gsub("///", "")
  elseif type == "pm" then
    prefix = "**(PM)**"
  elseif type == "con" then
    prefix = "**(CONNECTION)**"
  elseif type == "sys" then
    prefix = "**(SYSTEM)**"
  end

  if config.discord.usePlayerName == false then
    message = sender..": "..message
  end
  
  message = prefix.." "..message
  local t = {
      ["content"] = tostring(message),
      ["username"] = tostring(sender)
  }
  local data = json.encode(t)
  local response_body = {}
  local res, code, responce_headers, status = https.request{
    url = config.discord.webhook_url,
    method = "POST",
    protocol = "tlsv1_2",
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = string.len(data)
    },
    source = ltn12.source.string(data),
    sink = ltn12.sink.table(response_body)
  }

  if discordRelay.DiscordCheckMessage(code) == true then
    discordRelay.Log("normal", "Message sent successfully")
  else
    discordRelay.Log("error", "Message failed to send")
    discordRelay.Log("normal", "\n %s", data)
  end
end

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
  if config.send_ping_on_startup then
    discordRelay.DiscordSendMessage("sys", config.discord.botUsername, "Pong!")

    if discordRelay.DiscordCheckMessage(code) == true then
      discordRelay.Log("normal", "Pinged Discord server successfully")
    else
      return false
    end
  end
  
  --discordRelay.DiscordSendMessage("sys", config.discord.botUsername, "Server has started up.")
end)

customEventHooks.registerValidator("OnPlayerSendMessage", function(eventStatus, pid, message)
  local playerName = GetPlayerName(pid)
  local botName = playerName
  local message = message
  local type = "sys"

  if message:sub(1, 3) == "///" then
    type = "looc"
  elseif message:sub(1, 2) == "//" then
    if rpchatConfig.toggleOOC == false and Players[pid].data.settings.staffRank <= 0 then
      return
    end

    type = "ooc"
  else
    return
  end

  if config.discord.usePlayerName == false then
    botName = config.discord.botUsername
  end

  discordRelay.DiscordSendMessage(type, botName, "%s: %s", playerName, message)
end)

customEventHooks.registerValidator("OnPlayerDisconnect", function(eventStatus, pid)
  local playerName = logicHandler.GetChatName(pid)
  local botName = config.discord.botUsername

  discordRelay.DiscordSendMessage("con", botName, "Player ``%s`` has left the server.", playerName)
end)

customEventHooks.registerHandler("OnPlayerFinishLogin", function(eventStatus, pid)
  local playerName = logicHandler.GetChatName(pid)
  local botName = config.discord.botUsername

  discordRelay.DiscordSendMessage("con", botName, "Player ``%s`` has logged into the server.", playerName)
end)

customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
  local playerName = logicHandler.GetChatName(pid)
  local botName = config.discord.botUsername

  discordRelay.DiscordSendMessage("con", botName, "Player ``%s`` has finished creating their character.", playerName)
end)