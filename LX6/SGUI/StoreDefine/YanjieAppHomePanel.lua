-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieAppHomePanel.lua
-- Decompiled from: 02109_YanjieAppHomePanel.lua_2969130b7076.luajit

C_YanjieAppHomePanel = DefClass("C_YanjieAppHomePanel", C_YanjieAppHomePanel, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.YanjieAppHomePanel = C_YanjieAppHomePanel
local M = C_YanjieAppHomePanel
local ShowTypeControl = {
	[":G\\x9d\\x82\\x8cV"] = 0,
	["N#nP"] = 1
}

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnExitClick)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.isLogout = nil
	self.popUpTipsQueue = self.popUpQueue or gDataStructureUtils.GetQueue()
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	self.bindData.isShowTips = false
end

M.GetMessageEvents = function(self)
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
					["[\\xa5\\x8f\\x90J"] = true,
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
			coroutine.wait(2)

			self.isPlayingPopUpTips = nil

			self:ShowPopUpTipsView()
		end)
	end
end

M.OnExitClick = function(self)
	if self.bindData.tabRect.selectedIndex ~= gClientConst.YanJieShowType.Display then
		local videoPlayPanelStore = gStoreManager:GetStoreGroup("YanjieVideoPlayPanelStore")

		videoPlayPanelStore:OnExitClick()

		return
	end

	M.base.OnExit(self)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.ClearData = function(self)
	self.popUpTipsQueue = nil
	self.isPlayingPopUpTips = nil
	self.showPopUpTipsCo = coroutine.stop(self.showPopUpTipsCo)

	if not self.isLogout then
		gSocialNetworkUtils.AskTwitterPageClose(UX.Game.CloseTwitterPanelType.TwitterPanel)
	end
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

M.OnLogOut = function(self)
	self.isLogout = true
end
