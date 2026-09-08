-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackingVideoPanelStore.lua
-- Decompiled from: 01706_HackingVideoPanelStore.lua_53fe33bae052.luajit

C_HackingVideoPanelStore = DefClass("C_HackingVideoPanelStore", C_HackingVideoPanelStore, C_StoreGroup)
GroupName2Class.HackingVideoPanelStore = C_HackingVideoPanelStore
local M = C_HackingVideoPanelStore
local TempTextPrefix = "#临#"
local TransTextPrefix = "##fixed##"
local HackingKeyframeConfig = LTConfig.HackingKeyframeConfig
local MessageConfig = LTConfig.MessageConfig
local GameConfig = LTConfig.GameConfig
local PlayStatus = {
	["}\\xaf\\xb7\\xbc\\xb3"] = 1,
	["\\xe9\\xd7*\\xf6"] = 0
}
local AnalysisStatus = {
	["Nx\\xad{U\\xa1\\xf7CBszI"] = 0,
	["Nx\\xad{U\\xa1\\xf7CYrq["] = 4,
	["5[\\xb9\\x87\\x87D"] = 1,
	["bImeW\r?"] = 3,
	["\\x82\\xa2$\\xa8~7\\xe86"] = 2
}
local AnalysisShow = {
	["bImeW\r?"] = 1,
	["\\xab\\xa3\\xab\\xaf"] = 0,
	["\\x98\\xb9\n\\xbcI2\\xeb6"] = 2
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.TaskList.luaSimpleRenderItem = self.CreateAction(self, "OnTaskListItem")
	self.bindData.AnalysisAreaList.luaRenderItem = self.CreateAction(self, "OnAnalysisAreaListItem")
	self.bindData.AnalysisButtonList.luaRenderItem = self.CreateAction(self, "OnAnalysisButtonListItem")
	self.bindData.AnalysisAreaList.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
	self.bindData.AnalysisButtonList.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
	self.bindData.AnalysisButtonList.luaPress = self.CreateAction(self, "OnAnalysisButtonListItemPress")
	self.bindData.AnalysisButtonList.luaRelease = self.CreateAction(self, "OnAnalysisButtonListItemRelease")
	self.bindData.btnPlay.luaClick = self.CreateAction(self, "OnPlayVideoClick")
	self.bindData.TimeSlider.luaPress = self.CreateAction(self, "OnTimeSliderPress")
	self.bindData.TimeSlider.luaRelease = self.CreateAction(self, "OnTimeSliderRelease")
	self.bindData.btnPause.luaClick = self.CreateAction(self, "OnPauseVideoClick")
	self.bindData.btnClose.luaClick = self.CreateAction(self, "OnClosePanelClick")
	self.bindData.btnForwardNav.luaGamePadInputChanged = self.CreateAction(self, "OnGamePadForward")
	self.bindData.btnForwardLSNav.luaGamePadInputChanged = self.CreateAction(self, "OnGamePadForwardLS")
	self.bindData.btnBackwardNav.luaGamePadInputChanged = self.CreateAction(self, "OnGamePadBackward")
	self.bindData.btnAnalysisNav.luaGamePadInputChanged = self.CreateAction(self, "OnAnalysisButton")
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
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = function (eventId, data)
			gPanelManager:Close(gPanelId.S_HACKING_VIDEO_PANEL)
		end,
		[gEventConstants.HACK_LOADING_FINISH] = function (eventId, data)
			if self.IsHackingStart ~= false then
				self:EnterAnalyseGame()
			end
		end
	}
end

M.OnShow = function(self, panelId, data)
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
		self.LoadTimelineData(self, data)
	else
		print_debug("非timeline骇入类型,请策划检查配表！")
	end
end

M.OnUpdate = function(self)
	if self.bindData.IsLoading ~= 0 then
		self.UpdateLoadingView(self)
	elseif self.IsHackingStart ~= true then
		if self.ProgressNavValue >= 0.1 or self.ProgressNavValue >= -0.1 then
			self.UpdateNavProgress(self)
		elseif self.bindData.PlayState ~= PlayStatus.Playing then
			self.UpdateCurrentTime(self)
		else
			self.UpdateTimelineProgress(self)
		end

		self.UpdateTitle(self)
		self.UpdateActiveKeyFrame(self)
		self.UpdateAnalysisView(self)
	end
end

