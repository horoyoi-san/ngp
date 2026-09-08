-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PalmKingStartPanelStore.lua
-- Decompiled from: 01069_PalmKingStartPanelStore.lua_7815b9e204ea.luajit

C_PalmKingStartPanelStore = DefClass("C_PalmKingStartPanelStore", C_PalmKingStartPanelStore, C_StoreGroup)
GroupName2Class.PalmKingStartPanelStore = C_PalmKingStartPanelStore
local M = C_PalmKingStartPanelStore

M.OnShow = function(self, panelId, data)
	gPanelManager:CheckShow(gPanelId.COMMON_GAMEPLAY_START_PANEL, {
		playId = LTConfig.GameplayHudDescBeginConfig.PalmKing,
		customData = data and data[3],
		cancelCb = function ()
			gPalmKingAction:ReturnToPosition()
		end
	})
	gPanelManager:Close(panelId)
end
