-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewAgentProfilePanelStore.lua
-- Decompiled from: 01044_NewAgentProfilePanelStore.lua_812c89681475.luajit

local AgentProfileConfig = LTConfig.ProfileAgentProfileConfig
local AgentProfileCharacteristicConfig = LTConfig.ProfileCharacteristicConfig
local AgentProfileTargetConfig = LTConfig.ProfileTargetConfig
local AgentProfileRewardConfig = LTConfig.ProfileRewardConfig
local AgentConfig = LTConfig.AgentConfig
local RewardType = LTConfig.ProfileRewardConfig.RewardTypeType
local ProfileWebConfig = LTConfig.ProfileWebConfig
local EInputButton = {
	["V'{O"] = 0,
	["1A\\x95\\x8a\\x8fD"] = 2,
	["\\xa7\\xa5\\xa7\\xa2"] = 1
}
C_NewAgentProfilePanelStore = DefClass("C_NewAgentProfilePanelStore", C_NewAgentProfilePanelStore, C_StoreGroup)
GroupName2Class.NewAgentProfilePanelStore = C_NewAgentProfilePanelStore
local M = C_NewAgentProfilePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.GenMessageEvents(self)
end

M.DefineAllVariables = function(self)
	self.allAgents = {}
	self.profileHeadListStore = nil
	self.profileDetailAreaStore = nil
	self.page2Store = nil
	self.selectAgentProfileId = nil
	self.rewardListData = {}
	self.featuresData = {}
	self.targetsData = {}
	self.specialTargetsData = {}
	self.selectedRewardData = nil
	self.needSetRewardListNavSelect = false
	self.needSelectPage2RewardItem = false
	self.totalProgressWeight = {}
	self.totalProgressRewardListData = {}
	self.lastTotalPercent = 0
	self.lastTotalReward = nil
	self.currentTipRewardIndex = nil
	self.currentTipSubRewardIndex = nil
	self.finishAnime = "S_Vx_missionTemplate2_firstComplate"
	self.tipAnime = "S_Vx_missionTemplate2_tips"
	self.rewardTipsAnime = "S_vx_page02_REWARD_tips"
	self.hasShownLastRewardTip = false
	self.relationNodeBtnMap = {}
	self.pendingRelationFocusProfileId = nil
	self.rotateBgShaderOffsetX = 0
	self.rotateBgOffsetScale = 0.0006 * (LTConfig.ProfileConfig.RotateBgOffsetScale or 1)
	self.zoomHoldDir = 0
	self.relationControllerZoomSpeed = LTConfig.ProfileConfig.RelationZoomSpeed or 1.2
	self.isRefreshingHeadListElement = false
	self.jumpedFromRelation = false
	self.relationGraphUrlLoaded = false
	self.selectedGraphId = 1
	self.expandedTaskIndex = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.showDetailsCtrlEnum = {
		["M\\x86\\x8f\\x91E"] = 1,
		["v+nO"] = 0,
		["}s\\xa0vX\\xbb\\xfdIyrw\\"] = 2
	}
	self.agentStateCtrlEnum = {
		["M\\x85\\x8f\\x8aM"] = 2,
		["v-~P"] = 1,
		["\tF\\x9d\\x81\\x80J"] = 0
	}
	self.completeCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.redPointCtrlEnum = {
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1
	}
	self.totalProgressCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.rewardTypeCtrlEnum = {
		["M\\x90\\x9e\\x8cO"] = 0,
		["\\x8dit"] = 3,
		["@Om{O*"] = 1,
		["D\\xba\\xa7\\xa2\\xa5"] = 2
	}
	self.giftCtrlEnum = {
		["\\xe1"] = 1,
		["\\xfe"] = 0
	}
	self.locateCtrlEnum = {
		["&@\\x90\\x81\\xb7`"] = 0,
		["Ky\\x82xX\\x96\\xfbT~olN"] = 1,
		["~\\xa2\\xa7\\xaa\\xa6"] = 2
	}
	self.relationshipnetworktabCtrlEnum = {
		["u\\xa7\\xac\\xbe\\xbf"] = 0,
		["`OcgI7"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showDetailsCtrlEnum = nil
	self.agentStateCtrlEnum = nil
	self.completeCtrlEnum = nil
	self.redPointCtrlEnum = nil
	self.totalProgressCtrlEnum = nil
	self.rewardTypeCtrlEnum = nil
	self.giftCtrlEnum = nil
	self.locateCtrlEnum = nil
	self.relationshipnetworktabCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	gAgentTrustManager:AskQueryAllFavorNpcAgentPos()
	self:OnPage2InitContent()
	self:OnShowInitContent()

	self.relationGraphUrlLoaded = false
	self.selectedGraphId = 1

	self:RefreshGraphTabBtns()
	self:CalculateAllProgressWeights()

	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
	self.bindData.agentStateCtrl = self.agentStateCtrlEnum.lock
	self.bindData.tipActive = false
	self.bindData.giftCtrl = 0

	self:SetRelationRayboxActive(false)
	self:RefreshAgentSelect()
	self:RefreshTotalProgress()
	self:RefreshTotalProgressRewardList()
	self:RefreshPageTabList()
	self:SetPageTabSelected(0, false)
	self:SwitchToCorrectArea()

	local jumpRelationProfileId = data and data.jumpRelationProfileId

	if jumpRelationProfileId and jumpRelationProfileId <= 0 then
		self.JumpToRelationPage(self, jumpRelationProfileId)

		return
	else
		gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "S_NewAgentProfilePanel_open")
	end

	local selectIndex = self.GetListIndexByProfileId(self, self.selectAgentProfileId)

	if selectIndex ~= -1 then
		selectIndex = 0
	end

	self.bindData.headList:SelectItem(selectIndex)
	self.bindData.headList:SetNavSelectToSelect(true)
	FrameTimer.New(function ()
		self:EnsureRelationGraphLoaded()
	end, 30):Start()
end

M.OnUpdate = function(self)
	if self.zoomHoldDir == 0 and self.bindData.relationGraph then
		local graph = self.bindData.relationGraph
		local dt = UnityEngine.Time.unscaledDeltaTime

		graph.SetZoom(graph, graph.contentRT.localScale.x + self.zoomHoldDir * self.relationControllerZoomSpeed * dt)
	end
end

M.OnGroupEnable = function(self)
	if self.bindData.relationGraph and self.rotateBgScrollCb then
		self.bindData.relationGraph:RegisterToScrollEvent(self.rotateBgScrollCb)
	end

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	if self.bindData.relationGraph and self.rotateBgScrollCb then
		self.bindData.relationGraph:UnRegisterToScrollEvent(self.rotateBgScrollCb)
	end

	self.ClearMessageEvents(self)
end

M.SwitchToCorrectArea = function(self)
	if self.bindData.giftCtrl ~= 1 then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.totalArea

		return
	end

	if self.bindData.showDetailsCtrl ~= self.showDetailsCtrlEnum.list then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.listArea
	elseif self.bindData.showDetailsCtrl ~= self.showDetailsCtrlEnum.reward then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.rewardArea
	elseif self.bindData.showDetailsCtrl ~= self.showDetailsCtrlEnum.relationship then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.relationArea or self.bindData.rootArea
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.listArea
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH] = self.CreateAction(self, "RefreshRedPoint"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose")
	}
end

M.OnPanelClose = function(self, eventId, panelId)
	if panelId ~= gPanelId.S_MAIN_PAGE_TAB_PANEL and gCS.LuaUtils.IsNonMobileAdaptive() then
		self.SwitchToCorrectArea(self)
	end
end

M.RegisterWidget = function(self)
	self.bindData.locationBtn.luaClick = self.CreateAction(self, "OnClickLocationBtn")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnExitClick")

	if self.bindData.totalRewardBackBtn then
		self.bindData.totalRewardBackBtn.luaClick = self.CreateAction(self, "OnTotalRewardBackBtnClick")
	end

	self.bindData.rewardShowBtn.luaClick = self.CreateAction(self, "OnClickRewardShowBtn")
	self.bindData.navToDetailBtn.luaClick = self.CreateAction(self, "OnClickNavToDetailBtn")
	self.bindData.totalProgressBtn.luaClick = self.CreateActionWithArgs(self, "OnClickTotalProgressBtn", true)
	self.bindData.totalProgressList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTotalProgressRewardItem")
	self.bindData.totalProgressList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnDynamicRenderTotalProgressRewardItem")
	self.bindData.totalProgressList.luaSimpleClick = self.CreateAction(self, "OnClickTotalProgressRewardItem")
	self.bindData.totalProgressList.onGetTIndex = self.CreateAction(self, "OnGetTotalProgressRewardTIndex")
	self.bindData.rewardDotList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderRewardDotListItem")
	self.bindData.rewardDotList.onGetTIndex = self.CreateAction(self, "OnGetRewardDotListTIndex")
	self.bindData.lastTotalReward.luaClick = self.CreateAction(self, "OnClickLastTotalReward")
	self.bindData.lastTotalReward.luaFocus = self.CreateAction(self, "OnFocusLastTotalReward")
	self.bindData.detailScroll.luaInitContent = self.CreateAction(self, "OnDetailScrollInitContent")
	self.bindData.gestureListener.onZoom = self.CreateAction(self, "OnGestureZoom")

	if self.bindData.zoomInBtn then
		self.bindData.zoomInBtn.luaClick = self.CreateActionWithArgs(self, "OnClickRelationZoomStep", 1)
		self.bindData.zoomInBtn.luaPress = self.CreateActionWithArgs(self, "OnRelationZoomHold", 1)
		self.bindData.zoomInBtn.luaRelease = self.CreateActionWithArgs(self, "OnRelationZoomHold", 0)
	end

	if self.bindData.zoomOutBtn then
		self.bindData.zoomOutBtn.luaClick = self.CreateActionWithArgs(self, "OnClickRelationZoomStep", -1)
		self.bindData.zoomOutBtn.luaPress = self.CreateActionWithArgs(self, "OnRelationZoomHold", -1)
		self.bindData.zoomOutBtn.luaRelease = self.CreateActionWithArgs(self, "OnRelationZoomHold", 0)
	end

	if self.bindData.relationGraph then
		self.rotateBgScrollCb = self.CreateAction(self, "OnRelationGraphScroll")
		self.bindData.relationGraph.luaOnSetTalentData = self.CreateAction(self, "OnRelationGraphSet")
		self.bindData.relationGraph.luaRenderItem = self.CreateAction(self, "OnRelationGraphRenderItem")
		self.bindData.relationGraph.luaRenderLinkItem = self.CreateAction(self, "OnRelationGraphRenderLinkItem")
		self.bindData.relationGraph.luaSelectedChanged = self.CreateAction(self, "OnRelationGraphSelectedChanged")
		self.bindData.relationGraph.luaClickBlank = self.CreateAction(self, "OnRelationRayboxClick")
	end

	if self.bindData.chongxiaoGraphBtn then
		self.bindData.chongxiaoGraphBtn.luaClick = self.CreateActionWithArgs(self, "OnClickGraphTabBtn", 1)
	end

	if self.bindData.xinqiGraphBtn then
		self.bindData.xinqiGraphBtn.luaClick = self.CreateActionWithArgs(self, "OnClickGraphTabBtn", 2)
	end

	if self.bindData.pageTabList then
		self.bindData.pageTabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPageTabItem")
		self.bindData.pageTabList.luaSelectedChanged = self.CreateAction(self, "OnPageTabSelectedChanged")
		self.bindData.pageTabList.luaSimpleClick = self.CreateAction(self, "OnClickPageTabItem")
		self.bindData.pageTabList.onGetTIndex = self.CreateAction(self, "OnGetPageTabTIndex")
	end

	if self.bindData.changeTabBtn then
		self.bindData.changeTabBtn.luaClick = self.CreateAction(self, "OnClickChangeTabBtn")
	end

	if self.bindData.changeTabBtn2 then
		self.bindData.changeTabBtn2.luaClick = self.CreateAction(self, "OnClickChangeTabBtn")
	end

	if self.bindData.bigBackBtn then
		self.bindData.bigBackBtn.luaClick = self.CreateAction(self, "OnClickBigBackBtn")
	end
