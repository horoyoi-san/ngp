C_YanjieMessagePanelStore = DefClass("C_YanjieMessagePanelStore", C_YanjieMessagePanelStore, C_StoreGroup)
GroupName2Class.YanjieMessagePanelStore = C_YanjieMessagePanelStore
local M = C_YanjieMessagePanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
end

function M:ShowPanel(args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(_)
	gClientToGameDelegate:AskGetFansAutoGiveHistory().Callback = function (errorId, dataList)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self:RefreshPanelView(dataList)
	end
end

function M:InitView()
	return
end

function M:RefreshPanelView(dataList)
	self.viewDataList = {}

	for _, data in ipairs(dataList) do
		table.insert(self.viewDataList, {
			fansGiveInfo = data
		})
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local fansGiveInfo = data.fansGiveInfo
	store.name = LTConfig.TuiteConfig.MessageAccountName
	local avatarStore = gStoreManager:GetStoreGroup(store.avatarWidget.Store):GetStoreByWidget(store.avatarWidget)
	avatarStore.headIcon = LTConfig.TuiteConfig.MessageAccountAvatarId
	local textId = nil

	if fansGiveInfo.Reason == UX.Game.FansAutoGiveReason.Offline then
		textId = 89901245
	elseif fansGiveInfo.Reason == UX.Game.FansAutoGiveReason.LeaveScene then
		textId = 89901246
	elseif fansGiveInfo.Reason == UX.Game.FansAutoGiveReason.AgentDestroy then
		textId = 89901247
	end

	local time = os.date("%Y/%m/%d %H:%M:%S", fansGiveInfo.GiveTime)
	store.content = LTConfig.TextScriptTextConfig.GetConfig(textId).Text:format(time, fansGiveInfo.GiveCount)
end

function M:OnClose()
	return
end
