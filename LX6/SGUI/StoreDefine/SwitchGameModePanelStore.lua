-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SwitchGameModePanelStore.lua
-- Decompiled from: 01305_SwitchGameModePanelStore.lua_c69fc7eb2fa7.luajit

local GestureEventListener = SGUI.EventSystems.GestureEventListener
local EInvokeTime = SGUI.EInvokeTime
local TaskEventConfig = LTConfig.TaskEventConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
local MessageConfig = LTConfig.MessageConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local SettingsScriptFunc = require("LX6/GUI/Setting/SettingsScriptFunc")
C_SwitchGameModePanelStore = DefClass("C_SwitchGameModePanelStore", C_SwitchGameModePanelStore, C_StoreGroup)
GroupName2Class.SwitchGameModePanelStore = C_SwitchGameModePanelStore
local M = C_SwitchGameModePanelStore
local GAME_MODE = {
	["~\\x9a\\x8d\\x9d\\x8f"] = 0,
	["\\X~"] = 1
}
local LAN2INPUT = {
	[1.0] = 478,
	[2.0] = 477
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local CLICK_ANI_TIME = 0.3

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.INIT_UI_COMPLETE] = self.CreateAction(self, self.OnInitUIComplete),
		[gEventConstants.ON_DISCONNECT] = self.CreateAction(self, self.OnDisconnected),
		[gEventConstants.LOGIN_SERVER_CHANGE] = self.CreateAction(self, self.OnChangeServer)
	}
	self.waitPlay = false
	self.inPlay = false
	self.playTimer = nil
	self.mgr = gLoginManager
end

M.OnAwake = function(self)
	self.bindData.storeBtn.luaClick = self.CreateAction(self, "OnClickStoreBtn")
	self.bindData.freeModeBtn.luaClick = self.CreateAction(self, "OnClickFreeModeBtn")
	self.bindData.preLanBtn.luaClick = self.CreateActionWithArgs(self, "OnSwitchLanguageStep", -1)
	self.bindData.nextLanBtn.luaClick = self.CreateActionWithArgs(self, "OnSwitchLanguageStep", 1)
	self.bindData.freeModeBtn.luaSelectChanged = self.CreateActionWithArgs(self, "OnSelected", GAME_MODE.FREE)
	self.bindData.storeBtn.luaSelectChanged = self.CreateActionWithArgs(self, "OnSelected", GAME_MODE.STORY)
	self.bindData.freeModeBtn.luaHover = self.CreateActionWithArgs(self, "OnHover", GAME_MODE.FREE)
	self.bindData.storeBtn.luaHover = self.CreateActionWithArgs(self, "OnHover", GAME_MODE.STORY)
	self.bindData.skipBtn.luaClick = self.CreateAction(self, "TGSSkip")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "TGSReset")
	self.bindData.startGameBtn.luaClick = self.CreateAction(self, "OnClickStartGameBtn")
	self.bindData.serverBtn.luaClick = self.CreateAction(self, "OpenSelectServerPanel", self.mgr)
	local freeBtnGesture = GestureEventListener.Get(self.bindData.freeModeBtn.gameObject)
	freeBtnGesture.onFourFingerStateChange = self.CreateAction(self, "OnFourFingerStateChange")

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		if self.bindData.storyMbBtn then
			self.bindData.storyMbBtn.luaClick = self.CreateAction(self, "OnClickStoryMbBtn")
		end

		if self.bindData.freeMbBtn then
			self.bindData.freeMbBtn.luaClick = self.CreateAction(self, "OnClickFreeMbBtn")
		end
	end

	self.RegisterMessageEvents(self, self.msgEvents)

	self.isCreateRole = false
	self.mainEventFinish = false
	self.currentMode = GAME_MODE.STORY
	self.mobileSelectedMode = nil
	self.preBtn = nil
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.SetButtonVisualSelected = function(self, index)
	local btn = index ~= GAME_MODE.FREE and self.bindData.freeModeBtn or self.bindData.storeBtn

	if self.preBtn then
		self.preBtn:SetSelected(false)
	end

	btn.SetSelected(btn, true)
	btn.InvokeCallback(btn, EInvokeTime.Selected)

	self.preBtn = btn
