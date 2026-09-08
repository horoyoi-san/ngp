-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\VolleyballGame\VolleyballControllerBase.lua
-- Decompiled from: 00633_VolleyballControllerBase.lua_9195ef604430.luajit

C_VolleyballControllerBase = DefClass("C_VolleyballControllerBase", C_VolleyballControllerBase)
local M = C_VolleyballControllerBase

M.ctor = function(self, character, gameInstance)
	self.gameInstance = gameInstance
	self.view = character
end

M.Init = function(self)
end

M.OnPossessionChange = function(self, team)
end

M.OnTargetChange = function(self, target)
end

M.OnCharacterStateChange = function(self, from, to)
end

M.OnDestroy = function(self)
end
