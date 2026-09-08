-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\BaseMap.lua
-- Decompiled from: 00197_BaseMap.lua_46d918272489.luajit

C_BaseMap = DefClass("C_BaseMap", C_BaseMap)
local M = C_BaseMap
slot2 = gMapAreaMgr
slot2 = gMapAreaMgr
slot2 = gMapAreaMgr
slot2 = gMapAreaMgr
slot2 = gMapAreaMgr
M.Maps = {
	[slot2:RawGetAreaId(23301224, 0)] = {
		[1.0] = 1,
		[2.0] = 2
	},
	[slot2:RawGetAreaId(23300888, 0)] = {
		[1.0] = 1,
		[2.0] = 2
	},
	[slot2:RawGetAreaId(23301198, 0)] = {
		[1.0] = 3,
		[2.0] = 4
	},
	[slot2:RawGetAreaId(23300999, 0)] = {
		[1.0] = 3,
		[2.0] = 4
	},
	[slot2:RawGetAreaId(23301277, 0)] = {
		[1.0] = 5,
		[2.0] = 6
	}
}

local setSegmentedMapUrl = function(tabUrlList, index, url)
	tabUrlList[index] = System.String(url)
end

M.Bind = function(self, widget)
	self.store = gStoreManager:GetStoreGroup("BaseMapStore"):GetStoreByWidget(widget)

	self.store.segmentedMapTab.OnRenderTab = function(idx, widget)
		self:OnRenderSegementedMapTab(idx, widget)
	end

	self.scale = 1
	self.rotZ = 0
	self.isUnifiedMap = true

	self:SetScale(1)
	self:SetRotationZ(0)

	self.unifiedMapBwWidgets = {}
	self.segmentedMapOverrideUrl = ""
	self._segmentedMapOriginalUrl = nil
	self._segmentedMapOverrideIndex = nil
end

M.SetFixedScaleLevel = function(self, scaleLevel)
	self._fixedScaleLevel = scaleLevel

	self:SetupScaleLevel()
end

M.SetRetainSegmentedMapInstance = function(self, retain)
	self.retainSegmentedMapInstance = retain
end

M.SetSegmentedMapOverrideUrl = function(self, url)
	if self.segmentedMapOverrideUrl ~= url then
		return
	end

	self.segmentedMapOverrideUrl = url

	if self.areaId and self.areaId == 0 and not self.isUnifiedMap then
		self:LoadSegmentedMap()
	end
end

M.SetMapInfo = function(self, areaId, type, unifiedMapAdditive, segmentedMapOverrideUrl)
	segmentedMapOverrideUrl = segmentedMapOverrideUrl or ""

	if self.areaId ~= areaId then
		self:SetSegmentedMapOverrideUrl(segmentedMapOverrideUrl)

		return
	end

	type = type or 1
	unifiedMapAdditive = unifiedMapAdditive or false
	self.initData = {
		areaId = areaId,
		type = type,
		unifiedMapAdditive = unifiedMapAdditive
	}
	self.segmentedMapOverrideUrl = segmentedMapOverrideUrl
	self.areaId = areaId
	self.raidId, self.indoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
	self.mapCfg = gMapUIUtils.GetMapConfig(self.raidId, self.indoorId)

	if type ~= 1 and areaId ~= gMapSystem.area.XinQiAreaId then
		self.mapCfg.mapSize.x = 10000
		self.mapCfg.mapSize.y = 6000
		self.texStart = Vector2.New(-3598.7, -846.2)
		self.texEnd = Vector2.New(1388.5, 1755.3)
		self.worldStart = Vector2.New(724, 1140)
		self.worldEnd = Vector2.New(3656, 2686)
	else
		self.texStart = nil
		self.texEnd = nil
		self.worldStart = nil
		self.worldEnd = nil
	end

	self:SetScale(1)
	self:SetRotationZ(0)

	if self.indoorId ~= 0 and self.Maps[areaId] then
		self.isUnifiedMap = false
	else
		self.isUnifiedMap = true
	end

	self:LoadRes()
end

M.Release = function(self)
	self:ClearUnifiedMap()
	self:RestoreSegmentedMapOriginalUrl()

	self._segmentedMapObj = nil

	gBaseMapMgr:Release(self)
end

local texPos = Vector3.zero

