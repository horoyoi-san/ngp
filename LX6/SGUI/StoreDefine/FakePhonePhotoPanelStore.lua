-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FakePhonePhotoPanelStore.lua
-- Decompiled from: 02050_FakePhonePhotoPanelStore.lua_d8acb7287058.luajit

C_FakePhonePhotoPanelStore = DefClass("C_FakePhonePhotoPanelStore", C_FakePhonePhotoPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.FakePhonePhotoPanelStore = C_FakePhonePhotoPanelStore
local M = C_FakePhonePhotoPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.albumId = args.albumId
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	local albumCfg = LTConfig.NPCChatAlbumConfig.GetConfig(self.albumId)
	self.bindData.icon = gUIUtils:GetSguiImagePath(albumCfg.ImageL)
	self.bindData.exitButtonActive = not albumCfg.KeyDialog
	self.bindData.title = albumCfg.Name
	self.bindData.time = albumCfg.Time

	self:ShowDialog(albumCfg.Dialog)
end

M.ShowDialog = function(self, dialogId)
	if dialogId and dialogId <= 0 then
		slot2 = gDialogManager

		slot2:ShowGeneralDialog(dialogId, gDialogSource.Phone, nil, , function ()
			if self.hasDestroy then
				return
			end

			self.bindData.exitButtonActive = true
		end)
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_CLOSE)
end

M.ClearData = function(self)
	gDialogManager:CloseDialog()
end
