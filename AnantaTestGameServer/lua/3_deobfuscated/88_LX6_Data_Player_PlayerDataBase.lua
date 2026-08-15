local DataSet = require("LX6/DataBind/DataSet")
C_PlayerDataBase = DefClass("C_PlayerDataBase", C_PlayerDataBase, C_BaseData)
local M = C_PlayerDataBase

function M:ctor(dataMgr)
	self:DefineBindEvents()
end

function M:DefineData()
	self.DataSet_Template = {}
	self.bindData = DataSet.New()
end

function M:DefineBindEvents()
	return
end

function M:Init()
	M.base.Init(self)

	if self.BindEventHandler then
		self.bindData:BindHandlers(self.BindEventHandler)
	end
end
