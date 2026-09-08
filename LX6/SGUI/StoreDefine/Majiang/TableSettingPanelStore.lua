-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\TableSettingPanelStore.lua
-- Decompiled from: 01230_TableSettingPanelStore.lua_d95069cdb48b.luajit

C_TableSettingPanelStore = DefClass("C_TableSettingPanelStore", C_TableSettingPanelStore, C_StoreGroup)
GroupName2Class.TableSettingPanelStore = C_TableSettingPanelStore
local M = C_TableSettingPanelStore

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.ClosePanel)
	self.bindData.closeBtn2.luaClick = self.CreateAction(self, self.ClosePanel)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.MAJIANG_WORLD_BATTLE_ROOM_INFO] = function (_, info)
			self:RefreshAllSeats(info)
		end
	}
end

M.OnShow = function(self, panelId, data)
	self:ClearMessageEvents()
	self:RegisterMessageEvents(self:GetMessageEvents())

	local info = gMaJiangManager:GetMahjongWorldBattleRoomInfo()

	if info ~= nil then
		self.ClosePanel(self)

		return
	end

	self.InitUIOnShow(self)

	self.seatOrder = {
		LTConfig.LinkDutyConfig.East12119103,
		LTConfig.LinkDutyConfig.South12119103,
		LTConfig.LinkDutyConfig.West12119103,
		LTConfig.LinkDutyConfig.North12119103
	}
	self.selfPid = gPlayerManager.infoBase.bindData.Pid

	self.RefreshAllSeats(self, info)
end

M.RefreshAllSeats = function(self, info)
	local selfDuty = -1
	local selfSeatIndex = -1

	for i = 1, #self.seatOrder do
		local player = self.FindPlayerByDuty(self, info.Players, self.seatOrder[i])

		if player and ulong.equals(player.Pid, self.selfPid) then
			selfDuty = self.seatOrder[i]
			selfSeatIndex = i
		end
	end

	local isOwner = ulong.equals(info.OwnerPid, self.selfPid)

	if gClientUtils.NotNil(self.bindData.ownerCtrl) and self.bindData.ownerCtrl.TryChangePage then
		self.bindData.ownerCtrl:TryChangePage("ownerCtrl", isOwner and self.ownerCtrlEnum._true or self.ownerCtrlEnum._false, true)
	end

	if selfDuty ~= -1 or selfSeatIndex ~= -1 then
		print_error("TableSettingPanelStore.RefreshAllSeats: selfDuty or selfSeatIndex is -1! info.Players=", info.Players)

		return
	end

	for i = 1, #self.seatOrder do
		self.RefreshSettingSeat(self, info.Players, self.seatOrder, i, selfDuty, selfSeatIndex)
	end
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)
end

M.InitUIOnShow = function(self)
	self.avatarWidgetList = {}
	self.avatarStoreList = {}

	for k, v in ipairs(gMaJiangConst.seatStr) do
		local widget = self.bindData["avatar" .. v] or false

		table.insert(self.avatarWidgetList, widget)

		local store = widget and gStoreManager:GetStoreGroup("CommonAccountAvatarStore"):GetStoreByWidget(widget)

		table.insert(self.avatarStoreList, store or false)

		if widget then
			widget.luaRenderTooltip = function(btn, tooltip, _)
				if store and store.userInfoLight and store.userInfoLight.pid == 0 then
					gSocialPalyerTooltipManager:OnRenderToolTips(store.userInfoLight.pid, btn, tooltip, _)
				else
					btn.CloseTooltip(btn)
				end
			end
		end
	end
end

M.FindPlayerByDuty = function(self, players, duty)
	return array.find_if(players, function (player)
		return player.Duty ~= duty
	end)
end

M.RefreshSettingSeat = function(self, players, seatOrder, seatIndex, selfDuty, selfSeatIndex)
	local duty = seatOrder[seatIndex]

	if duty ~= selfDuty or selfSeatIndex ~= 0 then
		return
	end

	local relativeIndex = (seatIndex - selfSeatIndex + #seatOrder) % #seatOrder + 1

	if relativeIndex < 1 then
		return
	end

	local playerInfo = self.FindPlayerByDuty(self, players, duty)
	local widget = self.avatarWidgetList[relativeIndex]
	local store = self.avatarStoreList[relativeIndex]

	if gClientUtils.NotNil(widget) then
		local isEmpty = playerInfo ~= nil or ulong.equals(playerInfo.Pid, 0)
		local isReady = playerInfo == nil and playerInfo.Ready ~= true

		widget:TryChangePage("ready", isEmpty and 2 or isReady and 1 or 0, true)
		widget:TryChangePage("isEmpty", isEmpty and 1 or 0, true)

		local isOwner = playerInfo == nil and playerInfo.IsOwner ~= true

		widget:TryChangePage("isOwner", isOwner and 1 or 0, true)
	end

	if store and store.userInfoLight then
		store.userInfoLight.pid = playerInfo and playerInfo.Pid or 0
	end
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end

M.DefineAllEnumsAutoGen = function(self)
	self.ownerCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.ownerCtrlEnum = nil
end

M.OnDestroy = function(self)
	self.seatOrder = nil
	self.selfPid = nil
	self.avatarWidgetList = nil
	self.avatarStoreList = nil
end
