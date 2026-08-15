C_BaseMap = DefClass("C_BaseMap", C_BaseMap)
local M = C_BaseMap
M.Maps = {
	[gMapAreaMgr:RawGetAreaId(23301224, 0)] = {
		[1.0] = 1,
		[2.0] = 2
	},
	[gMapAreaMgr:RawGetAreaId(23300888, 0)] = {
		[1.0] = 1,
		[2.0] = 2
	},
	[gMapAreaMgr:RawGetAreaId(23301198, 0)] = {
		[1.0] = 3,
		[2.0] = 4
	},
	[gMapAreaMgr:RawGetAreaId(23300999, 0)] = {
		[1.0] = 3,
		[2.0] = 4
	}
}

function M:Bind(widget)
	self.store = gStoreManager:GetStoreGroup("BaseMapStore"):GetStoreByWidget(widget)

	function self.store.segmentedMapTab.OnRenderTab(idx, widget)
		self:OnRenderSegementedMapTab(idx, widget)
	end

	self.scale = 1
	self.rotZ = 0
	self.isUnifiedMap = true

	self:SetScale(1)
	self:SetRotationZ(0)
end

function M:SetFixedScaleLevel(scaleLevel)
	self._fixedScaleLevel = scaleLevel

	self:SetupScaleLevel()
end

function M:SetMapInfo(areaId, type, unifiedMapAdditive)
	if self.areaId == areaId then
		return
	end

	type = type or 1
	unifiedMapAdditive = unifiedMapAdditive or false
	self.initData = {
		areaId = areaId,
		type = type,
		unifiedMapAdditive = unifiedMapAdditive
	}
	self.areaId = areaId
	self.raidId, self.indoorId = gMapAreaMgr:GetRaidIdAndIndoorId(areaId)
	self.mapCfg = gMapUIUtils.GetMapConfig(self.raidId, self.indoorId)

	if type == 1 and areaId == gMapSystem.area.XinQiAreaId then
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

	if self.indoorId == 0 and self.Maps[areaId] then
		self.isUnifiedMap = false
	else
		self.isUnifiedMap = true
	end

	self:LoadRes()
end

function M:Release()
	self:ClearUnifiedMap()

	self._segmentedMapObj = nil

	gBaseMapMgr:Release(self)
end

local texPos = Vector3.zero

function M:Align(worldPos, rectTransform)
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

function M:TransformWorldPosXZ2TexPosXY(worldPosX, worldPosZ)
	if self.initData.type == 1 and self.areaId == gMapSystem.area.XinQiAreaId then
		local texPosX = (worldPosX - self.worldStart.x) / (self.worldEnd.x - self.worldStart.x) * (self.texEnd.x - self.texStart.x) + self.texStart.x
		local texPosY = (worldPosZ - self.worldStart.y) / (self.worldEnd.y - self.worldStart.y) * (self.texEnd.y - self.texStart.y) + self.texStart.y

		return texPosX, texPosY
	else
		return gMapTransformHelper:WorldPosXZ2TexPosXY(worldPosX, worldPosZ, self.areaId)
	end
end

function M:SetScale(scale)
	self.scale = scale
	self.store.mapRT.localScale = Vector3.New(scale, scale, 1)
end

function M:SetRotationZ(eulerZ)
	self.rotZ = eulerZ

	self.store.mapRT:SetLocalEulerAnglesZ(eulerZ)
end

function M:LoadRes()
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

function M:LoadSegmentedMap()
	local areaEntry = self.Maps[self.areaId]
	local index = areaEntry and areaEntry[self.initData.type] or 0
	self.store.segmentedMapTab.selectedIndex = index - 1
end

function M:OnRenderSegementedMapTab(idx, comp)
	local storeGroup = gStoreManager:GetStoreGroup("BaseMapInstanceStore")
	local store = storeGroup and storeGroup:GetStoreByWidget(comp) or {}
	self._segmentedMapObj = {
		store = store,
		root = comp
	}

	self:SetupScaleLevel()
	self:UpdateSegmentedBlockInfo()

	local rt = self.store.segmentedMapTab.rectTransform
	rt.localPosition = Vector3.New(0, 0, 0)

	rt:SetLocalScaleXY(1, 1)
end

function M:ClearSegmentedMap()
	self._segmentedMapObj = nil
	self.store.segmentedMapTab.selectedIndex = -1

	self.store.segmentedMapTab:ClearUnusedTabInstances()
end

function M:SetupScaleLevel()
	if not self._segmentedMapObj then
		return
	end

	local level = self._fixedScaleLevel or 3
	self._segmentedMapObj.store.scaleLevel = level
end

function M:UpdateSegmentedBlockInfo()
	if self.raidId ~= LTConfig.RaidConfig.WorldMap or self.indoorId > 0 or not self._segmentedMapObj then
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

function M:SetChildWidgetUnlockState(prefix, reverseUnlock, blockState)
	local i = 1
	local rootRT = self._segmentedMapObj.store[prefix .. i]

	while rootRT do
		for j = 0, rootRT.childCount - 1 do
			local rt = rootRT:GetChild(j)
			local unlocked = blockState[rt.name]

			if unlocked == nil then
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

