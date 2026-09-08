-- Original chunk: @Lua\LuaFiles\LX6\GUI\CallPhone\CallPhoneUtils.lua
-- Decompiled from: 02174_CallPhoneUtils.lua_a5d2e7a8bd60.luajit

local FightSpiritConfig = LTConfig.FightSpiritConfig
local M = {
	allSpiritIdList = {
		["n\\xa1\\xb7\\xa1\\xa2"] = 0,
		["0M\\x9f\\x89\\x97I"] = 0
	}
}

M.InitMessages = function()
	slot0 = gMessageManager

	slot0:AddMessageListener(gEventConstants.MULTI_DIALOG_MOVE_STATUS, function (_, status)
		M.OnMultiDialogMoveStatus(status)
	end)

	slot0 = gMessageManager

	slot0:AddMessageListener(gEventConstants.ON_VIDEO_CALL_IN_RUNNING_STATE_CHANGE, function ()
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_STATE_CHANGE)
	end)
end

M.InitMessages()

M.GetAllSpiritIdList = function()
	if M.allSpiritIdList.Count ~= 0 then
		for index = 0, FightSpiritConfig.count - 1 do
			local fightSpiritCfg = FightSpiritConfig.LoadAt(index)

			table.insert(M.allSpiritIdList, fightSpiritCfg.Id)

			M.allSpiritIdList.Count = M.allSpiritIdList.Count + 1
			M.allSpiritIdList.Length = M.allSpiritIdList.Length + 1
		end
	end

	return M.allSpiritIdList
end

M.TryGetPhoneInfos = function(spiritId)
	spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId)
	local spiritPhoneInfos = gPlayerManager.infoMinor.bindData.spiritPhoneInfos

	return spiritPhoneInfos and spiritPhoneInfos[spiritId]
end

M.GetContactList = function(spiritId)
	local phoneInfos = M.TryGetPhoneInfos(spiritId)

	if not phoneInfos then
		return {}
	end

	return phoneInfos.ContactList
end

M.ReviewPhoneNumber = function(phoneNumber, onPass, onFail)
	if string.is_null_or_empty(phoneNumber) then
		onPass()

		return
	end

	gClientUtils.EnvSdkReviewWords(phoneNumber, function ()
		onPass()
	end, function ()
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SNSCheckFail)

		if onFail then
			onFail()
		end
	end, gClientConst.CallPhoneChannelName)
end

M.AddPhoneContact = function(spiritId, phoneNumber, remark)
	if M.CheckPhoneNumberIsExist(spiritId, phoneNumber, true) then
		return
	end

	if M.CheckManualContactAddLimit(spiritId, true) then
		return
	end

	M.ReviewPhoneNumber(phoneNumber, function ()
		local maxLen = LTConfig.PhoneConfig.ContactNameMaxLength

		gClientUtils.CheckNameValid(remark, maxLen, nil, gClientConst.CallPhoneChannelName, function ()
			slot0 = gClientToGameDelegate

			slot0:AskPhoneAddContact(spiritId, phoneNumber, remark).Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				local addContactInfo = {
					PhoneNumber = phoneNumber,
					Remark = remark
				}

				M.SyncAddPhoneContact(spiritId, addContactInfo)
				gMessageManager:SendMessage(gEventConstants.ON_CALL_PHONE_ADD_CONTACT_SUCCESS, addContactInfo)
			end
		end)
	end)
end

M.CheckManualContactAddLimit = function(spiritId, showTips)
	local manualAddContactCount = M.GetManualAddContactCount(spiritId)

	if LTConfig.PhoneConfig.ManualAddContactMaxCount >= manualAddContactCount + 1 then
		if showTips then
			local addMaxTips = LTConfig.PhoneConfig.ContactAddMaxTips

			gDisplayMessageMgr:ShowMessageContent(addMaxTips)
		end

		return true
	end

	return false
end

M.CheckPhoneNumberIsExist = function(spiritId, phoneNumber, showExistTips)
	local contactList = M.GetContactList(spiritId)

	for _, contactInfo in ipairs(contactList) do
		if contactInfo.PhoneNumber ~= phoneNumber then
			if showExistTips then
				local existTips = LTConfig.PhoneConfig.ContactPhoneNumberExistTips

				gDisplayMessageMgr:ShowMessageContent(existTips)
			end

			return true
		end
	end
