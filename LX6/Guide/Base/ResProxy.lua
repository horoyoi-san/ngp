-- Original chunk: @Lua\LuaFiles\LX6\Guide\Base\ResProxy.lua
-- Decompiled from: 00382_ResProxy.lua_27905f341127.luajit

C_GuideBT_ResProxy = {}
local M = C_GuideBT_ResProxy
local mt = {
	__index = M
}

M.NewProxy = function()
	local proxy = setmetatable({}, mt)

	return proxy
end

M.Eval = function(self)
	if self.immutable then
		return self.val
	end

	self.res:Eval()

	return self.val
end

M.SetImmutable = function(self, val)
	self.immutable = true
	self.val = val
end

M.SetValue = function(self, val)
	self.val = val
end
