local UNavigationMgr = SGUI.UNavigationMgr
C_BubbleDetailPanelStore = DefClass("C_BubbleDetailPanelStore", C_BubbleDetailPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleDetailPanelStore = C_BubbleDetailPanelStore
local M = C_BubbleDetailPanelStore

function M:ctor()
	self.postId = 0
end

function M:OnAwake()
	self.mgr = gNewBubbleMgr
	self.bindData.detailList.luaSimpleDynamicRenderItem = self:CreateAction(self.OnRenderDynamicItem)
	self.bindData.detailList.luaSimpleRenderItem = self:CreateAction(self.OnRenderDynamicItem)
	self.bindData.detailList.onGetTIndex = self:CreateAction(self.OnGetTIndex)
	self.bindData.commentBtn.luaClick = self:CreateAction(self.OnCommentClick)
	self.commentList = {}
	self.replyList = {}
	self.detailStore = nil
end

function M:OnGetTIndex(index)
	return index == 0 and 0 or 1
end

function M:OnRenderDynamicItem(btn, index)
	if index == 0 then
		local store = self.mgr:OnRenderDynamicItem(btn, self.postId, self.hasReply)
		self.detailStore = store

		if store and store.commentBtn then
			store.commentBtn.luaClick = self:CreateActionWithArgs(self.OnCommentClick, store)
			store.commentNumLabel = #self.replyList
		end

		if store and store.replyList then
			store.replyList.luaSimpleClick = self:CreateAction(self.OnClickReplyItem)

			store.replyList:SetSimpleList(0)

			for i = 1, #self.replyList do
				store.replyList:AddSimpleLabel(0, self.replyList[i].label)
			end

			store.replyList:RefreshList()
		end
	else
		local comment = self.commentList[index]
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		store.contentLabel = comment.label

		self.mgr:OnRenderBubbleCommonAvatar(store.headAvatar, 0, comment.commentUserId, 0)
	end
end

function M:InitView(data)
	if data and data.postId then
		self.callback = data.callback
		self.postId = data.postId

		self:RefreshPage()
	end
end

function M:OnClose()
	if self.callback then
		self.callback()
	end
end

function M:RefreshPage()
	if self.detailStore and self.detailStore.detailModel == 1 then
		self.detailStore.detailModel = 0
	end

	self.commentList, self.replyList = self.mgr:GetCommentsInfo(self.postId)
	self.hasReply = #self.replyList > 0

	self.bindData.detailList:SetSimpleList(#self.commentList + 1)
	self:RefreshNaviArea()
end

function M:RefreshNaviArea()
	if not self.detailStore then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		UNavigationMgr.Inst.CurrentActiveArea = self.detailStore.detailModel == 1 and self.hasReply and self.detailStore.dropNavigationArea or self.bindData.nativeNavigationArea
	end
end

function M:OnCommentClick(store)
	if not self.hasReply then
		return
	end

	store.detailModel = store.detailModel == 1 and 0 or 1

	self:RefreshNaviArea()
end

function M:OnClickReplyItem(btn, index)
	local data = self.replyList[index + 1]

	self.mgr:AskPostComment(self.postId, data.commentId)
end
