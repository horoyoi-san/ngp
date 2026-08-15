C_RedDotDemoStore = DefClass("C_RedDotDemoStore", C_RedDotDemoStore, C_StoreGroup)
GroupName2Class.RedDotDemoStore = C_RedDotDemoStore
local M = C_RedDotDemoStore

function M:OnChildDotClick(redKey)
	local isSingleDotShow = SGUI.RedDotMgr.GetRedDotIsShown(redKey)

	print_debug("isSingleDotShow, redKey", isSingleDotShow, redKey)
	SGUI.RedDotMgr.LuaSetRedDot(not isSingleDotShow, "RedDotDemo.parent/" .. redKey)
end

function M:OnSingleDotClick(btn, data)
	local isSingleDotShow = SGUI.RedDotMgr.GetRedDotIsShown("RedDotDemo.single")

	SGUI.RedDotMgr.LuaSetRedDot(not isSingleDotShow, "RedDotDemo.single")

	if not isSingleDotShow then
		self.bindData.singleText = "点击关闭红点"
	else
		self.bindData.singleText = "点击打开红点"
	end
end

function M:ClosePanel()
	gPanelManager:Close(gPanelId.S_RED_DOT_DEMO)
end

function M:OnAwake()
	self.bindData.childDot1.luaClick = self:CreateActionWithArgs("OnChildDotClick", "RedDotDemo.child1")
	self.bindData.childDot2.luaClick = self:CreateActionWithArgs("OnChildDotClick", "RedDotDemo.child2")
	self.bindData.singleDot.luaClick = self:CreateAction("OnSingleDotClick")
	self.bindData.backBtn.luaClick = self:CreateAction("ClosePanel")
end

function M:OnShow(panelId, data)
	SGUI.RedDotMgr.LuaSetRedDot(true, "RedDotDemo.single")
end

function M:OnClose()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnGroupEnable()
	return
end
