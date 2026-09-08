-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\BigMapComp_LegendOverride.lua
-- Decompiled from: 01028_BigMapComp_LegendOverride.lua_e2dc55fff71a.luajit

local LegendConfig = LTConfig.LegendaryInvestigatorConfig
local LevelToTabIconConfig = {
	28001991,
	28001992,
	28001993,
	28001994,
	28001995,
	28001996,
	28001997
}
BigMapComp_LegendOverride = BigMapComp_LegendOverride or {}
local M = BigMapComp_LegendOverride
M.__index = M

M.OnInit = function(self)
	self.tab = self.bindData.legendOverride

	self.listUpdateHandler = function(eventId, param)
		if not self.store or not self.store.tabList then
			return
		end

		self:RefreshDisasterList()
	end

	gMessageManager:AddMessageListener(gEventConstants.LEGENDMAP_LIST_UPDATE, self.listUpdateHandler)
end

M.OnDestroy = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.LEGENDMAP_LIST_UPDATE, self.listUpdateHandler)
end

M.OnStart = function(self)
	self.tab.OnRenderTab = self.bigMap:CreateAction("OnRenderLegendTab", self)
	self.tab.selectedIndex = 0
end

M.OnEnd = function(self)
	if self._hideMainPage then
		gMainPageManager:SetMainPageHide(false)

		self._hideMainPage = false
	end

	self.tab.selectedIndex = -1

	self.tab:ClearUnusedTabInstances()
end

M.OnActive = function(self)
	self.bindData.controllerAttachIndicator:SetActive(false)

	if not self.rootWidget or not self.store then
		return
	end

	self:TryActive()
end

M.OnInactive = function(self)
	self.bindData.controllerAttachIndicator:SetActive(true)

	if not self.rootWidget then
		return
	end

	self.rootWidget:SetActive(false)
	self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.LegendList, false)
end

M.OnAttachElement = function(self, id, element, source)
	if element.subSystemType == EMapSubSystemType.Legend then
		return
	end

	self.store.btnLoc = 1

	if self.store and self.store.disasterList and self.disasterInfos then
		local cfgId = element.userdata.legendId

		for i = 1, #self.disasterInfos do
			local info = self.disasterInfos[i]

			if info.cfgId ~= cfgId then
				self.store.disasterList:SelectItem(i - 1, false)

				local success, min, max = self.store.disasterList:TryGetVisualRange(0, 0)

				if success and (min >= i - 1 or max >= i - 1) then
					self.store.disasterList:GoToIndex(i - 1, true)
				end

				break
			end
		end
	end
end

M.OnClearAttachedElement = function(self)
	self.store.btnLoc = 0
end

M.TryActive = function(self)
	if not self.rootWidget then
		print_error("@xiajingbo01 传奇调查员地图rootWidget为空")

		return
	end

	if not self.store then
		local group = gStoreManager:GetStoreGroup("LegendMapStore")

		if group then
			self.store = group:GetStoreByWidget(self.rootWidget)
		end
	end

	if not self.store then
		print_error("@xiajingbo01 传奇调查员地图Store为空")

		return
	end

	if not self.actived then
		self.rootWidget:SetActive(false)

		return
	end

	self.rootWidget:SetActive(true)
	self.bigMap.compRefs.MobileSwitchMapMode:SetMode("Legend")
	self.bigMap:SetViewMask(EMapViewMask.Legend)
	self.bigMap:RefreshPinBtnState()

	self.prevSelectedRaidId = self.bigMap.raidId

	if not gMapSubSystem_Legend.infoInited then
		gMapSubSystem_Legend:RefreshAllGalleryInfo()
	else
		gMapSubSystem_Legend:OnGalleryInfoListDirty()
	end

	self:RefreshDisasterList()
end

