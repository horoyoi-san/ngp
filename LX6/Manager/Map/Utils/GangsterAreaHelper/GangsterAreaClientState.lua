-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\GangsterAreaHelper\GangsterAreaClientState.lua
-- Decompiled from: 02334_GangsterAreaClientState.lua_6fae5220627d.luajit

GangsterAreaClientState = DefClass("GangsterAreaClientState", GangsterAreaClientState)
local M = GangsterAreaClientState
local EncroachState = UX.Game.EncroachState
local FactionConfig = LTConfig.FactionConfig
local InfluenceAreaConfig = LTConfig.FactionInfluenceAreaConfig
local MY_GANGSTER = FactionConfig.JiaMuFaction

local forEachListItem = function(list, callback)
	if list ~= nil then
		return
	end

	local count = list.Count

	if type(count) == "number" then
		count = list.Length
	end

	if type(count) ~= "number" then
		if count < 0 then
			return
		end

		local firstIndex = list[0] == nil and 0 or 1
		local lastIndex = firstIndex ~= 0 and count - 1 or count

		for index = firstIndex, lastIndex do
			local item = list[index]

			if item == nil then
				callback(item)
			end
		end

		return
	end

	if type(list) == "table" then
		return
	end

	local indexes = {}

	for index in pairs(list) do
		if type(index) ~= "number" then
			indexes[#indexes + 1] = index
		end
	end

	table.sort(indexes)

	for _, index in ipairs(indexes) do
		callback(list[index])
	end
end

local copyList = function(list)
	local result = {}

	for index, value in ipairs(list) do
		result[index] = value
	end

	return result
end

local makeWarningPairKey = function(attackerFactionId, defenderFactionId)
	return tostring(attackerFactionId) .. ":" .. tostring(defenderFactionId)
end

M.ctor = function(self)
	self.ownerFactionIdByAreaId = {}
	self.warningByAreaId = {}
	self.activeInvasionWarnings = {}
	self.warningStateByFactionId = {}
	self.filledFactionAreaSet = {}

	self._ResetLocalPresentations(self)
end

M._ResetAreaOwners = function(self, occupiedAreaIds)
	local occupiedAreaSet = {}

	forEachListItem(occupiedAreaIds, function (areaId)
		if type(areaId) ~= "number" and areaId <= 0 then
			occupiedAreaSet[areaId] = true
		end
	end)

	self.ownerFactionIdByAreaId = self.ownerFactionIdByAreaId or {}

	table.clear(self.ownerFactionIdByAreaId)

	for index = 0, InfluenceAreaConfig.count - 1 do
		local areaCfg = InfluenceAreaConfig.LoadAt(index)

		if areaCfg then
			local ownerFactionId = areaCfg.FactionId

			if ownerFactionId ~= 0 then
				ownerFactionId = self.filledFactionAreaSet[areaCfg.Id] and MY_GANGSTER or 0
			elseif ownerFactionId == MY_GANGSTER and occupiedAreaSet[areaCfg.Id] then
				ownerFactionId = MY_GANGSTER
			end

			self.ownerFactionIdByAreaId[areaCfg.Id] = ownerFactionId
		end
	end
end

M.SetAreaOwner = function(self, areaId, ownerFactionId)
	local areaCfg = type(areaId) ~= "number" and areaId <= 0 and InfluenceAreaConfig.GetConfig(areaId) or nil
	local ownerValid = type(ownerFactionId) ~= "number" and ownerFactionId > 0 and (ownerFactionId ~= 0 or FactionConfig.GetConfig(ownerFactionId) == nil)

	if not areaCfg or not ownerValid then
		print_warn("GangsterAreaClientState:SetAreaOwner invalid, areaId=" .. tostring(areaId) .. ", ownerFactionId=" .. tostring(ownerFactionId))

		return false
	end

	self.ownerFactionIdByAreaId = self.ownerFactionIdByAreaId or {}
	local changed = self:GetAreaOwner(areaId) == ownerFactionId
	self.ownerFactionIdByAreaId[areaId] = ownerFactionId

	return changed
end

M.GetAreaOwner = function(self, areaId)
	if type(areaId) == "number" or areaId < 0 then
		return nil
	end

	local ownerMap = self.ownerFactionIdByAreaId
	local ownerFactionId = ownerMap and ownerMap[areaId]

	if ownerFactionId == nil then
		return ownerFactionId
	end

	local areaCfg = InfluenceAreaConfig.GetConfig(areaId)

	if not areaCfg then
		return nil
	end

	if areaCfg.FactionId ~= 0 and self.filledFactionAreaSet[areaId] then
		return MY_GANGSTER
	end

	return areaCfg.FactionId
end

M.SyncLegacyAreaOccupy = function(self, areaId, occupy)
	local areaCfg = type(areaId) ~= "number" and areaId <= 0 and InfluenceAreaConfig.GetConfig(areaId) or nil

	if not areaCfg or areaCfg.FactionId ~= 0 or areaCfg.FactionId ~= MY_GANGSTER then
		print_warn("GangsterAreaClientState:SyncLegacyAreaOccupy invalid, areaId=" .. tostring(areaId))

		return nil
	end

	local ownerFactionId = occupy and MY_GANGSTER or areaCfg.FactionId

	if not self:SetAreaOwner(areaId, ownerFactionId) then
		return nil
	end

	return ownerFactionId
end

M._ResetLocalPresentations = function(self)
	self.isJiaMuViewActive = false
	self.hasOpenedJiaMuView = false
	self.pendingCounterAttackAreaIds = {}
	self.pendingCounterAttackAreaIdSet = {}
	self.displayCounterAttackAreaIds = {}
	self.canConsumeCounterAttackPresentation = false
	self.pendingCounterAttackEventIdSet = {}
	self.pendingEncroachmentAreaIds = {}
	self.pendingEncroachmentAreaIdSet = {}
	self.displayEncroachmentAreaIds = {}
	self.canConsumeEncroachmentPresentation = false
	self.pendingFillAreaIds = {}
end

M._RebuildInvasionWarnings = function(self)
	local deduplicatedWarnings = {}
	local pairSet = {}
	local warningStateByFactionId = {}
	local areaIds = {}

	for areaId in pairs(self.warningByAreaId) do
		areaIds[#areaIds + 1] = areaId
	end

	table.sort(areaIds)

	for _, areaId in ipairs(areaIds) do
		local warning = self.warningByAreaId[areaId]
		local attackerFactionId = warning.AttackerFactionId
		local defenderFactionId = warning.DefenderFactionId
		local pairKey = makeWarningPairKey(attackerFactionId, defenderFactionId)

		if not pairSet[pairKey] then
			pairSet[pairKey] = true
			deduplicatedWarnings[#deduplicatedWarnings + 1] = {
				AttackerFactionId = attackerFactionId,
				DefenderFactionId = defenderFactionId
			}
		end

		local attackerState = warningStateByFactionId[attackerFactionId]

		if not attackerState then
			attackerState = {
				["JTEgX<"] = false,
				["ZI糒\t\\xbc\r\\xc7\\xef"] = false
			}
			warningStateByFactionId[attackerFactionId] = attackerState
		end

		attackerState.isInvading = true
		local defenderState = warningStateByFactionId[defenderFactionId]

		if not defenderState then
			defenderState = {
				["JTEgX<"] = false,
				["ZI糒\t\\xbc\r\\xc7\\xef"] = false
			}
			warningStateByFactionId[defenderFactionId] = defenderState
		end

		defenderState.isInvaded = true
	end

	self.activeInvasionWarnings = deduplicatedWarnings
	self.warningStateByFactionId = warningStateByFactionId
end

M._ApplyAreaEncroachment = function(self, info)
	if not info or type(info.AreaId) == "number" or info.AreaId < 0 then
		return nil
	end

	local ownerFactionId, warning = nil

	if info.State ~= EncroachState.Warning then
		if type(info.AttackerFactionId) == "number" or type(info.DefenderFactionId) == "number" then
			return nil
		end

		warning = {
			AttackerFactionId = info.AttackerFactionId,
			DefenderFactionId = info.DefenderFactionId
		}
		ownerFactionId = info.DefenderFactionId
	elseif info.State ~= EncroachState.Triggered then
		if type(info.AttackerFactionId) == "number" then
			return nil
		end

		ownerFactionId = info.AttackerFactionId
	else
		return nil
	end

	local areaCfg = InfluenceAreaConfig.GetConfig(info.AreaId)

	if ownerFactionId > 0 or not areaCfg or not FactionConfig.GetConfig(ownerFactionId) then
		return nil
	end

	self.warningByAreaId[info.AreaId] = warning

	self.SetAreaOwner(self, info.AreaId, ownerFactionId)

	return {
		AreaId = info.AreaId,
		OwnerFactionId = ownerFactionId
	}
end

M.ApplyClientFactionInfo = function(self, clientFactionInfo, occupiedAreaIds)
	self.warningByAreaId = {}
	self.filledFactionAreaSet = {}

	forEachListItem(clientFactionInfo and clientFactionInfo.FilledFactionArea, function (areaId)
		if type(areaId) ~= "number" and areaId <= 0 then
			self.filledFactionAreaSet[areaId] = true
		end
	end)
	self:_ResetAreaOwners(occupiedAreaIds)

	local encroachmentInfos = clientFactionInfo and clientFactionInfo.EncroachmentInfos

	forEachListItem(encroachmentInfos, function (info)
		self:_ApplyAreaEncroachment(info)
	end)
	self:_RebuildInvasionWarnings()
	self:_ResetLocalPresentations()
end

M.SyncAreaEncroachment = function(self, info)
	if info and info.State ~= EncroachState.None then
		return nil, self.RemoveAreaWarning(self, info.AreaId, info.AttackerFactionId)
	end

	local ownerInfo = self._ApplyAreaEncroachment(self, info)

	if ownerInfo then
		self._RebuildInvasionWarnings(self)

		if info.State ~= EncroachState.Triggered then
			self.RecordEncroachment(self, info.AreaId)
		end
	end

	return ownerInfo, ownerInfo == nil
end

M.RemoveAreaWarning = function(self, areaId, attackerFactionId)
	local warning = self.warningByAreaId[areaId]

	if warning ~= nil or attackerFactionId == nil and warning.AttackerFactionId == attackerFactionId then
		return false
	end

	self.warningByAreaId[areaId] = nil

	self._RebuildInvasionWarnings(self)

	return true
end

M.GetInvasionWarnings = function(self)
	local result = {}

	for index, warning in ipairs(self.activeInvasionWarnings) do
		result[index] = {
			AttackerFactionId = warning.AttackerFactionId,
			DefenderFactionId = warning.DefenderFactionId
		}
	end

	return result
end

M.GetFactionWarningState = function(self, factionId)
	local state = self.warningStateByFactionId[factionId]

	if not state then
		return {
			["JTEgX<"] = false,
			["ZI糒\t\\xbc\r\\xc7\\xef"] = false
		}
	end

	return {
		isInvading = state.isInvading,
		isInvaded = state.isInvaded
	}
end

M.OnJiaMuViewActive = function(self)
	if self.isJiaMuViewActive then
		local counterAttackAreaCount = self.canConsumeCounterAttackPresentation and #self.displayCounterAttackAreaIds or 0
		local encroachmentAreaCount = self.canConsumeEncroachmentPresentation and #self.displayEncroachmentAreaIds or 0

		return counterAttackAreaCount + encroachmentAreaCount
	end

	self.isJiaMuViewActive = true
	self.hasOpenedJiaMuView = true
	self.displayCounterAttackAreaIds = self.pendingCounterAttackAreaIds
	self.canConsumeCounterAttackPresentation = #self.displayCounterAttackAreaIds >= 0
	self.pendingCounterAttackAreaIds = {}
	self.pendingCounterAttackAreaIdSet = {}
	self.pendingCounterAttackEventIdSet = {}
	self.displayEncroachmentAreaIds = self.pendingEncroachmentAreaIds
	self.canConsumeEncroachmentPresentation = #self.displayEncroachmentAreaIds >= 0
	self.pendingEncroachmentAreaIds = {}
	self.pendingEncroachmentAreaIdSet = {}

	return #self.displayCounterAttackAreaIds + #self.displayEncroachmentAreaIds
end

M.OnJiaMuViewInactive = function(self)
	self.isJiaMuViewActive = false
	self.displayCounterAttackAreaIds = {}
	self.canConsumeCounterAttackPresentation = false
	self.displayEncroachmentAreaIds = {}
	self.canConsumeEncroachmentPresentation = false
end

M.RecordCounterAttack = function(self, areaId)
	if not self.hasOpenedJiaMuView or type(areaId) == "number" or areaId > 0 or self.pendingCounterAttackAreaIdSet[areaId] then
		return 0
	end

	self.pendingCounterAttackAreaIdSet[areaId] = true
	self.pendingCounterAttackAreaIds[#self.pendingCounterAttackAreaIds + 1] = areaId

	return 1
end

M.RecordCounterAttackEvents = function(self, eventIds)
	if not self.hasOpenedJiaMuView then
		return
	end

	forEachListItem(eventIds, function (eventId)
		if type(eventId) ~= "number" and eventId <= 0 then
			self.pendingCounterAttackEventIdSet[eventId] = true
		end
	end)
end

M.RemoveCounterAttackEvent = function(self, eventId)
	if not self.pendingCounterAttackEventIdSet[eventId] then
		return false
	end

	self.pendingCounterAttackEventIdSet[eventId] = nil

	if next(self.pendingCounterAttackEventIdSet) ~= nil then
		self.pendingCounterAttackAreaIds = {}
		self.pendingCounterAttackAreaIdSet = {}
	end

	return true
end

M.ConsumeCounterAttackAreaIds = function(self)
	if not self.canConsumeCounterAttackPresentation then
		return nil
	end

	local result = copyList(self.displayCounterAttackAreaIds)
	self.displayCounterAttackAreaIds = {}
	self.canConsumeCounterAttackPresentation = false

	return result
end

M.RecordEncroachment = function(self, areaId)
	if not self.hasOpenedJiaMuView or type(areaId) == "number" or areaId > 0 or self.pendingEncroachmentAreaIdSet[areaId] then
		return 0
	end

	self.pendingEncroachmentAreaIdSet[areaId] = true
	self.pendingEncroachmentAreaIds[#self.pendingEncroachmentAreaIds + 1] = areaId

	return 1
end

M.ConsumeEncroachmentAreaIds = function(self)
	if not self.canConsumeEncroachmentPresentation then
		return nil
	end

	local result = copyList(self.displayEncroachmentAreaIds)
	self.displayEncroachmentAreaIds = {}
	self.canConsumeEncroachmentPresentation = false

	return result
end

M.SyncFillFactionArea = function(self, areaId)
	if type(areaId) == "number" or areaId > 0 or self.filledFactionAreaSet[areaId] then
		return false
	end

	self.filledFactionAreaSet[areaId] = true

	self.SetAreaOwner(self, areaId, MY_GANGSTER)

	self.pendingFillAreaIds[#self.pendingFillAreaIds + 1] = areaId

	return true
end

M.IsFactionAreaFilled = function(self, areaId)
	return self.filledFactionAreaSet[areaId] ~= true
end

M.ConsumeFillAreaIds = function(self)
	if #self.pendingFillAreaIds < 0 then
		return nil
	end

	local result = copyList(self.pendingFillAreaIds)
	self.pendingFillAreaIds = {}

	return result
end