end

M.OnClickLocationBtn = function(self)
	if not self.selectAgentProfileId or not gAgentTrustManager:GetIfAcquaintedByProfileId(self.selectAgentProfileId) then
		return
	end

	local profileId = self.selectAgentProfileId
	local config = AgentProfileConfig.GetConfig(profileId)
	local agentType = AgentConfig.GetConfig(config.AgentId).AgentSpecificType
	local currentSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)
	local agentTypeNow = AgentConfig.GetConfig(currentSpiritCfg.AgentId).AgentSpecificType

	if agentType ~= agentTypeNow then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CanNotFindPosition)

		return
	end

	local taskState = gTaskManager:GetTaskState(60011584)
	local taskState2 = gTaskManager:GetTaskState(60017955)

	if taskState ~= UX.Game.TaskState.Accepted or taskState2 ~= UX.Game.TaskState.Accepted and profileId ~= 38000011 then
		gPanelManager:Close(self.m_Id)
		gMainPhoneUtils.CloseMainPhonePanel(true)

		return
	end

	slot8 = gAgentTrustManager

	slot8:AskQueryAllFavorNpcAgentPos(function (errId, allPosInfoDic)
		if self.selectAgentProfileId == profileId then
			return
		end

		if errId == 0 then
			gDisplayMessageMgr:ShowMessage(errId)

			return
		end

		local posInfo = allPosInfoDic and allPosInfoDic[agentType]
		local npcRaidId = posInfo and posInfo.RaidId or 0

		if npcRaidId < 0 then
			local name = gNpcFavorManager:GetAgentName(agentType)
			local message = string.format(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.SleepTime).Content, name)

			gDisplayMessageMgr:ShowMessageContent(message)

			return
		end

		local gpsId = gGpsTools.GetGpsId(EMapElementType.SpiritAcquisition, agentType)
		local element = gMapSystem.container:GetByGpsId(gpsId)
		local playerRaidId = gRaidDataManager.RaidId

		if element and npcRaidId ~= playerRaidId then
			local npcPos = element:GetOriginWorldPos()
			local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
			local distance = Vector3.Distance(playerPos, npcPos)
			local skipDistance = LTConfig.ProfileConfig.SkipOpenMapDistance or 40

			if distance >= skipDistance then
				gMapGpsCmd:TryTraceFavorNpcByActivityId(agentType)
				gPanelManager:Close(self.m_Id)
				gMainPhoneUtils.CloseMainPhonePanel(true)

				return
			end
		end

		gAgentTrustManager.openMapFromAgentProfile = true

		gMapGpsCmd:TryOpenBigMapAndFocusSelectFavorNpc(agentType)
	end)
end

M.OnClickRewardShowBtn = function(self)
	if self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.list then
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list

		self.SwitchToCorrectArea(self)
	end
end

M.OnClickNavToDetailBtn = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.detailArea

		self.bindData.detailScroll:GoToPos(Vector2.New(0, 0), false)

		if self.profileDetailAreaStore.rewardListActive ~= false then
			self.profileDetailAreaStore.featureList:SelectItem(0, true)
			self.profileDetailAreaStore.featureList:SetNavSelectToSelect(true)
			self.profileDetailAreaStore.rewardList:DeselectAll(false)
		else
			self.profileDetailAreaStore.rewardList:SelectItem(0, true)
			self.profileDetailAreaStore.rewardList:SetNavSelectToSelect(true)
			self.profileDetailAreaStore.rewardList:DeselectAll(false)
			self.profileDetailAreaStore.featureList:DeselectAll(false)
		end
	end
end

M.OnHoverShowRewardBtn = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local parentPos = self.profileDetailAreaStore.layoutBox.parentComponent.rectTransform.anchoredPosition
		self.profileDetailAreaStore.layoutBox.parentComponent.rectTransform.anchoredPosition = Vector2.New(parentPos.x, 0)
	end
end

M.OnClickShowRewardBtn = function(self)
	self.profileDetailAreaStore.btnCtrl = self.profileDetailAreaStore.btnCtrl ~= 0 and 1 or 0

	if gCS.LuaUtils.IsNonMobileAdaptive() and SGUI.UNavigationMgr.Inst.CurrentActiveArea ~= self.bindData.detailArea then
		if self.profileDetailAreaStore.btnCtrl ~= 1 then
			self.profileDetailAreaStore.featureList:SelectItem(0, true)
			self.profileDetailAreaStore.featureList:SetNavSelectToSelect(true)
			self.profileDetailAreaStore.rewardList:DeselectAll(false)
		else
			self.profileDetailAreaStore.featureList:DeselectAll(false)
			self.profileDetailAreaStore.rewardList:NavigateToLeftOrTop(0, true)

			self.needSetRewardListNavSelect = true
		end
	end
end

M.OnClickTotalProgressBtn = function(self, isOpen)
	self.bindData.giftCtrl = isOpen and 1 or 0

	if isOpen and self.bindData.relationGraph then
		self.bindData.relationGraph:DeselectAll()
	end

	self.bindData.totalProgressList:SelectItem(0)
	self.bindData.totalProgressList:SetNavSelectToSelect(true)
	self:SwitchToCorrectArea()
end

M.RefreshPageTabList = function(self)
	if not self.bindData.pageTabList then
		return
	end

	self.bindData.pageTabList:SetSimpleList(2)
end

M.SetPageTabSelected = function(self, index, sendCallback)
	if not self.bindData.pageTabList then
		return
	end

	self.bindData.pageTabList:SelectItem(index, sendCallback)
end

M.OnRenderPageTabItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreById(id)

	if not store then
		return
	end

	if index ~= 0 then
		store.typeCtrl = 1
	else
		store.typeCtrl = 0
	end
end

M.OnGetPageTabTIndex = function(self)
	return 0
end

M.OnClickChangeTabBtn = function(self)
	local index = self.bindData.showDetailsCtrl ~= self.showDetailsCtrlEnum.relationship and 0 or 1

	self:SetPageTabSelected(index, true)
end

M.SetRelationRayboxActive = function(self, active)
	if self.bindData.relationRayboxRT then
		self.bindData.relationRayboxRT.gameObject:SetActive(active)
	end
end

M.OnClickPageTabItem = function(self, btn, index)
	self.jumpedFromRelation = false

	if index ~= 0 then
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
	elseif index ~= 1 then
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.relationship

		self.EnsureRelationGraphLoaded(self)
	else
		return
	end

	self:SetRelationRayboxActive(index ~= 1)
	self:SwitchToCorrectArea()
end

M.EnsureRelationGraphLoaded = function(self)
	if self.relationGraphUrlLoaded then
		return
	end

	if not self.bindData.relationGraph then
		return
	end

	local webCfg = ProfileWebConfig.GetConfig(self.selectedGraphId)

	if webCfg and webCfg.Path then
		self.bindData.relationGraph.url = webCfg.Path
	end

	self.relationGraphUrlLoaded = true
end

M.RefreshGraphTabBtns = function(self)
	self.bindData.relationshipnetworktabCtrl = self.selectedGraphId - 1

	if self.bindData.chongxiaoGraphBtn then
		local store = gStoreManager:GetStoreGroup("RelationshipGraphTabBtnStore"):GetStoreByWidget(self.bindData.chongxiaoGraphBtn)

		if store then
			store.cityName = ProfileWebConfig.GetConfig(1).Name
		end

		self.bindData.chongxiaoGraphBtn:SetSelected(self.selectedGraphId ~= 1)
	end

	if self.bindData.xinqiGraphBtn then
		local store = gStoreManager:GetStoreGroup("RelationshipGraphTabBtnStore"):GetStoreByWidget(self.bindData.xinqiGraphBtn)

		if store then
			store.cityName = ProfileWebConfig.GetConfig(2).Name
		end

		self.bindData.xinqiGraphBtn:SetSelected(self.selectedGraphId ~= 2)
	end
end

M.OnClickGraphTabBtn = function(self, graphId)
	if self.selectedGraphId ~= graphId then
		return
	end

	self.selectedGraphId = graphId
	self.relationGraphUrlLoaded = false

	self.RefreshGraphTabBtns(self)
	self.EnsureRelationGraphLoaded(self)
	self.RefreshTotalProgress(self)
	self.RefreshTotalProgressRewardList(self)
