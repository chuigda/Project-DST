local function OnTaskTick(inst, self, period)
   self:DoDec(period)
end

local WGCElectricity = Class(function (self, inst)
   self.inst = inst
   self.max = 800
   self.current = 800

   -- Electricity decays very slow natually, but consumes quickly when in combat
   local period = 1
   self.inst:DoPeriodicTask(period, OnTaskTick, nil, self, period)
end)

function WGCElectricity:DoDec(dt, ignore_damage)
   -- don't decay when user's ghost
   if self.inst:HasTag("playerghost") then
      return
   end

   if self.current > 0 then
      -- if user is running, decay faster
      self:DoDelta(-0.05, true)
   end
end

function WGCElectricity:DoDelta(delta, overtime)
   local old = self.current
   self.current = math.clamp(self.current + delta, 0, self.max)

   if old ~= self.current then
      self.inst:PushEvent("wgc_electricity_delta", {
         old = old,
         current = self.current,
         oldpercent = old / self.max,
         newpercent = self.current / self.max,
         overtime = overtime
      })

      if old ~= 0 and self.current == 0 then
         self.inst:PushEvent("wgc_electricity_empty")
      elseif old == 0 and self.current ~= 0 then
         self.inst:PushEvent("wgc_electricity_nonempty")
      end
   end
end

function WGCElectricity:ForceUpdate()
   self.inst:PushEvent("wgc_electricity_delta", {
      old = self.current,
      current = self.current,
      oldpercent = self.current / self.max,
      newpercent = self.current / self.max,
      overtime = false
   })

   if self.current == 0 then
      self.inst:PushEvent("wgc_electricity_empty")
   else
      self.inst:PushEvent("wgc_electricity_nonempty")
   end
end

return WGCElectricity
