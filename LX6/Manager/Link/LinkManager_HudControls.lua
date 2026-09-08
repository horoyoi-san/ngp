-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_HudControls.lua
-- Decompiled from: 00718_LinkManager_HudControls.lua_24b3c51b9e8f.luajit

local MessageConfig = LTConfig.MessageConfig
local M = C_LinkManager

M.UpdateOnlineControls = function(self)
	if gLinkManager:CheckInLinkMode() then
		gPanelManager:CheckShow(gPanelId.S_ONLINE_CONTROLS)
	else
		gPanelManager:Close(gPanelId.S_ONLINE_CONTROLS)
	end

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Match and gLinkManager:GetCurMultiType() == 0 then
		print_notice("[OnlineCommonIngameBtnPanel] UpdateOnlineControls -> CheckShow, LinkMode=", gLinkManager.LinkMode, "curMultiType=", gLinkManager:GetCurMultiType())
		gPanelManager:CheckShow(gPanelId.ONLINE_COMMON_INGAMEBTN_PANEL)
	else
		print_notice("[OnlineCommonIngameBtnPanel] UpdateOnlineControls -> Close, LinkMode=", gLinkManager.LinkMode, "curMultiType=", gLinkManager:GetCurMultiType())
		gPanelManager:Close(gPanelId.ONLINE_COMMON_INGAMEBTN_PANEL)
	end
end

M.OnEnterScene = function(self, enterInfo)
	local matchGameId = enterInfo.MatchGameId
	local matchGameConfig = LTConfig.LinkMultiPlayerConfig.GetConfig(matchGameId)
	self.curMultiType = matchGameConfig and matchGameConfig.MultiType or 0
	local store = gStoreManager:GetStoreGroup("OnlineControlsStore")

	if store then
		store.UpdatePinBtnState(store, self.curMultiType)
	end

	gShootManager:OnRefreshFire()

	local linkInfo = enterInfo.LinkSimpleInfo

	if linkInfo and linkInfo.Mode == self.LinkMode then
		self.OnChangeLinkMode(self, linkInfo.Mode, true)
	end
end

M.GetCurMultiType = function(self)
	return self.curMultiType or 0
end

M.UpdateShortChatWheels = function(self)
	local multiType = self.curMultiType

	if multiType == 0 then
		slot2 = gClientToGameDelegate

		slot2:GetShortChatWheel(multiType).Callback = function (err, data)
			if err ~= LTConfig.MessageConfig.LinkNotExist then
				return
			end

			if err == LTConfig.MessageConfig.Ok then
				return
			end

			self:SyncChatWheelItems(data)
		end
	end
end

M.SyncChatWheelItems = function(self, data, multiType)
	self.lastSyncMultiType = multiType or self.lastSyncMultiType
	self.multiTypeToChatWheelDict[multiType] = self.multiTypeToChatWheelDict[multiType] or {}
	local wheelList = self.multiTypeToChatWheelDict[multiType]

	table.clear(wheelList)

	for i = 1, self.MAX_CHAT_ITEM_COUNT do
		table.insert(wheelList, data[i] or {
			[")\r"] = 0,
			["N;m^"] = 0
		})
	end

	gMessageManager:SendMessage(gEventConstants.LINK_ONLINE_SIGNAL_CIRCLE_STATE_CHANGE)
end

M.GetCurShortChatWheelItems = function(self)
	return self.multiTypeToChatWheelDict[self.lastSyncMultiType]
end

M.NeedShortChatWheel = function(self)
	local gameTypeCfg = LTConfig.LinkMultiTypeConfig.GetConfig(self.curMultiType)

	if gameTypeCfg and next(gameTypeCfg.ShortChatWheel) then
		return true
	else
		return false
	end
end

M.GetShortChatWheelItemsByMultiType = function(self, multiType, callback)
	if self.multiTypeToChatWheelDict[multiType] then
		callback(true, self.multiTypeToChatWheelDict[multiType])
	else
		slot3 = gClientToGameDelegate

		slot3:GetShortChatWheel(multiType).Callback = function (err, data)
			if err ~= LTConfig.MessageConfig.Ok then
				self.multiTypeToChatWheelDict[multiType] = self.multiTypeToChatWheelDict[multiType] or {}
				local wheelList = self.multiTypeToChatWheelDict[multiType]

				table.clear(wheelList)

				for i = 1, self.MAX_CHAT_ITEM_COUNT do
					table.insert(wheelList, data[i] or {
						[")\r"] = 0,
						["N;m^"] = 0
					})
				end

				callback(true, wheelList)
			else
				callback(false)
				gDisplayMessageMgr:ShowServerMessage(err)
			end
		end
	end
end

