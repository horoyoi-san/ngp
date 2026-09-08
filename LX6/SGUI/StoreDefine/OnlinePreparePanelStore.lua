-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlinePreparePanelStore.lua
-- Decompiled from: 01115_OnlinePreparePanelStore.lua_b7eb2b6e5427.luajit

local InputButtonNameConfig = LTConfig.InputButtonNameConfig
local LinkConfig = LTConfig.LinkConfig
local LinkStageConfig = LTConfig.LinkStageConfig
local consts = gClientConst
C_OnlinePreparePanelStore = DefClass("C_OnlinePreparePanelStore", C_OnlinePreparePanelStore, C_StoreGroup)
GroupName2Class.OnlinePreparePanelStore = C_OnlinePreparePanelStore
local M = C_OnlinePreparePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local TICK_RATE = 10

M.ctor = function(self)
	self.OnInit(self)

	self.msgEvents = {
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, self.OnMemberInfoChange)
	}
	self.DUTY_TEMPLATE = {
		["\\xbbJ\\xb4q\\xed\\x85\\x97"] = 1,
		["^Ib"] = 0
	}
	self.mgr = gLinkManager
end

M.OnAwake = function(self)
	self.bindData.customBtn.luaClick = self:CreateAction(self.OnCustomBtnClick)
	self.bindData.readyBtn.luaClick = self:CreateAction(self.OnReadyBtnClick)
	self.bindData.customBackBtn.luaClick = self:CreateAction(self.OnCustomBtnClick)
	self.bindData.playerList.luaSimpleRenderItem = self:CreateAction(self.OnMemberRenderItem)
	self.bindData.playerList.luaDynamicRenderItem = self:CreateAction(self.OnMemberRenderItem)
	self.bindData.playerList.onGetTIndex = self:CreateAction(self.OnGetMemberEleIndex)
	self.bindData.displayList.onGetTIndex = self:CreateAction(self.OnGetDisplayEleIndex)
	self.bindData.displayList.luaRenderItem = self:CreateAction(self.OnRenderDisplayItem)
	self.bindData.dutyList.luaSimpleRenderItem = self:CreateAction(self.OnDutyRenderItem)
	self.bindData.expandBtn.luaClick = self:CreateAction(self.OnExpandBtnClick)
	self.bindData.chatBtn.luaClick = self:CreateAction(self.OnChatBtnClick)

	self:OnInit()

	self.switchStore = gStoreManager:GetStoreGroup("CommonSwitchPanelStore")
	self.MODEL_OFFSET = LinkConfig.HudModelOffset
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)

	self.mgr.cs.OnUnitModelLoaded = self.CreateAction(self, self.OnSyncPlayerUnitInfo)
	self.mgr.cs.OnVehicleModelLoaded = self.CreateAction(self, self.OnSyncVehicleUnitInfo)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.mgr.cs.OnUnitModelLoaded = nil
	self.mgr.cs.OnVehicleModelLoaded = nil
end

M.OnGetDisplayEleIndex = function(self, index)
	return 0
end

M.OnRenderDisplayItem = function(self, btn, index)
	self.hudModelBtns[index] = btn
end

M.OnMemberRenderItem = function(self, btn, index)
	local data = self.memberList[index + 1]

	if data.tIndex == 1 then
		self.mgr:OnMemberRenderItem(btn, index, data)
	else
		self.OnDutyRenderItem(self, btn, index, data.dutyId)
	end
end

M.OnDutyRenderItem = function(self, btn, idnex, dutyId)
	dutyId = dutyId or self.mgr:GetSelfDuty()
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local dutyInfo = self.mgr:GetDutyConfigInfo(dutyId)
	store.nameLabel = dutyInfo.name
	store.iconId = dutyInfo.icon
end

M.OnGetMemberEleIndex = function(self, index)
	return self.memberList[index + 1].tIndex
end

