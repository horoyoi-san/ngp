-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UniqueSkillTaFeiStore.lua
-- Decompiled from: 01182_UniqueSkillTaFeiStore.lua_cb60e3bde776.luajit

local FightSpiritConfig = LTConfig.FightSpiritConfig
local HudDescConfig = LTConfig.HudDescConfig
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
C_UniqueSkillTaFeiStore = DefClass("C_UniqueSkillTaFeiStore", C_UniqueSkillTaFeiStore, C_StoreGroup)
GroupName2Class.UniqueSkillTaFeiStore = C_UniqueSkillTaFeiStore
local M = C_UniqueSkillTaFeiStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.started = false
	self.isDebug = false
	self.isMotoActive = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnStart = function(self)
	gBattleMgr.uniqueSkillTaFeiPanel = self
	self.started = true

	self.InitData(self)
	self.InitTipInfo(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.OnControllerSettingChange(self, _, gameProfile.isNewControllerSetting)
	end
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	gBattleMgr.uniqueSkillTaFeiPanel = nil
	self.started = nil

	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.InitTipInfo = function(self)
	gCoreHudTipManager:InitButtonInfoForTabRect(self.bindData.motoBtn, gCoreHudTipManager.btnInfoEnum.TaFeiMoto)
	gCoreHudTipManager:InitButtonInfoForTabRect(self.bindData.motoSpeedUpBtn, gCoreHudTipManager.btnInfoEnum.MotoDash)
	gCoreHudTipManager:InitButtonInfoForTabRect(self.bindData.motoLightBtn, gCoreHudTipManager.btnInfoEnum.MotoLight)
end

M.InitData = function(self)
	self.GetBtnBindData(self)
	self.BindBtnEvent(self)
	self.RegisterBtnAction(self)
end

M.GetBtnBindData = function(self)
	self.motoBtn = self.GetStoreByWidget(self, self.bindData.motoBtn)
	self.motoBtn.btnId = HudDescConfig.MOTO_BTN

	if self.bindData.motoSpeedUpBtn then
		self.motoSpeedUpBtn = self.GetStoreByWidget(self, self.bindData.motoSpeedUpBtn)
		self.motoSpeedUpBtn.btnId = HudDescConfig.MOTO_SPEED_UP_BTN
		self.motoSpeedUpBtn.multiBtn.luaPress = self.CreateAction(self, "OnMotoSpeedUpBtnBeginLongPress")
		self.motoSpeedUpBtn.multiBtn.luaRelease = self.CreateAction(self, "OnMotoSpeedUpBtnEndLongPress")
	end

	if self.bindData.motoLightBtn then
		self.motoLightBtn = self.GetStoreByWidget(self, self.bindData.motoLightBtn)
		self.motoLightBtn.btnId = HudDescConfig.MOTO_LIGHT_BTN
	end

	self.InitBtnStatus(self)
end

M.InitBtnStatus = function(self)
	gCoreHudUIManager:OnRefreshSkillBtn(gCoreHudUIManager.skillType.TaFeiMoto, true)
	gCoreHudUIManager:OnRefreshSkillBtn(gCoreHudUIManager.skillType.MotoDash, true)
	gCoreHudUIManager:OnRefreshSkillBtn(gCoreHudUIManager.skillType.MotoLight, true)
end

M.BindBtnEvent = function(self)
	self.bindData.motoBtn.luaBeginLongPress = self.CreateAction(self, "OnMotoBtnBeginLongPress")
	self.bindData.motoBtn.luaEndLongPress = self.CreateAction(self, "OnMotoBtnEndLongPress")

	if self.bindData.motoSpeedUpBtn then
		self.bindData.motoSpeedUpBtn.luaBeginLongPress = self:CreateAction("OnMotoSpeedUpBtnBeginLongPress")
		self.bindData.motoSpeedUpBtn.luaEndLongPress = self:CreateAction("OnMotoSpeedUpBtnEndLongPress")

		gCoreHudUIManager:SetupDragButtons(self.bindData, {
			"\\xea\\x95\\xe3/\\xe3\\xee\\xbd\\xfd\\xa04&"
		})
	end

	if self.bindData.motoLightBtn then
		self.bindData.motoLightBtn.luaClick = self.CreateAction(self, "OnClickMotoLightBtn")
	end
end

M.RegisterBtnAction = function(self)
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self.CreateAction(self, "OnSpiritChange"),
		[gEventConstants.WEAPON_LIST_CHANGED] = self.CreateAction(self, "OnSpiritWeaponChange"),
		[gEventConstants.PAOKU_STATE_CHANGE] = self.CreateAction(self, "OnParkourStateChange"),
		[gEventConstants.SETTING_CONTROLLER_TYPE_CHANGE] = self.CreateAction(self, "OnControllerSettingChange")
	}

	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)

	self.dataSetEvents = {
		{
			gMainMenuMgr.triggerDisableParkourUIVisiable,
			1,
			self.CreateAction(self, "OnTriggerPaoKuLimit")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.TaFeiMoto,
			self.CreateAction(self, "UpdateBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.MotoDash,
			self.CreateAction(self, "UpdateBtnState")
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.MotoLight,
			self.CreateAction(self, "UpdateBtnState")
		}
	}

	self.ClearDataSetEvents(self)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.CheckIsOnMoto = function(self)
	return gCS.MyPlayerManager.PlayerUnit:HasGameplayTag(LTConfig.GameplayTagParentConfig.Motion_Special_TafeiMoto)
end

M.OnMotoBtnBeginLongPress = function(self)
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.motoBtn)

	if self:CheckIsOnMoto() then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.TaFeiMotoLeave)
	else
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.TaFeiMotoEnter)
	end
