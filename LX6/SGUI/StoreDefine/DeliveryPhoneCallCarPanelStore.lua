-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryPhoneCallCarPanelStore.lua
-- Decompiled from: 01974_DeliveryPhoneCallCarPanelStore.lua_217887c314e0.luajit

C_DeliveryPhoneCallCarPanelStore = DefClass("C_DeliveryPhoneCallCarPanelStore", C_DeliveryPhoneCallCarPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryPhoneCallCarPanelStore = C_DeliveryPhoneCallCarPanelStore
local M = C_DeliveryPhoneCallCarPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.chooseButton.luaClick = self:CreateAction(self.OnCallCarClick)
	self.bindData.carList.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)

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
	self.supportConfig = args.supportConfig
	self.defaultSelectedVehicleId = args.clientTruckOrderView.DefaultVehicleId
	self.vehicleList = {}
	self.selectVehicleId = nil
	local defaultVehicleId = self.supportConfig and self.supportConfig.vehicleId

	if defaultVehicleId then
		local lastQuality = 99999
		local defaultSelectedVehicleIdValid = false

		for _, vehicleInfo in ipairs(unlockedVehicles) do
			if vehicleInfo.Id <= 0 and table.contains(defaultVehicleId, vehicleInfo.Id) then
				local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleInfo.Id)

				if vehicleCfg.VehicleQuality >= lastQuality then
					self.selectVehicleId = vehicleInfo.Id
					lastQuality = vehicleCfg.VehicleQuality
				end

				if self.defaultSelectedVehicleId ~= vehicleInfo.Id then
					defaultSelectedVehicleIdValid = true
				end

				table.insert(self.vehicleList, vehicleInfo)
			end
		end

		if defaultSelectedVehicleIdValid then
			self.selectVehicleId = self.defaultSelectedVehicleId
		end
	end
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshView(self)
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

M.RefreshView = function(self)
	local vehicleList = self.vehicleList
	self.viewDataList = {}

	for _, vehicle in ipairs(vehicleList) do
		local vehicleId = vehicle.Id

		table.insert(self.viewDataList, {
			vehicleId = vehicleId
		})
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

	if self.selectVehicleId and self.selectVehicleId <= 0 then
		for i = 1, #self.viewDataList do
			local data = self.viewDataList[i]

			if data.vehicleId ~= self.selectVehicleId then
				selectedIndex = i - 1

				break
			end
		end
	else
		self.selectVehicleId = self.viewDataList[1] and self.viewDataList[1].vehicleId
	end

	self.bindData.carList:SetSimpleList(#self.viewDataList)
	self.bindData.carList:GoToIndex(selectedIndex, true)

	self.bindData.isShowEmpty = #self.viewDataList > 0
end

M.OnRenderItem = function(self, btn, index)
	local data = self.viewDataList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("DeliveryPhoneCallCarTemplateStore"):GetStoreByWidget(btn)
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

	store.vehicleSelectBtn.luaClick = function()
		if self.defaultSelectedVehicleId == vehicleId then
			gClientToGameDelegate:AskSetTruckJobDefaultVehicleId(vehicleId).Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				if gClientUtils.NotNil(self.rootGo) then
					self.defaultSelectedVehicleId = vehicleId
					self.selectVehicleId = vehicleId

					self:RefreshView()
					gMessageManager:SendMessage(gEventConstants.DELIVERY_DEFAULT_VEHICLE_CHANGED, vehicleId)
				end
			end
		end
	end

	if isSelected then
		self.bindData.navArea.CurrentActiveContent = btn
	end

	store.vehicleSelect = self.defaultSelectedVehicleId ~= vehicleId and 1 or 0
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
	self.viewDataList = nil
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end