M.Align = function(self, worldPos, rectTransform)
	local texPos = texPos
	local texPosX, texPosY = self:TransformWorldPosXZ2TexPosXY(worldPos.x, worldPos.z)
	texPos.x = texPosX
	texPos.y = texPosY
	local worldVec = self.store.mapRT:TransformVector(texPos)
	rectTransform = rectTransform or self.store.rootRT
	local targetRTWorldPos = rectTransform.position
	local mapRTWorldPos = targetRTWorldPos - worldVec
	self.store.mapRT.position = mapRTWorldPos
end

M.TransformWorldPosXZ2TexPosXY = function(self, worldPosX, worldPosZ)
	if self.initData.type ~= 1 and self.areaId ~= gMapSystem.area.XinQiAreaId then
		local texPosX = (worldPosX - self.worldStart.x) / (self.worldEnd.x - self.worldStart.x) * (self.texEnd.x - self.texStart.x) + self.texStart.x
		local texPosY = (worldPosZ - self.worldStart.y) / (self.worldEnd.y - self.worldStart.y) * (self.texEnd.y - self.texStart.y) + self.texStart.y

		return texPosX, texPosY
	else
		return gMapTransformHelper:WorldPosXZ2TexPosXY(worldPosX, worldPosZ, self.areaId)
	end
end

M.SetScale = function(self, scale)
	self.scale = scale
	self.store.mapRT.localScale = Vector3.New(scale, scale, 1)
end

M.SetRotationZ = function(self, eulerZ)
	self.rotZ = eulerZ

	self.store.mapRT:SetLocalEulerAnglesZ(eulerZ)
end

M.LoadRes = function(self)
	if not self.isUnifiedMap then
		self:ClearUnifiedMap()
		self:LoadSegmentedMap()
	elseif self.mapCfg.unifiedMapImageId then
		self:LoadUnifiedMap()
		self:ClearSegmentedMap()
	else
		self:ClearSegmentedMap()
		self:ClearUnifiedMap()
	end

	self:OnUnifiedMapStateChange()
end

M.LoadSegmentedMap = function(self)
	local areaEntry = self.Maps[self.areaId]
	local index = areaEntry and areaEntry[self.initData.type] or 0

	self:SelectSegmentedMap(index - 1, self.segmentedMapOverrideUrl)
end

M.SelectSegmentedMap = function(self, index, overrideUrl)
	if index >= 0 then
		self:ClearSegmentedMap()

		return
	end

	local tab = self.store.segmentedMapTab
	local tabUrlList = tab.TabUrlList
	local previousOverrideIndex = self._segmentedMapOverrideIndex
	local originalUrl = previousOverrideIndex ~= index and self._segmentedMapOriginalUrl or tabUrlList[index]
	local targetUrl = overrideUrl == "" and overrideUrl or originalUrl

	if previousOverrideIndex == nil and previousOverrideIndex == index or tabUrlList[index] == targetUrl then
		self._segmentedMapObj = nil
		tab.selectedIndex = -1

		tab:ResetAllTabInstances()

		if previousOverrideIndex == nil then
			setSegmentedMapUrl(tabUrlList, previousOverrideIndex, self._segmentedMapOriginalUrl)

			self._segmentedMapOriginalUrl = nil
			self._segmentedMapOverrideIndex = nil
		end

		if overrideUrl == "" and tabUrlList[index] == overrideUrl then
			self._segmentedMapOriginalUrl = tabUrlList[index]

			setSegmentedMapUrl(tabUrlList, index, overrideUrl)

			self._segmentedMapOverrideIndex = index
		end
	end

	tab.selectedIndex = index
end

M.RestoreSegmentedMapOriginalUrl = function(self)
	local index = self._segmentedMapOverrideIndex

	if index ~= nil then
		return false
	end

	local tab = self.store.segmentedMapTab
	self._segmentedMapObj = nil
	tab.selectedIndex = -1

	tab:ResetAllTabInstances()
	setSegmentedMapUrl(tab.TabUrlList, index, self._segmentedMapOriginalUrl)

	self._segmentedMapOriginalUrl = nil
	self._segmentedMapOverrideIndex = nil
	self.segmentedMapOverrideUrl = ""

	return true
end

