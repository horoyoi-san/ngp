-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Composite\DeviceBranch.lua
-- Decompiled from: 00386_DeviceBranch.lua_64d112f7435a.luajit

C_GuideBT_DeviceBranch = DefClass("C_GuideBT_DeviceBranch", C_GuideBT_DeviceBranch, C_GuideBT_CompositeBase)
local M = C_GuideBT_DeviceBranch
local GameDevice = SGUI.GameDevice

GetBranchIndex = function()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return 1
	end

	local device = gCS.LuaUtils.GetActiveDevice()

	if device ~= GameDevice.KeyboardMouse then
		return 2
	elseif device ~= GameDevice.PlayStation then
		return 3
	elseif device ~= GameDevice.Xbox then
		return 4
	end

	return 1
end

M.OnTick = function(self)
	local index = GetBranchIndex()
	local child = self.children[index]

	if child then
		return child.DoTick(child)
	end

	return gGuideNodeState.Success
end
