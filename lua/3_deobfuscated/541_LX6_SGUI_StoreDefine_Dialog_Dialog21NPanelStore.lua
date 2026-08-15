C_Dialog21NPanelStore = DefClass("C_Dialog21NPanelStore", C_Dialog21NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog21NPanelStore = C_Dialog21NPanelStore
local M = C_Dialog21NPanelStore
local base = C_Dialog21NPanelStore.base
local GuiMgr = LX6.GUI.GuiMgr
local PhoneStateType = {
	PanelClose = 0,
	WaitingCalling = 1,
	Calling = 2
}

function M:BindListener()
	self.EventHandler[gEventConstants.HIDE_DIALOG_INCALL_MESSAGE] = function (eventId, isHide)
		if self.bindData and self.bindData.CallMessage then
			if isHide then
				self.bindData.CallMessage.transform:SetLocalScale(0, 0, 1)
			else
				self.bindData.CallMessage.transform:SetLocalScale(1, 1, 1)
			end
		end
	end

	base.BindListener(self)
end

function M:OnDisable()
	base.OnDisable(self)
	self:ShowJoyStick(false)
end

function M:ShowJoyStick(enable)
	if self.stickShowing ~= enable then
		self.stickShowing = enable

		GuiMgr.Instance:SetShowJoystick(enable, gPanelId.S_PHOTO_PANEL)

		if enable then
			gClientUtils.PlayPhoneAction()
		else
			gClientUtils.ExitPhoneAction()
		end

		gCS.TransitionMgr.showMainCube = enable
		gCS.TransitionMgr.IsExitPhoneAction = not enable
	end
end

function M:OnClose()
	base.OnClose(self)

	self.PhoneState = PhoneStateType.PanelClose

	gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 3)
end

function M:InitDialogComponent(data)
	base.InitDialogComponent(self, data)

	if self.bindData.Dialog21Phone then
		self:Init21Phone(self.bindData.Dialog21Phone, data)
		table.insert(self.activatedComponent, self.DialogComponents.Dialog21Phone)
	end
end

function M:InitContent(widget, content)
	base.InitContent(self, widget, content)
	base.InitFreeContent(self, widget)

	function self.ChangeContentState(state)
		widget:SetActive(state)
	end

	local store = self:GetDialogComponentStore(widget)
	store.NextButton.luaClick = self:CreateAction("OnNextDialogClick")

	function self.refreshNextFunc(param)
		store.NextButton:SetActive(param.Content_ShowNext)
	end

	self.refreshNextFunc(content)
end

function M:Waiting(store)
	if self.PhoneState ~= PhoneStateType.WaitingCalling then
		gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 1)

		self.PhoneState = PhoneStateType.WaitingCalling
		store.pageTab = 1

		self.ChangeContentState(false)
		Timer.New(function ()
			self:Calling(store)
		end, 2):Start()
	end
end

function M:Calling(store)
	if self.PhoneState ~= PhoneStateType.Calling then
		if self.PhoneState == PhoneStateType.PanelClose then
			gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 1)
		end

		self.PhoneState = PhoneStateType.Calling
		store.pageTab = 2
		self.phoneStartTime = gLogicTime.time

		self.ChangeContentState(true)
		gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 2)
	end
end

function M:Init21Phone(widget, data)
	local store = self:GetDialogComponentStore(widget)

	if store.AutoReleaseRT and data.Remote_Camera then
		store.AutoReleaseRT:SetCamera(data.Remote_Camera)
	end

	if data.Remote_ShowJoyStick then
		self:ShowJoyStick(true)
	end

	store.HeadLabel = data.Remote_TopName
	store.HeadSpriteIcon = data.Remote_HostImage

	local function phoneTimeFunc()
		if self.PhoneState == PhoneStateType.Calling then
			local showTime = gLogicTime.time - (self.phoneStartTime or 0)
			store.ConnectedTime = self:GetTimeTextFromSecond(showTime)
		end
	end

	table.insert(self.updateFunc, phoneTimeFunc)

	if self.Tags and table.contains(self.Tags, "ConnectAnim") and (not self.PhoneState or self.PhoneState == PhoneStateType.PanelClose) then
		self:Waiting(store)
	else
		self:Calling(store)
	end
end
