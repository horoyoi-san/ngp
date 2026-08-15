local FightSpiritConfig = LTConfig.FightSpiritConfig
local M = {
	allSpiritIdList = {
		Count = 0,
		Length = 0
	}
}

function M.InitMessages()
	gMessageManager:AddMessageListener(gEventConstants.MULTI_DIALOG_MOVE_STATUS, function (_, status)
		M.OnMultiDialogMoveStatus(status)
	end)
	gMessageManager:AddMessageListener(gEventConstants.ON_VIDEO_CALL_IN_RUNNING_STATE_CHANGE, function ()
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_STATE_CHANGE)
	end)
end

M.InitMessages()

function M.GetAllSpiritIdList()
	if M.allSpiritIdList.Count == 0 then
		for index = 0, FightSpiritConfig.count - 1 do
			local fightSpiritCfg = FightSpiritConfig.LoadAt(index)

			table.insert(M.allSpiritIdList, fightSpiritCfg.Id)

			M.allSpiritIdList.Count = M.allSpiritIdList.Count + 1
			M.allSpiritIdList.Length = M.allSpiritIdList.Length + 1
		end
	end

	return M.allSpiritIdList
end

function M.TryGetPhoneInfos(spiritId)
	local spiritPhoneInfos = gPlayerManager.infoMinor.bindData.spiritPhoneInfos

	return spiritPhoneInfos and spiritPhoneInfos[spiritId]
end

function M.GetContactList(spiritId)
	local phoneInfos = M.TryGetPhoneInfos(spiritId)

	if not phoneInfos then
		return {}
	end

	return phoneInfos.ContactList
end

function M.AddPhoneContact(spiritId, phoneNumber, remark)
	if M.CheckPhoneNumberIsExist(spiritId, phoneNumber, true) then
		return
	end

	if M.CheckManualContactAddLimit(spiritId, true) then
		return
	end

	local maxLen = LTConfig.PhoneConfig.ContactNameMaxLength

	gClientUtils.CheckNameValid(remark, maxLen, nil, gClientConst.CallPhoneChannelName, function ()
		gClientToGameDelegate:AskPhoneAddContact(spiritId, phoneNumber, remark).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
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
end

function M.CheckManualContactAddLimit(spiritId, showTips)
	local manualAddContactCount = M.GetManualAddContactCount(spiritId)

	if LTConfig.PhoneConfig.ManualAddContactMaxCount < manualAddContactCount + 1 then
		if showTips then
			local addMaxTips = LTConfig.PhoneConfig.ContactAddMaxTips

			gDisplayMessageMgr:ShowMessageContent(addMaxTips)
		end

		return true
	end

	return false
end

function M.CheckPhoneNumberIsExist(spiritId, phoneNumber, showExistTips)
	local contactList = M.GetContactList(spiritId)

	for _, contactInfo in ipairs(contactList) do
		if contactInfo.PhoneNumber == phoneNumber then
			if showExistTips then
				local existTips = LTConfig.PhoneConfig.ContactPhoneNumberExistTips

				gDisplayMessageMgr:ShowMessageContent(existTips)
			end

			return true
		end
	end
end

function M.SyncAddPhoneContact(spiritId, newContactInfo)
	local contactList = M.GetContactList(spiritId)

	for _, contactInfo in ipairs(contactList) do
		if contactInfo.PhoneNumber == newContactInfo.PhoneNumber then
			return
		end
	end

	table.insert(contactList, newContactInfo)

	contactList.Count = contactList.Count + 1
	contactList.Length = contactList.Length + 1
end

function M.SyncDeletePhoneContact(spiritId, deleteContactInfo)
	local contactList = M.GetContactList(spiritId)

	for idx, contactInfo in ipairs(contactList) do
		if contactInfo.PhoneNumber == deleteContactInfo.PhoneNumber then
			table.remove(contactList, idx)

			contactList.Count = contactList.Count - 1
			contactList.Length = contactList.Length - 1

			return
		end
	end
end

function M.SyncPhoneUnlockContactIdList(incrementContactUnlockIdList)
	if not gMainPhoneUtils.CheckAppCanShow(LTConfig.MobileMenuSGuiConfig.CallPhoneId) then
		return
	end

	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()
	local showContactIdList = {}

	for _, unlockContactId in ipairs(incrementContactUnlockIdList) do
		local phoneContactUnlockCfg = LTConfig.PhoneContactUnlockConfig.GetConfig(unlockContactId)
		local phoneContactId = phoneContactUnlockCfg and phoneContactUnlockCfg.PhoneContactId

		if phoneContactId then
			local phoneContactCfg = LTConfig.PhoneContactConfig.GetConfig(phoneContactId)

			if phoneContactCfg and phoneContactCfg.PhoneNumber and phoneContactCfg.AutoAddFlag and (#phoneContactUnlockCfg.SpiritIdList == 0 or table.contains(phoneContactUnlockCfg.SpiritIdList, currentSpiritId)) then
				table.insert(showContactIdList, phoneContactId)
			end
		end
	end

	gPhoneCallPopupManager:PushPopupInfoList(showContactIdList)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTACT_UNLOCKED)
end

function M.SyncPhoneUnlockOptionIdList(incrementUnlockOptionIdList)
	for _, unlockOptionId in ipairs(incrementUnlockOptionIdList) do
		local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(unlockOptionId)

		if contactOptionCfg and contactOptionCfg.UnlockDialogId and not contactOptionCfg.IgnoreAutoCallIn then
			gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_IN, unlockOptionId)
		end
	end
