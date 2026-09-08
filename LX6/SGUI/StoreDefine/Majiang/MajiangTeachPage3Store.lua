-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangTeachPage3Store.lua
-- Decompiled from: 01226_MajiangTeachPage3Store.lua_2ba07f0da5ab.luajit

C_MajiangTeachPage3Store = DefClass("C_MajiangTeachPage3Store", C_MajiangTeachPage3Store, C_StoreGroup)
GroupName2Class.MajiangTeachPage3Store = C_MajiangTeachPage3Store
local M = C_MajiangTeachPage3Store

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTechTemplate)
	self.bindData.contentList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnRenderTechTemplate)
	self.bindData.contentList.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	local currentIndex = gMaJiangUtils:GetTeachPanelStore().bindData.tabIndex
	local pageList = gMaJiangUtils:GetTeachPanelStore():GetPageList()[currentIndex]
	local subTabList = {}

	for i = 1, #pageList do
		table.insert(subTabList, gMaJiangUtils:GetTeachPanelStore():GetTechTemplate(pageList[i]))
	end

	self.contentListData = subTabList

	self.bindData.contentList:SetSimpleList(#subTabList)
end

M.OnDestroy = function(self)
	self.contentListData = nil
end

M.OnRenderTechTemplate = function(self, btn, index)
	local data = self.contentListData[index + 1]

	gMaJiangUtils:GetTeachPanelStore():RenderTechTemplate(btn, index, data)
end

M.OnGetTIndex = function(self, index)
	return self.contentListData[index + 1].tIndex
end
