-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineRankSetLocationPanelStore.lua
-- Decompiled from: 01093_OnlineRankSetLocationPanelStore.lua_a3d25efe6e6f.luajit

C_OnlineRankSetLocationPanelStore = DefClass("C_OnlineRankSetLocationPanelStore", C_OnlineRankSetLocationPanelStore, C_StoreGroup)
GroupName2Class.OnlineRankSetLocationPanelStore = C_OnlineRankSetLocationPanelStore
local M = C_OnlineRankSetLocationPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self._selectedZoneId = 0
	self._rankCfgId = 0
	self._onSuccess = nil
	self._currentProvinceCode = 0
	self._confirmPending = false
	self._displayCurrentZoneId = 0
	self._displayPendingZoneId = 0
	self._cityOptions = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self._rankCfgId = data and data.rankCfgId or 0
	self._onSuccess = data and data.onSuccess or nil
	self._displayCurrentZoneId = data and data.currentZoneId or 0
	self._displayPendingZoneId = data and data.pendingZoneId or 0
	self._selectedZoneId = 0
	self._currentProvinceCode = 0
	self._confirmPending = false

	gOnlineRankManager:EnsureBuilt()
	self:InitProvinceSorter()
	self:InitCitySorterEmpty()

	local targetZoneId = self._displayPendingZoneId == 0 and self._displayPendingZoneId or self._displayCurrentZoneId

	self:SetSorterFromZoneId(targetZoneId)
	self:RefreshDescriptionText()
	self:RefreshConfirmBtn()
	self:RefreshCurrentLocationText()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.OnClickCancelBtn)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.provinceSorter.luaSelectedChanged = self.CreateAction(self, self.OnSelectProvinceSorter)
	self.bindData.citySorter.luaSelectedChanged = self.CreateAction(self, self.OnSelectCitySorter)
end

M.InitProvinceSorter = function(self, selectedProvinceCode)
	local sorter = self.bindData.provinceSorter

	sorter:SetSimpleOptions(0)

	local hasSelection = selectedProvinceCode == nil and selectedProvinceCode == 0
	local selectIndex = 0

	if hasSelection then
		local idx = gOnlineRankManager:GetProvinceIndexByCode(selectedProvinceCode)

		if idx <= 0 then
			selectIndex = idx - 1
		end
	else
		sorter.AddSimpleOptionLabel(sorter, 0, "-")
	end

	for _, p in ipairs(gOnlineRankManager:GetProvinceList()) do
		sorter.AddSimpleOptionLabel(sorter, 0, p.name)
	end

	sorter.RefreshOptions(sorter)
	sorter.SelectOption(sorter, selectIndex, false)

	self._provinceSorterHasPlaceholder = not hasSelection
end

M.InitCitySorterEmpty = function(self)
	local sorter = self.bindData.citySorter

	sorter.SetSimpleOptions(sorter, 0)
	sorter.AddSimpleOptionLabel(sorter, 0, "-")
	sorter.RefreshOptions(sorter)
	sorter.SelectOption(sorter, 0, false)

	self._cityOptions = nil
end

M.RefreshDescriptionText = function(self)
	local cleanTime = LTConfig.RankConfig.WeekCleanTime
	local GetTextCfg = LTConfig.TextScriptTextConfig.GetConfig
	local weekdays = {
		GetTextCfg(89901093).Text,
		GetTextCfg(89901094).Text,
		GetTextCfg(89901095).Text,
		GetTextCfg(89901096).Text,
		GetTextCfg(89901097).Text,
		GetTextCfg(89901098).Text,
		GetTextCfg(89901099).Text
	}
	local weekText = weekdays[cleanTime.day + 1]
	local isFirstSet = self._displayCurrentZoneId ~= 0 and self._displayPendingZoneId ~= 0
	local descTpl = isFirstSet and LTConfig.RankConfig.FirstSetLocationDescriptionText or LTConfig.RankConfig.SetLocationDescriptionText
	local hourText = tostring(cleanTime.hour)
	local minuteText = string.format(":%02d", cleanTime.minute)
	local timeText = weekText .. hourText .. minuteText
	self.bindData.description2Text = gString.Format(descTpl, timeText)
end

