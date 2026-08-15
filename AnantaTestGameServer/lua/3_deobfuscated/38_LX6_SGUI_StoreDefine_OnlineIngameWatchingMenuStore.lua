C_OnlineIngameWatchingMenuStore = DefClass("C_OnlineIngameWatchingMenuStore", C_OnlineIngameWatchingMenuStore, C_StoreGroup)
GroupName2Class.OnlineIngameWatchingMenuStore = C_OnlineIngameWatchingMenuStore
local M = C_OnlineIngameWatchingMenuStore

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.list.luaSelectedChanged = self:CreateAction("OnItemSelectedChange")

	function self.bindData.list.onGetTIndex(_)
		return 0
	end

	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
end

function M:OnEnable()
	self:InitData()
end

function M:InitData()
	local actionInfo = gPlayerManager.infoMinor.bindData.PlayerInterActionInfo
	local count = LTConfig.LinkInteractionConfig.count
	self.list = {}

	for i = 4, count do
		local data = {}
		local cfg = LTConfig.LinkInteractionConfig.GetConfig(i)

		if cfg then
			data.Id = cfg.Id
			data.Icon = cfg.Icon

			if actionInfo and actionInfo[i] then
				data.Text = actionInfo[i]
			else
				data.Text = LTConfig.TextCommonTextConfig.GetConfig(tonumber(cfg.Text)).Text
			end

			table.insert(self.list, data)
		end
	end

	self.bindData.list:SetSimpleList(#self.list)
	self.bindData.list:SetItemSelected(0, true)
end

function M:OnRenderItem(btn, index)
	local data = self.list[index + 1]
	local store = gStoreManager:GetStoreGroup("OnlineIngameWatchingMenuTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.icon = data.Icon
	store.text = data.Text
	local args = {
		data = data,
		store = store
	}
	store.editBtn.luaClick = self:CreateActionWithArgs("OnEditBtnClick", args)
	store.saveBtn.luaClick = self:CreateActionWithArgs("OnSaveBtnClick", args)
	store.backBtn.luaClick = self:CreateActionWithArgs("OnBackBtnClick", args)
	btn.luaClick = self:CreateActionWithArgs("OnSendMessageClick", data.Id)
end

function M:OnSendMessageClick(msgId)
	gClientToGameDelegate:AskSendInteractionInfoToWatchee(msgId, false).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	gPanelManager:Close(gPanelId.S_ONLINE_INGAME_WATCHING_MENU)
end

function M:OnEditBtnClick(args)
	args.store.isEditing = 1
end

function M:OnSaveBtnClick(args)
	local msg = args.store.input.text

	if string.is_null_or_empty(msg) then
		return
	end

	gClientToGameDelegate:SaveCustomInteractionInfo(args.data.Id, msg).Callback = function (err, data)
		args.store.isEditing = 0

		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			args.store.text = msg
			gPlayerManager.infoMinor.bindData.PlayerInterActionInfo[args.data.Id] = msg
		end
	end
end

function M:OnBackBtnClick(args)
	args.store.input.text = ""
	args.store.isEditing = 0
end

function M:OnCloseBtnClick()
	gPanelManager:Close(gPanelId.S_ONLINE_INGAME_WATCHING_MENU)
end
