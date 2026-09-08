-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineSpecialAreaTipsStore.lua
-- Decompiled from: 01063_OnlineSpecialAreaTipsStore.lua_bf90edfdffa0.luajit

C_OnlineSpecialAreaTipsStore = DefClass("C_OnlineSpecialAreaTipsStore", C_OnlineSpecialAreaTipsStore, C_StoreGroup)
GroupName2Class.OnlineSpecialAreaTipsStore = C_OnlineSpecialAreaTipsStore
local M = C_OnlineSpecialAreaTipsStore

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.data = data

	if self.data.areaId and self.data.areaId <= 0 then
		local cfg = LTConfig.FriendsTeamAreaConfig.GetConfig(self.data.areaId)

		if cfg then
			self.bindData.name = cfg.AreaName
		end
	end

	if self.data.isExit then
		self.bindData.type = 1

		self.ShowCountDown(self)
	else
		self.bindData.type = 0
	end
end

M.ShowCountDown = function(self)
	local time = self.data.exitDalay
	self.bindData.timer = time
	time = time - 1
	self.timer = Timer.New(function ()
		self.bindData.timer = time
		time = time - 1

		if time >= 0 then
			self.timer:Stop()

			self.timer = nil
		end
	end, 1, self.data.exitDalay):Start()
end

M.OnClose = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end