end

M.SyncAddPhoneContact = function(spiritId, newContactInfo)
	local contactList = M.GetContactList(spiritId)

	for _, contactInfo in ipairs(contactList) do
		if contactInfo.PhoneNumber ~= newContactInfo.PhoneNumber then
			return
		end
	end

	table.insert(contactList, newContactInfo)

	contactList.Count = contactList.Count + 1
	contactList.Length = contactList.Length + 1
end

M.SyncDeletePhoneContact = function(spiritId, deleteContactInfo)
	local contactList = M.GetContactList(spiritId)

	for idx, contactInfo in ipairs(contactList) do
		if contactInfo.PhoneNumber ~= deleteContactInfo.PhoneNumber then
			table.remove(contactList, idx)

			contactList.Count = contactList.Count - 1
			contactList.Length = contactList.Length - 1

			return
		end
	end
end

M.SyncPhoneUnlockContactIdList = function(incrementContactUnlockIdList)
	if not gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.CallPhoneId) then
		return
	end

	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()
	local spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(currentSpiritId)
	local showContactIdList = {}

	for _, unlockContactId in ipairs(incrementContactUnlockIdList) do
		local phoneContactUnlockCfg = LTConfig.PhoneContactUnlockConfig.GetConfig(unlockContactId)
		local phoneContactId = phoneContactUnlockCfg and phoneContactUnlockCfg.PhoneContactId

		if phoneContactId then
			local phoneContactCfg = LTConfig.PhoneContactConfig.GetConfig(phoneContactId)

			if phoneContactCfg and phoneContactCfg.PhoneNumber and phoneContactCfg.AutoAddFlag and (#phoneContactUnlockCfg.SpiritIdList ~= 0 or table.contains(phoneContactUnlockCfg.SpiritIdList, spiritId)) then
				table.insert(showContactIdList, phoneContactId)
			end
		end
	end

	gPhoneCallPopupManager:PushPopupInfoList(showContactIdList)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTACT_UNLOCKED)
end

M.SyncPhoneUnlockOptionIdList = function(incrementUnlockOptionIdList)
	for _, unlockOptionId in ipairs(incrementUnlockOptionIdList) do
		local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(unlockOptionId)

		if contactOptionCfg and contactOptionCfg.UnlockDialogId and not contactOptionCfg.IgnoreAutoCallIn then
			gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_IN, unlockOptionId)
		end
	end
end

M.EditPhoneContact = function(spiritId, contactId, newPhoneNumber, newRemark)
	local contactInfo = M.GetContactInfoById(gSpiritManager:GetCurFirstSpiritTid(), contactId)
	local remark = M.GetContactRemark(contactId)

	if contactInfo.PhoneNumber ~= newPhoneNumber and remark ~= newRemark then
		gMessageManager:SendMessage(gEventConstants.ON_CALL_PHONE_EDIT_CONTACT_SUCCESS, contactId)

		return
	end

	local isPhoneNumberChanged = contactInfo.PhoneNumber == newPhoneNumber

	if isPhoneNumberChanged and M.CheckPhoneNumberIsExist(spiritId, newPhoneNumber, true) then
		return
	end

	local maxLen = LTConfig.PhoneConfig.ContactNameMaxLength

	local onPhoneNumberPass = function()
		gClientUtils.CheckNameValid(newRemark, maxLen, nil, gClientConst.CallPhoneChannelName, function ()
			local oldPhoneNumber = contactInfo.PhoneNumber
			slot1 = gClientToGameDelegate

			slot1:AskPhoneEditContact(spiritId, oldPhoneNumber, newPhoneNumber, newRemark).Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				contactInfo.PhoneNumber = newPhoneNumber
				contactInfo.Remark = newRemark

				gMessageManager:SendMessage(gEventConstants.ON_CALL_PHONE_EDIT_CONTACT_SUCCESS, contactId)
			end
		end)
	end

	if not isPhoneNumberChanged then
		onPhoneNumberPass()

		return
	end

	M.ReviewPhoneNumber(newPhoneNumber, onPhoneNumberPass)
