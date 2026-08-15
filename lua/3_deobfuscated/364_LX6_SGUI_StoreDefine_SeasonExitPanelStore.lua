local SeasonRaidRaidConfig = LTConfig.SeasonRaidRaidConfig
local MessageConfig = LTConfig.MessageConfig
C_SeasonExitPanelStore = DefClass("C_SeasonExitPanelStore", C_SeasonExitPanelStore, C_StoreGroup)
GroupName2Class.SeasonExitPanelStore = C_SeasonExitPanelStore
local M = C_SeasonExitPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self:RegisterButtons()
end

function M:OnShow(panelId, data)
	local raidId = gRaidDataManager.RaidInstanceId

	for i = 0, SeasonRaidRaidConfig.count - 1 do
		local raidCfg = SeasonRaidRaidConfig.LoadAt(i)

		if raidCfg.RaidId == raidId then
			self.bindData.nameText = raidCfg.Name

			break
		end
	end
end

function M:RegisterButtons()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnClick")
	self.bindData.settleBtn.luaClick = self:CreateAction("OnSettleBtnClick")
end

function M:OnCloseBtnClick()
	gPanelManager:Close(self.m_Id)
end

function M:OnExitBtnClick()
	gClientToGameDelegate:AskLeaveRaid(gRaidDataManager.RaidInstanceId)
end

function M:OnSettleBtnClick()
	self.bindData.settleBtn.interactable = false

	gClientToGameSceneDelegate:AskEndSeasonRaid().Callback = function (err)
		if err ~= MessageConfig.Ok then
			self.bindData.settleBtn.interactable = true

			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end
	end
end
