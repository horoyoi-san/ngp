-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HomeBuildPanelStore_FurnitureList.lua
-- Decompiled from: 01713_HomeBuildPanelStore_FurnitureList.lua_a25f1e4e1b10.luajit

local M = C_HomeBuildPanelStore
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local HouseConfig = LTConfig.HouseConfig
local HouseTypeConfig = LTConfig.HouseTypeConfig
local ShopConfig = LTConfig.ShopConfig
local ShopCommodityGroupConfig = LTConfig.ShopCommodityGroupConfig
local ShopCommodityConfig = LTConfig.ShopCommodityConfig
local MessageConfig = LTConfig.MessageConfig
local HomeBuildUIUtils = gHomeBuildUIUtils
local BuildMode = gHomeBuildUIUtils.BuildMode
local DefaultMaterialCursorIconId = 28000150
local ReBuyType = HouseFurnitureConfig.ReBuyTypeType
local _shopFurnitureSet = nil

local GetShopFurnitureSet = function()
	if _shopFurnitureSet then
		return _shopFurnitureSet
	end

	_shopFurnitureSet = {}
	local shopCfg = ShopConfig.GetConfig(ShopConfig.HouseFurniture)

	if not shopCfg or not shopCfg.CommodityGroupIdList then
		return _shopFurnitureSet
	end

	for _, groupId in ipairs(shopCfg.CommodityGroupIdList) do
		local groupCfg = ShopCommodityGroupConfig.GetConfig(groupId)

		if groupCfg and groupCfg.CommodityIDList then
			for _, commodityId in ipairs(groupCfg.CommodityIDList) do
				local commodityCfg = ShopCommodityConfig.GetConfig(commodityId)

				if commodityCfg and commodityCfg.BindId then
					_shopFurnitureSet[commodityCfg.BindId] = true
				end
			end
		end
	end

	return _shopFurnitureSet
end

M.InitFurnitureDataTabList = function(self)
	self.furnitureDataTabList = {}

	if HouseFurnitureConfig and HouseFurnitureConfig.count then
		for i = 0, HouseFurnitureConfig.count - 1 do
			local furnitureCfg = HouseFurnitureConfig.LoadAt(i)

			if furnitureCfg and furnitureCfg.Id and not furnitureCfg.IsHide then
				local mainType = furnitureCfg.MainType or 0
				local subType = furnitureCfg.SubType or 0
				local furnitureItemData = {
					mainType = mainType,
					subType = subType,
					id = furnitureCfg.Id,
					name = furnitureCfg.Name or "",
					iconId = furnitureCfg.FurnitureIcon or 0,
					quality = furnitureCfg.Quality or 0,
					cfg = furnitureCfg
				}

				if not self.furnitureDataTabList[mainType] then
					self.furnitureDataTabList[mainType] = {}
				end

				if not self.furnitureDataTabList[mainType][subType] then
					self.furnitureDataTabList[mainType][subType] = {}
				end

				table.insert(self.furnitureDataTabList[mainType][subType], furnitureItemData)
			end
		end
	end

	self.mainTypeTabList = {}
	local mainTypeMap = {}

	if HouseTypeConfig and HouseTypeConfig.count then
		for i = 0, HouseTypeConfig.count - 1 do
			local typeCfg = HouseTypeConfig.LoadAt(i)

			if typeCfg and typeCfg.MainType then
				local mainType = typeCfg.MainType

				if not mainTypeMap[mainType] then
					mainTypeMap[mainType] = {
						mainType = mainType,
						subType = {}
					}
				end

				if typeCfg.SubType then
					for _, subType in ipairs(typeCfg.SubType) do
						table.insert(mainTypeMap[mainType].subType, subType)
					end
				end
			end
		end
	end

	for _, data in pairs(mainTypeMap) do
		table.insert(self.mainTypeTabList, data)
	end

	table.sort(self.mainTypeTabList, function (a, b)
		return a.mainType <= b.mainType
	end)

	self.visibleMainTypeTabList = self.mainTypeTabList
