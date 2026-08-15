C_GuideBT_FloatingGuideText = DefClass("C_GuideBT_FloatingGuideText", C_GuideBT_FloatingGuideText, C_GuideBT_ActionBase)
local M = C_GuideBT_FloatingGuideText

function M:OnTick()
	return gGuideNodeState.Running
end

function M:Run()
	if not self.guideTextData then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:ShowText()
	else
		self:ShowTopText()
	end
end

function M:OnEnterRunning()
	if self.guideTextData == nil then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的FloatingGuideText没有设置guideText")

		return
	end
end

function M:OnExitRunning()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:HideText()
	else
		self:HideTopText()
	end
end

function M:ShowTopText()
	if not self.IsShow then
		gPanelManager:CheckShow(gPanelId.S_FLOATING_GUIDE_TEXT_TOP, {
			Param = {
				guideTextData = self.guideTextData:Eval()
			}
		})

		self.IsShow = true
	end
end

function M:ShowText()
	if not self.IsShow then
		if self.isFrontLayer then
			gPanelManager:CheckShow(gPanelId.FLOATING_GUIDE_TEXT_FRONT, {
				guideTextData = self.guideTextData:Eval()
			})
		else
			gPanelManager:CheckShow(gPanelId.FLOATING_GUIDE_TEXT, {
				guideTextData = self.guideTextData:Eval()
			})
		end

		self.IsShow = true
	end
end

function M:HideTopText()
	if self.IsShow then
		gPanelManager:Close(gPanelId.S_FLOATING_GUIDE_TEXT_TOP)

		self.IsShow = nil
	end
end

function M:HideText()
	if self.IsShow then
		if self.isFrontLayer then
			gPanelManager:Close(gPanelId.FLOATING_GUIDE_TEXT_FRONT)
		else
			gPanelManager:Close(gPanelId.FLOATING_GUIDE_TEXT)
		end

		self.IsShow = nil
	end
end
