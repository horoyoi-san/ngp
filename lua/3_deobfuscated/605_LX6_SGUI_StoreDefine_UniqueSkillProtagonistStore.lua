local HudDescConfig = LTConfig.HudDescConfig
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local DataSet = require("LX6/DataBind/DataSet")
C_UniqueSkillProtagonistStore = DefClass("C_UniqueSkillProtagonistStore", C_UniqueSkillProtagonistStore, C_StoreGroup)
GroupName2Class.UniqueSkillProtagonistStore = C_UniqueSkillProtagonistStore
local M = C_UniqueSkillProtagonistStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.isDebug = false
	self.BTN_ANIME = {
		UP = "s_vx_HudSkillbtn_fanse_up",
		DOWN = "s_vx_HudSkillbtn_fanse"
	}
	self.isFeiSuoGuideClose = false
	self.FeiSuoDecisions = {
		{
			func = ""
		},
		{
			func = "Decide_Platform"
		},
		{
			func = "Decide_TaskFeiSuo"
		},
		{
			func = "Decide_ForbidNormalFeiSuo"
		},
		{
			func = "Decide_IsGuideOpen"
		},
		{
			func = "Decide_FeiSuoPoint"
		},
		{
			func = "Decide_FeiSuoTarget"
		}
	}
	self.curBtnState = {
		interactable = false,
		isFinal = false,
		reason = "Default Button State",
		visible = false
	}
	self.buttonStateMonitor = DataSet.New({
		FeiSuo = {
			false,
			false
		}
	})
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
	gBattleMgr.uniqueSkillProtagonistPanel = self

	self:InitData()
	gMainMenuMgr:SetAwakeUI("UniqueSkillProtagonistStore")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:OnControllerSettingChange(_, gameProfile.isNewControllerSetting)
	end

	self:OnRefreshFeiSuoBtn(true)
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	gBattleMgr.uniqueSkillProtagonistPanel = nil

	self:ClearDataSetEvents()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
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
	self.grappleBtn = self:GetStoreByWidget(self.bindData.grappleBtn)
	self.airDashBtn = self:GetStoreByWidget(self.bindData.airDashBtn)
	self.grappleBtn.btnId = HudDescConfig.GRAPPLE_BTN
	self.airDashBtn.btnId = HudDescConfig.AIR_DASH_BTN
end

function M:BindBtnEvent()
	self.bindData.grappleBtn.luaBeginLongPress = self:CreateAction("OnGrappleBtnPress")
	self.bindData.grappleBtn.luaEndLongPress = self:CreateAction("OnGrappleBtnRelease")

	if self.bindData.airDashBtn then
		self.bindData.airDashBtn.luaBeginLongPress = self:CreateAction("OnAirDashBtnDown")
		self.bindData.airDashBtn.luaEndLongPress = self:CreateAction("OnAirDashBtnUp")
	end
end

function M:RegisterBtnAction()
	self.OnRefreshFeiSuoHandler = self:CreateAction("OnRefreshFeiSuoBtn")
	self.dataSetEvents = {
		{
			gFeisuoAssassMgr.InteractionInfo,
			"CanInteract",
			self.OnRefreshFeiSuoHandler
		},
		{
			gFeisuoAssassMgr.InteractionInfo,
			"LockEnemyId",
			self.OnRefreshFeiSuoHandler
		},
		{
			gPlayerManager.main.bindData,
			"isFeiSuoCrouch",
			self.OnRefreshFeiSuoHandler
		},
		{
			gGadgetManager.FeiSuoData,
			"hasFarFlyTarget",
			self.OnRefreshFeiSuoHandler
		},
		{
			gPlayerManager.main.bindData,
			"isInFeisuo",
			self.OnRefreshFeiSuoHandler
		},
		{
			gTaskManager.taskFeiSuo,
			"hasTaskFeiSuo",
			self.OnRefreshFeiSuoHandler
		}
	}

	self:ClearDataSetEvents()
	self:RegisterDataSetEvents(self.dataSetEvents)
end

function M:OnGrappleBtnPress()
	if not self.bindData.grappleBtn.interactable then
		return
	end

	gBattleMgr.btnPaoKuBtnDown = true
	gBattleMgr.btnPaoKuBtnDownFrame = Time.frameCount

	self:PlayBtnDownAnime(self.grappleBtn)
	gFeiSuoCrouchManager:FeisuoButtonClicked()
end

function M:OnGrappleBtnRelease()
	gBattleMgr.btnPaoKuBtnDown = false

	self:PlayBtnUpAnime(self.grappleBtn)
