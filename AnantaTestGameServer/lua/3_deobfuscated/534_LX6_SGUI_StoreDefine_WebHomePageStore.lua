C_WebHomePageStore = DefClass("C_WebHomePageStore", C_WebHomePageStore, C_StoreGroup)
GroupName2Class.WebHomePageStore = C_WebHomePageStore
local M = C_WebHomePageStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderContentListItem")
	self.mgr = gWebManager
end

function M:OnShow(panelId, data)
	local urls = self.mgr.homePageList

	self.bindData.contentList:SetSimpleList(#urls)
end

function M:OnClose()
	return
end

function M:OnSimpleRenderContentListItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.pageId = self.mgr.homePageList[index + 1]
end