M.OnCustomBtnClick = function(self)
	self.bindData.inCustom = self.bindData.inCustom ~= BOOL2CTL[true] and BOOL2CTL[false] or BOOL2CTL[true]

	if self.bindData.inCustom ~= BOOL2CTL[false] then
		self.switchStore.type = C_CommonSwitchPanelStore.Tabs.AVATAR
	end
end

M.OnReadyBtnClick = function(self)
	self.mgr:AskReadyToPlay(not self.isReady)
end

M.OnInit = function(self)
	self.memberList = {}
	self.hudItemList = {}
	self.currentTime = 0
	self.pendingPatch = nil
	self.timeTick = 0
	self.endTime = 0
	self.subModelStore = nil
	self.hudModelBtns = {}
	self.baseUnits = {}
	self.baseVehicles = {}
	self.isReady = nil
end

M.SetPendingReadyInfo = function(self, patch)
	self.pendingPatch = self.pendingPatch or {}

	for k, v in pairs(patch) do
		self.pendingPatch[k] = v
	end
end

M.OnSwitchSelect = function(self, type, subType, id)
	if type ~= C_CommonSwitchPanelStore.Tabs.AVATAR then
		self.SetPendingReadyInfo(self, {
			SpiritId = id
		})
		self.OnCharacterSwitch(self, id)
	elseif type ~= C_CommonSwitchPanelStore.Tabs.FASHION then
		-- Nothing
	elseif type ~= C_CommonSwitchPanelStore.Tabs.CAR then
		self.SetPendingReadyInfo(self, {
			VehicleId = id
		})
	elseif type ~= C_CommonSwitchPanelStore.Tabs.ONLINE_POSE then
		self.SetPendingReadyInfo(self, {
			PoseId = id
		})
	end
end

M.OnUpdate = function(self)
	self.timeTick = self.timeTick + 1

	if self.timeTick < TICK_RATE then
		return
	end

	self.timeTick = 0

	self.RefreshUnitInfo(self)

	if self.pendingPatch then
		local selfPid = gPlayerManager.infoLogin.bindData.pid
		local snapshot = self.mgr:GetReadyInfo(selfPid) or {}
		local sendInfo = {}

		for k, v in pairs(snapshot) do
			sendInfo[k] = v
		end

		for k, v in pairs(self.pendingPatch) do
			sendInfo[k] = v
		end

		self.lastPendingPatch = self.pendingPatch
		self.pendingPatch = nil
		slot4 = self.mgr

		slot4:AskChangePrepareInfo(sendInfo, function (isSuccess)
			if not isSuccess then
				self.pendingPatch = self.lastPendingPatch
				self.lastPendingPatch = nil
			end
		end)
	end
end

