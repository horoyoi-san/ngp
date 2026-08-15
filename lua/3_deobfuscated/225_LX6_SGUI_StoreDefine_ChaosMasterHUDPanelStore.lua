local AnimMgr = SGUI.AnimMgr
local DOTween = DOTween
local Ease = DG.Tweening.Ease
C_ChaosMasterHUDPanelStore = DefClass("C_ChaosMasterHUDPanelStore", C_ChaosMasterHUDPanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterHUDPanelStore = C_ChaosMasterHUDPanelStore
local M = C_ChaosMasterHUDPanelStore
local TabType = {
	Hide = 1,
	Show = 0
}
local RoundResult = {
	Lose = 2,
	Hide = 0,
	Win = 1
}
local CutInType = {
	Hide = 0,
	Right = 2,
	Left = 1
}
local DamageTabType = {
	Damaged = 0,
	DamageOther = 1
}
local GenreDetailType = {
	Left = 0,
	Hide = 2,
	Right = 1
}
local SwitchViewType = {
	Dps = 0,
	GenreList = 1,
	OnlineMember = 2
}

function M:ctor()
	self.isLockBuff = false
	self.roundNum = 1
	self.damageTabType = DamageTabType.DamageOther
	self.isFreeCamera = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.cameraSpeed = LTConfig.ChaosMasterConfig.CameraSpeed
	self.cameraMaxRadius = LTConfig.ChaosMasterConfig.CameraMaxRadius
	self.curUpdateCameraPosCD = 0
	self.canRefreshBuff = true
	self.moneyTween = nil
	self.durabilityTextTween = nil
	self.chaosDurability = {}
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	local store = self:GetStoreByWidget(self.bindData.buffSelect)

	if store then
		store.lockBtn.luaClick = self:CreateAction("OnLockBuffCardBtnClick")
		store.refreshBtn.luaClick = self:CreateAction("OnRefreshBuffCardBtnClick")
		store.readyBtn.luaClick = self:CreateAction("OnReadyBtnClick")
		store.readyBtn.luaInvalidClick = self:CreateAction("OnReadyBtnClick")
		store.detailBtn.luaClick = self:CreateAction("OnDetailBtnClick")
		store.buffCardList.luaRenderItem = self:CreateAction("OnRenderBuffCardListItem")
		store.buffCardList.luaClick = self:CreateAction("OnBuffCardClick")
		self.readyBtn = store.readyBtn
	end

	store = self:GetStoreByWidget(self.bindData.myGenreDetail)

	if store then
		store.buffList.luaRenderItem = self:CreateAction("OnRenderGenreBuffItem")
	end

	store = self:GetStoreByWidget(self.bindData.otherGenreDetail)

	if store then
		store.buffList.luaRenderItem = self:CreateAction("OnRenderGenreBuffItem")
	end

	store = self:GetStoreByWidget(self.bindData.dps)

	if store then
		store.dpsTab.luaRenderItem = self:CreateAction("OnRenderDpsTabItem")
		store.dpsTab.luaClick = self:CreateAction("OnDpsTabItemClick")
		store.dpsList.luaRenderItem = self:CreateAction("OnRenderDpsListItem")

		if store.switchBtn then
			store.switchBtn.luaClick = self:CreateAction("OnClickSwitchSkillTabBtn")
			self.switchBtn = gStoreManager:GetStoreGroup("ChaosGamePadSwitchTemplate"):GetStoreByWidget(store.switchBtn)
		end
	end

	self.LTopPokemon = gStoreManager:GetStoreGroup("CMHudTopTemplate"):GetStoreByWidget(self.bindData.leftHead)
	self.LTopPokemon.buffList.luaRenderItem = self:CreateAction("OnRenderBuffItem")
	self.LTopPokemon.prepareList.luaRenderItem = self:CreateAction("OnRenderPrepareList")
	self.LTopPokemon.prepareList.luaClick = self:CreateActionWithArgs("OnClickPrepareListItem", true)
	self.RTopPokemon = gStoreManager:GetStoreGroup("CMHudTopTemplate"):GetStoreByWidget(self.bindData.rightHead)
	self.RTopPokemon.buffList.luaRenderItem = self:CreateAction("OnRenderBuffItem")
	self.RTopPokemon.prepareList.luaRenderItem = self:CreateAction("OnRenderPrepareList")
	self.RTopPokemon.prepareList.luaClick = self:CreateActionWithArgs("OnClickPrepareListItem", false)
	self.leftCutIn = gStoreManager:GetStoreGroup("ChaosMasterCutInTemplate"):GetStoreByWidget(self.bindData.leftCutIn)
	self.rightCutIn = gStoreManager:GetStoreGroup("ChaosMasterCutInTemplate"):GetStoreByWidget(self.bindData.rightCutIn)
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	if self.moneyTween then
		self.moneyTween:Kill()

		self.moneyTween = nil
	end

	if self.durabilityTextTween then
		self.durabilityTextTween:Kill()

		self.durabilityTextTween = nil
	end
end

function M:OnGroupEnable()
	self.msgEvents = {
		[gEventConstants.REFRESH_HEADVIEW_BUFFS] = self:CreateAction("OnRefreshBuffs")
	}
	self.dataSetEvents = {}

	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterDataSetEvents(self.dataSetEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
	self:ClearDataSetEvents()
end

function M:OnShow(panelId, data)
	table.clear(self.chaosDurability)
	self:ChangeBuffCardLockState(false)
	self:RefreshDDLType(gBattlePetsMgr.BVBDDLType.Prepare)
	self:EnableBuffSelectTab(false)
	self:EnableExitBtn(gBattlePetsMgr.bvbOnlineType ~= gBattlePetsMgr.BVBOnlineType.MultiOnline)
	self:EnableSurrenderBtn(gBattlePetsMgr.bvbOnlineType ~= gBattlePetsMgr.BVBOnlineType.Single)
	self:ShowTopHead(true)
	self:EnableDamageTab(true)
	self:RefreshBuffSelectTab()
	self:RefreshGenreList(true)
	self:RefreshGenreList(false)
	self:RefreshPrepareList(self.bindData.battleSelectMyChaosList, true, true)
	self:RefreshPrepareList(self.bindData.battleSelectEnemyChaosList, false, true)
	self:SwitchCameraMode(self.isFreeCamera)

	if gBattlePetsMgr.gameMode ~= UX.Game.BVBGameModeType.BVBGameContinuousBrawl then
		gBattleMgr.dataSet.showEnemyHp = false
	end

	gPanelManager:Close(gPanelId.S_CORE_HUD_PANEL)
	gMapUtils:CloseMiniMap()

	gBattlePetsMgr.showHudPanel = true
	L50.L50App.Scene.GamePlayUtils.showHudPanel = true

	gNewGuideMgr:StopGuide()
	gPopupPauseManager:PausePopup(gPopupPauseManager.PAUSE_REASON.BVB)
	self:EnableCamera(gBattlePetsMgr.myChaosCamp == UX.Game.UnitCamp.BVBFriend and 1 or 2)

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		gLuaDataManager.guiMgr.sguiJoystick:ShowJoystickUI(false)
	end

	self.canRefreshBuff = true
	self.switchViewType = gCS.LuaUtils.IsNonMobileAdaptive() and SwitchViewType.GenreList or SwitchViewType.Dps
	self.bindData.showGenreCtrl = gBattlePetsMgr:CheckIsBVBGameDoJoChallenge() and 1 or 0
	self.bindData.showDurabilityCtrl = gBattlePetsMgr:CheckIsBVBGameDoJoChallenge() and 1 or 0
end

function M:OnClose()
	if gBattlePetsMgr.gameMode ~= UX.Game.BVBGameModeType.BVBGameContinuousBrawl then
		gBattleMgr.dataSet.showEnemyHp = true
	end

	gPanelManager:CheckShow(gPanelId.S_CORE_HUD_PANEL)
	gMapUtils:ShowMiniMap()

	gBattlePetsMgr.showHudPanel = false
	L50.L50App.Scene.GamePlayUtils.showHudPanel = false

	gPopupPauseManager:ResumePopup(gPopupPauseManager.PAUSE_REASON.BVB)

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		gLuaDataManager.guiMgr.sguiJoystick:ShowJoystickUI(true)
	end

	gCS.PreLoadSkillMgr:Release(LX6.Fight.PreLoad.LoadType.BVB)
end

function M:OnUpdate()
	if self.enableDLLUpdate then
		self:UpdateDDL()
	end

	self:UpdateCutIn()
	self:CheckShowTopHead()
	self:CheckShowTopChaosList()
	self:CheckShowSwitchViewBtn()
	self:CheckShowRightSwitchBtn()
	self:CheckShowDamageTab()
	self:UpdateCameraPos()
	self:DoUpdateCameraPos()
	self:UpdateGamepadCamera()
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
	self.bindData.fullScreenBackBtn.luaClick = self:CreateAction("OnClickFullScreenBackBtn")
	self.bindData.exitBtn.luaClick = self:CreateAction("OnClickExitBtn")
	self.bindData.switchViewBtn.luaClick = self:CreateAction("OnClickSwitchViewBtn")
	self.bindData.switchCameraBtn.luaClick = self:CreateAction("OnClickSwitchCameraBtn")
	self.bindData.guideBtn.luaClick = self:CreateAction("OnClickGuideBtn")
	self.bindData.genreList.luaRenderItem = self:CreateAction("OnRenderGenreListItem")
	self.bindData.genreList.luaClick = self:CreateAction("OnClickGenreList")
	self.bindData.otherGenreList.luaRenderItem = self:CreateAction("OnRenderGenreListItem")
	self.bindData.otherGenreList.luaClick = self:CreateAction("OnClickGenreList")
	self.bindData.battleSelectMyChaosList.luaRenderItem = self:CreateAction("OnRenderPrepareList")
	self.bindData.battleSelectMyChaosList.luaClick = self:CreateActionWithArgs("OnClickPrepareListItem", true)
	self.bindData.battleSelectEnemyChaosList.luaRenderItem = self:CreateAction("OnRenderPrepareList")
	self.bindData.battleSelectEnemyChaosList.luaClick = self:CreateActionWithArgs("OnClickPrepareListItem", false)

	if self.bindData.controllerR then
		self.needUpdateCamera = false
		self.rightStickValue = {
			x = 0,
			y = 0
		}
		self.bindData.controllerR.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
	end
end

function M:OnClickFullScreenBackBtn()
	self:EnableGenreInfoTab(false)
	self:EnableChaosInfoTab(false)
end

function M:OnClickExitBtn()
	gDisplayMessageMgr:ShowMessageContent(LTConfig.ChaosMasterConfig.ExitBtnContent, gDisplayMessageId.SELECT, 1, function ()
		gBattlePetsMgr.clickExitHUDBtn = true

		gClientToGameSceneDelegate:AskExitBVBGame().Callback = function ()
			return
		end
	end, nil)
end

function M:OnClickSurrenderBtn()
	self:OnClickExitBtn()
end

function M:OnClickSwitchViewBtn()
	local mod = 3

	if gBattlePetsMgr.bvbOnlineType ~= gBattlePetsMgr.BVBOnlineType.MultiOnline then
		mod = 2
	end

	local type = (self.switchViewType + 1) % mod

	if gCS.LuaUtils.IsNonMobileAdaptive() and type == SwitchViewType.Dps then
		type = SwitchViewType.GenreList or type
	end

	self:SwitchView(type)
end

function M:OnClickSwitchCameraBtn()
	self:SwitchCameraMode()
end

function M:OnClickGuideBtn()
	gPanelManager:CheckShow(gPanelId.CHAOS_MASTER_GUIDE_PANEL)
end

function M:OnChaosInfoClick(data)
	self.recordClickChaosInfo = {
		isMyChaos = data.isMyChaos,
		chaosInfo = data.chaosData
	}

	self:RefreshChaosInfoTab(data.isMyChaos, data.chaosData)
end

function M:OnChaosInfoHover(data)
	self:RefreshChaosInfoTab(data.isMyChaos, data.chaosData)
end

function M:OnChaosInfoUnHover(btn, data)
	if self.recordClickChaosInfo then
		self:RefreshChaosInfoTab(self.recordClickChaosInfo.isMyChaos, self.recordClickChaosInfo.chaosInfo)
	else
		self:EnableChaosInfoTab(false)
	end
end

function M:OnBuffCardClick(btn, data)
	if data.cost > (self.money or 0) or data.soldCtrl == 0 then
		return
	end

	gClientToGameSceneDelegate:AskBVBSelectChaosBuff(data.cfg.Id).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self:OnBuyBuffCard(btn, data)
		end
	end
end

function M:OnClickPrepareListItem(isMyChaos, btn, data)
	self.recordClickChaosInfo = {
		isMyChaos = isMyChaos,
		chaosInfo = data
	}

	self:RefreshChaosInfoTab(isMyChaos, data)
end

function M:OnRightStickControl(context)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not self.isFreeCamera or not context then
		self.needUpdateCamera = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)

		return
	end

	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.needUpdateCamera = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.needUpdateCamera = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
	end
end

function M:UpdateGamepadCamera()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if self.needUpdateCamera then
		local cameraConfigId = 1

		gCameraUtils:DoRotateCameraByGamePad(cameraConfigId, self.rightStickValue.x, self.rightStickValue.y)
	end
end

function M:ClearGamepadCameraRotate()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.needUpdateCamera = false
	self.rightStickValue.x = 0
	self.rightStickValue.y = 0

	gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
end

function M:OnDpsTabItemClick(btn, data)
	self.dpsTabType = data.type
	local store = self:GetStoreByWidget(self.bindData.dps)

	self:RefreshDamageTab(store)
	self:RefreshDamageList(data.type)
end

function M:OnLockBuffCardBtnClick()
	if self.isLockBuff then
		gClientToGameSceneDelegate:AskBVBUnlockChaosBuffCandidates().Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				self:ChangeBuffCardLockState()
			end
		end
	else
		gClientToGameSceneDelegate:AskBVBLockChaosBuffCandidates().Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				self:ChangeBuffCardLockState()
			end
		end
	end
end

function M:OnRefreshBuffCardBtnClick()
	if not self.canRefreshBuff then
		return
	end

	self.playRefreshBuffCardAni = true
	self.canRefreshBuff = false

	gClientToGameSceneDelegate:AskBVBRefreshChaosBuffCandidates().Callback = function (err)
		self.playRefreshBuffCardAni = false
	end
end

function M:OnReadyBtnClick()
	if not self.readyBtn.interactable then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901185).Text)

		return
	end

	gClientToGameSceneDelegate:AskBVBGetReady().Callback = function (err)
		if err == LTConfig.MessageConfig.Ok and self.readyBtn then
			self.readyBtn.interactable = false
		end
	end
