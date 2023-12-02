-- local function OnTaskTick(inst, self, period)
--    self:DoDec(period)
-- end

local WGCElectricity = Class(function (self, inst)
   self.inst = inst
   self.max = 800
   self.current = 800

   self.net_max = net_ushortint(inst.GUID, "wgc_electricity_max", "wgc_electricity_maxdirty")
   self.net_current = net_ushortint(inst.GUID, "wgc_electricity_current", "wgc_electricity_currentdirty")

   -- Electricity decays very slow natually, but consumes quickly when in combat
   -- local period = 1
   -- self.inst:DoPeriodicTask(period, OnTaskTick, nil, self, period)

   -- electricity decaying handled elsewhere
end)

-- function WGCElectricity:DoDec(dt, ignore_damage)
--    -- don't decay when user's ghost
--    if self.inst:HasTag("playerghost") then
--       return
--    end

--    if self.current > 0 then
--       self:DoDelta(-0.2, true)
--    end
-- end

function WGCElectricity:DoDelta(delta, overtime)
   local old = self.current
   self.current = math.clamp(self.current + delta, 0, self.max)

   if old ~= self.current then
      self.net_max:set(self.max)
      self.net_current:set(self.current)

      if old ~= 0 and self.current == 0 then
         self.inst:PushEvent("wgc_electricity_empty")
      elseif old == 0 and self.current ~= 0 then
         self.inst:PushEvent("wgc_electricity_nonempty")
      end
   end
end

function WGCElectricity:ForceUpdate()
   self.net_max:set(self.max)
   self.net_current:set(self.current)

   if self.current == 0 then
      self.inst:PushEvent("wgc_electricity_empty")
   else
      self.inst:PushEvent("wgc_electricity_nonempty")
   end
end

return WGCElectricity
