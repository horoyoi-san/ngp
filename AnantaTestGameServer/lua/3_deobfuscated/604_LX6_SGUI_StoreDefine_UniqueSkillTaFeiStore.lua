local FightSpiritConfig = LTConfig.FightSpiritConfig
local HudDescConfig = LTConfig.HudDescConfig
local ButtonInfoEnum = LX6.Units.Module.ButtonInfoEnum
local DataSet = require("LX6/DataBind/DataSet")
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
C_UniqueSkillTaFeiStore = DefClass("C_UniqueSkillTaFeiStore", C_UniqueSkillTaFeiStore, C_StoreGroup)
GroupName2Class.UniqueSkillTaFeiStore = C_UniqueSkillTaFeiStore
local M = C_UniqueSkillTaFeiStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.started = false
	self.isDebug = false
	self.curBtnState = {
		interactable = false,
		isFinal = false,
		reason = "Default Button State",
		visible = false
	}
	self.motoSpeedUpState = {
		specialReplace = true,
		isTaffyMotoOn = false
	}
	self.motoSpeedUpDecisions = {
		{
			func = ""
		},
		{
			func = "DecideSkill_Trigger",
			type = LX6.PaoKu.FightLimitType.dodge
		},
		{
			func = "DecideMotoSpeedUp_TaffyMoto"
		},
		{
			type = "Dodge",
			func = "DecideSkill_Parkour"
		},
		{
			func = ""
		}
	}
	self.buttonStateMonitor = DataSet.New({
		MotoSpeedUp = {
			false,
			false
		}
	})
	self.btnStore = {
		MotoSpeedUp = "motoSpeedUpBtn"
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

function M:OnStart()
	gBattleMgr.uniqueSkillTaFeiPanel = self
	self.started = true

	self:InitData()
	gMainMenuMgr:InitButtonInfoForTabRect(self.bindData.motoBtn, ButtonInfoEnum.TaFeiMoto)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:OnControllerSettingChange(_, gameProfile.isNewControllerSetting)
	end
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	gBattleMgr.uniqueSkillTaFeiPanel = nil
	self.started = nil

	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:InitData()
	self:GetBtnBindData()
	self:BindBtnEvent()
	self:RegisterBtnAction()
end

function M:GetBtnBindData()
	self.motoBtn = self:GetStoreByWidget(self.bindData.motoBtn)
	self.motoBtn.btnId = HudDescConfig.MOTO_BTN

	self:RefreshMotoBtnStatus()

	self.motoSpeedUpBtn = self:GetStoreByWidget(self.bindData.motoSpeedUpBtn)
	self.motoSpeedUpBtn.btnId = HudDescConfig.MOTO_SPEED_UP_BTN
	self.motoSpeedUpBtn.multiBtn.luaClick = self:CreateAction("OnMotoSpeedUpBtnBeginLongPress")
	self.motoSpeedUpBtn.multiBtn.luaRelease = self:CreateAction("OnMotoSpeedUpBtnEndLongPress")

	self:OnRefreshButton("MotoSpeedUp")
end

function M:BindBtnEvent()
	self.bindData.motoBtn.luaBeginLongPress = self:CreateAction("OnMotoBtnBeginLongPress")
	self.bindData.motoBtn.luaEndLongPress = self:CreateAction("OnMotoBtnEndLongPress")

	if self.bindData.motoSpeedUpBtn then
		self.bindData.motoSpeedUpBtn.luaBeginLongPress = self:CreateAction("OnMotoSpeedUpBtnBeginLongPress")
		self.bindData.motoSpeedUpBtn.luaEndLongPress = self:CreateAction("OnMotoSpeedUpBtnEndLongPress")
	end
end

function M:RegisterBtnAction()
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self:CreateAction("OnSpiritChange"),
		[gEventConstants.WEAPON_LIST_CHANGED] = self:CreateAction("OnSpiritWeaponChange"),
		[gEventConstants.PAOKU_STATE_CHANGE] = self:CreateAction("OnParkourStateChange"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("OnSystemUnlock"),
		[gEventConstants.ON_TAFFY_MOTO] = self:CreateAction("OnRefreshMotoState"),
		[gEventConstants.SETTING_CONTROLLER_TYPE_CHANGE] = self:CreateAction("OnControllerSettingChange"),
		[gEventConstants.ON_TAFFY_FIGHT_LIMIT] = self:CreateAction("OnFightLimitChange")
	}

	self:ClearMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)

	self.dataSetEvents = {
		{
			gMainMenuMgr.triggerDisableParkourUIVisiable,
			1,
			self:CreateAction("OnTriggerPaoKuLimit")
		}
	}

	self:ClearDataSetEvents()
	self:RegisterDataSetEvents(self.dataSetEvents)