M.SwitchCircleIndex = function(self, multiType, fromIndex, toIndex, callback)
	if self.banChatCircleOperation then
		callback(false)

		return
	end

	if fromIndex <= 1 or self.MAX_CHAT_ITEM_COUNT >= fromIndex then
		callback(false)

		return
	end

	if toIndex <= 1 or self.MAX_CHAT_ITEM_COUNT >= toIndex then
		callback(false)

		return
	end

	local dataList = self.multiTypeToChatWheelDict[multiType]

	if not dataList then
		callback(false)

		return
	end

	local fromItem = dataList[fromIndex]
	local toItem = dataList[toIndex]
	dataList[fromIndex] = toItem
	dataList[toIndex] = fromItem
	self.banChatCircleOperation = true
	slot8 = gClientToGameDelegate

	slot8:SetShortChatWheel(multiType, dataList).Callback = function (err)
		self.banChatCircleOperation = false

		if err ~= LTConfig.MessageConfig.Ok then
			callback(true)
		else
			dataList[fromIndex] = fromItem
			dataList[toIndex] = toItem

			callback(false)
			gDisplayMessageMgr:ShowServerMessage(err)
		end
	end
end

M.RemoveCircleIndex = function(self, multiType, removeIndex, callback)
	if self.banChatCircleOperation then
		callback(false)

		return
	end

	if removeIndex <= 1 or self.MAX_CHAT_ITEM_COUNT >= removeIndex then
		callback(false)

		return
	end

	local dataList = self.multiTypeToChatWheelDict[multiType]

	if not dataList then
		callback(false)

		return
	end

	local removeItem = dataList[removeIndex]
	dataList[removeIndex] = {
		[")\r"] = 0,
		["N;m^"] = 0
	}
	self.banChatCircleOperation = true
	slot6 = gClientToGameDelegate

	slot6:SetShortChatWheel(multiType, dataList).Callback = function (err)
		self.banChatCircleOperation = false

		if err ~= LTConfig.MessageConfig.Ok then
			callback(true)
		else
			dataList[removeIndex] = removeItem

			callback(false)
			gDisplayMessageMgr:ShowServerMessage(err)
		end
	end
end

M.LoadToCircleIndex = function(self, multiType, loadIndex, loadId, callback)
	if self.banChatCircleOperation then
		callback(false)

		return
	end

	if loadIndex <= 1 or self.MAX_CHAT_ITEM_COUNT >= loadIndex then
		callback(false)

		return
	end

	local dataList = self.multiTypeToChatWheelDict[multiType]

	if not dataList then
		callback(false)

		return
	end

	local preItem = dataList[loadIndex]
	local newItem = {
		["N;m^"] = 0,
		Id = loadId
	}
	dataList[loadIndex] = newItem
	self.banChatCircleOperation = true
	slot8 = gClientToGameDelegate

	slot8:SetShortChatWheel(multiType, dataList).Callback = function (err)
		self.banChatCircleOperation = false

		if err ~= LTConfig.MessageConfig.Ok then
			callback(true)
		else
			dataList[loadIndex] = preItem

			callback(false)
			gDisplayMessageMgr:ShowServerMessage(err)
		end
	end
end

M.NeedCrossHair = function(self)
	return self.NeedShortChatWheel(self)
end

M.GetCurShortChatCD = function(self)
	local cfg = LTConfig.LinkConfig
	local now = Time.realtimeSinceStartup

	if now >= (self.shortChatPunishUntil or 0) then
		return cfg.ShortChatPunishCD or 0
	end

	return cfg.ShortChatCD or 0
end

M.CheckAndConsumeShortChatCD = function(self)
	local now = Time.realtimeSinceStartup
	local cd = self:GetCurShortChatCD()
	local elapsed = now - (self.lastCallTime or 0)

	if cd <= elapsed then
		return false, math.ceil(cd - elapsed)
	end

	self.lastCallTime = now

	if now >= (self.shortChatPunishUntil or 0) then
		return true
	end

	local highFreq = LTConfig.LinkConfig.ShortChatHighFrequency
	local window = highFreq and highFreq[1]
	local threshold = highFreq and highFreq[2]

	if window and threshold and threshold <= 0 then
		local sendTimes = self.shortChatSendTimes or {}

		table.insert(sendTimes, now)

		local valid = {}

		for _, t in ipairs(sendTimes) do
			if window <= now - t then
				table.insert(valid, t)
			end
		end

		self.shortChatSendTimes = valid

		if threshold < #valid then
			self.shortChatPunishUntil = now + (LTConfig.LinkConfig.ShortChatPunishTime or 0)
			self.shortChatSendTimes = {}
		end
	end

	return true
end
