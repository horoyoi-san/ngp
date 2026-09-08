-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieMyRelatedPanel.lua
-- Decompiled from: 02065_YanjieMyRelatedPanel.lua_b8bce270d2ea.luajit

C_YanjieMyRelatedPanel = DefClass("C_YanjieMyRelatedPanel", C_YanjieMyRelatedPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieMyRelatedPanel = C_YanjieMyRelatedPanel
local M = C_YanjieMyRelatedPanel

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_YANJIE_CATEGORY_CHANGE] = self.CreateAction(self, "OnCategoryChange")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, _)
	self.momentList = self.SubGroup.CommonNewYanjieListTemplateStore
	self.momentList.GetList = gSocialNetworkUtils.GetMyRelatedMomentList

	self.momentList:StartRequest()
end

M.OnCategoryChange = function(self, _, categoryId)
	if self.categoryId ~= categoryId then
		return
	end

	self.categoryId = categoryId

	self.momentList:ClearAndRefreshData()
end
