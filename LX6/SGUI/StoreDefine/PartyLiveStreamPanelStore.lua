-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartyLiveStreamPanelStore.lua
-- Decompiled from: 01079_PartyLiveStreamPanelStore.lua_3bcc28b6f714.luajit

C_PartyLiveStreamPanelStore = DefClass("C_PartyLiveStreamPanelStore", C_PartyLiveStreamPanelStore, C_StoreGroup)
GroupName2Class.PartyLiveStreamPanelStore = C_PartyLiveStreamPanelStore
local M = C_PartyLiveStreamPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.begLikeButton.luaClick = self.CreateAction(self, "OnClickBegLikeButton")
	self.bindData.begGiftButton.luaClick = self.CreateAction(self, "OnClickBegGiftButton")
	self.bindData.gestureButton.luaClick = self.CreateAction(self, "OnClickGestureButton")
	self.bindData.banCommentButton.luaClick = self.CreateAction(self, "OnClickBanCommentButton")
	self.bindData.liveGiftItem.luaClick = self.CreateAction(self, "OnClickLiveGiftItem")
	self.bindData.sendButton.luaClick = self.CreateAction(self, "OnClickSendButton")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnClickExitButton")
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnClickFullScreenButton")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnSimpleClickList")
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputFieldInputValueChanged")
	self.bindData.inputField.onActivateAction = self.CreateAction(self, "OnInputActivate")
	self.bindData.inputField.onDeActivateAction = self.CreateAction(self, "OnInputDeactivate")

	self.InitMessages(self)
end

M.InitMessages = function(self)
	self.RegisterMessageEvents(self, {
		[gEventConstants.ON_SYNC_PARTY_RESPONSE] = self.CreateAction(self, "OnSyncPartyResponse"),
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = self.CreateAction(self, "OnGamePlayOutWardSignal"),
		[gEventConstants.ON_ENTER_CHAR_MOTION_ANIMATION] = self.CreateAction(self, "OnEnterCharMotionAnimation")
	})
end

M.OnShow = function(self, _, args)
	self:InitModel(args)
	self:InitView(args)
	gMessageManager:SendMessage(gEventConstants.MINI_MAP_VISIBILITY_CHANGE, {
		["M\\x90\\x9d\\x8cO"] = "3+2\\xf0j\\xb4\\xfe\"\\xad\\xf2\\xe0\\xe3u\\xf6",
		["\\xcf\\xd2(\\xf4"] = false
	})

	local store = gStoreManager:GetStoreGroup("CoreHudSystemControlStore")

	if store and store.bindData.chatBtn then
		store.bindData.chatBtn:SetActive(false)
	end

	local popupAreaStore = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore")

	if popupAreaStore and popupAreaStore.bindData.popupList then
		popupAreaStore.bindData.popupList:SetActive(false)
	end
end

M.InitModel = function(self, args)
	self.BegAnimationStart = 1600
	self.BegAnimationEnd = 1601
	self.MaxCommentCount = 10
	self.commentList = {}
	self.giftTipsList = {}
	self.pendingCommentQueue = {}
	self.commentDelayCo = nil
	self.popularity = args and args.Popularity or 0
end

M.InitView = function(self, _)
	self.bindData.popularity = self.popularity

	self.bindData.list:SetSimpleList(#self.commentList)

	self.giftPopUpStore = gStoreManager:GetStoreGroup(self.bindData.liveGiftItem.Store):GetStoreByWidget(self.bindData.liveGiftItem)
end

M.OnClickBegLikeButton = function(self)
	if self.inputActive then
		return
	end

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8019)
	self.SendPartyEvent(self, LTConfig.PartyPartyEventConfig.AskForLike)
end

M.OnClickBegGiftButton = function(self)
	if self.inputActive then
		return
	end

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8018)
	self.SendPartyEvent(self, LTConfig.PartyPartyEventConfig.AskForGift)
end