end

function M.EditPhoneContact(spiritId, contactId, newPhoneNumber, newRemark)
	local contactInfo = M.GetContactInfoById(gSpiritManager:GetCurFirstSpiritTid(), contactId)
	local remark = M.GetContactRemark(contactId)

	if contactInfo.PhoneNumber == newPhoneNumber and remark == newRemark then
		gMessageManager:SendMessage(gEventConstants.ON_CALL_PHONE_EDIT_CONTACT_SUCCESS, contactId)

		return
	end

	if contactInfo.PhoneNumber ~= newPhoneNumber and M.CheckPhoneNumberIsExist(spiritId, newPhoneNumber, true) then
		return
	end

	local maxLen = LTConfig.PhoneConfig.ContactNameMaxLength

	gClientUtils.CheckNameValid(newRemark, maxLen, nil, gClientConst.CallPhoneChannelName, function ()
		local oldPhoneNumber = contactInfo.PhoneNumber

		gClientToGameDelegate:AskPhoneEditContact(spiritId, oldPhoneNumber, newPhoneNumber, newRemark).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			contactInfo.PhoneNumber = newPhoneNumber
			contactInfo.Remark = newRemark

			gMessageManager:SendMessage(gEventConstants.ON_CALL_PHONE_EDIT_CONTACT_SUCCESS, contactId)
		end
	end)
end

function M.GetContactIdList(spiritId)
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

function M.SortContactList(contactIdList)
	table.sort(contactIdList, function (contactId1, contactId2)
		local remark1 = M.GetContactRemark(contactId1)
		local remark2 = M.GetContactRemark(contactId2)

		if remark1 ~= remark2 then
			local pinyinRemark1 = gCS.LuaUtils.GetPinyin(remark1)
			local pinyinRemark2 = gCS.LuaUtils.GetPinyin(remark2)

			return pinyinRemark1 < pinyinRemark2
		end

		return contactId1 < contactId2
	end)
end

function M.CheckContactCanDelete(contactId)
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