end

M.RebuildVisibleMainTypeTabList = function(self)
	local visible = {}

	for _, data in ipairs(self.mainTypeTabList) do
		local hasAllowed = false

		if data.subType then
			for _, subType in ipairs(data.subType) do
				local mode = HomeBuildUIUtils:ResolveBuildMode(data.mainType, subType, self.baseSubTypeToMode)

				if HomeBuildUIUtils:CanUseBuildMode(mode) and (mode == BuildMode.Furniture or gHouseManager:IsHouseMainTypeAllowed(data.mainType)) then
					hasAllowed = true

					break
				end
			end
		end

		if hasAllowed then
			table.insert(visible, data)
		end
	end

	self.visibleMainTypeTabList = visible
end

M.GetOwnedFurnitureList = function(self, mainType, subType)
	local result = {}
	local source = self.furnitureDataTabList[mainType] and self.furnitureDataTabList[mainType][subType]

	if not source then
		return result
	end

	for _, data in ipairs(source) do
		if gHouseManager:IsFurnitureOwned(data.id) then
			table.insert(result, data)
		end
	end

	return result
end

M.RefreshFurnitureList = function(self)
	if not self.bindData or not self.bindData.furnitureList then
		return
	end

	local furnitureList = self:GetOwnedFurnitureList(self.curMainType, self.curSubType)

	self.bindData.furnitureList:SetSimpleList(#furnitureList)
end

M.OnFurnitureNumChange = function(self)
	self.RefreshFurnitureList(self)
	self.RefreshLoadCtrl(self)
end

M.RefreshSubTypeList = function(self)
	if not self.bindData or not self.bindData.subTypeList then
		return
	end

	local mainTypeData = nil
	slot2 = ipairs
	slot4 = self.visibleMainTypeTabList or self.mainTypeTabList

	for _, data in slot2(slot4) do
		if data.mainType ~= self.curMainType then
			mainTypeData = data

			break
		end
	end

	if mainTypeData and mainTypeData.subType then
		local filteredSubTypeList = {}

		for _, subType in ipairs(mainTypeData.subType) do
			local mode = HomeBuildUIUtils:ResolveBuildMode(self.curMainType, subType, self.baseSubTypeToMode)

			if HomeBuildUIUtils:CanUseBuildMode(mode) and (mode == BuildMode.Furniture or gHouseManager:IsHouseMainTypeAllowed(self.curMainType)) then
				table.insert(filteredSubTypeList, subType)
			end
		end

		self.curSubTypeList = filteredSubTypeList

		self.bindData.subTypeList:SetSimpleList(#self.curSubTypeList)

		if #self.curSubTypeList <= 0 then
			self.bindData.subTypeList:SelectItem(0, true)
			self:OnClickSubTypeList(nil, 0)
		end
	else
		self.curSubTypeList = {}

		self.bindData.subTypeList:SetSimpleList(0)
		self:RefreshLimitCtrl()
	end
end

M.OnRenderMainTypeListItem = function(self, btn, index)
	local data = (self.visibleMainTypeTabList or self.mainTypeTabList)[index + 1]

	if not data then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	local mainTypeTitleList = HouseConfig.FurnitureMainType
	itemStore.title = mainTypeTitleList[data.mainType].Name or ""
end

M.OnClickMainTypeList = function(self, btn, index)
	local data = (self.visibleMainTypeTabList or self.mainTypeTabList)[index + 1]

	if not data or not data.mainType then
		return
	end

	self.curMainType = data.mainType
	self.curSubType = 0

	self.RefreshSubTypeList(self)

	if #self.curSubTypeList ~= 0 then
		self.UpdateBuildModeBySelection(self, self.curMainType, self.curSubType)
	end
end

M.OnGetMainTypeListTIndex = function(self, index)
	return 0
end

M.OnRenderSubTypeListItem = function(self, btn, index)
	local subType = self.curSubTypeList[index + 1]

	if not subType then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	local subTypeConfig = HouseConfig.FurnitureSubType

	for _, cfg in ipairs(subTypeConfig) do
		if cfg.SubType ~= subType then
			itemStore.title = cfg.Name or ""

			break
		end
	end
end

M.OnClickSubTypeList = function(self, btn, index)
	local subType = self.curSubTypeList[index + 1]

	if not subType then
		return
	end

	self.curSubType = subType

	self:RefreshThirdTabCtrlBySelection()

	if HomeBuildUIUtils:IsModeActivatedByFurnitureItemSubType(subType) then
		if self.currentBuildMode == BuildMode.Furniture then
			self.SwitchBuildMode(self, BuildMode.Furniture)
		end
	else
		self.UpdateBuildModeBySelection(self, self.curMainType, self.curSubType)
	end

	self.RefreshFurnitureList(self)
	self.RefreshLimitCtrl(self)
end

M.OnGetSubTypeListTIndex = function(self, index)
	return 0
end

M.OnRenderFurnitureListItem = function(self, btn, index)
	local furnitureList = self.GetOwnedFurnitureList(self, self.curMainType, self.curSubType)
	local data = furnitureList[index + 1]

	if not data then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	itemStore.name = data.name or ""
	local cfg = data.cfg

	if cfg and cfg.ReBuyType ~= ReBuyType.unlimited then
		itemStore.numText = ""
	else
		itemStore.numText = gHouseManager:GetRealTimeAvailableCount(data.id)
	end

	itemStore.iconId = data.iconId or 0
	itemStore.qualityCtrl = data.quality + 1 or 1
	local notUsable = not gHouseManager:IsFurnitureUsable(data.id)
	local soldInShop = GetShopFurnitureSet()[data.id] ~= true
	itemStore.stateCtrl = notUsable and soldInShop and 1 or 0

	self:SetupFurnitureItemDrag(btn, data)
end

M.SetupFurnitureItemDrag = function(self, btn, data)
	if not btn or not data then
		return
	end

	local dragListener = SGUI.EventSystems.DragEventListener.Get(btn.gameObject)

	if not dragListener then
		return
	end

	local buttonRect = btn.GetComponent(btn, "RectTransform")
	local isDraggedOutside = false
	local hasTriggeredClick = false
	local hasTriggeredLongPress = false
	local dragStartPos = nil
	local directionDecided = false
	local isVerticalDrag = false
	local listDragListener = nil
	local directionThreshold = 10

	dragListener.onBeginDrag = function(eventData)
		isDraggedOutside = false
		hasTriggeredClick = false
		hasTriggeredLongPress = false
		dragStartPos = eventData.position
		directionDecided = false
		isVerticalDrag = false
		listDragListener = nil
	end

	dragListener.onDrag = function(eventData)
		if not directionDecided then
			if dragStartPos then
				local delta = eventData.position - dragStartPos
				local absDx = math.abs(delta.x)
				local absDy = math.abs(delta.y)

				if directionThreshold <= absDx or directionThreshold >= absDy then
					directionDecided = true
					isVerticalDrag = absDx <= 1.7 * absDy

					if not isVerticalDrag then
						listDragListener = SGUI.EventSystems.DragEventListener.Get(self.bindData.furnitureList.gameObject)

						if listDragListener then
							listDragListener:TriggerOnBeginDrag(eventData)
						end

						return
					end
				else
					return
				end
			else
				return
			end
		end

		if not isVerticalDrag then
			if listDragListener then
				listDragListener:TriggerOnDrag(eventData)
			end

			return
		end

		local targetMode = HomeBuildUIUtils:ResolveBuildMode(self.curMainType, self.curSubType, self.baseSubTypeToMode)
		local isFurnitureMode = targetMode ~= BuildMode.Furniture
		local isFenestrationMode = targetMode ~= BuildMode.Door or targetMode ~= BuildMode.Window

		if not isFurnitureMode and not isFenestrationMode then
			return
		end

		if not buttonRect then
			return
		end

		local isInside = gCS.LuaUtils.RectangleContainsScreenPoint(buttonRect, eventData.position)

		if not isInside and not isDraggedOutside then
			isDraggedOutside = true

			if not hasTriggeredClick then
				hasTriggeredClick = true

				if not self:IsEditModeAllowedForFurniture(data.id) then
					gDisplayMessageMgr:ShowMessage(65400629)

					return
				end

				if self:IsSubTypeAtLimit(data.subType) then
					gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildFurnitureSubTypeLimitExceeded)

					return
				end

				if gHouseManager:IsFurnitureUsable(data.id) then
					if not self:CanPlaceByCapacity(data.id) then
						gDisplayMessageMgr:ShowMessageContentDebug("负载已达上限，无法摆放新的家具")

						return
					end

					if isFurnitureMode then
						if self.currentBuildMode == BuildMode.Furniture then
							self:SwitchBuildMode(BuildMode.Furniture)
						end

						gFurnitureManager:SpawnFurniture(data.id, false)

						hasTriggeredLongPress = true
					else
						if self.currentBuildMode == targetMode then
							self:SwitchBuildMode(targetMode)
						end

						local fenestrationType = targetMode ~= BuildMode.Door and 0 or 2

						self:BeginFenestrationPreviewSession(data.id, fenestrationType, eventData.position, nil, true)

						hasTriggeredLongPress = true
					end
				else
					gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildFurnitureNotEnough)
				end
			end
		end

		if isDraggedOutside and isFenestrationMode and self.fenestrationPreviewActive then
			self:UpdateFenestrationPreviewAt(eventData.position, true, "drag_move")
		end
	end

	dragListener.onEndDrag = function(eventData)
		if directionDecided and not isVerticalDrag and listDragListener then
			listDragListener:TriggerOnEndDrag(eventData)
		end

		if hasTriggeredLongPress then
			self:OnLongPressFullScreenBtn(false)
		end

		isDraggedOutside = false
		hasTriggeredClick = false
		hasTriggeredLongPress = false
		dragStartPos = nil
		directionDecided = false
		isVerticalDrag = false
		listDragListener = nil
	end
