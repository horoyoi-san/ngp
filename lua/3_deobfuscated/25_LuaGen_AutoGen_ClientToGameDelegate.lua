local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGameDelegate = invoker:New()

function ClientToGameDelegate.Sender()
	return NetworkManager.LuaGameRpcProcessor
end

function SerializerHelper.AskDeleteMails_Serializer(writer, ids)
	SerializeBase.WriteList(writer, ids, writer.WriteUInt64, 0, "ids", false, 1024, nil)
end

function ClientToGameDelegate:AskDeleteMails(ids)
	return self:Invoke(63001519, SerializerHelper.AskDeleteMails_Serializer, ids)
end

function SerializerHelper.AskResetFashionColoringSchemeInfos_Serializer(writer, resetfashioncoloringschemeinfolist)
	SerializeBase.WriteList(writer, resetfashioncoloringschemeinfolist, SerializeBase.WriteStructWrap(SerializeAuto.WriteResetFashionColoringSchemeInfo, "resetfashioncoloringschemeinfolist"), nil, "resetfashioncoloringschemeinfolist", false, 32, nil)
end

function ClientToGameDelegate:AskResetFashionColoringSchemeInfos(resetfashioncoloringschemeinfolist)
	return self:Invoke(63003069, SerializerHelper.AskResetFashionColoringSchemeInfos_Serializer, resetfashioncoloringschemeinfolist)
end

function SerializerHelper.AskPhoneAddContactGroup_Serializer(writer, spiritid, groupname)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer:WriteString(groupname, false, "groupname", 32)
end

function ClientToGameDelegate:AskPhoneAddContactGroup(spiritid, groupname)
	return self:Invoke(63003116, SerializerHelper.AskPhoneAddContactGroup_Serializer, spiritid, groupname)
end

function SerializerHelper.AskLoadWeaponToSlot_Serializer(writer, spiritid, weaponid, slotindex)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, slotindex, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskLoadWeaponToSlot(spiritid, weaponid, slotindex)
	return self:Invoke(63006163, SerializerHelper.AskLoadWeaponToSlot_Serializer, spiritid, weaponid, slotindex)
end

function SerializerHelper.AskBuyVehicleFromMass_Serializer(writer, vehicleid, sendchat)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sendchat, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskBuyVehicleFromMass(vehicleid, sendchat)
	return self:Invoke(63011891, SerializerHelper.AskBuyVehicleFromMass_Serializer, vehicleid, sendchat)
end

function SerializerHelper.AskWebviewToken_Serializer(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteWebviewLoginTokenInfo, "info", false)
end

function ClientToGameDelegate:AskWebviewToken(info)
	return self:Invoke(63012422, SerializerHelper.AskWebviewToken_Serializer, info)
end

function SerializerHelper.AskSetSpiritCustomSuitSchemeInfo_Serializer(writer, spiritid, schemeindex, customsuitschemeinfo)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, schemeindex, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, customsuitschemeinfo, SerializeAuto.WriteFashionCustomSuitSchemeInfo, "customsuitschemeinfo", false)
end

function ClientToGameDelegate:AskSetSpiritCustomSuitSchemeInfo(spiritid, schemeindex, customsuitschemeinfo)
	return self:Invoke(63014629, SerializerHelper.AskSetSpiritCustomSuitSchemeInfo_Serializer, spiritid, schemeindex, customsuitschemeinfo)
end

