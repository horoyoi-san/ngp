C_DialogControlPanelStore = DefClass("C_DialogControlPanelStore", C_DialogControlPanelStore, C_StoreGroup)
GroupName2Class.DialogControlPanelStore = C_DialogControlPanelStore
local M = C_DialogControlPanelStore

function M:OnAwake()
	self.mode = 0

	if not self.EventHandler then
		self.EventHandler = {
			[gEventConstants.DIALOG_REFRESH_CONTROLLER] = function (eventId, param)
				self:SetBtnStateByCS(param)
			end
		}
	end
end

function M:OnUpdate()
	if self.mode == 0 then
		return
	end

	if gDialogManager:IsBranchShowing() then
		self.bindData.DialogControl:SetActive(false)
	else
		self.bindData.DialogControl:SetActive(true)
	end
end

function M:OnShow(panelId, data)
	local store = self:GetDialogComponentStore(self.bindData.DialogControl)
	self.store = store
	store.btnReview.luaClick = self:CreateAction("OnHistoryClick")
	store.btnSetting.luaClick = self:CreateAction("OnSettingClick")
	store.btnSpeed0.luaClick = self:CreateAction("OnSpeedClick")
	store.btnSpeed1.luaClick = self:CreateAction("OnSpeedClick")
	store.btnSpeed2.luaClick = self:CreateAction("OnSpeedClick")
	store.btnSpeed3.luaClick = self:CreateAction("OnSpeedClick")
	store.btnSkip.luaClick = self:CreateAction("OnJumpDialogClick")

	self:SetBtnStateByCS(data)
end

function M:OnEnable()
	self:BindListener()
end

function M:OnDisable()
	self:UnbindListener()
end

function M:OnClose()
	self.mode = 0
end

function M:BindListener()
	if not self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		self.IsBindListener = true
	end
end

function M:UnbindListener()
	if self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:RemoveMessageListener(i, v)
		end

		self.IsBindListener = false
	end
end

function M:GetDialogComponentStore(widget)
	return gStoreManager:GetStoreGroup("S_DialogComponentStore"):GetStoreByWidget(widget)
end

function M:SetBtnStateByCS(data)
	local param = data:ToTable()

	self:SetBtnState(param.mode, param.showSpeed, param.showSkip, param.speedIndex)
end

function M:SetBtnState(mode, showSpeed, showSkip, speedIndex)
	if not self.store then
		return
	end

	self.mode = mode

	if mode == 0 then
		self:ShowSkip(false)
		self:ShowSpeed(false)
		self:ShowSetting(false)
		self:ShowReview(false)
	elseif mode == 1 then
		self:ShowSkip(showSkip)
		self:ShowSpeed(showSpeed)
		self:ShowReview(false)
		self:ShowSetting(false)

		if showSpeed then
			self:SetSpeedBtnState(speedIndex)
		end
	elseif mode == 2 then
		self:ShowSkip(showSkip)
		self:ShowSpeed(showSpeed)
		self:ShowReview(false)
		self:ShowSetting(false)

		if showSpeed then
			self:SetSpeedBtnState(speedIndex)
		end
	elseif mode == 3 then
		self:ShowSkip(false)
		self:ShowSpeed(false)
		self:ShowSetting(false)
		self:ShowReview(false)
	end
end

function M:SetSpeedBtnState(speedIndex)
	if not self.store.btnSpeed0 then
		return
	end

	self.store.btnSpeed0:SetActive(speedIndex == 0)
	self.store.btnSpeed1:SetActive(speedIndex == 1)
	self.store.btnSpeed2:SetActive(speedIndex == 2)
	self.store.btnSpeed3:SetActive(speedIndex == 3)
end

function M:ShowSkip(enable)
	if not self.store.btnSkip then
		return
	end

	self.store.btnSkip:SetActive(enable)
end

function M:ShowSpeed(enable)
	if not self.store.btnSpeedRoot then
		return
	end

	self.store.btnSpeedRoot:SetActive(enable)
end

function M:ShowSetting(enable)
	if not self.store.btnSetting then
		return
	end

	self.store.btnSetting:SetActive(enable)
end

function M:ShowReview(enable)
	if not self.store.btnReview then
		return
	end

	self.store.btnReview:SetActive(enable)
end

function M:OnHistoryClick()
	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		type = 2,
		dialogId = self.dialogId
	})
end

function M:OnJumpDialogClick()
	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		type = 3,
		dialogId = self.dialogId
	})
end

function M:OnSpeedClick()
	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		type = 4,
		dialogId = self.dialogId
	})
end

function M:OnSettingClick()
	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		type = 6,
		dialogId = self.dialogId
	})
end
