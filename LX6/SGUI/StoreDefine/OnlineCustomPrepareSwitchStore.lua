-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineCustomPrepareSwitchStore.lua
-- Decompiled from: 01106_OnlineCustomPrepareSwitchStore.lua_13eaf5422889.luajit

local LingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
C_OnlineCustomPrepareSwitchStore = DefClass("C_OnlineCustomPrepareSwitchStore", C_OnlineCustomPrepareSwitchStore, C_StoreGroup)
GroupName2Class.OnlineCustomPrepareSwitchStore = C_OnlineCustomPrepareSwitchStore
local M = C_OnlineCustomPrepareSwitchStore

M.ctor = function(self)
	self.mgr = gLinkManager
end

M.DefineAllVariables = function(self)
	self.TAB_TYPE = {
		["/x\\xb8\\xbc\\xaau"] = 0,
		["J\rN~"] = 3,
		["\\xff\\xfa'57\\xdf"] = 2,
		["\\xef\\xfe<4=\\xd4"] = 1
	}
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
	self.onSelectCallback = nil
	self.confirmCallback = nil
	self.onTabChangeCallback = nil
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

M.RegisterWidget = function(self)
	self.bindData.mainTabRect.OnRenderTab = self.CreateAction(self, self.OnMainTabRectRender)
	self.bindData.onConfirmBtn = self.CreateAction(self, self.OnConfirmBtnClick)
end

M.OnConfirmBtnClick = function(self)
	if self.confirmCallback then
		self.confirmCallback()
	end
end

M.OnMainTabRectRender = function(self, index, widget)
	local tabType = nil

	for i, data in ipairs(self.tabDataLists) do
		if data.tabRectIndex ~= index then
			tabType = data.type

			break
		end
	end

	if not tabType then
		return
	end

	if tabType ~= self.TAB_TYPE.SPIRIT then
		self.RefreshSpiritPage(self, widget)
	elseif tabType ~= self.TAB_TYPE.VEHICLE then
		self.RefreshVehiclePage(self, widget)
	elseif tabType ~= self.TAB_TYPE.FASHION then
		self.RefreshFashionPage(self, widget)
	end
end

