local GameConfig = LTConfig.GameConfig
C_MessagePanelStore = DefClass("C_MessagePanelStore", C_MessagePanelStore, C_StoreGroup)
GroupName2Class.MessagePanelStore = C_MessagePanelStore
local M = C_MessagePanelStore
local MSG_MAX_NUM = 1

function M:ctor()
	self.msgList = {}
	self.displayList = {}
	self.updateTime = {}
	self.DEFINE_DynamicOnUpdate = true
end

function M:OnAwake()
	gLuaUIMgr.commonQueueMessage = self
	self.msgEvents = {
		[gEventConstants.MESSAGE_CLEAR] = self:CreateAction("OnMessageClear"),
		[gEventConstants.BEFORE_SWITCH_SCENE] = self:CreateAction("OnBeforeSwitchScene")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnDestroy()
	gLuaUIMgr.commonQueueMessage = nil

	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	gStoreManager:UnregisterDynamicOnUpdate(self)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnBeforeSwitchScene(switchType)
	self.msgList = {}

	self:RefreshMessageDisplay()
end

function M:OnMessageClear()
	self.msgList = {}

	self:RefreshMessageDisplay()
end

function M:CheckInUpdate()
	if not self.updateTime[1] or self.updateTime[1] <= Time.unscaledTime then
		gStoreManager:UnregisterDynamicOnUpdate(self)

		return false
	end

	gStoreManager:RegisterDynamicOnUpdate(self)

	return true
end

function M:OnUpdate()
	self:RefreshMessageDisplay()
end

function M:RefreshMessageDisplay()
	self.displayList = {}
	self.updateTime = {}

	for i = 1, #self.msgList do
		if MSG_MAX_NUM <= #self.displayList then
			break
		end

		local ele = self.msgList[i]

		if ele.hideTime == 0 then
			ele.hideTime = Time.unscaledTime + ele.autoHideTime
		end

		if Time.unscaledTime < ele.hideTime then
			table.insert(self.displayList, ele)
			table.insert(self.updateTime, ele.hideTime)
		end
	end

	self.bindData.messageList:SetList(self.displayList)
	self:CheckInUpdate()
end

function M:ClearMessageList()
	local tmp = {}
	self.msgList = tmp
end

function M:ShowAutoHideMessage(message, autoHideTime)
	autoHideTime = autoHideTime or GameConfig.HideMessageAfter

	self:ClearMessageList()

	local ele = {
		hideTime = 0,
		label = message,
		autoHideTime = autoHideTime
	}

	table.insert(self.msgList, ele)
	self:RefreshMessageDisplay()
end