function M.CheckConfigContactHasUnlock(spiritId, configId)
	if not configId then
		return true
	end

	local targetContactUnlockCfg = nil

	for i = 0, LTConfig.PhoneContactUnlockConfig.count - 1 do
		local contactUnlockCfg = LTConfig.PhoneContactUnlockConfig.LoadAt(i)

		if contactUnlockCfg.PhoneContactId == configId and (#contactUnlockCfg.SpiritIdList == 0 or table.contains(contactUnlockCfg.SpiritIdList, spiritId)) then
			targetContactUnlockCfg = contactUnlockCfg

			break
		end
	end

	return targetContactUnlockCfg and gEventConditionUtils.CheckHasUnlocked(targetContactUnlockCfg, UX.Game.EventConditionImplModule.PhoneContact)
end

function M.GetContactInfoById(spiritId, contactId)
	local contactList = M.GetContactList(spiritId)
	local index = contactId

	return contactList[index]
end

function M.GetHudQuickCallInfoList()
	return {
		LTConfig.PhoneConfig.ShortCutCallCar,
		LTConfig.PhoneConfig.ShortCutCallMilkVehicle
	}
end

function M.GetContactRemark(contactId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local contactInfo = M.GetContactInfoById(spiritId, contactId)

	if contactInfo then
		local phoneNumber = contactInfo.PhoneNumber
		local configId = M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)
		local config = LTConfig.PhoneContactConfig.GetConfig(configId)
		local isEmptyRemark = string.is_null_or_empty(contactInfo.Remark)

		if configId == LTConfig.PhoneContactConfig.Player and gLoginManager:CheckIsTgsPack() then
			return LTConfig.NpcCultivationConfig.GetConfig(LTConfig.NpcCultivationConfig.DefaultMale).Name
		else
			return isEmptyRemark and config and config.Remark or contactInfo.Remark
		end
	else
		return ""
	end
end

function M.GetContactName(contactId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local contactInfo = M.GetContactInfoById(spiritId, contactId)
	local configId = nil

	if contactInfo then
		local phoneNumber = contactInfo.PhoneNumber
		configId = M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)
	end

	return M.GetContactNameByConfigId(configId)
end

function M.GetContactNameByConfigId(configId)
	if configId == LTConfig.PhoneContactConfig.Player and gLoginManager:CheckIsTgsPack() then
		return LTConfig.NpcCultivationConfig.GetConfig(LTConfig.NpcCultivationConfig.DefaultMale).Name
	else
		local config = LTConfig.PhoneContactConfig.GetConfig(configId)

		return config and config.Name or ""
	end
end

function M.GetContactPhoneNumber(contactId)
	local contactInfo = M.GetContactInfoById(gSpiritManager:GetCurFirstSpiritTid(), contactId)

	if contactInfo then
		return contactInfo.PhoneNumber
	else
		return ""
	end
end

function M.GetContactSAvatarId(contactId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local contactInfo = M.GetContactInfoById(spiritId, contactId)
	local configId = contactInfo and M.GetConfigIdByPhoneNumber(spiritId, contactInfo.PhoneNumber)

	return M.GetSAvatarByConfigId(configId)
end

function M.GetSAvatarByConfigId(configId)
	local avatarId = nil

	if configId == LTConfig.PhoneContactConfig.Player then
		avatarId = gStoreStaticMethod:GetHeadIcon(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)
	else
		local config = LTConfig.PhoneContactConfig.GetConfig(configId)
		avatarId = config and config.SAvatarIcon
	end

	return avatarId or LTConfig.PhoneConfig.ContactDefaultSAvatarId
end

function M.DeletePhoneContact(spiritId, contactId, failCallback)
	local contactInfo = M.GetContactInfoById(gSpiritManager:GetCurFirstSpiritTid(), contactId)
	local phoneNumber = contactInfo.PhoneNumber

	gClientToGameDelegate:AskPhoneDeleteContact(spiritId, phoneNumber).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
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

function M.AskPhoneAddCallRecord(spiritId, phoneNumber, callType, callback)
	gClientToGameDelegate:AskPhoneAddCallRecord(spiritId, phoneNumber, callType).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
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

function M.DoPhoneContactOptionAction(spiritId, contactOptionId, callback)
	local phoneNumber = M.currentDialogPhoneNumber
	local configId = M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)

	gClientToGameDelegate:AskPhoneContactOptionAction(spiritId, configId, contactOptionId).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
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

function M.ShowEditPanelByAddContact(spiritId, phoneNumber, lastShowType)
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

function M.GetManualAddContactCount(spiritId)
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

function M.ShowContactDetailPanel(spiritId, phoneNumber)
	local contactId = M.GetContactIdByPhoneNumber(spiritId, phoneNumber)
	local args = {
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.CallPhone,
		secondShowType = gClientConst.CallPhoneShowType.Detail,
		contactId = contactId
	}

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

function M.GetContactIdByPhoneNumber(spiritId, phoneNumber)
	local contactList = M.GetContactList(spiritId)

	for index, contactInfo in ipairs(contactList) do
		if contactInfo.PhoneNumber == phoneNumber then
			local id = index

			return id
		end
	end
end

function M.GetConfigIdByPhoneNumber(spiritId, phoneNumber)
	local count = LTConfig.PhoneContactConfig.count

	for i = 0, count - 1 do
		local config = LTConfig.PhoneContactConfig.LoadAt(i)

		if config.PhoneNumber == phoneNumber then
			if not spiritId then
				return config.Id
			end

			local contactUnlockIdList = M.GetContactUnlockIdList(config.Id)

			if #contactUnlockIdList == 0 then
				return config.Id
			end

			for _, contactUnlockId in ipairs(contactUnlockIdList) do
				local contactUnlockCfg = LTConfig.PhoneContactUnlockConfig.GetConfig(contactUnlockId)

				if next(contactUnlockCfg.SpiritIdList) == nil or table.contains(contactUnlockCfg.SpiritIdList, spiritId) then
					return config.Id
				end
			end
		end
	end
end

function M.GetContactUnlockIdList(contactId)
	local count = LTConfig.PhoneContactUnlockConfig.count
	local contactUnlockIdList = {}

	for i = 0, count - 1 do
		local config = LTConfig.PhoneContactUnlockConfig.LoadAt(i)

		if config.PhoneContactId == contactId then
			table.insert(contactUnlockIdList, config.Id)
		end
	end

	return contactUnlockIdList
end

function M.ShowCallPhoneTimelineDialogPanel(spiritId, phoneNumber)
	if gCallPhoneUtils.waitCo then
		return
	end

	gCallPhoneUtils.waitCo = coroutine.start(function ()
		coroutine.wait(0.3)

		gCallPhoneUtils.waitCo = nil
	end)
	local dialogId, callSuccess, configId = M.GetDialogArgsByPhoneNumber(spiritId, phoneNumber)
	local failTips = not callSuccess and LTConfig.PhoneConfig.ContactCallFail
	local callType = callSuccess and UX.Game.PhoneContactCallType.Outgoing or UX.Game.PhoneContactCallType.OutgoingMissed

	M.AskPhoneAddCallRecord(spiritId, phoneNumber, callType)

	local phoneContactCfg = LTConfig.PhoneContactConfig.GetConfig(configId)

	if phoneContactCfg and phoneContactCfg.TaskPhoneList then
		for _, taskPhone in ipairs(phoneContactCfg.TaskPhoneList) do
			local taskId = taskPhone.taskId
			local timelineName = taskPhone.timelineName
			local taskState = gTaskManager:GetTaskState(taskId)

			if taskState == UX.Game.TaskState.Accepted then
				gTimelineManager:Timeline_LoadAndPlay(timelineName, gTimelineManager:Timeline_CreateTimelineData())

				return
			end
		end
	end

	M.currentDialogPhoneNumber = phoneNumber
	local param = gDialogManager.CreateDialogParam()

	if type(param.FailCallMessage) == "string" then
		param.FailCallMessage = failTips
	end

	param.ConnectAnim = true

	if not table.find(LTConfig.PhoneConfig.IgnoreAutoClosePhoneDialogIdList, dialogId) then
		gClientUtils.CloseMainPhonePanel()
	end

	gDialogManager:CloseDialog(true)
	gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Phone, nil, param, function (callbackDialogId, _, state)
		if state == gClientConst.DialogState.Start then
			M.ExecuteStartAction(spiritId, callbackDialogId, true)
		elseif state == gClientConst.DialogState.End then
			M.ExecuteLinkModeDialogAction(configId)
		end
	end)
