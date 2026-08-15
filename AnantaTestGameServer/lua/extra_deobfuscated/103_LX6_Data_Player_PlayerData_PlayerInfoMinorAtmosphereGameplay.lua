C_PlayerInfoMinorAtmosphereGameplayData = DefClass("C_PlayerInfoMinorAtmosphereGameplayData", C_PlayerInfoMinorAtmosphereGameplayData, C_PlayerDataBase)
local M = C_PlayerInfoMinorAtmosphereGameplayData

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template
	t.animalInfos = {}

	self.bindData:RefreshData(t)
end

function M:OnLogOut()
	self.bindData:Clear()
end