end

function M:OnMotoBtnBeginLongPress()
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.motoBtn)
	gBattleMgr:DownHandlerMotoBtn()
end

function M:OnMotoBtnEndLongPress()
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.motoBtn)
	gBattleMgr:UpHandlerMotoBtn()
end

function M:OnSpiritChange()
	self:RefreshMotoBtnStatus()
end

function M:OnSpiritWeaponChange()
	if not self.motoBtn or not gCS.MyPlayerManager.PlayerUnit or gCS.MyPlayerManager.PlayerUnit.ClientData.cardId ~= FightSpiritConfig.Taffy then
		return
	end

	self:RefreshMotoBtnStatus()
end

function M:OnSystemUnlock()
	self:RefreshMotoBtnStatus()
end

function M:OnTriggerPaoKuLimit()
	self:RefreshMotoBtnStatus()
	self:OnRefreshButton("MotoSpeedUp")
end

function M:RefreshMotoBtnStatus()
	local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

	if not myPlayerCSUnit or not self.started or not self.motoBtn then
		return
	end

	local isTaffi = myPlayerCSUnit.ClientData.cardId == FightSpiritConfig.Taffy
	local isPaokuLimit = gPaokuLimitManager:CheckNeedLimit(LX6.PaoKu.PaokuLimitType.moto)
	local isFightLimit = gPaokuLimitManager:CheckFightNeedLimit(LX6.PaoKu.FightLimitType.all)
	local show = isTaffi and (gCS.WeaponMgr:HasWeapon(98003021) or gCS.WeaponMgr:HasWeapon(98003022) or gCS.WeaponMgr:HasWeapon(98003023))
	show = show and not isPaokuLimit and not isFightLimit
	local visible = self.parkourStateVisible and not gCS.LuaUtils.IsNonMobileAdaptive()
	self.motoBtn.btnHideCtrl = visible and 0 or 1
	local unlock = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.TafeiMoto)
	local interactable = self.parkourStateInteractable and show and unlock

	self.bindData.motoBtn:SetActive(interactable)
end

function M:OnParkourStateChange()
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("UniqueSkillTaFeiStore.PreCalc")
	end

	self.parkourStateVisible = true
	self.parkourStateInteractable = true
	local platform = gCS.LuaUtils.IsNonMobileAdaptive() and gBattleMgr.scheme == SGUI.GameDevice.KeyboardMouse and 1 or 2

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		local motoConfig = gMainMenuMgr.clientStateConfig[state].TaFeiMoto

		if type(motoConfig) == "table" and motoConfig[platform] and not motoConfig[platform].visible and not motoConfig[platform].interactable then
			self.parkourStateVisible = motoConfig[platform].visible
			self.parkourStateInteractable = motoConfig[platform].interactable
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
		gCS.LuaUtils.BeginSample("UniqueSkillTaFeiStore.RefreshMotoBtnStatus")
	end

	self:RefreshMotoBtnStatus()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:OnFightLimitChange()
	self:RefreshMotoBtnStatus()
end

