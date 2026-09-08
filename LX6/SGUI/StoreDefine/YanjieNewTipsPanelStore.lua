-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNewTipsPanelStore.lua
-- Decompiled from: 01255_YanjieNewTipsPanelStore.lua_b49c71f29829.luajit

C_YanjieNewTipsPanelStore = DefClass("C_YanjieNewTipsPanelStore", C_YanjieNewTipsPanelStore, C_StoreGroup)
GroupName2Class.YanjieNewTipsPanelStore = C_YanjieNewTipsPanelStore
local M = C_YanjieNewTipsPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.hitBtn.luaClick = self.CreateAction(self, self.OnItemClick)
end

M.OnDestroy = function(self)
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId

	self.InitModel(self, args)
	self.InitView(self)
end

M.InitModel = function(self, args)
	self.areaIndex = args and args.areaIndex
end

M.InitView = function(self)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		self:ClosePanel()
	end)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnItemClick = function(self)
	gMainPhoneFunctionAction.OpenSocialNetwork()
	self.ClosePanel(self)
end
