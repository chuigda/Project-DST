local assets =
{
    Asset("ANIM", "anim/wgc0310_staff_yellow.zip"),
	Asset("ANIM", "anim/wgc0310_staff_yellow_ground.zip"),

    Asset("ATLAS", "images/inventoryimages/wgc0310_spear.xml"),
    Asset("IMAGE", "images/inventoryimages/wgc0310_spear.tex"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "wgc0310_staff_yellow", "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

-- somewhat copied from components/staff.lua
local function onattack_yellow(inst, attacker, target)
    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end

    if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if target.components.combat ~= nil then
        target.components.combat:SuggestTarget(attacker)
    end

	if target.components.health ~= nil and target:IsValid() then
        if attacker.prefab == "wgc0310" then
            if attacker.components.wgc_electricity.current > attacker.components.wgc_electricity.max * 0.2 then
                attacker.components.wgc_electricity:DoDelta(-attacker.components.wgc_electricity.max * 0.2)
                target.components.health:DeltaPenalty(target.components.health.maxhealth * 0.12)
            end
        elseif attacker.components.sanity ~= nil then
            -- other charachters can also consume sanity to do this
            if attacker.components.sanity.current > attacker.components.sanity.max * 0.15 then
                attacker.components.sanity:DoDelta(-attacker.components.sanity.max * 0.15)
                target.components.health:DeltaPenalty(target.components.health.maxhealth * 0.08)
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wgc0310_staff_yellow_ground")
    inst.AnimState:SetBuild("wgc0310_staff_yellow_ground")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("icestaff")
    inst:AddTag("weapon")
    inst:AddTag("rangedweapon")
    inst.projectiledelay = 1 / 30.0

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(65)
    inst.components.weapon:SetRange(12, 20)
    inst.components.weapon:SetOnAttack(onattack_yellow)
    inst.components.weapon:SetProjectile("ice_projectile")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wgc0310_spear"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wgc0310_spear.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wgc0310_staff_yellow", fn, assets)
