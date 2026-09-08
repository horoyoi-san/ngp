-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\PlayerMovementInput.lua
-- Decompiled from: 00496_PlayerMovementInput.lua_5a9b576f4931.luajit

C_GuideBT_PlayerMovementInput = DefClass("C_GuideBT_PlayerMovementInput", C_GuideBT_PlayerMovementInput, C_GuideBT_ResourceBase)
local M = C_GuideBT_PlayerMovementInput

M.OnCreate = function(self)
	self._x = 0
	self._y = 0

	self._moveListener = function(e)
		local v = e.ReadValueVector2(e)
		self._x = v.x
		self._y = v.y
	end

	LX6.Manager.GameInputManager.RegisterInputCallback(gInputActionId.MOVEMENT_MOVE, self._moveListener)
end

M.Eval = function(self)
	self.x.val = self._x
	self.y.val = self._y
end

M.OnDestroy = function(self)
	if self._moveListener then
		LX6.Manager.GameInputManager.UnregisterInputCallback(gInputActionId.MOVEMENT_MOVE, self._moveListener)

		self._moveListener = nil
	end
end
