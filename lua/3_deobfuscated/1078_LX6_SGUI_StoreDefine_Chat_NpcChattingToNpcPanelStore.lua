C_NpcChattingToNpcPanelStore = DefClass("C_NpcChattingToNpcPanelStore", C_NpcChattingToNpcPanelStore, C_ChattingToNpcPanelStore)
GroupName2Class.NpcChattingToNpcPanelStore = C_NpcChattingToNpcPanelStore
local M = C_NpcChattingToNpcPanelStore
local CloseType_Reason = {
	DialogTypeChat = 1,
	KeyDialog = 2
}
local CloseType_ActionType = {
	Set = 1,
	Cancel = 2
}

function M:ctor()
	self.CustomCloseFunc = self:CreateAction(self.OnCloseBtnClick)
end

function M:OnShow(tabIndex, data)
	self.isPV = (gGmUtils or {}).stealPhoneMode == 1
	self._closeTypeInfo = {}
	self.phoneCfg = gChatNpcsPhoneManager.phoneCfg
	self.subChannelId = data.subChannelId
	self.isTalkingToPlayer = self.subChannelId == self.phoneCfg.Owner

	M.base.OnShow(self, tabIndex, data)

	if gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		local blockClose = gChatNpcsPhoneManager.mainDialog == nil
		local closeType = blockClose and gChatConst.CloseButtonType.Hide or gChatConst.CloseButtonType.Return

		self:SetBasePanelCloseType(CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, closeType, self.CustomCloseFunc)
	elseif gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		self:SetBasePanelCloseType(CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gChatConst.CloseButtonType.Return, self.CustomCloseFunc)
	end

	gChatUtils.GetBasePanelStore():ShowUid(false)

	if gChatNpcsPhoneManager.isAtmosphereNpc then
		self:OnAtmosphereNpcShow(gChatNpcsPhoneManager.atmosphereNpcInfo, data)
	end
end

function M:AfterAddLastMessage(msg)
	if not self.isTalkingToPlayer then
		M.base.AfterAddLastMessage(self, msg)
	end
end

function M:RefreshNpcChatOptions(msg, gamePlayId)
	local canShowChatOptions = self.subChannelId == gChatNpcsPhoneManager.subChannelId

	if canShowChatOptions then
		M.base.RefreshNpcChatOptions(self, msg, gamePlayId)
	else
		self:ShowBottom(false)
	end
end

function M:OnClickChatBG()
	if not self.isTalkingToPlayer then
		M.base.OnClickChatBG(self)
	end
end

function M:OnClose()
	gDialogManager:CloseDialog()
	M.base.OnClose(self)
end

function M:RefreshAllMsg()
	if gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		if self.subChannelId == gChatNpcsPhoneManager.subChannelId then
			if gChatNpcsPhoneManager.mainDialog then
				for _, v in ipairs(gChatNpcsPhoneManager.mainDialog) do
					gDialogMainChatManager:ShowNpcNewChat(v, true)
				end
			else
				gDialogMainChatManager:GetAllNpcMessage(self.topChannelId, self.subChannelId, gChatManager.currentNpcChatType)
			end
		else
			print_error_without_stack("@liulijun04 NpcChattingToNpcPanelStore.RefreshAllMsg: 不支持显示未拉起的 Dialog 类型对话!!!")
		end
	elseif gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Normal then
		C_ChattingToNpcPanelStore.base.RefreshAllMsg(self)
	elseif gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		C_ChattingToNpcPanelStore.base.RefreshAllMsg(self)
		gChatNpcsPhoneManager:AddFakeChatChannelMessages(self.subChannelId)
	else
		print_error_without_stack("@liulijun04 NpcChattingToNpcPanelStore.RefreshAllMsg: not supported chat type", gChatManager.currentNpcChatType)
	end
end

