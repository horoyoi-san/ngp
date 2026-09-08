-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\DisableAllMobileButton.lua
-- Decompiled from: 00404_DisableAllMobileButton.lua_5a3a0611e759.luajit

C_GuideBT_DisableAllMobileButton = DefClass("C_GuideBT_DisableAllMobileButton", C_GuideBT_DisableAllMobileButton, C_GuideBT_ActionBase)
local M = C_GuideBT_DisableAllMobileButton

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	self.SetDisableButton(self, true)
end

M.OnExitRunning = function(self)
	self.SetDisableButton(self, false)
end

M.SetDisableButton = function(self, isDisable)
	local validBtn = {
		1,
		2,
		3,
		4,
		5,
		6
	}
	local btnEnum = LX6.Units.Module.ButtonInfoEnum

	for k, v in pairs(btnEnum) do
		if not table.contains(validBtn, v) then
			-- Nothing
		elseif not self.isNeedExcept or self.except == v then
			gCoreHudUIManager:OnSetSkillBtnState(v, "isGuideOpen", isDisable, true)
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_GUIDE_REFRESH_FEISUO, isDisable)
end
