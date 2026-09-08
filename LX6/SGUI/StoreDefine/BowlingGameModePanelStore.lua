-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingGameModePanelStore.lua
-- Decompiled from: 01682_BowlingGameModePanelStore.lua_a7390fe13e13.luajit

C_BowlingGameModePanelStore = DefClass("C_BowlingGameModePanelStore", C_BowlingGameModePanelStore, C_StoreGroup)
GroupName2Class.BowlingGameModePanelStore = C_BowlingGameModePanelStore
local M = C_BowlingGameModePanelStore

M.OnAwake = function(self)
	print_debug("BowlingGameModePanelStore OnAwake")
end

M.OnStart = function(self)
	print_debug("BowlingGameModePanelStore OnStart")

	self.bindData.BtnSingle.luaClick = self.CreateAction(self, "SelectModeSingle")
	self.bindData.BtnBattle.luaClick = self.CreateAction(self, "SelectModeBattle")
	self.bindData.BtnTech.luaClick = self.CreateAction(self, "SelectModeTech")
	self.bindData.BtnF.luaClick = self.CreateAction(self, "SelectExit")
end

M.OnDestroy = function(self)
end

M.OnShow = function(self, panelId, data)
	self.game = gBowlingGameManager.currentGame
end

M.OnUpdate = function(self)
end

M.OnRelease = function(self)
end

M.SelectModeSingle = function(self)
	self.game:ExecuteSelectModeSingle()
end

M.SelectModeBattle = function(self)
	self.game:ExecuteSelectModeBattle()
end

M.SelectModeTech = function(self)
	self.game:ExecuteSelectModeTech()
end

M.SelectExit = function(self)
	gBowlingGameManager:ExecuteExitGame()
end
