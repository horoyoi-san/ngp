local ProfileManager = LX6.Engine.ProfileManager
C_PlayerInfoOtherData = DefClass("C_PlayerInfoOtherData", C_PlayerInfoOtherData, C_PlayerDataBase)
local M = C_PlayerInfoOtherData

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template
	t.houseInfo = {
		HouseId = 1
	}
	t.selectTeacherPid = 0
	t.critRate = 0
	t.friendOnly = false
	t.myNameActive = ProfileManager.gameProfile.myNameActive
	t.teammateNameActive = ProfileManager.gameProfile.teammateNameActive
	t.BirthDay = 0
	t.SharedSceneBlackList = {}

	self.bindData:RefreshData(t)
end

function M:OnLogOut()
	self.bindData:Clear()
end
