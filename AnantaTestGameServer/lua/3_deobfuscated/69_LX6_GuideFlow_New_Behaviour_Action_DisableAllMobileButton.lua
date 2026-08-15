C_GuideBT_DisableAllMobileButton = DefClass("C_GuideBT_DisableAllMobileButton", C_GuideBT_DisableAllMobileButton, C_GuideBT_ActionBase)
local M = C_GuideBT_DisableAllMobileButton

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	self:SetDisableButton(true)
end

function M:OnExitRunning()
	self:SetDisableButton(false)
end

function M:SetDisableButton(isDisable)
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
		elseif not self.isNeedExcept or self.except ~= v then
			gCoreHudUIManager:OnSetSkillBtnState(v, "isGuideOpen", isDisable, true)
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_GUIDE_REFRESH_FEISUO, isDisable)
end
