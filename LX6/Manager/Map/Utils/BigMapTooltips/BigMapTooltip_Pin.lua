-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_Pin.lua
-- Decompiled from: 01009_BigMapTooltip_Pin.lua_0d8a84064ca3.luajit

C_BigMapTooltip_Pin = DefClass("C_BigMapTooltip_Pin", C_BigMapTooltip_Pin, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Pin

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "pinInfo") then
		return
	end

	self:GetStore("MapPinTooltipStore")

	local info = self.tooltipInfo.pinInfo
	self.store.outOfArea = info.outOfArea and 1 or 0

	if not info.outOfArea then
		self.SetUpLocation(self)

		self.store.pinCount = "(" .. tostring(info.pinCount) .. "/" .. tostring(info.maxPinCount) .. ")"
	end

	if self.bigMap.bindData.isMapIndoor <= 0 then
		self.store.indoorCtrl = 1
	else
		self.store.indoorCtrl = 0
	end
end

local PIN = 0
local DELETE_PIN = 1

M.SetUpActions = function(self, store, actions, blockReason)
	self.containerStore.showPin = 0

	if blockReason or not actions or #actions ~= 0 then
		store.showMainBtn = self.HIDE_BTN

		return
	end

	store.showMainBtn = self.SHOW_BTN
	store.clickMain = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[1], self)
	store.mainBtnText = gMapUIUtils.GetElementActionName(actions[1])

	if not actions[2] then
		store.showPin = self.HIDE_PIN

		print_error("BigMapTooltip_Pin:SetUpActions: No Pin Action provided in actions,element:\n" .. gGpsTools.GetGpsDebugDesc(self.element.instanceId))
	else
		store.showPin = self.SHOW_PIN
		local isDelete = actions[2] ~= gMapSystemElementAction.DeletePin

		if isDelete then
			store.pinType = DELETE_PIN
			store.clickDelete = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[2], self)
			store.deleteBtnText = gMapUIUtils.GetElementActionName(actions[2])
		else
			store.pinType = PIN
			store.clickPin = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[2], self)
			store.pinBtnText = gMapUIUtils.GetElementActionName(actions[2])
		end
	end
end