end

M.GetContactIdList = function(spiritId)
	local contactList = M.GetContactList(spiritId)
	local friendContactIdList = {}
	local quickCallContactIdList = {}

	for index, contactInfo in ipairs(contactList) do
		local id = index
		local phoneNumber = contactInfo.PhoneNumber
		local configId = M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)

		if configId then
			local config = LTConfig.PhoneContactConfig.GetConfig(configId)
			local isQuickCall = config.IsQuickCall

			if not string.is_null_or_empty(config.Check) then
				local success, flag = gClientUtils.RunCode(config.Check, gDialogScriptFunc)

				if not success or not flag then
					id = nil
				end
			end

			if isQuickCall and id then
				table.insert(quickCallContactIdList, id)
			end
		end

		if id then
			table.insert(friendContactIdList, id)
		end
	end

	M.SortContactList(friendContactIdList)
	M.SortContactList(quickCallContactIdList)

	return quickCallContactIdList, friendContactIdList
end

M.SortContactList = function(contactIdList)
	table.sort(contactIdList, function (contactId1, contactId2)
		local remark1 = M.GetContactRemark(contactId1)
		local remark2 = M.GetContactRemark(contactId2)

		if remark1 == remark2 then
			local pinyinRemark1 = gCS.LuaUtils.GetPinyin(remark1)
			local pinyinRemark2 = gCS.LuaUtils.GetPinyin(remark2)

			return pinyinRemark1 <= pinyinRemark2
		end

		return contactId1 <= contactId2
	end)
end

M.CheckContactCanDelete = function(contactId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local contactInfo = M.GetContactInfoById(spiritId, contactId)

	if contactInfo then
		local phoneNumber = contactInfo.PhoneNumber
		local configId = M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)

		if configId then
			local hasUnlock = M.CheckConfigContactHasUnlock(spiritId, configId)

			if hasUnlock then
				local config = LTConfig.PhoneContactConfig.GetConfig(configId)

				if config then
					return config.CanDelete
				end
			end
		end
	end

	return true
end

