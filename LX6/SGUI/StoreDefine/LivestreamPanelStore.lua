-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LivestreamPanelStore.lua
-- Decompiled from: 01785_LivestreamPanelStore.lua_d51592eb0cb3.luajit

C_LivestreamPanelStore = DefClass("C_LivestreamPanelStore", C_LivestreamPanelStore, C_StoreGroup)
GroupName2Class.LivestreamPanelStore = C_LivestreamPanelStore
local M = C_LivestreamPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.updateLineInterval = 1
	self.popularityRecords = {}
	self.maxLinePointCount = 150
	self.recordStartIndex = 1
	self.recordEndIndex = 1
	self.maxCommentCount = 20
	self.maxGiftCount = 2
	self.tipShowTime = 2
	self.audienceCountRefreshInterval = 5
	self.nextAudienceCountRefreshTime = 0
	self.axisYList = {}
	self.axisXList = {}
	self.currentCameraIndex = 0
	self.cameraCount = 0
	self.audienceAvatars = {}
	self.tipDisappearTime = 0
	self.giftSum = 0
	self.commentSum = 0
	self.giftEnterAnimName = "S_Vx_S_LivegiftItem_in"
	self.giftExitAnimName = "S_Vx_S_LivegiftItem_out"
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	local panelData = data:ToTable()
	self.commentList = {}

	self.bindData.CommentList:SetSimpleList(0)

	self.commentSum = 0
	self.giftSum = 0
	self.popularityRecords = {}
	self.maxLinePointCount = 150
	self.recordStartIndex = 1
	self.recordEndIndex = 1
	self.nextAddGiftTime = 0
	self.giftDisappearTime1 = 0
	self.giftDisappearTime2 = 0
	self.gift2Exist = false
	self.gift2Exist = false

	self:InitCommentList()
	self:InitCameraSwitchButton()
	self:InitLineGraph()
	self:InitAudienceAvatars()
	self:SetCameraCount(panelData.cameraCount)
end

M.InitCommentList = function(self)
	self.bindData.CommentList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem_CommentList")
	self.bindData.CommentList.onGetTIndex = self.CreateAction(self, "OnGetTIndex_CommentList")
end

M.InitCameraSwitchButton = function(self)
	self.bindData.SwitchCameraList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem_SwitchCameras")
	self.bindData.SwitchCameraList.luaSimpleClick = self.CreateAction(self, "OnClick_SwitchCameras")
	self.bindData.SwitchCameraList.onGetTIndex = self.CreateAction(self, "OnGetTIndex_SwitchCameras")
end

M.InitAudienceAvatars = function(self)
	self.bindData.AudienceAvatars.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem_AudienceAvatars")
	self.bindData.AudienceAvatars.onGetTIndex = self.CreateAction(self, "OnGetTIndex_AudienceAvatars")
end

