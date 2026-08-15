C_KeSiControllerStore = DefClass("C_KeSiControllerStore", C_KeSiControllerStore, C_StoreGroup)
GroupName2Class.KeSiControllerStore = C_KeSiControllerStore
local M = C_KeSiControllerStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self:CreateAction("OnKeSiChange")
	}
end

function M:RegisterWidget()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnTabRectRender")
end

function M:OnTabRectRender(index, widget)
	self.curKeSiStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curKeSiStore then
		self.curKeSiStore:OnShow(nil, self.data)
	end
end

function M:OnKeSiChange(eventId, isKeSiMode)
	if not self.STATE_EnableOnce then
		return
	end

	if self.curKeSiStore then
		self.curKeSiStore:OnClose()

		self.curKeSiStore = nil
	end

	if gCS.MyPlayerManager.PlayerUnit.ClientData.cardId ~= 15022030 then
		self.bindData.tabRect.selectedIndex = -1

		return
	end

	self.bindData.tabRect.selectedIndex = isKeSiMode and 0 or -1
end
