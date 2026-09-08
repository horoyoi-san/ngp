-- Original chunk: @Lua\LuaFiles\LX6\Guide\Base\NodeBase.lua
-- Decompiled from: 00374_NodeBase.lua_dcfdb9da4445.luajit

C_GuideBT_NodeBase = DefClass("C_GuideBT_NodeBase", C_GuideBT_NodeBase)
local M = C_GuideBT_NodeBase

M.OnCreate = function(self)
end

M.OnDestroy = function(self)
end

M.AddField = function(self, fieldName, value, resProxy)
	local fieldProxy = C_GuideBT_FieldProxy.new()
	self[fieldName] = fieldProxy

	if resProxy then
		fieldProxy.resProxy = resProxy
	else
		fieldProxy.val = value
	end
end

M.GetBlackboard = function(self)
	return self.tree.blackboard
end

M.GetCounterDic = function(self)
	local counterDic = self.GetBlackboard(self).counterDic

	if not counterDic then
		counterDic = {}
		self.GetBlackboard(self).counterDic = counterDic
	end

	return counterDic
end