M.RefreshSpiritPage = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local lingList = LingGuiUtils:GetAllLingList()
	self.selectableSpiritList = {}
	self.selectedSpiritIndex = 0

	for i = 1, #lingList do
		local lingInfo = lingList[i]
		local element = {
			tid = lingInfo.Tid,
			icon = lingInfo.sIcon,
			name = lingInfo.Name
		}

		if self.selectDict[self.TAB_TYPE.SPIRIT] ~= lingInfo.Tid then
			self.selectedSpiritIndex = i - 1
		end

		table.insert(self.selectableSpiritList, element)
	end

	local list = store.mainList
	list.luaSimpleRenderItem = self.CreateAction(self, self.OnSpiritListItemRender)
	list.luaSelectedChanged = self.CreateAction(self, self.OnSpiritListSelectedChanged)

	list.SetSimpleList(list, #self.selectableSpiritList)
	list.SelectItem(list, self.selectedSpiritIndex)
end

M.OnSpiritListItemRender = function(self, btn, index)
	btn.gameObject.name = ("OnSpiritItem:%d"):format(index)
	local data = self.selectableSpiritList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.icon

	if self.selectDict[self.TAB_TYPE.SPIRIT] ~= data.tid then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
	end

	btn.luaClick = function()
		if self.selectDict[self.TAB_TYPE.SPIRIT] == data.tid then
			self.selectDict[self.TAB_TYPE.SPIRIT] = data.tid
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
		end
	end
end

M.OnSpiritListSelectedChanged = function(self, uList)
	if self.bindData.mainTabRect.selectedIndex == 1 then
		return
	end

	local data = self.selectableSpiritList[uList.selectedIndex + 1]

	if not data then
		return
	end

	if self.selectDict[self.TAB_TYPE.SPIRIT] == data.tid then
		self.selectDict[self.TAB_TYPE.SPIRIT] = data.tid

		if self.onSelectCallback then
			slot3 = self.SubGroup.CommonTabSingleStore

			slot3:SetInteractable(false)
			self.onSelectCallback(self.TAB_TYPE.SPIRIT, data.tid, function ()
				self.SubGroup.CommonTabSingleStore:SetInteractable(true)
			end)
		end
	end
end

M.RefreshFashionPage = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	store:OnShow(store.m_Id, {
		["Yr\\xf2u\\xd6\\xfc\\xe2n.\\xf1ZJ\\xf4\\xfdU\\xf2`w\\xda\\xf1\\xfcɕ\\xfdj"] = true,
		dressUnitPid = gLinkManager:GetSelfUnitPid()
	})
end

M.RefreshVehiclePage = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not self.selectableVehicleList then
		return
	end

	local selectedIndex = 0

	for i, data in ipairs(self.selectableVehicleList) do
		if self.selectDict[self.TAB_TYPE.VEHICLE] ~= data then
			selectedIndex = i - 1

			break
		end
	end

	local mainList = store.mainList
	mainList.luaSimpleRenderItem = self.CreateAction(self, self.OnVehicleListItemRender)
	local infoTooltipWidget = store.infoTooltipWidget

	mainList.luaSelectedChanged = function(uList)
		local vehicleId = self.selectableVehicleList[uList.selectedIndex + 1]

		if not vehicleId then
			return
		end

		self.selectDict[self.TAB_TYPE.VEHICLE] = vehicleId

		if self.onSelectCallback then
			self.onSelectCallback(self.TAB_TYPE.VEHICLE, vehicleId)
		end

		local infoTooltipStore = gStoreManager:GetStoreGroup(infoTooltipWidget.Store):GetStoreByWidget(infoTooltipWidget)

		gNewCarStoreMgr:RenderCarInfoTooltip(infoTooltipStore, vehicleId)
	end

	mainList.SetSimpleList(mainList, #self.selectableVehicleList)
	mainList.SelectItem(mainList, selectedIndex)
end

M.OnVehicleListItemRender = function(self, btn, index)
	local vehicleId = self.selectableVehicleList[index + 1]

	if not vehicleId then
		return
	end

	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)

	if not vehicleCfg then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = vehicleCfg.SVehicleIconId
	store.name = vehicleCfg.VehicleName
	store.qualityCtrl = vehicleCfg.VehicleQuality
	store.brandIconId = vehicleCfg.SVehicleBrandIcon
	local canUse = self:CheckVehicleCanUse(vehicleId)
	btn.interactable = canUse
	store.lockCtrl = canUse and 0 or 1
end

M.CheckVehicleCanUse = function(self, vehicleId)
	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)
	local gameCfg = self.linkGame:GetConfig()
	local currentVehicleLimit = gameCfg and gameCfg.VehicleTypeLimit
	local canUse = array.contains(currentVehicleLimit, vehicleCfg.VehicleType)

	return canUse
end