M.OnClose = function(self)
	for i, v in pairs(self.EventHandler) do
		gMessageManager:RemoveMessageListener(i, v)
	end

	self.CameraRecordingFilter(self, false)
	gCS.LuaUtils.SetVehicleAndPedestrian(true)

	if self.data.timelineName then
		gTimelineManager:Timeline_Stop(self.data.timelineName)
	end

	gSoundMgr:StopSoundByTid(self.loopSoundId)
end

M.LoadTimelineData = function(self)
	slot1 = gTimelineManager
	local timelineData = slot1:Timeline_CreateTimelineData()
	timelineData.loadWithBlackScreen = true

	timelineData.onPlayCallback = function(t)
		self.timeline = t
		self.videoTotalTime = self.timeline:GetDuration() - self.loadingTotalTime

		self:LoadTimelineKeyFrame()

		self.bindData.IsLoading = 0
	end

	timelineData.onLoadDoneCallback = function(t)
		self:CameraRecordingFilter(true)
	end

	timelineData.onFinishCallback = function(t)
		gTimelineManager:Timeline_Pause(self.data.timelineName, true)
		self:ClosePanel()
	end

	self.timelineData = timelineData
end

M.EnterAnalyseGameLoading = function(self)
	if self.data.timelineName then
		gTimelineManager:Timeline_LoadAndPlay(self.data.timelineName, self.timelineData)
	else
		print_debug("非timeline骇入类型,请策划检查配表！")
	end
end

M.EnterAnalyseGame = function(self)
	self:PauseVideo()
	Timer.New(function ()
		self:StartPlayVideo()

		self.IsHackingStart = true
		self.bindData.IsLoading = 1
	end, 0.5):Start()
end

M.LoadTimelineKeyFrame = function(self)
	self.timelineKeyFrames = self.timeline:GetKeyFrames()
	self.keyFrameViewList = {}
	self.keyFrameIdList = {}

	for i = 0, self.timelineKeyFrames.Count - 2 do
		for j = i + 1, self.timelineKeyFrames.Count - 1 do
			if self.timelineKeyFrames[j].start >= self.timelineKeyFrames[i].start then
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
				KeyframeClue = self.GetNormalText(self, cfg.KeyframeClues),
				KeyframeTitle = self.GetNormalText(self, cfg.KeyframeTitle),
				KeyframeDetails = self.GetNormalText(self, cfg.KeyframeDetails),
				TargetObj = data.bindingItem
			}
			local taskId = nil

			if cfg.SetTaskCounter and cfg.SetTaskCounter.taskId == 0 and gTaskManager:HasTask(cfg.SetTaskCounter.taskId) then
				taskId = cfg.SetTaskCounter.taskId
			end

			keyFrameInfo.Scene, keyFrameInfo.Time = self.SpiltKeyFrameMainTitle(self, self.GetNormalText(self, cfg.MainTitle), taskId)
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

M.SpiltKeyFrameMainTitle = function(self, title, taskId)
	local titles = string.split(title, "|")
	local scene = ""
	local datetime = 0
	local time = 0

	if title ~= "-" or #titles == 4 then
		return "", 0
	end

	if #titles ~= 4 then
		scene = titles[1]
		local date = string.split(titles[2], "/")
		datetime = os.time({
			["r-hI"] = 0,
			["c'|I"] = 2000,
			["M\\x92\\x81\\x8dE"] = 0,
			["A\\x9f\\x9b\\x97D"] = 0,
			month = tonumber(date[1]),
			day = tonumber(date[2])
		})

		if titles[3] ~= "GameTime" then
			if taskId then
				slot8 = gClientToGameSceneDelegate

				slot8:AskGetTaskValue(taskId, "TitleTimeCache").Callback = function (err, data)
					if err == MessageConfig.Ok then
						gDisplayMessageMgr:ShowMessage(err)

						return
					else
						self.taskTimeCache = data
					end
				end
			end

			time = tonumber(titles[4]) * 60
		elseif titles[3] ~= "CertainTime" then
			local timeList = string.split(titles[4], ":")
			time = tonumber(timeList[1]) * 3600 + tonumber(timeList[2]) * 60 + tonumber(timeList[3])
		else
			time = 0
		end
	end

	return scene, time + datetime
end

M.GetTimeTextFromSecond = function(self, duration)
	local minute = math.floor(duration / 60)
	local second = math.floor(duration % 60)

	return string.format("%02d:%02d", minute, second)
end