M.OnShow = function(self, panelId, data)
	local stages = self.mgr.currentGameCfg.Stages
	local prepareTime = nil

	for i = 1, #stages do
		if stages[i].Stage ~= LinkStageConfig.Prepare then
			prepareTime = stages[i].Timeout

			break
		end
	end

	if not prepareTime then
		print_error("LinkMultiPlayerConfig中联机玩法", self.mgr.currentGameCfg.Id, "没有配置准备阶段时间")

		prepareTime = 600
	end

	local stageStartTime = 0

	if self.mgr.currentLinkGame then
		if self.mgr.currentLinkGame.StageStartTime and self.mgr.currentLinkGame.StageStartTime == 0 then
			stageStartTime = self.mgr.currentLinkGame.StageStartTime
		elseif self.mgr.currentLinkGame.PrepareStartTime and self.mgr.currentLinkGame.PrepareStartTime == 0 then
			stageStartTime = self.mgr.currentLinkGame.PrepareStartTime
		end
	end

	self.endTime = stageStartTime + prepareTime

	self.bindData.countDown:Play(self.endTime - gCS.TimeManager.ServerUnixTime)

	local selectedDict = {
		[C_CommonSwitchPanelStore.Tabs.AVATAR] = self.mgr:GetCharacterId(gPlayerManager.infoLogin.bindData.pid),
		[C_CommonSwitchPanelStore.Tabs.CAR] = self.mgr:GetVehicleId(gPlayerManager.infoLogin.bindData.pid),
		[C_CommonSwitchPanelStore.Tabs.ONLINE_POSE] = self.mgr:GetPoseId(gPlayerManager.infoLogin.bindData.pid)
	}

	self.switchStore:SetData(self.mgr.currentGameCfg.UseVehicle, selectedDict, self:CreateAction(self.OnSwitchSelect))
	self:OnCharacterSwitch(self.mgr:GetCharacterId(gPlayerManager.infoLogin.bindData.pid))
	self:RefreshMemberList()
	self:RefreshReadyState()
	self.SubGroup.RoomChatStore:RegisterParentNaviArea(self.bindData.navigationArea)
	self.SubGroup.ModelViewerStore:SetModelViewType(self.mgr.currentGameCfg.ModelViewType)

	self.bindData.dutyExpand = BOOL2CTL[true]

	self:RefreshDutyInfo()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnMemberInfoChange = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.RefreshMemberList(self)
	self.RefreshReadyState(self)
	self.RefreshDutyInfo(self)
end

M.RefreshReadyState = function(self)
	local isReady = self.mgr:CheckPlayerIsReady(gPlayerManager.infoLogin.bindData.pid)
	self.isReady = isReady
	self.bindData.isReady = BOOL2CTL[isReady]
	self.bindData.customBtn.interactable = not isReady

	self.bindData.readyBtn:SetActive(not self.mgr:CheckIsBlockReady())

	if isReady then
		local cfg = InputButtonNameConfig.GetConfig(432)

		self.bindData.navigationArea:RelpaceButtonNameByButtonName(311, 432)

		self.bindData.readyLabel = cfg.Name
	else
		local cfg = InputButtonNameConfig.GetConfig(311)

		self.bindData.navigationArea:RelpaceButtonNameByButtonName(432, 311)

		self.bindData.readyLabel = cfg.Name
	end
end

M.GetMemberListByDuty = function(self, dutyId, ret)
	local linkGame = self.mgr.currentLinkGame

	if not linkGame or not linkGame.Members then
		return
	end

	for i = 1, #linkGame.Members do
		local member = linkGame.Members[i]

		if member.Duty ~= dutyId then
			ret[#ret + 1] = {
				["a\\x9f\\x8a\\x86Y"] = 2,
				memberId = member.Pid,
				dutyId = dutyId
			}
		end
	end
end

M.RefreshMemberList = function(self)
	self.memberList = {}

	if #self.mgr.currentGameCfg.MemberComposition <= 0 then
		for i = 1, #self.mgr.currentGameCfg.MemberComposition do
			local ele = {
				["a\\x9f\\x8a\\x86Y"] = 1,
				dutyId = self.mgr.currentGameCfg.MemberComposition[i].duty
			}

			table.insert(self.memberList, ele)
			self.GetMemberListByDuty(self, ele.dutyId, self.memberList)
		end

		self.bindData.playerList:SetSimpleList(#self.memberList)
	else
		local isInRace = self.mgr:CheckIsInRace()

		if isInRace then
			table.insert(self.memberList, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				memberId = gPlayerManager.infoLogin.bindData.pid
			})
		end

		local memberList = self.mgr.currentLinkGame and self.mgr.currentLinkGame.Members

		if memberList then
			for i = 1, #memberList do
				local member = memberList[i]

				if not isInRace or member.Pid == gPlayerManager.infoLogin.bindData.pid then
					local ele = {
						["a\\x9f\\x8a\\x86Y"] = 0,
						memberId = member.Pid
					}

					table.insert(self.memberList, ele)
				end
			end

			self.bindData.playerList:SetSimpleList(#self.memberList)
		end
	end

	self.hudItemList = {}
	local cnt = self.mgr.currentLinkGame and self.mgr.currentLinkGame.Members and #self.mgr.currentLinkGame.Members or 0

	for i = 1, cnt do
		local member = self.mgr.currentLinkGame.Members[i]
		local ele = {
			memberId = member.Pid
		}
		self.hudItemList[i] = ele
	end

	self.bindData.displayList:SetList(#self.hudItemList)
end

M.OnRefreshMemberInfo = function(self)
	self.bindData.playerList:RefreshLogicList()
end

M.OnCharacterSwitch = function(self, characterId)
	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(characterId)
	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)
	local modelConfig = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)
	local bodyType = modelConfig.CameraBodyType

	if bodyType ~= 0 then
		bodyType = modelConfig.BodyType
	end

	self.switchStore:OnBodyTypeRefresh(bodyType)
