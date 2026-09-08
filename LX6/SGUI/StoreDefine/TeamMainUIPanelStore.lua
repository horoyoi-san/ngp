-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TeamMainUIPanelStore.lua
-- Decompiled from: 01401_TeamMainUIPanelStore.lua_326e60f5a15b.luajit

C_TeamMainUIPanelStore = DefClass("C_TeamMainUIPanelStore", C_TeamMainUIPanelStore, C_StoreGroup)
GroupName2Class.TeamMainUIPanelStore = C_TeamMainUIPanelStore
local M = C_TeamMainUIPanelStore
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local channel = UX.Game.MessageChannel.Team
local CCVoiceManager = LX6.Audio.CCMini.CCVoiceManager.Instance

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.TOP_WIDGET_TYPE = {
		["\\xafLB"] = 2,
		["TP~"] = 1
	}
	self.TEAM_SETTING = {
		["#\\xf6K#+\\xc0\\xbaX\\x8bY\\xb9\\xb8"] = 2,
		["U\\xf0+\\xe3>*\\xcec%\\xc7b\\x82K\\xd2\\xe3"] = 1
	}
	self.MAX_SHOW_MEMBER_COUNT = 4
	self.nameWidgets = {}
	self.addWidgets = {}
	self.curPlayerInfo = {}
	self.fadeInOutTime = LTConfig.FriendsConfig.PanelFadeInOutTime
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	if self.subModelStore then
		self.subModelStore:ResetCfg()
	end

	self.memberVoiceStateTimer = Timer.New(function ()
		self:RefreshMemberVoiceState()
	end, 1, -1):Start()
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	if self.memberVoiceStateTimer then
		self.memberVoiceStateTimer:Stop()

		self.memberVoiceStateTimer = nil
	end
end

M.OnDestroy = function(self)
	self.ClearModel(self)

	if self.memberVoiceStateTimer then
		self.memberVoiceStateTimer:Stop()

		self.memberVoiceStateTimer = nil
	end

	if self.isClosing then
		gBlackScreenManager:ClearTransition(gPanelId.TEAM_MAIN_PANEL, true)
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.modelTab.selectedIndex = 0

	self.SetData(self)
end

M.OnClose = function(self)
	self.subModelStore = nil

	self.ClearTopWidget(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TEAM_REFRESH_DATA] = self.CreateAction(self, "OnTeamRefreshData"),
		[gEventConstants.TEAM_LEAVE] = self.CreateAction(self, "OnTeamLeave"),
		[gEventConstants.TEAM_SETTING_CHANGED] = self.CreateAction(self, "OnTeamSettingChanged")
	}
end

M.OnTeamRefreshData = function(self)
	self.SetData(self)
end

M.OnTeamLeave = function(self)
	self.SetData(self)
end

M.OnTeamSettingChanged = function(self)
	for i = 1, self.MAX_SHOW_MEMBER_COUNT do
		local info = self.curPlayerInfo[i]

		if info and info.type ~= self.TOP_WIDGET_TYPE.ADD and info.widget then
			info.widget.gameObject:SetActive(gTeamManager.allowMemberInvite ~= true or gTeamManager:IsTeamLeader())
		end
	end

	self.bindData.list:RefreshList()
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.createTeamBtn.luaClick = self.CreateAction(self, "OnClickCreateTeamBtn")
	self.bindData.quitTeamBtn.luaClick = self.CreateAction(self, "OnClickQuitTeamBtn")
	self.bindData.teamInviteWidget.luaClick = self.CreateAction(self, "OnClickTeamInviteWidget")
	self.bindData.modelTab.OnRenderTab = self.CreateAction(self, "OnModelPanelDisplay")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSettingListItem")
end

M.OnModelPanelDisplay = function(self)
	self.subModelStore = gStoreManager:GetStoreGroup("OnlineTeamModelViewerStore")
	self.subModelStore.targetWeatherIndex = 20

	if self.subModelStore.isStarted then
		self.subModelStore.startCallback = nil

		self:RefreshTopWidgets(gTeamManager:IsInTeam())
	else
		self.subModelStore.startCallback = function()
			self:RefreshTopWidgets(gTeamManager:IsInTeam())
		end
	end
