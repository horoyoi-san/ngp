-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CarModsPanelVehiclePageStore.lua
-- Decompiled from: 01638_CarModsPanelVehiclePageStore.lua_38d312f6b89b.luajit

local VehiclePartShopTabConfig = LTConfig.VehiclePartShopTabConfig
local VehicleConfig = LTConfig.VehicleConfig
local VehicleTypeConfig = LTConfig.VehicleTypeConfig
C_CarModsPanelVehiclePageStore = DefClass("C_CarModsPanelVehiclePageStore", C_CarModsPanelVehiclePageStore, C_StoreGroup)
GroupName2Class.CarModsPanelVehiclePageStore = C_CarModsPanelVehiclePageStore
local M = C_CarModsPanelVehiclePageStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.parent = gStoreManager:GetStoreGroup("CarModsPanelStore")
	self.mgr = gNewCarStoreMgr
	self.allVehicleList = nil
	self.allVehicleIndexMap = nil
	self.vehicleList = nil
	self.searchText = ""

	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RefreshPage = function(self)
	self:_BuildAllVehicleList()
	self:_RefreshList()
	self.mgr:SetCameraState(VehiclePartShopTabConfig.ViewTypeType.Right)
end

M._BuildAllVehicleList = function(self)
	self.allVehicleList = {}
	self.allVehicleIndexMap = {}
	local list = gApplyCarManager and gApplyCarManager.UnlockedVehicles

	if not list or not list.Count then
		return
	end

	for i = 1, list.Count do
		local info = list[i]

		if info and info.Id then
			local cfg = VehicleConfig.GetConfig(info.Id)
			local defaultSuit = self.mgr:GetDefaultSuitParts(cfg)
			local canModify = false

			if defaultSuit then
				for j = 1, #defaultSuit do
					if defaultSuit[j] and defaultSuit[j] == 0 then
						canModify = true

						break
					end
				end
			end

			local canShow = false
			local typeCfg = VehicleTypeConfig.GetConfig(cfg and cfg.VehicleType)

			if typeCfg and typeCfg.CarshopCanShow then
				canShow = true
			end

			if canModify and canShow then
				table.insert(self.allVehicleList, info.Id)

				self.allVehicleIndexMap[info.Id] = #self.allVehicleList
			end
		end
	end
end

M._ApplyFilter = function(self)
	self.vehicleList = {}

	if not self.allVehicleList then
		return
	end

	local filter = self.parent.vehicleFilter
	local search = self.searchText
	local lowerSearch = search and search == "" and string.lower(search) or nil

	for _, vid in ipairs(self.allVehicleList) do
		local cfg = VehicleConfig.GetConfig(vid)

		if filter then
			if filter.typeSet and cfg and cfg.VehicleType and cfg.VehicleType == 0 and not filter.typeSet[cfg.VehicleType] then
				-- Nothing
			elseif filter.approachSet and cfg and cfg.VehicleGetway and cfg.VehicleGetway == 0 and not filter.approachSet[cfg.VehicleGetway] then
				-- Nothing
			elseif filter.brandSet and cfg and cfg.Brand and cfg.Brand == 0 and not filter.brandSet[cfg.Brand] then
				-- Nothing
			end
		elseif lowerSearch then
			local name = cfg and cfg.VehicleName or ""

			if not string.find(string.lower(name), lowerSearch, 1, true) then
				-- Nothing
			end
		else
			table.insert(self.vehicleList, vid)
		end
	end

	if filter then
		self._SortVehicleList(self, filter)
	end
end

M._SortVehicleList = function(self, filter)
	local sortType = filter.sortType or 1
	local ascending = filter.ascending == false
	local less = nil

	if sortType ~= 2 then
		less = function(a, b)
			return (self.allVehicleIndexMap[a] or 0) <= (self.allVehicleIndexMap[b] or 0)
		end
	else
		less = function(a, b)
			local qa = (VehicleConfig.GetConfig(a) or {}).VehicleQuality or 0
			local qb = (VehicleConfig.GetConfig(b) or {}).VehicleQuality or 0

			return qa <= qb
		end
	end

	table.sort(self.vehicleList, function (a, b)
		if ascending then
			return less(a, b)
		else
			return less(b, a)
		end
	end)
end

M._RefreshList = function(self)
	self:_ApplyFilter()

	local count = self.vehicleList and #self.vehicleList or 0

	self.bindData.vehicleList:SetSimpleList(count)

	local curId = self.parent.vehicleId
	local selectedIndex = -1

	if self.vehicleList and curId then
		for i, vid in ipairs(self.vehicleList) do
			if vid ~= curId then
				selectedIndex = i - 1

				break
			end
		end
	end

	if selectedIndex >= 0 then
		local hasFilter = self.parent.vehicleFilter == nil

		if (not self.searchText or self.searchText ~= "") and not hasFilter then
			print_error("[CarModsPanel] VehiclePage: 当前展示车不在 UnlockedVehicles 列表中, vehicleId=", curId)
		end
	else
		self.bindData.vehicleList:SelectItem(selectedIndex)
	end
end

M.OnSearchInputValueChanged = function(self, text)
	self.searchText = string.trim(text or "")

	self:_RefreshList()
end

M.OnClickClearBtn = function(self)
	self.bindData.searchInputField.text = ""
end

M.OnClickFilterBtn = function(self)
	gPanelManager:CheckShow(gPanelId.VEHICLE_FILTER_PANEL, {
		callBack = self:CreateAction(self.OnFilterClose)
	})
end

M.OnFilterClose = function(self)
	self._RefreshList(self)
end

M.RegisterWidget = function(self)
	self.bindData.vehicleList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderVehicleListItem)
	self.bindData.vehicleList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickVehicleList)
	self.bindData.searchInputField.luaValueChanged = self.CreateAction(self, self.OnSearchInputValueChanged)
	self.bindData.clearBtn.luaClick = self.CreateAction(self, self.OnClickClearBtn)
	self.bindData.filterBtn.luaClick = self.CreateAction(self, self.OnClickFilterBtn)
end

M.OnSimpleRenderVehicleListItem = function(self, btn, index)
	if not self.vehicleList then
		return
	end

	local vehicleId = self.vehicleList[index + 1]

	if not vehicleId then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = vehicleId
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		local cfg = VehicleConfig.GetConfig(vehicleId)
		store.nameText = cfg and cfg.VehicleName or ""
	end
end

M.OnSimpleClickVehicleList = function(self, btn, index)
	if not self.vehicleList then
		return
	end

	local newVehicleId = self.vehicleList[index + 1]

	if not newVehicleId then
		return
	end

	self.parent:SwitchVehicle(newVehicleId)
end
