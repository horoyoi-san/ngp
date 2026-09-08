-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityV2PanelStore.lua
-- Decompiled from: 01136_UrbanAbilityV2PanelStore.lua_27bb3b2d1a8a.luajit

local AnimMgr = SGUI.AnimMgr
local MODEL_SWITCH_TWEEN_ID = "UrbanAbilityModelSwitch"
local MODEL_SWITCH_TIMEOUT = 0.5
C_UrbanAbilityV2PanelStore = DefClass("C_UrbanAbilityV2PanelStore", C_UrbanAbilityV2PanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityV2PanelStore = C_UrbanAbilityV2PanelStore
local M = C_UrbanAbilityV2PanelStore

M.ctor = function(self)
	self.Empty = {
		["\\x85\\xbe\\x8eg.\\xea*"] = 0,
		["h\\xa3\\xb2\\xbb\\xaf"] = 1
	}
	self.Active = {
		["\\x9e\\xbf$\\xa8~7\\xe86"] = 1,
		["=K\\x85\\x87\\x95D"] = 0
	}
	self.fadeInOutTime = LTConfig.UrbanAbilityConfig.PanelFadeInOutTime
end

M.DefineAllVariables = function(self)
	self.defaultId = nil
	self.defaultData = nil
	self.curTabNavArea = nil
	self.curOpenedAbilityType = nil
	self.modelSwitchVersion = 0
end

M.DefineAllEnumsAutoGen = function(self)
	self.ShowMainPageCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.ShowMainPageCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_URBAN_ABILITY_PANEL) and 1 or 0
end

M.OnShow = function(self, panelId, data)
	self._listData = nil
	self._waitingSpiritPanelData = true
	self.bindData.modelTab.selectedIndex = 0
	local needDefaultSelect = false
	self.defaultTargetTid = nil
	self.curOpenedAbilityType = nil

	if data then
		if data.tab then
			self.defaultId = data.tab
			self.defaultData = data
			needDefaultSelect = true
		else
			self.defaultId = nil
			self.defaultData = nil
		end

		if data.selectedTid then
			self.defaultTargetTid = data.selectedTid
		end
	end

	self.SetSpiritList(self)

	if needDefaultSelect then
		self.DefaultSelect(self)
	end

	self.defaultTargetTid = nil

	gUrbanAbilityManager:GetAllSpiritPanelData()
	gUrbanAbilityManager:SetPanelEnterTime()
	gCS.LuaUtils.SetUrbanAbility(true)

	self.lastTabRectId = -1
end

M.OnEnable = function(self)
	self.tid = nil
	self.changeSpiritOnce = nil

	self.InitModelBg(self)
end

M.OnDisable = function(self)
	self.ResetModelSwitch(self)
end

M.OnGroupDisable = function(self)
end

M.OnClose = function(self)
	self.ResetModelSwitch(self)

	self.subModelStore = nil

	gCS.LuaUtils.SetUrbanAbility(false)
end

