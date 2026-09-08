-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\NightRunManager.lua
-- Decompiled from: 00727_NightRunManager.lua_ce2193373526.luajit

local M = gNightRunManager or {}
local NightRunManager = L50.Gameplay.NightRun.NightRunManager

M.StartPlay = function(self, trackId)
	NightRunManager.StartPlay(trackId)

	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		gameplayControlStore:StopGameplayByType(gHUDGameplayType.NIGHT_RUN)
		gameplayControlStore:StartGameplayByType(gHUDGameplayType.NIGHT_RUN)
	end
end

M.StopPlay = function(self, success)
	NightRunManager.StopPlay(success ~= true)
end

M.CloseHud = function(self)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		gameplayControlStore:StopGameplayByType(gHUDGameplayType.NIGHT_RUN)
	end
end

M.OnHudDataChanged = function(self, data)
	local store = gStoreManager:GetStoreGroup("NightRunPanelStore")

	if store then
		store:RefreshRunData(data)
	end
end

M.OnSettlement = function(self, data)
	self:CloseHud()

	self.settlementData = data

	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = data.success,
		callback = function ()
			gNightRunManager:PushSettlementPopup(data)
		end
	})
end

M.PushSettlementPopup = function(self, data)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.NightRunSettlement, data)
end

M.FormatDistance = function(self, distance)
	return string.format("%.2f", (distance or 0) / 1000)
end

M.FormatDuration = function(self, duration)
	duration = math.floor(duration or 0)

	return string.format("%02d:%02d", math.floor(duration / 60), duration % 60)
end

M.OnClickSpeedUp = function(self)
	NightRunManager.SpeedUp()
end

M.OnClickSpeedDown = function(self)
	NightRunManager.SpeedDown()
end

M.SetBreathHolding = function(self, holding)
	NightRunManager.SetBreathHolding(holding ~= true)
end

M.OnClickGreet = function(self)
	NightRunManager.Greet()
end

M.IsLevelLocked = function(self)
	return NightRunManager.IsLevelLocked
end

gNightRunManager = M
