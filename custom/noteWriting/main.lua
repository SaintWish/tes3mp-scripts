--Created by Saint Wish/Wishbone - https://github.com/SaintWish
--Released under GPL 2.0 license - https://github.com/SaintWish/tes3mp-scripts/blob/master/LICENSE
local config = require("custom/noteWriting/config")

local noteWriting = {}
local noteObj = {}

----------------
-- Healper functions
----------------
local function createBookRecord(pid, noteID, recordTable)
	local recordStore = RecordStores["book"]

	recordStore.data.permanentRecords[noteID] = recordTable
	recordStore:Save()
  tes3mp.ClearRecords()
  tes3mp.SetRecordType(enumerations.recordType[string.upper("book")])
	packetBuilder.AddBookRecord(noteID, recordTable)
	tes3mp.SendRecordDynamic(pid, true)
end

--shortcut function for cleaner code.
local function invContainsItem(inv, item)
  return inventoryHelper.containsItem(inv, item)
end

local function isMod(pid)
  if(Players[pid].data.settings.staffRank >= 1)then
		return true
	else
		return false
	end
end

----------------
-- Object creation
----------------
local noteMeta = {}
noteMeta.__index = noteMeta
function noteWriting.createObj(pid, type)
  noteWriting.log("Creating note object for pid "..pid, "debug")

  local NOTE = {}
  setmetatable(NOTE, noteMeta)

  NOTE.ownerPID = pid
  NOTE.ownerName = Players[pid].name
  NOTE.type = type

  NOTE.data = {}
  NOTE.data.id = nil
  NOTE.data.name = "Simple Note"
  NOTE.data.author = "Unknown"
  NOTE.data.icon = "m\\Tx_note_02.tga"
  NOTE.data.model = "m\\Text_Note_02.nif"
  NOTE.data.weight = 0.2
  NOTE.data.value = 1
  NOTE.data.text = "Blank"

  return NOTE
end

----------------
-- Note object functions
----------------
function noteMeta:setID()
  local counter = nil
  local cType = ""
  local prefix

  noteWriting.log("Generating note writing ID", "debug")
  if self.type == "note" then
    counter = WorldInstance.data.customVariables.noteCounter
    prefix = "pnote_"
    cType = "noteCounter"
  elseif self.type == "book" then
    counter = WorldInstance.data.customVariables.bookCounter
    prefix = "pbook_"
    cType = "bookCounter"
  elseif self.type == "scroll" then
    counter = WorldInstance.data.customVariables.scrollCounter
    prefix = "pscroll_"
    cType = "scrollCounter"
  else
    noteWriting.log("Invalid note type of "..self.type, "error")
  end

  if counter == nil then
    counter = 0
  else
    counter = counter + 1
  end
	WorldInstance.data.customVariables[cType] = counter

  noteWriting.log("Generated note id of: "..prefix..counter, "debug")
  self.data.id = prefix..counter
end

function noteMeta:setAuthor()
  local rpchat = Players[self.ownerPID].data.customVariables.rpchat

  if rpchat and config.useRPName then
    self.data.author = rpchat.name
  else
    self.data.author = self.ownerName
  end

  noteWriting.log("Setting note object author  "..self.data.author, "debug")
end

function noteMeta:removeMats()
  if not config.needPaperMats or not config.removeItem then
    return
  end

  if noteWriting.PlyIsValid(self.ownerPID, self.ownerName) then
    noteWriting.log("Removing materials for type  "..self.type, "debug")
    if type == "note" then
      inventoryHelper.removeItem(Players[self.ownerPID].data.inventory, config.noteItem, 1)
    elseif type == "book" then
      inventoryHelper.removeItem(Players[self.ownerPID].data.inventory, config.bookItem, 1)
    elseif type == "scroll" then
      inventoryHelper.removeItem(Players[self.ownerPID].data.inventory, config.scrollItem, 1)
    end
  end
end

function noteMeta:setName(name)
  local newName = name[2]
  local i

  if #name > 2 then
    for i=3, #name, 1 do
      newName = newName.." "..name[i]
    end
  end

  noteWriting.log("Setting note object name  "..newName, "debug")
  self.data.name = newName
end

function noteMeta:setText(txt)
  self.data.text = txt
