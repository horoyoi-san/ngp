local RestaurantConfig = LTConfig.RestaurantConfig
local NPCChatGamePlayTypeConfig = LTConfig.NPCChatGamePlayTypeConfig
local M = gNpcInviteManager or {}
M.InviteNpcList = {}
M.UPDATE_FREQUENCY = 30
M.DISTANCE_THRESHOLD = 30
M.LAST_UPDATE_FRAME = 0

function M:RefreshDynamicUpdate()
	if table.isNilOrEmpty(self.InviteNpcList) then
		gLuaClient:UnregisterDynamicUpdate("gNpcInviteManager")
	else
		gLuaClient:RegisterDynamicUpdate("gNpcInviteManager", self)
	end
end

function M:OnUpdate()
	local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

	if self.UPDATE_FREQUENCY < Time.frameCount - M.LAST_UPDATE_FRAME and myPlayerCSUnit then
		for k, v in pairs(self.InviteNpcList) do
			if self:CheckOutOfRange(v.csUnit) then
				gCS.BaseUnitUtils.DestroyAgentUnit(v.csUnit, true, true, false)

				self.InviteNpcList[k] = nil

				if v.manager.OnInviteNpcOutOfRange then
					v.manager:OnInviteNpcOutOfRange()
				end
			end
		end

		M.LAST_UPDATE_FRAME = Time.frameCount

		self:RefreshDynamicUpdate()
	end
end

function M:CheckOutOfRange(csUnit)
	if csUnit == nil then
		return true
	end

	local dist, valid = gCS.LuaUtils.GetUnitPlayerDist(csUnit.Pid, nil)

	if not valid then
		return true
	end

	return self.DISTANCE_THRESHOLD < dist
end

function M:AddClientInviteNpc(csUnit, manager)
	self.InviteNpcList[csUnit.Pid] = {
		csUnit = csUnit,
		manager = manager
	}

	self:RefreshDynamicUpdate()
end

function M:RemoveClientInviteNpc(csUnit)
	local pid = csUnit.Pid

	if self.InviteNpcList[pid] then
		gCS.BaseUnitUtils.DestroyAgentUnit(self.InviteNpcList[pid].csUnit, true, true, false)

		self.InviteNpcList[pid] = nil

		self:RefreshDynamicUpdate()
	end
end

function M:InviteClientNpcForGamePlayWithPos(npcConfigId, gameplay, manager, trans, loadCompleteHandler, suitId)
	if gCS.LuaUtils.IsNull(trans) then
		return self:InviteClientNpcForGamePlay(npcConfigId, gameplay, manager, loadCompleteHandler, suitId)
	elseif gameplay == NPCChatGamePlayTypeConfig.Restaurant or gameplay == NPCChatGamePlayTypeConfig.MaidHouse or gameplay == NPCChatGamePlayTypeConfig.FastFood or gameplay == NPCChatGamePlayTypeConfig.MaidTea then
		local pos = trans.position
		local angle = trans.eulerAngles
		local csUnit = gCS.LuaUtils.CreateClientAgentByCfg(npcConfigId, pos, angle, loadCompleteHandler, suitId)

		if csUnit then
			self:AddClientInviteNpc(csUnit, manager)
		end

		return csUnit
	end
end

function M:InviteClientNpcForGamePlay(npcConfigId, gameplay, manager, loadCompleteHandler, suitId)
	if gameplay == NPCChatGamePlayTypeConfig.Restaurant or gameplay == NPCChatGamePlayTypeConfig.MaidHouse or gameplay == NPCChatGamePlayTypeConfig.FastFood or gameplay == NPCChatGamePlayTypeConfig.MaidTea then
		local npcWaypoint = gSpoonMgr:GetWayPointByNameOrId(RestaurantConfig.RestaurantWayPointName .. gameplay)

		if npcWaypoint then
			local trans = npcWaypoint.transform
			local pos = trans.position
			local angle = trans.eulerAngles
			local csUnit = gCS.LuaUtils.CreateClientAgentByCfg(npcConfigId, pos, angle, loadCompleteHandler, suitId)

			if csUnit then
				self:AddClientInviteNpc(csUnit, manager)
			end

			return csUnit
		end
	end
end

gNpcInviteManager = M