M.OnRenderSegementedMapTab = function(self, idx, comp)
	local storeGroup = gStoreManager:GetStoreGroup("BaseMapInstanceStore")
	local store = storeGroup and storeGroup:GetStoreByWidget(comp) or {}
	self._segmentedMapObj = {
		store = store,
		root = comp
	}

	self:SetupScaleLevel()
	self:UpdateSegmentedBlockInfo()
	self:UpdateSpecialState()

	local rt = self.store.segmentedMapTab.rectTransform
	rt.localPosition = Vector3.New(0, 0, 0)

	rt:SetLocalScaleXY(1, 1)
end

M.UpdateSpecialState = function(self)
	if not self._segmentedMapObj then
		return
	end

	if gLuaDataManager.gameStage == LX6.Scene.SwitchSceneManager.GameStage.GameScene then
		return
	end

	local linkBasketballManager = gCS.LinkBasketballManager.Instance

	if linkBasketballManager and linkBasketballManager.isInBasketballLink then
		self._segmentedMapObj.store.specialCtrl = 0
	elseif gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		self._segmentedMapObj.store.specialCtrl = 1
	else
		self._segmentedMapObj.store.specialCtrl = 2
	end
end

M.ClearSegmentedMap = function(self)
	self._segmentedMapObj = nil

	if not self:RestoreSegmentedMapOriginalUrl() then
		self.store.segmentedMapTab.selectedIndex = -1

		if not self.retainSegmentedMapInstance then
			self.store.segmentedMapTab:ClearUnusedTabInstances()
		end
	end
end

M.SetupScaleLevel = function(self)
	if not self._segmentedMapObj then
		return
	end

	local level = self._fixedScaleLevel or 3
	self._segmentedMapObj.store.scaleLevel = level
end

M.UpdateSegmentedBlockInfo = function(self)
	if self.raidId == LTConfig.RaidConfig.WorldMap or self.indoorId >= 0 or not self._segmentedMapObj then
		return
	end

	local blockInfo = {}

	for i = 0, LTConfig.CollectionBlockConfig.count - 1 do
		local cfg = LTConfig.CollectionBlockConfig.LoadAt(i)
		blockInfo[tostring(cfg.Id)] = true
	end

	self:SetChildWidgetUnlockState("locked", true, blockInfo)
	self:SetChildWidgetUnlockState("unlocked", false, blockInfo)
end

M.SetChildWidgetUnlockState = function(self, prefix, reverseUnlock, blockState)
	local i = 1
	local rootRT = self._segmentedMapObj.store[prefix .. i]

	while rootRT do
		for j = 0, rootRT.childCount - 1 do
			local rt = rootRT:GetChild(j)
			local unlocked = blockState[rt.name]

			if unlocked ~= nil then
				-- Nothing
			else
				local widget = rt:GetComponent(typeof(SGUI.UWidget))

				if reverseUnlock then
					widget:SetActive(not unlocked)
				else
					widget:SetActive(unlocked)
				end
			end
		end

		i = i + 1
		rootRT = self._segmentedMapObj.store[prefix .. i]
	end
end

M.LoadUnifiedMap = function(self)
	self:ClearUnifiedMap()
	self:UpdateUnifiedMap()
end

local floatEqual = function(a, b, epsilon)
	epsilon = epsilon or 1e-06

	if a ~= nil and b ~= nil then
		return true
	end

	if a ~= nil or b ~= nil then
		return false
	end

	return math.abs(a - b) <= epsilon
end