end

function noteMeta:openGUI()
  noteWriting.log("Opening GUI for player "..self.ownerPID, "debug")
  if noteWriting.PlyIsValid(self.ownerPID, self.ownerName) then
    if self.type == "note" then
      tes3mp.InputDialog(self.ownerPID, config.gui.noteID, "Enter what you would like your note to say:", "")
    elseif self.type == "book" then
      tes3mp.InputDialog(self.ownerPID, config.gui.bookID, "Enter what you would like your book to say:", "")
    elseif self.type == "scroll" then
      tes3mp.InputDialog(self.ownerPID, config.gui.scrollID, "Enter what you would like your scroll to say:", "")
    else
      noteWriting.log("Invalid note type of "..self.type, "error")
    end
  end
end

function noteMeta:createItem()
  noteWriting.log("Trying to create note item of type "..self.type, "debug")

  if self.type == "note" then
		noteWriting.log("Creating note item of type note", "debug")
    self.data.icon = config.res.noteIcon
    self.data.model = config.res.noteModel
    self.data.weight = 0.1
    self.data.value = 1
  elseif self.type == "book" then
		noteWriting.log("Creating note item of type book", "debug")
    self.data.icon = config.res.bookIcon
    self.data.model = config.res.bookModel
    self.data.weight = 0.3
    self.data.value = 2
  elseif self.type == "scroll" then
		noteWriting.log("Creating note item of type scroll", "debug")
    self.data.icon = config.res.scrollIcon
    self.data.model = config.res.scrollModel
    self.data.weight = 0.1
    self.data.value = 1
  end

  local noteText = "<DIV ALIGN=\"CENTER\">"..tostring(self.data.text).."<p>"
  self:setID()
  self:setAuthor()

  if noteWriting.PlyIsValid(self.ownerPID, self.ownerName) then
    local recordTbl = {
      ["weight"] = self.data.weight,
      ["icon"] = self.data.icon,
      ["skillId"] = "-1",
      ["model"] = self.data.model,
      ["text"] = noteText,
      ["value"] = self.data.value,
      ["scrollState"] = true,
      ["name"] = self.data.name
    }

    noteWriting.log("Creating book record for "..self.data.id, "debug")
    createBookRecord(self.ownerPID, self.data.id, recordTbl)

    noteWriting.log("Saving world instance by "..self.data.id, "debug")
    WorldInstance:Save()
  end

  self:giveItem({refId = self.data.id, count = 1, charge = -1, enchantmentCharge = -1, soul = ""})
  self:removeMats()
end

function noteMeta:giveItem(itemStruct)
  if noteWriting.PlyIsValid(self.ownerPID, self.ownerName) then
    noteWriting.log("Giving item of id "..self.data.id.." to player "..self.ownerPID, "debug")

    table.insert(Players[self.ownerPID].data.inventory, itemStruct)
    Players[self.ownerPID]:LoadInventory()
    Players[self.ownerPID]:LoadEquipment()
    Players[self.ownerPID]:Save()
  end
end

----------------
-- Script functions
----------------
function noteWriting.log(message, logType)
  if logType == nil or logType == "normal" then
    message = "[NOTE-WRITING]: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "error" then
    message = "[NOTE-WRITING]ERR: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "warning" then
    message = "[NOTE-WRITING]WARN: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "notice" then
    message = "[NOTE-WRITING]NOTE: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "debug" and config.debug then
    message = "[NOTE-WRITING]DBG: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)

  else
    noteWriting.log("INVALID LOG CALL", "error")
    message = "[NOTE-WRITING](invalid): " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  end
end

--Make sure the player is the same one, otherwise don't pass
function noteWriting.PlyIsValid(pid, name)
  noteWriting.log("Checking if ply is valid with name: "..name.."("..pid..")", "debug")
  if Players[pid] then
    if Players[pid].name == name then
      noteWriting.log("Ply is valid", "debug")
      return true
    else
      noteWriting.log("Ply is invalid 1", "debug")
      return false
    end

  else
    noteWriting.log("Ply is invalid 2", "debug")
    return false
  end
end

function noteWriting.systemMessage(pid, message)
  message = config.prefixColor .. config.prefix ..": " .. config.msgColor .. message .. "\n"
  tes3mp.SendMessage(pid, message, false)
