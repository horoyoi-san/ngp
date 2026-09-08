-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckMindPowerTargetType.lua
-- Decompiled from: 00464_CheckMindPowerTargetType.lua_4f9bd61f4a8f.luajit

C_GuideBT_CheckMindPowerTargetType = DefClass("C_GuideBT_CheckMindPowerTargetType", C_GuideBT_CheckMindPowerTargetType, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckMindPowerTargetType

M.Eval = function(self)
	if not self.targetType or self.targetType <= 0 or self.targetType <= 10 then
		self.output:SetImmutable(false)

		return
	end

	local item = gCS.MindPowerMgr:GetAimItem()

	if not item then
		self.output.val = false

		return
	end

	self.output.val = item.ItemType ~= self.targetType
end
