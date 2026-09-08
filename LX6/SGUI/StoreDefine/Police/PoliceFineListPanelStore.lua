-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Police\PoliceFineListPanelStore.lua
-- Decompiled from: 01965_PoliceFineListPanelStore.lua_b244bc1208ad.luajit

C_PoliceFineListPanelStore = DefClass("C_PoliceFineListPanelStore", C_PoliceFineListPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceFineListPanelStore = C_PoliceFineListPanelStore
local M = C_PoliceFineListPanelStore
local PoliceFineConfig = LTConfig.PoliceFineConfig

M.OnAwake = function(self)
	self.itemList = {}
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.Close)
	self.bindData.fineCarExit.luaClick = self.CreateAction(self, self.Close)
	self.bindData.submitBtn.luaClick = self.CreateAction(self, self.OnSubmitBtnClick)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnListItemClick)
end

M.OnShow = function(self, panelId, data)
	if data.isExamineCar then
		self.isExamineCar = true
	else
		self.isExamineCar = false
	end

	self.isConfirmed = false
	self.isTriggered = false

	self.EnableCamera(self)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	if args.isExamineCar then
		self.isExamineCar = true

		self:EnableCamera()
		self.bindData.fineCarExit.gameObject:SetActive(true)
	else
		self.isExamineCar = false

		self.bindData.fineCarExit.gameObject:SetActive(false)
	end

	self.isConfirmed = false
	self.isTriggered = false
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	if args.isExamineCar then
		self.ShowExamineCar(self, args.fineInfoDict, args.fineList)
	end

	self.SetupCamera(self)
end

M.OnClose = function(self)
	self.DisableCamera(self)

	self.itemList = nil
end

M.SetCloseCallback = function(self, closeCallback)
	self.closeCallback = closeCallback
end

M.Close = function(self)
	if self.closeCallback then
		self.closeCallback()
	end

	self.rootWidget:SetActive(false)

	if self.isExamineCar then
		if not self.isTriggered then
			self.isTriggered = true

			gPoliceJobManager.cs:TriggerExamineVehicleFineAction(self.isConfirmed, nil)
		end

		self.OnExit(self)
	end
end

M.OnSubmitBtnClick = function(self)
	local fineList = {}

	for id, _ in pairs(self.selectedFineItems) do
		table.insert(fineList, id)
	end

	if self.closeCallback then
		self.closeCallback(fineList)
	end

	if self.isExamineCar then
		self.isConfirmed = true

		if not self.isTriggered then
			self.isTriggered = true

			gPoliceJobManager.cs:TriggerExamineVehicleFineAction(self.isConfirmed, fineList)
		end

		self.OnExit(self)
	end
end

M.OnRenderItem = function(self, btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	btn.interactable = data.isFined ~= false
	data.checkBtn = store.checkBtn
	data.checkBtn.interactable = data.isFined ~= false
	store.text = data.text
	store.checkCtrl = data.check and 1 or 0

	store.checkBtn.luaClick = function()
		self:OnListItemClick(btn, index)
	end

	self:UpdateBtnSelect(btn, data)
end

M.UpdateBtnSelect = function(self, btn, data)
	if self.selectedFineItems[data.id] then
		btn:SetSelected(true)
		data.checkBtn:SetSelected(true)
	else
		btn:SetSelected(false)
		data.checkBtn:SetSelected(false)
	end
end

M.OnListItemClick = function(self, btn, index)
	local data = self.itemList[index + 1]

	if self.selectedFineItems[data.id] then
		self.selectedFineItems[data.id] = nil
		self.selectedFineItemsCount = self.selectedFineItemsCount - 1
	else
		self.selectedFineItems[data.id] = data.id
		self.selectedFineItemsCount = self.selectedFineItemsCount + 1
	end

	self.UpdateBtnSelect(self, btn, data)

	if self.haveFineTime then
		self.bindData.submitBtn.interactable = self.selectedFineItemsCount >= 0
	end
end

M.ClearData = function(self)
	if self.isExamineCar then
		if not self.isTriggered then
			self.isTriggered = true

			gPoliceJobManager.cs:TriggerExamineVehicleFineAction(self.isConfirmed, nil)
		end

		self.DisableCamera(self)
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.Show = function(self, fineTimes, fineInfoDict, fineList)
	local remainTimes = LTConfig.PoliceConfig.MaxFineTimes - fineTimes
	self.bindData.remainTimesText = gString.Format(LTConfig.PoliceConfig.MaxFineTimesText, remainTimes)
	self.haveFineTime = remainTimes == 0
	self.selectedFineItems = {}
	self.selectedFineItemsCount = 0
	self.bindData.submitBtn.interactable = false

	self:SetFineList(fineInfoDict, fineList)
end

M.SetFineList = function(self, fineInfoDict, fineList)
	table.clear(self.itemList)

	local count = LTConfig.PoliceFineConfig.count
	local jobId = 0
	local spirit = gSpiritManager:GetSpirit(gSpiritManager:GetCurFirstSpiritTid())

	if spirit then
		jobId = spirit.SpiritInfo.SpiritJobInfo.CurrentJob
	end

	for i = 0, count - 1 do
		local fineCfg = LTConfig.PoliceFineConfig.LoadAt(i)
		local canShowFine = false

		if self.isExamineCar then
			canShowFine = fineCfg.Type == PoliceFineConfig.TypeType.Npc
		else
			canShowFine = gPoliceJobManager.examineMgr:CanShowFine(fineCfg)
		end

		if canShowFine then
			local fineInfo = fineInfoDict and fineInfoDict[fineCfg.Id]
			local fined = fineInfo and fineInfo.isFined or false
			local isCheck = fineList and table.contains(fineList, fineCfg.Id)
			local canShow = true

			if fineCfg.Jobid and fineCfg.Jobid <= 0 then
				canShow = fineCfg.Jobid > jobId
			end

			if canShow then
				table.insert(self.itemList, {
					id = fineCfg.Id,
					text = fineCfg.Title,
					check = isCheck,
					isFined = fined,
					disabled = fined
				})
			end
		end
	end

	table.sort(self.itemList, function (a, b)
		if a.isFined == b.isFined then
			return a.isFined ~= false
		end

		return a.id <= b.id
	end)

	for i, v in ipairs(self.itemList) do
		v.index = i
	end

	self.bindData.list:SetSimpleList(#self.itemList)
end

M.ShowExamineCar = function(self, fineInfoDict, fineList)
	self.bindData.remainTimesText = ""
	self.haveFineTime = true
	self.selectedFineItems = {}
	self.selectedFineItemsCount = 0
	self.bindData.submitBtn.interactable = false

	self.SetFineList(self, fineInfoDict, fineList)
end

M.EnableCamera = function(self)
end

M.SetupCamera = function(self)
end

M.DisableCamera = function(self)
end
