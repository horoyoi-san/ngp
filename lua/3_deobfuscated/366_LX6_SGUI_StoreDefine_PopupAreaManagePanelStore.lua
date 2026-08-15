local PopupConfig = LTConfig.PopupConfig
local EInvokeTime = SGUI.EInvokeTime
C_PopupAreaManagePanelStore = DefClass("C_PopupAreaManagePanelStore", C_PopupAreaManagePanelStore, C_StoreGroup)
GroupName2Class.PopupAreaManagePanelStore = C_PopupAreaManagePanelStore
local M = C_PopupAreaManagePanelStore

function M:ctor()
	self.DEFINE_DynamicOnUpdate = true
end

function M:DefineAllVariables()
	self.needUpdateList = false
	self.popupList = {}
	self.LIST_ITEM_STAGE = {
		CLOSE = 1,
		SHOW = 0
	}
	self.needUpdateWaiting = false
	self.WAIT_STAGE = {
		WAIT_SPACE = 1,
		WAIT_ENOUGH = 2,
		WAIT_RENDER = 0
	}
	self.waitingInfo = nil
	self.waitingFrame = 0
	self.waitStage = 0
	self.needCheckSpace = false
	self.needUpdateMove = false
	self.moveSpeed = 0
	self.moveLength = 0
	self.moveCountDown = 0
	local customData = self.rootWidget.CustomBindData
	self.moveCurve = customData.curve
	self.moveCurveLength = self.moveCurve.length
	self.moveTime = customData.length and customData.length or -1

	if customData.length < 0 then
		self.moveTime = PopupConfig.AreaFiveMoveTime
	end

	self.moveInitPos = Vector2.zero
	self.needUpdateNext = false
	self.currId = -1
	self.nextTime = 0
	self.DEBUG = false
	self.DEFAULT_ICON = LTConfig.PopupConfig.AreaFiveDefaultIcon
	self.isNonMobileAdaptive = gCS.LuaUtils.IsNonMobileAdaptive()
	self.taskHeightSpace = 0
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnDestroy()
	self:ClearMessageEvents()

	self.moveCurve = nil
	self.moveCurveLength = 0
end

function M:OnShow(panelId, data)
	self.bindData.popupList.poolMode = SGUI.EPoolMode.Default

	if not self.isNonMobileAdaptive then
		self.bindData.popupList.rectTransform:SetAnchoredPositionY(-LTConfig.PopupConfig.AreaFiveYOffsetMobile)
	end
end

function M:OnClose()
	self:BreakPopup()
end

function M:OnUpdate()
	self:UpdateListCountDown()
	self:UpdateWaiting()
	self:UpdateMove()
	self:UpdateNext()
	self:CheckUpdateDisable()
end

function M:UpdateListCountDown()
	if not self.needUpdateList then
		return
	end

	for i = #self.popupList, 1, -1 do
		local info = self.popupList[i]
		info.countDown = info.countDown - Time.deltaTime

		if info.stage == self.LIST_ITEM_STAGE.SHOW then
			if info.countDown <= 0 then
				self:SetListItemStage(info, self.LIST_ITEM_STAGE.CLOSE)
			end
		elseif info.stage == self.LIST_ITEM_STAGE.CLOSE and info.countDown <= 0 and i == #self.popupList then
			self:RemovePopup(i)

			self.needCheckSpace = true
		end
	end
end

function M:UpdateWaiting()
	if not self.needUpdateWaiting then
		return
	end

	if self.waitStage == self.WAIT_STAGE.WAIT_SPACE then
		self.waitingFrame = self.waitingFrame - 1

		if self.waitingFrame <= 0 then
			self:RefreshSpaceInfo(self.waitingInfo)
			self:SwitchWaitingStage(self.WAIT_STAGE.WAIT_ENOUGH)
		end
	elseif self.waitStage == self.WAIT_STAGE.WAIT_ENOUGH then
		if self.needUpdateMove then
			return
		end

		if self.needCheckSpace then
			self.needCheckSpace = false
			local spaceEnough = false

			if #self.popupList == 0 then
				spaceEnough = true
			else
				local space = 0

				for i = 1, #self.popupList do
					space = space + self.popupList[i].space
				end

				space = self:MaxSpace() - space
				spaceEnough = self.waitingInfo.space <= space
			end

			if spaceEnough then
				self:AddPopup(self.waitingInfo)
				self:ClearWaiting()
			end
		end
	end
end

function M:UpdateMove()
	if not self.needUpdateMove then
		return
	end

	self.moveCountDown = self.moveCountDown - Time.deltaTime

	if self.moveCountDown <= 0 then
		self:SetMoveProgress(1)
		self:ClearMove()
	else
		self:SetMoveProgress((self.moveTime - self.moveCountDown) / self.moveTime)
	end
