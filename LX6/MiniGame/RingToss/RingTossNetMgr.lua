-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\RingToss\RingTossNetMgr.lua
-- Decompiled from: 00662_RingTossNetMgr.lua_4f7347e57873.luajit

C_RingTossNetMgr = DefClass("C_RingTossNetMgr", C_RingTossNetMgr)
local M = C_RingTossNetMgr
local RingTossManager = L50.Gameplay.RingToss.RingTossManager
local PoiGameConfig = LTConfig.PoiGameConfig

local print_error = function(...)
	_G.print_error("[RingTossNetMgr] ", ...)
end

local print_debug = function(...)
	if gRingTossNetMgr and gRingTossNetMgr.debug then
		_G.print_warn("[RingTossNetMgr] ", ...)
	end
end

local try_handle_error = function(err, rpcName)
	if err == LTConfig.MessageConfig.Ok then
		gDisplayMessageMgr:DisplayServerMessageId(err)
		print_error("RPC error in callback: " .. (rpcName or "unknown"), err)

		return true
	end

	return false
end

M.ctor = function(self)
	self.debug = false

	self:ResetState()
	self:InitMessages()
end

M.ResetState = function(self)
	self.gadgetUId = nil
	self.myPid = nil
	self.throwIndex = 0
	self.localResults = {}
end

M.InitMessages = function(self)
	if self.IsAddMessages then
		return
	end

	self.IsAddMessages = true
	self._msgListeners = {}

	self:AddMessageListener(gEventConstants.RING_TOSS_ENTER_AIM, function ()
		self:TryEnterZone()
	end)
	self:AddMessageListener(gEventConstants.RING_TOSS_SINGLE_RESULT, function (eventId, rewardDropId)
		self:OnLocalThrowSettled(rewardDropId)
	end)
end

M.AddMessageListener = function(self, eventId, handler)
	gMessageManager:AddMessageListener(eventId, handler)
	table.insert(self._msgListeners, {
		eventId = eventId,
		handler = handler
	})
end

M.TryEnterZone = function(self)
	if self.gadgetUId then
		return
	end

	local gadgetUId = RingTossManager.GetCurrentGadgetUId()

	if gadgetUId ~= nil or not ulong.Greater(gadgetUId, 0) then
		print_error("TryEnterZone: 无效 gadgetUId")

		return
	end

	self.gadgetUId = gadgetUId
	self.throwIndex = 0
	self.localResults = {}

	if self.debug then
		print_debug("EnterRingTossZone", gadgetUId)
	end

	gClientToGameSceneDelegate:EnterRingTossZone(gadgetUId).Callback = function (err, pid)
		if try_handle_error(err, "EnterRingTossZone") then
			gSpoonClientMgr:ReleaseContextEventMessageTrigger(gadgetUId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gEventConstants.RING_TOSS_ENTER_FAIL)
			self:ResetState()
			RingTossManager.DestroyGameSceneNode()

			return
		end

		self.myPid = pid
	end
end

M.OnLocalThrowSettled = function(self, rewardDropId)
	if not self.gadgetUId then
		print_error("OnLocalThrowSettled: 尚未进入Zone，丢弃上报")

		return
	end

	rewardDropId = rewardDropId or 0
	self.throwIndex = self.throwIndex + 1
	self.localResults[self.throwIndex] = rewardDropId
	local throwResult = {
		ThrowIndex = self.throwIndex,
		RewardDropId = rewardDropId
	}

	if self.debug then
		print_debug("RecordRingTossResult", self.throwIndex, rewardDropId)
	end

	gClientToGameSceneDelegate:RecordRingTossResult(self.gadgetUId, throwResult).Callback = function (err)
		try_handle_error(err, "RecordRingTossResult")
	end
end

M.Leave = function(self, abort)
	if not self.gadgetUId then
		return
	end

	local gadgetUId = self.gadgetUId

	self:ResetState()

	if self.debug then
		print_debug("LeaveRingToss", gadgetUId, abort)
	end

	gClientToGameSceneDelegate:LeaveRingToss(gadgetUId, abort and true or false).Callback = function (err)
		if err == LTConfig.MessageConfig.InvalidPara then
			try_handle_error(err, "LeaveRingToss")
		end
	end
end

M.OnSyncZoneTurnChange = function(self, currentRound, currentTurn)
	local maxThrows = PoiGameConfig.RingToss_RingCount
	local remaining = maxThrows - currentRound

	if self.debug then
		print_debug("OnSyncZoneTurnChange", currentRound, currentTurn, "remaining=", remaining)
	end
end

M.OnSyncGameGroundZoneInfo = function(self, zoneInfo)
	if zoneInfo ~= nil then
		self:OnZoneDestroyed()

		return
	end

	if not self.gadgetUId and ulong.Greater(zoneInfo.GadgetUId, 0) then
		self.gadgetUId = zoneInfo.GadgetUId
	end

	local serverResults = zoneInfo.ThrowResults

	if serverResults then
		for i = 1, #serverResults do
			local r = serverResults[i]
			local idx = r.ThrowIndex
			local serverReward = r.RewardDropId
			local localReward = self.localResults[idx]

			if localReward == nil and localReward == 0 and serverReward ~= 0 then
				if self.debug then
					print_debug("结果被服务端降级为未命中, throwIndex=", idx)
				end

				gMessageManager:SendMessage(gEventConstants.RING_TOSS_RESULT_CORRECTED, idx)
			end

			self.localResults[idx] = serverReward

			if self.throwIndex >= idx then
				self.throwIndex = idx
			end
		end
	end
end

M.OnZoneDestroyed = function(self)
	if self.debug then
		print_debug("OnZoneDestroyed")
	end

	self:ResetState()
end

gRingTossNetMgr = gRingTossNetMgr or C_RingTossNetMgr.new()

return C_RingTossNetMgr
