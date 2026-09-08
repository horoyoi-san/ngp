-- Original chunk: @Lua\LuaGen\AutoGen\ClientToGameDelegate.lua
-- Decompiled from: 00069_ClientToGameDelegate.lua_f7fd6ed698e3.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGameDelegate = invoker.New(invoker)

ClientToGameDelegate.Sender = function()
	return NetworkManager.LuaGameRpcProcessor
end

SerializerHelper.CastVotes_Serializer = function(writer, sessionid, vote)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, vote, writer.WriteUInt32, 0, "vote", false, RpcLengthLimits.IClientToGame_CastVotes_vote, nil)
end

ClientToGameDelegate.CastVotes = function(self, sessionid, vote)
	return self.Invoke(self, 63000944, SerializerHelper.CastVotes_Serializer, sessionid, vote)
end

SerializerHelper.AskStartDivinerGame_Serializer = function(writer, agententityid, agentname, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer.WriteString(writer, agentname, false, "AskStartDivinerGame.agentName", RpcLengthLimits.IClientToGame_AskStartDivinerGame_agentName)
	writer.WriteString(writer, lang, false, "AskStartDivinerGame.lang", RpcLengthLimits.IClientToGame_AskStartDivinerGame_lang)
end

ClientToGameDelegate.AskStartDivinerGame = function(self, agententityid, agentname, lang)
	return self.Invoke(self, 63005394, SerializerHelper.AskStartDivinerGame_Serializer, agententityid, agentname, lang)
end

SerializerHelper.AskApplyJoinClub_Serializer = function(writer, clubid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskApplyJoinClub = function(self, clubid)
	return self.Invoke(self, 63006959, SerializerHelper.AskApplyJoinClub_Serializer, clubid)
end

SerializerHelper.AskSkipDialog_Serializer = function(writer, dialogid, enddialogid, dialogids)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enddialogid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, dialogids, writer.WriteUInt32, 0, "dialogids", false, RpcLengthLimits.IClientToGame_AskSkipDialog_DialogIds, nil)
end

ClientToGameDelegate.AskSkipDialog = function(self, dialogid, enddialogid, dialogids)
	return self.Invoke(self, 63007235, SerializerHelper.AskSkipDialog_Serializer, dialogid, enddialogid, dialogids)
end

SerializerHelper.AskPlayerComplain_Serializer = function(writer, count)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPlayerComplain = function(self, count)
	self.Notify(self, 63007701, SerializerHelper.AskPlayerComplain_Serializer, count)
end

SerializerHelper.AskTamagotchiChangeItems_Serializer = function(writer, additems, removeitems)
	SerializeBase.WriteDict7Bit(writer, additems, writer.WriteUInt32, writer.WriteUInt32, 0, "additems", false, RpcLengthLimits.IClientToGame_AskTamagotchiChangeItems_addItems)
	SerializeBase.WriteDict7Bit(writer, removeitems, writer.WriteUInt32, writer.WriteUInt32, 0, "removeitems", false, RpcLengthLimits.IClientToGame_AskTamagotchiChangeItems_removeItems)
end

ClientToGameDelegate.AskTamagotchiChangeItems = function(self, additems, removeitems)
	return self.Invoke(self, 63008295, SerializerHelper.AskTamagotchiChangeItems_Serializer, additems, removeitems)
end

SerializerHelper.AskComputerEmailScrollToBottom_Serializer = function(writer, email)
	SerializeBase.WritePrimitive(writer, email, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskComputerEmailScrollToBottom = function(self, email)
	return self.Invoke(self, 63009552, SerializerHelper.AskComputerEmailScrollToBottom_Serializer, email)
end

SerializerHelper.AskExtractionShooterSortBags_Serializer = function(writer, bagconfigids)
	SerializeBase.WriteList7Bit(writer, bagconfigids, writer.WriteUInt32, 0, "bagconfigids", false, RpcLengthLimits.IClientToGame_AskExtractionShooterSortBags_bagConfigIds, nil)
end

ClientToGameDelegate.AskExtractionShooterSortBags = function(self, bagconfigids)
	return self.Invoke(self, 63009939, SerializerHelper.AskExtractionShooterSortBags_Serializer, bagconfigids)
end

SerializerHelper.AskForceFinishDialog_Serializer = function(writer)
end

ClientToGameDelegate.AskForceFinishDialog = function(self)
	return self.Invoke(self, 63010951, SerializerHelper.AskForceFinishDialog_Serializer)
end

SerializerHelper.ChatToNpc_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.ChatToNpc = function(self, chatid)
	return self.Invoke(self, 63013781, SerializerHelper.ChatToNpc_Serializer, chatid)
end

SerializerHelper.AskFinishTaskCounter_Serializer = function(writer, taskid, counterindex)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counterindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskFinishTaskCounter = function(self, taskid, counterindex)
	return self.Invoke(self, 63015577, SerializerHelper.AskFinishTaskCounter_Serializer, taskid, counterindex)
end

SerializerHelper.AskTakeCompetitionSeasonHighestRankReward_Serializer = function(writer, rewardid)
	SerializeBase.WritePrimitive(writer, rewardid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeCompetitionSeasonHighestRankReward = function(self, rewardid)
	return self.Invoke(self, 63015722, SerializerHelper.AskTakeCompetitionSeasonHighestRankReward_Serializer, rewardid)
end

SerializerHelper.AskStartGymExercise_Serializer = function(writer, exerciseid)
	SerializeBase.WritePrimitive(writer, exerciseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartGymExercise = function(self, exerciseid)
	self.Notify(self, 63016555, SerializerHelper.AskStartGymExercise_Serializer, exerciseid)
end

SerializerHelper.AskChangeBuildHouseIndoor_Serializer = function(writer, houseid, floor, changeplacedfurnitureinfo)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, changeplacedfurnitureinfo, SerializeAuto.WriteChangePlacedFurnitureInfo, "changeplacedfurnitureinfo")
end

ClientToGameDelegate.AskChangeBuildHouseIndoor = function(self, houseid, floor, changeplacedfurnitureinfo)
	return self.Invoke(self, 63017136, SerializerHelper.AskChangeBuildHouseIndoor_Serializer, houseid, floor, changeplacedfurnitureinfo)
end

SerializerHelper.RpcUpdatePlayerCollectionItemInfo_Serializer = function(writer, boothid, slot, info)
	SerializeBase.WritePrimitive(writer, boothid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slot, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WritePlayerCollectionItemInfo, "info", true)
end

ClientToGameDelegate.RpcUpdatePlayerCollectionItemInfo = function(self, boothid, slot, info)
	return self.Invoke(self, 63017998, SerializerHelper.RpcUpdatePlayerCollectionItemInfo_Serializer, boothid, slot, info)
end

SerializerHelper.AskApplyJoinPrivateLink_Serializer = function(writer, linkid)
	SerializeBase.WritePrimitive(writer, linkid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskApplyJoinPrivateLink = function(self, linkid)
	return self.Invoke(self, 63018343, SerializerHelper.AskApplyJoinPrivateLink_Serializer, linkid)
end

SerializerHelper.AskClubCreateCustomJob_Serializer = function(writer, jobname)
	writer.WriteString(writer, jobname, false, "AskClubCreateCustomJob.jobName", RpcLengthLimits.IClientToGame_AskClubCreateCustomJob_jobName)
end

ClientToGameDelegate.AskClubCreateCustomJob = function(self, jobname)
	return self.Invoke(self, 63021593, SerializerHelper.AskClubCreateCustomJob_Serializer, jobname)
end

SerializerHelper.AskItemBreakdown_Serializer = function(writer, breakdownid, iteminstanceid, count)
	SerializeBase.WriteList7Bit(writer, breakdownid, writer.WriteUInt32, 0, "breakdownid", false, RpcLengthLimits.IClientToGame_AskItemBreakdown_breakdownId, nil)
	SerializeBase.WriteList7Bit(writer, iteminstanceid, writer.WriteUInt64, 0, "iteminstanceid", false, RpcLengthLimits.IClientToGame_AskItemBreakdown_itemInstanceId, nil)
	SerializeBase.WriteList7Bit(writer, count, writer.WriteUInt32, 0, "count", false, RpcLengthLimits.IClientToGame_AskItemBreakdown_count, nil)
end

ClientToGameDelegate.AskItemBreakdown = function(self, breakdownid, iteminstanceid, count)
	return self.Invoke(self, 63021682, SerializerHelper.AskItemBreakdown_Serializer, breakdownid, iteminstanceid, count)
end

SerializerHelper.ImageModeration_Serializer = function(writer, objectkey)
	writer.WriteString(writer, objectkey, false, "ImageModeration.objectKey", RpcLengthLimits.IClientToGame_ImageModeration_objectKey)
end

ClientToGameDelegate.ImageModeration = function(self, objectkey)
	return self.Invoke(self, 63022673, SerializerHelper.ImageModeration_Serializer, objectkey)
end

SerializerHelper.AskMomentsTapPostWithCount_Serializer = function(writer, postid, emojilist)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, emojilist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteEmojiData, "EmojiData", false), nil, "emojilist", false, RpcLengthLimits.IClientToGame_AskMomentsTapPostWithCount_emojiList, nil)
end

ClientToGameDelegate.AskMomentsTapPostWithCount = function(self, postid, emojilist)
	return self.Invoke(self, 63024597, SerializerHelper.AskMomentsTapPostWithCount_Serializer, postid, emojilist)
end

SerializerHelper.ReportKTVEvent_Serializer = function(writer, timing)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(timing, 4, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.ReportKTVEvent = function(self, timing)
	self.Notify(self, 63025527, SerializerHelper.ReportKTVEvent_Serializer, timing)
end

SerializerHelper.AskClubResignCustomJob_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskClubResignCustomJob = function(self, pid)
	return self.Invoke(self, 63025869, SerializerHelper.AskClubResignCustomJob_Serializer, pid)
end

SerializerHelper.AskReportTuiteDetailOpened_Serializer = function(writer, tuiteid)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskReportTuiteDetailOpened = function(self, tuiteid)
	return self.Invoke(self, 63029158, SerializerHelper.AskReportTuiteDetailOpened_Serializer, tuiteid)
end

SerializerHelper.AskConfirmDutySwap_Serializer = function(writer, sourcepid, accept)
	SerializeBase.WritePrimitive(writer, sourcepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskConfirmDutySwap = function(self, sourcepid, accept)
	return self.Invoke(self, 63029245, SerializerHelper.AskConfirmDutySwap_Serializer, sourcepid, accept)
end

SerializerHelper.ExitAbnormalTagLink_Serializer = function(writer)
end

ClientToGameDelegate.ExitAbnormalTagLink = function(self)
	return self.Invoke(self, 63029573, SerializerHelper.ExitAbnormalTagLink_Serializer)
end

SerializerHelper.AskSellCommodityToShop_Serializer = function(writer, shopid, commodityid, count)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSellCommodityToShop = function(self, shopid, commodityid, count)
	return self.Invoke(self, 63030714, SerializerHelper.AskSellCommodityToShop_Serializer, shopid, commodityid, count)
end

SerializerHelper.AskUnlockFashionColoringSlot_Serializer = function(writer, fashionid, unlockslotcount)
	SerializeBase.WritePrimitive(writer, fashionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlockslotcount, writer.WriteByte, 0)
end

ClientToGameDelegate.AskUnlockFashionColoringSlot = function(self, fashionid, unlockslotcount)
	return self.Invoke(self, 63030977, SerializerHelper.AskUnlockFashionColoringSlot_Serializer, fashionid, unlockslotcount)
end

SerializerHelper.ReportPreTeleportFinish_Serializer = function(writer, teleportid)
	SerializeBase.WritePrimitive(writer, teleportid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.ReportPreTeleportFinish = function(self, teleportid)
	return self.Invoke(self, 63032762, SerializerHelper.ReportPreTeleportFinish_Serializer, teleportid)
end

SerializerHelper.AskReceiveFansStageLvReward_Serializer = function(writer, endorsementid)
	SerializeBase.WritePrimitive(writer, endorsementid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskReceiveFansStageLvReward = function(self, endorsementid)
	return self.Invoke(self, 63034204, SerializerHelper.AskReceiveFansStageLvReward_Serializer, endorsementid)
end

SerializerHelper.AskAcceptHackerPostTask_Serializer = function(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskAcceptHackerPostTask = function(self, postid)
	return self.Invoke(self, 63036377, SerializerHelper.AskAcceptHackerPostTask_Serializer, postid)
end

SerializerHelper.CompleteBeggarAiPainting_Serializer = function(writer, objectkey, name, isaipolished)
	writer.WriteString(writer, objectkey, false, "CompleteBeggarAiPainting.objectKey", RpcLengthLimits.IClientToGame_CompleteBeggarAiPainting_objectKey)
	writer.WriteString(writer, name, false, "CompleteBeggarAiPainting.name", RpcLengthLimits.IClientToGame_CompleteBeggarAiPainting_name)
	SerializeBase.WritePrimitive(writer, isaipolished, writer.WriteBoolean, false)
end

ClientToGameDelegate.CompleteBeggarAiPainting = function(self, objectkey, name, isaipolished)
	return self.Invoke(self, 63037231, SerializerHelper.CompleteBeggarAiPainting_Serializer, objectkey, name, isaipolished)
end

SerializerHelper.Peng_Serializer = function(writer, selectpais)
	SerializeBase.WriteList7Bit(writer, selectpais, SerializeBase.WriteStructWrap(SerializeAuto.WriteMjPaiInfo, "selectpais"), nil, "selectpais", false, RpcLengthLimits.IClientToGame_Peng_selectPais, nil)
end

ClientToGameDelegate.Peng = function(self, selectpais)
	self.Notify(self, 63037703, SerializerHelper.Peng_Serializer, selectpais)
end

SerializerHelper.AskBestRankByMainType_Serializer = function(writer, pid, rankmaintype)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, rankmaintype, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBestRankByMainType = function(self, pid, rankmaintype)
	return self.Invoke(self, 63038472, SerializerHelper.AskBestRankByMainType_Serializer, pid, rankmaintype)
end

SerializerHelper.AskFinishWushuTournamentRound_Serializer = function(writer, roundid, starresults)
	SerializeBase.WritePrimitive(writer, roundid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, starresults, writer.WriteBoolean, false, "starresults", false, RpcLengthLimits.IClientToGame_AskFinishWushuTournamentRound_starResults, nil)
end

ClientToGameDelegate.AskFinishWushuTournamentRound = function(self, roundid, starresults)
	return self.Invoke(self, 63038501, SerializerHelper.AskFinishWushuTournamentRound_Serializer, roundid, starresults)
end

SerializerHelper.AskPanelOpenOrClose_Serializer = function(writer, panelid, isopen)
	SerializeBase.WritePrimitive(writer, panelid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isopen, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskPanelOpenOrClose = function(self, panelid, isopen)
	return self.Invoke(self, 63038633, SerializerHelper.AskPanelOpenOrClose_Serializer, panelid, isopen)
end

SerializerHelper.AskModifySpiritCustomSuitSchemeName_Serializer = function(writer, spiritid, schemeindex, schemename)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, schemeindex, writer.WriteInt32, 0)
	writer.WriteString(writer, schemename, false, "AskModifySpiritCustomSuitSchemeName.schemeName", RpcLengthLimits.IClientToGame_AskModifySpiritCustomSuitSchemeName_schemeName)
end

ClientToGameDelegate.AskModifySpiritCustomSuitSchemeName = function(self, spiritid, schemeindex, schemename)
	return self.Invoke(self, 63039743, SerializerHelper.AskModifySpiritCustomSuitSchemeName_Serializer, spiritid, schemeindex, schemename)
end

SerializerHelper.AskSetTeamSetting_Serializer = function(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteTeamSetting, "setting", false)
end

ClientToGameDelegate.AskSetTeamSetting = function(self, setting)
	return self.Invoke(self, 63040238, SerializerHelper.AskSetTeamSetting_Serializer, setting)
end

SerializerHelper.AskSetSpiritFunctionSuitSchemeInfo_Serializer = function(writer, spiritid, functionsuitid, isbatch, functionsuitschemeinfo)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, functionsuitid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isbatch, writer.WriteBoolean, false)
	SerializeBase.WriteComplex(writer, functionsuitschemeinfo, SerializeAuto.WriteFashionFunctionSuitSchemeInfo, "functionsuitschemeinfo", false)
end

ClientToGameDelegate.AskSetSpiritFunctionSuitSchemeInfo = function(self, spiritid, functionsuitid, isbatch, functionsuitschemeinfo)
	return self.Invoke(self, 63040765, SerializerHelper.AskSetSpiritFunctionSuitSchemeInfo_Serializer, spiritid, functionsuitid, isbatch, functionsuitschemeinfo)
end

SerializerHelper.AskGetComputerUnlockInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskGetComputerUnlockInfo = function(self)
	return self.Invoke(self, 63041490, SerializerHelper.AskGetComputerUnlockInfo_Serializer)
end

SerializerHelper.CastVote_Serializer = function(writer, sessionid, vote)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, vote, writer.WriteUInt32, 0)
end

ClientToGameDelegate.CastVote = function(self, sessionid, vote)
	return self.Invoke(self, 63042598, SerializerHelper.CastVote_Serializer, sessionid, vote)
end

SerializerHelper.AskTeamRoomInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskTeamRoomInfo = function(self)
	return self.Invoke(self, 63043676, SerializerHelper.AskTeamRoomInfo_Serializer)
end

SerializerHelper.AskApplyFashionColoringSchemeInfos_Serializer = function(writer, applyfashioncoloringschemeiddict)
	SerializeBase.WriteDict7Bit(writer, applyfashioncoloringschemeiddict, writer.WriteUInt32, writer.WriteByte, 0, "applyfashioncoloringschemeiddict", false, RpcLengthLimits.IClientToGame_AskApplyFashionColoringSchemeInfos_applyFashionColoringSchemeIdDict)
end

ClientToGameDelegate.AskApplyFashionColoringSchemeInfos = function(self, applyfashioncoloringschemeiddict)
	return self.Invoke(self, 63045354, SerializerHelper.AskApplyFashionColoringSchemeInfos_Serializer, applyfashioncoloringschemeiddict)
end

SerializerHelper.AskStartSingleGame_Serializer = function(writer, gameid, difficulty)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, difficulty, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartSingleGame = function(self, gameid, difficulty)
	return self.Invoke(self, 63045972, SerializerHelper.AskStartSingleGame_Serializer, gameid, difficulty)
end

SerializerHelper.AskStartDivinerGameWithDemand_Serializer = function(writer, agententityid, agentname, demandcfgid, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer.WriteString(writer, agentname, false, "AskStartDivinerGameWithDemand.agentName", RpcLengthLimits.IClientToGame_AskStartDivinerGameWithDemand_agentName)
	SerializeBase.WritePrimitive(writer, demandcfgid, writer.WriteUInt32, 0)
	writer.WriteString(writer, lang, false, "AskStartDivinerGameWithDemand.lang", RpcLengthLimits.IClientToGame_AskStartDivinerGameWithDemand_lang)
end

ClientToGameDelegate.AskStartDivinerGameWithDemand = function(self, agententityid, agentname, demandcfgid, lang)
	return self.Invoke(self, 63048883, SerializerHelper.AskStartDivinerGameWithDemand_Serializer, agententityid, agentname, demandcfgid, lang)
end

SerializerHelper.AskDivinerChooseBranch_Serializer = function(writer, agententityid, branchid, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, branchid, writer.WriteUInt32, 0)
	writer.WriteString(writer, lang, false, "AskDivinerChooseBranch.lang", RpcLengthLimits.IClientToGame_AskDivinerChooseBranch_lang)
end

ClientToGameDelegate.AskDivinerChooseBranch = function(self, agententityid, branchid, lang)
	return self.Invoke(self, 63048906, SerializerHelper.AskDivinerChooseBranch_Serializer, agententityid, branchid, lang)
end

SerializerHelper.AskHotSpringInviteCompanionNpc_Serializer = function(writer, npc)
	SerializeBase.WritePrimitive(writer, npc, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskHotSpringInviteCompanionNpc = function(self, npc)
	return self.Invoke(self, 63052900, SerializerHelper.AskHotSpringInviteCompanionNpc_Serializer, npc)
end

SerializerHelper.AskEquipBasketballAppearance_Serializer = function(writer, appearanceid)
	SerializeBase.WritePrimitive(writer, appearanceid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskEquipBasketballAppearance = function(self, appearanceid)
	return self.Invoke(self, 63052927, SerializerHelper.AskEquipBasketballAppearance_Serializer, appearanceid)
end

SerializerHelper.AskPlayGameAgain_Serializer = function(writer, playagain, nextgame, rematch)
	SerializeBase.WritePrimitive(writer, playagain, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, nextgame, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, rematch, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskPlayGameAgain = function(self, playagain, nextgame, rematch)
	return self.Invoke(self, 63053503, SerializerHelper.AskPlayGameAgain_Serializer, playagain, nextgame, rematch)
end

SerializerHelper.GetLastMode_Serializer = function(writer)
end

ClientToGameDelegate.GetLastMode = function(self)
	return self.Invoke(self, 63053629, SerializerHelper.GetLastMode_Serializer)
end

SerializerHelper.AskOpenOrCloseFashionPanel_Serializer = function(writer, isopen, reason)
	SerializeBase.WritePrimitive(writer, isopen, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(reason, 5, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskOpenOrCloseFashionPanel = function(self, isopen, reason)
	return self.Invoke(self, 63054165, SerializerHelper.AskOpenOrCloseFashionPanel_Serializer, isopen, reason)
end

SerializerHelper.AskUnequipBasketballAppearance_Serializer = function(writer, slot)
	SerializeBase.WritePrimitive(writer, slot, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUnequipBasketballAppearance = function(self, slot)
	return self.Invoke(self, 63056021, SerializerHelper.AskUnequipBasketballAppearance_Serializer, slot)
end

SerializerHelper.AskPoliceFakeFileAcceptTaskEvent_Serializer = function(writer, fakefileid)
	SerializeBase.WritePrimitive(writer, fakefileid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPoliceFakeFileAcceptTaskEvent = function(self, fakefileid)
	return self.Invoke(self, 63056330, SerializerHelper.AskPoliceFakeFileAcceptTaskEvent_Serializer, fakefileid)
end

SerializerHelper.AskFarmerShopRestockItem_Serializer = function(writer, shelfindex, count)
	SerializeBase.WritePrimitive(writer, shelfindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFarmerShopRestockItem = function(self, shelfindex, count)
	return self.Invoke(self, 63056368, SerializerHelper.AskFarmerShopRestockItem_Serializer, shelfindex, count)
end

SerializerHelper.AskPoliceStopHelicopterDispatch_Serializer = function(writer)
end

ClientToGameDelegate.AskPoliceStopHelicopterDispatch = function(self)
	return self.Invoke(self, 63057829, SerializerHelper.AskPoliceStopHelicopterDispatch_Serializer)
end

SerializerHelper.ChangePartyRoomSetting_Serializer = function(writer, param)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteCustomRoomSettingParam, "param", false)
end

ClientToGameDelegate.ChangePartyRoomSetting = function(self, param)
	return self.Invoke(self, 63058182, SerializerHelper.ChangePartyRoomSetting_Serializer, param)
end

SerializerHelper.AskEnterRaidRandomEvent_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskEnterRaidRandomEvent = function(self, eventid)
	self.Notify(self, 63058481, SerializerHelper.AskEnterRaidRandomEvent_Serializer, eventid)
end

SerializerHelper.AskQueryClubHonors_Serializer = function(writer)
end

ClientToGameDelegate.AskQueryClubHonors = function(self)
	return self.Invoke(self, 63060427, SerializerHelper.AskQueryClubHonors_Serializer)
end

SerializerHelper.AskTakeCompetitionSeasonAllRankRewards_Serializer = function(writer)
end

ClientToGameDelegate.AskTakeCompetitionSeasonAllRankRewards = function(self)
	return self.Invoke(self, 63060786, SerializerHelper.AskTakeCompetitionSeasonAllRankRewards_Serializer)
end

SerializerHelper.AskSetCurrentOrder_Serializer = function(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSetCurrentOrder = function(self, orderid)
	return self.Invoke(self, 63061039, SerializerHelper.AskSetCurrentOrder_Serializer, orderid)
end

SerializerHelper.AskSaveHouseConfiguration_Serializer = function(writer, configurationinfo)
	SerializeBase.WriteComplex(writer, configurationinfo, SerializeAuto.WritePlayerHouseConfiguration, "configurationinfo", false)
end

ClientToGameDelegate.AskSaveHouseConfiguration = function(self, configurationinfo)
	return self.Invoke(self, 63064319, SerializerHelper.AskSaveHouseConfiguration_Serializer, configurationinfo)
end

SerializerHelper.AskDirectionalEnchant_Serializer = function(writer, weaponinstanceid, slotindex)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, slotindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskDirectionalEnchant = function(self, weaponinstanceid, slotindex)
	return self.Invoke(self, 63067823, SerializerHelper.AskDirectionalEnchant_Serializer, weaponinstanceid, slotindex)
end

SerializerHelper.RpcCollectionBookUpgrade_Serializer = function(writer, target, materialcells)
	SerializeBase.WriteComplex(writer, target, SerializeAuto.WriteExtractionShooterCellPos, "target", false)
	SerializeBase.WriteList7Bit(writer, materialcells, SerializeBase.WriteComplexWrap(SerializeAuto.WriteExtractionShooterCellPos, "ExtractionShooterCellPos", false), nil, "materialcells", false, RpcLengthLimits.IClientToGame_RpcCollectionBookUpgrade_materialCells, nil)
end

ClientToGameDelegate.RpcCollectionBookUpgrade = function(self, target, materialcells)
	return self.Invoke(self, 63068487, SerializerHelper.RpcCollectionBookUpgrade_Serializer, target, materialcells)
end

SerializerHelper.AskSetWeaponFightStyle_Serializer = function(writer, weaponinstanceid, fightstyleid)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, fightstyleid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSetWeaponFightStyle = function(self, weaponinstanceid, fightstyleid)
	return self.Invoke(self, 63069077, SerializerHelper.AskSetWeaponFightStyle_Serializer, weaponinstanceid, fightstyleid)
end

SerializerHelper.AskMomentsShareCustomPost_Serializer = function(writer, url, title)
	writer.WriteString(writer, url, false, "AskMomentsShareCustomPost.url", RpcLengthLimits.IClientToGame_AskMomentsShareCustomPost_url)
	writer.WriteString(writer, title, true, "AskMomentsShareCustomPost.title", RpcLengthLimits.IClientToGame_AskMomentsShareCustomPost_title)
end

ClientToGameDelegate.AskMomentsShareCustomPost = function(self, url, title)
	return self.Invoke(self, 63069828, SerializerHelper.AskMomentsShareCustomPost_Serializer, url, title)
end

SerializerHelper.AskManualRefreshSell_Serializer = function(writer, shopid)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskManualRefreshSell = function(self, shopid)
	return self.Invoke(self, 63070871, SerializerHelper.AskManualRefreshSell_Serializer, shopid)
end

SerializerHelper.AskRefreshTruckOrder_Serializer = function(writer)
end

ClientToGameDelegate.AskRefreshTruckOrder = function(self)
	return self.Invoke(self, 63071191, SerializerHelper.AskRefreshTruckOrder_Serializer)
end

SerializerHelper.AskItemCountRecord_Serializer = function(writer, itemid)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskItemCountRecord = function(self, itemid)
	return self.Invoke(self, 63072043, SerializerHelper.AskItemCountRecord_Serializer, itemid)
end

SerializerHelper.SetChallengeStatisticalData_Serializer = function(writer, taskid, score, statisticaldata)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteInt32, 0)
	SerializeBase.WriteDict7Bit(writer, statisticaldata, writer.WriteInt32, writer.WriteDouble, 0, "statisticaldata", true, RpcLengthLimits.IClientToGame_SetChallengeStatisticalData_statisticalData)
end

ClientToGameDelegate.SetChallengeStatisticalData = function(self, taskid, score, statisticaldata)
	return self.Invoke(self, 63072173, SerializerHelper.SetChallengeStatisticalData_Serializer, taskid, score, statisticaldata)
end

SerializerHelper.AskStartPlayerInteractionAction_Serializer = function(writer)
end

ClientToGameDelegate.AskStartPlayerInteractionAction = function(self)
	return self.Invoke(self, 63072342, SerializerHelper.AskStartPlayerInteractionAction_Serializer)
end

SerializerHelper.AskDeleteMail_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskDeleteMail = function(self, id)
	return self.Invoke(self, 63073632, SerializerHelper.AskDeleteMail_Serializer, id)
end

SerializerHelper.AskHotSpringUseTicket_Serializer = function(writer)
end

ClientToGameDelegate.AskHotSpringUseTicket = function(self)
	return self.Invoke(self, 63073900, SerializerHelper.AskHotSpringUseTicket_Serializer)
end

SerializerHelper.AskAddTruckOrderSpecialPointRewards_Serializer = function(writer, orderids, pointid)
	SerializeBase.WriteList7Bit(writer, orderids, writer.WriteUInt32, 0, "orderids", false, RpcLengthLimits.IClientToGame_AskAddTruckOrderSpecialPointRewards_orderIds, nil)
	SerializeBase.WritePrimitive(writer, pointid, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskAddTruckOrderSpecialPointRewards = function(self, orderids, pointid)
	return self.Invoke(self, 63076643, SerializerHelper.AskAddTruckOrderSpecialPointRewards_Serializer, orderids, pointid)
end

SerializerHelper.AskGetNpcGroupPhotos_Serializer = function(writer, publisher, includesamenpc)
	SerializeBase.WritePrimitive(writer, publisher, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, includesamenpc, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskGetNpcGroupPhotos = function(self, publisher, includesamenpc)
	return self.Invoke(self, 63081738, SerializerHelper.AskGetNpcGroupPhotos_Serializer, publisher, includesamenpc)
end

SerializerHelper.SendCustomCommonDataClientToGame_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToGameDelegate.SendCustomCommonDataClientToGame = function(self, data)
	return self.Invoke(self, 63081866, SerializerHelper.SendCustomCommonDataClientToGame_Serializer, data)
end

SerializerHelper.RequestNpcChatList_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.RequestNpcChatList = function(self, chatid)
	return self.Invoke(self, 63082065, SerializerHelper.RequestNpcChatList_Serializer, chatid)
end

SerializerHelper.AskQueryPlayerUnlockAvatarFrame_Serializer = function(writer)
end

ClientToGameDelegate.AskQueryPlayerUnlockAvatarFrame = function(self)
	return self.Invoke(self, 63082163, SerializerHelper.AskQueryPlayerUnlockAvatarFrame_Serializer)
end

SerializerHelper.AskPlayerFarmerWater_Serializer = function(writer, landidlist)
	SerializeBase.WriteList7Bit(writer, landidlist, writer.WriteInt32, 0, "landidlist", false, RpcLengthLimits.IClientToGame_AskPlayerFarmerWater_landIdList, nil)
end

ClientToGameDelegate.AskPlayerFarmerWater = function(self, landidlist)
	self.Notify(self, 63083006, SerializerHelper.AskPlayerFarmerWater_Serializer, landidlist)
end

SerializerHelper.AskGetNewCustomTuiteId_Serializer = function(writer)
end

ClientToGameDelegate.AskGetNewCustomTuiteId = function(self)
	return self.Invoke(self, 63083730, SerializerHelper.AskGetNewCustomTuiteId_Serializer)
end

SerializerHelper.AskMiniGame_BeeSettlement_Serializer = function(writer)
end

ClientToGameDelegate.AskMiniGame_BeeSettlement = function(self)
	self.Notify(self, 63084657, SerializerHelper.AskMiniGame_BeeSettlement_Serializer)
end

SerializerHelper.GetCurrentMultiPlayerId_Serializer = function(writer)
end

ClientToGameDelegate.GetCurrentMultiPlayerId = function(self)
	return self.Invoke(self, 63084658, SerializerHelper.GetCurrentMultiPlayerId_Serializer)
end

SerializerHelper.StartUgcMapTest_Serializer = function(writer, mapid)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.StartUgcMapTest = function(self, mapid)
	return self.Invoke(self, 63086313, SerializerHelper.StartUgcMapTest_Serializer, mapid)
end

SerializerHelper.AskChangeNameByItem_Serializer = function(writer, name)
	writer.WriteString(writer, name, false, "AskChangeNameByItem.name", RpcLengthLimits.IClientToGame_AskChangeNameByItem_name)
end

ClientToGameDelegate.AskChangeNameByItem = function(self, name)
	return self.Invoke(self, 63087020, SerializerHelper.AskChangeNameByItem_Serializer, name)
end

SerializerHelper.AskClaimAllBattlePassReward_Serializer = function(writer, bpid)
	SerializeBase.WritePrimitive(writer, bpid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskClaimAllBattlePassReward = function(self, bpid)
	return self.Invoke(self, 63088039, SerializerHelper.AskClaimAllBattlePassReward_Serializer, bpid)
end

SerializerHelper.AskChangePlayerScenarioSlot_Serializer = function(writer, slot)
	SerializeBase.WritePrimitive(writer, slot, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskChangePlayerScenarioSlot = function(self, slot)
	return self.Invoke(self, 63088205, SerializerHelper.AskChangePlayerScenarioSlot_Serializer, slot)
end

SerializerHelper.AskLeaveGame_Serializer = function(writer, punish, autorematch)
	SerializeBase.WritePrimitive(writer, punish, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, autorematch, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskLeaveGame = function(self, punish, autorematch)
	return self.Invoke(self, 63088539, SerializerHelper.AskLeaveGame_Serializer, punish, autorematch)
end

SerializerHelper.AskGetAISessionBasicInfo_Serializer = function(writer, sessiontype, sessionid)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sessiontype, 6, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskGetAISessionBasicInfo = function(self, sessiontype, sessionid)
	return self.Invoke(self, 63088845, SerializerHelper.AskGetAISessionBasicInfo_Serializer, sessiontype, sessionid)
end

SerializerHelper.AskRemoveClubApplication_Serializer = function(writer, clubid, memberpid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskRemoveClubApplication = function(self, clubid, memberpid)
	return self.Invoke(self, 63089504, SerializerHelper.AskRemoveClubApplication_Serializer, clubid, memberpid)
end

SerializerHelper.UpdateNgPushSetting_Serializer = function(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteNgpushSetting, "setting", false)
end

ClientToGameDelegate.UpdateNgPushSetting = function(self, setting)
	self.Notify(self, 63089654, SerializerHelper.UpdateNgPushSetting_Serializer, setting)
end

SerializerHelper.AskGetMailsItem_Serializer = function(writer, mailids)
	SerializeBase.WriteList7Bit(writer, mailids, writer.WriteUInt64, 0, "mailids", false, RpcLengthLimits.IClientToGame_AskGetMailsItem_mailIds, nil)
end

ClientToGameDelegate.AskGetMailsItem = function(self, mailids)
	return self.Invoke(self, 63091483, SerializerHelper.AskGetMailsItem_Serializer, mailids)
end

SerializerHelper.AskMallBuyCommodity_Serializer = function(writer, commodityid, buycnt, isautoexchange)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buycnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isautoexchange, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskMallBuyCommodity = function(self, commodityid, buycnt, isautoexchange)
	return self.Invoke(self, 63091872, SerializerHelper.AskMallBuyCommodity_Serializer, commodityid, buycnt, isautoexchange)
end

SerializerHelper.AskYachtLogoUploadUrl_Serializer = function(writer)
end

ClientToGameDelegate.AskYachtLogoUploadUrl = function(self)
	return self.Invoke(self, 63091905, SerializerHelper.AskYachtLogoUploadUrl_Serializer)
end

SerializerHelper.StartNewChallenge_Serializer = function(writer, challengeid)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.StartNewChallenge = function(self, challengeid)
	return self.Invoke(self, 63092905, SerializerHelper.StartNewChallenge_Serializer, challengeid)
end

SerializerHelper.AskGetPersonalZoneRedSpot_Serializer = function(writer, type)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 7, 1), writer.WriteByte, 1)
end

ClientToGameDelegate.AskGetPersonalZoneRedSpot = function(self, type)
	return self.Invoke(self, 63093688, SerializerHelper.AskGetPersonalZoneRedSpot_Serializer, type)
end

SerializerHelper.AskGetBeLikeCount_Serializer = function(writer)
end

ClientToGameDelegate.AskGetBeLikeCount = function(self)
	return self.Invoke(self, 63094650, SerializerHelper.AskGetBeLikeCount_Serializer)
end

SerializerHelper.AskOCCreateGrandpa_Serializer = function(writer, generateocinfo)
	SerializeBase.WriteComplex(writer, generateocinfo, SerializeAuto.WriteOCGenerateInfo, "generateocinfo", false)
end

ClientToGameDelegate.AskOCCreateGrandpa = function(self, generateocinfo)
	return self.Invoke(self, 63094834, SerializerHelper.AskOCCreateGrandpa_Serializer, generateocinfo)
end

SerializerHelper.FollowTeamLeader_Serializer = function(writer)
end

ClientToGameDelegate.FollowTeamLeader = function(self)
	return self.Invoke(self, 63096148, SerializerHelper.FollowTeamLeader_Serializer)
end

SerializerHelper.AskPlanningBoardSelectStepOption_Serializer = function(writer, stepid, optionindex)
	SerializeBase.WritePrimitive(writer, stepid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, optionindex, writer.WriteByte, 0)
end

ClientToGameDelegate.AskPlanningBoardSelectStepOption = function(self, stepid, optionindex)
	return self.Invoke(self, 63096463, SerializerHelper.AskPlanningBoardSelectStepOption_Serializer, stepid, optionindex)
end

SerializerHelper.AskQueryPlayerUnlockNameEffect_Serializer = function(writer)
end

ClientToGameDelegate.AskQueryPlayerUnlockNameEffect = function(self)
	return self.Invoke(self, 63096878, SerializerHelper.AskQueryPlayerUnlockNameEffect_Serializer)
end

SerializerHelper.AskModifySpiritWearFashions_Serializer = function(writer, spiritid, unwearfashionidlist, wearfashioninfolist, uneditwearfashionidlist, editwearfashioneditinfolist)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, unwearfashionidlist, writer.WriteUInt32, 0, "unwearfashionidlist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashions_unwearFashionIdList, nil)
	SerializeBase.WriteList7Bit(writer, wearfashioninfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionInfo, "WearFashionInfo", true), nil, "wearfashioninfolist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashions_wearFashionInfoList, nil)
	SerializeBase.WriteList7Bit(writer, uneditwearfashionidlist, writer.WriteUInt32, 0, "uneditwearfashionidlist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashions_uneditWearFashionIdList, nil)
	SerializeBase.WriteList7Bit(writer, editwearfashioneditinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "editwearfashioneditinfolist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashions_editWearFashionEditInfoList, nil)
end

ClientToGameDelegate.AskModifySpiritWearFashions = function(self, spiritid, unwearfashionidlist, wearfashioninfolist, uneditwearfashionidlist, editwearfashioneditinfolist)
	return self.Invoke(self, 63098145, SerializerHelper.AskModifySpiritWearFashions_Serializer, spiritid, unwearfashionidlist, wearfashioninfolist, uneditwearfashionidlist, editwearfashioneditinfolist)
end

SerializerHelper.AskLeaveWushuTournament_Serializer = function(writer)
end

ClientToGameDelegate.AskLeaveWushuTournament = function(self)
	return self.Invoke(self, 63098285, SerializerHelper.AskLeaveWushuTournament_Serializer)
end

SerializerHelper.InteractNpcChat_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.InteractNpcChat = function(self, chatid)
	return self.Invoke(self, 63098840, SerializerHelper.InteractNpcChat_Serializer, chatid)
end

SerializerHelper.AskKickTeamMember_Serializer = function(writer, memberpid)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskKickTeamMember = function(self, memberpid)
	return self.Invoke(self, 63099203, SerializerHelper.AskKickTeamMember_Serializer, memberpid)
end

SerializerHelper.AskTeleportToHouseGarage_Serializer = function(writer, houseid, parkingspaceindex)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, parkingspaceindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskTeleportToHouseGarage = function(self, houseid, parkingspaceindex)
	return self.Invoke(self, 63099218, SerializerHelper.AskTeleportToHouseGarage_Serializer, houseid, parkingspaceindex)
end

SerializerHelper.AskChangeRankZone_Serializer = function(writer, rankconfigid, zoneid)
	SerializeBase.WritePrimitive(writer, rankconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, zoneid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskChangeRankZone = function(self, rankconfigid, zoneid)
	return self.Invoke(self, 63103564, SerializerHelper.AskChangeRankZone_Serializer, rankconfigid, zoneid)
end

SerializerHelper.AskSetPokemonLockState_Serializer = function(writer, id, state)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskSetPokemonLockState = function(self, id, state)
	return self.Invoke(self, 63103811, SerializerHelper.AskSetPokemonLockState_Serializer, id, state)
end

SerializerHelper.AskConfirmEnchantChoice_Serializer = function(writer, weaponinstanceid, keepnew)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, keepnew, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskConfirmEnchantChoice = function(self, weaponinstanceid, keepnew)
	return self.Invoke(self, 63106737, SerializerHelper.AskConfirmEnchantChoice_Serializer, weaponinstanceid, keepnew)
end

SerializerHelper.AskOCDeleteSpeech_Serializer = function(writer, speechname)
	writer.WriteString(writer, speechname, false, "AskOCDeleteSpeech.speechName", RpcLengthLimits.IClientToGame_AskOCDeleteSpeech_speechName)
end

ClientToGameDelegate.AskOCDeleteSpeech = function(self, speechname)
	return self.Invoke(self, 63107480, SerializerHelper.AskOCDeleteSpeech_Serializer, speechname)
end

SerializerHelper.AskDoAgentFansPerformance_Serializer = function(writer, nuid, agentinstanceid)
	SerializeBase.WritePrimitive(writer, nuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentinstanceid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskDoAgentFansPerformance = function(self, nuid, agentinstanceid)
	self.Notify(self, 63107699, SerializerHelper.AskDoAgentFansPerformance_Serializer, nuid, agentinstanceid)
end

SerializerHelper.AskOpenFarmerShopApp_Serializer = function(writer)
end

ClientToGameDelegate.AskOpenFarmerShopApp = function(self)
	return self.Invoke(self, 63108486, SerializerHelper.AskOpenFarmerShopApp_Serializer)
end

SerializerHelper.AskCancelHideAndSeekTransformModel_Serializer = function(writer)
end

ClientToGameDelegate.AskCancelHideAndSeekTransformModel = function(self)
	return self.Invoke(self, 63108626, SerializerHelper.AskCancelHideAndSeekTransformModel_Serializer)
end

SerializerHelper.JoinBasketballLink_Serializer = function(writer, psnonly)
	SerializeBase.WritePrimitive(writer, psnonly, writer.WriteBoolean, false)
end

ClientToGameDelegate.JoinBasketballLink = function(self, psnonly)
	self.Notify(self, 63108779, SerializerHelper.JoinBasketballLink_Serializer, psnonly)
end

SerializerHelper.AskRowBoatPhotoCheckIn_Serializer = function(writer, sightid)
	SerializeBase.WritePrimitive(writer, sightid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskRowBoatPhotoCheckIn = function(self, sightid)
	return self.Invoke(self, 63109250, SerializerHelper.AskRowBoatPhotoCheckIn_Serializer, sightid)
end

SerializerHelper.AskLoadHouseData_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskLoadHouseData = function(self, houseid)
	return self.Invoke(self, 63109556, SerializerHelper.AskLoadHouseData_Serializer, houseid)
end

SerializerHelper.AskAcceptTruckJobOrder_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskAcceptTruckJobOrder = function(self, id)
	return self.Invoke(self, 63110537, SerializerHelper.AskAcceptTruckJobOrder_Serializer, id)
end

SerializerHelper.AskGetBeLikeList_Serializer = function(writer)
end

ClientToGameDelegate.AskGetBeLikeList = function(self)
	return self.Invoke(self, 63113609, SerializerHelper.AskGetBeLikeList_Serializer)
end

SerializerHelper.AskAppendAISessionMessage_Serializer = function(writer, sessiontype, sessionid, constdata, mutabledata)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sessiontype, 6, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt32, 0)
	writer.WriteString(writer, constdata, false, "AskAppendAISessionMessage.constData", RpcLengthLimits.IClientToGame_AskAppendAISessionMessage_constData)
	writer.WriteString(writer, mutabledata, false, "AskAppendAISessionMessage.mutableData", RpcLengthLimits.IClientToGame_AskAppendAISessionMessage_mutableData)
end

ClientToGameDelegate.AskAppendAISessionMessage = function(self, sessiontype, sessionid, constdata, mutabledata)
	return self.Invoke(self, 63114109, SerializerHelper.AskAppendAISessionMessage_Serializer, sessiontype, sessionid, constdata, mutabledata)
end

SerializerHelper.SyncChangeBlock_Serializer = function(writer, blockid)
	SerializeBase.WritePrimitive(writer, blockid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.SyncChangeBlock = function(self, blockid)
	self.Notify(self, 63114795, SerializerHelper.SyncChangeBlock_Serializer, blockid)
end

SerializerHelper.AskExtractionShooterBagExpansion_Serializer = function(writer, expansionid)
	SerializeBase.WritePrimitive(writer, expansionid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskExtractionShooterBagExpansion = function(self, expansionid)
	return self.Invoke(self, 63115121, SerializerHelper.AskExtractionShooterBagExpansion_Serializer, expansionid)
end

SerializerHelper.AskComputerFileRead_Serializer = function(writer, fileid, isvideoend)
	SerializeBase.WritePrimitive(writer, fileid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isvideoend, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskComputerFileRead = function(self, fileid, isvideoend)
	return self.Invoke(self, 63116823, SerializerHelper.AskComputerFileRead_Serializer, fileid, isvideoend)
end

SerializerHelper.AskGetClubApplicationCount_Serializer = function(writer, clubid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskGetClubApplicationCount = function(self, clubid)
	return self.Invoke(self, 63117105, SerializerHelper.AskGetClubApplicationCount_Serializer, clubid)
end

SerializerHelper.AskPlaceFish_Serializer = function(writer, placedinfo, fishuniqueid)
	SerializeBase.WriteComplex(writer, placedinfo, SerializeAuto.WriteFishPlacedInfo, "placedinfo", false)
	SerializeBase.WritePrimitive(writer, fishuniqueid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPlaceFish = function(self, placedinfo, fishuniqueid)
	return self.Invoke(self, 63118644, SerializerHelper.AskPlaceFish_Serializer, placedinfo, fishuniqueid)
end

SerializerHelper.AskTamagotchiSignIn_Serializer = function(writer, signinid)
	SerializeBase.WritePrimitive(writer, signinid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTamagotchiSignIn = function(self, signinid)
	return self.Invoke(self, 63119028, SerializerHelper.AskTamagotchiSignIn_Serializer, signinid)
end

SerializerHelper.OnCarriageChanged_Serializer = function(writer, carriageid, isenter)
	SerializeBase.WritePrimitive(writer, carriageid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isenter, writer.WriteBoolean, false)
end

ClientToGameDelegate.OnCarriageChanged = function(self, carriageid, isenter)
	self.Notify(self, 63119804, SerializerHelper.OnCarriageChanged_Serializer, carriageid, isenter)
end

SerializerHelper.StartGameInTeam_Serializer = function(writer, gameid, difficulty)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, difficulty, writer.WriteUInt32, 0)
end

ClientToGameDelegate.StartGameInTeam = function(self, gameid, difficulty)
	return self.Invoke(self, 63121362, SerializerHelper.StartGameInTeam_Serializer, gameid, difficulty)
end

SerializerHelper.AskExtraStateConfirm_Serializer = function(writer, confirminfo)
	SerializeBase.WriteStruct(writer, confirminfo, SerializeAuto.WriteExtraStateConfirmInfo, "confirminfo")
end

ClientToGameDelegate.AskExtraStateConfirm = function(self, confirminfo)
	return self.Invoke(self, 63122333, SerializerHelper.AskExtraStateConfirm_Serializer, confirminfo)
end

SerializerHelper.AskSaveGuitarInfo_Serializer = function(writer, index, guitarinfo)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, guitarinfo, SerializeAuto.WritePlayerGuitarInfo, "guitarinfo", false)
end

ClientToGameDelegate.AskSaveGuitarInfo = function(self, index, guitarinfo)
	return self.Invoke(self, 63122484, SerializerHelper.AskSaveGuitarInfo_Serializer, index, guitarinfo)
end

SerializerHelper.AskStartBartenderGame_Serializer = function(writer, bartenderid)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartBartenderGame = function(self, bartenderid)
	return self.Invoke(self, 63122669, SerializerHelper.AskStartBartenderGame_Serializer, bartenderid)
end

SerializerHelper.AskNewChallengeRecord_Serializer = function(writer, challengeid)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskNewChallengeRecord = function(self, challengeid)
	return self.Invoke(self, 63126760, SerializerHelper.AskNewChallengeRecord_Serializer, challengeid)
end

SerializerHelper.AskUpdatePersonalZoneBirthday_Serializer = function(writer, birthday)
	SerializeBase.WritePrimitive(writer, birthday, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUpdatePersonalZoneBirthday = function(self, birthday)
	return self.Invoke(self, 63129735, SerializerHelper.AskUpdatePersonalZoneBirthday_Serializer, birthday)
end

SerializerHelper.AskBuildMeccaGrandpa_Serializer = function(writer, slots)
	SerializeBase.WriteList7Bit(writer, slots, SerializeBase.WriteComplexWrap(SerializeAuto.WriteMeccaGrandpaSlotInfo, "MeccaGrandpaSlotInfo", false), nil, "slots", false, RpcLengthLimits.IClientToGame_AskBuildMeccaGrandpa_slots, nil)
end

ClientToGameDelegate.AskBuildMeccaGrandpa = function(self, slots)
	return self.Invoke(self, 63130394, SerializerHelper.AskBuildMeccaGrandpa_Serializer, slots)
end

SerializerHelper.Hu_Serializer = function(writer)
end

ClientToGameDelegate.Hu = function(self)
	self.Notify(self, 63131631, SerializerHelper.Hu_Serializer)
end

SerializerHelper.OnImposterExplode_Serializer = function(writer)
end

ClientToGameDelegate.OnImposterExplode = function(self)
	self.Notify(self, 63131874, SerializerHelper.OnImposterExplode_Serializer)
end

SerializerHelper.AskLinkInfo_Serializer = function(writer, mode)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskLinkInfo = function(self, mode)
	return self.Invoke(self, 63131968, SerializerHelper.AskLinkInfo_Serializer, mode)
end

SerializerHelper.AskMomentsMarkRead_Serializer = function(writer, postids)
	SerializeBase.WriteList7Bit(writer, postids, writer.WriteUInt32, 0, "postids", false, RpcLengthLimits.IClientToGame_AskMomentsMarkRead_postIds, nil)
end

ClientToGameDelegate.AskMomentsMarkRead = function(self, postids)
	return self.Invoke(self, 63132673, SerializerHelper.AskMomentsMarkRead_Serializer, postids)
end

SerializerHelper.ExitCinemaLink_Serializer = function(writer)
end

ClientToGameDelegate.ExitCinemaLink = function(self)
	self.Notify(self, 63134290, SerializerHelper.ExitCinemaLink_Serializer)
end

SerializerHelper.AskTuiteUploadedToOSS_Serializer = function(writer, tuiteid, osskey)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
	writer.WriteString(writer, osskey, false, "AskTuiteUploadedToOSS.ossKey", RpcLengthLimits.IClientToGame_AskTuiteUploadedToOSS_ossKey)
end

ClientToGameDelegate.AskTuiteUploadedToOSS = function(self, tuiteid, osskey)
	return self.Invoke(self, 63136226, SerializerHelper.AskTuiteUploadedToOSS_Serializer, tuiteid, osskey)
end

SerializerHelper.AskFarmerWithdraw_Serializer = function(writer)
end

ClientToGameDelegate.AskFarmerWithdraw = function(self)
	return self.Invoke(self, 63136252, SerializerHelper.AskFarmerWithdraw_Serializer)
end

SerializerHelper.InviteNpcChat_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.InviteNpcChat = function(self, chatid)
	return self.Invoke(self, 63137850, SerializerHelper.InviteNpcChat_Serializer, chatid)
end

SerializerHelper.AskChangeTeamLeaderApply_Serializer = function(writer)
end

ClientToGameDelegate.AskChangeTeamLeaderApply = function(self)
	return self.Invoke(self, 63138682, SerializerHelper.AskChangeTeamLeaderApply_Serializer)
end

SerializerHelper.LoginGame_Serializer = function(writer, pid, token)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, token, false, "LoginGame.token", RpcLengthLimits.IClientToGame_LoginGame_token)
end

ClientToGameDelegate.LoginGame = function(self, pid, token)
	self.Notify(self, 63142082, SerializerHelper.LoginGame_Serializer, pid, token)
end

SerializerHelper.AskEndEnsemble_Serializer = function(writer)
end

ClientToGameDelegate.AskEndEnsemble = function(self)
	return self.Invoke(self, 63147178, SerializerHelper.AskEndEnsemble_Serializer)
end

SerializerHelper.SetChallengeStartTime_Serializer = function(writer, taskid, starttime)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, starttime, writer.WriteUInt32, 0)
end

ClientToGameDelegate.SetChallengeStartTime = function(self, taskid, starttime)
	return self.Invoke(self, 63147427, SerializerHelper.SetChallengeStartTime_Serializer, taskid, starttime)
end

SerializerHelper.AskStartWushuTournamentChallenge_Serializer = function(writer, roundid)
	SerializeBase.WritePrimitive(writer, roundid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartWushuTournamentChallenge = function(self, roundid)
	return self.Invoke(self, 63147564, SerializerHelper.AskStartWushuTournamentChallenge_Serializer, roundid)
end

SerializerHelper.AskGetAllAchievementReward_Serializer = function(writer)
end

ClientToGameDelegate.AskGetAllAchievementReward = function(self)
	return self.Invoke(self, 63149191, SerializerHelper.AskGetAllAchievementReward_Serializer)
end

SerializerHelper.AskSaveYachtOptions_Serializer = function(writer, optionids)
	SerializeBase.WriteList7Bit(writer, optionids, writer.WriteUInt32, 0, "optionids", false, RpcLengthLimits.IClientToGame_AskSaveYachtOptions_optionIds, nil)
end

ClientToGameDelegate.AskSaveYachtOptions = function(self, optionids)
	return self.Invoke(self, 63150345, SerializerHelper.AskSaveYachtOptions_Serializer, optionids)
end

SerializerHelper.AskReadHackerNewPost_Serializer = function(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskReadHackerNewPost = function(self, postid)
	return self.Invoke(self, 63150736, SerializerHelper.AskReadHackerNewPost_Serializer, postid)
end

SerializerHelper.AskDivinerCheckSpecialEvent_Serializer = function(writer)
end

ClientToGameDelegate.AskDivinerCheckSpecialEvent = function(self)
	return self.Invoke(self, 63151187, SerializerHelper.AskDivinerCheckSpecialEvent_Serializer)
end

SerializerHelper.AskWushuTournamentPostSettlement_Serializer = function(writer, roundid, action)
	SerializeBase.WritePrimitive(writer, roundid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(action, 9, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskWushuTournamentPostSettlement = function(self, roundid, action)
	return self.Invoke(self, 63153079, SerializerHelper.AskWushuTournamentPostSettlement_Serializer, roundid, action)
end

SerializerHelper.ChangePersonalTimeSetting_Serializer = function(writer, index, info)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WritePersonalTimeSetting, "info", true)
end

ClientToGameDelegate.ChangePersonalTimeSetting = function(self, index, info)
	return self.Invoke(self, 63153182, SerializerHelper.ChangePersonalTimeSetting_Serializer, index, info)
end

SerializerHelper.TuoGuan_Serializer = function(writer, type)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

ClientToGameDelegate.TuoGuan = function(self, type)
	return self.Invoke(self, 63154069, SerializerHelper.TuoGuan_Serializer, type)
end

SerializerHelper.AskHouseParking_Serializer = function(writer, parkinginfolist)
	SerializeBase.WriteList7Bit(writer, parkinginfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteHouseParkingInfo, "HouseParkingInfo", false), nil, "parkinginfolist", false, RpcLengthLimits.IClientToGame_AskHouseParking_parkingInfoList, nil)
end

ClientToGameDelegate.AskHouseParking = function(self, parkinginfolist)
	return self.Invoke(self, 63154177, SerializerHelper.AskHouseParking_Serializer, parkinginfolist)
end

SerializerHelper.InTurnOperationEvent_Serializer = function(writer, playerindex, opindex, remaintime)
	SerializeBase.WritePrimitive(writer, playerindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, opindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, remaintime, writer.WriteInt32, 0)
end

ClientToGameDelegate.InTurnOperationEvent = function(self, playerindex, opindex, remaintime)
	self.Notify(self, 63154331, SerializerHelper.InTurnOperationEvent_Serializer, playerindex, opindex, remaintime)
end

SerializerHelper.AskTrackEvent_Serializer = function(writer, evenid)
	SerializeBase.WritePrimitive(writer, evenid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTrackEvent = function(self, evenid)
	self.Notify(self, 63155371, SerializerHelper.AskTrackEvent_Serializer, evenid)
end

SerializerHelper.AddPoliceChargingProgress_Serializer = function(writer, chargingeventid)
	SerializeBase.WritePrimitive(writer, chargingeventid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AddPoliceChargingProgress = function(self, chargingeventid)
	return self.Invoke(self, 63155900, SerializerHelper.AddPoliceChargingProgress_Serializer, chargingeventid)
end

SerializerHelper.AskCreateCustomLink_Serializer = function(writer, param)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteCustomLinkCreateParam, "param", false)
end

ClientToGameDelegate.AskCreateCustomLink = function(self, param)
	return self.Invoke(self, 63155988, SerializerHelper.AskCreateCustomLink_Serializer, param)
end

SerializerHelper.AskShoulderPoleAttachAllCargo_Serializer = function(writer)
end

ClientToGameDelegate.AskShoulderPoleAttachAllCargo = function(self)
	return self.Invoke(self, 63156734, SerializerHelper.AskShoulderPoleAttachAllCargo_Serializer)
end

SerializerHelper.AskFriendRankingTop_Serializer = function(writer, rankconfigid, options)
	SerializeBase.WritePrimitive(writer, rankconfigid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, options, SerializeAuto.WriteRankQueryOptions, "options", true)
end

ClientToGameDelegate.AskFriendRankingTop = function(self, rankconfigid, options)
	return self.Invoke(self, 63159289, SerializerHelper.AskFriendRankingTop_Serializer, rankconfigid, options)
end

SerializerHelper.ResponseOKEvent_Serializer = function(writer, playerindex)
	SerializeBase.WritePrimitive(writer, playerindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.ResponseOKEvent = function(self, playerindex)
	self.Notify(self, 63160451, SerializerHelper.ResponseOKEvent_Serializer, playerindex)
end

SerializerHelper.AskTierById_Serializer = function(writer, tierconfigid)
	SerializeBase.WritePrimitive(writer, tierconfigid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTierById = function(self, tierconfigid)
	return self.Invoke(self, 63161070, SerializerHelper.AskTierById_Serializer, tierconfigid)
end

SerializerHelper.AskLeaveTeam_Serializer = function(writer)
end

ClientToGameDelegate.AskLeaveTeam = function(self)
	return self.Invoke(self, 63162834, SerializerHelper.AskLeaveTeam_Serializer)
end

SerializerHelper.AskActiveSpiritJobTalentLayer_Serializer = function(writer, spiritid, jobclassid, talentid, addlayer)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, talentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addlayer, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskActiveSpiritJobTalentLayer = function(self, spiritid, jobclassid, talentid, addlayer)
	return self.Invoke(self, 63162837, SerializerHelper.AskActiveSpiritJobTalentLayer_Serializer, spiritid, jobclassid, talentid, addlayer)
end

SerializerHelper.AskApplyDutySwap_Serializer = function(writer, sourceduty, targetpid, targetduty)
	SerializeBase.WritePrimitive(writer, sourceduty, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetduty, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskApplyDutySwap = function(self, sourceduty, targetpid, targetduty)
	return self.Invoke(self, 63162918, SerializerHelper.AskApplyDutySwap_Serializer, sourceduty, targetpid, targetduty)
end

SerializerHelper.AskChangeClubName_Serializer = function(writer, clubid, name)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	writer.WriteString(writer, name, false, "AskChangeClubName.name", RpcLengthLimits.IClientToGame_AskChangeClubName_name)
end

ClientToGameDelegate.AskChangeClubName = function(self, clubid, name)
	return self.Invoke(self, 63164501, SerializerHelper.AskChangeClubName_Serializer, clubid, name)
end

SerializerHelper.AskClubAssignCustomJob_Serializer = function(writer, pid, jobid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, jobid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskClubAssignCustomJob = function(self, pid, jobid)
	return self.Invoke(self, 63165207, SerializerHelper.AskClubAssignCustomJob_Serializer, pid, jobid)
end

SerializerHelper.AskSetFashionColoringSchemeInfos_Serializer = function(writer, fashioncoloringschemeinfolist)
	SerializeBase.WriteList7Bit(writer, fashioncoloringschemeinfolist, SerializeBase.WriteStructWrap(SerializeAuto.WriteFashionColoringSchemeInfo, "fashioncoloringschemeinfolist"), nil, "fashioncoloringschemeinfolist", false, RpcLengthLimits.IClientToGame_AskSetFashionColoringSchemeInfos_fashionColoringSchemeInfoList, nil)
end

ClientToGameDelegate.AskSetFashionColoringSchemeInfos = function(self, fashioncoloringschemeinfolist)
	return self.Invoke(self, 63166582, SerializerHelper.AskSetFashionColoringSchemeInfos_Serializer, fashioncoloringschemeinfolist)
end

SerializerHelper.AskExtractionShooterSplitItem_Serializer = function(writer, bagconfigid, splitcellx, splitcelly, splitcount, isrotated)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcount, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskExtractionShooterSplitItem = function(self, bagconfigid, splitcellx, splitcelly, splitcount, isrotated)
	return self.Invoke(self, 63166850, SerializerHelper.AskExtractionShooterSplitItem_Serializer, bagconfigid, splitcellx, splitcelly, splitcount, isrotated)
end

SerializerHelper.AskSetSpiritFashionsWithSource_Serializer = function(writer, spiritorinstanceid, source, spiritwearfashionsinfo)
	SerializeBase.WritePrimitive(writer, spiritorinstanceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, source, writer.WriteInt16, 0)
	SerializeBase.WriteComplex(writer, spiritwearfashionsinfo, SerializeAuto.WriteSpiritWearFashionsInfo, "spiritwearfashionsinfo", false)
end

ClientToGameDelegate.AskSetSpiritFashionsWithSource = function(self, spiritorinstanceid, source, spiritwearfashionsinfo)
	return self.Invoke(self, 63167148, SerializerHelper.AskSetSpiritFashionsWithSource_Serializer, spiritorinstanceid, source, spiritwearfashionsinfo)
end

SerializerHelper.AskGetFriendOwnedCommodities_Serializer = function(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskGetFriendOwnedCommodities = function(self, friendpid)
	return self.Invoke(self, 63167345, SerializerHelper.AskGetFriendOwnedCommodities_Serializer, friendpid)
end

SerializerHelper.AskInterruptDialog_Serializer = function(writer, taskid, dialogid, interruptdialogid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interruptdialogid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskInterruptDialog = function(self, taskid, dialogid, interruptdialogid)
	return self.Invoke(self, 63168073, SerializerHelper.AskInterruptDialog_Serializer, taskid, dialogid, interruptdialogid)
end

SerializerHelper.AskGetArrestTimes_Serializer = function(writer)
end

ClientToGameDelegate.AskGetArrestTimes = function(self)
	return self.Invoke(self, 63170713, SerializerHelper.AskGetArrestTimes_Serializer)
end

SerializerHelper.AskJoinVoiceTeam_Serializer = function(writer, channel, id)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(channel, 10, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskJoinVoiceTeam = function(self, channel, id)
	return self.Invoke(self, 63171491, SerializerHelper.AskJoinVoiceTeam_Serializer, channel, id)
end

SerializerHelper.AskStealNPCMoney_Serializer = function(writer)
end

ClientToGameDelegate.AskStealNPCMoney = function(self)
	return self.Invoke(self, 63172360, SerializerHelper.AskStealNPCMoney_Serializer)
end

SerializerHelper.AskTakePopularityReward_Serializer = function(writer, cfgid)
	SerializeBase.WritePrimitive(writer, cfgid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakePopularityReward = function(self, cfgid)
	return self.Invoke(self, 63173101, SerializerHelper.AskTakePopularityReward_Serializer, cfgid)
end

SerializerHelper.SendCustomHotPatchClientToGame_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToGameDelegate.SendCustomHotPatchClientToGame = function(self, data)
	return self.Invoke(self, 63173218, SerializerHelper.SendCustomHotPatchClientToGame_Serializer, data)
end

SerializerHelper.AskFeedFish_Serializer = function(writer, count)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFeedFish = function(self, count)
	return self.Invoke(self, 63173861, SerializerHelper.AskFeedFish_Serializer, count)
end

SerializerHelper.AskTeleport_Serializer = function(writer, option)
	SerializeBase.WriteComplex(writer, option, SerializeAuto.WritePreTeleportOption, "option", false)
end

ClientToGameDelegate.AskTeleport = function(self, option)
	return self.Invoke(self, 63175104, SerializerHelper.AskTeleport_Serializer, option)
end

SerializerHelper.AskEnterPartyDanceFloor_Serializer = function(writer, gadgetid, waitareaindex)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, waitareaindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskEnterPartyDanceFloor = function(self, gadgetid, waitareaindex)
	return self.Invoke(self, 63175407, SerializerHelper.AskEnterPartyDanceFloor_Serializer, gadgetid, waitareaindex)
end

SerializerHelper.GetCharacterRandomDialog_Serializer = function(writer, agentid, maintag, subtag)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maintag, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, subtag, writer.WriteUInt32, 0, "subtag", true, RpcLengthLimits.IClientToGame_GetCharacterRandomDialog_SubTag, nil)
end

ClientToGameDelegate.GetCharacterRandomDialog = function(self, agentid, maintag, subtag)
	return self.Invoke(self, 63175540, SerializerHelper.GetCharacterRandomDialog_Serializer, agentid, maintag, subtag)
end

SerializerHelper.AskClaimGift_Serializer = function(writer, giftid)
	SerializeBase.WritePrimitive(writer, giftid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskClaimGift = function(self, giftid)
	return self.Invoke(self, 63178673, SerializerHelper.AskClaimGift_Serializer, giftid)
end

SerializerHelper.BackToMahjong_Serializer = function(writer)
end

ClientToGameDelegate.BackToMahjong = function(self)
	return self.Invoke(self, 63179270, SerializerHelper.BackToMahjong_Serializer)
end

SerializerHelper.AskUpdateDisplayLevel_Serializer = function(writer, displaylevel)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(displaylevel, 11, 1), writer.WriteByte, 1)
end

ClientToGameDelegate.AskUpdateDisplayLevel = function(self, displaylevel)
	self.Notify(self, 63180673, SerializerHelper.AskUpdateDisplayLevel_Serializer, displaylevel)
end

SerializerHelper.AskAgentChangeWeaponByTemplateId_Serializer = function(writer, agentid, weaponid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskAgentChangeWeaponByTemplateId = function(self, agentid, weaponid)
	return self.Invoke(self, 63182186, SerializerHelper.AskAgentChangeWeaponByTemplateId_Serializer, agentid, weaponid)
end

SerializerHelper.AskStartMahjongGame_Serializer = function(writer, type, npcidls, seatindex, addfavor, mahjonggametype)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 12, 0), writer.WriteByte, 0)
	SerializeBase.WriteList7Bit(writer, npcidls, writer.WriteUInt32, 0, "npcidls", false, RpcLengthLimits.IClientToGame_AskStartMahjongGame_npcIdLs, nil)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, addfavor, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mahjonggametype, 13, 1), writer.WriteByte, 1)
end

ClientToGameDelegate.AskStartMahjongGame = function(self, type, npcidls, seatindex, addfavor, mahjonggametype)
	return self.Invoke(self, 63184671, SerializerHelper.AskStartMahjongGame_Serializer, type, npcidls, seatindex, addfavor, mahjonggametype)
end

SerializerHelper.AskSetYachtAccessMode_Serializer = function(writer, mode)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 14, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskSetYachtAccessMode = function(self, mode)
	return self.Invoke(self, 63185562, SerializerHelper.AskSetYachtAccessMode_Serializer, mode)
end

SerializerHelper.ClearCompetitionRacingRecord_Serializer = function(writer, trackid)
	SerializeBase.WritePrimitive(writer, trackid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.ClearCompetitionRacingRecord = function(self, trackid)
	return self.Invoke(self, 63185742, SerializerHelper.ClearCompetitionRacingRecord_Serializer, trackid)
end

SerializerHelper.AskMoveMobilePlatform_Serializer = function(writer, mobileplatformid, targetindex)
	SerializeBase.WritePrimitive(writer, mobileplatformid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskMoveMobilePlatform = function(self, mobileplatformid, targetindex)
	return self.Invoke(self, 63185921, SerializerHelper.AskMoveMobilePlatform_Serializer, mobileplatformid, targetindex)
end

SerializerHelper.AskLinkWatchOther_Serializer = function(writer, watchee)
	SerializeBase.WritePrimitive(writer, watchee, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskLinkWatchOther = function(self, watchee)
	return self.Invoke(self, 63186259, SerializerHelper.AskLinkWatchOther_Serializer, watchee)
end

SerializerHelper.AskTradeBuyItem_Serializer = function(writer, tradeitemid, maxprice, count)
	SerializeBase.WritePrimitive(writer, tradeitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maxprice, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTradeBuyItem = function(self, tradeitemid, maxprice, count)
	return self.Invoke(self, 63188959, SerializerHelper.AskTradeBuyItem_Serializer, tradeitemid, maxprice, count)
end

SerializerHelper.AskAddBuildHouseIndoor_Serializer = function(writer, houseid, floor, addplacedfurnitureinfo)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, addplacedfurnitureinfo, SerializeAuto.WriteAddPlacedFurnitureInfo, "addplacedfurnitureinfo")
end

ClientToGameDelegate.AskAddBuildHouseIndoor = function(self, houseid, floor, addplacedfurnitureinfo)
	return self.Invoke(self, 63189680, SerializerHelper.AskAddBuildHouseIndoor_Serializer, houseid, floor, addplacedfurnitureinfo)
end

SerializerHelper.QueryMobileBind_Serializer = function(writer)
end

ClientToGameDelegate.QueryMobileBind = function(self)
	return self.Invoke(self, 63190204, SerializerHelper.QueryMobileBind_Serializer)
end

SerializerHelper.AskPhoneEditContactGroup_Serializer = function(writer, spiritid, groupindex, groupname)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, groupindex, writer.WriteInt32, 0)
	writer.WriteString(writer, groupname, false, "AskPhoneEditContactGroup.groupName", RpcLengthLimits.IClientToGame_AskPhoneEditContactGroup_groupName)
end

ClientToGameDelegate.AskPhoneEditContactGroup = function(self, spiritid, groupindex, groupname)
	return self.Invoke(self, 63192774, SerializerHelper.AskPhoneEditContactGroup_Serializer, spiritid, groupindex, groupname)
end

SerializerHelper.GetGamePlayCount_Serializer = function(writer, multiplayerid)
	SerializeBase.WritePrimitive(writer, multiplayerid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.GetGamePlayCount = function(self, multiplayerid)
	return self.Invoke(self, 63196386, SerializerHelper.GetGamePlayCount_Serializer, multiplayerid)
end

SerializerHelper.AskPublishCustomTuite_Serializer = function(writer, tuiteid)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPublishCustomTuite = function(self, tuiteid)
	return self.Invoke(self, 63197408, SerializerHelper.AskPublishCustomTuite_Serializer, tuiteid)
end

SerializerHelper.AskKTVMusicInfoList_Serializer = function(writer, musicids)
	SerializeBase.WriteList7Bit(writer, musicids, writer.WriteUInt32, 0, "musicids", false, RpcLengthLimits.IClientToGame_AskKTVMusicInfoList_musicIds, nil)
end

ClientToGameDelegate.AskKTVMusicInfoList = function(self, musicids)
	return self.Invoke(self, 63198422, SerializerHelper.AskKTVMusicInfoList_Serializer, musicids)
end

SerializerHelper.AskAddTruckOrderSpecialPointReward_Serializer = function(writer, orderid, pointid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pointid, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskAddTruckOrderSpecialPointReward = function(self, orderid, pointid)
	return self.Invoke(self, 63198726, SerializerHelper.AskAddTruckOrderSpecialPointReward_Serializer, orderid, pointid)
end

SerializerHelper.AskForceLogout_Serializer = function(writer)
end

ClientToGameDelegate.AskForceLogout = function(self)
	return self.Invoke(self, 63198924, SerializerHelper.AskForceLogout_Serializer)
end

SerializerHelper.RpcUpgradePlayerCollectionSlot_Serializer = function(writer, boothid, slot)
	SerializeBase.WritePrimitive(writer, boothid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slot, writer.WriteUInt32, 0)
end

ClientToGameDelegate.RpcUpgradePlayerCollectionSlot = function(self, boothid, slot)
	return self.Invoke(self, 63199509, SerializerHelper.RpcUpgradePlayerCollectionSlot_Serializer, boothid, slot)
end

SerializerHelper.AskOpenScientistFactorApp_Serializer = function(writer)
end

ClientToGameDelegate.AskOpenScientistFactorApp = function(self)
	return self.Invoke(self, 63200841, SerializerHelper.AskOpenScientistFactorApp_Serializer)
end

SerializerHelper.AskTeleportFromHouseGarage_Serializer = function(writer, houseid, parkingspaceindex, vehicleconfigid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, parkingspaceindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleconfigid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTeleportFromHouseGarage = function(self, houseid, parkingspaceindex, vehicleconfigid)
	return self.Invoke(self, 63203581, SerializerHelper.AskTeleportFromHouseGarage_Serializer, houseid, parkingspaceindex, vehicleconfigid)
end

SerializerHelper.InteractNpcChatToEnd_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.InteractNpcChatToEnd = function(self, chatid)
	return self.Invoke(self, 63203620, SerializerHelper.InteractNpcChatToEnd_Serializer, chatid)
end

SerializerHelper.AskOCGenerate_Serializer = function(writer, generateocinfo)
	SerializeBase.WriteComplex(writer, generateocinfo, SerializeAuto.WriteOCGenerateInfo, "generateocinfo", false)
end

ClientToGameDelegate.AskOCGenerate = function(self, generateocinfo)
	return self.Invoke(self, 63205332, SerializerHelper.AskOCGenerate_Serializer, generateocinfo)
end

SerializerHelper.OnVehicleColliding_Serializer = function(writer, data)
	SerializeBase.WriteStruct(writer, data, SerializeAuto.WriteVehicleCollisionUploadData, "data")
end

ClientToGameDelegate.OnVehicleColliding = function(self, data)
	self.Notify(self, 63206770, SerializerHelper.OnVehicleColliding_Serializer, data)
end

SerializerHelper.AskStartGuideByCondition_Serializer = function(writer, tag, value, value2)
	SerializeBase.WritePrimitive(writer, tag, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value2, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartGuideByCondition = function(self, tag, value, value2)
	return self.Invoke(self, 63207190, SerializerHelper.AskStartGuideByCondition_Serializer, tag, value, value2)
end

SerializerHelper.AskSelectWushuTournamentOpponent_Serializer = function(writer, roundid, opponentagentid)
	SerializeBase.WritePrimitive(writer, roundid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, opponentagentid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSelectWushuTournamentOpponent = function(self, roundid, opponentagentid)
	return self.Invoke(self, 63207842, SerializerHelper.AskSelectWushuTournamentOpponent_Serializer, roundid, opponentagentid)
end

SerializerHelper.AskSpiritSexTransition_Serializer = function(writer)
end

ClientToGameDelegate.AskSpiritSexTransition = function(self)
	return self.Invoke(self, 63209111, SerializerHelper.AskSpiritSexTransition_Serializer)
end

SerializerHelper.AskNewLink_Serializer = function(writer, type, psnonly)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 8, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, psnonly, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskNewLink = function(self, type, psnonly)
	return self.Invoke(self, 63210597, SerializerHelper.AskNewLink_Serializer, type, psnonly)
end

SerializerHelper.AskPlayerRankingSummary_Serializer = function(writer, pid, rankconfigids)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, rankconfigids, writer.WriteUInt32, 0, "rankconfigids", false, RpcLengthLimits.IClientToGame_AskPlayerRankingSummary_rankConfigIds, nil)
end

ClientToGameDelegate.AskPlayerRankingSummary = function(self, pid, rankconfigids)
	return self.Invoke(self, 63212153, SerializerHelper.AskPlayerRankingSummary_Serializer, pid, rankconfigids)
end

SerializerHelper.ReconnectGame_Serializer = function(writer)
end

ClientToGameDelegate.ReconnectGame = function(self)
	self.Notify(self, 63212713, SerializerHelper.ReconnectGame_Serializer)
end

SerializerHelper.AskWebviewToken_Serializer = function(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteWebviewLoginTokenInfo, "info", false)
end

ClientToGameDelegate.AskWebviewToken = function(self, info)
	return self.Invoke(self, 63213376, SerializerHelper.AskWebviewToken_Serializer, info)
end

SerializerHelper.AskClaimGachaMilestone_Serializer = function(writer, gachaid, milestonecount)
	SerializeBase.WritePrimitive(writer, gachaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, milestonecount, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskClaimGachaMilestone = function(self, gachaid, milestonecount)
	return self.Invoke(self, 63216112, SerializerHelper.AskClaimGachaMilestone_Serializer, gachaid, milestonecount)
end

SerializerHelper.AskQueryFavorNpcAgentPos_Serializer = function(writer, agenttag)
	SerializeBase.WritePrimitive(writer, agenttag, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskQueryFavorNpcAgentPos = function(self, agenttag)
	return self.Invoke(self, 63216726, SerializerHelper.AskQueryFavorNpcAgentPos_Serializer, agenttag)
end

SerializerHelper.AskGetJobBoardInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskGetJobBoardInfo = function(self)
	return self.Invoke(self, 63217039, SerializerHelper.AskGetJobBoardInfo_Serializer)
end

SerializerHelper.AskReportTamagotchiPetState_Serializer = function(writer, state)
	SerializeBase.WriteComplex(writer, state, SerializeAuto.WriteTamagotchiPetState, "state", false)
end

ClientToGameDelegate.AskReportTamagotchiPetState = function(self, state)
	return self.Invoke(self, 63217450, SerializerHelper.AskReportTamagotchiPetState_Serializer, state)
end

SerializerHelper.AskChallengeRecord_Serializer = function(writer, challengeid)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskChallengeRecord = function(self, challengeid)
	return self.Invoke(self, 63217972, SerializerHelper.AskChallengeRecord_Serializer, challengeid)
end

SerializerHelper.SetShortChatWheel_Serializer = function(writer, multitypeid, list)
	SerializeBase.WritePrimitive(writer, multitypeid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, list, SerializeBase.WriteComplexWrap(SerializeAuto.WriteChatWheelItem, "ChatWheelItem", false), nil, "list", false, RpcLengthLimits.IClientToGame_SetShortChatWheel_list, nil)
end

ClientToGameDelegate.SetShortChatWheel = function(self, multitypeid, list)
	return self.Invoke(self, 63217975, SerializerHelper.SetShortChatWheel_Serializer, multitypeid, list)
end

SerializerHelper.AskNewRoom_Serializer = function(writer, gameid, ugcmapid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ugcmapid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskNewRoom = function(self, gameid, ugcmapid)
	return self.Invoke(self, 63218261, SerializerHelper.AskNewRoom_Serializer, gameid, ugcmapid)
end

SerializerHelper.AskSendInteractionInfo_Serializer = function(writer, pid, type, isresponse)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isresponse, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskSendInteractionInfo = function(self, pid, type, isresponse)
	return self.Invoke(self, 63218516, SerializerHelper.AskSendInteractionInfo_Serializer, pid, type, isresponse)
end

SerializerHelper.InviteToPartyRoom_Serializer = function(writer, targetpid)
	SerializeBase.WritePrimitive(writer, targetpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.InviteToPartyRoom = function(self, targetpid)
	self.Notify(self, 63219455, SerializerHelper.InviteToPartyRoom_Serializer, targetpid)
end

SerializerHelper.AskStartCompetitionRacing_Serializer = function(writer, trackid, vehicleid)
	SerializeBase.WritePrimitive(writer, trackid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartCompetitionRacing = function(self, trackid, vehicleid)
	return self.Invoke(self, 63221200, SerializerHelper.AskStartCompetitionRacing_Serializer, trackid, vehicleid)
end

SerializerHelper.AskModifySpiritWearFashionEditInfos_Serializer = function(writer, spiritid, uneditwearfashionidlist, editwearfashioneditinfolist)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, uneditwearfashionidlist, writer.WriteUInt32, 0, "uneditwearfashionidlist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionEditInfos_uneditWearFashionIdList, nil)
	SerializeBase.WriteList7Bit(writer, editwearfashioneditinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "editwearfashioneditinfolist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionEditInfos_editWearFashionEditInfoList, nil)
end

ClientToGameDelegate.AskModifySpiritWearFashionEditInfos = function(self, spiritid, uneditwearfashionidlist, editwearfashioneditinfolist)
	return self.Invoke(self, 63221752, SerializerHelper.AskModifySpiritWearFashionEditInfos_Serializer, spiritid, uneditwearfashionidlist, editwearfashioneditinfolist)
end

SerializerHelper.AskOCEditMemoryParams_Serializer = function(writer, memoryid, newparams, setid)
	SerializeBase.WritePrimitive(writer, memoryid, writer.WriteUInt32, 0)
	SerializeBase.WriteDict7Bit(writer, newparams, writer.WriteUInt32, SerializeBase.WriteStringWrap(false, "newparams", RpcLengthLimits.IClientToGame_AskOCEditMemoryParams_newParams_String), nil, "newparams", false, RpcLengthLimits.IClientToGame_AskOCEditMemoryParams_newParams)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(setid, 15, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskOCEditMemoryParams = function(self, memoryid, newparams, setid)
	return self.Invoke(self, 63222912, SerializerHelper.AskOCEditMemoryParams_Serializer, memoryid, newparams, setid)
end

SerializerHelper.AskUpdatePersonalZoneBackground_Serializer = function(writer, pid, backgroundid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, backgroundid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUpdatePersonalZoneBackground = function(self, pid, backgroundid)
	return self.Invoke(self, 63224580, SerializerHelper.AskUpdatePersonalZoneBackground_Serializer, pid, backgroundid)
end

SerializerHelper.RecordDarts_Serializer = function(writer, challengeid, score, goal, finish, types)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, goal, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, finish, writer.WriteBoolean, false)
	SerializeBase.WriteList7Bit(writer, types, writer.WriteByte, 0, "types", false, RpcLengthLimits.IClientToGame_RecordDarts_types, nil)
end

ClientToGameDelegate.RecordDarts = function(self, challengeid, score, goal, finish, types)
	return self.Invoke(self, 63225711, SerializerHelper.RecordDarts_Serializer, challengeid, score, goal, finish, types)
end

SerializerHelper.ArchiveInvestigateGallery_Serializer = function(writer, galleryid)
	SerializeBase.WritePrimitive(writer, galleryid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.ArchiveInvestigateGallery = function(self, galleryid)
	return self.Invoke(self, 63227536, SerializerHelper.ArchiveInvestigateGallery_Serializer, galleryid)
end

SerializerHelper.AskMahjongInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskMahjongInfo = function(self)
	return self.Invoke(self, 63229637, SerializerHelper.AskMahjongInfo_Serializer)
end

SerializerHelper.AskSwitchLinkMode_Serializer = function(writer, mode, autonew)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, autonew, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskSwitchLinkMode = function(self, mode, autonew)
	return self.Invoke(self, 63231540, SerializerHelper.AskSwitchLinkMode_Serializer, mode, autonew)
end

SerializerHelper.MahjongChat_Serializer = function(writer, chattype, msgid)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(chattype, 16, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, msgid, writer.WriteInt32, 0)
end

ClientToGameDelegate.MahjongChat = function(self, chattype, msgid)
	return self.Invoke(self, 63232366, SerializerHelper.MahjongChat_Serializer, chattype, msgid)
end

SerializerHelper.AskSetSpiritCustomSuitSchemeInfo_Serializer = function(writer, spiritid, schemeindex, customsuitschemeinfo)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, schemeindex, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, customsuitschemeinfo, SerializeAuto.WriteFashionCustomSuitSchemeInfo, "customsuitschemeinfo", false)
end

ClientToGameDelegate.AskSetSpiritCustomSuitSchemeInfo = function(self, spiritid, schemeindex, customsuitschemeinfo)
	return self.Invoke(self, 63232435, SerializerHelper.AskSetSpiritCustomSuitSchemeInfo_Serializer, spiritid, schemeindex, customsuitschemeinfo)
end

SerializerHelper.AskPoliceTakeCaseReward_Serializer = function(writer, caseid)
	SerializeBase.WritePrimitive(writer, caseid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskPoliceTakeCaseReward = function(self, caseid)
	return self.Invoke(self, 63234061, SerializerHelper.AskPoliceTakeCaseReward_Serializer, caseid)
end

SerializerHelper.AskMonthlyPassDoDailyRewardPopUp_Serializer = function(writer, monthlypassid)
	SerializeBase.WritePrimitive(writer, monthlypassid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskMonthlyPassDoDailyRewardPopUp = function(self, monthlypassid)
	return self.Invoke(self, 63237232, SerializerHelper.AskMonthlyPassDoDailyRewardPopUp_Serializer, monthlypassid)
end

SerializerHelper.AskLikeHouse_Serializer = function(writer, ownerpid, houseid)
	SerializeBase.WritePrimitive(writer, ownerpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskLikeHouse = function(self, ownerpid, houseid)
	return self.Invoke(self, 63237723, SerializerHelper.AskLikeHouse_Serializer, ownerpid, houseid)
end

SerializerHelper.AskGiveToBeggar_Serializer = function(writer, beggarpid, choice)
	SerializeBase.WritePrimitive(writer, beggarpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, choice, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskGiveToBeggar = function(self, beggarpid, choice)
	return self.Invoke(self, 63239210, SerializerHelper.AskGiveToBeggar_Serializer, beggarpid, choice)
end

SerializerHelper.AskReport_Serializer = function(writer, pid, reporttypes, description)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, reporttypes, writer.WriteUInt32, 0, "reporttypes", false, RpcLengthLimits.IClientToGame_AskReport_reportTypes, nil)
	writer.WriteString(writer, description, false, "AskReport.description", RpcLengthLimits.IClientToGame_AskReport_description)
end

ClientToGameDelegate.AskReport = function(self, pid, reporttypes, description)
	return self.Invoke(self, 63240085, SerializerHelper.AskReport_Serializer, pid, reporttypes, description)
end

SerializerHelper.AskTuiteFollowRole_Serializer = function(writer, roleid)
	SerializeBase.WritePrimitive(writer, roleid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTuiteFollowRole = function(self, roleid)
	return self.Invoke(self, 63241162, SerializerHelper.AskTuiteFollowRole_Serializer, roleid)
end

SerializerHelper.StartPartyLottery_Serializer = function(writer)
end

ClientToGameDelegate.StartPartyLottery = function(self)
	return self.Invoke(self, 63241176, SerializerHelper.StartPartyLottery_Serializer)
end

SerializerHelper.AskTuiteLikeComment_Serializer = function(writer, tuiteid, commentid, islike)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, commentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, islike, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskTuiteLikeComment = function(self, tuiteid, commentid, islike)
	return self.Invoke(self, 63242664, SerializerHelper.AskTuiteLikeComment_Serializer, tuiteid, commentid, islike)
end

SerializerHelper.AskDestroyAllGangMember_Serializer = function(writer)
end

ClientToGameDelegate.AskDestroyAllGangMember = function(self)
	return self.Invoke(self, 63243016, SerializerHelper.AskDestroyAllGangMember_Serializer)
end

SerializerHelper.OutTurnOperationEvent_Serializer = function(writer, playerindex, opindex, remaintime)
	SerializeBase.WritePrimitive(writer, playerindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, opindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, remaintime, writer.WriteInt32, 0)
end

ClientToGameDelegate.OutTurnOperationEvent = function(self, playerindex, opindex, remaintime)
	self.Notify(self, 63244376, SerializerHelper.OutTurnOperationEvent_Serializer, playerindex, opindex, remaintime)
end

SerializerHelper.AskLikePlayer_Serializer = function(writer, pid, liketype)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(liketype, 17, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskLikePlayer = function(self, pid, liketype)
	return self.Invoke(self, 63244481, SerializerHelper.AskLikePlayer_Serializer, pid, liketype)
end

SerializerHelper.ChangePrepareRoomSetting_Serializer = function(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WritePrepareRoomSetting, "setting", false)
end

ClientToGameDelegate.ChangePrepareRoomSetting = function(self, setting)
	return self.Invoke(self, 63245091, SerializerHelper.ChangePrepareRoomSetting_Serializer, setting)
end

SerializerHelper.AskFerrisWheelStart_Serializer = function(writer)
end

ClientToGameDelegate.AskFerrisWheelStart = function(self)
	return self.Invoke(self, 63246150, SerializerHelper.AskFerrisWheelStart_Serializer)
end

SerializerHelper.AskInvitePartyDanceFloor_Serializer = function(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskInvitePartyDanceFloor = function(self, targetid)
	return self.Invoke(self, 63248572, SerializerHelper.AskInvitePartyDanceFloor_Serializer, targetid)
end

SerializerHelper.AskEnterMultiverse_Serializer = function(writer, multiversepanelid, mode, psnonly)
	SerializeBase.WritePrimitive(writer, multiversepanelid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, psnonly, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskEnterMultiverse = function(self, multiversepanelid, mode, psnonly)
	return self.Invoke(self, 63248956, SerializerHelper.AskEnterMultiverse_Serializer, multiversepanelid, mode, psnonly)
end

SerializerHelper.AskItemExchange_Serializer = function(writer, exchangeid, count)
	SerializeBase.WritePrimitive(writer, exchangeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskItemExchange = function(self, exchangeid, count)
	return self.Invoke(self, 63249265, SerializerHelper.AskItemExchange_Serializer, exchangeid, count)
end

SerializerHelper.AskMallBuyBundle_Serializer = function(writer, bundleid, buycnt, isautoexchange)
	SerializeBase.WritePrimitive(writer, bundleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buycnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isautoexchange, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskMallBuyBundle = function(self, bundleid, buycnt, isautoexchange)
	return self.Invoke(self, 63249587, SerializerHelper.AskMallBuyBundle_Serializer, bundleid, buycnt, isautoexchange)
end

SerializerHelper.AskRemoveAllFish_Serializer = function(writer, placedinfo)
	SerializeBase.WriteComplex(writer, placedinfo, SerializeAuto.WriteFishPlacedInfo, "placedinfo", false)
end

ClientToGameDelegate.AskRemoveAllFish = function(self, placedinfo)
	return self.Invoke(self, 63250163, SerializerHelper.AskRemoveAllFish_Serializer, placedinfo)
end

SerializerHelper.AskGiveUpPoliceTask_Serializer = function(writer)
end

ClientToGameDelegate.AskGiveUpPoliceTask = function(self)
	return self.Invoke(self, 63254628, SerializerHelper.AskGiveUpPoliceTask_Serializer)
end

SerializerHelper.AskQueryFunplayHudData_Serializer = function(writer, gameplaylistids)
	SerializeBase.WriteList7Bit(writer, gameplaylistids, writer.WriteUInt32, 0, "gameplaylistids", false, RpcLengthLimits.IClientToGame_AskQueryFunplayHudData_gamePlayListIds, nil)
end

ClientToGameDelegate.AskQueryFunplayHudData = function(self, gameplaylistids)
	return self.Invoke(self, 63254781, SerializerHelper.AskQueryFunplayHudData_Serializer, gameplaylistids)
end

SerializerHelper.AskTradeRecycleFashion_Serializer = function(writer, tradeitemid, count)
	SerializeBase.WritePrimitive(writer, tradeitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTradeRecycleFashion = function(self, tradeitemid, count)
	return self.Invoke(self, 63256120, SerializerHelper.AskTradeRecycleFashion_Serializer, tradeitemid, count)
end

SerializerHelper.ChangeUgcMapComponentInfos_Serializer = function(writer, mapid, pointinfos)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, pointinfos, SerializeBase.WriteComplexWrap(SerializeAuto.WriteUgcComponentPointInfo, "UgcComponentPointInfo", false), nil, "pointinfos", false, RpcLengthLimits.IClientToGame_ChangeUgcMapComponentInfos_pointInfos, nil)
end

ClientToGameDelegate.ChangeUgcMapComponentInfos = function(self, mapid, pointinfos)
	return self.Invoke(self, 63257576, SerializerHelper.ChangeUgcMapComponentInfos_Serializer, mapid, pointinfos)
end

SerializerHelper.AskBuyRowBoatTicketDouble_Serializer = function(writer, conductorid, npccultivationid)
	SerializeBase.WritePrimitive(writer, conductorid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBuyRowBoatTicketDouble = function(self, conductorid, npccultivationid)
	return self.Invoke(self, 63257625, SerializerHelper.AskBuyRowBoatTicketDouble_Serializer, conductorid, npccultivationid)
end

SerializerHelper.AskFarmerFry_Serializer = function(writer, ruleid, count)
	SerializeBase.WritePrimitive(writer, ruleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFarmerFry = function(self, ruleid, count)
	return self.Invoke(self, 63258925, SerializerHelper.AskFarmerFry_Serializer, ruleid, count)
end

SerializerHelper.AskBatchUseItems_Serializer = function(writer, requests)
	SerializeBase.WriteDict7Bit(writer, requests, writer.WriteUInt64, writer.WriteUInt32, 0, "requests", false, RpcLengthLimits.IClientToGame_AskBatchUseItems_requests)
end

ClientToGameDelegate.AskBatchUseItems = function(self, requests)
	return self.Invoke(self, 63259670, SerializerHelper.AskBatchUseItems_Serializer, requests)
end

SerializerHelper.AskExitFortune_Serializer = function(writer, gadgetid)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskExitFortune = function(self, gadgetid)
	self.Notify(self, 63259865, SerializerHelper.AskExitFortune_Serializer, gadgetid)
end

SerializerHelper.FinishNewChallenge_Serializer = function(writer, challengeid, taskid)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.FinishNewChallenge = function(self, challengeid, taskid)
	return self.Invoke(self, 63261145, SerializerHelper.FinishNewChallenge_Serializer, challengeid, taskid)
end

SerializerHelper.AskTuiteGetTimelineData_Serializer = function(writer, tuiteid)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTuiteGetTimelineData = function(self, tuiteid)
	return self.Invoke(self, 63264230, SerializerHelper.AskTuiteGetTimelineData_Serializer, tuiteid)
end

SerializerHelper.JoinBasketballLinkAndInviteTeam_Serializer = function(writer, psnonly)
	SerializeBase.WritePrimitive(writer, psnonly, writer.WriteBoolean, false)
end

ClientToGameDelegate.JoinBasketballLinkAndInviteTeam = function(self, psnonly)
	self.Notify(self, 63265626, SerializerHelper.JoinBasketballLinkAndInviteTeam_Serializer, psnonly)
end

SerializerHelper.AskDestroyHouseParkingVehicles_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskDestroyHouseParkingVehicles = function(self, houseid)
	return self.Invoke(self, 63266373, SerializerHelper.AskDestroyHouseParkingVehicles_Serializer, houseid)
end

SerializerHelper.AskClearPersonalZoneNewBubbleLikes_Serializer = function(writer)
end

ClientToGameDelegate.AskClearPersonalZoneNewBubbleLikes = function(self)
	return self.Invoke(self, 63266395, SerializerHelper.AskClearPersonalZoneNewBubbleLikes_Serializer)
end

SerializerHelper.GetServerTimeGame_Serializer = function(writer, clientunixtime)
	SerializeBase.WritePrimitive(writer, clientunixtime, writer.WriteDouble, 0)
end

ClientToGameDelegate.GetServerTimeGame = function(self, clientunixtime)
	self.Notify(self, 63266454, SerializerHelper.GetServerTimeGame_Serializer, clientunixtime)
end

SerializerHelper.AskMarkNpcChatRead_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskMarkNpcChatRead = function(self, chatid)
	return self.Invoke(self, 63266674, SerializerHelper.AskMarkNpcChatRead_Serializer, chatid)
end

SerializerHelper.AskTakeOnlineSeasonProgressLevelReward_Serializer = function(writer, rewardid)
	SerializeBase.WritePrimitive(writer, rewardid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeOnlineSeasonProgressLevelReward = function(self, rewardid)
	return self.Invoke(self, 63271870, SerializerHelper.AskTakeOnlineSeasonProgressLevelReward_Serializer, rewardid)
end

SerializerHelper.RpcOpenPanel_Serializer = function(writer, panelid)
	SerializeBase.WritePrimitive(writer, panelid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.RpcOpenPanel = function(self, panelid)
	return self.Invoke(self, 63272255, SerializerHelper.RpcOpenPanel_Serializer, panelid)
end

SerializerHelper.AskGetUnlockedVehicles_Serializer = function(writer)
end

ClientToGameDelegate.AskGetUnlockedVehicles = function(self)
	return self.Invoke(self, 63272881, SerializerHelper.AskGetUnlockedVehicles_Serializer)
end

SerializerHelper.AskKickFriendFromLink_Serializer = function(writer, friendid)
	SerializeBase.WritePrimitive(writer, friendid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskKickFriendFromLink = function(self, friendid)
	return self.Invoke(self, 63274334, SerializerHelper.AskKickFriendFromLink_Serializer, friendid)
end

SerializerHelper.AskFishingSpotFullSync_Serializer = function(writer, fishgroupid)
	SerializeBase.WritePrimitive(writer, fishgroupid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFishingSpotFullSync = function(self, fishgroupid)
	return self.Invoke(self, 63275440, SerializerHelper.AskFishingSpotFullSync_Serializer, fishgroupid)
end

SerializerHelper.AskFeedback_Serializer = function(writer, feedbacktypes, description, urls)
	SerializeBase.WriteList7Bit(writer, feedbacktypes, writer.WriteUInt32, 0, "feedbacktypes", false, RpcLengthLimits.IClientToGame_AskFeedback_feedbackTypes, nil)
	writer.WriteString(writer, description, false, "AskFeedback.description", RpcLengthLimits.IClientToGame_AskFeedback_description)
	SerializeBase.WriteList7Bit(writer, urls, SerializeBase.WriteStringWrap(false, "urls", RpcLengthLimits.IClientToGame_AskFeedback_urls_String), nil, "urls", false, RpcLengthLimits.IClientToGame_AskFeedback_urls, nil)
end

ClientToGameDelegate.AskFeedback = function(self, feedbacktypes, description, urls)
	return self.Invoke(self, 63279787, SerializerHelper.AskFeedback_Serializer, feedbacktypes, description, urls)
end

SerializerHelper.AskClaimFactors_Serializer = function(writer)
end

ClientToGameDelegate.AskClaimFactors = function(self)
	return self.Invoke(self, 63280882, SerializerHelper.AskClaimFactors_Serializer)
end

SerializerHelper.AskPhoneAddContactGroup_Serializer = function(writer, spiritid, groupname)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer.WriteString(writer, groupname, false, "AskPhoneAddContactGroup.groupName", RpcLengthLimits.IClientToGame_AskPhoneAddContactGroup_groupName)
end

ClientToGameDelegate.AskPhoneAddContactGroup = function(self, spiritid, groupname)
	return self.Invoke(self, 63282540, SerializerHelper.AskPhoneAddContactGroup_Serializer, spiritid, groupname)
end

SerializerHelper.AskLeaveLink_Serializer = function(writer, mode)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskLeaveLink = function(self, mode)
	return self.Invoke(self, 63282978, SerializerHelper.AskLeaveLink_Serializer, mode)
end

SerializerHelper.AskTouchMapEntrance_Serializer = function(writer, raidid, mapentranceid)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, mapentranceid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTouchMapEntrance = function(self, raidid, mapentranceid)
	self.Notify(self, 63284182, SerializerHelper.AskTouchMapEntrance_Serializer, raidid, mapentranceid)
end

SerializerHelper.AskSwitchFightStyle_Serializer = function(writer, spiritid, fightstyletypeid, fightstyleid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fightstyletypeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fightstyleid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSwitchFightStyle = function(self, spiritid, fightstyletypeid, fightstyleid)
	return self.Invoke(self, 63285856, SerializerHelper.AskSwitchFightStyle_Serializer, spiritid, fightstyletypeid, fightstyleid)
end

SerializerHelper.AskAbortCardFlipGame_Serializer = function(writer)
end

ClientToGameDelegate.AskAbortCardFlipGame = function(self)
	return self.Invoke(self, 63287937, SerializerHelper.AskAbortCardFlipGame_Serializer)
end

SerializerHelper.AskRemoveFish_Serializer = function(writer, placedinfo, fishuniqueid)
	SerializeBase.WriteComplex(writer, placedinfo, SerializeAuto.WriteFishPlacedInfo, "placedinfo", false)
	SerializeBase.WritePrimitive(writer, fishuniqueid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskRemoveFish = function(self, placedinfo, fishuniqueid)
	return self.Invoke(self, 63290495, SerializerHelper.AskRemoveFish_Serializer, placedinfo, fishuniqueid)
end

SerializerHelper.AskDrawGacha_Serializer = function(writer, gachapoolid, drawcount, isautoexchange)
	SerializeBase.WritePrimitive(writer, gachapoolid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, drawcount, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isautoexchange, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskDrawGacha = function(self, gachapoolid, drawcount, isautoexchange)
	return self.Invoke(self, 63290913, SerializerHelper.AskDrawGacha_Serializer, gachapoolid, drawcount, isautoexchange)
end

SerializerHelper.AskTradeListItem_Serializer = function(writer, tradeitemid, count, price, days)
	SerializeBase.WritePrimitive(writer, tradeitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, price, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, days, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTradeListItem = function(self, tradeitemid, count, price, days)
	return self.Invoke(self, 63291047, SerializerHelper.AskTradeListItem_Serializer, tradeitemid, count, price, days)
end

SerializerHelper.AskExtractionShooterTransferAllToStash_Serializer = function(writer)
end

ClientToGameDelegate.AskExtractionShooterTransferAllToStash = function(self)
	return self.Invoke(self, 63291609, SerializerHelper.AskExtractionShooterTransferAllToStash_Serializer)
end

SerializerHelper.AskResetMobileSkinPart_Serializer = function(writer)
end

ClientToGameDelegate.AskResetMobileSkinPart = function(self)
	return self.Invoke(self, 63291656, SerializerHelper.AskResetMobileSkinPart_Serializer)
end

SerializerHelper.QueryQuestionnaire_Serializer = function(writer)
end

ClientToGameDelegate.QueryQuestionnaire = function(self)
	return self.Invoke(self, 63292493, SerializerHelper.QueryQuestionnaire_Serializer)
end

SerializerHelper.AskMallBuyCartItems_Serializer = function(writer, items, isautoexchange)
	SerializeBase.WriteList7Bit(writer, items, SerializeBase.WriteComplexWrap(SerializeAuto.WriteMallCartBuyItem, "MallCartBuyItem", false), nil, "items", false, RpcLengthLimits.IClientToGame_AskMallBuyCartItems_items, nil)
	SerializeBase.WritePrimitive(writer, isautoexchange, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskMallBuyCartItems = function(self, items, isautoexchange)
	return self.Invoke(self, 63292525, SerializerHelper.AskMallBuyCartItems_Serializer, items, isautoexchange)
end

SerializerHelper.AskStartPartyDance_Serializer = function(writer)
end

ClientToGameDelegate.AskStartPartyDance = function(self)
	return self.Invoke(self, 63292540, SerializerHelper.AskStartPartyDance_Serializer)
end

SerializerHelper.AskItemProduce_Serializer = function(writer, produceid, count, bias)
	SerializeBase.WritePrimitive(writer, produceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(bias, 18, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskItemProduce = function(self, produceid, count, bias)
	return self.Invoke(self, 63293120, SerializerHelper.AskItemProduce_Serializer, produceid, count, bias)
end

SerializerHelper.LiveHouseMusicStart_Serializer = function(writer, livehousemusicid, npcid, difficulty)
	SerializeBase.WritePrimitive(writer, livehousemusicid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, difficulty, writer.WriteUInt32, 0)
end

ClientToGameDelegate.LiveHouseMusicStart = function(self, livehousemusicid, npcid, difficulty)
	self.Notify(self, 63293678, SerializerHelper.LiveHouseMusicStart_Serializer, livehousemusicid, npcid, difficulty)
end

SerializerHelper.GetBeggarAiPaintingUploadUrl_Serializer = function(writer)
end

ClientToGameDelegate.GetBeggarAiPaintingUploadUrl = function(self)
	return self.Invoke(self, 63294837, SerializerHelper.GetBeggarAiPaintingUploadUrl_Serializer)
end

SerializerHelper.AskBuyVehicleFromMass_Serializer = function(writer, vehicleid, sendchat)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sendchat, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskBuyVehicleFromMass = function(self, vehicleid, sendchat)
	return self.Invoke(self, 63295543, SerializerHelper.AskBuyVehicleFromMass_Serializer, vehicleid, sendchat)
end

SerializerHelper.AskAcceptWasherMission_Serializer = function(writer, index, missionid)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, missionid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskAcceptWasherMission = function(self, index, missionid)
	return self.Invoke(self, 63297472, SerializerHelper.AskAcceptWasherMission_Serializer, index, missionid)
end

SerializerHelper.AskYachtUpgrade_Serializer = function(writer)
end

ClientToGameDelegate.AskYachtUpgrade = function(self)
	return self.Invoke(self, 63299431, SerializerHelper.AskYachtUpgrade_Serializer)
end

SerializerHelper.SyncBundles_Serializer = function(writer, bundles)
	SerializeBase.WriteList7Bit(writer, bundles, writer.WriteUInt32, 0, "bundles", false, RpcLengthLimits.IClientToGame_SyncBundles_bundles, nil)
end

ClientToGameDelegate.SyncBundles = function(self, bundles)
	self.Notify(self, 63300552, SerializerHelper.SyncBundles_Serializer, bundles)
end

SerializerHelper.InvitePlayerToPrepareRoom_Serializer = function(writer, inviteepid)
	SerializeBase.WritePrimitive(writer, inviteepid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.InvitePlayerToPrepareRoom = function(self, inviteepid)
	return self.Invoke(self, 63300992, SerializerHelper.InvitePlayerToPrepareRoom_Serializer, inviteepid)
end

SerializerHelper.AskSimulationInviteNpc_Serializer = function(writer, configid)
	SerializeBase.WritePrimitive(writer, configid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSimulationInviteNpc = function(self, configid)
	return self.Invoke(self, 63301526, SerializerHelper.AskSimulationInviteNpc_Serializer, configid)
end

SerializerHelper.AskStartEnsemble_Serializer = function(writer, soundid)
	SerializeBase.WritePrimitive(writer, soundid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartEnsemble = function(self, soundid)
	return self.Invoke(self, 63301592, SerializerHelper.AskStartEnsemble_Serializer, soundid)
end

SerializerHelper.AskTriggerNpcQueuedEvent_Serializer = function(writer, id, ismanual)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ismanual, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskTriggerNpcQueuedEvent = function(self, id, ismanual)
	return self.Invoke(self, 63302154, SerializerHelper.AskTriggerNpcQueuedEvent_Serializer, id, ismanual)
end

SerializerHelper.AskCreateClub_Serializer = function(writer, name, declaration, iconid, setting)
	writer.WriteString(writer, name, false, "AskCreateClub.name", RpcLengthLimits.IClientToGame_AskCreateClub_name)
	writer.WriteString(writer, declaration, true, "AskCreateClub.declaration", RpcLengthLimits.IClientToGame_AskCreateClub_declaration)
	SerializeBase.WritePrimitive(writer, iconid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteClubSetting, "setting", false)
end

ClientToGameDelegate.AskCreateClub = function(self, name, declaration, iconid, setting)
	return self.Invoke(self, 63303279, SerializerHelper.AskCreateClub_Serializer, name, declaration, iconid, setting)
end

SerializerHelper.AskReceiveChefRecipeRewardBatch_Serializer = function(writer, recipeid)
	SerializeBase.WritePrimitive(writer, recipeid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskReceiveChefRecipeRewardBatch = function(self, recipeid)
	return self.Invoke(self, 63303868, SerializerHelper.AskReceiveChefRecipeRewardBatch_Serializer, recipeid)
end

SerializerHelper.AskBartendingByDrinkMenu_Serializer = function(writer, bartenderid, drinkmenuid)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, drinkmenuid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBartendingByDrinkMenu = function(self, bartenderid, drinkmenuid)
	return self.Invoke(self, 63304927, SerializerHelper.AskBartendingByDrinkMenu_Serializer, bartenderid, drinkmenuid)
end

SerializerHelper.AskMomentsHaveUnreadMessage_Serializer = function(writer)
end

ClientToGameDelegate.AskMomentsHaveUnreadMessage = function(self)
	return self.Invoke(self, 63304982, SerializerHelper.AskMomentsHaveUnreadMessage_Serializer)
end

SerializerHelper.AskDeleteAISession_Serializer = function(writer, sessiontype, sessionid)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sessiontype, 6, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskDeleteAISession = function(self, sessiontype, sessionid)
	return self.Invoke(self, 63305057, SerializerHelper.AskDeleteAISession_Serializer, sessiontype, sessionid)
end

SerializerHelper.AskRemoveMailFromFavorites_Serializer = function(writer, mailid)
	SerializeBase.WritePrimitive(writer, mailid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskRemoveMailFromFavorites = function(self, mailid)
	return self.Invoke(self, 63307208, SerializerHelper.AskRemoveMailFromFavorites_Serializer, mailid)
end

SerializerHelper.AskIsArrested_Serializer = function(writer)
end

ClientToGameDelegate.AskIsArrested = function(self)
	return self.Invoke(self, 63307468, SerializerHelper.AskIsArrested_Serializer)
end

SerializerHelper.SendMobileBindSMS_Serializer = function(writer, phonenum)
	writer.WriteString(writer, phonenum, false, "SendMobileBindSMS.phoneNum", RpcLengthLimits.IClientToGame_SendMobileBindSMS_phoneNum)
end

ClientToGameDelegate.SendMobileBindSMS = function(self, phonenum)
	return self.Invoke(self, 63308061, SerializerHelper.SendMobileBindSMS_Serializer, phonenum)
end

SerializerHelper.AskWushuTournamentSeasonData_Serializer = function(writer)
end

ClientToGameDelegate.AskWushuTournamentSeasonData = function(self)
	return self.Invoke(self, 63308286, SerializerHelper.AskWushuTournamentSeasonData_Serializer)
end

SerializerHelper.AskPhoneAppDownload_Serializer = function(writer, appid)
	SerializeBase.WritePrimitive(writer, appid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPhoneAppDownload = function(self, appid)
	return self.Invoke(self, 63308287, SerializerHelper.AskPhoneAppDownload_Serializer, appid)
end

SerializerHelper.SyncChangeSafeArea_Serializer = function(writer, regionid)
	SerializeBase.WritePrimitive(writer, regionid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.SyncChangeSafeArea = function(self, regionid)
	self.Notify(self, 63310118, SerializerHelper.SyncChangeSafeArea_Serializer, regionid)
end

SerializerHelper.AskSetAnimalInteractionId_Serializer = function(writer, animalid, interactionid)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interactionid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSetAnimalInteractionId = function(self, animalid, interactionid)
	return self.Invoke(self, 63310210, SerializerHelper.AskSetAnimalInteractionId_Serializer, animalid, interactionid)
end

SerializerHelper.AskSendInteractionInfoToWatchee_Serializer = function(writer, type, isresponse)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isresponse, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskSendInteractionInfoToWatchee = function(self, type, isresponse)
	return self.Invoke(self, 63310335, SerializerHelper.AskSendInteractionInfoToWatchee_Serializer, type, isresponse)
end

SerializerHelper.AskDeleteTaskGroup_Serializer = function(writer, taskid, fail)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fail, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskDeleteTaskGroup = function(self, taskid, fail)
	return self.Invoke(self, 63311944, SerializerHelper.AskDeleteTaskGroup_Serializer, taskid, fail)
end

SerializerHelper.ChangeUgcMapDefinitionInfo_Serializer = function(writer, mapid, definitioninfo)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, definitioninfo, SerializeAuto.WriteUgcMapDefinitionInfo, "definitioninfo", false)
end

ClientToGameDelegate.ChangeUgcMapDefinitionInfo = function(self, mapid, definitioninfo)
	return self.Invoke(self, 63314612, SerializerHelper.ChangeUgcMapDefinitionInfo_Serializer, mapid, definitioninfo)
end

SerializerHelper.SaveCustomInteractionInfo_Serializer = function(writer, type, info)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
	writer.WriteString(writer, info, false, "SaveCustomInteractionInfo.info", RpcLengthLimits.IClientToGame_SaveCustomInteractionInfo_info)
end

ClientToGameDelegate.SaveCustomInteractionInfo = function(self, type, info)
	return self.Invoke(self, 63315549, SerializerHelper.SaveCustomInteractionInfo_Serializer, type, info)
end

SerializerHelper.AskUseFerrisWheelTicket_Serializer = function(writer, tickettype, ferriswheelid, npccultivationid)
	SerializeBase.WritePrimitive(writer, tickettype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, ferriswheelid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUseFerrisWheelTicket = function(self, tickettype, ferriswheelid, npccultivationid)
	return self.Invoke(self, 63317740, SerializerHelper.AskUseFerrisWheelTicket_Serializer, tickettype, ferriswheelid, npccultivationid)
end

SerializerHelper.AskSetBestNpcs_Serializer = function(writer, setbestnpcinfolist)
	SerializeBase.WriteList7Bit(writer, setbestnpcinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteBestNpcInfo, "BestNpcInfo", false), nil, "setbestnpcinfolist", false, RpcLengthLimits.IClientToGame_AskSetBestNpcs_setBestNpcInfoList, nil)
end

ClientToGameDelegate.AskSetBestNpcs = function(self, setbestnpcinfolist)
	return self.Invoke(self, 63319472, SerializerHelper.AskSetBestNpcs_Serializer, setbestnpcinfolist)
end

SerializerHelper.AskFavoriteFashions_Serializer = function(writer, unfavoritefashionidlist, favoritefashionidlist)
	SerializeBase.WriteList7Bit(writer, unfavoritefashionidlist, writer.WriteUInt32, 0, "unfavoritefashionidlist", true, RpcLengthLimits.IClientToGame_AskFavoriteFashions_unfavoriteFashionIdList, nil)
	SerializeBase.WriteList7Bit(writer, favoritefashionidlist, writer.WriteUInt32, 0, "favoritefashionidlist", true, RpcLengthLimits.IClientToGame_AskFavoriteFashions_favoriteFashionIdList, nil)
end

ClientToGameDelegate.AskFavoriteFashions = function(self, unfavoritefashionidlist, favoritefashionidlist)
	return self.Invoke(self, 63320432, SerializerHelper.AskFavoriteFashions_Serializer, unfavoritefashionidlist, favoritefashionidlist)
end

SerializerHelper.Exit_Serializer = function(writer)
end

ClientToGameDelegate.Exit = function(self)
	return self.Invoke(self, 63320834, SerializerHelper.Exit_Serializer)
end

SerializerHelper.GetFavorNpcRandomDialog_Serializer = function(writer, activityid, maintag, subtag)
	SerializeBase.WritePrimitive(writer, activityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maintag, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, subtag, writer.WriteUInt32, 0)
end

ClientToGameDelegate.GetFavorNpcRandomDialog = function(self, activityid, maintag, subtag)
	return self.Invoke(self, 63322429, SerializerHelper.GetFavorNpcRandomDialog_Serializer, activityid, maintag, subtag)
end

SerializerHelper.AskTimePanelInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskTimePanelInfo = function(self)
	return self.Invoke(self, 63323227, SerializerHelper.AskTimePanelInfo_Serializer)
end

SerializerHelper.AskSubmitTask_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSubmitTask = function(self, taskid)
	return self.Invoke(self, 63323631, SerializerHelper.AskSubmitTask_Serializer, taskid)
end

SerializerHelper.AskReadyToPlay_Serializer = function(writer, readystatus)
	SerializeBase.WritePrimitive(writer, readystatus, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskReadyToPlay = function(self, readystatus)
	return self.Invoke(self, 63328299, SerializerHelper.AskReadyToPlay_Serializer, readystatus)
end

SerializerHelper.AskChaosMasterGacha_Serializer = function(writer, poolid, count)
	SerializeBase.WritePrimitive(writer, poolid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskChaosMasterGacha = function(self, poolid, count)
	return self.Invoke(self, 63330194, SerializerHelper.AskChaosMasterGacha_Serializer, poolid, count)
end

SerializerHelper.AskSwitchHouseShowcaseAgent_Serializer = function(writer, houseid, placedinstanceid, modelindex, showcaseconfig)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, placedinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, modelindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, showcaseconfig, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSwitchHouseShowcaseAgent = function(self, houseid, placedinstanceid, modelindex, showcaseconfig)
	return self.Invoke(self, 63331812, SerializerHelper.AskSwitchHouseShowcaseAgent_Serializer, houseid, placedinstanceid, modelindex, showcaseconfig)
end

SerializerHelper.AskModifySpiritWearFashionsWithSource_Serializer = function(writer, spiritorinstanceid, source, unwearfashionidlist, wearfashioninfolist, uneditwearfashionidlist, editwearfashioneditinfolist)
	SerializeBase.WritePrimitive(writer, spiritorinstanceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, source, writer.WriteInt16, 0)
	SerializeBase.WriteList7Bit(writer, unwearfashionidlist, writer.WriteUInt32, 0, "unwearfashionidlist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionsWithSource_unwearFashionIdList, nil)
	SerializeBase.WriteList7Bit(writer, wearfashioninfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionInfo, "WearFashionInfo", true), nil, "wearfashioninfolist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionsWithSource_wearFashionInfoList, nil)
	SerializeBase.WriteList7Bit(writer, uneditwearfashionidlist, writer.WriteUInt32, 0, "uneditwearfashionidlist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionsWithSource_uneditWearFashionIdList, nil)
	SerializeBase.WriteList7Bit(writer, editwearfashioneditinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "editwearfashioneditinfolist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionsWithSource_editWearFashionEditInfoList, nil)
end

ClientToGameDelegate.AskModifySpiritWearFashionsWithSource = function(self, spiritorinstanceid, source, unwearfashionidlist, wearfashioninfolist, uneditwearfashionidlist, editwearfashioneditinfolist)
	return self.Invoke(self, 63333810, SerializerHelper.AskModifySpiritWearFashionsWithSource_Serializer, spiritorinstanceid, source, unwearfashionidlist, wearfashioninfolist, uneditwearfashionidlist, editwearfashioneditinfolist)
end

SerializerHelper.AskFinishJob_Serializer = function(writer)
end

ClientToGameDelegate.AskFinishJob = function(self)
	return self.Invoke(self, 63333823, SerializerHelper.AskFinishJob_Serializer)
end

SerializerHelper.NextGame_Serializer = function(writer, roomtype, basescore)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(roomtype, 12, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, basescore, writer.WriteInt32, 0)
end

ClientToGameDelegate.NextGame = function(self, roomtype, basescore)
	self.Notify(self, 63334786, SerializerHelper.NextGame_Serializer, roomtype, basescore)
end

SerializerHelper.AskExitCustomLink_Serializer = function(writer)
end

ClientToGameDelegate.AskExitCustomLink = function(self)
	return self.Invoke(self, 63335203, SerializerHelper.AskExitCustomLink_Serializer)
end

SerializerHelper.AskClearAbilityRedPoint_Serializer = function(writer, spiritid, abilityid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, abilityid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskClearAbilityRedPoint = function(self, spiritid, abilityid)
	return self.Invoke(self, 63338173, SerializerHelper.AskClearAbilityRedPoint_Serializer, spiritid, abilityid)
end

SerializerHelper.AskPlayerFarmerProcess_Serializer = function(writer, type, itemcountinfos)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 19, 0), writer.WriteByte, 0)
	SerializeBase.WriteList7Bit(writer, itemcountinfos, SerializeBase.WriteComplexWrap(SerializeAuto.WriteItemCountInfo, "ItemCountInfo", false), nil, "itemcountinfos", false, RpcLengthLimits.IClientToGame_AskPlayerFarmerProcess_itemCountInfos, nil)
end

ClientToGameDelegate.AskPlayerFarmerProcess = function(self, type, itemcountinfos)
	self.Notify(self, 63338504, SerializerHelper.AskPlayerFarmerProcess_Serializer, type, itemcountinfos)
end

SerializerHelper.AskResetSpiritJobTalent_Serializer = function(writer, spiritid, jobclassid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskResetSpiritJobTalent = function(self, spiritid, jobclassid)
	return self.Invoke(self, 63343248, SerializerHelper.AskResetSpiritJobTalent_Serializer, spiritid, jobclassid)
end

SerializerHelper.AskGetTruckSatisfactionAverage_Serializer = function(writer)
end

ClientToGameDelegate.AskGetTruckSatisfactionAverage = function(self)
	return self.Invoke(self, 63344040, SerializerHelper.AskGetTruckSatisfactionAverage_Serializer)
end

SerializerHelper.AskRemovePersonalZoneRedSpot_Serializer = function(writer, type, itemid)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 20, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskRemovePersonalZoneRedSpot = function(self, type, itemid)
	return self.Invoke(self, 63344598, SerializerHelper.AskRemovePersonalZoneRedSpot_Serializer, type, itemid)
end

SerializerHelper.AskAidByPid_Serializer = function(writer, pids)
	SerializeBase.WriteList7Bit(writer, pids, writer.WriteUInt64, 0, "pids", false, RpcLengthLimits.IClientToGame_AskAidByPid_pids, nil)
end

ClientToGameDelegate.AskAidByPid = function(self, pids)
	return self.Invoke(self, 63346485, SerializerHelper.AskAidByPid_Serializer, pids)
end

SerializerHelper.AskDeleteMails_Serializer = function(writer, ids)
	SerializeBase.WriteList7Bit(writer, ids, writer.WriteUInt64, 0, "ids", false, RpcLengthLimits.IClientToGame_AskDeleteMails_ids, nil)
end

ClientToGameDelegate.AskDeleteMails = function(self, ids)
	return self.Invoke(self, 63346499, SerializerHelper.AskDeleteMails_Serializer, ids)
end

SerializerHelper.AskSetSpiritFashions_Serializer = function(writer, spiritid, spiritwearfashionsinfo)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, spiritwearfashionsinfo, SerializeAuto.WriteSpiritWearFashionsInfo, "spiritwearfashionsinfo", false)
end

ClientToGameDelegate.AskSetSpiritFashions = function(self, spiritid, spiritwearfashionsinfo)
	return self.Invoke(self, 63347169, SerializerHelper.AskSetSpiritFashions_Serializer, spiritid, spiritwearfashionsinfo)
end

SerializerHelper.AskStartSingleMatch_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartSingleMatch = function(self, gameid)
	return self.Invoke(self, 63347492, SerializerHelper.AskStartSingleMatch_Serializer, gameid)
end

SerializerHelper.LeavePartyRoom_Serializer = function(writer)
end

ClientToGameDelegate.LeavePartyRoom = function(self)
	self.Notify(self, 63347667, SerializerHelper.LeavePartyRoom_Serializer)
end

SerializerHelper.TryInteractOuterStory_Serializer = function(writer, npccultivationid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.TryInteractOuterStory = function(self, npccultivationid)
	self.Notify(self, 63349091, SerializerHelper.TryInteractOuterStory_Serializer, npccultivationid)
end

SerializerHelper.KTVMusicStart_Serializer = function(writer, musicid)
	SerializeBase.WritePrimitive(writer, musicid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.KTVMusicStart = function(self, musicid)
	return self.Invoke(self, 63351848, SerializerHelper.KTVMusicStart_Serializer, musicid)
end

SerializerHelper.AskMallUpdateCartItemCount_Serializer = function(writer, items)
	SerializeBase.WriteList7Bit(writer, items, SerializeBase.WriteComplexWrap(SerializeAuto.WriteMallCartBuyItem, "MallCartBuyItem", false), nil, "items", false, RpcLengthLimits.IClientToGame_AskMallUpdateCartItemCount_items, nil)
end

ClientToGameDelegate.AskMallUpdateCartItemCount = function(self, items)
	return self.Invoke(self, 63354768, SerializerHelper.AskMallUpdateCartItemCount_Serializer, items)
end

SerializerHelper.AskRemoveBuildHouseIndoor_Serializer = function(writer, houseid, floor, removeplacedinstanceidlist)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, removeplacedinstanceidlist, writer.WriteUInt64, 0, "removeplacedinstanceidlist", false, RpcLengthLimits.IClientToGame_AskRemoveBuildHouseIndoor_removePlacedInstanceIdList, nil)
end

ClientToGameDelegate.AskRemoveBuildHouseIndoor = function(self, houseid, floor, removeplacedinstanceidlist)
	return self.Invoke(self, 63356091, SerializerHelper.AskRemoveBuildHouseIndoor_Serializer, houseid, floor, removeplacedinstanceidlist)
end

SerializerHelper.AskQueryAllFavorNpcAgentPos_Serializer = function(writer)
end

ClientToGameDelegate.AskQueryAllFavorNpcAgentPos = function(self)
	return self.Invoke(self, 63357395, SerializerHelper.AskQueryAllFavorNpcAgentPos_Serializer)
end

SerializerHelper.AskGeneralBuyBackItemToShop_Serializer = function(writer, shopid, iteminstanceid, count)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, iteminstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskGeneralBuyBackItemToShop = function(self, shopid, iteminstanceid, count)
	return self.Invoke(self, 63358211, SerializerHelper.AskGeneralBuyBackItemToShop_Serializer, shopid, iteminstanceid, count)
end

SerializerHelper.AskPidByAid_Serializer = function(writer, aids)
	SerializeBase.WriteList7Bit(writer, aids, writer.WriteInt32, 0, "aids", false, RpcLengthLimits.IClientToGame_AskPidByAid_aids, nil)
end

ClientToGameDelegate.AskPidByAid = function(self, aids)
	return self.Invoke(self, 63358436, SerializerHelper.AskPidByAid_Serializer, aids)
end

SerializerHelper.AskStartRPSInterrogation_Serializer = function(writer, caseid)
	SerializeBase.WritePrimitive(writer, caseid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskStartRPSInterrogation = function(self, caseid)
	return self.Invoke(self, 63361257, SerializerHelper.AskStartRPSInterrogation_Serializer, caseid)
end

SerializerHelper.AskUnloadHouse_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUnloadHouse = function(self, houseid)
	return self.Invoke(self, 63362685, SerializerHelper.AskUnloadHouse_Serializer, houseid)
end

SerializerHelper.AskReplyInvitePlayerInteractionAction_Serializer = function(writer, replystate)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(replystate, 21, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskReplyInvitePlayerInteractionAction = function(self, replystate)
	return self.Invoke(self, 63363240, SerializerHelper.AskReplyInvitePlayerInteractionAction_Serializer, replystate)
end

SerializerHelper.AskSelectPartyDanceSong_Serializer = function(writer, musicid)
	SerializeBase.WritePrimitive(writer, musicid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSelectPartyDanceSong = function(self, musicid)
	return self.Invoke(self, 63363245, SerializerHelper.AskSelectPartyDanceSong_Serializer, musicid)
end

SerializerHelper.AskInterruptInterrogation_Serializer = function(writer, caseid)
	SerializeBase.WritePrimitive(writer, caseid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskInterruptInterrogation = function(self, caseid)
	return self.Invoke(self, 63364512, SerializerHelper.AskInterruptInterrogation_Serializer, caseid)
end

SerializerHelper.AskDivinerLiveChatInteract_Serializer = function(writer, eventid, lang)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	writer.WriteString(writer, lang, false, "AskDivinerLiveChatInteract.lang", RpcLengthLimits.IClientToGame_AskDivinerLiveChatInteract_lang)
end

ClientToGameDelegate.AskDivinerLiveChatInteract = function(self, eventid, lang)
	return self.Invoke(self, 63365557, SerializerHelper.AskDivinerLiveChatInteract_Serializer, eventid, lang)
end

SerializerHelper.AskResetGameplayTalent_Serializer = function(writer, gameplayid)
	SerializeBase.WritePrimitive(writer, gameplayid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskResetGameplayTalent = function(self, gameplayid)
	return self.Invoke(self, 63365723, SerializerHelper.AskResetGameplayTalent_Serializer, gameplayid)
end

SerializerHelper.TryInteractVoice_Serializer = function(writer, npccultivationid, voiceid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, voiceid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.TryInteractVoice = function(self, npccultivationid, voiceid)
	self.Notify(self, 63368582, SerializerHelper.TryInteractVoice_Serializer, npccultivationid, voiceid)
end

SerializerHelper.AskModifySpiritWearFashionsOnlyWear_Serializer = function(writer, spiritid, unwearfashionidlist, wearfashioninfolist)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, unwearfashionidlist, writer.WriteUInt32, 0, "unwearfashionidlist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionsOnlyWear_unwearFashionIdList, nil)
	SerializeBase.WriteList7Bit(writer, wearfashioninfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionInfo, "WearFashionInfo", true), nil, "wearfashioninfolist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionsOnlyWear_wearFashionInfoList, nil)
end

ClientToGameDelegate.AskModifySpiritWearFashionsOnlyWear = function(self, spiritid, unwearfashionidlist, wearfashioninfolist)
	return self.Invoke(self, 63370160, SerializerHelper.AskModifySpiritWearFashionsOnlyWear_Serializer, spiritid, unwearfashionidlist, wearfashioninfolist)
end

SerializerHelper.StartUgcMapEditingComponentInfo_Serializer = function(writer, mapid)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.StartUgcMapEditingComponentInfo = function(self, mapid)
	return self.Invoke(self, 63371042, SerializerHelper.StartUgcMapEditingComponentInfo_Serializer, mapid)
end

SerializerHelper.AskChangeYachtName_Serializer = function(writer, name)
	writer.WriteString(writer, name, false, "AskChangeYachtName.name", RpcLengthLimits.IClientToGame_AskChangeYachtName_name)
end

ClientToGameDelegate.AskChangeYachtName = function(self, name)
	return self.Invoke(self, 63372042, SerializerHelper.AskChangeYachtName_Serializer, name)
end

SerializerHelper.AskManualRefreshBuyback_Serializer = function(writer, shopid)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskManualRefreshBuyback = function(self, shopid)
	return self.Invoke(self, 63374366, SerializerHelper.AskManualRefreshBuyback_Serializer, shopid)
end

SerializerHelper.SetMiniGame_BeeScore_Serializer = function(writer, scores)
	SerializeBase.WriteList7Bit(writer, scores, writer.WriteUInt32, 0, "scores", false, RpcLengthLimits.IClientToGame_SetMiniGame_BeeScore_scores, nil)
end

ClientToGameDelegate.SetMiniGame_BeeScore = function(self, scores)
	return self.Invoke(self, 63375767, SerializerHelper.SetMiniGame_BeeScore_Serializer, scores)
end

SerializerHelper.GetMailHeadList_Serializer = function(writer)
end

ClientToGameDelegate.GetMailHeadList = function(self)
	return self.Invoke(self, 63378189, SerializerHelper.GetMailHeadList_Serializer)
end

SerializerHelper.AskResetTruckOrderGoods_Serializer = function(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskResetTruckOrderGoods = function(self, orderid)
	return self.Invoke(self, 63383400, SerializerHelper.AskResetTruckOrderGoods_Serializer, orderid)
end

SerializerHelper.AskTierByMultiPlayerId_Serializer = function(writer, multiplayerid)
	SerializeBase.WritePrimitive(writer, multiplayerid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTierByMultiPlayerId = function(self, multiplayerid)
	return self.Invoke(self, 63385167, SerializerHelper.AskTierByMultiPlayerId_Serializer, multiplayerid)
end

SerializerHelper.AskGetTruckJobOrders_Serializer = function(writer)
end

ClientToGameDelegate.AskGetTruckJobOrders = function(self)
	return self.Invoke(self, 63386469, SerializerHelper.AskGetTruckJobOrders_Serializer)
end

SerializerHelper.AskModifySpiritWearFashionEditInfosWithSource_Serializer = function(writer, spiritorinstanceid, source, uneditwearfashionidlist, editwearfashioneditinfolist)
	SerializeBase.WritePrimitive(writer, spiritorinstanceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, source, writer.WriteInt16, 0)
	SerializeBase.WriteList7Bit(writer, uneditwearfashionidlist, writer.WriteUInt32, 0, "uneditwearfashionidlist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionEditInfosWithSource_uneditWearFashionIdList, nil)
	SerializeBase.WriteList7Bit(writer, editwearfashioneditinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "editwearfashioneditinfolist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionEditInfosWithSource_editWearFashionEditInfoList, nil)
end

ClientToGameDelegate.AskModifySpiritWearFashionEditInfosWithSource = function(self, spiritorinstanceid, source, uneditwearfashionidlist, editwearfashioneditinfolist)
	return self.Invoke(self, 63387455, SerializerHelper.AskModifySpiritWearFashionEditInfosWithSource_Serializer, spiritorinstanceid, source, uneditwearfashionidlist, editwearfashioneditinfolist)
end

SerializerHelper.AskJoinPartyRoom_Serializer = function(writer, roomid, password)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
	writer.WriteString(writer, password, true, "AskJoinPartyRoom.password", RpcLengthLimits.IClientToGame_AskJoinPartyRoom_password)
end

ClientToGameDelegate.AskJoinPartyRoom = function(self, roomid, password)
	return self.Invoke(self, 63388288, SerializerHelper.AskJoinPartyRoom_Serializer, roomid, password)
end

SerializerHelper.SwitchLinkByTag_Serializer = function(writer, tag, inviteteam, publiceventid, reason)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(tag, 22, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, inviteteam, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, publiceventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(reason, 23, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.SwitchLinkByTag = function(self, tag, inviteteam, publiceventid, reason)
	return self.Invoke(self, 63392401, SerializerHelper.SwitchLinkByTag_Serializer, tag, inviteteam, publiceventid, reason)
end

SerializerHelper.AskPartySettleLike_Serializer = function(writer, targetpid)
	SerializeBase.WritePrimitive(writer, targetpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskPartySettleLike = function(self, targetpid)
	return self.Invoke(self, 63393115, SerializerHelper.AskPartySettleLike_Serializer, targetpid)
end

SerializerHelper.AskCancelInviteePlayerInteractionAction_Serializer = function(writer, immediatecanceltrustee)
	SerializeBase.WritePrimitive(writer, immediatecanceltrustee, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskCancelInviteePlayerInteractionAction = function(self, immediatecanceltrustee)
	return self.Invoke(self, 63393410, SerializerHelper.AskCancelInviteePlayerInteractionAction_Serializer, immediatecanceltrustee)
end

SerializerHelper.RpcCollectionBookConvertToSkin_Serializer = function(writer, bagid, cellx, celly)
	SerializeBase.WritePrimitive(writer, bagid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
end

ClientToGameDelegate.RpcCollectionBookConvertToSkin = function(self, bagid, cellx, celly)
	return self.Invoke(self, 63394223, SerializerHelper.RpcCollectionBookConvertToSkin_Serializer, bagid, cellx, celly)
end

SerializerHelper.PartyOver_Serializer = function(writer)
end

ClientToGameDelegate.PartyOver = function(self)
	return self.Invoke(self, 63396665, SerializerHelper.PartyOver_Serializer)
end

SerializerHelper.AskLinkWatcheeList_Serializer = function(writer)
end

ClientToGameDelegate.AskLinkWatcheeList = function(self)
	return self.Invoke(self, 63398921, SerializerHelper.AskLinkWatcheeList_Serializer)
end

SerializerHelper.AskGetNpcRandomWearFashions_Serializer = function(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskGetNpcRandomWearFashions = function(self, spiritid)
	return self.Invoke(self, 63398939, SerializerHelper.AskGetNpcRandomWearFashions_Serializer, spiritid)
end

SerializerHelper.DiscardTile_Serializer = function(writer, info)
	SerializeBase.WriteStruct(writer, info, SerializeAuto.WriteDiscardTileInfo, "info")
end

ClientToGameDelegate.DiscardTile = function(self, info)
	self.Notify(self, 63399529, SerializerHelper.DiscardTile_Serializer, info)
end

SerializerHelper.AskTamagotchiInteractReply_Serializer = function(writer, interacttype, pid, agree)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(interacttype, 24, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agree, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskTamagotchiInteractReply = function(self, interacttype, pid, agree)
	return self.Invoke(self, 63403866, SerializerHelper.AskTamagotchiInteractReply_Serializer, interacttype, pid, agree)
end

SerializerHelper.AskGetAchievementReward_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskGetAchievementReward = function(self, id)
	return self.Invoke(self, 63409349, SerializerHelper.AskGetAchievementReward_Serializer, id)
end

SerializerHelper.AskReportJoystickChange_Serializer = function(writer, joystickinfo)
	writer.WriteString(writer, joystickinfo, false, "AskReportJoystickChange.joystickInfo", RpcLengthLimits.IClientToGame_AskReportJoystickChange_joystickInfo)
end

ClientToGameDelegate.AskReportJoystickChange = function(self, joystickinfo)
	self.Notify(self, 63410673, SerializerHelper.AskReportJoystickChange_Serializer, joystickinfo)
end

SerializerHelper.AskSaveSettings_Serializer = function(writer, settings)
	SerializeBase.WriteDict7Bit(writer, settings, writer.WriteUInt32, SerializeBase.WriteComplexWrap(SerializeAuto.WritePlayerSettingValue, "PlayerSettingValue", false), nil, "settings", false, RpcLengthLimits.IClientToGame_AskSaveSettings_settings)
end

ClientToGameDelegate.AskSaveSettings = function(self, settings)
	return self.Invoke(self, 63411797, SerializerHelper.AskSaveSettings_Serializer, settings)
end

SerializerHelper.AskUpdatePlayerAvatarFrame_Serializer = function(writer, avatarframeid)
	SerializeBase.WritePrimitive(writer, avatarframeid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUpdatePlayerAvatarFrame = function(self, avatarframeid)
	return self.Invoke(self, 63413183, SerializerHelper.AskUpdatePlayerAvatarFrame_Serializer, avatarframeid)
end

SerializerHelper.AskTakeJob_Serializer = function(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeJob = function(self, jobclassid)
	return self.Invoke(self, 63414583, SerializerHelper.AskTakeJob_Serializer, jobclassid)
end

SerializerHelper.AskMahjongWorldBattleReady_Serializer = function(writer, gadgetid, ready)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, ready, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskMahjongWorldBattleReady = function(self, gadgetid, ready)
	return self.Invoke(self, 63415722, SerializerHelper.AskMahjongWorldBattleReady_Serializer, gadgetid, ready)
end

SerializerHelper.AskGeneralBuyBackExtractionShooterItemToShop_Serializer = function(writer, shopid, slots)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, slots, SerializeBase.WriteComplexWrap(SerializeAuto.WriteExtractionShooterSellItemInfo, "ExtractionShooterSellItemInfo", false), nil, "slots", false, RpcLengthLimits.IClientToGame_AskGeneralBuyBackExtractionShooterItemToShop_slots, nil)
end

ClientToGameDelegate.AskGeneralBuyBackExtractionShooterItemToShop = function(self, shopid, slots)
	return self.Invoke(self, 63420185, SerializerHelper.AskGeneralBuyBackExtractionShooterItemToShop_Serializer, shopid, slots)
end

SerializerHelper.UnlockInvestigateGallery_Serializer = function(writer, galleryid, reason)
	SerializeBase.WritePrimitive(writer, galleryid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(reason, 25, 0), writer.WriteInt32, 0)
end

ClientToGameDelegate.UnlockInvestigateGallery = function(self, galleryid, reason)
	self.Notify(self, 63420503, SerializerHelper.UnlockInvestigateGallery_Serializer, galleryid, reason)
end

SerializerHelper.AskAcceptTask_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskAcceptTask = function(self, taskid)
	return self.Invoke(self, 63422116, SerializerHelper.AskAcceptTask_Serializer, taskid)
end

SerializerHelper.AskFarmerShopRemoveItem_Serializer = function(writer, shopslotindex)
	SerializeBase.WritePrimitive(writer, shopslotindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskFarmerShopRemoveItem = function(self, shopslotindex)
	return self.Invoke(self, 63426651, SerializerHelper.AskFarmerShopRemoveItem_Serializer, shopslotindex)
end

SerializerHelper.AskDiscardArmoryWeapon_Serializer = function(writer, weaponinstanceid, isdropout)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isdropout, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskDiscardArmoryWeapon = function(self, weaponinstanceid, isdropout)
	return self.Invoke(self, 63426982, SerializerHelper.AskDiscardArmoryWeapon_Serializer, weaponinstanceid, isdropout)
end

SerializerHelper.RequestGameSceneData_Serializer = function(writer)
end

ClientToGameDelegate.RequestGameSceneData = function(self)
	self.Notify(self, 63427902, SerializerHelper.RequestGameSceneData_Serializer)
end

SerializerHelper.AskFarmerCompleteOrder_Serializer = function(writer, orderconfigid)
	SerializeBase.WritePrimitive(writer, orderconfigid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFarmerCompleteOrder = function(self, orderconfigid)
	return self.Invoke(self, 63428172, SerializerHelper.AskFarmerCompleteOrder_Serializer, orderconfigid)
end

SerializerHelper.AskOCSetControllerByteValue_Serializer = function(writer, ocid, controllerid, value)
	SerializeBase.WritePrimitive(writer, ocid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, controllerid, writer.WriteUInt16, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteByte, 0)
end

ClientToGameDelegate.AskOCSetControllerByteValue = function(self, ocid, controllerid, value)
	return self.Invoke(self, 63430253, SerializerHelper.AskOCSetControllerByteValue_Serializer, ocid, controllerid, value)
end

SerializerHelper.AskChangeClubMemberJobType_Serializer = function(writer, clubid, memberpid, jobtype)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(jobtype, 26, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskChangeClubMemberJobType = function(self, clubid, memberpid, jobtype)
	return self.Invoke(self, 63430373, SerializerHelper.AskChangeClubMemberJobType_Serializer, clubid, memberpid, jobtype)
end

SerializerHelper.AskShoulderPoleFallDown_Serializer = function(writer)
end

ClientToGameDelegate.AskShoulderPoleFallDown = function(self)
	return self.Invoke(self, 63431841, SerializerHelper.AskShoulderPoleFallDown_Serializer)
end

SerializerHelper.AskReportQualitySetting_Serializer = function(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteClientQualitySetting, "setting", false)
end

ClientToGameDelegate.AskReportQualitySetting = function(self, setting)
	self.Notify(self, 63432654, SerializerHelper.AskReportQualitySetting_Serializer, setting)
end

SerializerHelper.AskTuiteCreateComment_Serializer = function(writer, tuiteid, content)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
	writer.WriteString(writer, content, false, "AskTuiteCreateComment.content", RpcLengthLimits.IClientToGame_AskTuiteCreateComment_content)
end

ClientToGameDelegate.AskTuiteCreateComment = function(self, tuiteid, content)
	return self.Invoke(self, 63432933, SerializerHelper.AskTuiteCreateComment_Serializer, tuiteid, content)
end

SerializerHelper.AskGiftFriend_Serializer = function(writer, receiverpid, commodityid, bundleid, isautoexchange, giftmessage)
	SerializeBase.WritePrimitive(writer, receiverpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, bundleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isautoexchange, writer.WriteBoolean, false)
	writer.WriteString(writer, giftmessage, false, "AskGiftFriend.giftMessage", RpcLengthLimits.IClientToGame_AskGiftFriend_giftMessage)
end

ClientToGameDelegate.AskGiftFriend = function(self, receiverpid, commodityid, bundleid, isautoexchange, giftmessage)
	return self.Invoke(self, 63434263, SerializerHelper.AskGiftFriend_Serializer, receiverpid, commodityid, bundleid, isautoexchange, giftmessage)
end

SerializerHelper.AskReadHUDRecommend_Serializer = function(writer, targetapp)
	SerializeBase.WritePrimitive(writer, targetapp, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskReadHUDRecommend = function(self, targetapp)
	return self.Invoke(self, 63434751, SerializerHelper.AskReadHUDRecommend_Serializer, targetapp)
end

SerializerHelper.AskRecommendGetTopWearFashionTagId_Serializer = function(writer)
end

ClientToGameDelegate.AskRecommendGetTopWearFashionTagId = function(self)
	return self.Invoke(self, 63435075, SerializerHelper.AskRecommendGetTopWearFashionTagId_Serializer)
end

SerializerHelper.AskItemStartCompound_Serializer = function(writer, compoundid, stationid, count, materials)
	SerializeBase.WritePrimitive(writer, compoundid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, materials, SerializeAuto.WriteSubmitItemInfo, "materials", true)
end

ClientToGameDelegate.AskItemStartCompound = function(self, compoundid, stationid, count, materials)
	return self.Invoke(self, 63435096, SerializerHelper.AskItemStartCompound_Serializer, compoundid, stationid, count, materials)
end

SerializerHelper.AskCancelInviterPlayerInteractionAction_Serializer = function(writer)
end

ClientToGameDelegate.AskCancelInviterPlayerInteractionAction = function(self)
	return self.Invoke(self, 63438568, SerializerHelper.AskCancelInviterPlayerInteractionAction_Serializer)
end

SerializerHelper.AskBartenderCustomerLeave_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskBartenderCustomerLeave = function(self, id)
	return self.Invoke(self, 63438863, SerializerHelper.AskBartenderCustomerLeave_Serializer, id)
end

SerializerHelper.AskFarmerShopSetPrice_Serializer = function(writer, shopslotindex, price)
	SerializeBase.WritePrimitive(writer, shopslotindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, price, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFarmerShopSetPrice = function(self, shopslotindex, price)
	return self.Invoke(self, 63440238, SerializerHelper.AskFarmerShopSetPrice_Serializer, shopslotindex, price)
end

SerializerHelper.AskFinishGuideTeachRead_Serializer = function(writer, guideteachid)
	SerializeBase.WritePrimitive(writer, guideteachid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFinishGuideTeachRead = function(self, guideteachid)
	return self.Invoke(self, 63440503, SerializerHelper.AskFinishGuideTeachRead_Serializer, guideteachid)
end

SerializerHelper.AskReadFashions_Serializer = function(writer, fashionidlist)
	SerializeBase.WriteList7Bit(writer, fashionidlist, writer.WriteUInt32, 0, "fashionidlist", false, RpcLengthLimits.IClientToGame_AskReadFashions_fashionIdList, nil)
end

ClientToGameDelegate.AskReadFashions = function(self, fashionidlist)
	return self.Invoke(self, 63441237, SerializerHelper.AskReadFashions_Serializer, fashionidlist)
end

SerializerHelper.AskStartJob_Serializer = function(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartJob = function(self, jobclassid)
	return self.Invoke(self, 63441623, SerializerHelper.AskStartJob_Serializer, jobclassid)
end

SerializerHelper.AskQueryGadgetStuntJumpRecord_Serializer = function(writer, gadgetid)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskQueryGadgetStuntJumpRecord = function(self, gadgetid)
	return self.Invoke(self, 63442535, SerializerHelper.AskQueryGadgetStuntJumpRecord_Serializer, gadgetid)
end

SerializerHelper.ClaimCityPediaLevelReward_Serializer = function(writer, leveltoclaim)
	SerializeBase.WritePrimitive(writer, leveltoclaim, writer.WriteUInt32, 0)
end

ClientToGameDelegate.ClaimCityPediaLevelReward = function(self, leveltoclaim)
	return self.Invoke(self, 63444462, SerializerHelper.ClaimCityPediaLevelReward_Serializer, leveltoclaim)
end

SerializerHelper.AskTakeAllOnlineSeasonProgressRewards_Serializer = function(writer)
end

ClientToGameDelegate.AskTakeAllOnlineSeasonProgressRewards = function(self)
	return self.Invoke(self, 63445431, SerializerHelper.AskTakeAllOnlineSeasonProgressRewards_Serializer)
end

SerializerHelper.CheckBotMatchState_Serializer = function(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.CheckBotMatchState = function(self, roomid)
	return self.Invoke(self, 63445450, SerializerHelper.CheckBotMatchState_Serializer, roomid)
end

SerializerHelper.InviteMultiNpcChat_Serializer = function(writer, chatid, npclist)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, npclist, writer.WriteUInt32, 0, "npclist", false, RpcLengthLimits.IClientToGame_InviteMultiNpcChat_npcList, nil)
end

ClientToGameDelegate.InviteMultiNpcChat = function(self, chatid, npclist)
	return self.Invoke(self, 63447141, SerializerHelper.InviteMultiNpcChat_Serializer, chatid, npclist)
end

SerializerHelper.AskMomentsTapPost_Serializer = function(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskMomentsTapPost = function(self, postid)
	return self.Invoke(self, 63447304, SerializerHelper.AskMomentsTapPost_Serializer, postid)
end

SerializerHelper.AskUploadPlayerConfig_Serializer = function(writer, config)
	SerializeBase.WriteList7Bit(writer, config, writer.WriteByte, 0, "config", false, RpcLengthLimits.IClientToGame_AskUploadPlayerConfig_config, nil)
end

ClientToGameDelegate.AskUploadPlayerConfig = function(self, config)
	self.Notify(self, 63449579, SerializerHelper.AskUploadPlayerConfig_Serializer, config)
end

SerializerHelper.AskHouseHostVisit_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskHouseHostVisit = function(self, houseid)
	return self.Invoke(self, 63449971, SerializerHelper.AskHouseHostVisit_Serializer, houseid)
end

SerializerHelper.AskClawSettlement_Serializer = function(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteClawSettlementInfo, "info", false)
end

ClientToGameDelegate.AskClawSettlement = function(self, info)
	return self.Invoke(self, 63451209, SerializerHelper.AskClawSettlement_Serializer, info)
end

SerializerHelper.SyncPSNSessionId_Serializer = function(writer, sessionid)
	writer.WriteString(writer, sessionid, false, "SyncPSNSessionId.sessionId", RpcLengthLimits.IClientToGame_SyncPSNSessionId_sessionId)
end

ClientToGameDelegate.SyncPSNSessionId = function(self, sessionid)
	return self.Invoke(self, 63451951, SerializerHelper.SyncPSNSessionId_Serializer, sessionid)
end

SerializerHelper.AskMomentsPostSimpleInfos_Serializer = function(writer, lastid, posttype)
	SerializeBase.WritePrimitive(writer, lastid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(posttype, 27, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskMomentsPostSimpleInfos = function(self, lastid, posttype)
	return self.Invoke(self, 63452251, SerializerHelper.AskMomentsPostSimpleInfos_Serializer, lastid, posttype)
end

SerializerHelper.JoinCinemaLink_Serializer = function(writer, psnonly)
	SerializeBase.WritePrimitive(writer, psnonly, writer.WriteBoolean, false)
end

ClientToGameDelegate.JoinCinemaLink = function(self, psnonly)
	self.Notify(self, 63452616, SerializerHelper.JoinCinemaLink_Serializer, psnonly)
end

SerializerHelper.AskSetSpiritWearFashionHiddenPartsWithSource_Serializer = function(writer, spiritorinstanceid, source, hiddenparts)
	SerializeBase.WritePrimitive(writer, spiritorinstanceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, source, writer.WriteInt16, 0)
	SerializeBase.WritePrimitive(writer, hiddenparts, writer.WriteByte, 0)
end

ClientToGameDelegate.AskSetSpiritWearFashionHiddenPartsWithSource = function(self, spiritorinstanceid, source, hiddenparts)
	return self.Invoke(self, 63452716, SerializerHelper.AskSetSpiritWearFashionHiddenPartsWithSource_Serializer, spiritorinstanceid, source, hiddenparts)
end

SerializerHelper.CheckPSOPermissions_Serializer = function(writer)
end

ClientToGameDelegate.CheckPSOPermissions = function(self)
	return self.Invoke(self, 63453981, SerializerHelper.CheckPSOPermissions_Serializer)
end

SerializerHelper.OnStoneDance_Serializer = function(writer, isphasetwo)
	SerializeBase.WritePrimitive(writer, isphasetwo, writer.WriteBoolean, false)
end

ClientToGameDelegate.OnStoneDance = function(self, isphasetwo)
	self.Notify(self, 63454825, SerializerHelper.OnStoneDance_Serializer, isphasetwo)
end

SerializerHelper.ArrangeMjHolds_Serializer = function(writer, instanceids)
	SerializeBase.WriteList7Bit(writer, instanceids, writer.WriteInt32, 0, "instanceids", false, RpcLengthLimits.IClientToGame_ArrangeMjHolds_instanceIds, nil)
end

ClientToGameDelegate.ArrangeMjHolds = function(self, instanceids)
	self.Notify(self, 63454839, SerializerHelper.ArrangeMjHolds_Serializer, instanceids)
end

SerializerHelper.AskTradeFavoriteItems_Serializer = function(writer, unfavoriteids, favoriteids)
	SerializeBase.WriteList7Bit(writer, unfavoriteids, writer.WriteUInt32, 0, "unfavoriteids", true, RpcLengthLimits.IClientToGame_AskTradeFavoriteItems_unfavoriteIds, nil)
	SerializeBase.WriteList7Bit(writer, favoriteids, writer.WriteUInt32, 0, "favoriteids", true, RpcLengthLimits.IClientToGame_AskTradeFavoriteItems_favoriteIds, nil)
end

ClientToGameDelegate.AskTradeFavoriteItems = function(self, unfavoriteids, favoriteids)
	return self.Invoke(self, 63455013, SerializerHelper.AskTradeFavoriteItems_Serializer, unfavoriteids, favoriteids)
end

SerializerHelper.AskMarkMailRead_Serializer = function(writer, mailid)
	SerializeBase.WritePrimitive(writer, mailid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskMarkMailRead = function(self, mailid)
	return self.Invoke(self, 63455058, SerializerHelper.AskMarkMailRead_Serializer, mailid)
end

SerializerHelper.AskPoliceTrailTeleport_Serializer = function(writer, caseid)
	SerializeBase.WritePrimitive(writer, caseid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskPoliceTrailTeleport = function(self, caseid)
	return self.Invoke(self, 63457607, SerializerHelper.AskPoliceTrailTeleport_Serializer, caseid)
end

SerializerHelper.AskFireworkTriggerPlan_Serializer = function(writer, fireworkplanid)
	SerializeBase.WritePrimitive(writer, fireworkplanid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFireworkTriggerPlan = function(self, fireworkplanid)
	return self.Invoke(self, 63458498, SerializerHelper.AskFireworkTriggerPlan_Serializer, fireworkplanid)
end

SerializerHelper.AskDivinerFinishRequestAppeal_Serializer = function(writer, agententityid, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer.WriteString(writer, lang, false, "AskDivinerFinishRequestAppeal.lang", RpcLengthLimits.IClientToGame_AskDivinerFinishRequestAppeal_lang)
end

ClientToGameDelegate.AskDivinerFinishRequestAppeal = function(self, agententityid, lang)
	return self.Invoke(self, 63458552, SerializerHelper.AskDivinerFinishRequestAppeal_Serializer, agententityid, lang)
end

SerializerHelper.AskTakeNpcProfileMaxTrustReward_Serializer = function(writer, profileid)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeNpcProfileMaxTrustReward = function(self, profileid)
	return self.Invoke(self, 63459434, SerializerHelper.AskTakeNpcProfileMaxTrustReward_Serializer, profileid)
end

SerializerHelper.AskStartFortune_Serializer = function(writer, gadgetid, startparams)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, startparams, SerializeAuto.WriteFortuneStartParams, "startparams", false)
end

ClientToGameDelegate.AskStartFortune = function(self, gadgetid, startparams)
	return self.Invoke(self, 63461326, SerializerHelper.AskStartFortune_Serializer, gadgetid, startparams)
end

SerializerHelper.AskReadCommodities_Serializer = function(writer, shopid, commodityidlist)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, commodityidlist, writer.WriteUInt32, 0, "commodityidlist", false, RpcLengthLimits.IClientToGame_AskReadCommodities_commodityIdList, nil)
end

ClientToGameDelegate.AskReadCommodities = function(self, shopid, commodityidlist)
	return self.Invoke(self, 63463947, SerializerHelper.AskReadCommodities_Serializer, shopid, commodityidlist)
end

SerializerHelper.RpcUpdatePlayerCollectionSlotActiveLevel_Serializer = function(writer, boothid, slot, activelevel)
	SerializeBase.WritePrimitive(writer, boothid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slot, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, activelevel, writer.WriteUInt32, 0)
end

ClientToGameDelegate.RpcUpdatePlayerCollectionSlotActiveLevel = function(self, boothid, slot, activelevel)
	return self.Invoke(self, 63463978, SerializerHelper.RpcUpdatePlayerCollectionSlotActiveLevel_Serializer, boothid, slot, activelevel)
end

SerializerHelper.AskPassingTime_Serializer = function(writer, hour, minute)
	SerializeBase.WritePrimitive(writer, hour, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, minute, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPassingTime = function(self, hour, minute)
	return self.Invoke(self, 63465040, SerializerHelper.AskPassingTime_Serializer, hour, minute)
end

SerializerHelper.AskLinkPlanningBoardTeamLeaderUpdateSettingsInfo_Serializer = function(writer, settingsinfo)
	SerializeBase.WriteComplex(writer, settingsinfo, SerializeAuto.WriteLinkPlanningBoardTeamSettingsInfo, "settingsinfo", false)
end

ClientToGameDelegate.AskLinkPlanningBoardTeamLeaderUpdateSettingsInfo = function(self, settingsinfo)
	return self.Invoke(self, 63466354, SerializerHelper.AskLinkPlanningBoardTeamLeaderUpdateSettingsInfo_Serializer, settingsinfo)
end

SerializerHelper.AskShoulderPoleReBalance_Serializer = function(writer, unbalancetype)
	SerializeBase.WritePrimitive(writer, unbalancetype, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskShoulderPoleReBalance = function(self, unbalancetype)
	return self.Invoke(self, 63466379, SerializerHelper.AskShoulderPoleReBalance_Serializer, unbalancetype)
end

SerializerHelper.AskRankWarZoneInfo_Serializer = function(writer, rankconfigid)
	SerializeBase.WritePrimitive(writer, rankconfigid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskRankWarZoneInfo = function(self, rankconfigid)
	return self.Invoke(self, 63467837, SerializerHelper.AskRankWarZoneInfo_Serializer, rankconfigid)
end

SerializerHelper.AskTuiteDeleteComment_Serializer = function(writer, tuiteid, commentid)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, commentid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTuiteDeleteComment = function(self, tuiteid, commentid)
	return self.Invoke(self, 63469541, SerializerHelper.AskTuiteDeleteComment_Serializer, tuiteid, commentid)
end

SerializerHelper.AskGetMailItem_Serializer = function(writer, mailid)
	SerializeBase.WritePrimitive(writer, mailid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskGetMailItem = function(self, mailid)
	return self.Invoke(self, 63469968, SerializerHelper.AskGetMailItem_Serializer, mailid)
end

SerializerHelper.AskReAcceptTaskFailGroup_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskReAcceptTaskFailGroup = function(self, taskid)
	return self.Invoke(self, 63470051, SerializerHelper.AskReAcceptTaskFailGroup_Serializer, taskid)
end

SerializerHelper.StartBotMatch_Serializer = function(writer, list)
	SerializeBase.WriteList7Bit(writer, list, SerializeBase.WriteComplexWrap(SerializeAuto.WriteBotInfo, "BotInfo", false), nil, "list", false, RpcLengthLimits.IClientToGame_StartBotMatch_list, nil)
end

ClientToGameDelegate.StartBotMatch = function(self, list)
	return self.Invoke(self, 63474603, SerializerHelper.StartBotMatch_Serializer, list)
end

SerializerHelper.AskGetAISessionMessageInfo_Serializer = function(writer, sessiontype, sessionid, beginid, endid)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sessiontype, 6, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, beginid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskGetAISessionMessageInfo = function(self, sessiontype, sessionid, beginid, endid)
	return self.Invoke(self, 63475209, SerializerHelper.AskGetAISessionMessageInfo_Serializer, sessiontype, sessionid, beginid, endid)
end

SerializerHelper.AskInteractNpcWithGift_Serializer = function(writer, activitycfgid, itemid, count)
	SerializeBase.WritePrimitive(writer, activitycfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskInteractNpcWithGift = function(self, activitycfgid, itemid, count)
	return self.Invoke(self, 63477049, SerializerHelper.AskInteractNpcWithGift_Serializer, activitycfgid, itemid, count)
end

SerializerHelper.AskTuiteGetCommentList_Serializer = function(writer, tuiteid, page, pagesize)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, page, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, pagesize, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskTuiteGetCommentList = function(self, tuiteid, page, pagesize)
	return self.Invoke(self, 63477523, SerializerHelper.AskTuiteGetCommentList_Serializer, tuiteid, page, pagesize)
end

SerializerHelper.AskSubmitItem_Serializer = function(writer, submiteventid, info)
	SerializeBase.WritePrimitive(writer, submiteventid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteSubmitItemInfo, "info", false)
end

ClientToGameDelegate.AskSubmitItem = function(self, submiteventid, info)
	return self.Invoke(self, 63477583, SerializerHelper.AskSubmitItem_Serializer, submiteventid, info)
end

SerializerHelper.AskCreateHouseParkingVehicles_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskCreateHouseParkingVehicles = function(self, houseid)
	return self.Invoke(self, 63479109, SerializerHelper.AskCreateHouseParkingVehicles_Serializer, houseid)
end

SerializerHelper.AskBuyBattlePassLevels_Serializer = function(writer, bpid, levelstobuy)
	SerializeBase.WritePrimitive(writer, bpid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, levelstobuy, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBuyBattlePassLevels = function(self, bpid, levelstobuy)
	return self.Invoke(self, 63479404, SerializerHelper.AskBuyBattlePassLevels_Serializer, bpid, levelstobuy)
end

SerializerHelper.AskUseLoadingText_Serializer = function(writer, loadingid)
	SerializeBase.WritePrimitive(writer, loadingid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUseLoadingText = function(self, loadingid)
	self.Notify(self, 63480376, SerializerHelper.AskUseLoadingText_Serializer, loadingid)
end

SerializerHelper.AskTradeCancelOrder_Serializer = function(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskTradeCancelOrder = function(self, orderid)
	return self.Invoke(self, 63483414, SerializerHelper.AskTradeCancelOrder_Serializer, orderid)
end

SerializerHelper.QueryPersonalZoneHeadExtendInfo_Serializer = function(writer)
end

ClientToGameDelegate.QueryPersonalZoneHeadExtendInfo = function(self)
	return self.Invoke(self, 63484020, SerializerHelper.QueryPersonalZoneHeadExtendInfo_Serializer)
end

SerializerHelper.ResponsePartyRoomInvite_Serializer = function(writer, roomid, accepted)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accepted, writer.WriteBoolean, false)
end

ClientToGameDelegate.ResponsePartyRoomInvite = function(self, roomid, accepted)
	return self.Invoke(self, 63484308, SerializerHelper.ResponsePartyRoomInvite_Serializer, roomid, accepted)
end

SerializerHelper.GetAllUnlockChatItems_Serializer = function(writer)
end

ClientToGameDelegate.GetAllUnlockChatItems = function(self)
	return self.Invoke(self, 63484512, SerializerHelper.GetAllUnlockChatItems_Serializer)
end

SerializerHelper.AskHotSpringStart_Serializer = function(writer)
end

ClientToGameDelegate.AskHotSpringStart = function(self)
	return self.Invoke(self, 63486302, SerializerHelper.AskHotSpringStart_Serializer)
end

SerializerHelper.AskPhoneAddCallRecord_Serializer = function(writer, spiritid, phonenumber, calltype)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer.WriteString(writer, phonenumber, false, "AskPhoneAddCallRecord.phoneNumber", RpcLengthLimits.IClientToGame_AskPhoneAddCallRecord_phoneNumber)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(calltype, 28, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskPhoneAddCallRecord = function(self, spiritid, phonenumber, calltype)
	return self.Invoke(self, 63487875, SerializerHelper.AskPhoneAddCallRecord_Serializer, spiritid, phonenumber, calltype)
end

SerializerHelper.RemoveCurrentTask_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.RemoveCurrentTask = function(self, taskid)
	return self.Invoke(self, 63488434, SerializerHelper.RemoveCurrentTask_Serializer, taskid)
end

SerializerHelper.OnInteractWithHugePigeon_Serializer = function(writer)
end

ClientToGameDelegate.OnInteractWithHugePigeon = function(self)
	self.Notify(self, 63488773, SerializerHelper.OnInteractWithHugePigeon_Serializer)
end

SerializerHelper.AskPlaceRumorInSlot_Serializer = function(writer, wuxueid, slottype, rumorid)
	SerializeBase.WritePrimitive(writer, wuxueid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slottype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, rumorid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPlaceRumorInSlot = function(self, wuxueid, slottype, rumorid)
	return self.Invoke(self, 63489098, SerializerHelper.AskPlaceRumorInSlot_Serializer, wuxueid, slottype, rumorid)
end

SerializerHelper.AskServerGraffitoUrl_Serializer = function(writer)
end

ClientToGameDelegate.AskServerGraffitoUrl = function(self)
	return self.Invoke(self, 63489995, SerializerHelper.AskServerGraffitoUrl_Serializer)
end

SerializerHelper.SyncEnterFogMapPoiId_Serializer = function(writer, poiid)
	SerializeBase.WritePrimitive(writer, poiid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.SyncEnterFogMapPoiId = function(self, poiid)
	self.Notify(self, 63491307, SerializerHelper.SyncEnterFogMapPoiId_Serializer, poiid)
end

SerializerHelper.AskPublicSwitchToPublicScene_Serializer = function(writer, raidid, delay, mapentranceid)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, delay, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, mapentranceid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPublicSwitchToPublicScene = function(self, raidid, delay, mapentranceid)
	return self.Invoke(self, 63491547, SerializerHelper.AskPublicSwitchToPublicScene_Serializer, raidid, delay, mapentranceid)
end

SerializerHelper.AskStartAIInterrogation_Serializer = function(writer, caseid)
	SerializeBase.WritePrimitive(writer, caseid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskStartAIInterrogation = function(self, caseid)
	return self.Invoke(self, 63492524, SerializerHelper.AskStartAIInterrogation_Serializer, caseid)
end

SerializerHelper.AskTradeGetMarketList_Serializer = function(writer, tradeitemid)
	SerializeBase.WritePrimitive(writer, tradeitemid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTradeGetMarketList = function(self, tradeitemid)
	return self.Invoke(self, 63492557, SerializerHelper.AskTradeGetMarketList_Serializer, tradeitemid)
end

SerializerHelper.SyncChangeBuilding_Serializer = function(writer, buildingid, floorid)
	SerializeBase.WritePrimitive(writer, buildingid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, floorid, writer.WriteInt32, 0)
end

ClientToGameDelegate.SyncChangeBuilding = function(self, buildingid, floorid)
	return self.Invoke(self, 63495099, SerializerHelper.SyncChangeBuilding_Serializer, buildingid, floorid)
end

SerializerHelper.AskHouseCancelParking_Serializer = function(writer, vehicleidlist)
	SerializeBase.WriteList7Bit(writer, vehicleidlist, writer.WriteUInt32, 0, "vehicleidlist", false, RpcLengthLimits.IClientToGame_AskHouseCancelParking_vehicleIdList, nil)
end

ClientToGameDelegate.AskHouseCancelParking = function(self, vehicleidlist)
	return self.Invoke(self, 63495236, SerializerHelper.AskHouseCancelParking_Serializer, vehicleidlist)
end

SerializerHelper.VehicleDriveStateChange_Serializer = function(writer, state)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(state, 29, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.VehicleDriveStateChange = function(self, state)
	return self.Invoke(self, 63495445, SerializerHelper.VehicleDriveStateChange_Serializer, state)
end

SerializerHelper.AskVehicleShopSpawnVehicle_Serializer = function(writer, shopid, vehicleid, isbind)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isbind, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskVehicleShopSpawnVehicle = function(self, shopid, vehicleid, isbind)
	return self.Invoke(self, 63497070, SerializerHelper.AskVehicleShopSpawnVehicle_Serializer, shopid, vehicleid, isbind)
end

SerializerHelper.PrepareRoomLeaveRoom_Serializer = function(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.PrepareRoomLeaveRoom = function(self, roomid)
	return self.Invoke(self, 63498431, SerializerHelper.PrepareRoomLeaveRoom_Serializer, roomid)
end

SerializerHelper.AskExtractionShooterLockItem_Serializer = function(writer, bagconfigid, cellx, celly, islocked)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, islocked, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskExtractionShooterLockItem = function(self, bagconfigid, cellx, celly, islocked)
	return self.Invoke(self, 63498996, SerializerHelper.AskExtractionShooterLockItem_Serializer, bagconfigid, cellx, celly, islocked)
end

SerializerHelper.AskDecompositePokemon_Serializer = function(writer, id)
	SerializeBase.WriteList7Bit(writer, id, writer.WriteUInt64, 0, "id", false, RpcLengthLimits.IClientToGame_AskDecompositePokemon_id, nil)
end

ClientToGameDelegate.AskDecompositePokemon = function(self, id)
	return self.Invoke(self, 63499075, SerializerHelper.AskDecompositePokemon_Serializer, id)
end

SerializerHelper.AskUnlockFashionSuitSlot_Serializer = function(writer, spiritid, unlockslotcount)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, unlockslotcount, writer.WriteByte, 0)
end

ClientToGameDelegate.AskUnlockFashionSuitSlot = function(self, spiritid, unlockslotcount)
	return self.Invoke(self, 63499120, SerializerHelper.AskUnlockFashionSuitSlot_Serializer, spiritid, unlockslotcount)
end

SerializerHelper.AskUpdatePersonalZoneHead_Serializer = function(writer, headtype, systemheadid, islink)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(headtype, 30, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, systemheadid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, islink, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskUpdatePersonalZoneHead = function(self, headtype, systemheadid, islink)
	return self.Invoke(self, 63499264, SerializerHelper.AskUpdatePersonalZoneHead_Serializer, headtype, systemheadid, islink)
end

SerializerHelper.AskPoliceDispatch_Serializer = function(writer, dispatchid, extrainfo)
	SerializeBase.WritePrimitive(writer, dispatchid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, extrainfo, SerializeAuto.WritePoliceDispatchExtraInfo, "extrainfo", true)
end

ClientToGameDelegate.AskPoliceDispatch = function(self, dispatchid, extrainfo)
	return self.Invoke(self, 63500791, SerializerHelper.AskPoliceDispatch_Serializer, dispatchid, extrainfo)
end

SerializerHelper.AskExchangeWeaponSlot_Serializer = function(writer, fromspirit, fromindex, tospirit, toindex)
	SerializeBase.WritePrimitive(writer, fromspirit, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, tospirit, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, toindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskExchangeWeaponSlot = function(self, fromspirit, fromindex, tospirit, toindex)
	return self.Invoke(self, 63501020, SerializerHelper.AskExchangeWeaponSlot_Serializer, fromspirit, fromindex, tospirit, toindex)
end

SerializerHelper.RequestNpcGroupMembers_Serializer = function(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.RequestNpcGroupMembers = function(self, groupid)
	return self.Invoke(self, 63501247, SerializerHelper.RequestNpcGroupMembers_Serializer, groupid)
end

SerializerHelper.AskEnterRaidByMapEntrance_Serializer = function(writer, mapentranceid)
	SerializeBase.WritePrimitive(writer, mapentranceid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskEnterRaidByMapEntrance = function(self, mapentranceid)
	return self.Invoke(self, 63510026, SerializerHelper.AskEnterRaidByMapEntrance_Serializer, mapentranceid)
end

SerializerHelper.AskOCPreGenerateOCId_Serializer = function(writer)
end

ClientToGameDelegate.AskOCPreGenerateOCId = function(self)
	return self.Invoke(self, 63514698, SerializerHelper.AskOCPreGenerateOCId_Serializer)
end

SerializerHelper.AskLeavePartyDance_Serializer = function(writer)
end

ClientToGameDelegate.AskLeavePartyDance = function(self)
	return self.Invoke(self, 63516846, SerializerHelper.AskLeavePartyDance_Serializer)
end

SerializerHelper.AskQueryHouseSocialInfo_Serializer = function(writer, ownerpid, houseid)
	SerializeBase.WritePrimitive(writer, ownerpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskQueryHouseSocialInfo = function(self, ownerpid, houseid)
	return self.Invoke(self, 63516886, SerializerHelper.AskQueryHouseSocialInfo_Serializer, ownerpid, houseid)
end

SerializerHelper.AskStartPartyMiniGameMatch_Serializer = function(writer, gameconfigid)
	SerializeBase.WritePrimitive(writer, gameconfigid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartPartyMiniGameMatch = function(self, gameconfigid)
	return self.Invoke(self, 63517279, SerializerHelper.AskStartPartyMiniGameMatch_Serializer, gameconfigid)
end

SerializerHelper.AskMomentsDeleteCustomPost_Serializer = function(writer, postid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskMomentsDeleteCustomPost = function(self, postid)
	return self.Invoke(self, 63518682, SerializerHelper.AskMomentsDeleteCustomPost_Serializer, postid)
end

SerializerHelper.SetNewChallengeStartTime_Serializer = function(writer, challengeid, starttime)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, starttime, writer.WriteUInt32, 0)
end

ClientToGameDelegate.SetNewChallengeStartTime = function(self, challengeid, starttime)
	return self.Invoke(self, 63519964, SerializerHelper.SetNewChallengeStartTime_Serializer, challengeid, starttime)
end

SerializerHelper.AskStartHackerTetris_Serializer = function(writer)
end

ClientToGameDelegate.AskStartHackerTetris = function(self)
	return self.Invoke(self, 63521495, SerializerHelper.AskStartHackerTetris_Serializer)
end

SerializerHelper.AskPublishTuite_Serializer = function(writer, tuiteconfigid)
	SerializeBase.WritePrimitive(writer, tuiteconfigid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPublishTuite = function(self, tuiteconfigid)
	return self.Invoke(self, 63522023, SerializerHelper.AskPublishTuite_Serializer, tuiteconfigid)
end

SerializerHelper.AskPutMapPinFar_Serializer = function(writer, raidid, x, z, type)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

ClientToGameDelegate.AskPutMapPinFar = function(self, raidid, x, z, type)
	return self.Invoke(self, 63522219, SerializerHelper.AskPutMapPinFar_Serializer, raidid, x, z, type)
end

SerializerHelper.AskCreateTeam_Serializer = function(writer)
end

ClientToGameDelegate.AskCreateTeam = function(self)
	return self.Invoke(self, 63522826, SerializerHelper.AskCreateTeam_Serializer)
end

SerializerHelper.DingQue_Serializer = function(writer, type)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 31, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.DingQue = function(self, type)
	return self.Invoke(self, 63522961, SerializerHelper.DingQue_Serializer, type)
end

SerializerHelper.AskDepositSpiritWeapon_Serializer = function(writer, spiritid, slotindex)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slotindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskDepositSpiritWeapon = function(self, spiritid, slotindex)
	return self.Invoke(self, 63524060, SerializerHelper.AskDepositSpiritWeapon_Serializer, spiritid, slotindex)
end

SerializerHelper.AskUpdatePlayerPopUp_Serializer = function(writer, popupid)
	SerializeBase.WritePrimitive(writer, popupid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUpdatePlayerPopUp = function(self, popupid)
	return self.Invoke(self, 63524645, SerializerHelper.AskUpdatePlayerPopUp_Serializer, popupid)
end

SerializerHelper.AskPlayerEnterOrLeaveDoor_Serializer = function(writer, gadgetid, isenter)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isenter, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskPlayerEnterOrLeaveDoor = function(self, gadgetid, isenter)
	self.Notify(self, 63525373, SerializerHelper.AskPlayerEnterOrLeaveDoor_Serializer, gadgetid, isenter)
end

SerializerHelper.AskMomentsUnreadMessage_Serializer = function(writer)
end

ClientToGameDelegate.AskMomentsUnreadMessage = function(self)
	return self.Invoke(self, 63525787, SerializerHelper.AskMomentsUnreadMessage_Serializer)
end

SerializerHelper.FinishTaskTitleGuideUnlock_Serializer = function(writer, title)
	SerializeBase.WritePrimitive(writer, title, writer.WriteUInt16, 0)
end

ClientToGameDelegate.FinishTaskTitleGuideUnlock = function(self, title)
	self.Notify(self, 63525907, SerializerHelper.FinishTaskTitleGuideUnlock_Serializer, title)
end

SerializerHelper.AskClearSpiritGroupChat_Serializer = function(writer)
end

ClientToGameDelegate.AskClearSpiritGroupChat = function(self)
	self.Notify(self, 63527240, SerializerHelper.AskClearSpiritGroupChat_Serializer)
end

SerializerHelper.TryInteractOuterVoice_Serializer = function(writer, npccultivationid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.TryInteractOuterVoice = function(self, npccultivationid)
	self.Notify(self, 63527736, SerializerHelper.TryInteractOuterVoice_Serializer, npccultivationid)
end

SerializerHelper.AskTakeSingleLevelReward_Serializer = function(writer, level)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeSingleLevelReward = function(self, level)
	return self.Invoke(self, 63529275, SerializerHelper.AskTakeSingleLevelReward_Serializer, level)
end

SerializerHelper.AskSetPersonalTeamSetting_Serializer = function(writer, setting)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WritePersonalTeamSetting, "setting", false)
end

ClientToGameDelegate.AskSetPersonalTeamSetting = function(self, setting)
	return self.Invoke(self, 63531427, SerializerHelper.AskSetPersonalTeamSetting_Serializer, setting)
end

SerializerHelper.AskDivinerPublishTuite_Serializer = function(writer)
end

ClientToGameDelegate.AskDivinerPublishTuite = function(self)
	return self.Invoke(self, 63532633, SerializerHelper.AskDivinerPublishTuite_Serializer)
end

SerializerHelper.PrepareRoomKickMember_Serializer = function(writer, roomid, kickedpid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, kickedpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.PrepareRoomKickMember = function(self, roomid, kickedpid)
	return self.Invoke(self, 63535210, SerializerHelper.PrepareRoomKickMember_Serializer, roomid, kickedpid)
end

SerializerHelper.AskInvestigatorInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskInvestigatorInfo = function(self)
	return self.Invoke(self, 63536759, SerializerHelper.AskInvestigatorInfo_Serializer)
end

SerializerHelper.AskBegBehavior_Serializer = function(writer, begstyle, spot, behaviortype)
	SerializeBase.WritePrimitive(writer, begstyle, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spot, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(behaviortype, 32, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskBegBehavior = function(self, begstyle, spot, behaviortype)
	return self.Invoke(self, 63537618, SerializerHelper.AskBegBehavior_Serializer, begstyle, spot, behaviortype)
end

SerializerHelper.AskTakeLevelLandmarkProgressReward_Serializer = function(writer, id, progressid)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, progressid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeLevelLandmarkProgressReward = function(self, id, progressid)
	return self.Invoke(self, 63538116, SerializerHelper.AskTakeLevelLandmarkProgressReward_Serializer, id, progressid)
end

SerializerHelper.DeleteBeggarAiPainting_Serializer = function(writer, objectkey)
	writer.WriteString(writer, objectkey, false, "DeleteBeggarAiPainting.objectKey", RpcLengthLimits.IClientToGame_DeleteBeggarAiPainting_objectKey)
end

ClientToGameDelegate.DeleteBeggarAiPainting = function(self, objectkey)
	return self.Invoke(self, 63538928, SerializerHelper.DeleteBeggarAiPainting_Serializer, objectkey)
end

SerializerHelper.AskChangeLinkTimelineInfo_Serializer = function(writer, timelineinfo)
	SerializeBase.WriteStruct(writer, timelineinfo, SerializeAuto.WriteLinkedTimelineInfo, "timelineinfo")
end

ClientToGameDelegate.AskChangeLinkTimelineInfo = function(self, timelineinfo)
	return self.Invoke(self, 63539857, SerializerHelper.AskChangeLinkTimelineInfo_Serializer, timelineinfo)
end

SerializerHelper.AskTakeNpcProfileProgressReward_Serializer = function(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeNpcProfileProgressReward = function(self, index)
	return self.Invoke(self, 63541872, SerializerHelper.AskTakeNpcProfileProgressReward_Serializer, index)
end

SerializerHelper.AskUpdateAISessionMessage_Serializer = function(writer, sessiontype, sessionid, messageid, mutabledata)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sessiontype, 6, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, messageid, writer.WriteUInt32, 0)
	writer.WriteString(writer, mutabledata, false, "AskUpdateAISessionMessage.mutableData", RpcLengthLimits.IClientToGame_AskUpdateAISessionMessage_mutableData)
end

ClientToGameDelegate.AskUpdateAISessionMessage = function(self, sessiontype, sessionid, messageid, mutabledata)
	return self.Invoke(self, 63545142, SerializerHelper.AskUpdateAISessionMessage_Serializer, sessiontype, sessionid, messageid, mutabledata)
end

SerializerHelper.AskGetFinishedOrderWraps_Serializer = function(writer)
end

ClientToGameDelegate.AskGetFinishedOrderWraps = function(self)
	return self.Invoke(self, 63545189, SerializerHelper.AskGetFinishedOrderWraps_Serializer)
end

SerializerHelper.AskBarterBuyCommodity_Serializer = function(writer, shopid, commodityid, count)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBarterBuyCommodity = function(self, shopid, commodityid, count)
	return self.Invoke(self, 63546283, SerializerHelper.AskBarterBuyCommodity_Serializer, shopid, commodityid, count)
end

SerializerHelper.GenerateBeggarAiPainting_Serializer = function(writer, sourceobjectkey, paintingconfigid)
	writer.WriteString(writer, sourceobjectkey, false, "GenerateBeggarAiPainting.sourceObjectKey", RpcLengthLimits.IClientToGame_GenerateBeggarAiPainting_sourceObjectKey)
	SerializeBase.WritePrimitive(writer, paintingconfigid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.GenerateBeggarAiPainting = function(self, sourceobjectkey, paintingconfigid)
	return self.Invoke(self, 63547246, SerializerHelper.GenerateBeggarAiPainting_Serializer, sourceobjectkey, paintingconfigid)
end

SerializerHelper.AskMallSetCartItems_Serializer = function(writer, items)
	SerializeBase.WriteList7Bit(writer, items, SerializeBase.WriteComplexWrap(SerializeAuto.WriteMallCartBuyItem, "MallCartBuyItem", false), nil, "items", false, RpcLengthLimits.IClientToGame_AskMallSetCartItems_items, nil)
end

ClientToGameDelegate.AskMallSetCartItems = function(self, items)
	return self.Invoke(self, 63547405, SerializerHelper.AskMallSetCartItems_Serializer, items)
end

SerializerHelper.AskCloseNpcShop_Serializer = function(writer, shopid)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskCloseNpcShop = function(self, shopid)
	self.Notify(self, 63547606, SerializerHelper.AskCloseNpcShop_Serializer, shopid)
end

SerializerHelper.RespondPrepareRoomInvite_Serializer = function(writer, roomid, accept)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

ClientToGameDelegate.RespondPrepareRoomInvite = function(self, roomid, accept)
	return self.Invoke(self, 63550066, SerializerHelper.RespondPrepareRoomInvite_Serializer, roomid, accept)
end

SerializerHelper.GetAllUgcMapSyncInfos_Serializer = function(writer)
end

ClientToGameDelegate.GetAllUgcMapSyncInfos = function(self)
	return self.Invoke(self, 63552577, SerializerHelper.GetAllUgcMapSyncInfos_Serializer)
end

SerializerHelper.AskCancelInteractTuite_Serializer = function(writer, tuiteid, interacttype)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interacttype, writer.WriteByte, 0)
end

ClientToGameDelegate.AskCancelInteractTuite = function(self, tuiteid, interacttype)
	return self.Invoke(self, 63553372, SerializerHelper.AskCancelInteractTuite_Serializer, tuiteid, interacttype)
end

SerializerHelper.AskLeaveRoom_Serializer = function(writer)
end

ClientToGameDelegate.AskLeaveRoom = function(self)
	return self.Invoke(self, 63554280, SerializerHelper.AskLeaveRoom_Serializer)
end

SerializerHelper.AskFinishHackerTetris_Serializer = function(writer, score)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFinishHackerTetris = function(self, score)
	return self.Invoke(self, 63554976, SerializerHelper.AskFinishHackerTetris_Serializer, score)
end

SerializerHelper.AskDestroyGangMember_Serializer = function(writer, templateid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskDestroyGangMember = function(self, templateid)
	return self.Invoke(self, 63555197, SerializerHelper.AskDestroyGangMember_Serializer, templateid)
end

SerializerHelper.DonateFactionByMoney_Serializer = function(writer, factionid, money)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, money, writer.WriteUInt32, 0)
end

ClientToGameDelegate.DonateFactionByMoney = function(self, factionid, money)
	return self.Invoke(self, 63555571, SerializerHelper.DonateFactionByMoney_Serializer, factionid, money)
end

SerializerHelper.SyncAuthorizationCode_Serializer = function(writer, authorizationcode)
	writer.WriteString(writer, authorizationcode, false, "SyncAuthorizationCode.authorizationCode", RpcLengthLimits.IClientToGame_SyncAuthorizationCode_authorizationCode)
end

ClientToGameDelegate.SyncAuthorizationCode = function(self, authorizationcode)
	return self.Invoke(self, 63556669, SerializerHelper.SyncAuthorizationCode_Serializer, authorizationcode)
end

SerializerHelper.AskPutMapPin_Serializer = function(writer, raidid, position, type)
	SerializeBase.WritePrimitive(writer, raidid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

ClientToGameDelegate.AskPutMapPin = function(self, raidid, position, type)
	return self.Invoke(self, 63558934, SerializerHelper.AskPutMapPin_Serializer, raidid, position, type)
end

SerializerHelper.AskChangeTeamLeader_Serializer = function(writer, newleader)
	SerializeBase.WritePrimitive(writer, newleader, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskChangeTeamLeader = function(self, newleader)
	return self.Invoke(self, 63561700, SerializerHelper.AskChangeTeamLeader_Serializer, newleader)
end

SerializerHelper.AskLeaveClub_Serializer = function(writer, clubid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskLeaveClub = function(self, clubid)
	return self.Invoke(self, 63561961, SerializerHelper.AskLeaveClub_Serializer, clubid)
end

SerializerHelper.StartMatchInTeam_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.StartMatchInTeam = function(self, gameid)
	return self.Invoke(self, 63563208, SerializerHelper.StartMatchInTeam_Serializer, gameid)
end

SerializerHelper.AskNpcShop_Serializer = function(writer, shopid)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskNpcShop = function(self, shopid)
	return self.Invoke(self, 63563263, SerializerHelper.AskNpcShop_Serializer, shopid)
end

SerializerHelper.AskUninstallMobileApp_Serializer = function(writer, appid)
	SerializeBase.WritePrimitive(writer, appid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUninstallMobileApp = function(self, appid)
	return self.Invoke(self, 63565763, SerializerHelper.AskUninstallMobileApp_Serializer, appid)
end

SerializerHelper.AskUpdateAISession_Serializer = function(writer, sessiontype, sessionid, mutabledata)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sessiontype, 6, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt32, 0)
	writer.WriteString(writer, mutabledata, false, "AskUpdateAISession.mutableData", RpcLengthLimits.IClientToGame_AskUpdateAISession_mutableData)
end

ClientToGameDelegate.AskUpdateAISession = function(self, sessiontype, sessionid, mutabledata)
	return self.Invoke(self, 63567318, SerializerHelper.AskUpdateAISession_Serializer, sessiontype, sessionid, mutabledata)
end

SerializerHelper.AskLeaveRaid_Serializer = function(writer, raidinstanceid)
	SerializeBase.WritePrimitive(writer, raidinstanceid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskLeaveRaid = function(self, raidinstanceid)
	self.Notify(self, 63568682, SerializerHelper.AskLeaveRaid_Serializer, raidinstanceid)
end

SerializerHelper.AskTierByIds_Serializer = function(writer, tierconfigids)
	SerializeBase.WriteList7Bit(writer, tierconfigids, writer.WriteUInt32, 0, "tierconfigids", false, RpcLengthLimits.IClientToGame_AskTierByIds_tierConfigIds, nil)
end

ClientToGameDelegate.AskTierByIds = function(self, tierconfigids)
	return self.Invoke(self, 63569751, SerializerHelper.AskTierByIds_Serializer, tierconfigids)
end

SerializerHelper.AskEndPainting_Serializer = function(writer, evaluationid, stroke_num, colorcount)
	writer.WriteString(writer, evaluationid, false, "AskEndPainting.evaluationId", RpcLengthLimits.IClientToGame_AskEndPainting_evaluationId)
	SerializeBase.WritePrimitive(writer, stroke_num, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, colorcount, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskEndPainting = function(self, evaluationid, stroke_num, colorcount)
	return self.Invoke(self, 63569998, SerializerHelper.AskEndPainting_Serializer, evaluationid, stroke_num, colorcount)
end

SerializerHelper.SetChallengeResult_Serializer = function(writer, taskid, score, goal, types)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, goal, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, types, writer.WriteByte, 0, "types", false, RpcLengthLimits.IClientToGame_SetChallengeResult_types, nil)
end

ClientToGameDelegate.SetChallengeResult = function(self, taskid, score, goal, types)
	return self.Invoke(self, 63571710, SerializerHelper.SetChallengeResult_Serializer, taskid, score, goal, types)
end

SerializerHelper.AskForceSkipTask_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskForceSkipTask = function(self, taskid)
	return self.Invoke(self, 63572830, SerializerHelper.AskForceSkipTask_Serializer, taskid)
end

SerializerHelper.AskSetMobileSkinPart_Serializer = function(writer, wallpaper, decoration, pendant)
	SerializeBase.WritePrimitive(writer, wallpaper, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, decoration, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pendant, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSetMobileSkinPart = function(self, wallpaper, decoration, pendant)
	return self.Invoke(self, 63575641, SerializerHelper.AskSetMobileSkinPart_Serializer, wallpaper, decoration, pendant)
end

SerializerHelper.AskSaveHouseSocialInfo_Serializer = function(writer, houseid, data)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteHouseSocialInfoSaveData, "data", false)
end

ClientToGameDelegate.AskSaveHouseSocialInfo = function(self, houseid, data)
	return self.Invoke(self, 63576212, SerializerHelper.AskSaveHouseSocialInfo_Serializer, houseid, data)
end

SerializerHelper.ReportRequisitionVehicle_Serializer = function(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.ReportRequisitionVehicle = function(self, vehicleid)
	self.Notify(self, 63577364, SerializerHelper.ReportRequisitionVehicle_Serializer, vehicleid)
end

SerializerHelper.AskFishingSuccess_Serializer = function(writer, fishgroupid, fishid)
	SerializeBase.WritePrimitive(writer, fishgroupid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fishid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFishingSuccess = function(self, fishgroupid, fishid)
	return self.Invoke(self, 63577896, SerializerHelper.AskFishingSuccess_Serializer, fishgroupid, fishid)
end

SerializerHelper.AskSellItem_Serializer = function(writer, bagconfigid, sellcellx, sellcelly, sellcount)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sellcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sellcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sellcount, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSellItem = function(self, bagconfigid, sellcellx, sellcelly, sellcount)
	return self.Invoke(self, 63578060, SerializerHelper.AskSellItem_Serializer, bagconfigid, sellcellx, sellcelly, sellcount)
end

SerializerHelper.AskTierByMultiPlayerIdList_Serializer = function(writer, multiplayerids)
	SerializeBase.WriteList7Bit(writer, multiplayerids, writer.WriteUInt32, 0, "multiplayerids", false, RpcLengthLimits.IClientToGame_AskTierByMultiPlayerIdList_multiPlayerIds, nil)
end

ClientToGameDelegate.AskTierByMultiPlayerIdList = function(self, multiplayerids)
	return self.Invoke(self, 63578262, SerializerHelper.AskTierByMultiPlayerIdList_Serializer, multiplayerids)
end

SerializerHelper.AskTradeGetHistoryPage_Serializer = function(writer, direction, filter)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(direction, 33, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(filter, 34, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskTradeGetHistoryPage = function(self, direction, filter)
	return self.Invoke(self, 63578362, SerializerHelper.AskTradeGetHistoryPage_Serializer, direction, filter)
end

SerializerHelper.AskQueryTeamInfoByPid_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskQueryTeamInfoByPid = function(self, pid)
	return self.Invoke(self, 63580827, SerializerHelper.AskQueryTeamInfoByPid_Serializer, pid)
end

SerializerHelper.AskCreateHouseFurnitureGadgets_Serializer = function(writer, houseid, floor, placedgadgets)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, placedgadgets, writer.WriteUInt64, 0, "placedgadgets", false, RpcLengthLimits.IClientToGame_AskCreateHouseFurnitureGadgets_placedGadgets, nil)
end

ClientToGameDelegate.AskCreateHouseFurnitureGadgets = function(self, houseid, floor, placedgadgets)
	return self.Invoke(self, 63581446, SerializerHelper.AskCreateHouseFurnitureGadgets_Serializer, houseid, floor, placedgadgets)
end

SerializerHelper.UpdateNgPushRegid_Serializer = function(writer, regid)
	writer.WriteString(writer, regid, false, "UpdateNgPushRegid.regid", RpcLengthLimits.IClientToGame_UpdateNgPushRegid_regid)
end

ClientToGameDelegate.UpdateNgPushRegid = function(self, regid)
	self.Notify(self, 63582787, SerializerHelper.UpdateNgPushRegid_Serializer, regid)
end

SerializerHelper.AskReportArcadeGameResultMUGEN_Serializer = function(writer, gameresult)
	SerializeBase.WriteComplex(writer, gameresult, SerializeAuto.WriteArcadeGameResultMUGEN, "gameresult", false)
end

ClientToGameDelegate.AskReportArcadeGameResultMUGEN = function(self, gameresult)
	return self.Invoke(self, 63583191, SerializerHelper.AskReportArcadeGameResultMUGEN_Serializer, gameresult)
end

SerializerHelper.AskCancelInteractionActionRedPoint_Serializer = function(writer, npcitemid)
	SerializeBase.WritePrimitive(writer, npcitemid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskCancelInteractionActionRedPoint = function(self, npcitemid)
	return self.Invoke(self, 63584158, SerializerHelper.AskCancelInteractionActionRedPoint_Serializer, npcitemid)
end

SerializerHelper.AskAcceptEvent_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskAcceptEvent = function(self, eventid)
	return self.Invoke(self, 63584351, SerializerHelper.AskAcceptEvent_Serializer, eventid)
end

SerializerHelper.AskReceiveChefRecipeReward_Serializer = function(writer, recipeid, rank)
	SerializeBase.WritePrimitive(writer, recipeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, rank, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskReceiveChefRecipeReward = function(self, recipeid, rank)
	return self.Invoke(self, 63584986, SerializerHelper.AskReceiveChefRecipeReward_Serializer, recipeid, rank)
end

SerializerHelper.AskReadPoliceFakeClueAgentInfoList_Serializer = function(writer, clueagentinfoindexlist)
	SerializeBase.WriteList7Bit(writer, clueagentinfoindexlist, writer.WriteInt32, 0, "clueagentinfoindexlist", false, RpcLengthLimits.IClientToGame_AskReadPoliceFakeClueAgentInfoList_clueAgentInfoIndexList, nil)
end

ClientToGameDelegate.AskReadPoliceFakeClueAgentInfoList = function(self, clueagentinfoindexlist)
	return self.Invoke(self, 63585436, SerializerHelper.AskReadPoliceFakeClueAgentInfoList_Serializer, clueagentinfoindexlist)
end

SerializerHelper.AskClearRedPointList_Serializer = function(writer, uids)
	SerializeBase.WriteList7Bit(writer, uids, writer.WriteUInt64, 0, "uids", false, RpcLengthLimits.IClientToGame_AskClearRedPointList_uIds, nil)
end

ClientToGameDelegate.AskClearRedPointList = function(self, uids)
	return self.Invoke(self, 63589029, SerializerHelper.AskClearRedPointList_Serializer, uids)
end

SerializerHelper.AskQueryTeamInfo_Serializer = function(writer, teamid)
	SerializeBase.WritePrimitive(writer, teamid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskQueryTeamInfo = function(self, teamid)
	return self.Invoke(self, 63596378, SerializerHelper.AskQueryTeamInfo_Serializer, teamid)
end

SerializerHelper.RequestMailsItem_Serializer = function(writer, mailids)
	SerializeBase.WriteList7Bit(writer, mailids, writer.WriteUInt64, 0, "mailids", false, RpcLengthLimits.IClientToGame_RequestMailsItem_mailIds, nil)
end

ClientToGameDelegate.RequestMailsItem = function(self, mailids)
	return self.Invoke(self, 63598363, SerializerHelper.RequestMailsItem_Serializer, mailids)
end

SerializerHelper.AskPurchaseElement_Serializer = function(writer, bartenderid, elementid, purchasecount)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, purchasecount, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPurchaseElement = function(self, bartenderid, elementid, purchasecount)
	return self.Invoke(self, 63599111, SerializerHelper.AskPurchaseElement_Serializer, bartenderid, elementid, purchasecount)
end

SerializerHelper.AskInvitePlayerInteractionAction_Serializer = function(writer, inviteepid, actionitemid)
	SerializeBase.WritePrimitive(writer, inviteepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionitemid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskInvitePlayerInteractionAction = function(self, inviteepid, actionitemid)
	return self.Invoke(self, 63601688, SerializerHelper.AskInvitePlayerInteractionAction_Serializer, inviteepid, actionitemid)
end

SerializerHelper.UpdateDaShenLogToken_Serializer = function(writer, logtoken)
	writer.WriteString(writer, logtoken, false, "UpdateDaShenLogToken.logToken", RpcLengthLimits.IClientToGame_UpdateDaShenLogToken_logToken)
end

ClientToGameDelegate.UpdateDaShenLogToken = function(self, logtoken)
	self.Notify(self, 63604899, SerializerHelper.UpdateDaShenLogToken_Serializer, logtoken)
end

SerializerHelper.HuanPai_Serializer = function(writer, selectpais)
	SerializeBase.WriteList7Bit(writer, selectpais, SerializeBase.WriteStructWrap(SerializeAuto.WriteMjPaiInfo, "selectpais"), nil, "selectpais", false, RpcLengthLimits.IClientToGame_HuanPai_selectPais, nil)
end

ClientToGameDelegate.HuanPai = function(self, selectpais)
	self.Notify(self, 63606054, SerializerHelper.HuanPai_Serializer, selectpais)
end

SerializerHelper.AskFireworkWorkStoreInfo_Serializer = function(writer, storeid)
	SerializeBase.WritePrimitive(writer, storeid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFireworkWorkStoreInfo = function(self, storeid)
	return self.Invoke(self, 63606146, SerializerHelper.AskFireworkWorkStoreInfo_Serializer, storeid)
end

SerializerHelper.AskBuyMiniGameTicket_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBuyMiniGameTicket = function(self, gameid)
	return self.Invoke(self, 63606259, SerializerHelper.AskBuyMiniGameTicket_Serializer, gameid)
end

SerializerHelper.AskKickCustomLinkMember_Serializer = function(writer, memberpid)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskKickCustomLinkMember = function(self, memberpid)
	return self.Invoke(self, 63607807, SerializerHelper.AskKickCustomLinkMember_Serializer, memberpid)
end

SerializerHelper.AskTakeOnlineSeasonProgressPendingRewards_Serializer = function(writer, seasonid)
	SerializeBase.WritePrimitive(writer, seasonid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeOnlineSeasonProgressPendingRewards = function(self, seasonid)
	return self.Invoke(self, 63610266, SerializerHelper.AskTakeOnlineSeasonProgressPendingRewards_Serializer, seasonid)
end

SerializerHelper.AskInviteFriendToLink_Serializer = function(writer, type, friendid, doublecheck)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 8, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, friendid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, doublecheck, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskInviteFriendToLink = function(self, type, friendid, doublecheck)
	return self.Invoke(self, 63610592, SerializerHelper.AskInviteFriendToLink_Serializer, type, friendid, doublecheck)
end

SerializerHelper.RpcCollectionBookDyeEffect_Serializer = function(writer, bagid, cellx, celly)
	SerializeBase.WritePrimitive(writer, bagid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
end

ClientToGameDelegate.RpcCollectionBookDyeEffect = function(self, bagid, cellx, celly)
	return self.Invoke(self, 63613287, SerializerHelper.RpcCollectionBookDyeEffect_Serializer, bagid, cellx, celly)
end

SerializerHelper.AskVehicleShopDestroyParking_Serializer = function(writer, shopid)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskVehicleShopDestroyParking = function(self, shopid)
	return self.Invoke(self, 63613647, SerializerHelper.AskVehicleShopDestroyParking_Serializer, shopid)
end

SerializerHelper.AskBuyCommodities_Serializer = function(writer, shopid, commodityiddict)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WriteDict7Bit(writer, commodityiddict, writer.WriteUInt32, writer.WriteUInt32, 0, "commodityiddict", false, RpcLengthLimits.IClientToGame_AskBuyCommodities_commodityIdDict)
end

ClientToGameDelegate.AskBuyCommodities = function(self, shopid, commodityiddict)
	return self.Invoke(self, 63614427, SerializerHelper.AskBuyCommodities_Serializer, shopid, commodityiddict)
end

SerializerHelper.AskClearBasketballOtherPlayers_Serializer = function(writer, gadgetid, playerinfos)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, playerinfos, SerializeBase.WriteComplexWrap(SerializeAuto.WriteClearWorldBattleOtherPlayer, "ClearWorldBattleOtherPlayer", false), nil, "playerinfos", false, RpcLengthLimits.IClientToGame_AskClearBasketballOtherPlayers_playerInfos, nil)
end

ClientToGameDelegate.AskClearBasketballOtherPlayers = function(self, gadgetid, playerinfos)
	return self.Invoke(self, 63614551, SerializerHelper.AskClearBasketballOtherPlayers_Serializer, gadgetid, playerinfos)
end

SerializerHelper.AskGetWasherMissionInfo_Serializer = function(writer, force)
	SerializeBase.WritePrimitive(writer, force, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskGetWasherMissionInfo = function(self, force)
	return self.Invoke(self, 63615574, SerializerHelper.AskGetWasherMissionInfo_Serializer, force)
end

SerializerHelper.AskDeleteTask_Serializer = function(writer, taskid, fail)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fail, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskDeleteTask = function(self, taskid, fail)
	return self.Invoke(self, 63618078, SerializerHelper.AskDeleteTask_Serializer, taskid, fail)
end

SerializerHelper.AskClearPersonalZoneNewSpiritNum_Serializer = function(writer)
end

ClientToGameDelegate.AskClearPersonalZoneNewSpiritNum = function(self)
	return self.Invoke(self, 63618518, SerializerHelper.AskClearPersonalZoneNewSpiritNum_Serializer)
end

SerializerHelper.GetSpriteToken_Serializer = function(writer, device, os)
	writer.WriteString(writer, device, false, "GetSpriteToken.device", RpcLengthLimits.IClientToGame_GetSpriteToken_device)
	writer.WriteString(writer, os, false, "GetSpriteToken.os", RpcLengthLimits.IClientToGame_GetSpriteToken_os)
end

ClientToGameDelegate.GetSpriteToken = function(self, device, os)
	return self.Invoke(self, 63619121, SerializerHelper.GetSpriteToken_Serializer, device, os)
end

SerializerHelper.AskStartCardFlipGame_Serializer = function(writer, difficulty)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(difficulty, 35, 1), writer.WriteByte, 1)
end

ClientToGameDelegate.AskStartCardFlipGame = function(self, difficulty)
	return self.Invoke(self, 63622224, SerializerHelper.AskStartCardFlipGame_Serializer, difficulty)
end

SerializerHelper.AskDivinerStartTimeCheck_Serializer = function(writer, lang)
	writer.WriteString(writer, lang, false, "AskDivinerStartTimeCheck.lang", RpcLengthLimits.IClientToGame_AskDivinerStartTimeCheck_lang)
end

ClientToGameDelegate.AskDivinerStartTimeCheck = function(self, lang)
	return self.Invoke(self, 63622995, SerializerHelper.AskDivinerStartTimeCheck_Serializer, lang)
end

SerializerHelper.AskModifyHouse_Serializer = function(writer, houseid, modification)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, modification, SerializeAuto.WriteHouseModification, "modification")
end

ClientToGameDelegate.AskModifyHouse = function(self, houseid, modification)
	return self.Invoke(self, 63623092, SerializerHelper.AskModifyHouse_Serializer, houseid, modification)
end

SerializerHelper.AskSyncWeaponSkinToSpirits_Serializer = function(writer, sourcespiritid, targetspiritids)
	SerializeBase.WritePrimitive(writer, sourcespiritid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, targetspiritids, writer.WriteUInt32, 0, "targetspiritids", false, RpcLengthLimits.IClientToGame_AskSyncWeaponSkinToSpirits_targetSpiritIds, nil)
end

ClientToGameDelegate.AskSyncWeaponSkinToSpirits = function(self, sourcespiritid, targetspiritids)
	return self.Invoke(self, 63623831, SerializerHelper.AskSyncWeaponSkinToSpirits_Serializer, sourcespiritid, targetspiritids)
end

SerializerHelper.AskReadFashionSuits_Serializer = function(writer, fashionsuitidlist)
	SerializeBase.WriteList7Bit(writer, fashionsuitidlist, writer.WriteUInt32, 0, "fashionsuitidlist", false, RpcLengthLimits.IClientToGame_AskReadFashionSuits_fashionSuitIdList, nil)
end

ClientToGameDelegate.AskReadFashionSuits = function(self, fashionsuitidlist)
	return self.Invoke(self, 63626107, SerializerHelper.AskReadFashionSuits_Serializer, fashionsuitidlist)
end

SerializerHelper.AskSetInputDeviceType_Serializer = function(writer, devicetype)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(devicetype, 36, 1), writer.WriteByte, 1)
end

ClientToGameDelegate.AskSetInputDeviceType = function(self, devicetype)
	return self.Invoke(self, 63626774, SerializerHelper.AskSetInputDeviceType_Serializer, devicetype)
end

SerializerHelper.AskNameAnimal_Serializer = function(writer, animalid, nickname)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	writer.WriteString(writer, nickname, false, "AskNameAnimal.nickName", RpcLengthLimits.IClientToGame_AskNameAnimal_nickName)
end

ClientToGameDelegate.AskNameAnimal = function(self, animalid, nickname)
	return self.Invoke(self, 63627320, SerializerHelper.AskNameAnimal_Serializer, animalid, nickname)
end

SerializerHelper.AskCloseFarmerShopApp_Serializer = function(writer)
end

ClientToGameDelegate.AskCloseFarmerShopApp = function(self)
	return self.Invoke(self, 63627409, SerializerHelper.AskCloseFarmerShopApp_Serializer)
end

SerializerHelper.AskAdjustMapPinPosition_Serializer = function(writer, pinid, pos)
	SerializeBase.WritePrimitive(writer, pinid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
end

ClientToGameDelegate.AskAdjustMapPinPosition = function(self, pinid, pos)
	return self.Invoke(self, 63631791, SerializerHelper.AskAdjustMapPinPosition_Serializer, pinid, pos)
end

SerializerHelper.AskTakeSevenDaysTaskReward_Serializer = function(writer, id, taskid)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeSevenDaysTaskReward = function(self, id, taskid)
	return self.Invoke(self, 63633748, SerializerHelper.AskTakeSevenDaysTaskReward_Serializer, id, taskid)
end

SerializerHelper.AskGeneralBuyBackWeaponToShop_Serializer = function(writer, shopid, weaponinstanceid)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskGeneralBuyBackWeaponToShop = function(self, shopid, weaponinstanceid)
	return self.Invoke(self, 63634218, SerializerHelper.AskGeneralBuyBackWeaponToShop_Serializer, shopid, weaponinstanceid)
end

SerializerHelper.AskLeaveRaidRandomEvent_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskLeaveRaidRandomEvent = function(self, eventid)
	self.Notify(self, 63634608, SerializerHelper.AskLeaveRaidRandomEvent_Serializer, eventid)
end

SerializerHelper.AskQueryClubInfo_Serializer = function(writer, clubid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskQueryClubInfo = function(self, clubid)
	return self.Invoke(self, 63635909, SerializerHelper.AskQueryClubInfo_Serializer, clubid)
end

SerializerHelper.AskStartTruckOrderGuide_Serializer = function(writer)
end

ClientToGameDelegate.AskStartTruckOrderGuide = function(self)
	return self.Invoke(self, 63637032, SerializerHelper.AskStartTruckOrderGuide_Serializer)
end

SerializerHelper.AskTakeAccumulateSignInReward_Serializer = function(writer, id, index)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskTakeAccumulateSignInReward = function(self, id, index)
	return self.Invoke(self, 63637174, SerializerHelper.AskTakeAccumulateSignInReward_Serializer, id, index)
end

SerializerHelper.AskOCPolish_Serializer = function(writer, ocid, description, story)
	SerializeBase.WritePrimitive(writer, ocid, writer.WriteUInt64, 0)
	writer.WriteString(writer, description, true, "AskOCPolish.description", RpcLengthLimits.IClientToGame_AskOCPolish_description)
	writer.WriteString(writer, story, true, "AskOCPolish.story", RpcLengthLimits.IClientToGame_AskOCPolish_story)
end

ClientToGameDelegate.AskOCPolish = function(self, ocid, description, story)
	return self.Invoke(self, 63638440, SerializerHelper.AskOCPolish_Serializer, ocid, description, story)
end

SerializerHelper.AskClearNpcUncompletedInviteChat_Serializer = function(writer)
end

ClientToGameDelegate.AskClearNpcUncompletedInviteChat = function(self)
	return self.Invoke(self, 63639364, SerializerHelper.AskClearNpcUncompletedInviteChat_Serializer)
end

SerializerHelper.AskEnterRogueRaid_Serializer = function(writer, rogueid)
	SerializeBase.WritePrimitive(writer, rogueid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskEnterRogueRaid = function(self, rogueid)
	return self.Invoke(self, 63639565, SerializerHelper.AskEnterRogueRaid_Serializer, rogueid)
end

SerializerHelper.AskApplyToTeam_Serializer = function(writer, teamid)
	SerializeBase.WritePrimitive(writer, teamid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskApplyToTeam = function(self, teamid)
	return self.Invoke(self, 63640403, SerializerHelper.AskApplyToTeam_Serializer, teamid)
end

SerializerHelper.AskNonDirectionalEnchant_Serializer = function(writer, weaponinstanceid)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskNonDirectionalEnchant = function(self, weaponinstanceid)
	return self.Invoke(self, 63644760, SerializerHelper.AskNonDirectionalEnchant_Serializer, weaponinstanceid)
end

SerializerHelper.RequestMailInfo_Serializer = function(writer, mailid)
	SerializeBase.WritePrimitive(writer, mailid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.RequestMailInfo = function(self, mailid)
	return self.Invoke(self, 63647856, SerializerHelper.RequestMailInfo_Serializer, mailid)
end

SerializerHelper.AskBuyHaircutCommodities_Serializer = function(writer, shopid, commodityiddict)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WriteDict7Bit(writer, commodityiddict, writer.WriteUInt32, writer.WriteUInt32, 0, "commodityiddict", false, RpcLengthLimits.IClientToGame_AskBuyHaircutCommodities_commodityIdDict)
end

ClientToGameDelegate.AskBuyHaircutCommodities = function(self, shopid, commodityiddict)
	return self.Invoke(self, 63647964, SerializerHelper.AskBuyHaircutCommodities_Serializer, shopid, commodityiddict)
end

SerializerHelper.UsePoliceChargingProgress_Serializer = function(writer, info)
	SerializeBase.WriteStruct(writer, info, SerializeAuto.WritePoliceChargingSkillInfo, "info")
end

ClientToGameDelegate.UsePoliceChargingProgress = function(self, info)
	return self.Invoke(self, 63649646, SerializerHelper.UsePoliceChargingProgress_Serializer, info)
end

SerializerHelper.CastMatchVote_Serializer = function(writer, vote)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(vote, 37, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.CastMatchVote = function(self, vote)
	return self.Invoke(self, 63650301, SerializerHelper.CastMatchVote_Serializer, vote)
end

SerializerHelper.AskEnterXinQiRaid_Serializer = function(writer)
end

ClientToGameDelegate.AskEnterXinQiRaid = function(self)
	return self.Invoke(self, 63652360, SerializerHelper.AskEnterXinQiRaid_Serializer)
end

SerializerHelper.AskConfirmMatchResult_Serializer = function(writer, ready)
	SerializeBase.WritePrimitive(writer, ready, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskConfirmMatchResult = function(self, ready)
	return self.Invoke(self, 63652665, SerializerHelper.AskConfirmMatchResult_Serializer, ready)
end

SerializerHelper.AskExtractionShooterRemoveItem_Serializer = function(writer, bagconfigid, cellx, celly)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskExtractionShooterRemoveItem = function(self, bagconfigid, cellx, celly)
	return self.Invoke(self, 63652942, SerializerHelper.AskExtractionShooterRemoveItem_Serializer, bagconfigid, cellx, celly)
end

SerializerHelper.AskTuiteGetDetail_Serializer = function(writer, tuiteid)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTuiteGetDetail = function(self, tuiteid)
	return self.Invoke(self, 63653286, SerializerHelper.AskTuiteGetDetail_Serializer, tuiteid)
end

SerializerHelper.AskTamagotchiCollectPet_Serializer = function(writer, petid)
	SerializeBase.WritePrimitive(writer, petid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTamagotchiCollectPet = function(self, petid)
	return self.Invoke(self, 63653465, SerializerHelper.AskTamagotchiCollectPet_Serializer, petid)
end

SerializerHelper.AskGiveUpPainting_Serializer = function(writer)
end

ClientToGameDelegate.AskGiveUpPainting = function(self)
	return self.Invoke(self, 63653759, SerializerHelper.AskGiveUpPainting_Serializer)
end

SerializerHelper.OnStealPhone_Serializer = function(writer)
end

ClientToGameDelegate.OnStealPhone = function(self)
	self.Notify(self, 63654437, SerializerHelper.OnStealPhone_Serializer)
end

SerializerHelper.AskGetClubEvents_Serializer = function(writer)
end

ClientToGameDelegate.AskGetClubEvents = function(self)
	return self.Invoke(self, 63661177, SerializerHelper.AskGetClubEvents_Serializer)
end

SerializerHelper.AskChangeClubOwner_Serializer = function(writer, clubid, newownerpid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, newownerpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskChangeClubOwner = function(self, clubid, newownerpid)
	return self.Invoke(self, 63663659, SerializerHelper.AskChangeClubOwner_Serializer, clubid, newownerpid)
end

SerializerHelper.AskEndBartenderGame_Serializer = function(writer)
end

ClientToGameDelegate.AskEndBartenderGame = function(self)
	return self.Invoke(self, 63663740, SerializerHelper.AskEndBartenderGame_Serializer)
end

SerializerHelper.AskBringInItems_Serializer = function(writer, items)
	SerializeBase.WriteDict7Bit(writer, items, writer.WriteUInt32, writer.WriteUInt32, 0, "items", false, RpcLengthLimits.IClientToGame_AskBringInItems_items)
end

ClientToGameDelegate.AskBringInItems = function(self, items)
	return self.Invoke(self, 63663953, SerializerHelper.AskBringInItems_Serializer, items)
end

SerializerHelper.VehicleDriveScore_Serializer = function(writer, score)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameDelegate.VehicleDriveScore = function(self, score)
	return self.Invoke(self, 63663967, SerializerHelper.VehicleDriveScore_Serializer, score)
end

SerializerHelper.AskEndRowBoatInvite_Serializer = function(writer)
end

ClientToGameDelegate.AskEndRowBoatInvite = function(self)
	return self.Invoke(self, 63664785, SerializerHelper.AskEndRowBoatInvite_Serializer)
end

SerializerHelper.AskTakeNpcProfileTrustReward_Serializer = function(writer, profileid, rewardid)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, rewardid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeNpcProfileTrustReward = function(self, profileid, rewardid)
	return self.Invoke(self, 63665219, SerializerHelper.AskTakeNpcProfileTrustReward_Serializer, profileid, rewardid)
end

SerializerHelper.AskLiveHouseUseItem_Serializer = function(writer, musicid)
	SerializeBase.WritePrimitive(writer, musicid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskLiveHouseUseItem = function(self, musicid)
	return self.Invoke(self, 63665380, SerializerHelper.AskLiveHouseUseItem_Serializer, musicid)
end

SerializerHelper.OnPaperCranesFly_Serializer = function(writer)
end

ClientToGameDelegate.OnPaperCranesFly = function(self)
	self.Notify(self, 63668134, SerializerHelper.OnPaperCranesFly_Serializer)
end

SerializerHelper.AskAnimalHandbookInteract_Serializer = function(writer, animalid)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskAnimalHandbookInteract = function(self, animalid)
	return self.Invoke(self, 63668381, SerializerHelper.AskAnimalHandbookInteract_Serializer, animalid)
end

SerializerHelper.DoMessageCallback_Serializer = function(writer, messageid, state, para)
	SerializeBase.WritePrimitive(writer, messageid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(state, 38, 0), writer.WriteByte, 0)
	SerializeBase.WriteComplex(writer, para, SerializeAuto.WriteMessageCallbackParameter, "para", true)
end

ClientToGameDelegate.DoMessageCallback = function(self, messageid, state, para)
	return self.Invoke(self, 63670878, SerializerHelper.DoMessageCallback_Serializer, messageid, state, para)
end

SerializerHelper.AskClaimTouTingRumors_Serializer = function(writer, rumorids)
	SerializeBase.WriteList7Bit(writer, rumorids, writer.WriteUInt32, 0, "rumorids", false, RpcLengthLimits.IClientToGame_AskClaimTouTingRumors_rumorIds, nil)
end

ClientToGameDelegate.AskClaimTouTingRumors = function(self, rumorids)
	return self.Invoke(self, 63672055, SerializerHelper.AskClaimTouTingRumors_Serializer, rumorids)
end

SerializerHelper.AskTakeOnlineSeasonProgressTaskReward_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeOnlineSeasonProgressTaskReward = function(self, taskid)
	return self.Invoke(self, 63675003, SerializerHelper.AskTakeOnlineSeasonProgressTaskReward_Serializer, taskid)
end

SerializerHelper.RpcTakePhoto_Serializer = function(writer)
end

ClientToGameDelegate.RpcTakePhoto = function(self)
	return self.Invoke(self, 63675176, SerializerHelper.RpcTakePhoto_Serializer)
end

SerializerHelper.AskOCBindOCSpeech_Serializer = function(writer, ocid, speechname, speechweights, soundeffectconfig)
	SerializeBase.WritePrimitive(writer, ocid, writer.WriteUInt64, 0)
	writer.WriteString(writer, speechname, false, "AskOCBindOCSpeech.speechName", RpcLengthLimits.IClientToGame_AskOCBindOCSpeech_speechName)
	SerializeBase.WriteDict7Bit(writer, speechweights, SerializeBase.WriteStringWrap(false, "speechweights", RpcLengthLimits.IClientToGame_AskOCBindOCSpeech_speechWeights_String), writer.WriteSingle, 0, "speechweights", false, RpcLengthLimits.IClientToGame_AskOCBindOCSpeech_speechWeights)
	SerializeBase.WriteComplex(writer, soundeffectconfig, SerializeAuto.WriteSoundEffectConfig, "soundeffectconfig", false)
end

ClientToGameDelegate.AskOCBindOCSpeech = function(self, ocid, speechname, speechweights, soundeffectconfig)
	return self.Invoke(self, 63677541, SerializerHelper.AskOCBindOCSpeech_Serializer, ocid, speechname, speechweights, soundeffectconfig)
end

SerializerHelper.AskCompleteUrbanPlay_Serializer = function(writer, playresult)
	SerializeBase.WriteComplex(writer, playresult, SerializeAuto.WriteUrbanGamePlayResult, "playresult", false)
end

ClientToGameDelegate.AskCompleteUrbanPlay = function(self, playresult)
	self.Notify(self, 63677874, SerializerHelper.AskCompleteUrbanPlay_Serializer, playresult)
end

SerializerHelper.AskClawDateFail_Serializer = function(writer)
end

ClientToGameDelegate.AskClawDateFail = function(self)
	return self.Invoke(self, 63678091, SerializerHelper.AskClawDateFail_Serializer)
end

SerializerHelper.AskUpdatePlayerScenarioInfo_Serializer = function(writer, slot, info)
	SerializeBase.WritePrimitive(writer, slot, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WritePlayerScenarioInfo, "info", true)
end

ClientToGameDelegate.AskUpdatePlayerScenarioInfo = function(self, slot, info)
	return self.Invoke(self, 63680600, SerializerHelper.AskUpdatePlayerScenarioInfo_Serializer, slot, info)
end

SerializerHelper.AskReadCityPediaBatch_Serializer = function(writer, citypediaidlist)
	SerializeBase.WriteList7Bit(writer, citypediaidlist, writer.WriteUInt32, 0, "citypediaidlist", false, RpcLengthLimits.IClientToGame_AskReadCityPediaBatch_cityPediaIdList, nil)
end

ClientToGameDelegate.AskReadCityPediaBatch = function(self, citypediaidlist)
	return self.Invoke(self, 63681037, SerializerHelper.AskReadCityPediaBatch_Serializer, citypediaidlist)
end

SerializerHelper.DeleteUgcMapInfo_Serializer = function(writer, mapid)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.DeleteUgcMapInfo = function(self, mapid)
	return self.Invoke(self, 63681315, SerializerHelper.DeleteUgcMapInfo_Serializer, mapid)
end

SerializerHelper.AskReportGadgetStuntJumpRecord_Serializer = function(writer, gadgetid, stuntjumpdistance, stuntjumpheight)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stuntjumpdistance, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, stuntjumpheight, writer.WriteSingle, 0)
end

ClientToGameDelegate.AskReportGadgetStuntJumpRecord = function(self, gadgetid, stuntjumpdistance, stuntjumpheight)
	return self.Invoke(self, 63682162, SerializerHelper.AskReportGadgetStuntJumpRecord_Serializer, gadgetid, stuntjumpdistance, stuntjumpheight)
end

SerializerHelper.ReportPostTeleportFinish_Serializer = function(writer, teleportid, result)
	SerializeBase.WritePrimitive(writer, teleportid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(result, 39, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.ReportPostTeleportFinish = function(self, teleportid, result)
	self.Notify(self, 63682240, SerializerHelper.ReportPostTeleportFinish_Serializer, teleportid, result)
end

SerializerHelper.AskExtractionShooterSortBag_Serializer = function(writer, bagconfigid)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskExtractionShooterSortBag = function(self, bagconfigid)
	return self.Invoke(self, 63684613, SerializerHelper.AskExtractionShooterSortBag_Serializer, bagconfigid)
end

SerializerHelper.AskHousePurchaseVideoTeleport_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskHousePurchaseVideoTeleport = function(self, houseid)
	return self.Invoke(self, 63686903, SerializerHelper.AskHousePurchaseVideoTeleport_Serializer, houseid)
end

SerializerHelper.AskGetOnMobilePlatform_Serializer = function(writer, mobileplatformid)
	SerializeBase.WritePrimitive(writer, mobileplatformid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskGetOnMobilePlatform = function(self, mobileplatformid)
	return self.Invoke(self, 63687984, SerializerHelper.AskGetOnMobilePlatform_Serializer, mobileplatformid)
end

SerializerHelper.AskRemoveRumorFromSlot_Serializer = function(writer, wuxueid, slottype)
	SerializeBase.WritePrimitive(writer, wuxueid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slottype, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskRemoveRumorFromSlot = function(self, wuxueid, slottype)
	return self.Invoke(self, 63688662, SerializerHelper.AskRemoveRumorFromSlot_Serializer, wuxueid, slottype)
end

SerializerHelper.AskClawBuyTicket_Serializer = function(writer)
end

ClientToGameDelegate.AskClawBuyTicket = function(self)
	return self.Invoke(self, 63690710, SerializerHelper.AskClawBuyTicket_Serializer)
end

SerializerHelper.TryUnlockNpcVoice_Serializer = function(writer, npccultivationid, voiceid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, voiceid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.TryUnlockNpcVoice = function(self, npccultivationid, voiceid)
	return self.Invoke(self, 63691751, SerializerHelper.TryUnlockNpcVoice_Serializer, npccultivationid, voiceid)
end

SerializerHelper.AskCancelNpcProfileNew_Serializer = function(writer, profileid)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskCancelNpcProfileNew = function(self, profileid)
	return self.Invoke(self, 63692447, SerializerHelper.AskCancelNpcProfileNew_Serializer, profileid)
end

SerializerHelper.AskActivateNpcProfile_Serializer = function(writer, profileid)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskActivateNpcProfile = function(self, profileid)
	return self.Invoke(self, 63692493, SerializerHelper.AskActivateNpcProfile_Serializer, profileid)
end

SerializerHelper.Chi_Serializer = function(writer, selectpais)
	SerializeBase.WriteList7Bit(writer, selectpais, SerializeBase.WriteStructWrap(SerializeAuto.WriteMjPaiInfo, "selectpais"), nil, "selectpais", false, RpcLengthLimits.IClientToGame_Chi_selectPais, nil)
end

ClientToGameDelegate.Chi = function(self, selectpais)
	self.Notify(self, 63693559, SerializerHelper.Chi_Serializer, selectpais)
end

SerializerHelper.AskHangUpDialog_Serializer = function(writer, taskid, dialogid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskHangUpDialog = function(self, taskid, dialogid)
	return self.Invoke(self, 63693679, SerializerHelper.AskHangUpDialog_Serializer, taskid, dialogid)
end

SerializerHelper.AskDivinerLiveChatOpen_Serializer = function(writer, lang)
	writer.WriteString(writer, lang, false, "AskDivinerLiveChatOpen.lang", RpcLengthLimits.IClientToGame_AskDivinerLiveChatOpen_lang)
end

ClientToGameDelegate.AskDivinerLiveChatOpen = function(self, lang)
	return self.Invoke(self, 63693729, SerializerHelper.AskDivinerLiveChatOpen_Serializer, lang)
end

SerializerHelper.AskPhoneAddContactToGroup_Serializer = function(writer, spiritid, groupindex, phonenumberlist)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, groupindex, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, phonenumberlist, SerializeBase.WriteStringWrap(false, "phonenumberlist", RpcLengthLimits.IClientToGame_AskPhoneAddContactToGroup_phoneNumberList_String), nil, "phonenumberlist", false, RpcLengthLimits.IClientToGame_AskPhoneAddContactToGroup_phoneNumberList, nil)
end

ClientToGameDelegate.AskPhoneAddContactToGroup = function(self, spiritid, groupindex, phonenumberlist)
	return self.Invoke(self, 63694616, SerializerHelper.AskPhoneAddContactToGroup_Serializer, spiritid, groupindex, phonenumberlist)
end

SerializerHelper.AskReportArcadeGameResultBee_Serializer = function(writer, gameresult)
	SerializeBase.WriteComplex(writer, gameresult, SerializeAuto.WriteArcadeGameResultBee, "gameresult", false)
end

ClientToGameDelegate.AskReportArcadeGameResultBee = function(self, gameresult)
	return self.Invoke(self, 63696576, SerializerHelper.AskReportArcadeGameResultBee_Serializer, gameresult)
end

SerializerHelper.AskFavoriteFashionSuits_Serializer = function(writer, unfavoritefashionsuitidlist, favoritefashionsuitidlist)
	SerializeBase.WriteList7Bit(writer, unfavoritefashionsuitidlist, writer.WriteUInt32, 0, "unfavoritefashionsuitidlist", true, RpcLengthLimits.IClientToGame_AskFavoriteFashionSuits_unfavoriteFashionSuitIdList, nil)
	SerializeBase.WriteList7Bit(writer, favoritefashionsuitidlist, writer.WriteUInt32, 0, "favoritefashionsuitidlist", true, RpcLengthLimits.IClientToGame_AskFavoriteFashionSuits_favoriteFashionSuitIdList, nil)
end

ClientToGameDelegate.AskFavoriteFashionSuits = function(self, unfavoritefashionsuitidlist, favoritefashionsuitidlist)
	return self.Invoke(self, 63696705, SerializerHelper.AskFavoriteFashionSuits_Serializer, unfavoritefashionsuitidlist, favoritefashionsuitidlist)
end

SerializerHelper.AskUseItemToFightSpirit_Serializer = function(writer, uid, itemcount)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, itemcount, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUseItemToFightSpirit = function(self, uid, itemcount)
	return self.Invoke(self, 63696776, SerializerHelper.AskUseItemToFightSpirit_Serializer, uid, itemcount)
end

SerializerHelper.AskQueryPlayerUnlockPopUp_Serializer = function(writer)
end

ClientToGameDelegate.AskQueryPlayerUnlockPopUp = function(self)
	return self.Invoke(self, 63697861, SerializerHelper.AskQueryPlayerUnlockPopUp_Serializer)
end

SerializerHelper.AskPhoneEditContact_Serializer = function(writer, spiritid, oldphonenumber, newphonenumber, contactname)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer.WriteString(writer, oldphonenumber, false, "AskPhoneEditContact.oldPhoneNumber", RpcLengthLimits.IClientToGame_AskPhoneEditContact_oldPhoneNumber)
	writer.WriteString(writer, newphonenumber, false, "AskPhoneEditContact.newPhoneNumber", RpcLengthLimits.IClientToGame_AskPhoneEditContact_newPhoneNumber)
	writer.WriteString(writer, contactname, false, "AskPhoneEditContact.contactName", RpcLengthLimits.IClientToGame_AskPhoneEditContact_contactName)
end

ClientToGameDelegate.AskPhoneEditContact = function(self, spiritid, oldphonenumber, newphonenumber, contactname)
	return self.Invoke(self, 63698450, SerializerHelper.AskPhoneEditContact_Serializer, spiritid, oldphonenumber, newphonenumber, contactname)
end

SerializerHelper.AskNpcShopCommodityInfo_Serializer = function(writer, shopid)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskNpcShopCommodityInfo = function(self, shopid)
	return self.Invoke(self, 63699253, SerializerHelper.AskNpcShopCommodityInfo_Serializer, shopid)
end

SerializerHelper.AskInviteToTeam_Serializer = function(writer, inviteepid, doublecheck)
	SerializeBase.WritePrimitive(writer, inviteepid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, doublecheck, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskInviteToTeam = function(self, inviteepid, doublecheck)
	return self.Invoke(self, 63699354, SerializerHelper.AskInviteToTeam_Serializer, inviteepid, doublecheck)
end

SerializerHelper.AskHack_Serializer = function(writer, hacktype)
	SerializeBase.WritePrimitive(writer, hacktype, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskHack = function(self, hacktype)
	return self.Invoke(self, 63700695, SerializerHelper.AskHack_Serializer, hacktype)
end

SerializerHelper.AskBuyModifyParts_Serializer = function(writer, shopid, vehicleid, commodityiddict, removedparttypes)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
	SerializeBase.WriteDict7Bit(writer, commodityiddict, writer.WriteUInt32, writer.WriteUInt32, 0, "commodityiddict", false, RpcLengthLimits.IClientToGame_AskBuyModifyParts_commodityIdDict)
	SerializeBase.WriteList7Bit(writer, removedparttypes, writer.WriteUInt32, 0, "removedparttypes", false, RpcLengthLimits.IClientToGame_AskBuyModifyParts_removedPartTypes, nil)
end

ClientToGameDelegate.AskBuyModifyParts = function(self, shopid, vehicleid, commodityiddict, removedparttypes)
	return self.Invoke(self, 63701165, SerializerHelper.AskBuyModifyParts_Serializer, shopid, vehicleid, commodityiddict, removedparttypes)
end

SerializerHelper.AskUpdatePersonalZoneDescription_Serializer = function(writer, pid, desc)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, desc, false, "AskUpdatePersonalZoneDescription.desc", RpcLengthLimits.IClientToGame_AskUpdatePersonalZoneDescription_desc)
end

ClientToGameDelegate.AskUpdatePersonalZoneDescription = function(self, pid, desc)
	return self.Invoke(self, 63703224, SerializerHelper.AskUpdatePersonalZoneDescription_Serializer, pid, desc)
end

SerializerHelper.AskSkipPoliceTask_Serializer = function(writer)
end

ClientToGameDelegate.AskSkipPoliceTask = function(self)
	return self.Invoke(self, 63706657, SerializerHelper.AskSkipPoliceTask_Serializer)
end

SerializerHelper.AskPhoneDeleteContact_Serializer = function(writer, spiritid, phonenumber)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer.WriteString(writer, phonenumber, false, "AskPhoneDeleteContact.phoneNumber", RpcLengthLimits.IClientToGame_AskPhoneDeleteContact_phoneNumber)
end

ClientToGameDelegate.AskPhoneDeleteContact = function(self, spiritid, phonenumber)
	return self.Invoke(self, 63707116, SerializerHelper.AskPhoneDeleteContact_Serializer, spiritid, phonenumber)
end

SerializerHelper.AskKTVFinishPackageTicket_Serializer = function(writer, ticketid)
	SerializeBase.WritePrimitive(writer, ticketid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskKTVFinishPackageTicket = function(self, ticketid)
	return self.Invoke(self, 63708015, SerializerHelper.AskKTVFinishPackageTicket_Serializer, ticketid)
end

SerializerHelper.AskChangeClubSettings_Serializer = function(writer, clubid, name, declaration, iconid, setting)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	writer.WriteString(writer, name, false, "AskChangeClubSettings.name", RpcLengthLimits.IClientToGame_AskChangeClubSettings_name)
	writer.WriteString(writer, declaration, true, "AskChangeClubSettings.declaration", RpcLengthLimits.IClientToGame_AskChangeClubSettings_declaration)
	SerializeBase.WritePrimitive(writer, iconid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteClubSetting, "setting", false)
end

ClientToGameDelegate.AskChangeClubSettings = function(self, clubid, name, declaration, iconid, setting)
	return self.Invoke(self, 63710866, SerializerHelper.AskChangeClubSettings_Serializer, clubid, name, declaration, iconid, setting)
end

SerializerHelper.AskTamagotchiInteract_Serializer = function(writer, interacttype, pid, giftitems)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(interacttype, 24, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WriteDict7Bit(writer, giftitems, writer.WriteUInt32, writer.WriteUInt32, 0, "giftitems", false, RpcLengthLimits.IClientToGame_AskTamagotchiInteract_giftItems)
end

ClientToGameDelegate.AskTamagotchiInteract = function(self, interacttype, pid, giftitems)
	return self.Invoke(self, 63713643, SerializerHelper.AskTamagotchiInteract_Serializer, interacttype, pid, giftitems)
end

SerializerHelper.AskGetClubApplicationList_Serializer = function(writer, clubid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskGetClubApplicationList = function(self, clubid)
	return self.Invoke(self, 63713811, SerializerHelper.AskGetClubApplicationList_Serializer, clubid)
end

SerializerHelper.GetPSOUploadObjectUrl_Serializer = function(writer, branchname, platformname, objectname)
	writer.WriteString(writer, branchname, false, "GetPSOUploadObjectUrl.branchName", RpcLengthLimits.IClientToGame_GetPSOUploadObjectUrl_branchName)
	writer.WriteString(writer, platformname, false, "GetPSOUploadObjectUrl.platformName", RpcLengthLimits.IClientToGame_GetPSOUploadObjectUrl_platformName)
	writer.WriteString(writer, objectname, false, "GetPSOUploadObjectUrl.objectName", RpcLengthLimits.IClientToGame_GetPSOUploadObjectUrl_objectName)
end

ClientToGameDelegate.GetPSOUploadObjectUrl = function(self, branchname, platformname, objectname)
	return self.Invoke(self, 63713869, SerializerHelper.GetPSOUploadObjectUrl_Serializer, branchname, platformname, objectname)
end

SerializerHelper.SetShortChatWheelByIndex_Serializer = function(writer, multitypeid, index2items)
	SerializeBase.WritePrimitive(writer, multitypeid, writer.WriteUInt32, 0)
	SerializeBase.WriteDict7Bit(writer, index2items, writer.WriteInt32, SerializeBase.WriteComplexWrap(SerializeAuto.WriteChatWheelItem, "ChatWheelItem", false), nil, "index2items", false, RpcLengthLimits.IClientToGame_SetShortChatWheelByIndex_index2Items)
end

ClientToGameDelegate.SetShortChatWheelByIndex = function(self, multitypeid, index2items)
	return self.Invoke(self, 63715342, SerializerHelper.SetShortChatWheelByIndex_Serializer, multitypeid, index2items)
end

SerializerHelper.AskTouTing_Serializer = function(writer, gossipid)
	SerializeBase.WritePrimitive(writer, gossipid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTouTing = function(self, gossipid)
	return self.Invoke(self, 63715550, SerializerHelper.AskTouTing_Serializer, gossipid)
end

SerializerHelper.AskInstallMobileApp_Serializer = function(writer, appid)
	SerializeBase.WritePrimitive(writer, appid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskInstallMobileApp = function(self, appid)
	return self.Invoke(self, 63715809, SerializerHelper.AskInstallMobileApp_Serializer, appid)
end

SerializerHelper.AskSelectPartyDanceMode_Serializer = function(writer, mode)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 40, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskSelectPartyDanceMode = function(self, mode)
	return self.Invoke(self, 63715994, SerializerHelper.AskSelectPartyDanceMode_Serializer, mode)
end

SerializerHelper.AskMassageBuyTicket_Serializer = function(writer, companionnpcid)
	SerializeBase.WritePrimitive(writer, companionnpcid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskMassageBuyTicket = function(self, companionnpcid)
	return self.Invoke(self, 63716827, SerializerHelper.AskMassageBuyTicket_Serializer, companionnpcid)
end

SerializerHelper.AskTakeLevelReward_Serializer = function(writer, level)
	SerializeBase.WritePrimitive(writer, level, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeLevelReward = function(self, level)
	return self.Invoke(self, 63717513, SerializerHelper.AskTakeLevelReward_Serializer, level)
end

SerializerHelper.SetKTVMusicResult_Serializer = function(writer, resultinfo)
	SerializeBase.WriteComplex(writer, resultinfo, SerializeAuto.WriteKTVMusicResultInfo, "resultinfo", false)
end

ClientToGameDelegate.SetKTVMusicResult = function(self, resultinfo)
	return self.Invoke(self, 63720830, SerializerHelper.SetKTVMusicResult_Serializer, resultinfo)
end

SerializerHelper.SetLiveHouseMusicResult_Serializer = function(writer, livehousemusicid, recordmusicinfo, npcid)
	SerializeBase.WritePrimitive(writer, livehousemusicid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, recordmusicinfo, writer.WriteUInt32, 0, "recordmusicinfo", false, RpcLengthLimits.IClientToGame_SetLiveHouseMusicResult_recordMusicInfo, nil)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.SetLiveHouseMusicResult = function(self, livehousemusicid, recordmusicinfo, npcid)
	return self.Invoke(self, 63723141, SerializerHelper.SetLiveHouseMusicResult_Serializer, livehousemusicid, recordmusicinfo, npcid)
end

SerializerHelper.AskDoDialogAction_Serializer = function(writer, dialogid)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskDoDialogAction = function(self, dialogid)
	return self.Invoke(self, 63723634, SerializerHelper.AskDoDialogAction_Serializer, dialogid)
end

SerializerHelper.ViewedEventPanel_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.ViewedEventPanel = function(self, eventid)
	return self.Invoke(self, 63724830, SerializerHelper.ViewedEventPanel_Serializer, eventid)
end

SerializerHelper.ClearMatch_Serializer = function(writer)
end

ClientToGameDelegate.ClearMatch = function(self)
	return self.Invoke(self, 63726578, SerializerHelper.ClearMatch_Serializer)
end

SerializerHelper.AskChangeClubSetting_Serializer = function(writer, clubid, setting)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, setting, SerializeAuto.WriteClubSetting, "setting", false)
end

ClientToGameDelegate.AskChangeClubSetting = function(self, clubid, setting)
	return self.Invoke(self, 63727852, SerializerHelper.AskChangeClubSetting_Serializer, clubid, setting)
end

SerializerHelper.AskGetAcceptedOrderWraps_Serializer = function(writer)
end

ClientToGameDelegate.AskGetAcceptedOrderWraps = function(self)
	return self.Invoke(self, 63728009, SerializerHelper.AskGetAcceptedOrderWraps_Serializer)
end

SerializerHelper.OnTafeiMotorColliding_Serializer = function(writer)
end

ClientToGameDelegate.OnTafeiMotorColliding = function(self)
	self.Notify(self, 63730520, SerializerHelper.OnTafeiMotorColliding_Serializer)
end

SerializerHelper.StartSingleParty_Serializer = function(writer, partyid, npcs, fashionsinfo)
	SerializeBase.WritePrimitive(writer, partyid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, npcs, writer.WriteUInt32, 0, "npcs", false, RpcLengthLimits.IClientToGame_StartSingleParty_NPCs, nil)
	SerializeBase.WriteComplex(writer, fashionsinfo, SerializeAuto.WritePartyNpcFashionsInfo, "fashionsinfo", true)
end

ClientToGameDelegate.StartSingleParty = function(self, partyid, npcs, fashionsinfo)
	return self.Invoke(self, 63731129, SerializerHelper.StartSingleParty_Serializer, partyid, npcs, fashionsinfo)
end

SerializerHelper.AskRankingTop_Serializer = function(writer, rankconfigid, options)
	SerializeBase.WritePrimitive(writer, rankconfigid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, options, SerializeAuto.WriteRankQueryOptions, "options", true)
end

ClientToGameDelegate.AskRankingTop = function(self, rankconfigid, options)
	return self.Invoke(self, 63732484, SerializerHelper.AskRankingTop_Serializer, rankconfigid, options)
end

SerializerHelper.AskSetSpiritFashionVariantPreference_Serializer = function(writer, spiritid, mainfashionid, variantfashionid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, mainfashionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, variantfashionid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSetSpiritFashionVariantPreference = function(self, spiritid, mainfashionid, variantfashionid)
	return self.Invoke(self, 63735260, SerializerHelper.AskSetSpiritFashionVariantPreference_Serializer, spiritid, mainfashionid, variantfashionid)
end

SerializerHelper.AskBringInItem_Serializer = function(writer, consumableid, count)
	SerializeBase.WritePrimitive(writer, consumableid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBringInItem = function(self, consumableid, count)
	return self.Invoke(self, 63735457, SerializerHelper.AskBringInItem_Serializer, consumableid, count)
end

SerializerHelper.AskFinishGuide_Serializer = function(writer, guideid, success)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskFinishGuide = function(self, guideid, success)
	return self.Invoke(self, 63736203, SerializerHelper.AskFinishGuide_Serializer, guideid, success)
end

SerializerHelper.AskReplyLinkApply_Serializer = function(writer, applierpid, linkid, accept)
	SerializeBase.WritePrimitive(writer, applierpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, linkid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskReplyLinkApply = function(self, applierpid, linkid, accept)
	return self.Invoke(self, 63737430, SerializerHelper.AskReplyLinkApply_Serializer, applierpid, linkid, accept)
end

SerializerHelper.AskAllSpiritPanelData_Serializer = function(writer)
end

ClientToGameDelegate.AskAllSpiritPanelData = function(self)
	return self.Invoke(self, 63738918, SerializerHelper.AskAllSpiritPanelData_Serializer)
end

SerializerHelper.AskReceiveChefCollectionReward_Serializer = function(writer, milestoneindex)
	SerializeBase.WritePrimitive(writer, milestoneindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskReceiveChefCollectionReward = function(self, milestoneindex)
	return self.Invoke(self, 63739851, SerializerHelper.AskReceiveChefCollectionReward_Serializer, milestoneindex)
end

SerializerHelper.AskResponseTeamInvite_Serializer = function(writer, inviter, teamid, reject)
	SerializeBase.WritePrimitive(writer, inviter, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, teamid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reject, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskResponseTeamInvite = function(self, inviter, teamid, reject)
	return self.Invoke(self, 63741170, SerializerHelper.AskResponseTeamInvite_Serializer, inviter, teamid, reject)
end

SerializerHelper.AskSummonGangMember_Serializer = function(writer, templateid, position, facing)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

ClientToGameDelegate.AskSummonGangMember = function(self, templateid, position, facing)
	return self.Invoke(self, 63745420, SerializerHelper.AskSummonGangMember_Serializer, templateid, position, facing)
end

SerializerHelper.AskTakeSevenDaysProgressReward_Serializer = function(writer, id, progressid)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, progressid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeSevenDaysProgressReward = function(self, id, progressid)
	return self.Invoke(self, 63746472, SerializerHelper.AskTakeSevenDaysProgressReward_Serializer, id, progressid)
end

SerializerHelper.GetGMSDKToken_Serializer = function(writer)
end

ClientToGameDelegate.GetGMSDKToken = function(self)
	return self.Invoke(self, 63746615, SerializerHelper.GetGMSDKToken_Serializer)
end

SerializerHelper.AskInvitePartyDance_Serializer = function(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskInvitePartyDance = function(self, targetid)
	return self.Invoke(self, 63746770, SerializerHelper.AskInvitePartyDance_Serializer, targetid)
end

SerializerHelper.AskCreateAISession_Serializer = function(writer, sessiontype, constdata, mutabledata)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sessiontype, 6, 1), writer.WriteByte, 1)
	writer.WriteString(writer, constdata, false, "AskCreateAISession.constData", RpcLengthLimits.IClientToGame_AskCreateAISession_constData)
	writer.WriteString(writer, mutabledata, false, "AskCreateAISession.mutableData", RpcLengthLimits.IClientToGame_AskCreateAISession_mutableData)
end

ClientToGameDelegate.AskCreateAISession = function(self, sessiontype, constdata, mutabledata)
	return self.Invoke(self, 63746945, SerializerHelper.AskCreateAISession_Serializer, sessiontype, constdata, mutabledata)
end

SerializerHelper.AskResponseTeamLeaderApply_Serializer = function(writer, leaderapplier, reject)
	SerializeBase.WritePrimitive(writer, leaderapplier, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reject, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskResponseTeamLeaderApply = function(self, leaderapplier, reject)
	return self.Invoke(self, 63749191, SerializerHelper.AskResponseTeamLeaderApply_Serializer, leaderapplier, reject)
end

SerializerHelper.AskExtractionShooterShiftItem_Serializer = function(writer, srcbagconfigid, fromcellx, fromcelly, destbagconfigid, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, srcbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, destbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskExtractionShooterShiftItem = function(self, srcbagconfigid, fromcellx, fromcelly, destbagconfigid, tocellx, tocelly, isrotated)
	return self.Invoke(self, 63749738, SerializerHelper.AskExtractionShooterShiftItem_Serializer, srcbagconfigid, fromcellx, fromcelly, destbagconfigid, tocellx, tocelly, isrotated)
end

SerializerHelper.LiveHouseMusicInterrupt_Serializer = function(writer, livehousemusicid, npcid)
	SerializeBase.WritePrimitive(writer, livehousemusicid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.LiveHouseMusicInterrupt = function(self, livehousemusicid, npcid)
	self.Notify(self, 63752208, SerializerHelper.LiveHouseMusicInterrupt_Serializer, livehousemusicid, npcid)
end

SerializerHelper.AskQueryInspireHubAllGamePlayRecommendData_Serializer = function(writer)
end

ClientToGameDelegate.AskQueryInspireHubAllGamePlayRecommendData = function(self)
	return self.Invoke(self, 63752762, SerializerHelper.AskQueryInspireHubAllGamePlayRecommendData_Serializer)
end

SerializerHelper.AskSetTaskCounterValue_Serializer = function(writer, taskid, counterindex, value)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counterindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskSetTaskCounterValue = function(self, taskid, counterindex, value)
	return self.Invoke(self, 63753212, SerializerHelper.AskSetTaskCounterValue_Serializer, taskid, counterindex, value)
end

SerializerHelper.StartMatchVote_Serializer = function(writer, gameid)
	SerializeBase.WritePrimitive(writer, gameid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.StartMatchVote = function(self, gameid)
	return self.Invoke(self, 63753288, SerializerHelper.StartMatchVote_Serializer, gameid)
end

SerializerHelper.AskStartDialog_Serializer = function(writer, dialogid, param, interrupt)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteDialogParameter, "param", false)
	SerializeBase.WritePrimitive(writer, interrupt, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskStartDialog = function(self, dialogid, param, interrupt)
	return self.Invoke(self, 63754798, SerializerHelper.AskStartDialog_Serializer, dialogid, param, interrupt)
end

SerializerHelper.AskPhoneDeleteContactGroup_Serializer = function(writer, spiritid, groupindex)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, groupindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskPhoneDeleteContactGroup = function(self, spiritid, groupindex)
	return self.Invoke(self, 63755356, SerializerHelper.AskPhoneDeleteContactGroup_Serializer, spiritid, groupindex)
end

SerializerHelper.AskObsoleteTruckJobOrder_Serializer = function(writer, orderid)
	SerializeBase.WritePrimitive(writer, orderid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskObsoleteTruckJobOrder = function(self, orderid)
	return self.Invoke(self, 63756681, SerializerHelper.AskObsoleteTruckJobOrder_Serializer, orderid)
end

SerializerHelper.GetUploadObjectUrl_Serializer = function(writer, objectname, publicread, temp)
	writer.WriteString(writer, objectname, false, "GetUploadObjectUrl.objectName", RpcLengthLimits.IClientToGame_GetUploadObjectUrl_objectName)
	SerializeBase.WritePrimitive(writer, publicread, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, temp, writer.WriteBoolean, false)
end

ClientToGameDelegate.GetUploadObjectUrl = function(self, objectname, publicread, temp)
	return self.Invoke(self, 63757076, SerializerHelper.GetUploadObjectUrl_Serializer, objectname, publicread, temp)
end

SerializerHelper.AskApplyJoinClubWithOneKey_Serializer = function(writer, clubids)
	SerializeBase.WriteList7Bit(writer, clubids, writer.WriteUInt64, 0, "clubids", false, RpcLengthLimits.IClientToGame_AskApplyJoinClubWithOneKey_clubIds, nil)
end

ClientToGameDelegate.AskApplyJoinClubWithOneKey = function(self, clubids)
	return self.Invoke(self, 63759432, SerializerHelper.AskApplyJoinClubWithOneKey_Serializer, clubids)
end

SerializerHelper.AskDestoryHouseFurnitureGadgets_Serializer = function(writer, houseid, floor, placedfurnitures)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, floor, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, placedfurnitures, writer.WriteUInt64, 0, "placedfurnitures", false, RpcLengthLimits.IClientToGame_AskDestoryHouseFurnitureGadgets_placedFurnitures, nil)
end

ClientToGameDelegate.AskDestoryHouseFurnitureGadgets = function(self, houseid, floor, placedfurnitures)
	return self.Invoke(self, 63759452, SerializerHelper.AskDestoryHouseFurnitureGadgets_Serializer, houseid, floor, placedfurnitures)
end

SerializerHelper.AskPopularityPhoneFirstOpened_Serializer = function(writer)
end

ClientToGameDelegate.AskPopularityPhoneFirstOpened = function(self)
	return self.Invoke(self, 63759687, SerializerHelper.AskPopularityPhoneFirstOpened_Serializer)
end

SerializerHelper.AskDoGuide_Serializer = function(writer, guideid, counter)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counter, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskDoGuide = function(self, guideid, counter)
	return self.Invoke(self, 63760149, SerializerHelper.AskDoGuide_Serializer, guideid, counter)
end

SerializerHelper.AskLeaveDivinerGame_Serializer = function(writer)
end

ClientToGameDelegate.AskLeaveDivinerGame = function(self)
	return self.Invoke(self, 63762049, SerializerHelper.AskLeaveDivinerGame_Serializer)
end

SerializerHelper.GetShortChatWheel_Serializer = function(writer, multitypeid)
	SerializeBase.WritePrimitive(writer, multitypeid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.GetShortChatWheel = function(self, multitypeid)
	return self.Invoke(self, 63762447, SerializerHelper.GetShortChatWheel_Serializer, multitypeid)
end

SerializerHelper.AskPlayGameNext_Serializer = function(writer)
end

ClientToGameDelegate.AskPlayGameNext = function(self)
	return self.Invoke(self, 63763107, SerializerHelper.AskPlayGameNext_Serializer)
end

SerializerHelper.AskQueryTruckPosInfo_Serializer = function(writer, pickupids, deliveryids)
	SerializeBase.WriteList7Bit(writer, pickupids, writer.WriteUInt32, 0, "pickupids", false, RpcLengthLimits.IClientToGame_AskQueryTruckPosInfo_pickupIds, nil)
	SerializeBase.WriteList7Bit(writer, deliveryids, writer.WriteUInt32, 0, "deliveryids", false, RpcLengthLimits.IClientToGame_AskQueryTruckPosInfo_deliveryIds, nil)
end

ClientToGameDelegate.AskQueryTruckPosInfo = function(self, pickupids, deliveryids)
	return self.Invoke(self, 63763434, SerializerHelper.AskQueryTruckPosInfo_Serializer, pickupids, deliveryids)
end

SerializerHelper.AskSetRacingCompetitionVehicle_Serializer = function(writer, trackid, vehicleid)
	SerializeBase.WritePrimitive(writer, trackid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSetRacingCompetitionVehicle = function(self, trackid, vehicleid)
	return self.Invoke(self, 63764162, SerializerHelper.AskSetRacingCompetitionVehicle_Serializer, trackid, vehicleid)
end

SerializerHelper.AskAddMailToFavorites_Serializer = function(writer, mailid)
	SerializeBase.WritePrimitive(writer, mailid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskAddMailToFavorites = function(self, mailid)
	return self.Invoke(self, 63764470, SerializerHelper.AskAddMailToFavorites_Serializer, mailid)
end

SerializerHelper.SendPartyEvent_Serializer = function(writer, eventid, comment)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteInt32, 0)
	writer.WriteString(writer, comment, true, "SendPartyEvent.comment", RpcLengthLimits.IClientToGame_SendPartyEvent_comment)
end

ClientToGameDelegate.SendPartyEvent = function(self, eventid, comment)
	return self.Invoke(self, 63765017, SerializerHelper.SendPartyEvent_Serializer, eventid, comment)
end

SerializerHelper.AskAcceptPoliceTask_Serializer = function(writer)
end

ClientToGameDelegate.AskAcceptPoliceTask = function(self)
	return self.Invoke(self, 63768375, SerializerHelper.AskAcceptPoliceTask_Serializer)
end

SerializerHelper.AskSetWeaponLock_Serializer = function(writer, weaponinstanceid, islocked)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, islocked, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskSetWeaponLock = function(self, weaponinstanceid, islocked)
	return self.Invoke(self, 63768707, SerializerHelper.AskSetWeaponLock_Serializer, weaponinstanceid, islocked)
end

SerializerHelper.AskLinkPlanningBoardDividendsPutInKeys_Serializer = function(writer, keycountinfodict)
	SerializeBase.WriteDict7Bit(writer, keycountinfodict, writer.WriteUInt32, writer.WriteUInt32, 0, "keycountinfodict", false, RpcLengthLimits.IClientToGame_AskLinkPlanningBoardDividendsPutInKeys_keyCountInfoDict)
end

ClientToGameDelegate.AskLinkPlanningBoardDividendsPutInKeys = function(self, keycountinfodict)
	return self.Invoke(self, 63769120, SerializerHelper.AskLinkPlanningBoardDividendsPutInKeys_Serializer, keycountinfodict)
end

SerializerHelper.AskFinishWpFansPerformance_Serializer = function(writer, nuid)
	SerializeBase.WritePrimitive(writer, nuid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskFinishWpFansPerformance = function(self, nuid)
	self.Notify(self, 63769732, SerializerHelper.AskFinishWpFansPerformance_Serializer, nuid)
end

SerializerHelper.AskFinishQuestionnaire_Serializer = function(writer)
end

ClientToGameDelegate.AskFinishQuestionnaire = function(self)
	return self.Invoke(self, 63770465, SerializerHelper.AskFinishQuestionnaire_Serializer)
end

SerializerHelper.AskReportAICall_Serializer = function(writer, uri, issuccess, ctx)
	writer.WriteString(writer, uri, false, "AskReportAICall.uri", RpcLengthLimits.IClientToGame_AskReportAICall_uri)
	SerializeBase.WritePrimitive(writer, issuccess, writer.WriteBoolean, false)
	SerializeBase.WriteComplex(writer, ctx, SerializeAuto.WriteAICallContext, "ctx", true)
end

ClientToGameDelegate.AskReportAICall = function(self, uri, issuccess, ctx)
	return self.Invoke(self, 63770787, SerializerHelper.AskReportAICall_Serializer, uri, issuccess, ctx)
end

SerializerHelper.AskReportDiceBehavior_Serializer = function(writer, playtime)
	SerializeBase.WritePrimitive(writer, playtime, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskReportDiceBehavior = function(self, playtime)
	return self.Invoke(self, 63771189, SerializerHelper.AskReportDiceBehavior_Serializer, playtime)
end

SerializerHelper.AskBegBehaviorStory_Serializer = function(writer, begstyle, spot, behaviortype)
	SerializeBase.WritePrimitive(writer, begstyle, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spot, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(behaviortype, 32, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskBegBehaviorStory = function(self, begstyle, spot, behaviortype)
	self.Notify(self, 63772146, SerializerHelper.AskBegBehaviorStory_Serializer, begstyle, spot, behaviortype)
end

SerializerHelper.AskTakeCompetitionSeasonOverallRankReward_Serializer = function(writer, rewardid)
	SerializeBase.WritePrimitive(writer, rewardid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeCompetitionSeasonOverallRankReward = function(self, rewardid)
	return self.Invoke(self, 63772368, SerializerHelper.AskTakeCompetitionSeasonOverallRankReward_Serializer, rewardid)
end

SerializerHelper.SurrenderVote_Serializer = function(writer, vote)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(vote, 41, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.SurrenderVote = function(self, vote)
	return self.Invoke(self, 63772651, SerializerHelper.SurrenderVote_Serializer, vote)
end

SerializerHelper.AskActiveGameplayTalentLayer_Serializer = function(writer, gameplayid, talentid, addlayer)
	SerializeBase.WritePrimitive(writer, gameplayid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, talentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addlayer, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskActiveGameplayTalentLayer = function(self, gameplayid, talentid, addlayer)
	return self.Invoke(self, 63772877, SerializerHelper.AskActiveGameplayTalentLayer_Serializer, gameplayid, talentid, addlayer)
end

SerializerHelper.FindCustomRoom_Serializer = function(writer, keyword)
	writer.WriteString(writer, keyword, false, "FindCustomRoom.keyword", RpcLengthLimits.IClientToGame_FindCustomRoom_keyword)
end

ClientToGameDelegate.FindCustomRoom = function(self, keyword)
	return self.Invoke(self, 63774959, SerializerHelper.FindCustomRoom_Serializer, keyword)
end

SerializerHelper.AskSetSpiritWearFashionHiddenParts_Serializer = function(writer, spiritid, hiddenparts)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hiddenparts, writer.WriteByte, 0)
end

ClientToGameDelegate.AskSetSpiritWearFashionHiddenParts = function(self, spiritid, hiddenparts)
	return self.Invoke(self, 63777485, SerializerHelper.AskSetSpiritWearFashionHiddenParts_Serializer, spiritid, hiddenparts)
end

SerializerHelper.StartDarts_Serializer = function(writer, dartid, challengeid, dartmode)
	SerializeBase.WritePrimitive(writer, dartid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, dartmode, writer.WriteUInt32, 0)
end

ClientToGameDelegate.StartDarts = function(self, dartid, challengeid, dartmode)
	return self.Invoke(self, 63777955, SerializerHelper.StartDarts_Serializer, dartid, challengeid, dartmode)
end

SerializerHelper.AskCombineRumors_Serializer = function(writer, wuxueid)
	SerializeBase.WritePrimitive(writer, wuxueid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskCombineRumors = function(self, wuxueid)
	return self.Invoke(self, 63778161, SerializerHelper.AskCombineRumors_Serializer, wuxueid)
end

SerializerHelper.AskPlayerFarmerSow_Serializer = function(writer, sowinfolist)
	SerializeBase.WriteList7Bit(writer, sowinfolist, SerializeBase.WriteStructWrap(SerializeAuto.WriteFarmerSowInfo, "sowinfolist"), nil, "sowinfolist", false, RpcLengthLimits.IClientToGame_AskPlayerFarmerSow_sowInfoList, nil)
end

ClientToGameDelegate.AskPlayerFarmerSow = function(self, sowinfolist)
	self.Notify(self, 63778556, SerializerHelper.AskPlayerFarmerSow_Serializer, sowinfolist)
end

SerializerHelper.AskModifyMeccaGrandpaSlots_Serializer = function(writer, slots)
	SerializeBase.WriteList7Bit(writer, slots, SerializeBase.WriteComplexWrap(SerializeAuto.WriteMeccaGrandpaSlotInfo, "MeccaGrandpaSlotInfo", false), nil, "slots", false, RpcLengthLimits.IClientToGame_AskModifyMeccaGrandpaSlots_slots, nil)
end

ClientToGameDelegate.AskModifyMeccaGrandpaSlots = function(self, slots)
	return self.Invoke(self, 63779680, SerializerHelper.AskModifyMeccaGrandpaSlots_Serializer, slots)
end

SerializerHelper.AskExitWatching_Serializer = function(writer)
end

ClientToGameDelegate.AskExitWatching = function(self)
	return self.Invoke(self, 63779776, SerializerHelper.AskExitWatching_Serializer)
end

SerializerHelper.AskHouseMoveParkingSpace_Serializer = function(writer, moveparkingspaceinfolist)
	SerializeBase.WriteList7Bit(writer, moveparkingspaceinfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteHouseMoveParkingSpaceInfo, "HouseMoveParkingSpaceInfo", false), nil, "moveparkingspaceinfolist", false, RpcLengthLimits.IClientToGame_AskHouseMoveParkingSpace_moveParkingSpaceInfoList, nil)
end

ClientToGameDelegate.AskHouseMoveParkingSpace = function(self, moveparkingspaceinfolist)
	return self.Invoke(self, 63780060, SerializerHelper.AskHouseMoveParkingSpace_Serializer, moveparkingspaceinfolist)
end

SerializerHelper.AskTakeAllLevelsReward_Serializer = function(writer)
end

ClientToGameDelegate.AskTakeAllLevelsReward = function(self)
	return self.Invoke(self, 63780432, SerializerHelper.AskTakeAllLevelsReward_Serializer)
end

SerializerHelper.AskStealNPCFan_Serializer = function(writer)
end

ClientToGameDelegate.AskStealNPCFan = function(self)
	return self.Invoke(self, 63781860, SerializerHelper.AskStealNPCFan_Serializer)
end

SerializerHelper.AskFireworkBuyTicket_Serializer = function(writer, buyinfo)
	SerializeBase.WriteComplex(writer, buyinfo, SerializeAuto.WriteFireworkBuyInfo, "buyinfo", false)
end

ClientToGameDelegate.AskFireworkBuyTicket = function(self, buyinfo)
	return self.Invoke(self, 63783226, SerializerHelper.AskFireworkBuyTicket_Serializer, buyinfo)
end

SerializerHelper.GetMahjongRankReward_Serializer = function(writer, rank)
	SerializeBase.WritePrimitive(writer, rank, writer.WriteUInt32, 0)
end

ClientToGameDelegate.GetMahjongRankReward = function(self, rank)
	return self.Invoke(self, 63783725, SerializerHelper.GetMahjongRankReward_Serializer, rank)
end

SerializerHelper.AskSetTruckJobDefaultVehicleId_Serializer = function(writer, defaultvehicleid)
	SerializeBase.WritePrimitive(writer, defaultvehicleid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSetTruckJobDefaultVehicleId = function(self, defaultvehicleid)
	return self.Invoke(self, 63784367, SerializerHelper.AskSetTruckJobDefaultVehicleId_Serializer, defaultvehicleid)
end

SerializerHelper.AskStageConfirm_Serializer = function(writer, confirminfo)
	SerializeBase.WriteStruct(writer, confirminfo, SerializeAuto.WriteExtraStateConfirmInfo, "confirminfo")
end

ClientToGameDelegate.AskStageConfirm = function(self, confirminfo)
	return self.Invoke(self, 63785301, SerializerHelper.AskStageConfirm_Serializer, confirminfo)
end

SerializerHelper.AskOCModifySpeechName_Serializer = function(writer, speechname, newspeechname)
	writer.WriteString(writer, speechname, false, "AskOCModifySpeechName.speechName", RpcLengthLimits.IClientToGame_AskOCModifySpeechName_speechName)
	writer.WriteString(writer, newspeechname, false, "AskOCModifySpeechName.newSpeechName", RpcLengthLimits.IClientToGame_AskOCModifySpeechName_newSpeechName)
end

ClientToGameDelegate.AskOCModifySpeechName = function(self, speechname, newspeechname)
	return self.Invoke(self, 63785740, SerializerHelper.AskOCModifySpeechName_Serializer, speechname, newspeechname)
end

SerializerHelper.AskLockYacht_Serializer = function(writer)
end

ClientToGameDelegate.AskLockYacht = function(self)
	return self.Invoke(self, 63785999, SerializerHelper.AskLockYacht_Serializer)
end

SerializerHelper.AskSaveSingleHouseConfiguration_Serializer = function(writer, houseid, config)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, config, SerializeAuto.WritePlayerSingleHouseConfiguration, "config", false)
end

ClientToGameDelegate.AskSaveSingleHouseConfiguration = function(self, houseid, config)
	return self.Invoke(self, 63786227, SerializerHelper.AskSaveSingleHouseConfiguration_Serializer, houseid, config)
end

SerializerHelper.AskComputerDeleteFile_Serializer = function(writer, computerid, fileid)
	SerializeBase.WritePrimitive(writer, computerid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fileid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskComputerDeleteFile = function(self, computerid, fileid)
	return self.Invoke(self, 63791026, SerializerHelper.AskComputerDeleteFile_Serializer, computerid, fileid)
end

SerializerHelper.AskOCModifyGrandpa_Serializer = function(writer, generateocinfo)
	SerializeBase.WriteComplex(writer, generateocinfo, SerializeAuto.WriteOCGenerateInfo, "generateocinfo", false)
end

ClientToGameDelegate.AskOCModifyGrandpa = function(self, generateocinfo)
	return self.Invoke(self, 63794787, SerializerHelper.AskOCModifyGrandpa_Serializer, generateocinfo)
end

SerializerHelper.AskMultiverseStatus_Serializer = function(writer)
end

ClientToGameDelegate.AskMultiverseStatus = function(self)
	return self.Invoke(self, 63799383, SerializerHelper.AskMultiverseStatus_Serializer)
end

SerializerHelper.ChatWithNpc_Serializer = function(writer, npcinstanceid)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.ChatWithNpc = function(self, npcinstanceid)
	return self.Invoke(self, 63799412, SerializerHelper.ChatWithNpc_Serializer, npcinstanceid)
end

SerializerHelper.AskTuiteTakeReward_Serializer = function(writer, tuiteid)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTuiteTakeReward = function(self, tuiteid)
	return self.Invoke(self, 63801315, SerializerHelper.AskTuiteTakeReward_Serializer, tuiteid)
end

SerializerHelper.AskRPSInterrogationSelectOption_Serializer = function(writer, caseid, card)
	SerializeBase.WritePrimitive(writer, caseid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, card, SerializeAuto.WritePoliceRPSCardInfo, "card")
end

ClientToGameDelegate.AskRPSInterrogationSelectOption = function(self, caseid, card)
	return self.Invoke(self, 63801940, SerializerHelper.AskRPSInterrogationSelectOption_Serializer, caseid, card)
end

SerializerHelper.AskReportEnvSdkBlockedLog_Serializer = function(writer, description)
	writer.WriteString(writer, description, false, "AskReportEnvSdkBlockedLog.description", RpcLengthLimits.IClientToGame_AskReportEnvSdkBlockedLog_description)
end

ClientToGameDelegate.AskReportEnvSdkBlockedLog = function(self, description)
	return self.Invoke(self, 63802311, SerializerHelper.AskReportEnvSdkBlockedLog_Serializer, description)
end

SerializerHelper.ReportWordReviewFailed_Serializer = function(writer, content, code, message)
	writer.WriteString(writer, content, false, "ReportWordReviewFailed.content", RpcLengthLimits.IClientToGame_ReportWordReviewFailed_content)
	SerializeBase.WritePrimitive(writer, code, writer.WriteInt32, 0)
	writer.WriteString(writer, message, false, "ReportWordReviewFailed.message", RpcLengthLimits.IClientToGame_ReportWordReviewFailed_message)
end

ClientToGameDelegate.ReportWordReviewFailed = function(self, content, code, message)
	self.Notify(self, 63804570, SerializerHelper.ReportWordReviewFailed_Serializer, content, code, message)
end

SerializerHelper.AskUploadConfig_Serializer = function(writer, config)
	SerializeBase.WriteList7Bit(writer, config, writer.WriteByte, 0, "config", false, RpcLengthLimits.IClientToGame_AskUploadConfig_config, nil)
end

ClientToGameDelegate.AskUploadConfig = function(self, config)
	self.Notify(self, 63808071, SerializerHelper.AskUploadConfig_Serializer, config)
end

SerializerHelper.AskLoadWeaponToSlot_Serializer = function(writer, spiritid, weaponid, slotindex)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, slotindex, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskLoadWeaponToSlot = function(self, spiritid, weaponid, slotindex)
	return self.Invoke(self, 63808768, SerializerHelper.AskLoadWeaponToSlot_Serializer, spiritid, weaponid, slotindex)
end

SerializerHelper.AskFarmerShopPlaceItem_Serializer = function(writer, shelfindex, itemid, quality, tags, count, price)
	SerializeBase.WritePrimitive(writer, shelfindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, itemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, quality, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, tags, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, price, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFarmerShopPlaceItem = function(self, shelfindex, itemid, quality, tags, count, price)
	return self.Invoke(self, 63811643, SerializerHelper.AskFarmerShopPlaceItem_Serializer, shelfindex, itemid, quality, tags, count, price)
end

SerializerHelper.AskChangeTaskCounterValue_Serializer = function(writer, taskid, counterindex, value)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counterindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskChangeTaskCounterValue = function(self, taskid, counterindex, value)
	return self.Invoke(self, 63812897, SerializerHelper.AskChangeTaskCounterValue_Serializer, taskid, counterindex, value)
end

SerializerHelper.AskTourHouse_Serializer = function(writer, ownerpid)
	SerializeBase.WritePrimitive(writer, ownerpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskTourHouse = function(self, ownerpid)
	return self.Invoke(self, 63815298, SerializerHelper.AskTourHouse_Serializer, ownerpid)
end

SerializerHelper.SendPartyComment_Serializer = function(writer, comment)
	writer.WriteString(writer, comment, false, "SendPartyComment.comment", RpcLengthLimits.IClientToGame_SendPartyComment_comment)
end

ClientToGameDelegate.SendPartyComment = function(self, comment)
	return self.Invoke(self, 63815361, SerializerHelper.SendPartyComment_Serializer, comment)
end

SerializerHelper.AskVehicleSendGamePlaySignal_Serializer = function(writer, signal)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(signal, 42, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskVehicleSendGamePlaySignal = function(self, signal)
	return self.Invoke(self, 63816400, SerializerHelper.AskVehicleSendGamePlaySignal_Serializer, signal)
end

SerializerHelper.AskReadCityPedia_Serializer = function(writer, citypediaid)
	SerializeBase.WritePrimitive(writer, citypediaid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskReadCityPedia = function(self, citypediaid)
	return self.Invoke(self, 63817604, SerializerHelper.AskReadCityPedia_Serializer, citypediaid)
end

SerializerHelper.AskPreSettleTruckOrder_Serializer = function(writer, uniqueid, cargosettlelist)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, cargosettlelist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteTruckCargoSettleInfo, "TruckCargoSettleInfo", false), nil, "cargosettlelist", false, RpcLengthLimits.IClientToGame_AskPreSettleTruckOrder_cargoSettleList, nil)
end

ClientToGameDelegate.AskPreSettleTruckOrder = function(self, uniqueid, cargosettlelist)
	return self.Invoke(self, 63818375, SerializerHelper.AskPreSettleTruckOrder_Serializer, uniqueid, cargosettlelist)
end

SerializerHelper.SendMobileUnbind_Serializer = function(writer, phonenum)
	writer.WriteString(writer, phonenum, false, "SendMobileUnbind.phoneNum", RpcLengthLimits.IClientToGame_SendMobileUnbind_phoneNum)
end

ClientToGameDelegate.SendMobileUnbind = function(self, phonenum)
	return self.Invoke(self, 63819309, SerializerHelper.SendMobileUnbind_Serializer, phonenum)
end

SerializerHelper.AskBringOutItem_Serializer = function(writer, bagconfigid, cellx, celly)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBringOutItem = function(self, bagconfigid, cellx, celly)
	return self.Invoke(self, 63820988, SerializerHelper.AskBringOutItem_Serializer, bagconfigid, cellx, celly)
end

SerializerHelper.AskSelectChatBubble_Serializer = function(writer, bubbleid)
	SerializeBase.WritePrimitive(writer, bubbleid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSelectChatBubble = function(self, bubbleid)
	return self.Invoke(self, 63821496, SerializerHelper.AskSelectChatBubble_Serializer, bubbleid)
end

SerializerHelper.CancelTuoGuan_Serializer = function(writer, type)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

ClientToGameDelegate.CancelTuoGuan = function(self, type)
	return self.Invoke(self, 63824909, SerializerHelper.CancelTuoGuan_Serializer, type)
end

SerializerHelper.AskNewChallengeRecordList_Serializer = function(writer, challengeids)
	SerializeBase.WriteList7Bit(writer, challengeids, writer.WriteUInt32, 0, "challengeids", false, RpcLengthLimits.IClientToGame_AskNewChallengeRecordList_challengeIds, nil)
end

ClientToGameDelegate.AskNewChallengeRecordList = function(self, challengeids)
	return self.Invoke(self, 63830456, SerializerHelper.AskNewChallengeRecordList_Serializer, challengeids)
end

SerializerHelper.AskQueryInspireHubAllGamePlayRankData_Serializer = function(writer)
end

ClientToGameDelegate.AskQueryInspireHubAllGamePlayRankData = function(self)
	return self.Invoke(self, 63830673, SerializerHelper.AskQueryInspireHubAllGamePlayRankData_Serializer)
end

SerializerHelper.AskPlayerFarmerReclaimLand_Serializer = function(writer, landidlist)
	SerializeBase.WriteList7Bit(writer, landidlist, writer.WriteInt32, 0, "landidlist", false, RpcLengthLimits.IClientToGame_AskPlayerFarmerReclaimLand_landIdList, nil)
end

ClientToGameDelegate.AskPlayerFarmerReclaimLand = function(self, landidlist)
	self.Notify(self, 63831533, SerializerHelper.AskPlayerFarmerReclaimLand_Serializer, landidlist)
end

SerializerHelper.AskRacingCompetitionGroupInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskRacingCompetitionGroupInfo = function(self)
	return self.Invoke(self, 63832346, SerializerHelper.AskRacingCompetitionGroupInfo_Serializer)
end

SerializerHelper.ChangeUgcMapPlayerCount_Serializer = function(writer, mapid, minplayercount, maxplayercount)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, minplayercount, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maxplayercount, writer.WriteUInt32, 0)
end

ClientToGameDelegate.ChangeUgcMapPlayerCount = function(self, mapid, minplayercount, maxplayercount)
	return self.Invoke(self, 63833154, SerializerHelper.ChangeUgcMapPlayerCount_Serializer, mapid, minplayercount, maxplayercount)
end

SerializerHelper.AskActivityCancelRedPoint_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskActivityCancelRedPoint = function(self, id)
	return self.Invoke(self, 63833513, SerializerHelper.AskActivityCancelRedPoint_Serializer, id)
end

SerializerHelper.AskPauseCardFlipGame_Serializer = function(writer)
end

ClientToGameDelegate.AskPauseCardFlipGame = function(self)
	return self.Invoke(self, 63833778, SerializerHelper.AskPauseCardFlipGame_Serializer)
end

SerializerHelper.DonateFactionByCfgId_Serializer = function(writer, factionid, donateid)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, donateid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.DonateFactionByCfgId = function(self, factionid, donateid)
	return self.Invoke(self, 63833888, SerializerHelper.DonateFactionByCfgId_Serializer, factionid, donateid)
end

SerializerHelper.AskRankingTopBatch_Serializer = function(writer, rankconfigids, options)
	SerializeBase.WriteList7Bit(writer, rankconfigids, writer.WriteUInt32, 0, "rankconfigids", false, RpcLengthLimits.IClientToGame_AskRankingTopBatch_rankConfigIds, nil)
	SerializeBase.WriteComplex(writer, options, SerializeAuto.WriteRankQueryOptions, "options", true)
end

ClientToGameDelegate.AskRankingTopBatch = function(self, rankconfigids, options)
	return self.Invoke(self, 63836627, SerializerHelper.AskRankingTopBatch_Serializer, rankconfigids, options)
end

SerializerHelper.AskTakePopularityFanBoxReward_Serializer = function(writer)
end

ClientToGameDelegate.AskTakePopularityFanBoxReward = function(self)
	return self.Invoke(self, 63838944, SerializerHelper.AskTakePopularityFanBoxReward_Serializer)
end

SerializerHelper.CreateUgcMapInfo_Serializer = function(writer, mapname, minplayercnt, maxplayercnt, definitioninfo)
	writer.WriteString(writer, mapname, false, "CreateUgcMapInfo.mapName", RpcLengthLimits.IClientToGame_CreateUgcMapInfo_mapName)
	SerializeBase.WritePrimitive(writer, minplayercnt, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maxplayercnt, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, definitioninfo, SerializeAuto.WriteUgcMapDefinitionInfo, "definitioninfo", false)
end

ClientToGameDelegate.CreateUgcMapInfo = function(self, mapname, minplayercnt, maxplayercnt, definitioninfo)
	return self.Invoke(self, 63841314, SerializerHelper.CreateUgcMapInfo_Serializer, mapname, minplayercnt, maxplayercnt, definitioninfo)
end

SerializerHelper.RequestPlayerStartHangup_Serializer = function(writer)
end

ClientToGameDelegate.RequestPlayerStartHangup = function(self)
	return self.Invoke(self, 63842476, SerializerHelper.RequestPlayerStartHangup_Serializer)
end

SerializerHelper.AskNpcShareTimeInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskNpcShareTimeInfo = function(self)
	return self.Invoke(self, 63844509, SerializerHelper.AskNpcShareTimeInfo_Serializer)
end

SerializerHelper.AskQueryLiveHouseInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskQueryLiveHouseInfo = function(self)
	return self.Invoke(self, 63848409, SerializerHelper.AskQueryLiveHouseInfo_Serializer)
end

SerializerHelper.AskEnterDivinerGame_Serializer = function(writer)
end

ClientToGameDelegate.AskEnterDivinerGame = function(self)
	return self.Invoke(self, 63848568, SerializerHelper.AskEnterDivinerGame_Serializer)
end

SerializerHelper.AskPoliceEffectiveExam_Serializer = function(writer)
end

ClientToGameDelegate.AskPoliceEffectiveExam = function(self)
	return self.Invoke(self, 63851241, SerializerHelper.AskPoliceEffectiveExam_Serializer)
end

SerializerHelper.AskChangeClubDeclaration_Serializer = function(writer, clubid, declaration)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	writer.WriteString(writer, declaration, false, "AskChangeClubDeclaration.declaration", RpcLengthLimits.IClientToGame_AskChangeClubDeclaration_declaration)
end

ClientToGameDelegate.AskChangeClubDeclaration = function(self, clubid, declaration)
	return self.Invoke(self, 63851449, SerializerHelper.AskChangeClubDeclaration_Serializer, clubid, declaration)
end

SerializerHelper.AskTuiteUpdateTimelineInfo_Serializer = function(writer, tuiteid, data)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
	writer.WriteString(writer, data, false, "AskTuiteUpdateTimelineInfo.data", RpcLengthLimits.IClientToGame_AskTuiteUpdateTimelineInfo_data)
end

ClientToGameDelegate.AskTuiteUpdateTimelineInfo = function(self, tuiteid, data)
	return self.Invoke(self, 63851715, SerializerHelper.AskTuiteUpdateTimelineInfo_Serializer, tuiteid, data)
end

SerializerHelper.CompleteSubQuest_Serializer = function(writer, subquestid)
	SerializeBase.WritePrimitive(writer, subquestid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.CompleteSubQuest = function(self, subquestid)
	return self.Invoke(self, 63852854, SerializerHelper.CompleteSubQuest_Serializer, subquestid)
end

SerializerHelper.AskEnableInvitedNotDisturb_Serializer = function(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskEnableInvitedNotDisturb = function(self, enable)
	return self.Invoke(self, 63855612, SerializerHelper.AskEnableInvitedNotDisturb_Serializer, enable)
end

SerializerHelper.VerifyMobileBindSMSCode_Serializer = function(writer, phonenum, code)
	writer.WriteString(writer, phonenum, false, "VerifyMobileBindSMSCode.phoneNum", RpcLengthLimits.IClientToGame_VerifyMobileBindSMSCode_phoneNum)
	writer.WriteString(writer, code, false, "VerifyMobileBindSMSCode.code", RpcLengthLimits.IClientToGame_VerifyMobileBindSMSCode_code)
end

ClientToGameDelegate.VerifyMobileBindSMSCode = function(self, phonenum, code)
	return self.Invoke(self, 63856149, SerializerHelper.VerifyMobileBindSMSCode_Serializer, phonenum, code)
end

SerializerHelper.AskItemUpgradeCompoundLevel_Serializer = function(writer, stationid, materials)
	SerializeBase.WritePrimitive(writer, stationid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, materials, SerializeAuto.WriteSubmitItemInfo, "materials", true)
end

ClientToGameDelegate.AskItemUpgradeCompoundLevel = function(self, stationid, materials)
	return self.Invoke(self, 63856306, SerializerHelper.AskItemUpgradeCompoundLevel_Serializer, stationid, materials)
end

SerializerHelper.AskFlipCardFlipPair_Serializer = function(writer, cardpos1, cardpos2)
	SerializeBase.WritePrimitive(writer, cardpos1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cardpos2, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFlipCardFlipPair = function(self, cardpos1, cardpos2)
	return self.Invoke(self, 63857117, SerializerHelper.AskFlipCardFlipPair_Serializer, cardpos1, cardpos2)
end

SerializerHelper.AskChangePrepareSetting_Serializer = function(writer, prepareinfo)
	SerializeBase.WriteComplex(writer, prepareinfo, SerializeAuto.WriteMatchPrepareInfo, "prepareinfo", false)
end

ClientToGameDelegate.AskChangePrepareSetting = function(self, prepareinfo)
	return self.Invoke(self, 63857161, SerializerHelper.AskChangePrepareSetting_Serializer, prepareinfo)
end

SerializerHelper.AskPlayerFarmerReap_Serializer = function(writer, landidlist)
	SerializeBase.WriteList7Bit(writer, landidlist, writer.WriteInt32, 0, "landidlist", false, RpcLengthLimits.IClientToGame_AskPlayerFarmerReap_landIdList, nil)
end

ClientToGameDelegate.AskPlayerFarmerReap = function(self, landidlist)
	self.Notify(self, 63857394, SerializerHelper.AskPlayerFarmerReap_Serializer, landidlist)
end

SerializerHelper.AskSelectPlanningBoardGameplayAttributeId_Serializer = function(writer, gameplayattributeid)
	SerializeBase.WritePrimitive(writer, gameplayattributeid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSelectPlanningBoardGameplayAttributeId = function(self, gameplayattributeid)
	return self.Invoke(self, 63857408, SerializerHelper.AskSelectPlanningBoardGameplayAttributeId_Serializer, gameplayattributeid)
end

SerializerHelper.GetPersonalInfo_Serializer = function(writer)
end

ClientToGameDelegate.GetPersonalInfo = function(self)
	return self.Invoke(self, 63859029, SerializerHelper.GetPersonalInfo_Serializer)
end

SerializerHelper.ChangeUgcMapComponentInfo_Serializer = function(writer, mapid, pointinfo)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, pointinfo, SerializeAuto.WriteUgcComponentPointInfo, "pointinfo", false)
end

ClientToGameDelegate.ChangeUgcMapComponentInfo = function(self, mapid, pointinfo)
	return self.Invoke(self, 63860050, SerializerHelper.ChangeUgcMapComponentInfo_Serializer, mapid, pointinfo)
end

SerializerHelper.SyncTrackGPS_Serializer = function(writer, gps)
	SerializeBase.WriteComplex(writer, gps, SerializeAuto.WriteTeamTrackGPS, "gps", true)
end

ClientToGameDelegate.SyncTrackGPS = function(self, gps)
	self.Notify(self, 63861463, SerializerHelper.SyncTrackGPS_Serializer, gps)
end

SerializerHelper.AskComputerDeleteEmail_Serializer = function(writer, computerid, emailid)
	SerializeBase.WritePrimitive(writer, computerid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, emailid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskComputerDeleteEmail = function(self, computerid, emailid)
	return self.Invoke(self, 63864964, SerializerHelper.AskComputerDeleteEmail_Serializer, computerid, emailid)
end

SerializerHelper.AskBartenderGameSettlement_Serializer = function(writer, bartenderid, customerid, drinkmenuid, drinkqualityscore, guestsatisfactionbonus)
	SerializeBase.WritePrimitive(writer, bartenderid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, customerid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, drinkmenuid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, drinkqualityscore, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, guestsatisfactionbonus, writer.WriteSingle, 0)
end

ClientToGameDelegate.AskBartenderGameSettlement = function(self, bartenderid, customerid, drinkmenuid, drinkqualityscore, guestsatisfactionbonus)
	return self.Invoke(self, 63867924, SerializerHelper.AskBartenderGameSettlement_Serializer, bartenderid, customerid, drinkmenuid, drinkqualityscore, guestsatisfactionbonus)
end

SerializerHelper.AskAbortDialog_Serializer = function(writer, abortdialog)
	SerializeBase.WriteStruct(writer, abortdialog, SerializeAuto.WriteAbortDialogInfo, "abortdialog")
end

ClientToGameDelegate.AskAbortDialog = function(self, abortdialog)
	self.Notify(self, 63868591, SerializerHelper.AskAbortDialog_Serializer, abortdialog)
end

SerializerHelper.AskResponsePartyDanceInvite_Serializer = function(writer, inviterpid, accepted)
	SerializeBase.WritePrimitive(writer, inviterpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accepted, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskResponsePartyDanceInvite = function(self, inviterpid, accepted)
	return self.Invoke(self, 63868636, SerializerHelper.AskResponsePartyDanceInvite_Serializer, inviterpid, accepted)
end

SerializerHelper.RpcCollectionBookDyeColor_Serializer = function(writer, bagid, cellx, celly)
	SerializeBase.WritePrimitive(writer, bagid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
end

ClientToGameDelegate.RpcCollectionBookDyeColor = function(self, bagid, cellx, celly)
	return self.Invoke(self, 63869587, SerializerHelper.RpcCollectionBookDyeColor_Serializer, bagid, cellx, celly)
end

SerializerHelper.AddPersonalTimeSetting_Serializer = function(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WritePersonalTimeSetting, "info", false)
end

ClientToGameDelegate.AddPersonalTimeSetting = function(self, info)
	return self.Invoke(self, 63871297, SerializerHelper.AddPersonalTimeSetting_Serializer, info)
end

SerializerHelper.AskSettleTruckOrder_Serializer = function(writer, uniqueid)
	SerializeBase.WritePrimitive(writer, uniqueid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSettleTruckOrder = function(self, uniqueid)
	return self.Invoke(self, 63873513, SerializerHelper.AskSettleTruckOrder_Serializer, uniqueid)
end

SerializerHelper.AskDeleteHousePromoImage_Serializer = function(writer, houseid)
	SerializeBase.WritePrimitive(writer, houseid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskDeleteHousePromoImage = function(self, houseid)
	return self.Invoke(self, 63873531, SerializerHelper.AskDeleteHousePromoImage_Serializer, houseid)
end

SerializerHelper.AskClearPersonalZoneNewFans_Serializer = function(writer)
end

ClientToGameDelegate.AskClearPersonalZoneNewFans = function(self)
	return self.Invoke(self, 63873822, SerializerHelper.AskClearPersonalZoneNewFans_Serializer)
end

SerializerHelper.AskAcceptOnlineSeasonTask_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskAcceptOnlineSeasonTask = function(self, taskid)
	return self.Invoke(self, 63874601, SerializerHelper.AskAcceptOnlineSeasonTask_Serializer, taskid)
end

SerializerHelper.AskReportArcadeGameResult_Serializer = function(writer, gameresult)
	SerializeBase.WriteComplex(writer, gameresult, SerializeAuto.WriteArcadeGameResult, "gameresult", false)
end

ClientToGameDelegate.AskReportArcadeGameResult = function(self, gameresult)
	return self.Invoke(self, 63878179, SerializerHelper.AskReportArcadeGameResult_Serializer, gameresult)
end

SerializerHelper.AskQueryBasicClubInfo_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskQueryBasicClubInfo = function(self, pid)
	return self.Invoke(self, 63878911, SerializerHelper.AskQueryBasicClubInfo_Serializer, pid)
end

SerializerHelper.AskMomentsPostInfos_Serializer = function(writer, postids)
	SerializeBase.WriteList7Bit(writer, postids, writer.WriteUInt32, 0, "postids", false, RpcLengthLimits.IClientToGame_AskMomentsPostInfos_postIds, nil)
end

ClientToGameDelegate.AskMomentsPostInfos = function(self, postids)
	return self.Invoke(self, 63879443, SerializerHelper.AskMomentsPostInfos_Serializer, postids)
end

SerializerHelper.AskReadyPartyDanceFloor_Serializer = function(writer, ready)
	SerializeBase.WritePrimitive(writer, ready, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskReadyPartyDanceFloor = function(self, ready)
	return self.Invoke(self, 63880666, SerializerHelper.AskReadyPartyDanceFloor_Serializer, ready)
end

SerializerHelper.AskUpdatePlayerNameEffect_Serializer = function(writer, nameeffectid)
	SerializeBase.WritePrimitive(writer, nameeffectid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUpdatePlayerNameEffect = function(self, nameeffectid)
	return self.Invoke(self, 63880835, SerializerHelper.AskUpdatePlayerNameEffect_Serializer, nameeffectid)
end

SerializerHelper.CancelMatch_Serializer = function(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.CancelMatch = function(self, roomid)
	return self.Invoke(self, 63881071, SerializerHelper.CancelMatch_Serializer, roomid)
end

SerializerHelper.AskTradeGetOrderList_Serializer = function(writer, tradeitemid, direction)
	SerializeBase.WritePrimitive(writer, tradeitemid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(direction, 33, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskTradeGetOrderList = function(self, tradeitemid, direction)
	return self.Invoke(self, 63882492, SerializerHelper.AskTradeGetOrderList_Serializer, tradeitemid, direction)
end

SerializerHelper.ChangeUgcMapName_Serializer = function(writer, mapid, mapname)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
	writer.WriteString(writer, mapname, false, "ChangeUgcMapName.mapName", RpcLengthLimits.IClientToGame_ChangeUgcMapName_mapName)
end

ClientToGameDelegate.ChangeUgcMapName = function(self, mapid, mapname)
	return self.Invoke(self, 63884661, SerializerHelper.ChangeUgcMapName_Serializer, mapid, mapname)
end

SerializerHelper.AskLiveHouseMusicList_Serializer = function(writer)
end

ClientToGameDelegate.AskLiveHouseMusicList = function(self)
	return self.Invoke(self, 63885626, SerializerHelper.AskLiveHouseMusicList_Serializer)
end

SerializerHelper.AskPersonalZoneUpdateSpiritList_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteComplexWrap(SerializeAuto.WritePersonalZoneFightSpiritInfo, "PersonalZoneFightSpiritInfo", false), nil, "infos", false, RpcLengthLimits.IClientToGame_AskPersonalZoneUpdateSpiritList_infos, nil)
end

ClientToGameDelegate.AskPersonalZoneUpdateSpiritList = function(self, infos)
	return self.Invoke(self, 63886807, SerializerHelper.AskPersonalZoneUpdateSpiritList_Serializer, infos)
end

SerializerHelper.AskMailFavorites_Serializer = function(writer)
end

ClientToGameDelegate.AskMailFavorites = function(self)
	return self.Invoke(self, 63888436, SerializerHelper.AskMailFavorites_Serializer)
end

SerializerHelper.AskPlayerFarmerClearLand_Serializer = function(writer, landidlist)
	SerializeBase.WriteList7Bit(writer, landidlist, writer.WriteInt32, 0, "landidlist", false, RpcLengthLimits.IClientToGame_AskPlayerFarmerClearLand_landIdList, nil)
end

ClientToGameDelegate.AskPlayerFarmerClearLand = function(self, landidlist)
	self.Notify(self, 63889695, SerializerHelper.AskPlayerFarmerClearLand_Serializer, landidlist)
end

SerializerHelper.AskFinishWasherMission_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFinishWasherMission = function(self, eventid)
	return self.Invoke(self, 63889979, SerializerHelper.AskFinishWasherMission_Serializer, eventid)
end

SerializerHelper.AskBuyFerrisWheelTicket_Serializer = function(writer, tickettype, ferriswheelid)
	SerializeBase.WritePrimitive(writer, tickettype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, ferriswheelid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBuyFerrisWheelTicket = function(self, tickettype, ferriswheelid)
	return self.Invoke(self, 63891470, SerializerHelper.AskBuyFerrisWheelTicket_Serializer, tickettype, ferriswheelid)
end

SerializerHelper.AskChangeMapPin_Serializer = function(writer, pin, type)
	SerializeBase.WritePrimitive(writer, pin, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

ClientToGameDelegate.AskChangeMapPin = function(self, pin, type)
	return self.Invoke(self, 63891832, SerializerHelper.AskChangeMapPin_Serializer, pin, type)
end

SerializerHelper.AskRemoveMapPin_Serializer = function(writer, pin)
	SerializeBase.WritePrimitive(writer, pin, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskRemoveMapPin = function(self, pin)
	return self.Invoke(self, 63892650, SerializerHelper.AskRemoveMapPin_Serializer, pin)
end

SerializerHelper.AskMomentsLikePost_Serializer = function(writer, postid, like)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, like, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskMomentsLikePost = function(self, postid, like)
	return self.Invoke(self, 63895686, SerializerHelper.AskMomentsLikePost_Serializer, postid, like)
end

SerializerHelper.KTVMusicInterrupt_Serializer = function(writer, musicid)
	SerializeBase.WritePrimitive(writer, musicid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.KTVMusicInterrupt = function(self, musicid)
	self.Notify(self, 63896310, SerializerHelper.KTVMusicInterrupt_Serializer, musicid)
end

SerializerHelper.AskUpdatePersonalZoneAchieveList_Serializer = function(writer, achievements, countryid)
	SerializeBase.WriteList7Bit(writer, achievements, SerializeBase.WriteComplexWrap(SerializeAuto.WritePersonalZoneAchievement, "PersonalZoneAchievement", false), nil, "achievements", false, RpcLengthLimits.IClientToGame_AskUpdatePersonalZoneAchieveList_achievements, nil)
	SerializeBase.WritePrimitive(writer, countryid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUpdatePersonalZoneAchieveList = function(self, achievements, countryid)
	return self.Invoke(self, 63898603, SerializerHelper.AskUpdatePersonalZoneAchieveList_Serializer, achievements, countryid)
end

SerializerHelper.AskTakeNpcProfileProgressRewardWithWeb_Serializer = function(writer, index, webid)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, webid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeNpcProfileProgressRewardWithWeb = function(self, index, webid)
	return self.Invoke(self, 63898756, SerializerHelper.AskTakeNpcProfileProgressRewardWithWeb_Serializer, index, webid)
end

SerializerHelper.AskPhoneAddContact_Serializer = function(writer, spiritid, phonenumber, contactname)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	writer.WriteString(writer, phonenumber, false, "AskPhoneAddContact.phoneNumber", RpcLengthLimits.IClientToGame_AskPhoneAddContact_phoneNumber)
	writer.WriteString(writer, contactname, false, "AskPhoneAddContact.contactName", RpcLengthLimits.IClientToGame_AskPhoneAddContact_contactName)
end

ClientToGameDelegate.AskPhoneAddContact = function(self, spiritid, phonenumber, contactname)
	return self.Invoke(self, 63899065, SerializerHelper.AskPhoneAddContact_Serializer, spiritid, phonenumber, contactname)
end

SerializerHelper.AskSetWeaponSkins_Serializer = function(writer, spiritids, sceneitemids, skinid)
	SerializeBase.WriteList7Bit(writer, spiritids, writer.WriteUInt32, 0, "spiritids", false, RpcLengthLimits.IClientToGame_AskSetWeaponSkins_spiritIds, nil)
	SerializeBase.WriteList7Bit(writer, sceneitemids, writer.WriteUInt32, 0, "sceneitemids", false, RpcLengthLimits.IClientToGame_AskSetWeaponSkins_sceneItemIds, nil)
	SerializeBase.WritePrimitive(writer, skinid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSetWeaponSkins = function(self, spiritids, sceneitemids, skinid)
	return self.Invoke(self, 63900850, SerializerHelper.AskSetWeaponSkins_Serializer, spiritids, sceneitemids, skinid)
end

SerializerHelper.AskConvertCommonSpiritTalentExp_Serializer = function(writer, spiritid, convertexp)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, convertexp, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskConvertCommonSpiritTalentExp = function(self, spiritid, convertexp)
	return self.Invoke(self, 63901381, SerializerHelper.AskConvertCommonSpiritTalentExp_Serializer, spiritid, convertexp)
end

SerializerHelper.AskPlayWithAnimal_Serializer = function(writer, animalid, favor)
	SerializeBase.WritePrimitive(writer, animalid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, favor, writer.WriteInt32, 0)
end

ClientToGameDelegate.AskPlayWithAnimal = function(self, animalid, favor)
	return self.Invoke(self, 63906432, SerializerHelper.AskPlayWithAnimal_Serializer, animalid, favor)
end

SerializerHelper.AskHotSpringSettlement_Serializer = function(writer)
end

ClientToGameDelegate.AskHotSpringSettlement = function(self)
	return self.Invoke(self, 63907688, SerializerHelper.AskHotSpringSettlement_Serializer)
end

SerializerHelper.AskMallRemoveFromCart_Serializer = function(writer, commodityidlist)
	SerializeBase.WriteList7Bit(writer, commodityidlist, writer.WriteUInt32, 0, "commodityidlist", false, RpcLengthLimits.IClientToGame_AskMallRemoveFromCart_commodityIdList, nil)
end

ClientToGameDelegate.AskMallRemoveFromCart = function(self, commodityidlist)
	return self.Invoke(self, 63908318, SerializerHelper.AskMallRemoveFromCart_Serializer, commodityidlist)
end

SerializerHelper.Gang_Serializer = function(writer, pai)
	SerializeBase.WriteStruct(writer, pai, SerializeAuto.WriteMjPaiInfo, "pai")
end

ClientToGameDelegate.Gang = function(self, pai)
	return self.Invoke(self, 63908461, SerializerHelper.Gang_Serializer, pai)
end

SerializerHelper.RequestPlayerStopHangup_Serializer = function(writer)
end

ClientToGameDelegate.RequestPlayerStopHangup = function(self)
	return self.Invoke(self, 63910160, SerializerHelper.RequestPlayerStopHangup_Serializer)
end

SerializerHelper.AskAgentEnterOrLeaveDoor_Serializer = function(writer, gadgetid, agentid, isenter)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isenter, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskAgentEnterOrLeaveDoor = function(self, gadgetid, agentid, isenter)
	self.Notify(self, 63910357, SerializerHelper.AskAgentEnterOrLeaveDoor_Serializer, gadgetid, agentid, isenter)
end

SerializerHelper.AskMahjongWorldBattleStart_Serializer = function(writer, gadgetid)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskMahjongWorldBattleStart = function(self, gadgetid)
	return self.Invoke(self, 63910913, SerializerHelper.AskMahjongWorldBattleStart_Serializer, gadgetid)
end

SerializerHelper.AskStartGuideByClient_Serializer = function(writer, guideid, taskid)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskStartGuideByClient = function(self, guideid, taskid)
	return self.Invoke(self, 63911933, SerializerHelper.AskStartGuideByClient_Serializer, guideid, taskid)
end

SerializerHelper.AskDivinerTriggerResult_Serializer = function(writer)
end

ClientToGameDelegate.AskDivinerTriggerResult = function(self)
	self.Notify(self, 63912365, SerializerHelper.AskDivinerTriggerResult_Serializer)
end

SerializerHelper.AskComputerOpened_Serializer = function(writer, computerid)
	SerializeBase.WritePrimitive(writer, computerid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskComputerOpened = function(self, computerid)
	return self.Invoke(self, 63913019, SerializerHelper.AskComputerOpened_Serializer, computerid)
end

SerializerHelper.AskStopMatch_Serializer = function(writer)
end

ClientToGameDelegate.AskStopMatch = function(self)
	return self.Invoke(self, 63913055, SerializerHelper.AskStopMatch_Serializer)
end

SerializerHelper.StopUgcMapEditingComponentInfo_Serializer = function(writer, mapid)
	SerializeBase.WritePrimitive(writer, mapid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.StopUgcMapEditingComponentInfo = function(self, mapid)
	return self.Invoke(self, 63913684, SerializerHelper.StopUgcMapEditingComponentInfo_Serializer, mapid)
end

SerializerHelper.AskAutoAcceptTruckJobOrder_Serializer = function(writer, bautoaccept)
	SerializeBase.WritePrimitive(writer, bautoaccept, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskAutoAcceptTruckJobOrder = function(self, bautoaccept)
	return self.Invoke(self, 63913941, SerializerHelper.AskAutoAcceptTruckJobOrder_Serializer, bautoaccept)
end

SerializerHelper.AskSunBathSettlement_Serializer = function(writer, npccultivationid, playtime)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, playtime, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskSunBathSettlement = function(self, npccultivationid, playtime)
	return self.Invoke(self, 63917627, SerializerHelper.AskSunBathSettlement_Serializer, npccultivationid, playtime)
end

SerializerHelper.AskPhoneContactOptionAction_Serializer = function(writer, spiritid, contactid, contactoptionid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, contactid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, contactoptionid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPhoneContactOptionAction = function(self, spiritid, contactid, contactoptionid)
	return self.Invoke(self, 63918677, SerializerHelper.AskPhoneContactOptionAction_Serializer, spiritid, contactid, contactoptionid)
end

SerializerHelper.AskResumeCardFlipGame_Serializer = function(writer)
end

ClientToGameDelegate.AskResumeCardFlipGame = function(self)
	return self.Invoke(self, 63920998, SerializerHelper.AskResumeCardFlipGame_Serializer)
end

SerializerHelper.AskLinkInfos_Serializer = function(writer)
end

ClientToGameDelegate.AskLinkInfos = function(self)
	return self.Invoke(self, 63923526, SerializerHelper.AskLinkInfos_Serializer)
end

SerializerHelper.AskPlaceCollectible_Serializer = function(writer, placedinfo, lootconfigid, itemuniqueid)
	SerializeBase.WriteComplex(writer, placedinfo, SerializeAuto.WriteFurniturePlacedInfo, "placedinfo", false)
	SerializeBase.WritePrimitive(writer, lootconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, itemuniqueid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskPlaceCollectible = function(self, placedinfo, lootconfigid, itemuniqueid)
	return self.Invoke(self, 63924450, SerializerHelper.AskPlaceCollectible_Serializer, placedinfo, lootconfigid, itemuniqueid)
end

SerializerHelper.AskPanelBrowsingTime_Serializer = function(writer, panelid, logicid, time)
	SerializeBase.WritePrimitive(writer, panelid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, logicid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, time, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPanelBrowsingTime = function(self, panelid, logicid, time)
	self.Notify(self, 63927330, SerializerHelper.AskPanelBrowsingTime_Serializer, panelid, logicid, time)
end

SerializerHelper.AskChangeRoleUseSystemName_Serializer = function(writer, usesystem)
	SerializeBase.WritePrimitive(writer, usesystem, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskChangeRoleUseSystemName = function(self, usesystem)
	return self.Invoke(self, 63927753, SerializerHelper.AskChangeRoleUseSystemName_Serializer, usesystem)
end

SerializerHelper.SyncChangeIndoor_Serializer = function(writer, indoorconfigid, boundid)
	SerializeBase.WritePrimitive(writer, indoorconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, boundid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.SyncChangeIndoor = function(self, indoorconfigid, boundid)
	return self.Invoke(self, 63927817, SerializerHelper.SyncChangeIndoor_Serializer, indoorconfigid, boundid)
end

SerializerHelper.AskDivinerEnterBattle_Serializer = function(writer)
end

ClientToGameDelegate.AskDivinerEnterBattle = function(self)
	return self.Invoke(self, 63928398, SerializerHelper.AskDivinerEnterBattle_Serializer)
end

SerializerHelper.AskOCAddSpeech_Serializer = function(writer, speechid, speechname, soundeffectconfig)
	writer.WriteString(writer, speechid, false, "AskOCAddSpeech.speechId", RpcLengthLimits.IClientToGame_AskOCAddSpeech_speechId)
	writer.WriteString(writer, speechname, false, "AskOCAddSpeech.speechName", RpcLengthLimits.IClientToGame_AskOCAddSpeech_speechName)
	SerializeBase.WriteComplex(writer, soundeffectconfig, SerializeAuto.WriteSoundEffectConfig, "soundeffectconfig", true)
end

ClientToGameDelegate.AskOCAddSpeech = function(self, speechid, speechname, soundeffectconfig)
	return self.Invoke(self, 63929121, SerializerHelper.AskOCAddSpeech_Serializer, speechid, speechname, soundeffectconfig)
end

SerializerHelper.AskCreatePartyRoom_Serializer = function(writer, param)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteCustomRoomCreateParam, "param", false)
end

ClientToGameDelegate.AskCreatePartyRoom = function(self, param)
	return self.Invoke(self, 63930160, SerializerHelper.AskCreatePartyRoom_Serializer, param)
end

SerializerHelper.AskClaimBattlePassReward_Serializer = function(writer, bpid, leveltoclaim)
	SerializeBase.WritePrimitive(writer, bpid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, leveltoclaim, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskClaimBattlePassReward = function(self, bpid, leveltoclaim)
	return self.Invoke(self, 63933021, SerializerHelper.AskClaimBattlePassReward_Serializer, bpid, leveltoclaim)
end

SerializerHelper.AskShoulderPoleUnBalance_Serializer = function(writer, unbalancetype, cargosceneiteminstanceid)
	writer.WriteString(writer, unbalancetype, false, "AskShoulderPoleUnBalance.unbalanceType", RpcLengthLimits.IClientToGame_AskShoulderPoleUnBalance_unbalanceType)
	SerializeBase.WritePrimitive(writer, cargosceneiteminstanceid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskShoulderPoleUnBalance = function(self, unbalancetype, cargosceneiteminstanceid)
	return self.Invoke(self, 63934735, SerializerHelper.AskShoulderPoleUnBalance_Serializer, unbalancetype, cargosceneiteminstanceid)
end

SerializerHelper.AskComputerEmailRead_Serializer = function(writer, email)
	SerializeBase.WritePrimitive(writer, email, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskComputerEmailRead = function(self, email)
	return self.Invoke(self, 63936010, SerializerHelper.AskComputerEmailRead_Serializer, email)
end

SerializerHelper.GetStsAssumeRole_Serializer = function(writer)
end

ClientToGameDelegate.GetStsAssumeRole = function(self)
	return self.Invoke(self, 63937079, SerializerHelper.GetStsAssumeRole_Serializer)
end

SerializerHelper.AskDoorClientInfo_Serializer = function(writer, gadgetid, index, info)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteDoorClientInfo, "info", false)
end

ClientToGameDelegate.AskDoorClientInfo = function(self, gadgetid, index, info)
	self.Notify(self, 63937430, SerializerHelper.AskDoorClientInfo_Serializer, gadgetid, index, info)
end

SerializerHelper.AskDivinerRequestAppeal_Serializer = function(writer, agententityid, message, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer.WriteString(writer, message, false, "AskDivinerRequestAppeal.message", RpcLengthLimits.IClientToGame_AskDivinerRequestAppeal_message)
	writer.WriteString(writer, lang, false, "AskDivinerRequestAppeal.lang", RpcLengthLimits.IClientToGame_AskDivinerRequestAppeal_lang)
end

ClientToGameDelegate.AskDivinerRequestAppeal = function(self, agententityid, message, lang)
	return self.Invoke(self, 63937822, SerializerHelper.AskDivinerRequestAppeal_Serializer, agententityid, message, lang)
end

SerializerHelper.AskNpcProfileCancelTargetNewState_Serializer = function(writer, profileid, target)
	SerializeBase.WritePrimitive(writer, profileid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, target, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskNpcProfileCancelTargetNewState = function(self, profileid, target)
	return self.Invoke(self, 63939232, SerializerHelper.AskNpcProfileCancelTargetNewState_Serializer, profileid, target)
end

SerializerHelper.AskReplyToFriendLinkInvite_Serializer = function(writer, type, friendid, accept)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 8, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, friendid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskReplyToFriendLinkInvite = function(self, type, friendid, accept)
	return self.Invoke(self, 63941383, SerializerHelper.AskReplyToFriendLinkInvite_Serializer, type, friendid, accept)
end

SerializerHelper.AskMomentsSendCommentWithId_Serializer = function(writer, postid, commentid)
	SerializeBase.WritePrimitive(writer, postid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, commentid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskMomentsSendCommentWithId = function(self, postid, commentid)
	return self.Invoke(self, 63943988, SerializerHelper.AskMomentsSendCommentWithId_Serializer, postid, commentid)
end

SerializerHelper.AskTakeClubWeeklyAward_Serializer = function(writer, clubid, cfgid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, cfgid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTakeClubWeeklyAward = function(self, clubid, cfgid)
	return self.Invoke(self, 63944840, SerializerHelper.AskTakeClubWeeklyAward_Serializer, clubid, cfgid)
end

SerializerHelper.AskHideAndSeekTransformModel_Serializer = function(writer, modelid)
	SerializeBase.WritePrimitive(writer, modelid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskHideAndSeekTransformModel = function(self, modelid)
	return self.Invoke(self, 63945807, SerializerHelper.AskHideAndSeekTransformModel_Serializer, modelid)
end

SerializerHelper.AskClubChangeJobName_Serializer = function(writer, jobid, jobname)
	SerializeBase.WritePrimitive(writer, jobid, writer.WriteUInt32, 0)
	writer.WriteString(writer, jobname, false, "AskClubChangeJobName.jobName", RpcLengthLimits.IClientToGame_AskClubChangeJobName_jobName)
end

ClientToGameDelegate.AskClubChangeJobName = function(self, jobid, jobname)
	return self.Invoke(self, 63946025, SerializerHelper.AskClubChangeJobName_Serializer, jobid, jobname)
end

SerializerHelper.AskAbandonPoliceTask_Serializer = function(writer)
end

ClientToGameDelegate.AskAbandonPoliceTask = function(self)
	return self.Invoke(self, 63946473, SerializerHelper.AskAbandonPoliceTask_Serializer)
end

SerializerHelper.AskConfirmPartyMiniGameMatch_Serializer = function(writer, gameconfigid, confirmed)
	SerializeBase.WritePrimitive(writer, gameconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, confirmed, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskConfirmPartyMiniGameMatch = function(self, gameconfigid, confirmed)
	return self.Invoke(self, 63947581, SerializerHelper.AskConfirmPartyMiniGameMatch_Serializer, gameconfigid, confirmed)
end

SerializerHelper.PartyLiveSwitch_Serializer = function(writer, start)
	SerializeBase.WritePrimitive(writer, start, writer.WriteBoolean, false)
end

ClientToGameDelegate.PartyLiveSwitch = function(self, start)
	return self.Invoke(self, 63948406, SerializerHelper.PartyLiveSwitch_Serializer, start)
end

SerializerHelper.SyncOpenInspireHub_Serializer = function(writer)
end

ClientToGameDelegate.SyncOpenInspireHub = function(self)
	return self.Invoke(self, 63948642, SerializerHelper.SyncOpenInspireHub_Serializer)
end

SerializerHelper.AskQueryRecommendClubs_Serializer = function(writer)
end

ClientToGameDelegate.AskQueryRecommendClubs = function(self)
	return self.Invoke(self, 63949445, SerializerHelper.AskQueryRecommendClubs_Serializer)
end

SerializerHelper.OnBreakChair_Serializer = function(writer)
end

ClientToGameDelegate.OnBreakChair = function(self)
	self.Notify(self, 63949803, SerializerHelper.OnBreakChair_Serializer)
end

SerializerHelper.AskCompleteSingleGymExercise_Serializer = function(writer, exerciseid, result)
	SerializeBase.WritePrimitive(writer, exerciseid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(result, 43, 0), writer.WriteByte, 0)
end

ClientToGameDelegate.AskCompleteSingleGymExercise = function(self, exerciseid, result)
	self.Notify(self, 63949981, SerializerHelper.AskCompleteSingleGymExercise_Serializer, exerciseid, result)
end

SerializerHelper.AskTuiteGetDetailByConfigId_Serializer = function(writer, tuitecfgid)
	SerializeBase.WritePrimitive(writer, tuitecfgid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskTuiteGetDetailByConfigId = function(self, tuitecfgid)
	return self.Invoke(self, 63950672, SerializerHelper.AskTuiteGetDetailByConfigId_Serializer, tuitecfgid)
end

SerializerHelper.AskCancelPartyMiniGameMatch_Serializer = function(writer, gameconfigid)
	SerializeBase.WritePrimitive(writer, gameconfigid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskCancelPartyMiniGameMatch = function(self, gameconfigid)
	return self.Invoke(self, 63953381, SerializerHelper.AskCancelPartyMiniGameMatch_Serializer, gameconfigid)
end

SerializerHelper.AskAkxSessionList_Serializer = function(writer)
end

ClientToGameDelegate.AskAkxSessionList = function(self)
	return self.Invoke(self, 63954207, SerializerHelper.AskAkxSessionList_Serializer)
end

SerializerHelper.PartyPrepareOver_Serializer = function(writer)
end

ClientToGameDelegate.PartyPrepareOver = function(self)
	return self.Invoke(self, 63955427, SerializerHelper.PartyPrepareOver_Serializer)
end

SerializerHelper.AskKTVBuyPackageTicket_Serializer = function(writer)
end

ClientToGameDelegate.AskKTVBuyPackageTicket = function(self)
	return self.Invoke(self, 63958203, SerializerHelper.AskKTVBuyPackageTicket_Serializer)
end

SerializerHelper.AskUseItems_Serializer = function(writer, uid, count)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskUseItems = function(self, uid, count)
	return self.Invoke(self, 63959573, SerializerHelper.AskUseItems_Serializer, uid, count)
end

SerializerHelper.AskClubGiveUpCustomJob_Serializer = function(writer)
end

ClientToGameDelegate.AskClubGiveUpCustomJob = function(self)
	return self.Invoke(self, 63960353, SerializerHelper.AskClubGiveUpCustomJob_Serializer)
end

SerializerHelper.ChuPai_Serializer = function(writer, pai, reach)
	SerializeBase.WriteStruct(writer, pai, SerializeAuto.WriteMjPaiInfo, "pai")
	SerializeBase.WritePrimitive(writer, reach, writer.WriteBoolean, false)
end

ClientToGameDelegate.ChuPai = function(self, pai, reach)
	self.Notify(self, 63960511, SerializerHelper.ChuPai_Serializer, pai, reach)
end

SerializerHelper.AskGachaDrawRecords_Serializer = function(writer, poolid, pageindex, pagesize)
	SerializeBase.WritePrimitive(writer, poolid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pageindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pagesize, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskGachaDrawRecords = function(self, poolid, pageindex, pagesize)
	return self.Invoke(self, 63960706, SerializerHelper.AskGachaDrawRecords_Serializer, poolid, pageindex, pagesize)
end

SerializerHelper.AskAcceptAndSetCurrentTask_Serializer = function(writer, taskid, spirit, ignoreswitchspirit)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spirit, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, ignoreswitchspirit, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskAcceptAndSetCurrentTask = function(self, taskid, spirit, ignoreswitchspirit)
	return self.Invoke(self, 63961538, SerializerHelper.AskAcceptAndSetCurrentTask_Serializer, taskid, spirit, ignoreswitchspirit)
end

SerializerHelper.Guo_Serializer = function(writer)
end

ClientToGameDelegate.Guo = function(self)
	self.Notify(self, 63962414, SerializerHelper.Guo_Serializer)
end

SerializerHelper.AskDivinerPersuade_Serializer = function(writer, agententityid, message, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer.WriteString(writer, message, false, "AskDivinerPersuade.message", RpcLengthLimits.IClientToGame_AskDivinerPersuade_message)
	writer.WriteString(writer, lang, false, "AskDivinerPersuade.lang", RpcLengthLimits.IClientToGame_AskDivinerPersuade_lang)
end

ClientToGameDelegate.AskDivinerPersuade = function(self, agententityid, message, lang)
	return self.Invoke(self, 63963071, SerializerHelper.AskDivinerPersuade_Serializer, agententityid, message, lang)
end

SerializerHelper.AskOCSetControllerByte9Value_Serializer = function(writer, ocid, controllerid, value)
	SerializeBase.WritePrimitive(writer, ocid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, controllerid, writer.WriteUInt16, 0)
	SerializeBase.WriteStruct(writer, value, SerializeAuto.WriteOCControllerByte9Value, "value")
end

ClientToGameDelegate.AskOCSetControllerByte9Value = function(self, ocid, controllerid, value)
	return self.Invoke(self, 63964115, SerializerHelper.AskOCSetControllerByte9Value_Serializer, ocid, controllerid, value)
end

SerializerHelper.AskClaimChallengeTaskReward_Serializer = function(writer, bpid, taskid)
	SerializeBase.WritePrimitive(writer, bpid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskClaimChallengeTaskReward = function(self, bpid, taskid)
	return self.Invoke(self, 63965239, SerializerHelper.AskClaimChallengeTaskReward_Serializer, bpid, taskid)
end

SerializerHelper.CreateSurrenderVote_Serializer = function(writer)
end

ClientToGameDelegate.CreateSurrenderVote = function(self)
	return self.Invoke(self, 63965738, SerializerHelper.CreateSurrenderVote_Serializer)
end

SerializerHelper.AskJoinTeam_Serializer = function(writer, newmember)
	SerializeBase.WritePrimitive(writer, newmember, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskJoinTeam = function(self, newmember)
	return self.Invoke(self, 63968355, SerializerHelper.AskJoinTeam_Serializer, newmember)
end

SerializerHelper.AskFactionInfo_Serializer = function(writer, factionid)
	SerializeBase.WritePrimitive(writer, factionid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFactionInfo = function(self, factionid)
	return self.Invoke(self, 63969725, SerializerHelper.AskFactionInfo_Serializer, factionid)
end

SerializerHelper.AskPublishNpcMoment_Serializer = function(writer, activitycfgid, isgroup, url, title)
	SerializeBase.WritePrimitive(writer, activitycfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isgroup, writer.WriteBoolean, false)
	writer.WriteString(writer, url, false, "AskPublishNpcMoment.url", RpcLengthLimits.IClientToGame_AskPublishNpcMoment_url)
	writer.WriteString(writer, title, true, "AskPublishNpcMoment.title", RpcLengthLimits.IClientToGame_AskPublishNpcMoment_title)
end

ClientToGameDelegate.AskPublishNpcMoment = function(self, activitycfgid, isgroup, url, title)
	return self.Invoke(self, 63969781, SerializerHelper.AskPublishNpcMoment_Serializer, activitycfgid, isgroup, url, title)
end

SerializerHelper.AskBuyCommodity_Serializer = function(writer, shopid, commodityid, count)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskBuyCommodity = function(self, shopid, commodityid, count)
	return self.Invoke(self, 63970007, SerializerHelper.AskBuyCommodity_Serializer, shopid, commodityid, count)
end

SerializerHelper.AskPlayerFarmerUnlockGroup_Serializer = function(writer, groupidlist)
	SerializeBase.WriteList7Bit(writer, groupidlist, writer.WriteUInt32, 0, "groupidlist", false, RpcLengthLimits.IClientToGame_AskPlayerFarmerUnlockGroup_groupIdList, nil)
end

ClientToGameDelegate.AskPlayerFarmerUnlockGroup = function(self, groupidlist)
	self.Notify(self, 63970660, SerializerHelper.AskPlayerFarmerUnlockGroup_Serializer, groupidlist)
end

SerializerHelper.AskRespondToPaintRequest_Serializer = function(writer, accepted)
	SerializeBase.WritePrimitive(writer, accepted, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskRespondToPaintRequest = function(self, accepted)
	return self.Invoke(self, 63970805, SerializerHelper.AskRespondToPaintRequest_Serializer, accepted)
end

SerializerHelper.AskTradeBuyOrder_Serializer = function(writer, orderkey)
	SerializeBase.WriteComplex(writer, orderkey, SerializeAuto.WriteTradeOrderIdQuadruple, "orderkey", false)
end

ClientToGameDelegate.AskTradeBuyOrder = function(self, orderkey)
	return self.Invoke(self, 63972452, SerializerHelper.AskTradeBuyOrder_Serializer, orderkey)
end

SerializerHelper.AskPoliceFakeFileTakeReward_Serializer = function(writer, fakefileid)
	SerializeBase.WritePrimitive(writer, fakefileid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskPoliceFakeFileTakeReward = function(self, fakefileid)
	return self.Invoke(self, 63972564, SerializerHelper.AskPoliceFakeFileTakeReward_Serializer, fakefileid)
end

SerializerHelper.AskMassageSettlement_Serializer = function(writer, companionnpcid)
	SerializeBase.WritePrimitive(writer, companionnpcid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskMassageSettlement = function(self, companionnpcid)
	return self.Invoke(self, 63973751, SerializerHelper.AskMassageSettlement_Serializer, companionnpcid)
end

SerializerHelper.AskQueryClubInfoByName_Serializer = function(writer, name)
	writer.WriteString(writer, name, false, "AskQueryClubInfoByName.name", RpcLengthLimits.IClientToGame_AskQueryClubInfoByName_name)
end

ClientToGameDelegate.AskQueryClubInfoByName = function(self, name)
	return self.Invoke(self, 63973808, SerializerHelper.AskQueryClubInfoByName_Serializer, name)
end

SerializerHelper.AskGetOffMobilePlatform_Serializer = function(writer)
end

ClientToGameDelegate.AskGetOffMobilePlatform = function(self)
	return self.Invoke(self, 63974264, SerializerHelper.AskGetOffMobilePlatform_Serializer)
end

SerializerHelper.AskChangeClubIcon_Serializer = function(writer, clubid, iconcfgid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, iconcfgid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskChangeClubIcon = function(self, clubid, iconcfgid)
	return self.Invoke(self, 63974305, SerializerHelper.AskChangeClubIcon_Serializer, clubid, iconcfgid)
end

SerializerHelper.AskChangeHackerName_Serializer = function(writer, name)
	writer.WriteString(writer, name, false, "AskChangeHackerName.name", RpcLengthLimits.IClientToGame_AskChangeHackerName_name)
end

ClientToGameDelegate.AskChangeHackerName = function(self, name)
	return self.Invoke(self, 63975191, SerializerHelper.AskChangeHackerName_Serializer, name)
end

SerializerHelper.ExitBasketballLink_Serializer = function(writer)
end

ClientToGameDelegate.ExitBasketballLink = function(self)
	self.Notify(self, 63975422, SerializerHelper.ExitBasketballLink_Serializer)
end

SerializerHelper.AskClubDeleteCustomJob_Serializer = function(writer, customjobid)
	SerializeBase.WritePrimitive(writer, customjobid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskClubDeleteCustomJob = function(self, customjobid)
	return self.Invoke(self, 63978354, SerializerHelper.AskClubDeleteCustomJob_Serializer, customjobid)
end

SerializerHelper.AskRemainChangeNameCount_Serializer = function(writer)
end

ClientToGameDelegate.AskRemainChangeNameCount = function(self)
	return self.Invoke(self, 63980351, SerializerHelper.AskRemainChangeNameCount_Serializer)
end

SerializerHelper.AskPopularityUIOpened_Serializer = function(writer)
end

ClientToGameDelegate.AskPopularityUIOpened = function(self)
	return self.Invoke(self, 63980710, SerializerHelper.AskPopularityUIOpened_Serializer)
end

SerializerHelper.SetPSNOnly_Serializer = function(writer, ispsnonly)
	SerializeBase.WritePrimitive(writer, ispsnonly, writer.WriteBoolean, false)
end

ClientToGameDelegate.SetPSNOnly = function(self, ispsnonly)
	self.Notify(self, 63980880, SerializerHelper.SetPSNOnly_Serializer, ispsnonly)
end

SerializerHelper.AskBuyCommodityToBag_Serializer = function(writer, shopid, commodityid, count, bagconfigids)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, commodityid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, bagconfigids, writer.WriteUInt32, 0, "bagconfigids", false, RpcLengthLimits.IClientToGame_AskBuyCommodityToBag_bagConfigIds, nil)
end

ClientToGameDelegate.AskBuyCommodityToBag = function(self, shopid, commodityid, count, bagconfigids)
	return self.Invoke(self, 63980996, SerializerHelper.AskBuyCommodityToBag_Serializer, shopid, commodityid, count, bagconfigids)
end

SerializerHelper.AskKickPartyMember_Serializer = function(writer, targetpid)
	SerializeBase.WritePrimitive(writer, targetpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskKickPartyMember = function(self, targetpid)
	return self.Invoke(self, 63981097, SerializerHelper.AskKickPartyMember_Serializer, targetpid)
end

SerializerHelper.AskDivinerFinishPersuade_Serializer = function(writer, agententityid, lang)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	writer.WriteString(writer, lang, false, "AskDivinerFinishPersuade.lang", RpcLengthLimits.IClientToGame_AskDivinerFinishPersuade_lang)
end

ClientToGameDelegate.AskDivinerFinishPersuade = function(self, agententityid, lang)
	return self.Invoke(self, 63983172, SerializerHelper.AskDivinerFinishPersuade_Serializer, agententityid, lang)
end

SerializerHelper.AskFarmerCraft_Serializer = function(writer, ruleid, count)
	SerializeBase.WritePrimitive(writer, ruleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskFarmerCraft = function(self, ruleid, count)
	return self.Invoke(self, 63985402, SerializerHelper.AskFarmerCraft_Serializer, ruleid, count)
end

SerializerHelper.AskFinishAIInterrogation_Serializer = function(writer, caseid, options)
	SerializeBase.WritePrimitive(writer, caseid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, options, SerializeAuto.WriteAIInterrogationFinishOptions, "options")
end

ClientToGameDelegate.AskFinishAIInterrogation = function(self, caseid, options)
	return self.Invoke(self, 63985830, SerializerHelper.AskFinishAIInterrogation_Serializer, caseid, options)
end

SerializerHelper.AskReFortune_Serializer = function(writer, gadgetid)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskReFortune = function(self, gadgetid)
	return self.Invoke(self, 63986024, SerializerHelper.AskReFortune_Serializer, gadgetid)
end

SerializerHelper.AskModifySpiritWearFashionsOnlyWearWithSource_Serializer = function(writer, spiritorinstanceid, source, unwearfashionidlist, wearfashioninfolist)
	SerializeBase.WritePrimitive(writer, spiritorinstanceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, source, writer.WriteInt16, 0)
	SerializeBase.WriteList7Bit(writer, unwearfashionidlist, writer.WriteUInt32, 0, "unwearfashionidlist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionsOnlyWearWithSource_unwearFashionIdList, nil)
	SerializeBase.WriteList7Bit(writer, wearfashioninfolist, SerializeBase.WriteComplexWrap(SerializeAuto.WriteWearFashionInfo, "WearFashionInfo", true), nil, "wearfashioninfolist", true, RpcLengthLimits.IClientToGame_AskModifySpiritWearFashionsOnlyWearWithSource_wearFashionInfoList, nil)
end

ClientToGameDelegate.AskModifySpiritWearFashionsOnlyWearWithSource = function(self, spiritorinstanceid, source, unwearfashionidlist, wearfashioninfolist)
	return self.Invoke(self, 63986985, SerializerHelper.AskModifySpiritWearFashionsOnlyWearWithSource_Serializer, spiritorinstanceid, source, unwearfashionidlist, wearfashioninfolist)
end

SerializerHelper.AskInteractTuite_Serializer = function(writer, tuiteid, interacttype)
	SerializeBase.WritePrimitive(writer, tuiteid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, interacttype, writer.WriteByte, 0)
end

ClientToGameDelegate.AskInteractTuite = function(self, tuiteid, interacttype)
	return self.Invoke(self, 63989368, SerializerHelper.AskInteractTuite_Serializer, tuiteid, interacttype)
end

SerializerHelper.AskGetInterruptedDialogId_Serializer = function(writer, taskid, dialogid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskGetInterruptedDialogId = function(self, taskid, dialogid)
	return self.Invoke(self, 63989414, SerializerHelper.AskGetInterruptedDialogId_Serializer, taskid, dialogid)
end

SerializerHelper.AskCloseConnectionToGame_Serializer = function(writer, msg)
	writer.WriteString(writer, msg, false, "AskCloseConnectionToGame.msg", RpcLengthLimits.IClientToGame_AskCloseConnectionToGame_msg)
end

ClientToGameDelegate.AskCloseConnectionToGame = function(self, msg)
	return self.Invoke(self, 63990036, SerializerHelper.AskCloseConnectionToGame_Serializer, msg)
end

SerializerHelper.SetNewChallengeData_Serializer = function(writer, challengeid, data, score)
	SerializeBase.WritePrimitive(writer, challengeid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, data, writer.WriteBoolean, false, "data", false, RpcLengthLimits.IClientToGame_SetNewChallengeData_data, nil)
	SerializeBase.WritePrimitive(writer, score, writer.WriteSingle, 0)
end

ClientToGameDelegate.SetNewChallengeData = function(self, challengeid, data, score)
	return self.Invoke(self, 63990449, SerializerHelper.SetNewChallengeData_Serializer, challengeid, data, score)
end

SerializerHelper.SearchCustomRooms_Serializer = function(writer, param)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteCustomRoomSearchParam, "param", false)
end

ClientToGameDelegate.SearchCustomRooms = function(self, param)
	return self.Invoke(self, 63990608, SerializerHelper.SearchCustomRooms_Serializer, param)
end

SerializerHelper.AskQuitJob_Serializer = function(writer, jobclassid)
	SerializeBase.WritePrimitive(writer, jobclassid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.AskQuitJob = function(self, jobclassid)
	return self.Invoke(self, 63990693, SerializerHelper.AskQuitJob_Serializer, jobclassid)
end

SerializerHelper.SyncPSNBlacklist_Serializer = function(writer, pids)
	SerializeBase.WriteList7Bit(writer, pids, writer.WriteUInt64, 0, "pids", false, RpcLengthLimits.IClientToGame_SyncPSNBlacklist_pids, nil)
end

ClientToGameDelegate.SyncPSNBlacklist = function(self, pids)
	return self.Invoke(self, 63990897, SerializerHelper.SyncPSNBlacklist_Serializer, pids)
end

SerializerHelper.AskKickMemberFromClub_Serializer = function(writer, clubid, memberpid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskKickMemberFromClub = function(self, clubid, memberpid)
	return self.Invoke(self, 63991393, SerializerHelper.AskKickMemberFromClub_Serializer, clubid, memberpid)
end

SerializerHelper.AskTamagotchiInfo_Serializer = function(writer)
end

ClientToGameDelegate.AskTamagotchiInfo = function(self)
	return self.Invoke(self, 63992007, SerializerHelper.AskTamagotchiInfo_Serializer)
end

SerializerHelper.AskSlowGuide_Serializer = function(writer, guideid, startorcancel)
	SerializeBase.WritePrimitive(writer, guideid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, startorcancel, writer.WriteBoolean, false)
end

ClientToGameDelegate.AskSlowGuide = function(self, guideid, startorcancel)
	return self.Invoke(self, 63995009, SerializerHelper.AskSlowGuide_Serializer, guideid, startorcancel)
end

SerializerHelper.AskJoinClub_Serializer = function(writer, clubid, memberpid)
	SerializeBase.WritePrimitive(writer, clubid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, memberpid, writer.WriteUInt64, 0)
end

ClientToGameDelegate.AskJoinClub = function(self, clubid, memberpid)
	return self.Invoke(self, 63996210, SerializerHelper.AskJoinClub_Serializer, clubid, memberpid)
end

SerializerHelper.AskBuyCommoditiesToBag_Serializer = function(writer, shopid, commodityiddict, bagconfigids)
	SerializeBase.WritePrimitive(writer, shopid, writer.WriteUInt32, 0)
	SerializeBase.WriteDict7Bit(writer, commodityiddict, writer.WriteUInt32, writer.WriteUInt32, 0, "commodityiddict", false, RpcLengthLimits.IClientToGame_AskBuyCommoditiesToBag_commodityIdDict)
	SerializeBase.WriteList7Bit(writer, bagconfigids, writer.WriteUInt32, 0, "bagconfigids", false, RpcLengthLimits.IClientToGame_AskBuyCommoditiesToBag_bagConfigIds, nil)
end

ClientToGameDelegate.AskBuyCommoditiesToBag = function(self, shopid, commodityiddict, bagconfigids)
	return self.Invoke(self, 63999030, SerializerHelper.AskBuyCommoditiesToBag_Serializer, shopid, commodityiddict, bagconfigids)
end

SerializerHelper.SyncWorldBattlePlayers_Serializer = function(writer, gadgetid, multiplayerid, enter, aiunitid, duty, extrainfo)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, multiplayerid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, aiunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, duty, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, extrainfo, SerializeAuto.WriteSyncWorldBattlePlayersExtraInfo, "extrainfo", true)
end

ClientToGameDelegate.SyncWorldBattlePlayers = function(self, gadgetid, multiplayerid, enter, aiunitid, duty, extrainfo)
	return self.Invoke(self, 63999507, SerializerHelper.SyncWorldBattlePlayers_Serializer, gadgetid, multiplayerid, enter, aiunitid, duty, extrainfo)
end

SerializerHelper.TryInteractStory_Serializer = function(writer, npccultivationid, storyid)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, storyid, writer.WriteUInt32, 0)
end

ClientToGameDelegate.TryInteractStory = function(self, npccultivationid, storyid)
	self.Notify(self, 63999952, SerializerHelper.TryInteractStory_Serializer, npccultivationid, storyid)
end

return ClientToGameDelegate
