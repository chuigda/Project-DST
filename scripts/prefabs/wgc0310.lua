local has_enabled_achievement_chasni = KnownModIndex:IsModEnabled("workshop-2937640068") -- Steam original
    or KnownModIndex:IsModEnabled("workshop-2199027653598543777") -- WeGame portings
    or KnownModIndex:IsModEnabled("workshop-2199027653598541538")
    or KnownModIndex:IsModEnabled("workshop-2199027653598543914")
    or KnownModIndex:IsModEnabled("workshop-2199027653598542318")
    or KnownModIndex:IsModEnabled(KnownModIndex:GetModActualName("Achievement Chasni Mod")) -- fallback way, detect by mod name

if has_enabled_achievement_chasni then
    print("WGC0310: Achievement Chasni Mod is enabled, electricity system will be adjusted accordingly!")
end

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

    inst.components.wgc_electricity.current = inst.components.wgc_electricity.current.max
    inst.components.sanity.current = inst.components.sanity.max
    inst.components.wgc_electricity:ForceUpdate()
end

local function WGC0310_OnBecomeGhost(inst)
    inst.components.wgc_electricity.current = inst.components.wgc_electricity.current.max
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
        if has_enabled_achievement_chasni and inst.currentlevel ~= nil then
            -- in case that user enabled Achievement Chasni Mod, the electricity consumption is
            -- reduced by Chasni level
            local consumption = math.clamp(12 - inst.currentlevel:value() * 0.5, 0, 12)
            inst.components.wgc_electricity:DoDelta(-consumption, true)
        else
            inst.components.wgc_electricity:DoDelta(-12, true)
        end
    end
end

local function WGC0310_WorkConsumesElectricity(inst, data)
    if inst.components.wgc_electricity ~= nil then
        inst.components.wgc_electricity:DoDelta(-4, true)
    end
end

local function WGC0310_Metabolism(inst)
    if inst:HasTag("playerghost") then
        -- don't do any metabolism when user's ghost
        return
    end

    if inst.components.health ~= nil and inst.components.health.invincible then
        -- in this mode, always fill the electricity to full
        inst.components.wgc_electricity.current = inst.components.wgc_electricity.max
        inst.components.wgc_electricity:ForceUpdate()
        return
    end

    local electricity_delta = -0.2 -- if doing nothing, consume 0.2 electricity per second
    local hunger_delta = 0.0 -- if doing nothing, consume 0 hunger per second

    if has_enabled_achievement_chasni and inst.currentlevel ~= nil then
        -- In Achievement Chasni Mod there's no "official" buffs for our quite weird electricity
        -- system, and there's unlikely to be one. So instead, we implement our own buff here
        -- to make the electricity system more reasonable. We're provide 0.3 electricity recover per
        -- second per Chasni level.
        electricity_delta = electricity_delta + 0.3 * inst.currentlevel:value()
    end

    if inst.components.hunger ~= nil and inst.components.wgc_electricity ~= nil then
        if inst.components.hunger.current >= 0.25 and 
           (inst.components.wgc_electricity.current + electricity_delta) <= inst.components.wgc_electricity.max - 2
        then
            -- under such circumstance, we can use hunger to recover electricity,
            -- 1 hunger point can recover 8 electricity points in 4 seconds
            electricity_delta = electricity_delta + 2
            hunger_delta = hunger_delta - 0.2
        end
    end

    -- then, search through the inventory to see if there's battery items
    -- if there is, consume the battery to recover electricity
    if inst.components.inventory ~= nil then
        for k, v in pairs(inst.components.inventory.itemslots) do
            if v.components.wgc_electricity_provider ~= nil and
               v.components.wgc_electricity_provider:CanProvide() and
               (inst.components.wgc_electricity.current + electricity_delta) <= (inst.components.wgc_electricity.max - v.components.wgc_electricity_provider.amount)
            then
                v.components.wgc_electricity_provider:Provide()
                electricity_delta = electricity_delta + v.components.wgc_electricity_provider.amount
            end
        end
    end

    -- finally, do the delta
    if electricity_delta ~= 0.0 then
        inst.components.wgc_electricity:DoDelta(electricity_delta, true)
    else
        -- even if there's no change, also trigger a forced update to inform HUD
        inst.components.wgc_electricity:ForceUpdate()
    end
    if hunger_delta ~= 0.0 then
        inst.components.hunger:DoDelta(hunger_delta, true)
    end
end

local function common_postinit(inst)
    inst:AddTag("electricdamageimmune")
    inst:AddTag("soulless")
    inst:AddTag("wgc0310")
    inst.MiniMapEntity:SetIcon("wgc0310.tex")

    inst.net_wgc_electricity_max = net_ushortint(inst.GUID, "wgc_electricity_max", "wgc_electricity_maxdirty")
    inst.net_wgc_electricity_current = net_ushortint(inst.GUID, "wgc_electricity_current", "wgc_electricity_currentdirty")
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

    -- if Achievement Chasni Mod is enabled, don't disable healing because Achievement Chasni mod has
    -- some advancements relevant with healing, and we don't want to make that system nonsense
    if not has_enabled_achievement_chasni then
        inst.components.health.canheal = false
    end

    inst.components.hunger:SetMax(TUNING.WGC0310_HUNGER)
    -- this character never really gets hungry, but it still has a (decaying) hunger bar
    inst.components.hunger.IsStarving = WGC0310_IsStarving
    inst.components.hunger:SetOverrideStarveFn(WGC0310_OnStarveOverride)
    -- bypass the default hunger decaying logic and implement our own system
    -- relevant with the electricity system
    inst.components.hunger:Pause()
    inst.components.hunger.Resume = inst.components.hunger.Pause
    inst.components.hunger.IsPaused = function (self) return true end

    inst:DoPeriodicTask(1, WGC0310_Metabolism)

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
