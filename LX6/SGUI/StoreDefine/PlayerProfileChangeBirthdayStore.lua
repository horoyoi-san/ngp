-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerProfileChangeBirthdayStore.lua
-- Decompiled from: 00808_PlayerProfileChangeBirthdayStore.lua_b2ad12c4e4b0.luajit

C_PlayerProfileChangeBirthdayStore = DefClass("C_PlayerProfileChangeBirthdayStore", C_PlayerProfileChangeBirthdayStore, C_StoreGroup)
GroupName2Class.PlayerProfileChangeBirthdayStore = C_PlayerProfileChangeBirthdayStore
local M = C_PlayerProfileChangeBirthdayStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.listMonth.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderListItem)
	self.bindData.listDay.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderListItem)
	self.bindData.btnSave.luaClick = self.CreateAction(self, self.OnClickSave)
	self.bindData.btnExit.luaClick = self.CreateAction(self, self.OnClickExit)
	self.bindData.btnExit2.luaClick = self.CreateAction(self, self.OnClickExit)
end

M.OnShow = function(self, panelId, data)
	if not data or not data.pid then
		return
	end

	self.pid = data.pid
	self.birthday = data.birthday or 0

	self:RefreshPanel()
	self:CloseOther()
end

M.CloseOther = function(self)
	local toClose = {
		gPanelId.PLAYER_PROFILE_CHANGE_HEAD_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_BACKGROUND_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_NOTE_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_POPUP_BACKGROUND_PANEL
	}

	for _, v in ipairs(toClose) do
		if gPanelManager:IsPanelShowing(v) then
			gPanelManager:Close(v)
		end
	end
end

M.GetBirth = function(self, code)
	if code ~= nil or code ~= 0 then
		return {
			["\\xc0"] = 1,
			["\\xc9"] = 1
		}
	end

	return {
		m = math.floor(code / 100),
		d = code % 100
	}
end

M.RefreshPanel = function(self)
	self.bindData.listMonth:SetSimpleList(12)
	self.bindData.listDay:SetSimpleList(31)

	local birth = self:GetBirth(self.birthday)

	self.bindData.listMonth:SelectItem(birth.m - 1)
	self.bindData.listDay:SelectItem(birth.d - 1)
end

M.OnRenderListItem = function(self, widget, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	store.label = index
end

M.OnClickSave = function(self)
	local month = self.bindData.listMonth.selectedIndex + 1
	local day = self.bindData.listDay.selectedIndex + 1
	slot3 = gDisplayMessageMgr

	slot3:ShowMessage(LTConfig.ImageConfig.ChangeBirth, function ()
		self.birthday = month * 100 + day
		slot0 = gClientToGameDelegate

		slot0:AskUpdatePersonalZoneBirthday(self.birthday).Callback = function (err, list)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			else
				gMessageManager:SendMessage(gEventConstants.PLAYER_PROFILE_INFO_CHANGED)
				self:OnClickExit()
			end
		end
	end, nil, tostring(month), tostring(day))
end

M.OnClickExit = function(self)
	gPanelManager:Close(gPanelId.PLAYER_PROFILE_CHANGE_BIRTHDAY_PANEL)
end

M.OnActiveDeviceChange = function(self, device)
end