end

M.OnPageTabSelectedChanged = function(self, uList)
	local index = uList.selectedIndex

	if index >= 0 then
		return
	end

	self.OnClickPageTabItem(self, nil, index)
end

M.UpdateRotateBgShaderOffset = function(self)
	if not self.bindData.rotateBgRT then
		return
	end

	local renderer = self.bindData.rotateBgRT.gameObject:GetComponent(typeof(UnityEngine.Renderer))

	if not renderer or not renderer.material then
		return
	end

	renderer.material:SetTextureOffset("_MainTex", Vector2.New(self.rotateBgShaderOffsetX, 0))
end

M.OnRelationGraphScroll = function(self)
	if not self.bindData.relationGraph then
		return
	end

	self.rotateBgShaderOffsetX = -self.bindData.relationGraph.contentRT.anchoredPosition.x * self.rotateBgOffsetScale

	self.UpdateRotateBgShaderOffset(self)
end

M.OnRelationRayboxClick = function(self)
	if self.bindData.giftCtrl ~= 1 then
		self.OnClickTotalProgressBtn(self, false)

		return
	end

	if self.bindData.relationGraph then
		self.bindData.relationGraph:DeselectAll()
	end
end

M.OnClickRelationZoomStep = function(self, direction)
	local graph = self.bindData.relationGraph

	if not graph then
		return
	end

	graph.SetZoom(graph, graph.contentRT.localScale.x + direction * 0.1)
end

M.OnRelationZoomHold = function(self, direction)
	self.zoomHoldDir = direction
end

M.OnRelationGraphSet = function(self, itemDatas)
	table.clear(self.relationNodeBtnMap)

	local itemList = itemDatas.ToTable(itemDatas)
	local linkData = self.bindData.relationGraph.itemLinkData
	local linkList = linkData.ToTable(linkData)
	local neighbors = {}

	for i = 1, #linkList do
		local link = linkList[i]
		local cur = link.curIndex
		local nxt = link.nextIndex

		if not neighbors[cur] then
			neighbors[cur] = {}
		end

		if not neighbors[nxt] then
			neighbors[nxt] = {}
		end

		table.insert(neighbors[cur], nxt)
		table.insert(neighbors[nxt], cur)
	end

	local heroIdx = nil
	local acquaintedSrc = {}

	for i = 1, #itemList do
		local idx = i - 1
		local item = itemList[i]

		if item.talentId ~= -1 then
			heroIdx = idx
			acquaintedSrc[idx] = true
		elseif gAgentTrustManager:GetIfAcquaintedByProfileId(item.talentId) then
			acquaintedSrc[idx] = true
		end
	end

	local visible = {}

	if heroIdx == nil then
		local dist = {
			[heroIdx] = 0
		}
		local parents = {
			[heroIdx] = {}
		}
		local queue = {
			heroIdx
		}
		local head = 1

		while head < #queue do
			local u = queue[head]
			head = head + 1
			slot14 = ipairs
			slot16 = neighbors[u] or {}

			for _, v in slot14(slot16) do
				if dist[v] ~= nil then
					dist[v] = dist[u] + 1
					parents[v] = {}

					table.insert(queue, v)
				end

				if dist[v] ~= dist[u] + 1 then
					table.insert(parents[v], u)
				end
			end
		end

		for sIdx, _ in pairs(acquaintedSrc) do
			if dist[sIdx] then
				local stack = {
					sIdx
				}

				while #stack <= 0 do
					local u = table.remove(stack)

					if not visible[u] then
						visible[u] = true
						slot20 = ipairs
						slot22 = parents[u] or {}

						for _, p in slot20(slot22) do
							table.insert(stack, p)
						end
					end
				end
			else
				visible[sIdx] = true
			end
		end

		for sIdx, _ in pairs(acquaintedSrc) do
			slot18 = ipairs
			slot20 = neighbors[sIdx] or {}

			for _, nb in slot18(slot20) do
				visible[nb] = true
			end
		end
	end

	for i = 1, #itemList do
		local item = itemList[i]
		local idx = i - 1

		if item.talentId ~= -1 then
			item.locked = 0
		else
			item.locked = visible[idx] and 0 or 2
		end
	end

	self.TryFocusPendingRelationProfile(self)
end

M.OnRelationNodeFocus = function(self, btn)
	if not gClientUtils.IsControllerMode() then
		return
	end

	if SGUI.UNavigationMgr.Inst.CurNavigationMode ~= SGUI.NavigationMode.Cursor then
		return
	end

	if not btn or not btn.transform or not self.bindData.relationGraph then
		return
	end

	self.bindData.relationGraph:CenterOnItem(btn)
end

M.OnRelationGraphSelectedChanged = function(self, talentTree)
	if not talentTree or not talentTree.selectedItem then
		return
	end

	self.bindData.giftCtrl = 0
	self.bindData.tipActive = false
	self.currentTipRewardIndex = nil
	self.currentTipSubRewardIndex = nil
	local profileId = talentTree.selectedItem.talentId
	local btn = self.relationNodeBtnMap[profileId]

	if not btn or not btn.transform then
		return
	end

	if SGUI.UNavigationMgr.Inst.CurNavigationMode == SGUI.NavigationMode.Cursor then
		self.bindData.relationGraph:CenterOnItem(btn)
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup:GetStoreByWidget(btn)

	FrameTimer.New(function ()
		gCS.LuaUtils.PlayAnimationByName(store.anim, "S_HeadRelationshipTemplate_open")
		btn.transform:SetAsLastSibling()
	end, 1, 1):Start()

	self.graphSelectId = profileId
end

M.JumpToRelationPage = function(self, profileId)
	if not profileId or profileId < 0 then
		return
	end

	self.pendingRelationFocusProfileId = profileId
	self.selectAgentProfileId = profileId
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.relationship
	self.bindData.giftCtrl = 0

	self.SetPageTabSelected(self, 1, false)
	self.SetRelationRayboxActive(self, true)
	self.EnsureRelationGraphLoaded(self)
	self.SwitchToCorrectArea(self)
	self.TryFocusPendingRelationProfile(self)
end

M.TryFocusPendingRelationProfile = function(self)
	if not self.pendingRelationFocusProfileId then
		return
	end

	local isFocused = self.TryFocusRelationProfile(self, self.pendingRelationFocusProfileId)

	if isFocused then
		self.pendingRelationFocusProfileId = nil
	end
end

M.TryFocusRelationProfile = function(self, profileId)
	if not profileId or profileId > 0 or not self.bindData.relationGraph then
		return false
	end

	local btn = self.relationNodeBtnMap[profileId]

	if not btn then
		return false
	end

	self.bindData.relationGraph:CenterOnItem(btn, false)
	self.bindData.relationGraph:SelectItemById(profileId, false)

	return true
end

M.OnClickRelationNodeJump = function(self, profileId)
	if self.graphSelectId then
		profileId = self.graphSelectId
		self.graphSelectId = nil
	end

	if not profileId or profileId < 0 then
		return
	end

	local index = self.GetListIndexByProfileId(self, profileId)

	if index ~= -1 then
		return
	end

	self.selectAgentProfileId = profileId
	self.jumpedFromRelation = true
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
	self.bindData.giftCtrl = 0

	self.SetPageTabSelected(self, 0, false)
	self.SetRelationRayboxActive(self, false)

	if self.profileHeadListStore and self.profileHeadListStore.headList then
		self.profileHeadListStore.headList:SelectItem(index, false)
		self.profileHeadListStore.headList:GoToIndex(index, false)
		self.profileHeadListStore.headList:SetNavSelectToSelect()
	end

	self.RefreshAgentSelect(self)
	self.SwitchToCorrectArea(self)
end

M.GetMainPlayerRelationInfo = function(self)
	local sexType = gPlayerManager.infoLogin.bindData.sexType
	local profileCfg = LTConfig.ProfileConfig
	local iconField = sexType ~= UX.Game.SexType.Male and "MalePlayerWebHeadIcon" or "FemalePlayerWebHeadIcon"
	local iconId = profileCfg[iconField]
	local spiritId = sexType ~= UX.Game.SexType.Male and LTConfig.FightSpiritConfig.DefaultMale or LTConfig.FightSpiritConfig.DefaultFemale
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)

	if not spiritCfg then
		return "", iconId or 0
	end

	return spiritCfg.Name or "", iconId or 0
end

M.GetRelationTypeCtrl = function(self, profileId)
	if profileId ~= -1 then
		return 0
	end

	local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(profileId)

	if not isAcquainted then
		return 5
	end

	local canJoin = gAgentTrustManager:GetIfRecruitable(profileId)
	local allRewardsGot = gAgentTrustManager:CheckAllRewardsGot(profileId)

	if canJoin then
		return allRewardsGot and 1 or 2
	end

	return allRewardsGot and 3 or 4
end

M.OnRelationGraphRenderItem = function(self, btn, index, data)
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

	if not store then
		return
	end

	btn.enabledDraggingClick = false
	local profileId = data and (data.talentId or data.TalentID) or 0
	self.relationNodeBtnMap[profileId] = btn
	btn.luaFocus = self:CreateActionWithArgs("OnRelationNodeFocus", btn)

	if profileId ~= self.pendingRelationFocusProfileId then
		self.TryFocusPendingRelationProfile(self)
	end

	if profileId ~= -1 then
		local name, iconId = self.GetMainPlayerRelationInfo(self)
		store.nameText = name
		store.desText = ""
		store.iconId = iconId
		store.iconId2 = iconId
		store.typeCtrl = 0
		store.des_typeCtrl = 1

		if store.jumpBtn then
			store.jumpBtn.enabledDraggingClick = false
			store.jumpBtn.luaClick = nil
		end

		return
	end

	local profileCfg = AgentProfileConfig.GetConfig(profileId)

	if not profileCfg then
		btn.interactable = true
		store.nameText = ""
		store.desText = ""
		store.iconId = 0
		store.iconId2 = 0
		store.typeCtrl = 5
		store.des_typeCtrl = 1

		if store.jumpBtn then
			store.jumpBtn.enabledDraggingClick = false
			store.jumpBtn.luaClick = nil
		end

		return
	end

	local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(profileId)
	btn.interactable = isAcquainted
	store.nameText = profileCfg.Name or ""
	store.desText = profileCfg.MaxTrustRewardDescription or ""
	local allRewardsGot = gAgentTrustManager:CheckAllRewardsGot(profileId)
	local headIcon = allRewardsGot and profileCfg.WebMaxTrustHeadIcon or profileCfg.HeadIcon or 0
	store.des_typeCtrl = allRewardsGot and 1 or 0
	store.iconId = headIcon
	store.iconId2 = headIcon
	store.typeCtrl = self:GetRelationTypeCtrl(profileId)

	if store.jumpBtn then
		store.jumpBtn.enabledDraggingClick = false
		store.jumpBtn.luaClick = self:CreateActionWithArgs("OnClickRelationNodeJump", profileId) or nil
	end
