C_PlayerInfoLoginData = DefClass("C_PlayerInfoLoginData", C_PlayerInfoLoginData, C_PlayerDataBase)
local M = C_PlayerInfoLoginData

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template
	t.pid = info.InfoLogin.Pid
	t.sexType = info.InfoLogin.Sex
	t.name = info.InfoLogin.Name
	t.playerName = info.InfoLogin.Name
	t.infoPzHeadInfo = info.InfoLogin.PzHeadInfo

	self.bindData:RefreshData(t)
end

function M:OnLogOut()
	self.bindData:Clear()
end
