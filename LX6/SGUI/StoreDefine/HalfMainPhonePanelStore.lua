-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HalfMainPhonePanelStore.lua
-- Decompiled from: 02112_HalfMainPhonePanelStore.lua_def9709379a0.luajit

C_HalfMainPhonePanelStore = DefClass("C_HalfMainPhonePanelStore", C_HalfMainPhonePanelStore, C_MainPhonePanelStore)
GroupName2Class.HalfMainPhonePanelStore = C_HalfMainPhonePanelStore
local M = C_HalfMainPhonePanelStore

M.ctor = function(self)
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId

	self.InitModel(self, args)
	self.InitView(self, args)
end

M.OnGroupEnable = function(self)
	gClientUtils.PlayPhoneAction()

	gCS.TransitionMgr.showMainCube = true
end

M.OnExitClick = function(self)
	self.bindData.maskActive = true
	local closeAnimationName = "S_Vx_MainPhonePanel_close"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)

	self.playCloseAnimationCo = coroutine.start(function ()
		coroutine.wait(clipTime)
		gPanelManager:Close(self.panelId)
	end)
end

M.OnAppItemClick = function(self, appId)
	gMainPhoneUtils.OnAppItemClick(appId)
end

M.OnClose = function(self)
	self.ReleaseMap(self)

	self.hasPlayInitExpAnimation = nil
	self.playCloseAnimationCo = coroutine.stop(self.playCloseAnimationCo)
	self.playExpProgressAnimationCo = coroutine.stop(self.playExpProgressAnimationCo)
end
