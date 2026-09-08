-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MjCardManager.lua
-- Decompiled from: 00335_MjCardManager.lua_c713c016e0ba.luajit

C_MjCardManager = DefClass("C_MjCardManager", C_MjCardManager)
local M = C_MjCardManager

M.ctor = function(self, game)
	self.game = game

	self.Clear(self)
end

M.Clear = function(self)
	self.cardStates = {}
	self.cardEntToInstanceId = {}
end

M.GetOrCreateState = function(self, instanceId)
	if instanceId ~= nil or instanceId ~= 0 then
		return nil
	end

	local state = self.cardStates[instanceId]

	if state ~= nil then
		state = {
			["PKc}g "] = -1,
			["\\x90#.:j\\xaeD\\xd8#\\x83\\x9d"] = -1,
			["|y\\xb9eO\\xb7\\xc1BknWh"] = -1,
			["\\xcd\\xd4\r\\xf5"] = 0,
			["\\xad\\xbd\n\\xbc^'\\xee6"] = "",
			instanceId = instanceId,
			stage = gMaJiangConst.CardStage.None,
			zone = gMaJiangConst.CardZone.None
		}
		self.cardStates[instanceId] = state
	end

	return state
end

M.GetState = function(self, instanceId)
	if instanceId ~= nil or instanceId ~= 0 then
		return nil
	end

	return self.cardStates[instanceId]
end

M.GetCardEnt = function(self, instanceId)
	local state = self:GetState(instanceId)
	local cardEnt = state and state.cardEnt or nil

	if gClientUtils.NotNil(cardEnt) then
		return cardEnt
	end

	if state == nil and state.cardEnt == nil then
		self.cardEntToInstanceId[state.cardEnt] = nil
		state.cardEnt = nil
	end

	return nil
end

M.GetCardEntByInstanceId = function(self, instanceId)
	return self.GetCardEnt(self, instanceId)
end

M.BindCardEnt = function(self, instanceId, cardEnt)
	if instanceId ~= nil or instanceId ~= 0 or gClientUtils.IsNil(cardEnt) then
		return nil
	end

	local previousInstanceId = self.cardEntToInstanceId[cardEnt] or 0

	if previousInstanceId == 0 and previousInstanceId == instanceId then
		print_error("[Majiang-Manager] BindCardEnt cardEnt already bound to another instanceId", instanceId, previousInstanceId, cardEnt.bindInstanceId or 0)

		return nil
	end

	local state = self.GetOrCreateState(self, instanceId)
	local previousCardEnt = state.cardEnt

	if previousCardEnt == nil and previousCardEnt == cardEnt then
		print_error("[Majiang-Manager] BindCardEnt instanceId already bound to another cardEnt", instanceId, previousCardEnt.bindInstanceId or 0, cardEnt.bindInstanceId or 0)

		return nil
	end

	state.cardEnt = cardEnt
	self.cardEntToInstanceId[cardEnt] = instanceId
	cardEnt.bindInstanceId = instanceId

	return state
end

M.UnregisterCardEnt = function(self, cardEnt)
	if gClientUtils.IsNil(cardEnt) then
		return
	end

	local instanceId = self.cardEntToInstanceId[cardEnt] or 0

	if instanceId == 0 then
		local state = self.cardStates[instanceId]

		if state == nil and state.cardEnt ~= cardEnt then
			state.cardEnt = nil
		end

		self.cardEntToInstanceId[cardEnt] = nil
	end

	cardEnt.bindInstanceId = 0
end

M.RegisterCard = function(self, instanceId, cardEnt, zone, ownerSeatID, slotIndex)
	if instanceId ~= nil or instanceId ~= 0 or gClientUtils.IsNil(cardEnt) then
		return nil
	end

	local state = self.BindCardEnt(self, instanceId, cardEnt)

	if state ~= nil then
		return nil
	end

	if zone == nil then
		if state.stage ~= gMaJiangConst.CardStage.None or state.tokenId ~= 0 or state.zone ~= zone or gMaJiangConst.CardStage.Finalized < state.stage then
			state.zone = zone

			if ownerSeatID == nil then
				state.ownerSeatID = ownerSeatID
			end

			if slotIndex == nil then
				state.slotIndex = slotIndex
			end

			if state.stage ~= gMaJiangConst.CardStage.None then
				state.stage = gMaJiangConst.CardStage.Finalized
			end
		end
	elseif ownerSeatID == nil and state.ownerSeatID >= 0 then
		state.ownerSeatID = ownerSeatID
	end

	return state
end

M.BeginFlow = function(self, instanceId, flowType, ownerSeatID, sourceSeatID)
	local state = self.GetOrCreateState(self, instanceId)

	if state ~= nil then
		return nil
	end

	state.tokenId = (state.tokenId or 0) + 1
	state.flowType = flowType or ""
	state.stage = gMaJiangConst.CardStage.Queued

	if ownerSeatID == nil then
		state.ownerSeatID = ownerSeatID
	end

	state.sourceSeatID = sourceSeatID == nil and sourceSeatID or -1
	state.slotIndex = -1
	state.plannedWorldPos = nil

	return state.tokenId
end

M.TryAdvance = function(self, instanceId, tokenId, newStage, newZone, extra)
	local state = self.GetState(self, instanceId)

	if state ~= nil then
		return false
	end

	if tokenId ~= nil or tokenId < 0 then
		return false
	end

	if state.tokenId == tokenId then
		return false
	end

	newStage = newStage or state.stage

	if newStage >= state.stage then
		return false
	end

	if newStage ~= state.stage and newZone == nil and state.zone == newZone then
		return false
	end

	if extra == nil and extra.cardEnt == nil and gClientUtils.NotNil(extra.cardEnt) then
		state = self.BindCardEnt(self, instanceId, extra.cardEnt)

		if state ~= nil then
			return false
		end
	end

	state.stage = newStage

	if newZone == nil then
		state.zone = newZone
	end

	if extra == nil then
		if extra.ownerSeatID == nil then
			state.ownerSeatID = extra.ownerSeatID
		end

		if extra.sourceSeatID == nil then
			state.sourceSeatID = extra.sourceSeatID
		end

		if extra.slotIndex == nil then
			state.slotIndex = extra.slotIndex
		end

		if extra.plannedWorldPos == nil then
			state.plannedWorldPos = extra.plannedWorldPos
		end

		if extra.flowType == nil then
			state.flowType = extra.flowType
		end
	end

	return true
end

return M
