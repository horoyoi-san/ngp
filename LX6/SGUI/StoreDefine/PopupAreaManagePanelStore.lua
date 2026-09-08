-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PopupAreaManagePanelStore.lua
-- Decompiled from: 00797_PopupAreaManagePanelStore.lua_9c7febdeab75.luajit

local PopupConfig = LTConfig.PopupConfig
local EInvokeTime = SGUI.EInvokeTime
C_PopupAreaManagePanelStore = DefClass("C_PopupAreaManagePanelStore", C_PopupAreaManagePanelStore, C_StoreGroup)
GroupName2Class.PopupAreaManagePanelStore = C_PopupAreaManagePanelStore
local M = C_PopupAreaManagePanelStore

M.ctor = function(self)
	self.DEFINE_DynamicOnUpdate = true
end

M.DefineAllVariables = function(self)
	self.needUpdateList = false
	self.popupList = {}
	self.LIST_ITEM_STAGE = {
		["n\\x82\\x8d\\x9c\\x93"] = 1,
		["I\nRl"] = 0
	}
	self.needUpdateWaiting = false
	self.WAIT_STAGE = {
		["d{牻;\\x88%\\xea\\xcd"] = 1,
		["\\xa8\tG\\xb8o\\xf6\\x8d\\x91"] = 2,
		["\\xa8\tG\\xafd\\xf7\\x8f\\x8b"] = 0
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

	if customData.length >= 0 then
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
	self.taskGuideHeight = 0
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.moveCurve = nil
	self.moveCurveLength = 0
end

M.OnShow = function(self, panelId, data)
	self.bindData.popupList.poolMode = SGUI.EPoolMode.Default

	if not self.isNonMobileAdaptive then
		self.RefreshMobileLayout(self)
	end
end

M.OnClose = function(self)
	self.BreakPopup(self)
end

M.OnLanguageChange = function(self, lang)
end

M.OnUpdate = function(self)
	self.UpdateListCountDown(self)
	self.UpdateWaiting(self)
	self.UpdateMove(self)
	self.UpdateNext(self)
	self.CheckUpdateDisable(self)
end

M.UpdateListCountDown = function(self)
	if not self.needUpdateList then
		return
	end

	for i = #self.popupList, 1, -1 do
		local info = self.popupList[i]
		info.countDown = info.countDown - Time.deltaTime

		if info.stage ~= self.LIST_ITEM_STAGE.SHOW then
			if info.countDown < 0 then
				self.SetListItemStage(self, info, self.LIST_ITEM_STAGE.CLOSE)
			end
		elseif info.stage ~= self.LIST_ITEM_STAGE.CLOSE and info.countDown < 0 and i ~= #self.popupList then
			self.RemovePopup(self, i)

			self.needCheckSpace = true
		end
	end
end

M.UpdateWaiting = function(self)
	if not self.needUpdateWaiting then
		return
	end

	if self.waitStage ~= self.WAIT_STAGE.WAIT_SPACE then
		self.waitingFrame = self.waitingFrame - 1

		if self.waitingFrame < 0 then
			self.RefreshSpaceInfo(self, self.waitingInfo)
			self.SwitchWaitingStage(self, self.WAIT_STAGE.WAIT_ENOUGH)
		end
	elseif self.waitStage ~= self.WAIT_STAGE.WAIT_ENOUGH then
		if self.needUpdateMove then
			return
		end

		if self.needCheckSpace then
			self.needCheckSpace = false
			local spaceEnough = false

			if #self.popupList ~= 0 then
				spaceEnough = true
			else
				local space = 0

				for i = 1, #self.popupList do
					space = space + self.popupList[i].space
				end

				space = self.MaxSpace(self) - space
				spaceEnough = self.waitingInfo.space > space
			end

			if spaceEnough then
				self.AddPopup(self, self.waitingInfo)
				self.ClearWaiting(self)
			end
		end
	end
end

M.UpdateMove = function(self)
	if not self.needUpdateMove then
		return
	end

	self.moveCountDown = self.moveCountDown - Time.deltaTime

	if self.moveCountDown < 0 then
		self.SetMoveProgress(self, 1)
		self.ClearMove(self)
	else
		self.SetMoveProgress(self, (self.moveTime - self.moveCountDown) / self.moveTime)
	end
end

M.UpdateNext = function(self)
	if not self.needUpdateNext or self.needUpdateWaiting then
		return
	end

	self.nextTime = self.nextTime - Time.deltaTime

	if self.needUpdateMove then
		return
	end

	if self.nextTime < 0 then
		self.TriggerNext(self)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.MOBILE_ADAPTIVE_MODE_CHANGE] = self.CreateAction(self, "OnMobileAdaptiveModeChange"),
		[gEventConstants.TASK_GUIDE_HEIGHT_CHANGE] = self.CreateAction(self, "OnTaskGuideHeightChange"),
		[gEventConstants.ON_MINIMAP_VISIBILITY_CHANGE] = self.CreateAction(self, "OnMinimapVisibleChange")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.RegisterWidget = function(self)
	self.bindData.popupList.luaRenderItem = self.CreateAction(self, "OnRenderPopupListItem")
	self.bindData.popupList.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
	self.layoutSetCb = self.CreateAction(self, "OnLayoutSet")