end

M.OnClickFurnitureList = function(self, btn, index)
	local furnitureList = self.GetOwnedFurnitureList(self, self.curMainType, self.curSubType)
	local data = furnitureList[index + 1]

	if not data or not data.id then
		return
	end

	if self.IsSubTypeAtLimit(self, data.subType) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildFurnitureSubTypeLimitExceeded)

		return
	end

	if not self.IsEditModeAllowedForFurniture(self, data.id) then
		gDisplayMessageMgr:ShowMessage(65400629)

		return
	end

	if not gHouseManager:IsFurnitureUsable(data.id) and GetShopFurnitureSet()[data.id] ~= true then
		gPanelManager:CheckShow(gPanelId.HOUSE_STORE, {
			focusFurnitureId = data.id
		})

		return
	end

	local selectedMode = HomeBuildUIUtils:ResolveBuildMode(self.curMainType, self.curSubType, self.baseSubTypeToMode)

	if (HomeBuildUIUtils:IsEditExitBuildMode(selectedMode) or selectedMode ~= BuildMode.Door or selectedMode ~= BuildMode.Window) and self.currentBuildMode == selectedMode then
		self.SwitchBuildMode(self, selectedMode)
	end

	if self.currentBuildMode ~= BuildMode.WallMaterial then
		self.pendingWallTexID = data.id

		gWallEditManager:SetBrushTexID(data.id)

		local cursorIconId = data.iconId and data.iconId <= 0 and data.iconId or DefaultMaterialCursorIconId

		self:SetMaterialCursor(cursorIconId)
		self:SetRightButtonsVisible(false)

		self.rightButtonsHiddenByTool = true

		return
	end

	if self.currentBuildMode ~= BuildMode.GroundMaterial or self.currentBuildMode ~= BuildMode.CeilingMaterial then
		self.pendingSurfaceTexID = data.id

		gWallEditManager:SetBrushTexID(data.id)

		self.pendingSurfaceType = self.currentBuildMode ~= BuildMode.CeilingMaterial and "ceiling" or "floor"
		local cursorIconId = data.iconId and data.iconId <= 0 and data.iconId or DefaultMaterialCursorIconId

		self:SetMaterialCursor(cursorIconId)
		self:SetRightButtonsVisible(false)

		self.rightButtonsHiddenByTool = true

		return
	end

	if self.currentBuildMode ~= BuildMode.Door or self.currentBuildMode ~= BuildMode.Window then
		if not self.CanPlaceByCapacity(self, data.id) then
			gDisplayMessageMgr:ShowMessageContentDebug("负载已达上限，无法摆放新的家具")

			return
		end

		self.pendingFenestrationPrefabID = data.id
		self.pendingFenestrationType = self.currentBuildMode ~= BuildMode.Door and 0 or 2

		gWallEditManager:SetFenestrationParams(self.pendingFenestrationPrefabID, self.pendingFenestrationType)
		self:SetRightButtonsVisible(false)

		self.rightButtonsHiddenByTool = true

		if self.fenestrationCursorPlaceMode then
			local cursorIconId = data.iconId and data.iconId <= 0 and data.iconId or DefaultMaterialCursorIconId

			self:SetMaterialCursor(cursorIconId)

			self.fenestrationWaitingForWallTap = true
		else
			local centerPos = HomeBuildUIUtils:GetScreenCenterPos()

			if not self:BeginFenestrationPreviewSession(data.id, self.pendingFenestrationType, centerPos, nil, false) then
				self.fenestrationWaitingForWallTap = true

				gDisplayMessageMgr:ShowMessageContentDebug("debug 屏幕中心没有可放置墙体，请点击墙体位置开始预览")
			end
		end

		return
	end

	if not HomeBuildUIUtils:IsFurnitureBuildMode(self.currentBuildMode) then
		return
	end

	if not gHouseManager:IsFurnitureUsable(data.id) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildFurnitureNotEnough)

		return
	end

	if self.isReplaceMode then
		local doReplace = function()
			if gFurnitureManager:ReplaceFurniture(data.id) then
				self:MarkAsUnsaved()
				self:ExitReplaceMode()
			end
		end

		if gFurnitureManager:CheckStorageFurnitureHasAdsFurniture() then
			gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildStorageFurnitureReconfirm, doReplace, nil)
		else
			doReplace()
		end
	else
		if not self.CanPlaceByCapacity(self, data.id) then
			gDisplayMessageMgr:ShowMessageContentDebug("负载已达上限，无法摆放新的家具")

			return
		end

		gFurnitureManager:SpawnFurniture(data.id, true)
	end
