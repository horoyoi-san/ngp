EBigMapOperationType = {
	WaitFocus = 6,
	FocusTexPos = 3,
	Select = 5,
	WaitSelect = 4
}
EBigMapFilterTagType = {
	AvailableSpirits = 3,
	NeedBadge = 2,
	FilterConfig = 1
}
gBigMapHelper = gBigMapHelper or {}
local M = gBigMapHelper

function M:Init()
	self.IconStateType = LTConfig.GpsMapIconScaleTypeConfig.IconStateType
	EBigMapIconScaleState = {
		Normal = self.IconStateType.Normal,
		Thumbnail = self.IconStateType.Thumbnail,
		None = self.IconStateType.None
	}
	self._filterState = {
		tags = {},
		groups = {
			activeGroupIds = {}
		}
	}
	self._inScreenSave = {
		groups = {}
	}
	self._rightTopSave = {
		groups = {}
	}
end

function M:OnLogin()
	self:ReloadIcon2FilterTags()
	self:ReloadFilterConfig()
end

function M:TryFocusOnBigMapByGpsId(gpsId)
	local bigMap = gStoreManager:GetStoreGroup("NewMapPanelStore")

	if not bigMap or not bigMap.STATE_OnShowOnce then
		return false
	end

	bigMap:ScheduleOperation(EBigMapOperationType.WaitFocus, {
		gpsId = gpsId
	})

	return true
end

function M:TrySelectOnBigMapByGpsId(gpsId)
	local bigMap = gStoreManager:GetStoreGroup("NewMapPanelStore")

	if not bigMap or not bigMap.STATE_OnShowOnce then
		return false
	end

	bigMap:ScheduleOperation(EBigMapOperationType.Select, {
		gpsId = gpsId
	})

	return true
end

function M:GetScaleLevel(scale)
	local isNonMobile = gCS.LuaUtils.IsNonMobileAdaptive()
	local scaleCfgs = LTConfig.GpsConfig.BigMapScaleLevelData

	for i = 1, #scaleCfgs do
		local cfg = scaleCfgs[i]

		if isNonMobile then
			if scale < cfg.maxScale then
				return i, cfg.bgScaleLevel
			end
		elseif scale < cfg.maxScale * 0.68 then
			return i, cfg.bgScaleLevel
		end
	end

	return #scaleCfgs, scaleCfgs[#scaleCfgs].bgScaleLevel
end

function M:GetScaleRange()
	local scaleCfgs = LTConfig.GpsConfig.BigMapScaleLevelData

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return scaleCfgs[1].minScale, scaleCfgs[#scaleCfgs].maxScale
	else
		return scaleCfgs[1].minScale * 0.68, scaleCfgs[#scaleCfgs].maxScale * 0.68
	end
end

function M:GetIconState(scaleLevel, iconShowType)
	local cfg = LTConfig.GpsMapIconScaleTypeConfig.GetConfig(iconShowType)

	if not cfg then
		return EBigMapIconScaleState.Normal
	end

	return cfg.IconState[scaleLevel]
end

function M:ReloadFilterConfig()
	local groupDatas = {}
	local groupCfgs = {}

	for i = 0, LTConfig.GpsFilterGroupConfig.count - 1 do
		local cfg = LTConfig.GpsFilterGroupConfig.LoadAt(i)

		table.insert(groupCfgs, cfg)
	end

	table.sort(groupCfgs, function (a, b)
		return a.Id < b.Id
	end)

	for i = 1, #groupCfgs do
		local cfg = groupCfgs[i]
		local groupData = {
			id = cfg.Id,
			tags = {}
		}

		for j = 0, LTConfig.GpsFilterTagConfig.count - 1 do
			local tagCfg = LTConfig.GpsFilterTagConfig.LoadAt(j)

			if tagCfg.Group == cfg.Id then
				table.insert(groupData.tags, tagCfg.Id)
			end
		end

		table.sort(groupData.tags)
		table.insert(groupDatas, groupData)
	end

	self._staticFilterGroupDatas = groupDatas

	self:LoadSpecialFilterTags()
end

function M:ReloadIcon2FilterTags()
	self._iconId2FilterTags = {}

	for i = 0, LTConfig.GpsFilterTagConfig.count - 1 do
		local cfg = LTConfig.GpsFilterTagConfig.LoadAt(i)

		if cfg.MatchIconId then
			for j = 1, #cfg.MatchIconId do
				local iconId = cfg.MatchIconId[j]

				if not self._iconId2FilterTags[iconId] then
					self._iconId2FilterTags[iconId] = {}
				end

				table.insert(self._iconId2FilterTags[iconId], cfg.Id)
			end
		end
	end

	for iconId, tags in pairs(self._iconId2FilterTags) do
		table.sort(tags)
	end
end

function M:GetFilterTagsByIconId(iconId)
	return self._iconId2FilterTags[iconId]
end

function M:GetStaticFilterTagGroups()
	return self._staticFilterGroupDatas
end

function M:LoadFilterSwitch(groupId, tagId)
	local groupTags = self._filterState.tags[groupId]

	if not groupTags then
		return true
	end

	local toggle = groupTags[tagId]

	if toggle == nil then
		return true
	end

	return toggle
end

function M:SaveFilterSwitch(groupId, tagId, toggle)
	local groupTags = self._filterState.tags[groupId]

	if not groupTags then
		groupTags = {}
		self._filterState.tags[groupId] = groupTags
	end

	if groupTags[tagId] == toggle then
		return
	end

	groupTags[tagId] = toggle
end

function M:SaveFilterActiveGroups(activeGroupIds)
	local stored = self._filterState.groups.activeGroupIds

	for groupId, _ in pairs(stored) do
		stored[groupId] = nil
	end

	for groupId, isActive in pairs(activeGroupIds) do
		stored[groupId] = true
	end
end

function M:LoadSpecialFilterTags()
	self._permanentFilterTags = {}
	self._expandFilterTags = {}

	for i = 0, LTConfig.GpsFilterTagConfig.count - 1 do
		local tagCfg = LTConfig.GpsFilterTagConfig.LoadAt(i)

		if tagCfg.IsPermanent then
			table.insert(self._permanentFilterTags, tagCfg.Id)
		end

		if tagCfg.Expand then
			table.insert(self._expandFilterTags, tagCfg.Id)
		end
	end
end

function M:IsPermanentTag(filterTag)
	return array.contains(self._permanentFilterTags, filterTag)
end

function M:IsExpandTag(filterTag)
	return array.contains(self._expandFilterTags, filterTag)
end

function M:GetElementTagId(id)
	local element = gMapSystem:GetByInstanceId(id)

	return element:GetElementFilterId()
end

function M:LoadInScreenGroupExpand(groupId)
	local saved = self._inScreenSave.groups[groupId]

	return saved ~= false
end

function M:SaveInScreenGroupExpand(groupId, isExpand)
	self._inScreenSave.groups[groupId] = isExpand
end

function M:LoadRightTopGroupExpand(raidId)
	local saved = self._rightTopSave.groups[raidId]

	return saved ~= false
end

function M:SaveRightTopGroupExpand(raidId, isExpand)
	self._rightTopSave.groups[raidId] = isExpand
end
