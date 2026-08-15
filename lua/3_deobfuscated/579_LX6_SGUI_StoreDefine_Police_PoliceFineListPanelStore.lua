C_PoliceFineListPanelStore = DefClass("C_PoliceFineListPanelStore", C_PoliceFineListPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceFineListPanelStore = C_PoliceFineListPanelStore
local M = C_PoliceFineListPanelStore
local PoliceFineConfig = LTConfig.PoliceFineConfig

function M:OnAwake()
	self.itemList = {}
	self.bindData.exitBtn.luaClick = self:CreateAction(self.Close)
	self.bindData.fineCarExit.luaClick = self:CreateAction(self.Close)
	self.bindData.submitBtn.luaClick = self:CreateAction(self.OnSubmitBtnClick)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.list.luaSimpleClick = self:CreateAction(self.OnListItemClick)
end

function M:OnShow(panelId, data)
	if data.isExamineCar then
		self.isExamineCar = true
	else
		self.isExamineCar = false
	end

	self.isConfirmed = false
	self.isTriggered = false

	self:EnableCamera()
end

function M:InitModel(args)
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

function M:InitView(args)
	M.base.InitView(self, args)

	if args.isExamineCar then
		self:ShowExamineCar(args.fineInfoDict, args.fineList)
	end

	self:SetupCamera()
end

function M:OnClose()
	self:DisableCamera()

	self.itemList = nil
end

function M:SetCloseCallback(closeCallback)
	self.closeCallback = closeCallback
end

function M:Close()
	if self.closeCallback then
		self.closeCallback()
	end

	self.rootWidget:SetActive(false)

	if self.isExamineCar then
		if not self.isTriggered then
			self.isTriggered = true

			gPoliceJobManager.cs:TriggerExamineVehicleFineAction(self.isConfirmed, nil)
		end

		self:OnExit()
	end
end

function M:OnSubmitBtnClick()
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

		self:OnExit()
	end
end

function M:OnRenderItem(btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	btn.interactable = data.isFined == false
	data.checkBtn = store.checkBtn
	data.checkBtn.interactable = data.isFined == false
	store.text = data.text
	store.checkCtrl = data.check and 1 or 0

	function store.checkBtn.luaClick()
		self:OnListItemClick(btn, index)
	end

	self:UpdateBtnSelect(btn, data)
end

function M:UpdateBtnSelect(btn, data)
	if self.selectedFineItems[data.id] then
		btn:SetSelected(true)
		data.checkBtn:SetSelected(true)
	else
		btn:SetSelected(false)
		data.checkBtn:SetSelected(false)
	end
end

function M:OnListItemClick(btn, index)
	local data = self.itemList[index + 1]

	if self.selectedFineItems[data.id] then
		self.selectedFineItems[data.id] = nil
		self.selectedFineItemsCount = self.selectedFineItemsCount - 1
	else
		self.selectedFineItems[data.id] = data.id
		self.selectedFineItemsCount = self.selectedFineItemsCount + 1
	end

	self:UpdateBtnSelect(btn, data)

	if self.haveFineTime then
		self.bindData.submitBtn.interactable = self.selectedFineItemsCount > 0
	end
end

function M:ClearData()
	if self.isExamineCar then
		if not self.isTriggered then
			self.isTriggered = true

			gPoliceJobManager.cs:TriggerExamineVehicleFineAction(self.isConfirmed, nil)
		end

		self:DisableCamera()
	end
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:Show(fineTimes, fineInfoDict, fineList)
	local remainTimes = LTConfig.PoliceConfig.MaxFineTimes - fineTimes
	self.bindData.remainTimesText = gString.Format(LTConfig.PoliceConfig.MaxFineTimesText, remainTimes)
	self.haveFineTime = remainTimes ~= 0
	self.selectedFineItems = {}
	self.selectedFineItemsCount = 0
	self.bindData.submitBtn.interactable = false

	self:SetFineList(fineInfoDict, fineList)
end

function M:SetFineList(fineInfoDict, fineList)
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
			canShowFine = fineCfg.Type ~= PoliceFineConfig.TypeType.Npc
		else
			canShowFine = gPoliceJobManager.examineMgr:CanShowFine(fineCfg)
		end

		if canShowFine then
			local fineInfo = fineInfoDict and fineInfoDict[fineCfg.Id]
			local fined = fineInfo and fineInfo.isFined or false
			local isCheck = fineList and table.contains(fineList, fineCfg.Id)
			local canShow = true

			if fineCfg.Jobid and fineCfg.Jobid > 0 then
				canShow = fineCfg.Jobid <= jobId
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
		if a.isFined ~= b.isFined then
			return a.isFined == false
		end

		return a.id < b.id
	end)

	for i, v in ipairs(self.itemList) do
		v.index = i
	end

	self.bindData.list:SetSimpleList(#self.itemList)
end

function M:ShowExamineCar(fineInfoDict, fineList)
	self.bindData.remainTimesText = ""
	self.haveFineTime = true
	self.selectedFineItems = {}
	self.selectedFineItemsCount = 0
	self.bindData.submitBtn.interactable = false

	self:SetFineList(fineInfoDict, fineList)
end

function M:EnableCamera()
	return
end

function M:SetupCamera()
	return
end

function M:DisableCamera()
	return
end
