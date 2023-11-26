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
-- actually not influenced by sanity, but still I'll set a value here
TUNING.WGC0310_SANITY = 200
TUNING.WGC0310_ABSORPTION_MODIFIER = 0.75
TUNING.WGC0310_ACCELERATION = 1.1
TUNING.WGC0310_ATTACK_MODIFIER = 1.5
TUNING.WGC0310_WORKEFFECTIVENESS_MODIFIER = 1.5

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WGC0310 = {
    "wgc0310_gear",
    "wgc0310_gear",
    "wgc0310_gear"
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WGC0310
end
local prefabs = FlattenTree(start_inv, true)

local function WGC0310_OnBecomePlayerCharacter(inst)
    inst.components.hunger:SetPercent(0.5)

    inst.components.wgc_electricity.current = 750
    inst.components.wgc_electricity:ForceUpdate()
end

local function WGC0310_OnBecomeGhost(inst)
    inst.components.wgc_electricity.current = 750
    inst.components.wgc_electricity:ForceUpdate()
end

local function WGC0310_OnSave(inst, data)
    if inst.components.wgc_electricity ~= nil then
        data.wgc_electricity = inst.components.wgc_electricity.current
    end
end

local function WGC0310_OnLoad(inst, data)
    inst:ListenForEvent("ms_respawnedfromghost", WGC0310_OnBecomePlayerCharacter)
    inst:ListenForEvent("ms_becameghost", WGC0310_OnBecomeGhost)

    if data ~= nil and data.wgc_electricity ~= nil and inst.components.wgc_electricity ~= nil then
        inst.components.wgc_electricity.current = data.wgc_electricity
        inst.components.wgc_electricity:ForceUpdate()
    end
end

TUNING.WGC0310_STUNNED_ACCERATION = 0.1
TUNING.WGC0310_STUNNED_ATTACK_MODIFIER = 0.1
TUNING.WGC0310_STUNNED_WORKEFFECTIVENESS_MODIFIER = 0.1

local function WGC0310_OnElectricityBecomeEmpty(inst)
    -- when the electricity is empty, the character will be almost stunned, no working and fighting allowed,
    -- and move very slow

    if inst.components.locomotor ~= nil then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "WGC0310_Acceleration", TUNING.WGC0310_STUNNED_ACCERATION)
    end

    if inst.components.combat ~= nil then
        inst.components.combat.damagemultiplier = TUNING.WGC0310_STUNNED_ATTACK_MODIFIER
    end

    if inst.components.workmultiplier ~= nil then
        inst.components.workmultiplier:RemoveMultiplier(ACTIONS.CHOP, inst)
        inst.components.workmultiplier:RemoveMultiplier(ACTIONS.MINE, inst)
        inst.components.workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)

        inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, TUNING.WGC0310_STUNNED_WORKEFFECTIVENESS_MODIFIER, inst)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE, TUNING.WGC0310_STUNNED_WORKEFFECTIVENESS_MODIFIER, inst)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.WGC0310_STUNNED_WORKEFFECTIVENESS_MODIFIER, inst)
    end
end

local function WGC0310_OnElectricityBecomeNonEmpty(inst)
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "WGC0310_Acceleration", TUNING.WGC0310_ACCELERATION)
    end

    if inst.components.combat ~= nil then
        inst.components.combat.damagemultiplier = TUNING.WGC0310_ATTACK_MODIFIER
    end

    if inst.components.workmultiplier ~= nil then
        inst.components.workmultiplier:RemoveMultiplier(ACTIONS.CHOP, inst)
        inst.components.workmultiplier:RemoveMultiplier(ACTIONS.MINE, inst)
        inst.components.workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)

        inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, TUNING.WGC0310_WORKEFFECTIVENESS_MODIFIER, inst)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE, TUNING.WGC0310_WORKEFFECTIVENESS_MODIFIER, inst)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.WGC0310_WORKEFFECTIVENESS_MODIFIER, inst)
    end
