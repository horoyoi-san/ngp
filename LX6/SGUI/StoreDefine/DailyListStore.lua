-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DailyListStore.lua
-- Decompiled from: 01511_DailyListStore.lua_0c108145cc71.luajit

C_DailyListStore = DefClass("C_DailyListStore", C_DailyListStore, C_StoreGroup)
GroupName2Class.DailyListStore = C_DailyListStore
local M = C_DailyListStore

M.ctor = function(self)
end

M.ShowPanel = function(self, data)
	self.bindData.rank = tostring(data and data.rank or "")
	self.bindData.name = data and data.name or ""
	self.bindData.playCount = data and data.playCount or ""
	self.bindData.colorCtrl = self:GetRankColorCtrl(data and data.rank or 0)
end

M.GetRankColorCtrl = function(self, rank)
	if rank ~= 1 then
		return 0
	end

	if rank ~= 2 then
		return 1
	end

	if rank ~= 3 then
		return 2
	end

	return 3
end
