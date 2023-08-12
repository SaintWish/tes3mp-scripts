--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSE
local config = require("custom/cellReset/config")
local cellReset = {}
cellReset.whitelist = {}
cellReset.cellDir = tes3mp.GetModDir().."/cell/"

function cellReset.Log(logType, message, ...)
	local message = string.format(message, ...)

	if logType == nil or logType == "normal" then
		message = "[CELLRESET]: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "error" then
		message = "[CELLRESET]ERR: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "warning" then
		message = "[CELLRESET]WARN: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "notice" then
		message = "[CELLRESET]NOTE: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "debug" then
		if config.debug then
			message = "[CELLRESET]DBG: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		end

	else
		cellReset.Log("error", "INVALID LOG CALL")
		message = "[CELLRESET](invalid): " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	end
end

function cellReset.SystemMessage(pid, message, ...)
  local msg = string.format(message, ...)
  local fMsg = config.prefix .. ": " .. color.White .. msg .. "\n"

  tes3mp.SendMessage(pid, fMsg, false)
end

function cellReset.LoadWhitelist()
  cellReset.whitelist = jsonInterface.load(config.whitelist)
end

function cellReset.SaveWhitelist()
  jsonInterface.writeToFile(config.whitelist, cellReset.whitelist)
end

--Check if cell is loaded in player memory.
--Returns boolean
function cellReset.IsCellLoaded(cell)
  
end

--Check if cell is excluded from being removed.
--Returns boolean
function cellReset.IsCellWhitelisted(cellDesc)
  if cellReset.whitelist[cellDesc] ~= nil then
    return true
  end
  
  return false
end

--Check time if cell should be reset now or not.
--Return: boolean, true = yes; false = no
function cellReset.CheckTime(cell)
	local cellDesc = cell.entry.description
	
	if config.resetTime <= 0 then
		return false
	end
	
	if not cell.data.lastReset then
		cell.data.lastReset = os.time()
		cellReset.Log("debug", "Creating lastReset entry for %s", cellDesc)
		cell:SaveToDrive()
		return false
	end
	
	--Enough time hasn't passed between resets
	if os.time() - cell.data.lastReset < scriptConfig.resetTime then
		cellReset.Log("debug", "Not enough time has passed in cell %s to require cell reset", cellDesc)
		return false
	end
end

function cellReset.DoReset(cell)
	cell:ClearRecordLinks()
	
	-- for k,v in pair(cell.data.recordLinks) then
	-- 	local recordStore = RecordStores[k]
	-- 	for ids,_ in pairs(v) do
	-- 		recordStore:RemoveLinkToCell(ids, cell)
	-- 	end
	-- end
end

--Resets the cell safely. Performs checks if cell is safe to be removed before removing.
function cellReset.TryCellReset(cellDesc)
	--Don't reset the cell if it's whitelisted.
	if cellReset.IsCellWhitelisted(cellDesc) then return end
	
  local cell = Cell(cellDesc)
  local cellFile = cellReset.cellDir..cell.entryFile
	
	--Load cell file.
	if tes3mp.DoesFileExist(cellFile) then
		cell:LoadFromDrive()
	end
	
	--Don't reset if cell has people in it.
	if cell:GetVisitorCount() > 0 then return end
	
	--Don't reset if it's not time to.
	if cellReset.CheckTime(cell) == false then return end
		
	cellReset.DoReset(cell)
	
	cellReset.Log("debug", "Reset cell %s", cellDesc)
end

--Force removes a cell. This is bad don't do it kthx.
function cellReset.ForceCellReset(cellDesc)
	--Don't reset the cell if it's whitelisted.
	if cellReset.IsCellWhitelisted(cellDesc) then return end
	
	--Load cell file.
	if tes3mp.DoesFileExist(cellFile) then
		cell:LoadFromDrive()
	end
	
	cellReset.DoReset(cell)
	
	cellReset.Log("debug", "Force reset cell %s", cellDesc)
end

customEventHooks.registerHandler("OnCellDeletion", function(eventStatus, cellDesc)
	cellReset.TryCellReset(cellDesc)
end)

customCommandHooks.registerCommand("forcereset", function(pid, cmd)
	--nested if statements are fun!
	if cmd[2] ~= nil then
		if cmd[3] ~= nil then
			if Players[pid].data.settings.staffRank >= 2 then
				cellReset.ForceCellReset(cmd[3])
				cellReset.SystemMessage(pid, "You have reset cell %s", cmd[3])
			end
		end
	end
end)

return cellReset