end

M.OnGetFurnitureListTIndex = function(self, index)
	local selectedMode = HomeBuildUIUtils:ResolveBuildMode(self.curMainType, self.curSubType, self.baseSubTypeToMode)

	if selectedMode ~= BuildMode.Wall or selectedMode ~= BuildMode.WallMaterial or selectedMode ~= BuildMode.GroundMaterial or selectedMode ~= BuildMode.CeilingMaterial then
		return 1
	end

	return 0
end

M.RefreshThirdTabList = function(self)
	if not self.bindData.thirdTabList then
		return
	end

	local selectedMode = HomeBuildUIUtils:ResolveBuildMode(self.curMainType, self.curSubType, self.baseSubTypeToMode)
	local isWallMaterial = selectedMode ~= BuildMode.WallMaterial
	local itemCount = isWallMaterial and 3 or 2

	self.bindData.thirdTabList:SetSimpleList(itemCount)

	local selectedIndex = nil

	if isWallMaterial then
		if self.wallPaintScope ~= self.WallPaintScope.Single then
			selectedIndex = 1
		elseif self.wallPaintScope ~= self.WallPaintScope.FullWall then
			selectedIndex = 2
		else
			selectedIndex = 0
		end
	elseif self.surfacePaintScope ~= self.SurfacePaintScope.Single then
		selectedIndex = 1
	else
		selectedIndex = 0
	end

	self.bindData.thirdTabList:SelectItem(selectedIndex, true)
