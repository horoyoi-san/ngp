C_MainPhoneWallPaperHomeStore = DefClass("C_MainPhoneWallPaperHomeStore", C_MainPhoneWallPaperHomeStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.MainPhoneWallPaperHomeStore = C_MainPhoneWallPaperHomeStore
local M = C_MainPhoneWallPaperHomeStore

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.fullScreenButton.luaClick = self:CreateAction(self.OnExitClick)
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_WALL_PAPER_APP_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_WALL_PAPER_APP_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end,
		[gEventConstants.ON_CLOSE_WALL_PAPER_APP] = self:CreateAction(self.OnCloseWallPaperApp)
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.closeArgs = nil
end

function M:InitView(args)
	M.base.InitView(self, args)
end

function M:OnCloseWallPaperApp(_, args)
	self.closeArgs = args

	self:OnExit()
end

function M:OnExitClick()
	self:OnExit()
end

function M:OnExit()
	if not self.closeArgs or not self.closeArgs.ignoreBackToMainAnimation then
		self:PlayCloseAnimation()
	end

	self:OnExecuteExitAction()
	self:ClearStoreGroupData()
end

function M:OnExecuteExitAction()
	gMainPhoneUtils.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE, self.closeArgs)
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
