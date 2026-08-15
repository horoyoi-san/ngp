local M = C_NpcChatChattingPanelStore

function M:ClearChatItems()
	self.chatItemList = {}

	self.chatList:SetList(0, false, 0)

	self.needClickItem = {}
end

function M:ScrollToTop()
	self:ScrollTo(0, 1)
end

function M:ScrollToBottom(instant)
	if instant then
		self.chatList:SetList(#self.chatItemList, false, 0)
		self:ScrollTo(0, 0)

		return
	end

	self.cs:ScrollBottomToPos(0)
end

function M:ScrollTo(x, y)
	self.chatList.normalizedScrollPosition = Vector2.Fetch(x, y)
end

function M:SetList()
	self.chatList:SetList(#self.chatItemList, false, 0)
end

function M:UpdateFakeChatContent(msg)
	self.inUpdateChatList = true

	self:AddNewChatMessage(msg)
	self:AfterAddMessage(msg)
	self:ShowBottom(false)

	self.inUpdateChatList = false
end

function M:UpdateChatContent(msg)
	self.inUpdateChatList = true

	self:AddNewChatMessage(msg)
	self:ShowBottom(false)

	self.inUpdateChatList = false
end

function M:UpdateChatList(updateFunction, keepPosition, msg)
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

		if endIndexOld + 1 == itemsCountOld then
			if startIndexOld >= 0 then
				self.cs:LogItemPositionAtIndex(startIndexOld)
			end

			updateFunction()

			if self.chatList.enabledVirtual then
				list:SetListAndGenerateLayoutRange(#self.chatItemList, startIndexOld, #self.chatItemList - 1)

				if startIndexOld >= 0 then
					self.cs:ResumeItemPositionAtIndex(startIndexOld)
				end
			elseif LTConfig.NPCChatConfig.ChatTypeType.Fake == gNpcChatManager.currentNpcChatType then
				list:SetList(#self.chatItemList, false, 0)
			else
				print_debug("@liulijun04 关闭虚拟化的情况不应调用 SetListAndGenerateLayoutRange!", "top", self.topChannelId, "sub", self.subChannelId, "len", #self.chatItemList, "last", self.lastMessage and self.lastMessage.npcChatId, "debugLog", self.debugLog)
			end
		else
			updateFunction()
			list:SetDataCountNoRefresh(#self.chatItemList)
		end
	else
		updateFunction()

		local itemsCountNew = #self.chatItemList
		local headInsertCount = itemsCountNew - itemsCountOld

		list:SetList(#self.chatItemList, keepPosition, headInsertCount)
	end

	self.inUpdateChatList = false
end

function M:AddItemToList(itemData)
	if not self.inUpdateChatList then
		print_error("ChatChattingPanel: AddItemToList should be called in UpdateChatList!")
	end

	table.insert(self.chatItemList, itemData)
end

function M:RemoveLastItem()
	if not self.inUpdateChatList then
		print_error("ChatChattingPanel: RemoveLastItem should be called in UpdateChatList!")
	end

	table.remove(self.chatItemList)
end

function M:RemoveSpecificItem()
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

function M:CacheInteractiveChatItemWidget(rootWidget)
	if not table.find(self.interactiveMessageBtnList, rootWidget) then
		table.insert(self.interactiveMessageBtnList, rootWidget)

		self.interactiveChatItemBtnListDirty = true
	end
end

function M:GetVisibleInteractiveChatItemBtnList()
	local result = {}
	local threshold = 10
	local viewMinY, viewMaxY = nil

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
			local outOfView = viewMaxY < btnMinY or btnMaxY < viewMinY

			if not outOfView then
				table.insert(result, btn)
			end
		end
	end

	return result
end

function M:FindMessageIndexByMsgId(msgId)
	if not msgId or not self.chatItemList then
		return nil
	end

	for i, itemData in ipairs(self.chatItemList) do
		if itemData.msg and itemData.msg.msgId == msgId then
			return i
		end
	end

	return nil
end

function M:CalculateDisplayRangeForMessage(targetIndex)
	if not targetIndex or targetIndex < 1 or targetIndex > #self.chatItemList then
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

function M:ScrollToMessageByMsgId(msgId)
	local messageIndex = self:FindMessageIndexByMsgId(msgId)

	if not messageIndex then
		print_warn("ScrollToMessageByMsgId: 未找到指定的消息", "msgId", msgId)

		return false
	end

	return self:ScrollToMessageByIndex(messageIndex, msgId)
end

function M:ScrollToMessageByIndex(messageIndex, msgId)
	if not messageIndex or messageIndex < 1 or messageIndex > #self.chatItemList then
		return false
	end

	local btnList = self:GetVisibleInteractiveChatItemBtnList()

	for _, btn in pairs(btnList) do
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if store and store.msgId == msgId then
			return true
		end
	end

	local startIndex, endIndex = self:CalculateDisplayRangeForMessage(messageIndex)

	if self.chatList.enabledVirtual then
		FrameTimer.New(function ()
			self.chatList:SetListAndGenerateLayoutRange(#self.chatItemList, messageIndex - 1, endIndex - 1)

			if messageIndex == endIndex then
				self:ScrollTo(0, 0)
			end
		end, 2, 1):Start()
	end

	return true
end

function M:ClearInputField()
	if gClientUtils.NotNil(self.bindData.inputField) then
		self.bindData.inputField.text = ""
	end
end
