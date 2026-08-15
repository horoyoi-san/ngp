local M = gBeggarManager or {}
M.IsInit = M.IsInit or false
M.BeggarStoreName = "BeggarPanelStore"
local MyPlayerManager = gCS.MyPlayerManager

function M:OnInit()
	if self.IsInit then
		return
	end

	self.IsInit = true
end

function M:OnStateTreeEnterWaitLoop()
	local beggarPanel = gStoreManager:GetStoreGroup(self.BeggarStoreName)

	if beggarPanel and self.isPanelShown then
		beggarPanel:OnStateTreeEnterWaitLoop()
	else
		FrameTimer.New(function ()
			gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, 117)
		end, 1):Start()
	end
end

function M:OnStateTreeEnterBeggingLoop()
	local beggarPanel = gStoreManager:GetStoreGroup(self.BeggarStoreName)

	if beggarPanel and self.isPanelShown and not beggarPanel:IsEndBegging() then
		beggarPanel:OnStateTreeEnterBeggingLoop()
	else
		FrameTimer.New(function ()
			gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, 116)
		end, 1):Start()
	end
end

function M:SetPanelShown(shown)
	self.isPanelShown = shown
end

function M:OnSyncSpiritBeggarJobData(spiritId, data)
	local beggarPanel = gStoreManager:GetStoreGroup(self.BeggarStoreName)

	if beggarPanel and self.isPanelShown then
		beggarPanel:OnSyncData(data)
	end
end

function M:OnSpotDataChange(spotId, npcLimit, npcProbability, npcIds)
	if MassAI.MassAIManager.Instance ~= nil then
		MassAI.MassAIManager.Instance:OnSpotDataChange(spotId, npcLimit, npcProbability, npcIds)
	end
end

function M:DonationPlayer(param)
	if param then
		self.donationPlayerId = param
	else
		local selfPid = gPlayerManager:GetLoginRolePid()
		local find = false

		for k, _ in pairs(gLinkManager.LinkMember) do
			if k ~= selfPid and not find then
				find = true
				self.donationPlayerId = k
			end
		end
	end

	if self.donationPlayerId then
		gMainPhoneUtils.ShowPhoneAppContent({
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.BeggarPayPanel
		})
	end
end

function M:OnOtherPlayerEndBegging(pid)
	if pid and self.donationPlayerId and self.donationPlayerId == pid and self.payPanel and self.payPanel.isShow then
		self.payPanel:OnExecuteExitAction()
	end
end

function M:ActivateRelatedAP(spotId)
	if MassAI.MassAIManager.Instance ~= nil then
		MassAI.MassAIManager.Instance:ActiveBeggarAP(spotId)
	end
end

function M:InactivateRelatedAP(spotId)
	if MassAI.MassAIManager.Instance ~= nil then
		MassAI.MassAIManager.Instance:InactiveAp(spotId)
	end
end

function M:OnAPNpcNumChanged(spotId, changedCount, totalCount)
	local beggarPanel = gStoreManager:GetStoreGroup(self.BeggarStoreName)

	if beggarPanel and beggarPanel.spot == spotId then
		gClientToGameDelegate:AskOnNpcAttractedByBeg(changedCount, totalCount)
	end
end

gBeggarManager = M
