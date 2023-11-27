local Badge = require "widgets/badge"

local WGCElectricityBadge = Class(Badge, function (self, owner)
   Badge._ctor(self, nil, owner, { 66 / 255, 187 / 255, 212 / 255, 1 }, nil, nil, nil, true)
   self:StartUpdating()
end)

function WGCElectricityBadge:OnUpdate(dt)
   if TheNet:IsServerPaused() then
      return
   end
end

return WGCElectricityBadge
