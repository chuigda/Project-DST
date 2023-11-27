local WGCElectricityProvider = Class(function (self, inst)
   self.inst = inst
   self.amount = 0.0
   self.check_can_provide_fn = nil
   self.on_provide_fn = nil
end)

function WGCElectricityProvider:CanProvide()
   return self.check_can_provide_fn == nil or self.check_can_provide_fn(self)
end

function WGCElectricityProvider:Provide()
   if self.on_provide_fn ~= nil then
      self.on_provide_fn(self, self.amount)
   end
end

function WGCElectricityProvider:SetCheckCanProvideFn(fn)
   self.check_can_provide_fn = fn
end

function WGCElectricityProvider:SetOnProvideFn(fn)
   self.on_provide_fn = fn
end

return WGCElectricityProvider