end

M.OnHover = function(self, index)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.SetButtonVisualSelected(self, index)
	self.OnSelected(self, index, true)
end

M.OnSelected = function(self, index, selected)
	if selected then
		if index ~= GAME_MODE.FREE and self.bindData.locked ~= 1 then
			self.currentMode = index

			return
		end

		if self.currentMode == index and not self.inPlay then
			self.bindData.bindWidget:InvokeCallback(index ~= GAME_MODE.FREE and EInvokeTime.User1 or EInvokeTime.User2)
		end

		self.currentMode = index
	end
end

M.OnShow = function(self, panelId, data)
	if self.ShouldUseFreshGamescomAccount(self, data) then
		self:PrepareFreshGamescomAccount(data)
		self.mgr:Connect()
	elseif self.mgr:IsGamescomDemo() then
		self.mgr:Connect()
	end

	self.inEnterGame = false
	self.bindData.showServerBtn = BOOL2CTL[gCS.LoginManager.canSelectServer]
	self.mobileSelectedMode = nil
	self.language = nil

	self:OnHover(GAME_MODE.STORY)
	self:OnSwitchLanguageStep(0)
	LX6.Manager.GameQualitySettings.Instance:ApplySettings()
	self:OnDisplay()
end

M.OnDisconnected = function(self)
	self.inEnterGame = false
	self.mgr.skipNext = false
end

M.OnInitUIComplete = function(self)
	self.waitPlay = true

	self.OnDisplay(self)
end

M.OnDisplay = function(self)
	if not self.waitPlay then
		return
	end

	self.bindData.locked = BOOL2CTL[gCS.LoginManager.isFirstLogin]

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

M.OnSetMainEventEnd = function(self)
	if self.inEnterGame then
		return
	end

	self.inEnterGame = true

	Timer.New(function ()
		if self.mgr:IsGamescomDemo() then
			gLoadingManager:PreShowLoading()
		end

		if not self.mgr:CheckHasRole() then
			self.mgr:RegisterAfterCreateRole(self:CreateAction("OnSetMainEventEnd"))

			self.inEnterGame = false

			self:CreateRoleForCurrentAccount()

			return
		end

		if gCS.NetworkManager:IsLoginConnected() then
			self.mgr:OnLogin()
		end

		gPopupPauseManager:PausePopup(gPopupPauseManager.PAUSE_REASON.TGS_MODE, LTConfig.PopupConfig.TgsDisableTime)
	end, CLICK_ANI_TIME):Start()
end

M.IsMobileSelectFirst = function(self, mode)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return false
	end

	if self.mobileSelectedMode == mode then
		self.SetButtonVisualSelected(self, mode)

		self.mobileSelectedMode = mode

		return true
	end

	return false
end

M.EnterStoryMode = function(self)
	local preRaidId = self.mgr:GetPreRaid()

	gCS.LoginManager:SetJumpToMainEvent(1, preRaidId)
	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User3)
	self:OnSetMainEventEnd()
end

M.EnterFreeMode = function(self)
	if gCS.LoginManager.isFirstLogin then
		local invalidBtn = self.bindData.freeMbBtn or self.bindData.freeModeBtn

		if invalidBtn then
			invalidBtn.InvokeCallback(invalidBtn, EInvokeTime.InvalidClick)
		end

		return
	end

	gCS.LoginManager:SetJumpToMainEvent(0, -1)
	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User4)
	self:OnSetMainEventEnd()
end

M.OnClickStoryMbBtn = function(self)
	self.SetButtonVisualSelected(self, GAME_MODE.STORY)
	self.OnSelected(self, GAME_MODE.STORY, true)
	self.EnterStoryMode(self)
end