end

function M.ExecuteStartAction(spiritId, dialogId, isSuccess)
	local count = LTConfig.PhoneContactOptionConfig.count

	for i = 0, count - 1 do
		local contactOptionCfg = LTConfig.PhoneContactOptionConfig.LoadAt(i)

		if contactOptionCfg and contactOptionCfg.OptionDialogId == dialogId then
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

function M.ExecuteLinkModeDialogAction(configId)
	local config = LTConfig.PhoneContactConfig.GetConfig(configId)

	if config and config.LinkModeStartDialogId > 0 and gClientUtils.CheckIsLinkMode() then
		local raidId = gMapSystem.lastRaidId
		local count = LTConfig.CollectionCountryConfig.count

		for i = 0, count - 1 do
			local countryCfg = LTConfig.CollectionCountryConfig.LoadAt(i)

			if countryCfg.RaidId == raidId then
				local functionPointId = LTConfig.IndoorConfig.LinkMilkCarPointId[countryCfg.Id]

				gMapSubSystem_FunctionPoint:TryTraceByFunctionPointId(functionPointId)

				return
			end
		end
	end
end

function M.GetDialogArgsByPhoneNumber(spiritId, phoneNumber)
	if phoneNumber then
		local configId = M.GetConfigIdByPhoneNumber(nil, phoneNumber)

		if configId then
			local config = LTConfig.PhoneContactConfig.GetConfig(configId)

			if configId == LTConfig.PhoneContactConfig.Player and gSpiritManager.CheckIsDefaultSpiritId(spiritId) then
				return LTConfig.PhoneConfig.ContactSelfDialogId
			end

			local relatedNpcId = config.RelatedNpcId

			if relatedNpcId and relatedNpcId > 0 then
				local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(relatedNpcId)
				local fightSpiritId = npcCultivationCfg and npcCultivationCfg.FightSpiritID

				if spiritId == fightSpiritId then
					return LTConfig.PhoneConfig.ContactSelfDialogId
				end
			end

			local hasUnlock = M.CheckConfigContactHasUnlock(spiritId, configId)

			if not hasUnlock then
				return config.LockDialogId, false, config.Id
			end

			if gClientUtils.CheckIsLinkMode() and config.LinkModeStartDialogId > 0 then
				return config.LinkModeStartDialogId, hasUnlock, config.Id
			end

			if config.OtherDialogId > 0 and not gClientUtils.CheckCurrentIsDefaultSpirit() then
				return config.OtherDialogId, hasUnlock, config.Id
			end

			if config.TaskDialogList then
				for _, taskDialogInfo in ipairs(config.TaskDialogList) do
					local taskId = taskDialogInfo.taskId
					local dialogId = taskDialogInfo.dialogId
					local taskState = gTaskManager:GetTaskState(taskId)

					if taskState == UX.Game.TaskState.Accepted then
						return dialogId, hasUnlock, config.Id
					end
				end
			end

			return config.StartDialogId, hasUnlock, config.Id
		end
	end

	return LTConfig.PhoneConfig.ContactUnknownPhoneNumberDialogId, false
