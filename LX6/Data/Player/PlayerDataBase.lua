-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerDataBase.lua
-- Decompiled from: 00087_PlayerDataBase.lua_244e094afc13.luajit

local DataSet = require("LX6/DataBind/DataSet")
C_PlayerDataBase = DefClass("C_PlayerDataBase", C_PlayerDataBase, C_BaseData)
local M = C_PlayerDataBase

M.ctor = function(self, dataMgr)
	self.DefineBindEvents(self)
end

M.DefineData = function(self)
	self.DataSet_Template = {}
	self.bindData = DataSet.New()
end

M.DefineBindEvents = function(self)
end

M.Init = function(self)
	M.base.Init(self)

	if self.BindEventHandler then
		self.bindData:BindHandlers(self.BindEventHandler)
	end
end
