local FilterGroupConfig = LTConfig.GpsFilterGroupConfig
local FilterTagConfig = LTConfig.GpsFilterTagConfig
C_NewMap_FilterLogicCore = DefClass("C_NewMap_FilterLogicCore", C_NewMap_FilterLogicCore)
local M = C_NewMap_FilterLogicCore
ENewMapFilterMode = {
	Multiple = 1,
	Exclusive = 0
}
ENewMapFilterGroupToggleMode = {
	ActiveAllTime = 1,
	Toggle = 0
}

function M:ctor(filterMode, showNonTagElements, groupToggleMode, bigMap)
	self.filterMode = filterMode
	self.showNonTagElements = showNonTagElements
	self.groupToggleMode = groupToggleMode
	self.groups = {}
	self.activeGroups = {}
	self.bigMap = bigMap

	self:InitTagGroup()

	self.isFiltering = nil
end

function M:RefreshFilterFsm()
	self:UpdateFilterStateWhenGroupChange()
	self:UpdateFilterStateWhenTagChange()
end

function M:InitTagGroup()
	local staticFilterTagGroups = gBigMapHelper:GetStaticFilterTagGroups()

	for i = 1, #staticFilterTagGroups do
		local staticData = staticFilterTagGroups[i]
		local groupCfg = FilterGroupConfig.GetConfig(staticData.id)
		local tagGroup = self:CreateGroup(staticData.id, groupCfg.Name)

		for _, tagId in ipairs(staticData.tags) do
			self:AddTagToGroup(staticData.id, tagId)
		end

		tagGroup.visible = table.count(tagGroup.tags) > 0
		tagGroup.active = false

		if self.groupToggleMode == ENewMapFilterGroupToggleMode.ActiveAllTime then
			tagGroup.active = true
			self.activeGroups[tagGroup.id] = tagGroup
		end
	end
end

function M:SetView(view)
	self.view = view

	if view then
		view:OnRefreshAllRequest()
		view:OnFilterStateChange(self:GetFilterState())
	end
end

function M:CreateGroup(groupId, groupName)
	local group = {
		visible = false,
		active = false,
		id = groupId,
		name = groupName,
		tags = {},
		expandTags = {},
		elementDict = {}
	}
	self.groups[groupId] = group

	return group
end

function M:AddTagToGroup(groupId, tagId)
	local tagCfg = FilterTagConfig.GetConfig(tagId)

	if tagCfg.OnlyMobile and gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local linkModes = tagCfg.LinkShowMode

	if table.count(linkModes) > 0 and not array.contains(linkModes, gMapUtils:UXLinkModeEnum2ConfigEnum(gLinkManager.LinkMode)) then
		return
	end

	local group = self.groups[groupId]

	if tagCfg.Expand then
		table.insert(group.expandTags, tagId)
	elseif not tagCfg.IsPermanent then
		local tag = {
			isExpandedTag = false,
			id = tagId,
			name = tagCfg.Name,
			enabled = gBigMapHelper:LoadFilterSwitch(groupId, tagId)
		}
		group.tags[tagId] = tag
	end
end

function M:ToggleGroup(groupId)
	if self.groupToggleMode == ENewMapFilterGroupToggleMode.ActiveAllTime then
		return false
	end

	local group = self.groups[groupId]

	if self.filterMode == ENewMapFilterMode.Exclusive then
		if group.active then
			self:DeactivateGroup(groupId)
		else
			for id, _ in pairs(self.activeGroups) do
				if id ~= groupId then
					self:DeactivateGroup(id)
				end
			end

			self:ActivateGroup(groupId)
		end
	elseif group.active then
		self:DeactivateGroup(groupId)
	else
		self:ActivateGroup(groupId)
	end

	self.bigMap:HideCandidatePanel()
	self.bigMap:ApplyFilter()
end

function M:ToggleTag(groupId, tagId)
	local group = self.groups[groupId]

	if not group or not group.tags[tagId] then
		return false
	end

	local tag = group.tags[tagId]
	tag.enabled = not tag.enabled

	gBigMapHelper:SaveFilterSwitch(groupId, tagId, tag.enabled)
	self:UpdateFilterStateWhenTagChange()
	self.bigMap:ApplyFilter()

	if self.view then
		self.view:OnTagToggle(groupId, tagId, tag.enabled)
	end

	return true
end

