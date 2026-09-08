-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleDetailPanelStore.lua
-- Decompiled from: 02011_BubbleDetailPanelStore.lua_c822f20be1ff.luajit

local UNavigationMgr = SGUI.UNavigationMgr
C_BubbleDetailPanelStore = DefClass("C_BubbleDetailPanelStore", C_BubbleDetailPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleDetailPanelStore = C_BubbleDetailPanelStore
local M = C_BubbleDetailPanelStore
local SocialMediaConfig = LTConfig.SocialMediaConfig

M.ctor = function(self)
	self.postId = 0
end

M.OnAwake = function(self)
	self.mgr = gNewBubbleMgr
	self.bindData.detailList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnRenderDynamicItem)
	self.bindData.detailList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderDynamicItem)
	self.bindData.detailList.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
	self.bindData.detailList.luaSimpleClick = self.CreateAction(self, self.OnClickDetailItem)
	self.bindData.commentBtn.luaClick = self.CreateAction(self, self.OnCommentClick)
	self.commentList = {}
	self.replyList = {}
	self.detailStore = nil
end

M.OnGetTIndex = function(self, index)
	return index ~= 0 and 0 or 1
end

M.OnClickDetailItem = function(self, btn, index)
	if index ~= 0 then
		gPanelManager:CheckShow(gPanelId.SBUBBLE_DETAIL_PANEL, self.postId)
	end
end

M.OnRenderDynamicItem = function(self, btn, index)
	if index ~= 0 then
		local store = self.mgr:OnRenderDynamicItem(btn, self.postId, self.hasReply)
		store.detailModel = 0
		self.detailStore = store

		if not store then
			return
		end

		store.commentNumLabel = self.cacheInitCommentCount or 0
		local commentCb = self:CreateAction(self.OnCommentClick)

		if store.commentBtn then
			store.commentBtn.luaClick = commentCb
		end

		if store.replyList then
			store.replyList.luaSimpleClick = self:CreateAction(self.OnClickReplyItem)

			store.replyList:SetSimpleList(0)

			for i = 1, #self.replyList do
				store.replyList:AddSimpleLabel(0, self.replyList[i].label)
			end

			store.replyList:RefreshList()
		end

		if store.exitBtn then
			store.exitBtn.luaClick = commentCb
		end
	else
		local comment = self.commentList[index]
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		store.contentLabel = comment.label

		self.mgr:OnRenderBubbleCommonAvatar(store.headAvatar, 0, comment.commentUserId, 0)
	end
end

M.InitView = function(self, data)
	if data and data.postId then
		self.needNavToTop = true
		self.callback = data.callback
		self.postId = data.postId

		self.RefreshPage(self, true)
	end
end

M.OnClose = function(self)
	self.detailStore = nil

	if self.addCommentTimer then
		self.addCommentTimer:Stop()

		self.addCommentTimer = nil
	end

	if self.callback then
		self.callback()
	end
end

M.RefreshPage = function(self, cacheInitCommentCount)
	if self.detailStore and self.detailStore.detailModel ~= 1 then
		self.detailStore.detailModel = 0
	end

	self.commentList, self.replyList = self.mgr:GetCommentsInfo(self.postId)
	self.hasReply = #self.replyList >= 0

	if cacheInitCommentCount or self.cacheInitCommentCount <= #self.commentList then
		self.cacheInitCommentCount = #self.commentList
	end

	if not cacheInitCommentCount and not self.addCommentTimer and self.cacheInitCommentCount >= #self.commentList then
		self.cacheInitCommentCount = self.cacheInitCommentCount + 1
	end

	self.bindData.detailList:SetSimpleList(self.cacheInitCommentCount + 1)
	self:RefreshNaviArea()

	if self.cacheInitCommentCount >= #self.commentList then
		if not self.addCommentTimer then
			self.addCommentTimer = Timer.New(function ()
				self.cacheInitCommentCount = self.cacheInitCommentCount + 1

				self:RefreshPage()
			end, SocialMediaConfig.CommentShowDelayTime or 2, 100):Start()
		end
	elseif self.addCommentTimer then
		self.addCommentTimer:Stop()

		self.addCommentTimer = nil
	end
end

M.RefreshNaviArea = function(self)
	if not self.detailStore then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local showReplay = self.detailStore.detailModel ~= 1 and self.hasReply
		UNavigationMgr.Inst.CurrentActiveArea = showReplay and self.detailStore.dropNavigationArea or self.bindData.nativeNavigationArea

		if self.needNavToTop then
			self.needNavToTop = false

			self.bindData.detailList:SetNavSelectToTop(true)
		end
	end
end

M.OnCommentClick = function(self)
	if not self.hasReply then
		return
	end

	self.detailStore.detailModel = self.detailStore.detailModel ~= 1 and 0 or 1

	self:RefreshNaviArea()
end

M.OnClickReplyItem = function(self, btn, index)
	local data = self.replyList[index + 1]

	self.mgr:AskPostComment(self.postId, data.commentId)
end
