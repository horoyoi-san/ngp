-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FakePhoneAlbumHomePanelStore.lua
-- Decompiled from: 02103_FakePhoneAlbumHomePanelStore.lua_728bba316313.luajit

C_FakePhoneAlbumHomePanelStore = DefClass("C_FakePhoneAlbumHomePanelStore", C_FakePhoneAlbumHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.FakePhoneAlbumHomePanelStore = C_FakePhoneAlbumHomePanelStore
local M = C_FakePhoneAlbumHomePanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end
	}
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.PlayBackToMainAnimation = function(self)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
