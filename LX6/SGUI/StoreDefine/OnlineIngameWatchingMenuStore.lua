-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineIngameWatchingMenuStore.lua
-- Decompiled from: 01129_OnlineIngameWatchingMenuStore.lua_43435a4ede82.luajit

C_OnlineIngameWatchingMenuStore = DefClass("C_OnlineIngameWatchingMenuStore", C_OnlineIngameWatchingMenuStore, C_StoreGroup)
GroupName2Class.OnlineIngameWatchingMenuStore = C_OnlineIngameWatchingMenuStore
local M = C_OnlineIngameWatchingMenuStore

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.luaSelectedChanged = self.CreateAction(self, "OnItemSelectedChange")

	self.bindData.list.onGetTIndex = function(_)
		return 0
	end

	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
end

M.OnEnable = function(self)
	self.InitData(self)
end

M.OnDisable = function(self)
end

M.OnGroupEnable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", true)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", true)
end

M.OnGroupDisable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", false)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", false)
end

M.InitData = function(self)
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

M.OnRenderItem = function(self, btn, index)
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
	store.editBtn.luaClick = self.CreateActionWithArgs(self, "OnEditBtnClick", args)
	store.saveBtn.luaClick = self.CreateActionWithArgs(self, "OnSaveBtnClick", args)
	store.backBtn.luaClick = self.CreateActionWithArgs(self, "OnBackBtnClick", args)
	btn.luaClick = self.CreateActionWithArgs(self, "OnSendMessageClick", data.Id)
end

M.OnSendMessageClick = function(self, msgId)
	gClientToGameDelegate:AskSendInteractionInfoToWatchee(msgId, false).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	gPanelManager:Close(gPanelId.S_ONLINE_INGAME_WATCHING_MENU)
end

M.OnEditBtnClick = function(self, args)
	args.store.isEditing = 1
end

M.OnSaveBtnClick = function(self, args)
	local msg = args.store.input.text

	if string.is_null_or_empty(msg) then
		return
	end

	slot3 = gClientToGameDelegate

	slot3:SaveCustomInteractionInfo(args.data.Id, msg).Callback = function (err, data)
		args.store.isEditing = 0

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			args.store.text = msg
			gPlayerManager.infoMinor.bindData.PlayerInterActionInfo[args.data.Id] = msg
		end
	end
end

M.OnBackBtnClick = function(self, args)
	args.store.input.text = ""
	args.store.isEditing = 0
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_INGAME_WATCHING_MENU)
end
