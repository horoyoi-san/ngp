-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WebJobPanelStore.lua
-- Decompiled from: 01161_WebJobPanelStore.lua_230e22faafcc.luajit

C_WebJobPanelStore = DefClass("C_WebJobPanelStore", C_WebJobPanelStore, C_StoreGroup)
GroupName2Class.WebJobPanelStore = C_WebJobPanelStore
local M = C_WebJobPanelStore
local CountryConfig = LTConfig.CollectionCountryConfig
local JobBoardConfig = LTConfig.UrbanJobJobBoardConfig
local JobTagConfig = LTConfig.UrbanJobJobTagConfig
local UrbanJobConfig = LTConfig.UrbanJobConfig
local savedCountryId = nil
local CARD_TYPE_CTRL = {
	["\\xa8\\xb0\\x8az.\\xf2*"] = 0,
	["G\\x92\\x85\\x86E"] = 2,
	["\\xaa\\xa1\\xa7s7\\xf04"] = 4,
	["B\\xa0\\x88\\xa0\\xb4"] = 1,
	["|#v^"] = 5,
	["\\x83i~"] = 3
}
local CARD_CONTENT_CTRL = {
	["\\xcc\\xd53\\xff"] = 1,
	["G\\x83\\x83\\x82M"] = 0
}
local STATE_TO_TYPE_CTRL = {
	[UX.Game.JobBoardJobState.Available] = CARD_TYPE_CTRL.canApply,
	[UX.Game.JobBoardJobState.Joined] = CARD_TYPE_CTRL.onJob,
	[UX.Game.JobBoardJobState.Locked] = CARD_TYPE_CTRL.locked,
	[UX.Game.JobBoardJobState.Full] = CARD_TYPE_CTRL.max,
	[UX.Game.JobBoardJobState.Applying] = CARD_TYPE_CTRL.applying
}
local HOST_CTRL_SHOW = 1
local HOST_CTRL_HIDE = 0

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.jobBoardInfo = nil
	self.tabCountryList = {}
	self.curTabIndex = -1
	self.curCountryId = savedCountryId
	self.contentEntryList = {}
	self.cardTagsData = {}
	self.tipsTimer = nil
	self.modelStore = nil
	self.pendingModelConfirm = nil
	self.pendingActions = {}
	self.outerScrollRect = nil
	self.planeFromPosition = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isEmptyEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.HideTips(self)
	self.HideModel(self)
	self.HidePlane(self)
	self.RefreshHeadIcon(self)

	self.pendingActions = {}

	self.RequestJobBoardInfo(self)
end

M.OnClose = function(self)
	self.HideTips(self)
	self.HidePlane(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.On_SYNC_SPIRIT_JOBINFO] = self.CreateAction(self, self.OnSpiritJobInfoChanged)
	}
end

M.OnSpiritJobInfoChanged = function(self)
	self.RequestJobBoardInfo(self)
end

M.GetHostBindData = function(self)
	return self.parent and self.parent.bindData or nil
end

M.ShowTips = function(self, text, duration)
	local host = self.GetHostBindData(self)

	if not host then
		return
	end

	host.tipsContent = text or ""
	host.tipsCtrl = HOST_CTRL_SHOW

	if self.tipsTimer then
		self.tipsTimer = coroutine.stop(self.tipsTimer)
	end

	self.tipsTimer = coroutine.start(function ()
		coroutine.wait(duration or 2)
		self:HideTips()
	end)
end

M.HideTips = function(self)
	if self.tipsTimer then
		self.tipsTimer = coroutine.stop(self.tipsTimer)
	end

	local host = self.GetHostBindData(self)

	if host then
		host.tipsCtrl = HOST_CTRL_HIDE
	end
end

local PLANE_ANIM_NAME = "S_Vx_WebJobPlatformContentWiget_Paperplane_sequence"

M.RecordPlaneFrom = function(self, applyBtn)
	self.planeFromPosition = applyBtn and applyBtn.transform.position or nil
end