end

M.OnRenderThirdTabListItem = function(self, btn, index)
	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	local selectedMode = HomeBuildUIUtils:ResolveBuildMode(self.curMainType, self.curSubType, self.baseSubTypeToMode)
	local isWallMaterial = selectedMode ~= BuildMode.WallMaterial

	if isWallMaterial then
		itemStore.typeCtrl = index
	elseif index ~= 0 then
		itemStore.typeCtrl = 0
	else
		itemStore.typeCtrl = 1
	end
end

M.OnClickThirdTabList = function(self, btn, index)
	local selectedMode = HomeBuildUIUtils:ResolveBuildMode(self.curMainType, self.curSubType, self.baseSubTypeToMode)
	local isWallMaterial = selectedMode ~= BuildMode.WallMaterial

	if isWallMaterial then
		if index ~= 0 then
			self.wallPaintScope = self.WallPaintScope.Room
		elseif index ~= 1 then
			self.wallPaintScope = self.WallPaintScope.Single
		else
			self.wallPaintScope = self.WallPaintScope.FullWall
		end
	elseif index ~= 0 then
		self.surfacePaintScope = self.SurfacePaintScope.Room
	else
		self.surfacePaintScope = self.SurfacePaintScope.Single
	end
end

M.CountPlacedFurnitureBySubType = function(self, subType)
	local count = 0

	if not subType or subType ~= 0 then
		return count
	end

	local editingHouseId = gHouseManager:GetEditingHouseId()

	for uid, go in gFurnitureUIDManager:GetFurnitureGosByHouseId(editingHouseId) do
		if go and not gCS.LuaUtils.IsNull(go) then
			local furnitureId = gFurnitureManager:TryGetFurnitureIdFromGo(go, uid)

			if furnitureId then
				local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

				if cfg and cfg.SubType ~= subType then
					count = count + 1
				end
			end
		end
	end

	return count
