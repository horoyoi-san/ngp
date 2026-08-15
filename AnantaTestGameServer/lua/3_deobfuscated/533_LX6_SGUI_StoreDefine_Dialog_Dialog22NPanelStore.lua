local DialogConfig = LTConfig.DialogConfig
local DialogPhoneConfig = LTConfig.DialogPhoneConfig
local CS_DialogManager = L18.Script.LX6.Dialog.DialogManager
C_Dialog22NPanelStore = DefClass("C_Dialog22NPanelStore", C_Dialog22NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog22NPanelStore = C_Dialog22NPanelStore
local M = C_Dialog22NPanelStore
local base = C_Dialog22NPanelStore.base
local C_DCTManager = L18.Script.LX6.Dialog.DCTManager.Instance
local PhoneStateType = {
	CallBack = 5,
	WaitingCalling = 1,
	Fail = 3,
	PanelClose = 0,
	CallIn = 4,
	Calling = 2
}

function M:Accept()
	if self.CallIn_AcceptCb then
		local cb = self.CallIn_AcceptCb
		self.CallIn_AcceptCb = nil
		self.CallIn_RefuseCb = nil

		if type(cb) == "function" then
			cb()
		elseif type(cb) == "userdata" then
			cb:DynamicInvoke()
		end
	end

	local param = gDialogManager:CreateDialogParam()
	local dialogCfg = DialogConfig.GetConfig(self.callIn_dialogId)

	if not dialogCfg or dialogCfg.Type ~= 22 then
		print_warn("来电面板使用的不是22类型电话" .. tostring(self.callIn_dialogId))

		if gDialogManager:GetCurrentDialogType() ~= 22 then
			gPanelManager:Close(gPanelId.S_DIALOG_22N_PANEL)
		end
	else
		param.ConnectAnim = self.callIn_connectAnim
		local showSuccess = gDialogManager:ShowGeneralDialog(self.callIn_dialogId, gDialogSource.VideoCallIn, nil, param)

		if not showSuccess and gDialogManager:GetCurrentDialogType() ~= 22 then
			gPanelManager:Close(gPanelId.S_DIALOG_22N_PANEL)
		end
	end
end

function M:Refuse()
	if self.CallIn_RefuseCb then
		local cb = self.CallIn_RefuseCb
		self.CallIn_AcceptCb = nil
		self.CallIn_RefuseCb = nil

		if type(cb) == "function" then
			cb()
		elseif type(cb) == "userdata" then
			cb:DynamicInvoke()
		end
	end

	if gDialogManager:GetCurrentDialogType() ~= 22 then
		gPanelManager:Close(gPanelId.S_DIALOG_22N_PANEL)
	end
end

function M:GetTopNameAndHostImage(dialogId)
	local dialogCfg = DialogConfig.GetConfig(dialogId)

	if not dialogCfg then
		print_error("未找到对话对应的Dialog配置，dialogId=", dialogId)

		return
	end

	local phoneCfg = DialogPhoneConfig.GetConfig(dialogCfg.PhoneInfoId)
	local hostImage = dialogCfg.HostImage == 0 and phoneCfg and phoneCfg.SGUIImageId or dialogCfg.HostImage

	return dialogCfg.TopName, hostImage
end

function M:ShowCallInInternal(widget, data)
	if not widget then
		return
	end

	local store = self:GetDialogComponentStore(widget)
	store.pageTab = 0

	if not data.Remote_TopName or not data.Remote_HostImage or data.Remote_HostImage == 0 then
		store.HeadLabel, store.HeadSpriteIcon = self:GetTopNameAndHostImage(data.DialogId)
	end

	if data.Remote_TopName then
		store.HeadLabel = data.Remote_TopName
	end

	if data.Remote_HostImage and data.Remote_HostImage ~= 0 then
		store.HeadSpriteIcon = data.Remote_HostImage
	end

	store.ShowMouseM = true
	store.CallIn_Refuse.luaClick = self:CreateAction("Refuse")
	store.CallIn_Accept.luaClick = self:CreateAction("Accept")
end

function M:ShowCallIn(data)
	if self.PhoneState == PhoneStateType.CallIn then
		return
	end

	self:SetState(PhoneStateType.CallIn)
	self:ChangeContentState(false)
	self:ShowCallInInternal(self.bindData.Dialog22Phone, data)
	self:ShowCallInInternal(self.bindData.Dialog22PhonePC, data)

	self.CallIn_AcceptCb = data.CallIn_AcceptCb
	self.CallIn_RefuseCb = data.CallIn_RefuseCb
	self.callIn_dialogId = data.DialogId
	self.callIn_connectAnim = self.Tags and table.contains(self.Tags, "ConnectAnim")
	self.callIn_startTime = gLogicTime.time

	if data.CallIn_Countdown and data.CallIn_Countdown ~= 0 then
		self.callIn_duration = data.CallIn_Countdown
	else
		self.callIn_duration = 10
	end

	if self.callIn_duration < 0 then
		self.callIn_duration = nil
	end
end

function M:CountDownInternal(widget)
	if not widget then
		return
	end

	local store = self:GetDialogComponentStore(widget)
	store.CallIn_CountDown.value = 1 - (gLogicTime.time - self.callIn_startTime) / self.callIn_duration
end

function M:CountDown()
	if self.callIn_duration < gLogicTime.time - self.callIn_startTime then
		self:Refuse()

		return
	end

	self:CountDownInternal(self.bindData.Dialog22Phone)
	self:CountDownInternal(self.bindData.Dialog22PhonePC)
end

function M:ShowWaitingInternal(widget, data)
	if not widget then
		return
	end

	local store = self:GetDialogComponentStore(widget)
	store.pageTab = 1
	store.HeadLabel = data.Remote_TopName
	store.HeadSpriteIcon = data.Remote_HostImage
	store.HeadSpriteIcon_Calling = data.Remote_HostImage
	store.HeadLabel_Calling = data.Remote_TopName
end

function M:ShowWaiting(data)
	if self.PhoneState == PhoneStateType.WaitingCalling then
		return
	end

	self:SetState(PhoneStateType.WaitingCalling)
	self:ChangeContentState(false)
	self:ShowWaitingInternal(self.bindData.Dialog22Phone, data)
	self:ShowWaitingInternal(self.bindData.Dialog22PhonePC, data)
end

function M:ShowCallingInternal(widget, data)
	if not widget then
		return
	end

	local store = self:GetDialogComponentStore(widget)
	local res = C_DCTManager:SetDialogPhoneTarget(store.TargetRT)

	if res then
		store.IsShowModel = 1
	else
		store.IsShowModel = 0
	end

	if data.Remote_TopName ~= "" then
		store.HeadLabel = data.Remote_TopName
		store.HeadLabel_Calling = data.Remote_TopName
	end

	if data.Remote_HostImage ~= 0 then
		store.HeadSpriteIcon = data.Remote_HostImage
		store.HeadSpriteIcon_Calling = data.Remote_HostImage
	end

	store.pageTab = 2
end

function M:ShowCalling(data)
	if self.PhoneState ~= PhoneStateType.Calling then
		self:SetState(PhoneStateType.Calling)

		self.phoneStartTime = gLogicTime.time - data.Remote_StartTime
	end

	self:ShowCallingInternal(self.bindData.Dialog22Phone, data)
	self:ShowCallingInternal(self.bindData.Dialog22PhonePC, data)
end

function M:SetMiniState()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local isMini = CS_DialogManager.IsDialog22Mini()
		self.bindData.miniState = isMini and 1 or 0
	end
end

function M:OnUpdate()
	base.OnUpdate(self)
	self:SetMiniState()

	if self.PhoneState == PhoneStateType.Calling then
		local widget = self.bindData.Dialog22PhonePC

		if not widget then
			return
		end

		local store = self:GetDialogComponentStore(widget)
		local showTime = gLogicTime.time - self.phoneStartTime
		store.ConnectedTime = self:GetTimeTextFromSecond(showTime)
	elseif self.callIn_duration and (self.PhoneState == PhoneStateType.CallIn or self.PhoneState == PhoneStateType.CallBack) then
		self:CountDown()
	end
end

function M:InitInfos(data)
	if self.CallIn_RefuseCb then
		self:Refuse()
	end

	if self.Tags and table.contains(self.Tags, "CallIn") then
		if not data.DialogId then
			if type(data) == "table" and data.CallIn_dialogId then
				data.DialogId = data.CallIn_dialogId
			else
				print_error("未添加Dialog参数")

				return
			end
		end

		if not DialogConfig.GetConfig(data.DialogId) then
			print_error("未找到DialogId配置，DialogId=" .. data.DialogId)

			return
		end

		self:ShowCallIn(data)
	elseif self.Tags and table.contains(self.Tags, "ConnectAnim") then
		self:ShowWaiting(data)
	else
		base.InitInfos(self, data)
		self:ShowCalling(data)
	end
end

function M:OnEnable()
	base.OnEnable(self)

	local store = self:GetDialogComponentStore(self.bindData.Dialog22Phone)

	if store.pageTab == 0 then
		self:SetState(PhoneStateType.CallIn)
	elseif store.pageTab == 1 then
		self:SetState(PhoneStateType.WaitingCalling)
	elseif store.pageTab == 2 then
		self:SetState(PhoneStateType.Calling)
	end
end

function M:OnDisable()
	base.OnDisable(self)
	self:SetState(PhoneStateType.PanelClose)
end

function M:OnClose()
	base.OnClose(self)
	self:SetState(PhoneStateType.PanelClose)
end

function M:InitContent(widget, content)
	base.InitContent(self, widget, content)
	base.InitFreeContent(self, widget)

	local newBottom = self:IsContentBeOccupied()
	local store = self:GetDialogComponentStore(widget)
	store.IsBottom = newBottom
end

function M:ChangeContentState(state)
	self.bindData.DialogContent:SetActive(state)
	self.bindData.DialogBranch:SetActive(state)

	if self.bindData.DialogBranch_Interaction then
		self.bindData.DialogBranch_Interaction:SetActive(state)
	end
end

function M:SetState(newState)
	gDialogManager.VideoCallInRunning = newState == PhoneStateType.CallIn or newState == PhoneStateType.CallBack

	gMessageManager:SendMessage(gEventConstants.ON_VIDEO_CALL_IN_RUNNING_STATE_CHANGE)

	if self.PhoneState ~= newState then
		if self.PhoneState == PhoneStateType.PanelClose then
			gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 1)
		end

		if newState == PhoneStateType.Calling then
			gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 2)
		end

		if newState == PhoneStateType.PanelClose then
			gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 3)
		end

		self.PhoneState = newState
	end
end
