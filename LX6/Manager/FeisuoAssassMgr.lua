-- Original chunk: @Lua\LuaFiles\LX6\Manager\FeisuoAssassMgr.lua
-- Decompiled from: 00356_FeisuoAssassMgr.lua_b31f25dc9c26.luajit

local DataSet = require("LX6/DataBind/DataSet")
local HackingConfig = LTConfig.HackingConfig
local M = gFeisuoAssassMgr or {}
M.InteractionInfo = DataSet.New({
	["\\xbc5.v\\x89D\\xcb6\\xa9\\xad"] = false,
	["\\xb3;#4]\\x93D\\xd4.\\x83\\xbd"] = 0,
	["U_Ǯ\\x91\\x8c\\xd9\\xed"] = -1
})

M.IsFeiSuoBattleCrouch = function(self)
	if ulong.Greater(self.InteractionInfo.LockEnemyId, 0) then
		return true
	end

	return false
end

M.SetCanFeiSuoCrouchAss = function(self, canAssassin, LockEnemyId, target1, target2)
	self.canAssassin = canAssassin
	self.InteractionInfo.LockEnemyId = LockEnemyId
	self.feisuoCrouchAssTarget1 = target1
	self.feisuoCrouchAssTarget2 = target2

	self:UpdateAssinateGps()
end

M.UpdateAssinateGps = function(self)
	local show = false

	if self.InteractionInfo then
		local configId = HackingConfig.PaokuFly

		if self:IsFeiSuoBattleCrouch() then
			configId = HackingConfig.FeiSuoEnemyCrouch
		else
			configId = nil
		end

		show = configId == nil
	end

	if show then
		gHackManager:AddFocusDangerEffect(self.feisuoCrouchAssTarget1, self.feisuoCrouchAssTarget2)
	else
		gHackManager:ClearDangerEffectData()
	end
end

gFeisuoAssassMgr = M

return gFeisuoAssassMgr