end

M.OnMotoBtnEndLongPress = function(self)
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.motoBtn)
	gBattleMgr:UpHandlerMotoBtn()
end

M.OnSpiritChange = function(self)
	self.RefreshMotoBtnStatus(self)
end

M.OnSpiritWeaponChange = function(self)
	if not self.motoBtn or not gCS.MyPlayerManager.PlayerUnit or gCS.MyPlayerManager.PlayerUnit.ClientData.cardId == FightSpiritConfig.Taffy then
		return
	end

	self.RefreshMotoBtnStatus(self)
end

M.OnTriggerPaoKuLimit = function(self)
	self.RefreshMotoBtnStatus(self)
end

M.RefreshMotoBtnStatus = function(self)
	gCoreHudUIManager:AddDirtySkillType(gCoreHudUIManager.skillType.TaFeiMoto)
end

M.OnParkourStateChange = function(self)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("UniqueSkillTaFeiStore.RefreshMotoBtnStatus")
	end

	self.RefreshMotoBtnStatus(self)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.OnMotoSpeedUpBtnBeginLongPress = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.TaFeiMotoDash)
end

M.OnMotoSpeedUpBtnEndLongPress = function(self)
end

M.OnClickMotoLightBtn = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_TAFFY_LIGHT)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.OnControllerSettingChange = function(self, eventId, isNewSetting)
	self.bindData.ControllerSettingCtrl = isNewSetting and 0 or 1
end

M.UpdateBtnState = function(self, data)
	local skillType = data.key
	local state = data.value
	local btnStore, btn = nil

	if skillType ~= gCoreHudUIManager.skillType.TaFeiMoto then
		btnStore = self.motoBtn
		btn = self.bindData.motoBtn
	elseif skillType ~= gCoreHudUIManager.skillType.MotoDash then
		btnStore = self.motoSpeedUpBtn
		btn = self.bindData.motoSpeedUpBtn
	elseif skillType ~= gCoreHudUIManager.skillType.MotoLight then
		btnStore = self.motoLightBtn
		btn = self.bindData.motoLightBtn
	end

	if not btnStore or not btn then
		return
	end

	self.SetBtnVisible(self, btnStore, state[1])
	btn.SetActive(btn, state[2])
end

M.SetBtnState = function(self, btnStore, targetVisible, targetInteractable)
	if targetVisible ~= nil or targetInteractable ~= nil or not btnStore then
		return
	end

	local targetHideCtrl = targetVisible and 0 or 1

	if targetHideCtrl == btnStore.btnHideCtrl then
		self.SetBtnVisible(self, btnStore, targetVisible)
	end

	if targetInteractable == btnStore.interactable then
		self.SetBtnInteractable(self, btnStore, targetInteractable)
	end
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnInteractable = function(self, btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

M.SetBtnControl = function(self, btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end

M.Log = function(self, ...)
	if self.isDebug then
		print_debug("[UniqueSkillTaFeiStore]", ...)
	end
end
