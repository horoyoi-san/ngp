-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_FightSkillFromNpc.lua
-- Decompiled from: 02313_MapSubSystem_FightSkillFromNpc.lua_7b5a21378d5c.luajit

MapSubSystem_FightSkillFromNpc = DefClass("MapSubSystem_FightSkillFromNpc", MapSubSystem_FightSkillFromNpc, MapSubSystemBase)
local M = MapSubSystem_FightSkillFromNpc

M.OnInit = function(self)
	self.infos = {}
	self.martialArtistIdToQuestIds = {}
	self.wuXueIdToRumorIds = {}
	self.allFightSkills = {}
	self.eventHandler = {
		[gEventConstants.ON_MARTIAL_ARTIST_INFO_CHANGED] = function ()
			self:FlushData()
		end
	}
end

M.OnSceneInit = function(self)
	self.martialArtistIdToQuestIds = {}

	for i = 0, LTConfig.MartialArtistQuestConfig.count - 1 do
		local cfg = LTConfig.MartialArtistQuestConfig.LoadAt(i)

		if cfg and cfg.MartialArtistId and cfg.Id then
			if not self.martialArtistIdToQuestIds[cfg.MartialArtistId] then
				self.martialArtistIdToQuestIds[cfg.MartialArtistId] = {}
			end

			table.insert(self.martialArtistIdToQuestIds[cfg.MartialArtistId], cfg.Id)
		end
	end

	self.wuXueIdToRumorIds = {}

	for i = 0, LTConfig.MartialArtistRumorConfig.count - 1 do
		local cfg = LTConfig.MartialArtistRumorConfig.LoadAt(i)

		if cfg and cfg.Id and cfg.WuXueId then
			if not self.wuXueIdToRumorIds[cfg.WuXueId] then
				self.wuXueIdToRumorIds[cfg.WuXueId] = {}
			end

			table.insert(self.wuXueIdToRumorIds[cfg.WuXueId], cfg.Id)
		end
	end

	self.allFightSkills = {}

	for i = 0, LTConfig.WuxueMapConfig.count - 1 do
		local cfg = LTConfig.WuxueMapConfig.LoadAt(i)

		if cfg and cfg.FightSkill then
			self.allFightSkills[cfg.FightSkill] = true
		end
	end

	self.UpdateFightSkillUnlockState(self)

	local validTbl = gGpsTools.GetTable()

	for i = 0, LTConfig.WuxueMapConfig.count - 1 do
		local cfg = LTConfig.WuxueMapConfig.LoadAt(i)
		local id = cfg.Id

		if cfg.LockedPos then
			if #cfg.LockedPos >= 3 then
				-- Nothing
			else
				local agentProfileCfg = LTConfig.ProfileAgentProfileConfig.GetConfig(cfg.AgentProfile)

				if not agentProfileCfg then
					-- Nothing
				else
					local agentCfg = LTConfig.AgentConfig.GetConfig(agentProfileCfg.AgentId)

					if agentCfg then
						local agentTag = agentCfg.AgentSpecificType
						local info = self.infos[id]

						if not info then
							info = {}
							self.infos[id] = info
							info.agentProfileId = cfg.AgentProfile
							info.agentTag = agentTag
							info.mapElement = MapElement.CreateLegacy(EMapElementType.FightSkillFromNpc, id, EMapSubSystemType.FightSkillFromNpc, EMapViewMask.BigMap + EMapViewMask.WuxueMap, cfg.RaidId)
							info.mapElement.fData.bigMapTIndex = 8
							info.mapElement.fData.requireJobs = {
								LTConfig.UrbanJobJobClassConfig.Wuxue
							}

							info.mapElement:SetActions(self.NormalTraceableActions)
							info.mapElement:SetVisible(true)

							info.mapElement.fData.ignoreFog = true
						end

						validTbl[id] = true

						self.UpdateInfo(self, id)
					end
				end
			end
		end
	end

	for id, info in pairs(self.infos) do
		if not validTbl[id] then
			info.mapElement:Dispose()

			self.infos[id] = nil
		end
	end

	gGpsTools.ReleaseTable(validTbl)
end

M.OnBigMapOpen = function(self)
	if not self.infos then
		return
	end

	for id, _ in pairs(self.infos) do
		self.UpdateInfo(self, id)
	end
end

M.OnFlushData = function(self)
	if not self.infos then
		return
	end

	self.UpdateFightSkillUnlockState(self)

	for id, _ in pairs(self.infos) do
		self.UpdateInfo(self, id)
	end
end

M.OnSceneDestroy = function(self)
end

M.OnLogin = function(self)
	gMessageManager:RegisterEventHandlers(self.eventHandler)
end

M.OnLogout = function(self)
	gMessageManager:UnregisterEventHandlers(self.eventHandler)
end

