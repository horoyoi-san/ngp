local PhotoConfig = LTConfig.PhotoConfig
C_AlbumPanelStore = DefClass("C_AlbumPanelStore", C_AlbumPanelStore, C_StoreGroup)
GroupName2Class.AlbumPanelStore = C_AlbumPanelStore
local M = C_AlbumPanelStore
local tabType = {
	all = 1,
	selfie = 3,
	normal = 2
}

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.isInit = false
	self.albumList = nil
	self.selectTab = tabType.all
	self.photoListData = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	self:RefreshTab()
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	Album.AlbumProxy.DeserializationAllThumbnail()

	local num = Album.AlbumProxy.GetAlbumNum()
	self.bindData.photoNumText = string.format("%d/48", num)

	if num == 0 then
		self.bindData.emptyCtrl = 1
	else
		self.bindData.emptyCtrl = 0
	end
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ALBUM_THUMBNAIL_DESERIALIZATION_FINISH] = function ()
			if not gPanelManager:IsPanelShowing(self.m_Id) then
				return
			end

			self.isInit = true
			self.albumList = Album.AlbumProxy.GetAllPhoto()

			self:RefreshPhotoList()
		end,
		[gEventConstants.ALBUM_REFRESH_LIST] = function ()
			if not gPanelManager:IsPanelShowing(self.m_Id) then
				return
			end

			self.albumList = Album.AlbumProxy.GetAllPhoto()

			self:RefreshPhotoList()
		end
	}
end

function M:RegisterWidget()
	self.bindData.photoList.luaSimpleRenderItem = self:CreateAction("OnRenderPhotoListItem")
	self.bindData.photoList.luaSimpleClick = self:CreateAction("OnClickPhotoList")

	function self.bindData.photoList.luaLayoutSet()
		self.bindData.photoList:SetNavSelectToTop()
	end

	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		self.bindData.openFolderBtn.luaClick = self:CreateAction("OnClickOpenFolderBtn")
	end
end

function M:OnRenderPhotoListItem(btn, index)
	local data = self.photoListData[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AlbumTemplate"):GetStoreById(id)

	if store then
		store.saveCtrl = data.isSaved and 1 or 0
		store.thumbTex = data.thumb
		store.dayText = string.format(PhotoConfig.PhotoSavingTimeText, PhotoConfig.PhotoSavingTime - data.date)
	end
end

function M:OnClickPhotoList(btn, index)
	local data = self.photoListData[index + 1]

	gPanelManager:CheckShow(gPanelId.S_PHOTO_RECORD_PANEL, {
		photo = data
	})
end

function M:RefreshTab()
	local cfgs = PhotoConfig.PhotoAlbumTab
	local data = {}

	for i = 1, 3 do
		local tab = {}

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			tab.title = cfgs[i].name
		else
			tab.iconId = cfgs[i].iconId
		end

		tab.type = i

		table.insert(data, tab)
	end

	self.SubGroup.CommonTabSingleStore:SetData(data, nil, 0, nil, self:CreateAction("OnChangeTab"))
end

function M:OnChangeTab(uList)
	local item = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
	self.selectTab = item.type

	if self.isInit then
		self:RefreshPhotoList()
	end
end

function M:OnClickCloseBtn()
	gPanelManager:Close(self.m_Id)
end

function M:OnClickOpenFolderBtn()
	Album.AlbumProxy.OpenPhotoFolder()
end

function M:RefreshPhotoList()
	table.clear(self.photoListData)

	local num = Album.AlbumProxy.GetAlbumNum()

	if num == 0 then
		self.bindData.emptyCtrl = 1
	else
		self.bindData.emptyCtrl = 0
	end

	for i = 0, self.albumList.Count - 1 do
		if self.selectTab == tabType.normal and self.albumList[i].isSelfie then
			if false then
				-- Nothing
			end
		else
			local data = {
				stamp = self.albumList[i].timestamp,
				thumb = self.albumList[i].thumbCache,
				isSaved = self.albumList[i].isSaved,
				isSelfie = self.albumList[i].isSelfie
			}
			data.date = Album.AlbumProxy.GetAlbumDay(data.stamp)

			table.insert(self.photoListData, data)
		end
	end

	self.bindData.photoList:SetSimpleList(#self.photoListData)
end
