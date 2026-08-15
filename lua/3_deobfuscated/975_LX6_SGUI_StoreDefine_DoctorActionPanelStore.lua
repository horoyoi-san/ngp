C_DoctorActionPanelStore = DefClass("C_DoctorActionPanelStore", C_DoctorActionPanelStore, C_StoreGroup)
GroupName2Class.DoctorActionPanelStore = C_DoctorActionPanelStore
local M = C_DoctorActionPanelStore
local AnimationManager = LX6.Units.AnimationManager

function M:ctor()
	self.STEP_CTRL = {
		CHECK = 0,
		RESULT = 2,
		CURE = 1,
		CURE_RESULT = 3
	}
	self.animTime = 2
	self.curTime = 0
	self.needUpdate = false
end

function M:OnAwake()
	self.bindData.continueBtn.luaClick = self:CreateAction(self.OnContinueBtnClick)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderDiseaseItem)
end

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.closeCallback = data and data.closeCallback
end

function M:OnClose()
	self.diseaseInfo = nil
end

function M:OnUpdate()
	if self.needUpdate then
		local percent = AnimationManager.GetCurrentActionNormalizedTime(gCS.MyPlayerManager.PlayerUnit, 0)

		if gDoctorManager.showResPercent <= percent then
			self:TriggerWaitFunc()
		end

		self.bindData.fillImg.fillAmount = math.max(math.min(1, percent / 0.8))
	end
end

function M:ShowTreatResult(dialogId)
	self.bindData.step = self.STEP_CTRL.CURE_RESULT
	self.diseaseInfo = {}
	local dialogCfg = LTConfig.DialogConfig.GetConfig(dialogId)

	if dialogCfg then
		table.insert(self.diseaseInfo, {
			id = 0,
			label = dialogCfg.Message
		})
	end

	self.bindData.list:SetSimpleList(#self.diseaseInfo)
end

function M:ShowSearchResult()
	self.bindData.step = self.STEP_CTRL.CHECK
	local diseases = gDoctorManager:GetCurrentDiseases()
	local showDisease = gSpiritJobManager:CheckCurSpiritContainBadge(LTConfig.DoctorConfig.CheckCanFindTreatment)
	self.diseaseInfo = {}

	for id, _ in pairs(diseases) do
		local cfg = LTConfig.DoctorDiseaseConfig.GetConfig(id)

		if cfg then
			if showDisease then
				table.insert(self.diseaseInfo, {
					id = id,
					label = cfg.Disease
				})
			elseif cfg.Dialog and #cfg.Dialog > 0 then
				local dialogCfg = LTConfig.DialogConfig.GetConfig(cfg.Dialog[1])

				if dialogCfg then
					table.insert(self.diseaseInfo, {
						id = id,
						label = dialogCfg.Message
					})
				end
			end
		end
	end

	if #self.diseaseInfo == 0 then
		table.insert(self.diseaseInfo, {
			id = 0,
			label = LTConfig.DoctorConfig.NoSearchResStr
		})
	end

	self.bindData.list:SetSimpleList(#self.diseaseInfo)

	self.needUpdate = true
	self.curTime = 0
	self.bindData.fillImg.fillAmount = 0

	function self.waitFunc()
		self.bindData.step = self.STEP_CTRL.RESULT
	end
end

function M:ShowTreatProcess()
	self.bindData.step = self.STEP_CTRL.CURE
	self.needUpdate = true
	self.curTime = 0
	self.bindData.fillImg.fillAmount = 0

	function self.waitFunc()
		self:OnContinueBtnClick()
	end
end

function M:TriggerWaitFunc()
	if self.needUpdate then
		self.needUpdate = false

		if self.waitFunc then
			self.waitFunc()

			self.waitFunc = nil
		end
	end
end

function M:SetCloseCallback(callback)
	self.closeCallback = callback
end

function M:OnContinueBtnClick()
	if self.closeCallback then
		self.closeCallback()
	end
end

function M:OnRenderDiseaseItem(btn, index)
	local data = self.diseaseInfo[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		store.text = data.label
	end
end