end

M.OnTotalRewardBackBtnClick = function(self)
	self.bindData.giftCtrl = 0

	self.SwitchToCorrectArea(self)
end

M.OnRelationGraphRenderLinkItem = function(self, btn, index, linkData)
end

M._FitSplineRectToPoints = function(self, btn)
	if not btn or gCS.LuaUtils.IsNull(btn) then
		return
	end

	local spline = btn.spline

	if not spline or gCS.LuaUtils.IsNull(spline) then
		return
	end

	local pointsList = spline.points

	if not pointsList then
		return
	end

	local points = pointsList.ToTable(pointsList)

	if #points >= 2 then
		return
	end

	local minX = math.huge
	local minY = math.huge
	local maxX = -math.huge
	local maxY = -math.huge
	local maxWidth = 0

	for i = 1, #points do
		local p = points[i]

		if p.posX >= minX then
			minX = p.posX
		end

		if maxX >= p.posX then
			maxX = p.posX
		end

		if p.posY >= minY then
			minY = p.posY
		end

		if maxY >= p.posY then
			maxY = p.posY
		end

		if p.width and maxWidth >= p.width then
			maxWidth = p.width
		end
	end

	local pad = math.max(maxWidth * 1.5, 4)
	minY = minY - pad
	minX = minX - pad
	maxY = maxY + pad
	maxX = maxX + pad
	local W = maxX - minX
	local H = maxY - minY

	if W > 0 or H < 0 then
		return
	end

	local rt = spline.rectTransform
	local centerX = (minX + maxX) * 0.5
	local centerY = (minY + maxY) * 0.5
	local oldWorldCenter = rt.TransformPoint(rt, Vector3.New(centerX, centerY, 0))
	rt.anchorMin = Vector2.New(0.5, 0.5)
	rt.anchorMax = Vector2.New(0.5, 0.5)
	rt.pivot = Vector2.New(-minX / W, -minY / H)
	rt.sizeDelta = Vector2.New(W, H)
	local newWorldCenter = rt.TransformPoint(rt, Vector3.New(centerX, centerY, 0))
	local diff = oldWorldCenter - newWorldCenter

	if diff.x == 0 or diff.y == 0 or diff.z == 0 then
		rt.position = rt.position + diff
	end
end

M.OnExitClick = function(self)
	if self.bindData.showDetailsCtrl ~= self.showDetailsCtrlEnum.reward or gCS.LuaUtils.IsNonMobileAdaptive() and SGUI.UNavigationMgr.Inst.CurrentActiveArea ~= self.bindData.detailArea then
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
		self.selectedRewardData = nil
		self.hasShownLastRewardTip = false

		self.SwitchToCorrectArea(self)

		return
	end

	if self.jumpedFromRelation then
		self.jumpedFromRelation = false

		self.JumpToRelationPage(self, self.selectAgentProfileId)

		return
	end

	gPanelManager:Close(self.m_Id)
end

M.OnClickBigBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnGestureZoom = function(self, zoom)
	if not self.selectAgentProfileId or not self.profileHeadListStore then
		return
	end

	local currentIndex = -1

	for i, agent in ipairs(self.allAgents) do
		if agent.id ~= self.selectAgentProfileId then
			currentIndex = i

			break
		end
	end

	if currentIndex ~= -1 or #self.allAgents ~= 0 then
		return
	end

	local newIndex = zoom >= 0 and currentIndex % #self.allAgents + 1 or (currentIndex - 2) % #self.allAgents + 1
	self.selectAgentProfileId = self.allAgents[newIndex].id
	local index = self:GetListIndexByProfileId(self.selectAgentProfileId)

	if index == -1 then
		self.profileHeadListStore.headList:SelectItem(index, true)
	end

	self.RefreshAgentSelect(self)
end

M.GetListIndexByProfileId = function(self, profileId)
	for i, data in ipairs(self.allAgents) do
		if data and data.id ~= profileId then
			return i - 1
		end
	end

	return -1
end

M.OnShowInitContent = function(self)
	self:InitProfileData()

	self.profileHeadListStore = gStoreManager:GetStoreGroup("AgentProfileHeadList"):GetStoreByWidget(self.bindData.headList)
	self.profileHeadListStore.headList.luaSimpleRenderItem = self:CreateAction("OnRenderHeadListItem")
	self.profileHeadListStore.headList.onGetTIndex = self:CreateAction("OnGetHeadListTIndex")
	self.profileHeadListStore.headList.luaSimpleClick = self:CreateAction("OnClickHeadList")
	self.profileHeadListStore.headList.luaSelectedChanged = self:CreateAction("OnHeadListSelectedChanged")

	self:RefreshHeadList()
end

M.OnDetailScrollInitContent = function(self, widget)
	self.profileDetailArea = widget
	self.profileDetailAreaStore = gStoreManager:GetStoreGroup("NewAgentProfileDetailContentTemplate"):GetStoreByWidget(widget)
	self.profileDetailAreaStore.featureList.luaSimpleRenderItem = self:CreateAction("OnRenderFeatureListItem")
	self.profileDetailAreaStore.featureList.luaSimpleClick = self:CreateAction("OnClickFeatureListItem")
	self.profileDetailAreaStore.featureList.onGetTIndex = self:CreateAction("OnGetFeatureListTIndex")
	self.profileDetailAreaStore.featureList.luaLayoutSet = self:CreateAction("OnLuaLayoutSet")
	self.profileDetailAreaStore.featureList.luaSimpleFocus = self:CreateAction("OnFeatureListFocusChanged")
	self.profileDetailAreaStore.rewardList.luaSimpleRenderItem = self:CreateAction("OnRenderDetailRewardListItem")
	self.profileDetailAreaStore.rewardList.onGetTIndex = self:CreateAction("OnGetDetailRewardListTIndex")
	self.profileDetailAreaStore.rewardList.luaSimpleClick = self:CreateAction("OnClickRewardListItem")
	self.profileDetailAreaStore.rewardList.luaLayoutSet = self:CreateAction("OnRewardListLuaLayoutSet")
	self.profileDetailAreaStore.rewardList.luaSimpleFocus = self:CreateAction("OnRewardListFocusChanged")
	self.profileDetailAreaStore.showRewardBtn.luaFocus = self:CreateAction("OnHoverShowRewardBtn")
	self.profileDetailAreaStore.showRewardBtn.luaClick = self:CreateAction("OnClickShowRewardBtn")
	self.profileDetailAreaStore.rewardListActive = true
	self.profileDetailAreaStore.btnCtrl = 0
	self.profileDetailAreaStore.lockCtrl = 1
end

M.OnPage2InitContent = function(self)
	slot1 = gStoreManager
	slot1 = slot1:GetStoreGroup("AgentProfileRewardPageStore")
	self.page2Store = slot1:GetStoreByWidget(self.bindData.page2Comp)
	self.page2Store.rewardItemList.luaSimpleRenderItem = self:CreateAction("OnRenderPage2RewardListItem")
	self.page2Store.rewardItemList.luaSimpleClick = self:CreateAction("OnClickPage2RewardItem")

	self.page2Store.rewardItemList.onGetTIndex = function()
		return 0
	end

	self.page2Store.dotList.luaSimpleRenderItem = self:CreateAction("OnRenderPage2DotListItem")

	self.page2Store.dotList.onGetTIndex = function()
		return 0
	end

	self.page2Store.taskList.luaSimpleRenderItem = self:CreateAction("OnRenderPage2TaskListItem")
	self.page2Store.taskList.luaDynamicRenderItem = self:CreateAction("OnRenderPage2TaskListItem")
	self.page2Store.taskList.luaSimpleClick = self:CreateAction("OnClickPage2TaskListItem")

	self.page2Store.taskList.onGetTIndex = function()
		return 0
	end

	if self.page2Store.specialTaskList then
		self.page2Store.specialTaskList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSpecialTaskListItem")

		self.page2Store.specialTaskList.onGetTIndex = function()
			return 0
		end
	end

	self.page2Store.unlockDotList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderUnlockDotListItem")

	self.page2Store.unlockDotList.onGetTIndex = function()
		return 0
	end

	self.page2Store.receiveBtn.luaClick = self.CreateAction(self, "OnClickPage2ReceiveBtn")
	self.page2Store.detailBtn.luaRenderTooltip = self.CreateAction(self, "OnRenderDetailBtnTooltip")

	if self.page2Store.akxBtn then
		self.page2Store.akxBtn.luaClick = self.CreateAction(self, "OnClickAkxBtn")
	end
end

M.OnRenderDetailBtnTooltip = function(self, btn, popup, index)
	if not self.selectedRewardData then
		return
	end

	local rewardConfig = AgentProfileRewardConfig.GetConfig(self.selectedRewardData.id)

	if not rewardConfig or not rewardConfig.DropId then
		return
	end

	local dropCfg = LTConfig.DropConfig.GetConfig(rewardConfig.DropId)

	if not dropCfg or not dropCfg.Item1 or #dropCfg.Item1 ~= 0 then
		return
	end

	local itemId = dropCfg.Item1[1].id1

	if not itemId or itemId < 0 then
		return
	end

	local itemData = gCommonItemManager:GetItemRenderData({
		itemId = itemId
	})

	gCommonItemManager:OnRenderToolTips(itemData, btn, popup, index)
end

