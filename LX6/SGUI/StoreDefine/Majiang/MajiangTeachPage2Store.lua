-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangTeachPage2Store.lua
-- Decompiled from: 01225_MajiangTeachPage2Store.lua_e4eb1ee7aedb.luajit

C_MajiangTeachPage2Store = DefClass("C_MajiangTeachPage2Store", C_MajiangTeachPage2Store, C_StoreGroup)
GroupName2Class.MajiangTeachPage2Store = C_MajiangTeachPage2Store
local M = C_MajiangTeachPage2Store

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTechTemplate)
	self.bindData.contentList.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
	self.bindData.pageList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderPageListItem)
	self.bindData.pageList.luaSelectedChanged = self.CreateAction(self, "OnTabSelectChange")
end

M.OnTabSelectChange = function(self, list)
	self.RefreshPage(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	local currentIndex = gMaJiangUtils:GetTeachPanelStore().bindData.tabIndex
	local pageList = gMaJiangUtils:GetTeachPanelStore():GetPageList()[currentIndex]
	local subTabList = {}
	local index = 0

	for k, v in pairs(pageList) do
		local subList = {}

		for i = 1, #v do
			table.insert(subList, gMaJiangUtils:GetTeachPanelStore():GetTechTemplate(v[i]))
		end

		table.insert(subTabList, {
			id = index,
			label = k,
			sort = v.sort,
			subList = subList
		})

		index = index + 1
	end

	table.sort(subTabList, function (a, b)
		return a.sort <= b.sort
	end)

	self.pageList = subTabList

	self.bindData.pageList:SetSimpleList(#subTabList)
	self.bindData.pageList:SelectItem(0)
	self:RefreshPage()
end

M.OnClose = function(self)
end

M.OnDestroy = function(self)
	self.pageList = nil
	self.contentListData = nil
end

M.RefreshPage = function(self)
	local contentList = self.pageList[self.bindData.pageList.selectedIndex + 1].subList
	self.contentListData = contentList

	self.bindData.contentList:SetSimpleList(#contentList)
	self.bindData.contentList:GoToIndex(0, true)
end

M.OnRenderTechTemplate = function(self, btn, index)
	local data = self.contentListData[index + 1]

	gMaJiangUtils:GetTeachPanelStore():RenderTechTemplate(btn, index, data)
end

M.OnRenderPageListItem = function(self, btn, index)
	local data = self.pageList[index + 1]
	btn.title.text = data.label
end

M.OnGetTIndex = function(self, index)
	local data = self.contentListData[index + 1]

	return data.tIndex
end