M.OnDestroy = function(self)
	self:ResetModelSwitch()
	gCS.LuaUtils.SetUrbanAbility(false)
	gUrbanAbilityManager:PanelExitTime()
	self:ClearMessageEvents()

	if self.btnTimer then
		self.btnTimer:Stop()

		self.btnTimer = nil
	end

	if self.changeSpiritTimer then
		self.changeSpiritTimer:Stop()

		self.changeSpiritTimer = nil
	end

	if self.isClosing then
		gBlackScreenManager:ClearTransition(gPanelId.S_URBAN_ABILITY_PANEL, true)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnLuaPlatformAdaptor = function(self, scale)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_CHANGE_JOBTAB] = self.CreateAction(self, "OnChangeJobTab"),
		[gEventConstants.ON_SYNC_SPIRIT_ABILITYINFO] = self.CreateAction(self, "SyncSpiritAbilityInfo"),
		[gEventConstants.ON_SYNC_URBAN_BADGEINFO] = self.CreateAction(self, "SyncUrbanBadgeInfo"),
		[gEventConstants.ON_SYNC_SPIRIT_URBAN_ATTRS] = self.CreateAction(self, "SyncSpiritUrbanAttrs"),
		[gEventConstants.ON_ASK_ALL_SPIRIT_PANEL_DATA] = self.CreateAction(self, "OnAllSpiritPanelData"),
		[gEventConstants.SPIRIT_COMBAT_POWER_CHANGED] = self.CreateAction(self, "SetCombatPower")
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.bindData.changeBtn.luaClick = self.CreateAction(self, "OnChangeBtnClick")
	self.bindData.changeAreaBtn.luaClick = self.CreateAction(self, "OnClickChangeAreaBtn")
	self.bindData.dimensionBtn.luaClick = self.CreateAction(self, "OnClickDimensionBtn")
	self.bindData.badgeBtn.luaClick = self.CreateAction(self, "OnClickBadgeBtn")
	self.bindData.spiritList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSpiritItem")
	self.bindData.abilityList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderAbilityItem")
	self.bindData.occupationList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderOccupationListItem")
	self.bindData.badgeCountList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderBadgeCountListItem")
	self.bindData.spiritList.luaSelectedChanged = self.CreateAction(self, "OnSpiritItemSelectedChange")
	self.bindData.abilityList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickAbilityList")
	self.bindData.occupationList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickOccupationList")
	self.bindData.curWidget.luaPlatformAdaptor = self.CreateAction(self, "OnLuaPlatformAdaptor")

	if self.bindData.QBtn then
		self.bindData.QBtn.luaClick = self.CreateAction(self, "OnQBtnClick")
	end

	if self.bindData.EBtn then
		self.bindData.EBtn.luaClick = self.CreateAction(self, "OnEBtnClick")
	end

	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.modelTab.OnRenderTab = self.CreateAction(self, "OnModelPanelDisplay")
	self.bindData.navigationArea.luaAreaIn = self.CreateAction(self, "OnRootAreaIn")
end

M.InitModelBg = function(self)
	self.bindData.imgBg.renderOpacity = 1

	self.bindData.imgBg.gameObject:SetActive(true)
end

M.HideModelBg = function(self)
	self.bindData.imgBg.renderOpacity = 0

	self.bindData.imgBg.gameObject:SetActive(false)
end

M.StopModelSwitchTimeout = function(self)
	if self.modelSwitchTimeoutTimer then
		self.modelSwitchTimeoutTimer:Stop()

		self.modelSwitchTimeoutTimer = nil
	end
end

M.ResetModelSwitch = function(self)
	self.modelSwitchVersion = self.modelSwitchVersion + 1
	self.isModelSwitching = nil

	self.StopModelSwitchTimeout(self)
	AnimMgr.Kill(self.bindData.imgBg.transform, MODEL_SWITCH_TWEEN_ID)
	self.HideModelBg(self)
end

M.FinishModelSwitch = function(self, version, force)
	if self.modelSwitchVersion == version or not self.isModelSwitching or not self.bindData.imgBg.gameObject.activeInHierarchy then
		return
	end

	if not force and (not self.subModelStore.wrapperReady or not self.subModelStore.modelReady) then
		return
	end

	self.isModelSwitching = nil

	self.StopModelSwitchTimeout(self)
	AnimMgr.Kill(self.bindData.imgBg.transform, MODEL_SWITCH_TWEEN_ID)
	AnimMgr.DoAlpha(self.bindData.imgBg, MODEL_SWITCH_TWEEN_ID, 0, self.fadeInOutTime[2], 0, DG.Tweening.Ease.Linear, function ()
		if self.modelSwitchVersion ~= version then
			self:HideModelBg()
		end
	end)
end

M.SwitchModel = function(self, tid)
	local modelStore = self.subModelStore

	if modelStore.tid ~= 0 then
		modelStore.LoadModel(modelStore, tid)

		return
	end

	if modelStore.tid ~= tid and not self.isModelSwitching then
		modelStore.LoadModel(modelStore, tid)

		return
	end

	self.modelSwitchVersion = self.modelSwitchVersion + 1
	local version = self.modelSwitchVersion
	self.isModelSwitching = true

	self:StopModelSwitchTimeout()
	AnimMgr.Kill(self.bindData.imgBg.transform, MODEL_SWITCH_TWEEN_ID)

	slot4 = self.bindData.imgBg.gameObject

	slot4:SetActive(true)
	AnimMgr.DoAlpha(self.bindData.imgBg, MODEL_SWITCH_TWEEN_ID, 1, self.fadeInOutTime[1], 0, DG.Tweening.Ease.Linear, function ()
		if self.modelSwitchVersion == version or not self.isModelSwitching or not self.bindData.imgBg.gameObject.activeInHierarchy then
			return
		end

		slot1 = Timer.New(function ()
			self:FinishModelSwitch(version, true)
		end, MODEL_SWITCH_TIMEOUT, 1, true)
		self.modelSwitchTimeoutTimer = slot1:Start()
		slot0 = modelStore

		slot0:LoadModel(tid, function ()
			self:FinishModelSwitch(version)
		end)
	end)
