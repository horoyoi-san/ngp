-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DivinerLivestreamPanelStore.lua
-- Decompiled from: 01899_DivinerLivestreamPanelStore.lua_0b046690fb60.luajit

C_DivinerLivestreamPanelStore = DefClass("C_DivinerLivestreamPanelStore", C_DivinerLivestreamPanelStore, C_StoreGroup)
GroupName2Class.DivinerLivestreamPanelStore = C_DivinerLivestreamPanelStore
local M = C_DivinerLivestreamPanelStore
local DivinerConfig = LTConfig.DivinerConfig
local TuiteNPCConfig = LTConfig.TuiteNPCConfig

M.ctor = function(self)
	self.SCCommentType = {
		["X.h^"] = 2,
		["]-q_"] = 4,
		[",]\\x83\\x9e\\x8fD"] = 3,
		["j\\xbc\\xa7\\xaa\\xb8"] = 1
	}
end

M.DefineAllVariables = function(self)
	self.maxCommentCount = DivinerConfig.LiveChatMaxMessageShowCount
	self.maxSCCommentCount = DivinerConfig.LiveChatMaxSCMessageShowCount
	self.maxGiftCount = 2
	self.tipShowTime = 2
	self.audienceCountRefreshInterval = 5
	self.nextAudienceCountRefreshTime = 0
	self.currentCameraIndex = 0
	self.cameraCount = 0
	self.audienceAvatars = {}
	self.tipDisappearTime = 0
	self.giftSum = 0
	self.commentSum = 0
	self.scCommentSum = 0
	self.addCommentDelta = DivinerConfig.LiveChatAddMessageTimeRange.RangeMin
	self.addCommentRandomDelta = DivinerConfig.LiveChatAddMessageTimeRange.RangeMax - DivinerConfig.LiveChatAddMessageTimeRange.RangeMin
	self.addSCCommentDelta = DivinerConfig.LiveChatAddSCMessageTimeRange.RangeMin
	self.addSCCommentRandomDelta = DivinerConfig.LiveChatAddSCMessageTimeRange.RangeMax - DivinerConfig.LiveChatAddSCMessageTimeRange.RangeMin
	self.showGiftMinTime = DivinerConfig.LiveChatGiftShowTimeRange.RangeMin
	self.showGiftMaxTime = DivinerConfig.LiveChatGiftShowTimeRange.RangeMax
	self.showGiftMinCount = DivinerConfig.LiveChatGiftCountRange.RangeMin
	self.showGiftMaxCount = DivinerConfig.LiveChatGiftCountRange.RangeMax
	self.messageLikeRangeMin = DivinerConfig.MessageLikeRange.RangeMin
	self.messageLikeRangeMax = DivinerConfig.MessageLikeRange.RangeMax
	self.giftLikeRangeMin = DivinerConfig.GiftLikeRange.RangeMin
	self.giftLikeRangeMax = DivinerConfig.GiftLikeRange.RangeMax
	self.audienceLikeRangeMin = DivinerConfig.AudienceLikeRange.RangeMin
	self.audienceLikeRangeMax = DivinerConfig.AudienceLikeRange.RangeMax
	self.addGiftPercent = DivinerConfig.LiveChatMessageAddGiftPercent
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
	self.commentList = nil
	self.scCommentList = nil
	self.messagePool = nil
	self.scMessagePool = nil
	self.giftInfos = nil
	self.npcInfoMap = nil
	self.SCCommentTypeInfo = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.InitCommentList = function(self)
	self.bindData.CommentList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem_CommentList")
	self.bindData.CommentList.onGetTIndex = self.CreateAction(self, "OnGetTIndex_CommentList")
	self.bindData.scList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem_SCCommentList")
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

	if self.nextAddCommentTime >= gLogicTime.time and #self.messagePool <= 0 then
		local message = self.messagePool[1]

		table.remove(self.messagePool, 1)
		self.AddComment(self, message)
		math.randomseed(os.clock())

		self.nextAddCommentTime = gLogicTime.time + self.addCommentDelta + math.random() * self.addCommentRandomDelta
	end

	self.UpdateSCComment(self)
