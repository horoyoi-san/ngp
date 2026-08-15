C_PlayerGuideEventsData = DefClass("C_PlayerGuideEventsData", C_PlayerGuideEventsData, C_PlayerDataBase)
local M = C_PlayerGuideEventsData

function M:OnLogOut()
	self.bindData:Clear()
end