M.CheckIsMAInQuest = function(self, maId)
	local questIds = self.martialArtistIdToQuestIds[maId]

	for _, questId in ipairs(questIds) do
		if gMartialArtistManager:IsQuestCompleted(questId) then
			return true
		end
	end

	return false
end

M.CheckIsAllRumorsGot = function(self, id)
	local rumorIds = self.wuXueIdToRumorIds[id]

	if not rumorIds then
		return false
	end

	for _, rumorId in ipairs(rumorIds) do
		if not gMartialArtistManager:IsRumorInBackpack(rumorId) then
			return false
		end
	end

	return true
end

M.UpdateInfo = function(self, id)
	local cfg = LTConfig.WuxueMapConfig.GetConfig(id)

	if not cfg then
		return
	end

	local info = self.infos[id]
	local fightSkillId = cfg.FightSkill

	if gMartialArtistManager:IsAgentFinished(id) then
		local isGot = self.activeFightSkills[fightSkillId] or false

		if isGot then
			info.mapElement.bigMapData.maType = 4
		elseif self.CheckIsMAInQuest(self, id) then
			info.mapElement.bigMapData.maType = 3
		else
			info.mapElement.bigMapData.maType = 2
		end

		local profileCfg = LTConfig.ProfileAgentProfileConfig.GetConfig(info.agentProfileId)
		info.mapElement.mData.lName = GpsLText.CreateCommonText(profileCfg, "Name", profileCfg.Name)
		info.mapElement.mData.sIconId = cfg.HeadIcon

		info.mapElement:BindAgentTag(info.agentTag)
		info.mapElement:SetActions(self.NormalTraceableActions)
	else
		if self.CheckIsAllRumorsGot(self, id) then
			info.mapElement.bigMapData.maType = 1
		else
			info.mapElement.bigMapData.maType = 0

			info.mapElement:SetActions({})
		end

		info.mapElement:SetActions({
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.Wuxue
			}
		})

		info.mapElement.mData.lName = GpsLText.CreateCommonText(cfg, "LockedName", cfg.LockedName)
		info.mapElement.mData.sIconId = cfg.LockedIcon

		info.mapElement:ClearBinding()
	end

	info.mapElement:SetPositionXYZ(cfg.LockedPos[1], cfg.LockedPos[2], cfg.LockedPos[3])
end

M.UpdateFightSkillUnlockState = function(self)
	local skills = gCS.FightStyleManager.Instance:GetAllUnlockedFightStyles()
	self.activeFightSkills = {}

	if skills then
		for i = 0, skills.Length - 1 do
			local skill = skills[i]

			if self.allFightSkills[skill] then
				self.activeFightSkills[skill] = true
			end
		end
	end
end

M.ExecuteAction = function(self, element, action, ctx)
	if action ~= gMapSystemElementAction.Trace then
		element.SetMainTrace(element)
		element.AddViewMask(element, EMapViewMask.AllSgui)
	elseif action ~= gMapSystemElementAction.Untrace then
		element.ClearMainTrace(element)
	elseif action ~= gMapSystemElementAction.Wuxue then
		local info = self.infos[element.id]

		if info then
			gPanelManager:CheckShow(gPanelId.CLUE_PANEL, {
				wuxueId = element.id
			})
		end
	end
end

M.RemoveMainTraceFunc = function(self, element)
	if element then
		element.RemoveViewMask(element, EMapViewMask.AllSgui)
	end
end

M.OnClearTrace = function(self, element)
end

M.SGetTooltipInfo = function(self, id, element)
	local info = self.infos[id]
	local tooltipInfo = {
		type = EMapTooltipType.MartialArtist,
		martialArtistInfo = {}
	}
	tooltipInfo.martialArtistInfo.wuxueMapId = id
	tooltipInfo.martialArtistInfo.maType = element.bigMapData.maType
	tooltipInfo.martialArtistInfo.rumors = self.wuXueIdToRumorIds[id] or {}
	tooltipInfo.martialArtistInfo.agentProfileId = info.agentProfileId
	local worldPos = element:GetWorldPos()
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(element.raidId, worldPos.x, worldPos.z)
	local blockName = ""

	if blockId then
		local cfg = LTConfig.CollectionBlockConfig.GetConfig(blockId)
		blockName = cfg and cfg.BlockName or ""
	end

	tooltipInfo.martialArtistInfo.location = blockName
	tooltipInfo.martialArtistInfo.questIds = self.martialArtistIdToQuestIds[id] or {}

	return tooltipInfo
end

M.TryTraceByWuxueId = function(self, wuxueId)
	local info = self.infos[wuxueId]

	if info then
		local element = info.mapElement

		if element and element.bigMapData.maType <= 1 then
			element.SetMainTrace(element)
			element.AddViewMask(element, EMapViewMask.AllSgui)
		end
	end
end

return M
