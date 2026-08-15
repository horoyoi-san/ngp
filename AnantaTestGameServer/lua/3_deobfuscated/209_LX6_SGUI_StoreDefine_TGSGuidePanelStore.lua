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

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("TGSKeyIndependentClose", gMainPageManager)
	self.bindData.contentTab.OnRenderTab = self:CreateAction("OnRenderTab")
	self.widDict = {}
end

function M:OnChangeTab(list)
	self.bindData.contentTab.selectedIndex = list.selectedIndex
end

function M:OnRenderTab(index, tab)
	if self.widDict[index] or index ~= 0 then
		tab:InvokeCallback(EInvokeTime.User1)
	end

	self.widDict[index] = tab

	tab:TryChangePage("Controller", DEVICE2CONTROLLER[InputActionBind.activeGameDevice] or 1)
end

function M:OnShow(panelId, data)
	local titles = {}

	for i = 1, #GuideConfig.TGSGuideTabName do
		local ret = {
			iconId = 28000069,
			id = i,
			title = GuideConfig.TGSGuideTabName[i]
		}

		table.insert(titles, ret)
	end

	self.SubGroup.CommonTabSingleStore:SetData(titles, nil, 0, nil, self:CreateAction("OnChangeTab"))

	self.bindData.contentTab.selectedIndex = 0

	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	local wid = self.widDict[self.bindData.contentTab.selectedIndex]

	if wid then
		wid:TryChangePage("Controller", DEVICE2CONTROLLER[InputActionBind.activeGameDevice] or 1)
	end
end
