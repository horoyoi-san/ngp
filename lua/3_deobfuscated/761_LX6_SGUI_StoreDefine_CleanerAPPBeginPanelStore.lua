C_CleanerAPPBeginPanelStore = DefClass("C_CleanerAPPBeginPanelStore", C_CleanerAPPBeginPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerAPPBeginPanelStore = C_CleanerAPPBeginPanelStore
local M = C_CleanerAPPBeginPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.startButton.luaClick = self:CreateAction(self.OnStartClick)
	self.bindData.logoutButton.luaClick = self:CreateAction(self.OnLogoutClick)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.NewJob_Control = {
		NewJob = 1,
		None = 0
	}
	self.animTimer = nil
	self.isContinue = false
end

function M:GetMessageEvents()
	return {
		[gEventConstants.JOB_CHANGE_EVENT] = self:CreateAction(self.OnJobChange)
	}
end

function M:InitView(args)
	M.base.InitView(self, args)

	local avatarWidget = self.bindData.avatar

	gWasherManager.RefreshWasherAvatarView(avatarWidget, true)
	self:RefreshPanelView()
end

function M:GetAnimTime()
	local clip = self.bindData.mainAnim:GetClip("S_Vx_CleanerAPPBeginPanel_open")

	return clip and clip.length or 0
end

function M:RegisterAnimCallback(callback)
	if self.animTimer then
		self.animTimer:Stop()

		self.animTimer = nil

		print_error("C_CleanerAPPBeginPanelStore animTimer is not nil")
	end

	local animTime = self:GetAnimTime()
	self.animTimer = Timer.New(function ()
		self.animTimer = nil

		if callback then
			callback()
		end
	end, animTime):Start()
end

function M:RefreshPanelView()
	self.bindData.roleName = self:GetSpiritName()
end

function M:OnJobChange()
	self:RefreshPanelView()
end

function M:GetSpiritName()
	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	if currentSpiritId == LTConfig.FightSpiritConfig.DefaultMale or currentSpiritId == LTConfig.FightSpiritConfig.DefaultFemale then
		return gPlayerManager.infoLogin.bindData.name
	else
		local fightSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(currentSpiritId)

		return fightSpiritCfg.Name
	end
end

function M:RefreshJobTemplateView(btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)

	if targetJobId and targetJobId > 0 then
		local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
		store.name = self:GetSpiritName()
		store.jobName = urbanJobCfg.Name
		local targetJobInfo = gSpiritJobManager.GetCurSpiritJob(targetJobId)
		local registerTime = os.date("%Y.%m.%d", targetJobInfo.RegisterTime)
		store.time = LTConfig.TextScriptTextConfig.GetConfig(89901082).Text:format(registerTime)
		local levelCfg = gSpiritJobManager:GetLevelConfig(urbanJobCfg)
		local progress = targetJobInfo.Exp / levelCfg.Exp

		self.bindData.progress:ProgressToValue(progress)

		self.bindData.progressText = ("%d/%d"):format(targetJobInfo.Exp, levelCfg.Exp)

		gWasherManager.RefreshWasherAvatarView(store.avatar, false)

		self.bindData.newJobControl = self.NewJob_Control.None

		self.bindData.startButton.gameObject:SetActive(true)
	else
		self.bindData.newJobControl = self.NewJob_Control.NewJob

		self.bindData.startButton.gameObject:SetActive(false)

		function store.button.luaClick()
			local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()

			if currentJobClassId ~= LTConfig.UrbanJobJobClassConfig.Washer then
				gClientToGameDelegate:AskTakeJob(LTConfig.UrbanJobJobClassConfig.Washer).Callback = function (errorId)
					if errorId ~= LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(errorId)

						return
					end
				end
			end
		end
	end
end

function M:OnOccupationEntranceClick()
	if gClientUtils.NotNil(self.rootGo) then
		self.isContinue = true

		gMainPhoneFunctionAction.OpenWasher({
			secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.OCCUPATION
		})
	end
end

function M:OpenWasher()
	if not self.isContinue and gClientUtils.NotNil(self.rootGo) then
		self.isContinue = true

		gMainPhoneFunctionAction.OpenWasher({
			secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.ORDER
		})
	end
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end

function M:OnStartClick()
	self:OpenWasher()
end

function M:OnLogoutClick()
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextConfig.GetConfig(73970547).Text,
		onConfirmCallback = function ()
			local rootGo = self.rootGo

			gClientToGameDelegate:AskQuitJob(LTConfig.UrbanJobJobClassConfig.Washer).Callback = function (errorId)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end

				if gClientUtils.IsNil(rootGo) then
					return
				end

				self:OnExit()
			end
		end
	})
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end
