C_InterrogationPanelStore = DefClass("C_InterrogationPanelStore", C_InterrogationPanelStore, C_StoreGroup)
GroupName2Class.InterrogationPanelStore = C_InterrogationPanelStore
local M = C_InterrogationPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	return
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
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	if data and data.clearData then
		gGadgetManager:ClearInterrogation()
	end

	if not gGadgetManager:CanInterrogation() then
		gPanelManager:Close(gPanelId.S_INTERROGATION)
		print_error("CanInterrogation false 没有可审问道具")

		return
	end

	self.curSelect = 0

	self:OnClickRight()

	self.bindData.leftBtn.luaClick = self:CreateAction(self.OnClickLeft)
	self.bindData.rightBtn.luaClick = self:CreateAction(self.OnClickRight)
	self.bindData.confirmBtn.luaClick = self:CreateAction(self.OnClickConfirm)
end

function M:OnClose()
	return
end

function M:OnClickRight()
	local newIndex = gGadgetManager:GetNextInterrogation(self.curSelect, true)

	if newIndex == self.curSelect then
		return
	end

	self.curSelect = newIndex

	gMessageManager:SendMessage(gEventConstants.SELECT_SHEEP, self.curSelect)
	gCS.BaseUnitModuleUtils.SetTortureLambBlendParam(self.curSelect)
end

function M:OnClickConfirm()
	local success = gGadgetManager:OnSelectInterrogation(self.curSelect)

	if success then
		gMessageManager:SendMessage(gEventConstants.SELECT_SHEEP, "")
	else
		print_error("OnSelectInterrogation false 当前选择道具已拿走，不可使用")
	end
end

function M:OnClickLeft()
	local newIndex = gGadgetManager:GetNextInterrogation(self.curSelect, false)

	if newIndex == self.curSelect then
		return
	end

	self.curSelect = newIndex

	gMessageManager:SendMessage(gEventConstants.SELECT_SHEEP, self.curSelect)
	gCS.BaseUnitModuleUtils.SetTortureLambBlendParam(self.curSelect)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
