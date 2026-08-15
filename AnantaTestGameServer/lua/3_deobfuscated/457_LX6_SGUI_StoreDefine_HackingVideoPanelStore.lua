C_HackingVideoPanelStore = DefClass("C_HackingVideoPanelStore", C_HackingVideoPanelStore, C_StoreGroup)
GroupName2Class.HackingVideoPanelStore = C_HackingVideoPanelStore
local M = C_HackingVideoPanelStore
local TempTextPrefix = "#临#"
local TransTextPrefix = "##fixed##"
local HackingKeyframeConfig = LTConfig.HackingKeyframeConfig
local MessageConfig = LTConfig.MessageConfig
local GameConfig = LTConfig.GameConfig
local PlayStatus = {
	Pause = 1,
	Playing = 0
}
local AnalysisStatus = {
	AnalysedHide = 0,
	AnalysedShow = 4,
	IsHide = 1,
	Analysing = 3,
	IsActive = 2
}
local AnalysisShow = {
	Analysing = 1,
	Ready = 0,
	ShowClue = 2
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.TaskList.luaSimpleRenderItem = self:CreateAction("OnTaskListItem")
	self.bindData.AnalysisAreaList.luaRenderItem = self:CreateAction("OnAnalysisAreaListItem")
	self.bindData.AnalysisButtonList.luaRenderItem = self:CreateAction("OnAnalysisButtonListItem")
	self.bindData.AnalysisAreaList.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.bindData.AnalysisButtonList.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.bindData.AnalysisButtonList.luaPress = self:CreateAction("OnAnalysisButtonListItemPress")
	self.bindData.AnalysisButtonList.luaRelease = self:CreateAction("OnAnalysisButtonListItemRelease")
	self.bindData.btnPlay.luaClick = self:CreateAction("OnPlayVideoClick")
	self.bindData.TimeSlider.luaPress = self:CreateAction("OnTimeSliderPress")
	self.bindData.TimeSlider.luaRelease = self:CreateAction("OnTimeSliderRelease")
	self.bindData.btnPause.luaClick = self:CreateAction("OnPauseVideoClick")
	self.bindData.btnClose.luaClick = self:CreateAction("OnClosePanelClick")
	self.bindData.btnForwardNav.luaGamePadInputChanged = self:CreateAction("OnGamePadForward")
	self.bindData.btnForwardLSNav.luaGamePadInputChanged = self:CreateAction("OnGamePadForwardLS")
	self.bindData.btnBackwardNav.luaGamePadInputChanged = self:CreateAction("OnGamePadBackward")
	self.bindData.btnAnalysisNav.luaGamePadInputChanged = self:CreateAction("OnAnalysisButton")
	self.keyFrameIdList = {}
	self.keyFrameViewList = {}
	self.TaskTagList = {}
	self.TitleStartTime = 0
	self.CurrentTitleUsedAnalysisId = 0
	self.IsHackingStart = false
	self.taskTimeCache = 0
	self.PlayStateTemp = PlayStatus.Pause
	self.currentProgress = 0
	self.currentTime = 0
	self.videoTotalTime = 10
	self.loadingTotalTime = 2.2
	self.ProgressNavValue = 0
	self.UpdateNavProgressCd = 1
	self.currentTaskList = {}
	self.pressTime = 1.1
	self.loopSoundId = 70600340
	self.EventHandler = {
		[gEventConstants.BEFORE_SWITCH_SCENE] = function (eventId, data)
			gPanelManager:Close(gPanelId.S_HACKING_VIDEO_PANEL)
		end,
		[gEventConstants.HACK_LOADING_FINISH] = function (eventId, data)
			if self.IsHackingStart == false then
				self:EnterAnalyseGame()
			end
		end
	}
end

function M:OnShow(panelId, data)
	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end

	self.bindData.IsLoading = 2
	self.bindData.IsTaskAllDone = 0

	gCS.LuaUtils.SetVehicleAndPedestrian(false)
	FrameTimer.New(function ()
		self:EnterAnalyseGameLoading()
	end, 1):Start()

	self.data = data
	self.progressLength = self.bindData.TimeSlider:GetTargetWidth()

	if data.timelineName then
		self:LoadTimelineData(data)
	else
		print_debug("非timeline骇入类型,请策划检查配表！")
	end
end

function M:OnUpdate()
	if self.bindData.IsLoading == 0 then
		self:UpdateLoadingView()
	elseif self.IsHackingStart == true then
		if self.ProgressNavValue > 0.1 or self.ProgressNavValue < -0.1 then
			self:UpdateNavProgress()
		elseif self.bindData.PlayState == PlayStatus.Playing then
			self:UpdateCurrentTime()
		else
			self:UpdateTimelineProgress()
		end

		self:UpdateTitle()
		self:UpdateActiveKeyFrame()
		self:UpdateAnalysisView()
	end
end

function M:OnClose()
	for i, v in pairs(self.EventHandler) do
		gMessageManager:RemoveMessageListener(i, v)
	end

	self:CameraRecordingFilter(false)
	gCS.LuaUtils.SetVehicleAndPedestrian(true)

	if self.data.timelineName then
		gTimelineManager:Timeline_Stop(self.data.timelineName)
	end

	gSoundMgr:StopSoundByTid(self.loopSoundId)
end

function M:LoadTimelineData()
	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	timelineData.canJump = false
	timelineData.loadWithBlackScreen = true

	function timelineData.onPlayCb()
		self.timeline = gTimelineManager:GetTimeline(self.data.timelineName)
		self.videoTotalTime = self.timeline:GetDuration() - self.loadingTotalTime

		self:LoadTimelineKeyFrame()

		self.bindData.IsLoading = 0
	end

	function timelineData.onLoadDoneCb()
		self:CameraRecordingFilter(true)
	end

	function timelineData.onFinishCb()
		gTimelineManager:Timeline_Pause(self.data.timelineName, true)
		self:ClosePanel()
	end

	self.timelineData = timelineData
end

function M:EnterAnalyseGameLoading()
	if self.data.timelineName then
		gTimelineManager:Timeline_LoadAndPlay(self.data.timelineName, self.timelineData)
	else
		print_debug("非timeline骇入类型,请策划检查配表！")
	end
end

function M:EnterAnalyseGame()
	self:PauseVideo()
	Timer.New(function ()
		self:StartPlayVideo()

		self.IsHackingStart = true
		self.bindData.IsLoading = 1
	end, 0.5):Start()
end

function M:LoadTimelineKeyFrame()
	self.timelineKeyFrames = self.timeline:GetKeyFrames()
	self.keyFrameViewList = {}
	self.keyFrameIdList = {}

	for i = 0, self.timelineKeyFrames.Count - 2 do
		for j = i + 1, self.timelineKeyFrames.Count - 1 do
			if self.timelineKeyFrames[j].start < self.timelineKeyFrames[i].start then
				local data = self.timelineKeyFrames[i]
				self.timelineKeyFrames[i] = self.timelineKeyFrames[j]
				self.timelineKeyFrames[j] = data
			end
		end
	end

	for i = 0, self.timelineKeyFrames.Count - 1 do
		local data = self.timelineKeyFrames[i]

		table.insert(self.keyFrameIdList, data.keyFrameId)

		local cfg = HackingKeyframeConfig.GetConfig(data.keyFrameId)

		if cfg then
			local keyFrameInfo = {
				AnalysisStatus = AnalysisStatus.IsHide,
				KeyFrameLengthPer = self.progressLength * (data["end"] - data.start) / self.videoTotalTime,
				KeyFrameStartProgress = (data.start - self.loadingTotalTime) / self.videoTotalTime,
				KeyFrameEndProgress = (data["end"] - self.loadingTotalTime) / self.videoTotalTime,
				ButtonStartProgress = cfg.KeyframeStarttime / self.videoTotalTime,
				ButtonEndProgress = cfg.KeyframeEndtime / self.videoTotalTime,
				KeyFrameStart = Vector3.New((data.start - self.loadingTotalTime) / self.videoTotalTime * self.progressLength, 0, 0),
				CfgId = cfg.Id,
				KeyframeClue = self:GetNormalText(cfg.KeyframeClues),
				KeyframeTitle = self:GetNormalText(cfg.KeyframeTitle),
				KeyframeDetails = self:GetNormalText(cfg.KeyframeDetails),
				TargetObj = data.bindingItem
			}
			local taskId = nil

			if cfg.SetTaskCounter and cfg.SetTaskCounter.taskId ~= 0 and gTaskManager:HasTask(cfg.SetTaskCounter.taskId) then
				taskId = cfg.SetTaskCounter.taskId
			end

			keyFrameInfo.Scene, keyFrameInfo.Time = self:SpiltKeyFrameMainTitle(self:GetNormalText(cfg.MainTitle), taskId)
			keyFrameInfo.AnalysisProgress = 0
			keyFrameInfo.effectUuid = 0
			keyFrameInfo.btnStore = nil

			table.insert(self.keyFrameViewList, keyFrameInfo)
		end
	end

	FrameTimer.New(function ()
		self:RefreshAll()
	end, 1):Start()
end

function M:SpiltKeyFrameMainTitle(title, taskId)
	local titles = string.split(title, "|")
	local scene = ""
	local datetime = 0
	local time = 0

	if title == "-" or #titles ~= 4 then
		return "", 0
	end

	if #titles == 4 then
		scene = titles[1]
		local date = string.split(titles[2], "/")
		datetime = os.time({
			hour = 0,
			year = 2000,
			second = 0,
			minute = 0,
			month = tonumber(date[1]),
			day = tonumber(date[2])
		})

		if titles[3] == "GameTime" then
			if taskId then
				gClientToGameSceneDelegate:AskGetTaskValue(taskId, "TitleTimeCache").Callback = function (err, data)
					if err ~= MessageConfig.Ok then
						gDisplayMessageMgr:ShowMessage(err)

						return
					else
						self.taskTimeCache = data
					end
				end
			end

			time = tonumber(titles[4]) * 60
		elseif titles[3] == "CertainTime" then
			local timeList = string.split(titles[4], ":")
			time = tonumber(timeList[1]) * 3600 + tonumber(timeList[2]) * 60 + tonumber(timeList[3])
		else
			time = 0
		end
	end

	return scene, time + datetime
end

function M:GetTimeTextFromSecond(duration)
	local minute = math.floor(duration / 60)
	local second = math.floor(duration % 60)

	return string.format("%02d:%02d", minute, second)
end

function M:GetNormalTimeTextFromSecond(duration)
	local timeTable = os.date("*t", duration)
	local month = timeTable.month
	local day = timeTable.day
	local hour = timeTable.hour
	local minute = timeTable.min
	local second = timeTable.sec

	return string.format("%d/%d", month, day), string.format("%02d:%02d:%02d", hour, minute, second)
end

function M:GetNormalText(str)
	if str:sub(1, #TempTextPrefix) == TempTextPrefix then
		return str:sub(#TempTextPrefix + 1)
	elseif str:sub(1, #TransTextPrefix) == TransTextPrefix then
		return str:sub(#TransTextPrefix + 1)
	else
		return str
	end
end

function M:CameraRecordingFilter(open)
	if open then
		gCS.CameraDataMgr.cameraEffectController:CameraRecordingFilter(true, GameConfig.CameraPostProcessColor, GameConfig.CameraPostProcessColorPos)
	else
		gCS.CameraDataMgr.cameraEffectController:CameraRecordingFilter(false)
	end
end

function M:StartPlayVideo()
	self.bindData.PlayState = PlayStatus.Playing

	if self.timeline then
		self.timeline:SetProgress(self.currentTime + self.loadingTotalTime)
	end

	if self.data.timelineName then
		gTimelineManager:Timeline_Pause(self.data.timelineName, false)
	end
end

function M:PauseVideo()
	self.bindData.PlayState = PlayStatus.Pause

	if self.data.timelineName then
		gTimelineManager:Timeline_Pause(self.data.timelineName, true)
	end
end

function M:AnalysisKeyFrameSuccess(index)
	if self.PlayStateTemp == PlayStatus.Playing then
		self:StartPlayVideo()
	end

	self.keyFrameViewList[index].AnalysisProgress = 0
	self.keyFrameViewList[index].AnalysisStatus = AnalysisStatus.AnalysedHide

	self:RefreshAll(index)

	local keyFrameInfo = self.keyFrameViewList[index]

	gClientToGameSceneDelegate:AskFinishHackingKeyFrame(keyFrameInfo.CfgId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end

	for k, v in pairs(self.keyFrameViewList) do
		if v.AnalysisStatus ~= AnalysisStatus.AnalysedHide and v.AnalysisStatus ~= AnalysisStatus.AnalysedShow then
			return
		end
	end

	self:TaskSuccess()
end

function M:TaskSuccess()
	self.bindData.IsTaskAllDone = 1
end

function M:ClosePanel()
	gSoundMgr:StopSoundByTid(self.loopSoundId)
	gPanelManager:Close(gPanelId.S_HACKING_VIDEO_PANEL)
end

function M:TimelineGoTo(currentTime)
	self.currentProgress = Mathf.Clamp(currentTime / self.videoTotalTime, 0, 0.99)
	self.currentTime = self.currentProgress * self.videoTotalTime

	self.timeline:SetProgress(self.currentTime + self.loadingTotalTime)
	self:UpdateTimeText()
	self:UpdateTimeArrowPosition(self.currentProgress)
end

function M:ChangeAnalysisButtonShow(index, show)
	if self.keyFrameViewList[index].btnStore.IsAnalysing == AnalysisShow.ShowClue then
		return
	end

	self.keyFrameViewList[index].btnStore.IsAnalysing = show
end

function M:UpdateCurrentTime()
	if self.data.timelineName then
		self.currentTime = Mathf.Max(self.timeline:GetTime() - self.loadingTotalTime, 0)
		self.currentProgress = self.currentTime / self.videoTotalTime

		self:UpdateTimeText()
		self:UpdateTimeArrowPosition(self.currentProgress)

		if self.currentProgress >= 0.99 then
			self:PauseVideo()
		end
	end
end

function M:UpdateLoadingView()
	local loadingProgress = 0

	if self.timeline then
		loadingProgress = Mathf.Min(self.timeline:GetTime() / self.loadingTotalTime, 1)
	end

	self.bindData.LoadingProgress = loadingProgress
	self.bindData.LoadingProgressText = string.format("%d%%", loadingProgress * 100)
end

function M:UpdateTimelineProgress()
	if self.timeline then
		self.currentProgress = Mathf.Min(self.bindData.TimeSlider.value, 0.99)
		self.currentTime = self.currentProgress * self.videoTotalTime

		self.timeline:SetProgress(self.currentTime + self.loadingTotalTime)
		self:UpdateTimeText()
	end
end

function M:UpdateTimeArrowPosition(progress)
	self.bindData.TimeSlider.value = progress
end

function M:UpdateTimeText()
	self.bindData.CurrentTimeText = self:GetTimeTextFromSecond(self.currentTime)
	self.bindData.TitleDate, self.bindData.TitleTime = self:GetNormalTimeTextFromSecond(self.currentTime + self.TitleStartTime + self.taskTimeCache)
end

function M:UpdateTitle()
	local keyFrameInfo = nil

	for i = #self.keyFrameViewList, 1, -1 do
		keyFrameInfo = self.keyFrameViewList[i]
		local scene = keyFrameInfo.Scene
		local time = keyFrameInfo.Time

		if keyFrameInfo.KeyFrameStartProgress <= self.currentProgress and scene ~= "" and self.CurrentTitleUsedAnalysisId ~= i then
			self.bindData.TitleScene = scene
			self.TitleStartTime = time
			self.CurrentTitleUsedAnalysisId = i

			return
		end
	end

	self.bindData.TitleScene = self.keyFrameViewList[1].Scene
	self.TitleStartTime = self.keyFrameViewList[1].Time
	self.CurrentTitleUsedAnalysisId = 1
end

function M:UpdateActiveKeyFrame()
	if not self.keyFrameViewList then
		return
	end

	for k, v in pairs(self.keyFrameViewList) do
		if self.currentProgress < v.ButtonEndProgress and v.ButtonStartProgress <= self.currentProgress then
			if v.AnalysisStatus == AnalysisStatus.IsHide then
				v.AnalysisStatus = AnalysisStatus.IsActive

				self:RefreshAnalysisKeyView()
			elseif v.AnalysisStatus == AnalysisStatus.AnalysedHide then
				v.AnalysisStatus = AnalysisStatus.AnalysedShow

				self:RefreshAnalysisKeyView()
			end
		elseif v.AnalysisStatus == AnalysisStatus.IsActive then
			v.AnalysisStatus = AnalysisStatus.IsHide

			self:RefreshAnalysisKeyView()
		elseif v.AnalysisStatus == AnalysisStatus.AnalysedShow then
			v.AnalysisStatus = AnalysisStatus.AnalysedHide

			self:RefreshAnalysisKeyView()
		end
	end
end

function M:UpdateAnalysisView()
	for k, v in pairs(self.keyFrameViewList) do
		if v.AnalysisStatus == AnalysisStatus.Analysing then
			v.AnalysisProgress = v.AnalysisProgress + gLogicTime.deltaTime / self.pressTime
			local realProgress = Mathf.Max(v.AnalysisProgress - 0.3, 0)
			v.btnStore.AnalysisProgress = realProgress
			v.btnStore.AnalysisProgressText = string.format("%d%%", realProgress * 100)

			if v.btnStore.AnalysisProgress >= 1 then
				self:AnalysisKeyFrameSuccess(k)
			end
		end
	end
end

function M:UpdateNavProgress()
	if self.ProgressNavValue < -0.1 or self.ProgressNavValue > 0.1 then
		self.UpdateNavProgressCd = self.UpdateNavProgressCd + gLogicTime.deltaTime

		if self.UpdateNavProgressCd > 0.05 then
			self.UpdateNavProgressCd = 0

			self:TimelineGoTo(self.currentTime + self.ProgressNavValue)
		end
	end
end

function M:RefreshAll(index)
	index = index or -1

	self:RefreshTaskList()
	self:RefreshAnalysisKeyView()
end

function M:RefreshTaskList()
	self.currentTaskList = {}

	for k, v in pairs(self.keyFrameViewList) do
		local taskInfo = {
			KeyframeClue = v.KeyframeClue
		}

		if v.AnalysisStatus == AnalysisStatus.AnalysedHide or v.AnalysisStatus == AnalysisStatus.AnalysedShow then
			taskInfo.IsTaskDone = 1
		else
			taskInfo.IsTaskDone = 0
		end

		table.insert(self.currentTaskList, taskInfo)
	end

	self.bindData.TaskList:SetSimpleList(#self.currentTaskList)
end

function M:RefreshAnalysisKeyView()
	self:RefreshEffect()
	self.bindData.AnalysisButtonList:SetList(#self.keyFrameViewList)
	self.bindData.AnalysisAreaList:SetList(#self.keyFrameViewList)
end

function M:RefreshEffect()
	for k, v in pairs(self.keyFrameViewList) do
		local go = v.TargetObj
		local idKey = "fx_ScanObj_cube_saomiao_hune_02" .. go:GetInstanceID()

		if v.AnalysisStatus == AnalysisStatus.IsActive or v.AnalysisStatus == AnalysisStatus.Analysing or v.AnalysisStatus == AnalysisStatus.AnalysedShow then
			if v.effectUuid == 0 then
				v.effectUuid = gCS.EffectMgr:PlayGameObjectMaterialEffect(538000540, idKey, go)
			end
		elseif v.effectUuid ~= 0 then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(v.effectUuid)

			v.effectUuid = 0
		end
	end
end

function M:OnTaskListItem(btn, index)
	local data = self.currentTaskList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		store.TaskTagText = data.KeyframeClue
		store.TaskTagDone = data.IsTaskDone
	end
end

function M:OnAnalysisAreaListItem(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local keyFrame = self.keyFrameViewList[index + 1]
	local areaStartPosX = (keyFrame.KeyFrameStartProgress - 0.5) * self.progressLength
	btn.rectTransform.sizeDelta = Vector2.New(keyFrame.KeyFrameLengthPer, btn.rectTransform.sizeDelta.y)

	btn.rectTransform:SetLocalPositionX(areaStartPosX)

	if keyFrame.AnalysisStatus == AnalysisStatus.AnalysedHide or keyFrame.AnalysisStatus == AnalysisStatus.AnalysedShow then
		store.AnalysisAreaDone = 0
	else
		store.AnalysisAreaDone = 1
	end
end

function M:OnGetTIndex(index)
	return 0
end

function M:OnAnalysisButtonListItem(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	self.keyFrameViewList[index + 1].btnStore = store
	store.AnalysisTaskTitle = self.keyFrameViewList[index + 1].KeyframeTitle
	store.AnalysisTaskComment = self.keyFrameViewList[index + 1].KeyframeDetails
	local keyFrame = self.keyFrameViewList[index + 1]
	local target = keyFrame.TargetObj

	if not target or gCS.LuaUtils.IsNull(target) then
		return
	end

	local isNPC, posW = gTimelineManager:Timeline_GetActorPosition(self.data.timelineName, target.name)
	local offsetX = 0
	local offsetY = 0

	if not isNPC then
		posW = target.transform.position
	else
		local modelSlot = target:GetComponent(typeof(LX6.Share.ModelSlot))

		if modelSlot then
			posW = modelSlot.upbodySlot.position
		end
	end

	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(posW, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.ScreenPointUI(btn.transform.parent, Vector2.New(x, y))

	btn.transform:SetLocalPositionXY(UIPos.x + offsetX, UIPos.y + offsetY)

	local IsActive = nil
	IsActive = keyFrame.AnalysisStatus ~= AnalysisStatus.IsHide and keyFrame.AnalysisStatus ~= AnalysisStatus.AnalysedHide

	btn:SetActive(IsActive)

	if keyFrame.AnalysisStatus == AnalysisStatus.AnalysedHide or keyFrame.AnalysisStatus == AnalysisStatus.AnalysedShow then
		store.IsAnalysing = AnalysisShow.ShowClue
	end
end

function M:OnAnalysisButtonListItemPress(btn, index)
	if self.keyFrameViewList[index + 1].AnalysisStatus == AnalysisStatus.IsActive then
		self.PlayStateTemp = self.bindData.PlayState

		self:PauseVideo()
		self:ChangeAnalysisButtonShow(index + 1, AnalysisShow.Analysing)

		self.keyFrameViewList[index + 1].AnalysisStatus = AnalysisStatus.Analysing
	end
end

function M:OnAnalysisButtonListItemRelease(btn, index)
	if self.keyFrameViewList[index + 1].AnalysisStatus == AnalysisStatus.Analysing then
		self:ChangeAnalysisButtonShow(index + 1, AnalysisShow.Ready)

		self.keyFrameViewList[index + 1].AnalysisProgress = 0
		self.keyFrameViewList[index + 1].AnalysisStatus = AnalysisStatus.IsActive

		if self.PlayStateTemp == PlayStatus.Playing then
			self:StartPlayVideo()
		end
	end
end

function M:OnAnalysisButton(context)
	if context.started then
		for k, v in pairs(self.keyFrameViewList) do
			if v.AnalysisStatus == AnalysisStatus.IsActive then
				self.keyFrameViewList[k].AnalysisStatus = AnalysisStatus.Analysing

				self:ChangeAnalysisButtonShow(k, AnalysisShow.Analysing)

				self.PlayStateTemp = self.bindData.PlayState

				self:PauseVideo()
			end
		end

		return
	end

	if context.canceled then
		for k, v in pairs(self.keyFrameViewList) do
			if v.AnalysisStatus == AnalysisStatus.Analysing then
				self.keyFrameViewList[k].AnalysisStatus = AnalysisStatus.IsActive
				self.keyFrameViewList[k].AnalysisProgress = 0

				self:ChangeAnalysisButtonShow(k, AnalysisShow.Ready)

				if self.PlayStateTemp == PlayStatus.Playing then
					self:StartPlayVideo()
				end
			end
		end

		return
	end
end

function M:NavPauseAndPlay(context)
	if context.started then
		self.PlayStateTemp = self.bindData.PlayState

		self:PauseVideo()

		self.UpdateNavProgressCd = 1
	end

	if context.canceled then
		if self.PlayStateTemp == PlayStatus.Playing then
			self:StartPlayVideo()
		end

		self.UpdateNavProgressCd = 1
	end
end

function M:OnGamePadForward(context)
	self:NavPauseAndPlay(context)

	self.ProgressNavValue = context:ReadValueFloat()
end

function M:OnGamePadForwardLS(context)
	self:NavPauseAndPlay(context)

	self.ProgressNavValue = context:ReadValueVector2().x
end

function M:OnGamePadBackward(context)
	self:NavPauseAndPlay(context)

	self.ProgressNavValue = context:ReadValueFloat() * -1
end

function M:OnPlayVideoClick()
	self.bindData.PlayState = PlayStatus.Playing

	self:StartPlayVideo()
end

function M:OnPauseVideoClick()
	self.bindData.PlayState = PlayStatus.Pause

	self:PauseVideo()
end

function M:OnTimeSliderPress()
	self.PlayStateTemp = self.bindData.PlayState

	self:PauseVideo()
	gSoundMgr:PlaySoundByTid(self.loopSoundId, nil, function (uuid)
		self.loopSoundData = gSoundMgr:GetSoundData(uuid)
	end)
end

function M:OnTimeSliderRelease()
	if self.PlayStateTemp == PlayStatus.Playing then
		self:StartPlayVideo()
	end

	gSoundMgr:StopSoundByTid(self.loopSoundId)
end

function M:OnClosePanelClick()
	self:ClosePanel()
end