end

function noteWriting.checkInkMats(pid)
  if not config.needNeedInkMats then
    return true
  end

  local inv = Players[pid].data.inventory
  if invContainsItem(inv, config.quillItem) and invContainsItem(inv, config.inkItem) then
    return true
  end

  return false
end

function noteWriting.checkNoteMats(pid)
  if not config.needPaperMats then
    return true
  end

  local inv = Players[pid].data.inventory
  if invContainsItem(inv, config.noteItem) then
    return true
  end

  return false
end

function noteWriting.checkBookMats(pid)
  if not config.needPaperMats then
    return true
  end

  local inv = Players[pid].data.inventory
  if invContainsItem(inv, config.bookItem) then
    return true
  end

  return false
end

function noteWriting.checkScrollMats(pid)
  if not config.needPaperMats then
    return true
  end

  local inv = Players[pid].data.inventory
  if invContainsItem(inv, config.scrollItem) then
    return true
  end

  return false
end

function noteWriting.makeCopy(pid, item)
  local structuredItem = {refId = item, count = 1, charge = -1}
  table.insert(Players[pid].data.inventory, structuredItem)
end

function noteWriting.guiAction(eventStatus, pid, guiID, data)
  if data == nil then
    return
  end

  if guiID == config.gui.noteID then
    noteObj[pid]:setText(data)
    noteObj[pid]:createItem()
  end

  if guiID == config.gui.bookID then
    noteObj[pid]:setText(data)
    noteObj[pid]:createItem()
  end

  if guiID == config.gui.scrollID then
    noteObj[pid]:setText(data)
    noteObj[pid]:createItem()
  end

  noteObj[pid] = nil
end

----------------
-- Hooks
----------------
customEventHooks.registerHandler("OnPlayerDisconnect", function(eventStatus, pid)
  --Destroy any left over note objects.
  noteObj[pid] = nil
end)

customEventHooks.registerHandler("OnGUIAction", noteWriting.guiAction)

customCommandHooks.registerCommand("writenote", function(pid, cmd)
  if cmd[2] ~= nil then
    if noteWriting.checkNoteMats(pid) and noteWriting.checkInkMats(pid) then
      noteObj[pid] = noteWriting.createObj(pid, "note")
      noteObj[pid]:setName(cmd)
      noteObj[pid]:openGUI()
    else
      noteWriting.systemMessage(pid, "You lack the materials to make a note")
    end
  else
    noteWriting.systemMessage(pid, "You need to name your note! /writenote name here")
  end
end)

customCommandHooks.registerCommand("writebook", function(pid, cmd)
  if cmd[2] ~= nil then
    if noteWriting.checkBookMats(pid) and noteWriting.checkInkMats(pid) then
      noteObj[pid] = noteWriting.createObj(pid, "book")
      noteObj[pid]:setName(cmd)
      noteObj[pid]:openGUI()
    else
      noteWriting.systemMessage(pid, "You lack the materials to make a book.")
    end
  else
    noteWriting.systemMessage(pid, "You need to name your book! /writebook name here")
  end
end)

customCommandHooks.registerCommand("writescroll", function(pid, cmd)
  if cmd[2] ~= nil then
    if noteWriting.checkScrollMats(pid) and noteWriting.checkInkMats(pid) then
      noteObj[pid] = noteWriting.createObj(pid, "scroll")
      noteObj[pid]:setName(cmd)
      noteObj[pid]:openGUI()
    else
      noteWriting.systemMessage(pid, "You lack the materials to make a scroll.")
    end
  else
    noteWriting.systemMessage(pid, "You need to name your scroll! /writescroll name here")
  end
end)

customCommandHooks.registerCommand("makecopy", function(pid, cmd)
  if not isMod(pid) then
    return
  end

  local inv = Players[pid].data.inventory
  if cmd[2] ~= nil then
    if invContainsItem(inv, cmd[2]) then
      noteWriting.makeCopy(cmd[2])
    else
      noteWriting.systemMessage(pid, "You can't copy that item or that item doesn't exist!")
    end
  else
    noteWriting.systemMessage(pid, "You didn't give the item ID of the item you want to copy!")
  end
end)

return noteWriting
