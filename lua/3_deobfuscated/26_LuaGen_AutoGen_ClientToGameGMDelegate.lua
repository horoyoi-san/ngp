local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGameGMDelegate = invoker:New()

function ClientToGameGMDelegate.Sender()
	return NetworkManager.LuaGameRpcProcessor
end

function SerializerHelper.GmRemoveAllPokemon_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmRemoveAllPokemon()
	return self:Invoke(65001013, SerializerHelper.GmRemoveAllPokemon_Serializer)
end

function SerializerHelper.GmCleanPackages_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmCleanPackages()
	return self:Invoke(65003274, SerializerHelper.GmCleanPackages_Serializer)
end

function SerializerHelper.GmStartMatchInTeam_Serializer(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmStartMatchInTeam(gameid)
	return self:Invoke(65009433, SerializerHelper.GmStartMatchInTeam_Serializer, gameid)
end

function SerializerHelper.GmUnlockInvestigateGallery_Serializer(writer, galleryid, unlock)
	SerializeBase.WritePrimitive(writer, galleryid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmUnlockInvestigateGallery(galleryid, unlock)
	return self:Invoke(65009948, SerializerHelper.GmUnlockInvestigateGallery_Serializer, galleryid, unlock)
end

function SerializerHelper.GmAcceptSpecialTruckJobOrder_Serializer(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAcceptSpecialTruckJobOrder(orderid)
	return self:Invoke(65010990, SerializerHelper.GmAcceptSpecialTruckJobOrder_Serializer, orderid)
end

function SerializerHelper.GmShowMatchInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmShowMatchInfo()
	return self:Invoke(65019475, SerializerHelper.GmShowMatchInfo_Serializer)
end

function SerializerHelper.GmHouseCancelParking_Serializer(writer, vehicleidlist)
	SerializeBase.WriteList(writer, vehicleidlist, writer.WriteUInt32, 0, "vehicleidlist", false, 256, nil)
end

function ClientToGameGMDelegate:GmHouseCancelParking(vehicleidlist)
	return self:Invoke(65019540, SerializerHelper.GmHouseCancelParking_Serializer, vehicleidlist)
end

function SerializerHelper.GmClearAllSubQuest_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearAllSubQuest()
	return self:Invoke(65024621, SerializerHelper.GmClearAllSubQuest_Serializer)
end

function SerializerHelper.GmResetGachaPityHistory_Serializer(writer, ruleid)
	SerializeBase.WritePrimitive(writer, ruleid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmResetGachaPityHistory(ruleid)
	return self:Invoke(65025084, SerializerHelper.GmResetGachaPityHistory_Serializer, ruleid)
end

function SerializerHelper.GmPhoneGetInfos_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmPhoneGetInfos()
	return self:Invoke(65027905, SerializerHelper.GmPhoneGetInfos_Serializer)
end

function SerializerHelper.GMReverseSeat_Serializer(writer, linkid)
	SerializeBase.WritePrimitive(writer, linkid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GMReverseSeat(linkid)
	return self:Invoke(65031157, SerializerHelper.GMReverseSeat_Serializer, linkid)
end

function SerializerHelper.GmPlayGameAgain_Serializer(writer, nextgame)
	SerializeBase.WritePrimitive(writer, nextgame, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmPlayGameAgain(nextgame)
	return self:Invoke(65033549, SerializerHelper.GmPlayGameAgain_Serializer, nextgame)
end

function SerializerHelper.GmSubmitAllTask_Serializer(writer, tabindex)
	SerializeBase.WritePrimitive(writer, tabindex, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSubmitAllTask(tabindex)
	return self:Invoke(65034847, SerializerHelper.GmSubmitAllTask_Serializer, tabindex)
end

function SerializerHelper.GmAnalysisSimpleGridData_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmAnalysisSimpleGridData()
	return self:Invoke(65035092, SerializerHelper.GmAnalysisSimpleGridData_Serializer)
end

function SerializerHelper.GmAddFakeMirrorDelta_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmAddFakeMirrorDelta()
	return self:Invoke(65037547, SerializerHelper.GmAddFakeMirrorDelta_Serializer)
end

function SerializerHelper.GMLockFightStyle_Serializer(writer, fightstyletypeid)
	SerializeBase.WritePrimitive(writer, fightstyletypeid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMLockFightStyle(fightstyletypeid)
	return self:Invoke(65038616, SerializerHelper.GMLockFightStyle_Serializer, fightstyletypeid)
end

function SerializerHelper.GmAddFactionInfluence_Serializer(writer, factionid, addvalue)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmAddFactionInfluence(factionid, addvalue)
	return self:Invoke(65039689, SerializerHelper.GmAddFactionInfluence_Serializer, factionid, addvalue)
end

function SerializerHelper.GmStartGameInTeam_Serializer(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmStartGameInTeam(gameid)
	return self:Invoke(65043194, SerializerHelper.GmStartGameInTeam_Serializer, gameid)
end

function SerializerHelper.GmClearGuides_Serializer(writer, guideid)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmClearGuides(guideid)
	return self:Invoke(65043943, SerializerHelper.GmClearGuides_Serializer, guideid)
end

function SerializerHelper.GmSetMapEntrance_Serializer(writer, mapentranceid, isopenandshow)
	SerializeBase.WritePrimitive(writer, mapentranceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isopenandshow, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmSetMapEntrance(mapentranceid, isopenandshow)
	return self:Invoke(65046173, SerializerHelper.GmSetMapEntrance_Serializer, mapentranceid, isopenandshow)
end

function SerializerHelper.GmGangBossUnlockGangMember_Serializer(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmGangBossUnlockGangMember(templateid)
	return self:Invoke(65048208, SerializerHelper.GmGangBossUnlockGangMember_Serializer, templateid)
end

function SerializerHelper.GmAskNameAnimal_Serializer(writer, animalid, nickname)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	writer:WriteString(nickname, false, "nickname", 256)
end

function ClientToGameGMDelegate:GmAskNameAnimal(animalid, nickname)
	return self:Invoke(65051887, SerializerHelper.GmAskNameAnimal_Serializer, animalid, nickname)
end

function SerializerHelper.GmClearAllAchievement_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearAllAchievement()
	return self:Invoke(65054041, SerializerHelper.GmClearAllAchievement_Serializer)
end

function SerializerHelper.GetTaskCountersPosition_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GetTaskCountersPosition(taskid)
	return self:Invoke(65063582, SerializerHelper.GetTaskCountersPosition_Serializer, taskid)
end

function SerializerHelper.GmRefreshCurrentShop_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmRefreshCurrentShop()
	return self:Invoke(65063650, SerializerHelper.GmRefreshCurrentShop_Serializer)
end

function SerializerHelper.GmClearDropLimit_Serializer(writer, dropid)
	SerializeBase.WritePrimitive(writer, dropid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmClearDropLimit(dropid)
	return self:Invoke(65069435, SerializerHelper.GmClearDropLimit_Serializer, dropid)
end

function SerializerHelper.GmTestCrash_Serializer(writer, type)
	SerializeBase.WritePrimitive(writer, type, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmTestCrash(type)
	return self:Invoke(65075942, SerializerHelper.GmTestCrash_Serializer, type)
end

function SerializerHelper.GmAskWebviewToken_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmAskWebviewToken()
	return self:Invoke(65076841, SerializerHelper.GmAskWebviewToken_Serializer)
end

function SerializerHelper.GmInspireHubChangeGamePlayJoinCount_Serializer(writer, gameplayid, diff)
	SerializeBase.WritePrimitive(writer, gameplayid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmInspireHubChangeGamePlayJoinCount(gameplayid, diff)
	return self:Invoke(65080572, SerializerHelper.GmInspireHubChangeGamePlayJoinCount_Serializer, gameplayid, diff)
end

function SerializerHelper.GmLinkReplyInvite_Serializer(writer, friendpid, mode, accept)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmLinkReplyInvite(friendpid, mode, accept)
	return self:Invoke(65083687, SerializerHelper.GmLinkReplyInvite_Serializer, friendpid, mode, accept)
end

function SerializerHelper.GmGetTaskEventNodes_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmGetTaskEventNodes(taskid)
	return self:Invoke(65086338, SerializerHelper.GmGetTaskEventNodes_Serializer, taskid)
end

function SerializerHelper.GmLinkInvite_Serializer(writer, friendpid, mode, doublecheck)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, doublecheck, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmLinkInvite(friendpid, mode, doublecheck)
	return self:Invoke(65086342, SerializerHelper.GmLinkInvite_Serializer, friendpid, mode, doublecheck)
end

function SerializerHelper.GmCreateTeam_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmCreateTeam()
	return self:Invoke(65086368, SerializerHelper.GmCreateTeam_Serializer)
end

function SerializerHelper.GmDisableIndoorSectorIds_Serializer(writer, indoorsectorid)
	SerializeBase.WritePrimitive(writer, indoorsectorid, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmDisableIndoorSectorIds(indoorsectorid)
	return self:Invoke(65090965, SerializerHelper.GmDisableIndoorSectorIds_Serializer, indoorsectorid)
end

function SerializerHelper.GmRandomCharacterRandomDialog_Serializer(writer, agentid, maintag)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maintag, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmRandomCharacterRandomDialog(agentid, maintag)
	return self:Invoke(65095004, SerializerHelper.GmRandomCharacterRandomDialog_Serializer, agentid, maintag)
end

function SerializerHelper.GmKickFriendInRoom_Serializer(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GmKickFriendInRoom(friendpid)
	return self:Invoke(65096287, SerializerHelper.GmKickFriendInRoom_Serializer, friendpid)
end

function SerializerHelper.GmUtils_Serializer(writer, methodname, args)
	writer:WriteString(methodname, false, "methodname", 0)
	SerializeBase.WriteList(writer, args, SerializeBase.WriteStringWrap(false, "args", 0), nil, "args", false, 0, nil)
end

function ClientToGameGMDelegate:GmUtils(methodname, args)
	return self:Invoke(65096709, SerializerHelper.GmUtils_Serializer, methodname, args)
end

function SerializerHelper.GmQuickPlaySingleGame_Serializer(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmQuickPlaySingleGame(gameid)
	return self:Invoke(65098587, SerializerHelper.GmQuickPlaySingleGame_Serializer, gameid)
end

function SerializerHelper.GmSetAnimalFavor_Serializer(writer, animalid, favor, dailyfavor)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, favor, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, dailyfavor, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmSetAnimalFavor(animalid, favor, dailyfavor)
	return self:Invoke(65101071, SerializerHelper.GmSetAnimalFavor_Serializer, animalid, favor, dailyfavor)
end

function SerializerHelper.GmSubmitEvent_Serializer(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSubmitEvent(eventid)
	return self:Invoke(65104800, SerializerHelper.GmSubmitEvent_Serializer, eventid)
end

function SerializerHelper.GmAllTaskResetByTitle_Serializer(writer, titleid)
	SerializeBase.WritePrimitive(writer, titleid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAllTaskResetByTitle(titleid)
	return self:Invoke(65108122, SerializerHelper.GmAllTaskResetByTitle_Serializer, titleid)
end

function SerializerHelper.GmStopMatch_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmStopMatch()
	return self:Invoke(65108954, SerializerHelper.GmStopMatch_Serializer)
end

function SerializerHelper.GmFakeFileAcceptTaskEvent_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmFakeFileAcceptTaskEvent()
	return self:Invoke(65114298, SerializerHelper.GmFakeFileAcceptTaskEvent_Serializer)
end

function SerializerHelper.GmHouseParking_Serializer(writer, houseidlist, vehicleidlist)
	SerializeBase.WriteList(writer, houseidlist, writer.WriteUInt32, 0, "houseidlist", false, 0, nil)
	SerializeBase.WriteList(writer, vehicleidlist, writer.WriteUInt32, 0, "vehicleidlist", false, 256, nil)
end

function ClientToGameGMDelegate:GmHouseParking(houseidlist, vehicleidlist)
	return self:Invoke(65118918, SerializerHelper.GmHouseParking_Serializer, houseidlist, vehicleidlist)
end

function SerializerHelper.GmIsGameUnlock_Serializer(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmIsGameUnlock(gameid)
	return self:Invoke(65119414, SerializerHelper.GmIsGameUnlock_Serializer, gameid)
end

function SerializerHelper.GmResetBuildHouseIndoor_Serializer(writer, houseid, resetfloor)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, resetfloor, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmResetBuildHouseIndoor(houseid, resetfloor)
	return self:Invoke(65121965, SerializerHelper.GmResetBuildHouseIndoor_Serializer, houseid, resetfloor)
end

function SerializerHelper.GmInjectFixPatch_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmInjectFixPatch()
	return self:Invoke(65124630, SerializerHelper.GmInjectFixPatch_Serializer)
end

function SerializerHelper.GmJobPromote_Serializer(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmJobPromote(jobclassid)
	return self:Invoke(65132412, SerializerHelper.GmJobPromote_Serializer, jobclassid)
end

function SerializerHelper.GMChangeNpcSendGiftCount_Serializer(writer, diff)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GMChangeNpcSendGiftCount(diff)
	return self:Invoke(65133346, SerializerHelper.GMChangeNpcSendGiftCount_Serializer, diff)
end

function SerializerHelper.GmSetJobLevel_Serializer(writer, jobclassid, level)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, level, writer.WriteByte, 0)
end

function ClientToGameGMDelegate:GmSetJobLevel(jobclassid, level)
	return self:Invoke(65134906, SerializerHelper.GmSetJobLevel_Serializer, jobclassid, level)
end

function SerializerHelper.GMGetPSNBlackList_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GMGetPSNBlackList()
	return self:Invoke(65140892, SerializerHelper.GMGetPSNBlackList_Serializer)
end

function SerializerHelper.GmLinkCreditReset_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmLinkCreditReset()
	return self:Invoke(65144411, SerializerHelper.GmLinkCreditReset_Serializer)
end

function SerializerHelper.GmRemoveFashions_Serializer(writer, fashionidlist)
	SerializeBase.WriteList(writer, fashionidlist, writer.WriteUInt32, 0, "fashionidlist", false, 0, nil)
end

function ClientToGameGMDelegate:GmRemoveFashions(fashionidlist)
	return self:Invoke(65147493, SerializerHelper.GmRemoveFashions_Serializer, fashionidlist)
end

function SerializerHelper.GmStartSingleParty_Serializer(writer, partyid, clearevent)
	SerializeBase.WritePrimitive(writer, partyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, clearevent, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmStartSingleParty(partyid, clearevent)
	return self:Invoke(65150235, SerializerHelper.GmStartSingleParty_Serializer, partyid, clearevent)
end

function SerializerHelper.GmPurchaseElement_Serializer(writer, bartenderid, elementid, purchasecount)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, purchasecount, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmPurchaseElement(bartenderid, elementid, purchasecount)
	return self:Invoke(65152194, SerializerHelper.GmPurchaseElement_Serializer, bartenderid, elementid, purchasecount)
end

function SerializerHelper.GmClearFerrisWheelTickets_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearFerrisWheelTickets()
	return self:Invoke(65168835, SerializerHelper.GmClearFerrisWheelTickets_Serializer)
end

function SerializerHelper.GmTestStackoverflow_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmTestStackoverflow()
	return self:Invoke(65169491, SerializerHelper.GmTestStackoverflow_Serializer)
end

function SerializerHelper.GmClearSkey_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearSkey()
	return self:Invoke(65170078, SerializerHelper.GmClearSkey_Serializer)
end

function SerializerHelper.GmRemoveDailyChat_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmRemoveDailyChat(chatid)
	return self:Invoke(65181256, SerializerHelper.GmRemoveDailyChat_Serializer, chatid)
end

function SerializerHelper.GmSwitchReadyToPlay_Serializer(writer, readystatus)
	SerializeBase.WritePrimitive(writer, readystatus, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmSwitchReadyToPlay(readystatus)
	return self:Invoke(65182253, SerializerHelper.GmSwitchReadyToPlay_Serializer, readystatus)
end

function SerializerHelper.GmJobEnd_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmJobEnd()
	return self:Invoke(65182984, SerializerHelper.GmJobEnd_Serializer)
end

function SerializerHelper.GMClearLockedNpcCardInfo_Serializer(writer, npccardid)
	SerializeBase.WritePrimitive(writer, npccardid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMClearLockedNpcCardInfo(npccardid)
	return self:Invoke(65185876, SerializerHelper.GMClearLockedNpcCardInfo_Serializer, npccardid)
end

function SerializerHelper.GmSurrenderVote_Serializer(writer, vote)
	SerializeBase.WritePrimitive(writer, vote, writer.WriteByte, 0)
end

function ClientToGameGMDelegate:GmSurrenderVote(vote)
	return self:Invoke(65189868, SerializerHelper.GmSurrenderVote_Serializer, vote)
end

function SerializerHelper.GMActivateLockedNpcCard_Serializer(writer, npccardid)
	SerializeBase.WritePrimitive(writer, npccardid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMActivateLockedNpcCard(npccardid)
	return self:Invoke(65190145, SerializerHelper.GMActivateLockedNpcCard_Serializer, npccardid)
end

function SerializerHelper.GmAddPoliceViolation_Serializer(writer, type)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddPoliceViolation(type)
	return self:Invoke(65195789, SerializerHelper.GmAddPoliceViolation_Serializer, type)
end

function SerializerHelper.GmGetAllNodesNexts_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmGetAllNodesNexts(taskid)
	return self:Invoke(65202950, SerializerHelper.GmGetAllNodesNexts_Serializer, taskid)
end

function SerializerHelper.GmGangBossKillMember_Serializer(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmGangBossKillMember(templateid)
	return self:Invoke(65204180, SerializerHelper.GmGangBossKillMember_Serializer, templateid)
end

function SerializerHelper.GmNpcChat_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmNpcChat(chatid)
	return self:Invoke(65204185, SerializerHelper.GmNpcChat_Serializer, chatid)
end

function SerializerHelper.GmClearDailyChatInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearDailyChatInfo()
	return self:Invoke(65207901, SerializerHelper.GmClearDailyChatInfo_Serializer)
end

function SerializerHelper.GmTriggerDailyChat_Serializer(writer, forcetime)
	SerializeBase.WritePrimitive(writer, forcetime, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmTriggerDailyChat(forcetime)
	return self:Invoke(65208444, SerializerHelper.GmTriggerDailyChat_Serializer, forcetime)
end

function SerializerHelper.GmSetSpiritFashions_Serializer(writer, spiritidlist, fashionidlist)
	SerializeBase.WriteList(writer, spiritidlist, writer.WriteUInt32, 0, "spiritidlist", false, 0, nil)
	SerializeBase.WriteList(writer, fashionidlist, writer.WriteUInt32, 0, "fashionidlist", false, 0, nil)
end

function ClientToGameGMDelegate:GmSetSpiritFashions(spiritidlist, fashionidlist)
	return self:Invoke(65209096, SerializerHelper.GmSetSpiritFashions_Serializer, spiritidlist, fashionidlist)
end

function SerializerHelper.GMUnlockAllFightStyle_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GMUnlockAllFightStyle()
	return self:Invoke(65210905, SerializerHelper.GMUnlockAllFightStyle_Serializer)
end

function SerializerHelper.GmCompleteTruckJobOrder_Serializer(writer, uniqueid, completeness)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, completeness, writer.WriteSingle, 0)
end

function ClientToGameGMDelegate:GmCompleteTruckJobOrder(uniqueid, completeness)
	return self:Invoke(65210931, SerializerHelper.GmCompleteTruckJobOrder_Serializer, uniqueid, completeness)
end

function SerializerHelper.GmConfirmMatchResult_Serializer(writer, ready)
	SerializeBase.WritePrimitive(writer, ready, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmConfirmMatchResult(ready)
	return self:Invoke(65213448, SerializerHelper.GmConfirmMatchResult_Serializer, ready)
end

function SerializerHelper.GmAddLifeSkillItem_Serializer(writer, item, count)
	SerializeBase.WritePrimitive(writer, item, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddLifeSkillItem(item, count)
	return self:Invoke(65215051, SerializerHelper.GmAddLifeSkillItem_Serializer, item, count)
end

function SerializerHelper.GmPhoneAddContact_Serializer(writer, contactid)
	SerializeBase.WritePrimitive(writer, contactid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmPhoneAddContact(contactid)
	return self:Invoke(65215225, SerializerHelper.GmPhoneAddContact_Serializer, contactid)
end

function SerializerHelper.GmClearItemRecord_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearItemRecord()
	return self:Invoke(65215272, SerializerHelper.GmClearItemRecord_Serializer)
end

function SerializerHelper.GmChaosMasterGacha_Serializer(writer, poolid, count)
	SerializeBase.WritePrimitive(writer, poolid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmChaosMasterGacha(poolid, count)
	return self:Invoke(65216824, SerializerHelper.GmChaosMasterGacha_Serializer, poolid, count)
end

function SerializerHelper.GmShowGuideTeach_Serializer(writer, guideteachid)
	SerializeBase.WritePrimitive(writer, guideteachid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmShowGuideTeach(guideteachid)
	return self:Invoke(65218093, SerializerHelper.GmShowGuideTeach_Serializer, guideteachid)
end

function SerializerHelper.CheckMahjongInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:CheckMahjongInfo()
	return self:Invoke(65221859, SerializerHelper.CheckMahjongInfo_Serializer)
end

function SerializerHelper.GmLinkShowSyncRateInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmLinkShowSyncRateInfo()
	return self:Invoke(65223564, SerializerHelper.GmLinkShowSyncRateInfo_Serializer)
end

function SerializerHelper.GmClearFirstKillEnemyRecord_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearFirstKillEnemyRecord()
	return self:Invoke(65226371, SerializerHelper.GmClearFirstKillEnemyRecord_Serializer)
end

function SerializerHelper.GMActivateAllNpcCard_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GMActivateAllNpcCard()
	return self:Invoke(65230026, SerializerHelper.GMActivateAllNpcCard_Serializer)
end

function SerializerHelper.GmStartEventNode_Serializer(writer, taskid, nodeid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmStartEventNode(taskid, nodeid)
	return self:Invoke(65231464, SerializerHelper.GmStartEventNode_Serializer, taskid, nodeid)
end

function SerializerHelper.GmNpcRandomWearFashions_Serializer(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmNpcRandomWearFashions(spiritid)
	return self:Invoke(65237431, SerializerHelper.GmNpcRandomWearFashions_Serializer, spiritid)
end

function SerializerHelper.ClientToGameGmQA_Serializer(writer, code, args)
	writer:WriteString(code, false, "code", 0)
	writer:WriteString(args, true, "args", 0)
end

function ClientToGameGMDelegate:ClientToGameGmQA(code, args)
	return self:Invoke(65245525, SerializerHelper.ClientToGameGmQA_Serializer, code, args)
end

function SerializerHelper.GmSetRankScore_Serializer(writer, score)
	SerializeBase.WritePrimitive(writer, score, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmSetRankScore(score)
	return self:Invoke(65246345, SerializerHelper.GmSetRankScore_Serializer, score)
end

function SerializerHelper.GmClearChallengeRecord_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearChallengeRecord()
	return self:Invoke(65260296, SerializerHelper.GmClearChallengeRecord_Serializer)
end

function SerializerHelper.GmShowGuide_Serializer(writer, guideid)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmShowGuide(guideid)
	return self:Invoke(65264610, SerializerHelper.GmShowGuide_Serializer, guideid)
end

function SerializerHelper.GmClearNpcChatInfo_Serializer(writer, npccultivationid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmClearNpcChatInfo(npccultivationid)
	return self:Invoke(65265180, SerializerHelper.GmClearNpcChatInfo_Serializer, npccultivationid)
end

function SerializerHelper.GmCompletedSubQuest_Serializer(writer, subquestid)
	SerializeBase.WritePrimitive(writer, subquestid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmCompletedSubQuest(subquestid)
	return self:Invoke(65266230, SerializerHelper.GmCompletedSubQuest_Serializer, subquestid)
end

function SerializerHelper.GmLinkAddAllMembersSyncRate_Serializer(writer, addvalue)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteSingle, 0)
end

function ClientToGameGMDelegate:GmLinkAddAllMembersSyncRate(addvalue)
	return self:Invoke(65267267, SerializerHelper.GmLinkAddAllMembersSyncRate_Serializer, addvalue)
end

function SerializerHelper.GmClearBartenderGame_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearBartenderGame()
	return self:Invoke(65273187, SerializerHelper.GmClearBartenderGame_Serializer)
end

function SerializerHelper.GmMatchGameComplete_Serializer(writer, success)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmMatchGameComplete(success)
	return self:Invoke(65273364, SerializerHelper.GmMatchGameComplete_Serializer, success)
end

function SerializerHelper.GmMallRefreshCommodity_Serializer(writer, commodityid)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmMallRefreshCommodity(commodityid)
	return self:Invoke(65273481, SerializerHelper.GmMallRefreshCommodity_Serializer, commodityid)
end

function SerializerHelper.GmClearDailyRewards_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearDailyRewards()
	return self:Invoke(65279736, SerializerHelper.GmClearDailyRewards_Serializer)
end

function SerializerHelper.GmEnterOtherRaid_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GmEnterOtherRaid(pid)
	return self:Invoke(65279843, SerializerHelper.GmEnterOtherRaid_Serializer, pid)
end

function SerializerHelper.GMInteractNpcWithGiftList_Serializer(writer, npcid, items)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
	writer:WriteString(items, true, "items", 0)
end

function ClientToGameGMDelegate:GMInteractNpcWithGiftList(npcid, items)
	return self:Invoke(65279974, SerializerHelper.GMInteractNpcWithGiftList_Serializer, npcid, items)
end

function SerializerHelper.GmShowDialog_Serializer(writer, dialogid, taskid)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmShowDialog(dialogid, taskid)
	return self:Invoke(65281627, SerializerHelper.GmShowDialog_Serializer, dialogid, taskid)
end

function SerializerHelper.GmEditSpiritFashionTransform_Serializer(writer, spiritidlist, wearfashionidlist, edittransformlist)
	SerializeBase.WriteList(writer, spiritidlist, writer.WriteUInt32, 0, "spiritidlist", false, 0, nil)
	SerializeBase.WriteList(writer, wearfashionidlist, writer.WriteUInt32, 0, "wearfashionidlist", false, 0, nil)
	SerializeBase.WriteList(writer, edittransformlist, writer.WriteSingle, 0, "edittransformlist", false, 7, nil)
end

function ClientToGameGMDelegate:GmEditSpiritFashionTransform(spiritidlist, wearfashionidlist, edittransformlist)
	return self:Invoke(65284016, SerializerHelper.GmEditSpiritFashionTransform_Serializer, spiritidlist, wearfashionidlist, edittransformlist)
end

function SerializerHelper.GmStartBartenderGame_Serializer(writer, bartenderid)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmStartBartenderGame(bartenderid)
	return self:Invoke(65289161, SerializerHelper.GmStartBartenderGame_Serializer, bartenderid)
end

function SerializerHelper.GmResetHackPosts_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmResetHackPosts()
	return self:Invoke(65297057, SerializerHelper.GmResetHackPosts_Serializer)
end

function SerializerHelper.GmClearTruckJobOrders_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearTruckJobOrders()
	return self:Invoke(65308960, SerializerHelper.GmClearTruckJobOrders_Serializer)
end

function SerializerHelper.GmStartPVEMahjong_Serializer(writer, gametype, seatindex)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmStartPVEMahjong(gametype, seatindex)
	return self:Invoke(65311046, SerializerHelper.GmStartPVEMahjong_Serializer, gametype, seatindex)
end

function SerializerHelper.FastReenter_Serializer(writer)
	return
end

function ClientToGameGMDelegate:FastReenter()
	return self:Invoke(65312053, SerializerHelper.FastReenter_Serializer)
end

function SerializerHelper.GMRemoveActiveNpcCard_Serializer(writer, npccardid)
	SerializeBase.WritePrimitive(writer, npccardid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMRemoveActiveNpcCard(npccardid)
	return self:Invoke(65314806, SerializerHelper.GMRemoveActiveNpcCard_Serializer, npccardid)
end

function SerializerHelper.GmClearNpcGroupChatInfo_Serializer(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmClearNpcGroupChatInfo(groupid)
	return self:Invoke(65323507, SerializerHelper.GmClearNpcGroupChatInfo_Serializer, groupid)
end

function SerializerHelper.GMAddCredit_Serializer(writer, credittoadd)
	SerializeBase.WritePrimitive(writer, credittoadd, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMAddCredit(credittoadd)
	return self:Invoke(65329084, SerializerHelper.GMAddCredit_Serializer, credittoadd)
end

function SerializerHelper.GmSetTimeFixLimit_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmSetTimeFixLimit(enable)
	return self:Invoke(65334927, SerializerHelper.GmSetTimeFixLimit_Serializer, enable)
end

function SerializerHelper.GmRemoveBuildHouseIndoor_Serializer(writer, houseid, floor, removeplacedinstanceidlist)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, removeplacedinstanceidlist, writer.WriteUInt64, 0, "removeplacedinstanceidlist", false, 256, nil)
end

function ClientToGameGMDelegate:GmRemoveBuildHouseIndoor(houseid, floor, removeplacedinstanceidlist)
	return self:Invoke(65337098, SerializerHelper.GmRemoveBuildHouseIndoor_Serializer, houseid, floor, removeplacedinstanceidlist)
end

function SerializerHelper.GmMallUnlockCommodity_Serializer(writer, commodityid)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmMallUnlockCommodity(commodityid)
	return self:Invoke(65340852, SerializerHelper.GmMallUnlockCommodity_Serializer, commodityid)
end

function SerializerHelper.GmJobTake_Serializer(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmJobTake(jobclassid)
	return self:Invoke(65353454, SerializerHelper.GmJobTake_Serializer, jobclassid)
end

function SerializerHelper.GmGangBossSetSummonLimitNum_Serializer(writer, summonlimitnum)
	SerializeBase.WritePrimitive(writer, summonlimitnum, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmGangBossSetSummonLimitNum(summonlimitnum)
	return self:Invoke(65362710, SerializerHelper.GmGangBossSetSummonLimitNum_Serializer, summonlimitnum)
end

function SerializerHelper.GmAddAllFashions_Serializer(writer, duration)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddAllFashions(duration)
	return self:Invoke(65369037, SerializerHelper.GmAddAllFashions_Serializer, duration)
end

function SerializerHelper.GMPSNSetting_Serializer(writer, ispsnplayer, openid)
	SerializeBase.WritePrimitive(writer, ispsnplayer, writer.WriteByte, 0)
	writer:WriteString(openid, false, "openid", 0)
end

function ClientToGameGMDelegate:GMPSNSetting(ispsnplayer, openid)
	return self:Invoke(65372367, SerializerHelper.GMPSNSetting_Serializer, ispsnplayer, openid)
end

function SerializerHelper.GmInviteTeam_Serializer(writer, memberpid, doublecheck)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, doublecheck, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmInviteTeam(memberpid, doublecheck)
	return self:Invoke(65372780, SerializerHelper.GmInviteTeam_Serializer, memberpid, doublecheck)
end

function SerializerHelper.GmLinkShowInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmLinkShowInfo()
	return self:Invoke(65376578, SerializerHelper.GmLinkShowInfo_Serializer)
end

function SerializerHelper.GmQuerySkey_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmQuerySkey()
	return self:Invoke(65377086, SerializerHelper.GmQuerySkey_Serializer)
end

function SerializerHelper.GmEventConditionGetInfos_Serializer(writer, module)
	SerializeBase.WritePrimitive(writer, module, writer.WriteByte, 0)
end

function ClientToGameGMDelegate:GmEventConditionGetInfos(module)
	return self:Invoke(65377554, SerializerHelper.GmEventConditionGetInfos_Serializer, module)
end

function SerializerHelper.GmClearNpcTuite_Serializer(writer, tuiteid)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmClearNpcTuite(tuiteid)
	return self:Invoke(65379944, SerializerHelper.GmClearNpcTuite_Serializer, tuiteid)
end

function SerializerHelper.GmChangeNpcInteractPoint_Serializer(writer, diff)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmChangeNpcInteractPoint(diff)
	return self:Invoke(65380746, SerializerHelper.GmChangeNpcInteractPoint_Serializer, diff)
end

function SerializerHelper.GmKickMyself_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmKickMyself()
	return self:Invoke(65382432, SerializerHelper.GmKickMyself_Serializer)
end

function SerializerHelper.GmSetTime_Serializer(writer, hour, transition)
	SerializeBase.WritePrimitive(writer, hour, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, transition, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSetTime(hour, transition)
	return self:Invoke(65386400, SerializerHelper.GmSetTime_Serializer, hour, transition)
end

function SerializerHelper.GmGangBossUnlockAllGangMember_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmGangBossUnlockAllGangMember()
	return self:Invoke(65390781, SerializerHelper.GmGangBossUnlockAllGangMember_Serializer)
end

function SerializerHelper.GmChangeRoomSetting_Serializer(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteMatchRoomSetting, "setting", false)
end

function ClientToGameGMDelegate:GmChangeRoomSetting(setting)
	return self:Invoke(65391416, SerializerHelper.GmChangeRoomSetting_Serializer, setting)
end

function SerializerHelper.GmPartyLiveOver_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmPartyLiveOver()
	return self:Invoke(65391808, SerializerHelper.GmPartyLiveOver_Serializer)
end

function SerializerHelper.GmTestS17_Serializer(writer, id, flag)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, flag, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmTestS17(id, flag)
	return self:Invoke(65392701, SerializerHelper.GmTestS17_Serializer, id, flag)
end

function SerializerHelper.GmResetGachaGroupMilestone_Serializer(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmResetGachaGroupMilestone(groupid)
	return self:Invoke(65395476, SerializerHelper.GmResetGachaGroupMilestone_Serializer, groupid)
end

function SerializerHelper.GmReplyInvitePlayerInteractionAction_Serializer(writer, isaccept)
	SerializeBase.WritePrimitive(writer, isaccept, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmReplyInvitePlayerInteractionAction(isaccept)
	return self:Invoke(65399494, SerializerHelper.GmReplyInvitePlayerInteractionAction_Serializer, isaccept)
end

function SerializerHelper.GmUnlockTaskTitleGuide_Serializer(writer, title, unlock, finish)
	SerializeBase.WritePrimitive(writer, title, writer.WriteUInt16, 0)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, finish, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmUnlockTaskTitleGuide(title, unlock, finish)
	return self:Invoke(65404916, SerializerHelper.GmUnlockTaskTitleGuide_Serializer, title, unlock, finish)
end

function SerializerHelper.GmEventUnlock_Serializer(writer, eventid, unlock)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmEventUnlock(eventid, unlock)
	return self:Invoke(65406621, SerializerHelper.GmEventUnlock_Serializer, eventid, unlock)
end

function SerializerHelper.GmCreateTaskAiVehicle_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmCreateTaskAiVehicle(taskid)
	return self:Invoke(65407638, SerializerHelper.GmCreateTaskAiVehicle_Serializer, taskid)
end

function SerializerHelper.GmDisableMapEntranceType_Serializer(writer, mapentrancetypeid)
	SerializeBase.WritePrimitive(writer, mapentrancetypeid, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmDisableMapEntranceType(mapentrancetypeid)
	return self:Invoke(65413346, SerializerHelper.GmDisableMapEntranceType_Serializer, mapentrancetypeid)
end

function SerializerHelper.GmApplyFashionColoringSchemeInfos_Serializer(writer, applyfashioncoloringschemeiddict)
	SerializeBase.WriteDict(writer, applyfashioncoloringschemeiddict, writer.WriteUInt32, writer.WriteByte, 0, "applyfashioncoloringschemeiddict", false, 0)
end

function ClientToGameGMDelegate:GmApplyFashionColoringSchemeInfos(applyfashioncoloringschemeiddict)
	return self:Invoke(65414320, SerializerHelper.GmApplyFashionColoringSchemeInfos_Serializer, applyfashioncoloringschemeiddict)
end

function SerializerHelper.GmChangeBuildHouseIndoor_Serializer(writer, houseid, floor, changeplacedfurnitureinfo)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, changeplacedfurnitureinfo, SerializeAuto.WriteChangePlacedFurnitureInfo, "changeplacedfurnitureinfo")
end

function ClientToGameGMDelegate:GmChangeBuildHouseIndoor(houseid, floor, changeplacedfurnitureinfo)
	return self:Invoke(65420056, SerializerHelper.GmChangeBuildHouseIndoor_Serializer, houseid, floor, changeplacedfurnitureinfo)
end

function SerializerHelper.GmActiveSpiritJobTalentLayer_Serializer(writer, spiritid, jobclassid, talentid, addlayer)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, talentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addlayer, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmActiveSpiritJobTalentLayer(spiritid, jobclassid, talentid, addlayer)
	return self:Invoke(65429134, SerializerHelper.GmActiveSpiritJobTalentLayer_Serializer, spiritid, jobclassid, talentid, addlayer)
end

function SerializerHelper.GmFinishAllGuides_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmFinishAllGuides()
	return self:Invoke(65430106, SerializerHelper.GmFinishAllGuides_Serializer)
end

function SerializerHelper.GmUnlockRandomEvent_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmUnlockRandomEvent()
	return self:Invoke(65436798, SerializerHelper.GmUnlockRandomEvent_Serializer)
end

function SerializerHelper.GmSetFavorNpcTimeTable_Serializer(writer, a1, a2, a3, a4)
	SerializeBase.WritePrimitive(writer, a1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, a2, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, a3, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, a4, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSetFavorNpcTimeTable(a1, a2, a3, a4)
	return self:Invoke(65438884, SerializerHelper.GmSetFavorNpcTimeTable_Serializer, a1, a2, a3, a4)
end

function SerializerHelper.GmLeaveRoom_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmLeaveRoom()
	return self:Invoke(65439161, SerializerHelper.GmLeaveRoom_Serializer)
end

function SerializerHelper.GmClearDialogNpcChat_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmClearDialogNpcChat(chatid)
	return self:Invoke(65441589, SerializerHelper.GmClearDialogNpcChat_Serializer, chatid)
end

function SerializerHelper.GMScientistAddRecipe_Serializer(writer, productid)
	SerializeBase.WritePrimitive(writer, productid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMScientistAddRecipe(productid)
	return self:Invoke(65443742, SerializerHelper.GMScientistAddRecipe_Serializer, productid)
end

function SerializerHelper.GmUnlockAllQuest_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmUnlockAllQuest()
	return self:Invoke(65443953, SerializerHelper.GmUnlockAllQuest_Serializer)
end

function SerializerHelper.GmAddMilkNpcFavor_Serializer(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmAddMilkNpcFavor(value)
	return self:Invoke(65445215, SerializerHelper.GmAddMilkNpcFavor_Serializer, value)
end

function SerializerHelper.GmConfirmDutySwap_Serializer(writer, sourcepid, accept)
	SerializeBase.WritePrimitive(writer, sourcepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmConfirmDutySwap(sourcepid, accept)
	return self:Invoke(65446537, SerializerHelper.GmConfirmDutySwap_Serializer, sourcepid, accept)
end

function SerializerHelper.GmRefreshAllFavorNpcTimeTable_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmRefreshAllFavorNpcTimeTable()
	return self:Invoke(65449498, SerializerHelper.GmRefreshAllFavorNpcTimeTable_Serializer)
end

function SerializerHelper.GmClientDialogFinish_Serializer(writer, dialogid)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmClientDialogFinish(dialogid)
	return self:Invoke(65456979, SerializerHelper.GmClientDialogFinish_Serializer, dialogid)
end

function SerializerHelper.GmSetTaskCounterValue_Serializer(writer, taskid, index, current, value)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, current, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmSetTaskCounterValue(taskid, index, current, value)
	return self:Invoke(65461786, SerializerHelper.GmSetTaskCounterValue_Serializer, taskid, index, current, value)
end

function SerializerHelper.ShowAllServerDumpInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:ShowAllServerDumpInfo()
	return self:Invoke(65462176, SerializerHelper.ShowAllServerDumpInfo_Serializer)
end

function SerializerHelper.GmSetReputation_Serializer(writer, countryid, reputation)
	SerializeBase.WritePrimitive(writer, countryid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, reputation, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSetReputation(countryid, reputation)
	return self:Invoke(65463427, SerializerHelper.GmSetReputation_Serializer, countryid, reputation)
end

function SerializerHelper.GmScientistClearProducedItems_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmScientistClearProducedItems()
	return self:Invoke(65464517, SerializerHelper.GmScientistClearProducedItems_Serializer)
end

function SerializerHelper.GMEndWatchOtherPlayer_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GMEndWatchOtherPlayer()
	return self:Invoke(65467218, SerializerHelper.GMEndWatchOtherPlayer_Serializer)
end

function SerializerHelper.GmAddFurniture_Serializer(writer, furnitureid, count)
	SerializeBase.WritePrimitive(writer, furnitureid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddFurniture(furnitureid, count)
	return self:Invoke(65468265, SerializerHelper.GmAddFurniture_Serializer, furnitureid, count)
end

function SerializerHelper.GmGetFakeFileInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmGetFakeFileInfo()
	return self:Invoke(65469249, SerializerHelper.GmGetFakeFileInfo_Serializer)
end

function SerializerHelper.GmChangeIndoor_Serializer(writer, indoorid, enter)
	SerializeBase.WritePrimitive(writer, indoorid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmChangeIndoor(indoorid, enter)
	return self:Invoke(65478579, SerializerHelper.GmChangeIndoor_Serializer, indoorid, enter)
end

function SerializerHelper.GmLinkNew_Serializer(writer, mode, psnonly)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, psnonly, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmLinkNew(mode, psnonly)
	return self:Invoke(65485749, SerializerHelper.GmLinkNew_Serializer, mode, psnonly)
end

function SerializerHelper.GmObsoleteCurTruckJobOrder_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmObsoleteCurTruckJobOrder()
	return self:Invoke(65491052, SerializerHelper.GmObsoleteCurTruckJobOrder_Serializer)
end

function SerializerHelper.GmAddHealItems_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmAddHealItems()
	return self:Invoke(65494338, SerializerHelper.GmAddHealItems_Serializer)
end

function SerializerHelper.GmArchiveInvestigateGallery_Serializer(writer, galleryid)
	SerializeBase.WritePrimitive(writer, galleryid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmArchiveInvestigateGallery(galleryid)
	return self:Invoke(65495831, SerializerHelper.GmArchiveInvestigateGallery_Serializer, galleryid)
end

function SerializerHelper.GmRemoveHouse_Serializer(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmRemoveHouse(houseid)
	return self:Invoke(65497027, SerializerHelper.GmRemoveHouse_Serializer, houseid)
end

function SerializerHelper.GmStartInviteRideNpc_Serializer(writer, npcid)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmStartInviteRideNpc(npcid)
	return self:Invoke(65502467, SerializerHelper.GmStartInviteRideNpc_Serializer, npcid)
end

function SerializerHelper.GmUnlockNpcActionItem_Serializer(writer, actionitemid)
	SerializeBase.WritePrimitive(writer, actionitemid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmUnlockNpcActionItem(actionitemid)
	return self:Invoke(65503090, SerializerHelper.GmUnlockNpcActionItem_Serializer, actionitemid)
end

function SerializerHelper.GmReportBattleData_Serializer(writer, content, filename)
	SerializeBase.WriteList(writer, content, writer.WriteByte, 0, "content", false, 0, nil)
	writer:WriteString(filename, false, "filename", 0)
end

function ClientToGameGMDelegate:GmReportBattleData(content, filename)
	return self:Invoke(65506393, SerializerHelper.GmReportBattleData_Serializer, content, filename)
end

function SerializerHelper.GmDropReward_Serializer(writer, dropid, droptimes)
	SerializeBase.WritePrimitive(writer, dropid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, droptimes, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmDropReward(dropid, droptimes)
	return self:Invoke(65509860, SerializerHelper.GmDropReward_Serializer, dropid, droptimes)
end

function SerializerHelper.GmCreateAndAcceptTruckJobOrder_Serializer(writer, type, cargoid, npcid, pickupid, deliveryid, accepttime, submittime, cargoid2, pickupid2)
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

function ClientToGameGMDelegate:GmCreateAndAcceptTruckJobOrder(type, cargoid, npcid, pickupid, deliveryid, accepttime, submittime, cargoid2, pickupid2)
	return self:Invoke(65512931, SerializerHelper.GmCreateAndAcceptTruckJobOrder_Serializer, type, cargoid, npcid, pickupid, deliveryid, accepttime, submittime, cargoid2, pickupid2)
end

function SerializerHelper.GmStartGame_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmStartGame()
	return self:Invoke(65517463, SerializerHelper.GmStartGame_Serializer)
end

function SerializerHelper.GmActiveBadgeEffect_Serializer(writer, spiritid, badgeid, enable)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, badgeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmActiveBadgeEffect(spiritid, badgeid, enable)
	return self:Invoke(65523224, SerializerHelper.GmActiveBadgeEffect_Serializer, spiritid, badgeid, enable)
end

function SerializerHelper.GmDoResetAccept_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmDoResetAccept(taskid)
	return self:Invoke(65524579, SerializerHelper.GmDoResetAccept_Serializer, taskid)
end

function SerializerHelper.GmChangeSafeArea_Serializer(writer, areaid, enter)
	SerializeBase.WritePrimitive(writer, areaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmChangeSafeArea(areaid, enter)
	return self:Invoke(65525470, SerializerHelper.GmChangeSafeArea_Serializer, areaid, enter)
end

function SerializerHelper.GmFinishAchievementCategory_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmFinishAchievementCategory(id)
	return self:Invoke(65526020, SerializerHelper.GmFinishAchievementCategory_Serializer, id)
end

function SerializerHelper.GmAddCommonSpiritTalentExp_Serializer(writer, exp)
	SerializeBase.WritePrimitive(writer, exp, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddCommonSpiritTalentExp(exp)
	return self:Invoke(65526982, SerializerHelper.GmAddCommonSpiritTalentExp_Serializer, exp)
end

function SerializerHelper.GmDonateFactionByCfgId_Serializer(writer, factionid, donateid)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, donateid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmDonateFactionByCfgId(factionid, donateid)
	return self:Invoke(65530584, SerializerHelper.GmDonateFactionByCfgId_Serializer, factionid, donateid)
end

function SerializerHelper.GmFireworkUnLockPlan_Serializer(writer, fireworkplanconfigid)
	SerializeBase.WritePrimitive(writer, fireworkplanconfigid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmFireworkUnLockPlan(fireworkplanconfigid)
	return self:Invoke(65540926, SerializerHelper.GmFireworkUnLockPlan_Serializer, fireworkplanconfigid)
end

function SerializerHelper.GmSetWeather_Serializer(writer, weatherid)
	SerializeBase.WritePrimitive(writer, weatherid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSetWeather(weatherid)
	return self:Invoke(65545868, SerializerHelper.GmSetWeather_Serializer, weatherid)
end

function SerializerHelper.GmUnlockCountry_Serializer(writer, countryid)
	SerializeBase.WritePrimitive(writer, countryid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmUnlockCountry(countryid)
	return self:Invoke(65551008, SerializerHelper.GmUnlockCountry_Serializer, countryid)
end

function SerializerHelper.GmChangeName_Serializer(writer, name)
	writer:WriteString(name, false, "name", 32)
end

function ClientToGameGMDelegate:GmChangeName(name)
	return self:Invoke(65556139, SerializerHelper.GmChangeName_Serializer, name)
end

function SerializerHelper.GmDebugReserveGpuDumps_Serializer(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmDebugReserveGpuDumps(value)
	return self:Invoke(65558563, SerializerHelper.GmDebugReserveGpuDumps_Serializer, value)
end

function SerializerHelper.GmAddTaskCounterValue_Serializer(writer, taskid, index, current, value)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, current, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmAddTaskCounterValue(taskid, index, current, value)
	return self:Invoke(65559175, SerializerHelper.GmAddTaskCounterValue_Serializer, taskid, index, current, value)
end

function SerializerHelper.GmReadyToPlay_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmReadyToPlay()
	return self:Invoke(65560136, SerializerHelper.GmReadyToPlay_Serializer)
end

function SerializerHelper.GmLeaveScene_Serializer(writer, raidid)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmLeaveScene(raidid)
	return self:Invoke(65560419, SerializerHelper.GmLeaveScene_Serializer, raidid)
end

function SerializerHelper.GmEnableIndoorSectorIds_Serializer(writer, indoorsectorid)
	SerializeBase.WritePrimitive(writer, indoorsectorid, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmEnableIndoorSectorIds(indoorsectorid)
	return self:Invoke(65566155, SerializerHelper.GmEnableIndoorSectorIds_Serializer, indoorsectorid)
end

function SerializerHelper.GmClearPostInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearPostInfo()
	return self:Invoke(65566553, SerializerHelper.GmClearPostInfo_Serializer)
end

function SerializerHelper.GmUnsetSpiritAllFashions_Serializer(writer, spiritidlist)
	SerializeBase.WriteList(writer, spiritidlist, writer.WriteUInt32, 0, "spiritidlist", false, 0, nil)
end

function ClientToGameGMDelegate:GmUnsetSpiritAllFashions(spiritidlist)
	return self:Invoke(65570482, SerializerHelper.GmUnsetSpiritAllFashions_Serializer, spiritidlist)
end

function SerializerHelper.RemoveAllResults_Serializer(writer)
	return
end

function ClientToGameGMDelegate:RemoveAllResults()
	return self:Invoke(65571728, SerializerHelper.RemoveAllResults_Serializer)
end

function SerializerHelper.GmAcceptEvent_Serializer(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAcceptEvent(eventid)
	return self:Invoke(65575794, SerializerHelper.GmAcceptEvent_Serializer, eventid)
end

function SerializerHelper.GmPlanningBoardSetStepOption_Serializer(writer, stepid, optionindex)
	SerializeBase.WritePrimitive(writer, stepid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, optionindex, writer.WriteByte, 0)
end

function ClientToGameGMDelegate:GmPlanningBoardSetStepOption(stepid, optionindex)
	return self:Invoke(65576740, SerializerHelper.GmPlanningBoardSetStepOption_Serializer, stepid, optionindex)
end

function SerializerHelper.GmDivinerAIChat_Serializer(writer, agentcfgid, stage, demandcfgid, popularityindex, msg, choiceindex, lang)
	SerializeBase.WritePrimitive(writer, agentcfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stage, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, demandcfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, popularityindex, writer.WriteUInt32, 0)
	writer:WriteString(msg, false, "msg", 0)
	SerializeBase.WritePrimitive(writer, choiceindex, writer.WriteInt32, 0)
	writer:WriteString(lang, false, "lang", 0)
end

function ClientToGameGMDelegate:GmDivinerAIChat(agentcfgid, stage, demandcfgid, popularityindex, msg, choiceindex, lang)
	return self:Invoke(65581047, SerializerHelper.GmDivinerAIChat_Serializer, agentcfgid, stage, demandcfgid, popularityindex, msg, choiceindex, lang)
end

function SerializerHelper.GmSetEnableMaxMultiPlayerId_Serializer(writer, enablemaxmultiplayerid)
	SerializeBase.WritePrimitive(writer, enablemaxmultiplayerid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSetEnableMaxMultiPlayerId(enablemaxmultiplayerid)
	return self:Invoke(65591358, SerializerHelper.GmSetEnableMaxMultiPlayerId_Serializer, enablemaxmultiplayerid)
end

function SerializerHelper.GMMaxAllNpcFavor_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GMMaxAllNpcFavor()
	return self:Invoke(65592073, SerializerHelper.GMMaxAllNpcFavor_Serializer)
end

function SerializerHelper.GMTakeItemProduced_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GMTakeItemProduced()
	return self:Invoke(65593995, SerializerHelper.GMTakeItemProduced_Serializer)
end

function SerializerHelper.GmAddFactionDisposition_Serializer(writer, factionid, addvalue)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmAddFactionDisposition(factionid, addvalue)
	return self:Invoke(65595170, SerializerHelper.GmAddFactionDisposition_Serializer, factionid, addvalue)
end

function SerializerHelper.GmAddFashionSuits_Serializer(writer, fashionsuitidlist, duration)
	SerializeBase.WriteList(writer, fashionsuitidlist, writer.WriteUInt32, 0, "fashionsuitidlist", false, 0, nil)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddFashionSuits(fashionsuitidlist, duration)
	return self:Invoke(65595444, SerializerHelper.GmAddFashionSuits_Serializer, fashionsuitidlist, duration)
end

function SerializerHelper.GMStartWatchOtherPlayer_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GMStartWatchOtherPlayer()
	return self:Invoke(65596071, SerializerHelper.GMStartWatchOtherPlayer_Serializer)
end

function SerializerHelper.GmCreateAiOnVehicle_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmCreateAiOnVehicle(taskid)
	return self:Invoke(65596200, SerializerHelper.GmCreateAiOnVehicle_Serializer, taskid)
end

function SerializerHelper.IamRobot_Serializer(writer)
	return
end

function ClientToGameGMDelegate:IamRobot()
	return self:Invoke(65597881, SerializerHelper.IamRobot_Serializer)
end

function SerializerHelper.GmAbilitySetLevel_Serializer(writer, spiritid, abilityid, level)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, abilityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAbilitySetLevel(spiritid, abilityid, level)
	return self:Invoke(65598618, SerializerHelper.GmAbilitySetLevel_Serializer, spiritid, abilityid, level)
end

function SerializerHelper.GmItemExchange_Serializer(writer, exchangeid, count)
	SerializeBase.WritePrimitive(writer, exchangeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmItemExchange(exchangeid, count)
	return self:Invoke(65599345, SerializerHelper.GmItemExchange_Serializer, exchangeid, count)
end

function SerializerHelper.GMScientistRemoveRecipe_Serializer(writer, productid)
	SerializeBase.WritePrimitive(writer, productid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMScientistRemoveRecipe(productid)
	return self:Invoke(65603390, SerializerHelper.GMScientistRemoveRecipe_Serializer, productid)
end

function SerializerHelper.GmPhoneUnlockContactOption_Serializer(writer, contactid, contactoptionid)
	SerializeBase.WritePrimitive(writer, contactid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, contactoptionid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmPhoneUnlockContactOption(contactid, contactoptionid)
	return self:Invoke(65605236, SerializerHelper.GmPhoneUnlockContactOption_Serializer, contactid, contactoptionid)
end

function SerializerHelper.GmKickTeamMember_Serializer(writer, memberpid)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GmKickTeamMember(memberpid)
	return self:Invoke(65615099, SerializerHelper.GmKickTeamMember_Serializer, memberpid)
end

function SerializerHelper.GmBreakdownItem_Serializer(writer, breakdownid, itemid, count)
	SerializeBase.WritePrimitive(writer, breakdownid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmBreakdownItem(breakdownid, itemid, count)
	return self:Invoke(65617522, SerializerHelper.GmBreakdownItem_Serializer, breakdownid, itemid, count)
end

function SerializerHelper.GmAddPopularity_Serializer(writer, drop, count, interval)
	SerializeBase.WritePrimitive(writer, drop, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interval, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddPopularity(drop, count, interval)
	return self:Invoke(65618312, SerializerHelper.GmAddPopularity_Serializer, drop, count, interval)
end

function SerializerHelper.GmScientistAddALLRecipe_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmScientistAddALLRecipe()
	return self:Invoke(65619866, SerializerHelper.GmScientistAddALLRecipe_Serializer)
end

function SerializerHelper.GmFinishTaskCounter_Serializer(writer, taskid, index, current)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, current, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmFinishTaskCounter(taskid, index, current)
	return self:Invoke(65625400, SerializerHelper.GmFinishTaskCounter_Serializer, taskid, index, current)
end

function SerializerHelper.GmLeaveGame_Serializer(writer, punish)
	SerializeBase.WritePrimitive(writer, punish, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmLeaveGame(punish)
	return self:Invoke(65625612, SerializerHelper.GmLeaveGame_Serializer, punish)
end

function SerializerHelper.ForceChangeTaskState_Serializer(writer, taskid, info)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	writer:WriteString(info, false, "info", 0)
end

function ClientToGameGMDelegate:ForceChangeTaskState(taskid, info)
	return self:Invoke(65632163, SerializerHelper.ForceChangeTaskState_Serializer, taskid, info)
end

function SerializerHelper.GmUnlockFogMap_Serializer(writer, sceneid, unlock)
	SerializeBase.WritePrimitive(writer, sceneid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmUnlockFogMap(sceneid, unlock)
	return self:Invoke(65632292, SerializerHelper.GmUnlockFogMap_Serializer, sceneid, unlock)
end

function SerializerHelper.GmReplyToFriendRoomInvite_Serializer(writer, roomid, friendpid, accept)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmReplyToFriendRoomInvite(roomid, friendpid, accept)
	return self:Invoke(65635766, SerializerHelper.GmReplyToFriendRoomInvite_Serializer, roomid, friendpid, accept)
end

function SerializerHelper.GmPartyGetPartyInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmPartyGetPartyInfo()
	return self:Invoke(65638681, SerializerHelper.GmPartyGetPartyInfo_Serializer)
end

function SerializerHelper.GmGetLuaString_Serializer(writer, filename)
	writer:WriteString(filename, false, "filename", 0)
end

function ClientToGameGMDelegate:GmGetLuaString(filename)
	return self:Invoke(65639345, SerializerHelper.GmGetLuaString_Serializer, filename)
end

function SerializerHelper.GmDrawGacha_Serializer(writer, gachaid, level)
	SerializeBase.WritePrimitive(writer, gachaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmDrawGacha(gachaid, level)
	return self:Invoke(65640597, SerializerHelper.GmDrawGacha_Serializer, gachaid, level)
end

function SerializerHelper.GmChoosePartyNPC_Serializer(writer, npcs)
	SerializeBase.WriteList(writer, npcs, writer.WriteUInt32, 0, "npcs", false, 0, nil)
end

function ClientToGameGMDelegate:GmChoosePartyNPC(npcs)
	return self:Invoke(65644685, SerializerHelper.GmChoosePartyNPC_Serializer, npcs)
end

function SerializerHelper.GMJoinLinkByPid_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GMJoinLinkByPid(pid)
	return self:Invoke(65645298, SerializerHelper.GMJoinLinkByPid_Serializer, pid)
end

function SerializerHelper.GmClearSignRecord_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearSignRecord()
	return self:Invoke(65646756, SerializerHelper.GmClearSignRecord_Serializer)
end

function SerializerHelper.GmDonateFactionByMoney_Serializer(writer, factionid, money)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, money, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmDonateFactionByMoney(factionid, money)
	return self:Invoke(65647387, SerializerHelper.GmDonateFactionByMoney_Serializer, factionid, money)
end

function SerializerHelper.GmJobQuit_Serializer(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmJobQuit(jobclassid)
	return self:Invoke(65649571, SerializerHelper.GmJobQuit_Serializer, jobclassid)
end

function SerializerHelper.GmGetPlayerFashionsInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmGetPlayerFashionsInfo()
	return self:Invoke(65651064, SerializerHelper.GmGetPlayerFashionsInfo_Serializer)
end

function SerializerHelper.GmBartendingByDrinkMenu_Serializer(writer, bartenderid, drinkmenuid)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, drinkmenuid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmBartendingByDrinkMenu(bartenderid, drinkmenuid)
	return self:Invoke(65652742, SerializerHelper.GmBartendingByDrinkMenu_Serializer, bartenderid, drinkmenuid)
end

function SerializerHelper.GmStartRoomMatch_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmStartRoomMatch()
	return self:Invoke(65653801, SerializerHelper.GmStartRoomMatch_Serializer)
end

function SerializerHelper.GMUnlockFightStyle_Serializer(writer, fightstyletypeid)
	SerializeBase.WritePrimitive(writer, fightstyletypeid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMUnlockFightStyle(fightstyletypeid)
	return self:Invoke(65663728, SerializerHelper.GMUnlockFightStyle_Serializer, fightstyletypeid)
end

function SerializerHelper.GmAddFakeFileClueValue_Serializer(writer, agentidlist)
	SerializeBase.WriteList(writer, agentidlist, writer.WriteUInt32, 0, "agentidlist", false, 32, nil)
end

function ClientToGameGMDelegate:GmAddFakeFileClueValue(agentidlist)
	return self:Invoke(65671040, SerializerHelper.GmAddFakeFileClueValue_Serializer, agentidlist)
end

function SerializerHelper.GMClearPSNBlackList_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GMClearPSNBlackList()
	return self:Invoke(65677007, SerializerHelper.GMClearPSNBlackList_Serializer)
end

function SerializerHelper.GMActivateNpcCard_Serializer(writer, npccardid)
	SerializeBase.WritePrimitive(writer, npccardid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMActivateNpcCard(npccardid)
	return self:Invoke(65677459, SerializerHelper.GMActivateNpcCard_Serializer, npccardid)
end

function SerializerHelper.GmResetGachaPoolHistory_Serializer(writer, prizepoolid)
	SerializeBase.WritePrimitive(writer, prizepoolid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmResetGachaPoolHistory(prizepoolid)
	return self:Invoke(65685417, SerializerHelper.GmResetGachaPoolHistory_Serializer, prizepoolid)
end

function SerializerHelper.GmCancelPlayerInteractionAction_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmCancelPlayerInteractionAction()
	return self:Invoke(65685566, SerializerHelper.GmCancelPlayerInteractionAction_Serializer)
end

function SerializerHelper.GmAddAllPeiYangItems_Serializer(writer, count)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddAllPeiYangItems(count)
	return self:Invoke(65688020, SerializerHelper.GmAddAllPeiYangItems_Serializer, count)
end

function SerializerHelper.GmMallBuyBundle_Serializer(writer, bundleid, buycnt, autoexchange)
	SerializeBase.WritePrimitive(writer, bundleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buycnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, autoexchange, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmMallBuyBundle(bundleid, buycnt, autoexchange)
	return self:Invoke(65690734, SerializerHelper.GmMallBuyBundle_Serializer, bundleid, buycnt, autoexchange)
end

function SerializerHelper.GmHouseVisit_Serializer(writer, ownerpid, houseid)
	SerializeBase.WritePrimitive(writer, ownerpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmHouseVisit(ownerpid, houseid)
	return self:Invoke(65690763, SerializerHelper.GmHouseVisit_Serializer, ownerpid, houseid)
end

function SerializerHelper.SendPlayerMailBatch_Serializer(writer, mailcfgid, pid, count)
	SerializeBase.WritePrimitive(writer, mailcfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:SendPlayerMailBatch(mailcfgid, pid, count)
	return self:Invoke(65693006, SerializerHelper.SendPlayerMailBatch_Serializer, mailcfgid, pid, count)
end

function SerializerHelper.GmRemoveFurniture_Serializer(writer, furnitureid)
	SerializeBase.WritePrimitive(writer, furnitureid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmRemoveFurniture(furnitureid)
	return self:Invoke(65702352, SerializerHelper.GmRemoveFurniture_Serializer, furnitureid)
end

function SerializerHelper.GMTriggerNpcQueueEvent_Serializer(writer, id, ismanual)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ismanual, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GMTriggerNpcQueueEvent(id, ismanual)
	return self:Invoke(65702733, SerializerHelper.GMTriggerNpcQueueEvent_Serializer, id, ismanual)
end

function SerializerHelper.GmGangBossLockGangMember_Serializer(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmGangBossLockGangMember(templateid)
	return self:Invoke(65703979, SerializerHelper.GmGangBossLockGangMember_Serializer, templateid)
end

function SerializerHelper.GmAskJoinLinkOnTeamInvite_Serializer(writer, inviterpid, targetlinkid, targetmode)
	SerializeBase.WritePrimitive(writer, inviterpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetlinkid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetmode, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GmAskJoinLinkOnTeamInvite(inviterpid, targetlinkid, targetmode)
	return self:Invoke(65705232, SerializerHelper.GmAskJoinLinkOnTeamInvite_Serializer, inviterpid, targetlinkid, targetmode)
end

function SerializerHelper.GmClearCharacterDialogRecord_Serializer(writer, characterdialogid)
	SerializeBase.WritePrimitive(writer, characterdialogid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmClearCharacterDialogRecord(characterdialogid)
	return self:Invoke(65705980, SerializerHelper.GmClearCharacterDialogRecord_Serializer, characterdialogid)
end

function SerializerHelper.GmUnlockAllFogMap_Serializer(writer, unlock)
	SerializeBase.WritePrimitive(writer, unlock, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmUnlockAllFogMap(unlock)
	return self:Invoke(65706033, SerializerHelper.GmUnlockAllFogMap_Serializer, unlock)
end

function SerializerHelper.GmLinkSwitchMode_Serializer(writer, mode)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
end

function ClientToGameGMDelegate:GmLinkSwitchMode(mode)
	return self:Invoke(65707845, SerializerHelper.GmLinkSwitchMode_Serializer, mode)
end

function SerializerHelper.CloseSocket_Serializer(writer, reason)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:CloseSocket(reason)
	return self:Invoke(65708448, SerializerHelper.CloseSocket_Serializer, reason)
end

function SerializerHelper.GmAddAllSpirits_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmAddAllSpirits()
	return self:Invoke(65712268, SerializerHelper.GmAddAllSpirits_Serializer)
end

function SerializerHelper.GmAcceptTask_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAcceptTask(taskid)
	return self:Invoke(65712806, SerializerHelper.GmAcceptTask_Serializer, taskid)
end

function SerializerHelper.GMAskPlayWithAnimal_Serializer(writer, animalid, favor, dailylimit)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, favor, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, dailylimit, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GMAskPlayWithAnimal(animalid, favor, dailylimit)
	return self:Invoke(65722093, SerializerHelper.GMAskPlayWithAnimal_Serializer, animalid, favor, dailylimit)
end

function SerializerHelper.GmApplyDutySwap_Serializer(writer, sourceduty, targetpid, targetduty)
	SerializeBase.WritePrimitive(writer, sourceduty, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetduty, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmApplyDutySwap(sourceduty, targetpid, targetduty)
	return self:Invoke(65726969, SerializerHelper.GmApplyDutySwap_Serializer, sourceduty, targetpid, targetduty)
end

function SerializerHelper.GmSendCustomDataToTest_Serializer(writer, data)
	SerializeBase.WriteList(writer, data, writer.WriteByte, 0, "data", false, 0, nil)
end

function ClientToGameGMDelegate:GmSendCustomDataToTest(data)
	return self:Invoke(65730933, SerializerHelper.GmSendCustomDataToTest_Serializer, data)
end

function SerializerHelper.GmPartyAddLikeAndGift_Serializer(writer, like, gift)
	SerializeBase.WritePrimitive(writer, like, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, gift, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmPartyAddLikeAndGift(like, gift)
	return self:Invoke(65732120, SerializerHelper.GmPartyAddLikeAndGift_Serializer, like, gift)
end

function SerializerHelper.GmScientistClearProduceHistory_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmScientistClearProduceHistory()
	return self:Invoke(65736272, SerializerHelper.GmScientistClearProduceHistory_Serializer)
end

function SerializerHelper.GmClearGuideTeach_Serializer(writer, guideteachid)
	SerializeBase.WritePrimitive(writer, guideteachid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmClearGuideTeach(guideteachid)
	return self:Invoke(65737938, SerializerHelper.GmClearGuideTeach_Serializer, guideteachid)
end

function SerializerHelper.GMSetDeviceLevel_Serializer(writer, level)
	SerializeBase.WritePrimitive(writer, level, writer.WriteByte, 0)
end

function ClientToGameGMDelegate:GMSetDeviceLevel(level)
	return self:Invoke(65741697, SerializerHelper.GMSetDeviceLevel_Serializer, level)
end

function SerializerHelper.GmGetPlayerDumpInfo_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GmGetPlayerDumpInfo(pid)
	return self:Invoke(65746119, SerializerHelper.GmGetPlayerDumpInfo_Serializer, pid)
end

function SerializerHelper.GmDoctorCure_Serializer(writer, agentid, treatmentid, successfulqtecount)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, treatmentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, successfulqtecount, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmDoctorCure(agentid, treatmentid, successfulqtecount)
	return self:Invoke(65747705, SerializerHelper.GmDoctorCure_Serializer, agentid, treatmentid, successfulqtecount)
end

function SerializerHelper.GmInvitePlayerInteractionAction_Serializer(writer, inviteepid, actionitemid)
	SerializeBase.WritePrimitive(writer, inviteepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionitemid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmInvitePlayerInteractionAction(inviteepid, actionitemid)
	return self:Invoke(65747804, SerializerHelper.GmInvitePlayerInteractionAction_Serializer, inviteepid, actionitemid)
end

function SerializerHelper.GmUnlockComputerFile_Serializer(writer, fileid)
	SerializeBase.WritePrimitive(writer, fileid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmUnlockComputerFile(fileid)
	return self:Invoke(65747911, SerializerHelper.GmUnlockComputerFile_Serializer, fileid)
end

function SerializerHelper.GmPolicePickNextMission_Serializer(writer, policemissionid, randomid)
	SerializeBase.WritePrimitive(writer, policemissionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, randomid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmPolicePickNextMission(policemissionid, randomid)
	return self:Invoke(65755222, SerializerHelper.GmPolicePickNextMission_Serializer, policemissionid, randomid)
end

function SerializerHelper.GmFollowTeamLeader_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmFollowTeamLeader()
	return self:Invoke(65755917, SerializerHelper.GmFollowTeamLeader_Serializer)
end

function SerializerHelper.GmSetRoomMemberDuty_Serializer(writer, duty)
	SerializeBase.WritePrimitive(writer, duty, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSetRoomMemberDuty(duty)
	return self:Invoke(65762448, SerializerHelper.GmSetRoomMemberDuty_Serializer, duty)
end

function SerializerHelper.GmEnableClientSpiritFashionTryWear_Serializer(writer, spiritid, enable)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmEnableClientSpiritFashionTryWear(spiritid, enable)
	return self:Invoke(65764617, SerializerHelper.GmEnableClientSpiritFashionTryWear_Serializer, spiritid, enable)
end

function SerializerHelper.GmAddPopularityFromConfig_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmAddPopularityFromConfig()
	return self:Invoke(65766648, SerializerHelper.GmAddPopularityFromConfig_Serializer)
end

function SerializerHelper.GmClearPhoneAppDownloadHistory_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearPhoneAppDownloadHistory()
	return self:Invoke(65772361, SerializerHelper.GmClearPhoneAppDownloadHistory_Serializer)
end

function SerializerHelper.GmAddAllPokemon_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmAddAllPokemon()
	return self:Invoke(65772419, SerializerHelper.GmAddAllPokemon_Serializer)
end

function SerializerHelper.GmUnlockFogMapPoi_Serializer(writer, poiid)
	SerializeBase.WritePrimitive(writer, poiid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmUnlockFogMapPoi(poiid)
	return self:Invoke(65777431, SerializerHelper.GmUnlockFogMapPoi_Serializer, poiid)
end

function SerializerHelper.GmJobStart_Serializer(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmJobStart(jobclassid)
	return self:Invoke(65780358, SerializerHelper.GmJobStart_Serializer, jobclassid)
end

function SerializerHelper.GMAddExp_Serializer(writer, exptoadd)
	SerializeBase.WritePrimitive(writer, exptoadd, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMAddExp(exptoadd)
	return self:Invoke(65783579, SerializerHelper.GMAddExp_Serializer, exptoadd)
end

function SerializerHelper.GmBreakdownItems_Serializer(writer, breakdownids, iteminstanceids, counts)
	SerializeBase.WriteList(writer, breakdownids, writer.WriteUInt32, 0, "breakdownids", false, 0, nil)
	SerializeBase.WriteList(writer, iteminstanceids, writer.WriteUInt64, 0, "iteminstanceids", false, 0, nil)
	SerializeBase.WriteList(writer, counts, writer.WriteUInt32, 0, "counts", false, 0, nil)
end

function ClientToGameGMDelegate:GmBreakdownItems(breakdownids, iteminstanceids, counts)
	return self:Invoke(65783857, SerializerHelper.GmBreakdownItems_Serializer, breakdownids, iteminstanceids, counts)
end

function SerializerHelper.GmUnLockQuest_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmUnLockQuest(id)
	return self:Invoke(65785691, SerializerHelper.GmUnLockQuest_Serializer, id)
end

function SerializerHelper.ClearBag_Serializer(writer)
	return
end

function ClientToGameGMDelegate:ClearBag()
	return self:Invoke(65790231, SerializerHelper.ClearBag_Serializer)
end

function SerializerHelper.GmAcceptTaskAndSubmitPre_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAcceptTaskAndSubmitPre(taskid)
	return self:Invoke(65790327, SerializerHelper.GmAcceptTaskAndSubmitPre_Serializer, taskid)
end

function SerializerHelper.GmInviteNpcChat_Serializer(writer, gameplay)
	SerializeBase.WritePrimitive(writer, gameplay, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmInviteNpcChat(gameplay)
	return self:Invoke(65792251, SerializerHelper.GmInviteNpcChat_Serializer, gameplay)
end

function SerializerHelper.GmLinkInfo_Serializer(writer, mode)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
end

function ClientToGameGMDelegate:GmLinkInfo(mode)
	return self:Invoke(65792663, SerializerHelper.GmLinkInfo_Serializer, mode)
end

function SerializerHelper.GmFillPlayerData_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmFillPlayerData()
	return self:Invoke(65796351, SerializerHelper.GmFillPlayerData_Serializer)
end

function SerializerHelper.GMSpawnNpcForAttractPoint_Serializer(writer, attractpointid)
	SerializeBase.WritePrimitive(writer, attractpointid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMSpawnNpcForAttractPoint(attractpointid)
	return self:Invoke(65797055, SerializerHelper.GMSpawnNpcForAttractPoint_Serializer, attractpointid)
end

function SerializerHelper.GmPlanningBoardClearStepOptions_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmPlanningBoardClearStepOptions()
	return self:Invoke(65797641, SerializerHelper.GmPlanningBoardClearStepOptions_Serializer)
end

function SerializerHelper.GmResetSpiritJobTalent_Serializer(writer, spiritid, jobclassid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmResetSpiritJobTalent(spiritid, jobclassid)
	return self:Invoke(65804103, SerializerHelper.GmResetSpiritJobTalent_Serializer, spiritid, jobclassid)
end

function SerializerHelper.GmDoctorDeathStart_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmDoctorDeathStart()
	return self:Invoke(65806104, SerializerHelper.GmDoctorDeathStart_Serializer)
end

function SerializerHelper.GmCBT_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmCBT()
	return self:Invoke(65809134, SerializerHelper.GmCBT_Serializer)
end

function SerializerHelper.IgnoreRpcRushProtect_Serializer(writer)
	return
end

function ClientToGameGMDelegate:IgnoreRpcRushProtect()
	return self:Invoke(65810363, SerializerHelper.IgnoreRpcRushProtect_Serializer)
end

function SerializerHelper.GmProduceItem_Serializer(writer, produceid, count, bias)
	SerializeBase.WritePrimitive(writer, produceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, bias, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmProduceItem(produceid, count, bias)
	return self:Invoke(65810955, SerializerHelper.GmProduceItem_Serializer, produceid, count, bias)
end

function SerializerHelper.GMAddPSNBlackList_Serializer(writer, pids)
	SerializeBase.WriteList(writer, pids, writer.WriteUInt64, 0, "pids", false, 0, nil)
end

function ClientToGameGMDelegate:GMAddPSNBlackList(pids)
	return self:Invoke(65811014, SerializerHelper.GMAddPSNBlackList_Serializer, pids)
end

function SerializerHelper.GmMallSetCommoditySpiritDisplayPreferences_Serializer(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmMallSetCommoditySpiritDisplayPreferences(spiritid)
	return self:Invoke(65811793, SerializerHelper.GmMallSetCommoditySpiritDisplayPreferences_Serializer, spiritid)
end

function SerializerHelper.GmPartyGetSettleData_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmPartyGetSettleData()
	return self:Invoke(65816242, SerializerHelper.GmPartyGetSettleData_Serializer)
end

function SerializerHelper.GmLinkAddSyncRate_Serializer(writer, otherpid, addvalue)
	SerializeBase.WritePrimitive(writer, otherpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteSingle, 0)
end

function ClientToGameGMDelegate:GmLinkAddSyncRate(otherpid, addvalue)
	return self:Invoke(65817734, SerializerHelper.GmLinkAddSyncRate_Serializer, otherpid, addvalue)
end

function SerializerHelper.AddSpirit_Serializer(writer, spirittemplateid, domain)
	SerializeBase.WritePrimitive(writer, spirittemplateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, domain, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:AddSpirit(spirittemplateid, domain)
	return self:Invoke(65822116, SerializerHelper.AddSpirit_Serializer, spirittemplateid, domain)
end

function SerializerHelper.GmMallBuyCommodity_Serializer(writer, commodityid, buycnt, autoexchange, ignorecheckandconsume)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buycnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, autoexchange, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorecheckandconsume, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmMallBuyCommodity(commodityid, buycnt, autoexchange, ignorecheckandconsume)
	return self:Invoke(65827989, SerializerHelper.GmMallBuyCommodity_Serializer, commodityid, buycnt, autoexchange, ignorecheckandconsume)
end

function SerializerHelper.GmGetAllWorkActionNodes_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmGetAllWorkActionNodes(taskid)
	return self:Invoke(65833574, SerializerHelper.GmGetAllWorkActionNodes_Serializer, taskid)
end

function SerializerHelper.GmUnlockPost_Serializer(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmUnlockPost(postid)
	return self:Invoke(65833774, SerializerHelper.GmUnlockPost_Serializer, postid)
end

function SerializerHelper.GmGetTruckJobOrders_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmGetTruckJobOrders()
	return self:Invoke(65837587, SerializerHelper.GmGetTruckJobOrders_Serializer)
end

function SerializerHelper.GmClearDialog_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearDialog()
	return self:Invoke(65840979, SerializerHelper.GmClearDialog_Serializer)
end

function SerializerHelper.GmLinkLeave_Serializer(writer, mode)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
end

function ClientToGameGMDelegate:GmLinkLeave(mode)
	return self:Invoke(65847449, SerializerHelper.GmLinkLeave_Serializer, mode)
end

function SerializerHelper.GmSubmitTask_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSubmitTask(taskid)
	return self:Invoke(65848277, SerializerHelper.GmSubmitTask_Serializer, taskid)
end

function SerializerHelper.GmConvertCommonSpiritTalentExp_Serializer(writer, spiritid, convertexp)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, convertexp, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmConvertCommonSpiritTalentExp(spiritid, convertexp)
	return self:Invoke(65850298, SerializerHelper.GmConvertCommonSpiritTalentExp_Serializer, spiritid, convertexp)
end

function SerializerHelper.GmClearMilkNpcFavor_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearMilkNpcFavor()
	return self:Invoke(65853040, SerializerHelper.GmClearMilkNpcFavor_Serializer)
end

function SerializerHelper.GmAddPokemon_Serializer(writer, limbochaid)
	SerializeBase.WritePrimitive(writer, limbochaid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddPokemon(limbochaid)
	return self:Invoke(65853628, SerializerHelper.GmAddPokemon_Serializer, limbochaid)
end

function SerializerHelper.GmStartMahjongWithNpc_Serializer(writer, gametype, seatindex)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmStartMahjongWithNpc(gametype, seatindex)
	return self:Invoke(65856188, SerializerHelper.GmStartMahjongWithNpc_Serializer, gametype, seatindex)
end

function SerializerHelper.GmWasherRandomPickMission_Serializer(writer, index, missionid)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, missionid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmWasherRandomPickMission(index, missionid)
	return self:Invoke(65858808, SerializerHelper.GmWasherRandomPickMission_Serializer, index, missionid)
end

function SerializerHelper.GmAddHouse_Serializer(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAddHouse(houseid)
	return self:Invoke(65860125, SerializerHelper.GmAddHouse_Serializer, houseid)
end

function SerializerHelper.GmAllTaskReset_Serializer(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmAllTaskReset(eventid)
	return self:Invoke(65863697, SerializerHelper.GmAllTaskReset_Serializer, eventid)
end

function SerializerHelper.GmLinkInfos_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmLinkInfos()
	return self:Invoke(65867865, SerializerHelper.GmLinkInfos_Serializer)
end

function SerializerHelper.GmAddBuildHouseIndoor_Serializer(writer, houseid, floor, addplacedfurnitureinfo)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, addplacedfurnitureinfo, SerializeAuto.WriteAddPlacedFurnitureInfo, "addplacedfurnitureinfo")
end

function ClientToGameGMDelegate:GmAddBuildHouseIndoor(houseid, floor, addplacedfurnitureinfo)
	return self:Invoke(65869155, SerializerHelper.GmAddBuildHouseIndoor_Serializer, houseid, floor, addplacedfurnitureinfo)
end

function SerializerHelper.GmClearPopularity_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmClearPopularity()
	return self:Invoke(65873771, SerializerHelper.GmClearPopularity_Serializer)
end

function SerializerHelper.GmSetTruckOrderLimitTime_Serializer(writer, uniqueid, limitseconds)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, limitseconds, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmSetTruckOrderLimitTime(uniqueid, limitseconds)
	return self:Invoke(65875339, SerializerHelper.GmSetTruckOrderLimitTime_Serializer, uniqueid, limitseconds)
end

function SerializerHelper.GMInteractNpcWithGift_Serializer(writer, activityid, giftid, count)
	SerializeBase.WritePrimitive(writer, activityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, giftid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GMInteractNpcWithGift(activityid, giftid, count)
	return self:Invoke(65878525, SerializerHelper.GMInteractNpcWithGift_Serializer, activityid, giftid, count)
end

function SerializerHelper.GmSetFactionInfluence_Serializer(writer, factionid, setvalue)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, setvalue, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GmSetFactionInfluence(factionid, setvalue)
	return self:Invoke(65884297, SerializerHelper.GmSetFactionInfluence_Serializer, factionid, setvalue)
end

function SerializerHelper.GmScientistRemoveAllRecipe_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmScientistRemoveAllRecipe()
	return self:Invoke(65890668, SerializerHelper.GmScientistRemoveAllRecipe_Serializer)
end

function SerializerHelper.GMResetPersonalZoneInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GMResetPersonalZoneInfo()
	return self:Invoke(65892033, SerializerHelper.GMResetPersonalZoneInfo_Serializer)
end

function SerializerHelper.GmGetTaskAllNodesName_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmGetTaskAllNodesName(taskid)
	return self:Invoke(65896033, SerializerHelper.GmGetTaskAllNodesName_Serializer, taskid)
end

function SerializerHelper.GmStartPlayerInteractionAction_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmStartPlayerInteractionAction()
	return self:Invoke(65900194, SerializerHelper.GmStartPlayerInteractionAction_Serializer)
end

function SerializerHelper.GMSetBestNpcs_Serializer(writer, setbestnpcinfolist)
	SerializeBase.WriteList(writer, setbestnpcinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteBestNpcInfo, "BestNpcInfo", false), nil, "setbestnpcinfolist", false, 32, nil)
end

function ClientToGameGMDelegate:GMSetBestNpcs(setbestnpcinfolist)
	return self:Invoke(65901855, SerializerHelper.GMSetBestNpcs_Serializer, setbestnpcinfolist)
end

function SerializerHelper.GmAddAllVehicles_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmAddAllVehicles()
	return self:Invoke(65902388, SerializerHelper.GmAddAllVehicles_Serializer)
end

function SerializerHelper.GmNewRoom_Serializer(writer, gameid, autoinvite)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, autoinvite, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmNewRoom(gameid, autoinvite)
	return self:Invoke(65903509, SerializerHelper.GmNewRoom_Serializer, gameid, autoinvite)
end

function SerializerHelper.GmGetHousesInfo_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmGetHousesInfo()
	return self:Invoke(65905195, SerializerHelper.GmGetHousesInfo_Serializer)
end

function SerializerHelper.GmLinkKick_Serializer(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GmLinkKick(friendpid)
	return self:Invoke(65906111, SerializerHelper.GmLinkKick_Serializer, friendpid)
end

function SerializerHelper.GmNewPrivateLink_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmNewPrivateLink()
	return self:Invoke(65914389, SerializerHelper.GmNewPrivateLink_Serializer)
end

function SerializerHelper.GmPassingTime_Serializer(writer, hour, minute)
	SerializeBase.WritePrimitive(writer, hour, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, minute, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmPassingTime(hour, minute)
	return self:Invoke(65918200, SerializerHelper.GmPassingTime_Serializer, hour, minute)
end

function SerializerHelper.GmUnlockComputerEmail_Serializer(writer, emailid)
	SerializeBase.WritePrimitive(writer, emailid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmUnlockComputerEmail(emailid)
	return self:Invoke(65922398, SerializerHelper.GmUnlockComputerEmail_Serializer, emailid)
end

function SerializerHelper.GmUnlockAllNpcVoice_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmUnlockAllNpcVoice()
	return self:Invoke(65923760, SerializerHelper.GmUnlockAllNpcVoice_Serializer)
end

function SerializerHelper.GmInviteFriendToRoom_Serializer(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GmInviteFriendToRoom(friendpid)
	return self:Invoke(65928161, SerializerHelper.GmInviteFriendToRoom_Serializer, friendpid)
end

function SerializerHelper.GmRaiseSurrender_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmRaiseSurrender()
	return self:Invoke(65934456, SerializerHelper.GmRaiseSurrender_Serializer)
end

function SerializerHelper.GmPublishAllTriggerTuite_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmPublishAllTriggerTuite()
	return self:Invoke(65934676, SerializerHelper.GmPublishAllTriggerTuite_Serializer)
end

function SerializerHelper.GmForceFollowPlayer_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GmForceFollowPlayer(pid)
	return self:Invoke(65935574, SerializerHelper.GmForceFollowPlayer_Serializer, pid)
end

function SerializerHelper.GmStartSingleMatch_Serializer(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmStartSingleMatch(gameid)
	return self:Invoke(65939542, SerializerHelper.GmStartSingleMatch_Serializer, gameid)
end

function SerializerHelper.GmCompleteUrbanPlay_Serializer(writer, playresult)
	SerializeBase.WriteComplex(writer, playresult, SerializeAuto.WriteUrbanGamePlayResult, "playresult", false)
end

function ClientToGameGMDelegate:GmCompleteUrbanPlay(playresult)
	return self:Invoke(65944304, SerializerHelper.GmCompleteUrbanPlay_Serializer, playresult)
end

function SerializerHelper.GmPartyLiveAddEvent_Serializer(writer, eventid, message)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteInt32, 0)
	writer:WriteString(message, true, "message", 0)
end

function ClientToGameGMDelegate:GmPartyLiveAddEvent(eventid, message)
	return self:Invoke(65947231, SerializerHelper.GmPartyLiveAddEvent_Serializer, eventid, message)
end

function SerializerHelper.GmLeaveTeam_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmLeaveTeam()
	return self:Invoke(65949719, SerializerHelper.GmLeaveTeam_Serializer)
end

function SerializerHelper.AddMatchTeamRoom_Serializer(writer, playercount, device, gameid, startmatch)
	SerializeBase.WritePrimitive(writer, playercount, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, device, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, startmatch, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:AddMatchTeamRoom(playercount, device, gameid, startmatch)
	return self:Invoke(65950100, SerializerHelper.AddMatchTeamRoom_Serializer, playercount, device, gameid, startmatch)
end

function SerializerHelper.GmFastZengFu_Serializer(writer, needspecific)
	SerializeBase.WritePrimitive(writer, needspecific, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmFastZengFu(needspecific)
	return self:Invoke(65952203, SerializerHelper.GmFastZengFu_Serializer, needspecific)
end

function SerializerHelper.GmTestPveLowMiddleHigh_Serializer(writer, level)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

function ClientToGameGMDelegate:GmTestPveLowMiddleHigh(level)
	return self:Invoke(65954775, SerializerHelper.GmTestPveLowMiddleHigh_Serializer, level)
end

function SerializerHelper.GmSetSpiritWearFashionHiddenParts_Serializer(writer, spiritid, hiddenparts)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hiddenparts, writer.WriteByte, 0)
end

function ClientToGameGMDelegate:GmSetSpiritWearFashionHiddenParts(spiritid, hiddenparts)
	return self:Invoke(65955298, SerializerHelper.GmSetSpiritWearFashionHiddenParts_Serializer, spiritid, hiddenparts)
end

function SerializerHelper.GmSetFashionColoringSchemeInfos_Serializer(writer, fashioncoloringschemeinfolist)
	SerializeBase.WriteList(writer, fashioncoloringschemeinfolist, SerializeBase.WriteStructWrap(SerializeAuto.WriteFashionColoringSchemeInfo, "fashioncoloringschemeinfolist"), nil, "fashioncoloringschemeinfolist", false, 0, nil)
end

function ClientToGameGMDelegate:GmSetFashionColoringSchemeInfos(fashioncoloringschemeinfolist)
	return self:Invoke(65963401, SerializerHelper.GmSetFashionColoringSchemeInfos_Serializer, fashioncoloringschemeinfolist)
end

function SerializerHelper.GmSkipTruckDailyOrder_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmSkipTruckDailyOrder()
	return self:Invoke(65964139, SerializerHelper.GmSkipTruckDailyOrder_Serializer)
end

function SerializerHelper.GMChangeNpcProfileTrustValue_Serializer(writer, profileid, diff)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, diff, writer.WriteInt32, 0)
end

function ClientToGameGMDelegate:GMChangeNpcProfileTrustValue(profileid, diff)
	return self:Invoke(65967090, SerializerHelper.GMChangeNpcProfileTrustValue_Serializer, profileid, diff)
end

function SerializerHelper.GMSyncWorldBattlePlayers_Serializer(writer, gadgetid, gameid, enter)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GMSyncWorldBattlePlayers(gadgetid, gameid, enter)
	return self:Invoke(65968747, SerializerHelper.GMSyncWorldBattlePlayers_Serializer, gadgetid, gameid, enter)
end

function SerializerHelper.GmSetSpiritFashionSuits_Serializer(writer, spiritidlist, fashionsuitidlist)
	SerializeBase.WriteList(writer, spiritidlist, writer.WriteUInt32, 0, "spiritidlist", false, 0, nil)
	SerializeBase.WriteList(writer, fashionsuitidlist, writer.WriteUInt32, 0, "fashionsuitidlist", false, 0, nil)
end

function ClientToGameGMDelegate:GmSetSpiritFashionSuits(spiritidlist, fashionsuitidlist)
	return self:Invoke(65970812, SerializerHelper.GmSetSpiritFashionSuits_Serializer, spiritidlist, fashionsuitidlist)
end

function SerializerHelper.GmReturnOriginalMode_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmReturnOriginalMode()
	return self:Invoke(65971803, SerializerHelper.GmReturnOriginalMode_Serializer)
end

function SerializerHelper.GmAskCreateTeam_Serializer(writer)
	return
end

function ClientToGameGMDelegate:GmAskCreateTeam()
	return self:Invoke(65973190, SerializerHelper.GmAskCreateTeam_Serializer)
end

function SerializerHelper.GmResetFashionColoringSchemeInfos_Serializer(writer, resetfashioncoloringschemeinfolist)
	SerializeBase.WriteList(writer, resetfashioncoloringschemeinfolist, SerializeBase.WriteStructWrap(SerializeAuto.WriteResetFashionColoringSchemeInfo, "resetfashioncoloringschemeinfolist"), nil, "resetfashioncoloringschemeinfolist", false, 0, nil)
end

function ClientToGameGMDelegate:GmResetFashionColoringSchemeInfos(resetfashioncoloringschemeinfolist)
	return self:Invoke(65982302, SerializerHelper.GmResetFashionColoringSchemeInfos_Serializer, resetfashioncoloringschemeinfolist)
end

function SerializerHelper.GmPullMemberToTeam_Serializer(writer, memberpid)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

function ClientToGameGMDelegate:GmPullMemberToTeam(memberpid)
	return self:Invoke(65984636, SerializerHelper.GmPullMemberToTeam_Serializer, memberpid)
end

function SerializerHelper.GmOccupyFactionInfluenceArea_Serializer(writer, areaid, occupy)
	SerializeBase.WritePrimitive(writer, areaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, occupy, writer.WriteBoolean, false)
end

function ClientToGameGMDelegate:GmOccupyFactionInfluenceArea(areaid, occupy)
	return self:Invoke(65997229, SerializerHelper.GmOccupyFactionInfluenceArea_Serializer, areaid, occupy)
end

return ClientToGameGMDelegate
