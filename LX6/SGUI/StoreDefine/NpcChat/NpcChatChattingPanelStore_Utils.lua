-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatChattingPanelStore_Utils.lua
-- Decompiled from: 01957_NpcChatChattingPanelStore_Utils.lua_a59ff12192bb.luajit

local M = C_NpcChatChattingPanelStore

M.ClearChatItems = function(self)
	self.chatItemList = {}

	if gClientUtils.NotNil(self.chatList) then
		self.chatList:SetList(0, false, 0)
	end

	self.needClickItem = {}
end

M.ScrollToTop = function(self)
	self.ScrollTo(self, 0, 1)
end

M.ScrollToBottom = function(self, instant)
	if not gClientUtils.NotNil(self.chatList) then
		return
	end

	if instant then
		self.chatList:SetList(#self.chatItemList, false, 0)
		self:ScrollTo(0, 0)

		return
	end

	if #self.chatItemList ~= 0 then
		self.ScrollTo(self, 0, 0)

		return
	end

	if not self.cs then
		print_error("@zhangzhiyuan06 NpcChatChattingPanelStore_Utils.ScrollToBottom: Warning - self.cs is nil!")

		return
	end

	if self.cs.isScrolling then
		print_error("@zhangzhiyuan06 NpcChatChattingPanelStore_Utils.ScrollToBottom: Warning - 正在滚动，跳过")

		return
	end

	if self.chatList.VirtualEndIndex ~= -1 then
		return
	end

	self.cs:ScrollBottomToPos(0)
end

M.ScrollTo = function(self, x, y)
	if gClientUtils.NotNil(self.chatList) then
		self.chatList.normalizedScrollPosition = Vector2.Fetch(x, y)
	end
end

M.SetListData = function(self)
	if gClientUtils.NotNil(self.chatList) then
		self.chatList:SetList(#self.chatItemList, false, 0)
	end
end

M.UpdateFakeChatContent = function(self, msg)
	self.inUpdateChatList = true

	self.AddNewChatMessage(self, msg)
	self.AfterAddMessage(self, msg)
	self.ShowBottom(self, false)

	self.inUpdateChatList = false
end

M.UpdateChatContent = function(self, msg)
	self.inUpdateChatList = true

	self.AddNewChatMessage(self, msg)
	self.ShowBottom(self, false)

	self.inUpdateChatList = false
end

M.UpdateChatList = function(self, updateFunction, keepPosition, msg)
	if not gClientUtils.NotNil(self.chatList) then
		return
	end

	if self.inUpdateChatList and msg then
		updateFunction()

		return
	end

	self.inUpdateChatList = true
	local itemsCountOld = #self.chatItemList
	local list = self.chatList

	if keepPosition then
		local startIndexOld = list.VirtualStartIndex
		local endIndexOld = list.VirtualEndIndex

		if endIndexOld + 1 ~= itemsCountOld then
			if startIndexOld > 0 then
				self.cs:LogItemPositionAtIndex(startIndexOld)
			end

			updateFunction()

			if self.chatList.enabledVirtual then
				list.SetListAndGenerateLayoutRange(list, #self.chatItemList, startIndexOld, #self.chatItemList - 1)

				if startIndexOld > 0 then
					self.cs:ResumeItemPositionAtIndex(startIndexOld)
				end
			elseif LTConfig.NPCChatConfig.ChatTypeType.Fake ~= gNpcChatManager.currentNpcChatType then
				list.SetList(list, #self.chatItemList, false, 0)
			else
				print_debug("@zhangzhiyuan06 关闭虚拟化的情况不应调用 SetListAndGenerateLayoutRange!", "top", self.topChannelId, "sub", self.subChannelId, "len", #self.chatItemList, "last", self.lastMessage and self.lastMessage.npcChatId, "debugLog", self.debugLog)
			end
		elseif startIndexOld ~= -1 and endIndexOld ~= -1 then
			updateFunction()
			list.SetList(list, #self.chatItemList, false, 0)
		else
			updateFunction()
			list.SetDataCountNoRefresh(list, #self.chatItemList)
		end
	else
		updateFunction()

		local itemsCountNew = #self.chatItemList
		local headInsertCount = itemsCountNew - itemsCountOld

		list.SetList(list, #self.chatItemList, keepPosition, headInsertCount)
	end

	self.inUpdateChatList = false
end

M.AddItemToList = function(self, itemData)
	if not self.inUpdateChatList then
		print_error("ChatChattingPanel: AddItemToList should be called in UpdateChatList!")
	end

	table.insert(self.chatItemList, itemData)
end

M.RemoveLastItem = function(self)
	if not self.inUpdateChatList then
		print_error("ChatChattingPanel: RemoveLastItem should be called in UpdateChatList!")
	end

	table.remove(self.chatItemList)
end

M.RemoveSpecificItem = function(self)
	if not self.inUpdateChatList then
		print_error("ChatChattingPanel: RemoveLastItem should be called in UpdateChatList!")
	end

	for i = #self.chatItemList, 1, -1 do
		if self.chatItemList[i].canRemove then
			table.remove(self.chatItemList, i)

			break
		end
	end
end

M.CacheInteractiveChatItemWidget = function(self, rootWidget)
	if not table.find(self.interactiveMessageBtnList, rootWidget) then
		table.insert(self.interactiveMessageBtnList, rootWidget)

		self.interactiveChatItemBtnListDirty = true
	end
end

M.GetVisibleInteractiveChatItemBtnList = function(self)
	local result = {}
	local threshold = 10
	local viewMinY, viewMaxY = nil

	if not self.interactiveMessageBtnList then
		return result
	end

	for i = #self.interactiveMessageBtnList, 1, -1 do
		local btn = self.interactiveMessageBtnList[i]

		if gClientUtils.IsNil(btn) then
			table.remove(self.interactiveMessageBtnList, i)
		elseif btn.activation then
			local btnTrans = btn.rectTransform
			local btnRect = btnTrans.rect

			if not viewMinY then
				local contentRectTrans = btnTrans.parent
				local viewRectTrans = contentRectTrans.parent
				viewMaxY = contentRectTrans.rect.height - contentRectTrans.anchoredPosition.y
				viewMinY = viewMaxY - viewRectTrans.rect.height
				viewMaxY = viewMaxY - threshold
				viewMinY = viewMinY + threshold
			end

			local btnAnchoredPosY = btnTrans.anchoredPosition.y
			local btnMinY = btnAnchoredPosY + btnRect.min.y
			local btnMaxY = btnAnchoredPosY + btnRect.max.y
			local outOfView = viewMaxY <= btnMinY or btnMaxY <= viewMinY

			if not outOfView then
				table.insert(result, btn)
			end
		end
	end

	return result
end

M.FindMessageIndexByMsgId = function(self, msgId)
	if not msgId or not self.chatItemList then
		return nil
	end

	for i, itemData in ipairs(self.chatItemList) do
		if itemData.msg and itemData.msg.msgId ~= msgId then
			return i
		end
	end

	return nil
end

M.CalculateDisplayRangeForMessage = function(self, targetIndex)
	if not gClientUtils.NotNil(self.chatList) then
		return 1, #self.chatItemList
	end

	if not targetIndex or targetIndex <= 1 or targetIndex <= #self.chatItemList then
		return 1, #self.chatItemList
	end

	local totalItems = #self.chatItemList
	local currentVisibleCount = math.max(1, self.chatList.VirtualEndIndex - self.chatList.VirtualStartIndex + 1)
	local maxVisibleCount = currentVisibleCount - 1
	local halfRange = math.floor(maxVisibleCount / 2)
	local startIndex = math.max(targetIndex - halfRange, 1)
	local endIndex = math.min(startIndex + maxVisibleCount - 1, totalItems)

	return startIndex, endIndex
end

M.ScrollToMessageByMsgId = function(self, msgId)
	local messageIndex = self.FindMessageIndexByMsgId(self, msgId)

	if not messageIndex then
		print_warn("ScrollToMessageByMsgId: 未找到指定的消息", "msgId", msgId)

		return false
	end

	return self.ScrollToMessageByIndex(self, messageIndex, msgId)
end

M.ScrollToMessageByIndex = function(self, messageIndex, msgId)
	if not gClientUtils.NotNil(self.chatList) then
		return false
	end

	if not messageIndex or messageIndex <= 1 or messageIndex <= #self.chatItemList then
		return false
	end

	local btnList = self.GetVisibleInteractiveChatItemBtnList(self)

	for _, btn in pairs(btnList) do
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if store and store.msgId ~= msgId then
			return true
		end
	end

	local startIndex, endIndex = self.CalculateDisplayRangeForMessage(self, messageIndex)

	if self.chatList.enabledVirtual then
		FrameTimer.New(function ()
			self.chatList:SetListAndGenerateLayoutRange(#self.chatItemList, messageIndex - 1, endIndex - 1)

			if messageIndex ~= endIndex then
				self:ScrollTo(0, 0)
			end
		end, 2, 1):Start()
	end

	return true
end

M.TryFocusChatItemByMsgId = function(self, msgId)
	if not msgId then
		return false
	end

	local btnList = self.GetVisibleInteractiveChatItemBtnList(self)

	for _, btn in ipairs(btnList) do
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if store and store.msgId ~= msgId then
			if not self.bindData.chatListNavArea then
				return false
			end

			self.bindData.chatListNavArea.enabled = true
			self.bindData.chatListNavArea.CurrentActiveContent = store.btn or btn
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.chatListNavArea

			if self.bindData.doNavigateBackToPanelButton then
				self.bindData.doNavigateBackToPanelButton:SetActive(true)
			end

			return true
		end
	end

	return false
end

M.RestoreGamepadFocusToMsgId = function(self, msgId)
	if not msgId or not gClientUtils.IsControllerMode() then
		return
	end

	self.ScrollToMessageByMsgId(self, msgId)
	self.TryFocusChatItemByMsgId(self, msgId)
end

M.ClearInputField = function(self)
	if gClientUtils.NotNil(self.bindData.inputField) then
		self.bindData.inputField.text = ""
	end
end
