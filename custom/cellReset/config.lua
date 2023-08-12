local config = {}

config.debug = true
config.resetTime = 259200 --The time in (real life) seconds that must've passed before a cell is attempted to be reset. 259200 seconds is 3 days. Set to -1 to disable automatic resetting
config.whitelist = "cellReset/whitelist.json"
config.prefix = "[CellReset]"

return config