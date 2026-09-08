-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuideLinkCommon.lua
-- Decompiled from: 00434_GuideLinkCommon.lua_4be8c3d77f56.luajit

local M = {}

local ToEndConfig = function(t)
	if not t then
		return nil
	end

	local e = SGUI.GuideMgr.CreateEndConfig()

	if t.anchorMode == nil then
		e.anchorMode = t.anchorMode
	end

	if t.shape == nil then
		e.shape = t.shape
	end

	if t.extraOffset == nil then
		e.extraOffset = t.extraOffset
	end

	if t.sizeScale == nil then
		e.sizeScale = Vector2(t.sizeScale.x or 1, t.sizeScale.y or 1)
	end

	return e
end

M.Create = function(key1, key2, prefabPath, endpoint1, endpoint2, angle)
	return SGUI.GuideMgr.CreateLink(key1, key2, prefabPath, angle or 0, ToEndConfig(endpoint1), ToEndConfig(endpoint2))
end

M.Remove = function(linkUid)
	if linkUid and linkUid == 0 then
		SGUI.GuideMgr.RemoveLink(linkUid)
	end
end

return M
