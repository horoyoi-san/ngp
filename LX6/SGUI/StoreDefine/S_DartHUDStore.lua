-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_DartHUDStore.lua
-- Decompiled from: 01393_S_DartHUDStore.lua_851f0ca0d83d.luajit

C_S_DartHUDStore = DefClass("C_S_DartHUDStore", C_S_DartHUDStore, C_StoreGroup)
GroupName2Class.S_DartHUDStore = C_S_DartHUDStore
local M = C_S_DartHUDStore

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if self.animaTimer == nil then
		self.animaTimer:Stop()
	end

	self.animaTimer = Timer.New(function ()
		self.animaTimer = nil

		gPanelManager:Close(gPanelId.S_DartHUDStorePanel)
	end, 2.5):Start()
	local hudType = data.hudType
	local num = data.roundNum
	self.bindData.hudType = hudType
	self.bindData.roundText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901074).Text, gUIUtils:NumberToChinese(num))
end

M.OnClose = function(self)
end