end

function M.CheckContactOptionHasUnlock(optionId)
	local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(optionId)

	if contactOptionCfg then
		local phoneContactOptionModule = UX.Game.EventConditionImplModule.PhoneContactOption

		return gEventConditionUtils.CheckHasUnlocked(contactOptionCfg, phoneContactOptionModule)
	end

	return false
end

function M.GetContactOptionId(contactId)
	local phoneContactCfg = LTConfig.PhoneContactConfig.GetConfig(contactId)
	local startDialogId = phoneContactCfg.StartDialogId
	local count = LTConfig.PhoneContactOptionConfig.count

	for i = 0, count - 1 do
		local contactOptionCfg = LTConfig.PhoneContactOptionConfig.LoadAt(i)

		if contactOptionCfg.OptionDialogId == startDialogId then
			return contactOptionCfg.Id
		end
	end
end

function M.CallMilkCar(contactOptionId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()

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

function M.ShowNpcFavourDialog(contactOptionId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()

	M.DoPhoneContactOptionAction(spiritId, contactOptionId, function (result)
		local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(contactOptionId)
		local dialogId = result and contactOptionCfg.UnlockDialogId or contactOptionCfg.FailDialogId

		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Phone)
	end)
end

function M.CallVehicle(vehicleId, contactOptionId, callback)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()

	M.DoPhoneContactOptionAction(spiritId, contactOptionId, function (result)
		if result then
			local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj

			gVehicleGamePlayManager.cs_manager:AskSummonVehicle(vehicleId, playerObj.position, playerObj.eulerAngles.y, function (isSuccess)
				M.ShowContactOptionDialog(contactOptionId, isSuccess, callback)
			end)
		else
			M.ShowContactOptionDialog(contactOptionId, false, callback)
		end
	end)
end

function M.ShowContactOptionDialog(contactOptionId, isSuccess, callback)
	local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(contactOptionId)
	local dialogId = isSuccess and contactOptionCfg.SuccessDialogId or contactOptionCfg.FailDialogId

	if dialogId then
		if isSuccess and not gMainPhoneUtils.IsFakePhoneExist() then
			gClientUtils.CloseMainPhonePanel()
		end

		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Phone)
	end

	if callback then
		callback()
	end