M.CheckConfigContactHasUnlock = function(spiritId, configId)
	if not configId then
		return true
	end

	spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId)

	for i = 0, LTConfig.PhoneContactUnlockConfig.count - 1 do
		local contactUnlockCfg = LTConfig.PhoneContactUnlockConfig.LoadAt(i)

		if contactUnlockCfg.PhoneContactId ~= configId and (#contactUnlockCfg.SpiritIdList ~= 0 or table.contains(contactUnlockCfg.SpiritIdList, spiritId)) and gEventConditionUtils.CheckHasUnlocked(contactUnlockCfg, UX.Game.EventConditionImplModule.PhoneContact) then
			return true
		end
	end

	return false
end

M.GetContactInfoById = function(spiritId, contactId)
	local contactList = M.GetContactList(spiritId)
	local index = contactId

	return contactList[index]
end

M.GetHudQuickCallInfoList = function()
	return {
		LTConfig.PhoneConfig.ShortCutCallCar,
		LTConfig.PhoneConfig.ShortCutCallMilkVehicle
	}
end

M.GetContactRemark = function(contactId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local contactInfo = M.GetContactInfoById(spiritId, contactId)

	if contactInfo then
		local phoneNumber = contactInfo.PhoneNumber
		local configId = M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)
		local config = LTConfig.PhoneContactConfig.GetConfig(configId)
		local isEmptyRemark = string.is_null_or_empty(contactInfo.Remark)

		return isEmptyRemark and config and config.Remark or contactInfo.Remark
	else
		return ""
	end
end

M.GetContactName = function(contactId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local contactInfo = M.GetContactInfoById(spiritId, contactId)
	local configId = nil

	if contactInfo then
		local phoneNumber = contactInfo.PhoneNumber
		configId = M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)
	end

	return M.GetContactNameByConfigId(configId)
end

M.GetContactNameByConfigId = function(configId)
	local config = LTConfig.PhoneContactConfig.GetConfig(configId)

	return config and config.Name or ""
end

M.GetContactPhoneNumber = function(contactId)
	local contactInfo = M.GetContactInfoById(gSpiritManager:GetCurFirstSpiritTid(), contactId)

	if contactInfo then
		return contactInfo.PhoneNumber
	else
		return ""
	end
end

M.GetContactSAvatarId = function(contactId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local contactInfo = M.GetContactInfoById(spiritId, contactId)
	local configId = contactInfo and M.GetConfigIdByPhoneNumber(spiritId, contactInfo.PhoneNumber)

	return M.GetSAvatarByConfigId(configId)
end

M.GetSAvatarByConfigId = function(configId)
	local avatarId = nil

	if configId ~= LTConfig.PhoneContactConfig.Player then
		avatarId = gStoreStaticMethod:GetHeadIcon(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	else
		local config = LTConfig.PhoneContactConfig.GetConfig(configId)
		avatarId = config and config.SAvatarIcon
	end

	return avatarId or LTConfig.PhoneConfig.ContactDefaultSAvatarId
end

M.DeletePhoneContact = function(spiritId, contactId, failCallback)
	slot5 = gSpiritManager
	local contactInfo = M.GetContactInfoById(slot5:GetCurFirstSpiritTid(), contactId)
	local phoneNumber = contactInfo.PhoneNumber
	slot5 = gClientToGameDelegate

	slot5:AskPhoneDeleteContact(spiritId, phoneNumber).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if failCallback then
				failCallback()
			end

			return
		end

		local contactList = M.GetContactList(spiritId)
		local index = contactId

		table.remove(contactList, index)

		contactList.Count = contactList.Count - 1
		contactList.Length = contactList.Length - 1

		gMessageManager:SendMessage(gEventConstants.ON_CALL_PHONE_DELETE_CONTACT_SUCCESS, contactId)
	end
end

M.AskPhoneAddCallRecord = function(spiritId, phoneNumber, callType, callback)
	if gClientUtils.CheckIsForbidRequestRpc() then
		return
	end

	slot4 = gClientToGameDelegate

	slot4:AskPhoneAddCallRecord(spiritId, phoneNumber, callType).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end

			return
		end

		local phoneInfos = M.TryGetPhoneInfos(spiritId)
		local callRecordList = phoneInfos.CallRecordList
		local callRecordInfo = {
			PhoneNumber = phoneNumber,
			callType = callType,
			CallTime = os.time()
		}

		table.insert(callRecordList, callRecordInfo)
		gMessageManager:SendMessage(gEventConstants.ON_CALL_PHONE_ADD_CALL_RECORD_SUCCESS, callRecordInfo)

		if callback then
			callback(true)
		end
	end
end

M.DoPhoneContactOptionAction = function(spiritId, contactOptionId, callback)
	local phoneNumber = M.currentDialogPhoneNumber
	local configId = M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)
	slot5 = gClientToGameDelegate

	slot5:AskPhoneContactOptionAction(spiritId, configId, contactOptionId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			if callback then
				callback(false)
			end

			return
		end

		if callback then
			callback(true)
		end
	end
end

M.ShowEditPanelByAddContact = function(spiritId, phoneNumber, lastShowType)
	if M.CheckPhoneNumberIsExist(spiritId, phoneNumber, true) then
		return
	end

	if M.CheckManualContactAddLimit(spiritId, true) then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_SHOW, {
		secondShowType = gClientConst.CallPhoneShowType.Edit,
		phoneNumber = phoneNumber,
		lastShowType = lastShowType
	})
end

M.GetManualAddContactCount = function(spiritId)
	local count = 0
	local contactList = M.GetContactList(spiritId)

	for index, _ in ipairs(contactList) do
		local contactId = index

		if M.CheckContactCanDelete(contactId) then
			count = count + 1
		end
	end

	return count
end

M.ShowContactDetailPanel = function(spiritId, phoneNumber)
	local contactId = M.GetContactIdByPhoneNumber(spiritId, phoneNumber)
	local args = {
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.CallPhone,
		secondShowType = gClientConst.CallPhoneShowType.Detail,
		contactId = contactId
	}

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

M.GetContactIdByPhoneNumber = function(spiritId, phoneNumber)
	local contactList = M.GetContactList(spiritId)

	for index, contactInfo in ipairs(contactList) do
		if contactInfo.PhoneNumber ~= phoneNumber then
			local id = index

			return id
		end
	end
end

M.GetConfigIdByPhoneNumber = function(spiritId, phoneNumber)
	spiritId = gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId)
	local count = LTConfig.PhoneContactConfig.count

	for i = 0, count - 1 do
		local config = LTConfig.PhoneContactConfig.LoadAt(i)

		if config.PhoneNumber ~= phoneNumber then
			if not spiritId then
				return config.Id
			end

			local contactUnlockIdList = M.GetContactUnlockIdList(config.Id)

			if #contactUnlockIdList ~= 0 then
				return config.Id
			end

			for _, contactUnlockId in ipairs(contactUnlockIdList) do
				local contactUnlockCfg = LTConfig.PhoneContactUnlockConfig.GetConfig(contactUnlockId)

				if next(contactUnlockCfg.SpiritIdList) ~= nil or table.contains(contactUnlockCfg.SpiritIdList, spiritId) then
					return config.Id
				end
			end
		end
	end
end

M.GetContactUnlockIdList = function(contactId)
	local count = LTConfig.PhoneContactUnlockConfig.count
	local contactUnlockIdList = {}

	for i = 0, count - 1 do
		local config = LTConfig.PhoneContactUnlockConfig.LoadAt(i)

		if config.PhoneContactId ~= contactId then
			table.insert(contactUnlockIdList, config.Id)
		end
	end

	return contactUnlockIdList
end

M.ShowCallPhoneTimelineDialogPanel = function(spiritId, phoneNumber)
	if gCallPhoneUtils.waitCo then
		return
	end

	gCallPhoneUtils.waitCo = coroutine.start(function ()
		coroutine.wait(0.3)

		gCallPhoneUtils.waitCo = nil
	end)
	local dialogId, callSuccess, configId = M.GetDialogArgsByPhoneNumber(spiritId, phoneNumber)

	if dialogId ~= 0 then
		print_error("@linmingh CallPhone Dialog is 0", dialogId, callSuccess, configId)
	end

	local failTips = not callSuccess and LTConfig.PhoneConfig.ContactCallFail
	local callType = callSuccess and UX.Game.PhoneContactCallType.Outgoing or UX.Game.PhoneContactCallType.OutgoingMissed

	M.AskPhoneAddCallRecord(spiritId, phoneNumber, callType)

	local phoneContactCfg = LTConfig.PhoneContactConfig.GetConfig(configId)

	if phoneContactCfg and phoneContactCfg.TaskPhoneList then
		for _, taskPhone in ipairs(phoneContactCfg.TaskPhoneList) do
			local taskId = taskPhone.taskId
			local timelineName = taskPhone.timelineName
			local taskState = gTaskManager:GetTaskState(taskId)

			if taskState ~= UX.Game.TaskState.Accepted then
				gTimelineManager:Timeline_LoadAndPlay(timelineName, gTimelineManager:Timeline_CreateTimelineData())

				return
			end
		end
	end

	M.currentDialogPhoneNumber = phoneNumber
	local param = gDialogManager.CreateDialogParam()

	if type(param.FailCallMessage) ~= "string" then
		param.FailCallMessage = failTips
	end

	param.ConnectAnim = true

	if not table.find(LTConfig.PhoneConfig.IgnoreAutoClosePhoneDialogIdList, dialogId) then
		gClientUtils.CloseMainPhonePanel()
	end

	slot9 = gDialogManager

	slot9:CloseDialog(true)

	slot9 = gDialogManager

	slot9:ShowGeneralDialog(dialogId, gDialogSource.Phone, nil, param, function (callbackDialogId, _, state)
		if state ~= gClientConst.DialogState.Start then
			M.ExecuteStartAction(spiritId, callbackDialogId, true)
		elseif state ~= gClientConst.DialogState.End then
			M.ExecuteLinkModeDialogAction(configId)
		end
	end)
end

M.ExecuteStartAction = function(spiritId, dialogId, isSuccess)
	local count = LTConfig.PhoneContactOptionConfig.count

	for i = 0, count - 1 do
		local contactOptionCfg = LTConfig.PhoneContactOptionConfig.LoadAt(i)

		if contactOptionCfg and contactOptionCfg.OptionDialogId ~= dialogId then
			if string.is_null_or_empty(contactOptionCfg.Action) then
				M.DoPhoneContactOptionAction(spiritId, contactOptionCfg.Id, function (result)
					isSuccess = result and isSuccess

					M.ShowContactOptionDialog(contactOptionCfg.Id, isSuccess, nil, dialogId)
				end)
			else
				gClientUtils.RunCode(contactOptionCfg.Action, gDialogScriptFunc)

				gCallPhoneUtils.waitCo = coroutine.stop(gCallPhoneUtils.waitCo)
			end

			break
		end
	end
end

M.ExecuteLinkModeDialogAction = function(configId)
	local config = LTConfig.PhoneContactConfig.GetConfig(configId)

	if config and config.LinkModeStartDialogId <= 0 and gClientUtils.CheckIsLinkMode() then
		local raidId = gMapSystem.lastRaidId
		local count = LTConfig.CollectionCountryConfig.count

		for i = 0, count - 1 do
			local countryCfg = LTConfig.CollectionCountryConfig.LoadAt(i)

			if table.contains(countryCfg.RaidIds, raidId) then
				local functionPointId = LTConfig.IndoorConfig.LinkMilkCarPointId[countryCfg.Id]

				gMapSubSystem_FunctionPoint:TryTraceByFunctionPointId(functionPointId)

				return
			end
		end
	end
end

M.GetDialogArgsByPhoneNumber = function(spiritId, phoneNumber)
	if phoneNumber then
		local configId = M.GetConfigIdByPhoneNumber(nil, phoneNumber)

		if configId then
			local config = LTConfig.PhoneContactConfig.GetConfig(configId)

			if configId ~= LTConfig.PhoneContactConfig.Player and gSpiritManager.CheckIsDefaultSpiritId(spiritId) then
				return LTConfig.PhoneConfig.ContactSelfDialogId
			end

			local relatedNpcId = config.RelatedNpcId

			if relatedNpcId and relatedNpcId <= 0 then
				local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(relatedNpcId)
				local fightSpiritId = npcCultivationCfg and npcCultivationCfg.FightSpiritID

				if spiritId ~= fightSpiritId then
					return LTConfig.PhoneConfig.ContactSelfDialogId
				end
			end

			local hasUnlock = M.CheckConfigContactHasUnlock(spiritId, configId)

			if not hasUnlock then
				return config.LockDialogId, false, config.Id
			end

			if gClientUtils.CheckIsLinkMode() and config.LinkModeStartDialogId <= 0 then
				return config.LinkModeStartDialogId, hasUnlock, config.Id
			end

			if config.OtherDialogId <= 0 and not gClientUtils.CheckCurrentIsDefaultSpirit() then
				return config.OtherDialogId, hasUnlock, config.Id
			end

			if config.TaskDialogList then
				for _, taskDialogInfo in ipairs(config.TaskDialogList) do
					local taskId = taskDialogInfo.taskId
					local dialogId = taskDialogInfo.dialogId
					local taskState = gTaskManager:GetTaskState(taskId)

					if taskState ~= UX.Game.TaskState.Accepted then
						return dialogId, hasUnlock, config.Id
					end
				end
			end

			return config.StartDialogId, hasUnlock, config.Id
		end
	end

	return LTConfig.PhoneConfig.ContactUnknownPhoneNumberDialogId, false
end

M.CheckContactOptionHasUnlock = function(optionId)
	local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(optionId)

	if contactOptionCfg then
		local phoneContactOptionModule = UX.Game.EventConditionImplModule.PhoneContactOption

		return gEventConditionUtils.CheckHasUnlocked(contactOptionCfg, phoneContactOptionModule)
	end

	return false
end

M.GetContactOptionId = function(contactId)
	local phoneContactCfg = LTConfig.PhoneContactConfig.GetConfig(contactId)
	local startDialogId = phoneContactCfg.StartDialogId
	local count = LTConfig.PhoneContactOptionConfig.count

	for i = 0, count - 1 do
		local contactOptionCfg = LTConfig.PhoneContactOptionConfig.LoadAt(i)

		if contactOptionCfg.OptionDialogId ~= startDialogId then
			return contactOptionCfg.Id
		end
	end
end

M.CallMilkCar = function(contactOptionId)
	slot1 = gSpiritManager
	local spiritId = slot1:GetCurFirstSpiritTid()

	M.DoPhoneContactOptionAction(spiritId, contactOptionId, function (result)
		if result and not gLinkManager:CheckInMatchMode() then
			M.SummonMilkVehicle(function (isSuccess)
				M.ShowContactOptionDialog(contactOptionId, isSuccess)
			end)
		else
			M.ShowContactOptionDialog(contactOptionId, false)
		end
	end)
end

M.ShowNpcFavourDialog = function(contactOptionId)
	slot1 = gSpiritManager
	local spiritId = slot1:GetCurFirstSpiritTid()

	M.DoPhoneContactOptionAction(spiritId, contactOptionId, function (result)
		local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(contactOptionId)
		local dialogId = result and contactOptionCfg.UnlockDialogId or contactOptionCfg.FailDialogId

		if dialogId ~= 0 then
			print_error("@linmingh CallPhone Dialog is 0", dialogId, result, contactOptionCfg.UnlockDialogId, contactOptionCfg.FailDialogId)
		end

		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Phone)
	end)
