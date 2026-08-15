local LinkConfig = LTConfig.LinkConfig
local VehicleConfig = LTConfig.VehicleConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
C_OnlinePreparePanelStore = DefClass("C_OnlinePreparePanelStore", C_OnlinePreparePanelStore, C_StoreGroup)
GroupName2Class.OnlinePreparePanelStore = C_OnlinePreparePanelStore
local M = C_OnlinePreparePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local TICK_RATE = 10

function M:ctor()
	self:OnInit()

	self.msgEvents = {
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self:CreateAction(self.OnMemberInfoChange)
	}
	self.mgr = gLinkManager
end

function M:OnAwake()
	self.bindData.customBtn.luaClick = self:CreateAction("OnCustomBtnClick")
	self.bindData.readyBtn.luaClick = self:CreateAction("OnReadyBtnClick")
	self.bindData.customBackBtn.luaClick = self:CreateAction("OnCustomBtnClick")
	self.bindData.playerList.luaSimpleRenderItem = self:CreateAction(self.OnMemberRenderItem)
	self.bindData.playerList.onGetTIndex = self:CreateAction(self.OnGetMemberEleIndex)
	self.bindData.modelTab.OnRenderTab = self:CreateAction("OnModelPanelDisplay")
	self.bindData.ruleBtn.luaClick = self:CreateAction("OnRuleBtnClick")
	self.bindData.displayList.onGetTIndex = self:CreateAction("OnGetDisplayEleIndex")
	self.bindData.displayList.luaRenderItem = self:CreateAction("OnRenderDisplayItem")

	self:OnInit()

	self.switchStore = gStoreManager:GetStoreGroup("CommonSwitchPanelStore")

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGetDisplayEleIndex(index)
	local data = self.hudItemList[index + 1]

	if data.memberId then
		return 1
	end

	return 0
end

function M:OnRenderDisplayItem(btn, index)
	local i = index + 1
	self.hudModelBtns[i] = btn

	FrameTimer.New(function ()
		self:RefreshHudModelBtn(i)
	end, 1):Start()
end

function M:OnMemberRenderItem(btn, index)
	local data = self.memberList[index + 1]

	if data.tIndex ~= 1 then
		self.mgr:OnMemberRenderItem(btn, index, data)

		return
	end

	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local dutyInfo = self.mgr:GetDutyConfigInfo(data.dutyId)
	store.nameLabel = dutyInfo.name
	store.iconId = dutyInfo.icon
end

function M:OnGetMemberEleIndex(index)
	return self.memberList[index + 1].tIndex
end

function M:OnModelPanelDisplay()
	self.subModelStore = gStoreManager:GetStoreGroup("ModelViewerStore")

	self.subModelStore:SetModelViewType(self.mgr.currentGameCfg.ModelViewType)
	self:OnRefreshModelView()
end

function M:OnRuleBtnClick()
	gPanelManager:CheckShow(gPanelId.ITEM_INFO_ONLY_TEXT_PANEL, self.mgr:GetDutyDesc())
end

function M:OnCustomBtnClick()
	self.bindData.inCustom = self.bindData.inCustom == BOOL2CTL[true] and BOOL2CTL[false] or BOOL2CTL[true]

	if self.bindData.inCustom == BOOL2CTL[false] then
		self.switchStore.type = C_CommonSwitchPanelStore.Tabs.AVATAR
	end
end

function M:OnReadyBtnClick()
	self.mgr:AskReadyToPlay(not self.isReady)
end

function M:OnInit()
	self.memberList = {}
	self.hudItemList = {}
	self.currentTime = 0
	self.dirty = false
	self.timeTick = 0
	self.endTime = 0
	self.subModelStore = nil
	self.hudModelBtns = {}
	self.isReady = nil
end

function M:OnSwitchSelect(type, subType, id)
	if type == C_CommonSwitchPanelStore.Tabs.AVATAR then
		self.mgr:SetSelfReadyInfo({
			SpiritId = id
		})
		self:OnCharacterSwitch(id)
	elseif type == C_CommonSwitchPanelStore.Tabs.FASHION then
		-- Nothing
	elseif type == C_CommonSwitchPanelStore.Tabs.CAR then
		self.mgr:SetSelfReadyInfo({
			VehicleId = id
		})
	elseif type == C_CommonSwitchPanelStore.Tabs.ONLINE_POSE then
		self.mgr:SetSelfReadyInfo({
			PoseId = id
		})
	end

	self.dirty = true
end

function M:OnUpdate()
	self.timeTick = self.timeTick + 1

	if self.timeTick <= TICK_RATE then
		return
	end

	self.timeTick = 0

	if gCS.TimeManager.ServerUnixTime < self.endTime then
		local currentTime = self.endTime - gCS.TimeManager.ServerUnixTime
		self.bindData.timeLabel = gTimeUtils:FormatTimeHMS(currentTime)
	end

	if self.dirty then
		self.dirty = false

		self.mgr:AskChangePrepareInfo(self.mgr:GetReadyInfo(gPlayerManager.infoLogin.bindData.pid))
	end
