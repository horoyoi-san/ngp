-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\Dialog21NPanelStore.lua
-- Decompiled from: 01989_Dialog21NPanelStore.lua_bec6154cca82.luajit

C_Dialog21NPanelStore = DefClass("C_Dialog21NPanelStore", C_Dialog21NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog21NPanelStore = C_Dialog21NPanelStore
local M = C_Dialog21NPanelStore
local base = C_Dialog21NPanelStore.base
local GuiMgr = LX6.GUI.GuiMgr
local PhoneStateType = {
	["c[\\xc0\\xb8\\x88+\\xb4\\xda\\xed"] = 0,
	["Л\\xf8\\xe18\\xeb\\x84\\xe1\\x8b./"] = 1,
	["\\xfa\\xda*\\xf6"] = 2
}

M.BindListener = function(self)
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

M.OnDisable = function(self)
	base.OnDisable(self)
	self.ShowJoyStick(self, false)
end

M.ShowJoyStick = function(self, enable)
	if self.stickShowing == enable then
		self.stickShowing = enable

		GuiMgr.Instance:SetShowJoystick(enable, gPanelId.S_PHOTO_PANEL)

		if enable then
			gCS.TransitionMgr.IsPlayPhoneAction = true
			gCS.TransitionMgr.IsExitPhoneAction = false
			gCS.TransitionMgr.showMainCube = true

			gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
		else
			gCS.TransitionMgr.IsPlayPhoneAction = false
			gCS.TransitionMgr.IsExitPhoneAction = true
			gCS.TransitionMgr.showMainCube = false
		end
	end
end

M.OnClose = function(self)
	base.OnClose(self)

	self.PhoneState = PhoneStateType.PanelClose

	gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 3)
end

M.InitDialogComponent = function(self, data)
	base.InitDialogComponent(self, data)

	if self.bindData.Dialog21Phone then
		self.Init21Phone(self, self.bindData.Dialog21Phone, data)
		table.insert(self.activatedComponent, self.DialogComponents.Dialog21Phone)
	end
end

M.InitContent = function(self, widget, content)
	base.InitContent(self, widget, content)
	base.InitFreeContent(self, widget)

	self.ChangeContentState = function(state)
		widget:SetActive(state)
	end

	local store = self.GetDialogComponentStore(self, widget)
	store.NextButton.luaClick = self.CreateAction(self, "OnNextDialogClick")

	self.refreshNextFunc = function(param)
		store.NextButton:SetActive(param.Content_ShowNext)
	end

	self.refreshNextFunc(content)
end

M.Waiting = function(self, store)
	if self.PhoneState == PhoneStateType.WaitingCalling then
		gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 1)

		self.PhoneState = PhoneStateType.WaitingCalling
		store.pageTab = 1

		self.ChangeContentState(false)
		Timer.New(function ()
			self:Calling(store)
		end, 2):Start()
	end
end

M.Calling = function(self, store)
	if self.PhoneState == PhoneStateType.Calling then
		if self.PhoneState ~= PhoneStateType.PanelClose then
			gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 1)
		end

		self.PhoneState = PhoneStateType.Calling
		store.pageTab = 2
		self.phoneStartTime = gLogicTime.time

		self.ChangeContentState(true)
		gMessageManager:SendMessage(gEventConstants.MULTI_DIALOG_MOVE_STATUS, 2)
	end
end

M.Init21Phone = function(self, widget, data)
	local store = self.GetDialogComponentStore(self, widget)

	if store.AutoReleaseRT and data.Remote_Camera then
		store.AutoReleaseRT:SetCamera(data.Remote_Camera)
	end

	if data.Remote_ShowJoyStick then
		self.ShowJoyStick(self, true)
	end

	store.HeadLabel = data.Remote_TopName
	store.HeadSpriteIcon = data.Remote_HostImage

	local phoneTimeFunc = function()
		if self.PhoneState ~= PhoneStateType.Calling then
			local showTime = gLogicTime.time - (self.phoneStartTime or 0)
			store.ConnectedTime = self:GetTimeTextFromSecond(showTime)
		end
	end

	table.insert(self.updateFunc, phoneTimeFunc)

	if self.Tags and table.contains(self.Tags, "ConnectAnim") and (not self.PhoneState or self.PhoneState ~= PhoneStateType.PanelClose) then
		self.Waiting(self, store)
	else
		self.Calling(self, store)
	end
end
