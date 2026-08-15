C_LivestreamPanelStore = DefClass("C_LivestreamPanelStore", C_LivestreamPanelStore, C_StoreGroup)
GroupName2Class.LivestreamPanelStore = C_LivestreamPanelStore
local M = C_LivestreamPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
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

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	local panelData = data:ToTable()
	self.commentList = {}
	self.nextAddCommentTime = gLogicTime.time + 3
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

function M:InitCommentList()
	self.bindData.CommentList.luaSimpleRenderItem = self:CreateAction("OnRenderItem_CommentList")
	self.bindData.CommentList.onGetTIndex = self:CreateAction("OnGetTIndex_CommentList")
end

function M:InitCameraSwitchButton()
	self.bindData.SwitchCameraList.luaSimpleRenderItem = self:CreateAction("OnRenderItem_SwitchCameras")
	self.bindData.SwitchCameraList.luaSimpleClick = self:CreateAction("OnClick_SwitchCameras")
	self.bindData.SwitchCameraList.onGetTIndex = self:CreateAction("OnGetTIndex_SwitchCameras")
end

function M:InitAudienceAvatars()
	self.bindData.AudienceAvatars.luaSimpleRenderItem = self:CreateAction("OnRenderItem_AudienceAvatars")
	self.bindData.AudienceAvatars.onGetTIndex = self:CreateAction("OnGetTIndex_AudienceAvatars")
end

function M:OnUpdate()
	if self.tipDisappearTime < gLogicTime.time then
		self.bindData.EnterTips:SetActive(false)
	end

	self:UpdateGiftList()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GetLiveComponentStore(widget)
	return gStoreManager:GetStoreGroup("S_LiveComponentStore"):GetStoreByWidget(widget)
end

function M:OnGetTIndex_SwitchCameras(index)
	return 0
end

function M:OnClick_SwitchCameras(btn, index)
	gMessageManager:SendMessage(gEventConstants.LIVESTREAM_CAMERA_SWITCH, index - self.currentCameraIndex)
end

function M:OnRenderItem_SwitchCameras(widget, index)
	local store = self:GetLiveComponentStore(widget)

	if not store then
		return
	end

	widget.isSelected = index == self.currentCameraIndex

	widget:SetPCKeyInfoWithOutTip(15 + index)

	store.indexText = tostring(index + 1)

	if index < #LTConfig.TaskConfig.LiveStreamCameraNames then
		store.buttonText = LTConfig.TaskConfig.LiveStreamCameraNames[index + 1]
	end

	if index < #LTConfig.TaskConfig.LiveStreamCameraImages then
		store.buttonImage = LTConfig.TaskConfig.LiveStreamCameraImages[index + 1]
	end
end

function M:OnGetTIndex_CommentList(index)
	return 0
end

function M:OnRenderItem_CommentList(widget, index)
	local store = self:GetLiveComponentStore(widget)

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
		print_error("[TimelineLivePanel]Npc Id不存在，npcId=" .. cfg.Publisher .. ", commentId=" .. commentId)

		return
	end

	store.Avatar = npcCfg.SImage
	store.CommentText.text = npcCfg.Name .. ": " .. cfg.Txt
end

function M:AddNewGiftItem()
	local store = nil

	if gLogicTime.time > self.giftDisappearTime1 + 1 then
		store = self:GetLiveComponentStore(self.bindData.Gift1)
		self.bindData.ShowGift1 = 1
		self.gift1Exist = true
		self.giftDisappearTime1 = gLogicTime.time + 3
	elseif gLogicTime.time > self.giftDisappearTime2 + 1 then
		store = self:GetLiveComponentStore(self.bindData.Gift2)
		self.bindData.ShowGift2 = 1
		self.gift2Exist = true
		self.giftDisappearTime2 = gLogicTime.time + 3
	else
		return
	end

	self:SetGiftItem(store)
end

function M:SetGiftItem(store)
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

function M:UpdateGiftList()
	if self.nextAddGiftTime < gLogicTime.time then
		self:AddNewGiftItem()

		self.nextAddGiftTime = gLogicTime.time + UnityEngine.Random.Range(1.5, 3)
	end

	if self.gift1Exist and self.giftDisappearTime1 < gLogicTime.time then
		local store = self:GetLiveComponentStore(self.bindData.Gift1)

		store.Animation:Play(self.giftExitAnimName, 0)

		self.gift1Exist = false
	end

	if self.gift2Exist and self.giftDisappearTime2 < gLogicTime.time then
		local store = self:GetLiveComponentStore(self.bindData.Gift2)

		store.Animation:Play(self.giftExitAnimName, 0)

		self.gift2Exist = false
	end
