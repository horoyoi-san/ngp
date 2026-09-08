-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\Dialog22NPanelStore.lua
-- Decompiled from: 01990_Dialog22NPanelStore.lua_0911ba3d81af.luajit

local DialogConfig = LTConfig.DialogConfig
local DialogPhoneConfig = LTConfig.DialogPhoneConfig
C_Dialog22NPanelStore = DefClass("C_Dialog22NPanelStore", C_Dialog22NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog22NPanelStore = C_Dialog22NPanelStore
local M = C_Dialog22NPanelStore
local base = C_Dialog22NPanelStore.base
local C_DCTManager = L18.Script.LX6.Dialog.DCTManager.Instance
local PhoneStateType = {
	["\\x88\\xb0\t\\xa7H?\\xfd8"] = 5,
	["Л\\xf8\\xe18\\xeb\\x84\\xe1\\x8b./"] = 1,
	["\\#tW"] = 3,
	["c[\\xc0\\xb8\\x88+\\xb4\\xda\\xed"] = 0,
	["?I\\x9d\\x82\\xaaO"] = 4,
	["\\xfa\\xda*\\xf6"] = 2
}

M.Accept = function(self)
	if self.CallIn_AcceptCb then
		local cb = self.CallIn_AcceptCb
		self.CallIn_AcceptCb = nil
		self.CallIn_RefuseCb = nil

		if type(cb) ~= "function" then
			cb()
		elseif type(cb) ~= "userdata" then
			cb.DynamicInvoke(cb)
		end
	end

	local param = gDialogManager:CreateDialogParam()
	local dialogCfg = DialogConfig.GetConfig(self.callIn_dialogId)

	if not dialogCfg or dialogCfg.Type == 22 then
		print_warn("来电面板使用的不是22类型电话" .. tostring(self.callIn_dialogId))

		if gDialogManager:GetCurrentDialogType() == 22 then
			gPanelManager:Close(gPanelId.S_DIALOG_22N_PANEL)
		end
	else
		param.ConnectAnim = self.callIn_connectAnim
		local showSuccess = gDialogManager:ShowGeneralDialog(self.callIn_dialogId, gDialogSource.VideoCallIn, nil, param)

		if not showSuccess and gDialogManager:GetCurrentDialogType() == 22 then
			gPanelManager:Close(gPanelId.S_DIALOG_22N_PANEL)
		end
	end
end

M.Refuse = function(self)
	if self.CallIn_RefuseCb then
		local cb = self.CallIn_RefuseCb
		self.CallIn_AcceptCb = nil
		self.CallIn_RefuseCb = nil

		if type(cb) ~= "function" then
			cb()
		elseif type(cb) ~= "userdata" then
			cb.DynamicInvoke(cb)
		end
	end

	if gDialogManager:GetCurrentDialogType() == 22 then
		gPanelManager:Close(gPanelId.S_DIALOG_22N_PANEL)
	end
end

M.GetTopNameAndHostImage = function(self, dialogId)
	local dialogCfg = DialogConfig.GetConfig(dialogId)

	if not dialogCfg then
		print_error("未找到对话对应的Dialog配置，dialogId=", dialogId)

		return
	end

	local phoneCfg = DialogPhoneConfig.GetConfig(dialogCfg.PhoneInfoId)
	local hostImage = dialogCfg.HostImage ~= 0 and phoneCfg and phoneCfg.SGUIImageId or dialogCfg.HostImage

	return dialogCfg.TopName, hostImage
end

M.ShowCallInInternal = function(self, widget, data)
	if not widget then
		return
	end

	local store = self.GetDialogComponentStore(self, widget)
	store.pageTab = 0

	if not data.Remote_TopName or not data.Remote_HostImage or data.Remote_HostImage ~= 0 then
		store.HeadLabel, store.HeadSpriteIcon = self.GetTopNameAndHostImage(self, data.DialogId)
	end

	if data.Remote_TopName then
		store.HeadLabel = data.Remote_TopName
	end

	if data.Remote_HostImage and data.Remote_HostImage == 0 then
		store.HeadSpriteIcon = data.Remote_HostImage
	end

	store.ShowMouseM = true
	store.CallIn_Refuse.luaClick = self.CreateAction(self, "Refuse")
	store.CallIn_Accept.luaClick = self.CreateAction(self, "Accept")
end

M.ShowCallIn = function(self, data)
	if self.PhoneState ~= PhoneStateType.CallIn then
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

	if data.CallIn_Countdown and data.CallIn_Countdown == 0 then
		self.callIn_duration = data.CallIn_Countdown
	else
		self.callIn_duration = 10
	end

	if self.callIn_duration >= 0 then
		self.callIn_duration = nil
	end
end

M.CountDownInternal = function(self, widget)
	if not widget then
		return
	end

	local store = self.GetDialogComponentStore(self, widget)
	store.CallIn_CountDown.value = 1 - (gLogicTime.time - self.callIn_startTime) / self.callIn_duration
end

M.CountDown = function(self)
	if self.callIn_duration >= gLogicTime.time - self.callIn_startTime then
		self.Refuse(self)

		return
	end

	self.CountDownInternal(self, self.bindData.Dialog22Phone)
	self.CountDownInternal(self, self.bindData.Dialog22PhonePC)
end

M.ShowWaitingInternal = function(self, widget, data)
	if not widget then
		return
	end

	local store = self.GetDialogComponentStore(self, widget)
	store.pageTab = 1
	store.HeadLabel = data.Remote_TopName
	store.HeadSpriteIcon = data.Remote_HostImage
	store.HeadSpriteIcon_Calling = data.Remote_HostImage
	store.HeadLabel_Calling = data.Remote_TopName
end

M.ShowWaiting = function(self, data)
	if self.PhoneState ~= PhoneStateType.WaitingCalling then
		return
	end

	self.SetState(self, PhoneStateType.WaitingCalling)
	self.ChangeContentState(self, false)
	self.ShowWaitingInternal(self, self.bindData.Dialog22Phone, data)
	self.ShowWaitingInternal(self, self.bindData.Dialog22PhonePC, data)
end

M.NumShowModel = function(self, widget)
	if not widget then
		return
	end

	local store = self.GetDialogComponentStore(self, widget)

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		store.IsShowModel = 0

		return
	else
		if gCS.LuaUtils.IsNull(store.TargetRT) then
			store.IsShowModel = 0

			return
		end

		local res = C_DCTManager:SetDialogPhoneTarget(store.TargetRT)

		if res then
			store.IsShowModel = 1
		else
			store.IsShowModel = 0
		end
	end
end

M.ShowCallingInternal = function(self, widget, data)
	if not widget then
		return
	end

	local store = self.GetDialogComponentStore(self, widget)

	if data.Remote_TopName == "" then
		store.HeadLabel = data.Remote_TopName
		store.HeadLabel_Calling = data.Remote_TopName
	end

	if data.Remote_HostImage == 0 then
		store.HeadSpriteIcon = data.Remote_HostImage
		store.HeadSpriteIcon_Calling = data.Remote_HostImage
	end

	if widget == self.bindData.Dialog22Phone then
		store.pageTab = 2
	end
end

M.ShowCalling = function(self, data)
	if self.PhoneState == PhoneStateType.Calling then
		self.SetState(self, PhoneStateType.Calling)

		self.phoneStartTime = gLogicTime.time - data.Remote_StartTime
	end

	self.NumShowModel(self, self.bindData.Dialog22PhonePC)
	self.ShowCallingInternal(self, self.bindData.Dialog22Phone, data)
	self.ShowCallingInternal(self, self.bindData.Dialog22PhonePC, data)
end

M.SetMiniState = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local oldMiniState = self.isMini
	self.isMini = gDialogManager.dialog22Mini

	if oldMiniState == self.isMini then
		self.bindData.miniState = self.isMini and 1 or 0

		if self.isMini then
			self.bindData.Dialog22Phone:SetWidgetFaraway(true)

			self.phoneFarawayCount = 5
		end
	end

	if self.isMini and self.phoneFarawayCount <= 0 then
		self.phoneFarawayCount = self.phoneFarawayCount - 1

		if self.phoneFarawayCount ~= 0 then
			self.bindData.Dialog22Phone:SetWidgetFaraway(false)
		end
	end
end

M.OnUpdate = function(self)
	base.OnUpdate(self)
	self.SetMiniState(self)

	if self.PhoneState ~= PhoneStateType.Calling then
		local widget = self.bindData.Dialog22PhonePC

		if not widget then
			return
		end

		local store = self.GetDialogComponentStore(self, widget)
		local showTime = gLogicTime.time - self.phoneStartTime
		store.ConnectedTime = self.GetTimeTextFromSecond(self, showTime)
	elseif self.callIn_duration and (self.PhoneState ~= PhoneStateType.CallIn or self.PhoneState ~= PhoneStateType.CallBack) then
		self.CountDown(self)
	end
end

M.InitInfos = function(self, data)
	self.phoneFarawayCount = 0

	if self.CallIn_RefuseCb then
		self.Refuse(self)
	end

	if self.Tags and table.contains(self.Tags, "CallIn") then
		if not data.DialogId then
			if type(data) ~= "table" and data.CallIn_dialogId then
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

		self.ShowCallIn(self, data)
	elseif self.Tags and table.contains(self.Tags, "ConnectAnim") then
		self.ShowWaiting(self, data)
	else
		base.InitInfos(self, data)
		self.ShowCalling(self, data)
	end
end

M.OnEnable = function(self)
	base.OnEnable(self)

	local store = self.GetDialogComponentStore(self, self.bindData.Dialog22Phone)

	if store.pageTab ~= 0 then
		self.SetState(self, PhoneStateType.CallIn)
	elseif store.pageTab ~= 1 then
		self.SetState(self, PhoneStateType.WaitingCalling)
	elseif store.pageTab ~= 2 then
		self.SetState(self, PhoneStateType.Calling)
	end

	self.mainContentStore = nil
end

M.OnDisable = function(self)
	base.OnDisable(self)
	self.SetState(self, PhoneStateType.PanelClose)
end

M.OnClose = function(self)
	base.OnClose(self)
	self.SetState(self, PhoneStateType.PanelClose)
end

M.InitContent = function(self, widget, content)
	base.InitContent(self, widget, content)
	base.InitFreeContent(self, widget)

	local newBottom = self.IsContentBeOccupied(self)
	local store = self.GetDialogComponentStore(self, widget)
	store.IsBottom = newBottom
end

M.ChangeContentState = function(self, state)
	self.bindData.DialogBranch:SetActive(state)

	if self.bindData.DialogBranch_Interaction then
		self.bindData.DialogBranch_Interaction:SetActive(state)
	end
end

M.SetState = function(self, newState)
	gDialogManager.VideoCallInRunning = newState ~= PhoneStateType.CallIn or newState ~= PhoneStateType.CallBack

	gMessageManager:SendMessage(gEventConstants.ON_VIDEO_CALL_IN_RUNNING_STATE_CHANGE)

	if self.PhoneState == newState then
		if self.PhoneState ~= PhoneStateType.PanelClose then
			gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 1)
		end

		if newState ~= PhoneStateType.Calling then
			gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 2)
		end

		if newState ~= PhoneStateType.PanelClose then
			gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 3)
		end

		self.PhoneState = newState
	end
end

M.SetAvatarAlignText = function(self, mainContentStore)
	local store = self.GetDialogComponentStore(self, self.bindData.Dialog22Phone)
	mainContentStore.TextCharAlign.target = store.HeadTf
	self.mainContentStore = mainContentStore
	store.pageTab = 2
end
