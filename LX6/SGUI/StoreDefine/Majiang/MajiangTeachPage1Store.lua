-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangTeachPage1Store.lua
-- Decompiled from: 01224_MajiangTeachPage1Store.lua_e014ff6b2e24.luajit

C_MajiangTeachPage1Store = DefClass("C_MajiangTeachPage1Store", C_MajiangTeachPage1Store, C_StoreGroup)
GroupName2Class.MajiangTeachPage1Store = C_MajiangTeachPage1Store
local M = C_MajiangTeachPage1Store

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.nextBtn.luaClick = self.CreateActionWithArgs(self, "OnStep", 1)
	self.bindData.prevBtn.luaClick = self.CreateActionWithArgs(self, "OnStep", -1)
	self.bindData.dotList.luaSimpleClick = self.CreateAction(self, self.OnDotClick)
	self.currentIndex = 1
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	local currentIndex = gMaJiangUtils:GetTeachPanelStore().bindData.tabIndex
	self.pageList = gMaJiangUtils:GetTeachPanelStore():GetPageList()[currentIndex]
	local dotList = {}

	for i = 1, #self.pageList do
		table.insert(dotList, {
			id = i,
			selected = i ~= self.currentIndex
		})
	end

	self.dotListData = dotList

	self.bindData.dotList:SetSimpleList(#dotList)
	self.bindData.dotList:SelectItem(self.currentIndex - 1)
	self:RefreshPage()
end

M.OnDotClick = function(self, btn, csIndex)
	local data = self.dotListData[csIndex + 1]
	self.currentIndex = data.id

	self.RefreshPage(self)
end

M.OnClose = function(self)
end

M.OnDestroy = function(self)
	self.pageList = nil
	self.dotListData = nil
	self.currentIndex = nil
end

M.RefreshPage = function(self)
	local data = gMaJiangUtils:GetTeachPanelStore():GetTechTemplate(self.pageList[self.currentIndex])

	self.bindData.dotList:SelectItem(self.currentIndex - 1)
	gMaJiangUtils:GetTeachPanelStore():RenderTechTemplate(self.bindData.content, 0, data)

	self.bindData.prevBtn.interactable = self.currentIndex >= 1
	self.bindData.nextBtn.interactable = self.currentIndex > #self.pageList - 1
end

M.OnStep = function(self, step)
	local nextId = self.currentIndex + step

	if nextId > 0 or nextId <= #self.pageList then
		return
	end

	self.currentIndex = nextId

	self.RefreshPage(self)
end