function M:LoadUnifiedMap()
	self:ClearUnifiedMap()
	self:UpdateUnifiedMap()
end

local function floatEqual(a, b, epsilon)
	epsilon = epsilon or 1e-06

	if a == nil and b == nil then
		return true
	end

	if a == nil or b == nil then
		return false
	end

	return math.abs(a - b) < epsilon
end

function M:UpdateUnifiedMap()
	if not self.initData or not self.mapCfg or not self.store then
		return
	end

	local imageId = nil
	local index = 0

	if self.mapCfg.extraUnifiedMapInfo and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		local playerY = gCS.MyPlayerManager.PlayerUnit.LocalPosition.y

		for i = #self.mapCfg.extraUnifiedMapInfo, 1, -1 do
			local info = self.mapCfg.extraUnifiedMapInfo[i]

			if info.MinY < playerY then
				imageId = info.ImageId
				index = i

				break
			end
		end
	end

	imageId = imageId or self.mapCfg.unifiedMapImageId
	self.store.unifiedMapImageId = imageId

	self.store.unifiedMap:SetSizeDelta(self.mapCfg.mapSize)

	if self.initData.unifiedMapAdditive and self.mapCfg.extraUnifiedMapInfo then
		local aboveImgId, belowImgId = nil
		local prevUnifiedMapMaxY = self.curUnifiedMapMaxY
		local prevUnifiedMapMinY = self.curUnifiedMapMinY
		self.curUnifiedMapMaxY = nil
		self.curUnifiedMapMinY = nil

		if index < #self.mapCfg.extraUnifiedMapInfo then
			aboveImgId = self.mapCfg.extraUnifiedMapInfo[index + 1].ImageId
			self.curUnifiedMapMaxY = self.mapCfg.extraUnifiedMapInfo[index + 1].MinY
		end

		if index > 1 then
			belowImgId = self.mapCfg.extraUnifiedMapInfo[index - 1].ImageId
			self.curUnifiedMapMinY = self.mapCfg.extraUnifiedMapInfo[index - 1].MinY
		elseif index == 1 then
			belowImgId = self.mapCfg.unifiedMapImageId
			self.curUnifiedMapMinY = self.mapCfg.extraUnifiedMapInfo[index].MinY
		end

		if aboveImgId then
			self.store.unifiedMapAboveImageId = aboveImgId

			self.store.unifiedMapAbove:SetSizeDelta(self.mapCfg.mapSize)
		else
			self.store.unifiedMapAboveImageId = 0
		end

		if belowImgId then
			self.store.unifiedMapBelowImageId = belowImgId

			self.store.unifiedMapBelow:SetSizeDelta(self.mapCfg.mapSize)
		else
			self.store.unifiedMapBelowImageId = 0
		end

		if not floatEqual(prevUnifiedMapMaxY, self.curUnifiedMapMaxY) or not floatEqual(prevUnifiedMapMinY, self.curUnifiedMapMinY) then
			self:OnUnifiedMapStateChange()
		end
	end
end

function M:UpdatePlayerY()
	if not self.isUnifiedMap or not self.store.unifiedMap then
		return
	end

	self:UpdateUnifiedMap()
end

function M:ClearUnifiedMap()
	if self.store and self.store.unifiedMap then
		self.store.unifiedMapImageId = 0
		self.store.unifiedMapBelowImageId = 0
		self.store.unifiedMapAboveImageId = 0
	end

	self.curUnifiedMapMaxY = nil
	self.curUnifiedMapMinY = nil
end

function M:ChangeBuildingVisibility(show)
	if not self._segmentedMapObj or not self._segmentedMapObj.store then
		return
	end

	local store = self._segmentedMapObj.store
	store.hideBuilding = show and 0 or 1
end

function M:ChangeMapBgTransparency(value)
	if not self._segmentedMapObj or not self._segmentedMapObj.store then
		return
	end

	local store = self._segmentedMapObj.store
	store.renderOpacity = value
end

function M:CheckElementInCurrentUnfinedMap(pos)
	if not pos then
		return false
	end

	local min = self.curUnifiedMapMinY or -math.huge
	local max = self.curUnifiedMapMaxY or math.huge

	return min <= pos.y and pos.y <= max
end

function M:CheckElementUnifiedMapLayer(pos)
	if not pos then
		return false
	end

	local min = self.curUnifiedMapMinY or -math.huge
	local max = self.curUnifiedMapMaxY or math.huge

	if pos.y < min then
		return 2
	elseif max < pos.y then
		return 1
	else
		return 0
	end
end

local Time = UnityEngine.Time

function M:OnUnifiedMapStateChange()
	if Time.frameCount == self._lastUnifiedMapFrameCount then
		return
	end

	self._lastUnifiedMapFrameCount = Time.frameCount

	gMessageManager:SendMessage(gEventConstants.ON_UNIFIED_MAP_CHANGE, self)
end
