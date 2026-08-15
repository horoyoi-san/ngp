C_DoctorGameplayPanelStore = DefClass("C_DoctorGameplayPanelStore", C_DoctorGameplayPanelStore, C_StoreGroup)
GroupName2Class.DoctorGameplayPanelStore = C_DoctorGameplayPanelStore
local M = C_DoctorGameplayPanelStore
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr

function M:ctor()
	self.QTE_CTRL = {
		FALSE = 0,
		TRUE = 1
	}
	self.CORE_LOOP_CTRL = {
		NORMAL = 0,
		ACTION = 1
	}
	self.EMOJI_CTRL = {
		FALSE = 0,
		TRUE = 1
	}
	self.treatEmojiShowTime = 0
end

function M:OnAwake()
	self.bindData.treatQTEBtn.luaClick = self:CreateAction(self.DoTreatQTEAction)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderDiseaseItem)
end

function M:OnStart()
	self.actionPanel = self.bindData.actionPanel
	self.actionPanelStore = gStoreManager:GetStoreGroup(self.actionPanel.Store)
end

function M:OnShow(panelId, data)
	gDoctorManager.panel = self
	self.isShow = true

	self:RefreshCureNum()
	self:ShowNormalContent()
	self:HideTreatQTE()

	self.bindData.emoji = self.EMOJI_CTRL.FALSE
	local store = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")

	if store and store.bindData.btnExit then
		store.bindData.btnExit:SetActive(true)
	end
end

function M:OnClose()
	self.isShow = false

	self:StopShowProgressTimer()

	self.diseases = nil
end

