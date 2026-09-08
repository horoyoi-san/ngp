-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MessagePanelStore.lua
-- Decompiled from: 00972_MessagePanelStore.lua_3ca0be8d79a3.luajit

local GameConfig = LTConfig.GameConfig
C_MessagePanelStore = DefClass("C_MessagePanelStore", C_MessagePanelStore, C_StoreGroup)
GroupName2Class.MessagePanelStore = C_MessagePanelStore
local M = C_MessagePanelStore
local MSG_MAX_NUM = 1

M.ctor = function(self)
	self.msgList = {}
	self.displayList = {}
	self.updateTime = {}
	self.DEFINE_DynamicOnUpdate = true
end

M.OnAwake = function(self)
	gLuaUIMgr.commonQueueMessage = self
	self.CONTROL = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.msgEvents = {
		[gEventConstants.MESSAGE_CLEAR] = self.CreateAction(self, "OnMessageClear"),
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = self.CreateAction(self, "OnBeforeSwitchScene"),
		[gEventConstants.POPUP_LINE_STATE_CHANGE] = self.CreateAction(self, "OnPopUpLineStateChange")
	}

	self.RegisterMessageEvents(self, self.msgEvents)

	self.bindData.messageList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderMessageListItem")
end

M.OnDestroy = function(self)
	gLuaUIMgr.commonQueueMessage = nil

	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
	gStoreManager:UnregisterDynamicOnUpdate(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnLanguageChange = function(self, lang)
	self.OnMessageClear(self)
end

M.OnBeforeSwitchScene = function(self, switchSceneEventParams)
	self.msgList = {}

	self.RefreshMessageDisplay(self)
end

M.OnMessageClear = function(self)
	self.msgList = {}

	self.RefreshMessageDisplay(self)
end

M.CheckInUpdate = function(self)
	if not self.updateTime[1] or self.updateTime[1] < Time.unscaledTime then
		gStoreManager:UnregisterDynamicOnUpdate(self)

		return false
	end

	gStoreManager:RegisterDynamicOnUpdate(self)

	return true
end

M.OnUpdate = function(self)
	self.RefreshMessageDisplay(self)
end

M.RefreshMessageDisplay = function(self)
	self.displayList = {}
	self.updateTime = {}

	for i = 1, #self.msgList do
		if MSG_MAX_NUM < #self.displayList then
			break
		end

		local ele = self.msgList[i]

		if ele.hideTime ~= 0 then
			ele.hideTime = Time.unscaledTime + ele.autoHideTime
		end

		if Time.unscaledTime >= ele.hideTime then
			table.insert(self.displayList, ele)
			table.insert(self.updateTime, ele.hideTime)
		end
	end

	self.bindData.messageList:SetSimpleList(#self.displayList)
	self:CheckInUpdate()
end

M.ClearMessageList = function(self)
	local tmp = {}
	self.msgList = tmp
end

M.ShowAutoHideMessage = function(self, message, autoHideTime)
	autoHideTime = autoHideTime or GameConfig.HideMessageAfter

	self:ClearMessageList()

	local ele = {
		["\\xa3\\xb8\\xae^7\\xf36"] = 0,
		label = message,
		autoHideTime = autoHideTime
	}

	table.insert(self.msgList, ele)
	self:RefreshMessageDisplay()
end

M.OnPopUpLineStateChange = function(self, eventId, line, enable)
	if line ~= LTConfig.PopupConfig.LineType.C then
		self.bindData.InvisibleCtrl = enable and self.CONTROL.TRUE or self.CONTROL.FALSE
	end
end

M.OnRenderMessageListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local data = self.displayList[index + 1]

	if store and data then
		store.content = data.label
	end
end
