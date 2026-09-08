-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatN2NChattingPanel.lua
-- Decompiled from: 02085_NpcChatN2NChattingPanel.lua_96f95ba24c57.luajit

C_NpcChatN2NChattingPanel = DefClass("C_NpcChatN2NChattingPanel", C_NpcChatN2NChattingPanel, C_NpcChatChattingPanelStore)
GroupName2Class.NpcChatN2NChattingPanel = C_NpcChatN2NChattingPanel
local M = C_NpcChatN2NChattingPanel
local CloseType_Reason = {
	["Ó\\xe0\\xd2\\xfa\\x8dΊ!<"] = 1,
	["hBuMG?"] = 2
}
local CloseType_ActionType = {
	["\\xbdmr"] = 1,
	["?I\\x9f\\x8d\\x86M"] = 2
}

local GetSubChannelId = function(chatCfg)
	if chatCfg ~= nil then
		return nil
	end

	if chatCfg.ChatGroup <= 0 then
		return chatCfg.ChatGroup
	end

	while chatCfg.ShowAsReceiver do
		local nextMessage = chatCfg.NextMessage[1]

		if nextMessage then
			chatCfg = LTConfig.NPCChatConfig.GetConfig(nextMessage)
		else
			return nil
		end
	end

	return chatCfg.NPCid
end

local GetRandomImageId = function(config)
	if not config or #config ~= 0 then
		return 0
	end

	local p = math.random()

	for _, v in ipairs(config) do
		p = p - v.Probability

		if p < 0 then
			return v.NpcsPhoneImageId
		end
	end

	return 0
end

M.ctor = function(self)
	self.CustomCloseFunc = self.CreateAction(self, self.OnCloseBtnClick)
end

M.OnShow = function(self, tabIndex, data)
	self.isPV = (gGmUtils or {}).stealPhoneMode ~= 1
	self._closeTypeInfo = {}
	self.phoneCfg = gNpcChatNpcsPhoneManager.phoneCfg
	self.subChannelId = data.subChannelId
	self.isTalkingToPlayer = self.subChannelId ~= self.phoneCfg.Owner

	M.base.OnShow(self, tabIndex, data)

	if gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		self.SetBasePanelCloseType(self, CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Hide, self.CustomCloseFunc)
	elseif gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
		local firstChatId = self.phoneCfg.ChatList[1]

		if firstChatId ~= gNpcChatNpcsPhoneManager.uncompletedFakeChat then
			gNpcChatNpcsPhoneManager.uncompletedFakeChat = nil
		end

		if firstChatId then
			local firstChatCfg = LTConfig.NPCChatConfig.GetConfig(firstChatId)

			if firstChatCfg and firstChatCfg.FakeMsgForceRead then
				self._originalCloseTypeInfo = {
					reason = CloseType_Reason.DialogTypeChat,
					closeType = gNpcChatConst.CloseButtonType.Return,
					customCloseFunc = self.CustomCloseFunc
				}

				self.SetBasePanelCloseType(self, CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Hide, self.CustomCloseFunc)
			else
				self.SetBasePanelCloseType(self, CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Return, self.CustomCloseFunc)
			end
		else
			self.SetBasePanelCloseType(self, CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Return, self.CustomCloseFunc)
		end
	end

	gNpcChatUtils.GetBasePanelStore():ShowUid(false)

	if gNpcChatNpcsPhoneManager.isAtmosphereNpc then
		self.OnAtmosphereNpcShow(self, gNpcChatNpcsPhoneManager.atmosphereNpcInfo, data)
	end
end

M.AfterAddLastMessage = function(self, msg)
	if not self.isTalkingToPlayer then
		M.base.AfterAddLastMessage(self, msg)
	end
end

M.RefreshNpcChatOptions = function(self, msg, gamePlayId)
	local canShowChatOptions = self.subChannelId ~= gNpcChatNpcsPhoneManager.subChannelId

	if canShowChatOptions then
		M.base.RefreshNpcChatOptions(self, msg, gamePlayId)
	else
		self.ShowBottom(self, false)
	end
end

M.OnClickChatBG = function(self)
	if not self.isTalkingToPlayer then
		M.base.OnClickChatBG(self)
	end
end

M.OnClose = function(self)
	gDialogManager:CloseDialog()
	M.base.OnClose(self)
end

