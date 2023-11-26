local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

-- Try making VSCode happy
if TUNING == nil then
    TUNING = {}
end

TUNING.WGC0310_HEALTH = 375
TUNING.WGC0310_HUNGER = 200
TUNING.WGC0310_SANITY = 200
TUNING.WGC0310_ABSORPTION_MODIFIER = 0.75
TUNING.WGC0310_ACCELERATION = 1.1

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WGC0310 = {}
local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WGC0310
end
local prefabs = FlattenTree(start_inv, true)

local function WGC0310_OnEat(inst, food)
    if food ~= nil and food.components.edible ~= nil then
        if food.components.edible.foodtype == FOODTYPE.GEARS then
            -- can heal by eating gears, 75 health per gear
            inst.components.health:DoDelta(75)
            inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
        end
    end
end

local function WGC0310_IsStarving(self)
    return false
end

local function WGC0310_OnStarveOverride(inst, dt)
    -- do nothing yet
    -- TODO: add several electric charge points on hunger drop
end

local function WGC0310_AttackConsumesElectricity(inst, data)
    if inst.components.wgc_electricity ~= nil then
        inst.components.wgc_electricity:DoDelta(-15, true)
    end
end

local function WGC0310_HungerBurn(inst)
    if inst.components.hunger ~= nil and inst.components.wgc_electricity ~= nil then
        if inst.components.wgc_electricity.current <= inst.components.wgc_electricity.max - 10 then
            -- if the electricity is not full, burn hunger to charge it
            inst.components.hunger:DoDelta(-1, true)
            inst.components.wgc_electricity:DoDelta(10, true)
        end
    end
end

local function common_postinit(inst)
    inst:AddTag("electricdamageimmune")
    inst:AddTag("soulless")
    inst.MiniMapEntity:SetIcon("wgc0310.tex")
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
    inst.soundsname = "wx78"

    -- this character uses electricity system specific to WGC0310
    inst:AddComponent("wgc_electricity")

    -- this character has quite high health and resistance to damage
    -- unfortunately, it cannot be healed by eating conventional food
    inst.components.health:SetMaxHealth(TUNING.WGC0310_HEALTH)
    inst.components.health.externalabsorbmodifiers:SetModifier(inst, TUNING.WGC0310_ABSORPTION_MODIFIER, "WGC0310_Absorption")
    inst.components.health.fire_damage_scale = 0
    inst.components.health.canheal = false

    inst.components.hunger:SetMax(TUNING.WGC0310_HUNGER)
    -- this character never really gets hungry, but it still has a (decaying) hunger bar
    inst.components.hunger.IsStarving = WGC0310_IsStarving
    inst.components.hunger:SetOverrideStarveFn(WGC0310_OnStarveOverride)
    -- bypass the default hunger decaying logic and implement our own system
    -- relevant with the electricity system
    inst.components.hunger:Pause()
    inst:DoPeriodicTask(2, WGC0310_HungerBurn)

    inst.components.sanity:SetMax(TUNING.WGC0310_SANITY)
    inst.components.sanity.ignore = true

    if inst.components.eater ~= nil then
        inst.components.eater:SetIgnoresSpoilage(true)
        inst.components.eater:SetCanEatGears()
        inst.components.eater:SetOnEatFn(WGC0310_OnEat)
        inst.components.eater:SetAbsorptionModifiers(0, 1, 0)
    end

    inst.components.combat.damagemultiplier = 2
    inst:ListenForEvent("onattackother", WGC0310_AttackConsumesElectricity)

    inst.Light:Enable(true)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(200 / 255, 150 / 255, 50 / 255)
    inst.Light:SetFalloff(.5)
    inst.Light:SetRadius(1)

    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "WGC0310_Acceleration", TUNING.WGC0310_ACCELERATION)
end

return MakePlayerCharacter("wgc0310", prefabs, assets, common_postinit, master_postinit, prefabs)
