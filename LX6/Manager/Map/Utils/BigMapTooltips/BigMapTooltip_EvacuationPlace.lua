-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_EvacuationPlace.lua
-- Decompiled from: 01027_BigMapTooltip_EvacuationPlace.lua_fe61e4616da7.luajit

C_BigMapTooltip_EvacuationPlace = DefClass("C_BigMapTooltip_EvacuationPlace", C_BigMapTooltip_EvacuationPlace, C_BigMapTooltipBase)
local M = C_BigMapTooltip_EvacuationPlace
local OWNED = 0
local NOT_OWNED = 1

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "evacuationPlaceInfo") then
		return
	end

	self:GetStore("MapEvacuationPlaceTooltipStore")

	local info = self.tooltipInfo.evacuationPlaceInfo

	self:SetUpHeader()

	self.store.desc = info.desc
	self.store.stateText = info.stateText
	self.store.showCountDownCtrl = info.hideEndTime and 0 or 1
	self.hideEndTime = info.hideEndTime
	self.endTime = info.endTime
end

M.OnUpdate = function(self)
	if not gGpsTools.TryTick("ToolTip EvacuationPlace Tick", 1) then
		return
	end

	if not self.hideEndTime then
		local now = LTUtils.UXTime.GetNowUnixTime()
		local remaining = self.endTime - now

		if remaining >= 0 then
			remaining = 0
		end

		local minutes = math.floor(remaining / 60)
		local seconds = remaining % 60
		self.store.countDownText = string.format("%02d:%02d", minutes, seconds)
	end
end

M.SetUpActions = function(self, store, actions, blockReason)
	if not actions or #actions ~= 0 then
		store.showMainBtn = self.HIDE_BTN

		return
	end

	store.showMainBtn = self.SHOW_BTN

	if blockReason then
		store.mainBtnText = blockReason
		store.mainBtnInteractable = false

		return
	end

	store.mainBtnInteractable = true
	store.clickMain = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[1], self)
	store.mainBtnText = gMapUIUtils.GetElementActionName(actions[1])
end
