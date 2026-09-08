-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\GameplayHudProManager.lua
-- Decompiled from: 00729_GameplayHudProManager.lua_81ba76bc1023.luajit

local StaticProps = {}
C_GameplayHudProManager = DefClass("C_GameplayHudProManager", C_GameplayHudProManager, nil, StaticProps)
local M = C_GameplayHudProManager
local GameplayHudDescGroupConfig = LTConfig.GameplayHudDescGroupConfig
local CallbackType = {
	["X^p"] = 2,
	[">}\\xa5\\xba\\xaco"] = 1,
	["n\\x82\\x8d\\x9c\\x93"] = 3,
	["I\nRl"] = 4
}

M.ctor = function(self)
	self:OnInit()
end

M.OnInit = function(self)
	self.activeInstanceId = nil
end

M.OpenHud = function(self, instanceId, groupId, useSignal)
	if self.activeInstanceId == nil or gPanelManager:IsPanelShowing(gPanelId.GAMEPLAY_HUD_PRO_PANEL) or not GameplayHudDescGroupConfig.GetConfig(groupId or 0) then
		print_error("[C_GameplayHudProManager] OpenHud failed, instanceId =", instanceId, "groupId =", groupId)

		return
	end

	local fireEvent = function(callbackType, btnId)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnGameplayHudProCallback, {
			kind = callbackType,
			btnId = btnId or 0,
			entityId = instanceId
		})
	end

	local opened = gPanelManager:CheckShow(gPanelId.GAMEPLAY_HUD_PRO_PANEL, {
		["\\x8c13,q\\x92O\\xf48\\xae\\xbc"] = true,
		groupId = groupId,
		buttonCallback = function (btnId)
			if useSignal then
				gSpoonClientMgr:TryCallInnerSignal(instanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, tostring(btnId))
			else
				fireEvent(CallbackType.BUTTON, btnId)
			end
		end,
		backCallback = function ()
			fireEvent(CallbackType.BACK)
		end,
		closeCallback = function ()
			if self.activeInstanceId ~= instanceId then
				self.activeInstanceId = nil
			end

			fireEvent(CallbackType.CLOSE)
		end,
		showCallback = function ()
			fireEvent(CallbackType.SHOW)
		end
	})

	if opened then
		self.activeInstanceId = instanceId
	else
		print_error("[C_GameplayHudProManager] OpenHud failed, instanceId =", instanceId, "groupId =", groupId)
	end
end

M.CloseHud = function(self, instanceId)
	if self.activeInstanceId == instanceId then
		return
	end

	gPanelManager:Close(gPanelId.GAMEPLAY_HUD_PRO_PANEL)
end

gGameplayHudProManager = gGameplayHudProManager or C_GameplayHudProManager.new()
