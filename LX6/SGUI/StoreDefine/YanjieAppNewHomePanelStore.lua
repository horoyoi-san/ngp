-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieAppNewHomePanelStore.lua
-- Decompiled from: 02111_YanjieAppNewHomePanelStore.lua_65e97f77021b.luajit

C_YanjieAppNewHomePanelStore = DefClass("C_YanjieAppNewHomePanelStore", C_YanjieAppNewHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.YanjieAppNewHomePanelStore = C_YanjieAppNewHomePanelStore
local M = C_YanjieAppNewHomePanelStore
local ShowTypeControl = {
	[":G\\x9d\\x82\\x8cV"] = 0,
	["N#nP"] = 1
}

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
end

M.OnShow = function(self, _, args)
	M.base.ShowPanel(self, args)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.popUpTipsQueue = self.popUpQueue or gDataStructureUtils.GetQueue()
	self.isLogout = nil
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	self.bindData.isShowTips = false
	local key = gClientUtils.GetPrefsKey("YanjieAppNewHomePanelStore")

	if not gClientUtils.GetBool(key, false) then
		gClientUtils.SetBool(key, true)
		self.bindData.loginVxWidget.gameObject:SetActive(true)
	end
end

M.PlayPanelAnimation = function(self)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_YANJIE_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_YANJIE_CONTENT_CLOSE] = self.CreateAction(self, "CloseContentPanel"),
		[gEventConstants.ON_TRACING_UNACCEPT_TASK] = self.CreateAction(self, "OnTracingTask"),
		[gEventConstants.ON_YANJIE_SHOW_POP_UP_TIPS] = self.CreateAction(self, "ShowPopUpTips")
	}
end

M.ShowPopUpTips = function(self, _, data)
	self.popUpTipsQueue:Push(data)
	self:ShowPopUpTipsView()
end

M.ShowPopUpTipsView = function(self)
	if self.isPlayingPopUpTips then
		return
	end

	if self.popUpTipsQueue.count < 0 then
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

M.CloseContentPanel = function(self)
	local lastStackPanel = self.stackPanel:Pop()

	if self.stackPanel.count ~= 0 then
		self.OnExit(self)
	else
		local stackInfo = self.stackPanel:Peek()
		local showType = self:GetShowType(stackInfo)
		stackInfo.lastShowType = self:GetShowType(lastStackPanel)

		self.bindData.tabRect:SelectIndexWithClose(showType)
	end
end

M.OnExecuteExitAction = function(self)
	gPanelManager:Close(self.m_Id)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_DETAIL_CONTENT_CLOSE)
end

M.ClearData = function(self)
	gNewGuideMgr:NotifySignal(EGuideSignal.YanJiePanelClose)

	self.popUpTipsQueue = nil
	self.isPlayingPopUpTips = nil
	self.showPopUpTipsCo = coroutine.stop(self.showPopUpTipsCo)
	gSocialNetworkUtils.jumpMapTaskId = nil

	if not self.isLogout then
		gSocialNetworkUtils.AskTwitterPageClose(UX.Game.CloseTwitterPanelType.TwitterPanel)
	end
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

M.OnTracingTask = function(self, _, taskLineId)
	local taskId = gSocialNetworkUtils.jumpMapTaskId
	local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

	if taskLineInfo and taskLineInfo.TaskLineId ~= taskLineId then
		gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
		gPanelManager:Close(self.m_Id)
		gMainPhoneUtils.CloseMainPhonePanel()
	end
end

M.OnLogOut = function(self)
	self.isLogout = true
end
