-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\BigMapComp_NewSwitchMapMode.lua
-- Decompiled from: 01037_BigMapComp_NewSwitchMapMode.lua_9b6efa9e4d2f.luajit

BigMapComp_NewSwitchMapMode = BigMapComp_NewSwitchMapMode or {}
local M = BigMapComp_NewSwitchMapMode
M.__index = M

M.OnInit = function(self)
	self.store = nil
	self.widget = nil
	self.countryList = {}
	self.countryId2TaskGps = {}
	self.tabRect = self.bindData.newSwitchMapModeTabRect
end

M.OnStart = function(self)
	self.tabRect.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
	self.tabRect.selectedIndex = 0
end

M.OnPanelLoaded = function(self, index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMap_SwitchCountryPart"):GetStoreByWidget(self.widget)
	self.store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnSGUIRenderSwitchCountryItem", self)
	self.store.list.luaSimpleClick = self.bigMap:CreateAction("OnClickSwitchCountry", self)

	self:Refresh()
end

M.OnEnd = function(self)
	self.tabRect.selectedIndex = -1

	self.tabRect:ClearUnusedTabInstances()
end

M.OnSGUIRenderSwitchCountryItem = function(self, btn, index)
	local countryInfo = self.countryList[index + 1]
	local store = gStoreManager:GetStoreGroup("WorldBtnStore"):GetStoreByWidget(btn)
	store.iconId = countryInfo.iconId
	store.name = countryInfo.name
	store.redKey = "NewSwitchCountry_" .. index + 1

	if self.curRaidId and self.curRaidId ~= countryInfo.raidId then
		store.selectCtrl = 0
	else
		store.selectCtrl = 1
	end
end

M.CheckHasTaskInCountry = function(self, countryId)
	if not table.isNilOrEmpty(self.countryId2TaskGps[countryId]) then
		return true
	else
		return false
	end
end

M.UpdateTaskGps = function(self, id)
	if self.bigMap._id2ElementInfo[id] then
		local element = self.bigMap._id2ElementInfo[id].element
		local raidId = element and element.raidId or 0
		local curCountryId = LTConfig.RaidConfig.GetConfig(raidId) and LTConfig.RaidConfig.GetConfig(raidId).CountryId or 0

		for countryId, _ in pairs(self.countryId2TaskGps) do
			if curCountryId ~= countryId then
				self.countryId2TaskGps[countryId][id] = true
			else
				self.countryId2TaskGps[countryId][id] = nil
			end
		end

		if not self.countryId2TaskGps[curCountryId] then
			self.countryId2TaskGps[curCountryId] = {
				["\t\r"] = true
			}
		end
	else
		for countryId, _ in pairs(self.countryId2TaskGps) do
			if self.countryId2TaskGps[countryId] then
				self.countryId2TaskGps[countryId][id] = nil
			end
		end
	end

	self:RefreshRedDot()
end

M.OnClickSwitchCountry = function(self, btn, index)
	local countryInfo = self.countryList[index + 1]
	local centerPos = countryInfo.centerPos

	if self.lastSwitchRaidId and self.lastSwitchRaidId ~= countryInfo.raidId then
		gSoundMgr:PlaySoundByTid(70650629)
	end

	self.lastSwitchRaidId = countryInfo.raidId

	if centerPos then
		local worldPos = Vector3.New(centerPos[1], centerPos[2], centerPos[3])

		self.bigMap:ScheduleOperation(self.bigMap.OperationType.FocusTexPos, {
			texPos = self.bigMap:TransformWorldToTex(worldPos, countryInfo.areaId)
		})
	end
end

M.OnActive = function(self)
	self.tabRect.selectedIndex = 0

	self:Refresh()
end

M.OnInactive = function(self)
	self.tabRect.selectedIndex = -1

	self:Refresh()
end

M.OnUpdate = function(self)
	if self.store and self.bigMap:IsBigWorld() and self.bigMap.areaRangeData then
		local halfViewportSize = self.bigMap:GetRootSize() * 0.5
		local texPos = self.bigMap:TransformUIToTex(halfViewportSize)
		local texX = texPos.x
		local texY = texPos.y
		local curRaidId = nil

		for raidId, rangeData in pairs(self.bigMap.areaRangeData) do
			if rangeData.texStartX < texX and texX < rangeData.texEndX and rangeData.texStartY < texY and texY < rangeData.texEndY then
				curRaidId = raidId

				break
			end
		end

		if curRaidId == self.curRaidId then
			self.curRaidId = curRaidId

			if not self.lastSwitchRaidId and curRaidId then
				self.lastSwitchRaidId = curRaidId
			end

			self.store.list:RefreshList()
		end
	end
end

M.Refresh = function(self)
	if not self.store then
		self.tabRect:SetActive(false)

		return
	end

	if self.actived then
		self.bigMap:RegisterNavArea(EBigMapNavArea.NewSwitchMapMode, self.store.navArea)
		self.bigMap:RegisterNavArea(EBigMapNavArea.NewSwitchMapMode, self.store.listNavArea)
		self.bigMap:RegisterControllerKey(EBigMapControllerKey.NewSwitchMap, self.store.controllerKey)
		self.tabRect:SetActive(true)
	else
		self.bigMap:UnRegisterNavArea(EBigMapNavArea.NewSwitchMapMode, self.store.navArea)
		self.bigMap:UnRegisterNavArea(EBigMapNavArea.NewSwitchMapMode, self.store.listNavArea)
		self.bigMap:UnRegisterControllerKey(EBigMapControllerKey.NewSwitchMap)
		self.tabRect:SetActive(false)

		return
	end

	self.countryList = {}

	for i = 0, LTConfig.CollectionCountryConfig.count - 1 do
		local cfg = LTConfig.CollectionCountryConfig.LoadAt(i)

		if cfg.RaidId and (cfg.SystemUnlockId ~= 0 or gSystemUnlockMgr:IsUnlock(cfg.SystemUnlockId)) then
			table.insert(self.countryList, {
				countryId = cfg.Id,
				name = cfg.Name,
				iconId = cfg.MapCountryImage,
				centerPos = cfg.CenterPos,
				raidId = cfg.RaidId,
				areaId = gMapSystem.area:GetAreaId(cfg.RaidId, 0)
			})
		end
	end

	if self.store then
		self.store.list:SetSimpleList(#self.countryList)
	end

	self:RefreshRedDot()
end

M.SortModes = function(self)
	table.sort(self.curMapModeData, function (a, b)
		local aCfg = LTConfig.GpsBigMapModeConfig.GetConfig(a.cfgId)
		local bCfg = LTConfig.GpsBigMapModeConfig.GetConfig(b.cfgId)

		return aCfg.Order <= bCfg.Order
	end)
end

M.RefreshRedDot = function(self)
	if self.countryList then
		for i, countryInfo in pairs(self.countryList) do
			local countryId = countryInfo.countryId

			if self:CheckHasTaskInCountry(countryId) then
				SGUI.RedDotMgr.LuaSetRedDot(true, "NewSwitchCountry_" .. i)
			else
				SGUI.RedDotMgr.LuaSetRedDot(false, "NewSwitchCountry_" .. i)
			end
		end
	end
end

M.OnFilterSpiritChange = function(self, tid)
	self:Refresh()
end

M.OnNavAreaChange = function(self, oldArea, newArea)
	if not self.store then
		return
	end

	if newArea ~= self.store.listNavArea then
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.NewSwitchMapMode, true)
	else
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.NewSwitchMapMode, false)
	end
end