function M:SetHeader()
	if self.isPV then
		M.base.SetHeader(self)

		return
	end

	local realSubChannelId = gRandomChatManager:GetSubChannelId(gChatNpcsPhoneManager.currentChatCfg or gChatNpcsPhoneManager.chatCfg)

	gChatUtils.SetHeader(self.bindData.header, self.isTalkingToPlayer, self.topChannelId, realSubChannelId)
end

function M:OnCloseBtnClick(btnType)
	if gChatNpcsPhoneManager.isAtmosphereNpc then
		gClientUtils.CloseMainPhonePanel()

		return true
	end

	local top, sub = gChatManager:GetCurrentChannel()

	if sub then
		if gChatNpcsPhoneManager.phoneCfg.BackToListAfterDialog then
			if btnType == 0 then
				gChatManager:UpdateCurrentChannel(gChatTopChannel.Npc)
				self.activity:ShowFragment(gChatConst.TabShowType.NpcPhoneChannel)
			else
				gClientUtils.CloseMainPhonePanel()
			end

			return true
		else
			gClientUtils.CloseMainPhonePanel()

			return true
		end
	end

	return false
end

function M:OnChatFinish()
	if gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		local list = gDialogMainChatManager:GetNpcChatItems(self.topChannelId, self.subChannelId, gChatManager.currentNpcChatType)

		self:SetBasePanelCloseType(CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gChatConst.CloseButtonType.Return, self.CustomCloseFunc)

		if gChatNpcsPhoneManager.mainDialog == nil then
			gChatNpcsPhoneManager.mainDialog = gUtils:ShallowCopy(list)
		end
	end

	self:AddFinishedHint()
end