end

local function WGC0310_OnEat(inst, food)
    if food ~= nil and food.components.edible ~= nil then
        if food.components.edible.foodtype == FOODTYPE.GEARS then
            -- can heal by eating gears, 125 health per gear
            inst.components.health:DoDelta(125)
            inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")

            -- and if this is the original gear (not WGC-0310 made), recover full electricity
            -- also the original code recovering hunger should just work here
            if food.name == "gears" then
                inst.components.wgc_electricity.current = inst.components.wgc_electricity.max
                inst.components.wgc_electricity:ForceUpdate()
            end
            inst.components.wgc_electricity:DoDelta(inst.components.wgc_electricity.max)
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
        inst.components.wgc_electricity:DoDelta(-18, true)
    end
end

local function WGC0310_WorkConsumesElectricity(inst, data)
    if inst.components.wgc_electricity ~= nil then
        inst.components.wgc_electricity:DoDelta(-3, true)
    end
end

local function WGC0310_HungerBurn(inst)
    if inst:HasTag("playerghost") then
        return
    end

    if inst.components.hunger ~= nil and inst.components.wgc_electricity ~= nil then
        if inst.components.wgc_electricity.current <= inst.components.wgc_electricity.max - 7.5 and 
            inst.components.hunger.current > 0
        then
            -- if the electricity is not full, burn hunger to charge it
            inst.components.hunger:DoDelta(-1, true)
            inst.components.wgc_electricity:DoDelta(7.5, true)
        end
    end
end

local function common_postinit(inst)
    inst:AddTag("electricdamageimmune")
    inst:AddTag("soulless")
    inst:AddTag("wgc0310")
    inst.MiniMapEntity:SetIcon("wgc0310.tex")
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
    inst.soundsname = "wx78"

    -- this character uses electricity system specific to WGC0310
    inst:AddComponent("wgc_electricity")
    inst:ListenForEvent("onattackother", WGC0310_AttackConsumesElectricity)
    inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, TUNING.WGC0310_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE, TUNING.WGC0310_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.WGC0310_WORKEFFECTIVENESS_MODIFIER, inst)
    inst:ListenForEvent("working", WGC0310_WorkConsumesElectricity)
    inst:ListenForEvent("tilling", WGC0310_WorkConsumesElectricity)

    inst:ListenForEvent("wgc_electricity_empty", WGC0310_OnElectricityBecomeEmpty)
    inst:ListenForEvent("wgc_electricity_nonempty", WGC0310_OnElectricityBecomeNonEmpty)

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
    inst.components.hunger.Resume = inst.components.hunger.Pause
    inst.components.hunger.IsPaused = function (self) return true end
    inst:DoPeriodicTask(3, WGC0310_HungerBurn)

    inst.components.sanity:SetMax(TUNING.WGC0310_SANITY)
    inst.components.sanity.ignore = true

    if inst.components.eater ~= nil then
        inst.components.eater:SetIgnoresSpoilage(true)
        inst.components.eater:SetCanEatGears()
        inst.components.eater:SetOnEatFn(WGC0310_OnEat)
        inst.components.eater:SetAbsorptionModifiers(0, 1, 0)
    end

    inst.components.combat.damagemultiplier = TUNING.WGC0310_ATTACK_MODIFIER

    inst.Light:Enable(true)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(200 / 255, 150 / 255, 50 / 255)
    inst.Light:SetFalloff(.5)
    inst.Light:SetRadius(1)

    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "WGC0310_Acceleration", TUNING.WGC0310_ACCELERATION)

    inst.OnLoad = WGC0310_OnLoad
    inst.OnNewSpawn = WGC0310_OnLoad
    inst.OnSave = WGC0310_OnSave
    inst:ListenForEvent("ms_playerseamlessswaped", WGC0310_OnLoad)
end

return MakePlayerCharacter("wgc0310", prefabs, assets, common_postinit, master_postinit, prefabs)
