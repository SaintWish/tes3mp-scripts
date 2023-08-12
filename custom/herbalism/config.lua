local config = {}

config.enabled = true

config.debug = true

config.saveFile = "herbalism.json"

config.growthDays = 2 --How many in game days it takes for the plant to respawn, tracked to the hour. Decimal numbers will not work
config.plantList = {
  ["flora_ash_yam_"] = {["name"] = "Ash Yam", ["ingredient"] = "ingred_ash_yam_01", ["count"] = 1, ["chance"] = 2/10},
  ["flora_bittergreen_"] = {["name"] = "Bittergreen Petal", ["ingredient"] = "ingred_bittergreen_petals_01", ["count"] = 2, ["chance"] = 2/10},
  ["flora_black_anther_"] = {["name"] = "Black Anther", ["ingredient"] = "ingred_black_anther_01", ["count"] = 2, ["chance"] = 2/10},
  ["flora_black_lichen_"] = {["name"] = "Black Lichen", ["ingredient"] = "ingred_black_lichen_01", ["count"] = 1, ["chance"] = 3/10},
  ["cavern_spore00"] = {["name"] = "Bloat", ["ingredient"] = "ingred_bloat_01", ["count"] = 1, ["chance"] = 3/10},
  ["flora_bc_shelffungus_0[12]"] = {["name"] = "Bungler's Bane", ["ingredient"] = "ingred_bc_bungler", ["count"] = 1, ["chance"] = 1/10},
  ["flora_bc_shelffungus_0[34]"] = {["name"] = "Hypha Facia", ["ingredient"] = "ingred_bc_hypha_facia", ["count"] = 1, ["chance"] = 1/10},
  ["flora_chokeweed_02"] = {["name"] = "Chokeweed", ["ingredient"] = "ingred_chokeweed_01", ["count"] = 1, ["chance"] = 1/10},
  ["flora_comberry_01"] = {["name"] = "Comberry", ["ingredient"] = "ingred_comberry_01", ["count"] = 1, ["chance"] = 1/10},
  ["flora_bc_podplant_0[12]"] = {["name"] = "Ampoule Pod", ["ingredient"] = "ingred_bc_ampoule_pod", ["count"] = 1, ["chance"] = 2/10},
  ["flora_bc_podplant_0[34]"] = {["name"] = "Coda Flower", ["ingredient"] = "ingred_bc_coda_flower", ["count"] = 1, ["chance"] = 2.5/10},
  ["flora_corkbulb"] = {["name"] = "Corkbulb Root", ["ingredient"] = "ingred_corkbulb_root_01", ["count"] = 1, ["chance"] = 2/10},
  ["flora_fire_fern_"] = {["name"] = "Fire Petal", ["ingredient"] = "ingred_fire_petal_01", ["count"] = 1, ["chance"] = 2/10},
  ["flora_gold_kanet_uni"] = {["name"] = "Roland's Tear", ["ingredient"] = "ingred_gold_kanet_unique", ["count"] = 3, ["chance"] = 0},
  ["flora_gold_kanet_"] = {["name"] = "Gold Kanet", ["ingredient"] = "ingred_gold_kanet_01", ["count"] = 1, ["chance"] = 2/10},
  ["flora_sedge_01"] = {["name"] = "Golden Sedge Flower", ["ingredient"] = "ingred_golden_sedge_01", ["count"] = 1, ["chance"] = 3/10},
  ["flora_green_lichen_"] = {["name"] = "Green Lichen", ["ingredient"] = "ingred_green_lichen_01", ["count"] = 1, ["chance"] = 2/10},
  ["flora_hackle"] = {["name"] = "Hackle-Lo Leaf", ["ingredient"] = "ingred_hackle-lo_leaf_01", ["count"] = 1, ["chance"] = 2.5/10},
  ["flora_heather_01"] = {["name"] = "Heather", ["ingredient"] = "ingred_heather_01", ["count"] = 2, ["chance"] = 1/10},
  ["flora_plant_01"] = {["name"] = "Horn Lily Bulb", ["ingredient"] = "ingred_horn_lily_bulb_01", ["count"] = 2, ["chance"] = 3/10},
  ["flora_kreshweed_"] = {["name"] = "Kresh Fiber", ["ingredient"] = "ingred_kresh_fiber_01", ["count"] = 1, ["chance"] = 2/10},
  ["egg_kwama00"] = {["name"] = "Large Kwama Egg", ["ingredient"] = "food_kwama_egg_02", ["count"] = 1, ["chance"] = 0},
  ["flora_bc_mushroom_0[12345]"] = {["name"] = "Luminous Russula", ["ingredient"] = "ingred_russula_01", ["count"] = 2, ["chance"] = 1/10},
  ["flora_bc_mushroom_0[678]"] = {["name"] = "Violet Coprinus", ["ingredient"] = "ingred_coprinus_01", ["count"] = 2, ["chance"] = 1/10},
  ["flora_marshmerrow_"] = {["name"] = "Marshmerrow", ["ingredient"] = "ingred_marshmerrow_01", ["count"] = 1, ["chance"] = 1/10},
  ["flora_plant_04"] = {["name"] = "Meadow Rye", ["ingredient"] = "ingred_meadow_rye_01", ["count"] = 2, ["chance"] = 0},
  ["flora_muckspunge_"] = {["name"] = "Muck", ["ingredient"] = "ingred_muck_01", ["count"] = 1, ["chance"] = 2/10},
  ["flora_plant_02"] = {["name"] = "Nirthfly Stalk", ["ingredient"] = "ingred_nirthfly_stalks_01", ["count"] = 2, ["chance"] = 3/10},
  ["flora_sedge_02"] = {["name"] = "Noble Sedge Flower", ["ingredient"] = "ingred_noble_sedge_01", ["count"] = 1, ["chance"] = 3/10},
  ["flora_red_lichen_"] = {["name"] = "Red Lichen", ["ingredient"] = "ingred_red_lichen_01", ["count"] = 1, ["chance"] = 2/10},
  ["flora_roobrush_"] = {["name"] = "Roobrush", ["ingredient"] = "ingred_roobrush_01", ["count"] = 1, ["chance"] = 1/10},
  ["flora_rm_scathecraw_"] = {["name"] = "Scathecraw", ["ingredient"] = "ingred_scathecraw_01", ["count"] = 1, ["chance"] = 1/10},
  ["flora_saltrice_"] = {["name"] = "Saltrice", ["ingredient"] = "ingred_saltrice_01", ["count"] = 1, ["chance"] = 1/10},
  ["flora_plant_07"] = {["name"] = "Scrib Cabbage", ["ingredient"] = "ingred_scrib_cabbage_01", ["count"] = 2, ["chance"] = 3/10},
  ["flora_bc_fern_01"] = {["name"] = "Spore Pod", ["ingredient"] = "ingred_bc_spore_pod", ["count"] = 3, ["chance"] = 0},
  ["flora_bc_fern_04_chuck"] = {["name"] = "Meteor Slime", ["ingredient"] = "ingred_scrib_jelly_02", ["count"] = 1, ["chance"] = 0},
  ["flora_plant_08"] = {["name"] = "Lloramor Spine", ["ingredient"] = "ingred_lloramor_spines_01", ["count"] = 2, ["chance"] = 0},
  ["flora_stoneflower_"] = {["name"] = "Stoneflower Petal", ["ingredient"] = "ingred_stoneflower_petals_01", ["count"] = 1, ["chance"] = 1/10},
  ["flora_plant_0[56]"] = {["name"] = "Sweetpulp", ["ingredient"] = "ingred_sweetpulp_01", ["count"] = 2, ["chance"] = 3/10},
  ["flora_plant_03"] = {["name"] = "Timsa-Come-By Flower", ["ingredient"] = "ingred_timsa-come-by_01", ["count"] = 2, ["chance"] = 3/10},
  ["tramaroot_"] = {["name"] = "Trama Root", ["ingredient"] = "ingred_trama_root_01", ["count"] = 3, ["chance"] = 2/10},
  ["contain_trama_shrub_"] = {["name"] = "Trama Root", ["ingredient"] = "ingred_trama_root_01", ["count"] = 3, ["chance"] = 2/10},
  ["flora_wickwheat_"] = {["name"] = "Wickwheat", ["ingredient"] = "ingred_wickwheat_01", ["count"] = 1, ["chance"] = 1/10},
  ["flora_willow_flower_"] = {["name"] = "Willow Anther", ["ingredient"] = "ingred_willow_anther_01", ["count"] = 1, ["chance"] = 1.5/10},
  ["flora_bm_belladonna_0[^3]"] = {["name"] = "Unripened Belladonna Berries", ["ingredient"] = "ingred_belladonna_01", ["count"] = 1, ["chance"] = 0},
  ["flora_bm_belladonna_03"] = {["name"] = "Ripened Belladonna Berries", ["ingredient"] = "ingred_belladonna_02", ["count"] = 1, ["chance"] = 2/10},
  ["flora_bm_holly_"] = {["name"] = "Holly Berries", ["ingredient"] = "ingred_holly_01", ["count"] = 1, ["chance"] = 2/10},
  ["flora_bm_wolfsbane_01"] = {["name"] = "Wolfsbane Petal", ["ingredient"] = "ingred_wolfsbane_01", ["count"] = 1, ["chance"] = 0},
}

return config