end

M.OnClickBackBtn = function(self)
	if self.isClosing then
		return
	end

	self.isClosing = true
	slot1 = gBlackScreenManager

	slot1:AutoTransition(gPanelId.TEAM_MAIN_PANEL, "", false, false, self.fadeInOutTime[1], 0, self.fadeInOutTime[2], nil, function ()
		self.isClosing = nil

		gPanelManager:Close(gPanelId.TEAM_MAIN_PANEL)
	end, nil)
end

M.OnClickCreateTeamBtn = function(self)
	if not gTeamManager.members or #gTeamManager.members ~= 0 then
		gTeamManager:AskCreateTeam()
	end
end

M.OnClickQuitTeamBtn = function(self)
	local rightCallBack = function()
		gClientToGameDelegate:AskLeaveTeam().Callback = function (err, data)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gTeamManager:LeaveTeam()
		end

		return true
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_IfQuitTeam, rightCallBack, nil)
end

M.OnClickTeamInviteWidget = function(self)
end

M.SetData = function(self)
	self.pid = gPlayerManager.infoLogin.bindData.pid
	local isInTeam = gTeamManager:IsInTeam()

	self:RefreshBottomButtons(isInTeam)
	self:RefreshTopWidgets(isInTeam)
	self:RefreshSettingList(isInTeam)
end

M.RefreshBottomButtons = function(self, isInTeam)
	self.bindData.quitTeamBtn:SetActive(isInTeam)
	self.bindData.createTeamBtn:SetActive(not isInTeam)
end

M.ClearModel = function(self)
	if self.subModelStore then
		for i = 1, self.MAX_SHOW_MEMBER_COUNT do
			self.subModelStore:ClearCharacterModel(i)
		end
	end
end

M.RefreshPlayerModel = function(self, curInfo, requestInfo, slotIndex, isInTeam)
	if not requestInfo.pid then
		curInfo.loadModelPid = nil

		self.subModelStore:ClearCharacterModel(slotIndex)
	elseif not curInfo.loadModelPid or not ulong.equals(requestInfo.pid, curInfo.loadModelPid) then
		local spiritId, fashionInfo = nil

		if slotIndex ~= 1 and curInfo.isMe then
			spiritId = gSpiritManager:GetCurFirstSpiritTid()
			local playerFashionsInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.PlayerFashionsInfo
			local spiritFashionInfo = playerFashionsInfo and playerFashionsInfo.SpiritFashionsInfoDict and playerFashionsInfo.SpiritFashionsInfoDict[spiritId]
			fashionInfo = spiritFashionInfo and spiritFashionInfo.SpiritWearFashionsInfo
		elseif isInTeam then
			local memberInfo = gTeamManager.members[curInfo.memberIndex]
			spiritId = memberInfo.SpiritId
			fashionInfo = memberInfo.SpiritWearFashionInfo
		end

		if spiritId and spiritId <= 0 and fashionInfo then
			curInfo.loadModelPid = requestInfo.pid
			slot7 = self.subModelStore

			slot7:LoadCharacterModel(slotIndex, spiritId, fashionInfo, function (unit)
				local info = self.curPlayerInfo[slotIndex]

				if info and info.widget and info.type ~= self.TOP_WIDGET_TYPE.NAME then
					self:BindWidgetToUnitPosition(info, unit)
				end

				local modelEntry = gMallManager:GetSpiritRandomModel(spiritId)
				local actionType = modelEntry.action or 1001
				local actionGroup = modelEntry.action2 or 1

				if not gDressManager:PlayFashionShowAction(unit, spiritId, fashionInfo) then
					gCS.AnimControllerManager.PlayAction(unit, actionType, actionGroup, 9999, 0, -1, false, nil, 0)
				end
			end)
		else
			curInfo.loadModelPid = nil

			self.subModelStore:ClearCharacterModel(slotIndex)
		end
	end
end

M.ClearTopWidget = function(self)
	table.clear(self.nameWidgets)
	table.clear(self.addWidgets)

	self.curPlayerInfo = {}