end

M.UpdateSCComment = function(self)
	local needRebuildList = false

	if self.scCommentList and #self.scCommentList <= 0 and self.firstShowEndTime < gLogicTime.time then
		needRebuildList = true
		local lastShowEndTime = self.firstShowEndTime
		self.firstShowEndTime = nil
		local count = #self.scCommentList

		for i = 1, count do
			local index = count - i + 1
			local comment = self.scCommentList[index]

			if comment.showEndTime < lastShowEndTime then
				table.remove(self.scCommentList, index)
			elseif self.firstShowEndTime then
				if comment.showEndTime >= self.firstShowEndTime then
					self.firstShowEndTime = comment.showEndTime
				end
			else
				self.firstShowEndTime = comment.showEndTime
			end
		end
	end

	if self.scMessagePool and #self.scMessagePool <= 0 and self.scCommentList and #self.scCommentList >= self.maxSCCommentCount and self.nextAddSCCommentTime >= gLogicTime.time and #self.scMessagePool <= 0 then
		local message = self.scMessagePool[1]

		table.remove(self.scMessagePool, 1)
		self.AddSCComment(self, message)

		self.nextAddSCCommentTime = gLogicTime.time + self.addSCCommentDelta + math.random() * self.addSCCommentRandomDelta
	end

	if needRebuildList then
		self.RebuildSCCommentList(self)
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GetLiveComponentStore = function(self, widget)
	return gStoreManager:GetStoreGroup("S_LiveComponentStore"):GetStoreByWidget(widget)
end

M.OnGetTIndex_CommentList = function(self, index)
	return 0
end

M.OnRenderItem_CommentList = function(self, widget, index)
	local store = self.GetLiveComponentStore(self, widget)

	if not store then
		return
	end

	local commentInfo = self.commentList[index + 1]
	store.Avatar = commentInfo.avatar
	store.CommentText.text = commentInfo.message
end

M.OnRenderItem_SCCommentList = function(self, widget, index)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	local commentInfo = self.scCommentList[index + 1]
	store.headIcon = commentInfo.avatar
	store.content = commentInfo.message
	store.qualityCtrl = commentInfo.quality
	local tuiteCfg = TuiteNPCConfig.GetConfig(commentInfo.tuiteId or 0)

	if tuiteCfg then
		store.name = tuiteCfg.Name
	end
end

M.AddNewGiftItem = function(self)
	if #self.giftInfos ~= 0 then
		return
	end

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
	local data = self.giftInfos[1]

	table.remove(self.giftInfos, 1)

	store.Avatar = data.iconId
	local count = math.floor(UnityEngine.Random.Range(self.showGiftMinCount, self.showGiftMaxCount))
	store.Count.text = tostring(count)
	store.Name.text = data.name

	store.Animation:Play(self.giftEnterAnimName, 0)
	self:AddGiftFans(count)
end

M.UpdateGiftList = function(self)
	if self.nextAddGiftTime >= gLogicTime.time then
		self.AddNewGiftItem(self)

		self.nextAddGiftTime = gLogicTime.time + UnityEngine.Random.Range(self.showGiftMinTime, self.showGiftMaxTime)
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

M.AddMessages = function(self, messages)
	if not self.messagePool then
		return
	end

	for i = 1, messages.Count do
		table.insert(self.messagePool, messages[i])
	end
end

M.AddSCMessages = function(self, messages)
	if not self.scMessagePool then
		return
	end

	for i = 1, messages.Count do
		table.insert(self.scMessagePool, messages[i])

		if #self.scMessagePool <= 30 then
			break
		end
	end
end

