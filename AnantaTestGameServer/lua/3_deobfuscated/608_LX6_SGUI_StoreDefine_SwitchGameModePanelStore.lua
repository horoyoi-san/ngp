local EInvokeTime = SGUI.EInvokeTime
local TaskEventConfig = LTConfig.TaskEventConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local SettingsScriptFunc = require("LX6/GUI/Setting/SettingsScriptFunc")
C_SwitchGameModePanelStore = DefClass("C_SwitchGameModePanelStore", C_SwitchGameModePanelStore, C_StoreGroup)
GroupName2Class.SwitchGameModePanelStore = C_SwitchGameModePanelStore
local M = C_SwitchGameModePanelStore
local GAME_MODE = {
	STORY = 0,
	FREE = 1
}
local LAN2INPUT = {
	478,
	477,
	476
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local CLICK_ANI_TIME = 0.3

function M:ctor()
	self.msgEvents = {
		[gEventConstants.INIT_UI_COMPLETE] = self:CreateAction(self.OnInitUIComplete),
		[gEventConstants.ON_DISCONNECT] = self:CreateAction(self.OnDisconnected)
	}
	self.waitPlay = false
	self.inPlay = false
	self.playTimer = nil
	self.mgr = gLoginManager
end

function M:OnAwake()
	self.bindData.storeBtn.luaClick = self:CreateAction("OnClickStoreBtn")
	self.bindData.freeModeBtn.luaClick = self:CreateAction("OnClickFreeModeBtn")
	self.bindData.preLanBtn.luaClick = self:CreateActionWithArgs("OnSwitchLanguageStep", -1)
	self.bindData.nextLanBtn.luaClick = self:CreateActionWithArgs("OnSwitchLanguageStep", 1)
	self.bindData.freeModeBtn.luaSelectChanged = self:CreateActionWithArgs("OnSelected", GAME_MODE.FREE)
	self.bindData.storeBtn.luaSelectChanged = self:CreateActionWithArgs("OnSelected", GAME_MODE.STORY)
	self.bindData.freeModeBtn.luaHover = self:CreateActionWithArgs("OnHover", GAME_MODE.FREE)
	self.bindData.storeBtn.luaHover = self:CreateActionWithArgs("OnHover", GAME_MODE.STORY)
	self.bindData.skipBtn.luaClick = self:CreateAction("TGSSkip", self.mgr)
	self.bindData.backBtn.luaClick = self:CreateAction("TGSReset", self.mgr)
	self.bindData.startGameBtn.luaClick = self:CreateAction("OnClickStartGameBtn")
	self.bindData.serverBtn.luaClick = self:CreateAction("OpenSelectServerPanel", self.mgr)

	self:RegisterMessageEvents(self.msgEvents)

	self.isCreateRole = false
	self.mainEventFinish = false
	self.currentMode = GAME_MODE.STORY
	self.preBtn = nil
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnHover(index)
	local btn = index == GAME_MODE.FREE and self.bindData.freeModeBtn or self.bindData.storeBtn

	if self.preBtn then
		self.preBtn:SetSelected(false)
	end

	btn:SetSelected(true)
	btn:InvokeCallback(EInvokeTime.Selected)

	self.preBtn = btn

	self:OnSelected(index, true)
end

function M:OnSelected(index, selected)
	if selected then
		if index == GAME_MODE.FREE and self.bindData.locked == 1 then
			self.currentMode = index

			return
		end

		if self.currentMode ~= index and not self.inPlay then
			self.bindData.bindWidget:InvokeCallback(index == GAME_MODE.FREE and EInvokeTime.User1 or EInvokeTime.User2)
		end

		self.currentMode = index
	end
end

function M:OnShow(panelId, data)
	if table.isNilOrEmpty(data) or data.isFirst ~= false then
		self.mgr:Connect()
	end

	self.inEnterGame = false
	self.bindData.showServerBtn = BOOL2CTL[gCS.LoginManager.canSelectServer]

	self:OnHover(GAME_MODE.STORY)
	self:OnSwitchLanguageStep(0)
	LX6.Manager.GameQualitySettings.Instance:ApplySettings()
	self:OnDisplay()
end

function M:OnDisconnected()
	self.inEnterGame = false
	self.mgr.skipNext = false
end

function M:OnInitUIComplete()
	self.waitPlay = true

	self:OnDisplay()
end

function M:OnDisplay()
	if not self.waitPlay then
		return
	end

	self.bindData.locked = boolToNumber(gCS.LoginManager.isFirstLogin)

	if not gCS.LoginManager.isFirstLogin then
		self.bindData.bindWidget:InvokeCallback(EInvokeTime.User5)

		self.inPlay = true

		if self.playTimer then
			self.playTimer:Stop()

			self.playTimer = nil
		end

		self.playTimer = Timer.New(function ()
			self.inPlay = false
		end, 1.5):Start()
	end

	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User6)
