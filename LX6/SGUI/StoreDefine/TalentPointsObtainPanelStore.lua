-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TalentPointsObtainPanelStore.lua
-- Decompiled from: 01398_TalentPointsObtainPanelStore.lua_1c6b7691364a.luajit

C_TalentPointsObtainPanelStore = DefClass("C_TalentPointsObtainPanelStore", C_TalentPointsObtainPanelStore, C_StoreGroup)
GroupName2Class.TalentPointsObtainPanelStore = C_TalentPointsObtainPanelStore
local M = C_TalentPointsObtainPanelStore

M.ctor = function(self)
	self.areaIndex = 0
end

M.OnAwake = function(self)
end

M.OnShow = function(self, panelId, data)
	self.areaIndex = data.areaIndex
	self.bindData.countLabel = "+" .. data.addition
	self.bindData.headIcon = data.headId

	Timer.New(function ()
		if self.areaIndex then
			gPanelManager:Close(gPanelId.S_TALENT_POINTS_OBTAIN_PANEL)
		else
			gPanelManager:Close(gPanelId.S_TALENT_POINTS_OBTAIN_FRONT_PANEL)
		end
	end, 3):Start()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
