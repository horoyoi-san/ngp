C_FakePhonePhotoPanelStore = DefClass("C_FakePhonePhotoPanelStore", C_FakePhonePhotoPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.FakePhonePhotoPanelStore = C_FakePhonePhotoPanelStore
local M = C_FakePhonePhotoPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.albumId = args.albumId
end

function M:InitView(args)
	M.base.InitView(self, args)

	local albumCfg = LTConfig.NPCChatAlbumConfig.GetConfig(self.albumId)
	local imageCfg = LTConfig.SguiImageConfig.GetConfig(albumCfg.ImageL)
	self.bindData.icon = imageCfg and imageCfg.ImgPath
	self.bindData.exitButtonActive = not albumCfg.KeyDialog
	self.bindData.title = albumCfg.Name
	self.bindData.time = albumCfg.Time

	self:ShowDialog(albumCfg.Dialog)
end

function M:ShowDialog(dialogId)
	if dialogId and dialogId > 0 then
		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Phone, nil, nil, function ()
			if self.hasDestroy then
				return
			end

			self.bindData.exitButtonActive = true
		end)
	end
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_CLOSE)
end

function M:ClearData()
	gDialogManager:CloseDialog()
end
