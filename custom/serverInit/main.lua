--Created by Saint Wish/Wishbone - https://github.com/SaintWish
--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSE
local config = require("custom/serverInit/config")

local serverInit = {}

local function randomString(length)
  math.randomseed(os.time())
	local res = ""

	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end

	return res
end

function serverInit.loadScripts()
  local scripts = {}
  
  if config.loadScripts then
    scripts = jsonInterface.load("scripts.json")
    tableHelper.fixNumericalKeys(scripts, true)
    
    if scripts == nil then
      tes3mp.LogMessage(enumerations.log.WARN, "Error reading scripts.json.\n")
      tes3mp.StopServer(2)
      return
    end
  
    tes3mp.LogMessage(enumerations.log.INFO, "Start Custom Script Initialization")
    for index,script in ipairs(scripts) do
      for name,file in pairs(script) do
        require(file)
        tes3mp.LogMessage(enumerations.log.INFO, "Loaded script "..name)
      end
    end
    tes3mp.LogMessage(enumerations.log.INFO, "End Custom Script Initialization\n")
  
  else
    tes3mp.LogMessage(enumerations.log.INFO, "Custom script loading disabled.\n")
  end
end

function serverInit.messageCompiler(pid, message, colorOverride)
  if colorOverride == nil then
		Players[pid]:Message(color.Cyan .. "[SYSTEM]: " .. color.White .. message)
	else
		Players[pid]:Message(color.Cyan .. "[SYSTEM]: " .. color[colorOverride] .. message)
	end
end

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
  local startMsg = ""

	if config.testing then
		startMsg = "\n\n\n==[INITIALIZATION INFO]==\n" ..
			"DATE-TIME: " .. os.date("%c") .. "\n" ..
			"VERSION: " .. tes3mp.GetServerVersion() .. "\n" ..
			"==[*THIS SERVER IS INTENDED FOR TESTING AND SHOULD NOT BE CONFIGURED FOR PUBLIC ACCESS*]==\n"
    tes3mp.LogMessage(enumerations.log.INFO, startMsg)

		if not tes3mp.HasPassword() then
			local randomStr = randomString(5)
			tes3mp.SetServerPassword(randomStr)
			tes3mp.LogMessage(enumerations.log.INFO, "\n\n==[PASSWORD: " .. randomStr .. "]==\n")
		end

	else
		tes3mp.SetScriptErrorIgnoringState(true)

		startMsg = "\n\n==[INITIALIZATION INFO]==\n" ..
			"DATE-TIME: " .. os.date("%c") .. "\n" ..
			"VERSION: " .. tes3mp.GetServerVersion() .. "\n"
    tes3mp.LogMessage(enumerations.log.INFO, startMsg)
	end

	tes3mp.SetGameMode(config.gamemode)

  tes3mp.SetRuleString("website", config.website)
	tes3mp.SetRuleString("discord", config.discord)
	tes3mp.SetRuleString("espInstall", config.espInstall)

  serverInit.loadScripts()
end)

customEventHooks.registerHandler("OnPlayerFinishLogin", function(eventStatus, pid)
  if Players[pid].data.debugMode == nil then
    tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'debugMode', repairing now. ")
    Players[pid].data.debugMode = false
    tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
  end
  
  if Players[pid].data.debugFlags == nil then
    tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. " was missing key player data from 'debugFlags', repairing now. ")
    Players[pid].data.debugFlags = {
      haltTracking == false
    }
  
    tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(Players[pid].pid) .. "'s playerdata was repaired. ")
  end
  
  if not Players[pid].data.customVariables then
    Players[pid].data.customVariables = {}
  end
end)

customCommandHooks.registerCommand("debug", function(pid, args)
  if config.debugMode == true or Players[pid]:IsAdmin() then
    if args[2] ~= nil then
      if args[2] == "enable" then
        Players[pid].data.debugMode = true
        serverInit.messageCompiler(pid, "DEBUG MODE ENABLED.\n")
      elseif args[2] == "disable" then
        Players[pid].data.debugMode = false
        serverInit.messageCompiler(pid, "DEBUG MODE DISABLED..\n")
      end
  
    else
      serverInit.messageCompiler(pid, "INVALID DEBUG COMMAND/FLAG.\n")
    end
  
  else
    serverInit.messageCompiler(pid, "DEBUGMODE IS DISABLED.\n")
  end
end)

customCommandHooks.registerCommand("playercollision", function(pid, args)
  if Players[pid]:IsAdmin() then
    if args[2] == "false" then
      config.enablePlayerCollision = false
      serverInit.messageCompiler(pid, "Player collision has been disabled.\n")
    elseif args[2] == "true" then
      config.enablePlayerCollision = true
      serverInit.messageCompiler(pid, "Player collision has been enabled.\n")
    else
      serverInit.messageCompiler(pid, "Argument has to be true/false. (Player collision is set to "..tostring(config.enablePlayerCollision)..")\n")
    end
  end
end)

return serverInit