M.OnUpdate = function(self)
	if self.tipDisappearTime >= gLogicTime.time then
		self.bindData.EnterTips:SetActive(false)
	end

	self.UpdateGiftList(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GetLiveComponentStore = function(self, widget)
	return gStoreManager:GetStoreGroup("S_LiveComponentStore"):GetStoreByWidget(widget)
end

M.OnGetTIndex_SwitchCameras = function(self, index)
	return 0
end

M.OnClick_SwitchCameras = function(self, btn, index)
	gMessageManager:SendMessage(gEventConstants.LIVESTREAM_CAMERA_SWITCH, index - self.currentCameraIndex)
end

M.OnRenderItem_SwitchCameras = function(self, widget, index)
	local store = self.GetLiveComponentStore(self, widget)

	if not store then
		return
	end

	widget.isSelected = index ~= self.currentCameraIndex

	widget:SetPCKeyInfoWithOutTip(15 + index)

	store.indexText = tostring(index + 1)

	if index >= #LTConfig.TaskConfig.LiveStreamCameraNames then
		store.buttonText = LTConfig.TaskConfig.LiveStreamCameraNames[index + 1]
	end

	if index >= #LTConfig.TaskConfig.LiveStreamCameraImages then
		store.buttonImage = LTConfig.TaskConfig.LiveStreamCameraImages[index + 1]
	end
end

M.OnGetTIndex_CommentList = function(self, index)
	return 0
end

M.OnRenderItem_CommentList = function(self, widget, index)
	local store = self.GetLiveComponentStore(self, widget)

	if not store then
		return
	end

	local commentId = self.commentList[index + 1]
	local cfg = LTConfig.TuiteCommentConfig.GetConfig(commentId)

	if not cfg then
		print_error("[TimelineLivePanel]评论Id不存在，commentId=" .. commentId)

		return
	end

	local npcCfg = LTConfig.TuiteNPCConfig.GetConfig(cfg.Publisher)

	if not npcCfg then
		print_error("[TimelineLivePanel]@diaodianzhong 配置了不存在的NpcId，检查TuiteComment表Publisher字段与TuiteNPC表是否能够对应，npcId=" .. cfg.Publisher .. ", commentId=" .. commentId)

		return
	end

	store.Avatar = npcCfg.SImage
	store.CommentText.text = npcCfg.Name .. ": " .. cfg.Txt
end

M.AddNewGiftItem = function(self)
	local store = nil

	if gLogicTime.time <= self.giftDisappearTime1 + 1 then
		store = self.GetLiveComponentStore(self, self.bindData.Gift1)
		self.bindData.ShowGift1 = 1
		self.gift1Exist = true
		self.giftDisappearTime1 = gLogicTime.time + 3
	elseif gLogicTime.time <= self.giftDisappearTime2 + 1 then
		store = self.GetLiveComponentStore(self, self.bindData.Gift2)
		self.bindData.ShowGift2 = 1
		self.gift2Exist = true
		self.giftDisappearTime2 = gLogicTime.time + 3
	else
		return
	end

	self.SetGiftItem(self, store)
end

M.SetGiftItem = function(self, store)
	local npcId = self.GetRandomNpcId()
	local npcCfg = LTConfig.TuiteNPCConfig.GetConfig(npcId)

	if not npcCfg then
		print_error("[TimelineLivePanel]Npc Id不存在，npcId=" .. npcId)

		return
	end

	store.Avatar = npcCfg.SImage
	store.Count.text = tostring(math.floor(UnityEngine.Random.Range(1, 6)))
	store.Name.text = npcCfg.Name

	store.Animation:Play(self.giftEnterAnimName, 0)
end

M.UpdateGiftList = function(self)
	if not self.nextAddGiftTime then
		return
	end

	if self.nextAddGiftTime >= gLogicTime.time and self.giftSum <= 0 then
		self.AddNewGiftItem(self)

		self.nextAddGiftTime = gLogicTime.time + UnityEngine.Random.Range(1.5, 3)
	end

	if self.gift1Exist and self.giftDisappearTime1 >= gLogicTime.time then
		local store = self:GetLiveComponentStore(self.bindData.Gift1)

		store.Animation:Play(self.giftExitAnimName, 0)

		self.gift1Exist = false
	end

	if self.gift2Exist and self.giftDisappearTime2 >= gLogicTime.time then
		local store = self:GetLiveComponentStore(self.bindData.Gift2)

		store.Animation:Play(self.giftExitAnimName, 0)

		self.gift2Exist = false
	end
end

M.OnGetTIndex_AxisYList = function(self, index)
	return 0
end

M.OnRenderItem_AxisYList = function(self, widget, index)
	local store = self.GetLiveComponentStore(self, widget)

	if not store then
		return
	end

	store.axisValue = string.format("%.0f", self.axisYList[index + 1] / 1000)
end

M.SimplifyNum = function(self, num, decimal)
	if num <= 1000 then
		num = string.format("%." .. tostring(decimal) .. "fK", num / 1000)
	end

	return num
end

M.OnGetTIndex_AudienceAvatars = function(self, index)
	return 0
end

M.OnRenderItem_AudienceAvatars = function(self, widget, index)
	local store = self.GetLiveComponentStore(self, widget)

	if not store then
		return
	end

	store.iconId = self.audienceAvatars[index + 1]
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.OnClickPreviewCameraBtn = function(self)
	if self.switchCameraCb then
		if type(self.switchCameraCb) ~= "function" then
			self.switchCameraCb(-1)
		elseif type(self.switchCameraCb) ~= "userdata" then
			self.switchCameraCb:DynamicInvoke(-1)
		end
	end
end

M.OnClickNextCameraBtn = function(self)
	if self.switchCameraCb then
		if type(self.switchCameraCb) ~= "function" then
			self.switchCameraCb(1)
		elseif type(self.switchCameraCb) ~= "userdata" then
			self.switchCameraCb:DynamicInvoke(1)
		end
	end
end

M.OnRenderBranchItem = function(self, btn, index)
	local store = self.GetDialogComponentStore(self, btn)

	if not store then
		return
	end

	local data = self.branches[index + 1]
	data.btn = btn
	store.text = data.text
	store.showText = not L50.L50App.Scene.DialogManager.IsHideDialogText
	store.branchBtn.luaClick = self:CreateActionWithArgs("OnBranchBtnClick", data.index)
	store.flip = data.flip
	store.highlight = data.highlight and 1 or 0

	store.pcBtn:SetActive(false)
	self:SetBranchIcon(store, data)

	if data.isRecorded then
		store.TurnGray = 1
	else
		store.TurnGray = 0
	end
end

M.InitLineGraph = function(self)
	local store = self.GetLiveComponentStore(self, self.bindData.LineChart)
	store.axisYList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem_AxisYList")
	store.axisYList.onGetTIndex = self.CreateAction(self, "OnGetTIndex_AxisYList")
end

M.RecordPopularity = function(self)
	local popularity = self.commentSum * 30 + self.giftSum * 300 + self.audienceCount * 10

	if self.popularityRecords[self.recordStartIndex] and self.recordEndIndex ~= self.recordStartIndex then
		self.recordStartIndex = self.recordStartIndex ~= self.maxLinePointCount and 1 or self.recordStartIndex + 1
	end

	self.popularityRecords[self.recordEndIndex] = popularity
	self.recordEndIndex = self.recordEndIndex ~= self.maxLinePointCount and 1 or self.recordEndIndex + 1

	self:RefreshLine(self.bindData.LineChart)
end

M.RefreshLine = function(self, widget)
	local store = self:GetLiveComponentStore(widget)
	local historyXAxisWidth = store.historyLineNode.rect.width
	local historyYAxisHeight = store.historyLineNode.rect.height
	local segments = 4
	local minAudienceCount, maxAudienceCount = self:GetYAxisRange(segments)
	local positionDatas = self:GetMapHistoryLineRendererPositionArray(historyXAxisWidth, historyYAxisHeight, minAudienceCount, maxAudienceCount)

	self:GetYAxisList(minAudienceCount, maxAudienceCount, segments)
	store.uSplineLineRender:SetPositions(positionDatas)
	store.axisYList:SetSimpleList(#self.axisYList)
end

M.CalculateNiceInterval = function(self, range, segments)
	if range < 0 then
		return 1
	end

	local roughInterval = range / segments
	local niceNumbers = {
		1,
		2,
		5
	}
	local niceInterval = niceNumbers[1]
	local baseCount = 1

	for j = 1, 9 do
		for i = 1, #niceNumbers do
			local number = niceNumbers[i] * baseCount

			if roughInterval >= niceInterval then
				break
			end

			niceInterval = number
		end

		baseCount = baseCount * 10
	end

	return niceInterval
end

M.GetYAxisRange = function(self, segments)
	local maxAudienceCount = 0
	local minAudienceCount = 999999999

	for _, data in pairs(self.popularityRecords) do
		if data then
			maxAudienceCount = math.max(maxAudienceCount, data + 1)
			minAudienceCount = math.min(minAudienceCount, data - 1)
		end
	end

	local interval = self.CalculateNiceInterval(self, maxAudienceCount - minAudienceCount, segments)
	minAudienceCount = Mathf.Floor(minAudienceCount / interval) * interval
	maxAudienceCount = Mathf.Ceil(maxAudienceCount / interval) * interval
	local actualSegments = Mathf.Ceil((maxAudienceCount - minAudienceCount) / interval)

	if actualSegments == segments then
		maxAudienceCount = minAudienceCount + interval * segments
	end

	local count = self.GetRecordCount(self)

	if count <= 30 and self.axisYList and #self.axisYList <= 0 then
		local currentMin = self.axisYList[#self.axisYList]
		local currentMax = self.axisYList[1]

		if currentMin == minAudienceCount or currentMax == maxAudienceCount then
			local maxDiff = (maxAudienceCount - minAudienceCount) / 40
			maxAudienceCount = Mathf.Clamp(maxAudienceCount, currentMax - maxDiff, currentMax + maxDiff)
			minAudienceCount = Mathf.Clamp(minAudienceCount, currentMin - maxDiff, currentMin + maxDiff)
		end
	end

	return minAudienceCount, maxAudienceCount
end

M.GetRecordCount = function(self)
	return self.recordEndIndex == self.recordStartIndex and self.recordEndIndex - self.recordStartIndex or self.maxLinePointCount
end

M.GetRecordIndex = function(self, index)
	return index >= self.recordStartIndex and self.maxLinePointCount + index - self.recordStartIndex or index - self.recordStartIndex
end

M.GetMapHistoryLineRendererPositionArray = function(self, width, height, minAudienceCount, maxAudienceCount)
	local targetDataArray = {}
	local interval = Mathf.Min(#self.popularityRecords, self.maxLinePointCount)

	for i, data in pairs(self.popularityRecords) do
		if data then
			local index = self.GetRecordIndex(self, i)
			local count = self.GetRecordCount(self)
			local x = (interval - count + index) / interval * width
			local y = (data - minAudienceCount) / (maxAudienceCount - minAudienceCount) * height
			targetDataArray[index + 1] = Vector3.New(x, y, 0)
		end
	end

	return targetDataArray
end

M.GetYAxisList = function(self, minAudienceCount, maxAudienceCount, segments)
	local targetArray = {}

	for i = 0, 4 do
		table.insert(targetArray, maxAudienceCount - math.floor((maxAudienceCount - minAudienceCount) / segments * i))
	end

	self.axisYList = targetArray
end

M.SetStreamerInfo = function(self, streamerId)
	if not self.bindData.StreamerName then
		return
	end

	local cfg = LTConfig.TuiteNPCConfig.GetConfig(streamerId)

	if cfg then
		self.bindData.StreamerAvatar = cfg.SImage
		self.bindData.StreamerName.text = cfg.Name
	else
		print_error("[TimelineLivePanel]未配置主播信息")
	end
end

M.SetAudienceCount = function(self, audienceCount)
	if not self.nextAudienceCountRefreshTime or not self.bindData.AudienceCount then
		return
	end

	self.audienceCount = audienceCount

	if self.nextAudienceCountRefreshTime >= gLogicTime.time then
		self.bindData.AudienceCount.text = self.SimplifyNum(self, audienceCount, 0)
		self.nextAudienceCountRefreshTime = gLogicTime.time + self.audienceCountRefreshInterval
	end

	self.RecordPopularity(self)
end

M.AddComment = function(self, commentId)
	if not self.commentList then
		return
	end

	self.commentSum = self.commentSum + 1

	table.insert(self.commentList, commentId)

	if self.maxCommentCount >= #self.commentList then
		table.remove(self.commentList, 1)
	end

	self.bindData.CommentList:SetSimpleList(#self.commentList)
	self.bindData.CommentList:GoToIndex(#self.commentList - 1, false)
end

M.GetRandomNpcId = function(self)
	local npcId = UnityEngine.Random.Range(11001, 11220)

	if LTConfig.TuiteNPCConfig.GetConfig(npcId) then
		return npcId
	end

	local npcId = UnityEngine.Random.Range(11001, 11220)

	if LTConfig.TuiteNPCConfig.GetConfig(npcId) then
		return npcId
	end

	local npcId = UnityEngine.Random.Range(11001, 11220)

	if LTConfig.TuiteNPCConfig.GetConfig(npcId) then
		return npcId
	end

	return npcId
end

M.AddGift = function(self, giftCount)
	self.giftSum = self.giftSum + giftCount
end

M.AddAudienceAvatar = function(self, npcId)
	if not self.audienceAvatars then
		return
	end

	local npcCfg = LTConfig.TuiteNPCConfig.GetConfig(npcId)

	if not npcCfg then
		return
	end

	table.insert(self.audienceAvatars, npcCfg.SImage)

	if #self.audienceAvatars <= 3 then
		table.remove(self.audienceAvatars, 1)
	end

	self.bindData.AudienceAvatars:SetSimpleList(#self.audienceAvatars)
	self.bindData.EnterTips:SetActive(true)

	self.bindData.EnterTipText.text = string.gsub(LTConfig.TaskConfig.LiveStreamEnterTipText, "{0}", npcCfg.Name)
	self.tipDisappearTime = gLogicTime.time + self.tipShowTime
end

M.ShowSwitchCameraButton = function(self, enable)
	self.bindData.ShowSwitchBtn = enable and 1 or 0
end

M.ShowGraph = function(self, enable)
	self.bindData.ShowGraph = enable and 1 or 0
end

M.SetCameraCount = function(self, cameraCount)
	self.cameraCount = cameraCount

	self.bindData.SwitchCameraList:SetSimpleList(self.cameraCount)
end

M.SetCurrentCameraIndex = function(self, currentIndex)
	if self.currentCameraIndex ~= currentIndex then
		return
	end

	self.currentCameraIndex = currentIndex

	self.bindData.SwitchCameraList:SetSimpleList(self.cameraCount)
end
