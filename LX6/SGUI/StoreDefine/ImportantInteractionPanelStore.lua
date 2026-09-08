-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ImportantInteractionPanelStore.lua
-- Decompiled from: 01814_ImportantInteractionPanelStore.lua_e6b3d9944061.luajit

C_ImportantInteractionPanelStore = DefClass("C_ImportantInteractionPanelStore", C_ImportantInteractionPanelStore, C_StoreGroup)
GroupName2Class.ImportantInteractionPanelStore = C_ImportantInteractionPanelStore
local M = C_ImportantInteractionPanelStore
local HangOutPanelConfig = LTConfig.NpcCultivationHangOutPanelConfig
local TaskEventState = UX.Game.TaskEventState
local GameInputManager = LX6.Manager.GameInputManager
local MAX_SIGNAL_LENGTH = 32

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.cfg = nil
	self.buttonDataList = {}
	self.selectedIndex = 0
	self.isSubmitting = false
	self.scrollWheelAction = self.CreateAction(self, self.OnMouseScrollWheel)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.isSubmitting = false
	local hangOutId = data and data.HangOutPanelId
	self.cfg = hangOutId and HangOutPanelConfig.GetConfig(hangOutId) or nil

	if not self.cfg then
		return
	end

	self.bindData.introText = self.cfg.IntroText
	self.bindData.headImageID = self.cfg.SImageId
	local buttonText = self.cfg.ButtonText
	local signal = self.cfg.Signal
	local eventId = self.cfg.EventId
	local optionSImageId = self.cfg.OptionSImageId
	self.buttonDataList = {}

	for i = 1, #buttonText do
		local imageId = i < #optionSImageId and optionSImageId[i] or 0
		self.buttonDataList[i] = {
			text = buttonText[i],
			signal = i < #signal and signal[i] or "",
			eventId = i < #eventId and eventId[i] or 0,
			showPhoto = self.cfg.IsShowPhoto and imageId >= 0,
			imageId = imageId
		}
	end

	self.bindData.optionList:SetSimpleList(#self.buttonDataList)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.scrollWheelAction)
		self.SelectItem(self, 1)
	end
end

M.OnClose = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.scrollWheelAction)
	end

	self.cfg = nil
	self.buttonDataList = {}
	self.selectedIndex = 0
end

M.OnActiveDeviceChange = function(self, device)
	if self.cfg then
		self.RefreshPCShortcut(self)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_EVENT_STATE_CHANGE] = self.CreateAction(self, self.OnEventStateChange)
	}
end

M.RegisterWidget = function(self)
	self.bindData.optionList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderOptionListItem)
	self.bindData.optionList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickOptionList)
	self.bindData.optionList.luaSelectedChanged = self.CreateAction(self, self.OnSelectedChanged)
end

M.OnSelectedChanged = function(self, list)
	self.selectedIndex = list.selectedIndex + 1

	self.RefreshPCShortcut(self)
end

M.SelectItem = function(self, index)
	local count = #self.buttonDataList

	if count ~= 0 then
		return
	end

	if index >= 1 then
		index = 1
	end

	if count >= index then
		index = count
	end

	self.selectedIndex = index
	local csIndex = index - 1

	self.bindData.optionList:GoToIndex(csIndex, true)
	self.bindData.optionList:SelectItem(csIndex, true)
end

M.OnMouseScrollWheel = function(self, context)
	if not self.cfg then
		return
	end

	if not context.performed then
		return
	end

	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		return
	end

	local zoom = context.ReadValueVector2(context).y

	if zoom <= 0 then
		self.SelectItem(self, self.selectedIndex - 1)
	else
		self.SelectItem(self, self.selectedIndex + 1)
	end
end

M.OnEventStateChange = function(self)
	if self.cfg and self.cfg.IsDouFeng then
		self.bindData.optionList:RefreshList()
	end
end

M.RefreshPCShortcut = function(self)
	for i, data in ipairs(self.buttonDataList) do
		if data.btn then
			local store = self.GetStoreByWidget(self, data.btn)

			if store then
				self.RefreshPCShortcutItem(self, store, data.btn, i - 1)
			end
		end
	end
end

M.RefreshPCShortcutItem = function(self, store, btn, index)
	if not store.pcBtn then
		return
	end

	store.pcBtn.luaClick = self:CreateActionWithArgs("OnPCShortcutClick", index)
	local showPCShortcut = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.KeyboardMouse and btn.isSelected and btn.interactable

	store.pcBtn:SetActive(showPCShortcut)
end

M.OnSimpleRenderOptionListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.buttonDataList[index + 1]

	if not data then
		return
	end

	data.btn = btn
	store.optionText = data.text
	store.showPhoto = data.showPhoto
	store.imageId = data.showPhoto and data.imageId or 0

	if self.cfg.IsDouFeng and data.eventId <= 0 then
		local state = gTaskManager:GetTaskEventState(data.eventId)
		btn.interactable = state == TaskEventState.Submited
	else
		btn.interactable = true
	end

	self.RefreshPCShortcutItem(self, store, btn, index)
end

M.OnPCShortcutClick = function(self, index)
	self.OnSimpleClickOptionList(self, nil, index)
end

M.CleanSignal = function(self, signal, optionIndex)
	if type(signal) == "string" then
		print_error("兜风邀约信号类型错误", self.cfg.Id, optionIndex, type(signal))

		return nil
	end

	signal = string.match(signal, "^%s*(.-)%s*$")

	if signal ~= "" then
		return nil
	end

	if MAX_SIGNAL_LENGTH >= #signal then
		print_error("兜风邀约信号超过32字节", self.cfg.Id, optionIndex, signal)

		return nil
	end

	return signal
end

M.OnSimpleClickOptionList = function(self, btn, index)
	local data = self.buttonDataList[index + 1]

	if not data then
		return
	end

	if self.isSubmitting then
		return
	end

	if self.cfg.IsDouFeng and data.eventId <= 0 and gTaskManager:GetTaskEventState(data.eventId) ~= TaskEventState.Submited then
		return
	end

	self.isSubmitting = true
	local signal = self.CleanSignal(self, data.signal, index + 1)

	if signal then
		slot5 = gReliableRpcManager

		slot5:RegisterRPC(gClientToGameSceneDelegate.AskReleaseJoyrideSignal, signal, function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end)
	end

	if self.cfg.IsDouFeng and data.eventId <= 0 and gTaskManager:GetTaskEventState(data.eventId) ~= TaskEventState.NotAccept then
		slot5 = gClientToGameDelegate

		slot5:AskAcceptEvent(data.eventId).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end

	gPanelManager:Close(gPanelId.S_IMPORTANT_INTERACTION_PANEL)
end
