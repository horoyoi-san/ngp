-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterRecommandStore.lua
-- Decompiled from: 01764_HotCenterRecommandStore.lua_1128de667aa8.luajit

C_HotCenterRecommandStore = DefClass("C_HotCenterRecommandStore", C_HotCenterRecommandStore, C_StoreGroup)
GroupName2Class.HotCenterRecommandStore = C_HotCenterRecommandStore
local M = C_HotCenterRecommandStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.showData = nil
	self.isFold = true
	self.foldCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.foldCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.RegisterWidget = function(self)
	self.bindData.button.luaClick = self.CreateAction(self, "OnButtonClick")
end

M.ShowPanel = function(self, data)
	self.showData = data
	self.isFold = data and data.isFold == false

	self:RefreshView()
end

M.RefreshView = function(self)
	if not self.showData then
		return
	end

	self.bindData.bg = self.showData.bg
	self.bindData.title = self.showData.title
	self.bindData.desc = self.isFold and (self.showData.shortDesc or "") or self.showData.fullDesc or ""
	self.bindData.foldCtrl = self.isFold and self.foldCtrlEnum._true or self.foldCtrlEnum._false

	self.bindData.starList:SetSimpleList(self.showData.starCount or 0)
end

M.OnButtonClick = function(self)
	if not self.showData then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_RECOMMEND_ITEM_CLICK, {
		id = self.showData.id
	})
end
