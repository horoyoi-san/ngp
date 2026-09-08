-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerAchieveData.lua
-- Decompiled from: 00091_PlayerAchieveData.lua_d8dd8e9299a3.luajit

local DataSet = require("LX6/DataBind/DataSet")
C_PlayerAchieveData = DefClass("C_PlayerAchieveData", C_PlayerAchieveData, C_PlayerDataBase)
local M = C_PlayerAchieveData

M.DefineData = function(self)
	self.DataSet_Template = {}
	self.bindData = DataSet.New({
		["\\xa5\\xb4\\x88e+\\xf0'"] = 0,
		["I\\x82\\xa0\\x86V"] = false
	})
end

M.OnLogOut = function(self)
	self.bindData.hasNew = false
	self.bindData.newCount = 0
	self.bindData.newQue = {}
end