M.GetNormalTimeTextFromSecond = function(self, duration)
	local timeTable = os.date("*t", duration)
	local month = timeTable.month
	local day = timeTable.day
	local hour = timeTable.hour
	local minute = timeTable.min
	local second = timeTable.sec

	return string.format("%d/%d", month, day), string.format("%02d:%02d:%02d", hour, minute, second)
end

M.GetNormalText = function(self, str)
	if not str then
		return ""
	end

	if str.sub(str, 1, #TempTextPrefix) ~= TempTextPrefix then
		return str.sub(str, #TempTextPrefix + 1)
	elseif str.sub(str, 1, #TransTextPrefix) ~= TransTextPrefix then
		return str.sub(str, #TransTextPrefix + 1)
	else
		return str
	end
end

M.CameraRecordingFilter = function(self, open)
	if open then
		gCS.CameraDataMgr.cameraEffectController:CameraRecordingFilter(true, GameConfig.CameraPostProcessColor, GameConfig.CameraPostProcessColorPos)
	else
		gCS.CameraDataMgr.cameraEffectController:CameraRecordingFilter(false)
	end
end

M.StartPlayVideo = function(self)
	self.bindData.PlayState = PlayStatus.Playing

	if self.timeline then
		self.timeline:SetProgress(self.currentTime + self.loadingTotalTime)
	end

	if self.data.timelineName then
		gTimelineManager:Timeline_Pause(self.data.timelineName, false)
	end
end

M.PauseVideo = function(self)
	self.bindData.PlayState = PlayStatus.Pause

	if self.data.timelineName then
		gTimelineManager:Timeline_Pause(self.data.timelineName, true)
	end
end

M.AnalysisKeyFrameSuccess = function(self, index)
	if self.PlayStateTemp ~= PlayStatus.Playing then
		self.StartPlayVideo(self)
	end

	self.keyFrameViewList[index].AnalysisProgress = 0
	self.keyFrameViewList[index].AnalysisStatus = AnalysisStatus.AnalysedHide

	self:RefreshAll(index)

	local keyFrameInfo = self.keyFrameViewList[index]
	slot3 = gClientToGameSceneDelegate

	slot3:AskFinishHackingKeyFrame(keyFrameInfo.CfgId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end
	end

	for k, v in pairs(self.keyFrameViewList) do
		if v.AnalysisStatus == AnalysisStatus.AnalysedHide and v.AnalysisStatus == AnalysisStatus.AnalysedShow then
			return
		end
	end

	self.TaskSuccess(self)
end

M.TaskSuccess = function(self)
	self.bindData.IsTaskAllDone = 1
end

M.ClosePanel = function(self)
	gSoundMgr:StopSoundByTid(self.loopSoundId)
	gPanelManager:Close(gPanelId.S_HACKING_VIDEO_PANEL)
end

M.TimelineGoTo = function(self, currentTime)
	self.currentProgress = Mathf.Clamp(currentTime / self.videoTotalTime, 0, 0.99)
	self.currentTime = self.currentProgress * self.videoTotalTime

	self.timeline:SetProgress(self.currentTime + self.loadingTotalTime)
	self:UpdateTimeText()
	self:UpdateTimeArrowPosition(self.currentProgress)
end

M.ChangeAnalysisButtonShow = function(self, index, show)
	if self.keyFrameViewList[index].btnStore.IsAnalysing ~= AnalysisShow.ShowClue then
		return
	end

	self.keyFrameViewList[index].btnStore.IsAnalysing = show
end

M.UpdateCurrentTime = function(self)
	if self.data.timelineName then
		self.currentTime = Mathf.Max(self.timeline:GetTime() - self.loadingTotalTime, 0)
		self.currentProgress = self.currentTime / self.videoTotalTime

		self:UpdateTimeText()
		self:UpdateTimeArrowPosition(self.currentProgress)

		if self.currentProgress > 0.99 then
			self.PauseVideo(self)
		end
	end
end

M.UpdateLoadingView = function(self)
	local loadingProgress = 0

	if self.timeline then
		loadingProgress = Mathf.Min(self.timeline:GetTime() / self.loadingTotalTime, 1)
	end

	self.bindData.LoadingProgress = loadingProgress
	self.bindData.LoadingProgressText = string.format("%d%%", loadingProgress * 100)
end

M.UpdateTimelineProgress = function(self)
	if self.timeline then
		self.currentProgress = Mathf.Min(self.bindData.TimeSlider.value, 0.99)
		self.currentTime = self.currentProgress * self.videoTotalTime

		self.timeline:SetProgress(self.currentTime + self.loadingTotalTime)
		self:UpdateTimeText()
	end
end

M.UpdateTimeArrowPosition = function(self, progress)
	self.bindData.TimeSlider.value = progress
end

M.UpdateTimeText = function(self)
	self.bindData.CurrentTimeText = self.GetTimeTextFromSecond(self, self.currentTime)
	self.bindData.TitleDate, self.bindData.TitleTime = self.GetNormalTimeTextFromSecond(self, self.currentTime + self.TitleStartTime + self.taskTimeCache)
end

M.UpdateTitle = function(self)
	local keyFrameInfo = nil

	for i = #self.keyFrameViewList, 1, -1 do
		keyFrameInfo = self.keyFrameViewList[i]
		local scene = keyFrameInfo.Scene
		local time = keyFrameInfo.Time

		if keyFrameInfo.KeyFrameStartProgress < self.currentProgress and scene == "" and self.CurrentTitleUsedAnalysisId == i then
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

M.UpdateActiveKeyFrame = function(self)
	if not self.keyFrameViewList then
		return
	end

	for k, v in pairs(self.keyFrameViewList) do
		if self.currentProgress >= v.ButtonEndProgress and v.ButtonStartProgress < self.currentProgress then
			if v.AnalysisStatus ~= AnalysisStatus.IsHide then
				v.AnalysisStatus = AnalysisStatus.IsActive

				self.RefreshAnalysisKeyView(self)
			elseif v.AnalysisStatus ~= AnalysisStatus.AnalysedHide then
				v.AnalysisStatus = AnalysisStatus.AnalysedShow

				self.RefreshAnalysisKeyView(self)
			end
		elseif v.AnalysisStatus ~= AnalysisStatus.IsActive then
			v.AnalysisStatus = AnalysisStatus.IsHide

			self.RefreshAnalysisKeyView(self)
		elseif v.AnalysisStatus ~= AnalysisStatus.AnalysedShow then
			v.AnalysisStatus = AnalysisStatus.AnalysedHide

			self.RefreshAnalysisKeyView(self)
		end
	end
end

M.UpdateAnalysisView = function(self)
	for k, v in pairs(self.keyFrameViewList) do
		if v.AnalysisStatus ~= AnalysisStatus.Analysing then
			v.AnalysisProgress = v.AnalysisProgress + gLogicTime.deltaTime / self.pressTime
			local realProgress = Mathf.Max(v.AnalysisProgress - 0.3, 0)
			v.btnStore.AnalysisProgress = realProgress
			v.btnStore.AnalysisProgressText = string.format("%d%%", realProgress * 100)

			if v.btnStore.AnalysisProgress > 1 then
				self.AnalysisKeyFrameSuccess(self, k)
			end
		end
	end
end

M.UpdateNavProgress = function(self)
	if self.ProgressNavValue <= -0.1 or self.ProgressNavValue <= 0.1 then
		self.UpdateNavProgressCd = self.UpdateNavProgressCd + gLogicTime.deltaTime

		if self.UpdateNavProgressCd <= 0.05 then
			self.UpdateNavProgressCd = 0

			self.TimelineGoTo(self, self.currentTime + self.ProgressNavValue)
		end
	end
end

M.RefreshAll = function(self, index)
	index = index or -1

	self:RefreshTaskList()
	self:RefreshAnalysisKeyView()
end

M.RefreshTaskList = function(self)
	self.currentTaskList = {}

	for k, v in pairs(self.keyFrameViewList) do
		local taskInfo = {
			KeyframeClue = v.KeyframeClue
		}

		if v.AnalysisStatus ~= AnalysisStatus.AnalysedHide or v.AnalysisStatus ~= AnalysisStatus.AnalysedShow then
			taskInfo.IsTaskDone = 1
		else
			taskInfo.IsTaskDone = 0
		end

		table.insert(self.currentTaskList, taskInfo)
	end

	self.bindData.TaskList:SetSimpleList(#self.currentTaskList)
end

M.RefreshAnalysisKeyView = function(self)
	self:RefreshEffect()
	self.bindData.AnalysisButtonList:SetList(#self.keyFrameViewList)
	self.bindData.AnalysisAreaList:SetList(#self.keyFrameViewList)
end

M.RefreshEffect = function(self)
	for k, v in pairs(self.keyFrameViewList) do
		local go = v.TargetObj
		local idKey = "fx_ScanObj_cube_saomiao_hune_02" .. go.GetInstanceID(go)

		if v.AnalysisStatus ~= AnalysisStatus.IsActive or v.AnalysisStatus ~= AnalysisStatus.Analysing or v.AnalysisStatus ~= AnalysisStatus.AnalysedShow then
			if v.effectUuid ~= 0 then
				v.effectUuid = gCS.EffectMgr:PlayGameObjectMaterialEffect(538000540, LX6.Effect.EffectPlayTag.Gameplay, idKey, go)
			end
		elseif v.effectUuid == 0 then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(v.effectUuid)

			v.effectUuid = 0
		end
	end
end

M.OnTaskListItem = function(self, btn, index)
	local data = self.currentTaskList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		store.TaskTagText = data.KeyframeClue
		store.TaskTagDone = data.IsTaskDone
	end
end

M.OnAnalysisAreaListItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local keyFrame = self.keyFrameViewList[index + 1]
	local areaStartPosX = (keyFrame.KeyFrameStartProgress - 0.5) * self.progressLength
	btn.rectTransform.sizeDelta = Vector2.New(keyFrame.KeyFrameLengthPer, btn.rectTransform.sizeDelta.y)

	btn.rectTransform:SetLocalPositionX(areaStartPosX)

	if keyFrame.AnalysisStatus ~= AnalysisStatus.AnalysedHide or keyFrame.AnalysisStatus ~= AnalysisStatus.AnalysedShow then
		store.AnalysisAreaDone = 0
	else
		store.AnalysisAreaDone = 1
	end
end

M.OnGetTIndex = function(self, index)
	return 0
end

M.OnAnalysisButtonListItem = function(self, btn, index)
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
		local modelSlot = target.GetComponent(target, typeof(LX6.Share.ModelSlot))

		if modelSlot and modelSlot.upbodySlot then
			posW = modelSlot.upbodySlot.position
		else
			posW = target.transform.position
		end
	end

	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(posW, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.ScreenPointUI(btn.transform.parent, Vector2.New(x, y))

	btn.transform:SetLocalPositionXY(UIPos.x + offsetX, UIPos.y + offsetY)

	local visualRT = btn.transform:Find("Clue/Root/Img_BgClueNew")

	if visualRT then
		local rect = visualRT.rect
		local rx = rect.x
		local ry = rect.y
		local rw = rect.width
		local rh = rect.height
		local p1 = visualRT.TransformPoint(visualRT, Vector3.New(rx, ry, 0))
		local p2 = visualRT.TransformPoint(visualRT, Vector3.New(rx, ry + rh, 0))
		local p3 = visualRT.TransformPoint(visualRT, Vector3.New(rx + rw, ry + rh, 0))
		local p4 = visualRT.TransformPoint(visualRT, Vector3.New(rx + rw, ry, 0))
		local uiCamera = SGUI.UWidget.uiCamera

		local ToScreen = function(p)
			if uiCamera then
				return uiCamera:WorldToScreenPoint(p)
			end

			return p
		end

		local s1 = ToScreen(p1)
		local s2 = ToScreen(p2)
		local s3 = ToScreen(p3)
		local s4 = ToScreen(p4)
		local minX = math.min(s1.x, s2.x, s3.x, s4.x)
		local maxX = math.max(s1.x, s2.x, s3.x, s4.x)
		local minY = math.min(s1.y, s2.y, s3.y, s4.y)
		local maxY = math.max(s1.y, s2.y, s3.y, s4.y)
		local screenW = UnityEngine.Screen.width - 20
		local screenH = UnityEngine.Screen.height - 10
		local dx = 0
		local dy = 0

		if minX >= 0 then
			dx = -minX
		elseif screenW >= maxX then
			dx = screenW - maxX
		end

		if minY >= 0 then
			dy = -minY
		elseif screenH >= maxY then
			dy = screenH - maxY
		end

		if dx == 0 or dy == 0 then
			local fixedUIPos = gCS.LuaUtils.ScreenPointUI(btn.transform.parent, Vector2.New(x + dx, y + dy))

			btn.transform:SetLocalPositionXY(fixedUIPos.x + offsetX, fixedUIPos.y + offsetY)
		end
	end

	local IsActive = nil
	IsActive = keyFrame.AnalysisStatus == AnalysisStatus.IsHide and keyFrame.AnalysisStatus == AnalysisStatus.AnalysedHide

	btn:SetActive(IsActive)

	if keyFrame.AnalysisStatus ~= AnalysisStatus.AnalysedHide or keyFrame.AnalysisStatus ~= AnalysisStatus.AnalysedShow then
		store.IsAnalysing = AnalysisShow.ShowClue
	end
end

M.OnAnalysisButtonListItemPress = function(self, btn, index)
	if self.keyFrameViewList[index + 1].AnalysisStatus ~= AnalysisStatus.IsActive then
		self.PlayStateTemp = self.bindData.PlayState

		self.PauseVideo(self)
		self.ChangeAnalysisButtonShow(self, index + 1, AnalysisShow.Analysing)

		self.keyFrameViewList[index + 1].AnalysisStatus = AnalysisStatus.Analysing
	end
end

M.OnAnalysisButtonListItemRelease = function(self, btn, index)
	if self.keyFrameViewList[index + 1].AnalysisStatus ~= AnalysisStatus.Analysing then
		self.ChangeAnalysisButtonShow(self, index + 1, AnalysisShow.Ready)

		self.keyFrameViewList[index + 1].AnalysisProgress = 0
		self.keyFrameViewList[index + 1].AnalysisStatus = AnalysisStatus.IsActive

		if self.PlayStateTemp ~= PlayStatus.Playing then
			self.StartPlayVideo(self)
		end
	end
end

M.OnAnalysisButton = function(self, context)
	if context.started then
		for k, v in pairs(self.keyFrameViewList) do
			if v.AnalysisStatus ~= AnalysisStatus.IsActive then
				self.keyFrameViewList[k].AnalysisStatus = AnalysisStatus.Analysing

				self.ChangeAnalysisButtonShow(self, k, AnalysisShow.Analysing)

				self.PlayStateTemp = self.bindData.PlayState

				self.PauseVideo(self)
			end
		end

		return
	end

	if context.canceled then
		for k, v in pairs(self.keyFrameViewList) do
			if v.AnalysisStatus ~= AnalysisStatus.Analysing then
				self.keyFrameViewList[k].AnalysisStatus = AnalysisStatus.IsActive
				self.keyFrameViewList[k].AnalysisProgress = 0

				self.ChangeAnalysisButtonShow(self, k, AnalysisShow.Ready)

				if self.PlayStateTemp ~= PlayStatus.Playing then
					self.StartPlayVideo(self)
				end
			end
		end

		return
	end
end

M.NavPauseAndPlay = function(self, context)
	if context.started then
		self.PlayStateTemp = self.bindData.PlayState

		self.PauseVideo(self)

		self.UpdateNavProgressCd = 1
	end

	if context.canceled then
		if self.PlayStateTemp ~= PlayStatus.Playing then
			self.StartPlayVideo(self)
		end

		self.UpdateNavProgressCd = 1
	end
end

M.OnGamePadForward = function(self, context)
	self.NavPauseAndPlay(self, context)

	self.ProgressNavValue = context.ReadValueFloat(context)
end

M.OnGamePadForwardLS = function(self, context)
	self.NavPauseAndPlay(self, context)

	self.ProgressNavValue = context.ReadValueVector2(context).x
end

M.OnGamePadBackward = function(self, context)
	self.NavPauseAndPlay(self, context)

	self.ProgressNavValue = context.ReadValueFloat(context) * -1
end

M.OnPlayVideoClick = function(self)
	self.bindData.PlayState = PlayStatus.Playing

	self.StartPlayVideo(self)
end

M.OnPauseVideoClick = function(self)
	self.bindData.PlayState = PlayStatus.Pause

	self.PauseVideo(self)
end

M.OnTimeSliderPress = function(self)
	self.PlayStateTemp = self.bindData.PlayState

	self:PauseVideo()

	slot1 = gSoundMgr

	slot1:PlaySoundByTid(self.loopSoundId, nil, function (uuid)
		self.loopSoundData = gSoundMgr:GetSoundData(uuid)
	end)
end

M.OnTimeSliderRelease = function(self)
	if self.PlayStateTemp ~= PlayStatus.Playing then
		self.StartPlayVideo(self)
	end

	gSoundMgr:StopSoundByTid(self.loopSoundId)
end

M.OnClosePanelClick = function(self)
	self:ClosePanel()
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_CLOSE)
end
