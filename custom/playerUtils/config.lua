local config = {}

config.debug = true
config.prefixColor = color.Orange
config.msgColor = color.White

config.stuckCooldown = 180 --In seconds.

config.startItems = {
  {"gold_001", 200, -1},
  {"p_restore_magicka_c", 1, -1},
}

--Change the cell where the hub is and the x, y, z position for it.
config.hubCell = "DoR Hub"
config.hubPos = {5566.8,3095.8,12839.1}

return config