function M:OnMotoSpeedUpBtnBeginLongPress()
	gBattleMgr:OnDodgeBtnPressFunc()
end

function M:OnMotoSpeedUpBtnEndLongPress()
	gBattleMgr:OnDodgeBtnReleaseFunc()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	return
end

function M:OnRefreshMotoState(eventId, isOnMoto)
	self:OnRefreshButton("MotoSpeedUp")

	self.bindData.motoIcon = isOnMoto and gCoreHudImgManager.imgOnTafeiMoto or gCoreHudImgManager.imgOffTafeiMoto
	self.bindData.motoVxIcon = isOnMoto and gCoreHudImgManager.imgOnTafeiMoto or gCoreHudImgManager.imgOffTafeiMoto
end

function M:OnControllerSettingChange(eventId, isNewSetting)
	self.bindData.ControllerSettingCtrl = isNewSetting and 0 or 1
end

function M:OnRefreshButton(buttonType)
	local decisions = self.motoSpeedUpDecisions
	self.curVisible = true
	self.curInteractable = true

	for i = 1, #decisions do
		if decisions[i] and decisions[i].func then
			if self[decisions[i].func] then
				local result = nil

				if decisions[i].type then
					result = self[decisions[i].func](self, decisions[i].type)
				else
					result = self[decisions[i].func](self)
				end

				if not result or result.visible == nil or result.interactable == nil then
					self:Log("[OnRefreshMotoSpeedUp] Decision Func Wrong:", i)

					return
				end

				if result.isFinal then
					self.curVisible = result.visible
					self.curInteractable = result.interactable

					self:Log("[OnRefreshMotoSpeedUp] isFinal", self.curVisible, self.curInteractable)

					break
				end

				if not result.visible then
					self.curVisible = false
				end

				if not result.interactable then
					self.curInteractable = false
				end

				self:Log("[OnRefreshMotoSpeedUp] finish", self.curVisible, self.curInteractable)
			end
		end
	end

	if self.buttonStateMonitor[buttonType][1] ~= self.curVisible or self.buttonStateMonitor[buttonType][2] ~= self.curInteractable then
		self.buttonStateMonitor[buttonType][1] = self.curVisible
		self.buttonStateMonitor[buttonType][2] = self.curInteractable

		self:SetBtnControl(self[self.btnStore[buttonType]], self.curVisible, self.curInteractable)
		self.bindData[self.btnStore[buttonType]]:SetPCKeyTipShowTip(self.curVisible)
	end
end

function M:SetBtnVisible(btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

function M:SetBtnInteractable(btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

function M:SetBtnControl(btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end

function M:Log(...)
	if self.isDebug then
		print_debug("[UniqueSkillTaFeiStore]", ...)
	end
end

function M:DecideSkill_Trigger(type)
	if not type then
		return
	end

	local hideTrigger = gPaokuLimitManager:CheckFightNeedLimit(type)
	local btn = self.curBtnState
	btn.visible = not hideTrigger
	btn.interactable = not hideTrigger
	btn.isFinal = hideTrigger

	return btn
end

function M:DecideSkill_Parkour(type)
	if not type then
		return
	end

	local visible = true
	local interactable = true
	local platform = gMainMenuMgr:GetParkourStatePlatform()
	local stateAll = ""

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		stateAll = stateAll .. "/" .. state
		local skill1Config = gMainMenuMgr.clientStateConfig[state][type]

		if gCoreHudUIManager:IsParkourStateValid(skill1Config, platform) then
			visible = visible and skill1Config[platform].visible
			interactable = interactable and skill1Config[platform].interactable
		end
	end

	local btn = self.curBtnState
	btn.visible = visible
	btn.interactable = interactable
	btn.isFinal = not visible and not interactable

	self:Log("ParkourState: ", tostring(visible), tostring(interactable), stateAll)

	return btn
end

function M:DecideMotoSpeedUp_TaffyMoto()
	return
end
