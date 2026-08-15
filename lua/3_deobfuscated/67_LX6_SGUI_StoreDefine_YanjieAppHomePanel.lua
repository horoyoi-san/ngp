C_YanjieAppHomePanel = DefClass("C_YanjieAppHomePanel", C_YanjieAppHomePanel, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.YanjieAppHomePanel = C_YanjieAppHomePanel
local M = C_YanjieAppHomePanel
local ShowTypeControl = {
	Follow = 0,
	Task = 1
}

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.fullScreenButton.luaClick = self:CreateAction(self.OnExitClick)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.isLogout = nil
	self.popUpTipsQueue = self.popUpQueue or gDataStructureUtils.GetQueue()
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.bindData.isShowTips = false
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_YANJIE_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_YANJIE_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end,
		[gEventConstants.SYNC_TASK_EVENT] = function (_, args)
			if args.becomeAcceptable then
				local eventInfo = args.eventInfo
				local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(eventInfo.EventId)
				local taskName = taskEventCfg.EventName

				gSocialNetworkUtils.ShowPopUp({
					isTask = true,
					taskName = taskName
				})
			end
		end,
		[gEventConstants.ON_YANJIE_SHOW_POP_UP_TIPS] = function (_, data)
			self.popUpTipsQueue:Push(data)
			self:ShowPopUpTipsView()
		end
	}
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
			coroutine.wait(2)

			self.isPlayingPopUpTips = nil

			self:ShowPopUpTipsView()
		end)
	end
end

function M:OnExitClick()
	if self.bindData.tabRect.selectedIndex == gClientConst.YanJieShowType.Display then
		local videoPlayPanelStore = gStoreManager:GetStoreGroup("YanjieVideoPlayPanelStore")

		videoPlayPanelStore:OnExitClick()

		return
	end

	M.base.OnExit(self)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:ClearData()
	self.popUpTipsQueue = nil
	self.isPlayingPopUpTips = nil
	self.showPopUpTipsCo = coroutine.stop(self.showPopUpTipsCo)

	if not self.isLogout then
		gSocialNetworkUtils.AskTwitterPageClose(UX.Game.CloseTwitterPanelType.TwitterPanel)
	end
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

function M:OnLogOut()
	self.isLogout = true
end