end

M.CallVehicle = function(vehicleId, contactOptionId, callback)
	slot3 = gSpiritManager
	local spiritId = slot3:GetCurFirstSpiritTid()

	M.DoPhoneContactOptionAction(spiritId, contactOptionId, function (result)
		if result then
			if not gCoreHudUIManager:GetSkillBtnState(gCoreHudUIManager.skillType.PhoneCall, "vehicleCondition") or not gCS.LuaUtils.IsBaseUnitValid(gCS.MyPlayerManager.PlayerUnit) then
				M.ShowContactOptionDialog(contactOptionId, false, callback)

				return
			end

			local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj
			slot2 = gVehicleGamePlayManager.cs_manager

			slot2:AskSummonVehicle(vehicleId, playerObj.position, playerObj.eulerAngles.y, function (isSuccess)
				M.ShowContactOptionDialog(contactOptionId, isSuccess, callback)
			end)
		else
			M.ShowContactOptionDialog(contactOptionId, false, callback)
		end
	end)

	return true
end

M.ShowContactOptionDialog = function(contactOptionId, isSuccess, callback)
	local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(contactOptionId)
	local dialogId = isSuccess and contactOptionCfg.SuccessDialogId or contactOptionCfg.FailDialogId

	if dialogId then
		if isSuccess and not gMainPhoneUtils.IsFakePhoneExist() then
			gClientUtils.CloseMainPhonePanel()
		end

		if dialogId ~= 0 then
			print_error("@linmingh CallPhone Dialog is 0", dialogId, isSuccess, contactOptionCfg.SuccessDialogId, contactOptionCfg.FailDialogId)
		end

		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Phone)
	end

	if callback then
		callback()
	end