end

function M:OnSetMainEventEnd()
	if self.inEnterGame then
		return
	end

	self.inEnterGame = true

	Timer.New(function ()
		if not self.mgr:CheckHasRole() then
			self.mgr:RegisterAfterCreateRole(self:CreateAction("OnSetMainEventEnd"))

			return
		end

		self.mgr:RequestEnterGame()
		gPopupPauseManager:PausePopup(gPopupPauseManager.PAUSE_REASON.TGS_MODE, LTConfig.PopupConfig.TgsDisableTime)
	end, CLICK_ANI_TIME):Start()
end

function M:OnClickStoreBtn()
	gCS.LoginManager:SetJumpToMainEvent(self:GetPreRaid())
	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User3)
	self:OnSetMainEventEnd()
end

function M:OnClickFreeModeBtn()
	if gCS.LoginManager.isFirstLogin then
		self.bindData.freeModeBtn:InvokeCallback(EInvokeTime.InvalidClick)

		return
	end

	gCS.LoginManager:SetJumpToMainEvent(-1)
	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User4)
	self:OnSetMainEventEnd()
end

function M:Clip(value, min, max)
	if value < min then
		return max
	elseif max < value then
		return min
	end

	return value
end

function M:OnSwitchLanguageStep(step)
	self.language = gUIUtils:GetLanguageIndex()
	self.language = self:Clip(self.language + step, 1, #ShezhiPanelConfig.LanguagesDisplay)

	if step ~= 0 then
		SettingsScriptFunc._RealSetLanguage(self.language)
	end

	local preLan = self:Clip(self.language - 1, 1, #ShezhiPanelConfig.LanguagesDisplay)
	local nextLan = self:Clip(self.language + 1, 1, #ShezhiPanelConfig.LanguagesDisplay)

	self.bindData.preLanBtn:SetPCKeyInfoTipNameId(LAN2INPUT[preLan])
	self.bindData.nextLanBtn:SetPCKeyInfoTipNameId(LAN2INPUT[nextLan])

	self.bindData.l18nLabel1 = InputButtonNameConfig.GetConfig(LAN2INPUT[preLan]).Name
	self.bindData.l18nLabel2 = InputButtonNameConfig.GetConfig(LAN2INPUT[nextLan]).Name
end

function M:OnClickStartGameBtn()
	if self.currentMode == GAME_MODE.FREE then
		self:OnClickFreeModeBtn()
	else
		self:OnClickStoreBtn()
	end
end

function M:GetPreRaid()
	local PreRaidCfg = TaskEventConfig.GetConfig(TaskEventConfig.PreRaid)
	local eventId = table.isNilOrEmpty(PreRaidCfg.NextEventIds) and 0 or PreRaidCfg.NextEventIds[1]
	local eCfg = TaskEventConfig.GetConfig(eventId)

	return eCfg and eventId or 0
end

function M:OnChangeServer(serverData)
	self.bindData.serverName = serverData.Name
end

function M:SetFullUI()
	return
end
