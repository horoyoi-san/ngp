-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RedDotDemoStore.lua
-- Decompiled from: 00903_RedDotDemoStore.lua_800da0dcb5df.luajit

C_RedDotDemoStore = DefClass("C_RedDotDemoStore", C_RedDotDemoStore, C_StoreGroup)
GroupName2Class.RedDotDemoStore = C_RedDotDemoStore
local M = C_RedDotDemoStore

M.OnChildDotClick = function(self, redKey)
	local isSingleDotShow = SGUI.RedDotMgr.GetRedDotIsShown(redKey)

	print_debug("isSingleDotShow, redKey", isSingleDotShow, redKey)
	SGUI.RedDotMgr.LuaSetRedDot(not isSingleDotShow, "RedDotDemo.parent/" .. redKey)
end

M.OnSingleDotClick = function(self, btn, data)
	local isSingleDotShow = SGUI.RedDotMgr.GetRedDotIsShown("RedDotDemo.single")

	SGUI.RedDotMgr.LuaSetRedDot(not isSingleDotShow, "RedDotDemo.single")

	if not isSingleDotShow then
		self.bindData.singleText = "点击关闭红点"
	else
		self.bindData.singleText = "点击打开红点"
	end
end

M.ClosePanel = function(self)
	gPanelManager:Close(gPanelId.S_RED_DOT_DEMO)
end

M.OnAwake = function(self)
	self.bindData.childDot1.luaClick = self.CreateActionWithArgs(self, "OnChildDotClick", "RedDotDemo.child1")
	self.bindData.childDot2.luaClick = self.CreateActionWithArgs(self, "OnChildDotClick", "RedDotDemo.child2")
	self.bindData.singleDot.luaClick = self.CreateAction(self, "OnSingleDotClick")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "ClosePanel")
end

M.OnShow = function(self, panelId, data)
	SGUI.RedDotMgr.LuaSetRedDot(true, "RedDotDemo.single")
end

M.OnClose = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnGroupEnable = function(self)
end