end

function M:UpdateNext()
	if not self.needUpdateNext or self.needUpdateWaiting then
		return
	end

	self.nextTime = self.nextTime - Time.deltaTime

	if self.needUpdateMove then
		return
	end

	if self.nextTime <= 0 then
		self:TriggerNext()
	end
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.MOBILE_ADAPTIVE_MODE_CHANGE] = self:CreateAction("OnMobileAdaptiveModeChange"),
		[gEventConstants.TASK_GUIDE_HEIGHT_CHANGE] = self:CreateAction("OnTaskGuideHeightChange")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:RegisterWidget()
	self.bindData.popupList.luaRenderItem = self:CreateAction("OnRenderPopupListItem")
	self.bindData.popupList.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.layoutSetCb = self:CreateAction("OnLayoutSet")
end

function M:OnRenderPopupListItem(btn, index, data)
	if self.DEBUG then
		print_notice("AREA 5 => OnRenderPopupListItem index=", index, "uuId=", self.waitingInfo.uuId)
	end

	btn:SetWidgetFaraway(true)
	gCS.LuaUtils.AdjustLayout(btn)

	local store = self:GetStoreByWidget(btn)
	local info = self.waitingInfo
	info.store = store

	if gPopupAreaFiveDataRefresh[info.cfg.DataRefresh] then
		if info.type == 4 or info.type == 5 then
			info.store.list.luaLayoutSet = self.layoutSetCb
		else
			self:SwitchWaitingStage(self.WAIT_STAGE.WAIT_SPACE)
		end

		gPopupAreaFiveDataRefresh:DoCommonRefresh(store, info.data, info)

		local ok, err = xpcall(gPopupAreaFiveDataRefresh[info.cfg.DataRefresh], tolua.traceback, gPopupAreaFiveDataRefresh, store, info.data, info)

		if not ok then
			self:OnLayoutSet()
			print_error(err)
		end
	else
		self:SwitchWaitingStage(self.WAIT_STAGE.WAIT_SPACE)
	end
end

function M:OnLayoutSet()
	if not self.needUpdateWaiting then
		return
	end

	self:SwitchWaitingStage(self.WAIT_STAGE.WAIT_SPACE)
end

function M:OnGetTIndex(index)
	if self.DEBUG then
		print_notice("AREA 5 => OnGetTIndex index=", index, "uuId=", self.waitingInfo.uuId)
	end

	return self.waitingInfo.type
end

function M:PushPopup(info)
	if self.needUpdateWaiting then
		print_error("waiting期间不允许插入5区域的新弹窗")

		return
	end

	if self.DEBUG then
		print_notice("AREA 5 => PushPopup uuId=", info.uuId, info.cfg.Id, info.nextArea, info.waitNum)
	end

	self:PreprocessInfo(info)
	self:SetWaiting(info)
	self:SetNext(info)
	self.bindData.popupList:InsertElement(0)
	self:CheckUpdateEnable()
end

function M:BreakPopup(uuId)
	if not self.STATE_OnShowOnce then
		return
	end

	local back = self.needUpdateWaiting and self.waitingInfo.uuId == uuId

	self:ClearList()
	self:ClearWaiting()
	self:ClearMove()
	self:ClearNext()
	self:CheckUpdateDisable()

	return back
end

function M:PreprocessInfo(info)
	if info.waitNum > 3 then
		info.showTime = info.cfg.ShowTimeFast
	else
		info.showTime = info.cfg.ShowTimeNormal
	end

	info.closeTime = 0.1
	info.countDown = 0
	info.type = info.cfg.TemplateIndex
end

function M:ClearList()
	self.bindData.popupList:SetList(0)
	table.clear(self.popupList)

	self.needUpdateList = false
end

function M:AddPopup(info)
	if self.DEBUG then
		print_notice("AREA 5 => AddPopup uuId=", info.uuId)
	end

	self.needUpdateList = true

	table.insert(self.popupList, 1, info)
	self:PrepareItemForShow(info.store)
	self:SetListItemStage(info, self.LIST_ITEM_STAGE.SHOW)

	if #self.popupList > 1 then
		self:SetMove(info.space)
	end
end

function M:RemovePopup(index)
	if self.DEBUG then
		print_notice("AREA 5 => RemovePopup index=", index, "uuId=", self.popupList[index].uuId)
	end

	table.remove(self.popupList, index)

	local removeIndex = self.needUpdateWaiting and index or index - 1

	self.bindData.popupList:RemoveElement(removeIndex)

	self.needUpdateList = #self.popupList > 0

	if not self.needUpdateList then
		self:ClearMove()
	end
end