end

function M:OnGetTIndex_AxisYList(index)
	return 0
end

function M:OnRenderItem_AxisYList(widget, index)
	local store = self:GetLiveComponentStore(widget)

	if not store then
		return
	end

	store.axisValue = string.format("%.0f", self.axisYList[index + 1] / 1000)
end

function M:SimplifyNum(num, decimal)
	if num > 1000 then
		num = string.format("%." .. tostring(decimal) .. "fK", num / 1000)
	end

	return num
end

function M:OnGetTIndex_AudienceAvatars(index)
	return 0
end

function M:OnRenderItem_AudienceAvatars(widget, index)
	local store = self:GetLiveComponentStore(widget)

	if not store then
		return
	end

	store.iconId = self.audienceAvatars[index + 1]
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	return
end

function M:OnClickPreviewCameraBtn()
	if self.switchCameraCb then
		if type(self.switchCameraCb) == "function" then
			self.switchCameraCb(-1)
		elseif type(self.switchCameraCb) == "userdata" then
			self.switchCameraCb:DynamicInvoke(-1)
		end
	end
end

function M:OnClickNextCameraBtn()
	if self.switchCameraCb then
		if type(self.switchCameraCb) == "function" then
			self.switchCameraCb(1)
		elseif type(self.switchCameraCb) == "userdata" then
			self.switchCameraCb:DynamicInvoke(1)
		end
	end
end

function M:OnRenderBranchItem(btn, index)
	local store = self:GetDialogComponentStore(btn)

	if not store then
		return
	end

	local data = self.branches[index + 1]
	data.btn = btn
	store.text = data.text
	store.showText = not CS_DialogManager.Instance.IsHideDialogText
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

function M:InitLineGraph()
	local store = self:GetLiveComponentStore(self.bindData.LineChart)
	store.axisYList.luaSimpleRenderItem = self:CreateAction("OnRenderItem_AxisYList")
	store.axisYList.onGetTIndex = self:CreateAction("OnGetTIndex_AxisYList")
end

function M:RecordPopularity()
	local popularity = self.commentSum * 30 + self.giftSum * 300 + self.audienceCount * 10

	if self.popularityRecords[self.recordStartIndex] and self.recordEndIndex == self.recordStartIndex then
		self.recordStartIndex = self.recordStartIndex == self.maxLinePointCount and 1 or self.recordStartIndex + 1
	end

	self.popularityRecords[self.recordEndIndex] = popularity
	self.recordEndIndex = self.recordEndIndex == self.maxLinePointCount and 1 or self.recordEndIndex + 1

	self:RefreshLine(self.bindData.LineChart)
end

function M:RefreshLine(widget)
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

function M:CalculateNiceInterval(range, segments)
	if range <= 0 then
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

			if roughInterval < niceInterval then
				break
			end

			niceInterval = number
		end

		baseCount = baseCount * 10
	end

	return niceInterval
end