function M:OnRenderChatItem(btn, index)
	M.base.OnRenderChatItem(self, btn, index)

	if #self.chatItemList == index + 1 then
		local phoneManager = gChatNpcsPhoneManager
		local dialogCfg = nil

		if self.subChannelId == phoneManager.subChannelId then
			dialogCfg = self.phoneCfg.Dialog[#self.phoneCfg.Dialog]
		else
			dialogCfg = phoneManager.subChannelId2DialogCfg[self.subChannelId]
		end

		if not table.isNilOrEmpty(dialogCfg) and not phoneManager.dialogPlayed[self.subChannelId] then
			self:PV_ShowGameplayDialog(dialogCfg)

			phoneManager.dialogPlayed[self.subChannelId] = true
		end
	end
end

function M:GetSender(index)
	local chatItem = self.chatItemList[index]

	if chatItem == nil then
		return nil
	end

	if chatItem.msg.ShowAsReceiver then
		return ChatSenderId.NewNpc(chatItem.msg.NPCid)
	end

	local owner = self.phoneCfg.Owner

	if self.subChannelId == owner then
		return M.base.GetSender(self, index)
	end

	local chatCfg = LTConfig.NPCChatConfig.GetConfig(chatItem.msg.npcChatId)
	local sender = chatItem.sender

	if sender then
		return sender
	end

	sender = ChatSenderId.New(chatCfg)

	if sender.pid then
		sender.npcId = owner
		sender.pid = nil
	end

	chatItem.sender = sender

	return sender
end

function M:AddViewItem(msg, bubblePos)
	bubblePos = self:TryRevertBubblePos(bubblePos)

	M.base.AddViewItem(self, msg, bubblePos)
end

function M:AddCustomViewItem(customData, msgType, bubblePos)
	bubblePos = self:TryRevertBubblePos(bubblePos)

	M.base.AddCustomViewItem(self, customData, msgType, bubblePos)
end

function M:TryRevertBubblePos(bubblePos)
	if self.isTalkingToPlayer then
		if bubblePos == "Left" then
			bubblePos = "Right"
		elseif bubblePos == "Right" then
			bubblePos = "Left"
		end
	end

	return bubblePos
end

function M:DoAutoClick(msg)
	if not self.isTalkingToPlayer then
		M.base.DoAutoClick(self, msg)
	end
end

function M:AddFinishedHint(content)
	if gChatNpcsPhoneManager.isAtmosphereNpc then
		if gChatNpcsPhoneManager.atmosphereNpcInfo.actionFalling then
			content = LTConfig.NPCChatConfig.CallFinishHint
		else
			content = LTConfig.NPCChatConfig.ChatFinishHint
		end
	end

	M.base.AddFinishedHint(self, content)
end

function M:OnChatMessageChanged_CheckIsCurrentChannel(data)
	if self.topChannelId ~= data.topChannelId or not data.msg then
		return false
	end

	if gChatUtils.IsStoryChannel(self.topChannelId) and LTConfig.NPCChatConfig.GetConfig(data.msg.npcChatId).ChatType ~= gChatManager.currentNpcChatType then
		return false
	end

	return true
end

function M:ReceiveNewMessage(msg, skipScroll)
	if gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		skipScroll = true
	end

	M.base.ReceiveNewMessage(self, msg, skipScroll)
end

function M:PV_ShowGameplayDialog(dialogCfg)
	local function OnDialogFinish(id, _, state, _)
		if state == 0 then
			self:SetBasePanelCloseType(CloseType_Reason.KeyDialog, CloseType_ActionType.Cancel)
		end
	end

	if dialogCfg.key then
		gDialogManager:ShowGeneralDialog(dialogCfg.dialogid, gDialogSource.Chat, nil, nil, OnDialogFinish)
		self:SetBasePanelCloseType(CloseType_Reason.KeyDialog, CloseType_ActionType.Set, gChatConst.CloseButtonType.Hide)
	else
		gDialogManager:ShowGeneralDialog(dialogCfg.dialogid, gDialogSource.Chat)
	end
end

function M:SetBasePanelCloseType(reason, actionType, ...)
	if actionType == CloseType_ActionType.Cancel then
		if reason == CloseType_Reason.KeyDialog then
			self._closeTypeInfo[reason] = nil
			local lastCloseTypeInfo = self._closeTypeInfo[CloseType_Reason.DialogTypeChat]

			gChatUtils.SetCloseType(unpack(lastCloseTypeInfo))
		else
			print_error("@liulijun04 NpcChattingToNpcPanelStore.SetBasePanelCloseType: not supported actionType", actionType)
		end

		return
	end

	self._closeTypeInfo[reason] = {
		...
	}

	if reason == CloseType_Reason.DialogTypeChat and self._closeTypeInfo[CloseType_Reason.KeyDialog] then
		return
	end

	gChatUtils.SetCloseType(...)
end

function M:OnAtmosphereNpcShow(atmosphereNpcInfo, showData)
	local behaviorType = atmosphereNpcInfo.behaviorType
	local DropItemsBehaviorType = LX6.Units.DropItemsBehaviorType
	local itemId = ulong.tostring(atmosphereNpcInfo.destructibleInstanceId)

	if behaviorType == DropItemsBehaviorType.Attack then
		self:SetRandomImageMask(LTConfig.NPCChatConfig.NpcsPhoneScreenAttack, itemId)
	elseif behaviorType == DropItemsBehaviorType.StrongCollision then
		self:SetRandomImageMask(LTConfig.NPCChatConfig.NpcsPhoneScreenStrongCollision, itemId)
	elseif behaviorType == DropItemsBehaviorType.LittleCollision then
		self:SetRandomImageMask(LTConfig.NPCChatConfig.NpcsPhoneScreenLittleCollision, itemId)
	elseif behaviorType == DropItemsBehaviorType.BeTrapped then
		self:SetRandomImageMask(LTConfig.NPCChatConfig.NpcsPhoneScreenBeTrapped, itemId)
	elseif behaviorType == DropItemsBehaviorType.ScaredByAction then
		self:SetRandomImageMask(LTConfig.NPCChatConfig.NpcsPhoneScreenAttackScaredByAction, itemId)
	end
end

function M:SetRandomImageMask(config, itemId)
	local imageId = gRandomChatManager:GetRandomImageId(config, itemId)
	local image = LTConfig.SguiImageConfig.GetConfig(imageId)
	local path = image and image.ImgPath
	self.bindData.imageMask = path
end
