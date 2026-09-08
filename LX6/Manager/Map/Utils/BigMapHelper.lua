-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapHelper.lua
-- Decompiled from: 00214_BigMapHelper.lua_cfd486df7786.luajit

local ProfileRewardConfig = LTConfig.ProfileRewardConfig
EBigMapOperationType = {
	["tFe}h+"] = 6,
	["\\xb9;#*k\\xa9D\\xc1\\xa5\\xaa"] = 3,
	["/M\\x9d\\x8b\\x80U"] = 5,
	["d[ǩ\\xb7\r\\xb4\\xca\\xfc"] = 4
}
EBigMapFilterTagType = {
	["F\\x9b\\x99\\xb3ݲ\\xc9>\\x9a/\\xa0\""] = 3,
	["mBiml="] = 2,
	["I\\xa0cI\\xa0\\xd1Hd|wK"] = 1
}
gBigMapHelper = gBigMapHelper or {}
local M = gBigMapHelper

M.Init = function(self)
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
	self._houseSave = {
		groups = {}
	}
end

M.OnLogin = function(self)
	self:ReloadIcon2FilterTags()
	self:ReloadFilterConfig()
end

M.TryFocusOnBigMapByGpsId = function(self, gpsId)
	local bigMap = gStoreManager:GetStoreGroup("NewMapPanelStore")

	if not bigMap or not bigMap.STATE_OnShowOnce then
		return false
	end

	bigMap:ScheduleOperation(EBigMapOperationType.WaitFocus, {
		gpsId = gpsId
	})

	return true
end

M.TrySelectOnBigMapByGpsId = function(self, gpsId)
	local bigMap = gStoreManager:GetStoreGroup("NewMapPanelStore")

	if not bigMap or not bigMap.STATE_OnShowOnce then
		return false
	end

	bigMap:ScheduleOperation(EBigMapOperationType.Select, {
		gpsId = gpsId
	})

	return true
end

M.GetMinScaleLevelIndex = function(self)
	if gMapSystem_Region:IsCountryUnlocked(2) then
		return 1
	end

	return 2
end

M.GetScaleLevel = function(self, scale)
	local isNonMobile = gCS.LuaUtils.IsNonMobileAdaptive()
	local scaleCfgs = LTConfig.GpsConfig.BigMapScaleLevelData
	local minIndex = self:GetMinScaleLevelIndex()

	for i = minIndex, #scaleCfgs do
		local cfg = scaleCfgs[i]

		if isNonMobile then
			if scale >= cfg.maxScale then
				return i, cfg.bgScaleLevel
			end
		elseif scale >= cfg.maxScale * 0.68 then
			return i, cfg.bgScaleLevel
		end
	end

	return #scaleCfgs, scaleCfgs[#scaleCfgs].bgScaleLevel
end