function M:GetYAxisRange(segments)
	local maxAudienceCount = 0
	local minAudienceCount = 999999999

	for _, data in pairs(self.popularityRecords) do
		if data then
			maxAudienceCount = math.max(maxAudienceCount, data + 1)
			minAudienceCount = math.min(minAudienceCount, data - 1)
		end
	end

	local interval = self:CalculateNiceInterval(maxAudienceCount - minAudienceCount, segments)
	minAudienceCount = Mathf.Floor(minAudienceCount / interval) * interval
	maxAudienceCount = Mathf.Ceil(maxAudienceCount / interval) * interval
	local actualSegments = Mathf.Ceil((maxAudienceCount - minAudienceCount) / interval)

	if actualSegments ~= segments then
		maxAudienceCount = minAudienceCount + interval * segments
	end

	local count = self:GetRecordCount()

	if count > 30 and self.axisYList and #self.axisYList > 0 then
		local currentMin = self.axisYList[#self.axisYList]
		local currentMax = self.axisYList[1]

		if currentMin ~= minAudienceCount or currentMax ~= maxAudienceCount then
			local maxDiff = (maxAudienceCount - minAudienceCount) / 40
			maxAudienceCount = Mathf.Clamp(maxAudienceCount, currentMax - maxDiff, currentMax + maxDiff)
			minAudienceCount = Mathf.Clamp(minAudienceCount, currentMin - maxDiff, currentMin + maxDiff)
		end
	end

	return minAudienceCount, maxAudienceCount
end

function M:GetRecordCount()
	return self.recordEndIndex ~= self.recordStartIndex and self.recordEndIndex - self.recordStartIndex or self.maxLinePointCount
end

function M:GetRecordIndex(index)
	return index < self.recordStartIndex and self.maxLinePointCount + index - self.recordStartIndex or index - self.recordStartIndex
end

function M:GetMapHistoryLineRendererPositionArray(width, height, minAudienceCount, maxAudienceCount)
	local targetDataArray = {}
	local interval = Mathf.Min(#self.popularityRecords, self.maxLinePointCount)

	for i, data in pairs(self.popularityRecords) do
		if data then
			local index = self:GetRecordIndex(i)
			local count = self:GetRecordCount()
			local x = (interval - count + index) / interval * width
			local y = (data - minAudienceCount) / (maxAudienceCount - minAudienceCount) * height
			targetDataArray[index + 1] = Vector3.New(x, y, 0)
		end
	end

	return targetDataArray
end

function M:GetYAxisList(minAudienceCount, maxAudienceCount, segments)
	local targetArray = {}

	for i = 0, 4 do
		table.insert(targetArray, maxAudienceCount - math.floor((maxAudienceCount - minAudienceCount) / segments * i))
	end

	self.axisYList = targetArray
end

function M:SetStreamerInfo(streamerId)
	local cfg = LTConfig.TuiteNPCConfig.GetConfig(streamerId)

	if cfg then
		self.bindData.StreamerAvatar = cfg.SImage
		self.bindData.StreamerName.text = cfg.Name
	else
		print_error("[TimelineLivePanel]未配置主播信息")
	end
end

function M:SetAudienceCount(audienceCount)
	self.audienceCount = audienceCount

	if self.nextAudienceCountRefreshTime < gLogicTime.time then
		self.bindData.AudienceCount.text = self:SimplifyNum(audienceCount, 0)
		self.nextAudienceCountRefreshTime = gLogicTime.time + self.audienceCountRefreshInterval
	end

	self:RecordPopularity()
end

function M:AddComment(commentId)
	if not self.commentList then
		return
	end

	self.commentSum = self.commentSum + 1

	table.insert(self.commentList, commentId)

	if self.maxCommentCount < #self.commentList then
		table.remove(self.commentList, 1)
	end

	self.bindData.CommentList:SetSimpleList(#self.commentList)
	self.bindData.CommentList:GoToIndex(#self.commentList - 1, false)
end

function M:GetRandomNpcId()
	local npcId = UnityEngine.Random.Range(11001, 11220)

	if LTConfig.TuiteNPCConfig.GetConfig(npcId) then
		return npcId
	end

	return 0
end

function M:AddGift(giftCount)
	self.giftSum = self.giftSum + giftCount
end

function M:AddAudienceAvatar(npcId)
	if not self.audienceAvatars then
		return
	end

	local npcCfg = LTConfig.TuiteNPCConfig.GetConfig(npcId)

	if not npcCfg then
		return
	end

	table.insert(self.audienceAvatars, npcCfg.SImage)

	if #self.audienceAvatars > 3 then
		table.remove(self.audienceAvatars, 1)
	end

	self.bindData.AudienceAvatars:SetSimpleList(#self.audienceAvatars)
	self.bindData.EnterTips:SetActive(true)

	self.bindData.EnterTipText.text = string.gsub(LTConfig.TaskConfig.LiveStreamEnterTipText, "{0}", npcCfg.Name)
	self.tipDisappearTime = gLogicTime.time + self.tipShowTime
end

function M:ShowSwitchCameraButton(enable)
	self.bindData.ShowSwitchBtn = enable and 1 or 0
end

function M:SetCameraCount(cameraCount)
	self.cameraCount = cameraCount

	self.bindData.SwitchCameraList:SetSimpleList(self.cameraCount)
end

function M:SetCurrentCameraIndex(currentIndex)
	self.currentCameraIndex = currentIndex

	self.bindData.SwitchCameraList:SetSimpleList(self.cameraCount)
end
