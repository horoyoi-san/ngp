-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerAPPBeginPanelStore.lua
-- Decompiled from: 02043_CleanerAPPBeginPanelStore.lua_d6ebd7e05103.luajit

C_CleanerAPPBeginPanelStore = DefClass("C_CleanerAPPBeginPanelStore", C_CleanerAPPBeginPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerAPPBeginPanelStore = C_CleanerAPPBeginPanelStore
local M = C_CleanerAPPBeginPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.startButton.luaClick = self.CreateAction(self, self.OnStartClick)
	self.bindData.logoutButton.luaClick = self.CreateAction(self, self.OnLogoutClick)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.NewJob_Control = {
		["2M\\x86\\xa4\\x8cC"] = 1,
		["T-s^"] = 0
	}
	self.animTimer = nil
	self.isContinue = false
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, self.OnJobChange)
	}
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	local avatarWidget = self.bindData.avatar

	gWasherManager.RefreshWasherAvatarView(avatarWidget, true)
	self.RefreshPanelView(self)
end

M.GetAnimTime = function(self)
	local clip = self.bindData.mainAnim:GetClip("S_Vx_CleanerAPPBeginPanel_open")

	return clip and clip.length or 0
end

M.RefreshPanelView = function(self)
	self.bindData.roleName = gClientUtils.GetCurrentSpiritDisplayName()
end

M.OnJobChange = function(self)
	self.RefreshPanelView(self)
end

M.RefreshJobTemplateView = function(self, btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)

	if targetJobId and targetJobId <= 0 then
		local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
		store.name = gClientUtils.GetCurrentSpiritDisplayName()
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
		slot4 = self.bindData.startButton.gameObject

		slot4:SetActive(false)

		store.button.luaClick = function()
			local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()

			if currentJobClassId == LTConfig.UrbanJobJobClassConfig.Washer then
				slot1 = gClientToGameDelegate

				slot1:AskTakeJob(LTConfig.UrbanJobJobClassConfig.Washer).Callback = function (errorId)
					if errorId == LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(errorId)

						return
					end
				end
			end
		end
	end
end

M.OnOccupationEntranceClick = function(self)
	if gClientUtils.NotNil(self.rootGo) then
		self.isContinue = true

		gMainPhoneFunctionAction.OpenWasher({
			secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.OCCUPATION
		})
	end
end

M.OpenWasher = function(self)
	if not self.isContinue and gClientUtils.NotNil(self.rootGo) then
		self.isContinue = true

		gMainPhoneFunctionAction.OpenWasher({
			secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.ORDER
		})
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end

M.OnStartClick = function(self)
	self.OpenWasher(self)
end

M.OnLogoutClick = function(self)
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextConfig.GetConfig(73970547).Text,
		onConfirmCallback = function ()
			local rootGo = self.rootGo
			slot1 = gClientToGameDelegate

			slot1:AskQuitJob(LTConfig.UrbanJobJobClassConfig.Washer).Callback = function (errorId)
				if errorId == LTConfig.MessageConfig.Ok then
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

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end