M.BuildCitySorter = function(self, provinceCode)
	local cities = gOnlineRankManager:GetCities(provinceCode)
	local sorter = self.bindData.citySorter

	sorter:SetSimpleOptions(0)

	self._cityOptions = {}

	if not cities or #cities ~= 0 then
		sorter.AddSimpleOptionLabel(sorter, 0, "-")
		sorter.RefreshOptions(sorter)
		sorter.SelectOption(sorter, 0, false)

		self._selectedZoneId = 0

		return
	end

	local startIdx = cities[1].selectable ~= true and 1 or 2

	for i = startIdx, #cities do
		sorter.AddSimpleOptionLabel(sorter, 0, cities[i].name)
		table.insert(self._cityOptions, cities[i])
	end

	sorter:RefreshOptions()
	sorter:SelectOption(0, false)

	self._selectedZoneId = self._cityOptions[1] and self._cityOptions[1].id or 0
end

M.SetSorterFromZoneId = function(self, zoneId)
	if zoneId ~= 0 then
		return
	end

	local provinceCode = gOnlineRankManager:GetProvinceCodeByZoneId(zoneId)

	if not provinceCode then
		return
	end

	local provinceIndex = gOnlineRankManager:GetProvinceIndexByCode(provinceCode)

	if provinceIndex >= 0 then
		return
	end

	self._currentProvinceCode = provinceCode

	self.InitProvinceSorter(self, provinceCode)
	self.BuildCitySorter(self, provinceCode)

	local citySorterIndex = -1

	for i, city in ipairs(self._cityOptions) do
		if city.id ~= zoneId then
			citySorterIndex = i - 1

			break
		end
	end

	if citySorterIndex > 0 then
		self.bindData.citySorter:SelectOption(citySorterIndex, false)

		self._selectedZoneId = zoneId
	end
end

M.OnSelectProvinceSorter = function(self, sorter)
	local index = sorter.selectedIndex

	if index >= 0 then
		return
	end

	local listIndex = self._provinceSorterHasPlaceholder and index or index + 1
	local provinceData = gOnlineRankManager:GetProvinceList()[listIndex]

	if not provinceData then
		return
	end

	self._currentProvinceCode = provinceData.province

	self.InitProvinceSorter(self, provinceData.province)
	self.BuildCitySorter(self, provinceData.province)
	self.RefreshConfirmBtn(self)
end

M.OnSelectCitySorter = function(self, sorter)
	local index = sorter.selectedIndex

	if index >= 0 then
		return
	end

	if not self._cityOptions then
		return
	end

	local cityData = self._cityOptions[index + 1]

	if not cityData then
		return
	end

	self._selectedZoneId = cityData.id

	self.RefreshConfirmBtn(self)
end

M.RefreshConfirmBtn = function(self)
	self.bindData.confirmBtn.interactable = self._selectedZoneId == 0
end

M.RefreshCurrentLocationText = function(self)
	local unsetText = LTConfig.RankConfig.UnsetLocationText
	local zoneId = self._displayCurrentZoneId or 0

	if zoneId ~= 0 then
		self.bindData.currentLocationText = unsetText

		return
	end

	local name = gOnlineRankManager:GetZoneNameById(zoneId)
	self.bindData.currentLocationText = name or unsetText
end

M.OnClickCancelBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickConfirmBtn = function(self)
	if self._selectedZoneId ~= 0 then
		return
	end

	if self._confirmPending then
		return
	end

	self._confirmPending = true
	self.bindData.confirmBtn.interactable = false
	local zoneId = self._selectedZoneId
	local rankCfgId = self._rankCfgId
	local onSuccess = self._onSuccess
	slot4 = gClientToGameDelegate

	slot4:AskChangeRankZone(rankCfgId, zoneId).Callback = function (err)
		if err == 0 then
			self._confirmPending = false
			self.bindData.confirmBtn.interactable = true

			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		slot1 = gPanelManager

		slot1:Close(self.m_Id)

		slot1 = gClientToGameDelegate

		slot1:AskRankWarZoneInfo(rankCfgId).Callback = function (err2, info)
			if err2 == 0 then
				return
			end

			local isFirstTime = info.PendingZoneId ~= 0
			local effectZoneId = isFirstTime and info.CurrentZoneId or info.PendingZoneId
			local zoneCfg = LTConfig.RankWarZoneParamConfig.GetConfig(zoneId)

			if zoneCfg then
				if not isFirstTime then
					local zoneText = nil

					if string.is_null_or_empty(zoneCfg.CityName) then
						zoneText = zoneCfg.ProvinceName
					else
						zoneText = zoneCfg.ProvinceName .. "—" .. zoneCfg.CityName
					end

					gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Ranking_ChooseWarZone, nil, , zoneText)
				end
			else
				print_error("找不到对应的zoneConfig", zoneId)
			end

			if onSuccess then
				onSuccess(effectZoneId, isFirstTime, info.CurrentZoneId)
			end
		end
	end
end