function M:SetListItemStage(info, stage)
	info.stage = stage

	if stage == self.LIST_ITEM_STAGE.SHOW then
		info.countDown = info.showTime

		self:PlayItemShowAnime(info)
	elseif stage == self.LIST_ITEM_STAGE.CLOSE then
		info.countDown = info.closeTime

		self:PlayItemCloseAnime(info)
	end
end

function M:PrepareItemForShow(store)
	store.bindWidget:SetWidgetFaraway(false)

	store.bindWidget.rectTransform.anchoredPosition = self.moveInitPos
end

function M:PlayItemShowAnime(info)
	info.store.animeBtn:InvokeCallback(EInvokeTime.User1)
end

function M:PlayItemCloseAnime(info)
	info.store.animeBtn:InvokeCallback(EInvokeTime.User2)
end

function M:SetWaiting(info)
	if self.DEBUG then
		print_notice("AREA 5 => SetWaiting", info.uuId)
	end

	self.needUpdateWaiting = true
	self.waitingInfo = info

	self:SwitchWaitingStage(self.WAIT_STAGE.WAIT_RENDER)
end

function M:ClearWaiting()
	if self.DEBUG then
		print_notice("AREA 5 => ClearWaiting", self.currId)
	end

	self.needUpdateWaiting = false
	self.waitingInfo = nil
end

function M:SwitchWaitingStage(stage)
	if self.DEBUG then
		print_notice("AREA 5 => SwitchWaitingStage stage=", stage, self.currId)
	end

	self.waitStage = stage

	if stage == self.WAIT_STAGE.WAIT_SPACE then
		self.waitingFrame = 2
	elseif stage == self.WAIT_STAGE.WAIT_ENOUGH then
		self.needCheckSpace = true
	end
end

function M:RefreshSpaceInfo(info)
	info.space = info.store.bindWidget:GetTargetHeight()

	if self.DEBUG then
		print_notice("AREA 5 => RefreshSpaceInfo uuId=", info.uuId, "space=", info.space)
	end
end

function M:SetNext(info)
	self.needUpdateNext = true
	self.currId = info.uuId
	self.nextTime = PopupConfig.AreaFiveNextInterval

	if self.DEBUG then
		print_notice("AREA 5 => SetNext uuId=", info.uuId, "nextTime=", self.nextTime)
	end
end

function M:ClearNext()
	if self.DEBUG then
		print_notice("AREA 5 => ClearNext", self.currId)
	end

	self.needUpdateNext = false
	self.currId = -1
	self.nextTime = 0
end

function M:TriggerNext()
	local uuId = self.currId

	self:ClearNext()
	gMessageManager:SendMessage(gEventConstants.POPUP_AREA_FIVE_FINISH, uuId)
end

function M:SetMove(length)
	if self.DEBUG then
		print_notice("AREA 5 => SetMove length=", length)
	end

	self.needUpdateMove = true
	self.moveLength = length
	self.moveCountDown = self.moveTime

	self:RecordListPosY()
end

function M:ClearMove()
	if self.DEBUG then
		print_notice("AREA 5 => ClearMove", self.currId)
	end

	self.needUpdateMove = false
end

function M:SetMoveProgress(progress)
	progress = Mathf.Clamp(progress, 0, 1)
	progress = self.moveLength * progress

	for i = 2, #self.popupList do
		local info = self.popupList[i]

		info.store.bindWidget.rectTransform:SetAnchoredPositionY(self.isNonMobileAdaptive and info.recordY + progress or info.recordY - progress)
	end
end

function M:RecordListPosY()
	for i = 2, #self.popupList do
		local info = self.popupList[i]
		info.recordY = info.store.bindWidget.rectTransform.anchoredPosition.y
	end
end

function M:MaxSpace()
	return self.isNonMobileAdaptive and PopupConfig.AreaFiveSpacePC or PopupConfig.AreaFiveSpaceMobile - self.taskHeightSpace
end

function M:CheckUpdateEnable()
	gStoreManager:RegisterDynamicOnUpdate(self)
end

function M:CheckUpdateDisable()
	if self.needUpdateList or self.needUpdateWaiting or self.needUpdateMove or self.needUpdateNext then
		return
	end

	gStoreManager:UnregisterDynamicOnUpdate(self)
end

function M:OnMobileAdaptiveModeChange(eventId, mode)
	self.isNonMobileAdaptive = not mode
end

function M:OnTaskGuideHeightChange(eventId, height)
	if self.STATE_OnShowOnce and not self.isNonMobileAdaptive then
		self.bindData.popupList.rectTransform:SetAnchoredPositionY(-LTConfig.PopupConfig.AreaFiveYOffsetMobile - height)
	end
end
