C_CleanerLogDetailPanelStore = DefClass("C_CleanerLogDetailPanelStore", C_CleanerLogDetailPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerLogDetailPanelStore = C_CleanerLogDetailPanelStore
local M = C_CleanerLogDetailPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.washerMissionResult = args.washerMissionResult
end

function M:InitView(args)
	M.base.InitView(self, args)
	gWasherManager.RefreshWasherAvatarView(self.bindData.avatar, true)
	self:RefreshDetailView()
end

function M:RefreshDetailView()
	local orderWidget = self.bindData.orderWidget
	local logWidget = self.bindData.logWidget
	local orderStore = gStoreManager:GetStoreGroup(orderWidget.Store):GetStoreByWidget(orderWidget)
	local logStore = gStoreManager:GetStoreGroup(logWidget.Store):GetStoreByWidget(logWidget)

	self:RefreshCommentList(logStore, self.washerMissionResult.progress)
	gWasherManager.RefreshOrderDetailView(orderStore, logStore, self.washerMissionResult)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end

function M:OnRenderCommentListItem(btn, index)
	local data = self.commentDataList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.commentText = data
end

function M:RefreshCommentList(logStore, progress)
	local commentDataList = nil

	if not progress or progress < 0 or progress > 100 then
		print_error("WasherMissionResult progress value is invalid:", progress)

		return
	end

	if progress < 50 then
		commentDataList = self:GetCommentTextList(LTConfig.WasherConfig.WasherTagBad)
	elseif progress < 75 then
		commentDataList = self:GetCommentTextList(LTConfig.WasherConfig.WasherTagNormal)
	elseif progress < 100 then
		commentDataList = self:GetCommentTextList(LTConfig.WasherConfig.WasherTagNice)
	else
		commentDataList = self:GetCommentTextList(LTConfig.WasherConfig.WasherTagExcellent)
	end

	self.commentDataList = commentDataList
	logStore.commentList.luaSimpleRenderItem = self:CreateAction(self.OnRenderCommentListItem)

	logStore.commentList:SetSimpleList(#commentDataList)
end

function M:GetCommentTextList(idList)
	local commentTextList = {}

	for _, id in pairs(idList) do
		if id and id ~= 0 then
			local cfg = LTConfig.TextConfig.GetConfig(id)

			if cfg then
				table.insert(commentTextList, cfg.Text)
			end
		end
	end

	return commentTextList
end