M.RebuildSCCommentList = function(self)
	table.sort(self.scCommentList, function (a, b)
		if a.quality ~= b.quality then
			return a.commentIndex <= b.commentIndex
		else
			return b.quality <= a.quality
		end
	end)
	self.bindData.scList:SetSimpleList(#self.scCommentList)
end

M.AddComment = function(self, message)
	if not self.commentList then
		return
	end

	self.commentSum = self.commentSum + 1
	local info, isNew = self:GetNpcInfo(message.NpcId, message.NpcType)

	table.insert(self.commentList, {
		avatar = info.iconId,
		message = LTConfig.PartyConfig.CommentFormatText:format(message.NpcNickname, message.Message)
	})

	if self.maxCommentCount >= #self.commentList then
		table.remove(self.commentList, 1)
	end

	self.bindData.CommentList:SetSimpleList(#self.commentList)
	self.bindData.CommentList:GoToIndex(#self.commentList - 1, false)
	self:AddMessageFans()

	if isNew then
		self.AddAudienceAvatar(self, info.iconId, message.NpcNickname)
	end

	if math.random() >= self.addGiftPercent then
		self.AddNpcGift(self, info.iconId, message.NpcNickname)
	end
end

M.AddSCComment = function(self, message)
	if not self.scCommentList then
		return
	end

	math.randomseed(os.clock())

	self.scCommentSum = self.scCommentSum + 1
	local info, isNew = self.GetNpcInfo(self, message.NpcId, message.NpcType)
	local randomWeight = math.random(0, self.totalSCWeight)
	local randomSCTypeInfo = self.SCCommentTypeInfo[1]

	for i = 1, 4 do
		local scTypeInfo = self.SCCommentTypeInfo[i]

		if scTypeInfo.weight >= randomWeight then
			randomWeight = randomWeight - scTypeInfo.weight
		else
			randomSCTypeInfo = scTypeInfo

			break
		end
	end

	local showEndTime = gLogicTime.time + randomSCTypeInfo.showTime

	if self.firstShowEndTime then
		if showEndTime >= self.firstShowEndTime then
			self.firstShowEndTime = showEndTime
		end
	else
		self.firstShowEndTime = showEndTime
	end

	table.insert(self.scCommentList, {
		avatar = info.iconId,
		tuiteId = info.tuiteId,
		message = LTConfig.PartyConfig.CommentFormatText:format(message.NpcNickname, message.Message),
		quality = randomSCTypeInfo.ctrl,
		showEndTime = showEndTime,
		commentIndex = self.scCommentSum
	})
	self:AddMessageFans()

	if isNew then
		self.AddAudienceAvatar(self, info.iconId, message.NpcNickname)
	end

	if math.random() >= self.addGiftPercent then
		self.AddNpcGift(self, info.iconId, message.NpcNickname)
	end
end

M.AddGift = function(self, giftCount)
	self.giftSum = self.giftSum + giftCount
end

M.AddAudienceAvatar = function(self, iconId, name)
	if not self.audienceAvatars then
		return
	end

	table.insert(self.audienceAvatars, iconId)

	if #self.audienceAvatars <= 3 then
		table.remove(self.audienceAvatars, 1)
	end

	self.bindData.AudienceAvatars:SetSimpleList(#self.audienceAvatars)
	self.bindData.EnterTips:SetActive(true)

	self.bindData.EnterTipText.text = string.gsub(LTConfig.TaskConfig.LiveStreamEnterTipText, "{0}", name)
	self.tipDisappearTime = gLogicTime.time + self.tipShowTime

	self:AddAudienceFans()
end

M.ShowSwitchCameraButton = function(self, enable)
	self.bindData.ShowSwitchBtn = enable and 1 or 0
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

M.SetData = function(self, data)
	self.commentList = {}
	self.scCommentList = {}
	self.messagePool = {}
	self.scMessagePool = {}
	self.giftInfos = {}
	self.npcInfoMap = {}
	self.nextAddCommentTime = gLogicTime.time + 3
	self.nextAddSCCommentTime = gLogicTime.time + 3
	self.commentSum = 0
	self.scCommentSum = 0
	self.giftSum = 0
	self.fans = 0
	self.firstShowEndTime = nil
	self.nextAddGiftTime = 0
	self.giftDisappearTime1 = 0
	self.giftDisappearTime2 = 0
	self.gift2Exist = false
	self.gift2Exist = false

	self:InitCommentList()
	self:InitAudienceAvatars()
	self:SetStreamerInfo(data.streamerIconId, data.streamerName)

	self.SCCommentTypeInfo = {}
	self.totalSCWeight = 0
	local weight = DivinerConfig.LiveChatMaxSCQualityWeight[self.SCCommentType.Green] or 10
	self.totalSCWeight = self.totalSCWeight + weight
	self.SCCommentTypeInfo[self.SCCommentType.Green] = {
		y6oW = 2,
		weight = weight,
		showTime = DivinerConfig.LiveChatMaxSCShowTime[self.SCCommentType.Green] or 2
	}
	weight = DivinerConfig.LiveChatMaxSCQualityWeight[self.SCCommentType.Blue] or 10
	self.totalSCWeight = self.totalSCWeight + weight
	self.SCCommentTypeInfo[self.SCCommentType.Blue] = {
		y6oW = 3,
		weight = weight,
		showTime = DivinerConfig.LiveChatMaxSCShowTime[self.SCCommentType.Blue] or 2
	}
	weight = DivinerConfig.LiveChatMaxSCQualityWeight[self.SCCommentType.Purple] or 10
	self.totalSCWeight = self.totalSCWeight + weight
	self.SCCommentTypeInfo[self.SCCommentType.Purple] = {
		y6oW = 4,
		weight = weight,
		showTime = DivinerConfig.LiveChatMaxSCShowTime[self.SCCommentType.Purple] or 2
	}
	weight = DivinerConfig.LiveChatMaxSCQualityWeight[self.SCCommentType.Gold] or 10
	self.totalSCWeight = self.totalSCWeight + weight
	self.SCCommentTypeInfo[self.SCCommentType.Gold] = {
		y6oW = 5,
		weight = weight,
		showTime = DivinerConfig.LiveChatMaxSCShowTime[self.SCCommentType.Gold] or 2
	}
end

M.GetNpcInfo = function(self, npcId, npcType)
	local npcIdNumber = gFurnitureUtils:ConvertServerUidToNumber(npcId)
	local info = self.npcInfoMap[npcIdNumber]
	local isNew = false

	if not info or not info.iconId then
		local viewerCfg = LTConfig.PartyLiveViewerConfig.GetConfig(npcType)
		info = {
			iconId = viewerCfg and viewerCfg.Image[math.random(#viewerCfg.Image)] or nil,
			tuiteId = viewerCfg and viewerCfg.NPCIds[math.random(#viewerCfg.NPCIds)] or nil
		}
		self.npcInfoMap[npcIdNumber] = info
		isNew = true
	end

	return info, isNew
end

M.AddNpcGift = function(self, iconId, name)
	table.insert(self.giftInfos, {
		iconId = iconId,
		name = name
	})
end

M.SetStreamerInfo = function(self, iconId, name)
	self.bindData.StreamerAvatar = iconId
	self.bindData.StreamerName.text = name
end

M.AddMessageFans = function(self)
	local fans = math.floor(UnityEngine.Random.Range(self.messageLikeRangeMin, self.messageLikeRangeMax)) / 10000
	self.fans = self.fans + fans
	self.bindData.likeCount = string.format(DivinerConfig.LikeCountText, self.fans)
end

M.AddGiftFans = function(self, count)
	local fans = math.floor(UnityEngine.Random.Range(self.giftLikeRangeMin, self.giftLikeRangeMax)) * count / 10000
	self.fans = self.fans + fans
	self.bindData.likeCount = string.format(DivinerConfig.LikeCountText, self.fans)
end

M.AddAudienceFans = function(self)
	local fans = math.floor(UnityEngine.Random.Range(self.audienceLikeRangeMin, self.audienceLikeRangeMax)) / 10000
	self.fans = self.fans + fans
	self.bindData.likeCount = string.format(DivinerConfig.LikeCountText, self.fans)
end
