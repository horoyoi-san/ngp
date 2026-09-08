-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MainPhoneWallPaperHomeStore.lua
-- Decompiled from: 02093_MainPhoneWallPaperHomeStore.lua_9e5f39efaf1d.luajit

C_MainPhoneWallPaperHomeStore = DefClass("C_MainPhoneWallPaperHomeStore", C_MainPhoneWallPaperHomeStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.MainPhoneWallPaperHomeStore = C_MainPhoneWallPaperHomeStore
local M = C_MainPhoneWallPaperHomeStore

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnExitClick)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_WALL_PAPER_APP_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_WALL_PAPER_APP_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end,
		[gEventConstants.ON_CLOSE_WALL_PAPER_APP] = self.CreateAction(self, self.OnCloseWallPaperApp)
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.closeArgs = nil
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
end

M.OnCloseWallPaperApp = function(self, _, args)
	self.closeArgs = args

	self.OnExit(self)
end

M.OnExitClick = function(self)
	self.OnExit(self)
end

M.OnExit = function(self)
	if not self.closeArgs or not self.closeArgs.ignoreBackToMainAnimation then
		self.PlayCloseAnimation(self)
	end

	self.OnExecuteExitAction(self)
	self.ClearStoreGroupData(self)
end

M.OnExecuteExitAction = function(self)
	gMainPhoneUtils.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE, self.closeArgs)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
