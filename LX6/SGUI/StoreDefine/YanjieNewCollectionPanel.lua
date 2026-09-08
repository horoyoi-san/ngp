-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNewCollectionPanel.lua
-- Decompiled from: 02015_YanjieNewCollectionPanel.lua_2eec52b5e45c.luajit

C_YanjieNewCollectionPanel = DefClass("C_YanjieNewCollectionPanel", C_YanjieNewCollectionPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewCollectionPanel = C_YanjieNewCollectionPanel
local M = C_YanjieNewCollectionPanel

M.OnAwake = function(self)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_YANJIE_CATEGORY_CHANGE] = self.CreateAction(self, "OnCategoryChange")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.CollectPage)
end

M.InitView = function(self, _)
	self.momentList = self.SubGroup.CommonNewYanjieListTemplateStore
	self.momentList.GetList = gSocialNetworkUtils.GetCollectionList

	self.momentList:StartRequest()
end

M.OnEnable = function(self)
end

M.OnDisable = function(self)
end