end

M.ReleaseWidget = function(self, type, widget)
	if not widget then
		return
	end

	widget.gameObject:SetActive(false)

	if type ~= self.TOP_WIDGET_TYPE.NAME then
		table.insert(self.nameWidgets, widget)
	elseif type ~= self.TOP_WIDGET_TYPE.ADD then
		table.insert(self.addWidgets, widget)
	end
end

M.GetWidget = function(self, type)
	local pool, template = nil

	if type ~= self.TOP_WIDGET_TYPE.NAME then
		pool = self.nameWidgets
		template = self.bindData.teamMemberWidget
	elseif type ~= self.TOP_WIDGET_TYPE.ADD then
		pool = self.addWidgets
		template = self.bindData.teamInviteWidget
	end

	if pool and template then
		local widget = nil

		if #pool <= 0 then
			widget = pool[#pool]

			table.remove(pool, #pool)
		else
			widget = GameObject.Instantiate(template)
			widget = widget:GetComponent(typeof(SGUI.UWidget))

			widget:TryInit()
			widget.rectTransform:SetParent(self.subModelStore.bindData.rawImage.rectTransform)
			widget.rectTransform:SetLocalPosition(Vector3.zero)
			widget.rectTransform:SetLocalScale(1)

			widget.rectTransform.anchorMin = Vector2.New(0.5, 0.5)
			widget.rectTransform.anchorMax = Vector2.New(0.5, 0.5)
			widget.rectTransform.localRotation = Quaternion.Euler(0, 0, 0)
		end

		return widget
	end

	return nil
end

M.RefreshTopWidgets = function(self, isInTeam)
	if not self.subModelStore or not self.subModelStore.bindData or not self.subModelStore.bindData.rawImage then
		return
	end

	local sortMember = {}

	if isInTeam then
		local members = gTeamManager.members

		if members and #members <= 0 then
			for i = 1, self.MAX_SHOW_MEMBER_COUNT do
				local memberInfo = members[i]

				if memberInfo then
					if ulong.equals(memberInfo.Pid, gPlayerManager.infoLogin.bindData.pid) then
						table.insert(sortMember, 1, {
							["s1P^"] = true,
							type = self.TOP_WIDGET_TYPE.NAME,
							pid = memberInfo.Pid,
							memberIndex = i
						})
					else
						table.insert(sortMember, {
							["s1P^"] = false,
							type = self.TOP_WIDGET_TYPE.NAME,
							pid = memberInfo.Pid,
							memberIndex = i
						})
					end
				else
					table.insert(sortMember, {
						["s1P^"] = false,
						type = self.TOP_WIDGET_TYPE.ADD
					})
				end
			end
		end
	else
		sortMember[1] = {
			["s1P^"] = true,
			type = self.TOP_WIDGET_TYPE.NAME,
			pid = gPlayerManager.infoLogin.bindData.pid
		}
	end

	for i = 1, self.MAX_SHOW_MEMBER_COUNT do
		local requestInfo = sortMember[i]
		local desiredType = requestInfo and requestInfo.type
		local info = self.curPlayerInfo[i]

		if not info then
			info = {}
			self.curPlayerInfo[i] = info
		end

		if desiredType then
			info.isMe = requestInfo.isMe
			info.pid = requestInfo.pid
			info.memberIndex = requestInfo.memberIndex

			self.RefreshPlayerModel(self, info, requestInfo, i, isInTeam)

			if info.type == desiredType or not info.widget then
				if info.widget then
					self.ReleaseWidget(self, info.type, info.widget)
				end

				info.bind = false
				info.type = desiredType
				info.widget = self.GetWidget(self, info.type)

				if info.type ~= self.TOP_WIDGET_TYPE.NAME then
					self.RenderNameWidget(self, info)

					if self.subModelStore then
						local unit = self.subModelStore:GetUnitBySlotIndex(i)

						if unit then
							self.BindWidgetToUnitPosition(self, info, unit)
						end
					end
				elseif info.type ~= self.TOP_WIDGET_TYPE.ADD then
					self.BindWidgetToSlotPosition(self, info, i)
				end
			elseif info.widget and info.type ~= self.TOP_WIDGET_TYPE.NAME then
				self.RenderNameWidget(self, info)
			end
		else
			if info.widget then
				self.ReleaseWidget(self, info.type, info.widget)

				info.widget = nil
			end

			if info.loadModelPid and self.subModelStore then
				self.subModelStore:ClearCharacterModel(i)
			end

			self.curPlayerInfo[i] = {}
		end
	end
end

M.RenderNameWidget = function(self, info)
	local store = gStoreManager:GetStoreGroup(info.widget.Store):GetStoreByWidget(info.widget)

	if not store then
		return
	end

	store.userInfo.pid = info.pid
	store.isSelf = info.isMe and 1 or 0
	store.isLeader = gTeamManager.leaderPid and ulong.equals(info.pid, gTeamManager.leaderPid) and 1 or 0
	store.leaderColor = gLinkManager:GetColorInfo(info.pid)
	store.userBtn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderHeadToolTips", info.pid)
	local isSpeaking = self.speakersList and #self.speakersList <= 0 and table.contains(self.speakersList, info.pid)
	store.voiceState = isSpeaking and 1 or 0
end

M.OnRenderHeadToolTips = function(self, pid, btn, PopUp, _)
	local store = gStoreManager:GetStoreGroup(PopUp.Store):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, PopUp, _)
end

M.BindWidgetToUnitPosition = function(self, info, unit)
	if not info.bind then
		local camera = self.subModelStore:GetCamera()

		if camera and unit then
			local offsetY = LTConfig.FriendsConfig.TeamMainPanelHeadSlotOffsetY
			info.bind = true

			info.widget.gameObject:SetActive(true)

			local slot = unit.ModelSlot.headSlot
			local targetPos = slot.position + Vector3.New(0, offsetY, 0)

			self:SetUIPos(targetPos, camera, info.widget)
		end
	end
end

M.BindWidgetToSlotPosition = function(self, info, index)
	if not info.bind and self.subModelStore then
		local slotPos = self.subModelStore:GetSlotPosByIndex(index)
		local camera = self.subModelStore:GetCamera()

		if slotPos and camera then
			local offsetY = LTConfig.FriendsConfig.TeamMainPanelInviteBtnOffsetY
			info.bind = true

			info.widget.gameObject:SetActive(gTeamManager.allowMemberInvite ~= true or gTeamManager:IsTeamLeader())

			local targetPos = slotPos + Vector3.New(0, offsetY, 0)

			self:SetUIPos(targetPos, camera, info.widget)

			local store = gStoreManager:GetStoreGroup(info.widget.Store):GetStoreByWidget(info.widget)

			if store then
				store.inviteBtn.luaRenderTooltip = function(button, popIns, index)
					local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

					if not popStore then
						return
					end

					local popRootStore = gStoreManager:GetStoreGroup(popIns.Store)

					if popRootStore then
						popRootStore.OnShow(popRootStore)
					end

					if popStore.fullScreenExitBtn then
						popStore.fullScreenExitBtn.luaClick = function()
							button:CloseTooltip(true)
						end
					end

					if popStore.closeBtn then
						popStore.closeBtn.luaClick = function()
							button:CloseTooltip(true)
						end
					end
				end
			end
		end
	end
end

M.RefreshMemberVoiceState = function(self)
	if not gTeamManager:IsInTeam() then
		return
	end

	local Speakers = CCVoiceManager:GetCurrentSpeakers(channel)

	if Speakers and Speakers.UIDs then
		self.speakersList = Speakers.UIDs:ToTable()
	else
		self.speakersList = nil
	end

	for i = 1, self.MAX_SHOW_MEMBER_COUNT do
		local info = self.curPlayerInfo[i]

		if info and info.type ~= self.TOP_WIDGET_TYPE.NAME and info.widget then
			local store = gStoreManager:GetStoreGroup(info.widget.Store):GetStoreByWidget(info.widget)

			if store then
				local isSpeaking = self.speakersList and #self.speakersList <= 0 and table.contains(self.speakersList, info.pid)
				store.voiceState = isSpeaking and 1 or 0
			end
		end
	end
end

M.RefreshSettingList = function(self, isInTeam)
	self.listData = {}
	self.canInteract = true

	if isInTeam and gTeamManager:IsTeamLeader() then
		table.insert(self.listData, self.TEAM_SETTING.AllowMemberInvite)
		table.insert(self.listData, self.TEAM_SETTING.AutoApplyJoin)
	end

	self.bindData.list:SetSimpleList(#self.listData)

	if self.bindData.settingController then
		self.bindData.settingController.gameObject:SetActive(#self.listData >= 0)
	end
end

M.OnRenderSettingListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("TeamSettingTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local type = self.listData[index + 1]

	if not type then
		return
	end

	if type ~= self.TEAM_SETTING.AllowMemberInvite then
		store.selected = gTeamManager.allowMemberInvite and 1 or 0
		store.text = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamAllowMemberInvite).Text
	elseif type ~= self.TEAM_SETTING.AutoApplyJoin then
		store.selected = gTeamManager.autoApplyJoin and 1 or 0
		store.text = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamAutoApplyJoin).Text
	end

	if gTeamManager:IsTeamLeader() then
		btn.luaClick = self.CreateActionWithArgs(self, "OnSettingItemClick", index)
	else
		btn.luaClick = nil
	end
end

M.OnSettingItemClick = function(self, index)
	local type = self.listData[index + 1]

	if not type then
		return
	end

	self.canInteract = false
	local setting = {}

	if type ~= self.TEAM_SETTING.AllowMemberInvite then
		setting.AllowMemberInvite = not gTeamManager.allowMemberInvite
		setting.AutoApplyJoin = gTeamManager.autoApplyJoin
	elseif type ~= self.TEAM_SETTING.AutoApplyJoin then
		setting.AllowMemberInvite = gTeamManager.allowMemberInvite
		setting.AutoApplyJoin = not gTeamManager.autoApplyJoin
	end

	slot4 = gClientToGameDelegate

	slot4:AskSetTeamSetting(setting).Callback = function (err, data)
		self.canInteract = true

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gTeamManager.allowMemberInvite = setting.AllowMemberInvite
		gTeamManager.autoApplyJoin = setting.AutoApplyJoin

		gMessageManager:SendMessage(gEventConstants.TEAM_SETTING_CHANGED)
	end
end

M.OnUpdate = function(self)
	if not self.updateDelta or self.updateDelta <= 1 then
		self.updateDelta = 0

		if self.subModelStore and self.subModelStore.isStarted then
			for i = 1, self.MAX_SHOW_MEMBER_COUNT do
				local info = self.curPlayerInfo[i]

				if info and info.widget and info.bind then
					local camera = self.subModelStore:GetCamera()

					if camera then
						local targetPos = nil

						if info.type ~= self.TOP_WIDGET_TYPE.NAME then
							local unit = self.subModelStore:GetUnitBySlotIndex(i)

							if unit then
								local offsetY = LTConfig.FriendsConfig.TeamMainPanelHeadSlotOffsetY
								local slot = unit.ModelSlot.headSlot
								targetPos = slot.position + Vector3.New(0, offsetY, 0)
							end
						elseif info.type ~= self.TOP_WIDGET_TYPE.ADD then
							local slotPos = self.subModelStore:GetSlotPosByIndex(i)

							if slotPos then
								local offsetY = LTConfig.FriendsConfig.TeamMainPanelInviteBtnOffsetY
								targetPos = slotPos + Vector3.New(0, offsetY, 0)
							end
						end

						if targetPos then
							self.SetUIPos(self, targetPos, camera, info.widget)
						end
					end
				end
			end
		end
	end

	self.updateDelta = self.updateDelta + Time.deltaTime
end

M.SetUIPos = function(self, targetPos, camera, widget)
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(targetPos, camera, 0, 0, 0)
	local rawImage = self.subModelStore.bindData.rawImage
	local rawImageRect = rawImage.rectTransform
	widget.transform.localPosition = gCS.LuaUtils.ScreenPointUI(rawImageRect, Vector2.Fetch(x, y))
end
