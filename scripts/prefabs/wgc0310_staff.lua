local assets =
{
    Asset("ANIM", "anim/wgc0310_staff.zip"),
	Asset("ANIM", "anim/wgc0310_staff_ground.zip"),

    Asset("ATLAS", "images/inventoryimages/wgc0310_spear.xml"),
    Asset("IMAGE", "images/inventoryimages/wgc0310_spear.tex"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "wgc0310_staff", "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wgc0310_staff")
    inst.AnimState:SetBuild("wgc0310_staff")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    --weapon (from weapon component) added to pristine state for optimization
    inst.components.weapon:SetDamage(28)

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

return Prefab("wgc0310_staff", fn, assets)
