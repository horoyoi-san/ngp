-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoOtherData.lua
-- Decompiled from: 00106_PlayerInfoOtherData.lua_be897dfee502.luajit

local ProfileManager = LX6.Engine.ProfileManager
C_PlayerInfoOtherData = DefClass("C_PlayerInfoOtherData", C_PlayerInfoOtherData, C_PlayerDataBase)
local M = C_PlayerInfoOtherData

M.InitPlayerInfo = function(self, info)
	local t = self.DataSet_Template
	t.houseInfo = {
		["\\xf1\\xd4\r\\xf5"] = 1
	}
	t.selectTeacherPid = 0
	t.friendOnly = false
	t.myNameActive = ProfileManager.gameProfile.myNameActive
	t.teammateNameActive = ProfileManager.gameProfile.teammateNameActive
	t.BirthDay = 0
	t.SharedSceneBlackList = {}

	self.bindData:RefreshData(t)
end

M.OnLogOut = function(self)
	self.bindData:Clear()
end