end

M.OnRenderPopupListItem = function(self, btn, index, data)
	if self.DEBUG then
		print_notice("AREA 5 => OnRenderPopupListItem index=", index, "uuId=", self.waitingInfo.uuId)
	end

	btn.SetWidgetFaraway(btn, true)
	gCS.LuaUtils.AdjustLayout(btn)

	local info = self.waitingInfo
	local store = self.GetStoreByWidget(self, btn)

	if not info then
		print_warn("AREA 5 => OnRenderPopupListItem self.waitingInfo is nil", self.waitStage, self.needUpdateWaiting, self.needUpdateList, self.needUpdateMove, self.needUpdateNext)

		return
	end

	info.store = store

	if gPopupAreaFiveDataRefresh[info.cfg.DataRefresh] then
		if info.type ~= 4 or info.type ~= 5 then
			info.store.list.luaLayoutSet = self.layoutSetCb
		else
			self.SwitchWaitingStage(self, self.WAIT_STAGE.WAIT_SPACE)
		end

		gPopupAreaFiveDataRefresh:DoCommonRefresh(store, info.data, info)

		local ok, err = xpcall(gPopupAreaFiveDataRefresh[info.cfg.DataRefresh], tolua.traceback, gPopupAreaFiveDataRefresh, store, info.data, info)

		if not ok then
			self.OnLayoutSet(self)
			print_error(err)
		end
	else
		self.SwitchWaitingStage(self, self.WAIT_STAGE.WAIT_SPACE)
	end
end

M.OnLayoutSet = function(self)
	if not self.needUpdateWaiting then
		return
	end

	self.SwitchWaitingStage(self, self.WAIT_STAGE.WAIT_SPACE)
end

M.OnGetTIndex = function(self, index)
	if self.DEBUG then
		print_notice("AREA 5 => OnGetTIndex index=", index, "uuId=", self.waitingInfo.uuId)
	end

	return self.waitingInfo.type
end

M.PushPopup = function(self, info)
	if not self.STATE_OnShowOnce then
		return
	end

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

M.BreakPopup = function(self, uuId)
	if not self.STATE_OnShowOnce then
		return
	end

	local back = self.needUpdateWaiting and self.waitingInfo.uuId ~= uuId

	self:ClearList()
	self:ClearWaiting()
	self:ClearMove()
	self:ClearNext()
	self:CheckUpdateDisable()

	return back
end

M.PreprocessInfo = function(self, info)
	if info.waitNum <= 3 then
		info.showTime = info.cfg.ShowTimeFast
	else
		info.showTime = info.cfg.ShowTimeNormal
	end

	info.closeTime = 0.1
	info.countDown = 0
	info.type = info.cfg.TemplateIndex
end

M.ClearList = function(self)
	self.bindData.popupList:SetList(0)
	table.clear(self.popupList)

	self.needUpdateList = false
end

M.AddPopup = function(self, info)
	if self.DEBUG then
		print_notice("AREA 5 => AddPopup uuId=", info.uuId)
	end

	self.needUpdateList = true

	table.insert(self.popupList, 1, info)
	self.PrepareItemForShow(self, info.store)
	self.SetListItemStage(self, info, self.LIST_ITEM_STAGE.SHOW)

	if #self.popupList <= 1 then
		self.SetMove(self, info.space)
	end
end

M.RemovePopup = function(self, index)
	if self.DEBUG then
		print_notice("AREA 5 => RemovePopup index=", index, "uuId=", self.popupList[index].uuId)
	end

	table.remove(self.popupList, index)

	local removeIndex = self.needUpdateWaiting and index or index - 1

	self.bindData.popupList:RemoveElement(removeIndex)

	self.needUpdateList = #self.popupList >= 0

	if not self.needUpdateList then
		self.ClearMove(self)
	end
end

M.SetListItemStage = function(self, info, stage)
	info.stage = stage

	if stage ~= self.LIST_ITEM_STAGE.SHOW then
		info.countDown = info.showTime

		self.PlayItemShowAnime(self, info)
	elseif stage ~= self.LIST_ITEM_STAGE.CLOSE then
		info.countDown = info.closeTime

		self.PlayItemCloseAnime(self, info)
	end
end

M.PrepareItemForShow = function(self, store)
	store.bindWidget:SetWidgetFaraway(false)

	store.bindWidget.rectTransform.anchoredPosition = self.moveInitPos
end

M.PlayItemShowAnime = function(self, info)
	if info.cfg.Id ~= LTConfig.PopupConfig.MapDangerMessage then
		info.store.animeBtn:InvokeCallback(EInvokeTime.User3)
	else
		info.store.animeBtn:InvokeCallback(EInvokeTime.User1)
	end
end

M.PlayItemCloseAnime = function(self, info)
	info.store.animeBtn:InvokeCallback(EInvokeTime.User2)
