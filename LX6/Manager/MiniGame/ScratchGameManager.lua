-- Original chunk: @Lua\LuaFiles\LX6\Manager\MiniGame\ScratchGameManager.lua
-- Decompiled from: 00612_ScratchGameManager.lua_4874c226befc.luajit

C_ScratchGameManager = DefClass("C_ScratchGameManager", C_ScratchGameManager)
local M = C_ScratchGameManager

M.Show = function(self, gadgetUid, scratchSubType, result)
	if result ~= nil or gPanelManager:IsPanelShowing(gPanelId.SCRATCHCARD_PANEL) then
		return
	end

	local entity = gGadgetManager:GetEntitySearchByInstanceId(gadgetUid)

	if entity ~= nil then
		L50.L50App.Scene.SpoonGadgetManager:RegisterWaitLoad({
			gadgetUid
		}, function (_)
			self:Show(gadgetUid, scratchSubType, result)
		end)

		return
	end

	local uiPivot = entity.gameObject.transform:Find("ItemViewNode/UIPose")

	if uiPivot ~= nil then
		print_error("[ScratchCard] UIPose not found, gadgetUid=" .. tostring(gadgetUid))

		return
	end

	gPanelManager:CheckShow(gPanelId.SCRATCHCARD_PANEL, {
		[3] = entity,
		gamePlayId = scratchSubType,
		scratchStartResult = result,
		uiPivot = uiPivot
	})
end

M.OnSyncGameGroundZoneInfo = function(self, zoneInfo)
	self:Show(zoneInfo.GadgetUId, zoneInfo.ScratchSubType, zoneInfo.ScratchStartResult)
end

gScratchGameManager = gScratchGameManager or C_ScratchGameManager.new()