M.PlayPlaneAnim = function(self)
	local fromPosition = self.planeFromPosition
	self.planeFromPosition = nil

	if not fromPosition then
		return
	end

	local planeWidget = self.bindData.planeWidget
	local planeMove = self.bindData.planeMove
	local targetPos = self.bindData.targetPos

	if gClientUtils.IsNil(planeWidget) or gClientUtils.IsNil(planeMove) or gClientUtils.IsNil(targetPos) then
		return
	end

	local planeParent = planeWidget.rectTransform.parent

	if gClientUtils.IsNil(planeParent) then
		return
	end

	local fromLocalPos = planeParent:InverseTransformPoint(fromPosition)
	local toLocalPos = planeParent:InverseTransformPoint(targetPos.position)

	planeMove:Kill(false)

	planeWidget.localPosition = fromLocalPos

	planeWidget:SetActive(true)
	FrameTimer.New(function ()
		if gClientUtils.IsNil(planeWidget) or gClientUtils.IsNil(planeMove) then
			return
		end

		local planeAnim = self.bindData.planeAnim

		if gClientUtils.NotNil(planeAnim) then
			if planeAnim:IsPlaying(PLANE_ANIM_NAME) then
				planeAnim:Stop()
			end

			planeAnim:Play(PLANE_ANIM_NAME)
		end

		planeMove:DoLocalMove(toLocalPos, self:CreateAction(self.OnPlaneMoveComplete))
	end, 1):Start()
end

M.OnPlaneMoveComplete = function(self)
	local planeAnim = self.bindData.planeAnim

	if gClientUtils.NotNil(planeAnim) then
		planeAnim.Stop(planeAnim)
	end

	local planeWidget = self.bindData.planeWidget

	if gClientUtils.NotNil(planeWidget) then
		planeWidget.SetActive(planeWidget, false)
	end
end

M.HidePlane = function(self)
	self.planeFromPosition = nil
	local planeMove = self.bindData.planeMove

	if gClientUtils.NotNil(planeMove) then
		planeMove.Kill(planeMove, false)
	end

	self.OnPlaneMoveComplete(self)
end

M.RegisterWidget = function(self)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabListItem)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderContentListItem)
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTabList)
	self.bindData.contentList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickContentList)
	self.bindData.contentList.luaLayoutSet = self.CreateAction(self, self.OnContentListLayoutSet)
end

M.OnContentListLayoutSet = function(self)
	self.RefreshWebLayout(self)
end

M.RefreshWebLayout = function(self)
	FrameTimer.New(function ()
		local host = self.parent
		local wc = host and host.webContainer
		local root = wc and wc.content

		if root then
			local rootRT = root.rectTransform

			if rootRT.childCount <= 0 then
				local mainRT = rootRT:GetChild(0)
				local targetH = mainRT.rect.height * mainRT.localScale.y

				if targetH <= 0 and math.abs(rootRT.rect.height - targetH) <= 0.5 then
					root:SetSizeY(targetH)
					root:SetLayoutDirty()
				end
			end
		end

		if host and host.RefreshContainer then
			host:RefreshContainer()
		end
	end, 1):Start()
end

M.RequestJobBoardInfo = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskGetJobBoardInfo().Callback = function (errorId, info)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self.jobBoardInfo = info

		self:RefreshJobCount()
		self:RefreshTabList()
	end
end

M.RefreshJobCount = function(self)
	local info = self.jobBoardInfo
	self.bindData.currentJobNum = tostring(info and info.JoinedJobCount or 0)
	self.bindData.maxJobNum = tostring(info and info.MaxJobCount or 0)
end

M.RefreshHeadIcon = function(self)
	local curSpiritTid = gCS.BattleNetcodeUtils.GetCurrentSpiritTemplateId(gPlayerManager:GetLoginRolePid())
	local cfg = curSpiritTid and LTConfig.FightSpiritConfig.GetConfig(curSpiritTid)
	self.bindData.headIconId = cfg and cfg.SHeadIconID or 0
end

