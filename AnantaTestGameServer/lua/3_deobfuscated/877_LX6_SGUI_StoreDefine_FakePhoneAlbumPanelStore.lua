C_FakePhoneAlbumPanelStore = DefClass("C_FakePhoneAlbumPanelStore", C_FakePhoneAlbumPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.FakePhoneAlbumPanelStore = C_FakePhoneAlbumPanelStore
local M = C_FakePhoneAlbumPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.albumList.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.fullScreenButton.luaClick = self:CreateAction("OnExitClick")
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.albumGroupId = args.albumGroupId
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.albumViewDataList = gFakePhoneUtils.GetAlbumViewDataList(self.albumGroupId)

	function self.bindData.albumList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.albumViewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.albumList:SetSimpleList(#self.albumViewDataList)
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.albumViewDataList[luaIndex]

	if data.tIndex == gClientConst.FakePhoneTemplateType.TitleTIndex then
		local store = gStoreManager:GetStoreGroup("FakePhoneAlbumTitleTemplateStore"):GetStoreByWidget(btn)
		local albumType = data.albumType
		store.title = LTConfig.NPCChatConfig.AlbumTitleList[albumType]
	elseif data.tIndex == gClientConst.FakePhoneTemplateType.AlbumItemTIndex then
		local store = gStoreManager:GetStoreGroup("FakePhoneAlbumTemplateStore"):GetStoreByWidget(btn)
		local albumId = data.albumId
		local albumCfg = LTConfig.NPCChatAlbumConfig.GetConfig(albumId)
		local imageCfg = LTConfig.SguiImageConfig.GetConfig(albumCfg.ImageS)
		store.icon = imageCfg and imageCfg.ImgPath
		store.button.luaClick = self:CreateActionWithArgs("OnAlbumItemClick", albumId)
	end
end

function M:OnAlbumItemClick(albumId)
	self.photoReadIds = self.photoReadIds or {}
	self.photoReadIds[albumId] = true

	gMessageManager:SendMessage(gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_SHOW, {
		secondShowType = gClientConst.FakePhoneAlbumShowType.PhotoDetail,
		albumId = albumId
	})

	self.bindData.fullScreenActive = not self:CheckAlbumAllKeyPhotoHasRead()
end

function M:OnExitClick()
	if self:CheckAlbumAllKeyPhotoHasRead() then
		M.base.OnExitClick(self)
	else
		gDisplayMessageMgr:ShowMessageContent(LTConfig.NPCChatConfig.AlbumAppExitTips)
	end
end

function M:CheckAlbumAllKeyPhotoHasRead()
	for _, data in ipairs(self.albumViewDataList) do
		if data.tIndex == gClientConst.FakePhoneTemplateType.AlbumItemTIndex then
			local albumId = data.albumId
			local albumCfg = LTConfig.NPCChatAlbumConfig.GetConfig(albumId)

			if albumCfg.KeyPhoto and not self:CheckPhotoHasRead(albumId) then
				return false
			end
		end
	end

	return true
end

function M:CheckPhotoHasRead(albumId)
	return self.photoReadIds and self.photoReadIds[albumId]
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_CLOSE)
end

function M:ClearData()
	self.photoReadIds = nil
end
