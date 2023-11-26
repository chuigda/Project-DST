local WGCElectricityBadge = require("widgets/wgc_electricity_badge")

PrefabFiles = {
   "wgc0310",
   "wgc0310_none",
   "wgc0310_gear"
}

Assets = {
   -- for characters
   Asset("IMAGE", "images/saveslot_portraits/wgc0310.tex"),
   Asset("ATLAS", "images/saveslot_portraits/wgc0310.xml"),

   Asset("IMAGE", "images/selectscreen_portraits/wgc0310.tex"),
   Asset("ATLAS", "images/selectscreen_portraits/wgc0310.xml"),

   Asset("IMAGE", "images/selectscreen_portraits/wgc0310_silho.tex"),
   Asset("ATLAS", "images/selectscreen_portraits/wgc0310_silho.xml"),

   Asset("IMAGE", "bigportraits/wgc0310.tex"),
   Asset("ATLAS", "bigportraits/wgc0310.xml"),

   Asset("IMAGE", "images/map_icons/wgc0310.tex"),
   Asset("ATLAS", "images/map_icons/wgc0310.xml"),

   Asset("IMAGE", "images/avatars/avatar_wgc0310.tex"),
   Asset("ATLAS", "images/avatars/avatar_wgc0310.xml"),

   Asset("IMAGE", "images/avatars/avatar_ghost_wgc0310.tex"),
   Asset("ATLAS", "images/avatars/avatar_ghost_wgc0310.xml"),

   Asset("IMAGE", "images/avatars/self_inspect_wgc0310.tex"),
   Asset("ATLAS", "images/avatars/self_inspect_wgc0310.xml"),

   Asset("IMAGE", "images/names_wgc0310.tex"),
   Asset("ATLAS", "images/names_wgc0310.xml"),

   Asset("IMAGE", "images/names_gold_wgc0310.tex"),
   Asset("ATLAS", "images/names_gold_wgc0310.xml"),

   -- for items
   Asset("ATLAS", "images/inventoryimages/wgc0310_gear.xml"),
   Asset("IMAGE", "images/inventoryimages/wgc0310_gear.tex"),
}

AddMinimapAtlas("images/map_icons/wgc0310.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

STRINGS.CHARACTER_TITLES.wgc0310 = "有感情的机器人"
STRINGS.CHARACTER_NAMES.wgc0310 = "WGC0310"
STRINGS.CHARACTER_DESCRIPTIONS.wgc0310 = "* 不受 SAN 值影响\n* 需要电能来维持运作"
STRINGS.CHARACTER_QUOTES.wgc0310 = "如果还能找到你，就让风儿告诉你，在那遥远的某地，有个人在想念着你"
STRINGS.CHARACTER_SURVIVABILITY.wgc0310 = "严峻"

STRINGS.CHARACTERS.WGC0310 = require "speech_wx78" -- TODO 暂时先用 WX78 的，虽然跟它 WGC0310 完全是两路人

STRINGS.NAMES.WGC0310 = "WGC-0310"
STRINGS.SKIN_NAMES.wgc0310_none = "WGC-0310"

local skin_modes = {
   {
      type = "ghost_skin",
      anim_bank = "ghost",
      idle_anim = "idle",
      scale = 0.75,
      offset = { 0, -25 }
   }
}

AddModCharacter("wgc0310", "NEUTRAL", skin_modes)

AddClassPostConstruct("widgets/statusdisplays", function (self, owner)
   local ThePlayer = owner
   if ThePlayer.prefab ~= "wgc0310" then
      return
   end

   self.brain:Hide()
   self.brain.Show = function ()
      self.brain:Hide()
   end

   self.wgc_electricity_badge = self:AddChild(WGCElectricityBadge(owner))
   -- use the position of original sanity badge
   self.wgc_electricity_badge:SetPosition(self.column3, -40, 0)

   -- listen to electricity delta event
   owner:ListenForEvent("wgc_electricity_delta", function (inst, data)
      self.wgc_electricity_badge:SetPercent(data.newpercent)
      self.wgc_electricity_badge.num:SetString(math.floor(data.current))
   end)
end)

STRINGS.NAMES.WGC0310_GEAR = "WGC-0310 的齿轮"
STRINGS.RECIPE_DESC.WGC0310_GEAR = "可以恢复机器人的生命值，但是无法用于维修或者合成"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WGC0310_GEAR = "齿轮的优秀人造替代品，可惜不能 100% 替代"

AddCharacterRecipe("wgc0310_gear", {
   Ingredient("goldnugget", 1),
   Ingredient("nitre", 1),
}, TECH.NONE, {
   builder_tag = "wgc0310",
   numtogive = 2,
   atlas = "images/inventoryimages/wgc0310_gear.xml"
}, { "TOOLS" })