function M:EnableDoctorCamera()
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("DoctorGameplayPanel")

	if not cmRegister then
		return
	end

	local CameraPos = LTConfig.DoctorConfig.CameraPos
	local CameraRot = LTConfig.DoctorConfig.CameraRot
	local CameraFov = LTConfig.DoctorConfig.CameraFov
	local playerTrans = MyPlayerManager.PlayerUnit.PlayerObj
	local worldPos = playerTrans:TransformPoint(CameraPos.x, CameraPos.y, CameraPos.z)
	local dir = Quaternion.Euler(CameraRot.x, CameraRot.y, CameraRot.z) * Vector3.forward
	local worldEuler = Quaternion.LookRotation(playerTrans:TransformDirection(dir)).eulerAngles
	local cameraName = "FixCam1"
	local cm = cmRegister:GetVcamByName(cameraName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFixCameraData(cm.gameObject, worldPos, worldEuler, CameraFov)
	cmRegister:EnableVCamera(cameraName, LX6.Cinemachine.EVcamPriority.Panel)
end

function M:RefreshCureNum()
	self.bindData.cureNum = tostring(gDoctorManager.cureLimit - gDoctorManager.cureTimes)
end

function M:ShowSearchResult(closeCallback)
	gDoctorManager.IsCheckDisease = true

	gDoctorManager:SetPanelStage(gDoctorManager.PANEL_STAGE_TYPE.SEARCH)

	self.bindData.coreLoop = self.CORE_LOOP_CTRL.ACTION
	self.bindData.qte = self.QTE_CTRL.FALSE

	self.actionPanelStore:ShowSearchResult()
	self.actionPanelStore:SetCloseCallback(closeCallback)
end

function M:ShowTreatProcess(closeCallback)
	gDoctorManager:SetPanelStage(gDoctorManager.PANEL_STAGE_TYPE.TREAT)
	self.actionPanelStore:SetCloseCallback(closeCallback)
	self:StopShowProgressTimer()

	self.showProgressTimer = FrameTimer.New(function ()
		self:ShowTreatProcessInternal()

		self.showProgressTimer = nil
	end, 2):Start()
end

function M:StopShowProgressTimer()
	if self.showProgressTimer then
		self.showProgressTimer:Stop()

		self.showProgressTimer = nil
	end
end

function M:ShowTreatProcessInternal()
	self.bindData.coreLoop = self.CORE_LOOP_CTRL.ACTION
	self.bindData.qte = self.QTE_CTRL.FALSE

	self.actionPanelStore:ShowTreatProcess()
end

function M:ShowNormalContent()
	gDoctorManager:SetPanelStage(gDoctorManager.PANEL_STAGE_TYPE.NORMAL)

	self.bindData.coreLoop = self.CORE_LOOP_CTRL.NORMAL
	self.diseases = {}
	local suggestion = nil

	if gDoctorManager.IsCheckDisease then
		local showTreatment = gSpiritJobManager:CheckCurSpiritContainBadge(LTConfig.DoctorConfig.CheckCanFindTreatment)
		local treatments = {}
		local currentDiseases = gDoctorManager:GetCurrentDiseases()

		if currentDiseases then
			for id, _ in pairs(currentDiseases) do
				local cfg = LTConfig.DoctorDiseaseConfig.GetConfig(id)

				if cfg then
					local diseaseLabel = nil

					if showTreatment then
						diseaseLabel = cfg.Disease
					elseif cfg.Dialog and #cfg.Dialog > 0 then
						local dialogCfg = LTConfig.DialogConfig.GetConfig(cfg.Dialog[1])

						if dialogCfg then
							diseaseLabel = dialogCfg.Message
						end
					end

					if diseaseLabel then
						table.insert(self.diseases, {
							id = id,
							label = diseaseLabel
						})
					end

					if showTreatment then
						for j = 1, #cfg.TreatableTreatment do
							local treatment = cfg.TreatableTreatment[j]

							if gDoctorManager:IsTreatmentEnable(treatment) and not table.contains(treatments, treatment) then
								table.insert(treatments, treatment)
							end
						end
					end
				end
			end
		end

		local noDisease = #self.diseases == 0

		if noDisease then
			table.insert(self.diseases, {
				label = LTConfig.DoctorConfig.NoDiseaseStr
			})
		end

		if showTreatment then
			for i = 1, #treatments do
				local treatment = treatments[i]
				local cfg = LTConfig.DoctorTreatmentConfig.GetConfig(treatment)

				if cfg then
					if suggestion then
						suggestion = string.format("%s%s%s", suggestion, LTConfig.DoctorConfig.TreatmentLinkStr, cfg.TreatmentName)
					else
						suggestion = cfg.TreatmentName
					end
				end
			end
		end

		if not suggestion then
			suggestion = noDisease and LTConfig.DoctorConfig.NoDiseaseNoSuggestionStr or LTConfig.DoctorConfig.HasDiseaseNoSuggestionStr
		end
	else
		table.insert(self.diseases, {
			label = LTConfig.DoctorConfig.NeedCheckStr
		})

		suggestion = LTConfig.DoctorConfig.NeedCheckSuggestion
	end

	self.bindData.list:SetSimpleList(#self.diseases)

	self.bindData.suggestion = suggestion
end

function M:ShowTreatNormalContentAndEmoji()
	self:ShowNormalContent()
end

function M:ShowTreatResultInfo()
	local treatPercent = gDoctorManager:GetTreatPercent()
	local TreatmentPercent = LTConfig.DoctorConfig.TreatmentPercentDialog
	local dialogId = nil

	if treatPercent == 0 then
		dialogId = LTConfig.DoctorConfig.NoneTreatDialog
	else
		local percent = 0

		for i = 1, #TreatmentPercent do
			local data = TreatmentPercent[i]

			if treatPercent <= data.percent and percent < data.percent then
				dialogId = data.dialogId
				percent = data.percent
			end
		end
	end

	if dialogId then
		self.actionPanelStore:ShowTreatResult(dialogId)
		self.actionPanelStore:SetCloseCallback(function ()
			self:ShowNormalContent()
		end)
	end

	if gDoctorManager.isDebug then
		print_notice("Doctor ShowTreatNormalContentAndEmoji treatPercent " .. tostring(treatPercent))
	end
end

function M:ShowNormalEmoji()
	self.bindData.emoji = self.EMOJI_CTRL.TRUE
	local Index = gDoctorManager:GetCurrentDiseaseLevel() + 1
	local levelEmoji = LTConfig.DoctorConfig.EmojiList
	local iconId = 0

	if levelEmoji and #levelEmoji > 0 then
		if Index > #levelEmoji then
			iconId = levelEmoji[#levelEmoji]
		else
			iconId = levelEmoji[Index]
		end

		self.bindData.emojiIcon = iconId
	end

	if gDoctorManager.isDebug then
		print_notice("Doctor ShowNormalEmoji Level " .. tostring(Index - 1) .. " iconId " .. tostring(iconId))
	end
end

function M:InitEmojiContent()
	self.bindData.emoji = self.EMOJI_CTRL.TRUE
	self.emojiOffsetY = LTConfig.DoctorConfig.EmojiOffsetY
	self.emojiPoint = nil
	self.treatEmojiShowTime = 0

	if gDoctorManager.currentTreatPid then
		local unit = SceneDataMgr.GetUnit(gDoctorManager.currentTreatPid)

		if unit then
			self.emojiPoint = unit.ModelSlot.headSlot
		end
	end
end

function M:ShowTreatQTE()
	self.bindData.qteRoot:SetActive(true)
	self.bindData.treatQTEParticle:SetActive(true)
	self.bindData.treatQTEClickAnim:Stop()
	self.bindData.treatQTEMissAnim:Stop()

	if gDoctorManager.isDebug then
		print_notice("#DoctorManager QTE播放开始动效")
	end
end

function M:HideTreatQTE()
	self.bindData.qteRoot:SetActive(false)

	if gDoctorManager.isDebug then
		print_notice("#DoctorManager QTE隐藏")
	end
end

function M:TreatQTEActionSuccess()
	self.bindData.treatQTEMissAnim:Stop()
	self.bindData.treatQTEClickAnim:Stop()
	self.bindData.treatQTEClickAnim:Play()
	self.bindData.treatQTEParticle:SetActive(false)

	if gDoctorManager.isDebug then
		print_notice("#DoctorManager QTE播放成功动效")
	end
end

function M:TreatQTEActionFailed()
	self.bindData.treatQTEClickAnim:Stop()
	self.bindData.treatQTEMissAnim:Stop()
	self.bindData.treatQTEMissAnim:Play()
	self.bindData.treatQTEParticle:SetActive(false)

	if gDoctorManager.isDebug then
		print_notice("#DoctorManager QTE播放失败动效")
	end
end

function M:DoTreatQTEAction()
	gDoctorManager:OnQTEBtnClick()
end

function M:OnRenderDiseaseItem(btn, index)
	local data = self.diseases[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		store.text = data.label
	end
end
