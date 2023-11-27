local assets = {
   Asset("ANIM", "anim/gears.zip"),

   Asset("ATLAS", "images/inventoryimages/wgc0310_volta_battery.xml"),
   Asset("IMAGE", "images/inventoryimages/wgc0310_volta_battery.tex"),
}

local function OnFill(inst, from_object)
   inst.components.finiteuses:SetUses(inst.components.finiteuses.total)
end

local function fn()
   local inst = CreateEntity()

   inst.entity:AddTransform()
   inst.entity:AddAnimState()
   inst.entity:AddSoundEmitter()
   inst.entity:AddNetwork()

   MakeInventoryPhysics(inst)

   inst.AnimState:SetBank("gears")
   inst.AnimState:SetBuild("gears")
   inst.AnimState:PlayAnimation("idle")

   inst.pickupsound = "metal"

   MakeInventoryFloatable(inst, "med", nil, 0.7)

   inst.entity:SetPristine()

   if not TheWorld.ismastersim then
       return inst
   end

   inst:AddComponent("inspectable")
   inst:AddComponent("inventoryitem")
   inst.components.inventoryitem.imagename = "wgc0310_volta_battery"
   inst.components.inventoryitem.atlasname = "images/inventoryimages/wgc0310_volta_battery.xml"

   inst:AddComponent("fillable")
   inst.components.fillable.overrideonfillfn = OnFill
   inst.components.fillable.showoceanaction = true
   inst.components.fillable.acceptsoceanwater = true

   inst:AddComponent("finiteuses")
   inst.components.finiteuses:SetMaxUses(100)
   inst.components.finiteuses:SetUses(100)

   inst:AddComponent("wgc_electricity_provider")
   inst.components.wgc_electricity_provider.amount = 3.0
   inst.components.wgc_electricity_provider:SetCheckCanProvideFn(function (self)
      if self.inst.components.finiteuses == nil then
         return true
      end
      return self.inst.components.finiteuses:GetUses() > 0
   end)

   inst.components.wgc_electricity_provider:SetOnProvideFn(function (self, amount)
      if self.inst.components.finiteuses ~= nil then
         self.inst.components.finiteuses:Use(1)
      end
   end)

   return inst
end

return Prefab("wgc0310_volta_battery", fn, assets)
