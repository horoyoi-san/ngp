-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_RedDot.lua
-- Decompiled from: 02294_MapSystem_RedDot.lua_9f8a137d81a5.luajit

gMapSystem_RedDot = gMapSystem_RedDot or {}
local M = gMapSystem_RedDot
local Namespace = "BigMap"
local TemplateKey = "Base"

M.Init = function(self)
	self._scopeLeaves = {}
end

M.OnLogin = function(self)
	self:ClearAll()
end

M.OnLogout = function(self)
	self:ClearAll()
end

M.GetRootKey = function(self, scope)
	return Namespace .. "." .. scope
end

M.GetLeafKey = function(self, scope, category, id)
	return Namespace .. "." .. scope .. "." .. category .. "." .. tostring(id)
end

M.GetLeafPath = function(self, scope, category, id)
	return self:GetRootKey(scope) .. "/" .. self:GetLeafKey(scope, category, id)
end

M.SetLeaf = function(self, scope, category, id, isShown)
	local path = self:GetLeafPath(scope, category, id)
	self._scopeLeaves[scope] = self._scopeLeaves[scope] or {}
	self._scopeLeaves[scope][path] = true

	SGUI.RedDotMgr.LuaSetRedDot(isShown ~= true, path)
end

M.BindRoot = function(self, widget, scope)
	widget.redKey = self:GetRootKey(scope)
	widget.templateKey = TemplateKey
end

M.BindLeaf = function(self, widget, scope, category, id)
	widget.redKey = self:GetLeafKey(scope, category, id)
	widget.templateKey = TemplateKey
end

M.ClearWidget = function(self, widget)
	widget.redKey = ""
	widget.templateKey = ""
end

M.ClearScope = function(self, scope)
	local scopeLeaves = self._scopeLeaves[scope]

	if not scopeLeaves then
		return
	end

	for path in pairs(scopeLeaves) do
		SGUI.RedDotMgr.LuaSetRedDot(false, path)
	end

	self._scopeLeaves[scope] = nil
end

M.ClearAll = function(self)
	for _, scopeLeaves in pairs(self._scopeLeaves) do
		for path in pairs(scopeLeaves) do
			SGUI.RedDotMgr.LuaSetRedDot(false, path)
		end
	end

	self._scopeLeaves = {}
end

return M
