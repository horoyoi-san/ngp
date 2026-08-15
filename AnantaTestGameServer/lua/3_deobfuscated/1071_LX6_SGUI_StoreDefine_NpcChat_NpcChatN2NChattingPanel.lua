C_NpcChatN2NChattingPanel = DefClass("C_NpcChatN2NChattingPanel", C_NpcChatN2NChattingPanel, C_NpcChatChattingPanelStore)
GroupName2Class.NpcChatN2NChattingPanel = C_NpcChatN2NChattingPanel
local M = C_NpcChatN2NChattingPanel
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
	self.phoneCfg = gNpcChatNpcsPhoneManager.phoneCfg
	self.subChannelId = data.subChannelId
	self.isTalkingToPlayer = self.subChannelId == self.phoneCfg.Owner

	M.base.OnShow(self, tabIndex, data)

	if gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		self:SetBasePanelCloseType(CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Hide, self.CustomCloseFunc)
	elseif gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		local firstChatId = self.phoneCfg.ChatList[1]

		if firstChatId then
			local firstChatCfg = LTConfig.NPCChatConfig.GetConfig(firstChatId)

			if firstChatCfg and firstChatCfg.FakeMsgForceRead then
				self._originalCloseTypeInfo = {
					reason = CloseType_Reason.DialogTypeChat,
					closeType = gNpcChatConst.CloseButtonType.Return,
					customCloseFunc = self.CustomCloseFunc
				}

				self:SetBasePanelCloseType(CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Hide, self.CustomCloseFunc)
			else
				self:SetBasePanelCloseType(CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Return, self.CustomCloseFunc)
			end
		else
			self:SetBasePanelCloseType(CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Return, self.CustomCloseFunc)
		end
	end

	gNpcChatUtils.GetBasePanelStore():ShowUid(false)

	if gNpcChatNpcsPhoneManager.isAtmosphereNpc then
		self:OnAtmosphereNpcShow(gNpcChatNpcsPhoneManager.atmosphereNpcInfo, data)
	end
end

function M:AfterAddLastMessage(msg)
	if not self.isTalkingToPlayer then
		M.base.AfterAddLastMessage(self, msg)
	end
end

function M:RefreshNpcChatOptions(msg, gamePlayId)
	local canShowChatOptions = self.subChannelId == gNpcChatNpcsPhoneManager.subChannelId

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
	if gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		if self.subChannelId == gNpcChatNpcsPhoneManager.subChannelId then
			local specialAsNpc = nil
			local cfg = self.data.cfg
			local specialReadableCharacter = cfg and cfg.SpecialReadableCharacter or nil

			if specialReadableCharacter == gNpcChatUtils.GetCurrentNpcId() then
				specialAsNpc = cfg.AsNpcCultivation
			end

			gNpcChatManager:GetAllNpcMessage(self.topChannelId, self.subChannelId, gNpcChatManager.currentNpcChatType, specialAsNpc)
		else
			print_error_without_stack("@zhangzhiyuan NpcChatN2NChattingPanel.RefreshAllMsg: 不支持显示未拉起的 Dialog 类型对话!!!")
		end
	elseif gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Normal then
		M.base.RefreshAllMsg(self)
	elseif gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		M.base.RefreshAllMsg(self)

		local isMind = false
		local otherData = gNpcChatNpcsPhoneManager.otherData

		if otherData and otherData.atmosphereNpcInfo and otherData.atmosphereNpcInfo.npcId and otherData.atmosphereNpcInfo.npcId > 0 then
			isMind = true
		end

		gNpcChatNpcsPhoneManager:AddFakeChatChannelMessages(self.subChannelId, isMind)
	else
		print_error_without_stack("@liulijun04 NpcChatN2NChattingPanel.RefreshAllMsg: not supported chat type", gNpcChatManager.currentNpcChatType)
	end
end

function M:SetHeader()
	if self.isPV then
		M.base.SetHeader(self)

		return
	end

	local realSubChannelId = gRandomChatManager:GetSubChannelId(gNpcChatNpcsPhoneManager.currentChatCfg or gNpcChatNpcsPhoneManager.chatCfg)

	gNpcChatUtils.SetHeader(self.bindData.header, self.isTalkingToPlayer, self.topChannelId, realSubChannelId)
end