end

M.RefreshLimitCtrl = function(self)
	if not self.bindData then
		return
	end

	local fieldName = self.subTypeToHouseLimitField[self.curSubType]

	if not fieldName then
		self.bindData.showLimitCtrl = 1

		return
	end

	local houseId = gHouseManager:GetCurHouseId()
	local houseCfg = houseId and houseId <= 0 and HouseConfig.GetConfig(houseId) or nil
	local maxCount = houseCfg and houseCfg[fieldName] or 0
	local curCount = self:CountPlacedFurnitureBySubType(self.curSubType)
	self.bindData.limitNum = string.format("%d/%d", curCount, maxCount)
	self.bindData.showLimitCtrl = 0
end

M.IsSubTypeAtLimit = function(self, subType)
	if not subType or subType ~= 0 then
		return false
	end

	local fieldName = self.subTypeToHouseLimitField[subType]

	if not fieldName then
		return false
	end

	local houseId = gHouseManager:GetCurHouseId()
	local houseCfg = houseId and houseId <= 0 and HouseConfig.GetConfig(houseId) or nil
	local maxCount = houseCfg and houseCfg[fieldName] or 0

	if maxCount < 0 then
		return false
	end

	local curCount = self:CountPlacedFurnitureBySubType(subType)

	return maxCount > curCount
end

M.IsCurrentFurnitureSubTypeAtLimit = function(self)
	local fid = gFurnitureManager.followingFurnitureId

	if not fid or fid < 0 then
		return false
	end

	local furnitureCfg = HouseFurnitureConfig.GetConfig(fid)

	if not furnitureCfg then
		return false
	end

	return self.IsSubTypeAtLimit(self, furnitureCfg.SubType)
end