function M:ToggleAllTags(groupId, enabled)
	local group = self.groups[groupId]

	if not group then
		return
	end

	local hasChange = false

	for tagId, tag in pairs(group.tags) do
		if tag.enabled ~= enabled then
			tag.enabled = enabled

			gBigMapHelper:SaveFilterSwitch(groupId, tagId, enabled)

			hasChange = true

			if self.view then
				self.view:OnTagToggle(groupId, tagId, enabled)
			end
		end
	end

	if hasChange then
		self.bigMap:ApplyFilter()
		self:UpdateFilterStateWhenTagChange()
	end
end

function M:ActivateGroup(groupId)
	local group = self.groups[groupId]

	if not group then
		return
	end

	if group.active then
		return
	end

	group.active = true
	self.activeGroups[groupId] = group

	self.bigMap:ApplyFilter()
	self:UpdateFilterStateWhenGroupChange()

	if self.view then
		self.view:OnGroupToggle(groupId, true)
	end
end

function M:DeactivateGroup(groupId)
	local group = self.groups[groupId]

	if not group.active then
		return
	end

	group.active = false
	self.activeGroups[groupId] = nil

	self.bigMap:ApplyFilter()
	self:UpdateFilterStateWhenGroupChange()

	if self.view then
		self.view:OnGroupToggle(groupId, false)
	end
end

function M:CancelAllFilters()
	for groupId, _ in pairs(self.activeGroups) do
		local group = self.groups[groupId]

		if self.groupToggleMode == ENewMapFilterGroupToggleMode.ActiveAllTime then
			self:ToggleAllTags(groupId, true)
		elseif group.active then
			group.active = false
			self.activeGroups[groupId] = nil
		end
	end

	self.bigMap:ApplyFilter()
	self:UpdateFilterStateWhenGroupChange()
	self:UpdateFilterStateWhenTagChange()

	if self.view then
		self.view:OnRefreshAllRequest()
	end
end

function M:CheckFilter(elementId, filterTag, filterTag2)
	if not self:HasActiveVisibleGroup() then
		return true
	end

	if filterTag == nil and filterTag2 == nil then
		return self.showNonTagElements
	end

	local isPermanentFilter = filterTag and gBigMapHelper:IsPermanentTag(filterTag) or filterTag2 and gBigMapHelper:IsPermanentTag(filterTag2)

	if isPermanentFilter then
		return true
	end

	local actualFilterTag = filterTag
	local actualFilterTag2 = filterTag2

	if filterTag and gBigMapHelper:IsExpandTag(filterTag) then
		actualFilterTag = gBigMapHelper:GetElementTagId(elementId)
	end

	if filterTag2 and gBigMapHelper:IsExpandTag(filterTag2) then
		actualFilterTag2 = gBigMapHelper:GetElementTagId(elementId)
	end

	if not actualFilterTag and not actualFilterTag2 then
		return false
	end

	for groupId, group in pairs(self.activeGroups) do
		if not group.visible then
			-- Nothing
		elseif self:CheckTagEnabled(groupId, actualFilterTag) or self:CheckTagEnabled(groupId, actualFilterTag2) then
			return true
		end
	end

	return false
end

function M:CheckTagEnabled(groupId, tagId)
	local group = self.groups[groupId]

	if not group.tags[tagId] then
		return false
	end

	return self.groups[groupId].tags[tagId].enabled
end

function M:OnAddElement(elementId)
	local element = gMapSystem:GetByInstanceId(elementId)

	if not self:CheckElementAddCondition(element) then
		return
	end

	local filterTag, filterTag2 = self.bigMap:GetFilterTag(elementId)
	local foundGroupId = nil

	for groupId, group in pairs(self.groups) do
		if #group.expandTags > 0 then
			for _, expandTagId in ipairs(group.expandTags) do
				if expandTagId == filterTag or expandTagId == filterTag2 then
					local elementTagId = element:GetElementFilterId()
					local tagName = element.fData.filterLName:GetText()
					local expandedTag = {
						isExpandedTag = true,
						id = elementTagId,
						name = tagName,
						enabled = gBigMapHelper:LoadFilterSwitch(groupId, elementTagId),
						elementId = elementId
					}
					group.tags[elementTagId] = expandedTag
					group.elementDict[elementId] = true
					foundGroupId = groupId

					break
				end
			end
		end
	end

	if foundGroupId then
		self:OnTagListDirty(foundGroupId)
	end
