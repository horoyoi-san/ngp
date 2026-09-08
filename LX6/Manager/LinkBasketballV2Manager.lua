-- Original chunk: @Lua\LuaFiles\LX6\Manager\LinkBasketballV2Manager.lua
-- Decompiled from: 02268_LinkBasketballV2Manager.lua_50653adaeb58.luajit

local M = {}

M.OnEnterBasketballField = function(self)
	gMainMenuMgr:SetState(LTConfig.UnitStateConfig.HideMiniMap, true)
	self:SetBanButton()
	gPanelManager:Close(gPanelId.S_TEAM_MAIN_PANEL)
	gPanelManager:SetActiveById(gPanelId.SYSTEM_CONTROLS, false)
end

M.OnExitBasketballField = function(self)
	gMainMenuMgr:SetState(LTConfig.UnitStateConfig.HideMiniMap, false)
	self:ClearBanButton()
	gTeamManager:RefreshHudUIState()
	gPanelManager:SetActiveById(gPanelId.SYSTEM_CONTROLS, true)
	gMessageManager:SendMessage(gEventConstants.SWITCH_BASKETBALL_SHOOTING_EXIT, {
		["\\x8b<\\xc1\\xb5]#\\xe4Z\\xc3\\xeb7VP\\xc6\\xa4\\xc2"] = true,
		["*9\\xfcz\\x8c\\xde9\\xa5*\\xe2\\xfb\\xe7`\\xfe"] = true,
		["\\xd0\\xc82'\\xf4"] = true
	})
end

M.SetBanButton = function(self)
	if not self.buttonBanId then
		self.buttonBanId = gStoreButtonMgr:RegisterOperation({
			["\\xca\\xcf\t\r\\xf5"] = 5,
			["\\xbb\\xa3\\xa4x7\\xea*"] = 0,
			groupId = LTConfig.HudDescGroupConfig.FERRISWHEEL
		})
	end
end

M.ClearBanButton = function(self)
	if self.buttonBanId then
		gStoreButtonMgr:UnRegisterOperation(self.buttonBanId)

		self.buttonBanId = nil
	end
end

gLinkBasketballV2Manager = M