M.RefreshAllMsg = function(self)
	if gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		if self.subChannelId ~= gNpcChatNpcsPhoneManager.subChannelId then
			local specialAsNpc = nil
			local cfg = self.data.cfg
			local specialReadableCharacter = cfg and cfg.SpecialReadableCharacter or nil

			if specialReadableCharacter ~= gNpcChatUtils.GetCurrentNpcId() then
				specialAsNpc = cfg.AsNpcCultivation
			end

			gNpcChatManager:GetAllNpcMessage(self.topChannelId, self.subChannelId, gNpcChatManager.currentNpcChatType, specialAsNpc)
		else
			print_error_without_stack("@zhangzhiyuan NpcChatN2NChattingPanel.RefreshAllMsg: 不支持显示未拉起的 Dialog 类型对话!!!")
		end
	elseif gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Normal then
		M.base.RefreshAllMsg(self)
	elseif gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
		M.base.RefreshAllMsg(self)

		local isMind = false
		local otherData = gNpcChatNpcsPhoneManager.otherData

		if otherData and otherData.atmosphereNpcInfo and otherData.atmosphereNpcInfo.npcId and otherData.atmosphereNpcInfo.npcId <= 0 then
			isMind = true
		end

		gNpcChatNpcsPhoneManager:AddFakeChatChannelMessages(self.subChannelId, isMind)
	else
		print_error_without_stack("@zhangzhiyuan06 NpcChatN2NChattingPanel.RefreshAllMsg: not supported chat type", gNpcChatManager.currentNpcChatType)
	end
end

M.SetHeader = function(self)
	if self.isPV then
		M.base.SetHeader(self)

		return
	end

	local realSubChannelId = GetSubChannelId(gNpcChatNpcsPhoneManager.currentChatCfg or gNpcChatNpcsPhoneManager.chatCfg)

	gNpcChatUtils.SetHeader(self.bindData.header, self.isTalkingToPlayer, self.topChannelId, realSubChannelId)
end

M.OnCloseBtnClick = function(self, btnType)
	if gNpcChatNpcsPhoneManager.isAtmosphereNpc then
		gClientUtils.CloseMainPhonePanel()

		return true
	end

	local top, sub = gNpcChatManager:GetCurrentChannel()

	if sub then
		if gNpcChatNpcsPhoneManager.phoneCfg.BackToListAfterDialog then
			if btnType ~= 0 then
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

M.OnChatFinish = function(self)
	gNpcChatManager.SkipAll = false

	if gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		self.SetBasePanelCloseType(self, CloseType_Reason.DialogTypeChat, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Return, self.CustomCloseFunc)

		local msg = gNpcChatUtils.GetCurrentNpcChannelLastMsg(self.topChannelId, self.subChannelId)
		local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

		if gNpcChatUtils.ShouldAskReadChat(lastChatCfg) then
			slot3 = gClientToGameDelegate

			slot3:AskMarkNpcChatRead(msg.npcChatId).Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end
			end
		end
	elseif gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake and self._originalCloseTypeInfo then
		self.SetBasePanelCloseType(self, self._originalCloseTypeInfo.reason, CloseType_ActionType.Set, self._originalCloseTypeInfo.closeType, self._originalCloseTypeInfo.customCloseFunc)

		self._originalCloseTypeInfo = nil
	end

	self.AddFinishedHint(self)
end