function M:OnCloseBtnClick(btnType)
	if gNpcChatNpcsPhoneManager.isAtmosphereNpc then
		gClientUtils.CloseMainPhonePanel()

		return true
	end

	local top, sub = gNpcChatManager:GetCurrentChannel()

	if sub then
		if gNpcChatNpcsPhoneManager.phoneCfg.BackToListAfterDialog then
			if btnType == 0 then
				gNpcChatManager:UpdateCurrentChannel(gNpcChatConst.ChatTopChannel.Npc, nil)
				self.activity:ShowFragment(gNpcChatConst.TabShowType.NpcPhoneChannel)
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
	gNpcChatManager.SkipAll = false

	if gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		self:SetBasePanelCloseType(CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Return, self.CustomCloseFunc)

		local msg = gNpcChatUtils.GetCurrentNpcChannelLastMsg(self.topChannelId, self.subChannelId)
		local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

		if gNpcChatUtils.ShouldAskReadChat(lastChatCfg) then
			gClientToGameDelegate:AskMarkNpcChatRead(msg.npcChatId).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end
			end
		end
	elseif gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake and self._originalCloseTypeInfo then
		self:SetBasePanelCloseType(self._originalCloseTypeInfo.reason, CloseType_ActionType.Set, self._originalCloseTypeInfo.closeType, self._originalCloseTypeInfo.customCloseFunc)

		self._originalCloseTypeInfo = nil
	end

	self:AddFinishedHint()
end

function M:OnRenderChatItem(btn, index)
	M.base.OnRenderChatItem(self, btn, index)

	if #self.chatItemList == index + 1 then
		local phoneManager = gNpcChatNpcsPhoneManager
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
		return NpcChatSenderId.NewNpc(chatItem.msg.NPCid)
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

	sender = NpcChatSenderId.New(chatCfg)

	if sender.pid then
		sender.npcId = owner
		sender.pid = nil
	end

	chatItem.sender = sender

	return sender
end

function M:DoAutoClick(msg)
	if not self.isTalkingToPlayer then
		M.base.DoAutoClick(self, msg)
	end
end

function M:AddFinishedHint(content)
	if gNpcChatNpcsPhoneManager.isAtmosphereNpc then
		if gNpcChatNpcsPhoneManager.atmosphereNpcInfo.actionFalling then
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

	if LTConfig.NPCChatConfig.GetConfig(data.msg.npcChatId).ChatType ~= gNpcChatManager.currentNpcChatType then
		return false
	end

	return true
end

function M:ReceiveNewMessage(msg, skipScroll)
	if gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		skipScroll = true

		if not gNpcChatManager.FakeChatAutoPlay then
			self:UpdateFakeChatContent(msg)

			if not gNpcChatUtils.HasNextMessage(msg) then
				self:OnChatFinish()
			end

			gMessageManager:SendMessage(gEventConstants.NPC_CHAT_FINISH, msg.npcChatId)

			return
		end
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
		self:SetBasePanelCloseType(CloseType_Reason.KeyDialog, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Hide)
	else
		gDialogManager:ShowGeneralDialog(dialogCfg.dialogid, gDialogSource.Chat)
	end
end

function M:SetBasePanelCloseType(reason, actionType, ...)
	if actionType == CloseType_ActionType.Cancel then
		if reason == CloseType_Reason.KeyDialog then
			self._closeTypeInfo[reason] = nil
			local lastCloseTypeInfo = self._closeTypeInfo[CloseType_Reason.DialogTypeChat]

			gNpcChatUtils.SetCloseType(unpack(lastCloseTypeInfo))
		else
			print_error("@liulijun04 NpcChatN2NChattingPanel.SetBasePanelCloseType: not supported actionType", actionType)
		end

		return
	end

	self._closeTypeInfo[reason] = {
		...
	}

	if reason == CloseType_Reason.DialogTypeChat and self._closeTypeInfo[CloseType_Reason.KeyDialog] then
		return
	end

	gNpcChatUtils.SetCloseType(...)
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

function M:OnClickSkillAllBtn()
	if gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		M.base.OnClickSkillAllBtn(self)
	else
		local lastMessage = self.lastMessage

		if lastMessage == nil then
			return
		end

		if #lastMessage.cfg.NextMessage == 0 and lastMessage.npcNextChatId == 0 then
			return
		end

		self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)

		self.cs:EnableNpcChatItemAnim(false)
		self:UpdateChatList(function ()
			self:TryRemoveEllipsisBubble()
			gNpcChatNpcsPhoneManager:AddRestFakeChatChannelMessages(lastMessage.npcChatId)
		end, false)
		self:ScrollTo(0, 0)

		self.bindData.showSkipBtnCtrl = 0

		self:OnChatFinish()
	end
end
