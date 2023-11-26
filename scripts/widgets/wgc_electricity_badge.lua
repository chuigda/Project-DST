local Badge = require "widgets/badge"

local WGCElectricityBadge = Class(Badge, function (self, owner)
   Badge._ctor(self, nil, owner, { 191 / 255, 191 / 255, 191 / 255, 1 }, nil, nil, nil, true)
   self:StartUpdating()
end)

function WGCElectricityBadge:OnUpdate(dt)
   if TheNet:IsServerPaused() then
      return
   end
end

return WGCElectricityBadge