M.OnClickGestureButton = function(self)
	if self.inputActive then
		return
	end

	gPanelManager:CheckShow(gPanelId.CHAR_MOTION_LIST_PANEL)
end

M.OnClickBanCommentButton = function(self)
	if self.inputActive then
		return
	end

	self.bindData.banCommentControl = self.bindData.banCommentControl ~= 0 and 1 or 0
end

M.OnClickLiveGiftItem = function(self)
end

M.OnSimpleRenderListItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.commentList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.isPlayer then
		local headIcon, _ = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
		store.iconId = headIcon
		local playerName = gPlayerManager.infoLogin.bindData.name
		store.comment = ("%s:%s"):format(playerName, data.Message)
	else
		store.iconId = data.iconId
		local nickName = data.nickName
		store.comment = LTConfig.PartyConfig.CommentFormatText:format(nickName, data.message)
		store.blackListButton.luaClick = self:CreateActionWithArgs("OnClickBlackListButton", data.npcId)
	end
end

M.OnClickBlackListButton = function(self, npcId)
	self.CloseBlackList(self, self.currentShowBlackStore)

	if npcId then
		self.SendPartyEvent(self, LTConfig.PartyPartyEventConfig.BlockViewer, npcId)
	end
end

M.CloseBlackList = function(self)
	if self.currentShowBlackStore then
		self.currentShowBlackStore.showBlacklistControl = 1
		self.currentShowBlackStore = nil
	end

	self.bindData.showFullScreenButtonControl = 0
end

M.OnSimpleClickList = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.commentList[luaIndex]

	if data.isPlayer then
		return
	end

	if self.currentShowBlackStore then
		self.currentShowBlackStore.showBlacklistControl = 1
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.showBlacklistControl = 0
	self.currentShowBlackStore = store
	self.bindData.showFullScreenButtonControl = 1
end

M.OnInputFieldInputValueChanged = function(self, text)
end

M.OnInputActivate = function(self)
	self.inputActive = true
end

M.OnInputDeactivate = function(self)
	self.inputActive = false
end

M.ActivateInputField = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.activeInputFieldCo = coroutine.start(function ()
			coroutine.wait(0.2)
			self.bindData.inputField:ActivateInputField()
		end)
	end
end

M.OnSyncPartyResponse = function(self, _, args)
	local response = args.response
	self.bindData.popularity = response.Popularity
	local npcInfoMap = self.BuildNpcInfoMap(self, args.npcIdList)

	self.ProcessGiftList(self, response.giftList, npcInfoMap)
	self.ProcessNpcMessages(self, response.NPCMessage, npcInfoMap)
end

