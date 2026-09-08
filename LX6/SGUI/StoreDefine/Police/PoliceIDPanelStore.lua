-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Police\PoliceIDPanelStore.lua
-- Decompiled from: 01968_PoliceIDPanelStore.lua_cf1c1dfb39a3.luajit

C_PoliceIDPanelStore = DefClass("C_PoliceIDPanelStore", C_PoliceIDPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceIDPanelStore = C_PoliceIDPanelStore
local M = C_PoliceIDPanelStore
local AgentConfig = LTConfig.AgentConfig
local NpcInformationPortraitConfig = LTConfig.NpcInformationPortraitConfig

M.ctor = function(self)
	self.FakeOptions = {
		["\\x9b\\xbe\\xbfx?\\xf7'"] = 1,
		["\t\r"] = 2
	}
end

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.Close)
	self.bindData.idCheckAskBtn.luaClick = self.CreateAction(self, self.OnIdCheckAskBtnClick)
	self.bindData.validCheckAskBtn.luaClick = self.CreateAction(self, self.OnValidCheckAskBtnClick)
	self.bindData.tagList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTagItem)
	self.panelId = nil
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	local unit = args.unit
	local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)

	gPoliceJobManager.examineMgr:InitExamineData(unit)
	self:ShowContent(unit, module, true)
end

M.ShowContent = function(self, unit, module, directOpen)
	self.directOpen = directOpen
	local component = module.Component
	local store = self.bindData
	local extraData = module.ClientExtraData
	local defaultCrimes = module.Crimes and module.Crimes:ToTable() or {}
	local fakeImagePath, fakeIdNumber = nil

	if extraData and extraData.fakeInfo and (extraData.fakeInfo.fakeImagePath == nil or extraData.fakeInfo.fakeIdNumber == nil) then
		fakeImagePath = extraData.fakeInfo.fakeImagePath
		fakeIdNumber = extraData.fakeInfo.fakeIdNumber
	elseif table.contains(defaultCrimes, LTConfig.PoliceFineConfig.FakeIdentity) then
		local fakeInfo = {}

		for i, option in pairs(self.FakeOptions) do
			if option ~= self.FakeOptions.Portrait then
				if false then
					local fakeModelId = unit.ClientData.AgentId

					while fakeModelId ~= unit.ClientData.AgentId do
						fakeModelId = AgentConfig.LoadAt(math.random(0, AgentConfig.count - 1)).Id
					end

					fakeImagePath = self.GetAvatarSavePath(self, fakeModelId)
					fakeInfo.fakeImagePath = fakeImagePath
				end
			elseif option ~= self.FakeOptions.id then
				local fakeBirthDay = gPoliceJobManager.panelMgr:GenerateRandomDate2(module.BirthDay)
				local fakeIdIssueDateDT = gPoliceJobManager.panelMgr:GenerateRandomDate2(module.IDIssueDate)
				fakeIdNumber = gPoliceJobManager.panelMgr:MakeIdNumber(fakeBirthDay, fakeIdIssueDateDT)
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

		if cfg.Factor > 3 then
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

		if cfg.Factor > 3 then
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
		store.idNumber = gPoliceJobManager.panelMgr:MakeIdNumber(birthDay, idIssueDate)
		store.IDCheckCtrl = 0
	end

	store.address = module.Address
	local list = {}
	local portraitCfg = NpcInformationPortraitConfig.GetConfig(component.Portrait)
	local portrait = ""

	if portraitCfg == nil then
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
					isRed = cfg.Type == 0,
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

	if store.validCheck ~= 1 then
		btn = self.bindData.validCheckAskBtn
	elseif store.IDCheckCtrl ~= 1 then
		btn = self.bindData.idCheckAskBtn
	end

	if btn then
		FrameTimer.New(function ()
			btn:Focus()
		end, 1):Start()
	end
end

M.SetCloseCallback = function(self, closeCallback)
	self.closeCallback = closeCallback
end

M.Close = function(self)
	if self.directOpen then
		self.OnExit(self)

		return
	end

	if self.panelId then
		gPanelManager:Close(self.panelId)

		return
	end

	if self.closeCallback then
		self.closeCallback()
	end

	self.rootWidget:SetActive(false)
end

M.OnIdCheckAskBtnClick = function(self)
	gPoliceJobManager.examineMgr:ShowAiDialogByFineId(nil, LTConfig.PoliceFineConfig.FakeIdentity)
end

M.OnValidCheckAskBtnClick = function(self)
	gPoliceJobManager.examineMgr:ShowAiDialogByFineId(nil, LTConfig.PoliceFineConfig.IdentityExpired)
end

M.OnRenderTagItem = function(self, btn, index)
	local data = self.tagListData[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if store and data then
		store.text = gClientUtils.RichTextToPlain(data.text)
		store.isRed = data.isRed and 1 or 0
		store.askBtn.luaClick = self:CreateActionWithArgs(self.OnTagItemClick, data)
	end
end

M.OnTagItemClick = function(self, data)
	if data.fineId and data.fineId <= 0 then
		gPoliceJobManager.examineMgr:ShowAiDialogByFineId(nil, data.fineId)
	end
end

M.GetAvatarSavePath = function(self, agentCfgId)
	local agentCfg = LTConfig.AgentConfig.GetConfig(agentCfgId)

	if not agentCfg or not agentCfg.HeadIcon then
		return 0
	end

	return agentCfg.HeadIcon
end

M.GetNPCAgeAndJob = function(self, agentCfgId)
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

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end