end

function M:OnRemoveElement(elementId)
	local foundGroupId = nil

	for groupId, group in pairs(self.groups) do
		if group.elementDict[elementId] then
			group.elementDict[elementId] = nil

			for tagId, tag in pairs(group.tags) do
				if tag.isExpandedTag and tag.elementId == elementId then
					group.tags[tagId] = nil
					foundGroupId = groupId

					break
				end
			end
		end
	end

	if foundGroupId then
		self:OnTagListDirty(foundGroupId)
	end
end

function M:GetGroup(groupId)
	return self.groups[groupId]
end

function M:GetAllGroups()
	return self.groups
end

function M:HasActiveVisibleGroup()
	for _, group in pairs(self.activeGroups) do
		if group.visible then
			return true
		end
	end

	return false
end

function M:GetFilterState()
	if self.groupToggleMode == ENewMapFilterGroupToggleMode.ActiveAllTime then
		local ret = false

		for _, group in pairs(self.groups) do
			if group.visible and not self:CheckAllTagsInGroup(group.id) then
				ret = true

				break
			end
		end

		return ret
	else
		return self:HasActiveVisibleGroup()
	end
end

function M:CheckAllTagsInGroup(groupId)
	local group = self.groups[groupId]

	if not group then
		return false
	end

	for _, tag in pairs(group.tags) do
		if not tag.enabled then
			return false
		end
	end

	return true
end

function M:CheckAllTagsDisabledInGroup(groupId)
	local group = self.groups[groupId]

	if not group then
		return false
	end

	for _, tag in pairs(group.tags) do
		if tag.enabled then
			return false
		end
	end

	return true
end

function M:OnTagListDirty(groupId)
	local group = self.groups[groupId]
	local prevVisible = group.visible
	local visible = table.count(group.tags) > 0
	group.visible = visible

	if prevVisible ~= visible then
		self.bigMap:ApplyFilter()
		self:UpdateFilterStateWhenGroupChange()
		self:UpdateFilterStateWhenTagChange()

		if self.view then
			self.view:OnRefreshAllRequest()
		end
	elseif self.view then
		self.view:OnTagListDirty(groupId)
	end
end

function M:UpdateFilterStateWhenGroupChange()
	if self.groupToggleMode == ENewMapFilterGroupToggleMode.Toggle then
		local prevFiltering = self.isFiltering
		local isFiltering = self:GetFilterState()

		if isFiltering ~= prevFiltering then
			if isFiltering then
				self.bigMap:SendFSMSignal(EBigMapFSMSignal.EnableFilter)
			else
				self.bigMap:SendFSMSignal(EBigMapFSMSignal.DisableFilter)
			end

			if self.view then
				self.view:OnFilterStateChange(isFiltering)
			end

			self.isFiltering = isFiltering
		end
	end
end

function M:UpdateFilterStateWhenTagChange()
	if self.groupToggleMode == ENewMapFilterGroupToggleMode.ActiveAllTime then
		local prevFiltering = self.isFiltering
		local isFiltering = self:GetFilterState()

		if isFiltering ~= prevFiltering then
			if isFiltering then
				self.bigMap:SendFSMSignal(EBigMapFSMSignal.EnableFilter)
			else
				self.bigMap:SendFSMSignal(EBigMapFSMSignal.DisableFilter)
			end

			if self.view then
				self.view:OnFilterStateChange(isFiltering)
			end

			self.isFiltering = isFiltering
		end
	end
end

function M:CheckElementAddCondition(element)
	local condKey = element.bigMapData.addToFilterMenuCondKey

	if not condKey then
		return true
	end

	local func = self[condKey]

	if not func then
		print_error("FilterMenuCore: Element Condition Key Func Not Found:" .. condKey)

		return true
	end

	return func(self, element)
end

function M:Condition_SpiritAcquisition(element)
	local cfg = LTConfig.AgentDataSetsActivityConfig.GetConfig(element.userdata.agentActivityId)
	local npcCultivationId = cfg.NpccultivationId
	local serverSpiritAcqUnlockData1 = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfosDic
	local serverSpiritAcqUnlockData2 = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfosDic

	if not serverSpiritAcqUnlockData1[npcCultivationId] and not serverSpiritAcqUnlockData2[npcCultivationId] then
		return false
	end

	return true
end

return M
