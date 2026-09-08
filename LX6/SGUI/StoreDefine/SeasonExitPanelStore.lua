-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SeasonExitPanelStore.lua
-- Decompiled from: 00875_SeasonExitPanelStore.lua_e1b9d94f63b4.luajit

local SeasonRaidRaidConfig = LTConfig.SeasonRaidRaidConfig
local MessageConfig = LTConfig.MessageConfig
C_SeasonExitPanelStore = DefClass("C_SeasonExitPanelStore", C_SeasonExitPanelStore, C_StoreGroup)
GroupName2Class.SeasonExitPanelStore = C_SeasonExitPanelStore
local M = C_SeasonExitPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.RegisterButtons(self)
end

M.OnShow = function(self, panelId, data)
	local raidId = gRaidDataManager.RaidInstanceId

	for i = 0, SeasonRaidRaidConfig.count - 1 do
		local raidCfg = SeasonRaidRaidConfig.LoadAt(i)

		if raidCfg.RaidId ~= raidId then
			self.bindData.nameText = raidCfg.Name

			break
		end
	end
end

M.RegisterButtons = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnClick")
	self.bindData.settleBtn.luaClick = self.CreateAction(self, "OnSettleBtnClick")
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnExitBtnClick = function(self)
	gClientToGameDelegate:AskLeaveRaid(gRaidDataManager.RaidInstanceId)
end

M.OnSettleBtnClick = function(self)
	self.bindData.settleBtn.interactable = false
	slot1 = gClientToGameSceneDelegate

	slot1:AskEndSeasonRaid().Callback = function (err)
		if err == MessageConfig.Ok then
			self.bindData.settleBtn.interactable = true

			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end
	end
end
