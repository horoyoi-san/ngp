local FactionConfig = LTConfig.FactionConfig
local DispositionConfig = LTConfig.FactionDispositionConfig
C_BigMapTooltip_Faction = DefClass("C_BigMapTooltip_Faction", C_BigMapTooltip_Faction, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Faction
local TOOLTIP_FACTION = 1
local MAX_LEVEL = 6

function M:OnActive()
	if not self._eventHandler then
		function self._eventHandler(eventId, param)
			if self.container:CheckTooltipHandlerActive(self) then
				self:RefreshFactionInfo()
			end
		end
	end

	self._registeredEvent = true

	gMessageManager:AddMessageListener(gEventConstants.FACTION_LEVEL_CHANGE, self._eventHandler)
end

function M:OnInActive()
	if self._registeredEvent then
		self._registeredEvent = false

		gMessageManager:RemoveMessageListener(gEventConstants.FACTION_LEVEL_CHANGE, self._eventHandler)
	end
end

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("factionInfo") then
		return
	end

	self:GetStore("MapFactionTooltipStore")
	self:SetUpHeader()
	self:SetUpLocation()

	self.store.tooltipType = TOOLTIP_FACTION
	local info = self.tooltipInfo.factionInfo
	local factionId = info.factionId

	self:RefreshFactionInfo()
	self.bigMap.compRefs.FactionOverride:AskFactionInteractionInfo(factionId, function (factionId, newInteractionCnt, newGreetCnt)
		self:RefreshInteractionInfo(factionId, newInteractionCnt, newGreetCnt)
	end)
end

function M:SetUpActions(store, actions, blockReason)
	local info = self.tooltipInfo.factionInfo
	store.clickMain = self.bigMap:CreateActionWithArgs("OnClickUpgrade", info.factionId, self)
end

function M:RefreshFactionInfo()
	local info = self.tooltipInfo.factionInfo
	local factionId = info.factionId
	local factionInfo = gClientUtils.GetFactionInfo(factionId)

	if not factionInfo then
		print_error("BigMapTooltip_Faction:SetUpInfo factionInfo is nil, factionId:", factionId)

		return
	end

	local cfg = FactionConfig.GetConfig(factionId)
	local curLevel = factionInfo.DispositionLevel
	local levelCfg = DispositionConfig.GetConfig(curLevel)
	self.store.attitudeIconId = levelCfg.DispositionIcon
	self.store.attitudeName = levelCfg.name
	local curDispositionValue = factionInfo.Disposition - levelCfg.DispositionValue

	if curLevel < MAX_LEVEL then
		local nextLevelCfg = DispositionConfig.GetConfig(curLevel + 1)
		local maxDispositionValue = nextLevelCfg.DispositionValue - levelCfg.DispositionValue
		self.store.attitudeProgressText = string.format("%d/%d", curDispositionValue, maxDispositionValue)
	else
		self.store.attitudeProgressText = string.format("%d/-", curDispositionValue)
	end

	local effects = FactionConfig.GetConfig(cfg.LevelEffectTooltip)

	if effects then
		self.buffList = self:GetLevelTooltipContent(effects, curLevel)
		self.store.buffList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderBuffItem", self)
		self.store.buffList.luaSimpleDynamicRenderItem = self.bigMap:CreateAction("OnRenderBuffItem", self)

		self.store.buffList:SetSimpleList(#self.buffList)
	end
end

function M:RefreshInteractionInfo(factionId, interactionCnt, greetCnt)
	if not self.container:CheckTooltipHandlerActive(self) then
		return
	end

	if self.tooltipInfo.factionInfo.factionId ~= factionId then
		return
	end

	if interactionCnt ~= nil then
		self.store.interactionCount = tostring(interactionCnt)
	end

	if greetCnt ~= nil then
		self.store.thankedCount = tostring(greetCnt)
	end
end

function M:OnRenderBuffItem(btn, index)
	index = index + 1
	local data = self.buffList[index]
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)
	store.content = data.content
	store.iconId = data.iconId
end

function M:OnClickUpgrade(factionId)
	gPanelManager:CheckShow(gPanelId.FACTION_UPGRADE_PANEL, {
		factionId = factionId
	})
end

function M:GetLevelTooltipContent(cfg, level)
	local contents = nil

	if level == 1 then
		contents = cfg.hatredDescription
	elseif level == 2 then
		contents = cfg.hostilityDescription
	elseif level == 3 then
		contents = cfg.indifferentDescription
	elseif level == 4 then
		contents = cfg.friendlyDescription
	elseif level == 5 then
		contents = cfg.worshipDescription
	end

	if not string.is_null_or_empty(contents) then
		local iconId = cfg.EffectIcon
		local dataList = {}
		contents = string.split(contents, "\n")

		for i, content in ipairs(contents) do
			table.insert(dataList, {
				content = content,
				iconId = iconId
			})
		end

		return dataList
	end

	return {}
end