M.GetScaleRange = function(self)
	local scaleCfgs = LTConfig.GpsConfig.BigMapScaleLevelData
	local startIndex = self:GetMinScaleLevelIndex()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return scaleCfgs[startIndex].minScale, scaleCfgs[#scaleCfgs].maxScale
	else
		return scaleCfgs[startIndex].minScale * 0.68, scaleCfgs[#scaleCfgs].maxScale * 0.68
	end
end

M.GetIconState = function(self, scaleLevel, iconShowType)
	local cfg = LTConfig.GpsMapIconScaleTypeConfig.GetConfig(iconShowType)

	if not cfg then
		return EBigMapIconScaleState.Normal
	end

	return cfg.IconState[scaleLevel]
end

M.ReloadFilterConfig = function(self)
	local groupDatas = {}
	local groupCfgs = {}

	for i = 0, LTConfig.GpsFilterGroupConfig.count - 1 do
		local cfg = LTConfig.GpsFilterGroupConfig.LoadAt(i)

		table.insert(groupCfgs, cfg)
	end

	table.sort(groupCfgs, function (a, b)
		return a.Id <= b.Id
	end)

	for i = 1, #groupCfgs do
		local cfg = groupCfgs[i]
		local groupData = {
			id = cfg.Id,
			tags = {}
		}

		for j = 0, LTConfig.GpsFilterTagConfig.count - 1 do
			local tagCfg = LTConfig.GpsFilterTagConfig.LoadAt(j)

			if tagCfg.Group ~= cfg.Id then
				table.insert(groupData.tags, tagCfg.Id)
			end
		end

		table.sort(groupData.tags)
		table.insert(groupDatas, groupData)
	end

	self._staticFilterGroupDatas = groupDatas

	self:LoadSpecialFilterTags()
end

M.ReloadIcon2FilterTags = function(self)
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

M.GetFilterTagsByIconId = function(self, iconId)
	return self._iconId2FilterTags[iconId]
end

M.GetStaticFilterTagGroups = function(self)
	return self._staticFilterGroupDatas
end

M.LoadFilterSwitch = function(self, groupId, tagId)
	local groupTags = self._filterState.tags[groupId]

	if not groupTags then
		return true
	end

	local toggle = groupTags[tagId]

	if toggle ~= nil then
		return true
	end

	return toggle
end

M.SaveFilterSwitch = function(self, groupId, tagId, toggle)
	local groupTags = self._filterState.tags[groupId]

	if not groupTags then
		groupTags = {}
		self._filterState.tags[groupId] = groupTags
	end

	if groupTags[tagId] ~= toggle then
		return
	end

	groupTags[tagId] = toggle
end

M.SaveFilterActiveGroups = function(self, activeGroupIds)
	local stored = self._filterState.groups.activeGroupIds

	for groupId, _ in pairs(stored) do
		stored[groupId] = nil
	end

	for groupId, isActive in pairs(activeGroupIds) do
		stored[groupId] = true
	end
end

M.LoadSpecialFilterTags = function(self)
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

M.IsPermanentTag = function(self, filterTag)
	return array.contains(self._permanentFilterTags, filterTag)
end

M.IsExpandTag = function(self, filterTag)
	return array.contains(self._expandFilterTags, filterTag)
end

M.GetElementTagId = function(self, id)
	local element = gMapSystem:GetByInstanceId(id)

	return element:GetElementFilterId()
end

M.LoadInScreenGroupExpand = function(self, groupId)
	local saved = self._inScreenSave.groups[groupId]

	return saved == false
end

M.SaveInScreenGroupExpand = function(self, groupId, isExpand)
	self._inScreenSave.groups[groupId] = isExpand
end

M.LoadRightTopGroupExpand = function(self, raidId)
	local saved = self._rightTopSave.groups[raidId]

	return saved == false
end

M.SaveRightTopGroupExpand = function(self, raidId, isExpand)
	self._rightTopSave.groups[raidId] = isExpand
end

M.LoadHouseGroupExpand = function(self, groupId)
	local saved = self._houseSave.groups[groupId]

	return saved == false
end

M.SaveHouseGroupExpand = function(self, groupId, isExpand)
	self._houseSave.groups[groupId] = isExpand
end

M.GetBigMapViewCfg = function(self, viewMask)
	local viewCfg = MapView.GetDefaultConfig()
	viewCfg.viewMask = viewMask
	viewCfg.openAllGateBetweenBigMaps = true
	viewCfg.skipImportantTaskSpiritFilter = true
	viewCfg.useBigMapSpiritFilter = true

	return viewCfg
end

M.CanFocusBigMapElement = function(self, instanceId)
	local element = gMapSystem.container:Get(instanceId)

	if not element or not element:VisibleOn(EMapViewMask.BigMap) then
		return false, nil
	end

	local areaId = element.areaId
	local mapViewCfg = gBigMapHelper:GetBigMapViewCfg(EMapViewMask.BigMap)
	local mapView = MapView.CreateView("BigMapPreopen", mapViewCfg)

	mapView:AddStage(mapView.defaultFogStage)
	mapView:Commit()

	if gMapAreaMgr:IsBigWorldAreaId(areaId) then
		if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.FogMap) then
			mapView:SetFogEnable(true)
		else
			mapView:SetFogEnable(false)
		end

		mapView:SetupBoundsByAreaId(MapAreaCluster.BigWorld.areaIdList)
	else
		mapView:SetFogEnable(false)
		mapView:SetupBoundsByAreaId({
			areaId
		})
	end

	mapView:ConnectTraceSource()
	mapView:ConnectOnlineTraceSource()

	local guideInterest = gMapSystem.ui:GetAllBigMapGuideInterest()

	if guideInterest then
		for _, instanceId in ipairs(guideInterest) do
			local element = gMapSystem.container:Get(instanceId)

			if element then
				gMapSystem.ui.bigMapInterestSource:AddElement(instanceId)
			end
		end
	end

	mapView:ConnectSource(gMapSystem.ui.bigMapInterestSource)
	mapView:Update(gMapSystem.container.playerConnectedBounds or {}, nil)

	local item = mapView:GetItemInfo(instanceId)
	local retSuccess, nextStageType = nil

	if not item then
		return false, nil
	end

	if item.passStageType ~= EMapViewStage.View then
		retSuccess = true
		nextStageType = nil
	else
		retSuccess = false
		nextStageType = item.nextStageType
	end

	mapView:Dispose()
	gMapSystem.ui.bigMapInterestSource:ClearAllElement()

	return retSuccess, nextStageType
end

M.GetProfileRewardData = function(self, profileId)
	local config = LTConfig.ProfileAgentProfileConfig.GetConfig(profileId)
	local nowTrust = gAgentTrustManager:GetTrustValue(profileId) or 0
	local sortedRewards = {}

	for _, rewardId in ipairs(config.TrustReward) do
		local rewardCfg = ProfileRewardConfig.GetConfig(rewardId)

		table.insert(sortedRewards, {
			id = rewardId,
			needTrust = rewardCfg.NeedTrust,
			cfg = rewardCfg
		})
	end

	table.sort(sortedRewards, function (a, b)
		return a.needTrust <= b.needTrust
	end)

	local nextTargetIndex = -1

	for i, item in ipairs(sortedRewards) do
		if nowTrust >= item.needTrust then
			nextTargetIndex = i

			break
		end
	end

	local rewardListData = {}

	for i, item in ipairs(sortedRewards) do
		local rewardCfg = item.cfg
		local isDisableReward = rewardCfg.RewardType ~= ProfileRewardConfig.RewardTypeType.Disable
		local isGot = isDisableReward or gAgentTrustManager:CheckRewardGot(profileId, rewardCfg.Id)

		table.insert(rewardListData, {
			id = rewardCfg.Id,
			needTrust = rewardCfg.NeedTrust,
			rewardIndex = i,
			isUnlocked = isDisableReward or rewardCfg.NeedTrust > nowTrust,
			isGot = isGot,
			canGet = not isDisableReward and rewardCfg.NeedTrust < nowTrust and not isGot,
			name = rewardCfg.Description,
			desc = rewardCfg.DetailExplain,
			iconId = rewardCfg.SmallIconId,
			bigIconId = rewardCfg.IconId,
			rewardType = rewardCfg.RewardType,
			isNextTarget = i ~= nextTargetIndex,
			nowTrust = nowTrust
		})
	end

	return rewardListData
end
