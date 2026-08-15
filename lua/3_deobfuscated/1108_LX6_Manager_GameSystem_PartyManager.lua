C_PartyManager = DefClass("C_PartyManager", C_PartyManager, nil, nil)
local M = C_PartyManager

function M:StartSingleParty(partyId, npcIdList)
	npcIdList = npcIdList or {}

	gClientToGameDelegate:StartSingleParty(partyId, npcIdList).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

function M:OnSyncResponse(response, npcIdList)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_RESPONSE, {
		response = response,
		npcIdList = npcIdList
	})
end

function M:OnSyncSettleData(settleData)
	gPanelManager:Close(gPanelId.PARTY_LIVE_STREAM_PANEL)
	gPanelManager:CheckShow(gPanelId.PARTY_END_PANEL, settleData)
end

gPartyManager = gPartyManager or C_PartyManager.new()
