-- Original chunk: @Lua\LuaGen\AutoGen\ClientToGameGMDelegate.lua
-- Decompiled from: 00070_ClientToGameGMDelegate.lua_612bb8d9e90e.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGameGMDelegate = invoker.New(invoker)

ClientToGameGMDelegate.Sender = function()
	return NetworkManager.LuaGameRpcProcessor
end

SerializerHelper.GmListSpeechDetail_Serializer = function(writer, speechname)
	writer.WriteString(writer, speechname, false, "GmListSpeechDetail.speechName", 0)
end

ClientToGameGMDelegate.GmListSpeechDetail = function(self, speechname)
	return self.Invoke(self, 65002546, SerializerHelper.GmListSpeechDetail_Serializer, speechname)
end

SerializerHelper.GmSetFashionOwnedCount_Serializer = function(writer, fashionid, count)
	SerializeBase.WritePrimitive(writer, fashionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmSetFashionOwnedCount = function(self, fashionid, count)
	return self.Invoke(self, 65006910, SerializerHelper.GmSetFashionOwnedCount_Serializer, fashionid, count)
end

SerializerHelper.GmStartInviteRideNpc_Serializer = function(writer, npcid)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmStartInviteRideNpc = function(self, npcid)
	return self.Invoke(self, 65008383, SerializerHelper.GmStartInviteRideNpc_Serializer, npcid)
end

SerializerHelper.GmSetFavorNpcOneDaySchedule_Serializer = function(writer, activityid)
	SerializeBase.WritePrimitive(writer, activityid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetFavorNpcOneDaySchedule = function(self, activityid)
	return self.Invoke(self, 65009467, SerializerHelper.GmSetFavorNpcOneDaySchedule_Serializer, activityid)
end

SerializerHelper.GmCustomLinkCreate_Serializer = function(writer, tag, raidid)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(tag, 22, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmCustomLinkCreate = function(self, tag, raidid)
	return self.Invoke(self, 65011331, SerializerHelper.GmCustomLinkCreate_Serializer, tag, raidid)
end

SerializerHelper.GmAddPoliceViolation_Serializer = function(writer, type)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddPoliceViolation = function(self, type)
	return self.Invoke(self, 65015252, SerializerHelper.GmAddPoliceViolation_Serializer, type)
end

SerializerHelper.GmResetGachaPityHistory_Serializer = function(writer, ruleid)
	SerializeBase.WritePrimitive(writer, ruleid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmResetGachaPityHistory = function(self, ruleid)
	return self.Invoke(self, 65016019, SerializerHelper.GmResetGachaPityHistory_Serializer, ruleid)
end

SerializerHelper.GmPublishAllTriggerTuite_Serializer = function(writer)
end

ClientToGameGMDelegate.GmPublishAllTriggerTuite = function(self)
	return self.Invoke(self, 65017536, SerializerHelper.GmPublishAllTriggerTuite_Serializer)
end

SerializerHelper.GMResetPersonalZoneInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GMResetPersonalZoneInfo = function(self)
	return self.Invoke(self, 65022086, SerializerHelper.GMResetPersonalZoneInfo_Serializer)
end

SerializerHelper.GMEnableFallingDownOnDeath_Serializer = function(writer, isenable)
	SerializeBase.WritePrimitive(writer, isenable, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GMEnableFallingDownOnDeath = function(self, isenable)
	return self.Invoke(self, 65022582, SerializerHelper.GMEnableFallingDownOnDeath_Serializer, isenable)
end

SerializerHelper.GmDirectCreateOC_Serializer = function(writer, name, gender, age, description, story, identity, speechname, labels)
	writer.WriteString(writer, name, false, "GmDirectCreateOC.name", 0)
	writer.WriteString(writer, gender, false, "GmDirectCreateOC.gender", 0)
	writer.WriteString(writer, age, true, "GmDirectCreateOC.age", 0)
	writer.WriteString(writer, description, true, "GmDirectCreateOC.description", 0)
	writer.WriteString(writer, story, true, "GmDirectCreateOC.story", 0)
	writer.WriteString(writer, identity, true, "GmDirectCreateOC.identity", 0)
	writer.WriteString(writer, speechname, false, "GmDirectCreateOC.speechName", 0)
	writer.WriteString(writer, labels, true, "GmDirectCreateOC.labels", 0)
end

ClientToGameGMDelegate.GmDirectCreateOC = function(self, name, gender, age, description, story, identity, speechname, labels)
	return self.Invoke(self, 65023015, SerializerHelper.GmDirectCreateOC_Serializer, name, gender, age, description, story, identity, speechname, labels)
end

SerializerHelper.GmHouseParking_Serializer = function(writer, houseidlist, vehicleidlist)
	SerializeBase.WriteList7Bit(writer, houseidlist, writer.WriteUInt32, 0, "houseidlist", false, 0, nil)
	SerializeBase.WriteList7Bit(writer, vehicleidlist, writer.WriteUInt32, 0, "vehicleidlist", false, 0, nil)
end

ClientToGameGMDelegate.GmHouseParking = function(self, houseidlist, vehicleidlist)
	return self.Invoke(self, 65027125, SerializerHelper.GmHouseParking_Serializer, houseidlist, vehicleidlist)
end

SerializerHelper.GmLeaveScene_Serializer = function(writer, raidid)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmLeaveScene = function(self, raidid)
	return self.Invoke(self, 65028409, SerializerHelper.GmLeaveScene_Serializer, raidid)
end

SerializerHelper.GmBuyBoatTicketDouble_Serializer = function(writer, conductorid, npccultivationid)
	SerializeBase.WritePrimitive(writer, conductorid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmBuyBoatTicketDouble = function(self, conductorid, npccultivationid)
	return self.Invoke(self, 65031218, SerializerHelper.GmBuyBoatTicketDouble_Serializer, conductorid, npccultivationid)
end

SerializerHelper.GmGetCurrentPartyStatus_Serializer = function(writer)
end

ClientToGameGMDelegate.GmGetCurrentPartyStatus = function(self)
	return self.Invoke(self, 65036015, SerializerHelper.GmGetCurrentPartyStatus_Serializer)
end

SerializerHelper.GmAllTaskReset_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAllTaskReset = function(self, eventid)
	return self.Invoke(self, 65038423, SerializerHelper.GmAllTaskReset_Serializer, eventid)
end

SerializerHelper.GmBreakdownItems_Serializer = function(writer, breakdownids, iteminstanceids, counts)
	SerializeBase.WriteList7Bit(writer, breakdownids, writer.WriteUInt32, 0, "breakdownids", false, 0, nil)
	SerializeBase.WriteList7Bit(writer, iteminstanceids, writer.WriteUInt64, 0, "iteminstanceids", false, 0, nil)
	SerializeBase.WriteList7Bit(writer, counts, writer.WriteUInt32, 0, "counts", false, 0, nil)
end

ClientToGameGMDelegate.GmBreakdownItems = function(self, breakdownids, iteminstanceids, counts)
	return self.Invoke(self, 65040597, SerializerHelper.GmBreakdownItems_Serializer, breakdownids, iteminstanceids, counts)
end

SerializerHelper.GmUnlockComputerEmail_Serializer = function(writer, emailid)
	SerializeBase.WritePrimitive(writer, emailid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnlockComputerEmail = function(self, emailid)
	return self.Invoke(self, 65047286, SerializerHelper.GmUnlockComputerEmail_Serializer, emailid)
end

SerializerHelper.GMSummonGangMember_Serializer = function(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMSummonGangMember = function(self, templateid)
	return self.Invoke(self, 65047403, SerializerHelper.GMSummonGangMember_Serializer, templateid)
end

SerializerHelper.GmSetColoringCollectionScore_Serializer = function(writer, score)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetColoringCollectionScore = function(self, score)
	return self.Invoke(self, 65047972, SerializerHelper.GmSetColoringCollectionScore_Serializer, score)
end

SerializerHelper.GmCreateTeam_Serializer = function(writer)
end

ClientToGameGMDelegate.GmCreateTeam = function(self)
	return self.Invoke(self, 65048282, SerializerHelper.GmCreateTeam_Serializer)
end

SerializerHelper.GmTriggerDailyChat_Serializer = function(writer, forcetime)
	SerializeBase.WritePrimitive(writer, forcetime, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmTriggerDailyChat = function(self, forcetime)
	return self.Invoke(self, 65049418, SerializerHelper.GmTriggerDailyChat_Serializer, forcetime)
end

SerializerHelper.GmTradeAddOrder_Serializer = function(writer, tradeitemid, count, price)
	SerializeBase.WritePrimitive(writer, tradeitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, price, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTradeAddOrder = function(self, tradeitemid, count, price)
	return self.Invoke(self, 65051595, SerializerHelper.GmTradeAddOrder_Serializer, tradeitemid, count, price)
end

SerializerHelper.GmChangeUseSystemName_Serializer = function(writer, usesystem)
	SerializeBase.WritePrimitive(writer, usesystem, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmChangeUseSystemName = function(self, usesystem)
	return self.Invoke(self, 65056167, SerializerHelper.GmChangeUseSystemName_Serializer, usesystem)
end

SerializerHelper.GmLeaveTeam_Serializer = function(writer)
end

ClientToGameGMDelegate.GmLeaveTeam = function(self)
	return self.Invoke(self, 65057059, SerializerHelper.GmLeaveTeam_Serializer)
end

SerializerHelper.GmResetBuildHouseIndoor_Serializer = function(writer, houseid, resetfloor)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, resetfloor, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmResetBuildHouseIndoor = function(self, houseid, resetfloor)
	return self.Invoke(self, 65060785, SerializerHelper.GmResetBuildHouseIndoor_Serializer, houseid, resetfloor)
end

SerializerHelper.GmRemoveFishingGear_Serializer = function(writer, uniqueid)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmRemoveFishingGear = function(self, uniqueid)
	return self.Invoke(self, 65061643, SerializerHelper.GmRemoveFishingGear_Serializer, uniqueid)
end

SerializerHelper.GmChangeBuilding_Serializer = function(writer, buildingid, floorid, enter)
	SerializeBase.WritePrimitive(writer, buildingid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, floorid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmChangeBuilding = function(self, buildingid, floorid, enter)
	return self.Invoke(self, 65063058, SerializerHelper.GmChangeBuilding_Serializer, buildingid, floorid, enter)
end

SerializerHelper.GmUnbindOCSpeech_Serializer = function(writer, ocid)
	SerializeBase.WritePrimitive(writer, ocid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmUnbindOCSpeech = function(self, ocid)
	return self.Invoke(self, 65065715, SerializerHelper.GmUnbindOCSpeech_Serializer, ocid)
end

SerializerHelper.GmRollChaosFishContent_Serializer = function(writer, times)
	SerializeBase.WritePrimitive(writer, times, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmRollChaosFishContent = function(self, times)
	return self.Invoke(self, 65067117, SerializerHelper.GmRollChaosFishContent_Serializer, times)
end

SerializerHelper.GmForceZoneMigration_Serializer = function(writer, rankconfigid, newzoneid)
	SerializeBase.WritePrimitive(writer, rankconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, newzoneid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmForceZoneMigration = function(self, rankconfigid, newzoneid)
	return self.Invoke(self, 65068567, SerializerHelper.GmForceZoneMigration_Serializer, rankconfigid, newzoneid)
end

SerializerHelper.GmPurchaseElement_Serializer = function(writer, bartenderid, elementid, purchasecount)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, purchasecount, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmPurchaseElement = function(self, bartenderid, elementid, purchasecount)
	return self.Invoke(self, 65068929, SerializerHelper.GmPurchaseElement_Serializer, bartenderid, elementid, purchasecount)
end

SerializerHelper.GMPSNSetting_Serializer = function(writer, ispsnplayer, psnonly)
	SerializeBase.WritePrimitive(writer, ispsnplayer, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, psnonly, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GMPSNSetting = function(self, ispsnplayer, psnonly)
	return self.Invoke(self, 65071783, SerializerHelper.GMPSNSetting_Serializer, ispsnplayer, psnonly)
end

SerializerHelper.GMTriggerAllBotsFallingDown_Serializer = function(writer)
end

ClientToGameGMDelegate.GMTriggerAllBotsFallingDown = function(self)
	return self.Invoke(self, 65071785, SerializerHelper.GMTriggerAllBotsFallingDown_Serializer)
end

SerializerHelper.GmAddPaokuLimit_Serializer = function(writer, limits, sourcetype, sourceid)
	SerializeBase.WriteList7Bit(writer, limits, writer.WriteUInt32, 0, "limits", false, 0, nil)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sourcetype, 44, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, sourceid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmAddPaokuLimit = function(self, limits, sourcetype, sourceid)
	return self.Invoke(self, 65072171, SerializerHelper.GmAddPaokuLimit_Serializer, limits, sourcetype, sourceid)
end

SerializerHelper.GmRemoveFurniture_Serializer = function(writer, furnitureid)
	SerializeBase.WritePrimitive(writer, furnitureid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmRemoveFurniture = function(self, furnitureid)
	return self.Invoke(self, 65073693, SerializerHelper.GmRemoveFurniture_Serializer, furnitureid)
end

SerializerHelper.GmUnlockCountry_Serializer = function(writer, countryid)
	SerializeBase.WritePrimitive(writer, countryid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnlockCountry = function(self, countryid)
	return self.Invoke(self, 65076449, SerializerHelper.GmUnlockCountry_Serializer, countryid)
end

SerializerHelper.GmStartOnlineParty_Serializer = function(writer, partyid, hasgift, giftitemid, giftitemcount, lottery, lotteryitemid, lotteryitemcount, ownerjoinlottery)
	SerializeBase.WritePrimitive(writer, partyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hasgift, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, giftitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, giftitemcount, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, lottery, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, lotteryitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, lotteryitemcount, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ownerjoinlottery, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmStartOnlineParty = function(self, partyid, hasgift, giftitemid, giftitemcount, lottery, lotteryitemid, lotteryitemcount, ownerjoinlottery)
	return self.Invoke(self, 65080498, SerializerHelper.GmStartOnlineParty_Serializer, partyid, hasgift, giftitemid, giftitemcount, lottery, lotteryitemid, lotteryitemcount, ownerjoinlottery)
end

SerializerHelper.GmSetSpiritWearFashionHiddenParts_Serializer = function(writer, spiritid, hiddenparts)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hiddenparts, writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmSetSpiritWearFashionHiddenParts = function(self, spiritid, hiddenparts)
	return self.Invoke(self, 65080511, SerializerHelper.GmSetSpiritWearFashionHiddenParts_Serializer, spiritid, hiddenparts)
end

SerializerHelper.GmStartMatchInTeam_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmStartMatchInTeam = function(self, gameid)
	return self.Invoke(self, 65082608, SerializerHelper.GmStartMatchInTeam_Serializer, gameid)
end

SerializerHelper.GmKickMyself_Serializer = function(writer)
end

ClientToGameGMDelegate.GmKickMyself = function(self)
	return self.Invoke(self, 65083148, SerializerHelper.GmKickMyself_Serializer)
end

SerializerHelper.GmUnlockRandomEvent_Serializer = function(writer)
end

ClientToGameGMDelegate.GmUnlockRandomEvent = function(self)
	return self.Invoke(self, 65083657, SerializerHelper.GmUnlockRandomEvent_Serializer)
end

SerializerHelper.GMAskPlayWithAnimal_Serializer = function(writer, animalid, favor, dailylimit)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, favor, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, dailylimit, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GMAskPlayWithAnimal = function(self, animalid, favor, dailylimit)
	return self.Invoke(self, 65083701, SerializerHelper.GMAskPlayWithAnimal_Serializer, animalid, favor, dailylimit)
end

SerializerHelper.GmAddMeccaGrandpaPart_Serializer = function(writer, partid, count)
	SerializeBase.WritePrimitive(writer, partid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddMeccaGrandpaPart = function(self, partid, count)
	return self.Invoke(self, 65084754, SerializerHelper.GmAddMeccaGrandpaPart_Serializer, partid, count)
end

SerializerHelper.GmLeaveRoom_Serializer = function(writer)
end

ClientToGameGMDelegate.GmLeaveRoom = function(self)
	return self.Invoke(self, 65085423, SerializerHelper.GmLeaveRoom_Serializer)
end

SerializerHelper.GMAddCredit_Serializer = function(writer, credittoadd)
	SerializeBase.WritePrimitive(writer, credittoadd, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMAddCredit = function(self, credittoadd)
	return self.Invoke(self, 65087117, SerializerHelper.GMAddCredit_Serializer, credittoadd)
end

SerializerHelper.GmJobTake_Serializer = function(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmJobTake = function(self, jobclassid)
	return self.Invoke(self, 65091612, SerializerHelper.GmJobTake_Serializer, jobclassid)
end

SerializerHelper.GmClaimGift_Serializer = function(writer, giftid)
	SerializeBase.WritePrimitive(writer, giftid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmClaimGift = function(self, giftid)
	return self.Invoke(self, 65092413, SerializerHelper.GmClaimGift_Serializer, giftid)
end

SerializerHelper.GmGangBossSetSummonLimitNum_Serializer = function(writer, summonlimitnum)
	SerializeBase.WritePrimitive(writer, summonlimitnum, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmGangBossSetSummonLimitNum = function(self, summonlimitnum)
	return self.Invoke(self, 65098249, SerializerHelper.GmGangBossSetSummonLimitNum_Serializer, summonlimitnum)
end

SerializerHelper.GmUnlockFogMapPoi_Serializer = function(writer, poiid)
	SerializeBase.WritePrimitive(writer, poiid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnlockFogMapPoi = function(self, poiid)
	return self.Invoke(self, 65099509, SerializerHelper.GmUnlockFogMapPoi_Serializer, poiid)
end

SerializerHelper.GmLinkReplyInvite_Serializer = function(writer, accept)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmLinkReplyInvite = function(self, accept)
	return self.Invoke(self, 65104602, SerializerHelper.GmLinkReplyInvite_Serializer, accept)
end

SerializerHelper.GmSetTaskCounterValue_Serializer = function(writer, taskid, index, current, value)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, current, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmSetTaskCounterValue = function(self, taskid, index, current, value)
	return self.Invoke(self, 65108307, SerializerHelper.GmSetTaskCounterValue_Serializer, taskid, index, current, value)
end

SerializerHelper.GmDumpRankingState_Serializer = function(writer, rankconfigid)
	SerializeBase.WritePrimitive(writer, rankconfigid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmDumpRankingState = function(self, rankconfigid)
	return self.Invoke(self, 65108482, SerializerHelper.GmDumpRankingState_Serializer, rankconfigid)
end

SerializerHelper.GmUnlockYacht_Serializer = function(writer, yachtid)
	SerializeBase.WritePrimitive(writer, yachtid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnlockYacht = function(self, yachtid)
	return self.Invoke(self, 65110539, SerializerHelper.GmUnlockYacht_Serializer, yachtid)
end

SerializerHelper.GmJobEnd_Serializer = function(writer)
end

ClientToGameGMDelegate.GmJobEnd = function(self)
	return self.Invoke(self, 65110787, SerializerHelper.GmJobEnd_Serializer)
end

SerializerHelper.GmClearDailyChatInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearDailyChatInfo = function(self)
	return self.Invoke(self, 65111087, SerializerHelper.GmClearDailyChatInfo_Serializer)
end

SerializerHelper.GmSettleTierSeason_Serializer = function(writer)
end

ClientToGameGMDelegate.GmSettleTierSeason = function(self)
	return self.Invoke(self, 65116017, SerializerHelper.GmSettleTierSeason_Serializer)
end

SerializerHelper.GmFastForwardFavorNpcCommute_Serializer = function(writer, agenttag, remainingdistance)
	SerializeBase.WritePrimitive(writer, agenttag, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, remainingdistance, writer.WriteSingle, 0)
end

ClientToGameGMDelegate.GmFastForwardFavorNpcCommute = function(self, agenttag, remainingdistance)
	return self.Invoke(self, 65116895, SerializerHelper.GmFastForwardFavorNpcCommute_Serializer, agenttag, remainingdistance)
end

SerializerHelper.GmCompleteMatchGameEventDefine_Serializer = function(writer, matchgameids)
	SerializeBase.WriteList7Bit(writer, matchgameids, writer.WriteUInt32, 0, "matchgameids", false, 0, nil)
end

ClientToGameGMDelegate.GmCompleteMatchGameEventDefine = function(self, matchgameids)
	return self.Invoke(self, 65117838, SerializerHelper.GmCompleteMatchGameEventDefine_Serializer, matchgameids)
end

SerializerHelper.GmAddFurniture_Serializer = function(writer, furnitureid, count)
	SerializeBase.WritePrimitive(writer, furnitureid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddFurniture = function(self, furnitureid, count)
	return self.Invoke(self, 65118207, SerializerHelper.GmAddFurniture_Serializer, furnitureid, count)
end

SerializerHelper.ClientToGameGmQA_Serializer = function(writer, code, args)
	writer.WriteString(writer, code, false, "ClientToGameGmQA.code", 0)
	writer.WriteString(writer, args, true, "ClientToGameGmQA.args", 0)
end

ClientToGameGMDelegate.ClientToGameGmQA = function(self, code, args)
	return self.Invoke(self, 65121714, SerializerHelper.ClientToGameGmQA_Serializer, code, args)
end

SerializerHelper.GmForceResetWorldBattle_Serializer = function(writer, gadgetid)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmForceResetWorldBattle = function(self, gadgetid)
	return self.Invoke(self, 65123662, SerializerHelper.GmForceResetWorldBattle_Serializer, gadgetid)
end

SerializerHelper.GmStartSingleMatch_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmStartSingleMatch = function(self, gameid)
	return self.Invoke(self, 65125136, SerializerHelper.GmStartSingleMatch_Serializer, gameid)
end

SerializerHelper.GmLinkInfos_Serializer = function(writer)
end

ClientToGameGMDelegate.GmLinkInfos = function(self)
	return self.Invoke(self, 65126047, SerializerHelper.GmLinkInfos_Serializer)
end

SerializerHelper.GmReplyInvitePlayerInteractionAction_Serializer = function(writer, replystate)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(replystate, 21, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmReplyInvitePlayerInteractionAction = function(self, replystate)
	return self.Invoke(self, 65130679, SerializerHelper.GmReplyInvitePlayerInteractionAction_Serializer, replystate)
end

SerializerHelper.GmItemExchange_Serializer = function(writer, exchangeid, count)
	SerializeBase.WritePrimitive(writer, exchangeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmItemExchange = function(self, exchangeid, count)
	return self.Invoke(self, 65131827, SerializerHelper.GmItemExchange_Serializer, exchangeid, count)
end

SerializerHelper.GmUpgradeCompoundStation_Serializer = function(writer, stationid, ignoreconsume)
	SerializeBase.WritePrimitive(writer, stationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ignoreconsume, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmUpgradeCompoundStation = function(self, stationid, ignoreconsume)
	return self.Invoke(self, 65135505, SerializerHelper.GmUpgradeCompoundStation_Serializer, stationid, ignoreconsume)
end

SerializerHelper.GmRemoveFashions_Serializer = function(writer, fashionidlist)
	SerializeBase.WriteList7Bit(writer, fashionidlist, writer.WriteUInt32, 0, "fashionidlist", false, 0, nil)
end

ClientToGameGMDelegate.GmRemoveFashions = function(self, fashionidlist)
	return self.Invoke(self, 65136255, SerializerHelper.GmRemoveFashions_Serializer, fashionidlist)
end

SerializerHelper.GmClearCharacterDialogRecord_Serializer = function(writer, characterdialogid)
	SerializeBase.WritePrimitive(writer, characterdialogid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearCharacterDialogRecord = function(self, characterdialogid)
	return self.Invoke(self, 65136260, SerializerHelper.GmClearCharacterDialogRecord_Serializer, characterdialogid)
end

SerializerHelper.GmDivinerSkipAppealStage_Serializer = function(writer)
end

ClientToGameGMDelegate.GmDivinerSkipAppealStage = function(self)
	return self.Invoke(self, 65138484, SerializerHelper.GmDivinerSkipAppealStage_Serializer)
end

SerializerHelper.GmResetHackPosts_Serializer = function(writer)
end

ClientToGameGMDelegate.GmResetHackPosts = function(self)
	return self.Invoke(self, 65138882, SerializerHelper.GmResetHackPosts_Serializer)
end

SerializerHelper.GmChangeSafeArea_Serializer = function(writer, areaid, enter)
	SerializeBase.WritePrimitive(writer, areaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmChangeSafeArea = function(self, areaid, enter)
	return self.Invoke(self, 65139946, SerializerHelper.GmChangeSafeArea_Serializer, areaid, enter)
end

SerializerHelper.SendPlayerMailBatch_Serializer = function(writer, mailcfgid, pid, count)
	SerializeBase.WritePrimitive(writer, mailcfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.SendPlayerMailBatch = function(self, mailcfgid, pid, count)
	return self.Invoke(self, 65142642, SerializerHelper.SendPlayerMailBatch_Serializer, mailcfgid, pid, count)
end

SerializerHelper.GmSetWeather_Serializer = function(writer, weatherid)
	SerializeBase.WritePrimitive(writer, weatherid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetWeather = function(self, weatherid)
	return self.Invoke(self, 65142873, SerializerHelper.GmSetWeather_Serializer, weatherid)
end

SerializerHelper.GmActiveBadgeEffect_Serializer = function(writer, spiritid, badgeid, enable)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, badgeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmActiveBadgeEffect = function(self, spiritid, badgeid, enable)
	return self.Invoke(self, 65143509, SerializerHelper.GmActiveBadgeEffect_Serializer, spiritid, badgeid, enable)
end

SerializerHelper.GmClearPopularity_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearPopularity = function(self)
	return self.Invoke(self, 65144896, SerializerHelper.GmClearPopularity_Serializer)
end

SerializerHelper.GmFixRaidTime_Serializer = function(writer, hour, minute, clear)
	SerializeBase.WritePrimitive(writer, hour, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, minute, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, clear, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmFixRaidTime = function(self, hour, minute, clear)
	return self.Invoke(self, 65145300, SerializerHelper.GmFixRaidTime_Serializer, hour, minute, clear)
end

SerializerHelper.GmClearVehicleRadioContentCd_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearVehicleRadioContentCd = function(self)
	return self.Invoke(self, 65145616, SerializerHelper.GmClearVehicleRadioContentCd_Serializer)
end

SerializerHelper.GmCreateTaskAiVehicle_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmCreateTaskAiVehicle = function(self, taskid)
	return self.Invoke(self, 65147854, SerializerHelper.GmCreateTaskAiVehicle_Serializer, taskid)
end

SerializerHelper.GmAskCreateTeam_Serializer = function(writer)
end

ClientToGameGMDelegate.GmAskCreateTeam = function(self)
	return self.Invoke(self, 65152024, SerializerHelper.GmAskCreateTeam_Serializer)
end

SerializerHelper.GmCreateAndAcceptTruckJobOrder_Serializer = function(writer, type, cargoid, npcid, pickupid, deliveryid, accepttime, submittime, cargoid2, pickupid2)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cargoid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, pickupid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, deliveryid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, accepttime, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, submittime, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, cargoid2, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pickupid2, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmCreateAndAcceptTruckJobOrder = function(self, type, cargoid, npcid, pickupid, deliveryid, accepttime, submittime, cargoid2, pickupid2)
	return self.Invoke(self, 65152993, SerializerHelper.GmCreateAndAcceptTruckJobOrder_Serializer, type, cargoid, npcid, pickupid, deliveryid, accepttime, submittime, cargoid2, pickupid2)
end

SerializerHelper.GmQueryLifeScheduleNpcHistory_Serializer = function(writer, agenttag, maxevents, beforerecordid)
	SerializeBase.WritePrimitive(writer, agenttag, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maxevents, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, beforerecordid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmQueryLifeScheduleNpcHistory = function(self, agenttag, maxevents, beforerecordid)
	return self.Invoke(self, 65157218, SerializerHelper.GmQueryLifeScheduleNpcHistory_Serializer, agenttag, maxevents, beforerecordid)
end

SerializerHelper.GmFastCreateTeamAndStartGame_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmFastCreateTeamAndStartGame = function(self, gameid)
	return self.Invoke(self, 65159448, SerializerHelper.GmFastCreateTeamAndStartGame_Serializer, gameid)
end

SerializerHelper.GmStartMatchVote_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmStartMatchVote = function(self, gameid)
	return self.Invoke(self, 65162357, SerializerHelper.GmStartMatchVote_Serializer, gameid)
end

SerializerHelper.GmDoResetAccept_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmDoResetAccept = function(self, taskid)
	return self.Invoke(self, 65163969, SerializerHelper.GmDoResetAccept_Serializer, taskid)
end

SerializerHelper.GmGetAllTierDetails_Serializer = function(writer)
end

ClientToGameGMDelegate.GmGetAllTierDetails = function(self)
	return self.Invoke(self, 65175373, SerializerHelper.GmGetAllTierDetails_Serializer)
end

SerializerHelper.GmSetOrnamentalFishPlaced_Serializer = function(writer, uniqueid, isplaced)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isplaced, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmSetOrnamentalFishPlaced = function(self, uniqueid, isplaced)
	return self.Invoke(self, 65176118, SerializerHelper.GmSetOrnamentalFishPlaced_Serializer, uniqueid, isplaced)
end

SerializerHelper.GmUnlockMultiverseAll_Serializer = function(writer, id, unlocktype)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(unlocktype, 3, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmUnlockMultiverseAll = function(self, id, unlocktype)
	return self.Invoke(self, 65176242, SerializerHelper.GmUnlockMultiverseAll_Serializer, id, unlocktype)
end

SerializerHelper.GmSetRankScore_Serializer = function(writer, score)
	SerializeBase.WritePrimitive(writer, score, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmSetRankScore = function(self, score)
	return self.Invoke(self, 65177212, SerializerHelper.GmSetRankScore_Serializer, score)
end

SerializerHelper.GMRemoveSpiritSummonAgentWheelWeapon_Serializer = function(writer, wheelid, weaponid)
	SerializeBase.WritePrimitive(writer, wheelid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMRemoveSpiritSummonAgentWheelWeapon = function(self, wheelid, weaponid)
	return self.Invoke(self, 65178624, SerializerHelper.GMRemoveSpiritSummonAgentWheelWeapon_Serializer, wheelid, weaponid)
end

SerializerHelper.GmCancelPlayerInteractionAction_Serializer = function(writer)
end

ClientToGameGMDelegate.GmCancelPlayerInteractionAction = function(self)
	return self.Invoke(self, 65181554, SerializerHelper.GmCancelPlayerInteractionAction_Serializer)
end

SerializerHelper.GmAddWeaponSkinList_Serializer = function(writer, skinids)
	SerializeBase.WriteList7Bit(writer, skinids, writer.WriteUInt32, 0, "skinids", false, 0, nil)
end

ClientToGameGMDelegate.GmAddWeaponSkinList = function(self, skinids)
	return self.Invoke(self, 65182958, SerializerHelper.GmAddWeaponSkinList_Serializer, skinids)
end

SerializerHelper.GmCompletedSubQuest_Serializer = function(writer, subquestid)
	SerializeBase.WritePrimitive(writer, subquestid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmCompletedSubQuest = function(self, subquestid)
	return self.Invoke(self, 65185342, SerializerHelper.GmCompletedSubQuest_Serializer, subquestid)
end

SerializerHelper.GmLinkInvite_Serializer = function(writer, friendpid, mode, doublecheck)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, doublecheck, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmLinkInvite = function(self, friendpid, mode, doublecheck)
	return self.Invoke(self, 65188977, SerializerHelper.GmLinkInvite_Serializer, friendpid, mode, doublecheck)
end

SerializerHelper.GmSetVehicleRadioNextSongContent_Serializer = function(writer, contenttype, radiocontentid, startcontentid, endcontentid, songid)
	SerializeBase.WritePrimitive(writer, contenttype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, radiocontentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, startcontentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endcontentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, songid, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmSetVehicleRadioNextSongContent = function(self, contenttype, radiocontentid, startcontentid, endcontentid, songid)
	return self.Invoke(self, 65190747, SerializerHelper.GmSetVehicleRadioNextSongContent_Serializer, contenttype, radiocontentid, startcontentid, endcontentid, songid)
end

SerializerHelper.GmScientistAddALLRecipe_Serializer = function(writer)
end

ClientToGameGMDelegate.GmScientistAddALLRecipe = function(self)
	return self.Invoke(self, 65193256, SerializerHelper.GmScientistAddALLRecipe_Serializer)
end

SerializerHelper.GMSetBestNpcs_Serializer = function(writer, setbestnpcinfolist)
	SerializeBase.WriteList7Bit(writer, setbestnpcinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteBestNpcInfo, "BestNpcInfo", false), nil, "setbestnpcinfolist", false, 0, nil)
end

ClientToGameGMDelegate.GMSetBestNpcs = function(self, setbestnpcinfolist)
	return self.Invoke(self, 65200314, SerializerHelper.GMSetBestNpcs_Serializer, setbestnpcinfolist)
end

SerializerHelper.GmScientistAddAllEnchantAffix_Serializer = function(writer)
end

ClientToGameGMDelegate.GmScientistAddAllEnchantAffix = function(self)
	return self.Invoke(self, 65202014, SerializerHelper.GmScientistAddAllEnchantAffix_Serializer)
end

SerializerHelper.GmCreateClub_Serializer = function(writer, name, declaration, iconid, setting)
	writer.WriteString(writer, name, false, "GmCreateClub.name", 0)
	writer.WriteString(writer, declaration, true, "GmCreateClub.declaration", 0)
	SerializeBase.WritePrimitive(writer, iconid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteClubSetting, "setting", false)
end

ClientToGameGMDelegate.GmCreateClub = function(self, name, declaration, iconid, setting)
	return self.Invoke(self, 65202621, SerializerHelper.GmCreateClub_Serializer, name, declaration, iconid, setting)
end

SerializerHelper.GmChangeDisableSystemGroup_Serializer = function(writer, id, add)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, add, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmChangeDisableSystemGroup = function(self, id, add)
	return self.Invoke(self, 65203487, SerializerHelper.GmChangeDisableSystemGroup_Serializer, id, add)
end

SerializerHelper.GMTriggerBotFallingDown_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GMTriggerBotFallingDown = function(self, uid)
	return self.Invoke(self, 65204281, SerializerHelper.GMTriggerBotFallingDown_Serializer, uid)
end

SerializerHelper.GmMallRefreshCommodity_Serializer = function(writer, commodityid)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmMallRefreshCommodity = function(self, commodityid)
	return self.Invoke(self, 65210063, SerializerHelper.GmMallRefreshCommodity_Serializer, commodityid)
end

SerializerHelper.GmBuffLibraryClearAll_Serializer = function(writer)
end

ClientToGameGMDelegate.GmBuffLibraryClearAll = function(self)
	return self.Invoke(self, 65213406, SerializerHelper.GmBuffLibraryClearAll_Serializer)
end

SerializerHelper.GmChangeBuildHouseIndoor_Serializer = function(writer, houseid, floor, changeplacedfurnitureinfo)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, changeplacedfurnitureinfo, SerializeAuto.WriteChangePlacedFurnitureInfo, "changeplacedfurnitureinfo")
end

ClientToGameGMDelegate.GmChangeBuildHouseIndoor = function(self, houseid, floor, changeplacedfurnitureinfo)
	return self.Invoke(self, 65216018, SerializerHelper.GmChangeBuildHouseIndoor_Serializer, houseid, floor, changeplacedfurnitureinfo)
end

SerializerHelper.GmAddWeaponToArmoryEx_Serializer = function(writer, armoryid, weaponid, count)
	SerializeBase.WritePrimitive(writer, armoryid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddWeaponToArmoryEx = function(self, armoryid, weaponid, count)
	return self.Invoke(self, 65219713, SerializerHelper.GmAddWeaponToArmoryEx_Serializer, armoryid, weaponid, count)
end

SerializerHelper.GMAddRumor_Serializer = function(writer, rumorid)
	SerializeBase.WritePrimitive(writer, rumorid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMAddRumor = function(self, rumorid)
	return self.Invoke(self, 65225275, SerializerHelper.GMAddRumor_Serializer, rumorid)
end

SerializerHelper.GmClearRanking_Serializer = function(writer, rankconfigid)
	SerializeBase.WritePrimitive(writer, rankconfigid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearRanking = function(self, rankconfigid)
	return self.Invoke(self, 65226306, SerializerHelper.GmClearRanking_Serializer, rankconfigid)
end

SerializerHelper.GmCompleteTruckJobOrder_Serializer = function(writer, uniqueid, completeness)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, completeness, writer.WriteSingle, 0)
end

ClientToGameGMDelegate.GmCompleteTruckJobOrder = function(self, uniqueid, completeness)
	return self.Invoke(self, 65232333, SerializerHelper.GmCompleteTruckJobOrder_Serializer, uniqueid, completeness)
end

SerializerHelper.GmStartSingleParty_Serializer = function(writer, partyid, clearevent)
	SerializeBase.WritePrimitive(writer, partyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, clearevent, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmStartSingleParty = function(self, partyid, clearevent)
	return self.Invoke(self, 65234061, SerializerHelper.GmStartSingleParty_Serializer, partyid, clearevent)
end

SerializerHelper.GmSubmitItem_Serializer = function(writer, submiteventid)
	SerializeBase.WritePrimitive(writer, submiteventid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSubmitItem = function(self, submiteventid)
	return self.Invoke(self, 65234771, SerializerHelper.GmSubmitItem_Serializer, submiteventid)
end

SerializerHelper.GmConfirmDutySwap_Serializer = function(writer, sourcepid, accept)
	SerializeBase.WritePrimitive(writer, sourcepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmConfirmDutySwap = function(self, sourcepid, accept)
	return self.Invoke(self, 65235431, SerializerHelper.GmConfirmDutySwap_Serializer, sourcepid, accept)
end

SerializerHelper.GmEndGameplayTest_Serializer = function(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmEndGameplayTest = function(self, spiritid)
	return self.Invoke(self, 65235685, SerializerHelper.GmEndGameplayTest_Serializer, spiritid)
end

SerializerHelper.GmClearReceivedFanStageLvRewards_Serializer = function(writer, stagelv)
	SerializeBase.WritePrimitive(writer, stagelv, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearReceivedFanStageLvRewards = function(self, stagelv)
	return self.Invoke(self, 65241920, SerializerHelper.GmClearReceivedFanStageLvRewards_Serializer, stagelv)
end

SerializerHelper.GmClearDropLimit_Serializer = function(writer, dropid)
	SerializeBase.WritePrimitive(writer, dropid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearDropLimit = function(self, dropid)
	return self.Invoke(self, 65243440, SerializerHelper.GmClearDropLimit_Serializer, dropid)
end

SerializerHelper.GmGetMeccaGrandpaInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmGetMeccaGrandpaInfo = function(self)
	return self.Invoke(self, 65244782, SerializerHelper.GmGetMeccaGrandpaInfo_Serializer)
end

SerializerHelper.GmProduceItem_Serializer = function(writer, produceid, count, bias)
	SerializeBase.WritePrimitive(writer, produceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(bias, 18, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmProduceItem = function(self, produceid, count, bias)
	return self.Invoke(self, 65244910, SerializerHelper.GmProduceItem_Serializer, produceid, count, bias)
end

SerializerHelper.GmResetChargeRefund_Serializer = function(writer)
end

ClientToGameGMDelegate.GmResetChargeRefund = function(self)
	return self.Invoke(self, 65245081, SerializerHelper.GmResetChargeRefund_Serializer)
end

SerializerHelper.IamRobot_Serializer = function(writer)
end

ClientToGameGMDelegate.IamRobot = function(self)
	return self.Invoke(self, 65245082, SerializerHelper.IamRobot_Serializer)
end

SerializerHelper.GmTestPveLowMiddleHigh_Serializer = function(writer, level)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTestPveLowMiddleHigh = function(self, level)
	return self.Invoke(self, 65245891, SerializerHelper.GmTestPveLowMiddleHigh_Serializer, level)
end

SerializerHelper.GmUnlockTaskTitleGuide_Serializer = function(writer, title, unlock, finish)
	SerializeBase.WritePrimitive(writer, title, writer.WriteUInt16, 0)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, finish, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmUnlockTaskTitleGuide = function(self, title, unlock, finish)
	return self.Invoke(self, 65248341, SerializerHelper.GmUnlockTaskTitleGuide_Serializer, title, unlock, finish)
end

SerializerHelper.GmBuffLibrarySetRemainingSeconds_Serializer = function(writer, librarycfgid, spirittemplateid, seconds)
	SerializeBase.WritePrimitive(writer, librarycfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spirittemplateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, seconds, writer.WriteSingle, 0)
end

ClientToGameGMDelegate.GmBuffLibrarySetRemainingSeconds = function(self, librarycfgid, spirittemplateid, seconds)
	return self.Invoke(self, 65250519, SerializerHelper.GmBuffLibrarySetRemainingSeconds_Serializer, librarycfgid, spirittemplateid, seconds)
end

SerializerHelper.GmGangBossUnlockAllGangMember_Serializer = function(writer)
end

ClientToGameGMDelegate.GmGangBossUnlockAllGangMember = function(self)
	return self.Invoke(self, 65250561, SerializerHelper.GmGangBossUnlockAllGangMember_Serializer)
end

SerializerHelper.GmUnlockFashionColoringSlot_Serializer = function(writer, fashionid, unlockslotcount)
	SerializeBase.WritePrimitive(writer, fashionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlockslotcount, writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmUnlockFashionColoringSlot = function(self, fashionid, unlockslotcount)
	return self.Invoke(self, 65254014, SerializerHelper.GmUnlockFashionColoringSlot_Serializer, fashionid, unlockslotcount)
end

SerializerHelper.GmFinishAchievementCategory_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmFinishAchievementCategory = function(self, id)
	return self.Invoke(self, 65254764, SerializerHelper.GmFinishAchievementCategory_Serializer, id)
end

SerializerHelper.GmQueryClubStarDatas_Serializer = function(writer)
end

ClientToGameGMDelegate.GmQueryClubStarDatas = function(self)
	return self.Invoke(self, 65254964, SerializerHelper.GmQueryClubStarDatas_Serializer)
end

SerializerHelper.GmChargeResetFirstChargeInfo_Serializer = function(writer, chargeid)
	SerializeBase.WritePrimitive(writer, chargeid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmChargeResetFirstChargeInfo = function(self, chargeid)
	return self.Invoke(self, 65255296, SerializerHelper.GmChargeResetFirstChargeInfo_Serializer, chargeid)
end

SerializerHelper.AddSpirit_Serializer = function(writer, spirittemplateid, domain)
	SerializeBase.WritePrimitive(writer, spirittemplateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, domain, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.AddSpirit = function(self, spirittemplateid, domain)
	return self.Invoke(self, 65255363, SerializerHelper.AddSpirit_Serializer, spirittemplateid, domain)
end

SerializerHelper.GmViewFishingSpot_Serializer = function(writer, spotid)
	SerializeBase.WritePrimitive(writer, spotid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmViewFishingSpot = function(self, spotid)
	return self.Invoke(self, 65257375, SerializerHelper.GmViewFishingSpot_Serializer, spotid)
end

SerializerHelper.GmRunGiftTests_Serializer = function(writer)
end

ClientToGameGMDelegate.GmRunGiftTests = function(self)
	return self.Invoke(self, 65258077, SerializerHelper.GmRunGiftTests_Serializer)
end

SerializerHelper.GmInviteTeam_Serializer = function(writer, memberpid, doublecheck)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, doublecheck, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmInviteTeam = function(self, memberpid, doublecheck)
	return self.Invoke(self, 65258195, SerializerHelper.GmInviteTeam_Serializer, memberpid, doublecheck)
end

SerializerHelper.GmSurrenderVote_Serializer = function(writer, vote)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(vote, 41, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmSurrenderVote = function(self, vote)
	return self.Invoke(self, 65261294, SerializerHelper.GmSurrenderVote_Serializer, vote)
end

SerializerHelper.GMChangeNpcProfileTrustValue_Serializer = function(writer, profileid, diff)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GMChangeNpcProfileTrustValue = function(self, profileid, diff)
	return self.Invoke(self, 65261687, SerializerHelper.GMChangeNpcProfileTrustValue_Serializer, profileid, diff)
end

SerializerHelper.GmSkipLife_Serializer = function(writer, skiplifeid)
	SerializeBase.WritePrimitive(writer, skiplifeid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSkipLife = function(self, skiplifeid)
	return self.Invoke(self, 65262407, SerializerHelper.GmSkipLife_Serializer, skiplifeid)
end

SerializerHelper.GmAddLifeSkillItem_Serializer = function(writer, item, count)
	SerializeBase.WritePrimitive(writer, item, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddLifeSkillItem = function(self, item, count)
	return self.Invoke(self, 65265069, SerializerHelper.GmAddLifeSkillItem_Serializer, item, count)
end

SerializerHelper.GmResetAllFishingSpots_Serializer = function(writer)
end

ClientToGameGMDelegate.GmResetAllFishingSpots = function(self)
	return self.Invoke(self, 65266529, SerializerHelper.GmResetAllFishingSpots_Serializer)
end

SerializerHelper.GmPartyGetPartyInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmPartyGetPartyInfo = function(self)
	return self.Invoke(self, 65270833, SerializerHelper.GmPartyGetPartyInfo_Serializer)
end

SerializerHelper.GmExtractionShooterSortBag_Serializer = function(writer, bagconfigid)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmExtractionShooterSortBag = function(self, bagconfigid)
	return self.Invoke(self, 65271052, SerializerHelper.GmExtractionShooterSortBag_Serializer, bagconfigid)
end

SerializerHelper.GmAcceptEvent_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAcceptEvent = function(self, eventid)
	return self.Invoke(self, 65271311, SerializerHelper.GmAcceptEvent_Serializer, eventid)
end

SerializerHelper.GmChoosePartyNPC_Serializer = function(writer, npcs)
	SerializeBase.WriteList7Bit(writer, npcs, writer.WriteUInt32, 0, "npcs", false, 0, nil)
end

ClientToGameGMDelegate.GmChoosePartyNPC = function(self, npcs)
	return self.Invoke(self, 65273889, SerializerHelper.GmChoosePartyNPC_Serializer, npcs)
end

SerializerHelper.GmPhoneUnlockContactOption_Serializer = function(writer, contactid, contactoptionid)
	SerializeBase.WritePrimitive(writer, contactid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, contactoptionid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmPhoneUnlockContactOption = function(self, contactid, contactoptionid)
	return self.Invoke(self, 65274871, SerializerHelper.GmPhoneUnlockContactOption_Serializer, contactid, contactoptionid)
end

SerializerHelper.GmAllTaskResetByTitle_Serializer = function(writer, titleid)
	SerializeBase.WritePrimitive(writer, titleid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAllTaskResetByTitle = function(self, titleid)
	return self.Invoke(self, 65277049, SerializerHelper.GmAllTaskResetByTitle_Serializer, titleid)
end

SerializerHelper.GmSkipToPartyEnd_Serializer = function(writer)
end

ClientToGameGMDelegate.GmSkipToPartyEnd = function(self)
	return self.Invoke(self, 65281218, SerializerHelper.GmSkipToPartyEnd_Serializer)
end

SerializerHelper.GmRefreshCurrentShop_Serializer = function(writer)
end

ClientToGameGMDelegate.GmRefreshCurrentShop = function(self)
	return self.Invoke(self, 65282262, SerializerHelper.GmRefreshCurrentShop_Serializer)
end

SerializerHelper.GmPlayGameAgain_Serializer = function(writer, playagain, nextgame, restart)
	SerializeBase.WritePrimitive(writer, playagain, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, nextgame, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, restart, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmPlayGameAgain = function(self, playagain, nextgame, restart)
	return self.Invoke(self, 65285182, SerializerHelper.GmPlayGameAgain_Serializer, playagain, nextgame, restart)
end

SerializerHelper.GmAcceptSpecialTruckJobOrder_Serializer = function(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAcceptSpecialTruckJobOrder = function(self, orderid)
	return self.Invoke(self, 65288647, SerializerHelper.GmAcceptSpecialTruckJobOrder_Serializer, orderid)
end

SerializerHelper.GmClearNpcChatInfo_Serializer = function(writer, npccultivationid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearNpcChatInfo = function(self, npccultivationid)
	return self.Invoke(self, 65288684, SerializerHelper.GmClearNpcChatInfo_Serializer, npccultivationid)
end

SerializerHelper.GmEditSpiritFashionTransform_Serializer = function(writer, spiritidlist, wearfashionidlist, edittransformlist)
	SerializeBase.WriteList7Bit(writer, spiritidlist, writer.WriteUInt32, 0, "spiritidlist", false, 0, nil)
	SerializeBase.WriteList7Bit(writer, wearfashionidlist, writer.WriteUInt32, 0, "wearfashionidlist", false, 0, nil)
	SerializeBase.WriteList7Bit(writer, edittransformlist, writer.WriteSingle, 0, "edittransformlist", false, 0, nil)
end

ClientToGameGMDelegate.GmEditSpiritFashionTransform = function(self, spiritidlist, wearfashionidlist, edittransformlist)
	return self.Invoke(self, 65291441, SerializerHelper.GmEditSpiritFashionTransform_Serializer, spiritidlist, wearfashionidlist, edittransformlist)
end

SerializerHelper.GMScientistRemoveRecipe_Serializer = function(writer, productid)
	SerializeBase.WritePrimitive(writer, productid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMScientistRemoveRecipe = function(self, productid)
	return self.Invoke(self, 65293616, SerializerHelper.GMScientistRemoveRecipe_Serializer, productid)
end

SerializerHelper.GmResponsePartyRoomInvite_Serializer = function(writer, roomid, accepted)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accepted, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmResponsePartyRoomInvite = function(self, roomid, accepted)
	return self.Invoke(self, 65298572, SerializerHelper.GmResponsePartyRoomInvite_Serializer, roomid, accepted)
end

SerializerHelper.GmTeleportPlayerToFavorNpcCommuteTarget_Serializer = function(writer, agenttag)
	SerializeBase.WritePrimitive(writer, agenttag, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTeleportPlayerToFavorNpcCommuteTarget = function(self, agenttag)
	return self.Invoke(self, 65298628, SerializerHelper.GmTeleportPlayerToFavorNpcCommuteTarget_Serializer, agenttag)
end

SerializerHelper.GmRemovePaokuLimit_Serializer = function(writer, limits, sourcetype, sourceid)
	SerializeBase.WriteList7Bit(writer, limits, writer.WriteUInt32, 0, "limits", false, 0, nil)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sourcetype, 44, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, sourceid, writer.WriteInt64, 0)
end

ClientToGameGMDelegate.GmRemovePaokuLimit = function(self, limits, sourcetype, sourceid)
	return self.Invoke(self, 65300075, SerializerHelper.GmRemovePaokuLimit_Serializer, limits, sourcetype, sourceid)
end

SerializerHelper.GMSetLinkDeviceLevel_Serializer = function(writer, level)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(level, 45, 1), writer.WriteByte, 1)
end

ClientToGameGMDelegate.GMSetLinkDeviceLevel = function(self, level)
	return self.Invoke(self, 65303741, SerializerHelper.GMSetLinkDeviceLevel_Serializer, level)
end

SerializerHelper.GmEnableClientSpiritFashionTryWear_Serializer = function(writer, spiritid, enable)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmEnableClientSpiritFashionTryWear = function(self, spiritid, enable)
	return self.Invoke(self, 65305837, SerializerHelper.GmEnableClientSpiritFashionTryWear_Serializer, spiritid, enable)
end

SerializerHelper.GmUnlockFashionSuitSlot_Serializer = function(writer, spiritid, unlockslotcount)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlockslotcount, writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmUnlockFashionSuitSlot = function(self, spiritid, unlockslotcount)
	return self.Invoke(self, 65309358, SerializerHelper.GmUnlockFashionSuitSlot_Serializer, spiritid, unlockslotcount)
end

SerializerHelper.GmQueryMahjongRoomInfo_Serializer = function(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmQueryMahjongRoomInfo = function(self, roomid)
	return self.Invoke(self, 65309710, SerializerHelper.GmQueryMahjongRoomInfo_Serializer, roomid)
end

SerializerHelper.GmAbilitySetLevel_Serializer = function(writer, spiritid, abilityid, level)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, abilityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAbilitySetLevel = function(self, spiritid, abilityid, level)
	return self.Invoke(self, 65310958, SerializerHelper.GmAbilitySetLevel_Serializer, spiritid, abilityid, level)
end

SerializerHelper.GmClearGadgetRecord_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearGadgetRecord = function(self)
	return self.Invoke(self, 65311996, SerializerHelper.GmClearGadgetRecord_Serializer)
end

SerializerHelper.GmSetRoomMemberDuty_Serializer = function(writer, duty)
	SerializeBase.WritePrimitive(writer, duty, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetRoomMemberDuty = function(self, duty)
	return self.Invoke(self, 65313957, SerializerHelper.GmSetRoomMemberDuty_Serializer, duty)
end

SerializerHelper.GmRunTests_Serializer = function(writer, module)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(module, 46, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmRunTests = function(self, module)
	return self.Invoke(self, 65316301, SerializerHelper.GmRunTests_Serializer, module)
end

SerializerHelper.GmTriggerFactionCounterAttack_Serializer = function(writer, factionid)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTriggerFactionCounterAttack = function(self, factionid)
	return self.Invoke(self, 65316350, SerializerHelper.GmTriggerFactionCounterAttack_Serializer, factionid)
end

SerializerHelper.GmClearAllSubQuest_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearAllSubQuest = function(self)
	return self.Invoke(self, 65316930, SerializerHelper.GmClearAllSubQuest_Serializer)
end

SerializerHelper.GmScientistRemoveAllRecipe_Serializer = function(writer)
end

ClientToGameGMDelegate.GmScientistRemoveAllRecipe = function(self)
	return self.Invoke(self, 65318620, SerializerHelper.GmScientistRemoveAllRecipe_Serializer)
end

SerializerHelper.GMBasketballBlock_Serializer = function(writer)
end

ClientToGameGMDelegate.GMBasketballBlock = function(self)
	return self.Invoke(self, 65318638, SerializerHelper.GMBasketballBlock_Serializer)
end

SerializerHelper.GmDisableMapEntranceType_Serializer = function(writer, mapentrancetypeid)
	SerializeBase.WritePrimitive(writer, mapentrancetypeid, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmDisableMapEntranceType = function(self, mapentrancetypeid)
	return self.Invoke(self, 65318705, SerializerHelper.GmDisableMapEntranceType_Serializer, mapentrancetypeid)
end

SerializerHelper.GmViewFishingInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmViewFishingInfo = function(self)
	return self.Invoke(self, 65319937, SerializerHelper.GmViewFishingInfo_Serializer)
end

SerializerHelper.GmUnlockPlanningBoardMultiPlayer_Serializer = function(writer, multiplayerid)
	SerializeBase.WritePrimitive(writer, multiplayerid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnlockPlanningBoardMultiPlayer = function(self, multiplayerid)
	return self.Invoke(self, 65321165, SerializerHelper.GmUnlockPlanningBoardMultiPlayer_Serializer, multiplayerid)
end

SerializerHelper.GmExtractionShooterBagExpansion_Serializer = function(writer, expansionid)
	SerializeBase.WritePrimitive(writer, expansionid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmExtractionShooterBagExpansion = function(self, expansionid)
	return self.Invoke(self, 65323540, SerializerHelper.GmExtractionShooterBagExpansion_Serializer, expansionid)
end

SerializerHelper.GmTradeRemoveOrder_Serializer = function(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmTradeRemoveOrder = function(self, orderid)
	return self.Invoke(self, 65324953, SerializerHelper.GmTradeRemoveOrder_Serializer, orderid)
end

SerializerHelper.GmAskQueryAgentDetailList_Serializer = function(writer, instanceids)
	SerializeBase.WriteList7Bit(writer, instanceids, writer.WriteUInt64, 0, "instanceids", false, 0, nil)
end

ClientToGameGMDelegate.GmAskQueryAgentDetailList = function(self, instanceids)
	return self.Invoke(self, 65326141, SerializerHelper.GmAskQueryAgentDetailList_Serializer, instanceids)
end

SerializerHelper.GmSetMoPai_Serializer = function(writer, pid, type, pai)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pai, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmSetMoPai = function(self, pid, type, pai)
	return self.Invoke(self, 65327474, SerializerHelper.GmSetMoPai_Serializer, pid, type, pai)
end

SerializerHelper.GMBasketballShoot_Serializer = function(writer, score, shoottype)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, shoottype, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GMBasketballShoot = function(self, score, shoottype)
	return self.Invoke(self, 65328889, SerializerHelper.GMBasketballShoot_Serializer, score, shoottype)
end

SerializerHelper.GMStartWatchOtherPlayer_Serializer = function(writer)
end

ClientToGameGMDelegate.GMStartWatchOtherPlayer = function(self)
	return self.Invoke(self, 65332666, SerializerHelper.GMStartWatchOtherPlayer_Serializer)
end

SerializerHelper.GMEndWatchOtherPlayer_Serializer = function(writer)
end

ClientToGameGMDelegate.GMEndWatchOtherPlayer = function(self)
	return self.Invoke(self, 65333711, SerializerHelper.GMEndWatchOtherPlayer_Serializer)
end

SerializerHelper.GmFinishCompetition_Serializer = function(writer, trackid, vehicleid, costtime, bestlaptime, rank, star)
	SerializeBase.WritePrimitive(writer, trackid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, costtime, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, bestlaptime, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, rank, writer.WriteUInt16, 0)
	SerializeBase.WritePrimitive(writer, star, writer.WriteUInt16, 0)
end

ClientToGameGMDelegate.GmFinishCompetition = function(self, trackid, vehicleid, costtime, bestlaptime, rank, star)
	return self.Invoke(self, 65345205, SerializerHelper.GmFinishCompetition_Serializer, trackid, vehicleid, costtime, bestlaptime, rank, star)
end

SerializerHelper.GmTestCrash_Serializer = function(writer, type)
	SerializeBase.WritePrimitive(writer, type, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmTestCrash = function(self, type)
	return self.Invoke(self, 65347286, SerializerHelper.GmTestCrash_Serializer, type)
end

SerializerHelper.GmSetReachInitialHand_Serializer = function(writer, seatindex, tiles)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
	writer.WriteString(writer, tiles, false, "GmSetReachInitialHand.tiles", 0)
end

ClientToGameGMDelegate.GmSetReachInitialHand = function(self, seatindex, tiles)
	return self.Invoke(self, 65348832, SerializerHelper.GmSetReachInitialHand_Serializer, seatindex, tiles)
end

SerializerHelper.GmQuickPlaySingleGame_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmQuickPlaySingleGame = function(self, gameid)
	return self.Invoke(self, 65350100, SerializerHelper.GmQuickPlaySingleGame_Serializer, gameid)
end

SerializerHelper.GmGetTaskAllNodesName_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmGetTaskAllNodesName = function(self, taskid)
	return self.Invoke(self, 65354318, SerializerHelper.GmGetTaskAllNodesName_Serializer, taskid)
end

SerializerHelper.GmAddCommonSpiritTalentExp_Serializer = function(writer, exp)
	SerializeBase.WritePrimitive(writer, exp, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddCommonSpiritTalentExp = function(self, exp)
	return self.Invoke(self, 65355850, SerializerHelper.GmAddCommonSpiritTalentExp_Serializer, exp)
end

SerializerHelper.GmDrawGacha_Serializer = function(writer, gachapoolid, drawcount)
	SerializeBase.WritePrimitive(writer, gachapoolid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, drawcount, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmDrawGacha = function(self, gachapoolid, drawcount)
	return self.Invoke(self, 65357790, SerializerHelper.GmDrawGacha_Serializer, gachapoolid, drawcount)
end

SerializerHelper.TestBeggarPaintAI_Serializer = function(writer, evaluationid, stroke_num, colorcount)
	writer.WriteString(writer, evaluationid, false, "TestBeggarPaintAI.evaluationId", 0)
	SerializeBase.WritePrimitive(writer, stroke_num, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, colorcount, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.TestBeggarPaintAI = function(self, evaluationid, stroke_num, colorcount)
	return self.Invoke(self, 65361689, SerializerHelper.TestBeggarPaintAI_Serializer, evaluationid, stroke_num, colorcount)
end

SerializerHelper.GmClearDialogNpcChat_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearDialogNpcChat = function(self, chatid)
	return self.Invoke(self, 65366579, SerializerHelper.GmClearDialogNpcChat_Serializer, chatid)
end

SerializerHelper.GmMallBuyBundle_Serializer = function(writer, bundleid, buycnt, autoexchange)
	SerializeBase.WritePrimitive(writer, bundleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buycnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, autoexchange, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmMallBuyBundle = function(self, bundleid, buycnt, autoexchange)
	return self.Invoke(self, 65366654, SerializerHelper.GmMallBuyBundle_Serializer, bundleid, buycnt, autoexchange)
end

SerializerHelper.GmAddMilkNpcFavor_Serializer = function(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmAddMilkNpcFavor = function(self, value)
	return self.Invoke(self, 65368808, SerializerHelper.GmAddMilkNpcFavor_Serializer, value)
end

SerializerHelper.GmSetCompoundStationLevel_Serializer = function(writer, stationid, level)
	SerializeBase.WritePrimitive(writer, stationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetCompoundStationLevel = function(self, stationid, level)
	return self.Invoke(self, 65368886, SerializerHelper.GmSetCompoundStationLevel_Serializer, stationid, level)
end

SerializerHelper.GmAddFashionSuits_Serializer = function(writer, fashionsuitidlist, duration)
	SerializeBase.WriteList7Bit(writer, fashionsuitidlist, writer.WriteUInt32, 0, "fashionsuitidlist", false, 0, nil)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddFashionSuits = function(self, fashionsuitidlist, duration)
	return self.Invoke(self, 65369728, SerializerHelper.GmAddFashionSuits_Serializer, fashionsuitidlist, duration)
end

SerializerHelper.GmGetTierMatchHistory_Serializer = function(writer, multiplayerid)
	SerializeBase.WritePrimitive(writer, multiplayerid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmGetTierMatchHistory = function(self, multiplayerid)
	return self.Invoke(self, 65372660, SerializerHelper.GmGetTierMatchHistory_Serializer, multiplayerid)
end

SerializerHelper.GmSetTime_Serializer = function(writer, hour, minute, transition)
	SerializeBase.WritePrimitive(writer, hour, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, minute, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, transition, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetTime = function(self, hour, minute, transition)
	return self.Invoke(self, 65373939, SerializerHelper.GmSetTime_Serializer, hour, minute, transition)
end

SerializerHelper.GMActivateAllNpcCard_Serializer = function(writer)
end

ClientToGameGMDelegate.GMActivateAllNpcCard = function(self)
	return self.Invoke(self, 65375537, SerializerHelper.GMActivateAllNpcCard_Serializer)
end

SerializerHelper.GmCompoundItem_Serializer = function(writer, compoundid, stationid, count, ignoreconsume)
	SerializeBase.WritePrimitive(writer, compoundid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ignoreconsume, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmCompoundItem = function(self, compoundid, stationid, count, ignoreconsume)
	return self.Invoke(self, 65376959, SerializerHelper.GmCompoundItem_Serializer, compoundid, stationid, count, ignoreconsume)
end

SerializerHelper.GMClearLockedNpcCardInfo_Serializer = function(writer, npccardid)
	SerializeBase.WritePrimitive(writer, npccardid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMClearLockedNpcCardInfo = function(self, npccardid)
	return self.Invoke(self, 65378205, SerializerHelper.GMClearLockedNpcCardInfo_Serializer, npccardid)
end

SerializerHelper.GmAddPopularity_Serializer = function(writer, drop, count, interval)
	SerializeBase.WritePrimitive(writer, drop, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interval, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddPopularity = function(self, drop, count, interval)
	return self.Invoke(self, 65380732, SerializerHelper.GmAddPopularity_Serializer, drop, count, interval)
end

SerializerHelper.GmClearGatherDropLimit_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearGatherDropLimit = function(self)
	return self.Invoke(self, 65384339, SerializerHelper.GmClearGatherDropLimit_Serializer)
end

SerializerHelper.GmPartyGetSettleData_Serializer = function(writer)
end

ClientToGameGMDelegate.GmPartyGetSettleData = function(self)
	return self.Invoke(self, 65385906, SerializerHelper.GmPartyGetSettleData_Serializer)
end

SerializerHelper.GmAddSpiritInitTalentPointAdd_Serializer = function(writer, point)
	SerializeBase.WritePrimitive(writer, point, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddSpiritInitTalentPointAdd = function(self, point)
	return self.Invoke(self, 65389637, SerializerHelper.GmAddSpiritInitTalentPointAdd_Serializer, point)
end

SerializerHelper.GmPassingTime_Serializer = function(writer, hour, minute)
	SerializeBase.WritePrimitive(writer, hour, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, minute, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmPassingTime = function(self, hour, minute)
	return self.Invoke(self, 65392342, SerializerHelper.GmPassingTime_Serializer, hour, minute)
end

SerializerHelper.GmExtractionShooterLockItem_Serializer = function(writer, bagconfigid, cellx, celly, islocked)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, islocked, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmExtractionShooterLockItem = function(self, bagconfigid, cellx, celly, islocked)
	return self.Invoke(self, 65392936, SerializerHelper.GmExtractionShooterLockItem_Serializer, bagconfigid, cellx, celly, islocked)
end

SerializerHelper.GmOnFishingSuccess_Serializer = function(writer, spotid, fishid)
	SerializeBase.WritePrimitive(writer, spotid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fishid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmOnFishingSuccess = function(self, spotid, fishid)
	return self.Invoke(self, 65394944, SerializerHelper.GmOnFishingSuccess_Serializer, spotid, fishid)
end

SerializerHelper.GmClearTruckJobOrders_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearTruckJobOrders = function(self)
	return self.Invoke(self, 65397141, SerializerHelper.GmClearTruckJobOrders_Serializer)
end

SerializerHelper.GmAddTaskCounterValue_Serializer = function(writer, taskid, index, current, value)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, current, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmAddTaskCounterValue = function(self, taskid, index, current, value)
	return self.Invoke(self, 65398008, SerializerHelper.GmAddTaskCounterValue_Serializer, taskid, index, current, value)
end

SerializerHelper.GmAddWorldLifeDropCount_Serializer = function(writer, worldlifetype, count)
	SerializeBase.WritePrimitive(writer, worldlifetype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddWorldLifeDropCount = function(self, worldlifetype, count)
	return self.Invoke(self, 65398509, SerializerHelper.GmAddWorldLifeDropCount_Serializer, worldlifetype, count)
end

SerializerHelper.GmRaiseSurrender_Serializer = function(writer)
end

ClientToGameGMDelegate.GmRaiseSurrender = function(self)
	return self.Invoke(self, 65398650, SerializerHelper.GmRaiseSurrender_Serializer)
end

SerializerHelper.GmResetGachaPoolHistory_Serializer = function(writer, prizepoolid)
	SerializeBase.WritePrimitive(writer, prizepoolid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmResetGachaPoolHistory = function(self, prizepoolid)
	return self.Invoke(self, 65399974, SerializerHelper.GmResetGachaPoolHistory_Serializer, prizepoolid)
end

SerializerHelper.GmRefreshAllFavorNpcTimeTable_Serializer = function(writer)
end

ClientToGameGMDelegate.GmRefreshAllFavorNpcTimeTable = function(self)
	return self.Invoke(self, 65402253, SerializerHelper.GmRefreshAllFavorNpcTimeTable_Serializer)
end

SerializerHelper.GmClearDialog_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearDialog = function(self)
	return self.Invoke(self, 65407238, SerializerHelper.GmClearDialog_Serializer)
end

SerializerHelper.GmSetColoringTopNScore_Serializer = function(writer, fashionid, score)
	SerializeBase.WritePrimitive(writer, fashionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetColoringTopNScore = function(self, fashionid, score)
	return self.Invoke(self, 65409332, SerializerHelper.GmSetColoringTopNScore_Serializer, fashionid, score)
end

SerializerHelper.GMSyncWorldBattlePlayers_Serializer = function(writer, gadgetid, gameid, enter)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GMSyncWorldBattlePlayers = function(self, gadgetid, gameid, enter)
	return self.Invoke(self, 65409938, SerializerHelper.GMSyncWorldBattlePlayers_Serializer, gadgetid, gameid, enter)
end

SerializerHelper.GmAddPaokuLimitClient_Serializer = function(writer, limit, sourcetype, sourceid)
	SerializeBase.WritePrimitive(writer, limit, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sourcetype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sourceid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmAddPaokuLimitClient = function(self, limit, sourcetype, sourceid)
	return self.Invoke(self, 65422980, SerializerHelper.GmAddPaokuLimitClient_Serializer, limit, sourcetype, sourceid)
end

SerializerHelper.GmAddFishingGear_Serializer = function(writer, gearconfigid)
	SerializeBase.WritePrimitive(writer, gearconfigid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddFishingGear = function(self, gearconfigid)
	return self.Invoke(self, 65426321, SerializerHelper.GmAddFishingGear_Serializer, gearconfigid)
end

SerializerHelper.GmFinishClubWeeklyTask_Serializer = function(writer, cfgid, count)
	SerializeBase.WritePrimitive(writer, cfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmFinishClubWeeklyTask = function(self, cfgid, count)
	return self.Invoke(self, 65426539, SerializerHelper.GmFinishClubWeeklyTask_Serializer, cfgid, count)
end

SerializerHelper.GmExtractionShooterSortBags_Serializer = function(writer, bagconfigids)
	SerializeBase.WriteList7Bit(writer, bagconfigids, writer.WriteUInt32, 0, "bagconfigids", false, 0, nil)
end

ClientToGameGMDelegate.GmExtractionShooterSortBags = function(self, bagconfigids)
	return self.Invoke(self, 65427827, SerializerHelper.GmExtractionShooterSortBags_Serializer, bagconfigids)
end

SerializerHelper.GmJobPromote_Serializer = function(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmJobPromote = function(self, jobclassid)
	return self.Invoke(self, 65430772, SerializerHelper.GmJobPromote_Serializer, jobclassid)
end

SerializerHelper.GmSpiritSexTransition_Serializer = function(writer)
end

ClientToGameGMDelegate.GmSpiritSexTransition = function(self)
	return self.Invoke(self, 65432023, SerializerHelper.GmSpiritSexTransition_Serializer)
end

SerializerHelper.GmAddFactionInfluence_Serializer = function(writer, factionid, addvalue)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmAddFactionInfluence = function(self, factionid, addvalue)
	return self.Invoke(self, 65435835, SerializerHelper.GmAddFactionInfluence_Serializer, factionid, addvalue)
end

SerializerHelper.GmUnlockAllQuest_Serializer = function(writer)
end

ClientToGameGMDelegate.GmUnlockAllQuest = function(self)
	return self.Invoke(self, 65436618, SerializerHelper.GmUnlockAllQuest_Serializer)
end

SerializerHelper.GmClearFishing_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearFishing = function(self)
	return self.Invoke(self, 65436943, SerializerHelper.GmClearFishing_Serializer)
end

SerializerHelper.GmLeaveGameTeam_Serializer = function(writer, success)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmLeaveGameTeam = function(self, success)
	return self.Invoke(self, 65437812, SerializerHelper.GmLeaveGameTeam_Serializer, success)
end

SerializerHelper.GmHouseVisit_Serializer = function(writer, ownerpid, houseid)
	SerializeBase.WritePrimitive(writer, ownerpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmHouseVisit = function(self, ownerpid, houseid)
	return self.Invoke(self, 65439259, SerializerHelper.GmHouseVisit_Serializer, ownerpid, houseid)
end

SerializerHelper.GmSetReputation_Serializer = function(writer, countryid, reputation)
	SerializeBase.WritePrimitive(writer, countryid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, reputation, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetReputation = function(self, countryid, reputation)
	return self.Invoke(self, 65439395, SerializerHelper.GmSetReputation_Serializer, countryid, reputation)
end

SerializerHelper.GmClearNpcTuite_Serializer = function(writer, cfgid)
	SerializeBase.WritePrimitive(writer, cfgid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearNpcTuite = function(self, cfgid)
	return self.Invoke(self, 65441843, SerializerHelper.GmClearNpcTuite_Serializer, cfgid)
end

SerializerHelper.GmResetMeccaGrandpaBuild_Serializer = function(writer)
end

ClientToGameGMDelegate.GmResetMeccaGrandpaBuild = function(self)
	return self.Invoke(self, 65442527, SerializerHelper.GmResetMeccaGrandpaBuild_Serializer)
end

SerializerHelper.GmExtractionShooterShiftItem_Serializer = function(writer, srcbagconfigid, fromcellx, fromcelly, destbagconfigid, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, srcbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, destbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmExtractionShooterShiftItem = function(self, srcbagconfigid, fromcellx, fromcelly, destbagconfigid, tocellx, tocelly, isrotated)
	return self.Invoke(self, 65443468, SerializerHelper.GmExtractionShooterShiftItem_Serializer, srcbagconfigid, fromcellx, fromcelly, destbagconfigid, tocellx, tocelly, isrotated)
end

SerializerHelper.GmTriggerHUDRecommend_Serializer = function(writer, configid)
	SerializeBase.WritePrimitive(writer, configid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTriggerHUDRecommend = function(self, configid)
	return self.Invoke(self, 65449980, SerializerHelper.GmTriggerHUDRecommend_Serializer, configid)
end

SerializerHelper.GmAddRadioSong_Serializer = function(writer, songid)
	SerializeBase.WritePrimitive(writer, songid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddRadioSong = function(self, songid)
	return self.Invoke(self, 65455143, SerializerHelper.GmAddRadioSong_Serializer, songid)
end

SerializerHelper.GmBuffLibraryDump_Serializer = function(writer)
end

ClientToGameGMDelegate.GmBuffLibraryDump = function(self)
	return self.Invoke(self, 65455461, SerializerHelper.GmBuffLibraryDump_Serializer)
end

SerializerHelper.GMOnPlayerAskDestroyAllGangMember_Serializer = function(writer)
end

ClientToGameGMDelegate.GMOnPlayerAskDestroyAllGangMember = function(self)
	return self.Invoke(self, 65456358, SerializerHelper.GMOnPlayerAskDestroyAllGangMember_Serializer)
end

SerializerHelper.GmSkipMjGame_Serializer = function(writer, enabled)
	SerializeBase.WritePrimitive(writer, enabled, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmSkipMjGame = function(self, enabled)
	return self.Invoke(self, 65458286, SerializerHelper.GmSkipMjGame_Serializer, enabled)
end

SerializerHelper.GmAskNameAnimal_Serializer = function(writer, animalid, nickname)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	writer.WriteString(writer, nickname, false, "GmAskNameAnimal.nickName", 0)
end

ClientToGameGMDelegate.GmAskNameAnimal = function(self, animalid, nickname)
	return self.Invoke(self, 65459066, SerializerHelper.GmAskNameAnimal_Serializer, animalid, nickname)
end

SerializerHelper.GmAddGameplayTalentExp_Serializer = function(writer, gameplayid, exp)
	SerializeBase.WritePrimitive(writer, gameplayid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, exp, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddGameplayTalentExp = function(self, gameplayid, exp)
	return self.Invoke(self, 65462672, SerializerHelper.GmAddGameplayTalentExp_Serializer, gameplayid, exp)
end

SerializerHelper.GmUnLockQuest_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnLockQuest = function(self, id)
	return self.Invoke(self, 65463677, SerializerHelper.GmUnLockQuest_Serializer, id)
end

SerializerHelper.GmFireworkUnLockPlan_Serializer = function(writer, fireworkplanconfigid)
	SerializeBase.WritePrimitive(writer, fireworkplanconfigid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmFireworkUnLockPlan = function(self, fireworkplanconfigid)
	return self.Invoke(self, 65464070, SerializerHelper.GmFireworkUnLockPlan_Serializer, fireworkplanconfigid)
end

SerializerHelper.GmLinkKick_Serializer = function(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmLinkKick = function(self, friendpid)
	return self.Invoke(self, 65468376, SerializerHelper.GmLinkKick_Serializer, friendpid)
end

SerializerHelper.GmTestMahjongAI_Serializer = function(writer, gametype)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTestMahjongAI = function(self, gametype)
	return self.Invoke(self, 65470242, SerializerHelper.GmTestMahjongAI_Serializer, gametype)
end

SerializerHelper.GmAddAllVehicles_Serializer = function(writer)
end

ClientToGameGMDelegate.GmAddAllVehicles = function(self)
	return self.Invoke(self, 65471338, SerializerHelper.GmAddAllVehicles_Serializer)
end

SerializerHelper.GmApplyFashionColoringSchemeInfos_Serializer = function(writer, applyfashioncoloringschemeiddict)
	SerializeBase.WriteDict7Bit(writer, applyfashioncoloringschemeiddict, writer.WriteUInt32, writer.WriteByte, 0, "applyfashioncoloringschemeiddict", false, 0)
end

ClientToGameGMDelegate.GmApplyFashionColoringSchemeInfos = function(self, applyfashioncoloringschemeiddict)
	return self.Invoke(self, 65471595, SerializerHelper.GmApplyFashionColoringSchemeInfos_Serializer, applyfashioncoloringschemeiddict)
end

SerializerHelper.GmStartMahjongWithNpc_Serializer = function(writer, gametype, seatindex)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmStartMahjongWithNpc = function(self, gametype, seatindex)
	return self.Invoke(self, 65472566, SerializerHelper.GmStartMahjongWithNpc_Serializer, gametype, seatindex)
end

SerializerHelper.GmSubmitTask_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSubmitTask = function(self, taskid)
	return self.Invoke(self, 65474103, SerializerHelper.GmSubmitTask_Serializer, taskid)
end

SerializerHelper.GmUnlockFogMap_Serializer = function(writer, sceneid, unlock)
	SerializeBase.WritePrimitive(writer, sceneid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmUnlockFogMap = function(self, sceneid, unlock)
	return self.Invoke(self, 65478823, SerializerHelper.GmUnlockFogMap_Serializer, sceneid, unlock)
end

SerializerHelper.GmTriggerChargeRefund_Serializer = function(writer, gold, battlepassitemid, monthlypassitemid, monthlypasscount)
	SerializeBase.WritePrimitive(writer, gold, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, battlepassitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, monthlypassitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, monthlypasscount, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTriggerChargeRefund = function(self, gold, battlepassitemid, monthlypassitemid, monthlypasscount)
	return self.Invoke(self, 65479020, SerializerHelper.GmTriggerChargeRefund_Serializer, gold, battlepassitemid, monthlypassitemid, monthlypasscount)
end

SerializerHelper.GmClearPreGenerateOCId_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearPreGenerateOCId = function(self)
	return self.Invoke(self, 65481445, SerializerHelper.GmClearPreGenerateOCId_Serializer)
end

SerializerHelper.GmPolicePickNextMission_Serializer = function(writer, policemissionid, randomid)
	SerializeBase.WritePrimitive(writer, policemissionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, randomid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmPolicePickNextMission = function(self, policemissionid, randomid)
	return self.Invoke(self, 65481486, SerializerHelper.GmPolicePickNextMission_Serializer, policemissionid, randomid)
end

SerializerHelper.GmRemoveHouse_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmRemoveHouse = function(self, houseid)
	return self.Invoke(self, 65483628, SerializerHelper.GmRemoveHouse_Serializer, houseid)
end

SerializerHelper.GmResetFashionColoringSchemeInfos_Serializer = function(writer, resetfashioncoloringschemeinfolist)
	SerializeBase.WriteList7Bit(writer, resetfashioncoloringschemeinfolist, SerializeBase.WriteStructWrap(SerializeAuto.WriteResetFashionColoringSchemeInfo, "resetfashioncoloringschemeinfolist"), nil, "resetfashioncoloringschemeinfolist", false, 0, nil)
end

ClientToGameGMDelegate.GmResetFashionColoringSchemeInfos = function(self, resetfashioncoloringschemeinfolist)
	return self.Invoke(self, 65484818, SerializerHelper.GmResetFashionColoringSchemeInfos_Serializer, resetfashioncoloringschemeinfolist)
end

SerializerHelper.GmRemoveIgnorePaokuLimit_Serializer = function(writer, limits, sourcetype, sourceid)
	SerializeBase.WriteList7Bit(writer, limits, writer.WriteUInt32, 0, "limits", false, 0, nil)
	SerializeBase.WritePrimitive(writer, sourcetype, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, sourceid, writer.WriteInt64, 0)
end

ClientToGameGMDelegate.GmRemoveIgnorePaokuLimit = function(self, limits, sourcetype, sourceid)
	return self.Invoke(self, 65489972, SerializerHelper.GmRemoveIgnorePaokuLimit_Serializer, limits, sourcetype, sourceid)
end

SerializerHelper.GmIsGameUnlock_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmIsGameUnlock = function(self, gameid)
	return self.Invoke(self, 65494338, SerializerHelper.GmIsGameUnlock_Serializer, gameid)
end

SerializerHelper.GMAddHouseAndTransfer_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMAddHouseAndTransfer = function(self, houseid)
	return self.Invoke(self, 65495323, SerializerHelper.GMAddHouseAndTransfer_Serializer, houseid)
end

SerializerHelper.GmLinkSwitchMode_Serializer = function(writer, mode)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmLinkSwitchMode = function(self, mode)
	return self.Invoke(self, 65495456, SerializerHelper.GmLinkSwitchMode_Serializer, mode)
end

SerializerHelper.GmSetMapEntrance_Serializer = function(writer, mapentranceid, isopenandshow)
	SerializeBase.WritePrimitive(writer, mapentranceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isopenandshow, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmSetMapEntrance = function(self, mapentranceid, isopenandshow)
	return self.Invoke(self, 65495623, SerializerHelper.GmSetMapEntrance_Serializer, mapentranceid, isopenandshow)
end

SerializerHelper.GMJoinLinkByPid_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GMJoinLinkByPid = function(self, pid)
	return self.Invoke(self, 65495649, SerializerHelper.GMJoinLinkByPid_Serializer, pid)
end

SerializerHelper.GmArchiveInvestigateGallery_Serializer = function(writer, galleryid)
	SerializeBase.WritePrimitive(writer, galleryid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmArchiveInvestigateGallery = function(self, galleryid)
	return self.Invoke(self, 65501170, SerializerHelper.GmArchiveInvestigateGallery_Serializer, galleryid)
end

SerializerHelper.GmTriggerFactionEncroach_Serializer = function(writer, areaid, attackfactionid)
	SerializeBase.WritePrimitive(writer, areaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, attackfactionid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTriggerFactionEncroach = function(self, areaid, attackfactionid)
	return self.Invoke(self, 65502302, SerializerHelper.GmTriggerFactionEncroach_Serializer, areaid, attackfactionid)
end

SerializerHelper.GmTriggerFactionCounterAttackByIntensity_Serializer = function(writer, factionid, intensity)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, intensity, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTriggerFactionCounterAttackByIntensity = function(self, factionid, intensity)
	return self.Invoke(self, 65503993, SerializerHelper.GmTriggerFactionCounterAttackByIntensity_Serializer, factionid, intensity)
end

SerializerHelper.GmBartendingByDrinkMenu_Serializer = function(writer, bartenderid, drinkmenuid)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, drinkmenuid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmBartendingByDrinkMenu = function(self, bartenderid, drinkmenuid)
	return self.Invoke(self, 65505405, SerializerHelper.GmBartendingByDrinkMenu_Serializer, bartenderid, drinkmenuid)
end

SerializerHelper.GmAddFakeMirrorDelta_Serializer = function(writer)
end

ClientToGameGMDelegate.GmAddFakeMirrorDelta = function(self)
	return self.Invoke(self, 65510676, SerializerHelper.GmAddFakeMirrorDelta_Serializer)
end

SerializerHelper.GmGetFakeFileInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmGetFakeFileInfo = function(self)
	return self.Invoke(self, 65510702, SerializerHelper.GmGetFakeFileInfo_Serializer)
end

SerializerHelper.GmExtractionShooterSellItem_Serializer = function(writer, bagconfigid, sellcellx, sellcelly, sellcount)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sellcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sellcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sellcount, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmExtractionShooterSellItem = function(self, bagconfigid, sellcellx, sellcelly, sellcount)
	return self.Invoke(self, 65510724, SerializerHelper.GmExtractionShooterSellItem_Serializer, bagconfigid, sellcellx, sellcelly, sellcount)
end

SerializerHelper.GmClearGuides_Serializer = function(writer, guideid, interrupt)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interrupt, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmClearGuides = function(self, guideid, interrupt)
	return self.Invoke(self, 65515186, SerializerHelper.GmClearGuides_Serializer, guideid, interrupt)
end

SerializerHelper.GmAddPopularityFromConfig_Serializer = function(writer)
end

ClientToGameGMDelegate.GmAddPopularityFromConfig = function(self)
	return self.Invoke(self, 65517212, SerializerHelper.GmAddPopularityFromConfig_Serializer)
end

SerializerHelper.GmPullMemberToTeam_Serializer = function(writer, memberpid)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmPullMemberToTeam = function(self, memberpid)
	return self.Invoke(self, 65517368, SerializerHelper.GmPullMemberToTeam_Serializer, memberpid)
end

SerializerHelper.GmAddFakeFileClueValue_Serializer = function(writer, agentidlist)
	SerializeBase.WriteList7Bit(writer, agentidlist, writer.WriteUInt32, 0, "agentidlist", false, 0, nil)
end

ClientToGameGMDelegate.GmAddFakeFileClueValue = function(self, agentidlist)
	return self.Invoke(self, 65517433, SerializerHelper.GmAddFakeFileClueValue_Serializer, agentidlist)
end

SerializerHelper.GmStartBartenderGame_Serializer = function(writer, bartenderid)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmStartBartenderGame = function(self, bartenderid)
	return self.Invoke(self, 65518046, SerializerHelper.GmStartBartenderGame_Serializer, bartenderid)
end

SerializerHelper.GmPartyOver_Serializer = function(writer)
end

ClientToGameGMDelegate.GmPartyOver = function(self)
	return self.Invoke(self, 65519491, SerializerHelper.GmPartyOver_Serializer)
end

SerializerHelper.GmLinkInfo_Serializer = function(writer, mode)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmLinkInfo = function(self, mode)
	return self.Invoke(self, 65522862, SerializerHelper.GmLinkInfo_Serializer, mode)
end

SerializerHelper.GmSetFactionInfluence_Serializer = function(writer, factionid, setvalue)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, setvalue, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmSetFactionInfluence = function(self, factionid, setvalue)
	return self.Invoke(self, 65525187, SerializerHelper.GmSetFactionInfluence_Serializer, factionid, setvalue)
end

SerializerHelper.GmDisableIndoorSectorIds_Serializer = function(writer, indoorsectorid)
	SerializeBase.WritePrimitive(writer, indoorsectorid, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmDisableIndoorSectorIds = function(self, indoorsectorid)
	return self.Invoke(self, 65526245, SerializerHelper.GmDisableIndoorSectorIds_Serializer, indoorsectorid)
end

SerializerHelper.GmGetAllNodesNexts_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmGetAllNodesNexts = function(self, taskid)
	return self.Invoke(self, 65527767, SerializerHelper.GmGetAllNodesNexts_Serializer, taskid)
end

SerializerHelper.GmRemoveDailyChat_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmRemoveDailyChat = function(self, chatid)
	return self.Invoke(self, 65529300, SerializerHelper.GmRemoveDailyChat_Serializer, chatid)
end

SerializerHelper.GmAddHealItems_Serializer = function(writer)
end

ClientToGameGMDelegate.GmAddHealItems = function(self)
	return self.Invoke(self, 65533890, SerializerHelper.GmAddHealItems_Serializer)
end

SerializerHelper.GmFollowTeamLeader_Serializer = function(writer)
end

ClientToGameGMDelegate.GmFollowTeamLeader = function(self)
	return self.Invoke(self, 65534149, SerializerHelper.GmFollowTeamLeader_Serializer)
end

SerializerHelper.GmStartGameplayRentTest_Serializer = function(writer, fashionrentids)
	SerializeBase.WriteList7Bit(writer, fashionrentids, writer.WriteUInt32, 0, "fashionrentids", true, 0, nil)
end

ClientToGameGMDelegate.GmStartGameplayRentTest = function(self, fashionrentids)
	return self.Invoke(self, 65538645, SerializerHelper.GmStartGameplayRentTest_Serializer, fashionrentids)
end

SerializerHelper.GmEventUnlock_Serializer = function(writer, eventid, unlock)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmEventUnlock = function(self, eventid, unlock)
	return self.Invoke(self, 65540775, SerializerHelper.GmEventUnlock_Serializer, eventid, unlock)
end

SerializerHelper.GmAddAllFishes_Serializer = function(writer)
end

ClientToGameGMDelegate.GmAddAllFishes = function(self)
	return self.Invoke(self, 65541185, SerializerHelper.GmAddAllFishes_Serializer)
end

SerializerHelper.GmFillPlayerData_Serializer = function(writer)
end

ClientToGameGMDelegate.GmFillPlayerData = function(self)
	return self.Invoke(self, 65542800, SerializerHelper.GmFillPlayerData_Serializer)
end

SerializerHelper.GmAddYachtHeat_Serializer = function(writer, delta)
	SerializeBase.WritePrimitive(writer, delta, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddYachtHeat = function(self, delta)
	return self.Invoke(self, 65545084, SerializerHelper.GmAddYachtHeat_Serializer, delta)
end

SerializerHelper.GMClearAllGangMemberReviveCd_Serializer = function(writer)
end

ClientToGameGMDelegate.GMClearAllGangMemberReviveCd = function(self)
	return self.Invoke(self, 65547473, SerializerHelper.GMClearAllGangMemberReviveCd_Serializer)
end

SerializerHelper.ClearBag_Serializer = function(writer)
end

ClientToGameGMDelegate.ClearBag = function(self)
	return self.Invoke(self, 65550331, SerializerHelper.ClearBag_Serializer)
end

SerializerHelper.GmClearAllControllers_Serializer = function(writer, ocid)
	SerializeBase.WritePrimitive(writer, ocid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmClearAllControllers = function(self, ocid)
	return self.Invoke(self, 65551763, SerializerHelper.GmClearAllControllers_Serializer, ocid)
end

SerializerHelper.GmAddBuildHouseIndoor_Serializer = function(writer, houseid, floor, addplacedfurnitureinfo)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, addplacedfurnitureinfo, SerializeAuto.WriteAddPlacedFurnitureInfo, "addplacedfurnitureinfo")
end

ClientToGameGMDelegate.GmAddBuildHouseIndoor = function(self, houseid, floor, addplacedfurnitureinfo)
	return self.Invoke(self, 65553017, SerializerHelper.GmAddBuildHouseIndoor_Serializer, houseid, floor, addplacedfurnitureinfo)
end

SerializerHelper.GmChangeGameplayTalentPoint_Serializer = function(writer, gameplayid, talentpoint)
	SerializeBase.WritePrimitive(writer, gameplayid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, talentpoint, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmChangeGameplayTalentPoint = function(self, gameplayid, talentpoint)
	return self.Invoke(self, 65553304, SerializerHelper.GmChangeGameplayTalentPoint_Serializer, gameplayid, talentpoint)
end

SerializerHelper.GmGangBossLockGangMember_Serializer = function(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmGangBossLockGangMember = function(self, templateid)
	return self.Invoke(self, 65554338, SerializerHelper.GmGangBossLockGangMember_Serializer, templateid)
end

SerializerHelper.GmAskWebviewToken_Serializer = function(writer)
end

ClientToGameGMDelegate.GmAskWebviewToken = function(self)
	return self.Invoke(self, 65556426, SerializerHelper.GmAskWebviewToken_Serializer)
end

SerializerHelper.GmShowGuide_Serializer = function(writer, guideid)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmShowGuide = function(self, guideid)
	return self.Invoke(self, 65564550, SerializerHelper.GmShowGuide_Serializer, guideid)
end

SerializerHelper.GmSetGachaPityDrawsSinceLastReset_Serializer = function(writer, ruleid, drawssincelastreset)
	SerializeBase.WritePrimitive(writer, ruleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, drawssincelastreset, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetGachaPityDrawsSinceLastReset = function(self, ruleid, drawssincelastreset)
	return self.Invoke(self, 65565665, SerializerHelper.GmSetGachaPityDrawsSinceLastReset_Serializer, ruleid, drawssincelastreset)
end

SerializerHelper.GmOccupyFactionInfluenceArea_Serializer = function(writer, areaid, occupy)
	SerializeBase.WritePrimitive(writer, areaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, occupy, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmOccupyFactionInfluenceArea = function(self, areaid, occupy)
	return self.Invoke(self, 65567078, SerializerHelper.GmOccupyFactionInfluenceArea_Serializer, areaid, occupy)
end

SerializerHelper.GmQueryPlayerMahjongRoomId_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmQueryPlayerMahjongRoomId = function(self, pid)
	return self.Invoke(self, 65567321, SerializerHelper.GmQueryPlayerMahjongRoomId_Serializer, pid)
end

SerializerHelper.GmStopMatch_Serializer = function(writer)
end

ClientToGameGMDelegate.GmStopMatch = function(self)
	return self.Invoke(self, 65567858, SerializerHelper.GmStopMatch_Serializer)
end

SerializerHelper.GmUnlockPost_Serializer = function(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnlockPost = function(self, postid)
	return self.Invoke(self, 65567904, SerializerHelper.GmUnlockPost_Serializer, postid)
end

SerializerHelper.GmClearItemRecord_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearItemRecord = function(self)
	return self.Invoke(self, 65569340, SerializerHelper.GmClearItemRecord_Serializer)
end

SerializerHelper.GmAddMonthlyPass_Serializer = function(writer, monthlypassid, days)
	SerializeBase.WritePrimitive(writer, monthlypassid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, days, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddMonthlyPass = function(self, monthlypassid, days)
	return self.Invoke(self, 65571332, SerializerHelper.GmAddMonthlyPass_Serializer, monthlypassid, days)
end

SerializerHelper.GmGetHousesInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmGetHousesInfo = function(self)
	return self.Invoke(self, 65573942, SerializerHelper.GmGetHousesInfo_Serializer)
end

SerializerHelper.GMTriggerPlayerFallingDown_Serializer = function(writer)
end

ClientToGameGMDelegate.GMTriggerPlayerFallingDown = function(self)
	return self.Invoke(self, 65574476, SerializerHelper.GMTriggerPlayerFallingDown_Serializer)
end

SerializerHelper.GmGangBossKillMember_Serializer = function(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmGangBossKillMember = function(self, templateid)
	return self.Invoke(self, 65575734, SerializerHelper.GmGangBossKillMember_Serializer, templateid)
end

SerializerHelper.GmClearWorldLifeDropLimit_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearWorldLifeDropLimit = function(self)
	return self.Invoke(self, 65578387, SerializerHelper.GmClearWorldLifeDropLimit_Serializer)
end

SerializerHelper.GmAddTestFavorNpcTempSchedule_Serializer = function(writer, agenttag, aliveseconds)
	SerializeBase.WritePrimitive(writer, agenttag, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, aliveseconds, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddTestFavorNpcTempSchedule = function(self, agenttag, aliveseconds)
	return self.Invoke(self, 65578538, SerializerHelper.GmAddTestFavorNpcTempSchedule_Serializer, agenttag, aliveseconds)
end

SerializerHelper.GmRemoveBuildHouseIndoor_Serializer = function(writer, houseid, floor, removeplacedinstanceidlist)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, removeplacedinstanceidlist, writer.WriteUInt64, 0, "removeplacedinstanceidlist", false, 0, nil)
end

ClientToGameGMDelegate.GmRemoveBuildHouseIndoor = function(self, houseid, floor, removeplacedinstanceidlist)
	return self.Invoke(self, 65581525, SerializerHelper.GmRemoveBuildHouseIndoor_Serializer, houseid, floor, removeplacedinstanceidlist)
end

SerializerHelper.GmClearDailyRewards_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearDailyRewards = function(self)
	return self.Invoke(self, 65581548, SerializerHelper.GmClearDailyRewards_Serializer)
end

SerializerHelper.GmAcceptRaidTaskAndSubmitPre_Serializer = function(writer, taskid, self, team)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, self, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, team, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmAcceptRaidTaskAndSubmitPre = function(self, taskid, self, team)
	return self.Invoke(self, 65585579, SerializerHelper.GmAcceptRaidTaskAndSubmitPre_Serializer, taskid, self, team)
end

SerializerHelper.GmClearFerrisWheelTickets_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearFerrisWheelTickets = function(self)
	return self.Invoke(self, 65585632, SerializerHelper.GmClearFerrisWheelTickets_Serializer)
end

SerializerHelper.GMBasketballBuzzerBeater_Serializer = function(writer, mode, score)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMBasketballBuzzerBeater = function(self, mode, score)
	return self.Invoke(self, 65587909, SerializerHelper.GMBasketballBuzzerBeater_Serializer, mode, score)
end

SerializerHelper.GmShowHandTiles_Serializer = function(writer)
end

ClientToGameGMDelegate.GmShowHandTiles = function(self)
	return self.Invoke(self, 65589119, SerializerHelper.GmShowHandTiles_Serializer)
end

SerializerHelper.GmApplyDutySwap_Serializer = function(writer, sourceduty, targetpid, targetduty)
	SerializeBase.WritePrimitive(writer, sourceduty, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetduty, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmApplyDutySwap = function(self, sourceduty, targetpid, targetduty)
	return self.Invoke(self, 65589569, SerializerHelper.GmApplyDutySwap_Serializer, sourceduty, targetpid, targetduty)
end

SerializerHelper.GmQueryLifeScheduleNpcsSnapshot_Serializer = function(writer)
end

ClientToGameGMDelegate.GmQueryLifeScheduleNpcsSnapshot = function(self)
	return self.Invoke(self, 65592509, SerializerHelper.GmQueryLifeScheduleNpcsSnapshot_Serializer)
end

SerializerHelper.GmSetSpiritFashionSuits_Serializer = function(writer, spiritidlist, fashionsuitidlist)
	SerializeBase.WriteList7Bit(writer, spiritidlist, writer.WriteUInt32, 0, "spiritidlist", false, 0, nil)
	SerializeBase.WriteList7Bit(writer, fashionsuitidlist, writer.WriteUInt32, 0, "fashionsuitidlist", false, 0, nil)
end

ClientToGameGMDelegate.GmSetSpiritFashionSuits = function(self, spiritidlist, fashionsuitidlist)
	return self.Invoke(self, 65592616, SerializerHelper.GmSetSpiritFashionSuits_Serializer, spiritidlist, fashionsuitidlist)
end

SerializerHelper.GmExtractionShooterClearBag_Serializer = function(writer, bagconfigid)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmExtractionShooterClearBag = function(self, bagconfigid)
	return self.Invoke(self, 65593785, SerializerHelper.GmExtractionShooterClearBag_Serializer, bagconfigid)
end

SerializerHelper.GmAddPokemon_Serializer = function(writer, limbochaid)
	SerializeBase.WritePrimitive(writer, limbochaid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddPokemon = function(self, limbochaid)
	return self.Invoke(self, 65598021, SerializerHelper.GmAddPokemon_Serializer, limbochaid)
end

SerializerHelper.GmExtractionShooterBringOutItem_Serializer = function(writer, bagconfigid, cellx, celly)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmExtractionShooterBringOutItem = function(self, bagconfigid, cellx, celly)
	return self.Invoke(self, 65598600, SerializerHelper.GmExtractionShooterBringOutItem_Serializer, bagconfigid, cellx, celly)
end

SerializerHelper.GmSetStreak_Serializer = function(writer, multiplayerid, winstreak, losestreak)
	SerializeBase.WritePrimitive(writer, multiplayerid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, winstreak, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, losestreak, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmSetStreak = function(self, multiplayerid, winstreak, losestreak)
	return self.Invoke(self, 65598627, SerializerHelper.GmSetStreak_Serializer, multiplayerid, winstreak, losestreak)
end

SerializerHelper.GmHouseCancelParking_Serializer = function(writer, vehicleidlist)
	SerializeBase.WriteList7Bit(writer, vehicleidlist, writer.WriteUInt32, 0, "vehicleidlist", false, 0, nil)
end

ClientToGameGMDelegate.GmHouseCancelParking = function(self, vehicleidlist)
	return self.Invoke(self, 65601170, SerializerHelper.GmHouseCancelParking_Serializer, vehicleidlist)
end

SerializerHelper.GmRemoveChaosFishFromSpot_Serializer = function(writer, spotid)
	SerializeBase.WritePrimitive(writer, spotid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmRemoveChaosFishFromSpot = function(self, spotid)
	return self.Invoke(self, 65604940, SerializerHelper.GmRemoveChaosFishFromSpot_Serializer, spotid)
end

SerializerHelper.GmGetPlayerFashionsInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmGetPlayerFashionsInfo = function(self)
	return self.Invoke(self, 65606620, SerializerHelper.GmGetPlayerFashionsInfo_Serializer)
end

SerializerHelper.GmCreateUgcMapInfo_Serializer = function(writer, mapname, minplayercnt, maxplayercnt)
	writer.WriteString(writer, mapname, false, "GmCreateUgcMapInfo.mapName", 0)
	SerializeBase.WritePrimitive(writer, minplayercnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maxplayercnt, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmCreateUgcMapInfo = function(self, mapname, minplayercnt, maxplayercnt)
	return self.Invoke(self, 65608320, SerializerHelper.GmCreateUgcMapInfo_Serializer, mapname, minplayercnt, maxplayercnt)
end

SerializerHelper.GmSimulateTierMatch_Serializer = function(writer, data, matchcontext)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteTierSettleDataBase, "data", false)
	SerializeBase.WriteComplex(writer, matchcontext, SerializeAuto.WriteMatchContext, "matchcontext", false)
end

ClientToGameGMDelegate.GmSimulateTierMatch = function(self, data, matchcontext)
	return self.Invoke(self, 65608900, SerializerHelper.GmSimulateTierMatch_Serializer, data, matchcontext)
end

SerializerHelper.GMUnlockFightStyle_Serializer = function(writer, fightstyletypeid)
	SerializeBase.WritePrimitive(writer, fightstyletypeid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMUnlockFightStyle = function(self, fightstyletypeid)
	return self.Invoke(self, 65609171, SerializerHelper.GMUnlockFightStyle_Serializer, fightstyletypeid)
end

SerializerHelper.GmDonateFactionByCfgId_Serializer = function(writer, factionid, donateid)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, donateid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmDonateFactionByCfgId = function(self, factionid, donateid)
	return self.Invoke(self, 65610532, SerializerHelper.GmDonateFactionByCfgId_Serializer, factionid, donateid)
end

SerializerHelper.GmWasherRandomPickMission_Serializer = function(writer, index, missionid, randomcfgid)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, missionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, randomcfgid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmWasherRandomPickMission = function(self, index, missionid, randomcfgid)
	return self.Invoke(self, 65611237, SerializerHelper.GmWasherRandomPickMission_Serializer, index, missionid, randomcfgid)
end

SerializerHelper.GmDivinerSkipPersuadeStage_Serializer = function(writer, success, enterbattle)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, enterbattle, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmDivinerSkipPersuadeStage = function(self, success, enterbattle)
	return self.Invoke(self, 65615871, SerializerHelper.GmDivinerSkipPersuadeStage_Serializer, success, enterbattle)
end

SerializerHelper.GMAddSpiritSummonAgentWheelWeapon_Serializer = function(writer, wheelid, weaponid)
	SerializeBase.WritePrimitive(writer, wheelid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMAddSpiritSummonAgentWheelWeapon = function(self, wheelid, weaponid)
	return self.Invoke(self, 65619193, SerializerHelper.GMAddSpiritSummonAgentWheelWeapon_Serializer, wheelid, weaponid)
end

SerializerHelper.GmUnlockAllChefRecipe_Serializer = function(writer)
end

ClientToGameGMDelegate.GmUnlockAllChefRecipe = function(self)
	return self.Invoke(self, 65619488, SerializerHelper.GmUnlockAllChefRecipe_Serializer)
end

SerializerHelper.GMLockFightStyle_Serializer = function(writer, fightstyletypeid)
	SerializeBase.WritePrimitive(writer, fightstyletypeid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMLockFightStyle = function(self, fightstyletypeid)
	return self.Invoke(self, 65620860, SerializerHelper.GMLockFightStyle_Serializer, fightstyletypeid)
end

SerializerHelper.GMOnPlayerAskDestroyGangMember_Serializer = function(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMOnPlayerAskDestroyGangMember = function(self, templateid)
	return self.Invoke(self, 65623570, SerializerHelper.GMOnPlayerAskDestroyGangMember_Serializer, templateid)
end

SerializerHelper.ShowAllServerDumpInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.ShowAllServerDumpInfo = function(self)
	return self.Invoke(self, 65624560, SerializerHelper.ShowAllServerDumpInfo_Serializer)
end

SerializerHelper.GmExtractionShooterAddItem_Serializer = function(writer, bagconfigid, slotindex, itemid, count)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slotindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmExtractionShooterAddItem = function(self, bagconfigid, slotindex, itemid, count)
	return self.Invoke(self, 65625323, SerializerHelper.GmExtractionShooterAddItem_Serializer, bagconfigid, slotindex, itemid, count)
end

SerializerHelper.GmUnlockCompetitionGroup_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnlockCompetitionGroup = function(self, id)
	return self.Invoke(self, 65625874, SerializerHelper.GmUnlockCompetitionGroup_Serializer, id)
end

SerializerHelper.GetTaskCountersPosition_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GetTaskCountersPosition = function(self, taskid)
	return self.Invoke(self, 65629038, SerializerHelper.GetTaskCountersPosition_Serializer, taskid)
end

SerializerHelper.GmShowGuideTeach_Serializer = function(writer, guideteachid)
	SerializeBase.WritePrimitive(writer, guideteachid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmShowGuideTeach = function(self, guideteachid)
	return self.Invoke(self, 65631795, SerializerHelper.GmShowGuideTeach_Serializer, guideteachid)
end

SerializerHelper.GmLeavePartyRoom_Serializer = function(writer)
end

ClientToGameGMDelegate.GmLeavePartyRoom = function(self)
	return self.Invoke(self, 65632277, SerializerHelper.GmLeavePartyRoom_Serializer)
end

SerializerHelper.GmGetAllWorkActionNodes_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmGetAllWorkActionNodes = function(self, taskid)
	return self.Invoke(self, 65633284, SerializerHelper.GmGetAllWorkActionNodes_Serializer, taskid)
end

SerializerHelper.GmResetGachaGroupMilestone_Serializer = function(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmResetGachaGroupMilestone = function(self, groupid)
	return self.Invoke(self, 65634401, SerializerHelper.GmResetGachaGroupMilestone_Serializer, groupid)
end

SerializerHelper.GmFinishCurrentInterrogation_Serializer = function(writer, state)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(state, 47, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmFinishCurrentInterrogation = function(self, state)
	return self.Invoke(self, 65635090, SerializerHelper.GmFinishCurrentInterrogation_Serializer, state)
end

SerializerHelper.GmPoliceClearTodayCompleteMissionCnt_Serializer = function(writer)
end

ClientToGameGMDelegate.GmPoliceClearTodayCompleteMissionCnt = function(self)
	return self.Invoke(self, 65635352, SerializerHelper.GmPoliceClearTodayCompleteMissionCnt_Serializer)
end

SerializerHelper.GmSkipPrepare_Serializer = function(writer)
end

ClientToGameGMDelegate.GmSkipPrepare = function(self)
	return self.Invoke(self, 65635982, SerializerHelper.GmSkipPrepare_Serializer)
end

SerializerHelper.GmNpcRandomWearFashions_Serializer = function(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmNpcRandomWearFashions = function(self, spiritid)
	return self.Invoke(self, 65641207, SerializerHelper.GmNpcRandomWearFashions_Serializer, spiritid)
end

SerializerHelper.GmEventConditionGetInfos_Serializer = function(writer, module)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(module, 2, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmEventConditionGetInfos = function(self, module)
	return self.Invoke(self, 65641281, SerializerHelper.GmEventConditionGetInfos_Serializer, module)
end

SerializerHelper.GmClearMilkNpcFavor_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearMilkNpcFavor = function(self)
	return self.Invoke(self, 65649202, SerializerHelper.GmClearMilkNpcFavor_Serializer)
end

SerializerHelper.GmClearMeccaGrandpaParts_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearMeccaGrandpaParts = function(self)
	return self.Invoke(self, 65649911, SerializerHelper.GmClearMeccaGrandpaParts_Serializer)
end

SerializerHelper.GmAddAllPokemon_Serializer = function(writer)
end

ClientToGameGMDelegate.GmAddAllPokemon = function(self)
	return self.Invoke(self, 65650224, SerializerHelper.GmAddAllPokemon_Serializer)
end

SerializerHelper.GmStartGameplayHostTest_Serializer = function(writer, spiritid, mockfashionids)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, mockfashionids, writer.WriteUInt32, 0, "mockfashionids", true, 0, nil)
end

ClientToGameGMDelegate.GmStartGameplayHostTest = function(self, spiritid, mockfashionids)
	return self.Invoke(self, 65651242, SerializerHelper.GmStartGameplayHostTest_Serializer, spiritid, mockfashionids)
end

SerializerHelper.GmStartGameInTeam_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmStartGameInTeam = function(self, gameid)
	return self.Invoke(self, 65658848, SerializerHelper.GmStartGameInTeam_Serializer, gameid)
end

SerializerHelper.GmChangeSystem_Serializer = function(writer, id, unlock)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmChangeSystem = function(self, id, unlock)
	return self.Invoke(self, 65660287, SerializerHelper.GmChangeSystem_Serializer, id, unlock)
end

SerializerHelper.GmTestStackoverflow_Serializer = function(writer)
end

ClientToGameGMDelegate.GmTestStackoverflow = function(self)
	return self.Invoke(self, 65661065, SerializerHelper.GmTestStackoverflow_Serializer)
end

SerializerHelper.GmBreakdownItem_Serializer = function(writer, breakdownid, itemid, count)
	SerializeBase.WritePrimitive(writer, breakdownid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmBreakdownItem = function(self, breakdownid, itemid, count)
	return self.Invoke(self, 65662079, SerializerHelper.GmBreakdownItem_Serializer, breakdownid, itemid, count)
end

SerializerHelper.GmPoliceRPSCardStarLevel_Serializer = function(writer, rocklevel, paperlevel, scissorslevel)
	SerializeBase.WritePrimitive(writer, rocklevel, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, paperlevel, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, scissorslevel, writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmPoliceRPSCardStarLevel = function(self, rocklevel, paperlevel, scissorslevel)
	return self.Invoke(self, 65664438, SerializerHelper.GmPoliceRPSCardStarLevel_Serializer, rocklevel, paperlevel, scissorslevel)
end

SerializerHelper.GmPhoneAddContact_Serializer = function(writer, contactid)
	SerializeBase.WritePrimitive(writer, contactid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmPhoneAddContact = function(self, contactid)
	return self.Invoke(self, 65666874, SerializerHelper.GmPhoneAddContact_Serializer, contactid)
end

SerializerHelper.GmFinishTaskCounter_Serializer = function(writer, taskid, index, current)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, current, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmFinishTaskCounter = function(self, taskid, index, current)
	return self.Invoke(self, 65667695, SerializerHelper.GmFinishTaskCounter_Serializer, taskid, index, current)
end

SerializerHelper.GmJoinPartyRoom_Serializer = function(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmJoinPartyRoom = function(self, roomid)
	return self.Invoke(self, 65668192, SerializerHelper.GmJoinPartyRoom_Serializer, roomid)
end

SerializerHelper.GmAddIgnorePaokuLimit_Serializer = function(writer, limits, sourcetype, sourceid)
	SerializeBase.WriteList7Bit(writer, limits, writer.WriteUInt32, 0, "limits", false, 0, nil)
	SerializeBase.WritePrimitive(writer, sourcetype, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, sourceid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmAddIgnorePaokuLimit = function(self, limits, sourcetype, sourceid)
	return self.Invoke(self, 65670410, SerializerHelper.GmAddIgnorePaokuLimit_Serializer, limits, sourcetype, sourceid)
end

SerializerHelper.GmDonateFactionByMoney_Serializer = function(writer, factionid, money)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, money, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmDonateFactionByMoney = function(self, factionid, money)
	return self.Invoke(self, 65670772, SerializerHelper.GmDonateFactionByMoney_Serializer, factionid, money)
end

SerializerHelper.GmExtractionShooterRemoveItem_Serializer = function(writer, bagconfigid, cellx, celly)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmExtractionShooterRemoveItem = function(self, bagconfigid, cellx, celly)
	return self.Invoke(self, 65671598, SerializerHelper.GmExtractionShooterRemoveItem_Serializer, bagconfigid, cellx, celly)
end

SerializerHelper.GMActivateNpcCard_Serializer = function(writer, npccardid)
	SerializeBase.WritePrimitive(writer, npccardid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMActivateNpcCard = function(self, npccardid)
	return self.Invoke(self, 65671769, SerializerHelper.GMActivateNpcCard_Serializer, npccardid)
end

SerializerHelper.GMActivateLockedNpcCard_Serializer = function(writer, npccardid)
	SerializeBase.WritePrimitive(writer, npccardid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMActivateLockedNpcCard = function(self, npccardid)
	return self.Invoke(self, 65672523, SerializerHelper.GMActivateLockedNpcCard_Serializer, npccardid)
end

SerializerHelper.GmForceDeleteSpeech_Serializer = function(writer, speechname)
	writer.WriteString(writer, speechname, false, "GmForceDeleteSpeech.speechName", 0)
end

ClientToGameGMDelegate.GmForceDeleteSpeech = function(self, speechname)
	return self.Invoke(self, 65672801, SerializerHelper.GmForceDeleteSpeech_Serializer, speechname)
end

SerializerHelper.GmAddAllSpirits_Serializer = function(writer)
end

ClientToGameGMDelegate.GmAddAllSpirits = function(self)
	return self.Invoke(self, 65674296, SerializerHelper.GmAddAllSpirits_Serializer)
end

SerializerHelper.GmInvitePlayerInteractionAction_Serializer = function(writer, inviteepid, actionitemid)
	SerializeBase.WritePrimitive(writer, inviteepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionitemid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmInvitePlayerInteractionAction = function(self, inviteepid, actionitemid)
	return self.Invoke(self, 65677123, SerializerHelper.GmInvitePlayerInteractionAction_Serializer, inviteepid, actionitemid)
end

SerializerHelper.GmClearChallengeRecord_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearChallengeRecord = function(self)
	return self.Invoke(self, 65677675, SerializerHelper.GmClearChallengeRecord_Serializer)
end

SerializerHelper.GmConvertCommonSpiritTalentExp_Serializer = function(writer, spiritid, convertexp)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, convertexp, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmConvertCommonSpiritTalentExp = function(self, spiritid, convertexp)
	return self.Invoke(self, 65678727, SerializerHelper.GmConvertCommonSpiritTalentExp_Serializer, spiritid, convertexp)
end

SerializerHelper.GmSetTruckOrderLimitTime_Serializer = function(writer, uniqueid, limitseconds)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, limitseconds, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetTruckOrderLimitTime = function(self, uniqueid, limitseconds)
	return self.Invoke(self, 65680432, SerializerHelper.GmSetTruckOrderLimitTime_Serializer, uniqueid, limitseconds)
end

SerializerHelper.GmCompleteUrbanPlay_Serializer = function(writer, playresult)
	SerializeBase.WriteComplex(writer, playresult, SerializeAuto.WriteUrbanGamePlayResult, "playresult", false)
end

ClientToGameGMDelegate.GmCompleteUrbanPlay = function(self, playresult)
	return self.Invoke(self, 65680573, SerializerHelper.GmCompleteUrbanPlay_Serializer, playresult)
end

SerializerHelper.GmAddChaosFishToSpot_Serializer = function(writer, spotid, count)
	SerializeBase.WritePrimitive(writer, spotid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddChaosFishToSpot = function(self, spotid, count)
	return self.Invoke(self, 65682443, SerializerHelper.GmAddChaosFishToSpot_Serializer, spotid, count)
end

SerializerHelper.GmPlanningBoardClearStepOptions_Serializer = function(writer)
end

ClientToGameGMDelegate.GmPlanningBoardClearStepOptions = function(self)
	return self.Invoke(self, 65687241, SerializerHelper.GmPlanningBoardClearStepOptions_Serializer)
end

SerializerHelper.GmChangeIndoor_Serializer = function(writer, indoorid, enter)
	SerializeBase.WritePrimitive(writer, indoorid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmChangeIndoor = function(self, indoorid, enter)
	return self.Invoke(self, 65692559, SerializerHelper.GmChangeIndoor_Serializer, indoorid, enter)
end

SerializerHelper.GmCleanPackages_Serializer = function(writer)
end

ClientToGameGMDelegate.GmCleanPackages = function(self)
	return self.Invoke(self, 65692809, SerializerHelper.GmCleanPackages_Serializer)
end

SerializerHelper.GmNewPrivateLink_Serializer = function(writer)
end

ClientToGameGMDelegate.GmNewPrivateLink = function(self)
	return self.Invoke(self, 65693664, SerializerHelper.GmNewPrivateLink_Serializer)
end

SerializerHelper.FastReenter_Serializer = function(writer)
end

ClientToGameGMDelegate.FastReenter = function(self)
	return self.Invoke(self, 65694957, SerializerHelper.FastReenter_Serializer)
end

SerializerHelper.GmClearFarmerAllLand_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearFarmerAllLand = function(self)
	return self.Invoke(self, 65698658, SerializerHelper.GmClearFarmerAllLand_Serializer)
end

SerializerHelper.GmDebugReserveGpuDumps_Serializer = function(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmDebugReserveGpuDumps = function(self, value)
	return self.Invoke(self, 65703186, SerializerHelper.GmDebugReserveGpuDumps_Serializer, value)
end

SerializerHelper.GmStartPlayerInteractionAction_Serializer = function(writer)
end

ClientToGameGMDelegate.GmStartPlayerInteractionAction = function(self)
	return self.Invoke(self, 65706004, SerializerHelper.GmStartPlayerInteractionAction_Serializer)
end

SerializerHelper.GmResetSpiritJobTalent_Serializer = function(writer, spiritid, jobclassid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmResetSpiritJobTalent = function(self, spiritid, jobclassid)
	return self.Invoke(self, 65706403, SerializerHelper.GmResetSpiritJobTalent_Serializer, spiritid, jobclassid)
end

SerializerHelper.GmCastMatchVote_Serializer = function(writer, vote)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(vote, 37, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmCastMatchVote = function(self, vote)
	return self.Invoke(self, 65706628, SerializerHelper.GmCastMatchVote_Serializer, vote)
end

SerializerHelper.GmMallUnlockCommodity_Serializer = function(writer, commodityid)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmMallUnlockCommodity = function(self, commodityid)
	return self.Invoke(self, 65707600, SerializerHelper.GmMallUnlockCommodity_Serializer, commodityid)
end

SerializerHelper.GmSetReachNpcDiscard_Serializer = function(writer, seatindex, tile)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
	writer.WriteString(writer, tile, false, "GmSetReachNpcDiscard.tile", 0)
end

ClientToGameGMDelegate.GmSetReachNpcDiscard = function(self, seatindex, tile)
	return self.Invoke(self, 65708815, SerializerHelper.GmSetReachNpcDiscard_Serializer, seatindex, tile)
end

SerializerHelper.GmSetTimeFixLimit_Serializer = function(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmSetTimeFixLimit = function(self, enable)
	return self.Invoke(self, 65708974, SerializerHelper.GmSetTimeFixLimit_Serializer, enable)
end

SerializerHelper.GmPartyAddLikeAndGift_Serializer = function(writer, like, gift)
	SerializeBase.WritePrimitive(writer, like, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, gift, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmPartyAddLikeAndGift = function(self, like, gift)
	return self.Invoke(self, 65713759, SerializerHelper.GmPartyAddLikeAndGift_Serializer, like, gift)
end

SerializerHelper.GmModifyClubMemberActivity_Serializer = function(writer, diff)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmModifyClubMemberActivity = function(self, diff)
	return self.Invoke(self, 65714357, SerializerHelper.GmModifyClubMemberActivity_Serializer, diff)
end

SerializerHelper.GmSetWeatherParam_Serializer = function(writer, weatherparamid)
	SerializeBase.WritePrimitive(writer, weatherparamid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetWeatherParam = function(self, weatherparamid)
	return self.Invoke(self, 65715648, SerializerHelper.GmSetWeatherParam_Serializer, weatherparamid)
end

SerializerHelper.GmFarmerAddOrder_Serializer = function(writer, orderconfigid)
	SerializeBase.WritePrimitive(writer, orderconfigid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmFarmerAddOrder = function(self, orderconfigid)
	return self.Invoke(self, 65719059, SerializerHelper.GmFarmerAddOrder_Serializer, orderconfigid)
end

SerializerHelper.GmRemoveAllPokemon_Serializer = function(writer)
end

ClientToGameGMDelegate.GmRemoveAllPokemon = function(self)
	return self.Invoke(self, 65721875, SerializerHelper.GmRemoveAllPokemon_Serializer)
end

SerializerHelper.GmMonthlyPassSetRemainDays_Serializer = function(writer, monthlypassid, remaindays)
	SerializeBase.WritePrimitive(writer, monthlypassid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, remaindays, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmMonthlyPassSetRemainDays = function(self, monthlypassid, remaindays)
	return self.Invoke(self, 65722119, SerializerHelper.GmMonthlyPassSetRemainDays_Serializer, monthlypassid, remaindays)
end

SerializerHelper.GmRemovePaokuLimitClient_Serializer = function(writer, limit, sourcetype, sourceid)
	SerializeBase.WritePrimitive(writer, limit, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sourcetype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sourceid, writer.WriteInt64, 0)
end

ClientToGameGMDelegate.GmRemovePaokuLimitClient = function(self, limit, sourcetype, sourceid)
	return self.Invoke(self, 65722870, SerializerHelper.GmRemovePaokuLimitClient_Serializer, limit, sourcetype, sourceid)
end

SerializerHelper.GmInitFishingSpot_Serializer = function(writer, spotid)
	SerializeBase.WritePrimitive(writer, spotid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmInitFishingSpot = function(self, spotid)
	return self.Invoke(self, 65731616, SerializerHelper.GmInitFishingSpot_Serializer, spotid)
end

SerializerHelper.GmClearSkey_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearSkey = function(self)
	return self.Invoke(self, 65735475, SerializerHelper.GmClearSkey_Serializer)
end

SerializerHelper.GmGangBossUnlockGangMember_Serializer = function(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmGangBossUnlockGangMember = function(self, templateid)
	return self.Invoke(self, 65736059, SerializerHelper.GmGangBossUnlockGangMember_Serializer, templateid)
end

SerializerHelper.GmGetPlayerDumpInfo_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmGetPlayerDumpInfo = function(self, pid)
	return self.Invoke(self, 65738139, SerializerHelper.GmGetPlayerDumpInfo_Serializer, pid)
end

SerializerHelper.GmAddAllFashions_Serializer = function(writer, duration)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddAllFashions = function(self, duration)
	return self.Invoke(self, 65740743, SerializerHelper.GmAddAllFashions_Serializer, duration)
end

SerializerHelper.GmUnlockInvestigateGallery_Serializer = function(writer, galleryid, unlock)
	SerializeBase.WritePrimitive(writer, galleryid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmUnlockInvestigateGallery = function(self, galleryid, unlock)
	return self.Invoke(self, 65745107, SerializerHelper.GmUnlockInvestigateGallery_Serializer, galleryid, unlock)
end

SerializerHelper.GmBuyBoatTicketSingle_Serializer = function(writer, conductorid)
	SerializeBase.WritePrimitive(writer, conductorid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmBuyBoatTicketSingle = function(self, conductorid)
	return self.Invoke(self, 65748546, SerializerHelper.GmBuyBoatTicketSingle_Serializer, conductorid)
end

SerializerHelper.GmClearPostInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearPostInfo = function(self)
	return self.Invoke(self, 65750032, SerializerHelper.GmClearPostInfo_Serializer)
end

SerializerHelper.GmSetFavorNpcTimeTable_Serializer = function(writer, a1, a2, a3, a4)
	SerializeBase.WritePrimitive(writer, a1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, a2, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, a3, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, a4, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetFavorNpcTimeTable = function(self, a1, a2, a3, a4)
	return self.Invoke(self, 65751116, SerializerHelper.GmSetFavorNpcTimeTable_Serializer, a1, a2, a3, a4)
end

SerializerHelper.GmTradeBuyItem_Serializer = function(writer, tradeitemid, maxprice, count)
	SerializeBase.WritePrimitive(writer, tradeitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maxprice, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTradeBuyItem = function(self, tradeitemid, maxprice, count)
	return self.Invoke(self, 65751194, SerializerHelper.GmTradeBuyItem_Serializer, tradeitemid, maxprice, count)
end

SerializerHelper.GmSubmitEvent_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSubmitEvent = function(self, eventid)
	return self.Invoke(self, 65753296, SerializerHelper.GmSubmitEvent_Serializer, eventid)
end

SerializerHelper.GmActiveSpiritJobTalentLayer_Serializer = function(writer, spiritid, jobclassid, talentid, addlayer)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, talentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addlayer, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmActiveSpiritJobTalentLayer = function(self, spiritid, jobclassid, talentid, addlayer)
	return self.Invoke(self, 65754431, SerializerHelper.GmActiveSpiritJobTalentLayer_Serializer, spiritid, jobclassid, talentid, addlayer)
end

SerializerHelper.GMAddBattlePassExp_Serializer = function(writer, bpid, exptoadd)
	SerializeBase.WritePrimitive(writer, bpid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, exptoadd, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMAddBattlePassExp = function(self, bpid, exptoadd)
	return self.Invoke(self, 65754859, SerializerHelper.GMAddBattlePassExp_Serializer, bpid, exptoadd)
end

SerializerHelper.GmMatchGameComplete_Serializer = function(writer, success)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmMatchGameComplete = function(self, success)
	return self.Invoke(self, 65758014, SerializerHelper.GmMatchGameComplete_Serializer, success)
end

SerializerHelper.GmFastZengFu_Serializer = function(writer, needspecific)
	SerializeBase.WritePrimitive(writer, needspecific, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmFastZengFu = function(self, needspecific)
	return self.Invoke(self, 65758352, SerializerHelper.GmFastZengFu_Serializer, needspecific)
end

SerializerHelper.GMBasketballTimeout_Serializer = function(writer)
end

ClientToGameGMDelegate.GMBasketballTimeout = function(self)
	return self.Invoke(self, 65758353, SerializerHelper.GMBasketballTimeout_Serializer)
end

SerializerHelper.GMCloseComboSkillCheck_Serializer = function(writer)
end

ClientToGameGMDelegate.GMCloseComboSkillCheck = function(self)
	return self.Invoke(self, 65761099, SerializerHelper.GMCloseComboSkillCheck_Serializer)
end

SerializerHelper.GmExtractionShooterSplitItem_Serializer = function(writer, bagconfigid, splitcellx, splitcelly, splitcount, isrotated)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcount, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmExtractionShooterSplitItem = function(self, bagconfigid, splitcellx, splitcelly, splitcount, isrotated)
	return self.Invoke(self, 65761317, SerializerHelper.GmExtractionShooterSplitItem_Serializer, bagconfigid, splitcellx, splitcelly, splitcount, isrotated)
end

SerializerHelper.GmTradeSetCompositeProgress_Serializer = function(writer, boxid, count)
	SerializeBase.WritePrimitive(writer, boxid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmTradeSetCompositeProgress = function(self, boxid, count)
	return self.Invoke(self, 65761676, SerializerHelper.GmTradeSetCompositeProgress_Serializer, boxid, count)
end

SerializerHelper.GmClearVehicleRadioContentOnce_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearVehicleRadioContentOnce = function(self)
	return self.Invoke(self, 65762428, SerializerHelper.GmClearVehicleRadioContentOnce_Serializer)
end

SerializerHelper.GmSubmitAllTask_Serializer = function(writer, tabindex)
	SerializeBase.WritePrimitive(writer, tabindex, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSubmitAllTask = function(self, tabindex)
	return self.Invoke(self, 65763500, SerializerHelper.GmSubmitAllTask_Serializer, tabindex)
end

SerializerHelper.GmShowDialog_Serializer = function(writer, dialogid, taskid)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmShowDialog = function(self, dialogid, taskid)
	return self.Invoke(self, 65767898, SerializerHelper.GmShowDialog_Serializer, dialogid, taskid)
end

SerializerHelper.GmApplyJoinClub_Serializer = function(writer, clubid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmApplyJoinClub = function(self, clubid)
	return self.Invoke(self, 65768293, SerializerHelper.GmApplyJoinClub_Serializer, clubid)
end

SerializerHelper.GmShowMatchInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmShowMatchInfo = function(self)
	return self.Invoke(self, 65773192, SerializerHelper.GmShowMatchInfo_Serializer)
end

SerializerHelper.GmForceCompleteFavorNpcCommute_Serializer = function(writer, agenttag)
	SerializeBase.WritePrimitive(writer, agenttag, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmForceCompleteFavorNpcCommute = function(self, agenttag)
	return self.Invoke(self, 65773372, SerializerHelper.GmForceCompleteFavorNpcCommute_Serializer, agenttag)
end

SerializerHelper.GmBuffLibraryAdd_Serializer = function(writer, librarycfgid, spirittemplateid)
	SerializeBase.WritePrimitive(writer, librarycfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spirittemplateid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmBuffLibraryAdd = function(self, librarycfgid, spirittemplateid)
	return self.Invoke(self, 65773631, SerializerHelper.GmBuffLibraryAdd_Serializer, librarycfgid, spirittemplateid)
end

SerializerHelper.GmReportBattleData_Serializer = function(writer, content, filename)
	SerializeBase.WriteList7Bit(writer, content, writer.WriteByte, 0, "content", false, 0, nil)
	writer.WriteString(writer, filename, false, "GmReportBattleData.fileName", 0)
end

ClientToGameGMDelegate.GmReportBattleData = function(self, content, filename)
	return self.Invoke(self, 65780761, SerializerHelper.GmReportBattleData_Serializer, content, filename)
end

SerializerHelper.GmJobStart_Serializer = function(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmJobStart = function(self, jobclassid)
	return self.Invoke(self, 65783301, SerializerHelper.GmJobStart_Serializer, jobclassid)
end

SerializerHelper.GmPartyLiveAddEvent_Serializer = function(writer, eventid, message)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteInt32, 0)
	writer.WriteString(writer, message, true, "GmPartyLiveAddEvent.message", 0)
end

ClientToGameGMDelegate.GmPartyLiveAddEvent = function(self, eventid, message)
	return self.Invoke(self, 65785804, SerializerHelper.GmPartyLiveAddEvent_Serializer, eventid, message)
end

SerializerHelper.GmClearPlayerScore_Serializer = function(writer, tierconfigid)
	SerializeBase.WritePrimitive(writer, tierconfigid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearPlayerScore = function(self, tierconfigid)
	return self.Invoke(self, 65791108, SerializerHelper.GmClearPlayerScore_Serializer, tierconfigid)
end

SerializerHelper.GmLinkCreditReset_Serializer = function(writer)
end

ClientToGameGMDelegate.GmLinkCreditReset = function(self)
	return self.Invoke(self, 65793775, SerializerHelper.GmLinkCreditReset_Serializer)
end

SerializerHelper.GmInviteToPartyRoom_Serializer = function(writer, targetpid)
	SerializeBase.WritePrimitive(writer, targetpid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmInviteToPartyRoom = function(self, targetpid)
	return self.Invoke(self, 65794528, SerializerHelper.GmInviteToPartyRoom_Serializer, targetpid)
end

SerializerHelper.GmJobQuit_Serializer = function(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmJobQuit = function(self, jobclassid)
	return self.Invoke(self, 65797945, SerializerHelper.GmJobQuit_Serializer, jobclassid)
end

SerializerHelper.GmUnlockFarmerAllLand_Serializer = function(writer)
end

ClientToGameGMDelegate.GmUnlockFarmerAllLand = function(self)
	return self.Invoke(self, 65803613, SerializerHelper.GmUnlockFarmerAllLand_Serializer)
end

SerializerHelper.GmActiveGameplayTalentLayer_Serializer = function(writer, gameplayid, talentid, addlayer)
	SerializeBase.WritePrimitive(writer, gameplayid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, talentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addlayer, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmActiveGameplayTalentLayer = function(self, gameplayid, talentid, addlayer)
	return self.Invoke(self, 65806073, SerializerHelper.GmActiveGameplayTalentLayer_Serializer, gameplayid, talentid, addlayer)
end

SerializerHelper.GmEndMahjongGame_Serializer = function(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmEndMahjongGame = function(self, roomid)
	return self.Invoke(self, 65808365, SerializerHelper.GmEndMahjongGame_Serializer, roomid)
end

SerializerHelper.GmAddHouse_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddHouse = function(self, houseid)
	return self.Invoke(self, 65812421, SerializerHelper.GmAddHouse_Serializer, houseid)
end

SerializerHelper.GMBasketballBeSteal_Serializer = function(writer)
end

ClientToGameGMDelegate.GMBasketballBeSteal = function(self)
	return self.Invoke(self, 65816842, SerializerHelper.GMBasketballBeSteal_Serializer)
end

SerializerHelper.GmClientDialogFinish_Serializer = function(writer, dialogid)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClientDialogFinish = function(self, dialogid)
	return self.Invoke(self, 65818408, SerializerHelper.GmClientDialogFinish_Serializer, dialogid)
end

SerializerHelper.GmBindOCSpeech_Serializer = function(writer, ocid, speechname)
	SerializeBase.WritePrimitive(writer, ocid, writer.WriteUInt64, 0)
	writer.WriteString(writer, speechname, false, "GmBindOCSpeech.speechName", 0)
end

ClientToGameGMDelegate.GmBindOCSpeech = function(self, ocid, speechname)
	return self.Invoke(self, 65820461, SerializerHelper.GmBindOCSpeech_Serializer, ocid, speechname)
end

SerializerHelper.GmSetCompetitionPointAndStart_Serializer = function(writer, point, star)
	SerializeBase.WritePrimitive(writer, point, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, star, writer.WriteUInt16, 0)
end

ClientToGameGMDelegate.GmSetCompetitionPointAndStart = function(self, point, star)
	return self.Invoke(self, 65820748, SerializerHelper.GmSetCompetitionPointAndStart_Serializer, point, star)
end

SerializerHelper.GmAddFish_Serializer = function(writer, fishconfigid, weight, length)
	SerializeBase.WritePrimitive(writer, fishconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, weight, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, length, writer.WriteSingle, 0)
end

ClientToGameGMDelegate.GmAddFish = function(self, fishconfigid, weight, length)
	return self.Invoke(self, 65821551, SerializerHelper.GmAddFish_Serializer, fishconfigid, weight, length)
end

SerializerHelper.ForceChangeTaskState_Serializer = function(writer, taskid, info)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	writer.WriteString(writer, info, true, "ForceChangeTaskState.info", 0)
end

ClientToGameGMDelegate.ForceChangeTaskState = function(self, taskid, info)
	return self.Invoke(self, 65822796, SerializerHelper.ForceChangeTaskState_Serializer, taskid, info)
end

SerializerHelper.GMChangeNpcSendGiftCount_Serializer = function(writer, diff)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GMChangeNpcSendGiftCount = function(self, diff)
	return self.Invoke(self, 65823936, SerializerHelper.GMChangeNpcSendGiftCount_Serializer, diff)
end

SerializerHelper.GMInteractNpcWithGiftList_Serializer = function(writer, npcid, items)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
	writer.WriteString(writer, items, true, "GMInteractNpcWithGiftList.items", 0)
end

ClientToGameGMDelegate.GMInteractNpcWithGiftList = function(self, npcid, items)
	return self.Invoke(self, 65825546, SerializerHelper.GMInteractNpcWithGiftList_Serializer, npcid, items)
end

SerializerHelper.GmAddAllChefItems_Serializer = function(writer, count)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddAllChefItems = function(self, count)
	return self.Invoke(self, 65831770, SerializerHelper.GmAddAllChefItems_Serializer, count)
end

SerializerHelper.GMBasketballBeBlock_Serializer = function(writer)
end

ClientToGameGMDelegate.GMBasketballBeBlock = function(self)
	return self.Invoke(self, 65832326, SerializerHelper.GMBasketballBeBlock_Serializer)
end

SerializerHelper.GMUnlockAllFightStyle_Serializer = function(writer)
end

ClientToGameGMDelegate.GMUnlockAllFightStyle = function(self)
	return self.Invoke(self, 65833950, SerializerHelper.GMUnlockAllFightStyle_Serializer)
end

SerializerHelper.GmInviteNpcChat_Serializer = function(writer, gameplay)
	SerializeBase.WritePrimitive(writer, gameplay, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmInviteNpcChat = function(self, gameplay)
	return self.Invoke(self, 65834367, SerializerHelper.GmInviteNpcChat_Serializer, gameplay)
end

SerializerHelper.GmKickTeamMember_Serializer = function(writer, memberpid)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmKickTeamMember = function(self, memberpid)
	return self.Invoke(self, 65835096, SerializerHelper.GmKickTeamMember_Serializer, memberpid)
end

SerializerHelper.GmPhoneGetInfos_Serializer = function(writer)
end

ClientToGameGMDelegate.GmPhoneGetInfos = function(self)
	return self.Invoke(self, 65835103, SerializerHelper.GmPhoneGetInfos_Serializer)
end

SerializerHelper.GMInteractNpcWithGift_Serializer = function(writer, activityid, giftid, count)
	SerializeBase.WritePrimitive(writer, activityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, giftid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMInteractNpcWithGift = function(self, activityid, giftid, count)
	return self.Invoke(self, 65835576, SerializerHelper.GMInteractNpcWithGift_Serializer, activityid, giftid, count)
end

SerializerHelper.RemoveAllResults_Serializer = function(writer)
end

ClientToGameGMDelegate.RemoveAllResults = function(self)
	return self.Invoke(self, 65839766, SerializerHelper.RemoveAllResults_Serializer)
end

SerializerHelper.GmEnableIndoorSectorIds_Serializer = function(writer, indoorsectorid)
	SerializeBase.WritePrimitive(writer, indoorsectorid, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmEnableIndoorSectorIds = function(self, indoorsectorid)
	return self.Invoke(self, 65843050, SerializerHelper.GmEnableIndoorSectorIds_Serializer, indoorsectorid)
end

SerializerHelper.GmSetReachNextDraw_Serializer = function(writer, seatindex, tile)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
	writer.WriteString(writer, tile, false, "GmSetReachNextDraw.tile", 0)
end

ClientToGameGMDelegate.GmSetReachNextDraw = function(self, seatindex, tile)
	return self.Invoke(self, 65844925, SerializerHelper.GmSetReachNextDraw_Serializer, seatindex, tile)
end

SerializerHelper.GmChangeNpcInteractPoint_Serializer = function(writer, diff)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmChangeNpcInteractPoint = function(self, diff)
	return self.Invoke(self, 65846937, SerializerHelper.GmChangeNpcInteractPoint_Serializer, diff)
end

SerializerHelper.GmExtraStateConfirm_Serializer = function(writer, stateid, confirm)
	SerializeBase.WritePrimitive(writer, stateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, confirm, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmExtraStateConfirm = function(self, stateid, confirm)
	return self.Invoke(self, 65848476, SerializerHelper.GmExtraStateConfirm_Serializer, stateid, confirm)
end

SerializerHelper.CheckMahjongInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.CheckMahjongInfo = function(self)
	return self.Invoke(self, 65849051, SerializerHelper.CheckMahjongInfo_Serializer)
end

SerializerHelper.GmStartEventNode_Serializer = function(writer, taskid, nodeid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmStartEventNode = function(self, taskid, nodeid)
	return self.Invoke(self, 65851225, SerializerHelper.GmStartEventNode_Serializer, taskid, nodeid)
end

SerializerHelper.GMScientistAddRecipe_Serializer = function(writer, productid)
	SerializeBase.WritePrimitive(writer, productid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMScientistAddRecipe = function(self, productid)
	return self.Invoke(self, 65852997, SerializerHelper.GMScientistAddRecipe_Serializer, productid)
end

SerializerHelper.GmAddWeaponSkin_Serializer = function(writer, skinid)
	SerializeBase.WritePrimitive(writer, skinid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddWeaponSkin = function(self, skinid)
	return self.Invoke(self, 65853091, SerializerHelper.GmAddWeaponSkin_Serializer, skinid)
end

SerializerHelper.GmTriggerClubEvent_Serializer = function(writer, pushconfigid, val)
	SerializeBase.WritePrimitive(writer, pushconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, val, writer.WriteDouble, 0)
end

ClientToGameGMDelegate.GmTriggerClubEvent = function(self, pushconfigid, val)
	return self.Invoke(self, 65854088, SerializerHelper.GmTriggerClubEvent_Serializer, pushconfigid, val)
end

SerializerHelper.GMBasketballSteal_Serializer = function(writer)
end

ClientToGameGMDelegate.GMBasketballSteal = function(self)
	return self.Invoke(self, 65854837, SerializerHelper.GMBasketballSteal_Serializer)
end

SerializerHelper.GmSetPlayerScore_Serializer = function(writer, multiplayerid, score)
	SerializeBase.WritePrimitive(writer, multiplayerid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSetPlayerScore = function(self, multiplayerid, score)
	return self.Invoke(self, 65856870, SerializerHelper.GmSetPlayerScore_Serializer, multiplayerid, score)
end

SerializerHelper.GMMaxAllNpcFavor_Serializer = function(writer)
end

ClientToGameGMDelegate.GMMaxAllNpcFavor = function(self)
	return self.Invoke(self, 65858734, SerializerHelper.GMMaxAllNpcFavor_Serializer)
end

SerializerHelper.GmMonthlyPassSetCumulativeLoginDays_Serializer = function(writer, monthlypassid, days)
	SerializeBase.WritePrimitive(writer, monthlypassid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, days, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmMonthlyPassSetCumulativeLoginDays = function(self, monthlypassid, days)
	return self.Invoke(self, 65860418, SerializerHelper.GmMonthlyPassSetCumulativeLoginDays_Serializer, monthlypassid, days)
end

SerializerHelper.GmGetTaskEventNodes_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmGetTaskEventNodes = function(self, taskid)
	return self.Invoke(self, 65861233, SerializerHelper.GmGetTaskEventNodes_Serializer, taskid)
end

SerializerHelper.GmGetRanking_Serializer = function(writer, rankconfigid, topcount)
	SerializeBase.WritePrimitive(writer, rankconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, topcount, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmGetRanking = function(self, rankconfigid, topcount)
	return self.Invoke(self, 65863534, SerializerHelper.GmGetRanking_Serializer, rankconfigid, topcount)
end

SerializerHelper.GmDivinerLiveChatInteract_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmDivinerLiveChatInteract = function(self, eventid)
	return self.Invoke(self, 65865674, SerializerHelper.GmDivinerLiveChatInteract_Serializer, eventid)
end

SerializerHelper.CloseSocket_Serializer = function(writer, reason)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.CloseSocket = function(self, reason)
	return self.Invoke(self, 65866335, SerializerHelper.CloseSocket_Serializer, reason)
end

SerializerHelper.GmLinkLeave_Serializer = function(writer, mode)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmLinkLeave = function(self, mode)
	return self.Invoke(self, 65866340, SerializerHelper.GmLinkLeave_Serializer, mode)
end

SerializerHelper.GmInspireHubChangeGamePlayJoinCount_Serializer = function(writer, gameplayid, diff)
	SerializeBase.WritePrimitive(writer, gameplayid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmInspireHubChangeGamePlayJoinCount = function(self, gameplayid, diff)
	return self.Invoke(self, 65867730, SerializerHelper.GmInspireHubChangeGamePlayJoinCount_Serializer, gameplayid, diff)
end

SerializerHelper.GMStartPartyLottery_Serializer = function(writer)
end

ClientToGameGMDelegate.GMStartPartyLottery = function(self)
	return self.Invoke(self, 65871513, SerializerHelper.GMStartPartyLottery_Serializer)
end

SerializerHelper.GmChangeDeviceLevel_Serializer = function(writer, level)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(level, 48, 0), writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmChangeDeviceLevel = function(self, level)
	return self.Invoke(self, 65872964, SerializerHelper.GmChangeDeviceLevel_Serializer, level)
end

SerializerHelper.GmGetTruckJobOrders_Serializer = function(writer)
end

ClientToGameGMDelegate.GmGetTruckJobOrders = function(self)
	return self.Invoke(self, 65874528, SerializerHelper.GmGetTruckJobOrders_Serializer)
end

SerializerHelper.GmPoliceViolationResumptionWork_Serializer = function(writer)
end

ClientToGameGMDelegate.GmPoliceViolationResumptionWork = function(self)
	return self.Invoke(self, 65874616, SerializerHelper.GmPoliceViolationResumptionWork_Serializer)
end

SerializerHelper.GmSetJobLevel_Serializer = function(writer, jobclassid, level)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, level, writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmSetJobLevel = function(self, jobclassid, level)
	return self.Invoke(self, 65875858, SerializerHelper.GmSetJobLevel_Serializer, jobclassid, level)
end

SerializerHelper.GmAddAllPeiYangItems_Serializer = function(writer, count)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAddAllPeiYangItems = function(self, count)
	return self.Invoke(self, 65876633, SerializerHelper.GmAddAllPeiYangItems_Serializer, count)
end

SerializerHelper.GmRemoveFish_Serializer = function(writer, uniqueid)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmRemoveFish = function(self, uniqueid)
	return self.Invoke(self, 65880600, SerializerHelper.GmRemoveFish_Serializer, uniqueid)
end

SerializerHelper.GmDivinerAIChat_Serializer = function(writer, agentcfgid, stage, eventtype, patience, demandcfgid, personalityindex, msg, choiceindex, lang)
	SerializeBase.WritePrimitive(writer, agentcfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stage, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, eventtype, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, patience, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, demandcfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, personalityindex, writer.WriteUInt32, 0)
	writer.WriteString(writer, msg, false, "GmDivinerAIChat.msg", 0)
	SerializeBase.WritePrimitive(writer, choiceindex, writer.WriteInt32, 0)
	writer.WriteString(writer, lang, false, "GmDivinerAIChat.lang", 0)
end

ClientToGameGMDelegate.GmDivinerAIChat = function(self, agentcfgid, stage, eventtype, patience, demandcfgid, personalityindex, msg, choiceindex, lang)
	return self.Invoke(self, 65881449, SerializerHelper.GmDivinerAIChat_Serializer, agentcfgid, stage, eventtype, patience, demandcfgid, personalityindex, msg, choiceindex, lang)
end

SerializerHelper.GmDiscard_Serializer = function(writer, info)
	SerializeBase.WriteStruct(writer, info, SerializeAuto.WriteDiscardTileInfo, "info")
end

ClientToGameGMDelegate.GmDiscard = function(self, info)
	return self.Invoke(self, 65885487, SerializerHelper.GmDiscard_Serializer, info)
end

SerializerHelper.GmClearGuideTeach_Serializer = function(writer, guideteachid)
	SerializeBase.WritePrimitive(writer, guideteachid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearGuideTeach = function(self, guideteachid)
	return self.Invoke(self, 65887705, SerializerHelper.GmClearGuideTeach_Serializer, guideteachid)
end

SerializerHelper.GmPlanningBoardSetStepOption_Serializer = function(writer, stepid, optionindex)
	SerializeBase.WritePrimitive(writer, stepid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, optionindex, writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmPlanningBoardSetStepOption = function(self, stepid, optionindex)
	return self.Invoke(self, 65890564, SerializerHelper.GmPlanningBoardSetStepOption_Serializer, stepid, optionindex)
end

SerializerHelper.GmSetSpiritFashions_Serializer = function(writer, spiritidlist, fashionidlist)
	SerializeBase.WriteList7Bit(writer, spiritidlist, writer.WriteUInt32, 0, "spiritidlist", false, 0, nil)
	SerializeBase.WriteList7Bit(writer, fashionidlist, writer.WriteUInt32, 0, "fashionidlist", false, 0, nil)
end

ClientToGameGMDelegate.GmSetSpiritFashions = function(self, spiritidlist, fashionidlist)
	return self.Invoke(self, 65892022, SerializerHelper.GmSetSpiritFashions_Serializer, spiritidlist, fashionidlist)
end

SerializerHelper.GmScientistAddEnchantAffix_Serializer = function(writer, affixid)
	SerializeBase.WritePrimitive(writer, affixid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmScientistAddEnchantAffix = function(self, affixid)
	return self.Invoke(self, 65892800, SerializerHelper.GmScientistAddEnchantAffix_Serializer, affixid)
end

SerializerHelper.GmUnlockNpcActionItem_Serializer = function(writer, actionitemid)
	SerializeBase.WritePrimitive(writer, actionitemid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnlockNpcActionItem = function(self, actionitemid)
	return self.Invoke(self, 65895879, SerializerHelper.GmUnlockNpcActionItem_Serializer, actionitemid)
end

SerializerHelper.GMTurnOnComboSkillCheck_Serializer = function(writer)
end

ClientToGameGMDelegate.GMTurnOnComboSkillCheck = function(self)
	return self.Invoke(self, 65896751, SerializerHelper.GMTurnOnComboSkillCheck_Serializer)
end

SerializerHelper.GmClearNpcGroupChatInfo_Serializer = function(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmClearNpcGroupChatInfo = function(self, groupid)
	return self.Invoke(self, 65898112, SerializerHelper.GmClearNpcGroupChatInfo_Serializer, groupid)
end

SerializerHelper.GmUnlockAllNpcVoice_Serializer = function(writer)
end

ClientToGameGMDelegate.GmUnlockAllNpcVoice = function(self)
	return self.Invoke(self, 65904114, SerializerHelper.GmUnlockAllNpcVoice_Serializer)
end

SerializerHelper.GmSetFashionColoringSchemeInfos_Serializer = function(writer, fashioncoloringschemeinfolist)
	SerializeBase.WriteList7Bit(writer, fashioncoloringschemeinfolist, SerializeBase.WriteStructWrap(SerializeAuto.WriteFashionColoringSchemeInfo, "fashioncoloringschemeinfolist"), nil, "fashioncoloringschemeinfolist", false, 0, nil)
end

ClientToGameGMDelegate.GmSetFashionColoringSchemeInfos = function(self, fashioncoloringschemeinfolist)
	return self.Invoke(self, 65904546, SerializerHelper.GmSetFashionColoringSchemeInfos_Serializer, fashioncoloringschemeinfolist)
end

SerializerHelper.GmUpdateRanking_Serializer = function(writer, rankconfigid, score, forceupdate)
	SerializeBase.WritePrimitive(writer, rankconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteInt64, 0)
	SerializeBase.WritePrimitive(writer, forceupdate, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmUpdateRanking = function(self, rankconfigid, score, forceupdate)
	return self.Invoke(self, 65905689, SerializerHelper.GmUpdateRanking_Serializer, rankconfigid, score, forceupdate)
end

SerializerHelper.GmForceFollowPlayer_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmForceFollowPlayer = function(self, pid)
	return self.Invoke(self, 65906686, SerializerHelper.GmForceFollowPlayer_Serializer, pid)
end

SerializerHelper.GmSetAnimalFavor_Serializer = function(writer, animalid, favor, dailyfavor)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, favor, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, dailyfavor, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmSetAnimalFavor = function(self, animalid, favor, dailyfavor)
	return self.Invoke(self, 65909121, SerializerHelper.GmSetAnimalFavor_Serializer, animalid, favor, dailyfavor)
end

SerializerHelper.GmSetMMR_Serializer = function(writer, multiplayerid, mmr)
	SerializeBase.WritePrimitive(writer, multiplayerid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, mmr, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmSetMMR = function(self, multiplayerid, mmr)
	return self.Invoke(self, 65910840, SerializerHelper.GmSetMMR_Serializer, multiplayerid, mmr)
end

SerializerHelper.GMSetTaskDeviceLevel_Serializer = function(writer, level)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMSetTaskDeviceLevel = function(self, level)
	return self.Invoke(self, 65911419, SerializerHelper.GMSetTaskDeviceLevel_Serializer, level)
end

SerializerHelper.IgnoreRpcRushProtect_Serializer = function(writer)
end

ClientToGameGMDelegate.IgnoreRpcRushProtect = function(self)
	return self.Invoke(self, 65912532, SerializerHelper.IgnoreRpcRushProtect_Serializer)
end

SerializerHelper.GmClearGadgetDropLimit_Serializer = function(writer, dropid, uniqueid)
	SerializeBase.WritePrimitive(writer, dropid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmClearGadgetDropLimit = function(self, dropid, uniqueid)
	return self.Invoke(self, 65913423, SerializerHelper.GmClearGadgetDropLimit_Serializer, dropid, uniqueid)
end

SerializerHelper.GmUnlockAllFogMap_Serializer = function(writer, unlock)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmUnlockAllFogMap = function(self, unlock)
	return self.Invoke(self, 65914419, SerializerHelper.GmUnlockAllFogMap_Serializer, unlock)
end

SerializerHelper.GmAcceptTaskAndSubmitPre_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAcceptTaskAndSubmitPre = function(self, taskid)
	return self.Invoke(self, 65915368, SerializerHelper.GmAcceptTaskAndSubmitPre_Serializer, taskid)
end

SerializerHelper.GmStartPVEMahjong_Serializer = function(writer, gametype, seatindex)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmStartPVEMahjong = function(self, gametype, seatindex)
	return self.Invoke(self, 65916132, SerializerHelper.GmStartPVEMahjong_Serializer, gametype, seatindex)
end

SerializerHelper.GmUnsetSpiritAllFashions_Serializer = function(writer, spiritidlist)
	SerializeBase.WriteList7Bit(writer, spiritidlist, writer.WriteUInt32, 0, "spiritidlist", false, 0, nil)
end

ClientToGameGMDelegate.GmUnsetSpiritAllFashions = function(self, spiritidlist)
	return self.Invoke(self, 65917010, SerializerHelper.GmUnsetSpiritAllFashions_Serializer, spiritidlist)
end

SerializerHelper.GmSkipTruckDailyOrder_Serializer = function(writer)
end

ClientToGameGMDelegate.GmSkipTruckDailyOrder = function(self)
	return self.Invoke(self, 65918886, SerializerHelper.GmSkipTruckDailyOrder_Serializer)
end

SerializerHelper.GMTriggerNpcQueueEvent_Serializer = function(writer, id, ismanual)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ismanual, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GMTriggerNpcQueueEvent = function(self, id, ismanual)
	return self.Invoke(self, 65919818, SerializerHelper.GMTriggerNpcQueueEvent_Serializer, id, ismanual)
end

SerializerHelper.GmQuerySkey_Serializer = function(writer)
end

ClientToGameGMDelegate.GmQuerySkey = function(self)
	return self.Invoke(self, 65920258, SerializerHelper.GmQuerySkey_Serializer)
end

SerializerHelper.GmClearSignRecord_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearSignRecord = function(self)
	return self.Invoke(self, 65920526, SerializerHelper.GmClearSignRecord_Serializer)
end

SerializerHelper.GmClearPhoneAppDownloadHistory_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearPhoneAppDownloadHistory = function(self)
	return self.Invoke(self, 65921762, SerializerHelper.GmClearPhoneAppDownloadHistory_Serializer)
end

SerializerHelper.GmQueryOCInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmQueryOCInfo = function(self)
	return self.Invoke(self, 65923042, SerializerHelper.GmQueryOCInfo_Serializer)
end

SerializerHelper.GmTestJoinVoiceTeam_Serializer = function(writer, channel, id)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(channel, 10, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmTestJoinVoiceTeam = function(self, channel, id)
	return self.Invoke(self, 65927072, SerializerHelper.GmTestJoinVoiceTeam_Serializer, channel, id)
end

SerializerHelper.GmStartSingleGame_Serializer = function(writer, gameid, difficuty)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, difficuty, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmStartSingleGame = function(self, gameid, difficuty)
	return self.Invoke(self, 65929769, SerializerHelper.GmStartSingleGame_Serializer, gameid, difficuty)
end

SerializerHelper.GmClearFirstKillEnemyRecord_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearFirstKillEnemyRecord = function(self)
	return self.Invoke(self, 65932920, SerializerHelper.GmClearFirstKillEnemyRecord_Serializer)
end

SerializerHelper.GmDeleteUgcMapInfo_Serializer = function(writer, mapid)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmDeleteUgcMapInfo = function(self, mapid)
	return self.Invoke(self, 65933661, SerializerHelper.GmDeleteUgcMapInfo_Serializer, mapid)
end

SerializerHelper.GmUtils_Serializer = function(writer, methodname, args)
	writer.WriteString(writer, methodname, false, "GmUtils.methodName", 0)
	SerializeBase.WriteList7Bit(writer, args, SerializeBase.WriteStringWrap(false, "args", 0), nil, "args", false, 0, nil)
end

ClientToGameGMDelegate.GmUtils = function(self, methodname, args)
	return self.Invoke(self, 65937886, SerializerHelper.GmUtils_Serializer, methodname, args)
end

SerializerHelper.GmReturnOriginalMode_Serializer = function(writer)
end

ClientToGameGMDelegate.GmReturnOriginalMode = function(self)
	return self.Invoke(self, 65943226, SerializerHelper.GmReturnOriginalMode_Serializer)
end

SerializerHelper.GmBuffLibraryRemove_Serializer = function(writer, librarycfgid, spirittemplateid)
	SerializeBase.WritePrimitive(writer, librarycfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spirittemplateid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmBuffLibraryRemove = function(self, librarycfgid, spirittemplateid)
	return self.Invoke(self, 65943761, SerializerHelper.GmBuffLibraryRemove_Serializer, librarycfgid, spirittemplateid)
end

SerializerHelper.GMRemoveActiveNpcCard_Serializer = function(writer, npccardid)
	SerializeBase.WritePrimitive(writer, npccardid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GMRemoveActiveNpcCard = function(self, npccardid)
	return self.Invoke(self, 65944236, SerializerHelper.GMRemoveActiveNpcCard_Serializer, npccardid)
end

SerializerHelper.GmShowPartyInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmShowPartyInfo = function(self)
	return self.Invoke(self, 65945146, SerializerHelper.GmShowPartyInfo_Serializer)
end

SerializerHelper.GmEnterOtherRaid_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmEnterOtherRaid = function(self, pid)
	return self.Invoke(self, 65947251, SerializerHelper.GmEnterOtherRaid_Serializer, pid)
end

SerializerHelper.GmLinkShowInfo_Serializer = function(writer)
end

ClientToGameGMDelegate.GmLinkShowInfo = function(self)
	return self.Invoke(self, 65951349, SerializerHelper.GmLinkShowInfo_Serializer)
end

SerializerHelper.GMUnlockAllCityPedia_Serializer = function(writer)
end

ClientToGameGMDelegate.GMUnlockAllCityPedia = function(self)
	return self.Invoke(self, 65951679, SerializerHelper.GMUnlockAllCityPedia_Serializer)
end

SerializerHelper.GmSpawnFishingSpotFish_Serializer = function(writer, spotid)
	SerializeBase.WritePrimitive(writer, spotid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmSpawnFishingSpotFish = function(self, spotid)
	return self.Invoke(self, 65951681, SerializerHelper.GmSpawnFishingSpotFish_Serializer, spotid)
end

SerializerHelper.GmEnterRogueRaid_Serializer = function(writer, rogueid)
	SerializeBase.WritePrimitive(writer, rogueid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmEnterRogueRaid = function(self, rogueid)
	return self.Invoke(self, 65952827, SerializerHelper.GmEnterRogueRaid_Serializer, rogueid)
end

SerializerHelper.GmRemoveFashionSuitInstance_Serializer = function(writer, fashionsuitid, suitinstanceid)
	SerializeBase.WritePrimitive(writer, fashionsuitid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, suitinstanceid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmRemoveFashionSuitInstance = function(self, fashionsuitid, suitinstanceid)
	return self.Invoke(self, 65953411, SerializerHelper.GmRemoveFashionSuitInstance_Serializer, fashionsuitid, suitinstanceid)
end

SerializerHelper.GmLoadHouseTemplate_Serializer = function(writer, houseid, furnituretemplateids, walldataid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	writer.WriteString(writer, furnituretemplateids, false, "GmLoadHouseTemplate.furnitureTemplateIds", 0)
	SerializeBase.WritePrimitive(writer, walldataid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmLoadHouseTemplate = function(self, houseid, furnituretemplateids, walldataid)
	return self.Invoke(self, 65955115, SerializerHelper.GmLoadHouseTemplate_Serializer, houseid, furnituretemplateids, walldataid)
end

SerializerHelper.GmFinishAllGuides_Serializer = function(writer)
end

ClientToGameGMDelegate.GmFinishAllGuides = function(self)
	return self.Invoke(self, 65956919, SerializerHelper.GmFinishAllGuides_Serializer)
end

SerializerHelper.GmModifyClubActivity_Serializer = function(writer, diff)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmModifyClubActivity = function(self, diff)
	return self.Invoke(self, 65957880, SerializerHelper.GmModifyClubActivity_Serializer, diff)
end

SerializerHelper.GmClearAllAchievement_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearAllAchievement = function(self)
	return self.Invoke(self, 65958454, SerializerHelper.GmClearAllAchievement_Serializer)
end

SerializerHelper.GmChangeName_Serializer = function(writer, name)
	writer.WriteString(writer, name, false, "GmChangeName.name", 0)
end

ClientToGameGMDelegate.GmChangeName = function(self, name)
	return self.Invoke(self, 65962516, SerializerHelper.GmChangeName_Serializer, name)
end

SerializerHelper.GmMallBuyCommodity_Serializer = function(writer, commodityid, buycnt, autoexchange, ignorecheckandconsume)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buycnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, autoexchange, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorecheckandconsume, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmMallBuyCommodity = function(self, commodityid, buycnt, autoexchange, ignorecheckandconsume)
	return self.Invoke(self, 65963563, SerializerHelper.GmMallBuyCommodity_Serializer, commodityid, buycnt, autoexchange, ignorecheckandconsume)
end

SerializerHelper.GmResetSubmitItemCount_Serializer = function(writer, submiteventid, count)
	SerializeBase.WritePrimitive(writer, submiteventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmResetSubmitItemCount = function(self, submiteventid, count)
	return self.Invoke(self, 65966107, SerializerHelper.GmResetSubmitItemCount_Serializer, submiteventid, count)
end

SerializerHelper.GmDeleteOC_Serializer = function(writer, ocid)
	SerializeBase.WritePrimitive(writer, ocid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GmDeleteOC = function(self, ocid)
	return self.Invoke(self, 65969391, SerializerHelper.GmDeleteOC_Serializer, ocid)
end

SerializerHelper.GmAcceptTask_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmAcceptTask = function(self, taskid)
	return self.Invoke(self, 65969473, SerializerHelper.GmAcceptTask_Serializer, taskid)
end

SerializerHelper.GmClearBartenderGame_Serializer = function(writer)
end

ClientToGameGMDelegate.GmClearBartenderGame = function(self)
	return self.Invoke(self, 65969552, SerializerHelper.GmClearBartenderGame_Serializer)
end

SerializerHelper.GmRenameChatGroupName_Serializer = function(writer, groupid, textid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, textid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmRenameChatGroupName = function(self, groupid, textid)
	return self.Invoke(self, 65970386, SerializerHelper.GmRenameChatGroupName_Serializer, groupid, textid)
end

SerializerHelper.GmChaosMasterGacha_Serializer = function(writer, poolid, count)
	SerializeBase.WritePrimitive(writer, poolid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmChaosMasterGacha = function(self, poolid, count)
	return self.Invoke(self, 65971055, SerializerHelper.GmChaosMasterGacha_Serializer, poolid, count)
end

SerializerHelper.GmObsoleteCurTruckJobOrder_Serializer = function(writer)
end

ClientToGameGMDelegate.GmObsoleteCurTruckJobOrder = function(self)
	return self.Invoke(self, 65971209, SerializerHelper.GmObsoleteCurTruckJobOrder_Serializer)
end

SerializerHelper.GmRandomCharacterRandomDialog_Serializer = function(writer, agentid, maintag)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maintag, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmRandomCharacterRandomDialog = function(self, agentid, maintag)
	return self.Invoke(self, 65971592, SerializerHelper.GmRandomCharacterRandomDialog_Serializer, agentid, maintag)
end

SerializerHelper.GmCreateAiOnVehicle_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmCreateAiOnVehicle = function(self, taskid)
	return self.Invoke(self, 65974744, SerializerHelper.GmCreateAiOnVehicle_Serializer, taskid)
end

SerializerHelper.GmFakeFileAcceptTaskEvent_Serializer = function(writer, fakefileid)
	SerializeBase.WritePrimitive(writer, fakefileid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmFakeFileAcceptTaskEvent = function(self, fakefileid)
	return self.Invoke(self, 65977558, SerializerHelper.GmFakeFileAcceptTaskEvent_Serializer, fakefileid)
end

SerializerHelper.GmSetControllerValue_Serializer = function(writer, ocid, controllerid, value)
	SerializeBase.WritePrimitive(writer, ocid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, controllerid, writer.WriteUInt16, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteByte, 0)
end

ClientToGameGMDelegate.GmSetControllerValue = function(self, ocid, controllerid, value)
	return self.Invoke(self, 65978316, SerializerHelper.GmSetControllerValue_Serializer, ocid, controllerid, value)
end

SerializerHelper.GmDivinerLiveChatOpen_Serializer = function(writer)
end

ClientToGameGMDelegate.GmDivinerLiveChatOpen = function(self)
	return self.Invoke(self, 65981908, SerializerHelper.GmDivinerLiveChatOpen_Serializer)
end

SerializerHelper.GmNpcChat_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmNpcChat = function(self, chatid)
	return self.Invoke(self, 65982583, SerializerHelper.GmNpcChat_Serializer, chatid)
end

SerializerHelper.GmAddFactionDisposition_Serializer = function(writer, factionid, addvalue)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteInt32, 0)
end

ClientToGameGMDelegate.GmAddFactionDisposition = function(self, factionid, addvalue)
	return self.Invoke(self, 65982962, SerializerHelper.GmAddFactionDisposition_Serializer, factionid, addvalue)
end

SerializerHelper.GMReverseSeat_Serializer = function(writer, linkid)
	SerializeBase.WritePrimitive(writer, linkid, writer.WriteUInt64, 0)
end

ClientToGameGMDelegate.GMReverseSeat = function(self, linkid)
	return self.Invoke(self, 65984984, SerializerHelper.GMReverseSeat_Serializer, linkid)
end

SerializerHelper.GmCustomLinkExit_Serializer = function(writer)
end

ClientToGameGMDelegate.GmCustomLinkExit = function(self)
	return self.Invoke(self, 65990862, SerializerHelper.GmCustomLinkExit_Serializer)
end

SerializerHelper.GmUnlockComputerFile_Serializer = function(writer, fileid)
	SerializeBase.WritePrimitive(writer, fileid, writer.WriteUInt32, 0)
end

ClientToGameGMDelegate.GmUnlockComputerFile = function(self, fileid)
	return self.Invoke(self, 65993764, SerializerHelper.GmUnlockComputerFile_Serializer, fileid)
end

SerializerHelper.GmTeleportTaskCounter_Serializer = function(writer, taskid, index, current, all)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, current, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, all, writer.WriteBoolean, false)
end

ClientToGameGMDelegate.GmTeleportTaskCounter = function(self, taskid, index, current, all)
	return self.Invoke(self, 65994906, SerializerHelper.GmTeleportTaskCounter_Serializer, taskid, index, current, all)
end

return ClientToGameGMDelegate
