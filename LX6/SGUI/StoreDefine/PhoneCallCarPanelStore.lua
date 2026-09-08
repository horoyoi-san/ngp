-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneCallCarPanelStore.lua
-- Decompiled from: 02033_PhoneCallCarPanelStore.lua_18ffec6bdf6f.luajit

C_PhoneCallCarPanelStore = DefClass("C_PhoneCallCarPanelStore", C_PhoneCallCarPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneCallCarPanelStore = C_PhoneCallCarPanelStore
local M = C_PhoneCallCarPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.chooseButton.luaClick = self:CreateAction("OnCallCarClick")
	self.bindData.carList.luaSimpleRenderItem = self:CreateAction("OnRenderItem")

	local frameFunc = function()
		if gClientUtils.NotNil(self.bindData.navArea) then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navArea
		end
	end

	FrameTimer.New(frameFunc, 2):Start()
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.MULTI_DIALOG_MOVE_STATUS] = function (_, value)
			if value ~= 1 then
				self:OnExit()
			end
		end
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.onConfirmCallback = args.onConfirmCallback
	self.onDestroyCallback = args.onDestroyCallback
	self.onExitClickCallback = args.onExitClickCallback
	self.onCustomConfirmCallback = args.onCustomConfirmCallback
	local unlockedVehicles = gApplyCarManager.UnlockedVehicles
	self.vehicleList = {}

	for _, vehicleInfo in ipairs(unlockedVehicles) do
		if (table.isNilOrEmpty(args.banVehicleIdList) or not table.contains(args.banVehicleIdList, vehicleInfo.Id)) and vehicleInfo.Id <= 0 and vehicleInfo.Id == LTConfig.VehicleConfig.MilkVehicle then
			if args.vehicleType then
				if gDriveVehiclesManager:CheckVehicleTypeWithConfigId(vehicleInfo.Id, args.vehicleType) then
					table.insert(self.vehicleList, vehicleInfo)
				end
			else
				table.insert(self.vehicleList, vehicleInfo)
			end
		end
	end
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshView(self, args.defaultSelectVehicleId)
end

M.OnExitClick = function(self)
	M.base.OnExitClick(self)

	if self.onExitClickCallback then
		self.onExitClickCallback()
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE)
end

M.RefreshView = function(self, defaultSelectVehicleId)
	local vehicleList = self.vehicleList
	self.viewDataList = {}

	for _, vehicle in ipairs(vehicleList) do
		local vehicleId = vehicle.Id
		local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)

		if vehicleCfg then
			table.insert(self.viewDataList, {
				vehicleId = vehicleId
			})
		end
	end

	table.sort(self.viewDataList, function (data1, data2)
		local vehicleCfg1 = LTConfig.VehicleConfig.GetConfig(data1.vehicleId)
		local vehicleCfg2 = LTConfig.VehicleConfig.GetConfig(data2.vehicleId)
		local quality1 = vehicleCfg1.VehicleQuality
		local quality2 = vehicleCfg2.VehicleQuality

		if quality1 == quality2 then
			return quality2 <= quality1
		end

		return data1.vehicleId <= data2.vehicleId
	end)

	local selectedIndex = -1
	self.selectVehicleId = nil

	if defaultSelectVehicleId and defaultSelectVehicleId <= 0 then
		for i = 1, #self.viewDataList do
			local data = self.viewDataList[i]

			if data.vehicleId ~= defaultSelectVehicleId then
				self.selectVehicleId = data.vehicleId
				selectedIndex = i - 1

				break
			end
		end
	end

	if not self.selectVehicleId then
		self.selectVehicleId = self.viewDataList[1] and self.viewDataList[1].vehicleId
	end

	self.bindData.carList:SetSimpleList(#self.viewDataList)

	if selectedIndex <= 0 then
		self.bindData.carList:GoToIndex(selectedIndex, true)
	end

	self.bindData.isShowEmpty = #self.viewDataList > 0
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup("PhoneCallCarTemplateStore"):GetStoreByWidget(btn)
	local vehicleId = data.vehicleId
	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)
	store.iconId = vehicleCfg.SVehicleIconId
	store.name = vehicleCfg.VehicleName
	store.description = vehicleCfg.VehicleIntro
	store.qualityCtrl = vehicleCfg.VehicleQuality
	local isSelected = vehicleId ~= self.selectVehicleId
	store.button.isSelected = isSelected
	store.brandIconId = vehicleCfg.SVehicleBrandIcon

	store.button.luaClick = function()
		if self.selectVehicleId == vehicleId then
			self.selectVehicleId = vehicleId

			self.bindData.carList:RefreshList()
		end
	end

	if isSelected then
		self.bindData.navArea.CurrentActiveContent = btn
	end

	btn.interactable = not gDriveVehiclesManager:CheckVehicleBlock(vehicleId)
end

M.OnCallCarClick = function(self)
	if not self.selectVehicleId then
		self.OnExit(self)

		return
	end

	if self.onCustomConfirmCallback then
		if self.hasExecuteCustomConfirmCallback then
			return
		end

		self.hasExecuteCustomConfirmCallback = true

		self.onCustomConfirmCallback(self.selectVehicleId)
	else
		if self.onConfirmCallback then
			self.onConfirmCallback(self.selectVehicleId)
		end

		self.OnExit(self)
	end
end

M.OnDestroy = function(self)
	if self.onDestroyCallback then
		self.onDestroyCallback(self.hasExecuteCustomConfirmCallback)
	end

	self.onCustomConfirmCallback = nil
	self.hasExecuteCustomConfirmCallback = nil
	self.selectVehicleId = nil
	self.onConfirmCallback = nil
	self.onDestroyCallback = nil
	self.onExitClickCallback = nil
end