M.BuildNpcInfoMap = function(self, npcIdList)
	local npcInfoMap = {}

	for _, npcInfo in ipairs(npcIdList) do
		local npcId = gFurnitureUtils:ConvertServerUidToNumber(npcInfo.NpcId)

		if not npcInfoMap[npcId] then
			local viewerCfg = LTConfig.PartyLiveViewerConfig.GetConfig(npcInfo.NPCType)
			npcInfo.iconId = viewerCfg and viewerCfg.Image[math.random(#viewerCfg.Image)] or nil
			npcInfoMap[npcId] = npcInfo
		end
	end

	return npcInfoMap
end

M.ProcessGiftList = function(self, giftList, npcInfoMap)
	if not giftList or #giftList ~= 0 then
		return
	end

	for _, npcId in ipairs(giftList) do
		local npcInfo = npcInfoMap[npcId]

		if npcInfo then
			local found = false

			for _, data in ipairs(self.giftTipsList) do
				if data.npcId ~= npcId then
					data.count = data.count + 1
					found = true

					break
				end
			end

			if not found then
				table.insert(self.giftTipsList, {
					["N\\xa1\\xb7\\xa1\\xa2"] = 1,
					npcId = npcId,
					nickName = npcInfo.NickName,
					iconId = npcInfo.iconId
				})
			end
		end
	end

	self.ShowGiftTipsView(self)
end

M.ProcessNpcMessages = function(self, npcMessageList, npcInfoMap)
	npcMessageList = npcMessageList or {}

	if #npcMessageList ~= 0 then
		return
	end

	local commentDataList = {}

	for _, npcMessage in ipairs(npcMessageList) do
		local npcInfo = npcInfoMap[npcMessage.Id]

		if npcInfo then
			table.insert(commentDataList, {
				message = npcMessage.Message,
				nickName = npcInfo.NickName,
				iconId = npcInfo.iconId,
				npcId = npcMessage.Id
			})
		end
	end

	if #commentDataList <= 0 then
		self.ProcessCommentList(self, commentDataList)
	end
end

M.ShowGiftTipsView = function(self)
	if self.bindData.showLiveGiftControl ~= 1 then
		return
	end

	if #self.giftTipsList < 0 then
		self.bindData.showLiveGiftControl = 0
	else
		self.bindData.showLiveGiftControl = 1
		local data = table.remove(self.giftTipsList, 1)
		self.giftPopUpStore.iconId = data.iconId
		self.giftPopUpStore.name = data.nickName
		self.giftPopUpStore.count = data.count
		self.showPopUpGiftTipsCo = coroutine.start(function ()
			coroutine.wait(2.5)

			self.bindData.showLiveGiftControl = 0

			self:ShowGiftTipsView()
		end)
	end
end

M.OnGamePlayOutWardSignal = function(self, _, data)
	local signalId = data.GetCfgId(data)

	if signalId ~= self.BegAnimationStart then
		self.bindData.showBubbleControl = 1
	elseif signalId ~= self.BegAnimationEnd then
		self.bindData.showBubbleControl = 0
	end
end

M.OnEnterCharMotionAnimation = function(self)
	local charMotionStore = gStoreManager:GetStoreGroup("CharMotionListPanelStore")
	local currentPlayActionInfo = charMotionStore.currentPlayActionInfo
	local actionId = currentPlayActionInfo and currentPlayActionInfo.id

	if not actionId then
		return
	end

	local positiveActionList = LTConfig.PartyConfig.PositiveActionList
	local danceActionList = LTConfig.PartyConfig.DanceActionList
	local eventId = nil

	if table.contains(positiveActionList, actionId) then
		eventId = LTConfig.PartyPartyEventConfig.PositiveAction
	elseif table.contains(danceActionList, actionId) then
		eventId = LTConfig.PartyPartyEventConfig.DanceAction
	else
		eventId = LTConfig.PartyPartyEventConfig.AbsurdistAction
	end

	self.SendPartyEvent(self, eventId)
end

local tmpVec = Vector2.zero
local npcNameDisplayOffset = Vector3.New(0, -0.4, 0)

M.OnUpdate = function(self)
	if self.bindData.showBubbleControl ~= 1 then
		if gCS.LuaUtils.IsBaseUnitValid(gCS.MyPlayerManager.PlayerUnit) and gCS.MyPlayerManager.PlayerUnit.HeadSlotPos then
			local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(gCS.MyPlayerManager.PlayerUnit.HeadSlotPos + gCS.MyPlayerManager.PlayerUnit.LocalPosition + npcNameDisplayOffset, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

			tmpVec:Set(x, y)

			self.bindData.bubbleNode.localPosition = gCS.LuaUtils.ScreenPointUI(self.bindData.centerNode, tmpVec)
		end

		self.bindData.playerSelectedNode:SetActive(false)
	end
end

M.OnClickSendButton = function(self)
	local inputValue = self.bindData.inputField.text

	if not self.inputActive and string.is_null_or_empty(inputValue) then
		self.ActivateInputField(self)

		return
	end

	if string.is_null_or_empty(inputValue) then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.PartyConfig.SendCommentEmptyTips)

		return
	end

	local rootGo = self.rootGo
	local comment = inputValue

	gClientUtils.EnvSdkReviewWords(comment, function ()
		slot0 = gClientToGameDelegate

		slot0:SendPartyComment(comment).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			if gClientUtils.NotNil(rootGo) then
				self:AddComment({
					["\\xa2\\xa25\\xa7k'\\xfb!"] = true,
					Message = comment
				})

				self.bindData.inputField.text = ""
			end
		end
	end, function ()
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)
	end, "PartyLive")
end

M.OnClickExitButton = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(LTConfig.MessageConfig.StopParty, function ()
		slot0 = gClientToGameDelegate

		slot0:PartyOver().Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			gPanelManager:Close(gPanelId.PARTY_LIVE_STREAM_PANEL)
		end
	end)
end

M.OnClickFullScreenButton = function(self)
	self.CloseBlackList(self, self.currentShowBlackStore)
end

M.ProcessCommentList = function(self, commentDataList)
	local commentShow = LTConfig.PartyConfig.CommentShow
	local immediateCount = math.min(math.random(commentShow[1], commentShow[2]), #commentDataList)

	for i = 1, immediateCount do
		self.AddComment(self, commentDataList[i])
	end

	for i = immediateCount + 1, #commentDataList do
		self.AddToPendingQueue(self, commentDataList[i])
	end

	if #self.pendingCommentQueue <= 0 then
		self.StartCommentDelayProcess(self)
	end
end

M.AddToPendingQueue = function(self, commentData)
	table.insert(self.pendingCommentQueue, commentData)

	local commentLineMax = LTConfig.PartyConfig.CommentLineMax

	if commentLineMax and commentLineMax >= #self.pendingCommentQueue then
		table.remove(self.pendingCommentQueue, 1)
	end
end

M.StartCommentDelayProcess = function(self)
	if self.commentDelayCo then
		return
	end

	self.commentDelayCo = coroutine.start(function ()
		while #self.pendingCommentQueue <= 0 do
			local delayTime = LTConfig.PartyConfig.CommentShowDelayTime
			local delay = delayTime[1] + (delayTime[2] - delayTime[1]) * math.random()

			coroutine.wait(delay)

			if #self.pendingCommentQueue <= 0 then
				self:AddComment(table.remove(self.pendingCommentQueue, 1))
			end
		end

		self.commentDelayCo = nil
	end)
end

M.AddComment = function(self, data)
	if LTConfig.PartyConfig.MaxCommentNum < #self.commentList then
		table.remove(self.commentList, 1)
	end

	table.insert(self.commentList, data)

	local count = #self.commentList

	self.bindData.list:SetSimpleList(count)
	self.bindData.list:GoToIndex(count - 1, false)
	self:CloseBlackList(self.currentShowBlackStore)
end

M.SendPartyEvent = function(self, eventId, comment)
	slot3 = gClientToGameDelegate

	slot3:SendPartyEvent(eventId, comment).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.OnDestroy = function(self)
	self:ClearMessageEvents()

	self.commentList = nil
	self.giftTipsList = nil
	self.pendingCommentQueue = nil
	self.showPopUpGiftTipsCo = coroutine.stop(self.showPopUpGiftTipsCo)
	self.commentDelayCo = coroutine.stop(self.commentDelayCo)

	LX6.Manager.GameInputManager.SetEnableInput(self.m_Id, true, true, true)
	gMessageManager:SendMessage(gEventConstants.MINI_MAP_VISIBILITY_CHANGE, {
		["M\\x90\\x9d\\x8cO"] = "3+2\\xf0j\\xb4\\xfe\"\\xad\\xf2\\xe0\\xe3u\\xf6",
		["\\xcf\\xd2(\\xf4"] = true
	})

	local store = gStoreManager:GetStoreGroup("CoreHudSystemControlStore")

	if store and store.bindData.chatBtn then
		store.RefreshChatBtnState(store)
	end

	local popupAreaStore = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore")

	if popupAreaStore and popupAreaStore.bindData.popupList then
		popupAreaStore.bindData.popupList:SetActive(false)
	end

	self.activeInputFieldCo = coroutine.stop(self.activeInputFieldCo)
end