M.OnRenderChatItem = function(self, btn, index)
	M.base.OnRenderChatItem(self, btn, index)

	if #self.chatItemList ~= index + 1 then
		local phoneManager = gNpcChatNpcsPhoneManager
		local dialogCfg = nil

		if self.subChannelId ~= phoneManager.subChannelId then
			dialogCfg = self.phoneCfg.Dialog[#self.phoneCfg.Dialog]
		else
			dialogCfg = phoneManager.subChannelId2DialogCfg[self.subChannelId]
		end

		if not table.isNilOrEmpty(dialogCfg) and not phoneManager.dialogPlayed[self.subChannelId] then
			self.PV_ShowGameplayDialog(self, dialogCfg)

			phoneManager.dialogPlayed[self.subChannelId] = true
		end
	end
end

M.GetSender = function(self, index)
	local chatItem = self.chatItemList[index]

	if chatItem ~= nil then
		return nil
	end

	if chatItem.msg.ShowAsReceiver then
		return NpcChatSenderId.NewNpc(chatItem.msg.NPCid)
	end

	local owner = self.phoneCfg.Owner

	if self.subChannelId ~= owner then
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

M.DoAutoClick = function(self, msg)
	if not self.isTalkingToPlayer then
		M.base.DoAutoClick(self, msg)
	end
end

M.AddFinishedHint = function(self, content)
	if gNpcChatNpcsPhoneManager.isAtmosphereNpc then
		if gNpcChatNpcsPhoneManager.atmosphereNpcInfo.actionFalling then
			content = LTConfig.NPCChatConfig.CallFinishHint
		else
			content = LTConfig.NPCChatConfig.ChatFinishHint
		end
	end

	M.base.AddFinishedHint(self, content)
end

M.OnChatMessageChanged_CheckIsCurrentChannel = function(self, data)
	if self.topChannelId == data.topChannelId or not data.msg then
		return false
	end

	if LTConfig.NPCChatConfig.GetConfig(data.msg.npcChatId).ChatType == gNpcChatManager.currentNpcChatType then
		return false
	end

	return true
end

M.ReceiveNewMessage = function(self, msg, skipScroll)
	if gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
		skipScroll = true

		if not gNpcChatManager.FakeChatAutoPlay then
			self.UpdateFakeChatContent(self, msg)

			if not gNpcChatUtils.HasNextMessage(msg) then
				self.OnChatFinish(self)
			end

			gMessageManager:SendMessage(gEventConstants.NPC_CHAT_FINISH, msg.npcChatId)

			return
		end
	end

	M.base.ReceiveNewMessage(self, msg, skipScroll)
end

M.PV_ShowGameplayDialog = function(self, dialogCfg)
	local OnDialogFinish = function(id, _, state, _)
		if state ~= 0 then
			self:SetBasePanelCloseType(CloseType_Reason.KeyDialog, CloseType_ActionType.Cancel)
		end
	end

	if dialogCfg.key then
		gDialogManager:ShowGeneralDialog(dialogCfg.dialogid, gDialogSource.Chat, nil, , OnDialogFinish)
		self:SetBasePanelCloseType(CloseType_Reason.KeyDialog, CloseType_ActionType.Set, gNpcChatConst.CloseButtonType.Hide)
	else
		gDialogManager:ShowGeneralDialog(dialogCfg.dialogid, gDialogSource.Chat)
	end
end

M.SetBasePanelCloseType = function(self, reason, actionType, ...)
	if actionType ~= CloseType_ActionType.Cancel then
		if reason ~= CloseType_Reason.KeyDialog then
			self._closeTypeInfo[reason] = nil
			local lastCloseTypeInfo = self._closeTypeInfo[CloseType_Reason.DialogTypeChat]

			gNpcChatUtils.SetCloseType(unpack(lastCloseTypeInfo))
		else
			print_error("@zhangzhiyuan06 NpcChatN2NChattingPanel.SetBasePanelCloseType: not supported actionType", actionType)
		end

		return
	end

	self._closeTypeInfo[reason] = {
		...
	}

	if reason ~= CloseType_Reason.DialogTypeChat and self._closeTypeInfo[CloseType_Reason.KeyDialog] then
		return
	end

	gNpcChatUtils.SetCloseType(...)
end

M.OnAtmosphereNpcShow = function(self, atmosphereNpcInfo, showData)
	local behaviorType = atmosphereNpcInfo.behaviorType
	local DropItemsBehaviorType = LX6.Units.DropItemsBehaviorType
	local itemId = ulong.tostring(atmosphereNpcInfo.destructibleInstanceId)

	if behaviorType ~= DropItemsBehaviorType.Attack then
		self.SetRandomImageMask(self, LTConfig.NPCChatConfig.NpcsPhoneScreenAttack, itemId)
	elseif behaviorType ~= DropItemsBehaviorType.StrongCollision then
		self.SetRandomImageMask(self, LTConfig.NPCChatConfig.NpcsPhoneScreenStrongCollision, itemId)
	elseif behaviorType ~= DropItemsBehaviorType.LittleCollision then
		self.SetRandomImageMask(self, LTConfig.NPCChatConfig.NpcsPhoneScreenLittleCollision, itemId)
	elseif behaviorType ~= DropItemsBehaviorType.BeTrapped then
		self.SetRandomImageMask(self, LTConfig.NPCChatConfig.NpcsPhoneScreenBeTrapped, itemId)
	elseif behaviorType ~= DropItemsBehaviorType.ScaredByAction then
		self.SetRandomImageMask(self, LTConfig.NPCChatConfig.NpcsPhoneScreenAttackScaredByAction, itemId)
	end
end

M.SetRandomImageMask = function(self, config, itemId)
	local imageId = GetRandomImageId(config)
	local path = gUIUtils:GetSguiImagePath(imageId)
	self.bindData.imageMask = path
end

M.OnClickSkillAllBtn = function(self)
	if gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		M.base.OnClickSkillAllBtn(self)
	else
		local lastMessage = self.lastMessage

		if lastMessage ~= nil then
			return
		end

		if #lastMessage.cfg.NextMessage ~= 0 and lastMessage.npcNextChatId ~= 0 then
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
