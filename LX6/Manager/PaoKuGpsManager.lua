-- Original chunk: @Lua\LuaFiles\LX6\Manager\PaoKuGpsManager.lua
-- Decompiled from: 00690_PaoKuGpsManager.lua_cfefd8649bc2.luajit

if not gPaoKuGpsManager then
	local M = {
		gpsTypeDict = {}
	}
end

M.OnInit = function(self)
	self.InitGpsType(self)
end

M.RefreshWallUpOverJumpGPS = function(self, x, y, z)
	local data = self.gpsTypeDict.wallUpOverJump
	data.addGps.TargetPos.z = z
	data.addGps.TargetPos.y = y
	data.addGps.TargetPos.x = x
	data.addGps.CanShow = 1

	gMessageManager:SendMessage(gEventConstants.ADD_SCENE_HINT, data.addGps)

	data.hasAdd = true
end

M.HideWallUpOverJumpGPS = function(self)
	local data = self.gpsTypeDict.wallUpOverJump

	if data.hasAdd and data.addGps.CanShow ~= 1 then
		data.addGps.CanShow = 0

		gMessageManager:SendMessage(gEventConstants.UPDATE_SCENE_HINT, data.addGps)
	end
end

M.ResetInfo = function(self)
	for _, v in pairs(self.gpsTypeDict) do
		gMessageManager:SendMessage(gEventConstants.REMOVE_SCENE_HINT, v.addGps)
	end
end

M.InitGpsType = function(self)
	self.gpsTypeDict = {
		wallUpOverJump = {
			["I\\x82\\xaf\\x87E"] = false,
			addGps = {
				["__ɼ\\x87\\x97\n\\xc5\\xf1"] = true,
				["\\xfa\\xda.+\\xe6"] = 0,
				["zTݩ\\x85\\xbb\\xe0\\xec"] = ";\\x9cិǰ\\xbf\\x9a\\xf7\\xf7?\\xd6\\xc3yƻ",
				TargetPos = Vector3.zero,
				GpsType = gTaskGpsType.WallUpOverJump
			}
		}
	}
end

M.OnBeforeSwitchScene = function(self, switchType)
	self.ResetInfo(self)
end

gPaoKuGpsManager = M

return gPaoKuGpsManager
