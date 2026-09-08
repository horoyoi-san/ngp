-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ShowSmartLine.lua
-- Decompiled from: 00436_ShowSmartLine.lua_6c3878c7fd54.luajit

C_GuideBT_ShowSmartLine = DefClass("C_GuideBT_ShowSmartLine", C_GuideBT_ShowSmartLine, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowSmartLine

M.OnCreate = function(self)
	self._smartLineUid = 0
	self.smartLineTipComponent = nil

	self._languageChangeHandler = function()
		self:RefreshSmartLineTipText()
	end

	self._renderSmartLineHandler = function(guideId, component)
		if guideId ~= self.guideKey:Eval() .. "-New" then
			self.smartLineTipComponent = component

			self:RefreshSmartLineTipText()
		end
	end
end

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	M.base.OnEnterRunning(self)

	local csConfig = self:CreateConfig(self.config)
	self._smartLineUid = SGUI.GuideMgr.CreateSmartLine(self.guideKey:Eval(), csConfig)

	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, self._languageChangeHandler)
	gNewGuideMgr:RegisterSGUIGuideEvent(gNewGuideMgr.SEventType.RenderGuideSmartLine, self._renderSmartLineHandler)
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)
	gMessageManager:RemoveMessageListener(gEventConstants.LANGUAGE_CHANGE, self._languageChangeHandler)
	gNewGuideMgr:UnRegisterSGUIGuideEvent(gNewGuideMgr.SEventType.RenderGuideSmartLine, self._renderSmartLineHandler)

	if self._smartLineUid == 0 then
		SGUI.GuideMgr.RemoveSmartLine(self._smartLineUid)

		self._smartLineUid = 0
	end

	self.smartLineTipComponent = nil
	self.smartLineTipStore = nil
	self.smartLineGuideTextStore = nil
end

M.CreateConfig = function(self, config)
	local csConfig = SGUI.GuideMgr.CreateSmartLineConfig()
	csConfig.smartLineTipUrl = config.smartLineTipUrl
	csConfig.smartLineUrl = config.smartLineUrl
	csConfig.endMaskUrl = config.endMaskUrl
	csConfig.smartLineTipAnchor = config.smartLineTipAnchor
	csConfig.smartRegionTabIndex = config.smartRegionTabIndex
	csConfig.minDistanceY = config.minDistanceY
	csConfig.minDistanceX = config.minDistanceX
	csConfig.turningOuterAngle = config.turningOuterAngle
	csConfig.enableOverrideLineWidth = config.enableOverrideLineWidth
	csConfig.overrideLineWidth = config.overrideLineWidth
	csConfig.endMaskScale = config.endMaskScale

	return csConfig
end

M.RefreshSmartLineTipText = function(self)
	if not self.smartLineTipComponent or gCS.LuaUtils.IsNull(self.smartLineTipComponent) then
		return
	end

	self.smartLineTipStore = gStoreManager:GetStoreGroup(self.smartLineTipComponent.Store):GetStoreByWidget(self.smartLineTipComponent)

	if not self.smartLineTipStore then
		return
	end

	self.smartLineTipStore.guideText = self:GetGuideText()
	self.smartLineGuideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.smartLineTipStore.guideTextBase)
	self.smartLineGuideTextStore.guideText = self:GetGuideText()
end

M.GetGuideText = function(self)
	if not self.guideTextData then
		print_error("#NoCreateIssue ShowSmartLine启用了Tip但是没有配置文本数据")

		return ""
	end

	local textData = self.guideTextData:Eval()

	return gGuideGlyph:GetGuideRichText(textData)
end