end

M.OnStart = function(self)
	local createParam = gTimelineManager:Timeline_CreateTimelineData()
	createParam.pos = Vector3.New(0, 500, 0)
	createParam.rot = Vector3.zero

	gTimelineManager:Timeline_LoadAndPlay("OnlinePrepareTL", createParam)
end

M.OnDestroy = function(self)
	gTimelineManager:Timeline_Stop("OnlinePrepareTL")
end

M.OnSyncPlayerUnitInfo = function(self, index, unit)
	self.baseUnits[index] = unit
end

M.RefreshUnitInfo = function(self)
	for i = 1, #self.hudItemList do
		local index = i - 1
		local btn = self.hudModelBtns[index]

		if not btn then
			-- Nothing
		else
			local unit = self.baseUnits[index]

			if unit and L50.L50App.Scene.GamePlayUtils and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
				if not unit.HeadPos then
					-- Nothing
				else
					local store = self.GetStoreByWidget(self, btn)

					if store then
						local data = self.hudItemList[i]
						store.numberLabel = self.mgr:GetMatchNumber(data.memberId)
						store.color = self.mgr:GetColorInfo(data.memberId)
						store.isReady = self.mgr:CheckPlayerIsReady(data.memberId) and 1 or 0
						store.nameLabel = gFriendManager:GetPlayerRealName(data.memberId)

						self.SubGroup.ModelViewerStore:CalcPositionForUnit(index + 1, unit)

						local localPos = gCS.LuaUtils.CalcPositionInScreenNew(self.bindData.displayList.rectTransform, unit.HeadPos)
						btn.rectTransform.anchoredPosition = Vector2.New(localPos.x + self.MODEL_OFFSET.X, localPos.y + self.MODEL_OFFSET.Y)
					end
				end
			end
		end
	end
end

M.OnSyncVehicleUnitInfo = function(self, index, vehicle)
end

M.RefreshDutyInfo = function(self)
	self.bindData.hasDuty = BOOL2CTL[#self.mgr.currentGameCfg.MemberComposition >= 0]

	self.bindData.dutyList:SetSimpleList(0)
	self.bindData.dutyList:AddSimpleData(self.DUTY_TEMPLATE.DUTY)

	if self.bindData.dutyExpand ~= consts.BOOL2CTL[true] then
		self.bindData.dutyList:AddSimpleLabel(self.DUTY_TEMPLATE.DESCRIPTION, self.mgr:GetDutyDescOfSelf())
	end

	self.bindData.dutyList:RefreshList()
end

M.OnExpandBtnClick = function(self)
	self.bindData.dutyExpand = self.bindData.dutyExpand ~= consts.BOOL2CTL[false] and consts.BOOL2CTL[true] or consts.BOOL2CTL[false]

	self:RefreshDutyInfo()
end

M.OnChatBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.SOCIAL_CHAT_HOME_PANEL_HALF_SCREEN, {
		topChannelId = gSocialChatManager.ChatTopChannel.Channels,
		subChannelId = UX.Game.MessageChannel.Room
	})
end
