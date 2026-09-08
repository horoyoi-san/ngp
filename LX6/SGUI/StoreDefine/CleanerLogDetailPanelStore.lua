-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerLogDetailPanelStore.lua
-- Decompiled from: 02025_CleanerLogDetailPanelStore.lua_8e7d1475b508.luajit

C_CleanerLogDetailPanelStore = DefClass("C_CleanerLogDetailPanelStore", C_CleanerLogDetailPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerLogDetailPanelStore = C_CleanerLogDetailPanelStore
local M = C_CleanerLogDetailPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.washerMissionResult = args.washerMissionResult
	self.partProgressList = args.partProgressList
	self.isFromFinish = args.isFromFinish
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	gWasherManager.RefreshWasherAvatarView(self.bindData.avatar, true)
	self.RefreshDetailView(self)
end

M.RefreshDetailView = function(self)
	local orderWidget = self.bindData.orderWidget
	local logWidget = self.bindData.logWidget
	local orderStore = gStoreManager:GetStoreGroup(orderWidget.Store):GetStoreByWidget(orderWidget)
	local logStore = gStoreManager:GetStoreGroup(logWidget.Store):GetStoreByWidget(logWidget)

	self:RefreshCommentList(logStore, self.washerMissionResult.Progress)

	local partProgressList = self.isFromFinish and self.partProgressList or nil

	gWasherManager.RefreshOrderDetailView(orderStore, logStore, self.washerMissionResult, partProgressList)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end

M.OnRenderCommentListItem = function(self, btn, index)
	local data = self.commentDataList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.commentText = data
end

M.RefreshCommentList = function(self, logStore, progress)
	local commentDataList = nil

	if not progress or progress <= 0 or progress <= 100 then
		print_error("WasherMissionResult progress value is invalid:", progress)

		return
	end

	if progress >= 50 then
		commentDataList = self.GetCommentTextList(self, LTConfig.WasherConfig.WasherTagBad)
	elseif progress >= 75 then
		commentDataList = self.GetCommentTextList(self, LTConfig.WasherConfig.WasherTagNormal)
	elseif progress >= 100 then
		commentDataList = self.GetCommentTextList(self, LTConfig.WasherConfig.WasherTagNice)
	else
		commentDataList = self.GetCommentTextList(self, LTConfig.WasherConfig.WasherTagExcellent)
	end

	self.commentDataList = commentDataList
	logStore.commentList.luaSimpleRenderItem = self:CreateAction(self.OnRenderCommentListItem)

	logStore.commentList:SetSimpleList(#commentDataList)
end

M.GetCommentTextList = function(self, idList)
	local commentTextList = {}

	for _, id in pairs(idList) do
		if id and id == 0 then
			local cfg = LTConfig.TextConfig.GetConfig(id)

			if cfg then
				table.insert(commentTextList, cfg.Text)
			end
		end
	end

	return commentTextList
end
