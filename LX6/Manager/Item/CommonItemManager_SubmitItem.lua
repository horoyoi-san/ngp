-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_SubmitItem.lua
-- Decompiled from: 02211_CommonItemManager_SubmitItem.lua_931cee627520.luajit

local SubmitItemEventConfig = LTConfig.SubmitItemEventConfig
local MessageConfig = LTConfig.MessageConfig
local M = C_CommonItemManager
M.SubmitItemType = {
	["+M\\x90\\x9e\\x8cO"] = 2,
	["2G\\x83\\x83\\x82M"] = 1,
	["Q\\xe43\\xfe(4;\\xcan.\\xe6C\\x83V\\xc3\\xf4"] = 3,
	["T-s^"] = 0
}

M.OnInitSubmitItem = function(self)
	self.submitItemDataDict = {}
	self.agentSubmitItemDataDict = {}
end

M.SetPlayerInfoSubmitItem = function(self, infoSubmitItem)
	self.submitItemDataDict = {}
	self.agentSubmitItemDataDict = {}

	for i = 0, SubmitItemEventConfig.count - 1 do
		local cfg = SubmitItemEventConfig.LoadAt(i)

		if cfg and cfg.AgentId then
			local agentId = cfg.AgentId

			if not self.agentSubmitItemDataDict[agentId] then
				self.agentSubmitItemDataDict[agentId] = {}
			end

			self.agentSubmitItemDataDict[agentId][cfg.Id] = {
				[",\\xe6G88\\xd5\\xb3U\\x95_\\xbd\\xb3"] = 0,
				["˛\\xf8/\\xe4\\xe3\\x9cً--"] = 0,
				["ԏ\\xe1\\xf2\\xee\\xab\\xe2\\x97.<"] = 0
			}
		end
	end

	local dataDict = infoSubmitItem and infoSubmitItem.SubmitItemDataDict or nil

	if dataDict then
		for eventId, data in pairs(dataDict) do
			self.submitItemDataDict[eventId] = data

			self._AddToAgentMapping(self, eventId, data)
		end
	end

	local agentIds = {}

	for agentId, data in pairs(self.agentSubmitItemDataDict) do
		table.insert(agentIds, agentId)
	end

	gMessageManager:SendMessage(gEventConstants.SUBMIT_ITEM_STATE_CHANGED, agentIds)
end

M._GetAgentIdByEventId = function(self, eventId)
	local cfg = SubmitItemEventConfig.GetConfig(eventId)

	return cfg and cfg.AgentId or nil
end

M._AddToAgentMapping = function(self, eventId, data)
	local agentId = self._GetAgentIdByEventId(self, eventId)

	if not agentId then
		return
	end

	if not self.agentSubmitItemDataDict[agentId] then
		self.agentSubmitItemDataDict[agentId] = {}
	end

	self.agentSubmitItemDataDict[agentId][eventId] = data
end

M._RemoveFromAgentMapping = function(self, eventId)
	local agentId = self._GetAgentIdByEventId(self, eventId)

	if not agentId or not self.agentSubmitItemDataDict[agentId] then
		return
	end

	self.agentSubmitItemDataDict[agentId][eventId] = nil

	if next(self.agentSubmitItemDataDict[agentId]) ~= nil then
		self.agentSubmitItemDataDict[agentId] = nil
	end
end

M.GetSubmitItemCDRemaining = function(self, eventId)
	local data = self.submitItemDataDict[eventId]

	if not data or data.LastSubmitTime ~= 0 then
		return 0
	end

	local cfg = SubmitItemEventConfig.GetConfig(eventId)

	if not cfg then
		return 0
	end

	local cd = cfg.CD or 0
	local currentTime = gCS.TimeManager.ServerUnixTime
	local remaining = data.LastSubmitTime + cd - currentTime

	return math.max(0, remaining)
end

M.GetSubmitItemRemainingTimes = function(self, eventId)
	local cfg = SubmitItemEventConfig.GetConfig(eventId)

	if not cfg then
		return 0
	end

	local effectiveTimes = cfg.EffectiveTimes or 0

	if effectiveTimes ~= 0 then
		return -1
	end

	local data = self.submitItemDataDict[eventId]
	local submittedCount = data and data.SubmittedCount or 0

	return math.max(0, effectiveTimes - submittedCount)
end

M.CanSubmitItem = function(self, eventId)
	if self.GetSubmitItemCDRemaining(self, eventId) <= 0 then
		return false
	end

	local remaining = self:GetSubmitItemRemainingTimes(eventId)

	return remaining ~= -1 or remaining >= 0
end

M.AskSubmitItem = function(self, submitEventId, info, callback)
	slot4 = gClientToGameDelegate

	slot4:AskSubmitItem(submitEventId, info).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)
		end

		if callback then
			callback(err)
		end
	end
end

M.AskSubmitItemAuto = function(self, submitEventId, callback)
	self.AskSubmitItem(self, submitEventId, {}, callback)
end

M.OnSyncSubmitItemState = function(self, changedItems)
	if not changedItems then
		return
	end

	for eventId, data in pairs(changedItems) do
		if data.SubmittedCount ~= 0 and data.LastSubmitTime ~= 0 and data.NextResetTime ~= 0 then
			self.submitItemDataDict[eventId] = nil

			self._RemoveFromAgentMapping(self, eventId)
		else
			self.submitItemDataDict[eventId] = data

			self._AddToAgentMapping(self, eventId, data)
		end
	end

	local agentIds = {}

	for agentId, data in pairs(self.agentSubmitItemDataDict) do
		table.insert(agentIds, agentId)
	end

	gMessageManager:SendMessage(gEventConstants.SUBMIT_ITEM_STATE_CHANGED, agentIds)
end

M.GetSubmitDataByAgentId = function(self, agentId)
	local data = self.agentSubmitItemDataDict[agentId]

	if not data then
		return nil
	end

	local itemIds = {}

	for itemId, _ in pairs(data) do
		table.insert(itemIds, itemId)
	end

	return itemIds
end

M.ShowSubmitItem = function(self, submitItemId)
	gPanelManager:CheckShow(gPanelId.ITEM_DELIVERY_PANEL, {
		submitEventId = submitItemId
	})
end
