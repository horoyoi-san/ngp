C_PlayerInfoBaseData = DefClass("C_PlayerInfoBaseData", C_PlayerInfoBaseData, C_PlayerDataBase)
local M = C_PlayerInfoBaseData

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template
	t.Aid = info.Aid
	t.Pid = info.Pid
	t.CreateTime = info.CreateTime
	t.AccountId = info.AccountId
	t.SaveToken = info.SaveToken

	self.bindData:RefreshData(t)
end

function M:OnLogOut()
	self.bindData:Clear()
end
