C_PartyLiveStreamPanelStore = DefClass("C_PartyLiveStreamPanelStore", C_PartyLiveStreamPanelStore, C_StoreGroup)
GroupName2Class.PartyLiveStreamPanelStore = C_PartyLiveStreamPanelStore
local M = C_PartyLiveStreamPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.begLikeButton.luaClick = self:CreateAction("OnClickBegLikeButton")
	self.bindData.begGiftButton.luaClick = self:CreateAction("OnClickBegGiftButton")
	self.bindData.gestureButton.luaClick = self:CreateAction("OnClickGestureButton")
	self.bindData.banCommentButton.luaClick = self:CreateAction("OnClickBanCommentButton")
	self.bindData.liveGiftItem.luaClick = self:CreateAction("OnClickLiveGiftItem")
	self.bindData.sendButton.luaClick = self:CreateAction("OnClickSendButton")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self:CreateAction("OnSimpleClickList")
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputFieldInputValueChanged")

	self:InitMessages()
end

function M:InitMessages()
	self:RegisterMessageEvents({
		[gEventConstants.ON_SYNC_PARTY_RESPONSE] = self:CreateAction("OnSyncPartyResponse"),
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = self:CreateAction("OnGamePlayOutWardSignal")
	})
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(_)
	self.BegAnimationStart = 1600
	self.BegAnimationEnd = 1601
	self.MaxCommentCount = 10
	self.commentList = {}
	self.giftTipsList = {}
end

function M:InitView(_)
	self.bindData.popularity = 0

	self.bindData.list:SetSimpleList(#self.commentList)

	self.giftPopUpStore = gStoreManager:GetStoreGroup(self.bindData.liveGiftItem.Store):GetStoreByWidget(self.bindData.liveGiftItem)
end

function M:OnClickBegLikeButton()
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.PartyBegLike)
end

function M:OnClickBegGiftButton()
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.PartyBegGift)
end

function M:OnClickGestureButton()
	gPanelManager:CheckShow(gPanelId.CHAR_MOTION_LIST_PANEL)
end

function M:OnClickBanCommentButton()
	self.bindData.banCommentControl = self.bindData.banCommentControl == 0 and 1 or 0
end

function M:OnClickLiveGiftItem()
	return
end

function M:OnSimpleRenderListItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.commentList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.isPlayer then
		local headIcon, _ = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
		store.iconId = headIcon
		local playerName = gPlayerManager.infoLogin.bindData.name
		store.comment = ("%s:%s"):format(playerName, data.Message)
	else
		local npcId = data.Id
		local cultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)
		store.iconId = cultivationCfg.SChatHeadId
		store.comment = LTConfig.PartyConfig.CommentFormatText:format(cultivationCfg.Name, data.Message)
	end
end

function M:OnSimpleClickList(btn, index)
	return
end

function M:OnInputFieldInputValueChanged(text)
	return
end

function M:OnSyncPartyResponse(_, args)
	local response = args.response
	self.bindData.popularity = response.Popularity

	if response.giftList and #response.giftList > 0 then
		for _, npcId in ipairs(response.giftList) do
			local found = false

			for _, data in ipairs(self.giftTipsList) do
				if data.npcId == npcId then
					data.count = data.count + 1
					found = true

					break
				end
			end

			if not found then
				table.insert(self.giftTipsList, {
					count = 1,
					npcId = npcId
				})
			end
		end

		self:ShowGiftTipsView()
	end

	local npcMessageList = response.NPCMessage or {}

	if #npcMessageList > 0 then
		for _, npcMessage in ipairs(npcMessageList) do
			self:AddComment(npcMessage)
		end
	end
end

function M:ShowGiftTipsView()
	if self.bindData.showLiveGiftControl == 1 then
		return
	end

	if #self.giftTipsList <= 0 then
		self.bindData.showLiveGiftControl = 0
	else
		self.bindData.showLiveGiftControl = 1
		local data = table.remove(self.giftTipsList, 1)
		local npcId = data.npcId
		local cultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)
		self.giftPopUpStore.name = cultivationCfg.Name
		self.giftPopUpStore.iconId = cultivationCfg.SChatHeadId
		self.giftPopUpStore.count = data.count
		self.showPopUpGiftTipsCo = coroutine.start(function ()
			coroutine.wait(2.5)

			self.bindData.showLiveGiftControl = 0

			self:ShowGiftTipsView()
		end)
	end
end

function M:OnGamePlayOutWardSignal(_, data)
	local signalId = data:GetCfgId()

	if signalId == self.BegAnimationStart then
		self.bindData.showBubbleControl = 1
	elseif signalId == self.BegAnimationEnd then
		self.bindData.showBubbleControl = 0
	end
end

local tmpVec = Vector2.zero
local npcNameDisplayOffset = Vector3.New(0, -0.4, 0)

function M:OnUpdate()
	if self.bindData.showBubbleControl == 1 then
		if gCS.MyPlayerManager.PlayerUnit and not gCS.MyPlayerManager.PlayerUnit.IsDestroyed and gCS.MyPlayerManager.PlayerUnit.HeadSlotPos then
			local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(gCS.MyPlayerManager.PlayerUnit.HeadSlotPos + gCS.MyPlayerManager.PlayerUnit.LocalPosition + npcNameDisplayOffset, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

			tmpVec:Set(x, y)

			self.bindData.bubbleNode.localPosition = gCS.LuaUtils.ScreenPointUI(self.bindData.centerNode, tmpVec)
		end

		self.bindData.playerSelectedNode:SetActive(false)
	end
end

function M:OnClickSendButton()
	if string.is_null_or_empty(self.bindData.inputField.text) then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.PartyConfig.SendCommentEmptyTips)

		return
	end

	local rootGo = self.rootGo
	local comment = self.bindData.inputField.text

	gClientUtils.EnvSdkReviewWords(comment, function ()
		gClientToGameDelegate:SendPartyComment(comment).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			if gClientUtils.NotNil(rootGo) then
				self:AddComment({
					isPlayer = true,
					Message = comment
				})
			end
		end
	end, function ()
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)
	end, "PartyLive")
end

function M:AddComment(data)
	if self.MaxCommentCount <= #self.commentList then
		table.remove(self.commentList, 1)
	end

	table.insert(self.commentList, data)

	local count = #self.commentList

	self.bindData.list:SetSimpleList(count)
	self.bindData.list:GoToIndex(count - 1, false)
end

function M:OnDestroy()
	self:ClearMessageEvents()

	self.commentList = nil
	self.giftTipsList = nil
	self.showPopUpGiftTipsCo = coroutine.stop(self.showPopUpGiftTipsCo)
end