end

M.CheckIsForbidModifyPhoneNumber = function(contactId, showTips)
	if contactId then
		local spiritId = gSpiritManager:GetCurFirstSpiritTid()
		local contactInfo = M.GetContactInfoById(spiritId, contactId)
		local phoneNumber = contactInfo.PhoneNumber
		local configId = M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)

		if configId then
			local hasUnlock = M.CheckConfigContactHasUnlock(spiritId, configId)

			if hasUnlock then
				if showTips then
					local forbidModifyPhoneNumberTips = LTConfig.PhoneConfig.ContactForbidModifyPhoneNumberTips

					gDisplayMessageMgr:ShowMessageContent(forbidModifyPhoneNumberTips)
				end

				return true
			end
		end
	end

	return false
end

M.CheckIsShowName = function(contactId)
	if contactId then
		local remark = M.GetContactRemark(contactId)
		local name = M.GetContactName(contactId)

		return not string.is_null_or_empty(name) and remark == name
	end

	return false
end

M.GetChatNpcId = function(contactId)
	local hasChatUnlock = gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.MessageId)

	if hasChatUnlock and contactId then
		local spiritId = gSpiritManager:GetCurFirstSpiritTid()
		local contactInfo = M.GetContactInfoById(spiritId, contactId)
		local configId = M.GetConfigIdByPhoneNumber(spiritId, contactInfo.PhoneNumber)
		local hasUnlock = M.CheckConfigContactHasUnlock(spiritId, configId)

		if hasUnlock then
			local contactCfg = LTConfig.PhoneContactConfig.GetConfig(configId)

			return contactCfg and contactCfg.RelatedNpcId
		end
	end
