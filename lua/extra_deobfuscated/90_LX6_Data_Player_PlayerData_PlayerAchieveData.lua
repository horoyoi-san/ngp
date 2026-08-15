local DataSet = require("LX6/DataBind/DataSet")
C_PlayerAchieveData = DefClass("C_PlayerAchieveData", C_PlayerAchieveData, C_PlayerDataBase)
local M = C_PlayerAchieveData

function M:DefineData()
	self.DataSet_Template = {}
	self.bindData = DataSet.New({
		newCount = 0,
		hasNew = false
	})
end

function M:OnLogOut()
	self.bindData.hasNew = false
	self.bindData.newCount = 0
	self.bindData.newQue = {}
end