M.RequestVehicleData = function(self)
	local vehicleList = gApplyCarManager.UnlockedVehicles or {}
	local validVehicleList = {}

	for _, vehicle in ipairs(vehicleList) do
		local id = vehicle.Id
		local vehicleCfg = LTConfig.VehicleConfig.GetConfig(id)

		if vehicleCfg then
			table.insert(validVehicleList, vehicle)
		end
	end

	vehicleList = validVehicleList
	local gameCfg = self.linkGame:GetConfig()
	local currentVehicleLimit = gameCfg and gameCfg.VehicleTypeLimit
	self.selectableVehicleList = {}

	if currentVehicleLimit then
		local selectedIndex = 0
		local myPid = gPlayerManager.infoLogin.bindData.pid
		slot7 = self.linkGame
		local readyVehicleId = slot7:GetVehicleId(myPid)

		table.sort(vehicleList, function (data1, data2)
			local vehicleId1 = data1.Id
			local vehicleId2 = data2.Id
			local isReady1 = readyVehicleId ~= vehicleId1
			local isReady2 = readyVehicleId ~= vehicleId2

			if isReady1 == isReady2 then
				return isReady1
			end

			local canUse1 = self:CheckVehicleCanUse(vehicleId1)
			local canUse2 = self:CheckVehicleCanUse(vehicleId2)

			if canUse1 == canUse2 then
				return canUse1
			end

			return vehicleId1 <= vehicleId2
		end)

		for i = 1, #vehicleList do
			local id = vehicleList[i].Id
			local vehicleCfg = LTConfig.VehicleConfig.GetConfig(id)

			if vehicleCfg then
				if self.selectDict[self.TAB_TYPE.VEHICLE] ~= id then
					selectedIndex = i - 1
				end

				table.insert(self.selectableVehicleList, id)
			end
		end
	end

	local tabData = self.tabDataDict[self.TAB_TYPE.VEHICLE]
	local tabIndex = tabData and tabData.tabRectIndex

	if tabIndex and self.bindData.mainTabRect.selectedIndex ~= tabIndex then
		local suc, widget = self.bindData.mainTabRect:TryGetTabInstance(tabIndex, nil)

		if suc and widget then
			self.RefreshVehiclePage(self, widget)
		end
	end
end

M.InitData = function(self, linkGame, hasVehicle, onSelectCallback, onConfirmCallback, onTabChangeCallback)
	self.linkGame = linkGame
	self.tabDataLists = {}

	table.insert(self.tabDataLists, {
		["{w\\xaeEI\\xb1\\xe6nd~{T"] = 1,
		type = self.TAB_TYPE.SPIRIT,
		title = TextScriptTextConfig.GetConfig(89901276).Text
	})

	if hasVehicle then
		table.insert(self.tabDataLists, {
			["{w\\xaeEI\\xb1\\xe6nd~{T"] = 0,
			type = self.TAB_TYPE.VEHICLE,
			title = TextScriptTextConfig.GetConfig(89901275).Text
		})
	end

	table.insert(self.tabDataLists, {
		["{w\\xaeEI\\xb1\\xe6nd~{T"] = 2,
		type = self.TAB_TYPE.FASHION,
		title = TextCommonTextConfig.GetConfig(74002213).Text
	})

	self.tabDataDict = {}

	for i, data in ipairs(self.tabDataLists) do
		self.tabDataDict[data.type] = data
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid
	self.selectDict = {
		[self.TAB_TYPE.SPIRIT] = self.linkGame:GetCharacterId(myPid),
		[self.TAB_TYPE.VEHICLE] = self.linkGame:GetVehicleId(myPid),
		[self.TAB_TYPE.POSE] = self.linkGame:GetPoseId(myPid)
	}
	self.onSelectCallback = onSelectCallback
	self.confirmCallback = onConfirmCallback
	self.onTabChangeCallback = onTabChangeCallback
	self.selectableVehicleList = nil

	self:RequestVehicleData()
end

M.OnOpen = function(self)
	local tabViewList = {}

	for i, data in ipairs(self.tabDataLists) do
		tabViewList[i] = {
			id = data.type,
			title = data.title
		}
	end

	self.bindData.mainTabRect.selectedIndex = -1
	slot2 = self.bindData.mainTabRect

	slot2:ClearUnusedTabInstances()

	slot2 = self.SubGroup.CommonTabSingleStore

	slot2:SetData(tabViewList, nil, 0, nil, function (uList, isSub)
		if not isSub then
			local data = self.tabDataLists[uList.selectedIndex + 1]

			if data then
				self.bindData.mainTabRect.selectedIndex = data.tabRectIndex

				if self.onTabChangeCallback then
					self.onTabChangeCallback(data.type)
				end
			end
		end
	end)
end
