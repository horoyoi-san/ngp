if not gPaoKuGpsManager then
	local M = {
		gpsTypeDict = {}
	}
end

function M:OnInit()
	self:InitGpsType()
end

function M:RefreshWallUpOverJumpGPS(x, y, z)
	local data = self.gpsTypeDict.wallUpOverJump
	data.addGps.TargetPos.z = z
	data.addGps.TargetPos.y = y
	data.addGps.TargetPos.x = x
	data.addGps.CanShow = 1

	gGpsManager:AddGPS(data.addGps)

	data.hasAdd = true
end

function M:HideWallUpOverJumpGPS()
	local data = self.gpsTypeDict.wallUpOverJump

	if data.hasAdd and data.addGps.CanShow == 1 then
		data.addGps.CanShow = 0

		gMessageManager:SendMessage(gEventConstants.UPDATE_GPS, data.addGps)
	end
end

function M:ResetInfo()
	for _, v in pairs(self.gpsTypeDict) do
		gGpsManager:RemoveGPS(v.addGps)
	end
end

function M:InitGpsType()
	self.gpsTypeDict = {
		wallUpOverJump = {
			hasAdd = false,
			addGps = {
				legacyOnly = true,
				CanShow = 0,
				InstanceId = "wallUpOverJump9999",
				TargetPos = Vector3.zero,
				GpsType = gTaskGpsType.WallUpOverJump
			}
		}
	}
end

function M:OnBeforeSwitchScene(switchType)
	self:ResetInfo()
end

gPaoKuGpsManager = M

return gPaoKuGpsManager
