-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerProfileChangeBgStore.lua
-- Decompiled from: 00835_PlayerProfileChangeBgStore.lua_d061c02fab67.luajit

C_PlayerProfileChangeBgStore = DefClass("C_PlayerProfileChangeBgStore", C_PlayerProfileChangeBgStore, C_StoreGroup)
GroupName2Class.PlayerProfileChangeBgStore = C_PlayerProfileChangeBgStore
local M = C_PlayerProfileChangeBgStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.avaliableBgs = {}
	self.btnStores = {}
	self.selectedBgIdx = 0
	self.usingBgIdx = 0
	self.currentBgId = 0
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnClickListItem)
	self.bindData.btnSave.luaClick = self.CreateAction(self, self.OnClickSave)
	self.bindData.btnExit.luaClick = self.CreateAction(self, self.OnClickExit)
	self.bindData.btnExit2.luaClick = self.CreateAction(self, self.OnClickExit)
end

M.OnShow = function(self, panelId, data)
	if not data or not data.pid then
		return
	end

	self.currentBgId = data.currentBgId

	self.LoadData(self)
	self.CloseOther(self)
end

M.CloseOther = function(self)
	local toClose = {
		gPanelId.PLAYER_PROFILE_CHANGE_HEAD_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_BIRTHDAY_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_NOTE_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_POPUP_BACKGROUND_PANEL
	}

	for _, v in ipairs(toClose) do
		if gPanelManager:IsPanelShowing(v) then
			gPanelManager:Close(v)
		end
	end
end

M.PreviewBg = function(self, bg)
	local store = gStoreManager:GetStoreGroup("PlayerProfileStore")

	if not store then
		return
	end

	store.SetPreviewBg(store, bg)
end

M.LoadData = function(self)
	self.avaliableBgs = {}

	for i = 0, LTConfig.ImageBackGroudConfig.count - 1 do
		local config = LTConfig.ImageBackGroudConfig.LoadAt(i)

		table.insert(self.avaliableBgs, {
			["[\\xae\\x80\\x86V"] = false,
			id = config.Id,
			iconId = config.Resource or 0,
			name = config.Name
		})

		if config.Id ~= self.currentBgId then
			self.selectedBgIdx = #self.avaliableBgs
			self.usingBgIdx = self.selectedBgIdx
		end
	end

	self.RefreshPanel(self)
end

M.RefreshPanel = function(self)
	self.btnStores = {}

	self.bindData.list:SetSimpleList(#self.avaliableBgs)
	self.bindData.list:SelectItem(self.selectedBgIdx - 1)
end

M.OnRenderListItem = function(self, widget, index)
	index = index + 1
	local data = self.avaliableBgs[index]
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	store.title.text = data.name

	store:Commit("icon", data.iconId, COMMIT_FORCE)

	store.usingCtrl = BOOL2CTL[self.usingBgIdx ~= index]
	self.btnStores[index] = store
end

M.OnClickListItem = function(self, widget, index)
	index = index + 1
	local data = self.avaliableBgs[index]

	self.bindData.list:SelectItem(index - 1)

	self.selectedBgIdx = index

	self:PreviewBg(data.id)
end

M.OnClickSave = function(self)
	if self.selectedBgIdx <= 0 then
		local info = self.avaliableBgs[self.selectedBgIdx]

		gClientToGameDelegate:AskUpdatePersonalZoneBackground(self.pid, info.id).Callback = function (err, list)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			else
				self:OnClickExit()
			end
		end

		gMessageManager:SendMessage(gEventConstants.PLAYER_PROFILE_INFO_CHANGED, {
			bg = info.id
		})
	end
end

M.OnClickExit = function(self)
	gPanelManager:Close(gPanelId.PLAYER_PROFILE_CHANGE_BACKGROUND_PANEL)
end

M.OnActiveDeviceChange = function(self, device)
end
