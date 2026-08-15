C_ChatAddFriendPanelStore = DefClass("C_ChatAddFriendPanelStore", C_ChatAddFriendPanelStore, C_AppFragmentStore)
GroupName2Class.ChatAddFriendPanelStore = C_ChatAddFriendPanelStore
local M = C_ChatAddFriendPanelStore

function M:OnAwake()
	self.bindData.inputField.luaValueChanged = self:CreateAction(self.OnInputFieldValueChanged)
end

function M:OnShow(_, data)
	self.bindData.inputField.onActivateAction = self:CreateAction(self.activity.OnInputFieldActivate)
	self.bindData.inputField.onDeActivateAction = self:CreateAction(self.activity.OnInputFieldDeActivate)

	self:ResetData()
	self:ResetUI()
end

function M:ResetData()
	self.currentSearchId = 0
	self.inputValue = 0
	self.nextRequestTime = 0
end

function M:ResetUI()
	self.bindData.inputField.text = ""
	self.bindData.resultCtrl = 2
end

function M:OnRenderItem(btn, _, itemData)
	local store = self:GetStoreByWidget(btn)
	local pid = itemData.Pid

	gChatUtils.SetChatChannelCardBaseView(btn, gChatTopChannel.Friend, pid)

	store.name = itemData.Name
	store.showOnline = true
	store.playerStateCtrl = itemData.OnlineState

	if ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) then
		store.typeCtrl = 2

		return
	end

	local isFriend = gFriendManager:IsFriend(pid, true)
	local applied = gFriendManager:IsFriend(pid, false)

	if isFriend then
		store.typeCtrl = 3
	elseif applied then
		store.typeCtrl = 0
		store.applyBtn.luaClick = self:CreateActionWithArgs(self.OnApplyBtnClickEx, itemData)
	else
		store.typeCtrl = 0
		store.applyBtn.luaClick = self:CreateActionWithArgs(self.OnApplyBtnClick, itemData)
	end
end

function M:OnApplyBtnClick(itemData, noBlackListCheck)
	local pid = itemData.Pid

	gFriendManager:AskApplyFriend(pid, function ()
		if ulong.equals(self.currentSearchId, pid) then
			self:DoSearch(pid)
		end
	end)
end

function M:OnApplyBtnClickEx(itemData)
	gFriendManager:DeleteFriend(itemData.Pid, function ()
		self:OnApplyBtnClick(itemData)
	end, true)
end

function M:OnInputFieldValueChanged(inputText)
	local text = string.gsub(inputText, "[^0-9]", "")
	text = string.sub(text, 1, 9)

	if text ~= inputText then
		self.bindData.inputField.text = text
	end

	if string.is_null_or_empty(text) then
		self.inputValue = nil
	else
		self.inputValue = tonumber(text)
	end
end

function M:OnUpdate()
	if ulong.equals(self.currentSearchId or 0, self.inputValue or 0) then
		return
	end

	if self.inputValue == nil then
		self:ResetUI()

		return
	end

	local currentTime = Time.unscaledTime

	if currentTime < self.nextRequestTime then
		return
	end

	self:DoSearch(self.inputValue)

	self.nextRequestTime = currentTime + LTConfig.NPCChatConfig.SearchFriendInterval
end

function M:DoSearch(id)
	id = ulong.check(id) and id or ulong.new(id)
	self.currentSearchId = id

	local function Callback(info)
		if not self.STATE_EnableOnce or self.currentSearchId ~= id then
			return
		end

		if info == nil or not info.Name then
			self.bindData.resultCtrl = 1

			return
		end

		self.bindData.resultCtrl = 0

		self:RefreshInfo(info)
	end

	gFriendManager:GetSimplePlayerInfo(id, Callback, true)
end

function M:RefreshInfo(data)
	if data and gClientUtils.NotNil(self.bindData.itemBtn) then
		self:OnRenderItem(self.bindData.itemBtn, 0, data)
	end
end
