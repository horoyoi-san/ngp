C_PlayerInfoMinorWorldBeliefsData = DefClass("C_PlayerInfoMinorWorldBeliefsData", C_PlayerInfoMinorWorldBeliefsData, C_PlayerDataBase)
local M = C_PlayerInfoMinorWorldBeliefsData

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template

	self.bindData:RefreshData(t)
end

function M:OnLogOut()
	self.bindData:Clear()
end
