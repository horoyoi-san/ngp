-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ShowUGuideCommon.lua
-- Decompiled from: 00396_ShowUGuideCommon.lua_b8e818c57e0a.luajit

local UGuideActionCommon = require("LX6/Guide/Behaviour/Action/UGuideActionCommon")
local GuideParamsCommon = require("LX6/Guide/Behaviour/Action/GuideParamsCommon")
local M = {
	OnCreate = function (self, debugName, displayHandler)
		UGuideActionCommon.InitMatchState(self)

		self.eventHandlers = {}

		if displayHandler == nil then
			self.eventHandlers[gEventConstants.LANGUAGE_CHANGE] = function ()
				self:RefreshTipText()
				self:RefreshSmartLineTipText()
			end
		end

		self.renderSmartLineHandler = function(guideId, component)
			if guideId ~= self.runtimeGuideId then
				self.smartLineTipComponent = component

				self:RefreshSmartLineTipText()
			end
		end

		local resolvedDisplayHandler = nil

		if displayHandler ~= nil then
			resolvedDisplayHandler = nil
		elseif displayHandler ~= false then
			resolvedDisplayHandler = function(guideId, component)
				if guideId ~= self.runtimeGuideId then
					self.tipComponent = component

					self:RefreshTipText()
				end
			end
		else
			resolvedDisplayHandler = displayHandler
		end

		UGuideActionCommon.BuildHandlers(self, function ()
			return self.runtimeGuideId
		end, debugName or "ShowUGuide", resolvedDisplayHandler, {
			[gNewGuideMgr.SEventType.RenderGuideSmartLine] = self.renderSmartLineHandler
		})
	end,
	RefreshTipText = function (self, getGuideText)
		if not self.tipComponent or gCS.LuaUtils.IsNull(self.tipComponent) then
			return
		end

		self.tipStore = gStoreManager:GetStoreGroup("DefaultUGuideStore"):GetStoreByWidget(self.tipComponent)

		if not self.tipStore then
			return
		end

		self.guideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.tipStore.guideTextBase)
		self.tipStore.mode = 1
		self.guideTextStore.guideText = getGuideText()

		if self.popVideoId and self.popVideoId == 0 then
			self.tipStore.videoCtrl = 1

			self.tipStore.videoPlayer:Init()
			self.tipStore.videoPlayer:PlayVideo(self.popVideoId, true)
		else
			self.tipStore.videoCtrl = 0
		end
	end
}

M.RefreshSmartLineTipText = function(self, getGuideText)
	if not self.smartLineTipComponent or gCS.LuaUtils.IsNull(self.smartLineTipComponent) then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup("UGuideSmartLineStore")

	if not storeGroup then
		return
	end

	self.smartLineTipStore = storeGroup.GetStoreByWidget(storeGroup, self.smartLineTipComponent)

	if not self.smartLineTipStore then
		return
	end

	self.smartLineGuideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.smartLineTipStore.guideTextBase)
	self.smartLineGuideTextStore.guideText = getGuideText()
end

M.GetGuideText = function(self, noConfigError)
	if not self.guideTextData then
		print_error(noConfigError)

		return ""
	end

	local textData = self.guideTextData:Eval()

	return gGuideGlyph:GetGuideRichText(textData)
end

M.OnTick = function(self)
	return UGuideActionCommon.DefaultOnTick(self)
end

M.OnActiveDeviceChange = function(self, getGuideText)
	M.RefreshTipText(self, getGuideText)
	M.RefreshSmartLineTipText(self, getGuideText)

	if self.autoNavigate and self.runtimeGuideId then
		SGUI.GuideMgr.TryLocateDirect(self.runtimeGuideId, true)
	end
end

M.OnEnterRunning = function(self, runtimeGuideKey, noGuideIdError)
	self.runtimeGuideId = runtimeGuideKey

	gMessageManager:RegisterEventHandlers(self.eventHandlers)

	if self.sguideEventHandlers then
		for eventType, handler in pairs(self.sguideEventHandlers) do
			if handler then
				gNewGuideMgr:RegisterSGUIGuideEvent(eventType, handler)
			end
		end
	end

	if self.runtimeGuideId then
		UGuideActionCommon.OpenGuide(self, self.runtimeGuideId, self.isSupportParallel, self.dontDisplay)
	elseif noGuideIdError then
		print_error(noGuideIdError)
	end
end

M.OnExitRunning = function(self)
	UGuideActionCommon.EndMatching(self)

	self.tipComponent = nil
	self.smartLineTipComponent = nil
	self.tipStore = nil
	self.guideTextStore = nil
	self.smartLineTipStore = nil
	self.smartLineGuideTextStore = nil

	if self.uGuideParam and self.realGuideKey then
		GuideParamsCommon.ClearFromGuideMgr(self.realGuideKey)
	end

	self.realGuideKey = nil
	self.runtimeGuideId = nil

	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	self._nextState = nil

	if self.sguideEventHandlers then
		for eventType, handler in pairs(self.sguideEventHandlers) do
			if handler then
				gNewGuideMgr:UnRegisterSGUIGuideEvent(eventType, handler)
			end
		end
	end

	SGUI.GuideMgr.CloseActiveGuide()
end

return M
