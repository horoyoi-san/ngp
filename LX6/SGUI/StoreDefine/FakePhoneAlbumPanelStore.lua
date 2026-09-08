-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FakePhoneAlbumPanelStore.lua
-- Decompiled from: 02053_FakePhoneAlbumPanelStore.lua_7ec163e8b9de.luajit

C_FakePhoneAlbumPanelStore = DefClass("C_FakePhoneAlbumPanelStore", C_FakePhoneAlbumPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.FakePhoneAlbumPanelStore = C_FakePhoneAlbumPanelStore
local M = C_FakePhoneAlbumPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.albumList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.albumGroupId = args.albumGroupId
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	self.albumViewDataList = gFakePhoneUtils.GetAlbumViewDataList(self.albumGroupId)

	self.bindData.albumList.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.albumViewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.albumList:SetSimpleList(#self.albumViewDataList)
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.albumViewDataList[luaIndex]

	if data.tIndex ~= gClientConst.FakePhoneTemplateType.TitleTIndex then
		local store = gStoreManager:GetStoreGroup("FakePhoneAlbumTitleTemplateStore"):GetStoreByWidget(btn)
		local albumType = data.albumType
		store.title = LTConfig.NPCChatConfig.AlbumTitleList[albumType]
	elseif data.tIndex ~= gClientConst.FakePhoneTemplateType.AlbumItemTIndex then
		local store = gStoreManager:GetStoreGroup("FakePhoneAlbumTemplateStore"):GetStoreByWidget(btn)
		local albumId = data.albumId
		local albumCfg = LTConfig.NPCChatAlbumConfig.GetConfig(albumId)
		store.icon = gUIUtils:GetSguiImagePath(albumCfg.ImageS)
		store.button.luaClick = self:CreateActionWithArgs("OnAlbumItemClick", albumId)
	end
end

M.OnAlbumItemClick = function(self, albumId)
	self.photoReadIds = self.photoReadIds or {}
	self.photoReadIds[albumId] = true

	gMessageManager:SendMessage(gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_SHOW, {
		secondShowType = gClientConst.FakePhoneAlbumShowType.PhotoDetail,
		albumId = albumId
	})

	self.bindData.fullScreenActive = not self:CheckAlbumAllKeyPhotoHasRead()
end

M.OnExitClick = function(self)
	if self.CheckAlbumAllKeyPhotoHasRead(self) then
		M.base.OnExitClick(self)
	else
		gDisplayMessageMgr:ShowMessageContent(LTConfig.NPCChatConfig.AlbumAppExitTips)
	end
end

M.CheckAlbumAllKeyPhotoHasRead = function(self)
	for _, data in ipairs(self.albumViewDataList) do
		if data.tIndex ~= gClientConst.FakePhoneTemplateType.AlbumItemTIndex then
			local albumId = data.albumId
			local albumCfg = LTConfig.NPCChatAlbumConfig.GetConfig(albumId)

			if albumCfg.KeyPhoto and not self.CheckPhotoHasRead(self, albumId) then
				return false
			end
		end
	end

	return true
end

M.CheckPhotoHasRead = function(self, albumId)
	return self.photoReadIds and self.photoReadIds[albumId]
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_CLOSE)
end

M.ClearData = function(self)
	self.photoReadIds = nil
end
