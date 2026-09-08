-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieMessagePanelStore.lua
-- Decompiled from: 01251_YanjieMessagePanelStore.lua_f78c111de5f9.luajit

C_YanjieMessagePanelStore = DefClass("C_YanjieMessagePanelStore", C_YanjieMessagePanelStore, C_StoreGroup)
GroupName2Class.YanjieMessagePanelStore = C_YanjieMessagePanelStore
local M = C_YanjieMessagePanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
end

M.ShowPanel = function(self, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, _)
	slot2 = gClientToGameDelegate

	slot2:AskGetFansAutoGiveHistory().Callback = function (errorId, dataList)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self:RefreshPanelView(dataList)
	end
end

M.InitView = function(self)
end

M.RefreshPanelView = function(self, dataList)
	self.viewDataList = {}

	for _, data in ipairs(dataList) do
		table.insert(self.viewDataList, {
			fansGiveInfo = data
		})
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local fansGiveInfo = data.fansGiveInfo
	store.name = LTConfig.TuiteConfig.MessageAccountName
	local avatarStore = gStoreManager:GetStoreGroup(store.avatarWidget.Store):GetStoreByWidget(store.avatarWidget)
	avatarStore.headIcon = LTConfig.TuiteConfig.MessageAccountAvatarId
	local textId = nil

	if fansGiveInfo.Reason ~= UX.Game.FansAutoGiveReason.Offline then
		textId = 89901245
	elseif fansGiveInfo.Reason ~= UX.Game.FansAutoGiveReason.LeaveScene then
		textId = 89901246
	elseif fansGiveInfo.Reason ~= UX.Game.FansAutoGiveReason.AgentDestroy then
		textId = 89901247
	end

	local time = os.date("%Y/%m/%d %H:%M:%S", fansGiveInfo.GiveTime)
	store.content = LTConfig.TextScriptTextConfig.GetConfig(textId).Text:format(time, fansGiveInfo.GiveCount)
end

M.OnClose = function(self)
end
