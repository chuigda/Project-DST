local assets = {
	Asset( "ANIM", "anim/wx78.zip" ),
	Asset( "ANIM", "anim/ghost_wx78_build.zip" ),
}

local skins = {
	normal_skin = "wx78",
	ghost_skin = "ghost_wx78_build",
}

return CreatePrefabSkin("wgc0310_none", {
	base_prefab = "wx78",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"WGC0310", "CHARACTER", "BASE"},
	build_name_override = "wx78",
	rarity = "Character",
})
