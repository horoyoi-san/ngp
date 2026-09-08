-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SaturnVideoWebpageStore.lua
-- Decompiled from: 02102_SaturnVideoWebpageStore.lua_b48e7a54900b.luajit

local SatrunSectionType = LTConfig.WebpageSatrunConfig.TypeType
local SatrunSubType = LTConfig.WebpageSatrunConfig.SubTypeType
C_SaturnVideoWebpageStore = DefClass("C_SaturnVideoWebpageStore", C_SaturnVideoWebpageStore, C_SaturnResourceWebpageBase)
GroupName2Class.SaturnVideoWebpageStore = C_SaturnVideoWebpageStore
local M = C_SaturnVideoWebpageStore
M.ShowPlayerCtl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}

M.ctor = function(self)
	self.bgImage = 0
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderList)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
	self.bindData.btnNextPage.luaClick = self.CreateAction(self, self.NextPage)
	self.bindData.btnPrevPage.luaClick = self.CreateAction(self, self.PrevPage)
	self.bindData.btnGoHome.luaClick = self.CreateAction(self, self.GoToHomePage)

	self.InitNavBindData(self, self.bindData.nav, self.bindData.navbar)
end

M.RefreshPage = function(self)
	self.LoadData(self, SatrunSectionType.movie, SatrunSubType.Movie)
end

M.OnRenderPage = function(self, resources)
	self.bindData.list:SetSimpleList(#resources)
	self:SetResourceId(1)
	self.bindData.list:SelectItem(0)

	if self.bgImage == 0 then
		-- Nothing
	end

	self.LoadResource(self)

	self.bindData.btnPrevPage.interactable = self.HasPrevPage(self)
	self.bindData.btnNextPage.interactable = self.HasNextPage(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end

M.OnSimpleRenderList = function(self, widget, index)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local resource = self.resources[index + 1]
	store.title.text = resource.title
	store.desc.text = resource.desc

	if resource.image then
		store.Commit(store, "image", resource.image, COMMIT_FORCE)
	end
end

M.OnSimpleClickList = function(self, _, index)
	self.bindData.list:SelectItem(index)
	self:SetResourceId(index + 1)
	self:LoadResource()
end

M.OnLoadResource = function(self, resource)
	self.bindData.title.text = resource.title
	self.bindData.desc.text = resource.desc
	self.bindData.showPlayerCtl = self.ShowPlayerCtl.Hide

	self.bindData:Commit("bgRes", resource.image, COMMIT_FORCE)
end