end

function M:PlayBtnDownAnime(store)
	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, self.BTN_ANIME.DOWN)
end

function M:PlayBtnUpAnime(store)
	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, self.BTN_ANIME.UP)
end

function M:OnAirDashBtnDown()
	self:PlayBtnDownAnime(self.airDashBtn)

	gCS.TransitionMgr.isAirDashBtnDown = true

	gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

	gCS.TransitionMgr.isAirDashBtnDown = false
end

function M:OnAirDashBtnUp()
	self:PlayBtnUpAnime(self.airDashBtn)
end

function M:Decide_ForbidNormalFeiSuo()
	local isForbidNormalFeiSuo = gFeisuoUIUpdateMgr.HideUI
	local btn = self.curBtnState
	btn.visible = not isForbidNormalFeiSuo
	btn.interactable = not isForbidNormalFeiSuo
	btn.isFinal = isForbidNormalFeiSuo

	return btn
end

function M:Decide_TaskFeiSuo()
	local isTaskFeiSuo = gTaskManager.taskFeiSuo.hasTaskFeiSuo or gGadgetManager.FeiSuoTarget ~= nil
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = true
	btn.isFinal = isTaskFeiSuo

	return btn
end

function M:Decide_FeiSuoPoint()
	local selectFeiSuoPoint = gFeisuoUIUpdateMgr.selectFeisuoInfo.select
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = selectFeiSuoPoint
	btn.isFinal = false

	return btn
end

function M:Decide_FeiSuoTarget()
	local btn = self.curBtnState
	btn.visible = true
	btn.interactable = true
	btn.isFinal = false

	return btn
end

function M:Decide_Platform()
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local btn = self.curBtnState
	btn.visible = isMobile
	btn.interactable = true
	btn.isFinal = false

	return btn
end

function M:Decide_IsGuideOpen()
	local GuideClose = self.isFeiSuoGuideClose
	local btn = self.curBtnState
	btn.visible = not GuideClose
	btn.interactable = not GuideClose
	btn.isFinal = GuideClose

	return btn
end

function M:OnRefreshFeiSuoBtn(force)
	local decisions = self.FeiSuoDecisions
	self.curVisible = true
	self.curInteractable = true

	for i = 1, #decisions do
		if decisions[i] and decisions[i].func then
			if self[decisions[i].func] then
				local result = self[decisions[i].func](self)

				if not result or result.visible == nil or result.interactable == nil then
					self:Log("[OnRefreshFeiSuoBtn] Decision Func Wrong:", i)

					return
				end

				if result.isFinal then
					self.curVisible = result.visible
					self.curInteractable = result.interactable

					self:Log("[OnRefreshFeiSuoBtn] isFinal", self.curVisible, self.curInteractable)

					break
				end

				if not result.visible then
					self.curVisible = false
				end

				if not result.interactable then
					self.curInteractable = false
				end

				self:Log("[OnRefreshFeiSuoBtn] finish", self.curVisible, self.curInteractable)
			end
		end
	end

	if self.buttonStateMonitor.FeiSuo[1] ~= self.curVisible or self.buttonStateMonitor.FeiSuo[2] ~= self.curInteractable or force then
		self.buttonStateMonitor.FeiSuo[1] = self.curVisible
		self.buttonStateMonitor.FeiSuo[2] = self.curInteractable
		self.grappleBtn.btnHideCtrl = self.curVisible and 0 or 1

		self.bindData.grappleBtn:SetActive(self.curInteractable)

		if not self.buttonStateMonitor.FeiSuo[2] then
			gBattleMgr:CommonStopAniTool(self.grappleBtn.btnFanseAni, self.BTN_ANIME.UP)
		end
	end
end

function M:OnGuideRefreshFeiSuo(eventId, isDisable)
	self.isFeiSuoGuideClose = isDisable

	self:OnRefreshFeiSuoBtn()
end

function M:OnControllerSettingChange(eventId, isNewSetting)
	self.bindData.ControllerSettingCtrl = isNewSetting and 0 or 1
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.SETTING_CONTROLLER_TYPE_CHANGE] = self:CreateAction("OnControllerSettingChange"),
		[gEventConstants.ON_GUIDE_REFRESH_FEISUO] = self:CreateAction("OnGuideRefreshFeiSuo")
	}
end

function M:RegisterWidget()
	return
end

function M:Log(...)
	if self.isDebug then
		print_debug("[UniqueSkillProtagonistStore]", ...)
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