end

M.SetWaiting = function(self, info)
	if self.DEBUG then
		print_notice("AREA 5 => SetWaiting", info.uuId)
	end

	self.needUpdateWaiting = true
	self.needCheckSpace = false
	self.waitingInfo = info

	self.SwitchWaitingStage(self, self.WAIT_STAGE.WAIT_RENDER)
end

M.ClearWaiting = function(self)
	if self.DEBUG then
		print_notice("AREA 5 => ClearWaiting", self.currId)
	end

	self.needUpdateWaiting = false
	self.waitingInfo = nil
end

M.SwitchWaitingStage = function(self, stage)
	if self.DEBUG then
		print_notice("AREA 5 => SwitchWaitingStage stage=", stage, self.currId)
	end

	self.waitStage = stage

	if stage ~= self.WAIT_STAGE.WAIT_SPACE then
		self.waitingFrame = 2
	elseif stage ~= self.WAIT_STAGE.WAIT_ENOUGH then
		self.needCheckSpace = true
	end
end

M.RefreshSpaceInfo = function(self, info)
	info.space = info.store.bindWidget:GetTargetHeight()

	if self.DEBUG then
		print_notice("AREA 5 => RefreshSpaceInfo uuId=", info.uuId, "space=", info.space)
	end
end

M.SetNext = function(self, info)
	self.needUpdateNext = true
	self.currId = info.uuId
	self.nextTime = PopupConfig.AreaFiveNextInterval

	if self.DEBUG then
		print_notice("AREA 5 => SetNext uuId=", info.uuId, "nextTime=", self.nextTime)
	end
end

M.ClearNext = function(self)
	if self.DEBUG then
		print_notice("AREA 5 => ClearNext", self.currId)
	end

	self.needUpdateNext = false
	self.currId = -1
	self.nextTime = 0
end

M.TriggerNext = function(self)
	local uuId = self.currId

	self:ClearNext()
	gMessageManager:SendMessage(gEventConstants.POPUP_AREA_FIVE_FINISH, uuId)
end

M.SetMove = function(self, length)
	if self.DEBUG then
		print_notice("AREA 5 => SetMove length=", length)
	end

	self.needUpdateMove = true
	self.moveLength = length
	self.moveCountDown = self.moveTime

	self.RecordListPosY(self)
end

M.ClearMove = function(self)
	if self.DEBUG then
		print_notice("AREA 5 => ClearMove", self.currId)
	end

	self.needUpdateMove = false
end

M.SetMoveProgress = function(self, progress)
	progress = Mathf.Clamp(progress, 0, 1)
	progress = self.moveLength * progress

	for i = 2, #self.popupList do
		local info = self.popupList[i]

		info.store.bindWidget.rectTransform:SetAnchoredPositionY(self.isNonMobileAdaptive and info.recordY + progress or info.recordY - progress)
	end
end

M.RecordListPosY = function(self)
	for i = 2, #self.popupList do
		local info = self.popupList[i]
		info.recordY = info.store.bindWidget.rectTransform.anchoredPosition.y
	end
end

M.MaxSpace = function(self)
	return self.isNonMobileAdaptive and PopupConfig.AreaFiveSpacePC or PopupConfig.AreaFiveSpaceMobile - self.taskHeightSpace
end

M.CheckUpdateEnable = function(self)
	gStoreManager:RegisterDynamicOnUpdate(self)
end

M.CheckUpdateDisable = function(self)
	if self.needUpdateList or self.needUpdateWaiting or self.needUpdateMove or self.needUpdateNext then
		return
	end

	gStoreManager:UnregisterDynamicOnUpdate(self)
end

M.OnMobileAdaptiveModeChange = function(self, eventId, mode)
	self.isNonMobileAdaptive = not mode
end

M.OnTaskGuideHeightChange = function(self, eventId, height)
	self.taskGuideHeight = height

	if self.STATE_OnShowOnce then
		self.RefreshMobileLayout(self)
	end
end

M.OnMinimapVisibleChange = function(self, eventId)
	if self.STATE_OnShowOnce then
		self.RefreshMobileLayout(self)
	end
end

M.RefreshMobileLayout = function(self)
	if self.isNonMobileAdaptive then
		return
	end

	local mapShow = gMapSystem.ui:IsMiniMapActive()
	local exitShow = gUIFunctionStateManager:GetExitEnable()[1]

	if exitShow and not mapShow then
		self.bindData.popupList.rectTransform:SetAnchoredPositionY(-LTConfig.PopupConfig.Mobile5PopUpPos02 - self.taskGuideHeight)
	elseif not exitShow and not mapShow then
		self.bindData.popupList.rectTransform:SetAnchoredPositionY(-LTConfig.PopupConfig.Mobile5PopUpPos03 - self.taskGuideHeight)
	else
		self.bindData.popupList.rectTransform:SetAnchoredPositionY(-LTConfig.PopupConfig.AreaFiveYOffsetMobile - self.taskGuideHeight)
	end
end