end

function M:OnDetailBtnClick()
	local list = {}

	for i = 1, #LTConfig.ChaosMasterConfig.RefreshRule do
		local item = {
			desc = LTConfig.ChaosMasterConfig.RefreshRule[i]
		}

		table.insert(list, item)
	end

	gPanelManager:CheckShow(gPanelId.ITEM_INFO_ONLY_TEXT_PANEL, {
		title = LTConfig.ChaosMasterConfig.RefreshRuleBigTitle,
		content = list
	})
end

function M:OnBuyBuffCard(btn, data)
	local store = gStoreManager:GetStoreGroup("ChaosBuffCardTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.soldCtrl = 0
	store.lockCtrl = 1
	self.cacheBuffList[data.index].Selected = true
	self.buffCardList[data.index].soldCtrl = 0
	self.buffCardList[data.index].lockCtrl = 1
end

function M:OnRenderGenreListItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("BuffGenreTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId
	store.levelActiveCtrl = data.levelActiveCtrl
	store.levelNum = data.levelNum
	store.genreExpCtrl = data.genreExpCtrl
	store.genreExpCom.fillAmount = data.expNum / data.expFm
	store.button.luaHover = self:CreateActionWithArgs("OnGenreListItemHover", {
		isMyChaos = data.isLeft,
		genreInfo = data
	})
	store.button.luaUnhover = self:CreateAction("OnGenreListItemUnHover")
	store.button.luaFocus = self:CreateActionWithArgs("OnGenreListItemHover", {
		isMyChaos = data.isLeft,
		genreInfo = data
	})

	store.refreshAni.gameObject:SetActive(data.playRefreshAni or data.playLevelUpAni)

	if data.playRefreshAni or data.playLevelUpAni then
		gBattleMgr:CommonPlayAniTool(store.levelNumAni, "S_BuffGenreTemplate_levelup", 0, 1, true)
	end
end

function M:OnGenreListItemHover(data)
	self:RefreshGenreInfoTab(data.isMyChaos, data.genreInfo)
end

function M:OnGenreListItemUnHover()
	if self.recordClickGenreInfo then
		self:RefreshGenreInfoTab(self.recordClickGenreInfo.isMyChaos, self.recordClickGenreInfo.genreInfo)
	else
		self:EnableGenreInfoTab(false)
	end
end

function M:OnClickGenreList(btn, data)
	self.recordClickGenreInfo = {
		isMyChaos = data.isLeft,
		genreInfo = data
	}

	self:RefreshGenreInfoTab(data.isLeft, data)
end

function M:OnClickSwitchSkillTabBtn(btn, data)
	self.dpsTabType = self.dpsTabType == DamageTabType.Damaged and DamageTabType.DamageOther or DamageTabType.Damaged
	local store = self:GetStoreByWidget(self.bindData.dps)

	self:RefreshDamageTab(store)
	self:RefreshDamageList(self.dpsTabType)
end

function M:OnRenderBuffCardListItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("ChaosBuffCardTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.playRefreshBuffCardAni then
		local clip = store.refreshAni:GetClip("S_ChaosBuffCardTemplate_re")

		gBattleMgr:CommonPlayAniTool(store.refreshAni, "S_ChaosBuffCardTemplate_re", 0, 1, true, function ()
			self.canRefreshBuff = true
		end)
		gLuaTimeMgrUtils.Delay(function ()
			self:DoRenderBuffCardListItem(store, data)
		end, clip.length * 0.5)
	else
		self:DoRenderBuffCardListItem(store, data)
	end
end

function M:DoRenderBuffCardListItem(store, data)
	if store == nil then
		return
	end

	store.icon = data.iconId
	store.name = data.name
	store.des = data.des
	store.cost = data.cost
	store.qualityCtrl = data.qualityCtrl
	store.soldCtrl = data.soldCtrl
	store.moneylackCtrl = data.moneylackCtrl
	store.goldenEffActive = data.goldenEffActive
	store.lockCtrl = data.lockCtrl
	store.selected = false
	store.buffStar.luaRenderItem = self:CreateAction("OnRenderBuffCardStarListItem")
	store.genreList.luaRenderItem = self:CreateAction("OnRenderBuffCardGenreListItem")
	store.genreList.luaClick = self:CreateAction("OnGenreClick")

	self:RefreshBuffCardStarList(store.buffStar, data, false)
	self:RefreshBuffCardGenreList(store, data.cfg)
end

function M:OnRenderBuffCardStarListItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("StarLevelTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.activeCtrl = data.activeCtrl
end

function M:OnGenreClick(btn, data)
	return
end

function M:OnRenderBuffCardGenreListItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("BuffGenreTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId or 0
end

function M:OnRenderGenreBuffItem(item, index, data)
	local store = gStoreManager:GetStoreGroup("ChaosBuffDetailTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.name = data.name
	store.iconId = data.iconId
	store.des = data.des
	store.qualityCtrl = data.qualityCtrl
	store.levelList.luaRenderItem = self:CreateAction("OnRenderBuffCardStarListItem")

	self:RefreshBuffCardStarList(store.levelList, data, true)
end

function M:OnRenderDpsTabItem(item, index, data)
	local store = gStoreManager:GetStoreGroup("ChaosMasterDpsTabTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.name = data.name
end

function M:OnRenderDpsListItem(item, index, data)
	local store = gStoreManager:GetStoreGroup("ChaosMasterDpsTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	gBattlePetsMgr:RefreshDpsListItem(store, data)
end

function M:OnRenderBuffItem(item, index, data)
	local store = gStoreManager:GetStoreGroup("ChaosMasterTopBuffTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId
	store.tier = data.tier
	store.cfg = data.cfg
	store.button.luaRenderTooltip = self:CreateAction("OnBuffToolTipRender")
	store.button.luaTooltipPopup = self:CreateAction("OnBuffToolTipPopUp")
end

function M:OnBuffToolTipRender(btn, popup, index)
	local store = gStoreManager:GetStoreGroup("ChaosMasterTopBuffTemplate"):GetStoreByWidget(btn)
	local popupStore = gStoreManager:GetStoreGroup("CommonBuffTip"):GetStoreByWidget(popup)

	if not popupStore or not popupStore then
		return
	end

	popupStore.des = gBattlePetsMgr:BuildDescriptionStrByValueList(store.cfg.Description, store.cfg.BuffParameter, store.cfg.StarUpParametersType, 1, false)
end

function M:OnBuffToolTipPopUp(btn, popup, index)
	local store = gStoreManager:GetStoreGroup("ChaosMasterTopBuffTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if not popup then
		store.selected = popup

		self:RefreshGenreList()
	end
end

function M:OnRenderPrepareList(item, index, data)
	local store = gStoreManager:GetStoreGroup("ChaosMasterHeadTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId
	store.deadCtrl = data.deadCtrl
	store.chaosData = data.chaosData
	store.selected = data.selected
	store.button.luaHover = self:CreateActionWithArgs("OnPrepareChaosInfoHover", {
		isMyChaos = data.isMyChaos,
		chaosData = data
	})
	store.button.luaUnhover = self:CreateAction("OnPrepareChaosInfoUnHover")
	store.button.luaFocus = self:CreateActionWithArgs("OnPrepareChaosInfoHover", {
		isMyChaos = data.isMyChaos,
		chaosData = data
	})

	if data.playDurabilityAni then
		store.durabilityCtrl = TabType.Show

		self:RefreshPrepareChaosDurability(store, data)
	end

	if data.playDeadAni then
		gBattleMgr:CommonPlayAniTool(store.deadAni, "S_ChaosHead_S_dead", 0, 1, true)
	end

	self.chaosDurability[data.chaosData.PokemonId] = data.RemainDurability
end

function M:OnPrepareChaosInfoHover(data)
	self:RefreshChaosInfoTab(data.isMyChaos, data.chaosData)
end

function M:OnPrepareChaosInfoUnHover(btn, data)
	if self.recordClickChaosInfo then
		self:RefreshChaosInfoTab(self.recordClickChaosInfo.isMyChaos, self.recordClickChaosInfo.chaosInfo)
	else
		self:EnableChaosInfoTab(false)
	end
end

function M:InitData()
	self.bindData.showMoneyCtrl = TabType.Show
	self.roundNum = 1
	gBattlePetsMgr.clickExitHUDBtn = false
	self.isFreeCamera = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.oldCameraType = self.isFreeCamera
end

function M:EnableExitBtn(enable)
	self.bindData.hideExit = enable and TabType.Show or TabType.Hide
end

function M:EnableSurrenderBtn(enable)
	return
end

function M:EnableBuffSelectTab(enable)
	if not self.STATE_EnableOnce then
		return
	end

	self.bindData.buffSelectCtrl = enable and TabType.Show or TabType.Hide

	self:ClearHUD()

	if self.readyBtn and not gCS.LuaUtils.IsNull(self.readyBtn) then
		self.readyBtn.interactable = true
	end

	self:ResetToInitCameraPos(not enable)
	self:SwitchNavAreaInSelectBuff(enable)
	gPanelManager:Close(gPanelId.ITEM_INFO_ONLY_TEXT_PANEL)

	if enable then
		self.canRefreshBuff = true

		self:RefreshDDLType(gBattlePetsMgr.BVBDDLType.Prepare)
		self:OnClickFullScreenBackBtn()

		self.oldCameraType = self.isFreeCamera

		self:SwitchCameraMode(false)
	else
		self:SwitchCameraMode(self.oldCameraType)

		self.bindData.showChaosInfoCtrl = TabType.Hide
	end
end

function M:RefreshBuffSelectTab(buffs)
	if buffs then
		self.cacheBuffList = buffs
	else
		buffs = self.cacheBuffList or {}
	end

	if self.bindData.buffSelectCtrl == TabType.Hide or not buffs or not self.bindData.buffSelect then
		return
	end

	local store = self:GetStoreByWidget(self.bindData.buffSelect)

	if store then
		store.refreshMoney = gBattlePetsMgr.refreshBuffCardMoney
		store.refreshMoneyCtrl = gBattlePetsMgr.refreshBuffCardMoney > (self.money or 0) and 1 or 0
		store.nCardPercent = "N:" .. gBattlePetsMgr.nCardPercent .. "%"
		store.rCardPercent = "R:" .. gBattlePetsMgr.rCardPercent .. "%"
		store.srCardPercent = "SR:" .. gBattlePetsMgr.srCardPercent .. "%"

		self:RefreshBuffCardList(store, buffs)
	end
end

function M:SwitchNavAreaInSelectBuff(isSelectBuff)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local targetArea = isSelectBuff and self.bindData.buffSelectGamePadArea or self.bindData.gamePadArea

	self.bindData.topLeftHeadArea:ChangeNavAreaByActionId(2, targetArea)
	self.bindData.topRightHeadArea:ChangeNavAreaByActionId(2, targetArea)
	self.bindData.leftGenreArea:ChangeNavAreaByActionId(2, targetArea)
	self.bindData.rightGenreArea:ChangeNavAreaByActionId(2, targetArea)
end

function M:ChangeBuffCardLockState(isLockBuff)
	if isLockBuff ~= nil then
		self.isLockBuff = isLockBuff
	else
		self.isLockBuff = not self.isLockBuff
	end

	self:RefreshBuffSelectTab()

	local store = self:GetStoreByWidget(self.bindData.buffSelect)
	store.buffLockCtrl = self.isLockBuff and 0 or 1

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local nameId = self.isLockBuff and 414 or 403

		self.bindData.buffSelectGamePadArea:SetButtonInfoTipNameId(nameId, 3)
	end
end

function M:RefreshBuffCardList(store, buffs)
	self.buffCardList = {}

	for i = 1, #buffs do
		local cfg = LTConfig.ChaosMasterChaosBuffConfig.GetConfig(buffs[i].ChaosBuffId)

		if cfg then
			local cost = LTConfig.ChaosMasterConfig.BuffCost[cfg.Quality]
			local level = gBattlePetsMgr:GetBuffLevel(buffs[i].ChaosBuffId, true)
			local item = {
				selected = false,
				iconId = cfg.SImageId,
				name = cfg.Name,
				des = gBattlePetsMgr:BuildDescriptionStrByValueList(cfg.Description, cfg.BuffParameter, cfg.StarUpParametersType, level + 1, true),
				cost = cost,
				qualityCtrl = cfg.Quality - 1,
				cfg = cfg,
				soldCtrl = buffs[i].Selected and 0 or 1,
				moneylackCtrl = cost > (self.money or 0) and 1 or 0,
				level = level,
				index = i,
				goldenEffActive = cfg.Quality == 3,
				playRefreshBuffCardAni = self.playRefreshBuffCardAni,
				lockCtrl = self.isLockBuff and not buffs[i].Selected and 0 or 1
			}

			table.insert(self.buffCardList, item)
		end
	end

	store.buffCardList:SetList(self.buffCardList)
end

function M:RefreshBuffCardSold(buffId)
	for i = 1, #self.buffCardList do
		if self.buffCardList[i].cfg.Id == buffId then
			self.buffCardList[i].soldCtrl = 0
			self.buffCardList[i].selected = false
		end
	end

	local store = self:GetStoreByWidget(self.bindData.buffSelect)

	store.buffCardList:SetList(self.buffCardList)
end

function M:RefreshCardCostInfo()
	if not self.bindData.buffSelect or not self.buffCardList then
		return
	end

	local store = self:GetStoreByWidget(self.bindData.buffSelect)

	for i = 1, #self.buffCardList do
		self.buffCardList[i].moneylackCtrl = self.buffCardList[i].cost > (self.money or 0) and 1 or 0
		self.buffCardList[i].playRefreshBuffCardAni = false
	end

	store.buffCardList:SetList(self.buffCardList)
end

function M:RefreshBuffCardStarList(uiList, data, isNowLevel)
	local cfg = data.cfg
	local maxStar = cfg.BuffMaxLevel
	local list = {}
	local addValue = isNowLevel and 0 or 1

	for i = 1, maxStar do
		local nowLevel = data.level
		local item = {
			activeCtrl = i <= nowLevel + addValue and 0 or 1
		}

		table.insert(list, item)
	end

	uiList:SetList(list)
end

function M:RefreshBuffCardGenreList(store, cfg)
	local allGenreList = cfg.Tag
	local list = {}

	for i = 1, #allGenreList do
		local cfg = LTConfig.ChaosMasterChaosTagConfig.GetConfig(allGenreList[i])
		local item = {
			iconId = cfg.SImageId,
			cfg = cfg
		}

		table.insert(list, item)
	end

	store.genreList:SetList(list)
end

function M:RefreshMoney(money)
	if self.money == money then
		return
	end

	self.money = money

	self:RefreshCardCostInfo()

	local ani = self.bindData.moneyAni

	if not ani then
		self.bindData.money = money

		return
	end

	local clip = ani:GetClip("S_ChaosMasterHUDPanel_money")
	local length = clip.length
	self.moneyTween = DOTween.To(function ()
		return self.bindData.money or 0
	end, function (value)
		self.bindData.money = math.ceil(value)
	end, money, length):SetEase(Ease.Linear):OnComplete(function ()
		self.bindData.money = money
	end)

	gBattleMgr:CommonPlayAniTool(ani, "S_ChaosMasterHUDPanel_money", 0, 1, true)
end

function M:ShowTopHead(enable)
	self.showTopHead = enable
	self.bindData.showTopHeadCtrl = self:CanShowTopHead() and TabType.Show or TabType.Hide
end

function M:CheckShowTopHead()
	self.bindData.showTopHeadCtrl = self:CanShowTopHead() and TabType.Show or TabType.Hide
end

function M:CheckShowTopChaosList()
	self.bindData.showTopChaosListCtrl = self:CheckIsSelectChaosOrSelectBuff() and TabType.Show or TabType.Hide
end

function M:CheckShowSwitchViewBtn()
	self.bindData.showSwitchViewBtnCtrl = not self:CheckIsSelectChaosOrSelectBuff() and TabType.Show or TabType.Hide
end

function M:CheckShowRightSwitchBtn()
	local enable = not gCS.LuaUtils.IsNonMobileAdaptive() and not self:CheckIsSelectChaosOrSelectBuff()
	self.bindData.showRightSwitchBtnCtrl = enable and TabType.Show or TabType.Hide
end

function M:CheckShowDamageTab()
	local enable = self.showDpsCtrl and not self:CheckIsSelectChaosOrSelectBuff()
	self.bindData.showDpsCtrl = enable and TabType.Show or TabType.Hide
end

function M:CanShowTopHead()
	if self:CheckIsSelectChaosOrSelectBuff() then
		return false
	end

	if gBattlePetsMgr.gameMode == UX.Game.BVBGameModeType.BVBGameContinuousBrawl then
		return false
	end

	return self.showTopHead
end

function M:CheckIsSelectChaosOrSelectBuff()
	if self.bindData.battleSelectCtrl == TabType.Show then
		return true
	end

	if self.bindData.buffSelectCtrl == TabType.Show then
		return true
	end

	return false
end

function M:RefreshAllChaosInfo()
	self:RefreshChaosInfo(self.bindData.leftHead, true)
	self:RefreshChaosInfo(self.bindData.rightHead, false)
end

function M:RefreshAllChaosDurability()
	local leftStore = gStoreManager:GetStoreGroup("CMHudTopTemplate"):GetStoreByWidget(self.bindData.leftHead)
	local durability = self:GetRemainDurability(true)

	self:RefreshChaosDurability(leftStore, durability)

	local rightStore = gStoreManager:GetStoreGroup("CMHudTopTemplate"):GetStoreByWidget(self.bindData.rightHead)
	local durability = self:GetRemainDurability(false)

	self:RefreshChaosDurability(rightStore, durability)
end

function M:RefreshAllChaosInfoSelect()
	if self.roundType == gBattlePetsMgr.BVBDDLType.Battle then
		self:RefreshChaosSelect(self.bindData.leftHead, true)
		self:RefreshChaosSelect(self.bindData.rightHead, false)
	else
		self:RefreshPrepareList(self.bindData.battleSelectMyChaosList, true, true)
		self:RefreshPrepareList(self.bindData.battleSelectEnemyChaosList, false, true)
	end
end

function M:RefreshChaosInfo(widget, isMyChaos)
	local store = gStoreManager:GetStoreGroup("CMHudTopTemplate"):GetStoreByWidget(widget)
	local data, cfg = gBattlePetsMgr:GetCurrentRoundChaosDataAndConfig(isMyChaos)

	if not data or not cfg then
		return
	end

	store.name = isMyChaos and gPlayerManager.infoLogin.bindData.name or self:GetOtherPlayerName()
	store.chaosName = cfg.Name
	store.element = cfg.HeadIconID
	store.chaosLevel = "Lv." .. gBattlePetsMgr:GetChaosGenreLevel(self.isMyChaos)
	store.FirstChaosInfoBtn.luaClick = self:CreateActionWithArgs("OnChaosInfoClick", {
		isMyChaos = isMyChaos,
		chaosData = {
			index = 0,
			isMyChaos = isMyChaos,
			chaosData = data
		}
	})
	store.FirstChaosInfoBtn.luaHover = self:CreateActionWithArgs("OnChaosInfoHover", {
		isMyChaos = isMyChaos,
		chaosData = {
			index = 0,
			isMyChaos = isMyChaos,
			chaosData = data
		}
	})
	store.FirstChaosInfoBtn.luaUnhover = self:CreateAction("OnChaosInfoUnHover")
	local durability = self:GetRemainDurability(isMyChaos, data)

	self:RefreshChaosDurability(store, durability, data)
	self:RefreshPokemonHp(isMyChaos, 1, true)
	store.energyProgress:ResetValue(0, 0, 0, 1)
	store.buffList:SetList({})
	self:RefreshPrepareList(store.prepareList, isMyChaos)
	self:RefreshChaosSelect(widget, isMyChaos)

	store.lastPokemonId = data.PokemonId
end

function M:GetRemainDurability(isMyChaos, data)
	local durability = nil

	if isMyChaos then
		durability = self.myDurability
	else
		durability = self.otherDurability
	end

	return durability and durability or data and data.RemainDurability or 0
end

function M:RefreshChaosDurability(store, durability, data)
	if not store.durabilityText then
		store.durabilityText = durability
	elseif durability < store.durabilityText and (not data or not store.lastPokemonId or store.lastPokemonId == data.PokemonId) then
		local ani = store.durabilityAni
		local clip = ani:GetClip("S_CMHudTopTemplate_durability")
		local length = clip.length

		gBattleMgr:CommonPlayAniTool(ani, "S_CMHudTopTemplate_durability", 0, 1, true)

		self.durabilityTextTween = DOTween.To(function ()
			return store.durabilityText or 0
		end, function (value)
			store.durabilityText = math.ceil(value)
		end, durability, length):SetEase(Ease.Linear):OnComplete(function ()
			store.durabilityText = durability
		end)
	else
		store.durabilityText = durability
	end
end

function M:RefreshPrepareChaosDurability(store, data, cb)
	local index = data.chaosData.PokemonId

	local function cb()
		store.durabilityCtrl = TabType.Hide
	end

	if not self.chaosDurability[index] then
		store.durabilityText = data.RemainDurability

		if cb then
			cb()
		end
	else
		if data.RemainDurability < self.chaosDurability[index] then
			local ani = store.durabilityAni
			local clip = ani:GetClip("S_ChaosHead_durability")
			local length = clip.length

			function cb()
				gLuaTimeMgrUtils.NotDestroyDelay(function ()
					if store then
						store.durabilityCtrl = TabType.Hide
					end
				end, length)
			end

			gBattleMgr:CommonPlayAniTool(ani, "S_ChaosHead_durability", 0, 1, true, cb)
			DOTween.To(function ()
				return store.durabilityText or 0
			end, function (value)
				store.durabilityText = math.ceil(value)
			end, data.RemainDurability, length):SetEase(Ease.Linear):OnComplete(function ()
				store.durabilityText = data.RemainDurability
			end)

			return
		end

		store.durabilityText = data.RemainDurability

		if cb then
			cb()
		end
	end
end

function M:RefreshChaosSelect(widget, isMyChaos)
	local store = gStoreManager:GetStoreGroup("CMHudTopTemplate"):GetStoreByWidget(widget)
	local select = self.curRightChaosSelectIndex == 0

	if isMyChaos then
		select = self.curLeftChaosSelectIndex == 0
	end

	store.FirstChaosInfoBtn:SetSelected(select)
	self:RefreshPrepareList(store.prepareList, isMyChaos)
end

function M:RefreshPrepareList(store, isMyChaos, showAll)
	local chaosList = isMyChaos and gBattlePetsMgr.myChaosList or gBattlePetsMgr.enemyChaosList
	local list = {}

	if not chaosList or #chaosList == 0 then
		store:SetList(list)

		return
	end

	for i = 1, chaosList.Count do
		local chaos = chaosList[i]

		if not chaos.IsActive or showAll then
			local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(chaos.TemplateId)
			local playDurabilityAni = self.chaosDurability[chaos.PokemonId] and chaos.RemainDurability < self.chaosDurability[chaos.PokemonId]
			local playDeadAni = self.chaosDurability[chaos.PokemonId] and self.chaosDurability[chaos.PokemonId] > 0 and chaos.RemainDurability == 0
			local item = {
				iconId = cfg.HeadIconID,
				deadCtrl = chaos.RemainDurability == 0 and 0 or 1,
				index = i,
				isMyChaos = isMyChaos,
				chaosData = chaos,
				selected = i == (isMyChaos and self.curLeftChaosSelectIndex or self.curRightChaosSelectIndex),
				RemainDurability = chaos.RemainDurability,
				playDeadAni = playDeadAni
			}

			if not showAll then
				item.playDurabilityAni = playDurabilityAni
			end

			table.insert(list, item)
		end
	end

	store:SetList(list)
end

function M:RefreshPokemonHp(isMyPokemon, curFill, isFirst)
	local store = isMyPokemon and self.LTopPokemon or self.RTopPokemon

	if not self.STATE_EnableOnce or not store or not store.hpCom then
		return
	end

	local isAddValue = store.hpCom.fill.fillAmount < curFill

	if isAddValue then
		store.healHpCom.fillAmount = curFill
		store.weakHpCom.fillAmount = curFill

		if isFirst then
			store.hpCom:ResetValue(curFill, 0, 0, 1)
		else
			store.hpCom:ProgressToValue(curFill, 1)
		end
	else
		store.healHpCom.fillAmount = curFill

		store.hpCom:ResetValue(curFill, 0, 0, 1)

		if isFirst then
			store.weakHpCom.fillAmount = curFill
		else
			AnimMgr.DoFill(store.weakHpCom, "ChaosHpDelTween_" .. store.m_Id, curFill, 1, 0, DG.Tweening.Ease.OutCirc, nil, false)
		end
	end
end

function M:RefreshPokemonEnergy(isMyPokemon, curFill, isFirst)
	local store = isMyPokemon and self.LTopPokemon or self.RTopPokemon

	if not store then
		return
	end

	if store.energyProgress.value < 1 and curFill >= 1 then
		gBattleMgr:CommonPlayAniTool(store.energyAni, "S_CMHudTopTemplate_energy", 0, 1, true)
	end

	store.energyProgress:ProgressToValue(curFill, 0.3)
end

function M:EnableChaosInfoTab(enable)
	if not self.STATE_EnableOnce then
		return
	end

	self.bindData.showChaosInfoCtrl = enable and TabType.Show or TabType.Hide

	if enable then
		self:EnableGenreInfoTab(false)
	else
		self.recordClickChaosInfo = nil
		self.curLeftChaosSelectIndex = -1
		self.curRightChaosSelectIndex = -1

		self:RefreshAllChaosInfoSelect()
	end

	self:EnableFullScreenBtn(enable)
end

function M:RefreshChaosInfoTab(isMyChaos, data)
	self.chaosInfo = gStoreManager:GetStoreGroup("ChaosInfoPanelStore")

	self.chaosInfo:OnShow(nil, {
		showGenreDetail = true,
		curChaosData = data.chaosData,
		isMyChaos = isMyChaos
	})
	self:EnableChaosInfoTab(true)

	if data.isMyChaos then
		self.curLeftChaosSelectIndex = data.index
		self.curRightChaosSelectIndex = -1
	else
		self.curRightChaosSelectIndex = data.index
		self.curLeftChaosSelectIndex = -1
	end

	self:RefreshAllChaosInfoSelect()
end

function M:RefreshGenreInfoTab(isLeft, data)
	self:EnableGenreInfoTab(true, data.isLeft)
	self:BuildGenreInfoTab(data.cfg.Id, data.isLeft)

	if data.isLeft then
		self.curLeftGenreSelectIndex = data.index
		self.curRightGenreSelectIndex = -1
	else
		self.curRightGenreSelectIndex = data.index
		self.curLeftGenreSelectIndex = -1
	end

	self:RefreshGenreList(true)
	self:RefreshGenreList(false)
end

function M:OnRefreshBuffs(eventId, pid)
	if not gBattlePetsMgr:CheckIsBVBUnit(pid) then
		return
	end

	if gBattlePetsMgr:CheckIsMyChaos(pid) then
		self:RefreshPokemonBuff(true, pid)
	elseif not gBattlePetsMgr:CheckIsMyChaos(pid) then
		self:RefreshPokemonBuff(false, pid)
	end
end

function M:RefreshPokemonBuff(isMyPokemon, pid)
	local store = isMyPokemon and self.LTopPokemon or self.RTopPokemon

	if not store or not store.buffList then
		return
	end

	local allBuffs = gBuffUtils.GetCSBuffList(pid)

	if #allBuffs == 0 or pid == 0 then
		store.buffList:SetList({})

		return
	end

	local max_conut = 5
	local maybeBuffs = {}

	for i = 1, #allBuffs do
		local id = allBuffs[i].Id

		if table.contains(LTConfig.ChaosMasterConfig.TagBuffNameList, id) then
			table.insert(maybeBuffs, allBuffs[i])
		end
	end

	self.showBuffs = {}

	if max_conut < #maybeBuffs then
		for i = #maybeBuffs - 4, #maybeBuffs do
			table.insert(self.showBuffs, maybeBuffs[i])
		end
	else
		self.showBuffs = maybeBuffs
	end

	if #self.showBuffs == 0 then
		store.buffList:SetList({})

		return
	end

	local items = {}

	for i = 1, max_conut do
		local iconId = 0
		local isShowCD = false
		local tier = ""
		local cfg = nil

		if i <= #self.showBuffs then
			cfg = LTConfig.BuffConfig.GetConfig(self.showBuffs[i].Id)
			iconId = cfg.IconIdSGUI
			isShowCD = cfg.IsHidden

			if self.showBuffs[i].Tier and self.showBuffs[i].Tier > 1 then
				tier = self.showBuffs[i].Tier
			end
		end

		if cfg then
			local item = {
				iconId = iconId,
				isShowCD = isShowCD,
				tier = tier,
				cfg = cfg
			}

			table.insert(items, item)
		end
	end

	store.buffList:SetList(items)
end

function M:GetOtherPlayerName()
	if gBattlePetsMgr.bvbOnlineType == gBattlePetsMgr.BVBOnlineType.Single then
		local cfg = LTConfig.ChaosMasterChaosBattleNpcConfig.GetConfig(gBattlePetsMgr.currentLevelNpcId)
		local npcCfg = LTConfig.AgentConfig.GetConfig(cfg.NormalNpcId)

		return npcCfg.Name
	else
		local memberInfo = gLinkManager:GetMemberInfo(gBattlePetsMgr.otherPlayerPid)

		return memberInfo and memberInfo.Name or ""
	end
end

function M:RefreshGenreList(isLeft, tagInfos, tagRefreshInfos)
	local allGenreList = gBattlePetsMgr.allGenreList
	local list = {}

	for i = 1, #allGenreList do
		local cfg = allGenreList[i]
		local tagType = gBattlePetsMgr:GetCurrentGenreType(cfg.Id)

		if tagType ~= gBattlePetsMgr.GenreTagType.Hide then
			local tagInfo = isLeft and gBattlePetsMgr.tagInfoDic[cfg.Id] or gBattlePetsMgr:GetTagInfo(cfg.Id, isLeft)
			local expFz = tagInfo and tagInfo.TagExp or 0
			local level = tagInfo and tagInfo.TagLevel or 0
			local nextLevel = LTConfig.ChaosMasterConfig.TagMaxLevel < level + 1 and LTConfig.ChaosMasterConfig.TagMaxLevel or level + 1
			local expFm = LTConfig.ChaosMasterConfig.TagExp[nextLevel]
			local levelActiveCtrl = gBattlePetsMgr:GetGenreLevelCtrlType(cfg.Id, isLeft)
			local playRefreshAni, playLevelUpAni = self:CheckPlayGenreAni(tagInfo and tagInfo.TagId or 0, tagInfos, tagRefreshInfos)
			local item = {
				iconId = cfg.SImageId,
				levelActiveCtrl = levelActiveCtrl,
				levelNum = tagInfo and tagInfo.TagLevel or 0,
				expNum = expFz,
				expFm = expFm,
				genreExpCtrl = levelActiveCtrl > 0 and 1 or 0,
				cfg = cfg,
				index = i,
				isLeft = isLeft,
				selected = i == (isLeft and self.curLeftGenreSelectIndex or self.curRightGenreSelectIndex),
				playRefreshAni = playRefreshAni,
				playLevelUpAni = playLevelUpAni
			}

			table.insert(list, item)
		end
	end

	table.sort(list, function (a, b)
		if a.levelActiveCtrl == b.levelActiveCtrl then
			return b.expNum < a.expNum
		end

		return b.levelActiveCtrl < a.levelActiveCtrl
	end)

	if isLeft then
		self.bindData.genreList:SetList(list)
	else
		self.bindData.otherGenreList:SetList(list)
	end
end

function M:CheckPlayGenreAni(id, tagInfos, tagRefreshInfos)
	local data = tagRefreshInfos and tagRefreshInfos[id] or nil

	if data and (data.isActive or data.isLevelUp) then
		return false, true
	end

	if tagInfos then
		for i = 1, tagInfos.Count do
			if tagInfos[i].TagId == id then
				return true, false
			end
		end
	end

	return false, false
end

function M:EnableGenreInfoTab(enable, isLeft)
	self.bindData.genreDetailCtrl = enable and (isLeft and GenreDetailType.Left or GenreDetailType.Right) or GenreDetailType.Hide

	if enable then
		self:EnableChaosInfoTab(false)
	else
		self.recordClickGenreInfo = nil
		self.curLeftGenreSelectIndex = -1
		self.curRightGenreSelectIndex = -1

		self:RefreshGenreList(true)
		self:RefreshGenreList(false)
	end

	self:EnableFullScreenBtn(enable)
end

function M:BuildGenreInfoTab(genreId, isLeft)
	if self.bindData.genreDetailCtrl == GenreDetailType.Hide then
		return
	end

	local widget = self.bindData.genreDetailCtrl == GenreDetailType.Left and self.bindData.myGenreDetail or self.bindData.otherGenreDetail
	local genreDetail = self:GetStoreByWidget(widget)
	local store = gStoreManager:GetStoreGroup("GenreDetailTemplate"):GetStoreByWidget(genreDetail.genreInfo)
	local cfg = LTConfig.ChaosMasterChaosTagConfig.GetConfig(genreId)
	local tagInfo = isLeft and gBattlePetsMgr.tagInfoDic[genreId] or gBattlePetsMgr:GetTagInfo(genreId, isLeft)
	local level = tagInfo and tagInfo.TagLevel or 0
	local expFz = tagInfo and tagInfo.TagExp or 0
	local nextLevel = LTConfig.ChaosMasterConfig.TagMaxLevel < level + 1 and LTConfig.ChaosMasterConfig.TagMaxLevel or level + 1
	local expFm = LTConfig.ChaosMasterConfig.TagExp[nextLevel]

	if store and cfg then
		store.iconId = cfg.SImageId
		store.name = cfg.Name
		store.des = gBattlePetsMgr:BuildDescriptionStrByValueList(cfg.Effect, cfg.BuffParameter, cfg.StarUpParametersType, level, true)
		store.level = "Lv." .. (tagInfo and tagInfo.TagLevel or 0)
		store.expText = expFz .. "/" .. expFm

		store.ExpProgress:ResetValue(expFz / expFm, 0, 0, 1)
	end

	self:RefreshGenreBuffList(genreDetail, genreId, isLeft)
end

function M:RefreshGenreBuffList(store, genreId, isLeft)
	local buffList = isLeft and gBattlePetsMgr.myGenreBuffDic[genreId] or gBattlePetsMgr.enemyGenreBuffDic[genreId]

	if not buffList then
		store.buffList:SetList({})

		return
	end

	local list = {}

	for i = 1, #buffList do
		local cfg = LTConfig.ChaosMasterChaosBuffConfig.GetConfig(buffList[i])

		if cfg then
			local level = gBattlePetsMgr:GetBuffLevel(buffList[i], isLeft)
			local item = {
				iconId = cfg.SImageId,
				name = cfg.Name,
				des = gBattlePetsMgr:BuildDescriptionStrByValueList(cfg.Description, cfg.BuffParameter, cfg.StarUpParametersType, level, true),
				qualityCtrl = cfg.Quality - 1,
				level = level,
				cfg = cfg
			}

			table.insert(list, item)
		end
	end

	table.sort(list, function (a, b)
		if a.qualityCtrl == b.qualityCtrl then
			return b.level < a.level
		end

		return b.qualityCtrl < a.qualityCtrl
	end)
	store.buffList:SetList(list)
end

function M:SwitchView(type)
	self.switchViewType = type

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self:EnableDamageTab(type == SwitchViewType.Dps)
	end

	self:EnableRightGenreTab(type == SwitchViewType.GenreList)
	self:EnableRightOnlineMemberTab(type == SwitchViewType.OnlineMember)
end

function M:EnableRightGenreTab(enable)
	self.bindData.rightSwitchBtnCtrl = enable and 0 or self.bindData.rightSwitchBtnCtrl
	self.bindData.showRightGenreListCtrl = enable and TabType.Show or TabType.Hide
end

function M:EnableRightOnlineMemberTab(enable)
	self.bindData.rightSwitchBtnCtrl = enable and 2 or self.bindData.rightSwitchBtnCtrl
end

function M:EnableDamageTab(enable)
	self.showDpsCtrl = enable
	self.dpsTabType = DamageTabType.DamageOther
	self.bindData.rightSwitchBtnCtrl = enable and 1 or self.bindData.rightSwitchBtnCtrl
	local store = self:GetStoreByWidget(self.bindData.dps)

	if store then
		self:RefreshDamageTab(store)
		self:RefreshDamageList(DamageTabType.DamageOther)
	end
end

function M:RefreshDamageTab(store)
	local tab1 = {
		name = LTConfig.TextScriptTextConfig.GetConfig(89901160).Text,
		type = DamageTabType.DamageOther,
		selected = self.dpsTabType == DamageTabType.DamageOther
	}
	local tab2 = {
		name = LTConfig.TextScriptTextConfig.GetConfig(89901161).Text,
		type = DamageTabType.Damaged,
		selected = self.dpsTabType == DamageTabType.Damaged
	}
	local list = {}

	table.insert(list, tab1)
	table.insert(list, tab2)
	store.dpsTab:SetList(list)

	if self.switchBtn then
		self.switchBtn.ArrowTypeCtrl = self.dpsTabType == DamageTabType.DamageOther and DamageTabType.Damaged or DamageTabType.DamageOther
	end
end

function M:RefreshDamageList(type)
	self.damageTabType = type or self.damageTabType
	local list = {}

	for i = 1, #gBattlePetsMgr.damageList do
		local damage = gBattlePetsMgr.damageList[i]

		if self.damageTabType == damage.DamageType then
			local isSkill = damage.SourceType == UX.Game.BVBDamageSourceType.Skill
			local cfg = LTConfig.ChaosMasterChaosSkillConfig.GetConfig(damage.ConfigId)
			local iconId = cfg and cfg.Icon or 0

			if not isSkill then
				cfg = LTConfig.ChaosMasterChaosTagConfig.GetConfig(damage.ConfigId)
				iconId = cfg and cfg.SImageId or 0
			end

			local percent = string.format("%d", math.floor(damage.Value / gBattlePetsMgr:GetAllDamage(damage.DamageType) * 100))

			if cfg then
				local item = {
					iconId = iconId,
					skillName = cfg.Name,
					value = damage.Value .. "(" .. percent .. "%)",
					fill = damage.Value / gBattlePetsMgr:GetMaxDamage(damage.DamageType)
				}

				table.insert(list, item)
			end
		end
	end

	local store = self:GetStoreByWidget(self.bindData.dps)

	store.dpsList:SetList(list)
end

function M:EnableCutInTab(isMyChaos)
	if isMyChaos then
		self.enableLeftCutIn = true
		self.bindData.showLeftCutInCtrl = TabType.Show
		self.leftCutInTime = Time.time + LTConfig.ChaosMasterConfig.CutInTime
	else
		self.enableRightCutIn = true
		self.bindData.showRightCutInCtrl = TabType.Show
		self.rightCutInTime = Time.time + LTConfig.ChaosMasterConfig.CutInTime
	end
end

function M:DisableCutInTab(isMyChaos)
	if isMyChaos then
		self.enableLeftCutIn = false
		self.bindData.showLeftCutInCtrl = TabType.Hide
	else
		self.enableRightCutIn = false
		self.bindData.showRightCutInCtrl = TabType.Hide
	end
end

function M:UpdateCutIn()
	if self.enableLeftCutIn and self.leftCutInTime < Time.time then
		self:DisableCutInTab(true)
	end

	if self.enableRightCutIn and self.rightCutInTime < Time.time then
		self:DisableCutInTab(false)
	end
end

function M:RefreshCutInTab(isMyChaos)
	local cutIn = isMyChaos and self.leftCutIn or self.rightCutIn
	local data, cfg = gBattlePetsMgr:GetCurrentRoundChaosDataAndConfig(isMyChaos)

	if not data or not cfg then
		return
	end

	local posData = cfg.ImageScaleOffset
	cutIn.chaosIcon = cfg.Icon

	cutIn.imageTrans:SetLocalScaleXY(posData[1], posData[1])
	cutIn.imageTrans:SetLocalPositionXY(posData[2], posData[3])
end

function M:SetBVBRoundEnd(result, bonus, nextRoundStartTime, myDurability, otherDurability)
	self:RefreshDDLType(gBattlePetsMgr.BVBDDLType.RoundEnd)
	self:RefreshRoundResult(result, nextRoundStartTime)
	self:RefreshDDL(nextRoundStartTime + gLogicTime.time, function ()
		self:CloseRoundResult()
	end)
	self:DisPlayRoundBonus(bonus)

	self.myDurability = myDurability
	self.otherDurability = otherDurability

	self:RefreshAllChaosDurability()

	self.myDurability = nil
	self.otherDurability = nil
end

function M:RefreshRoundResult(result)
	if result == UX.Game.BVBEndType.Win then
		self.bindData.showSettlementCtrl = RoundResult.Win
	else
		self.bindData.showSettlementCtrl = RoundResult.Lose
	end
end

function M:DisPlayRoundBonus(bonus, nextRoundStartTime)
	local cfg = LTConfig.ChaosMasterConfig
	local msg = cfg.BonusText[1] .. ": "
	local msg = msg .. cfg.BonusText[2] .. "*" .. bonus.Basic

	if bonus.WinBonus > 0 then
		msg = msg .. "、" .. cfg.BonusText[3] .. "*" .. bonus.WinBonus
	end

	if bonus.StreakLength > 0 then
		msg = msg .. "、" .. string.format(cfg.BonusText[4], bonus.StreakLength) .. "*" .. bonus.StreakBonus
	end

	self.bindData.shoRewardCtrl = TabType.Show
	self.bindData.rewardStr = msg
end

function M:CloseRoundResult()
	self.bindData.showSettlementCtrl = RoundResult.Hide
	self.bindData.shoRewardCtrl = TabType.Hide
end

function M:RefreshDDLType(type, round)
	local cfg = LTConfig.ChaosMasterConfig
	self.roundNum = round or self.roundNum
	self.roundType = type

	if type == gBattlePetsMgr.BVBDDLType.Prepare then
		self.bindData.countDownStage = cfg.CountDownTypeText[1]
	elseif type == gBattlePetsMgr.BVBDDLType.Battle then
		self.bindData.countDownStage = string.format(cfg.CountDownTypeText[2], self.roundNum)
	elseif type == gBattlePetsMgr.BVBDDLType.RoundEnd then
		self.bindData.countDownStage = cfg.CountDownTypeText[3]
	elseif type == gBattlePetsMgr.BVBDDLType.GameEnd then
		self.bindData.countDownStage = cfg.CountDownTypeText[3]
	end
end

function M:RefreshDDL(ddl, cb)
	self.enableDLLUpdate = true
	gBattlePetsMgr.countDown = ddl
	self.bindData.countDown = ddl

	self:RegisterCountDownCallBack(cb)
end

function M:EndDDL()
	self.bindData.countDown = 0
	self.enableDLLUpdate = false

	if self.ddlCallBack then
		self.ddlCallBack()
	end
end

function M:UpdateDDL()
	if not self.bindData.countDown or self.bindData.countDown <= 0 or gBattlePetsMgr.countDown == "" then
		self:EndDDL()

		return
	end

	self.bindData.countDown = math.ceil(math.max(0, gBattlePetsMgr.countDown - gLogicTime.time))
end

function M:RegisterCountDownCallBack(cb)
	self.ddlCallBack = cb
end

function M:EnableCamera(playerIndex)
	local npcCfg = LTConfig.ChaosMasterChaosBattleNpcConfig.GetConfig(gBattlePetsMgr.currentLevelNpcId)

	if not npcCfg then
		-- Nothing
	end

	local sceneId = npcCfg.ChaosBattleSceneId

	if not sceneId then
		return
	end

	local sceneCfg = LTConfig.ChaosMasterChaosBattleSceneConfig.GetConfig(sceneId)

	if not sceneCfg then
		return
	end

	local pos = Vector3.New(sceneCfg.BattleCenterPosition[1], sceneCfg.BattleCenterPosition[2], sceneCfg.BattleCenterPosition[3])
	playerIndex = playerIndex or 1
	local eulerCfg = playerIndex == 1 and sceneCfg.CameraOne or sceneCfg.CameraTwo
	local camDirection = nil

	if #eulerCfg >= 3 then
		local rot = Quaternion.Euler(45, eulerCfg[2] + sceneCfg.BattleCenterRotation, eulerCfg[3])
		camDirection = rot * Vector3.New(0, 0, 1)
	end

	self.initCameraPos = pos + Vector3.up
	self.lastCameraPos = pos + Vector3.up
	self.targetCameraPos = pos + Vector3.up

	gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(pos, LTConfig.CameraFreeLookActionStatusConfig.BVB, 0, nil, camDirection)
	gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(0.5, 1)
end

function M:SwitchCameraMode(isFree)
	self.isFreeCamera = not self.isFreeCamera

	if isFree ~= nil then
		self.isFreeCamera = isFree
	end

	if self.isFreeCamera then
		self:EnableFullScreenBtn(false)
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.CHAOS_MASTER_HUD_PANEL, true)
	else
		self:EnableFullScreenBtn(true)
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.CHAOS_MASTER_HUD_PANEL, false)
	end

	local tipId = self.isFreeCamera and 379 or 380

	self:RefreshSwitchCameraTips(tipId)
	self:OnRightStickControl(nil)
end

function M:RefreshSwitchCameraTips(tipId)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local buttonInfoIndex = 3

	if gBattleMgr.scheme == SGUI.GameDevice.KeyboardMouse then
		self.bindData.switchCameraBtn:SetPCKeyInfoTipNameId(tipId)
	else
		self.bindData.gamePadArea:SetButtonInfoTipNameId(tipId, buttonInfoIndex)
	end
end

function M:EnableFullScreenBtn(enable)
	if not self.isFreeCamera and gCS.LuaUtils.GetActiveDevice() <= SGUI.GameDevice.KeyboardMouse then
		enable = true
	end

	self.bindData.fullScreenBackBtn:SetActive(enable)
end

function M:UpdateCameraPos()
	self.curUpdateCameraPosCD = self.curUpdateCameraPosCD - gLogicTime.deltaTime

	if self.curUpdateCameraPosCD > 0 or self.disableUpdateCameraPos then
		return
	end

	self.curUpdateCameraPosCD = LTConfig.ChaosMasterConfig.CameraMoveCD or 1
	local myChaos = gBattlePetsMgr.myChaos
	local enemyChaos = gBattlePetsMgr.enemyChaos
	local center = self.initCameraPos

	if myChaos and enemyChaos then
		local myChaosUnit, enemyChaosUnit = nil

		if myChaosUnit and enemyChaosUnit then
			center = (myChaosUnit.position + enemyChaosUnit.position) * 0.5
		end
	end

	local dir = center - self.initCameraPos
	dir.y = 0
	local dis = dir:Magnitude()

	if self.cameraMaxRadius < dis then
		dis = self.cameraMaxRadius or dis
	end

	local pos = self.initCameraPos + dir.normalized * dis
	self.targetCameraPos = pos
end

function M:DoUpdateCameraPos()
	if not self.targetCameraPos then
		return
	end

	local delta = Vector3.Distance(self.targetCameraPos, self.lastCameraPos or self.initCameraPos)
	self.lastCameraPos = self.lastCameraPos + (self.targetCameraPos - self.lastCameraPos).normalized * delta / self.cameraSpeed

	gCS.CameraDataMgr.cinemachineManager.commonAssignableTarget:SetPosition(self.lastCameraPos)
end

function M:ResetToInitCameraPos(updateCameraPos)
	self.disableUpdateCameraPos = not updateCameraPos
	self.lastCameraPos = self.initCameraPos
	self.targetCameraPos = self.initCameraPos

	gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(self.initCameraPos, LTConfig.CameraFreeLookActionStatusConfig.BVB)
end

function M:EnableBattleSelect(enable, ddl)
	self.bindData.battleSelectCtrl = enable and TabType.Show or TabType.Hide

	self:CheckShowTopChaosList()
	self:RefreshDamageList()
	self:ResetToInitCameraPos(not enable)

	if enable then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.gamePadArea

		self.bindData.gamePadArea:SelectDefaultContent()
		self:RefreshDDLType(gBattlePetsMgr.BVBDDLType.Prepare)
		self:ClearHUD()
		gStoreManager:GetStoreGroup("ChaosBattleSelectPanelStore"):OnShow()
		self:RefreshGenreList(true)
		self:RefreshGenreList(false)
		self:RefreshPrepareList(self.bindData.battleSelectMyChaosList, true, true)
		self:RefreshPrepareList(self.bindData.battleSelectEnemyChaosList, false, true)
		self:RefreshDDL(gLogicTime.time + ddl)

		self.oldCameraType = self.isFreeCamera

		self:SwitchCameraMode(false)
	else
		self:SwitchCameraMode(self.oldCameraType)
	end
end

function M:EnableHud(enable)
	self.bindData.hudCtrl = enable and TabType.Show or TabType.Hide
end

function M:ClearHUD()
	self:OnClickFullScreenBackBtn()
	self:CloseRoundResult()
	self:SwitchView(SwitchViewType.GenreList)
end
