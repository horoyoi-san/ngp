C_DeliveryPhoneCallCarPanelStore = DefClass("C_DeliveryPhoneCallCarPanelStore", C_DeliveryPhoneCallCarPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryPhoneCallCarPanelStore = C_DeliveryPhoneCallCarPanelStore
local M = C_DeliveryPhoneCallCarPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.chooseButton.luaClick = self:CreateAction(self.OnCallCarClick)
	self.bindData.carList.luaRenderItem = self:CreateAction(self.OnRenderItem)

	local function frameFunc()
		if gClientUtils.NotNil(self.bindData.navArea) then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navArea
		end
	end

	FrameTimer.New(frameFunc, 2):Start()
end

function M:GetMessageEvents()
	return {
		[gEventConstants.MULTI_DIALOG_MOVE_STATUS] = function (_, value)
			if value == 1 then
				self:OnExit()
			end
		end
	}
end

function M:InitModel(args)
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
			if vehicleInfo.Id > 0 and table.contains(defaultVehicleId, vehicleInfo.Id) then
				local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleInfo.Id)

				if vehicleCfg.VehicleQuality < lastQuality then
					self.selectVehicleId = vehicleInfo.Id
					lastQuality = vehicleCfg.VehicleQuality
				end

				if self.defaultSelectedVehicleId == vehicleInfo.Id then
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

function M:InitView(args)
	M.base.InitView(self, args)
	self:RefreshView()
end

function M:OnExitClick()
	M.base.OnExitClick(self)

	if self.onExitClickCallback then
		self.onExitClickCallback()
	end
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE)
end

function M:RefreshView()
	local vehicleList = self.vehicleList
	local viewDataList = {}

	for _, vehicle in ipairs(vehicleList) do
		local vehicleId = vehicle.Id

		table.insert(viewDataList, {
			vehicleId = vehicleId
		})
	end

	table.sort(viewDataList, function (data1, data2)
		local vehicleCfg1 = LTConfig.VehicleConfig.GetConfig(data1.vehicleId)
		local vehicleCfg2 = LTConfig.VehicleConfig.GetConfig(data2.vehicleId)
		local quality1 = vehicleCfg1.VehicleQuality
		local quality2 = vehicleCfg2.VehicleQuality

		if quality1 ~= quality2 then
			return quality2 < quality1
		end

		return data1.vehicleId < data2.vehicleId
	end)

	local selectedIndex = -1

	if self.selectVehicleId and self.selectVehicleId > 0 then
		for i = 1, #viewDataList do
			local data = viewDataList[i]

			if data.vehicleId == self.selectVehicleId then
				selectedIndex = i - 1

				break
			end
		end
	else
		self.selectVehicleId = viewDataList[1] and viewDataList[1].vehicleId
	end

	self.bindData.carList:SetList(viewDataList)
	self.bindData.carList:GoToIndex(selectedIndex, true)

	self.bindData.isShowEmpty = #viewDataList <= 0
end

function M:OnRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("DeliveryPhoneCallCarTemplateStore"):GetStoreByWidget(btn)
	local vehicleId = data.vehicleId
	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)
	store.iconId = vehicleCfg.SVehicleIconId
	store.name = vehicleCfg.VehicleName
	store.description = vehicleCfg.VehicleIntro
	store.qualityCtrl = vehicleCfg.VehicleQuality
	local isSelected = vehicleId == self.selectVehicleId
	store.button.isSelected = isSelected
	store.brandIconId = vehicleCfg.SVehicleBrandIcon

	function store.button.luaClick()
		if self.selectVehicleId ~= vehicleId then
			self.selectVehicleId = vehicleId

			self.bindData.carList:RefreshList()
		end
	end

	function store.vehicleSelectBtn.luaClick()
		if self.defaultSelectedVehicleId ~= vehicleId then
			gClientToGameDelegate:AskSetTruckJobDefaultVehicleId(vehicleId).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
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

	store.vehicleSelect = self.defaultSelectedVehicleId == vehicleId and 1 or 0
end

function M:OnCallCarClick()
	if not self.selectVehicleId then
		self:OnExit()

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

		self:OnExit()
	end
end

function M:OnDestroy()
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

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end