function SerializerHelper.AskInvitePlayerInteractionAction_Serializer(writer, inviteepid, actionitemid)
	SerializeBase.WritePrimitive(writer, inviteepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionitemid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskInvitePlayerInteractionAction(inviteepid, actionitemid)
	return self:Invoke(63020013, SerializerHelper.AskInvitePlayerInteractionAction_Serializer, inviteepid, actionitemid)
end

function SerializerHelper.AskItemCountRecord_Serializer(writer, itemid)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskItemCountRecord(itemid)
	return self:Invoke(63021930, SerializerHelper.AskItemCountRecord_Serializer, itemid)
end

function SerializerHelper.AskGetArrestTimes_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetArrestTimes()
	return self:Invoke(63024757, SerializerHelper.AskGetArrestTimes_Serializer)
end

function SerializerHelper.RequestGameSceneData_Serializer(writer)
	return
end

function ClientToGameDelegate:RequestGameSceneData()
	self:Notify(63026079, SerializerHelper.RequestGameSceneData_Serializer)
end

function SerializerHelper.AskFactionInfo_Serializer(writer, factionid)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskFactionInfo(factionid)
	return self:Invoke(63026208, SerializerHelper.AskFactionInfo_Serializer, factionid)
end

function SerializerHelper.AskVehicleShopSpawnVehicle_Serializer(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskVehicleShopSpawnVehicle(vehicleid)
	return self:Invoke(63026985, SerializerHelper.AskVehicleShopSpawnVehicle_Serializer, vehicleid)
end

function SerializerHelper.AskSwitchFightStyle_Serializer(writer, spiritid, fightstyletypeid, fightstyleid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fightstyletypeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fightstyleid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSwitchFightStyle(spiritid, fightstyletypeid, fightstyleid)
	return self:Invoke(63028844, SerializerHelper.AskSwitchFightStyle_Serializer, spiritid, fightstyletypeid, fightstyleid)
end

function SerializerHelper.AskBegBehavior_Serializer(writer, poseid, spot, behaviortype)
	SerializeBase.WritePrimitive(writer, poseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spot, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, behaviortype, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskBegBehavior(poseid, spot, behaviortype)
	return self:Invoke(63029825, SerializerHelper.AskBegBehavior_Serializer, poseid, spot, behaviortype)
end

function SerializerHelper.AskFireworkBuyTicket_Serializer(writer, buyinfo)
	SerializeBase.WriteComplex(writer, buyinfo, SerializeAuto.WriteFireworkBuyInfo, "buyinfo", false)
end

function ClientToGameDelegate:AskFireworkBuyTicket(buyinfo)
	return self:Invoke(63040583, SerializerHelper.AskFireworkBuyTicket_Serializer, buyinfo)
end

function SerializerHelper.AskMiniGame_BeeSettlement_Serializer(writer)
	return
end

function ClientToGameDelegate:AskMiniGame_BeeSettlement()
	self:Notify(63042784, SerializerHelper.AskMiniGame_BeeSettlement_Serializer)
end

function SerializerHelper.AskPurchaseElement_Serializer(writer, bartenderid, elementid, purchasecount)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, purchasecount, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskPurchaseElement(bartenderid, elementid, purchasecount)
	return self:Invoke(63043900, SerializerHelper.AskPurchaseElement_Serializer, bartenderid, elementid, purchasecount)
end

function SerializerHelper.AskFinishMilkTopic_Serializer(writer, topicid)
	SerializeBase.WritePrimitive(writer, topicid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskFinishMilkTopic(topicid)
	self:Notify(63045599, SerializerHelper.AskFinishMilkTopic_Serializer, topicid)
end

function SerializerHelper.AskClaimGachaMilestone_Serializer(writer, gachaid, milestonecount)
	SerializeBase.WritePrimitive(writer, gachaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, milestonecount, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskClaimGachaMilestone(gachaid, milestonecount)
	return self:Invoke(63046025, SerializerHelper.AskClaimGachaMilestone_Serializer, gachaid, milestonecount)
end

function SerializerHelper.AskRecommendGetTopWearFashionTagId_Serializer(writer)
	return
end

function ClientToGameDelegate:AskRecommendGetTopWearFashionTagId()
	return self:Invoke(63046424, SerializerHelper.AskRecommendGetTopWearFashionTagId_Serializer)
end

function SerializerHelper.AskCancelInviteePlayerInteractionAction_Serializer(writer)
	return
end

function ClientToGameDelegate:AskCancelInviteePlayerInteractionAction()
	return self:Invoke(63047594, SerializerHelper.AskCancelInviteePlayerInteractionAction_Serializer)
end

function SerializerHelper.AskStartBarDice_Serializer(writer, diceid)
	SerializeBase.WritePrimitive(writer, diceid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskStartBarDice(diceid)
	return self:Invoke(63050331, SerializerHelper.AskStartBarDice_Serializer, diceid)
end

function SerializerHelper.AskTwitterPanelOpen_Serializer(writer, panelid, key, value)
	SerializeBase.WritePrimitive(writer, panelid, writer.WriteInt32, 0)
	writer:WriteString(key, false, "key", 32)
	SerializeBase.WritePrimitive(writer, value, writer.WriteDouble, 0)
end

function ClientToGameDelegate:AskTwitterPanelOpen(panelid, key, value)
	self:Notify(63050689, SerializerHelper.AskTwitterPanelOpen_Serializer, panelid, key, value)
end

function SerializerHelper.AskNpcInteractionActionFinish_Serializer(writer, npcitemid, npcactionid)
	SerializeBase.WritePrimitive(writer, npcitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcactionid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskNpcInteractionActionFinish(npcitemid, npcactionid)
	return self:Invoke(63050860, SerializerHelper.AskNpcInteractionActionFinish_Serializer, npcitemid, npcactionid)
end

function SerializerHelper.AskReportSinglePose_Serializer(writer, actionid, type)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskReportSinglePose(actionid, type)
	self:Notify(63050865, SerializerHelper.AskReportSinglePose_Serializer, actionid, type)
end

function SerializerHelper.AskStartMahjongGame_Serializer(writer, type, npcidls, seatindex, addfavor)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WriteList(writer, npcidls, writer.WriteUInt32, 0, "npcidls", false, 32, nil)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, addfavor, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskStartMahjongGame(type, npcidls, seatindex, addfavor)
	return self:Invoke(63053101, SerializerHelper.AskStartMahjongGame_Serializer, type, npcidls, seatindex, addfavor)
end

function SerializerHelper.ChatWithNpc_Serializer(writer, npcinstanceid)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:ChatWithNpc(npcinstanceid)
	return self:Invoke(63053258, SerializerHelper.ChatWithNpc_Serializer, npcinstanceid)
end

function SerializerHelper.AskSubmitTask_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSubmitTask(taskid)
	return self:Invoke(63055507, SerializerHelper.AskSubmitTask_Serializer, taskid)
end

function SerializerHelper.AskChallengeRecord_Serializer(writer, challengeid)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskChallengeRecord(challengeid)
	return self:Invoke(63055746, SerializerHelper.AskChallengeRecord_Serializer, challengeid)
end

function SerializerHelper.FollowTeamLeader_Serializer(writer)
	return
end

function ClientToGameDelegate:FollowTeamLeader()
	return self:Invoke(63056068, SerializerHelper.FollowTeamLeader_Serializer)
end

function SerializerHelper.AskPoliceDispatch_Serializer(writer, dispatchid, extrainfo)
	SerializeBase.WritePrimitive(writer, dispatchid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, extrainfo, SerializeAuto.WritePoliceDispatchExtraInfo, "extrainfo", true)
end

function ClientToGameDelegate:AskPoliceDispatch(dispatchid, extrainfo)
	return self:Invoke(63062011, SerializerHelper.AskPoliceDispatch_Serializer, dispatchid, extrainfo)
end

function SerializerHelper.AskStartDivinerGameWithDemand_Serializer(writer, agententityid, demandcfgid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, demandcfgid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskStartDivinerGameWithDemand(agententityid, demandcfgid)
	return self:Invoke(63068075, SerializerHelper.AskStartDivinerGameWithDemand_Serializer, agententityid, demandcfgid)
end

function SerializerHelper.AskGetNpcGroupPhotos_Serializer(writer, publisher, includesamenpc)
	SerializeBase.WritePrimitive(writer, publisher, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, includesamenpc, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskGetNpcGroupPhotos(publisher, includesamenpc)
	return self:Invoke(63068948, SerializerHelper.AskGetNpcGroupPhotos_Serializer, publisher, includesamenpc)
end

function SerializerHelper.TryInteractStory_Serializer(writer, npccultivationid, storyid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, storyid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:TryInteractStory(npccultivationid, storyid)
	self:Notify(63071583, SerializerHelper.TryInteractStory_Serializer, npccultivationid, storyid)
end

function SerializerHelper.AskDivinerFinishPersuade_Serializer(writer, agententityid, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer:WriteString(lang, false, "lang", 32)
end

function ClientToGameDelegate:AskDivinerFinishPersuade(agententityid, lang)
	return self:Invoke(63074816, SerializerHelper.AskDivinerFinishPersuade_Serializer, agententityid, lang)
end

function SerializerHelper.AskPlayerAchievements_Serializer(writer)
	return
end

function ClientToGameDelegate:AskPlayerAchievements()
	return self:Invoke(63079235, SerializerHelper.AskPlayerAchievements_Serializer)
end

function SerializerHelper.AskDeleteTaskGroup_Serializer(writer, taskid, fail)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fail, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskDeleteTaskGroup(taskid, fail)
	return self:Invoke(63079570, SerializerHelper.AskDeleteTaskGroup_Serializer, taskid, fail)
end

function SerializerHelper.AskTakeNpcProfileProgressReward_Serializer(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTakeNpcProfileProgressReward(index)
	return self:Invoke(63083488, SerializerHelper.AskTakeNpcProfileProgressReward_Serializer, index)
end

function SerializerHelper.AskSwitchLinkMode_Serializer(writer, mode, autonew)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, autonew, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskSwitchLinkMode(mode, autonew)
	return self:Invoke(63089336, SerializerHelper.AskSwitchLinkMode_Serializer, mode, autonew)
end

function SerializerHelper.AskSetPokemonLockState_Serializer(writer, id, state)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskSetPokemonLockState(id, state)
	return self:Invoke(63090513, SerializerHelper.AskSetPokemonLockState_Serializer, id, state)
end

function SerializerHelper.AskTakeCompetitionSeasonAllRankRewards_Serializer(writer)
	return
end

function ClientToGameDelegate:AskTakeCompetitionSeasonAllRankRewards()
	return self:Invoke(63091013, SerializerHelper.AskTakeCompetitionSeasonAllRankRewards_Serializer)
end

function SerializerHelper.SendCustomHotPatchClientToGame_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToGameDelegate:SendCustomHotPatchClientToGame(data)
	return self:Invoke(63094262, SerializerHelper.SendCustomHotPatchClientToGame_Serializer, data)
end

function SerializerHelper.AskMallBuyCommodity_Serializer(writer, commodityid, buycnt, isautoexchange)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buycnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isautoexchange, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskMallBuyCommodity(commodityid, buycnt, isautoexchange)
	return self:Invoke(63095016, SerializerHelper.AskMallBuyCommodity_Serializer, commodityid, buycnt, isautoexchange)
end

function SerializerHelper.AskLeaveRoom_Serializer(writer)
	return
end

function ClientToGameDelegate:AskLeaveRoom()
	return self:Invoke(63096167, SerializerHelper.AskLeaveRoom_Serializer)
end

function SerializerHelper.AskMomentsUnreadMessage_Serializer(writer)
	return
end

function ClientToGameDelegate:AskMomentsUnreadMessage()
	return self:Invoke(63099387, SerializerHelper.AskMomentsUnreadMessage_Serializer)
end

function SerializerHelper.AskPassingTime_Serializer(writer, hour, minute)
	SerializeBase.WritePrimitive(writer, hour, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, minute, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskPassingTime(hour, minute)
	return self:Invoke(63099919, SerializerHelper.AskPassingTime_Serializer, hour, minute)
end

function SerializerHelper.AskDecompositePokemon_Serializer(writer, id)
	SerializeBase.WriteList(writer, id, writer.WriteUInt64, 0, "id", false, 256, nil)
end

function ClientToGameDelegate:AskDecompositePokemon(id)
	return self:Invoke(63100829, SerializerHelper.AskDecompositePokemon_Serializer, id)
end

function SerializerHelper.AskChangeMapPin_Serializer(writer, pin, type)
	SerializeBase.WritePrimitive(writer, pin, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskChangeMapPin(pin, type)
	return self:Invoke(63112345, SerializerHelper.AskChangeMapPin_Serializer, pin, type)
end

function SerializerHelper.AskUploadPlayerConfig_Serializer(writer, config)
	SerializeBase.WriteList(writer, config, writer.WriteByte, 0, "config", false, 1024, nil)
end

function ClientToGameDelegate:AskUploadPlayerConfig(config)
	self:Notify(63113629, SerializerHelper.AskUploadPlayerConfig_Serializer, config)
end

function SerializerHelper.AskClaimChallengeTaskReward_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskClaimChallengeTaskReward(taskid)
	return self:Invoke(63113674, SerializerHelper.AskClaimChallengeTaskReward_Serializer, taskid)
end

function SerializerHelper.AskReadFashions_Serializer(writer, fashionidlist)
	SerializeBase.WriteList(writer, fashionidlist, writer.WriteUInt32, 0, "fashionidlist", false, 32, nil)
end

function ClientToGameDelegate:AskReadFashions(fashionidlist)
	return self:Invoke(63118547, SerializerHelper.AskReadFashions_Serializer, fashionidlist)
end

function SerializerHelper.OnStoneDance_Serializer(writer, isphasetwo)
	SerializeBase.WritePrimitive(writer, isphasetwo, writer.WriteBoolean, false)
end

function ClientToGameDelegate:OnStoneDance(isphasetwo)
	self:Notify(63123396, SerializerHelper.OnStoneDance_Serializer, isphasetwo)
end

function SerializerHelper.AskReportEnvSdkBlockedLog_Serializer(writer, description)
	writer:WriteString(description, false, "description", 1024)
end

function ClientToGameDelegate:AskReportEnvSdkBlockedLog(description)
	return self:Invoke(63126780, SerializerHelper.AskReportEnvSdkBlockedLog_Serializer, description)
end

function SerializerHelper.RemoveCurrentTask_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:RemoveCurrentTask(taskid)
	return self:Invoke(63128266, SerializerHelper.RemoveCurrentTask_Serializer, taskid)
end

function SerializerHelper.AskTakeNpcProfileMaxTrustReward_Serializer(writer, profileid)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTakeNpcProfileMaxTrustReward(profileid)
	return self:Invoke(63129881, SerializerHelper.AskTakeNpcProfileMaxTrustReward_Serializer, profileid)
end

function SerializerHelper.AskHouseCancelParking_Serializer(writer, vehicleidlist)
	SerializeBase.WriteList(writer, vehicleidlist, writer.WriteUInt32, 0, "vehicleidlist", false, 256, nil)
end

function ClientToGameDelegate:AskHouseCancelParking(vehicleidlist)
	return self:Invoke(63134598, SerializerHelper.AskHouseCancelParking_Serializer, vehicleidlist)
end

function SerializerHelper.AskPlayWithAnimal_Serializer(writer, animalid, favor)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, favor, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskPlayWithAnimal(animalid, favor)
	return self:Invoke(63135334, SerializerHelper.AskPlayWithAnimal_Serializer, animalid, favor)
end

function SerializerHelper.AskDivinerChooseBranch_Serializer(writer, agententityid, branchid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, branchid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskDivinerChooseBranch(agententityid, branchid)
	return self:Invoke(63137808, SerializerHelper.AskDivinerChooseBranch_Serializer, agententityid, branchid)
end

function SerializerHelper.AskEnterDivinerGame_Serializer(writer)
	return
end

function ClientToGameDelegate:AskEnterDivinerGame()
	return self:Invoke(63144730, SerializerHelper.AskEnterDivinerGame_Serializer)
end

function SerializerHelper.AskBuyMiniGameTicket_Serializer(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskBuyMiniGameTicket(gameid)
	return self:Invoke(63145374, SerializerHelper.AskBuyMiniGameTicket_Serializer, gameid)
end

function SerializerHelper.SetNewChallengeStartTime_Serializer(writer, challengeid, starttime)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, starttime, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:SetNewChallengeStartTime(challengeid, starttime)
	return self:Invoke(63145726, SerializerHelper.SetNewChallengeStartTime_Serializer, challengeid, starttime)
end

function SerializerHelper.AskUploadConfig_Serializer(writer, config)
	SerializeBase.WriteList(writer, config, writer.WriteByte, 0, "config", false, 1024, nil)
end

function ClientToGameDelegate:AskUploadConfig(config)
	self:Notify(63145908, SerializerHelper.AskUploadConfig_Serializer, config)
end

function SerializerHelper.AskStealNPCFan_Serializer(writer)
	return
end

function ClientToGameDelegate:AskStealNPCFan()
	return self:Invoke(63151450, SerializerHelper.AskStealNPCFan_Serializer)
end

function SerializerHelper.AskQueryTeamInfo_Serializer(writer, teamid)
	SerializeBase.WritePrimitive(writer, teamid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskQueryTeamInfo(teamid)
	return self:Invoke(63153332, SerializerHelper.AskQueryTeamInfo_Serializer, teamid)
end

function SerializerHelper.AskIsArrested_Serializer(writer)
	return
end

function ClientToGameDelegate:AskIsArrested()
	return self:Invoke(63154129, SerializerHelper.AskIsArrested_Serializer)
end

function SerializerHelper.AskSetPersonalTeamSetting_Serializer(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WritePersonalTeamSetting, "setting", false)
end

function ClientToGameDelegate:AskSetPersonalTeamSetting(setting)
	return self:Invoke(63155318, SerializerHelper.AskSetPersonalTeamSetting_Serializer, setting)
end

function SerializerHelper.AskForceFinishDialog_Serializer(writer)
	return
end

function ClientToGameDelegate:AskForceFinishDialog()
	return self:Invoke(63157099, SerializerHelper.AskForceFinishDialog_Serializer)
end

function SerializerHelper.TryUnlockNpcVoice_Serializer(writer, npccultivationid, voiceid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, voiceid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:TryUnlockNpcVoice(npccultivationid, voiceid)
	return self:Invoke(63158291, SerializerHelper.TryUnlockNpcVoice_Serializer, npccultivationid, voiceid)
end

function SerializerHelper.AskGetRaidWildEnemyInfo_Serializer(writer, raidid)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskGetRaidWildEnemyInfo(raidid)
	return self:Invoke(63159815, SerializerHelper.AskGetRaidWildEnemyInfo_Serializer, raidid)
end

function SerializerHelper.AskNewRoom_Serializer(writer, gameid, autoinvite)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, autoinvite, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskNewRoom(gameid, autoinvite)
	return self:Invoke(63162423, SerializerHelper.AskNewRoom_Serializer, gameid, autoinvite)
end

function SerializerHelper.AskGiveToBeggar_Serializer(writer, beggarpid, choice)
	SerializeBase.WritePrimitive(writer, beggarpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, choice, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskGiveToBeggar(beggarpid, choice)
	return self:Invoke(63164692, SerializerHelper.AskGiveToBeggar_Serializer, beggarpid, choice)
end

function SerializerHelper.AskAddBuildHouseIndoor_Serializer(writer, houseid, floor, addplacedfurnitureinfo)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, addplacedfurnitureinfo, SerializeAuto.WriteAddPlacedFurnitureInfo, "addplacedfurnitureinfo")
end

function ClientToGameDelegate:AskAddBuildHouseIndoor(houseid, floor, addplacedfurnitureinfo)
	return self:Invoke(63166164, SerializerHelper.AskAddBuildHouseIndoor_Serializer, houseid, floor, addplacedfurnitureinfo)
end

function SerializerHelper.AskFinishGuide_Serializer(writer, guideid, success)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskFinishGuide(guideid, success)
	return self:Invoke(63166613, SerializerHelper.AskFinishGuide_Serializer, guideid, success)
end

function SerializerHelper.ChoosePartyNPC_Serializer(writer, npcs)
	SerializeBase.WriteList(writer, npcs, writer.WriteUInt32, 0, "npcs", false, 256, nil)
end

function ClientToGameDelegate:ChoosePartyNPC(npcs)
	return self:Invoke(63166628, SerializerHelper.ChoosePartyNPC_Serializer, npcs)
end

function SerializerHelper.AskInteractNpcWithGift_Serializer(writer, activitycfgid, itemid, count)
	SerializeBase.WritePrimitive(writer, activitycfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskInteractNpcWithGift(activitycfgid, itemid, count)
	return self:Invoke(63167276, SerializerHelper.AskInteractNpcWithGift_Serializer, activitycfgid, itemid, count)
end

function SerializerHelper.AskInviteFriendToLink_Serializer(writer, type, friendid, doublecheck)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, friendid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, doublecheck, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskInviteFriendToLink(type, friendid, doublecheck)
	return self:Invoke(63167914, SerializerHelper.AskInviteFriendToLink_Serializer, type, friendid, doublecheck)
end

function SerializerHelper.AskPlayGameAgain_Serializer(writer)
	return
end

function ClientToGameDelegate:AskPlayGameAgain()
	return self:Invoke(63170733, SerializerHelper.AskPlayGameAgain_Serializer)
end

function SerializerHelper.AskReportDoublePose_Serializer(writer, actionid, type, npcinstanceid)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskReportDoublePose(actionid, type, npcinstanceid)
	self:Notify(63172552, SerializerHelper.AskReportDoublePose_Serializer, actionid, type, npcinstanceid)
end

function SerializerHelper.AskCreateTeam_Serializer(writer)
	return
end

function ClientToGameDelegate:AskCreateTeam()
	return self:Invoke(63174315, SerializerHelper.AskCreateTeam_Serializer)
end

function SerializerHelper.AskBuyCommodities_Serializer(writer, commodityiddict)
	SerializeBase.WriteDict(writer, commodityiddict, writer.WriteUInt32, writer.WriteUInt32, 0, "commodityiddict", false, 32)
end

function ClientToGameDelegate:AskBuyCommodities(commodityiddict)
	return self:Invoke(63178280, SerializerHelper.AskBuyCommodities_Serializer, commodityiddict)
end

function SerializerHelper.LiveHouseMusicStart_Serializer(writer, livehousemusicid, npcid, difficulty)
	SerializeBase.WritePrimitive(writer, livehousemusicid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, difficulty, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:LiveHouseMusicStart(livehousemusicid, npcid, difficulty)
	self:Notify(63179222, SerializerHelper.LiveHouseMusicStart_Serializer, livehousemusicid, npcid, difficulty)
end

function SerializerHelper.AskTwitterPanelClose_Serializer(writer, panelid, key, value)
	SerializeBase.WritePrimitive(writer, panelid, writer.WriteInt32, 0)
	writer:WriteString(key, false, "key", 32)
	SerializeBase.WritePrimitive(writer, value, writer.WriteDouble, 0)
end

function ClientToGameDelegate:AskTwitterPanelClose(panelid, key, value)
	self:Notify(63180839, SerializerHelper.AskTwitterPanelClose_Serializer, panelid, key, value)
end

function SerializerHelper.AskLeaveRaid_Serializer(writer, raidinstanceid)
	SerializeBase.WritePrimitive(writer, raidinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskLeaveRaid(raidinstanceid)
	self:Notify(63184730, SerializerHelper.AskLeaveRaid_Serializer, raidinstanceid)
end

function SerializerHelper.AskExchangeWeaponSlot_Serializer(writer, fromspirit, fromindex, tospirit, toindex)
	SerializeBase.WritePrimitive(writer, fromspirit, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, tospirit, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, toindex, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskExchangeWeaponSlot(fromspirit, fromindex, tospirit, toindex)
	return self:Invoke(63185930, SerializerHelper.AskExchangeWeaponSlot_Serializer, fromspirit, fromindex, tospirit, toindex)
end

function SerializerHelper.AskCancelInteractionActionRedPoint_Serializer(writer, npcitemid)
	SerializeBase.WritePrimitive(writer, npcitemid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskCancelInteractionActionRedPoint(npcitemid)
	return self:Invoke(63187022, SerializerHelper.AskCancelInteractionActionRedPoint_Serializer, npcitemid)
end

function SerializerHelper.AskSetTraceTarget_Serializer(writer, raidid, spoonid, targetid, name)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spoonid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	writer:WriteString(name, false, "name", 256)
end

function ClientToGameDelegate:AskSetTraceTarget(raidid, spoonid, targetid, name)
	self:Notify(63188650, SerializerHelper.AskSetTraceTarget_Serializer, raidid, spoonid, targetid, name)
end

function SerializerHelper.AskStartJob_Serializer(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskStartJob(jobclassid)
	return self:Invoke(63188923, SerializerHelper.AskStartJob_Serializer, jobclassid)
end

function SerializerHelper.OnBreakChair_Serializer(writer)
	return
end

function ClientToGameDelegate:OnBreakChair()
	self:Notify(63194564, SerializerHelper.OnBreakChair_Serializer)
end

function SerializerHelper.AskRefreshTruckOrder_Serializer(writer)
	return
end

function ClientToGameDelegate:AskRefreshTruckOrder()
	return self:Invoke(63196226, SerializerHelper.AskRefreshTruckOrder_Serializer)
end

function SerializerHelper.AskFireworkTriggerPlan_Serializer(writer, fireworkplanid)
	SerializeBase.WritePrimitive(writer, fireworkplanid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskFireworkTriggerPlan(fireworkplanid)
	return self:Invoke(63198576, SerializerHelper.AskFireworkTriggerPlan_Serializer, fireworkplanid)
end

function SerializerHelper.AskSkipPoliceTask_Serializer(writer)
	return
end

function ClientToGameDelegate:AskSkipPoliceTask()
	return self:Invoke(63201104, SerializerHelper.AskSkipPoliceTask_Serializer)
end

function SerializerHelper.AskTakeCompetitionSeasonOverallRankReward_Serializer(writer, rewardid)
	SerializeBase.WritePrimitive(writer, rewardid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTakeCompetitionSeasonOverallRankReward(rewardid)
	return self:Invoke(63206228, SerializerHelper.AskTakeCompetitionSeasonOverallRankReward_Serializer, rewardid)
end

function SerializerHelper.AskClearNpcUncompletedInviteChat_Serializer(writer)
	return
end

function ClientToGameDelegate:AskClearNpcUncompletedInviteChat()
	return self:Invoke(63207682, SerializerHelper.AskClearNpcUncompletedInviteChat_Serializer)
end

function SerializerHelper.AskNpcShopCommodityInfo_Serializer(writer, shopid)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskNpcShopCommodityInfo(shopid)
	return self:Invoke(63207943, SerializerHelper.AskNpcShopCommodityInfo_Serializer, shopid)
end

function SerializerHelper.AskSendInteractionInfoToWatchee_Serializer(writer, type, isresponse)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isresponse, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskSendInteractionInfoToWatchee(type, isresponse)
	return self:Invoke(63208749, SerializerHelper.AskSendInteractionInfoToWatchee_Serializer, type, isresponse)
end

function SerializerHelper.AskPlanningBoardSelectStepOption_Serializer(writer, stepid, optionindex)
	SerializeBase.WritePrimitive(writer, stepid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, optionindex, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskPlanningBoardSelectStepOption(stepid, optionindex)
	return self:Invoke(63210052, SerializerHelper.AskPlanningBoardSelectStepOption_Serializer, stepid, optionindex)
end

function SerializerHelper.SetLiveHouseMusicResult_Serializer(writer, livehousemusicid, recordmusicinfo, npcid)
	SerializeBase.WritePrimitive(writer, livehousemusicid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, recordmusicinfo, writer.WriteUInt32, 0, "recordmusicinfo", false, 4, nil)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:SetLiveHouseMusicResult(livehousemusicid, recordmusicinfo, npcid)
	return self:Invoke(63214264, SerializerHelper.SetLiveHouseMusicResult_Serializer, livehousemusicid, recordmusicinfo, npcid)
end

function SerializerHelper.AskKickFriendFromLink_Serializer(writer, friendid)
	SerializeBase.WritePrimitive(writer, friendid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskKickFriendFromLink(friendid)
	return self:Invoke(63214829, SerializerHelper.AskKickFriendFromLink_Serializer, friendid)
end

function SerializerHelper.AskWildEnemyBasicInfo_Serializer(writer)
	return
end

function ClientToGameDelegate:AskWildEnemyBasicInfo()
	return self:Invoke(63214919, SerializerHelper.AskWildEnemyBasicInfo_Serializer)
end

function SerializerHelper.QueryMobileBind_Serializer(writer)
	return
end

function ClientToGameDelegate:QueryMobileBind()
	return self:Invoke(63215920, SerializerHelper.QueryMobileBind_Serializer)
end

function SerializerHelper.AskDivinerEnterBattle_Serializer(writer)
	return
end

function ClientToGameDelegate:AskDivinerEnterBattle()
	return self:Invoke(63216279, SerializerHelper.AskDivinerEnterBattle_Serializer)
end

function SerializerHelper.AskResetMobileSkinPart_Serializer(writer)
	return
end

function ClientToGameDelegate:AskResetMobileSkinPart()
	return self:Invoke(63221226, SerializerHelper.AskResetMobileSkinPart_Serializer)
end

function SerializerHelper.StartMatchInTeam_Serializer(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:StartMatchInTeam(gameid)
	return self:Invoke(63221552, SerializerHelper.StartMatchInTeam_Serializer, gameid)
end

function SerializerHelper.AskRemovePersonalZoneRedSpot_Serializer(writer, type, itemid)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskRemovePersonalZoneRedSpot(type, itemid)
	return self:Invoke(63221599, SerializerHelper.AskRemovePersonalZoneRedSpot_Serializer, type, itemid)
end

function SerializerHelper.AskComputerFileRead_Serializer(writer, fileid, isvideoend)
	SerializeBase.WritePrimitive(writer, fileid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isvideoend, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskComputerFileRead(fileid, isvideoend)
	return self:Invoke(63222371, SerializerHelper.AskComputerFileRead_Serializer, fileid, isvideoend)
end

function SerializerHelper.AskAgentStartBack_Serializer(writer, npcinstanceid)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskAgentStartBack(npcinstanceid)
	return self:Invoke(63225005, SerializerHelper.AskAgentStartBack_Serializer, npcinstanceid)
end

function SerializerHelper.AskPlayerChargeBillInfo_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskPlayerChargeBillInfo(pid)
	return self:Invoke(63226615, SerializerHelper.AskPlayerChargeBillInfo_Serializer, pid)
end

function SerializerHelper.AskPoliceExamInteract_Serializer(writer, agententityid, interactid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, interactid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskPoliceExamInteract(agententityid, interactid)
	return self:Invoke(63233964, SerializerHelper.AskPoliceExamInteract_Serializer, agententityid, interactid)
end

function SerializerHelper.AskUpdatePersonalZoneHead_Serializer(writer, headtype, systemheadid)
	SerializeBase.WritePrimitive(writer, headtype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, systemheadid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskUpdatePersonalZoneHead(headtype, systemheadid)
	return self:Invoke(63236328, SerializerHelper.AskUpdatePersonalZoneHead_Serializer, headtype, systemheadid)
end

function SerializerHelper.AskReadPoliceFakeClueAgentInfoList_Serializer(writer, clueagentinfoindexlist)
	SerializeBase.WriteList(writer, clueagentinfoindexlist, writer.WriteInt32, 0, "clueagentinfoindexlist", false, 32, nil)
end

function ClientToGameDelegate:AskReadPoliceFakeClueAgentInfoList(clueagentinfoindexlist)
	return self:Invoke(63236739, SerializerHelper.AskReadPoliceFakeClueAgentInfoList_Serializer, clueagentinfoindexlist)
end

function SerializerHelper.AskPoliceFakeFileAcceptTaskEvent_Serializer(writer)
	return
end

function ClientToGameDelegate:AskPoliceFakeFileAcceptTaskEvent()
	return self:Invoke(63238313, SerializerHelper.AskPoliceFakeFileAcceptTaskEvent_Serializer)
end

function SerializerHelper.AskGetTruckSatisfactionAverage_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetTruckSatisfactionAverage()
	return self:Invoke(63239349, SerializerHelper.AskGetTruckSatisfactionAverage_Serializer)
end

function SerializerHelper.AskSetTracePosition_Serializer(writer, raidid, posid, position, name)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, posid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	writer:WriteString(name, false, "name", 256)
end

function ClientToGameDelegate:AskSetTracePosition(raidid, posid, position, name)
	self:Notify(63239512, SerializerHelper.AskSetTracePosition_Serializer, raidid, posid, position, name)
end

function SerializerHelper.AskTwitterPageClose_Serializer(writer, closetype)
	SerializeBase.WritePrimitive(writer, closetype, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskTwitterPageClose(closetype)
	self:Notify(63239647, SerializerHelper.AskTwitterPageClose_Serializer, closetype)
end

function SerializerHelper.AskHotSpringStart_Serializer(writer)
	return
end

function ClientToGameDelegate:AskHotSpringStart()
	return self:Invoke(63239719, SerializerHelper.AskHotSpringStart_Serializer)
end

function SerializerHelper.AskModifySpiritCustomSuitSchemeName_Serializer(writer, spiritid, schemeindex, schemename)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, schemeindex, writer.WriteInt32, 0)
	writer:WriteString(schemename, false, "schemename", 256)
end

function ClientToGameDelegate:AskModifySpiritCustomSuitSchemeName(spiritid, schemeindex, schemename)
	return self:Invoke(63244961, SerializerHelper.AskModifySpiritCustomSuitSchemeName_Serializer, spiritid, schemeindex, schemename)
end

function SerializerHelper.TaskSpoonCountBehavior_Serializer(writer, taskid, spooncnt, message)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spooncnt, writer.WriteUInt32, 0)
	writer:WriteString(message, false, "message", 256)
end

function ClientToGameDelegate:TaskSpoonCountBehavior(taskid, spooncnt, message)
	self:Notify(63246023, SerializerHelper.TaskSpoonCountBehavior_Serializer, taskid, spooncnt, message)
end

function SerializerHelper.AskDoctorCheck_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskDoctorCheck(agententityid)
	return self:Invoke(63248718, SerializerHelper.AskDoctorCheck_Serializer, agententityid)
end

function SerializerHelper.AskTouchMapEntrance_Serializer(writer, raidid, mapentranceid)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, mapentranceid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTouchMapEntrance(raidid, mapentranceid)
	self:Notify(63250338, SerializerHelper.AskTouchMapEntrance_Serializer, raidid, mapentranceid)
end

function SerializerHelper.AskClearAbilityRedPoint_Serializer(writer, spiritid, abilityid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, abilityid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskClearAbilityRedPoint(spiritid, abilityid)
	return self:Invoke(63255088, SerializerHelper.AskClearAbilityRedPoint_Serializer, spiritid, abilityid)
end

function SerializerHelper.OnTafeiMotorAccelerating_Serializer(writer)
	return
end

function ClientToGameDelegate:OnTafeiMotorAccelerating()
	self:Notify(63256406, SerializerHelper.OnTafeiMotorAccelerating_Serializer)
end

function SerializerHelper.AskNewLink_Serializer(writer, type, psnonly)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, psnonly, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskNewLink(type, psnonly)
	return self:Invoke(63256669, SerializerHelper.AskNewLink_Serializer, type, psnonly)
end

function SerializerHelper.AskGetSavedRaidTargetInfo_Serializer(writer, raidid)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskGetSavedRaidTargetInfo(raidid)
	return self:Invoke(63257209, SerializerHelper.AskGetSavedRaidTargetInfo_Serializer, raidid)
end

function SerializerHelper.AskDeleteMail_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskDeleteMail(id)
	return self:Invoke(63257388, SerializerHelper.AskDeleteMail_Serializer, id)
end

function SerializerHelper.StartGameInTeam_Serializer(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:StartGameInTeam(gameid)
	return self:Invoke(63259642, SerializerHelper.StartGameInTeam_Serializer, gameid)
end

function SerializerHelper.AskFerrisWheelStart_Serializer(writer)
	return
end

function ClientToGameDelegate:AskFerrisWheelStart()
	self:Notify(63267531, SerializerHelper.AskFerrisWheelStart_Serializer)
end

function SerializerHelper.AskReplyToFriendLinkInvite_Serializer(writer, type, friendid, accept)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, friendid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskReplyToFriendLinkInvite(type, friendid, accept)
	return self:Invoke(63269471, SerializerHelper.AskReplyToFriendLinkInvite_Serializer, type, friendid, accept)
end

function SerializerHelper.AskEnterRaidByMapEntrance_Serializer(writer, mapentranceid)
	SerializeBase.WritePrimitive(writer, mapentranceid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskEnterRaidByMapEntrance(mapentranceid)
	return self:Invoke(63273437, SerializerHelper.AskEnterRaidByMapEntrance_Serializer, mapentranceid)
end

function SerializerHelper.AskReadHackerNewPost_Serializer(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskReadHackerNewPost(postid)
	return self:Invoke(63273976, SerializerHelper.AskReadHackerNewPost_Serializer, postid)
end

function SerializerHelper.AskAbandonPoliceTask_Serializer(writer)
	return
end

function ClientToGameDelegate:AskAbandonPoliceTask()
	return self:Invoke(63275788, SerializerHelper.AskAbandonPoliceTask_Serializer)
end

function SerializerHelper.AskVehicleSendGamePlaySignal_Serializer(writer, signal)
	SerializeBase.WritePrimitive(writer, signal, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskVehicleSendGamePlaySignal(signal)
	return self:Invoke(63276604, SerializerHelper.AskVehicleSendGamePlaySignal_Serializer, signal)
end

function SerializerHelper.AskTeleportFromHouseGarage_Serializer(writer, houseid, parkingspaceindex)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, parkingspaceindex, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskTeleportFromHouseGarage(houseid, parkingspaceindex)
	return self:Invoke(63285675, SerializerHelper.AskTeleportFromHouseGarage_Serializer, houseid, parkingspaceindex)
end

function SerializerHelper.AskFinishWpFansPerformance_Serializer(writer, nuid)
	SerializeBase.WritePrimitive(writer, nuid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskFinishWpFansPerformance(nuid)
	self:Notify(63288556, SerializerHelper.AskFinishWpFansPerformance_Serializer, nuid)
end

function SerializerHelper.CastVote_Serializer(writer, sessionid, vote)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, vote, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:CastVote(sessionid, vote)
	return self:Invoke(63288852, SerializerHelper.CastVote_Serializer, sessionid, vote)
end

function SerializerHelper.AskLiveHouseMusicList_Serializer(writer)
	return
end

function ClientToGameDelegate:AskLiveHouseMusicList()
	return self:Invoke(63290316, SerializerHelper.AskLiveHouseMusicList_Serializer)
end

function SerializerHelper.AskMomentsSendCommentWithId_Serializer(writer, postid, commentid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, commentid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskMomentsSendCommentWithId(postid, commentid)
	return self:Invoke(63292504, SerializerHelper.AskMomentsSendCommentWithId_Serializer, postid, commentid)
end

function SerializerHelper.AskWebpageOpenOrClose_Serializer(writer, webpageid, open)
	SerializeBase.WritePrimitive(writer, webpageid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, open, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskWebpageOpenOrClose(webpageid, open)
	self:Notify(63292674, SerializerHelper.AskWebpageOpenOrClose_Serializer, webpageid, open)
end

function SerializerHelper.AskObsoleteTruckJobOrder_Serializer(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskObsoleteTruckJobOrder(orderid)
	return self:Invoke(63296228, SerializerHelper.AskObsoleteTruckJobOrder_Serializer, orderid)
end

function SerializerHelper.AskBuyCommodity_Serializer(writer, commodityid, count)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskBuyCommodity(commodityid, count)
	return self:Invoke(63296328, SerializerHelper.AskBuyCommodity_Serializer, commodityid, count)
end

function SerializerHelper.AskJoinTeam_Serializer(writer, newmember)
	SerializeBase.WritePrimitive(writer, newmember, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskJoinTeam(newmember)
	return self:Invoke(63296618, SerializerHelper.AskJoinTeam_Serializer, newmember)
end

function SerializerHelper.AskPoliceStopHelicopterDispatch_Serializer(writer)
	return
end

function ClientToGameDelegate:AskPoliceStopHelicopterDispatch()
	return self:Invoke(63302890, SerializerHelper.AskPoliceStopHelicopterDispatch_Serializer)
end

function SerializerHelper.AskAddMailToFavorites_Serializer(writer, mailid)
	SerializeBase.WritePrimitive(writer, mailid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskAddMailToFavorites(mailid)
	return self:Invoke(63303581, SerializerHelper.AskAddMailToFavorites_Serializer, mailid)
end

function SerializerHelper.AskPSNPlayersInfo_Serializer(writer, pids)
	SerializeBase.WriteList(writer, pids, writer.WriteUInt64, 0, "pids", false, 256, nil)
end

function ClientToGameDelegate:AskPSNPlayersInfo(pids)
	return self:Invoke(63303712, SerializerHelper.AskPSNPlayersInfo_Serializer, pids)
end

function SerializerHelper.AskComputerDeleteFile_Serializer(writer, computerid, fileid)
	SerializeBase.WritePrimitive(writer, computerid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fileid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskComputerDeleteFile(computerid, fileid)
	return self:Invoke(63304115, SerializerHelper.AskComputerDeleteFile_Serializer, computerid, fileid)
end

function SerializerHelper.AskLeaveTeam_Serializer(writer)
	return
end

function ClientToGameDelegate:AskLeaveTeam()
	return self:Invoke(63304509, SerializerHelper.AskLeaveTeam_Serializer)
end

function SerializerHelper.AskPokemonRebuild_Serializer(writer, id, bodyid, campid, weaponid)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, bodyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, campid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskPokemonRebuild(id, bodyid, campid, weaponid)
	return self:Invoke(63305288, SerializerHelper.AskPokemonRebuild_Serializer, id, bodyid, campid, weaponid)
end

function SerializerHelper.AskMahjongInfo_Serializer(writer)
	return
end

function ClientToGameDelegate:AskMahjongInfo()
	return self:Invoke(63306015, SerializerHelper.AskMahjongInfo_Serializer)
end

function SerializerHelper.AskClearAllNpcDialogNpcChat_Serializer(writer)
	return
end

function ClientToGameDelegate:AskClearAllNpcDialogNpcChat()
	return self:Invoke(63307384, SerializerHelper.AskClearAllNpcDialogNpcChat_Serializer)
end

function SerializerHelper.AskInvestigatorInfo_Serializer(writer)
	return
end

function ClientToGameDelegate:AskInvestigatorInfo()
	return self:Invoke(63311744, SerializerHelper.AskInvestigatorInfo_Serializer)
end

function SerializerHelper.InviteNpcChat_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:InviteNpcChat(chatid)
	return self:Invoke(63315080, SerializerHelper.InviteNpcChat_Serializer, chatid)
end

function SerializerHelper.AskFireworkWorkStoreInfo_Serializer(writer, storeid)
	SerializeBase.WritePrimitive(writer, storeid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskFireworkWorkStoreInfo(storeid)
	return self:Invoke(63316010, SerializerHelper.AskFireworkWorkStoreInfo_Serializer, storeid)
end

function SerializerHelper.AskLeaveLink_Serializer(writer, mode)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskLeaveLink(mode)
	return self:Invoke(63317095, SerializerHelper.AskLeaveLink_Serializer, mode)
end

function SerializerHelper.PartyOver_Serializer(writer)
	return
end

function ClientToGameDelegate:PartyOver()
	return self:Invoke(63318103, SerializerHelper.PartyOver_Serializer)
end

function SerializerHelper.AskActivityCancelRedPoint_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskActivityCancelRedPoint(id)
	return self:Invoke(63327583, SerializerHelper.AskActivityCancelRedPoint_Serializer, id)
end

function SerializerHelper.SyncWorldBattlePlayers_Serializer(writer, gadgetid, multiplayerid, enter)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, multiplayerid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

function ClientToGameDelegate:SyncWorldBattlePlayers(gadgetid, multiplayerid, enter)
	return self:Invoke(63327702, SerializerHelper.SyncWorldBattlePlayers_Serializer, gadgetid, multiplayerid, enter)
end

function SerializerHelper.AskGetOnMobilePlatform_Serializer(writer, mobileplatformid)
	SerializeBase.WritePrimitive(writer, mobileplatformid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskGetOnMobilePlatform(mobileplatformid)
	return self:Invoke(63327755, SerializerHelper.AskGetOnMobilePlatform_Serializer, mobileplatformid)
end

function SerializerHelper.AskChallengeTeleport_Serializer(writer, taskid, pos, face)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WritePrimitive(writer, face, writer.WriteSingle, 0)
end

function ClientToGameDelegate:AskChallengeTeleport(taskid, pos, face)
	return self:Invoke(63327819, SerializerHelper.AskChallengeTeleport_Serializer, taskid, pos, face)
end

function SerializerHelper.AskUseFerrisWheelTicket_Serializer(writer, tickettype, ferriswheelid, npccultivationid)
	SerializeBase.WritePrimitive(writer, tickettype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, ferriswheelid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskUseFerrisWheelTicket(tickettype, ferriswheelid, npccultivationid)
	return self:Invoke(63331329, SerializerHelper.AskUseFerrisWheelTicket_Serializer, tickettype, ferriswheelid, npccultivationid)
end

function SerializerHelper.AskChangeTeamLeaderApply_Serializer(writer)
	return
end

function ClientToGameDelegate:AskChangeTeamLeaderApply()
	return self:Invoke(63333284, SerializerHelper.AskChangeTeamLeaderApply_Serializer)
end

function SerializerHelper.AskLinkInfos_Serializer(writer)
	return
end

function ClientToGameDelegate:AskLinkInfos()
	return self:Invoke(63335013, SerializerHelper.AskLinkInfos_Serializer)
end

function SerializerHelper.ActiveTaskCounter_Serializer(writer, taskid, counterindex, isonfoot)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counterindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isonfoot, writer.WriteBoolean, false)
end

function ClientToGameDelegate:ActiveTaskCounter(taskid, counterindex, isonfoot)
	return self:Invoke(63335971, SerializerHelper.ActiveTaskCounter_Serializer, taskid, counterindex, isonfoot)
end

function SerializerHelper.AskStartSingleMatch_Serializer(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskStartSingleMatch(gameid)
	return self:Invoke(63336499, SerializerHelper.AskStartSingleMatch_Serializer, gameid)
end

function SerializerHelper.AskNpcShareTimeInfo_Serializer(writer)
	return
end

function ClientToGameDelegate:AskNpcShareTimeInfo()
	return self:Invoke(63337960, SerializerHelper.AskNpcShareTimeInfo_Serializer)
end

function SerializerHelper.OnInteractWithHugePigeon_Serializer(writer)
	return
end

function ClientToGameDelegate:OnInteractWithHugePigeon()
	self:Notify(63343982, SerializerHelper.OnInteractWithHugePigeon_Serializer)
end

function SerializerHelper.AskAddTruckOrderSpecialPointReward_Serializer(writer, orderid, pointid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pointid, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskAddTruckOrderSpecialPointReward(orderid, pointid)
	return self:Invoke(63346443, SerializerHelper.AskAddTruckOrderSpecialPointReward_Serializer, orderid, pointid)
end

function SerializerHelper.AskChangeBuildHouseIndoor_Serializer(writer, houseid, floor, changeplacedfurnitureinfo)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, changeplacedfurnitureinfo, SerializeAuto.WriteChangePlacedFurnitureInfo, "changeplacedfurnitureinfo")
end

function ClientToGameDelegate:AskChangeBuildHouseIndoor(houseid, floor, changeplacedfurnitureinfo)
	return self:Invoke(63356561, SerializerHelper.AskChangeBuildHouseIndoor_Serializer, houseid, floor, changeplacedfurnitureinfo)
end

function SerializerHelper.AskHack_Serializer(writer, hacktype)
	SerializeBase.WritePrimitive(writer, hacktype, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskHack(hacktype)
	return self:Invoke(63359217, SerializerHelper.AskHack_Serializer, hacktype)
end

function SerializerHelper.AskCloseConnectionToGame_Serializer(writer, msg)
	writer:WriteString(msg, false, "msg", 256)
end

function ClientToGameDelegate:AskCloseConnectionToGame(msg)
	return self:Invoke(63361417, SerializerHelper.AskCloseConnectionToGame_Serializer, msg)
end

function SerializerHelper.AskDoDialogAction_Serializer(writer, dialogid)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskDoDialogAction(dialogid)
	return self:Invoke(63361629, SerializerHelper.AskDoDialogAction_Serializer, dialogid)
end

function SerializerHelper.AskChangeHackerName_Serializer(writer, name)
	writer:WriteString(name, false, "name", 32)
end

function ClientToGameDelegate:AskChangeHackerName(name)
	return self:Invoke(63362157, SerializerHelper.AskChangeHackerName_Serializer, name)
end

function SerializerHelper.AskStartDialog_Serializer(writer, dialogid, param, interrupt)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteDialogParameter, "param", false)
	SerializeBase.WritePrimitive(writer, interrupt, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskStartDialog(dialogid, param, interrupt)
	self:Notify(63364652, SerializerHelper.AskStartDialog_Serializer, dialogid, param, interrupt)
end

function SerializerHelper.AskAgentUpdateBackTransform_Serializer(writer, npcinstanceid, autobackindex, pos, facing)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, autobackindex, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

function ClientToGameDelegate:AskAgentUpdateBackTransform(npcinstanceid, autobackindex, pos, facing)
	self:Notify(63365357, SerializerHelper.AskAgentUpdateBackTransform_Serializer, npcinstanceid, autobackindex, pos, facing)
end

function SerializerHelper.AskComputerEmailRead_Serializer(writer, email)
	SerializeBase.WritePrimitive(writer, email, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskComputerEmailRead(email)
	return self:Invoke(63368528, SerializerHelper.AskComputerEmailRead_Serializer, email)
end

function SerializerHelper.SaveCustomInteractionInfo_Serializer(writer, type, info)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
	writer:WriteString(info, false, "info", 256)
end

function ClientToGameDelegate:SaveCustomInteractionInfo(type, info)
	return self:Invoke(63369010, SerializerHelper.SaveCustomInteractionInfo_Serializer, type, info)
end

function SerializerHelper.AskHouseParking_Serializer(writer, parkinginfolist)
	SerializeBase.WriteList(writer, parkinginfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteHouseParkingInfo, "HouseParkingInfo", false), nil, "parkinginfolist", false, 256, nil)
end

function ClientToGameDelegate:AskHouseParking(parkinginfolist)
	return self:Invoke(63369229, SerializerHelper.AskHouseParking_Serializer, parkinginfolist)
end

function SerializerHelper.AskPoliceEffectiveExam_Serializer(writer)
	return
end

function ClientToGameDelegate:AskPoliceEffectiveExam()
	return self:Invoke(63369381, SerializerHelper.AskPoliceEffectiveExam_Serializer)
end

function SerializerHelper.AskClawBuyTicket_Serializer(writer)
	return
end

function ClientToGameDelegate:AskClawBuyTicket()
	return self:Invoke(63370028, SerializerHelper.AskClawBuyTicket_Serializer)
end

function SerializerHelper.InteractNpcChatToEnd_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:InteractNpcChatToEnd(chatid)
	return self:Invoke(63371712, SerializerHelper.InteractNpcChatToEnd_Serializer, chatid)
end

function SerializerHelper.AskPolicePrepareExam_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskPolicePrepareExam(agententityid)
	return self:Invoke(63371802, SerializerHelper.AskPolicePrepareExam_Serializer, agententityid)
end

function SerializerHelper.AskDrawGacha_Serializer(writer, gachaid, level)
	SerializeBase.WritePrimitive(writer, gachaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskDrawGacha(gachaid, level)
	return self:Invoke(63371981, SerializerHelper.AskDrawGacha_Serializer, gachaid, level)
end

function SerializerHelper.AskSetSpiritWearFashionHiddenParts_Serializer(writer, spiritid, hiddenparts)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hiddenparts, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskSetSpiritWearFashionHiddenParts(spiritid, hiddenparts)
	return self:Invoke(63372220, SerializerHelper.AskSetSpiritWearFashionHiddenParts_Serializer, spiritid, hiddenparts)
end

function SerializerHelper.AskDivinerPersuade_Serializer(writer, agententityid, message, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer:WriteString(message, false, "message", 256)
	writer:WriteString(lang, false, "lang", 32)
end

function ClientToGameDelegate:AskDivinerPersuade(agententityid, message, lang)
	return self:Invoke(63377145, SerializerHelper.AskDivinerPersuade_Serializer, agententityid, message, lang)
end

function SerializerHelper.OnPaperCranesFly_Serializer(writer)
	return
end

function ClientToGameDelegate:OnPaperCranesFly()
	self:Notify(63377904, SerializerHelper.OnPaperCranesFly_Serializer)
end

function SerializerHelper.AskSetSpiritFunctionSuitSchemeInfo_Serializer(writer, spiritid, functionsuitid, isbatch, functionsuitschemeinfo)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, functionsuitid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isbatch, writer.WriteBoolean, false)
	SerializeBase.WriteComplex(writer, functionsuitschemeinfo, SerializeAuto.WriteFashionFunctionSuitSchemeInfo, "functionsuitschemeinfo", false)
end

function ClientToGameDelegate:AskSetSpiritFunctionSuitSchemeInfo(spiritid, functionsuitid, isbatch, functionsuitschemeinfo)
	return self:Invoke(63386651, SerializerHelper.AskSetSpiritFunctionSuitSchemeInfo_Serializer, spiritid, functionsuitid, isbatch, functionsuitschemeinfo)
end

function SerializerHelper.RequestNpcChatList_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:RequestNpcChatList(chatid)
	return self:Invoke(63386828, SerializerHelper.RequestNpcChatList_Serializer, chatid)
end

function SerializerHelper.AskRemoveMailFromFavorites_Serializer(writer, mailid)
	SerializeBase.WritePrimitive(writer, mailid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskRemoveMailFromFavorites(mailid)
	return self:Invoke(63390024, SerializerHelper.AskRemoveMailFromFavorites_Serializer, mailid)
end

function SerializerHelper.AskLiveHouseUseItem_Serializer(writer, musicid)
	SerializeBase.WritePrimitive(writer, musicid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskLiveHouseUseItem(musicid)
	return self:Invoke(63391260, SerializerHelper.AskLiveHouseUseItem_Serializer, musicid)
end

function SerializerHelper.AskReportClientFpsInfo_Serializer(writer, fpsinfo)
	SerializeBase.WriteComplex(writer, fpsinfo, SerializeAuto.WriteClientFpsInfo, "fpsinfo", false)
end

function ClientToGameDelegate:AskReportClientFpsInfo(fpsinfo)
	self:Notify(63392341, SerializerHelper.AskReportClientFpsInfo_Serializer, fpsinfo)
end

function SerializerHelper.AskComputerDeleteEmail_Serializer(writer, computerid, emailid)
	SerializeBase.WritePrimitive(writer, computerid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, emailid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskComputerDeleteEmail(computerid, emailid)
	return self:Invoke(63392432, SerializerHelper.AskComputerDeleteEmail_Serializer, computerid, emailid)
end

function SerializerHelper.AskPoliceExitEscortOrExam_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskPoliceExitEscortOrExam(agententityid)
	return self:Invoke(63398162, SerializerHelper.AskPoliceExitEscortOrExam_Serializer, agententityid)
end

function SerializerHelper.AskLinkWatchOther_Serializer(writer, watchee)
	SerializeBase.WritePrimitive(writer, watchee, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskLinkWatchOther(watchee)
	return self:Invoke(63405583, SerializerHelper.AskLinkWatchOther_Serializer, watchee)
end

function SerializerHelper.AskDoGuide_Serializer(writer, guideid, counter)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counter, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskDoGuide(guideid, counter)
	return self:Invoke(63408340, SerializerHelper.AskDoGuide_Serializer, guideid, counter)
end

function SerializerHelper.AskGetTruckJobOrders_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetTruckJobOrders()
	return self:Invoke(63413415, SerializerHelper.AskGetTruckJobOrders_Serializer)
end

function SerializerHelper.AskDivinerFinishRequestAppeal_Serializer(writer, agententityid, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer:WriteString(lang, false, "lang", 32)
end

function ClientToGameDelegate:AskDivinerFinishRequestAppeal(agententityid, lang)
	return self:Invoke(63414477, SerializerHelper.AskDivinerFinishRequestAppeal_Serializer, agententityid, lang)
end

function SerializerHelper.AskPhoneAddContact_Serializer(writer, spiritid, phonenumber, contactname)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer:WriteString(phonenumber, false, "phonenumber", 10)
	writer:WriteString(contactname, false, "contactname", 32)
end

function ClientToGameDelegate:AskPhoneAddContact(spiritid, phonenumber, contactname)
	return self:Invoke(63418511, SerializerHelper.AskPhoneAddContact_Serializer, spiritid, phonenumber, contactname)
end

function SerializerHelper.UpdateDaShenLogToken_Serializer(writer, logtoken)
	writer:WriteString(logtoken, false, "logtoken", 256)
end

function ClientToGameDelegate:UpdateDaShenLogToken(logtoken)
	self:Notify(63420784, SerializerHelper.UpdateDaShenLogToken_Serializer, logtoken)
end

function SerializerHelper.AskEndBarDice_Serializer(writer, diceid, gameresult)
	SerializeBase.WritePrimitive(writer, diceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, gameresult, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskEndBarDice(diceid, gameresult)
	return self:Invoke(63421408, SerializerHelper.AskEndBarDice_Serializer, diceid, gameresult)
end

function SerializerHelper.AskPhoneAddContactToGroup_Serializer(writer, spiritid, groupindex, phonenumberlist)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, groupindex, writer.WriteInt32, 0)
	SerializeBase.WriteList(writer, phonenumberlist, SerializeBase.WriteStringWrap(false, "phonenumberlist", 32), nil, "phonenumberlist", false, 32, nil)
end

function ClientToGameDelegate:AskPhoneAddContactToGroup(spiritid, groupindex, phonenumberlist)
	return self:Invoke(63421624, SerializerHelper.AskPhoneAddContactToGroup_Serializer, spiritid, groupindex, phonenumberlist)
end

function SerializerHelper.QueryQuestionnaire_Serializer(writer)
	return
end

function ClientToGameDelegate:QueryQuestionnaire()
	return self:Invoke(63423790, SerializerHelper.QueryQuestionnaire_Serializer)
end

function SerializerHelper.AskPhoneContactOptionAction_Serializer(writer, spiritid, contactid, contactoptionid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, contactid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, contactoptionid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskPhoneContactOptionAction(spiritid, contactid, contactoptionid)
	return self:Invoke(63426840, SerializerHelper.AskPhoneContactOptionAction_Serializer, spiritid, contactid, contactoptionid)
end

function SerializerHelper.SyncEnterFogMapPoiId_Serializer(writer, poiid)
	SerializeBase.WritePrimitive(writer, poiid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:SyncEnterFogMapPoiId(poiid)
	self:Notify(63428058, SerializerHelper.SyncEnterFogMapPoiId_Serializer, poiid)
end

function SerializerHelper.SpoonClientCountBehavior_Serializer(writer, clienttype, graphname, spooncnt)
	SerializeBase.WritePrimitive(writer, clienttype, writer.WriteUInt32, 0)
	writer:WriteString(graphname, false, "graphname", 256)
	SerializeBase.WritePrimitive(writer, spooncnt, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:SpoonClientCountBehavior(clienttype, graphname, spooncnt)
	self:Notify(63431261, SerializerHelper.SpoonClientCountBehavior_Serializer, clienttype, graphname, spooncnt)
end

function SerializerHelper.AskRemoveTraceGps_Serializer(writer)
	return
end

function ClientToGameDelegate:AskRemoveTraceGps()
	return self:Invoke(63432343, SerializerHelper.AskRemoveTraceGps_Serializer)
end

function SerializerHelper.AskKickFriendInRoom_Serializer(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskKickFriendInRoom(friendpid)
	return self:Invoke(63433550, SerializerHelper.AskKickFriendInRoom_Serializer, friendpid)
end

function SerializerHelper.AskFavoriteFashionSuits_Serializer(writer, unfavoritefashionsuitidlist, favoritefashionsuitidlist)
	SerializeBase.WriteList(writer, unfavoritefashionsuitidlist, writer.WriteUInt32, 0, "unfavoritefashionsuitidlist", true, 32, nil)
	SerializeBase.WriteList(writer, favoritefashionsuitidlist, writer.WriteUInt32, 0, "favoritefashionsuitidlist", true, 32, nil)
end

function ClientToGameDelegate:AskFavoriteFashionSuits(unfavoritefashionsuitidlist, favoritefashionsuitidlist)
	return self:Invoke(63434217, SerializerHelper.AskFavoriteFashionSuits_Serializer, unfavoritefashionsuitidlist, favoritefashionsuitidlist)
end

function SerializerHelper.SetMiniGame_BeeScore_Serializer(writer, scores)
	SerializeBase.WriteList(writer, scores, writer.WriteUInt32, 0, "scores", false, 256, nil)
end

function ClientToGameDelegate:SetMiniGame_BeeScore(scores)
	return self:Invoke(63437331, SerializerHelper.SetMiniGame_BeeScore_Serializer, scores)
end

function SerializerHelper.AskResponseTeamInvite_Serializer(writer, inviter, teamid, reject)
	SerializeBase.WritePrimitive(writer, inviter, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, teamid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reject, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskResponseTeamInvite(inviter, teamid, reject)
	return self:Invoke(63443233, SerializerHelper.AskResponseTeamInvite_Serializer, inviter, teamid, reject)
end

function SerializerHelper.VerifyMobileBindSMSCode_Serializer(writer, phonenum, code)
	writer:WriteString(phonenum, false, "phonenum", 32)
	writer:WriteString(code, false, "code", 32)
end

function ClientToGameDelegate:VerifyMobileBindSMSCode(phonenum, code)
	return self:Invoke(63444074, SerializerHelper.VerifyMobileBindSMSCode_Serializer, phonenum, code)
end

function SerializerHelper.ReportPoliceExamCommandEnd_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:ReportPoliceExamCommandEnd(agententityid)
	self:Notify(63445929, SerializerHelper.ReportPoliceExamCommandEnd_Serializer, agententityid)
end

function SerializerHelper.AskTakeJob_Serializer(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTakeJob(jobclassid)
	return self:Invoke(63446135, SerializerHelper.AskTakeJob_Serializer, jobclassid)
end

function SerializerHelper.AskItemExchange_Serializer(writer, exchangeid, count)
	SerializeBase.WritePrimitive(writer, exchangeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskItemExchange(exchangeid, count)
	return self:Invoke(63447065, SerializerHelper.AskItemExchange_Serializer, exchangeid, count)
end

function SerializerHelper.UpdateNgPushSetting_Serializer(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteNgpushSetting, "setting", false)
end

function ClientToGameDelegate:UpdateNgPushSetting(setting)
	self:Notify(63447550, SerializerHelper.UpdateNgPushSetting_Serializer, setting)
end

function SerializerHelper.AskUpdatePersonalZoneAchieveList_Serializer(writer, achievements, countryid)
	SerializeBase.WriteList(writer, achievements, SerializeBase.WriteComplexWrap(SerializeAuto.WritePersonalZoneAchievement, "PersonalZoneAchievement", false), nil, "achievements", false, 32, nil)
	SerializeBase.WritePrimitive(writer, countryid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskUpdatePersonalZoneAchieveList(achievements, countryid)
	return self:Invoke(63449927, SerializerHelper.AskUpdatePersonalZoneAchieveList_Serializer, achievements, countryid)
end

function SerializerHelper.ActiveGadgetId_Serializer(writer, gadgetid)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:ActiveGadgetId(gadgetid)
	self:Notify(63452412, SerializerHelper.ActiveGadgetId_Serializer, gadgetid)
end

function SerializerHelper.StartSingleParty_Serializer(writer, partyid, npcs)
	SerializeBase.WritePrimitive(writer, partyid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, npcs, writer.WriteUInt32, 0, "npcs", false, 256, nil)
end

function ClientToGameDelegate:StartSingleParty(partyid, npcs)
	return self:Invoke(63452554, SerializerHelper.StartSingleParty_Serializer, partyid, npcs)
end

function SerializerHelper.OnTafeiMotorColliding_Serializer(writer)
	return
end

function ClientToGameDelegate:OnTafeiMotorColliding()
	self:Notify(63455004, SerializerHelper.OnTafeiMotorColliding_Serializer)
end

function SerializerHelper.OnParkourStateChange_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:OnParkourStateChange(id)
	self:Notify(63457958, SerializerHelper.OnParkourStateChange_Serializer, id)
end

function SerializerHelper.AskModifySpiritWearFashions_Serializer(writer, spiritid, unwearfashionidlist, wearfashioninfolist, uneditwearfashionidlist, editwearfashioneditinfolist)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, unwearfashionidlist, writer.WriteUInt32, 0, "unwearfashionidlist", true, 32, nil)
	SerializeBase.WriteList(writer, wearfashioninfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionInfo, "WearFashionInfo", true), nil, "wearfashioninfolist", true, 32, nil)
	SerializeBase.WriteList(writer, uneditwearfashionidlist, writer.WriteUInt32, 0, "uneditwearfashionidlist", true, 32, nil)
	SerializeBase.WriteList(writer, editwearfashioneditinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "editwearfashioneditinfolist", true, 32, nil)
end

function ClientToGameDelegate:AskModifySpiritWearFashions(spiritid, unwearfashionidlist, wearfashioninfolist, uneditwearfashionidlist, editwearfashioneditinfolist)
	return self:Invoke(63460243, SerializerHelper.AskModifySpiritWearFashions_Serializer, spiritid, unwearfashionidlist, wearfashioninfolist, uneditwearfashionidlist, editwearfashioneditinfolist)
end

function SerializerHelper.AskFeedback_Serializer(writer, feedbacktypes, description, urls)
	SerializeBase.WriteList(writer, feedbacktypes, writer.WriteUInt32, 0, "feedbacktypes", false, 32, nil)
	writer:WriteString(description, false, "description", 1024)
	SerializeBase.WriteList(writer, urls, SerializeBase.WriteStringWrap(false, "urls", 32), nil, "urls", false, 32, nil)
end

function ClientToGameDelegate:AskFeedback(feedbacktypes, description, urls)
	return self:Invoke(63460318, SerializerHelper.AskFeedback_Serializer, feedbacktypes, description, urls)
end

function SerializerHelper.AskReAcceptTaskFailGroup_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskReAcceptTaskFailGroup(taskid)
	return self:Invoke(63463540, SerializerHelper.AskReAcceptTaskFailGroup_Serializer, taskid)
end

function SerializerHelper.AskStartDivinerGame_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskStartDivinerGame(agententityid)
	return self:Invoke(63463734, SerializerHelper.AskStartDivinerGame_Serializer, agententityid)
end

function SerializerHelper.RequestMailsItem_Serializer(writer, mailids)
	SerializeBase.WriteList(writer, mailids, writer.WriteUInt64, 0, "mailids", false, 256, nil)
end

function ClientToGameDelegate:RequestMailsItem(mailids)
	return self:Invoke(63464186, SerializerHelper.RequestMailsItem_Serializer, mailids)
end

function SerializerHelper.AskTakeNpcProfileTrustReward_Serializer(writer, profileid, rewardid)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, rewardid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTakeNpcProfileTrustReward(profileid, rewardid)
	return self:Invoke(63464563, SerializerHelper.AskTakeNpcProfileTrustReward_Serializer, profileid, rewardid)
end

function SerializerHelper.SetNewChallengeData_Serializer(writer, challengeid, data, score)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, data, writer.WriteBoolean, false, "data", false, 32, nil)
	SerializeBase.WritePrimitive(writer, score, writer.WriteSingle, 0)
end

function ClientToGameDelegate:SetNewChallengeData(challengeid, data, score)
	return self:Invoke(63465082, SerializerHelper.SetNewChallengeData_Serializer, challengeid, data, score)
end

function SerializerHelper.AskLinkPlanningBoardDividendsPutInKeys_Serializer(writer, keycountinfolist)
	SerializeBase.WriteList(writer, keycountinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteItemCountInfo, "ItemCountInfo", false), nil, "keycountinfolist", false, 32, nil)
end

function ClientToGameDelegate:AskLinkPlanningBoardDividendsPutInKeys(keycountinfolist)
	return self:Invoke(63465403, SerializerHelper.AskLinkPlanningBoardDividendsPutInKeys_Serializer, keycountinfolist)
end

function SerializerHelper.AskMallBuyBundle_Serializer(writer, bundleid, buycnt, isautoexchange)
	SerializeBase.WritePrimitive(writer, bundleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buycnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isautoexchange, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskMallBuyBundle(bundleid, buycnt, isautoexchange)
	return self:Invoke(63469498, SerializerHelper.AskMallBuyBundle_Serializer, bundleid, buycnt, isautoexchange)
end

function SerializerHelper.RequestNpcGroupMembers_Serializer(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:RequestNpcGroupMembers(groupid)
	return self:Invoke(63471624, SerializerHelper.RequestNpcGroupMembers_Serializer, groupid)
end

function SerializerHelper.AskNewChallengeTeleport_Serializer(writer, challengeid)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskNewChallengeTeleport(challengeid)
	return self:Invoke(63476354, SerializerHelper.AskNewChallengeTeleport_Serializer, challengeid)
end

function SerializerHelper.AskStealNPCMoney_Serializer(writer)
	return
end

function ClientToGameDelegate:AskStealNPCMoney()
	return self:Invoke(63478765, SerializerHelper.AskStealNPCMoney_Serializer)
end

function SerializerHelper.AskMailFavorites_Serializer(writer)
	return
end

function ClientToGameDelegate:AskMailFavorites()
	return self:Invoke(63479890, SerializerHelper.AskMailFavorites_Serializer)
end

function SerializerHelper.AskDivinerUpdatePersuadeProgress_Serializer(writer, agententityid, progress)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, progress, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskDivinerUpdatePersuadeProgress(agententityid, progress)
	return self:Invoke(63480056, SerializerHelper.AskDivinerUpdatePersuadeProgress_Serializer, agententityid, progress)
end

function SerializerHelper.AskHouseMoveParkingSpace_Serializer(writer, moveparkingspaceinfolist)
	SerializeBase.WriteList(writer, moveparkingspaceinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteHouseMoveParkingSpaceInfo, "HouseMoveParkingSpaceInfo", false), nil, "moveparkingspaceinfolist", false, 256, nil)
end

function ClientToGameDelegate:AskHouseMoveParkingSpace(moveparkingspaceinfolist)
	return self:Invoke(63481355, SerializerHelper.AskHouseMoveParkingSpace_Serializer, moveparkingspaceinfolist)
end

function SerializerHelper.AskGetAcceptedOrderWraps_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetAcceptedOrderWraps()
	return self:Invoke(63489148, SerializerHelper.AskGetAcceptedOrderWraps_Serializer)
end

function SerializerHelper.AskTrackEvent_Serializer(writer, evenid)
	SerializeBase.WritePrimitive(writer, evenid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTrackEvent(evenid)
	self:Notify(63490021, SerializerHelper.AskTrackEvent_Serializer, evenid)
end

function SerializerHelper.AskDeleteTask_Serializer(writer, taskid, fail)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fail, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskDeleteTask(taskid, fail)
	return self:Invoke(63493056, SerializerHelper.AskDeleteTask_Serializer, taskid, fail)
end

function SerializerHelper.AskPublishTuite_Serializer(writer, tuiteconfigid)
	SerializeBase.WritePrimitive(writer, tuiteconfigid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskPublishTuite(tuiteconfigid)
	return self:Invoke(63493355, SerializerHelper.AskPublishTuite_Serializer, tuiteconfigid)
end

function SerializerHelper.AskAnimalHandbookInteract_Serializer(writer, animalid)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskAnimalHandbookInteract(animalid)
	return self:Invoke(63499638, SerializerHelper.AskAnimalHandbookInteract_Serializer, animalid)
end

function SerializerHelper.CreateSurrenderVote_Serializer(writer)
	return
end

function ClientToGameDelegate:CreateSurrenderVote()
	return self:Invoke(63501003, SerializerHelper.CreateSurrenderVote_Serializer)
end

function SerializerHelper.AskQueryTruckPosInfo_Serializer(writer, pickupids, deliveryids)
	SerializeBase.WriteList(writer, pickupids, writer.WriteUInt32, 0, "pickupids", false, 32, nil)
	SerializeBase.WriteList(writer, deliveryids, writer.WriteUInt32, 0, "deliveryids", false, 32, nil)
end

function ClientToGameDelegate:AskQueryTruckPosInfo(pickupids, deliveryids)
	return self:Invoke(63501449, SerializerHelper.AskQueryTruckPosInfo_Serializer, pickupids, deliveryids)
end

function SerializerHelper.AskConfirmDutySwap_Serializer(writer, sourcepid, accept)
	SerializeBase.WritePrimitive(writer, sourcepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskConfirmDutySwap(sourcepid, accept)
	return self:Invoke(63502374, SerializerHelper.AskConfirmDutySwap_Serializer, sourcepid, accept)
end

function SerializerHelper.ArchiveInvestigateGallery_Serializer(writer, galleryid)
	SerializeBase.WritePrimitive(writer, galleryid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:ArchiveInvestigateGallery(galleryid)
	return self:Invoke(63502680, SerializerHelper.ArchiveInvestigateGallery_Serializer, galleryid)
end

function SerializerHelper.SendMobileBindSMS_Serializer(writer, phonenum)
	writer:WriteString(phonenum, false, "phonenum", 32)
end

function ClientToGameDelegate:SendMobileBindSMS(phonenum)
	return self:Invoke(63505594, SerializerHelper.SendMobileBindSMS_Serializer, phonenum)
end

function SerializerHelper.AskLeaveDivinerGame_Serializer(writer)
	return
end

function ClientToGameDelegate:AskLeaveDivinerGame()
	return self:Invoke(63505983, SerializerHelper.AskLeaveDivinerGame_Serializer)
end

function SerializerHelper.OnStealPhone_Serializer(writer)
	return
end

function ClientToGameDelegate:OnStealPhone()
	self:Notify(63507656, SerializerHelper.OnStealPhone_Serializer)
end

function SerializerHelper.AskAidByPid_Serializer(writer, pids)
	SerializeBase.WriteList(writer, pids, writer.WriteUInt64, 0, "pids", false, 256, nil)
end

function ClientToGameDelegate:AskAidByPid(pids)
	return self:Invoke(63508651, SerializerHelper.AskAidByPid_Serializer, pids)
end

function SerializerHelper.AskDiscardArmoryWeapon_Serializer(writer, weaponinstanceid, isdropout)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isdropout, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskDiscardArmoryWeapon(weaponinstanceid, isdropout)
	return self:Invoke(63510779, SerializerHelper.AskDiscardArmoryWeapon_Serializer, weaponinstanceid, isdropout)
end

function SerializerHelper.AskAgentPatrolFinish_Serializer(writer, npcinstanceid, groupindex, success)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, groupindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskAgentPatrolFinish(npcinstanceid, groupindex, success)
	self:Notify(63513155, SerializerHelper.AskAgentPatrolFinish_Serializer, npcinstanceid, groupindex, success)
end

function SerializerHelper.RecordDarts_Serializer(writer, challengeid, score, goal, finish, types)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, goal, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, finish, writer.WriteBoolean, false)
	SerializeBase.WriteList(writer, types, writer.WriteByte, 0, "types", false, 32, nil)
end

function ClientToGameDelegate:RecordDarts(challengeid, score, goal, finish, types)
	return self:Invoke(63515128, SerializerHelper.RecordDarts_Serializer, challengeid, score, goal, finish, types)
end

function SerializerHelper.AskApplyToTeam_Serializer(writer, teamid)
	SerializeBase.WritePrimitive(writer, teamid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskApplyToTeam(teamid)
	return self:Invoke(63516264, SerializerHelper.AskApplyToTeam_Serializer, teamid)
end

function SerializerHelper.AskSetMobileSkinPart_Serializer(writer, wallpaper, decoration, pendant)
	SerializeBase.WritePrimitive(writer, wallpaper, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, decoration, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pendant, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSetMobileSkinPart(wallpaper, decoration, pendant)
	return self:Invoke(63516582, SerializerHelper.AskSetMobileSkinPart_Serializer, wallpaper, decoration, pendant)
end

function SerializerHelper.AskResetTruckOrderGoods_Serializer(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskResetTruckOrderGoods(orderid)
	return self:Invoke(63517412, SerializerHelper.AskResetTruckOrderGoods_Serializer, orderid)
end

function SerializerHelper.AskBartenderGameSettlement_Serializer(writer, bartenderid, customerid, drinkmenuid, drinkqualityscore, guestsatisfactionbonus)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, customerid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, drinkmenuid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, drinkqualityscore, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, guestsatisfactionbonus, writer.WriteSingle, 0)
end

function ClientToGameDelegate:AskBartenderGameSettlement(bartenderid, customerid, drinkmenuid, drinkqualityscore, guestsatisfactionbonus)
	return self:Invoke(63520587, SerializerHelper.AskBartenderGameSettlement_Serializer, bartenderid, customerid, drinkmenuid, drinkqualityscore, guestsatisfactionbonus)
end

function SerializerHelper.AskTwitterBehaviorFinish_Serializer(writer, behavior, id)
	SerializeBase.WritePrimitive(writer, behavior, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskTwitterBehaviorFinish(behavior, id)
	return self:Invoke(63521359, SerializerHelper.AskTwitterBehaviorFinish_Serializer, behavior, id)
end

function SerializerHelper.AskCancelInviterPlayerInteractionAction_Serializer(writer)
	return
end

function ClientToGameDelegate:AskCancelInviterPlayerInteractionAction()
	return self:Invoke(63522633, SerializerHelper.AskCancelInviterPlayerInteractionAction_Serializer)
end

function SerializerHelper.AskSetFashionColoringSchemeInfos_Serializer(writer, fashioncoloringschemeinfolist)
	SerializeBase.WriteList(writer, fashioncoloringschemeinfolist, SerializeBase.WriteStructWrap(SerializeAuto.WriteFashionColoringSchemeInfo, "fashioncoloringschemeinfolist"), nil, "fashioncoloringschemeinfolist", false, 32, nil)
end

function ClientToGameDelegate:AskSetFashionColoringSchemeInfos(fashioncoloringschemeinfolist)
	return self:Invoke(63524349, SerializerHelper.AskSetFashionColoringSchemeInfos_Serializer, fashioncoloringschemeinfolist)
end

function SerializerHelper.UsePoliceChargingProgress_Serializer(writer, info)
	SerializeBase.WriteStruct(writer, info, SerializeAuto.WritePoliceChargingSkillInfo, "info")
end

function ClientToGameDelegate:UsePoliceChargingProgress(info)
	return self:Invoke(63525617, SerializerHelper.UsePoliceChargingProgress_Serializer, info)
end

function SerializerHelper.AskStartGymExercise_Serializer(writer, exerciseid)
	SerializeBase.WritePrimitive(writer, exerciseid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskStartGymExercise(exerciseid)
	self:Notify(63528170, SerializerHelper.AskStartGymExercise_Serializer, exerciseid)
end

function SerializerHelper.AskAgentChangeIndoor_Serializer(writer, npcinstanceid, indoorid, enter)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, indoorid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskAgentChangeIndoor(npcinstanceid, indoorid, enter)
	self:Notify(63528784, SerializerHelper.AskAgentChangeIndoor_Serializer, npcinstanceid, indoorid, enter)
end

function SerializerHelper.AskInviteToTeam_Serializer(writer, inviteepid, doublecheck)
	SerializeBase.WritePrimitive(writer, inviteepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, doublecheck, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskInviteToTeam(inviteepid, doublecheck)
	return self:Invoke(63530713, SerializerHelper.AskInviteToTeam_Serializer, inviteepid, doublecheck)
end

function SerializerHelper.AskPlayGameNext_Serializer(writer)
	return
end

function ClientToGameDelegate:AskPlayGameNext()
	return self:Invoke(63536758, SerializerHelper.AskPlayGameNext_Serializer)
end

function SerializerHelper.AskNpcProfileCancelTargetNewState_Serializer(writer, profileid, target)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, target, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskNpcProfileCancelTargetNewState(profileid, target)
	return self:Invoke(63537805, SerializerHelper.AskNpcProfileCancelTargetNewState_Serializer, profileid, target)
end

function SerializerHelper.AskAcceptWasherMission_Serializer(writer, index, missionid)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, missionid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskAcceptWasherMission(index, missionid)
	return self:Invoke(63538188, SerializerHelper.AskAcceptWasherMission_Serializer, index, missionid)
end

function SerializerHelper.AskDivinerTriggerResult_Serializer(writer)
	return
end

function ClientToGameDelegate:AskDivinerTriggerResult()
	self:Notify(63542057, SerializerHelper.AskDivinerTriggerResult_Serializer)
end

function SerializerHelper.AskTakeItemProduced_Serializer(writer)
	return
end

function ClientToGameDelegate:AskTakeItemProduced()
	return self:Invoke(63542679, SerializerHelper.AskTakeItemProduced_Serializer)
end

function SerializerHelper.AskUpdatePersonalZoneDescription_Serializer(writer, pid, desc)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer:WriteString(desc, false, "desc", 256)
end

function ClientToGameDelegate:AskUpdatePersonalZoneDescription(pid, desc)
	return self:Invoke(63544265, SerializerHelper.AskUpdatePersonalZoneDescription_Serializer, pid, desc)
end

function SerializerHelper.AskHotSpringSettlement_Serializer(writer)
	return
end

function ClientToGameDelegate:AskHotSpringSettlement()
	return self:Invoke(63544648, SerializerHelper.AskHotSpringSettlement_Serializer)
end

function SerializerHelper.CompleteSubQuest_Serializer(writer, subquestid)
	SerializeBase.WritePrimitive(writer, subquestid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:CompleteSubQuest(subquestid)
	return self:Invoke(63545469, SerializerHelper.CompleteSubQuest_Serializer, subquestid)
end

function SerializerHelper.AskPoliceFineNpc_Serializer(writer, agententityid, finelist)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WriteList(writer, finelist, writer.WriteUInt32, 0, "finelist", false, 32, nil)
end

function ClientToGameDelegate:AskPoliceFineNpc(agententityid, finelist)
	return self:Invoke(63548238, SerializerHelper.AskPoliceFineNpc_Serializer, agententityid, finelist)
end

function SerializerHelper.ReportRequisitionVehicle_Serializer(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:ReportRequisitionVehicle(vehicleid)
	self:Notify(63553227, SerializerHelper.ReportRequisitionVehicle_Serializer, vehicleid)
end

function SerializerHelper.AskClearPersonalZoneNewBubbleLikes_Serializer(writer)
	return
end

function ClientToGameDelegate:AskClearPersonalZoneNewBubbleLikes()
	return self:Invoke(63555824, SerializerHelper.AskClearPersonalZoneNewBubbleLikes_Serializer)
end

function SerializerHelper.AskRemainChangeNameCount_Serializer(writer)
	return
end

function ClientToGameDelegate:AskRemainChangeNameCount()
	return self:Invoke(63558886, SerializerHelper.AskRemainChangeNameCount_Serializer)
end

function SerializerHelper.AskTakeCompetitionSeasonHighestRankReward_Serializer(writer, rewardid)
	SerializeBase.WritePrimitive(writer, rewardid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTakeCompetitionSeasonHighestRankReward(rewardid)
	return self:Invoke(63560225, SerializerHelper.AskTakeCompetitionSeasonHighestRankReward_Serializer, rewardid)
end

function SerializerHelper.AskPhoneEditContactGroup_Serializer(writer, spiritid, groupindex, groupname)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, groupindex, writer.WriteInt32, 0)
	writer:WriteString(groupname, false, "groupname", 32)
end

function ClientToGameDelegate:AskPhoneEditContactGroup(spiritid, groupindex, groupname)
	return self:Invoke(63561922, SerializerHelper.AskPhoneEditContactGroup_Serializer, spiritid, groupindex, groupname)
end

function SerializerHelper.AskForceSkipTask_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskForceSkipTask(taskid)
	return self:Invoke(63562905, SerializerHelper.AskForceSkipTask_Serializer, taskid)
end

function SerializerHelper.OnImposterExplode_Serializer(writer)
	return
end

function ClientToGameDelegate:OnImposterExplode()
	self:Notify(63563350, SerializerHelper.OnImposterExplode_Serializer)
end

function SerializerHelper.ClaimCityPediaLevelReward_Serializer(writer, leveltoclaim)
	SerializeBase.WritePrimitive(writer, leveltoclaim, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:ClaimCityPediaLevelReward(leveltoclaim)
	return self:Invoke(63563728, SerializerHelper.ClaimCityPediaLevelReward_Serializer, leveltoclaim)
end

function SerializerHelper.AskMomentsLikePost_Serializer(writer, postid, like)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, like, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskMomentsLikePost(postid, like)
	return self:Invoke(63565367, SerializerHelper.AskMomentsLikePost_Serializer, postid, like)
end

function SerializerHelper.AskSendInteractionInfo_Serializer(writer, pid, type, isresponse)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isresponse, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskSendInteractionInfo(pid, type, isresponse)
	return self:Invoke(63565459, SerializerHelper.AskSendInteractionInfo_Serializer, pid, type, isresponse)
end

function SerializerHelper.InteractNpcChat_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:InteractNpcChat(chatid)
	return self:Invoke(63565583, SerializerHelper.InteractNpcChat_Serializer, chatid)
end

function SerializerHelper.DoMessageCallback_Serializer(writer, messageid, state, para)
	SerializeBase.WritePrimitive(writer, messageid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteByte, 0)
	SerializeBase.WriteComplex(writer, para, SerializeAuto.WriteMessageCallbackParameter, "para", true)
end

function ClientToGameDelegate:DoMessageCallback(messageid, state, para)
	return self:Invoke(63568618, SerializerHelper.DoMessageCallback_Serializer, messageid, state, para)
end

function SerializerHelper.AskAutoAcceptTruckJobOrder_Serializer(writer, bautoaccept)
	SerializeBase.WritePrimitive(writer, bautoaccept, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskAutoAcceptTruckJobOrder(bautoaccept)
	return self:Invoke(63571409, SerializerHelper.AskAutoAcceptTruckJobOrder_Serializer, bautoaccept)
end

function SerializerHelper.AskHotSpringInviteCompanionNpc_Serializer(writer, npc)
	SerializeBase.WritePrimitive(writer, npc, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskHotSpringInviteCompanionNpc(npc)
	return self:Invoke(63573435, SerializerHelper.AskHotSpringInviteCompanionNpc_Serializer, npc)
end

function SerializerHelper.AskGetUnlockedVehicles_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetUnlockedVehicles()
	return self:Invoke(63574292, SerializerHelper.AskGetUnlockedVehicles_Serializer)
end

function SerializerHelper.AskGetOffMobilePlatform_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetOffMobilePlatform()
	return self:Invoke(63574661, SerializerHelper.AskGetOffMobilePlatform_Serializer)
end

function SerializerHelper.StartDarts_Serializer(writer, dartid, challengeid, dartmode)
	SerializeBase.WritePrimitive(writer, dartid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, dartmode, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:StartDarts(dartid, challengeid, dartmode)
	return self:Invoke(63577426, SerializerHelper.StartDarts_Serializer, dartid, challengeid, dartmode)
end

function SerializerHelper.AskEndBartenderGame_Serializer(writer)
	return
end

function ClientToGameDelegate:AskEndBartenderGame()
	return self:Invoke(63577859, SerializerHelper.AskEndBartenderGame_Serializer)
end

function SerializerHelper.AskPhoneAppDownload_Serializer(writer, appid)
	SerializeBase.WritePrimitive(writer, appid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskPhoneAppDownload(appid)
	return self:Invoke(63577993, SerializerHelper.AskPhoneAppDownload_Serializer, appid)
end

function SerializerHelper.AddPoliceChargingProgress_Serializer(writer, chargingeventid)
	SerializeBase.WritePrimitive(writer, chargingeventid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AddPoliceChargingProgress(chargingeventid)
	return self:Invoke(63578799, SerializerHelper.AddPoliceChargingProgress_Serializer, chargingeventid)
end

function SerializerHelper.AskDivinerStartTimeCheck_Serializer(writer, lang)
	writer:WriteString(lang, false, "lang", 32)
end

function ClientToGameDelegate:AskDivinerStartTimeCheck(lang)
	return self:Invoke(63579450, SerializerHelper.AskDivinerStartTimeCheck_Serializer, lang)
end

function SerializerHelper.SetChallengeStartTime_Serializer(writer, taskid, starttime)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, starttime, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:SetChallengeStartTime(taskid, starttime)
	return self:Invoke(63581743, SerializerHelper.SetChallengeStartTime_Serializer, taskid, starttime)
end

function SerializerHelper.AskReplyToFriendRoomInvite_Serializer(writer, roomid, friendpid, accept)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskReplyToFriendRoomInvite(roomid, friendpid, accept)
	return self:Invoke(63582610, SerializerHelper.AskReplyToFriendRoomInvite_Serializer, roomid, friendpid, accept)
end

function SerializerHelper.AskIgnoreFailPanel_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskIgnoreFailPanel(taskid)
	return self:Invoke(63582824, SerializerHelper.AskIgnoreFailPanel_Serializer, taskid)
end

function SerializerHelper.AskChangeTaskCounterValue_Serializer(writer, taskid, counterindex, value)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counterindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskChangeTaskCounterValue(taskid, counterindex, value)
	self:Notify(63583961, SerializerHelper.AskChangeTaskCounterValue_Serializer, taskid, counterindex, value)
end

function SerializerHelper.AskModifySpiritWearFashionEditInfos_Serializer(writer, spiritid, uneditwearfashionidlist, editwearfashioneditinfolist)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, uneditwearfashionidlist, writer.WriteUInt32, 0, "uneditwearfashionidlist", true, 32, nil)
	SerializeBase.WriteList(writer, editwearfashioneditinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "editwearfashioneditinfolist", true, 32, nil)
end

function ClientToGameDelegate:AskModifySpiritWearFashionEditInfos(spiritid, uneditwearfashionidlist, editwearfashioneditinfolist)
	return self:Invoke(63585267, SerializerHelper.AskModifySpiritWearFashionEditInfos_Serializer, spiritid, uneditwearfashionidlist, editwearfashioneditinfolist)
end

function SerializerHelper.AskTakePopularityReward_Serializer(writer, count)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTakePopularityReward(count)
	return self:Invoke(63586619, SerializerHelper.AskTakePopularityReward_Serializer, count)
end

function SerializerHelper.AskAcceptHackerPostTask_Serializer(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskAcceptHackerPostTask(postid)
	return self:Invoke(63594408, SerializerHelper.AskAcceptHackerPostTask_Serializer, postid)
end

function SerializerHelper.AskSetTruckJobDefaultVehicleId_Serializer(writer, defaultvehicleid)
	SerializeBase.WritePrimitive(writer, defaultvehicleid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSetTruckJobDefaultVehicleId(defaultvehicleid)
	return self:Invoke(63596082, SerializerHelper.AskSetTruckJobDefaultVehicleId_Serializer, defaultvehicleid)
end

function SerializerHelper.SendMobileUnbind_Serializer(writer, phonenum)
	writer:WriteString(phonenum, false, "phonenum", 32)
end

function ClientToGameDelegate:SendMobileUnbind(phonenum)
	return self:Invoke(63597720, SerializerHelper.SendMobileUnbind_Serializer, phonenum)
end

function SerializerHelper.AskPolicePrepareEscort_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskPolicePrepareEscort(agententityid)
	return self:Invoke(63598566, SerializerHelper.AskPolicePrepareEscort_Serializer, agententityid)
end

function SerializerHelper.AskMomentsTapPostWithCount_Serializer(writer, postid, emojilist)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, emojilist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteEmojiData, "EmojiData", false), nil, "emojilist", false, 256, nil)
end

function ClientToGameDelegate:AskMomentsTapPostWithCount(postid, emojilist)
	return self:Invoke(63599025, SerializerHelper.AskMomentsTapPostWithCount_Serializer, postid, emojilist)
end

function SerializerHelper.AskHangUpDialog_Serializer(writer, taskid, dialogid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskHangUpDialog(taskid, dialogid)
	return self:Invoke(63604699, SerializerHelper.AskHangUpDialog_Serializer, taskid, dialogid)
end

function SerializerHelper.GetMahjongRankReward_Serializer(writer, rank)
	SerializeBase.WritePrimitive(writer, rank, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:GetMahjongRankReward(rank)
	return self:Invoke(63605850, SerializerHelper.GetMahjongRankReward_Serializer, rank)
end

function SerializerHelper.AskAllSpiritPanelData_Serializer(writer)
	return
end

function ClientToGameDelegate:AskAllSpiritPanelData()
	return self:Invoke(63609539, SerializerHelper.AskAllSpiritPanelData_Serializer)
end

function SerializerHelper.AskPreSettleTruckOrder_Serializer(writer, uniqueid, completenesslist)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, completenesslist, writer.WriteSingle, 0, "completenesslist", false, 32, nil)
end

function ClientToGameDelegate:AskPreSettleTruckOrder(uniqueid, completenesslist)
	return self:Invoke(63612583, SerializerHelper.AskPreSettleTruckOrder_Serializer, uniqueid, completenesslist)
end

function SerializerHelper.AskStartPlayerInteractionAction_Serializer(writer)
	return
end

function ClientToGameDelegate:AskStartPlayerInteractionAction()
	return self:Invoke(63615056, SerializerHelper.AskStartPlayerInteractionAction_Serializer)
end

function SerializerHelper.AskActiveSpiritJobTalentLayer_Serializer(writer, spiritid, jobclassid, talentid, addlayer)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, talentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addlayer, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskActiveSpiritJobTalentLayer(spiritid, jobclassid, talentid, addlayer)
	return self:Invoke(63615905, SerializerHelper.AskActiveSpiritJobTalentLayer_Serializer, spiritid, jobclassid, talentid, addlayer)
end

function SerializerHelper.AskPanelBrowsingTime_Serializer(writer, panelid, logicid, time)
	SerializeBase.WritePrimitive(writer, panelid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, logicid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, time, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskPanelBrowsingTime(panelid, logicid, time)
	self:Notify(63617493, SerializerHelper.AskPanelBrowsingTime_Serializer, panelid, logicid, time)
end

function SerializerHelper.AddPersonalTimeSetting_Serializer(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WritePersonalTimeSetting, "info", false)
end

function ClientToGameDelegate:AddPersonalTimeSetting(info)
	return self:Invoke(63617533, SerializerHelper.AddPersonalTimeSetting_Serializer, info)
end

function SerializerHelper.ProgressStateChange_Serializer(writer, state, markid)
	SerializeBase.WritePrimitive(writer, state, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, markid, writer.WriteInt32, 0)
end

function ClientToGameDelegate:ProgressStateChange(state, markid)
	return self:Invoke(63620214, SerializerHelper.ProgressStateChange_Serializer, state, markid)
end

function SerializerHelper.AskFinishQuestionnaire_Serializer(writer)
	return
end

function ClientToGameDelegate:AskFinishQuestionnaire()
	return self:Invoke(63621000, SerializerHelper.AskFinishQuestionnaire_Serializer)
end

function SerializerHelper.AskReportWebpageResource_Serializer(writer, resourceid)
	SerializeBase.WritePrimitive(writer, resourceid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskReportWebpageResource(resourceid)
	self:Notify(63624820, SerializerHelper.AskReportWebpageResource_Serializer, resourceid)
end

function SerializerHelper.AskEnableInvitedNotDisturb_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskEnableInvitedNotDisturb(enable)
	return self:Invoke(63625065, SerializerHelper.AskEnableInvitedNotDisturb_Serializer, enable)
end

function SerializerHelper.AskConfirmMatchResult_Serializer(writer, ready)
	SerializeBase.WritePrimitive(writer, ready, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskConfirmMatchResult(ready)
	return self:Invoke(63625130, SerializerHelper.AskConfirmMatchResult_Serializer, ready)
end

function SerializerHelper.AskAcceptAndSetCurrentTask_Serializer(writer, taskid, spirit, ignoreswitchspirit)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spirit, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ignoreswitchspirit, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskAcceptAndSetCurrentTask(taskid, spirit, ignoreswitchspirit)
	return self:Invoke(63628971, SerializerHelper.AskAcceptAndSetCurrentTask_Serializer, taskid, spirit, ignoreswitchspirit)
end

function SerializerHelper.AskTwitterPageOpen_Serializer(writer, pagetype, key, value)
	SerializeBase.WritePrimitive(writer, pagetype, writer.WriteByte, 0)
	writer:WriteString(key, false, "key", 32)
	SerializeBase.WritePrimitive(writer, value, writer.WriteDouble, 0)
end

function ClientToGameDelegate:AskTwitterPageOpen(pagetype, key, value)
	self:Notify(63629684, SerializerHelper.AskTwitterPageOpen_Serializer, pagetype, key, value)
end

function SerializerHelper.AskNearbyRunningAttractPoint_Serializer(writer, crowduid)
	SerializeBase.WritePrimitive(writer, crowduid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskNearbyRunningAttractPoint(crowduid)
	self:Notify(63630533, SerializerHelper.AskNearbyRunningAttractPoint_Serializer, crowduid)
end

function SerializerHelper.AskItemProduce_Serializer(writer, produceid, count, bias)
	SerializeBase.WritePrimitive(writer, produceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, bias, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskItemProduce(produceid, count, bias)
	return self:Invoke(63630944, SerializerHelper.AskItemProduce_Serializer, produceid, count, bias)
end

function SerializerHelper.AskCloseNpcChatWnd_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskCloseNpcChatWnd(chatid)
	self:Notify(63634630, SerializerHelper.AskCloseNpcChatWnd_Serializer, chatid)
end

function SerializerHelper.AskBuyBattlePassLevels_Serializer(writer, levelstobuy)
	SerializeBase.WritePrimitive(writer, levelstobuy, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskBuyBattlePassLevels(levelstobuy)
	return self:Invoke(63634877, SerializerHelper.AskBuyBattlePassLevels_Serializer, levelstobuy)
end

function SerializerHelper.SetChallengeResult_Serializer(writer, taskid, score, goal, types)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, goal, writer.WriteInt32, 0)
	SerializeBase.WriteList(writer, types, writer.WriteByte, 0, "types", false, 32, nil)
end

function ClientToGameDelegate:SetChallengeResult(taskid, score, goal, types)
	return self:Invoke(63635730, SerializerHelper.SetChallengeResult_Serializer, taskid, score, goal, types)
end

function SerializerHelper.AskSetSpiritFashions_Serializer(writer, spiritid, spiritwearfashionsinfo)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, spiritwearfashionsinfo, SerializeAuto.WriteSpiritWearFashionsInfo, "spiritwearfashionsinfo", false)
end

function ClientToGameDelegate:AskSetSpiritFashions(spiritid, spiritwearfashionsinfo)
	return self:Invoke(63637715, SerializerHelper.AskSetSpiritFashions_Serializer, spiritid, spiritwearfashionsinfo)
end

function SerializerHelper.AskPhoneDeleteContact_Serializer(writer, spiritid, phonenumber)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer:WriteString(phonenumber, false, "phonenumber", 10)
end

function ClientToGameDelegate:AskPhoneDeleteContact(spiritid, phonenumber)
	return self:Invoke(63637797, SerializerHelper.AskPhoneDeleteContact_Serializer, spiritid, phonenumber)
end

function SerializerHelper.AskFinishWasherMission_Serializer(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskFinishWasherMission(eventid)
	return self:Invoke(63639926, SerializerHelper.AskFinishWasherMission_Serializer, eventid)
end

function SerializerHelper.AskSkipDialog_Serializer(writer, dialogid, enddialogid, dialogids)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enddialogid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, dialogids, writer.WriteUInt32, 0, "dialogids", false, 32, nil)
end

function ClientToGameDelegate:AskSkipDialog(dialogid, enddialogid, dialogids)
	return self:Invoke(63641980, SerializerHelper.AskSkipDialog_Serializer, dialogid, enddialogid, dialogids)
end

function SerializerHelper.AskGetAllAchievementReward_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetAllAchievementReward()
	return self:Invoke(63642349, SerializerHelper.AskGetAllAchievementReward_Serializer)
end

function SerializerHelper.ReportWordReviewFailed_Serializer(writer, content, code, message)
	writer:WriteString(content, false, "content", 10240)
	SerializeBase.WritePrimitive(writer, code, writer.WriteInt32, 0)
	writer:WriteString(message, false, "message", 256)
end

function ClientToGameDelegate:ReportWordReviewFailed(content, code, message)
	self:Notify(63644957, SerializerHelper.ReportWordReviewFailed_Serializer, content, code, message)
end

function SerializerHelper.AskFavoriteFashions_Serializer(writer, unfavoritefashionidlist, favoritefashionidlist)
	SerializeBase.WriteList(writer, unfavoritefashionidlist, writer.WriteUInt32, 0, "unfavoritefashionidlist", true, 256, nil)
	SerializeBase.WriteList(writer, favoritefashionidlist, writer.WriteUInt32, 0, "favoritefashionidlist", true, 256, nil)
end

function ClientToGameDelegate:AskFavoriteFashions(unfavoritefashionidlist, favoritefashionidlist)
	return self:Invoke(63646317, SerializerHelper.AskFavoriteFashions_Serializer, unfavoritefashionidlist, favoritefashionidlist)
end

function SerializerHelper.AskReportQualitySetting_Serializer(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteClientQualitySetting, "setting", false)
end

function ClientToGameDelegate:AskReportQualitySetting(setting)
	self:Notify(63646888, SerializerHelper.AskReportQualitySetting_Serializer, setting)
end

function SerializerHelper.AskClearPersonalZoneNewSpiritNum_Serializer(writer)
	return
end

function ClientToGameDelegate:AskClearPersonalZoneNewSpiritNum()
	return self:Invoke(63651444, SerializerHelper.AskClearPersonalZoneNewSpiritNum_Serializer)
end

function SerializerHelper.AskGetAchievementReward_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskGetAchievementReward(id)
	return self:Invoke(63652865, SerializerHelper.AskGetAchievementReward_Serializer, id)
end

function SerializerHelper.AskNewChallengeRecord_Serializer(writer, challengeid)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskNewChallengeRecord(challengeid)
	return self:Invoke(63652914, SerializerHelper.AskNewChallengeRecord_Serializer, challengeid)
end

function SerializerHelper.TryInteractOuterStory_Serializer(writer, npccultivationid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:TryInteractOuterStory(npccultivationid)
	self:Notify(63655870, SerializerHelper.TryInteractOuterStory_Serializer, npccultivationid)
end

function SerializerHelper.AskClearSpiritGroupChat_Serializer(writer)
	return
end

function ClientToGameDelegate:AskClearSpiritGroupChat()
	self:Notify(63661870, SerializerHelper.AskClearSpiritGroupChat_Serializer)
end

function SerializerHelper.FinishTaskTitleGuideUnlock_Serializer(writer, title)
	SerializeBase.WritePrimitive(writer, title, writer.WriteUInt16, 0)
end

function ClientToGameDelegate:FinishTaskTitleGuideUnlock(title)
	self:Notify(63662045, SerializerHelper.FinishTaskTitleGuideUnlock_Serializer, title)
end

function SerializerHelper.AskTakeAccumulateSignInReward_Serializer(writer, id, index)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskTakeAccumulateSignInReward(id, index)
	return self:Invoke(63664501, SerializerHelper.AskTakeAccumulateSignInReward_Serializer, id, index)
end

function SerializerHelper.TryInteractOuterVoice_Serializer(writer, npccultivationid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:TryInteractOuterVoice(npccultivationid)
	self:Notify(63665632, SerializerHelper.TryInteractOuterVoice_Serializer, npccultivationid)
end

function SerializerHelper.AskSlowGuide_Serializer(writer, guideid, startorcancel)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, startorcancel, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskSlowGuide(guideid, startorcancel)
	return self:Invoke(63665760, SerializerHelper.AskSlowGuide_Serializer, guideid, startorcancel)
end

function SerializerHelper.AskAcceptTruckJobOrder_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskAcceptTruckJobOrder(id)
	return self:Invoke(63666925, SerializerHelper.AskAcceptTruckJobOrder_Serializer, id)
end

function SerializerHelper.AskMomentsPostSimpleInfos_Serializer(writer, lastid, posttype)
	SerializeBase.WritePrimitive(writer, lastid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, posttype, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskMomentsPostSimpleInfos(lastid, posttype)
	return self:Invoke(63669696, SerializerHelper.AskMomentsPostSimpleInfos_Serializer, lastid, posttype)
end

function SerializerHelper.GetFavorNpcRandomDialog_Serializer(writer, activityid, maintag, subtag)
	SerializeBase.WritePrimitive(writer, activityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maintag, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, subtag, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:GetFavorNpcRandomDialog(activityid, maintag, subtag)
	return self:Invoke(63672752, SerializerHelper.GetFavorNpcRandomDialog_Serializer, activityid, maintag, subtag)
end

function SerializerHelper.AskPoliceEscortNpc_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskPoliceEscortNpc(agententityid)
	return self:Invoke(63674017, SerializerHelper.AskPoliceEscortNpc_Serializer, agententityid)
end

function SerializerHelper.AskGetFansAutoGiveHistory_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetFansAutoGiveHistory()
	return self:Invoke(63675749, SerializerHelper.AskGetFansAutoGiveHistory_Serializer)
end

function SerializerHelper.AskActivateNpcProfile_Serializer(writer, profileid)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskActivateNpcProfile(profileid)
	return self:Invoke(63676062, SerializerHelper.AskActivateNpcProfile_Serializer, profileid)
end

function SerializerHelper.AskSummonGangMember_Serializer(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSummonGangMember(templateid)
	return self:Invoke(63679798, SerializerHelper.AskSummonGangMember_Serializer, templateid)
end

function SerializerHelper.AskSetMilkTopicList_Serializer(writer, topiclist)
	SerializeBase.WriteList(writer, topiclist, writer.WriteUInt32, 0, "topiclist", false, 32, nil)
end

function ClientToGameDelegate:AskSetMilkTopicList(topiclist)
	return self:Invoke(63681985, SerializerHelper.AskSetMilkTopicList_Serializer, topiclist)
end

function SerializerHelper.InviteMultiNpcChat_Serializer(writer, chatid, npclist)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, npclist, writer.WriteUInt32, 0, "npclist", false, 32, nil)
end

function ClientToGameDelegate:InviteMultiNpcChat(chatid, npclist)
	return self:Invoke(63683403, SerializerHelper.InviteMultiNpcChat_Serializer, chatid, npclist)
end

function SerializerHelper.AskCompleteUrbanPlay_Serializer(writer, playresult)
	SerializeBase.WriteComplex(writer, playresult, SerializeAuto.WriteUrbanGamePlayResult, "playresult", false)
end

function ClientToGameDelegate:AskCompleteUrbanPlay(playresult)
	self:Notify(63683721, SerializerHelper.AskCompleteUrbanPlay_Serializer, playresult)
end

function SerializerHelper.AskKickTeamMember_Serializer(writer, memberpid)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskKickTeamMember(memberpid)
	return self:Invoke(63684061, SerializerHelper.AskKickTeamMember_Serializer, memberpid)
end

function SerializerHelper.FavorNpcInteract_Serializer(writer, spoonagentid, start)
	SerializeBase.WritePrimitive(writer, spoonagentid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, start, writer.WriteBoolean, false)
end

function ClientToGameDelegate:FavorNpcInteract(spoonagentid, start)
	self:Notify(63685936, SerializerHelper.FavorNpcInteract_Serializer, spoonagentid, start)
end

function SerializerHelper.ReportMoveSwing_Serializer(writer, time, distance)
	SerializeBase.WritePrimitive(writer, time, writer.WriteDouble, 0)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteSingle, 0)
end

function ClientToGameDelegate:ReportMoveSwing(time, distance)
	self:Notify(63686537, SerializerHelper.ReportMoveSwing_Serializer, time, distance)
end

function SerializerHelper.AskGetMilkTopicInfo_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetMilkTopicInfo()
	return self:Invoke(63689562, SerializerHelper.AskGetMilkTopicInfo_Serializer)
end

function SerializerHelper.AskMomentsTapPost_Serializer(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskMomentsTapPost(postid)
	return self:Invoke(63691025, SerializerHelper.AskMomentsTapPost_Serializer, postid)
end

function SerializerHelper.OnCarriageChanged_Serializer(writer, carriageid, isenter)
	SerializeBase.WritePrimitive(writer, carriageid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isenter, writer.WriteBoolean, false)
end

function ClientToGameDelegate:OnCarriageChanged(carriageid, isenter)
	self:Notify(63693174, SerializerHelper.OnCarriageChanged_Serializer, carriageid, isenter)
end

function SerializerHelper.AskReportJoystickChange_Serializer(writer, joystickinfo)
	writer:WriteString(joystickinfo, false, "joystickinfo", 256)
end

function ClientToGameDelegate:AskReportJoystickChange(joystickinfo)
	self:Notify(63693479, SerializerHelper.AskReportJoystickChange_Serializer, joystickinfo)
end

function SerializerHelper.AskQueryAgentDetailList_Serializer(writer, instanceids)
	SerializeBase.WriteList(writer, instanceids, writer.WriteUInt64, 0, "instanceids", false, 32, nil)
end

function ClientToGameDelegate:AskQueryAgentDetailList(instanceids)
	return self:Invoke(63700323, SerializerHelper.AskQueryAgentDetailList_Serializer, instanceids)
end

function SerializerHelper.AskAcceptPoliceTask_Serializer(writer)
	return
end

function ClientToGameDelegate:AskAcceptPoliceTask()
	return self:Invoke(63700415, SerializerHelper.AskAcceptPoliceTask_Serializer)
end

function SerializerHelper.AskDoctorCure_Serializer(writer, agententityid, interactid, successfulqtecount)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, interactid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, successfulqtecount, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskDoctorCure(agententityid, interactid, successfulqtecount)
	return self:Invoke(63703743, SerializerHelper.AskDoctorCure_Serializer, agententityid, interactid, successfulqtecount)
end

function SerializerHelper.AskAgentBackSuccess_Serializer(writer, npcinstanceid)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskAgentBackSuccess(npcinstanceid)
	return self:Invoke(63709000, SerializerHelper.AskAgentBackSuccess_Serializer, npcinstanceid)
end

function SerializerHelper.GetServerTimeGame_Serializer(writer, clientunixtime)
	SerializeBase.WritePrimitive(writer, clientunixtime, writer.WriteDouble, 0)
end

function ClientToGameDelegate:GetServerTimeGame(clientunixtime)
	self:Notify(63710146, SerializerHelper.GetServerTimeGame_Serializer, clientunixtime)
end

function SerializerHelper.AskInviteFriendToRoom_Serializer(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskInviteFriendToRoom(friendpid)
	return self:Invoke(63710585, SerializerHelper.AskInviteFriendToRoom_Serializer, friendpid)
end

function SerializerHelper.AskCancelNpcProfileNew_Serializer(writer, profileid)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskCancelNpcProfileNew(profileid)
	return self:Invoke(63710814, SerializerHelper.AskCancelNpcProfileNew_Serializer, profileid)
end

function SerializerHelper.AskQuitJob_Serializer(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskQuitJob(jobclassid)
	return self:Invoke(63717772, SerializerHelper.AskQuitJob_Serializer, jobclassid)
end

function SerializerHelper.AskSubmitItemsByTask_Serializer(writer, taskid, countindex, itemlist, submititemid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, countindex, writer.WriteInt32, 0)
	SerializeBase.WriteDict(writer, itemlist, writer.WriteUInt32, writer.WriteUInt32, 0, "itemlist", false, 32)
	SerializeBase.WritePrimitive(writer, submititemid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSubmitItemsByTask(taskid, countindex, itemlist, submititemid)
	return self:Invoke(63719219, SerializerHelper.AskSubmitItemsByTask_Serializer, taskid, countindex, itemlist, submititemid)
end

function SerializerHelper.AskCompleteSingleGymExercise_Serializer(writer, exerciseid, result)
	SerializeBase.WritePrimitive(writer, exerciseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, result, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskCompleteSingleGymExercise(exerciseid, result)
	self:Notify(63719511, SerializerHelper.AskCompleteSingleGymExercise_Serializer, exerciseid, result)
end

function SerializerHelper.AskFinishGuideTeachRead_Serializer(writer, guideteachid)
	SerializeBase.WritePrimitive(writer, guideteachid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskFinishGuideTeachRead(guideteachid)
	return self:Invoke(63720594, SerializerHelper.AskFinishGuideTeachRead_Serializer, guideteachid)
end

function SerializerHelper.AskSimulationInviteNpc_Serializer(writer, configid)
	SerializeBase.WritePrimitive(writer, configid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSimulationInviteNpc(configid)
	return self:Invoke(63726563, SerializerHelper.AskSimulationInviteNpc_Serializer, configid)
end

function SerializerHelper.AskReadyToPlay_Serializer(writer, readystatus)
	SerializeBase.WritePrimitive(writer, readystatus, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskReadyToPlay(readystatus)
	return self:Invoke(63727613, SerializerHelper.AskReadyToPlay_Serializer, readystatus)
end

function SerializerHelper.AskSettleTruckOrder_Serializer(writer, uniqueid)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSettleTruckOrder(uniqueid)
	return self:Invoke(63728943, SerializerHelper.AskSettleTruckOrder_Serializer, uniqueid)
end

function SerializerHelper.AskAddTruckOrderSpecialPointRewards_Serializer(writer, orderids, pointid)
	SerializeBase.WriteList(writer, orderids, writer.WriteUInt32, 0, "orderids", false, 32, nil)
	SerializeBase.WritePrimitive(writer, pointid, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskAddTruckOrderSpecialPointRewards(orderids, pointid)
	return self:Invoke(63729442, SerializerHelper.AskAddTruckOrderSpecialPointRewards_Serializer, orderids, pointid)
end

function SerializerHelper.AskPhoneEditContact_Serializer(writer, spiritid, oldphonenumber, newphonenumber, contactname)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer:WriteString(oldphonenumber, false, "oldphonenumber", 10)
	writer:WriteString(newphonenumber, false, "newphonenumber", 10)
	writer:WriteString(contactname, false, "contactname", 32)
end

function ClientToGameDelegate:AskPhoneEditContact(spiritid, oldphonenumber, newphonenumber, contactname)
	return self:Invoke(63729792, SerializerHelper.AskPhoneEditContact_Serializer, spiritid, oldphonenumber, newphonenumber, contactname)
end

function SerializerHelper.AskPanelOpenOrClose_Serializer(writer, panelid, isopen)
	SerializeBase.WritePrimitive(writer, panelid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isopen, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskPanelOpenOrClose(panelid, isopen)
	self:Notify(63730749, SerializerHelper.AskPanelOpenOrClose_Serializer, panelid, isopen)
end

function SerializerHelper.AskMoveMobilePlatform_Serializer(writer, mobileplatformid, targetindex)
	SerializeBase.WritePrimitive(writer, mobileplatformid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetindex, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskMoveMobilePlatform(mobileplatformid, targetindex)
	return self:Invoke(63733659, SerializerHelper.AskMoveMobilePlatform_Serializer, mobileplatformid, targetindex)
end

function SerializerHelper.EventSpoonCountBehavior_Serializer(writer, eventid, spooncnt, message)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spooncnt, writer.WriteUInt32, 0)
	writer:WriteString(message, false, "message", 256)
end

function ClientToGameDelegate:EventSpoonCountBehavior(eventid, spooncnt, message)
	self:Notify(63733699, SerializerHelper.EventSpoonCountBehavior_Serializer, eventid, spooncnt, message)
end

function SerializerHelper.AskChangeRoomSetting_Serializer(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteMatchRoomSetting, "setting", false)
end

function ClientToGameDelegate:AskChangeRoomSetting(setting)
	return self:Invoke(63735136, SerializerHelper.AskChangeRoomSetting_Serializer, setting)
end

function SerializerHelper.AskWildEnemyPositionInfo_Serializer(writer, campid)
	SerializeBase.WritePrimitive(writer, campid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskWildEnemyPositionInfo(campid)
	return self:Invoke(63737397, SerializerHelper.AskWildEnemyPositionInfo_Serializer, campid)
end

function SerializerHelper.AskGetWasherMissionInfo_Serializer(writer, force)
	SerializeBase.WritePrimitive(writer, force, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskGetWasherMissionInfo(force)
	return self:Invoke(63738815, SerializerHelper.AskGetWasherMissionInfo_Serializer, force)
end

function SerializerHelper.AskNameAnimal_Serializer(writer, animalid, nickname)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	writer:WriteString(nickname, false, "nickname", 256)
end

function ClientToGameDelegate:AskNameAnimal(animalid, nickname)
	return self:Invoke(63740237, SerializerHelper.AskNameAnimal_Serializer, animalid, nickname)
end

function SerializerHelper.AskUseLoadingText_Serializer(writer, loadingid)
	SerializeBase.WritePrimitive(writer, loadingid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskUseLoadingText(loadingid)
	self:Notify(63745854, SerializerHelper.AskUseLoadingText_Serializer, loadingid)
end

function SerializerHelper.AskClawDateFail_Serializer(writer)
	return
end

function ClientToGameDelegate:AskClawDateFail()
	return self:Invoke(63746165, SerializerHelper.AskClawDateFail_Serializer)
end

function SerializerHelper.QueryPersonalZoneHeadExtendInfo_Serializer(writer)
	return
end

function ClientToGameDelegate:QueryPersonalZoneHeadExtendInfo()
	return self:Invoke(63748619, SerializerHelper.QueryPersonalZoneHeadExtendInfo_Serializer)
end

function SerializerHelper.AskStartRoomMatch_Serializer(writer)
	return
end

function ClientToGameDelegate:AskStartRoomMatch()
	return self:Invoke(63748734, SerializerHelper.AskStartRoomMatch_Serializer)
end

function SerializerHelper.AskGetMailItem_Serializer(writer, mailid)
	SerializeBase.WritePrimitive(writer, mailid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskGetMailItem(mailid)
	return self:Invoke(63751218, SerializerHelper.AskGetMailItem_Serializer, mailid)
end

function SerializerHelper.AskLinkInfo_Serializer(writer, mode)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskLinkInfo(mode)
	return self:Invoke(63752748, SerializerHelper.AskLinkInfo_Serializer, mode)
end

function SerializerHelper.AskQueryTeamInfoByPid_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskQueryTeamInfoByPid(pid)
	return self:Invoke(63756002, SerializerHelper.AskQueryTeamInfoByPid_Serializer, pid)
end

function SerializerHelper.AskTimePanelInfo_Serializer(writer)
	return
end

function ClientToGameDelegate:AskTimePanelInfo()
	return self:Invoke(63756954, SerializerHelper.AskTimePanelInfo_Serializer)
end

function SerializerHelper.AskMomentsDeleteCustomPost_Serializer(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskMomentsDeleteCustomPost(postid)
	return self:Invoke(63757690, SerializerHelper.AskMomentsDeleteCustomPost_Serializer, postid)
end

function SerializerHelper.AskUpdatePersonalZoneBackground_Serializer(writer, pid, backgroundid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, backgroundid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskUpdatePersonalZoneBackground(pid, backgroundid)
	return self:Invoke(63758108, SerializerHelper.AskUpdatePersonalZoneBackground_Serializer, pid, backgroundid)
end

function SerializerHelper.AskChaosMasterGacha_Serializer(writer, poolid, count)
	SerializeBase.WritePrimitive(writer, poolid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskChaosMasterGacha(poolid, count)
	return self:Invoke(63760478, SerializerHelper.AskChaosMasterGacha_Serializer, poolid, count)
end

function SerializerHelper.LiveHouseMusicInterrupt_Serializer(writer, livehousemusicid, npcid)
	SerializeBase.WritePrimitive(writer, livehousemusicid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:LiveHouseMusicInterrupt(livehousemusicid, npcid)
	self:Notify(63762014, SerializerHelper.LiveHouseMusicInterrupt_Serializer, livehousemusicid, npcid)
end

function SerializerHelper.AskDivinerRequestAppeal_Serializer(writer, agententityid, message, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer:WriteString(message, false, "message", 256)
	writer:WriteString(lang, false, "lang", 32)
end

function ClientToGameDelegate:AskDivinerRequestAppeal(agententityid, message, lang)
	return self:Invoke(63763686, SerializerHelper.AskDivinerRequestAppeal_Serializer, agententityid, message, lang)
end

function SerializerHelper.AskPutMapPin_Serializer(writer, raidid, position, type)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskPutMapPin(raidid, position, type)
	return self:Invoke(63766041, SerializerHelper.AskPutMapPin_Serializer, raidid, position, type)
end

function SerializerHelper.AskMomentsHaveUnreadMessage_Serializer(writer)
	return
end

function ClientToGameDelegate:AskMomentsHaveUnreadMessage()
	return self:Invoke(63770294, SerializerHelper.AskMomentsHaveUnreadMessage_Serializer)
end

function SerializerHelper.AskDivinerTakeCommission_Serializer(writer, commissionid)
	SerializeBase.WritePrimitive(writer, commissionid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskDivinerTakeCommission(commissionid)
	return self:Invoke(63774932, SerializerHelper.AskDivinerTakeCommission_Serializer, commissionid)
end

function SerializerHelper.AskReadCommodities_Serializer(writer, commodityidlist)
	SerializeBase.WriteList(writer, commodityidlist, writer.WriteUInt32, 0, "commodityidlist", false, 32, nil)
end

function ClientToGameDelegate:AskReadCommodities(commodityidlist)
	return self:Invoke(63776972, SerializerHelper.AskReadCommodities_Serializer, commodityidlist)
end

function SerializerHelper.AskFinishJob_Serializer(writer)
	return
end

function ClientToGameDelegate:AskFinishJob()
	return self:Invoke(63779182, SerializerHelper.AskFinishJob_Serializer)
end

function SerializerHelper.AskChangeNameByItem_Serializer(writer, name)
	writer:WriteString(name, false, "name", 32)
end

function ClientToGameDelegate:AskChangeNameByItem(name)
	return self:Invoke(63784548, SerializerHelper.AskChangeNameByItem_Serializer, name)
end

function SerializerHelper.AskCloseNpcShop_Serializer(writer, shopid)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskCloseNpcShop(shopid)
	return self:Invoke(63788394, SerializerHelper.AskCloseNpcShop_Serializer, shopid)
end

function SerializerHelper.AskReplyInvitePlayerInteractionAction_Serializer(writer, isaccept)
	SerializeBase.WritePrimitive(writer, isaccept, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskReplyInvitePlayerInteractionAction(isaccept)
	return self:Invoke(63789535, SerializerHelper.AskReplyInvitePlayerInteractionAction_Serializer, isaccept)
end

function SerializerHelper.AskClearPersonalZoneNewFans_Serializer(writer)
	return
end

function ClientToGameDelegate:AskClearPersonalZoneNewFans()
	return self:Invoke(63790110, SerializerHelper.AskClearPersonalZoneNewFans_Serializer)
end

function SerializerHelper.AskExchangeGiftCode_Serializer(writer, cdkey)
	writer:WriteString(cdkey, false, "cdkey", 100)
end

function ClientToGameDelegate:AskExchangeGiftCode(cdkey)
	return self:Invoke(63791049, SerializerHelper.AskExchangeGiftCode_Serializer, cdkey)
end

function SerializerHelper.AskPhoneDeleteContactGroup_Serializer(writer, spiritid, groupindex)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, groupindex, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskPhoneDeleteContactGroup(spiritid, groupindex)
	return self:Invoke(63791580, SerializerHelper.AskPhoneDeleteContactGroup_Serializer, spiritid, groupindex)
end

function SerializerHelper.AskSetTaskCounterValue_Serializer(writer, taskid, counterindex, value)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counterindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskSetTaskCounterValue(taskid, counterindex, value)
	return self:Invoke(63792721, SerializerHelper.AskSetTaskCounterValue_Serializer, taskid, counterindex, value)
end

function SerializerHelper.SyncChangeIndoor_Serializer(writer, indoorconfigid, boundid)
	SerializeBase.WritePrimitive(writer, indoorconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, boundid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:SyncChangeIndoor(indoorconfigid, boundid)
	self:Notify(63793248, SerializerHelper.SyncChangeIndoor_Serializer, indoorconfigid, boundid)
end

function SerializerHelper.AskMomentsMarkRead_Serializer(writer, postids)
	SerializeBase.WriteList(writer, postids, writer.WriteUInt32, 0, "postids", false, 256, nil)
end

function ClientToGameDelegate:AskMomentsMarkRead(postids)
	return self:Invoke(63801528, SerializerHelper.AskMomentsMarkRead_Serializer, postids)
end

function SerializerHelper.AskClawSettlement_Serializer(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteClawSettlementInfo, "info", false)
end

function ClientToGameDelegate:AskClawSettlement(info)
	return self:Invoke(63808947, SerializerHelper.AskClawSettlement_Serializer, info)
end

function SerializerHelper.SendCustomCommonDataClientToGame_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToGameDelegate:SendCustomCommonDataClientToGame(data)
	return self:Invoke(63809638, SerializerHelper.SendCustomCommonDataClientToGame_Serializer, data)
end

function SerializerHelper.AskStopMatch_Serializer(writer)
	return
end

function ClientToGameDelegate:AskStopMatch()
	return self:Invoke(63809753, SerializerHelper.AskStopMatch_Serializer)
end

function SerializerHelper.AskUseItemToFightSpirit_Serializer(writer, uid, itemcount)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, itemcount, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskUseItemToFightSpirit(uid, itemcount)
	return self:Invoke(63811038, SerializerHelper.AskUseItemToFightSpirit_Serializer, uid, itemcount)
end

function SerializerHelper.AskReadFashionSuits_Serializer(writer, fashionsuitidlist)
	SerializeBase.WriteList(writer, fashionsuitidlist, writer.WriteUInt32, 0, "fashionsuitidlist", false, 32, nil)
end

function ClientToGameDelegate:AskReadFashionSuits(fashionsuitidlist)
	return self:Invoke(63817963, SerializerHelper.AskReadFashionSuits_Serializer, fashionsuitidlist)
end

function SerializerHelper.AskInteractTuite_Serializer(writer, tuiteconfigid, interacttype)
	SerializeBase.WritePrimitive(writer, tuiteconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interacttype, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskInteractTuite(tuiteconfigid, interacttype)
	return self:Invoke(63819885, SerializerHelper.AskInteractTuite_Serializer, tuiteconfigid, interacttype)
end

function SerializerHelper.AskStartGame_Serializer(writer)
	return
end

function ClientToGameDelegate:AskStartGame()
	return self:Invoke(63820182, SerializerHelper.AskStartGame_Serializer)
end

function SerializerHelper.AskPidByAid_Serializer(writer, aids)
	SerializeBase.WriteList(writer, aids, writer.WriteInt32, 0, "aids", false, 256, nil)
end

function ClientToGameDelegate:AskPidByAid(aids)
	return self:Invoke(63823240, SerializerHelper.AskPidByAid_Serializer, aids)
end

function SerializerHelper.AskReadCityPedia_Serializer(writer, citypediaid)
	SerializeBase.WritePrimitive(writer, citypediaid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskReadCityPedia(citypediaid)
	return self:Invoke(63826389, SerializerHelper.AskReadCityPedia_Serializer, citypediaid)
end

function SerializerHelper.AskGetComputerUnlockInfo_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetComputerUnlockInfo()
	return self:Invoke(63828430, SerializerHelper.AskGetComputerUnlockInfo_Serializer)
end

function SerializerHelper.AskClearRedPointList_Serializer(writer, uids)
	SerializeBase.WriteList(writer, uids, writer.WriteUInt64, 0, "uids", false, 256, nil)
end

function ClientToGameDelegate:AskClearRedPointList(uids)
	return self:Invoke(63830867, SerializerHelper.AskClearRedPointList_Serializer, uids)
end

function SerializerHelper.AskClaimBattlePassReward_Serializer(writer, leveltoclaim)
	SerializeBase.WritePrimitive(writer, leveltoclaim, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskClaimBattlePassReward(leveltoclaim)
	return self:Invoke(63834781, SerializerHelper.AskClaimBattlePassReward_Serializer, leveltoclaim)
end

function SerializerHelper.AskExitWatching_Serializer(writer)
	return
end

function ClientToGameDelegate:AskExitWatching()
	return self:Invoke(63836674, SerializerHelper.AskExitWatching_Serializer)
end

function SerializerHelper.AskGetPersonalZoneBackGroundList_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetPersonalZoneBackGroundList()
	return self:Invoke(63838275, SerializerHelper.AskGetPersonalZoneBackGroundList_Serializer)
end

function SerializerHelper.AskComputerEmailScrollToBottom_Serializer(writer, email)
	SerializeBase.WritePrimitive(writer, email, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskComputerEmailScrollToBottom(email)
	return self:Invoke(63844141, SerializerHelper.AskComputerEmailScrollToBottom_Serializer, email)
end

function SerializerHelper.AskFinishTaskCounter_Serializer(writer, taskid, counterindex)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counterindex, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskFinishTaskCounter(taskid, counterindex)
	return self:Invoke(63844382, SerializerHelper.AskFinishTaskCounter_Serializer, taskid, counterindex)
end

function SerializerHelper.AskReport_Serializer(writer, pid, reporttypes, description)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WriteList(writer, reporttypes, writer.WriteUInt32, 0, "reporttypes", false, 32, nil)
	writer:WriteString(description, false, "description", 1024)
end

function ClientToGameDelegate:AskReport(pid, reporttypes, description)
	return self:Invoke(63846499, SerializerHelper.AskReport_Serializer, pid, reporttypes, description)
end

function SerializerHelper.AskLinkWatcheeList_Serializer(writer)
	return
end

function ClientToGameDelegate:AskLinkWatcheeList()
	return self:Invoke(63852506, SerializerHelper.AskLinkWatcheeList_Serializer)
end

function SerializerHelper.AskGetFinishedOrderWraps_Serializer(writer)
	return
end

function ClientToGameDelegate:AskGetFinishedOrderWraps()
	return self:Invoke(63853110, SerializerHelper.AskGetFinishedOrderWraps_Serializer)
end

function SerializerHelper.SyncPSNBlacklist_Serializer(writer, pids)
	SerializeBase.WriteList(writer, pids, writer.WriteUInt64, 0, "pids", false, 1024, nil)
end

function ClientToGameDelegate:SyncPSNBlacklist(pids)
	return self:Invoke(63853555, SerializerHelper.SyncPSNBlacklist_Serializer, pids)
end

function SerializerHelper.AskMomentsShareCustomPost_Serializer(writer, url, title)
	writer:WriteString(url, false, "url", 256)
	writer:WriteString(title, true, "title", 256)
end

function ClientToGameDelegate:AskMomentsShareCustomPost(url, title)
	return self:Invoke(63854664, SerializerHelper.AskMomentsShareCustomPost_Serializer, url, title)
end

function SerializerHelper.AskStartBartenderGame_Serializer(writer, bartenderid)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskStartBartenderGame(bartenderid)
	return self:Invoke(63854977, SerializerHelper.AskStartBartenderGame_Serializer, bartenderid)
end

function SerializerHelper.AskFinishPlayerRace_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskFinishPlayerRace(taskid)
	return self:Invoke(63856818, SerializerHelper.AskFinishPlayerRace_Serializer, taskid)
end

function SerializerHelper.AskRemoveMapPin_Serializer(writer, pin)
	SerializeBase.WritePrimitive(writer, pin, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskRemoveMapPin(pin)
	return self:Invoke(63857300, SerializerHelper.AskRemoveMapPin_Serializer, pin)
end

function SerializerHelper.DonateFactionByCfgId_Serializer(writer, factionid, donateid)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, donateid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:DonateFactionByCfgId(factionid, donateid)
	return self:Invoke(63857346, SerializerHelper.DonateFactionByCfgId_Serializer, factionid, donateid)
end

function SerializerHelper.AskApplyDutySwap_Serializer(writer, sourceduty, targetpid, targetduty)
	SerializeBase.WritePrimitive(writer, sourceduty, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetduty, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskApplyDutySwap(sourceduty, targetpid, targetduty)
	return self:Invoke(63861812, SerializerHelper.AskApplyDutySwap_Serializer, sourceduty, targetpid, targetduty)
end

function SerializerHelper.SendPartyComment_Serializer(writer, comment)
	writer:WriteString(comment, false, "comment", 256)
end

function ClientToGameDelegate:SendPartyComment(comment)
	return self:Invoke(63864950, SerializerHelper.SendPartyComment_Serializer, comment)
end

function SerializerHelper.AskSetBestNpcs_Serializer(writer, setbestnpcinfolist)
	SerializeBase.WriteList(writer, setbestnpcinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteBestNpcInfo, "BestNpcInfo", false), nil, "setbestnpcinfolist", false, 32, nil)
end

function ClientToGameDelegate:AskSetBestNpcs(setbestnpcinfolist)
	return self:Invoke(63865265, SerializerHelper.AskSetBestNpcs_Serializer, setbestnpcinfolist)
end

function SerializerHelper.AskPoliceTakeCaseReward_Serializer(writer, caseid)
	SerializeBase.WritePrimitive(writer, caseid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskPoliceTakeCaseReward(caseid)
	return self:Invoke(63870038, SerializerHelper.AskPoliceTakeCaseReward_Serializer, caseid)
end

function SerializerHelper.AskGetNpcRandomWearFashions_Serializer(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskGetNpcRandomWearFashions(spiritid)
	return self:Invoke(63872191, SerializerHelper.AskGetNpcRandomWearFashions_Serializer, spiritid)
end

function SerializerHelper.SetChallengeStatisticalData_Serializer(writer, taskid, score, statisticaldata)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteInt32, 0)
	SerializeBase.WriteDict(writer, statisticaldata, writer.WriteInt32, writer.WriteDouble, 0, "statisticaldata", true, 32)
end

function ClientToGameDelegate:SetChallengeStatisticalData(taskid, score, statisticaldata)
	return self:Invoke(63874553, SerializerHelper.SetChallengeStatisticalData_Serializer, taskid, score, statisticaldata)
end

function SerializerHelper.RequestMailInfo_Serializer(writer, mailid)
	SerializeBase.WritePrimitive(writer, mailid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:RequestMailInfo(mailid)
	return self:Invoke(63875023, SerializerHelper.RequestMailInfo_Serializer, mailid)
end

function SerializerHelper.AskFinishNpcChatRegistration_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskFinishNpcChatRegistration(chatid)
	self:Notify(63888772, SerializerHelper.AskFinishNpcChatRegistration_Serializer, chatid)
end

function SerializerHelper.AskBartendingByDrinkMenu_Serializer(writer, bartenderid, drinkmenuid)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, drinkmenuid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskBartendingByDrinkMenu(bartenderid, drinkmenuid)
	return self:Invoke(63890074, SerializerHelper.AskBartendingByDrinkMenu_Serializer, bartenderid, drinkmenuid)
end

function SerializerHelper.VehicleDriveScore_Serializer(writer, score)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:VehicleDriveScore(score)
	return self:Invoke(63892976, SerializerHelper.VehicleDriveScore_Serializer, score)
end

function SerializerHelper.AskDoAgentFansPerformance_Serializer(writer, nuid, agentinstanceid)
	SerializeBase.WritePrimitive(writer, nuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskDoAgentFansPerformance(nuid, agentinstanceid)
	self:Notify(63894385, SerializerHelper.AskDoAgentFansPerformance_Serializer, nuid, agentinstanceid)
end

function SerializerHelper.AskTakeLevelReward_Serializer(writer, level)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskTakeLevelReward(level)
	return self:Invoke(63894466, SerializerHelper.AskTakeLevelReward_Serializer, level)
end

function SerializerHelper.AskChangePrepareSetting_Serializer(writer, prepareinfo)
	SerializeBase.WriteComplex(writer, prepareinfo, SerializeAuto.WriteMatchPrepareInfo, "prepareinfo", false)
end

function ClientToGameDelegate:AskChangePrepareSetting(prepareinfo)
	return self:Invoke(63899448, SerializerHelper.AskChangePrepareSetting_Serializer, prepareinfo)
end

function SerializerHelper.AskGetPersonalZoneRedSpot_Serializer(writer, type)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskGetPersonalZoneRedSpot(type)
	return self:Invoke(63899476, SerializerHelper.AskGetPersonalZoneRedSpot_Serializer, type)
end

function SerializerHelper.AskPhoneAddCallRecord_Serializer(writer, spiritid, phonenumber, calltype)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer:WriteString(phonenumber, false, "phonenumber", 10)
	SerializeBase.WritePrimitive(writer, calltype, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskPhoneAddCallRecord(spiritid, phonenumber, calltype)
	return self:Invoke(63899645, SerializerHelper.AskPhoneAddCallRecord_Serializer, spiritid, phonenumber, calltype)
end

function SerializerHelper.AskSunBathSettlement_Serializer(writer, npccultivationid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSunBathSettlement(npccultivationid)
	return self:Invoke(63900065, SerializerHelper.AskSunBathSettlement_Serializer, npccultivationid)
end

function SerializerHelper.AskComputerOpened_Serializer(writer, computerid)
	SerializeBase.WritePrimitive(writer, computerid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskComputerOpened(computerid)
	return self:Invoke(63902942, SerializerHelper.AskComputerOpened_Serializer, computerid)
end

function SerializerHelper.AskLeaveGame_Serializer(writer, punish)
	SerializeBase.WritePrimitive(writer, punish, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskLeaveGame(punish)
	return self:Invoke(63903024, SerializerHelper.AskLeaveGame_Serializer, punish)
end

function SerializerHelper.AskChangeTeamLeader_Serializer(writer, newleader)
	SerializeBase.WritePrimitive(writer, newleader, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskChangeTeamLeader(newleader)
	return self:Invoke(63904256, SerializerHelper.AskChangeTeamLeader_Serializer, newleader)
end

function SerializerHelper.AskUpdatePersonalZoneBirthday_Serializer(writer, birthday)
	SerializeBase.WritePrimitive(writer, birthday, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskUpdatePersonalZoneBirthday(birthday)
	return self:Invoke(63904758, SerializerHelper.AskUpdatePersonalZoneBirthday_Serializer, birthday)
end

function SerializerHelper.DonateFactionByMoney_Serializer(writer, factionid, money)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, money, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:DonateFactionByMoney(factionid, money)
	return self:Invoke(63906448, SerializerHelper.DonateFactionByMoney_Serializer, factionid, money)
end

function SerializerHelper.UnlockInvestigateGallery_Serializer(writer, galleryid, reason)
	SerializeBase.WritePrimitive(writer, galleryid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteInt32, 0)
end

function ClientToGameDelegate:UnlockInvestigateGallery(galleryid, reason)
	self:Notify(63907804, SerializerHelper.UnlockInvestigateGallery_Serializer, galleryid, reason)
end

function SerializerHelper.OnVehicleColliding_Serializer(writer)
	return
end

function ClientToGameDelegate:OnVehicleColliding()
	self:Notify(63908812, SerializerHelper.OnVehicleColliding_Serializer)
end

function SerializerHelper.AskHideMassArea_Serializer(writer, id, center, extends, hide, hidetype)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, center, SerializeAuto.WriteUXVector3, "center")
	SerializeBase.WriteStruct(writer, extends, SerializeAuto.WriteUXVector3, "extends")
	SerializeBase.WritePrimitive(writer, hide, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, hidetype, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskHideMassArea(id, center, extends, hide, hidetype)
	self:Notify(63914613, SerializerHelper.AskHideMassArea_Serializer, id, center, extends, hide, hidetype)
end

function SerializerHelper.AskDepositSpiritWeapon_Serializer(writer, spiritid, slotindex)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slotindex, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskDepositSpiritWeapon(spiritid, slotindex)
	return self:Invoke(63915981, SerializerHelper.AskDepositSpiritWeapon_Serializer, spiritid, slotindex)
end

function SerializerHelper.AskPublicSwitchToPublicScene_Serializer(writer, raidid, delay, mapentranceid)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, delay, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, mapentranceid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskPublicSwitchToPublicScene(raidid, delay, mapentranceid)
	return self:Invoke(63919736, SerializerHelper.AskPublicSwitchToPublicScene_Serializer, raidid, delay, mapentranceid)
end

function SerializerHelper.AskHotSpringUseTicket_Serializer(writer)
	return
end

function ClientToGameDelegate:AskHotSpringUseTicket()
	return self:Invoke(63920526, SerializerHelper.AskHotSpringUseTicket_Serializer)
end

function SerializerHelper.AskDivinerCheckSpecialEvent_Serializer(writer)
	return
end

function ClientToGameDelegate:AskDivinerCheckSpecialEvent()
	return self:Invoke(63921296, SerializerHelper.AskDivinerCheckSpecialEvent_Serializer)
end

function SerializerHelper.AskSetTraceMapEntrance_Serializer(writer, mapentranceid, name)
	SerializeBase.WritePrimitive(writer, mapentranceid, writer.WriteUInt32, 0)
	writer:WriteString(name, false, "name", 256)
end

function ClientToGameDelegate:AskSetTraceMapEntrance(mapentranceid, name)
	self:Notify(63924870, SerializerHelper.AskSetTraceMapEntrance_Serializer, mapentranceid, name)
end

function SerializerHelper.SyncChangeSafeArea_Serializer(writer, regionid)
	SerializeBase.WritePrimitive(writer, regionid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:SyncChangeSafeArea(regionid)
	self:Notify(63925146, SerializerHelper.SyncChangeSafeArea_Serializer, regionid)
end

function SerializerHelper.TryInteractVoice_Serializer(writer, npccultivationid, voiceid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, voiceid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:TryInteractVoice(npccultivationid, voiceid)
	self:Notify(63925923, SerializerHelper.TryInteractVoice_Serializer, npccultivationid, voiceid)
end

function SerializerHelper.AskGetMailsItem_Serializer(writer, mailids)
	SerializeBase.WriteList(writer, mailids, writer.WriteUInt64, 0, "mailids", false, 1024, nil)
end

function ClientToGameDelegate:AskGetMailsItem(mailids)
	return self:Invoke(63927190, SerializerHelper.AskGetMailsItem_Serializer, mailids)
end

function SerializerHelper.ChangePersonalTimeSetting_Serializer(writer, index, info)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WritePersonalTimeSetting, "info", true)
end

function ClientToGameDelegate:ChangePersonalTimeSetting(index, info)
	return self:Invoke(63933081, SerializerHelper.ChangePersonalTimeSetting_Serializer, index, info)
end

function SerializerHelper.GetMailHeadList_Serializer(writer)
	return
end

function ClientToGameDelegate:GetMailHeadList()
	return self:Invoke(63934517, SerializerHelper.GetMailHeadList_Serializer)
end

function SerializerHelper.VehicleDriveStateChange_Serializer(writer, state)
	SerializeBase.WritePrimitive(writer, state, writer.WriteByte, 0)
end

function ClientToGameDelegate:VehicleDriveStateChange(state)
	return self:Invoke(63939233, SerializerHelper.VehicleDriveStateChange_Serializer, state)
end

function SerializerHelper.CastVotes_Serializer(writer, sessionid, vote)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt64, 0)
	SerializeBase.WriteList(writer, vote, writer.WriteUInt32, 0, "vote", false, 256, nil)
end

function ClientToGameDelegate:CastVotes(sessionid, vote)
	return self:Invoke(63940657, SerializerHelper.CastVotes_Serializer, sessionid, vote)
end

function SerializerHelper.AskCancelInteractTuite_Serializer(writer, tuiteconfigid, interacttype)
	SerializeBase.WritePrimitive(writer, tuiteconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interacttype, writer.WriteByte, 0)
end

function ClientToGameDelegate:AskCancelInteractTuite(tuiteconfigid, interacttype)
	return self:Invoke(63942991, SerializerHelper.AskCancelInteractTuite_Serializer, tuiteconfigid, interacttype)
end

function SerializerHelper.AskAcceptTask_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskAcceptTask(taskid)
	return self:Invoke(63946088, SerializerHelper.AskAcceptTask_Serializer, taskid)
end

function SerializerHelper.AskBuyFerrisWheelTicket_Serializer(writer, tickettype, ferriswheelid)
	SerializeBase.WritePrimitive(writer, tickettype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, ferriswheelid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskBuyFerrisWheelTicket(tickettype, ferriswheelid)
	return self:Invoke(63946292, SerializerHelper.AskBuyFerrisWheelTicket_Serializer, tickettype, ferriswheelid)
end

function SerializerHelper.AskDestroyGangMember_Serializer(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskDestroyGangMember(templateid)
	return self:Invoke(63948993, SerializerHelper.AskDestroyGangMember_Serializer, templateid)
end

function SerializerHelper.AskOnNpcAttractedByBeg_Serializer(writer, count, total)
	SerializeBase.WritePrimitive(writer, count, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, total, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskOnNpcAttractedByBeg(count, total)
	self:Notify(63949043, SerializerHelper.AskOnNpcAttractedByBeg_Serializer, count, total)
end

function SerializerHelper.AskRemoveBuildHouseIndoor_Serializer(writer, houseid, floor, removeplacedinstanceidlist)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, removeplacedinstanceidlist, writer.WriteUInt64, 0, "removeplacedinstanceidlist", false, 256, nil)
end

function ClientToGameDelegate:AskRemoveBuildHouseIndoor(houseid, floor, removeplacedinstanceidlist)
	return self:Invoke(63951006, SerializerHelper.AskRemoveBuildHouseIndoor_Serializer, houseid, floor, removeplacedinstanceidlist)
end

function SerializerHelper.AskUseItems_Serializer(writer, uid, count)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskUseItems(uid, count)
	return self:Invoke(63951439, SerializerHelper.AskUseItems_Serializer, uid, count)
end

function SerializerHelper.AskConvertCommonSpiritTalentExp_Serializer(writer, spiritid, convertexp)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, convertexp, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskConvertCommonSpiritTalentExp(spiritid, convertexp)
	return self:Invoke(63951524, SerializerHelper.AskConvertCommonSpiritTalentExp_Serializer, spiritid, convertexp)
end

function SerializerHelper.AskSetAnimalInteractionId_Serializer(writer, animalid, interactionid)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interactionid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSetAnimalInteractionId(animalid, interactionid)
	return self:Invoke(63953543, SerializerHelper.AskSetAnimalInteractionId_Serializer, animalid, interactionid)
end

function SerializerHelper.AskResetSpiritJobTalent_Serializer(writer, spiritid, jobclassid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskResetSpiritJobTalent(spiritid, jobclassid)
	return self:Invoke(63955299, SerializerHelper.AskResetSpiritJobTalent_Serializer, spiritid, jobclassid)
end

function SerializerHelper.AskMallSetCommoditySpiritDisplayPreferences_Serializer(writer, spiritidlist)
	SerializeBase.WriteList(writer, spiritidlist, writer.WriteUInt32, 0, "spiritidlist", false, 256, nil)
end

function ClientToGameDelegate:AskMallSetCommoditySpiritDisplayPreferences(spiritidlist)
	return self:Invoke(63955808, SerializerHelper.AskMallSetCommoditySpiritDisplayPreferences_Serializer, spiritidlist)
end

function SerializerHelper.UpdateNgPushRegid_Serializer(writer, regid)
	writer:WriteString(regid, false, "regid", 256)
end

function ClientToGameDelegate:UpdateNgPushRegid(regid)
	self:Notify(63957411, SerializerHelper.UpdateNgPushRegid_Serializer, regid)
end

function SerializerHelper.AskItemBreakdown_Serializer(writer, breakdownid, iteminstanceid, count)
	SerializeBase.WriteList(writer, breakdownid, writer.WriteUInt32, 0, "breakdownid", false, 32, nil)
	SerializeBase.WriteList(writer, iteminstanceid, writer.WriteUInt64, 0, "iteminstanceid", false, 32, nil)
	SerializeBase.WriteList(writer, count, writer.WriteUInt32, 0, "count", false, 32, nil)
end

function ClientToGameDelegate:AskItemBreakdown(breakdownid, iteminstanceid, count)
	return self:Invoke(63957623, SerializerHelper.AskItemBreakdown_Serializer, breakdownid, iteminstanceid, count)
end

function SerializerHelper.ChatToNpc_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:ChatToNpc(chatid)
	return self:Invoke(63969573, SerializerHelper.ChatToNpc_Serializer, chatid)
end

function SerializerHelper.AskModifySpiritWearFashionsOnlyWear_Serializer(writer, spiritid, unwearfashionidlist, wearfashioninfolist)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, unwearfashionidlist, writer.WriteUInt32, 0, "unwearfashionidlist", true, 32, nil)
	SerializeBase.WriteList(writer, wearfashioninfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionInfo, "WearFashionInfo", true), nil, "wearfashioninfolist", true, 32, nil)
end

function ClientToGameDelegate:AskModifySpiritWearFashionsOnlyWear(spiritid, unwearfashionidlist, wearfashioninfolist)
	return self:Invoke(63969681, SerializerHelper.AskModifySpiritWearFashionsOnlyWear_Serializer, spiritid, unwearfashionidlist, wearfashioninfolist)
end

function SerializerHelper.LoginGame_Serializer(writer, pid, token)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer:WriteString(token, false, "token", 256)
end

function ClientToGameDelegate:LoginGame(pid, token)
	self:Notify(63969849, SerializerHelper.LoginGame_Serializer, pid, token)
end

function SerializerHelper.AskPublishNpcMoment_Serializer(writer, activitycfgid, isgroup, url, title)
	SerializeBase.WritePrimitive(writer, activitycfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isgroup, writer.WriteBoolean, false)
	writer:WriteString(url, false, "url", 256)
	writer:WriteString(title, true, "title", 256)
end

function ClientToGameDelegate:AskPublishNpcMoment(activitycfgid, isgroup, url, title)
	return self:Invoke(63970959, SerializerHelper.AskPublishNpcMoment_Serializer, activitycfgid, isgroup, url, title)
end

function SerializerHelper.ViewedEventPanel_Serializer(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:ViewedEventPanel(eventid)
	return self:Invoke(63971131, SerializerHelper.ViewedEventPanel_Serializer, eventid)
end

function SerializerHelper.AskApplyFashionColoringSchemeInfos_Serializer(writer, applyfashioncoloringschemeiddict)
	SerializeBase.WriteDict(writer, applyfashioncoloringschemeiddict, writer.WriteUInt32, writer.WriteByte, 0, "applyfashioncoloringschemeiddict", false, 32)
end

function ClientToGameDelegate:AskApplyFashionColoringSchemeInfos(applyfashioncoloringschemeiddict)
	return self:Invoke(63972375, SerializerHelper.AskApplyFashionColoringSchemeInfos_Serializer, applyfashioncoloringschemeiddict)
end

function SerializerHelper.AskStartGuideByClient_Serializer(writer, guideid, taskid)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskStartGuideByClient(guideid, taskid)
	return self:Invoke(63972499, SerializerHelper.AskStartGuideByClient_Serializer, guideid, taskid)
end

function SerializerHelper.AskMarkNpcChatRead_Serializer(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskMarkNpcChatRead(chatid)
	return self:Invoke(63979914, SerializerHelper.AskMarkNpcChatRead_Serializer, chatid)
end

function SerializerHelper.AskBartenderCustomerLeave_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameDelegate:AskBartenderCustomerLeave(id)
	return self:Invoke(63980222, SerializerHelper.AskBartenderCustomerLeave_Serializer, id)
end

function SerializerHelper.AskSetCurrentOrder_Serializer(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:AskSetCurrentOrder(orderid)
	return self:Invoke(63981476, SerializerHelper.AskSetCurrentOrder_Serializer, orderid)
end

function SerializerHelper.AskTeleportToHouseGarage_Serializer(writer, houseid, parkingspaceindex)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, parkingspaceindex, writer.WriteInt32, 0)
end

function ClientToGameDelegate:AskTeleportToHouseGarage(houseid, parkingspaceindex)
	return self:Invoke(63981686, SerializerHelper.AskTeleportToHouseGarage_Serializer, houseid, parkingspaceindex)
end

function SerializerHelper.FinishNewChallenge_Serializer(writer, challengeid, taskid)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameDelegate:FinishNewChallenge(challengeid, taskid)
	return self:Invoke(63982066, SerializerHelper.FinishNewChallenge_Serializer, challengeid, taskid)
end

function SerializerHelper.AskTriggerNpcQueuedEvent_Serializer(writer, id, ismanual)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ismanual, writer.WriteBoolean, false)
end

function ClientToGameDelegate:AskTriggerNpcQueuedEvent(id, ismanual)
	return self:Invoke(63987750, SerializerHelper.AskTriggerNpcQueuedEvent_Serializer, id, ismanual)
end

function SerializerHelper.GetCharacterRandomDialog_Serializer(writer, agentid, maintag, subtag)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maintag, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, subtag, writer.WriteUInt32, 0, "subtag", true, 32, nil)
end

function ClientToGameDelegate:GetCharacterRandomDialog(agentid, maintag, subtag)
	return self:Invoke(63989753, SerializerHelper.GetCharacterRandomDialog_Serializer, agentid, maintag, subtag)
end

function SerializerHelper.AskPersonalZoneUpdateSpiritList_Serializer(writer, infos)
	SerializeBase.WriteList(writer, infos, SerializeBase.WriteComplexWrap(SerializeAuto.WritePersonalZoneFightSpiritInfo, "PersonalZoneFightSpiritInfo", false), nil, "infos", false, 32, nil)
end

function ClientToGameDelegate:AskPersonalZoneUpdateSpiritList(infos)
	return self:Invoke(63991228, SerializerHelper.AskPersonalZoneUpdateSpiritList_Serializer, infos)
end

function SerializerHelper.AskSetTeamSetting_Serializer(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteTeamSetting, "setting", false)
end

function ClientToGameDelegate:AskSetTeamSetting(setting)
	return self:Invoke(63994070, SerializerHelper.AskSetTeamSetting_Serializer, setting)
end

function SerializerHelper.AskStartTruckOrderGuide_Serializer(writer)
	return
end

function ClientToGameDelegate:AskStartTruckOrderGuide()
	return self:Invoke(63998035, SerializerHelper.AskStartTruckOrderGuide_Serializer)
end

function SerializerHelper.AskMomentsPostInfos_Serializer(writer, postids)
	SerializeBase.WriteList(writer, postids, writer.WriteUInt32, 0, "postids", false, 32, nil)
end

function ClientToGameDelegate:AskMomentsPostInfos(postids)
	return self:Invoke(63998721, SerializerHelper.AskMomentsPostInfos_Serializer, postids)
end

return ClientToGameDelegate