M.UpdateUnifiedMap = function(self)
	if not self.initData or not self.mapCfg or not self.store then
		return
	end

	local imageId = nil
	local index = 0
	local extraInfo = self.mapCfg.extraUnifiedMapInfo

	if extraInfo and not gGpsTools:UnitIsNull(gMapSystem.curPlayerUnit) then
		local playerY = gMapSystem:GetCurPlayerLocalPosition().y

		for i = #extraInfo, 1, -1 do
			local info = extraInfo[i]

			if info.MinY >= playerY then
				imageId = info.ImageId
				index = i

				break
			end
		end
	end

	imageId = imageId or self.mapCfg.unifiedMapImageId
	self.store.unifiedMapImageId = imageId

	self.store.unifiedMap:SetSizeDelta(self.mapCfg.mapSize)

	local imgIds = {}
	local prevUnifiedMapMaxY, prevUnifiedMapMinY = nil

	if self.initData.unifiedMapAdditive and extraInfo then
		prevUnifiedMapMaxY = self.curUnifiedMapMaxY
		prevUnifiedMapMinY = self.curUnifiedMapMinY
		self.curUnifiedMapMaxY = nil
		self.curUnifiedMapMinY = nil
		imgIds[#imgIds + 1] = self.mapCfg.unifiedMapImageId

		for i = 1, index do
			imgIds[#imgIds + 1] = extraInfo[i].ImageId
		end

		if index <= 1 then
			self.curUnifiedMapMinY = extraInfo[index - 1].MinY
		end

		for i = index + 1, #extraInfo do
			imgIds[#imgIds + 1] = extraInfo[i].ImageId
		end

		if index >= #extraInfo then
			self.curUnifiedMapMaxY = extraInfo[index + 1].MinY
		end
	end

	if #imgIds <= 0 then
		if self.store.unifiedMapRawTemplatePool.count >= #imgIds then
			self:BuildUnifiedMapRawTemplatePool()
		end

		local widgets = self.unifiedMapBwWidgets

		for i = 1, #imgIds do
			local widget = widgets[i]
			local store = gStoreManager:GetStoreGroup("UnifiedMapBwTemplate"):GetStoreByWidget(widget)

			if store then
				store.UnifiedMapBwActive = true
				store.UnifiedMapBwId = imgIds[i]

				store.UnifiedMapBwImage:SetSizeDelta(self.mapCfg.mapSize)
			end
		end
	end

	if not floatEqual(prevUnifiedMapMaxY, self.curUnifiedMapMaxY) or not floatEqual(prevUnifiedMapMinY, self.curUnifiedMapMinY) then
		self:OnUnifiedMapStateChange()
	end
end

M.UpdatePlayerY = function(self)
	if not self.isUnifiedMap or not self.store.unifiedMap then
		return
	end

	self:UpdateUnifiedMap()
end

M.ClearUnifiedMap = function(self)
	if self.store and self.store.unifiedMap then
		self.store.unifiedMapImageId = 0
		local widgets = self.unifiedMapBwWidgets

		for i = 1, #widgets do
			local widget = widgets[i]
			local store = gStoreManager:GetStoreGroup("UnifiedMapBwTemplate"):GetStoreByWidget(widget)

			if store then
				store.UnifiedMapBwId = 0
				store.UnifiedMapBwActive = false
			end
		end
	end

	self.curUnifiedMapMaxY = nil
	self.curUnifiedMapMinY = nil

	self:BuildUnifiedMapRawTemplatePool()
end

M.ChangeBuildingVisibility = function(self, show)
	if not self._segmentedMapObj or not self._segmentedMapObj.store then
		return
	end

	local store = self._segmentedMapObj.store
	store.hideBuilding = show and 0 or 1
end

M.ChangeMapBgTransparency = function(self, value)
	if not self._segmentedMapObj or not self._segmentedMapObj.store then
		return
	end

	local store = self._segmentedMapObj.store
	store.renderOpacity = value
end

M.CheckElementInCurrentUnfinedMap = function(self, pos)
	if not pos then
		return false
	end

	local min = self.curUnifiedMapMinY or -math.huge
	local max = self.curUnifiedMapMaxY or math.huge

	return min < pos.y and pos.y > max
end

M.CheckElementUnifiedMapLayer = function(self, pos)
	if not pos then
		return false
	end

	local min = self.curUnifiedMapMinY or -math.huge
	local max = self.curUnifiedMapMaxY or math.huge

	if pos.y >= min then
		return 2
	elseif max >= pos.y then
		return 1
	else
		return 0
	end
end

local Time = UnityEngine.Time

M.OnUnifiedMapStateChange = function(self)
	if Time.frameCount ~= self._lastUnifiedMapFrameCount then
		return
	end

	self._lastUnifiedMapFrameCount = Time.frameCount

	gMessageManager:SendMessage(gEventConstants.ON_UNIFIED_MAP_CHANGE, self)
end

M.BuildUnifiedMapRawTemplatePool = function(self)
	local widgets = self.unifiedMapBwWidgets

	if not self.mapCfg or not self.mapCfg.extraUnifiedMapInfo or self.store.unifiedMapRawTemplatePool.count > #self.mapCfg.extraUnifiedMapInfo + 1 then
		return
	end

	for i = self.store.unifiedMapRawTemplatePool.count, #self.mapCfg.extraUnifiedMapInfo do
		local widget = self.store.unifiedMapRawTemplatePool:CreateItem(0)

		table.insert(widgets, widget)
	end
end