end

function M:OnShow(panelId, data)
	self.bindData.modelTab.selectedIndex = 0
	self.bindData.hasDuty = BOOL2CTL[#self.mgr.currentGameCfg.MemberComposition > 0]
	self.endTime = self.mgr.currentLinkGame.PrepareStartTime + self.mgr.currentGameCfg.PrepareTime
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
end

function M:OnClose()
	self:ClearMessageEvents()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnMemberInfoChange()
	self:RefreshMemberList()
	self:OnRefreshModelView()
	self:RefreshReadyState()
end

function M:RefreshReadyState()
	local isReady = self.mgr.matchMemberReady[gPlayerManager.infoLogin.bindData.pid]
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

function M:GetMemberListByDuty(dutyId, ret)
	for k, v in pairs(self.mgr.matchMemberDuty) do
		if v == dutyId then
			ret[#ret + 1] = {
				tIndex = 2,
				memberId = k
			}
		end
	end
end

function M:RefreshMemberList()
	self.memberList = {}

	if #self.mgr.currentGameCfg.MemberComposition > 0 then
		for i = 1, #self.mgr.currentGameCfg.MemberComposition do
			local ele = {
				tIndex = 1,
				dutyId = self.mgr.currentGameCfg.MemberComposition[i].duty
			}

			table.insert(self.memberList, ele)
			self:GetMemberListByDuty(ele.dutyId, self.memberList)
		end

		self.bindData.playerList:SetSimpleList(#self.memberList)

		self.bindData.dutyDesc = self.mgr:GetDutyDescOfSelf()
	else
		local isInRace = self.mgr:CheckIsInRace()

		if isInRace then
			table.insert(self.memberList, {
				tIndex = 0,
				memberId = gPlayerManager.infoLogin.bindData.pid
			})
		end

		for i = 1, #self.mgr.matchMemberList do
			local member = self.mgr.matchMemberList[i]

			if not isInRace or member.memberId ~= gPlayerManager.infoLogin.bindData.pid then
				local ele = {
					tIndex = 0,
					memberId = member.memberId
				}

				table.insert(self.memberList, ele)
			end
		end

		self.bindData.playerList:SetSimpleList(#self.memberList)
	end
end

function M:OnRefreshMemberInfo()
	self.bindData.playerList:RefreshLogicList()
	self:OnRefreshModelView()
end

function M:RefreshHudModelBtns()
	for i = 1, #self.hudItemList do
		self:RefreshHudModelBtn(i)
	end
end

function M:RefreshHudModelBtn(index)
	local btn = self.hudModelBtns[index]

	if not btn then
		return
	end

	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.hudItemList[index]
	local uiPos = nil

	if data.memberId then
		local offset = LinkConfig.HudModelOffset
		uiPos = self.subModelStore:GetModelPositon(data.index, Vector3.New(offset[1], offset[2], offset[3]))
	else
		local offset = LinkConfig.HudVehicleOffset
		uiPos = self.subModelStore:GetVehiclePos(data.index, Vector3.New(offset[1], offset[2], offset[3]))
	end

	store.nameLabel = data.label

	btn.transform:SetLocalPosition(uiPos)
end

function M:OnRefreshModelView()
	if not self.subModelStore then
		return
	end

	local index = 1
	self.hudItemList = {}

	for i = 1, #self.memberList do
		local member = self.memberList[i]

		if member.memberId then
			local actionId, groupId, expressionId = self.mgr:GetPoseDetail(member.memberId)

			self.subModelStore:LoadModel(index, self.mgr:GetCharacterId(member.memberId), self.mgr:GetFashionInfo(member.memberId))
			self.subModelStore:LoadPose(index, actionId, groupId, expressionId)

			if member.memberId == gPlayerManager.infoLogin.bindData.pid and self.mgr.currentGameCfg.UseVehicle then
				local vehicleId = self.mgr:GetVehicleId(member.memberId)
				local cfg = VehicleConfig.GetConfig(vehicleId)

				self.subModelStore:LoadVehicle(1, vehicleId)
				table.insert(self.hudItemList, {
					index = 1,
					vehicleId = vehicleId,
					label = cfg and cfg.VehicleName or ""
				})
			end

			table.insert(self.hudItemList, {
				memberId = member.memberId,
				index = index,
				label = self.mgr:GetMatchNumber(member.memberId)
			})

			index = index + 1
		end
	end

	self.bindData.displayList:SetList(#self.hudItemList)
	self:RefreshHudModelBtns()
end

function M:OnCharacterSwitch(characterId)
	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(characterId)
	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)
	local modelConfig = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)
	local bodyType = modelConfig.CameraBodyType

	if bodyType == 0 then
		bodyType = modelConfig.BodyType
	end

	self.switchStore:OnBodyTypeRefresh(bodyType)
end