M.OnClickFreeMbBtn = function(self)
	self.SetButtonVisualSelected(self, GAME_MODE.FREE)
	self.OnSelected(self, GAME_MODE.FREE, true)
	self.EnterFreeMode(self)
end

M.OnClickStoreBtn = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.SetButtonVisualSelected(self, GAME_MODE.STORY)

		return
	end

	if self.IsMobileSelectFirst(self, GAME_MODE.STORY) then
		return
	end

	self.EnterStoryMode(self)
end

M.OnClickFreeModeBtn = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.SetButtonVisualSelected(self, GAME_MODE.FREE)

		return
	end

	if self.IsMobileSelectFirst(self, GAME_MODE.FREE) then
		return
	end

	self.EnterFreeMode(self)
end

M.Clip = function(self, value, min, max)
	if value >= min then
		return max
	elseif max >= value then
		return min
	end

	return value
end

M.ShouldUseFreshGamescomAccount = function(self, data)
	return table.isNilOrEmpty(data) or data.isFirst == false
end

M.PrepareFreshGamescomAccount = function(self, data)
	if not self.ShouldUseFreshGamescomAccount(self, data) then
		return
	end

	self.mgr:SetEditorAccount(self.mgr:GenerateGamescomAccount())
end

M.CreateRoleForCurrentAccount = function(self)
	local cfg = NpcCultivationConfig.GetConfig(NpcCultivationConfig.DefaultMale)
	local userName = cfg and cfg.Name or ""

	return self.mgr:CreateRole(userName, UX.Game.SexType.Male, false, true)
end

M.GetLanguageInputNameId = function(self, languageIndex)
	return LAN2INPUT[languageIndex]
end

M.SetLanguageButtonTip = function(self, btn, nameId)
	if btn and nameId then
		btn.SetPCKeyInfoTipNameId(btn, nameId)
	end
end

M.GetLanguageLabel = function(self, nameId)
	if not nameId then
		return ""
	end

	local cfg = InputButtonNameConfig.GetConfig(nameId)

	return cfg and cfg.Name or ""
end

M.OnSwitchLanguageStep = function(self, step)
	if self.language ~= nil then
		self.language = gUIUtils:GetLanguageIndex()
	end

	local targetLang = self.Clip(self, self.language + step, 1, #LAN2INPUT)
	local preLan = self.Clip(self, targetLang - 1, 1, #LAN2INPUT)
	local nextLan = self.Clip(self, targetLang + 1, 1, #LAN2INPUT)

	if step == 0 then
		SettingsScriptFunc._RealSetLanguage(targetLang)
	end

	self.language = targetLang
	local preInputNameId = self:GetLanguageInputNameId(preLan)
	local nextInputNameId = self:GetLanguageInputNameId(nextLan)

	self:SetLanguageButtonTip(self.bindData.preLanBtn, preInputNameId)
	self:SetLanguageButtonTip(self.bindData.nextLanBtn, nextInputNameId)

	self.bindData.l18nLabel1 = self:GetLanguageLabel(preInputNameId)
	self.bindData.l18nLabel2 = self:GetLanguageLabel(nextInputNameId)
	local lanCount = #LAN2INPUT

	self.bindData.preLanBtn:SetActive(lanCount >= 2)
	self.bindData.nextLanBtn:SetActive(lanCount < 2)
end

M.OnClickStartGameBtn = function(self)
	if self.currentMode ~= GAME_MODE.FREE then
		self.EnterFreeMode(self)
	else
		self.EnterStoryMode(self)
	end
end

M.OnChangeServer = function(self, _, serverData)
	self.bindData.serverName = serverData.Name
end

M.TGSSkip = function(self)
	gCS.LoginManager.isFirstLogin = false
	self.bindData.locked = BOOL2CTL[gCS.LoginManager.isFirstLogin]
end

M.OnFourFingerStateChange = function(self, isFourFingers)
	if isFourFingers then
		self.TGSSkip(self)
	end
end

M.TGSReset = function(self)
	self.mgr:OpenSelectServerPanel()
end

M.SetFullUI = function(self)
end
