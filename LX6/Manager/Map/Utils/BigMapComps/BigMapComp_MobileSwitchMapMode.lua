-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\BigMapComp_MobileSwitchMapMode.lua
-- Decompiled from: 01039_BigMapComp_MobileSwitchMapMode.lua_a20c5cd84d21.luajit

BigMapComp_MobileSwitchMapMode = BigMapComp_MobileSwitchMapMode or {}
local M = BigMapComp_MobileSwitchMapMode
M.__index = M

M.OnInit = function(self)
	self.store = nil
	self.widget = nil
	self.defaultMapModeData = {
		{
			["w-y^"] = "?G\\x9c\\x83\\x8cO",
			cfgId = LTConfig.GpsBigMapModeConfig.Common,
			signal = EBigMapFSMSignal.SwitchModeCommon
		},
		{
			["w-y^"] = "\\xff\\xda\t+\\xff",
			cfgId = LTConfig.GpsBigMapModeConfig.Faction,
			signal = EBigMapFSMSignal.SwitchModeFaction
		},
		{
			["w-y^"] = "0M\\x96\\x8b\\x8dE",
			cfgId = LTConfig.GpsBigMapModeConfig.Legend,
			signal = EBigMapFSMSignal.SwitchModeLegend,
			availableSpirits = LTConfig.LegendaryInvestigatorConfig.UnlockLimitedPlayRole
		}
	}
	self.curMapModeData = {}
	self.mode = "Common"
	self.tabRect = self.bindData.mobileSwitchMapModeTab
end

M.OnStart = function(self)
	self.tabRect.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
	self.tabRect.selectedIndex = 0
end

M.OnPanelLoaded = function(self, index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMap_MobileSwitchMapMode"):GetStoreByWidget(self.widget)

	if self.store.switchMapSelector then
		self.store.switchMapSelector.luaSimpleOptionClick = function(_, index)
			local modeData = self.curMapModeData[index + 1]

			if not modeData then
				return
			end

			self.bigMap:SendFSMSignal(EBigMapFSMSignal.Interaction_Reset)
			self.bigMap:SendFSMSignal(modeData.signal)
		end

		self.store.switchMapSelector.luaOnPopup = function(isOpen)
		end
	end

	self:Refresh()
end

M.OnEnd = function(self)
	self.tabRect.selectedIndex = -1

	self.tabRect:ClearUnusedTabInstances()
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
end

M.SetMode = function(self, mode)
	self.mode = mode

	self:Refresh()
end

M.Refresh = function(self)
	if not self.widget then
		return
	end

	if not self.store then
		self.widget:SetActive(false)

		return
	end

	self.curMapModeData = {}

	for i = 1, #self.defaultMapModeData do
		local modeData = self.defaultMapModeData[i]
		local cfg = LTConfig.GpsBigMapModeConfig.GetConfig(modeData.cfgId)

		if not cfg then
			-- Nothing
		elseif modeData.availableSpirits and #modeData.availableSpirits <= 0 then
			local curSpiritId = self.bigMap.filterCharacterTid or gSpiritManager:GetCurFirstSpiritTid()

			if not array.contains(modeData.availableSpirits, curSpiritId) then
				-- Nothing
			end
		elseif cfg.SystemUnlockId and cfg.SystemUnlockId == 0 and not gSystemUnlockMgr:IsUnlock(cfg.SystemUnlockId) then
			-- Nothing
		elseif not modeData.availableJobClass or modeData.availableJobClass ~= 0 or gSpiritJobManager:CheckContainJobClassId(modeData.availableJobClass) then
			table.insert(self.curMapModeData, modeData)
		end
	end

	if self.actived and not gCS.LuaUtils.IsNonMobileAdaptive() and #self.curMapModeData <= 1 then
		self.widget:SetActive(true)
	else
		self.widget:SetActive(false)

		return
	end

	self.store.switchMapSelector.options = nil

	if #self.curMapModeData ~= 0 then
		self.store.switchMapSelector:SetActive(false)
	else
		self:SortModes()

		for i = 1, #self.curMapModeData do
			local cfg = LTConfig.GpsBigMapModeConfig.GetConfig(self.curMapModeData[i].cfgId)

			if cfg then
				self.store.switchMapSelector:AddSimpleOptionLabel(0, cfg.Name, i ~= 1)
			end
		end

		self.store.switchMapSelector:SetActive(true)
	end

	if self.store.switchMapSelector.selectedIndex ~= -1 then
		self.store.switchMapSelector:SelectOption(0, true)
	end

	self.store.switchMapSelector:RefreshOptions()

	for i = 1, #self.curMapModeData do
		local modeData = self.curMapModeData[i]

		if modeData.mode ~= self.mode then
			if self.store.switchMapSelector.selectedIndex == i - 1 then
				self.store.switchMapSelector:SelectOption(i - 1, true)
			end

			break
		end
	end
end

M.SortModes = function(self)
	table.sort(self.curMapModeData, function (a, b)
		local aCfg = LTConfig.GpsBigMapModeConfig.GetConfig(a.cfgId)
		local bCfg = LTConfig.GpsBigMapModeConfig.GetConfig(b.cfgId)

		return aCfg.Order <= bCfg.Order
	end)
end

M.OnFilterSpiritChange = function(self, tid)
	self:Refresh()
end
