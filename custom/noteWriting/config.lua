--Created by Wishbone https://github.com/SaintWish for Dawn of Resdayn RP
--All rights reserved.
local config = {}

config.debug = true

config.useRPName = true --Made to work with rpchat by Nac

config.prefix = "[noteWriting]"
config.prefixColor = color.Cyan
config.msgColor = color.LightCyan

config.needNeedInkMats = true
--config.quillItem = "misc_quill"
config.quillItem = "aa_quill_s" -- Edited to use Hold It Items, edit out and uncomment above for vanilla/TR items
config.inkItem = "misc_inkwell"

config.needPaperMats = true
config.noteItem = "sc_paper plain"
--config.bookItem = "tr_m1_bk_plain"
config.bookItem = "aa_folio_s" -- Edited to use Hold It Items, edit out and uncomment above for vanilla/TR items
--config.scrollItem = "t_sc_blank"
config.scrollItem = "aa_scroll_s" -- Edited to use Hold It Items, edit out and uncomment above for vanilla/TR items
config.removeItem = true

--Below are what icons and models the items are supposed to use when created.
config.res = {}
config.res.noteIcon = "m\\Tx_Note_02.tga"
config.res.noteModel = "m\\Text_Note_02.nif"
config.res.bookIcon = "m\\Tx_Octavo_04.tga"
config.res.bookModel = "m\\Text_Octavo_04.nif"
config.res.scrollIcon = "m\\Tx_Scroll_01.tga"
config.res.scrollModel = "m\\Text_Scroll_01.nif"

--You shouldn't have to modify anything below...
config.gui = {}
config.gui.noteID = 41300
config.gui.bookID = 41301
config.gui.scrollID = 41302

return config