end

M.ReportAlarm = function(contactOptionId)
	slot1 = gSpiritManager
	local spiritId = slot1:GetCurFirstSpiritTid()

	M.DoPhoneContactOptionAction(spiritId, contactOptionId, function (result)
		local isSuccess = gCS.PoliceSystem.Instance:ReportAlarm(nil, , true)
		isSuccess = result and isSuccess

		M.ShowContactOptionDialog(contactOptionId, isSuccess)
	end)
end

M.CallCar = function(contactOptionId, defaultSelectVehicleId)
	slot2 = gMessageManager

	slot2:SendMessage(gEventConstants.HIDE_DIALOG_INCALL_MESSAGE, true)
	gMainPhoneUtils.ShowPhoneAppContent({
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.CallPhone,
		secondShowType = gClientConst.CallPhoneShowType.Call_Car,
		defaultSelectVehicleId = defaultSelectVehicleId,
		onCustomConfirmCallback = function (selectedVehicleId)
			gCallPhoneUtils.CallVehicle(selectedVehicleId, contactOptionId)
		end,
		onDestroyCallback = function ()
			gMessageManager:SendMessage(gEventConstants.HIDE_DIALOG_INCALL_MESSAGE, false)
		end
	})
end

M.OnCarSummonBtnClick = function()
	local callCarInfo = LTConfig.PhoneConfig.ShortCutCallCar
	local contactCfg = LTConfig.PhoneContactConfig.GetConfig(callCarInfo.contactId)
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

	gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(spiritId, contactCfg.PhoneNumber)
