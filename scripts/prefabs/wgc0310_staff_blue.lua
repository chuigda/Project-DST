local assets =
{
    Asset("ANIM", "anim/wgc0310_staff_blue.zip"),
	Asset("ANIM", "anim/wgc0310_staff_blue_ground.zip"),

    Asset("ATLAS", "images/inventoryimages/wgc0310_spear.xml"),
    Asset("IMAGE", "images/inventoryimages/wgc0310_spear.tex"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "wgc0310_staff_blue", "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

-- somewhat copied from components/staff.lua
local function onattack_blue(inst, attacker, target)
    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end

    if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.components.combat ~= nil then
        target.components.combat:SuggestTarget(attacker)
    end

	if target.components.freezable ~= nil and target:IsValid() then
        target.components.freezable:AddColdness(10)
        target.components.freezable:SpawnShatterFX()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wgc0310_staff_blue")
    inst.AnimState:SetBuild("wgc0310_staff_blue")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("icestaff")
    inst:AddTag("weapon")
    inst:AddTag("rangedweapon")
    inst:AddTag("extinguisher")
    inst.projectiledelay = 1 / 30.0

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(40)
    inst.components.weapon:SetRange(8, 16)
    inst.components.weapon:SetOnAttack(onattack_blue)
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

return Prefab("wgc0310_staff_blue", fn, assets)
