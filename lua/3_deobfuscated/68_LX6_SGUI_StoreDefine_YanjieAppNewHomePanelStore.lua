C_YanjieAppNewHomePanelStore = DefClass("C_YanjieAppNewHomePanelStore", C_YanjieAppNewHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.YanjieAppNewHomePanelStore = C_YanjieAppNewHomePanelStore
local M = C_YanjieAppNewHomePanelStore
local ShowTypeControl = {
	Follow = 0,
	Task = 1
}

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
end

function M:OnShow(_, args)
	M.base.ShowPanel(self, args)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.popUpTipsQueue = self.popUpQueue or gDataStructureUtils.GetQueue()
	self.isLogout = nil
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.bindData.isShowTips = false
	local key = gClientUtils.GetPrefsKey("YanjieAppNewHomePanelStore")

	if not gClientUtils.GetBool(key, false) then
		gClientUtils.SetBool(key, true)
		self.bindData.loginVxWidget.gameObject:SetActive(true)
	end
end

function M:PlayPanelAnimation()
	return
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_YANJIE_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_YANJIE_CONTENT_CLOSE] = self:CreateAction("CloseContentPanel"),
		[gEventConstants.ON_TRACING_UNACCEPT_TASK] = self:CreateAction("OnTracingTask"),
		[gEventConstants.ON_YANJIE_SHOW_POP_UP_TIPS] = self:CreateAction("ShowPopUpTips")
	}
end

function M:ShowPopUpTips(_, data)
	self.popUpTipsQueue:Push(data)
	self:ShowPopUpTipsView()
end

function M:ShowPopUpTipsView()
	if self.isPlayingPopUpTips then
		return
	end

	if self.popUpTipsQueue.count <= 0 then
		self.bindData.isShowTips = false
	else
		self.bindData.isShowTips = true
		self.isPlayingPopUpTips = true
		local data = self.popUpTipsQueue:Pop()

		if data.isFollow then
			self.bindData.showTypeCtrl = ShowTypeControl.Follow
			self.bindData.tips = data.roleName
		elseif data.isTask then
			self.bindData.showTypeCtrl = ShowTypeControl.Task
			self.bindData.tips = data.taskName
		end

		self.showPopUpTipsCo = coroutine.start(function ()
			coroutine.wait(2.5)

			self.isPlayingPopUpTips = nil
			self.bindData.isShowTips = false

			coroutine.step()
			self:ShowPopUpTipsView()
		end)
	end
end

function M:CloseContentPanel()
	local lastStackPanel = self.stackPanel:Pop()

	if self.stackPanel.count == 0 then
		self:OnExit()
	else
		local stackInfo = self.stackPanel:Peek()
		local showType = self:GetShowType(stackInfo)
		stackInfo.lastShowType = self:GetShowType(lastStackPanel)

		self.bindData.tabRect:SelectIndexWithClose(showType)
	end
end

function M:OnExecuteExitAction()
	gPanelManager:Close(self.m_Id)
end

function M:ClearData()
	gNewGuideMgr:NotifySignal(EGuideSignal.YanJiePanelClose)

	self.popUpTipsQueue = nil
	self.isPlayingPopUpTips = nil
	self.showPopUpTipsCo = coroutine.stop(self.showPopUpTipsCo)
	gSocialNetworkUtils.jumpMapTaskId = nil

	if not self.isLogout then
		gSocialNetworkUtils.AskTwitterPageClose(UX.Game.CloseTwitterPanelType.TwitterPanel)
	end
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

function M:OnTracingTask(_, taskLineId)
	local taskId = gSocialNetworkUtils.jumpMapTaskId
	local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

	if taskLineInfo and taskLineInfo.TaskLineId == taskLineId then
		gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
		gPanelManager:Close(self.m_Id)
		gMainPhoneUtils.CloseMainPhonePanel()
	end
end

function M:OnLogOut()
	self.isLogout = true
end
