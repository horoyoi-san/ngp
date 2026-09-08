-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SetDisableButtonType.lua
-- Decompiled from: 00429_SetDisableButtonType.lua_209ee46ad58f.luajit

C_GuideBT_SetDisableButtonType = DefClass("C_GuideBT_SetDisableButtonType", C_GuideBT_SetDisableButtonType, C_GuideBT_ActionBase)
local M = C_GuideBT_SetDisableButtonType

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	local guideKey = self.guideKey:Eval()

	if string.is_null_or_empty(guideKey) then
		print_error("@huangzhecong SetDisableButtonType没有设置guideKey,guideId =", self.tree.guideId, "counterId =", self.tree.counterId)

		return
	end

	SGUI.GuideMgr.BlockGuideButton(guideKey, self.disableType)
end

M.OnExitRunning = function(self)
	local guideKey = self.guideKey:Eval()

	if string.is_null_or_empty(guideKey) then
		return
	end

	SGUI.GuideMgr.UnblockGuideButton(guideKey)
end