end

M.DefaultSelect = function(self)
	if not self.defaultId then
		return
	end

	self.bindData.tabRect.selectedIndex = self.defaultId
end

M.SetSpiritList = function(self)
	self.spiritList = gUrbanAbilityManager:GetAllLingList()
	self.spiritIndexList = {}
	local ulistData = {}
	local targetTid = self:GetCurSpiritTid()

	for i, v in pairs(self.spiritList) do
		local cfg = LTConfig.FightSpiritConfig.GetConfig(v.Id)

		if not cfg then
			print_error("SetSpiritList Not Find FightSpirit  Id = " .. v.Id)

			return
		end

		local info = {
			id = v.Id,
			selected = v.Id ~= targetTid,
			cfg = cfg,
			alreadyJoin = true
		}

		table.insert(ulistData, info)
	end

	self._spiritListData = ulistData
	local selectIdx = -1

	for i, v in ipairs(ulistData) do
		if v.selected then
			selectIdx = i - 1

			break
		end
	end

	self.bindData.spiritList:SetSimpleList(#ulistData)

	if selectIdx > 0 then
		self.bindData.spiritList:SelectItem(selectIdx, true)
	end

	self.bindData.spiritList:GoToIndex(self.bindData.spiritList.selectedIndex, true)
end

M.GetCurSpiritTid = function(self)
	if self.defaultTargetTid then
		return self.defaultTargetTid
	end

	if not self.tid then
		return gSpiritManager:GetCurFirstSpiritTid()
	end

	return self.tid
end

M.ChangeSpiritViewData = function(self, spiritId)
	if self.changeSpiritTimer then
		self.changeSpiritTimer:Stop()

		self.changeSpiritTimer = nil
	end

	local apply = function()
		self.tid = spiritId
		self.spiritViewData = gSpiritManager:GetSpirit(self.tid)

		self:SetSpiritData()
	end

	if self.changeSpiritOnce then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_Vx_N_UrbanAbilityPanel_cut")

		self.changeSpiritTimer = Timer.New(apply, 0.2):Start()
	else
		self.changeSpiritOnce = true

		apply()
	end
end

M.SyncSpiritAbilityInfo = function(self)
	self:SetAbilityList()
	gUrbanAbilityManager:GetAllSpiritPanelData()
end

M.SyncUrbanBadgeInfo = function(self)
	self.SetBadgeList(self)
end

M.SyncSpiritUrbanAttrs = function(self, tid, urbanAttrs)
	if self.tid ~= tid then
		self.SetLiuWei(self, urbanAttrs)
	end
end

M.OnAllSpiritPanelData = function(self)
	self._waitingSpiritPanelData = false

	self.SetLiuWei(self)
end

M.SetSpiritData = function(self)
	if not self.spiritViewData then
		return
	end

	self.SetSpirit(self)
	self.SetOccupationList(self)
	self.SetBadgeList(self)
	self.SetAbilityList(self)

	if not self._waitingSpiritPanelData then
		self.SetLiuWei(self)
	end
end

M.SetSpirit = function(self)
	self.bindData.phoneNum = gUrbanAbilityManager:GetPhoneNum(self.tid)
	self.bindData.name = self.spiritViewData.Name

	self:SetCombatPower()
end

M.SetCombatPower = function(self)
	self.bindData.combatPower = gCombatPowerManager:GetSpiritCombatPower(self:GetCurSpiritTid())
end

M.SetOccupationList = function(self)
	local list = {}

	for i, v in pairs(self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs) do
		if v.Job == LTConfig.UrbanJobConfig.Jobless then
			local jobCfg = LTConfig.UrbanJobConfig.GetConfig(v.Job)

			if jobCfg then
				local jobClassCfg = LTConfig.UrbanJobJobClassConfig.GetConfig(jobCfg.JobClass)

				if not jobClassCfg or jobClassCfg.SystemUnlock ~= 0 or gSystemUnlockMgr:IsUnlock(jobClassCfg.SystemUnlock) then
					local info = {
						id = v.Job,
						selected = false
					}

					table.insert(list, info)
				end
			end
		end
	end

	self._occupationListData = list

	self.bindData.occupationList:SetSimpleList(#list)
end

M.SetBadgeList = function(self)
	local _, _, qualityList, quality = gUrbanAbilityManager:GetSpiritAllBadgeNum(self.tid)
	local list = {}

	for i = 1, 3 do
		local q = quality[i]

		if q then
			local info = {
				quality = q,
				count = #qualityList[q],
				selected = false
			}

			table.insert(list, info)
		end
	end

	self._badgeListData = list

	self.bindData.badgeCountList:SetSimpleList(#list)
end

M.SetAbilityList = function(self)
	local list = {}

	for i, v in pairs(gUrbanAbilityManager:GetAbilityClassList()) do
		local info = {
			id = i,
			selected = false
		}

		table.insert(list, info)
	end

	self._abilityListData = list

	self.bindData.abilityList:SetSimpleList(#list)
end

M.SetLiuWei = function(self, urbanAttrs)
	urbanAttrs = urbanAttrs or gUrbanAbilityManager:GetUrbanAttrs(self.tid)

	if not urbanAttrs then
		local cfg = LTConfig.FightSpiritConfig.GetConfig(self.tid)

		if cfg and cfg.UrbanAttribute then
			urbanAttrs = cfg.UrbanAttribute
		end
	end

	if not urbanAttrs then
		return
	end

	local list = {}

	for i, v in ipairs(urbanAttrs) do
		local cfg = LTConfig.UrbanAttributeConfig.GetConfig(i)
		local oldInfo = self._listData and self._listData[i]
		local oldValue = oldInfo and oldInfo.value or 0

		if not oldInfo then
			self.bindData["radarTitle" .. i] = cfg.Name
			self.bindData["radarIcon" .. i] = cfg.SIcon
		end

		if not oldInfo or oldValue == v then
			self.bindData["radarText" .. i] = v

			DOTween.To(function ()
				return oldValue
			end, function (value)
				if self.bindData.radarChart then
					self.bindData.radarChart:SetVertexValue(i - 1, value)
				end
			end, v, math.abs(v - oldValue) / 100 * 1.2):SetEase(DG.Tweening.Ease.OutQuart)
		end

		local info = {
			id = i,
			selected = false,
			cfg = cfg,
			value = v
		}

		table.insert(list, info)
	end

	self._listData = list
end

M.SetFriendShip = function(self)
	local IsUnlock = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Favorability)

	if not IsUnlock then
		self.bindData.friendShip:SetActive(false)

		return
	end

	local npcId = gUrbanAbilityManager:GetNpcIdBySpiritId(self.tid)

	if not gNpcInteracsUtils:CheckIfCanInteract(npcId) then
		self.bindData.friendShip:SetActive(false)

		return
	end

	if gSpiritManager.CheckIsDefaultSpiritId(self.tid) then
		self.bindData.friendShip:SetActive(false)

		return
	end

	self.bindData.friendShip:SetActive(true)

	local store = gStoreManager:GetStoreGroup("CommonFriendshipTemplate"):GetStoreByWidget(self.bindData.friendShip)

	if not store then
		return
	end

	local favorInfo = gNpcFavorManager:GetSpiritFavorInfo(npcId)
	store.favorAmount = favorInfo.favorAmount
	store.favorLabel = favorInfo.favorLevel
end

M.SetChangeBtnStatus = function(self)
	if self.fightSpiritCfg.Faction ~= 0 then
		self.bindData.changeBtn.interactable = true

		return
	end

	local agentConfig = LTConfig.AgentConfig.GetConfig(self.fightSpiritCfg.AgentId)

	if agentConfig ~= nil then
		return
	end

	local faction = agentConfig.Faction
	local info = gClientUtils.GetFactionInfo(faction)

	if info ~= nil then
		return
	end

	if LTConfig.FactionConfig.DispositionDontSwitch >= info.DispositionLevel then
		self.bindData.changeBtn.interactable = true

		return
	end

	self.bindData.changeBtn.interactable = not self.fightSpiritCfg.DispositionDontSwitch
end

M.SetPageData = function(self, index, para)
	if index <= 0 then
		self.SetPageDataPara = para

		self:OnItemClick(index)
		self.bindData.tabList:SelectItem(index)
	end
end

M.SetQEBtnPos = function(self)
	if not self.bindData.QPCKey or not self.bindData.EPCKey then
		return
	end

	if self.btnTimer then
		self.btnTimer:Stop()

		self.btnTimer = nil
	end

	self.btnTimer = Timer.New(function ()
		local success, min, max = self.bindData.spiritList:TryGetVisualRange(0, 0)

		if not success then
			return
		end

		local haveMin, minIcon = self.bindData.spiritList:TryGetChildAt(min, nil)
		local haveMax, maxIcon = self.bindData.spiritList:TryGetChildAt(max, nil)

		if not haveMin or not haveMax then
			return
		end

		self.bindData.QPCKey.transform:SetPosition(minIcon.transform.position)
		self.bindData.EPCKey.transform:SetPosition(maxIcon.transform.position)
	end, 0.1):Start()
end

M.OnCloseBtnClick = function(self)
	if gCommonItemManager.itemToolTipRefBtn then
		gCommonItemManager:CloseItemToolTips()

		return
	end

	if self.isClosing then
		return
	end

	self.isClosing = true
	slot1 = gNewGuideMgr

	slot1:NotifySignal(EGuideSignal.UrbanAbilityPanelClose)

	slot1 = gBlackScreenManager

	slot1:AutoTransition(gPanelId.S_URBAN_ABILITY_PANEL, "", false, false, self.fadeInOutTime[1], 0, self.fadeInOutTime[2], nil, function ()
		self.isClosing = nil

		gPanelManager:Close(gPanelId.S_URBAN_ABILITY_PANEL)
	end, nil)
end

M.OnChangeBtnClick = function(self)
	local selectTid = self:GetCurSpiritTid()

	if selectTid ~= gSpiritManager:GetCurFirstSpiritTid() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.AbilityHome_ChangeBtn_CurrentRole)

		return
	end

	self.isClosing = nil

	gBlackScreenManager:ClearTransition(gPanelId.S_URBAN_ABILITY_PANEL, true)
	gLoadingManager:SwitchTeleport_BeginShow(selectTid)
	gPanelManager:Close(gPanelId.S_URBAN_ABILITY_PANEL)
	gMainPhoneUtils.CloseMainPhonePanel()
end

M.OnClickChangeAreaBtn = function(self)
end

M.OnClickBadgeBtn = function(self)
	self.bindData.tabRect.selectedIndex = gUrbanAbilityManager.URBANABILITY_PAGE.BADGE
end

M.OnClickDimensionBtn = function(self)
	self.bindData.tabRect.selectedIndex = gUrbanAbilityManager.URBANABILITY_PAGE.ATTRIBUTE_DETAIL
end

M.OnUnfoldBtnClick = function(self)
	self.isUnfold = not self.isUnfold

	self.bindData.goLeft:SetActive(self.isUnfold)
end

M.OnQBtnClick = function(self)
	self.SwitchSpiritIndex(self, -1)
end

M.OnEBtnClick = function(self)
	self.SwitchSpiritIndex(self, 1)
end

M.OnItemClick = function(self, id)
	if self.lastTabRectId ~= id then
		return
	end

	self.bindData.tabRect.selectedIndex = id
	self.lastTabRectId = id
end

M.SwitchSpiritIndex = function(self, delta)
	local index = self.bindData.spiritList.selectedIndex + delta

	if index <= 0 or index <= #self.spiritList - 1 then
		return
	end

	self.bindData.spiritList:SelectItem(index)

	local success, min, max = self.bindData.spiritList:TryGetVisualRange(0, 0)

	if success and (index <= min or max >= index) then
		local goToIndex = delta <= 0 and math.max(0, index - (max - min)) or index

		self.bindData.spiritList:GoToIndex(goToIndex, true)
	end

	self.SetQEBtnPos(self)
end

M.OnChangeJobTab = function(self, eventId, data)
	if data == self.bindData.tabRect.selectedIndex then
		self.bindData.tabRect.selectedIndex = data
	end
end

M.OnL2BtnBeginLongPress = function(self)
	if self.R2BtnAreaActive then
		return
	end

	self.L2BtnAreaActive = true
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.tabListNavigationArea
	self.bindData.ctrlTab = 1
end

M.OnL2BtnEndLongPress = function(self)
	if self.L2BtnAreaActive then
		self.OnChangeAreaBtnClick(self)

		self.L2BtnAreaActive = false
		self.bindData.ctrlTab = 0
	end
end

M.OnR2BtnBeginLongPress = function(self)
	if self.L2BtnAreaActive then
		return
	end

	self.R2BtnAreaActive = true
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.fightSpiritListNavigationArea
	self.bindData.ctrlRolelist = 1
end

M.OnR2BtnEndLongPress = function(self)
	if self.R2BtnAreaActive then
		self.OnChangeAreaBtnClick(self)

		self.R2BtnAreaActive = false
		self.bindData.ctrlRolelist = 0
	end
end

M.OnRenderSpiritItem = function(self, btn, index)
	local data = self._spiritListData[index + 1]
	local store = gStoreManager:GetStoreGroup("HeadAvatarAquareBtnStore"):GetStoreByWidget(btn)
	local cfg = data.cfg
	store.iconId = cfg.SHeadIconID
	store.bg = Color.NewByStr(cfg.CharListTemplateBgColor)
	store.guide = cfg.GuideId

	if data.alreadyJoin then
		store.type = 0
	elseif data.canJoin then
		store.type = 1
	else
		store.type = 2
	end
end

M.OnRenderAbilityItem = function(self, btn, index)
	local data = self._abilityListData[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local typeCfg = LTConfig.UrbanAbilityUrbanAbilityTypeConfig.GetConfig(data.id)
	store.title = typeCfg.Name
	local curExp = 0

	if self.spiritViewData then
		curExp = gUrbanAbilityManager:GetAbilityClassCurExp(self.spiritViewData.SpiritInfo.SpiritAbilities, data.id)
	end

	local maxExp = gUrbanAbilityManager:GetAbilityClassMaxExp(data.id)

	store.progress:ProgressToValue(curExp / maxExp)

	store.level = gUrbanAbilityManager:GetAbilityInterval(curExp / maxExp)

	if maxExp < curExp then
		store.isFull = 1
	else
		store.isFull = 0
	end

	store.icon = typeCfg.Icon
	store.selectIcon = typeCfg.SelectBG
	store.guideId = typeCfg.GuideId
end

M.OnRenderOccupationListItem = function(self, btn, index)
	local data = self._occupationListData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanAbilitySlotTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.id)

	self:SetBlurSource(store.blur)

	if not cfg then
		store.empty = self.Empty.Empty
		store.active = self.Active.UnActive
		store.button.interactable = false
		store.title.text = ""

		return
	end

	store.empty = self.Empty.NotEmpty
	store.icon = cfg.Icon

	if data.id ~= self.spiritViewData.SpiritInfo.SpiritJobInfo.CurrentJob then
		store.active = self.Active.Active
	else
		store.active = self.Active.UnActive
	end

	local serverdata = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[data.id]

	if cfg and serverdata then
		local levelCfg = gSpiritJobManager:GetLevelCfg(cfg.JobClass, serverdata.Level)

		if not levelCfg then
			return
		end

		local progress = serverdata.Exp / levelCfg.Exp

		if progress and progress <= 0 then
			store.progress = progress
		else
			store.progress = 0
		end

		if store.lv then
			store.lv.text = serverdata.Level
		end

		store.progessText = serverdata.Exp .. " / " .. levelCfg.Exp
	end

	local arg = {
		id = data.id,
		serverdata = serverdata
	}
end

M.OnRenderBadgeCountListItem = function(self, btn, index)
	local data = self._badgeListData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanBadgeCountTemplateStore"):GetStoreByWidget(btn)
	store.quality = data.quality - 1
	store.num = data.count
	store.selectCtrl = data.selected and 0 or 1
end

M.OnSpiritItemSelectedChange = function(self, uList)
	local spiritData = {}
	local selectedIndex = uList.selectedIndex

	if selectedIndex >= 0 then
		return
	end

	local data = self._spiritListData[selectedIndex + 1]

	if not data then
		return
	end

	local cfg = LTConfig.FightSpiritConfig.GetConfig(data.id)

	if not cfg then
		print_debug("FightSpiritConfig 里不存在 " .. data.id)

		return
	end

	spiritData.cfg = cfg
	spiritData.data = data

	self.OnSpiritItemClick(self, spiritData)
end

M.OnSpiritItemClick = function(self, data)
	if self.tid ~= data.data.id then
		return
	end

	self:CloseCurrentTab()

	self.tid = data.data.id
	self.fightSpiritCfg = data.cfg
	self.bindData.iconId = data.cfg.SguiVerticalDrawing

	self:SetChangeBtnStatus()

	self.bindData.hideTab = 0

	gMessageManager:SendMessage(gEventConstants.ON_CHANGE_SPIRITVIEW_DATA, data)

	if self.subModelStore then
		self.SwitchModel(self, self.GetCurSpiritTid(self))
	end

	self.ChangeSpiritViewData(self, data.data.id)
end

M.SwitchOrRefreshTab = function(self, targetIndex)
	local tabRect = self.bindData.tabRect

	if tabRect.selectedIndex ~= targetIndex then
		local exist, widget = tabRect.TryGetTabInstance(tabRect, targetIndex, nil)

		if exist and widget then
			self.OnRenderTab(self, targetIndex, widget)
		end
	else
		tabRect.selectedIndex = targetIndex
	end
end

M.OnSimpleClickOccupationList = function(self, btn, index)
	local data = self._occupationListData[index + 1]
	self.curSelectOccupationId = data.id

	self.SwitchOrRefreshTab(self, gUrbanAbilityManager.URBANABILITY_PAGE.OCCUPATION)
end

M.OnSimpleClickAbilityList = function(self, btn, index)
	local data = self._abilityListData[index + 1]

	if self.bindData.tabRect.selectedIndex ~= gUrbanAbilityManager.URBANABILITY_PAGE.ABILITY and self.curOpenedAbilityType ~= data.id then
		return
	end

	self.curSelectAbilityType = data.id

	self.SwitchOrRefreshTab(self, gUrbanAbilityManager.URBANABILITY_PAGE.ABILITY)
end

M.SetAbilityListIsSelect = function(self, isSelect, selectedType)
	local list = self.bindData.abilityList

	for i = 0, list.GetListCount(list) - 1 do
		local have, btn = list.TryGetChildAt(list, i, nil)

		if have then
			local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
			store.isSelect = isSelect and 1 or 0

			if not isSelect then
				btn.isSelected = false
			elseif selectedType then
				local data = self._abilityListData[i + 1]
				btn.isSelected = data == nil and data.id ~= selectedType
			end
		end
	end
end

M.SetOccupationListIsSelect = function(self, isSelect, selectedType)
	local list = self.bindData.occupationList

	for i = 0, list.GetListCount(list) - 1 do
		local have, btn = list.TryGetChildAt(list, i, nil)

		if have then
			local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
			store.isSelect = isSelect and 1 or 0

			if not isSelect then
				btn.isSelected = false
			elseif selectedType then
				local data = self._occupationListData[i + 1]
				btn.isSelected = data == nil and data.id ~= selectedType
			end
		end
	end
end

M.SetTabBtnSelected = function(self, pageIndex)
	local PAGE = gUrbanAbilityManager.URBANABILITY_PAGE
	self.bindData.dimensionBtn.isSelected = pageIndex ~= PAGE.ATTRIBUTE_DETAIL
	self.bindData.badgeBtn.isSelected = pageIndex ~= PAGE.BADGE
end

M.ResetDimensionAndBadgeBtns = function(self)
	self.SetTabBtnSelected(self, -1)
end

M.OnRootAreaIn = function(self)
	if self.tabStore and self.tabStore.panelNavArea then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.tabStore.panelNavArea
	end
end

M.CloseCurrentTab = function(self)
	self.bindData.spiritList.gameObject:SetActive(true)

	self.bindData.tabRect.selectedIndex = -1
	self.curOpenedAbilityType = nil

	self:ResetDimensionAndBadgeBtns()
	self:SetAbilityListIsSelect()
	self:SetOccupationListIsSelect()

	if self.curTabNavArea then
		SGUI.UNavigationMgr.Inst:UnRegisterArea(self.curTabNavArea)

		self.curTabNavArea = nil
	end

	self.tabStore = nil
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navigationArea
end

M.GetDefaultPanelArg = function(self, index)
	local PAGE = gUrbanAbilityManager.URBANABILITY_PAGE

	if index ~= PAGE.OCCUPATION then
		return self.defaultData.jobId or self.defaultData.cfg.JobId
	elseif index ~= PAGE.ABILITY then
		local abilityCfg = LTConfig.UrbanAbilityConfig.GetConfig(self.defaultData.urbanAbilityId)

		return abilityCfg and abilityCfg.AbilityType or nil
	elseif index ~= PAGE.BADGE then
		return self.defaultData.cfg
	end
end

M.OnRenderTab = function(self, index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	local lastTabBlur = self.tabStore and self.tabStore.bindData.blur
	self.tabStore = store
	store.m_Id = self.m_Id

	self:SetTabBtnSelected(index)

	local arg = nil

	if self.curSelectOccupationId then
		arg = self.curSelectOccupationId
		self.curSelectOccupationId = nil
	elseif self.curSelectAbilityType then
		arg = self.curSelectAbilityType
		self.curSelectAbilityType = nil
	elseif self.defaultData then
		arg = self.GetDefaultPanelArg(self, index)
		self.defaultData = nil
	end

	store.ShowPanel(store, arg)

	local blur = store.bindData.blur

	if self.subModelStore and blur and blur == lastTabBlur then
		self.SetBlurSource(self, blur)
	end

	local navArea = widget.GetComponent(widget, typeof(SGUI.UNavigationArea))

	if navArea and index ~= self.bindData.tabRect.selectedIndex then
		local prev = self.curTabNavArea
		self.curTabNavArea = navArea
		store.panelNavArea = navArea

		if prev and prev == navArea then
			SGUI.UNavigationMgr.Inst:UnRegisterArea(prev)
		end

		SGUI.UNavigationMgr.Inst.CurrentActiveArea = navArea
	end

	local PAGE = gUrbanAbilityManager.URBANABILITY_PAGE
	local isAbility = index ~= PAGE.ABILITY

	if isAbility and arg then
		self.curOpenedAbilityType = arg
	elseif not isAbility then
		self.curOpenedAbilityType = nil
	end

	self:SetAbilityListIsSelect(isAbility, isAbility and arg or nil)

	local isOccupation = index ~= PAGE.OCCUPATION

	self:SetOccupationListIsSelect(isOccupation, isOccupation and arg or nil)
	self.bindData.spiritList.gameObject:SetActive(isOccupation)
end

M.OnModelPanelDisplay = function(self)
	self.subModelStore = gStoreManager:GetStoreGroup("UrbanAbilityModelViewerStore")
	local version = self.modelSwitchVersion

	if self.bindData.imgBg.gameObject.activeInHierarchy and not self.isModelSwitching then
		self.isModelSwitching = true

		self:StopModelSwitchTimeout()

		self.modelSwitchTimeoutTimer = Timer.New(function ()
			self:FinishModelSwitch(version, true)
		end, MODEL_SWITCH_TIMEOUT, 1, true):Start()
	end

	self.subModelStore:LoadModel(self:GetCurSpiritTid(), function ()
		self:FinishModelSwitch(version)
	end)
	self.bindData.occupationList:RefreshList()
	self:DefaultSelect()

	if self.tabStore and self.tabStore.blur then
		self.SetBlurSource(self, self.tabStore.blur)
	end

	self.SetBlurSource(self, self.bindData.dimensionBlur)
	self.SetBlurSource(self, self.bindData.badgeBlur)
end

M.SetBlurSource = function(self, widget)
	if not self.subModelStore then
		return
	end

	widget.videoImage = self.subModelStore.bindData.rawImage

	widget.gameObject:SetActive(true)
	widget:ActiveBlur()
end