M.RefreshTabList = function(self)
	self.tabCountryList = {}
	local module = UX.Game.EventConditionImplModule.JobBoardCountryShow

	for index = 0, CountryConfig.count - 1 do
		local cfg = CountryConfig.LoadAt(index)

		if cfg then
			local progress = gEventConditionUtils.GetEventInfoProgress(module, cfg.Id, 0)
			local threshold = cfg.JobUnlockProgress or 0

			if progress > threshold then
				table.insert(self.tabCountryList, cfg)
			end
		end
	end

	self.bindData.tabList:SetSimpleList(#self.tabCountryList)

	if #self.tabCountryList <= 0 then
		local selectIndex = 0

		if self.curCountryId then
			for i, cfg in ipairs(self.tabCountryList) do
				if cfg.Id ~= self.curCountryId then
					selectIndex = i - 1

					break
				end
			end
		end

		self.SelectTab(self, selectIndex)
	else
		self.curTabIndex = -1
		self.curCountryId = nil
		self.contentEntryList = {}
		self.cardTagsData = {}
		self.bindData.isEmpty = self.isEmptyEnum._true

		self.bindData.contentList:SetSimpleList(0)
		self:RefreshWebLayout()
	end
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = self.tabCountryList[index + 1]

	if not cfg then
		return
	end

	store.title = cfg.Name
end

M.SelectTab = function(self, index)
	local cfg = self.tabCountryList[index + 1]

	if not cfg then
		return
	end

	self.curTabIndex = index
	self.curCountryId = cfg.Id
	savedCountryId = cfg.Id

	self.bindData.tabList:SetItemSelected(index, true)
	self:RefreshContentList()
end

M.OnSimpleClickTabList = function(self, btn, index)
	if self.curTabIndex ~= index then
		return
	end

	self.SelectTab(self, index)
end

M.RefreshContentList = function(self)
	self.contentEntryList = {}
	self.cardTagsData = {}
	local list = self.jobBoardInfo and self.jobBoardInfo.CountryJobEntries[self.curCountryId]
	local entries = list and list.Entries

	if entries then
		for i = 1, #entries do
			self.contentEntryList[i] = entries[i]
		end
	end

	table.sort(self.contentEntryList, function (a, b)
		local ca = JobBoardConfig.GetConfig(a.BoardId)
		local cb = JobBoardConfig.GetConfig(b.BoardId)

		return (ca and ca.SortOrder or 0) <= (cb and cb.SortOrder or 0)
	end)

	for i, entry in ipairs(self.contentEntryList) do
		local cfg = JobBoardConfig.GetConfig(entry.BoardId)
		self.cardTagsData[i] = cfg and self:BuildCardTags(cfg) or {}
	end

	local hiddenCount = 0

	if self.jobBoardInfo and self.jobBoardInfo.HiddenCountPerCity then
		hiddenCount = self.jobBoardInfo.HiddenCountPerCity[self.curCountryId] or 0
	end

	if hiddenCount <= 0 then
		table.insert(self.contentEntryList, {
			["\\x8b<زX&\\xc9L\\xf8\\xe2\"RT\\xc5-\\xb8\\xce"] = true
		})
	end

	local knownCount = #self.contentEntryList - (hiddenCount <= 0 and 1 or 0)
	self.bindData.isEmpty = knownCount ~= 0 and self.isEmptyEnum._true or self.isEmptyEnum._false

	self.bindData.contentList:SetSimpleList(#self.contentEntryList)
	self:RefreshWebLayout()
end

M.BuildCardTags = function(self, cfg)
	local tags = {}
	local jobTags = cfg.JobTags

	if jobTags then
		for k = 1, #jobTags do
			local tagCfg = JobTagConfig.GetConfig(jobTags[k])

			if tagCfg then
				table.insert(tags, tagCfg.Name)
			end
		end
	end

	return tags
end

M.OnSimpleRenderContentListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local entry = self.contentEntryList[index + 1]

	if not entry then
		return
	end

	if entry.isUnknownPlaceholder then
		store.Commit(store, "typeCtrl", CARD_TYPE_CTRL.canApply, COMMIT_IMMEDIATELY)
		store.Commit(store, "contentCtrl", CARD_CONTENT_CTRL.unknown, COMMIT_IMMEDIATELY)

		if store.tagList then
			store.tagList:SetSimpleList(0)
		end

		return
	end

	local cfg = JobBoardConfig.GetConfig(entry.BoardId)

	if not cfg then
		return
	end

	local typeCtrl = nil
	typeCtrl = (not cfg.JobId or cfg.JobId ~= 0) and CARD_TYPE_CTRL.fake or STATE_TO_TYPE_CTRL[entry.State] or CARD_TYPE_CTRL.canApply

	store:Commit("typeCtrl", typeCtrl, COMMIT_IMMEDIATELY)
	store:Commit("contentCtrl", CARD_CONTENT_CTRL.normal, COMMIT_IMMEDIATELY)
	store:Commit("jobIconId", cfg.Image or 0, COMMIT_FORCE)

	store.jobName = cfg.JobTitle
	store.jobContent = cfg.JobDescription
	store.salary = tostring(cfg.Salary or 0)
	store.lockInfo = cfg.UnlockText

	if store.tagList then
		local cardIndex = index

		store.tagList.luaSimpleRenderItem = function(tagBtn, tagIndex)
			self:OnSimpleRenderCardTagListItem(tagBtn, tagIndex, cardIndex)
		end

		local tags = self.cardTagsData[index + 1]

		store.tagList:SetSimpleList(tags and #tags or 0)
	end

	if store.applyBtn then
		local applyBtn = store.applyBtn

		applyBtn.luaClick = function()
			self:RecordPlaneFrom(applyBtn)
			self:OnClickApplyBtn(entry)
		end
	end

	if store.resignBtn then
		store.resignBtn.luaClick = function()
			self:OnClickResignBtn(entry)
		end
	end
end

M.OnSimpleRenderCardTagListItem = function(self, btn, tagIndex, cardIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local tags = self.cardTagsData[cardIndex + 1]
	local tagName = tags and tags[tagIndex + 1]

	if not tagName then
		return
	end

	store.tagName = tagName
end

M.OnSimpleClickContentList = function(self, btn, index)
end

M.GetJobClassId = function(self, entry)
	if not entry then
		return 0
	end

	if entry.JobClassId and entry.JobClassId == 0 then
		return entry.JobClassId
	end

	return entry.JobId or 0
end

M.OnClickApplyBtn = function(self, entry)
	if not entry then
		return
	end

	if self.pendingActions[entry.BoardId] then
		return
	end

	local cfg = JobBoardConfig.GetConfig(entry.BoardId)
	local relatedTask = cfg and cfg.RelatedTask or 0

	if relatedTask == 0 and gTaskManager:GetTaskEventState(relatedTask) ~= UX.Game.TaskEventState.Submited then
		self.ShowConfirmModel(self, UrbanJobConfig.JobBoardReEmployConfirm, "", function ()
			self:DoTakeJob(entry)
		end)

		return
	end

	self.DoAcceptEvent(self, entry, relatedTask)
end

M.DoAcceptEvent = function(self, entry, relatedTask)
	self.pendingActions[entry.BoardId] = {
		entry = entry
	}
	local eventCfg = LTConfig.TaskEventConfig.GetConfig(relatedTask)
	local startTask = eventCfg and eventCfg.StartTask or 0

	gClientToGameDelegate:AskAcceptAndSetCurrentTask(startTask, 0, false).Callback = function (errorId)
		self.pendingActions[entry.BoardId] = nil

		if errorId == LTConfig.MessageConfig.Ok then
			self.planeFromPosition = nil

			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		if gTaskManager:GetTaskEventState(relatedTask) ~= UX.Game.TaskEventState.Accepted then
			self:ApplyOptimisticState(entry, UX.Game.JobBoardJobState.Applying)
			self:ClearOptimisticState(entry)
			self:PlayPlaneAnim()
			self:ShowTips(UrbanJobConfig.JobBoardFirstAcceptTip)
		else
			self.planeFromPosition = nil
		end
	end
end

M.DoTakeJob = function(self, entry)
	if not entry then
		return
	end

	if self.pendingActions[entry.BoardId] then
		return
	end

	local jobClassId = self:GetJobClassId(entry)

	self:ApplyOptimisticState(entry, UX.Game.JobBoardJobState.Joined)

	slot3 = gClientToGameDelegate

	slot3:AskTakeJob(jobClassId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			self:RevertOptimisticState(entry)

			self.planeFromPosition = nil

			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self:ClearOptimisticState(entry)
		self:PlayPlaneAnim()
		self:ShowTips(UrbanJobConfig.JobBoardAcceptSuccess)
	end
end

M.OnClickResignBtn = function(self, entry)
	self.ShowResignModel(self, entry)
end

M.RefreshEntryCard = function(self, entry)
	if not entry then
		return
	end

	local index = nil

	for i, e in ipairs(self.contentEntryList) do
		if e ~= entry then
			index = i - 1

			break
		end
	end

	if not index then
		return
	end

	local success, btn = self.bindData.contentList:TryGetChildAt(index, nil)

	if success and btn then
		self.OnSimpleRenderContentListItem(self, btn, index)
	end
end

M.ApplyOptimisticState = function(self, entry, newState)
	if not entry or not self.jobBoardInfo then
		return
	end

	local prevState = entry.State
	local prevJobCount = self.jobBoardInfo.JoinedJobCount
	self.pendingActions[entry.BoardId] = {
		entry = entry,
		prevState = prevState,
		newState = newState,
		prevJobCount = prevJobCount
	}
	entry.State = newState
	local wasJoined = prevState ~= UX.Game.JobBoardJobState.Joined
	local isJoined = newState ~= UX.Game.JobBoardJobState.Joined

	if not wasJoined and isJoined then
		self.jobBoardInfo.JoinedJobCount = prevJobCount + 1
	elseif wasJoined and not isJoined then
		self.jobBoardInfo.JoinedJobCount = math.max(0, prevJobCount - 1)
	end

	self.RefreshJobCount(self)
	self.RefreshEntryCard(self, entry)
end

M.RevertOptimisticState = function(self, entry)
	if not entry then
		return
	end

	local pending = self.pendingActions[entry.BoardId]

	if not pending then
		return
	end

	if pending.entry.State ~= pending.newState then
		pending.entry.State = pending.prevState

		if self.jobBoardInfo then
			self.jobBoardInfo.JoinedJobCount = pending.prevJobCount
		end

		self.RefreshJobCount(self)
		self.RefreshEntryCard(self, entry)
	end

	self.pendingActions[entry.BoardId] = nil
end

M.ClearOptimisticState = function(self, entry)
	if not entry then
		return
	end

	self.pendingActions[entry.BoardId] = nil
end

M.GetOuterScrollRect = function(self)
	if self.outerScrollRect ~= nil then
		local host = self.GetHostBindData(self)

		if host then
			self.outerScrollRect = host.webContainerRect
		end
	end

	return self.outerScrollRect
end

M.SetOuterScrollDisabled = function(self, disabled)
	local scroll = self.GetOuterScrollRect(self)

	if scroll then
		scroll.SetScrollDisabled(scroll, disabled)
	end
end

M.InitModelStore = function(self)
	if self.modelStore then
		return
	end

	local host = self.GetHostBindData(self)

	if not host or not host.webJobModel then
		return
	end

	self.modelStore = gStoreManager:GetStoreGroup(host.webJobModel.Store):GetStoreByWidget(host.webJobModel)

	if not self.modelStore then
		return
	end

	if self.modelStore.confirmBtn then
		self.modelStore.confirmBtn.luaClick = self.CreateAction(self, self.OnClickModelConfirm)
	end

	if self.modelStore.cancelBtn then
		self.modelStore.cancelBtn.luaClick = self.CreateAction(self, self.OnClickModelCancel)
	end
end

M.ShowConfirmModel = function(self, title, content, onConfirm)
	self.InitModelStore(self)

	if not self.modelStore then
		return
	end

	local host = self.GetHostBindData(self)

	if not host then
		return
	end

	self.pendingModelConfirm = onConfirm
	self.modelStore.modelTitle = title or ""
	self.modelStore.modelContent = content or ""
	host.modelCtrl = HOST_CTRL_SHOW

	self:SetOuterScrollDisabled(true)
end

M.ShowResignModel = function(self, entry)
	self.ShowConfirmModel(self, UrbanJobConfig.JobBoardResignConfirm, UrbanJobConfig.JobBoardResignTip, function ()
		self:DoResign(entry)
	end)
end

M.HideModel = function(self)
	local host = self.GetHostBindData(self)

	if host then
		host.modelCtrl = HOST_CTRL_HIDE
	end

	self.pendingModelConfirm = nil

	self.SetOuterScrollDisabled(self, false)
end

M.OnClickModelConfirm = function(self)
	local onConfirm = self.pendingModelConfirm

	self.HideModel(self)

	if onConfirm then
		onConfirm()
	end
end

M.DoResign = function(self, entry)
	if not entry then
		return
	end

	if self.pendingActions[entry.BoardId] then
		return
	end

	local jobClassId = self.GetJobClassId(self, entry)

	if jobClassId ~= 0 then
		return
	end

	self:ApplyOptimisticState(entry, UX.Game.JobBoardJobState.Available)

	slot3 = gClientToGameDelegate

	slot3:AskQuitJob(jobClassId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			self:RevertOptimisticState(entry)
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self:ClearOptimisticState(entry)
		self:ShowTips(UrbanJobConfig.JobBoardResignMessage)
	end
end

M.OnClickModelCancel = function(self)
	self.planeFromPosition = nil

	self.HideModel(self)
end