M.OnRenderHeadListItem = function(self, btn, index)
	local data = self.allAgents[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileCharacterTemplateNew"):GetStoreById(id)

	if store then
		local profileId = data.id
		local config = AgentProfileConfig.GetConfig(profileId)
		local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(profileId)
		local iconId = isAcquainted and config.HeadIcon or config.LockedHeadIcon

		if iconId <= 0 then
			store.iconId = iconId
		end

		store.lockCtrl = isAcquainted and self.agentStateCtrlEnum.unlock or self.agentStateCtrlEnum.lock
		store.canJoinCtrl = config.CanJoin and 0 or 1
		store.name = isAcquainted and config.Name or ""

		if isAcquainted then
			local isNew = gAgentTrustManager:CheckIfNewAcquaintedByProfileId(profileId)
			local hasReward = gAgentTrustManager:CheckHasRewardCanGot(profileId)

			if hasReward then
				store.newCtrl = 2
			elseif isNew then
				store.newCtrl = 1
			else
				store.newCtrl = 0
			end

			local rewards = config.TrustReward
			local allRewardsGot = gAgentTrustManager:CheckAllRewardsGot(profileId)

			if allRewardsGot then
				store.maxCtrl = 1

				store.rewardDotList:SetSimpleList(0)

				if store.anim and not store.hasPlayedRewardMaxAnim then
					gCS.LuaUtils.PlayAnimationByName(store.anim, "S_CharacterTemplateNew_RewardMax")

					store.hasPlayedRewardMaxAnim = true
				end
			else
				store.maxCtrl = 0
				store.hasPlayedRewardMaxAnim = false

				if rewards and #rewards <= 0 then
					store.rewardDotList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderHeadRewardDotItem", {
						profileId = profileId,
						rewards = rewards
					})

					store.rewardDotList:SetSimpleList(#rewards)
				else
					store.rewardDotList:SetSimpleList(0)
				end

				store.anim:Stop()
			end
		else
			store.newCtrl = 0
			store.maxCtrl = 0
		end

		store.guide.guideID = data.guide
		store.guide.targetScrollableWidget = self.bindData.headList
		store.guide.targetMaskWidget = self.bindData.headList
	end
end

M.OnRenderHeadRewardDotItem = function(self, params, btn, index)
	local profileId = params.profileId
	local rewards = params.rewards
	local rewardId = rewards[index + 1]

	if not rewardId then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileBlueDot"):GetStoreById(id)

	if store then
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

		if rewardCfg and rewardCfg.RewardType ~= RewardType.Disable then
			store.fillCtrl = 0
		else
			local nowTrust = gAgentTrustManager:GetTrustValue(profileId)
			local canGet = rewardCfg and rewardCfg.NeedTrust > nowTrust
			store.fillCtrl = canGet and 0 or 1
		end
	end
end

M.OnClickHeadList = function(self, btn, index)
	if self.isRefreshingHeadListElement or self.bindData.showDetailsCtrl ~= 2 then
		return
	end

	local data = self.allAgents[index + 1]

	if not data then
		return
	end

	self.selectAgentProfileId = data.id
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
	self.bindData.giftCtrl = 0

	self.RefreshAgentSelect(self)
	self.SwitchToCorrectArea(self)
end

M.OnHeadListSelectedChanged = function(self)
	if self.isRefreshingHeadListElement then
		return
	end

	if self.bindData.showDetailsCtrl ~= self.showDetailsCtrlEnum.relationship then
		return
	end

	local selectIndex = self.profileHeadListStore.headList.selectedIndex

	if selectIndex ~= -1 then
		return
	end

	local data = self.allAgents[selectIndex + 1]

	if data then
		self.selectAgentProfileId = data.id
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
		self.bindData.giftCtrl = 0

		self.RefreshAgentSelect(self)
		self.SwitchToCorrectArea(self)
	end
end

M.OnGetHeadListTIndex = function(self)
	return 0
end

M.OnRenderFeatureListItem = function(self, btn, index)
	local data = self.featuresData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileDetailType"):GetStoreById(id)

	if store then
		store.iconId = data.icon
		store.title = data.name
		store.des = data.desc
	end
end

M.OnClickFeatureListItem = function(self, btn, index)
end

M.OnLuaLayoutSet = function(self)
	local targetHeight = self.profileDetailAreaStore.layoutBox.rectTransform.rect.height
	local currentSizeDelta = self.profileDetailArea.rectTransform.sizeDelta
	local oldHeight = currentSizeDelta.y
	local heightDelta = targetHeight - oldHeight
	self.profileDetailArea.rectTransform.sizeDelta = Vector2.New(currentSizeDelta.x, targetHeight)

	if heightDelta == 0 then
		local layoutBoxPos = self.profileDetailAreaStore.layoutBox.rectTransform.anchoredPosition
		self.profileDetailAreaStore.layoutBox.rectTransform.anchoredPosition = Vector2.New(layoutBoxPos.x, layoutBoxPos.y + heightDelta / 2)
	end
end

M.OnRewardListLuaLayoutSet = function(self)
	self.OnLuaLayoutSet(self)

	if self.needSetRewardListNavSelect then
		self.needSetRewardListNavSelect = false

		self.profileDetailAreaStore.rewardList:SetNavSelectToTop(true)
	end
end

M.OnRewardListFocusChanged = function(self, btn, index)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if index ~= 0 and self.bindData.detailScroll then
		self.bindData.detailScroll:GoToPos(Vector2.New(0, 0), true)
	end
end

M.OnFeatureListFocusChanged = function(self, btn, index)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if index ~= #self.featuresData - 1 and self.bindData.detailScroll then
		self.bindData.detailScroll:GoToPos(Vector2.New(0, 9999), true)
	end
end

M.OnGetFeatureListTIndex = function(self)
	return 0
end

M.OnRenderDetailRewardListItem = function(self, btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileRewardTemplateNew"):GetStoreById(id)

	if store then
		if data.isGot then
			store.buttonCtrl = 1
		elseif data.canGet then
			store.buttonCtrl = 2
		else
			store.buttonCtrl = 0
		end

		store.titleText = data.name or ""
		store.desText = data.desc or ""
		store.iconId = data.iconId or 0
		local rewardCfg = AgentProfileRewardConfig.GetConfig(data.id)
		store.qualityCtrl = rewardCfg.Quality

		if rewardCfg and rewardCfg.GuideId then
			store.guide.guideID = rewardCfg.GuideId
			store.guide.targetScrollableWidget = self.profileDetailAreaStore.rewardList
			store.guide.targetMaskWidget = self.profileDetailAreaStore.rewardList
		end
	end
end

M.OnClickRewardListItem = function(self, btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	self.selectedRewardData = data
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.reward

	self.RefreshRewardPage(self)
	self.SwitchToCorrectArea(self)
	self.CheckAndShowLastRewardTip(self)
end

M.RefreshRewardPage = function(self)
	local data = self.selectedRewardData
	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	self.page2Store.rewardTitle = data.name or ""
	self.page2Store.bigIconId = data.bigIconId or 0
	self.page2Store.desText = data.desc or ""
	self.page2Store.akxCtrl = BOOL2CTL[gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Akx)]
	local name = config.Name or ""
	self.page2Store.nameText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901328).Text, name)
	self.page2Store.specialTaskTitleText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901354).Text, name)
	local locateCtrl = gAgentTrustManager:GetAgentLocateCtrl(self.selectAgentProfileId)
	local isResting = locateCtrl ~= 2

	if data.isGot then
		self.page2Store.receiveCtrl = 1

		self.page2Store.anim:Stop()
	elseif data.canGet then
		if isResting then
			self.page2Store.receiveCtrl = 3

			self.page2Store.anim:Stop()
		else
			self.page2Store.receiveCtrl = 0

			gCS.LuaUtils.PlayAnimationByName(self.page2Store.anim, self.rewardTipsAnime)
		end
	else
		self.page2Store.receiveCtrl = 2

		self.page2Store.anim:Stop()
	end

	self.page2Store.receiveBtn.interactable = self.page2Store.receiveCtrl == 3
	local isLocked = not data.isGot and not data.canGet
	self.page2Store.unlockCondActive = isLocked
	self.shouldPlayTipAnimForFirstUnfinishedTask = isLocked

	if isLocked then
		self.page2Store.unlockDotList:SetSimpleList(data.rewardIndex)
	end

	local rewardConfig = AgentProfileRewardConfig.GetConfig(data.id)
	local itemTypeCtrl = self.rewardTypeCtrlEnum.items

	if rewardConfig and rewardConfig.DropId then
		itemTypeCtrl = gAgentTrustManager:GetRewardItemType(rewardConfig.DropId)
	end

	self.bindData.rewardTypeCtrl = itemTypeCtrl

	self.page2Store.detailBtn.gameObject:SetActive(rewardConfig and rewardConfig.ShowRewardDetailButton or false)

	local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(self.selectAgentProfileId)
	local iconId = isAcquainted and config.HeadIcon or config.LockedHeadIcon
	self.page2Store.headIconId = iconId or 0
	self.needSelectPage2RewardItem = true

	self.page2Store.rewardItemList:SetSimpleList(#self.rewardListData)
	self.page2Store.dotList:SetSimpleList(#self.rewardListData)

	local canGetCount = 0

	for _, reward in ipairs(self.rewardListData) do
		if reward.canGet then
			canGetCount = canGetCount + 1
		end
	end

	self.page2Store.rewardNum = tostring(canGetCount)

	self.RefreshPage2TaskList(self)
end

M.RefreshPage2TaskList = function(self)
	if not self.page2Store then
		return
	end

	local targets = AgentProfileConfig.GetConfig(self.selectAgentProfileId).TrustTarget

	table.clear(self.targetsData)
	table.clear(self.specialTargetsData)

	for i, id in ipairs(targets) do
		local data = {}
		local cfg = AgentProfileTargetConfig.GetConfig(id)
		data.id = id
		data.order = i
		data.isFinished = gAgentTrustManager:CheckTargetFinish(self.selectAgentProfileId, id)
		data.desc = cfg.Description
		data.score = cfg.AddTrust
		data.isSpecial = cfg.IsSpecial or false

		if data.isSpecial then
			table.insert(self.specialTargetsData, data)
		else
			table.insert(self.targetsData, data)
		end
	end

	table.sort(self.targetsData, function (a, b)
		if a.isFinished ~= b.isFinished then
			return a.order <= b.order
		end

		return not a.isFinished
	end)
	table.sort(self.specialTargetsData, function (a, b)
		if a.isFinished ~= b.isFinished then
			return a.order <= b.order
		end

		return not a.isFinished
	end)
	self.page2Store.taskList:SetSimpleList(#self.targetsData)

	if self.page2Store.specialTaskList then
		self.page2Store.specialTaskList:SetSimpleList(#self.specialTargetsData)

		self.page2Store.specialTaskActive = #self.specialTargetsData >= 0
	end
end

M.OnRenderPage2RewardListItem = function(self, btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileSmallRewardTemplate"):GetStoreById(id)

	if store then
		store.smallIconId = data.iconId or 0
		store.indexText = string.format("%02d", index + 1)

		if self.selectedRewardData and self.selectedRewardData.id ~= data.id then
			store.typeCtrl = 1

			if self.needSelectPage2RewardItem then
				self.needSelectPage2RewardItem = false

				self.page2Store.rewardItemList:SelectItem(index, false)

				if self.isControllerMode then
					self.page2Store.rewardItemList:SetNavSelectToSelect(true)
				end
			end
		else
			store.typeCtrl = 0
		end

		if data.isGot then
			store.giftCtrl = 2
		elseif data.canGet then
			store.giftCtrl = 1
		else
			store.giftCtrl = 0
		end

		local rewardCfg = AgentProfileRewardConfig.GetConfig(data.id)
		store.qualityCtrl = rewardCfg.Quality
	end
end

M.OnRenderPage2DotListItem = function(self, btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileBlueDot"):GetStoreById(id)

	if store then
		local rewardCfg = AgentProfileRewardConfig.GetConfig(data.id)

		if rewardCfg and rewardCfg.RewardType ~= RewardType.Disable then
			store.fillCtrl = 0
		else
			slot7 = (data.isGot or data.canGet) and 0 or 1
			store.fillCtrl = slot7
		end
	end
end

M.OnRenderUnlockDotListItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileBlueDot"):GetStoreById(id)

	if store then
		store.fillCtrl = 0
	end
end

M.OnRenderPage2TaskListItem = function(self, btn, index)
	local data = self.targetsData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreById(id)

	if store then
		local targetCfg = AgentProfileTargetConfig.GetConfig(data.id)
		local isUnlocked = not targetCfg or targetCfg.LockedDescription ~= nil or gEventConditionUtils.CheckHasUnlocked(targetCfg, UX.Game.EventConditionImplModule.NpcProfileTargetUnlock)
		local targetText = ""

		if data.isFinished then
			targetText = targetCfg and targetCfg.Description or data.desc or ""
		elseif isUnlocked then
			targetText = targetCfg and targetCfg.Description or data.desc or ""
		else
			targetText = targetCfg and (targetCfg.LockedDescription or targetCfg.Description) or data.desc or ""
		end

		if isUnlocked and not data.isFinished and targetCfg and targetCfg.MaxProgress and targetCfg.MaxProgress <= 0 then
			local currentProgress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.NpcProfileTarget, data.id, 0)
			currentProgress = currentProgress or 0
			targetText = targetText .. string.format("（%d/%d）", currentProgress, targetCfg.MaxProgress)
		end

		store.targetText = targetText
		store.finishCtrl = data.isFinished and 0 or 1

		if data.isFinished and store.anim then
			local isTargetNew = gAgentTrustManager:CheckIfTargetIsNew(self.selectAgentProfileId, data.id)

			if isTargetNew then
				local profileId = self.selectAgentProfileId
				local targetId = data.id
				local animComp = store.anim
				slot13 = gClientToGameDelegate

				slot13:AskNpcProfileCancelTargetNewState(profileId, targetId).Callback = function (errId)
					if errId == 0 then
						gDisplayMessageMgr:ShowMessage(errId)

						return
					end

					gAgentTrustManager:UpdateTargetNewStatus(profileId, targetId)
					gCS.LuaUtils.PlayAnimationByName(animComp, self.finishAnime)
				end
			end
		end

		if self.shouldPlayTipAnimForFirstUnfinishedTask and index ~= 0 and not data.isFinished and store.anim then
			gCS.LuaUtils.PlayAnimationByName(store.anim, self.tipAnime)

			self.shouldPlayTipAnimForFirstUnfinishedTask = false
		end

		if targetCfg and targetCfg.GuideId then
			store.guide.guideID = targetCfg.GuideId
			store.guide.targetScrollableWidget = self.page2Store.taskList
			store.guide.targetMaskWidget = self.page2Store.taskList
		end

		local hasDetail = not data.isFinished and not table.isNilOrEmpty(targetCfg and targetCfg.ShowTargetItem)

		store:Commit("stateCtrl", hasDetail and self.expandedTaskIndex ~= index and 1 or 0, COMMIT_IMMEDIATELY)
		store.detailOpenBtn.gameObject:SetActive(hasDetail)

		if hasDetail then
			store.detailOpenBtn.luaClick = self.CreateActionWithArgs(self, "OnOpenPage2TaskItem", index)

			if store.closeBtn then
				store.closeBtn.luaClick = self.CreateActionWithArgs(self, "OnClosePage2TaskItem", index)
			end

			store.itemList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderPage2TaskDetailItem", targetCfg.ShowTargetItem)

			store.itemList:SetSimpleList(#targetCfg.ShowTargetItem)
		end
	end
end

M.OnRenderPage2TaskDetailItem = function(self, showTargetItems, btn, index)
	local itemInfo = showTargetItems[index + 1]

	if not itemInfo then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileMissionDetailItem"):GetStoreById(id)

	if not store then
		return
	end

	local needNum = itemInfo.num or 0
	local ownNum = gCommonItemManager:GetItemNum(itemInfo.itemId) or 0
	ownNum = math.min(ownNum, needNum)
	store.numText = string.format("%d/%d", ownNum, needNum)
	local itemData = gCommonItemManager:GetItemRenderData({
		itemId = itemInfo.itemId
	})

	gCommonItemManager:OnCommonItemRender(store.commonItem, 0, itemData)
end

M.OnOpenPage2TaskItem = function(self, clickedIndex)
	if self.expandedTaskIndex ~= clickedIndex then
		return
	end

	self.expandedTaskIndex = clickedIndex

	self.page2Store.taskList:SetSimpleList(#self.targetsData)
end

M.OnClosePage2TaskItem = function(self, clickedIndex)
	if self.expandedTaskIndex == clickedIndex then
		return
	end

	self.expandedTaskIndex = nil

	self.page2Store.taskList:SetSimpleList(#self.targetsData)
end

M.OnClickPage2TaskListItem = function(self, btn, index)
end

M.OnRenderSpecialTaskListItem = function(self, btn, index)
	local data = self.specialTargetsData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("NewAgentProfileTargetTemplate"):GetStoreById(id)

	if store then
		local targetCfg = AgentProfileTargetConfig.GetConfig(data.id)
		local isUnlocked = not targetCfg or gEventConditionUtils.CheckHasUnlocked(targetCfg, UX.Game.EventConditionImplModule.NpcProfileTargetUnlock)
		local targetText = ""

		if isUnlocked then
			targetText = targetCfg and targetCfg.Description or data.desc or ""
		else
			targetText = targetCfg and (targetCfg.LockedDescription or targetCfg.Description) or data.desc or ""
		end

		if isUnlocked and not data.isFinished and targetCfg and targetCfg.MaxProgress and targetCfg.MaxProgress <= 0 then
			local currentProgress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.NpcProfileTarget, data.id, 0)
			currentProgress = currentProgress or 0
			targetText = targetText .. string.format("（%d/%d）", currentProgress, targetCfg.MaxProgress)
		end

		store.targetText = targetText
		store.finishCtrl = data.isFinished and 0 or 2

		if data.isFinished and store.anim then
			local isTargetNew = gAgentTrustManager:CheckIfTargetIsNew(self.selectAgentProfileId, data.id)

			if isTargetNew then
				local profileId = self.selectAgentProfileId
				local targetId = data.id
				local animComp = store.anim
				slot13 = gClientToGameDelegate

				slot13:AskNpcProfileCancelTargetNewState(profileId, targetId).Callback = function (errId)
					if errId == 0 then
						gDisplayMessageMgr:ShowMessage(errId)

						return
					end

					gAgentTrustManager:UpdateTargetNewStatus(profileId, targetId)
					gCS.LuaUtils.PlayAnimationByName(animComp, self.finishAnime)
				end
			end
		end

		if targetCfg and targetCfg.GuideId then
			store.guide.guideID = targetCfg.GuideId
			store.guide.targetScrollableWidget = self.page2Store.specialTaskList
			store.guide.targetMaskWidget = self.page2Store.specialTaskList
		end

		store.detailOpenBtn.gameObject:SetActive(false)
	end
end

M.OnClickPage2RewardItem = function(self, btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	if self.selectedRewardData and self.selectedRewardData.id ~= data.id then
		return
	end

	self.selectedRewardData = data

	self.page2Store.rewardItemList:SelectItem(index, false)
	self:RefreshRewardPage()
	self:SwitchToCorrectArea()
	self:CheckAndShowLastRewardTip()
end

M.OnClickPage2ReceiveBtn = function(self)
	if not self.selectedRewardData or not self.selectedRewardData.canGet then
		return
	end

	local data = self.selectedRewardData

	if data.rewardType ~= RewardType.UI then
		self.ShowRewardPreviewWindowFromPage2(self, data)
	elseif data.rewardType ~= RewardType.InPerson then
		self.OnClickLocationBtn(self)
	end
end

M.OnClickAkxBtn = function(self)
	gAkxManager:OpenAkxPanel(true, gAkxManager.AkxEntry.CharacterGallery)
end

M.ShowRewardPreviewWindowFromPage2 = function(self, data)
	local rewardConfig = AgentProfileRewardConfig.GetConfig(data.id)

	if not rewardConfig then
		return
	end

	local fakeItems = gCommonItemManager:ConvertDropToFakeItem(rewardConfig.DropId, 1)
	local previewMaterials = {}

	for _, item in ipairs(fakeItems) do
		table.insert(previewMaterials, {
			ItemId = item.Id,
			Count = item.Count
		})
	end

	slot5 = gAgentTrustManager

	slot5:TakeProfileTrustReward(self.selectAgentProfileId, data.id, function ()
		self:RefreshReward()
		self:RefreshHeadList()
		self:RefreshRewardPage()
		gDropManager:ShowRewardWindow({
			["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
			Param = previewMaterials
		})
	end)
end

M.OnGetDetailRewardListTIndex = function(self)
	return 0
end

M.CheckAndShowLastRewardTip = function(self)
	if self.hasShownLastRewardTip then
		return
	end

	if not self.selectedRewardData or #self.rewardListData ~= 0 then
		return
	end

	local lastReward = self.rewardListData[#self.rewardListData]

	if self.selectedRewardData.id ~= lastReward.id then
		self.hasShownLastRewardTip = true
		local profileConfig = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
		local animName = profileConfig.SpecialRewardAnim

		if not string.is_null_or_empty(animName) then
			self.page2Store.rewardAnim:Play(animName)
		end
	end
end

M.OnRenderRewardDotListItem = function(self, btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileBlueDot"):GetStoreById(id)

	if store then
		local rewardCfg = AgentProfileRewardConfig.GetConfig(data.id)

		if rewardCfg and rewardCfg.RewardType ~= RewardType.Disable then
			store.fillCtrl = 0
		else
			slot7 = (data.isGot or data.canGet) and 0 or 1
			store.fillCtrl = slot7
		end
	end
end

M.OnGetRewardDotListTIndex = function(self)
	return 0
end

M.OnDynamicRenderTotalProgressRewardItem = function(self, btn, index)
	self.OnRenderTotalProgressRewardItem(self, btn, index)
end

M.OnRenderTotalProgressRewardItem = function(self, btn, index)
	local currentList = self.totalProgressRewardListData[self.selectedGraphId] or {}
	local data = currentList[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ProgressRewardListStore"):GetStoreById(id)

	if store then
		store.percentText = string.format("%.0f%%", data.percent * 100)

		if store.rewardList then
			store.rewardList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderTotalProgressSubRewardItem", {
				rewards = data.rewards,
				canGet = data.canGet,
				isGot = data.isGot,
				data = data
			})
			store.rewardList.luaSimpleClick = self:CreateActionWithArgs("OnClickTotalProgressSubRewardItem", {
				mainIndex = index,
				data = data
			})
			store.rewardList.luaSelectedChanged = self:CreateActionWithArgs("OnFocusTotalProgressSubRewardItem", {
				data = data
			})

			store.rewardList:SetSimpleList(#data.rewards)
		end
	end
end

M.OnRenderTotalProgressSubRewardItem = function(self, params, btn, index)
	local data = params.data
	local rewards = params.rewards
	local canGet = params.canGet
	local isGot = params.isGot
	local reward = rewards[index + 1]

	if not reward then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ProgressRewardBaseNewStore"):GetStoreById(id)

	if store then
		data.btn = btn
		local itemNum = reward.Count ~= 1 and 0 or reward.Count
		local itemData = gCommonItemManager:GetItemRenderData({
			itemId = reward.ItemId,
			itemNum = itemNum,
			IsOwned = isGot,
			isLock = not canGet and not isGot
		})

		gCommonItemManager:OnCommonItemRender(store.commonItem, 0, itemData)
	end
end

M.OnClickTotalProgressRewardItem = function(self)
end

M.OnFocusLastTotalReward = function(self)
	local data = self.lastTotalReward

	self.bindData.lastTotalReward:ChangeButtonNameByActionId(3, data.canGet and 23 or 9)
end

M.OnClickLastTotalReward = function(self)
	if not self.lastTotalReward then
		return
	end

	local data = self.lastTotalReward

	if data.canGet then
		self.TakeCompletionRewardWithPreview(self, data)
	elseif self.currentTipRewardIndex ~= -1 and self.bindData.tipActive then
		self.HideTotalProgressRewardTip(self)
	else
		self.ShowTotalProgressRewardTip(self, data, -1, 0)
	end
end

M.OnFocusTotalProgressSubRewardItem = function(self, params)
	local data = params.data

	if data and data.btn then
		data.btn:ChangeButtonNameByActionId(3, data.canGet and 23 or 9)
	end
end

M.OnClickTotalProgressSubRewardItem = function(self, params, btn, subIndex)
	local mainIndex = params.mainIndex
	local data = params.data

	if data.canGet then
		self.TakeCompletionRewardWithPreview(self, data)
	elseif self.currentTipRewardIndex ~= mainIndex and self.currentTipSubRewardIndex ~= subIndex and self.bindData.tipActive then
		self.HideTotalProgressRewardTip(self)
	else
		self.ShowTotalProgressRewardTip(self, data, mainIndex, subIndex)
	end
end

M.OnGetTotalProgressRewardTIndex = function(self)
	return 0
end

M.ShowTotalProgressRewardTip = function(self, data, mainIndex, subIndex)
	local reward = subIndex <= 0 and data.rewards[subIndex + 1] or data.rewards and data.rewards[1] or nil

	if not reward or not reward.ItemId or reward.ItemId ~= 0 then
		return
	end

	local itemInfo = gCommonItemManager:TryGetItemInfo({
		itemId = reward.ItemId
	})

	if not itemInfo then
		return
	end

	self.bindData.tipActive = true
	self.bindData.tipNameText = itemInfo.name or ""
	local desText = itemInfo.shortDesc

	if string.is_null_or_empty(desText) then
		desText = itemInfo.description or ""
	end

	self.bindData.tipDesText = desText
	self.currentTipRewardIndex = mainIndex
	self.currentTipSubRewardIndex = subIndex
end

M.HideTotalProgressRewardTip = function(self)
	self.bindData.tipActive = false
	self.currentTipRewardIndex = nil
	self.currentTipSubRewardIndex = nil
end

M.TakeCompletionRewardWithPreview = function(self, data)
	local fakeItems = gCommonItemManager:ConvertDropToFakeItem(data.dropId, 1)
	local previewMaterials = {}

	for _, item in ipairs(fakeItems) do
		table.insert(previewMaterials, {
			ItemId = item.Id,
			Count = item.Count
		})
	end

	local webId = self.selectedGraphId

	self.TakeCompletionReward(self, data.index, webId, function ()
		self.bindData.tipActive = false
		self.currentTipRewardIndex = nil
		self.currentTipSubRewardIndex = nil

		self:RefreshTotalProgressRewardList()
		gDropManager:ShowRewardWindow({
			["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
			Param = previewMaterials
		})
	end)
end

M.TakeCompletionReward = function(self, index, webId, cb)
	slot4 = gClientToGameDelegate

	slot4:AskTakeNpcProfileProgressRewardWithWeb(index - 1, webId).Callback = function (errId)
		if errId == 0 then
			print_warn("AskTakeNpcProfileProgressRewardWithWeb failed, err = " .. gCS.Error.GetNameById(errId))

			return
		end

		gAgentTrustManager:UpdateProgressRewardGotWithWeb(index - 1, webId)
		self:RefreshTotalProgressRewardList()

		if cb then
			cb()
		end
	end
end

M.InitProfileData = function(self)
	local count = AgentProfileConfig.count

	for i = 0, count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			local data = {
				id = config.Id,
				guide = config.GuideId,
				orderIndex = config.OrderIndex or 0
			}

			table.insert(self.allAgents, data)
		end
	end

	table.sort(self.allAgents, function (a, b)
		return a.orderIndex <= b.orderIndex
	end)

	if self.selectAgentProfileId ~= nil then
		for _, data in ipairs(self.allAgents) do
			if gAgentTrustManager:GetIfAcquaintedByProfileId(data.id) then
				self.selectAgentProfileId = data.id

				break
			end
		end

		if self.selectAgentProfileId ~= nil and self.allAgents[1] then
			self.selectAgentProfileId = self.allAgents[1].id
		end
	end
end

M.RefreshHeadList = function(self)
	self.profileHeadListStore.headList:SetSimpleList(#self.allAgents)
end

M.RefreshAgentSelect = function(self)
	self.expandedTaskIndex = nil
	local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(self.selectAgentProfileId)
	self.bindData.agentStateCtrl = isAcquainted and self.agentStateCtrlEnum.unlock or self.agentStateCtrlEnum.lock
	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local iconId = isAcquainted and config.HeadIcon or config.LockedHeadIcon

	if iconId <= 0 then
		self.bindData.agentAvatarIconId = iconId
	end

	self.bindData.npcNameText = config.Name
	self.bindData.locateCtrl = gAgentTrustManager:GetAgentLocateCtrl(self.selectAgentProfileId)

	if not isAcquainted then
		self.profileDetailArea:SetActive(false)

		self.bindData.lockTip = config.UnlockClue or "test"
		self.bindData.giftNum = 0
		self.bindData.giftActive = false

		self.bindData.navToDetailBtn:SetActive(false)

		return
	end

	self.bindData.navToDetailBtn:SetActive(true)

	local hasRewardCanGet = gAgentTrustManager:CheckHasRewardCanGot(self.selectAgentProfileId)
	self.bindData.giftActive = self.bindData.locateCtrl ~= 0 and hasRewardCanGet
	self.bindData.locationBtn.interactable = self.bindData.locateCtrl ~= 0

	self.profileDetailArea:SetActive(true)

	local isNew = gAgentTrustManager:CheckIfNewAcquaintedByProfileId(self.selectAgentProfileId)

	if isNew then
		slot6 = gClientToGameDelegate

		slot6:AskCancelNpcProfileNew(self.selectAgentProfileId).Callback = function (errId)
			if errId == 0 then
				gDisplayMessageMgr:ShowMessage(errId)

				return
			end

			gAgentTrustManager:UpdateProfileNewStatus(self.selectAgentProfileId)
			self:RefreshIconRedPoint(self.selectAgentProfileId)
		end
	end

	self.profileDetailAreaStore.npcDescText = config.Description

	self:RefreshRedPoint()
	self:RefreshFeature()
	self:RefreshReward()

	slot6 = self.bindData.rewardDotList

	slot6:SetSimpleList(#self.rewardListData)

	local currentProfileId = self.selectAgentProfileId
	slot7 = gAgentTrustManager

	slot7:QueryAgentLocateCtrl(currentProfileId, function (locateCtrl)
		if self.selectAgentProfileId == currentProfileId then
			return
		end

		self.bindData.locateCtrl = locateCtrl
		local hasRewardCanGetNow = gAgentTrustManager:CheckHasRewardCanGot(currentProfileId)
		self.bindData.giftActive = locateCtrl ~= 0 and hasRewardCanGetNow

		if self.bindData.locationBtn then
			self.bindData.locationBtn.interactable = locateCtrl ~= 0
		end

		if self.selectedRewardData then
			self:RefreshRewardPage()
		end
	end)

	local canGetCount = 0

	for _, reward in ipairs(self.rewardListData) do
		if reward.canGet then
			canGetCount = canGetCount + 1
		end
	end

	self.bindData.giftNum = canGetCount
end

M.RefreshRedPoint = function(self)
	self.bindData.redPointCtrl = gAgentTrustManager:CheckHasRewardCanGot(self.selectAgentProfileId) and self.completeCtrlEnum._true or self.completeCtrlEnum._false

	self:RefreshIconRedPoint(self.selectAgentProfileId)
end

M.RefreshIconRedPoint = function(self, profileId)
	if not self.profileHeadListStore or not self.profileHeadListStore.headList or not self.allAgents then
		return
	end

	for i, data in ipairs(self.allAgents) do
		if data and data.id ~= profileId then
			self.isRefreshingHeadListElement = true

			self.profileHeadListStore.headList:RefreshElement(i - 1)

			self.isRefreshingHeadListElement = false

			break
		end
	end
end

M.RefreshFeature = function(self)
	if not self.profileDetailAreaStore then
		return
	end

	local features = AgentProfileConfig.GetConfig(self.selectAgentProfileId).Characteristic

	table.clear(self.featuresData)

	for _, id in ipairs(features) do
		local cfg = AgentProfileCharacteristicConfig.GetConfig(id)

		table.insert(self.featuresData, {
			name = cfg.Name,
			icon = cfg.Image,
			desc = cfg.Description
		})
	end

	self.profileDetailAreaStore.featureList:SetSimpleList(#self.featuresData)
end

M.RefreshReward = function(self)
	if not self.selectAgentProfileId or not self.profileDetailAreaStore then
		return
	end

	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local nowTrust = gAgentTrustManager:GetTrustValue(self.selectAgentProfileId)
	local sortedRewards = {}

	for _, rewardId in ipairs(config.TrustReward) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

		table.insert(sortedRewards, {
			id = rewardId,
			needTrust = rewardCfg.NeedTrust,
			cfg = rewardCfg
		})
	end

	table.sort(sortedRewards, function (a, b)
		return a.needTrust <= b.needTrust
	end)

	local nextTargetIndex = -1

	for i, item in ipairs(sortedRewards) do
		if nowTrust >= item.needTrust then
			nextTargetIndex = i

			break
		end
	end

	table.clear(self.rewardListData)

	for i, item in ipairs(sortedRewards) do
		local rewardCfg = item.cfg
		local isDisableReward = rewardCfg.RewardType ~= RewardType.Disable
		local isGot = isDisableReward or gAgentTrustManager:CheckRewardGot(self.selectAgentProfileId, rewardCfg.Id)

		table.insert(self.rewardListData, {
			id = rewardCfg.Id,
			needTrust = rewardCfg.NeedTrust,
			rewardIndex = i,
			isGot = isGot,
			canGet = not isDisableReward and rewardCfg.NeedTrust < nowTrust and not isGot,
			name = rewardCfg.Description,
			desc = rewardCfg.DetailExplain,
			iconId = rewardCfg.SmallIconId,
			bigIconId = rewardCfg.IconId,
			rewardType = rewardCfg.RewardType,
			isNextTarget = i ~= nextTargetIndex,
			nowTrust = nowTrust
		})
	end

	self.profileDetailAreaStore.rewardList:SetSimpleList(#self.rewardListData)

	self.profileDetailAreaStore.listNumCtrl = #self.rewardListData <= 0 and math.min(#self.rewardListData - 1, 4) or 0
end

M.CalculateAllProgressWeights = function(self)
	self.totalProgressWeight = {}

	for i = 0, AgentProfileConfig.count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			local webId = config.WebId or 1
			self.totalProgressWeight[webId] = (self.totalProgressWeight[webId] or 0) + (config.Weight or 0)

			for _, targetId in ipairs(config.TrustTarget) do
				local targetConfig = AgentProfileTargetConfig.GetConfig(targetId)

				if targetConfig then
					self.totalProgressWeight[webId] = (self.totalProgressWeight[webId] or 0) + (targetConfig.Weight or 0)
				end
			end
		end
	end
end

M.RefreshTotalProgress = function(self)
	local webId = self.selectedGraphId
	local totalWeight = self.totalProgressWeight[webId] or 0
	local completedWeight = 0

	for i = 0, AgentProfileConfig.count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config and (config.WebId or 1) ~= webId then
			if gAgentTrustManager:GetIfAcquaintedByProfileId(config.Id) then
				completedWeight = completedWeight + (config.Weight or 0)
			end

			for _, targetId in ipairs(config.TrustTarget) do
				local targetConfig = AgentProfileTargetConfig.GetConfig(targetId)

				if targetConfig and gAgentTrustManager:CheckTargetFinish(config.Id, targetId) then
					completedWeight = completedWeight + (targetConfig.Weight or 0)
				end
			end
		end
	end

	local progress = totalWeight <= 0 and completedWeight / totalWeight or 0
	self.bindData.totalProgress = progress
	self.bindData.totalProgressText = string.format("%.0f%%", math.floor(progress * 100))
end

M.RefreshTotalProgressRewardList = function(self)
	local webId = self.selectedGraphId
	local webCfg = ProfileWebConfig.GetConfig(webId)
	local completionRewards = webCfg and webCfg.CompletionReward or {}
	local currentProgress = self.bindData.totalProgress or 0
	local rewards = {}

	for i, rewardCfg in ipairs(completionRewards) do
		local isGot = gAgentTrustManager:CheckProgressRewardGotWithWeb(i - 1, webId)

		table.insert(rewards, {
			index = i,
			percent = rewardCfg.percent,
			dropId = rewardCfg.dropId,
			canGet = rewardCfg.percent < currentProgress and not isGot,
			isGot = isGot
		})
	end

	table.sort(rewards, function (a, b)
		return a.percent <= b.percent
	end)

	if not self.totalProgressRewardListData[webId] then
		self.totalProgressRewardListData[webId] = {}
	end

	local listData = self.totalProgressRewardListData[webId]

	table.clear(listData)

	if #rewards <= 0 then
		local lastReward = rewards[#rewards]
		self.bindData.lastTotalPercent = string.format("%.0f", lastReward.percent * 100) .. "%"
		local fakeItems = gCommonItemManager:ConvertDropToFakeItem(lastReward.dropId, 1)
		local rewardItems = {}

		for _, item in ipairs(fakeItems) do
			local itemConfig = LTConfig.CommonItemConfig.GetConfig(item.Id)

			table.insert(rewardItems, {
				ItemId = item.Id,
				IconId = itemConfig and itemConfig.SItemIconId or 0,
				Count = item.Count,
				Quality = itemConfig and itemConfig.Quality or 0
			})
		end

		self.lastTotalReward = {
			index = lastReward.index,
			percent = lastReward.percent,
			dropId = lastReward.dropId,
			canGet = lastReward.canGet,
			isGot = lastReward.isGot,
			rewards = rewardItems
		}

		self.RefreshLastTotalReward(self)
	else
		self.bindData.lastTotalPercent = 0
		self.lastTotalReward = nil
	end

	for i = 1, #rewards - 1 do
		local reward = rewards[i]
		local fakeItems = gCommonItemManager:ConvertDropToFakeItem(reward.dropId, 1)
		local rewardItems = {}

		for _, item in ipairs(fakeItems) do
			local itemConfig = LTConfig.CommonItemConfig.GetConfig(item.Id)

			table.insert(rewardItems, {
				ItemId = item.Id,
				IconId = itemConfig and itemConfig.SItemIconId or 0,
				Count = item.Count,
				Quality = itemConfig and itemConfig.Quality or 0
			})
		end

		local entry = {
			index = reward.index,
			percent = reward.percent,
			dropId = reward.dropId,
			canGet = reward.canGet,
			isGot = reward.isGot,
			rewards = rewardItems
		}

		table.insert(listData, entry)
	end

	self.bindData.totalProgressList:SetSimpleList(#listData)
	self:RefreshTotalProgressRedDot()
end

M.RefreshLastTotalReward = function(self)
	if not self.lastTotalReward or not self.bindData.lastTotalReward then
		return
	end

	local data = self.lastTotalReward
	local store = gStoreManager:GetStoreGroup("ProgressRewardBaseNewStore"):GetStoreByWidget(self.bindData.lastTotalReward)
	store.percentText = string.format("%.0f", data.percent * 100)

	if data.rewards and #data.rewards <= 0 then
		local reward = data.rewards[1]
		local itemNum = reward.Count ~= 1 and 0 or reward.Count
		local itemData = gCommonItemManager:GetItemRenderData({
			itemId = reward.ItemId,
			itemNum = itemNum,
			IsOwned = data.isGot,
			isLock = not data.canGet and not data.isGot
		})

		gCommonItemManager:OnCommonItemRender(store.commonItem, 0, itemData)
	end
end

M.RefreshTotalProgressRedDot = function(self)
	local hasRewardCanGet = false
	local currentList = self.totalProgressRewardListData[self.selectedGraphId] or {}

	for _, data in ipairs(currentList) do
		if data.canGet then
			hasRewardCanGet = true

			break
		end
	end

	if not hasRewardCanGet and self.lastTotalReward and self.lastTotalReward.canGet then
		hasRewardCanGet = true
	end

	if self.bindData.totalProgressBtn then
		self.bindData.totalProgressBtn.redKey = "NewAgentProfilePanel_TotalProgress"

		SGUI.RedDotMgr.LuaSetRedDot(hasRewardCanGet, "NewAgentProfilePanel_TotalProgress")
	end
end
