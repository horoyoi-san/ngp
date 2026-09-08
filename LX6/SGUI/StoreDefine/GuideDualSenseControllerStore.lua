-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideDualSenseControllerStore.lua
-- Decompiled from: 01757_GuideDualSenseControllerStore.lua_68b1807c9162.luajit

local GuideGuideTextConfig = LTConfig.GuideGuideTextConfig
C_GuideDualSenseControllerStore = DefClass("C_GuideDualSenseControllerStore", C_GuideDualSenseControllerStore, C_StoreGroup)
GroupName2Class.GuideDualSenseControllerStore = C_GuideDualSenseControllerStore
local M = C_GuideDualSenseControllerStore

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
	if not data then
		print_error("GuideDualSenseControllerStore OnShow data is nil")

		return
	end

	self.showData = data

	if not data.controllerTabIndex then
		print_error("GuideDualSenseController节点的TabIndex为空")
	elseif data.controllerTabIndex <= 0 or self.bindData.controllerAnimTab.tabUrlListCount < data.controllerTabIndex then
		print_error("GuideDualSenseController节点的TabIndex越界, index:" .. data.controllerTabIndex)
	else
		self.bindData.controllerAnimTab.selectedIndex = data.controllerTabIndex
	end

	self.RefreshText(self, data)
end

M.OnClose = function(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshText(self, self.showData)
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshText(self, self.showData)
end

M.RefreshText = function(self, data)
	if data.normalGuideTextId and data.normalGuideTextId == 0 then
		self.bindData:Commit("normalGuideTextId", GuideGuideTextConfig.GetConfig(data.normalGuideTextId).Text, COMMIT_FORCE)
	end

	if data.dualSenseGuideTextId and data.dualSenseGuideTextId == 0 then
		self.bindData:Commit("dualSenseGuideTextId", GuideGuideTextConfig.GetConfig(data.dualSenseGuideTextId).Text, COMMIT_FORCE)
	end
end
