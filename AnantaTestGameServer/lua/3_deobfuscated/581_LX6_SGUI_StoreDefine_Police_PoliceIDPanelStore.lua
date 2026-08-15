C_PoliceIDPanelStore = DefClass("C_PoliceIDPanelStore", C_PoliceIDPanelStore, C_StoreGroup)
GroupName2Class.PoliceIDPanelStore = C_PoliceIDPanelStore
local M = C_PoliceIDPanelStore
local AgentConfig = LTConfig.AgentConfig
local NpcInformationPortraitConfig = LTConfig.NpcInformationPortraitConfig

function M:ctor()
	self.FakeOptions = {
		Portrait = 1,
		id = 2
	}
end

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.Close)
	self.bindData.idCheckAskBtn.luaClick = self:CreateAction(self.OnIdCheckAskBtnClick)
	self.bindData.validCheckAskBtn.luaClick = self:CreateAction(self.OnValidCheckAskBtnClick)
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTagItem)
	self.panelId = nil
end

function M:ShowContent(unit, module)
	local component = module.Component
	local store = self.bindData
	local extraData = module.ClientExtraData
	local defaultCrimes = module.Crimes and module.Crimes:ToTable() or {}
	local fakeImagePath, fakeIdNumber = nil

	if extraData and extraData.fakeInfo and (extraData.fakeInfo.fakeImagePath ~= nil or extraData.fakeInfo.fakeIdNumber ~= nil) then
		fakeImagePath = extraData.fakeInfo.fakeImagePath
		fakeIdNumber = extraData.fakeInfo.fakeIdNumber
	elseif table.contains(defaultCrimes, LTConfig.PoliceFineConfig.FakeIdentity) then
		local fakeInfo = {}

		for i, option in pairs(self.FakeOptions) do
			if option == self.FakeOptions.Portrait then
				if false then
					local fakeModelId = unit.ClientData.AgentId

					while fakeModelId == unit.ClientData.AgentId do
						fakeModelId = AgentConfig.LoadAt(math.random(0, AgentConfig.count - 1)).Id
					end

					fakeImagePath = self:GetAvatarSavePath(fakeModelId)
					fakeInfo.fakeImagePath = fakeImagePath
				end
			elseif option == self.FakeOptions.id then
				local fakeBirthDay = self:GenerateRandomDate2(module.BirthDay)
				local fakeIdIssueDateDT = self:GenerateRandomDate2(module.IDIssueDate)
				fakeIdNumber = self:MakeIdNumber(component, fakeBirthDay, fakeIdIssueDateDT)
				fakeInfo.fakeIdNumber = fakeIdNumber
			end
		end

		if extraData then
			extraData.fakeInfo = fakeInfo
		else
			module.ClientExtraData = {
				fakeInfo = fakeInfo
			}
		end
	end

	local serious = 0

	if table.contains(defaultCrimes, LTConfig.PoliceFineConfig.FakeIdentity) then
		local cfg = LTConfig.PoliceFineConfig.GetConfig(LTConfig.PoliceFineConfig.FakeIdentity)

		if cfg.Factor >= 3 then
			serious = math.max(serious, 2)
		else
			serious = math.max(serious, 1)
		end
	end

	store.name = module.Name
	store.imagePath = fakeImagePath or self:GetAvatarSavePath(unit.ClientData.AgentId)
	local birthDay = module.BirthDay
	store.birthday = birthDay.Month .. "." .. birthDay.Day
	local age, job = self:GetNPCAgeAndJob(unit.ClientData.AgentId)
	store.sex = age
	local idIssueDate = module.IDIssueDate
	store.assignDate = idIssueDate.Month .. "." .. idIssueDate.Day

	if table.contains(defaultCrimes, LTConfig.PoliceFineConfig.IdentityExpired) then
		store.validDate = LTConfig.PoliceConfig.IdentityExpiredText
		store.validCheck = 1
		local cfg = LTConfig.PoliceFineConfig.GetConfig(LTConfig.PoliceFineConfig.IdentityExpired)

		if cfg.Factor >= 3 then
			serious = math.max(serious, 2)
		else
			serious = math.max(serious, 1)
		end
	else
		store.validDate = tostring(module.IdValidDate)
		store.validCheck = 0
	end

	if fakeIdNumber then
		store.idNumber = fakeIdNumber
		store.IDCheckCtrl = 1
	else
		store.idNumber = self:MakeIdNumber(component, birthDay, idIssueDate)
		store.IDCheckCtrl = 0
	end

	store.address = module.Address
	local list = {}
	local portraitCfg = NpcInformationPortraitConfig.GetConfig(component.Portrait)
	local portrait = ""

	if portraitCfg ~= nil then
		portrait = portraitCfg.Name
	end

	table.insert(list, {
		text = portrait
	})
	table.insert(list, {
		text = job
	})

	if module.CrimeRecord then
		local crimeRecordTable = module.CrimeRecord:ToTable()

		for i = 1, #crimeRecordTable do
			local crimeRecord = crimeRecordTable[i]
			local cfg = LTConfig.NpcInformationCriminalRecordConfig.GetConfig(crimeRecord)

			if cfg then
				local fineId = gPoliceJobManager.examineMgr.crimeType2Fine[cfg.Type]

				table.insert(list, {
					text = cfg.Name,
					isRed = cfg.Type ~= 0,
					fineId = fineId
				})
			end
		end
	end

	self.tagListData = list

	store.tagList:SetSimpleList(#self.tagListData)

	local suggestion = gPoliceJobManager.examineMgr:GetOptionResSuggestion(LTConfig.PoliceConfig.IdCheck)

	if suggestion then
		self.bindData.suggestCtrl = 1
		self.bindData.suggestText = suggestion
	else
		self.bindData.suggestCtrl = 0
	end

	local btn = nil

	if store.validCheck == 1 then
		btn = self.bindData.validCheckAskBtn
	elseif store.IDCheckCtrl == 1 then
		btn = self.bindData.idCheckAskBtn
	end

	if btn then
		FrameTimer.New(function ()
			btn:Focus()
		end, 1):Start()
	end
end

function M:SetCloseCallback(closeCallback)
	self.closeCallback = closeCallback
end

function M:Close()
	if self.panelId then
		gPanelManager:Close(self.panelId)

		return
	end

	if self.closeCallback then
		self.closeCallback()
	end

	self.rootWidget:SetActive(false)
end

function M:OnIdCheckAskBtnClick()
	gPoliceJobManager.examineMgr:ShowAiDialogByFineId(nil, LTConfig.PoliceFineConfig.FakeIdentity)
end

function M:OnValidCheckAskBtnClick()
	gPoliceJobManager.examineMgr:ShowAiDialogByFineId(nil, LTConfig.PoliceFineConfig.IdentityExpired)
end

function M:OnRenderTagItem(btn, index)
	local data = self.tagListData[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		store.text = gClientUtils.RichTextToPlain(data.text)
		store.isRed = data.isRed and 1 or 0
		store.askBtn.luaClick = self:CreateActionWithArgs(self.OnTagItemClick, data)
	end
end

function M:OnTagItemClick(data)
	if data.fineId and data.fineId > 0 then
		gPoliceJobManager.examineMgr:ShowAiDialogByFineId(nil, data.fineId)
	end
end

function M:MakeIdNumber(component, birthday, idIssueDate)
	return string.format("NVC%02d%02d%02d%02d", birthday.Month, birthday.Day, idIssueDate.Month, idIssueDate.Day)
end

function M:GenerateRandomDate2(skipDate)
	local dt = System.DateTime.New(2000, 1, 1)
	local randomDate = {
		Month = skipDate.Month,
		Day = skipDate.Day
	}

	while randomDate.Month == skipDate.Month and randomDate.Day == skipDate.Day do
		randomOffset = math.random(1, 366)
		randomDt = dt:AddDays(randomOffset - 1)
		randomDate.Month = randomDt.Month
		randomDate.Day = randomDt.Day
	end

	return randomDate
end

function M:GetAvatarSavePath(agentCfgId)
	local agentCfg = LTConfig.AgentConfig.GetConfig(agentCfgId)

	if not agentCfg or not agentCfg.HeadIcon then
		return 0
	end

	return agentCfg.HeadIcon
end

function M:GetNPCAgeAndJob(agentCfgId)
	local agentCfg = LTConfig.AgentConfig.GetConfig(agentCfgId)
	local age = 0
	local job = ""

	if agentCfg and agentCfg.Age then
		age = agentCfg.Age
	end

	if agentCfg and agentCfg.JobFakeTag then
		job = agentCfg.JobFakeTag
	end

	return age, job
end
