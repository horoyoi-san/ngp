local M = C_ChatChattingPanelStore

dofile("LX6/SGUI/StoreDefine/Chat/ChatChattingPanelStore_AnimUtils")

function M:ClearChatItems()
	self.chatItemList = {}

	self:AnimUtilsInit()
	self.chatList:SetList(0, false, 0)
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

	if gCS.LuaUtils.IsNotUseGM then
		self.cs:ScrollBottomToPos()
	else
		self.debugLog = self.debugLog or {}

		table.insert(self.debugLog, {
			traceback = debug.traceback(),
			time = Time.frameCount
		})

		if #self.debugLog > 10 then
			table.remove(self.debugLog, 1)
		end
	end
end

function M:ScrollTo(x, y)
	self.chatList.normalizedScrollPosition = Vector2.Fetch(x, y)
end

function M:SetList()
	self.chatList:SetList(#self.chatItemList, false, 0)
end

function M:UpdateChatList(updateFunction, keepPosition)
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
			elseif gChatUtils.IsStoryChannel(self.topChannelId) and LTConfig.NPCChatConfig.ChatTypeType.Fake == gChatManager.currentNpcChatType then
				list:SetList(#self.chatItemList, false, 0)
			else
				local lastMessage = self.lastMessage or {}

				print_error("@liulijun04 关闭虚拟化的情况不应调用 SetListAndGenerateLayoutRange!", "top", self.topChannelId, "sub", self.subChannelId, "len", #self.chatItemList, "last", lastMessage.npcChatId, "debugLog", self.debugLog)
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

function M:ClearInputField()
	if gClientUtils.NotNil(self.bindData.inputField) then
		self.bindData.inputField.text = ""
	end
end
