C_PlayerInfoMinorSpiritStandingDrawingData = DefClass("C_PlayerInfoMinorSpiritStandingDrawingData", C_PlayerInfoMinorSpiritStandingDrawingData, C_PlayerDataBase)
local M = C_PlayerInfoMinorSpiritStandingDrawingData

function M:InitPlayerInfo(info)
	return
end

function M:OnLogOut()
	self.bindData:Clear()
end
