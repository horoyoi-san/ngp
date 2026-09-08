-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TGSGuidePanelStore.lua
-- Decompiled from: 01379_TGSGuidePanelStore.lua_63d2cd8194db.luajit

local InputActionBind = SGUI.InputActionBind
local GuideConfig = LTConfig.GuideConfig
local GameDevice = SGUI.GameDevice
local EInvokeTime = SGUI.EInvokeTime
C_TGSGuidePanelStore = DefClass("C_TGSGuidePanelStore", C_TGSGuidePanelStore, C_StoreGroup)
GroupName2Class.TGSGuidePanelStore = C_TGSGuidePanelStore
local M = C_TGSGuidePanelStore
local DEVICE2CONTROLLER = {
	[GameDevice.PlayStation] = 0,
	[GameDevice.Xbox] = 1
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.contentTab.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.widDict = {}
end

M.OnChangeTab = function(self, list)
	self.bindData.contentTab.selectedIndex = list.selectedIndex
end

M.OnRenderTab = function(self, index, tab)
	if self.widDict[index] or index == 0 then
		tab.InvokeCallback(tab, EInvokeTime.User1)
	end

	self.widDict[index] = tab

	tab:TryChangePage("Controller", DEVICE2CONTROLLER[InputActionBind.activeGameDevice] or 1)
end

M.OnShow = function(self, panelId, data)
	local titles = {}

	for i = 1, #GuideConfig.TGSGuideTabName do
		local ret = {
			["K\\x9e\\x80\\xaaE"] = 28000069,
			id = i,
			title = GuideConfig.TGSGuideTabName[i]
		}

		table.insert(titles, ret)
	end

	self.SubGroup.CommonTabSingleStore:SetData(titles, nil, 0, nil, self:CreateAction("OnChangeTab"))

	self.bindData.contentTab.selectedIndex = 0

	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	local wid = self.widDict[self.bindData.contentTab.selectedIndex]

	if wid then
		wid:TryChangePage("Controller", DEVICE2CONTROLLER[InputActionBind.activeGameDevice] or 1)
	end
end