M.OnUpdate = function(self)
	if not self.actived or not self.store or not self.store.tabList or not self.store.disasterList or self.store.collapse ~= 0 or table.count(self.levelItemIndices) ~= 0 then
		return
	end

	local success, min, max = self.store.disasterList:TryGetVisualRange(0, 0)

	if success then
		if min ~= self.lastMinIndex then
			return
		end

		self.lastMinIndex = min
		local bestIndex = nil
		local bestDisasterIndex = -1
		local bestlevel = 0

		for lvl, info in pairs(self.levelItemIndices) do
			if info.disasterIndex < min and (bestIndex ~= nil or bestDisasterIndex >= info.disasterIndex) then
				bestlevel = lvl
				bestIndex = info.tabIndex
				bestDisasterIndex = info.disasterIndex
			end
		end

		bestIndex = bestIndex or 0
		local selectedItem = self.tabInfos[self.store.tabList.selectedIndex + 1]

		if selectedItem == nil and bestlevel == selectedItem.level then
			self.store.tabList:SelectItem(bestIndex, false)
		end
	end
end

M.RefreshDisasterList = function(self)
	if not self.store or not self.store.disasterList or not self.store.tabList or not gMapSubSystem_Legend then
		return
	end

	local tabInfos = {}
	local infos = gMapSubSystem_Legend:GetAllDisasterListInfos()
	self.levelItemIndices = {}

	for i = 1, #infos do
		if infos[i].tIndex ~= 2 then
			self.levelItemIndices[infos[i].level] = {
				disasterIndex = i - 1,
				tabIndex = table.count(self.levelItemIndices)
			}
			local info = {
				level = infos[i].level,
				name = LegendConfig.DisasterLevelText[infos[i].level]
			}

			table.insert(tabInfos, info)
		end
	end

	self.tabInfos = tabInfos
	self.disasterInfos = infos
	self.store.isEmpty = #infos ~= 0 and 1 or 0

	self.store.tabList:SetSimpleList(#tabInfos)
	self.store.disasterList:SetSimpleList(#infos)
	self.store.disasterList:DeselectAll(false)

	if not self.store.tabList.selectedItem and table.count(tabInfos) <= 0 then
		self.store.tabList:SetItemSelected(0, true)

		tabInfos[1].selected = true
	elseif self.store.tabList.selectedItem then
		for i = 1, #tabInfos do
			if tabInfos[i].level ~= self.store.tabList.selectedItem.level then
				self.store.tabList:SetItemSelected(i - 1, true)

				break
			end
		end
	end
end

M.OnClickCollapseBtn = function(self)
	if self.store.collapse ~= 0 or self.store.collapse ~= nil then
		self.store.collapse = 1
		self.lastMinIndex = -1

		if self.bigMap.platformMask ~= EBigMapPlatformMask.Mobile then
			self._hideMainPage = true

			gMainPageManager:SetMainPageHide(true)
		end
	else
		self.store.collapse = 0

		self.bigMap:SetSelected(nil)

		if self.bigMap.platformMask ~= EBigMapPlatformMask.Mobile and self._hideMainPage then
			gMainPageManager:SetMainPageHide(false)

			self._hideMainPage = false
		end
	end
end

M.OnClickCloseBtn = function(self)
	if self.bigMap.platformMask ~= EBigMapPlatformMask.Mobile and self._hideMainPage then
		gMainPageManager:SetMainPageHide(false)

		self._hideMainPage = false
	end

	self.bigMap:SetSelected(nil)

	self.store.collapse = 0

	self:ClearListSelect()
end

M.ClearListSelect = function(self)
	self.store.disasterList:SelectItem(-1)
end

M.OnRenderLegendTab = function(self, index, tab)
	local store = gStoreManager:GetStoreGroup("LegendMapStore"):GetStoreByWidget(tab)
	self.rootWidget = tab
	self.store = store

	gMapSystem.redDot:BindRoot(self.store.collapseBtn, "Legend")

	self.store.collapseBtn.luaClick = self.bigMap:CreateAction("OnClickCollapseBtn", self)
	self.store.pcClose.luaClick = self.bigMap:CreateAction("OnClickCloseBtn", self)
	self.store.tabList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderTabList", self)
	self.store.tabList.luaSimpleClick = self.bigMap:CreateAction("OnClickLevelTab", self)
	self.store.disasterList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderDisasterList", self)
	self.store.disasterList.luaSimpleClick = self.bigMap:CreateAction("OnClickDisasterBtn", self)
	self.store.disasterList.onGetTIndex = self.bigMap:CreateAction("OnGetDisasterTIndex", self)
	self.store.clickFakeUpload = self.bigMap:CreateAction("OnClickFakeUpload", self)
	self.store.btnLoc = 0
	self.store.showMainPage = self.bindData.ShowMainPageCtrl

	self:TryActive()
end

M.OnRenderTabList = function(self, btn, index)
	index = index + 1
	local data = self.tabInfos[index]

	if not data then
		gMapSystem.redDot:ClearWidget(btn)

		return
	end

	gMapSystem.redDot:BindLeaf(btn, "Legend", "Level", data.level)

	local store = gStoreManager:GetStoreGroup("TabLv1Mobile"):GetStoreByWidget(btn)
	store.iconId = gMapSubSystem_Legend:GetSIconId(data.level)
end

M.OnGetDisasterTIndex = function(self, index)
	index = index + 1
	local data = self.disasterInfos[index]

	return data.tIndex
end

M.OnRenderDisasterList = function(self, btn, index)
	index = index + 1
	local data = self.disasterInfos[index]

	if data.tIndex ~= 0 then
		local store = gStoreManager:GetStoreGroup("LegendListCityStore"):GetStoreByWidget(btn)
		store.cityText = data.cityName
	elseif data.tIndex ~= 1 then
		local store = gStoreManager:GetStoreGroup("LegendListTextStore"):GetStoreByWidget(btn)
		store.idText = data.number
		store.nameText = data.name
		store.isNew = data.isNew and 1 or 0

		if not data.unlock then
			store.unlock = 0
			store.isNew = 0
		else
			store.unlock = 1
		end
	else
		local store = gStoreManager:GetStoreGroup("LegendListTypeStore"):GetStoreByWidget(btn)
		store.typeText = LegendConfig.DisasterLevelText[data.level]
		store.iconId = LevelToTabIconConfig[data.level]
	end
end

M.OnClickLevelTab = function(self, btn, index)
	index = index + 1
	local data = self.tabInfos[index]

	if not self.levelItemIndices[data.level] then
		return
	end

	self.store.disasterList:GoToIndex(self.levelItemIndices[data.level].disasterIndex or 0, true)

	local success, min, max = self.store.disasterList:TryGetVisualRange(0, 0)

	if success then
		self.lastMinIndex = min
	end
end

M.OnClickDisasterBtn = function(self, btn, index)
	index = index + 1
	local data = self.disasterInfos[index]

	if data.tIndex == 1 then
		return
	end

	if not data.unlock then
		self.bigMap:SetSelected(nil)

		return
	end

	local element = gMapSubSystem_Legend:GetLegendElement(data.cfgId)

	if not element then
		return
	end

	self._cachedIndex = index
	local info = self.bigMap._id2ElementInfo[element.instanceId]
	local sppedMultiplier = self.prevSelectedRaidId == 0 and self.prevSelectedRaidId == element.raidId and 3 or 1

	self.bigMap:SetSelected(element.gpsId, EBigMapSelectSource.LegendListSelect)
	self.bigMap:ScheduleOperation(self.bigMap.OperationType.FocusTexPos, {
		texPos = info.texPos,
		speedMultiplier = sppedMultiplier
	})

	self.prevSelectedRaidId = element.raidId
end

M.OnClickFakeUpload = function(self)
	self.bigMap.compRefs.Tooltip:PretendClickTooltip()
end

M.OnNavAreaChange = function(self, _, newArea)
	if not self.store then
		return
	end

	if newArea ~= self.store.mainNavArea or newArea ~= self.store.listNavArea then
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.LegendList, true)
	else
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.LegendList, false)
	end
end