end

M.OnMilkCarSummonBtnClick = function()
	local milkVehicleInfo = LTConfig.PhoneConfig.ShortCutCallMilkVehicle
	local contactCfg = LTConfig.PhoneContactConfig.GetConfig(milkVehicleInfo.contactId)
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

	gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(spiritId, contactCfg.PhoneNumber)
end

M.CheckMilkCarHasUnlocked = function()
	local unlockedVehicles = gApplyCarManager.UnlockedVehicles

	if unlockedVehicles then
		for _, vehicleInfo in ipairs(unlockedVehicles) do
			if vehicleInfo.Id ~= LTConfig.VehicleConfig.MilkVehicle then
				return true
			end
		end
	end

	return false
end

M.CheckCallCarEnable = function()
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.CallVehicleUnlock) and not gCallPhoneUtils.CheckPhoneCallConflict()
end

M.CheckMilkCarEnable = function()
	return gCallPhoneUtils.CheckMilkCarHasUnlocked() and not gLinkManager:CheckInMatchMode() and not gCallPhoneUtils.CheckPhoneCallConflict()
end

M.SummonMilkVehicle = function(callback)
	if not gCoreHudUIManager:GetSkillBtnState(gCoreHudUIManager.skillType.MilkCar, "vehicleCondition") or not gCS.LuaUtils.IsBaseUnitValid(gCS.MyPlayerManager.PlayerUnit) then
		if callback then
			callback(false)
		end

		return
	end

	local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj

	gVehicleGamePlayManager.cs_manager:AskSummonVehicle(LTConfig.VehicleConfig.MilkVehicle, playerObj.position, playerObj.eulerAngles.y, callback)
end

M.OnMultiDialogMoveStatus = function(status)
	M.multiMoveStatus = status

	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_STATE_CHANGE)
end

M.CheckPhoneCallConflict = function()
	return M.multiMoveStatus ~= 1 or M.multiMoveStatus ~= 2 or gDialogManager.VideoCallInRunning
end

gCallPhoneUtils = M