end

function M.CheckIsForbidModifyPhoneNumber(contactId, showTips)
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

function M.CheckIsShowName(contactId)
	if contactId then
		local remark = M.GetContactRemark(contactId)
		local name = M.GetContactName(contactId)

		return not string.is_null_or_empty(name) and remark ~= name
	end

	return false
end

function M.GetChatNpcId(contactId)
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

function M.ReportAlarm(contactOptionId)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()

	M.DoPhoneContactOptionAction(spiritId, contactOptionId, function (result)
		local isSuccess = gCS.PoliceSystem.Instance:ReportAlarm(nil, nil, true)
		isSuccess = result and isSuccess

		M.ShowContactOptionDialog(contactOptionId, isSuccess)
	end)
end

function M.CallCar(contactOptionId, defaultSelectVehicleId)
	gMessageManager:SendMessage(gEventConstants.HIDE_DIALOG_INCALL_MESSAGE, true)
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

function M.OnCarSummonBtnClick()
	local callCarInfo = LTConfig.PhoneConfig.ShortCutCallCar
	local contactCfg = LTConfig.PhoneContactConfig.GetConfig(callCarInfo.contactId)
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

	gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(spiritId, contactCfg.PhoneNumber)
end

function M.OnMilkCarSummonBtnClick()
	local milkVehicleInfo = LTConfig.PhoneConfig.ShortCutCallMilkVehicle
	local contactCfg = LTConfig.PhoneContactConfig.GetConfig(milkVehicleInfo.contactId)
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

	gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(spiritId, contactCfg.PhoneNumber)
end

function M.CheckMilkCarHasUnlocked()
	local unlockedVehicles = gApplyCarManager.UnlockedVehicles

	if unlockedVehicles then
		for _, vehicleInfo in ipairs(unlockedVehicles) do
			if vehicleInfo.Id == LTConfig.VehicleConfig.MilkVehicle then
				return true
			end
		end
	end

	return false
end

function M.CheckPhoneCallCarHasUnlocked()
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.CallVehicleUnlock)
end

function M.SummonMilkVehicle(callback)
	local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj

	gVehicleGamePlayManager.cs_manager:AskSummonVehicle(LTConfig.VehicleConfig.MilkVehicle, playerObj.position, playerObj.eulerAngles.y, callback)
end

function M.OpenCallCarPanel()
	local args = {
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.CallPhone,
		secondShowType = gClientConst.CallPhoneShowType.Call_Car,
		onCustomConfirmCallback = function (selectedVehicleId)
			local phoneCallCarPanelStore = gStoreManager:GetStoreGroup("PhoneCallCarPanelStore")
			local rootGo = phoneCallCarPanelStore and phoneCallCarPanelStore.rootGo

			local function closePanel()
				if gClientUtils.NotNil(rootGo) then
					phoneCallCarPanelStore:OnExit()
				end
			end

			if not selectedVehicleId then
				closePanel()

				return
			end

			local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj

			gVehicleGamePlayManager.cs_manager:AskSummonVehicle(selectedVehicleId, playerObj.position, playerObj.eulerAngles.y, function (_)
				closePanel()
			end)
		end
	}

	gPanelManager:CheckShow(gPanelId.S_HALF_PHONE_APP_HOME_PANEL, args)
end

function M.OnMultiDialogMoveStatus(status)
	M.multiMoveStatus = status

	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_STATE_CHANGE)
end

function M.CheckPhoneCallConflict()
	return M.multiMoveStatus == 1 or M.multiMoveStatus == 2 or gDialogManager.VideoCallInRunning
end

gCallPhoneUtils = M
