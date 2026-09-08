-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GameplayDiaoCheStore.lua
-- Decompiled from: 01741_GameplayDiaoCheStore.lua_a7d0d366800a.luajit

C_GameplayDiaoCheStore = DefClass("C_GameplayDiaoCheStore", C_GameplayDiaoCheStore, C_StoreGroup)
GroupName2Class.GameplayDiaoCheStore = C_GameplayDiaoCheStore
local M = C_GameplayDiaoCheStore

M.ctor = function(self)
	self.crane = nil
end

M.OnAwake = function(self)
	self.bindData.LeftRotate.luaPress = self.CreateAction(self, self.OnLeftRotatePressDown)
	self.bindData.LeftRotate.luaRelease = self.CreateAction(self, self.OnLeftRotatePressUp)
	self.bindData.RightRotate.luaPress = self.CreateAction(self, self.OnRightRotatePressDown)
	self.bindData.RightRotate.luaRelease = self.CreateAction(self, self.OnRightRotatePressUp)
	self.bindData.dpadXRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnDpadX)
	self.bindData.dpadYRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnDpadY)
	self.bindData.Exit.luaClick = self.CreateAction(self, self.ClickClose)
end

M.OnDestroy = function(self)
	self.crane = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, craneMono)
	self.crane = craneMono
end

M.OnLeftRotatePressDown = function(self)
	self.crane:PressRotate(-1)
end

M.OnLeftRotatePressUp = function(self)
	self.crane:PressRotate(0)
end

M.OnRightRotatePressDown = function(self)
	self.crane:PressRotate(1)
end

M.OnRightRotatePressUp = function(self)
	self.crane:PressRotate(0)
end

M.OnClose = function(self)
end

M.OnStart = function(self)
end

M.OnDpadX = function(self, ctx)
	local dir = ctx.performed and ctx:ReadValueFloat()
end

M.OnDpadY = function(self, ctx)
	local dir = ctx.performed and ctx:ReadValueFloat()
end

M.ClickClose = function(self)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	gameplayControlStore:StopGameplayByType(gHUDGameplayType.DIAO_CHE)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnGadgetReceiveSignal, {
		["PNkgO:!"] = "\\x8e\\xbf\\x88x?\\xf06"
	})
end
