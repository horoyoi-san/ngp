-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BackCircleOnlineSignalStore.lua
-- Decompiled from: 01924_BackCircleOnlineSignalStore.lua_d17e82f055e0.luajit

C_BackCircleOnlineSignalStore = DefClass("C_BackCircleOnlineSignalStore", C_BackCircleOnlineSignalStore, C_BackCircleBase)
GroupName2Class.BackCircleOnlineSignalStore = C_BackCircleOnlineSignalStore
local M = C_BackCircleOnlineSignalStore
local LinkConfig = LTConfig.LinkConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.SELECT_MODE = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.circleOpen = false
	self.storeReady = false
	self.signalReady = false
	self.signalSwitchAnimeDown = "S_vx_CircleWeaponPanel_cut_d"
	self.signalSwitchAnimeUp = "S_vx_CircleWeaponPanel_cut_u"
	self.MaxVectorLength = 80000
	self.touchSafeAreaRadius = LinkConfig.ShortChatWheelSafeAreaRadius
	self.touchSafeAreaRadiusSqr = self.touchSafeAreaRadius^2
	self.touchDragMoveVector = Vector2.New(0, 0)
	self.isTouchDragInput = false
	self.gamepadMode = false
	self.signalItemMap = {}
	self.signalTabList = {}
	self.signalItemStore = {}
	self.MAX_SLOT_COUNT = 8
	self.selectIndex = 0
end

M.DefineInitVector = function(self)
	self.InitVector = Vector2.New(-math.cos(math.pi / 4), math.sin(math.pi / 4))
	self.EachAngle = 45
	self.baseRotation = 90
end

M.DefineAllEnumsAutoGen = function(self)
	self.signalStartSelectEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.ShowSignalDetailCtrlEnum = {
		["c\\xa1\\x97\\xbc\\xb3"] = 2,
		["8M\\x97\\x9b\\x8fU"] = 0,
		["/A\\x96\\x80\\x82M"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.signalStartSelectEnum = nil
	self.ShowSignalDetailCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.circleOpen = false
	self.signalReady = false
end

M.OnGroupEnable = function(self)
	self.targetPageIndex = 1

	table.clear(self.signalItemStore)
	table.insert(self.signalItemStore, gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(self.bindData.signalItem1))
	table.insert(self.signalItemStore, gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(self.bindData.signalItem2))
	table.insert(self.signalItemStore, gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(self.bindData.signalItem3))
	table.insert(self.signalItemStore, gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(self.bindData.signalItem4))
	table.insert(self.signalItemStore, gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(self.bindData.signalItem5))
	table.insert(self.signalItemStore, gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(self.bindData.signalItem6))
	table.insert(self.signalItemStore, gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(self.bindData.signalItem7))
	table.insert(self.signalItemStore, gStoreManager:GetStoreGroup("OnlineSignalItemStore"):GetStoreByWidget(self.bindData.signalItem8))

	self.storeReady = true
end

M.OnCircleOpen = function(self, data)
	self.circleOpen = true
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.hasReceivedStickInput = false
	self.isTouchDragInput = false
	self.touchDragMoveVector.x = 0
	self.touchDragMoveVector.y = 0

	self:RebuildCircleView()
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.signalTabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSignalTabListItem")
	self.bindData.signalTabList.luaSelectedChanged = self.CreateAction(self, "OnSwitchSignalPage")
	self.bindData.signalCloseBtnPC.luaClick = self.CreateAction(self, "CloseCircleNoEvent")
	self.bindData.signalCloseBtnPad.luaClick = self.CreateAction(self, "CloseCircleNoEvent")
	self.bindData.signalConfirmBtnPC.luaClick = self.CreateAction(self, "CloseCircle")
	self.bindData.signalConfirmBtnPad.luaClick = self.CreateAction(self, "CloseCircle")
	self.bindData.mouseScrollRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMouseScroll")
	self.bindData.signalMouseMoveRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMouseMove")
	self.bindData.signalRightStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnStickMove")
	self.bindData.switchBtnPad.luaClick = self.CreateAction(self, "SwitchSignalTypeLoop")
end

M.DoUpdate = function(self)
	self.UpdateArrowSelect(self)
end

M.GetArrowSelect = function(self, moveVector)
	if self.gamepadMode then
		local angle = self.CalculateAngle(self, self.InitVector, moveVector)

		if angle >= 0 then
			angle = angle + 360
		end

		local index = math.floor(angle / self.EachAngle) + 1

		return index, angle + self.baseRotation
	elseif not self.IsInTouchSafeArea(self) then
		local angle = self.CalculateAngle(self, self.InitVector, moveVector)

		if angle >= 0 then
			angle = angle + 360
		end

		local index = math.floor(angle / self.EachAngle) + 1

		return index, angle + self.baseRotation
	else
		return 0, nil
	end
end

M.IsInTouchSafeArea = function(self)
	return self.isTouchDragInput and self.touchDragMoveVector.sqrMagnitude > self.touchSafeAreaRadiusSqr
end

M.OnDragMoveStart = function(self, eventPointer)
	self.isDragMove = true
	self.isTouchDragInput = true

	if not self.touchDragMoveVector then
		self.touchDragMoveVector = Vector2.New(0, 0)
	end

	self.touchDragMoveVector.x = 0
	self.touchDragMoveVector.y = 0
end

M.OnDragMove = function(self, eventPointer)
	if not self.STATE_EnableOnce then
		return
	end

	self.touchDragMoveVector:Add(eventPointer.delta)
	self.accumulateMoveVector:Add(eventPointer.delta * 5)
	self:SetVectorLength(self.accumulateMoveVector, self.MaxVectorLength)

	if self.MinVectorLength < self.accumulateMoveVector.sqrMagnitude then
		self.SetSmoothMove(self, self.accumulateMoveVector)
	else
		self.ClearSmoothMove(self)
	end

	if self.IsInTouchSafeArea(self) then
		self.bindData.signalStartSelect = self.SELECT_MODE.FALSE

		self.SetSignalSelect(self, 0)
	end
end

M.UpdateArrowSelect = function(self)
	if self.updateSelect then
		self.UpdateSmoothMoveVector(self)

		local index, angle = self.GetArrowSelect(self, self.moveVector)

		if angle then
			self.bindData.signalStartSelect = self.SELECT_MODE.TRUE

			self.SetSignalSelect(self, index)

			self.bindData.signalArrowAngle = -angle
		else
			self.bindData.signalStartSelect = self.SELECT_MODE.FALSE

			self.SetSignalSelect(self, 0)
		end
	end
end

M.OnSimpleRenderSignalTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local item = self.signalTabList[index + 1]

	if item and store then
		store.text = item
	end
end

M.OnSwitchSignalPage = function(self)
	local index = self.bindData.signalTabList.selectedIndex + 1
	local up = index <= self.targetPageIndex
	self.targetPageIndex = index

	self:RebuildCircleView()
	self:PlaySwitchAnime(up)
end

M.PlaySwitchAnime = function(self, up)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, up and self.signalSwitchAnimeUp or self.signalSwitchAnimeDown)
end

M.OnCircleClose = function(self)
	self.circleOpen = false
	self.signalReady = false

	table.clear(self.signalItemMap)
	table.clear(self.signalTabList)
end

M.CloseTrigger = function(self)
	self.UseCurChatWheelItem(self)
end

M.OnSignalMouseMoveRespondInputChanged = function(self, context)
	local mousePos = context.ReadValueVector2(context)
	local screenCenter = Vector2.New(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2)
	local radian = math.atan2(mousePos.x - screenCenter.x, mousePos.y - screenCenter.y)
	local radianDefault = math.atan2(-1, -1)
	local delta = (radian - radianDefault) % (2 * math.pi)

	if delta >= 0 then
		delta = delta + 2 * math.pi
	end

	local angle = math.deg(delta)
	self.bindData.signalArrowAngle = -angle
end

M.OnStickMove = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.performed then
		if not self.hasReceivedStickInput then
			self.hasReceivedStickInput = true
		end

		self.UpdateSmoothMoveVector(self)
		self.SetSmoothMove(self, value)
	elseif context.canceled then
		self.ClearSmoothMove(self)
	end
end

M.OnMouseScroll = function(self, context)
	if context.performed then
		local zoom = context.ReadValueVector2(context).y

		if zoom <= 0 then
			self.ScrollSignalType(self, true)
		elseif zoom >= 0 then
			self.ScrollSignalType(self, false)
		end
	end
end

M.ScrollSignalType = function(self, up)
	if up then
		if self.targetPageIndex < 1 then
			return
		end

		self.targetPageIndex = self.targetPageIndex - 1

		self.RebuildCircleView(self)
		self.PlaySwitchAnime(self, true)
	else
		if self.targetPageIndex > #self.signalTabList then
			return
		end

		self.targetPageIndex = self.targetPageIndex + 1

		self.RebuildCircleView(self)
		self.PlaySwitchAnime(self, false)
	end

	self.bindData.signalTabList:SelectItem(self.targetPageIndex - 1, false)
end

M.SwitchSignalTypeLoop = function(self)
	local to = self.targetPageIndex + 1

	if to <= #self.signalTabList then
		to = 1
	end

	local up = to <= self.targetPageIndex
	self.targetPageIndex = to

	self:RebuildCircleView()
	self:PlaySwitchAnime(up)
end

M.RebuildCircleView = function(self)
	if not self.storeReady or not self.circleOpen then
		return
	end

	self:RefreshSignalCircle()
	self:RebuildSignalPageView()
	self:RebuildSignalCircleView()
	self:ResetMousePosition()
	self:SetSignalSelect(0, true)

	self.bindData.signalStartSelect = self.SELECT_MODE.FALSE

	self.bindData.signalTabList:SelectItem(self.targetPageIndex - 1, false)

	if self.selectIndex ~= 0 then
		self.moveVector.x = 0
		self.moveVector.y = 1
		self.accumulateMoveVector.x = 0
		self.accumulateMoveVector.y = 0
	else
		local angle = self.EachAngle * (self.selectIndex + 0.5)
		self.moveVector.x = -math.sin(angle / 180 * math.pi)
		self.moveVector.y = -math.cos(angle / 180 * math.pi)
		self.accumulateMoveVector.x = 0
		self.accumulateMoveVector.y = 0
	end

	self.ClearSmoothMove(self)
end

M.GetWheelItemInfo = function(self, cfg)
	local res = {
		name = cfg and cfg.ShortName,
		icon = cfg and cfg.Icon
	}

	if cfg then
		if cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Motion then
			local actionCfg = LTConfig.ActionItemConfig.GetConfig(cfg.ActionItemId)

			if actionCfg then
				res = {
					name = actionCfg and actionCfg.Name,
					unlockDesc = actionCfg and actionCfg.Desc,
					icon = actionCfg and actionCfg.Icon
				}
			end
		elseif (cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Voice or cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Mark) and cfg.FightSpiritGroup and cfg.DialogVoiceGroup then
			local spiritId = gSpiritManager:GetCurFirstSpiritTid()

			for i = 1, #cfg.FightSpiritGroup do
				if spiritId ~= cfg.FightSpiritGroup[i] and cfg.DialogVoiceGroup[i] then
					local dialogVoiceCfg = LTConfig.DialogVoiceConfig.GetConfig(cfg.DialogVoiceGroup[i])

					if dialogVoiceCfg and dialogVoiceCfg.Message then
						res.desc = dialogVoiceCfg.Message
					end

					break
				end
			end
		end
	end

	return res
end

M.RefreshSignalCircle = function(self)
	if self.signalReady then
		return
	end

	table.clear(self.signalItemMap)

	local hudStore = gStoreManager:GetStoreGroup("OnlineControlsStore")

	if hudStore then
		local shortChatWheels = gLinkManager:GetCurShortChatWheelItems()

		for i = 1, 2 * self.MAX_SLOT_COUNT do
			local id = shortChatWheels[i] and shortChatWheels[i].Id or 0
			local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(id)

			if cfg then
				local itemInfo = self.GetWheelItemInfo(self, cfg)
				local item = {
					id = id,
					shortName = itemInfo.name,
					icon = itemInfo.icon,
					type = cfg.Type,
					desc = itemInfo.desc
				}

				table.insert(self.signalItemMap, item)
			else
				table.insert(self.signalItemMap, {})
			end
		end
	end

	table.clear(self.signalTabList)

	for i = 1, 2 do
		table.insert(self.signalTabList, i)
	end

	self.signalReady = true
end

M.RebuildSignalCircleView = function(self)
	local startIndex = (self.targetPageIndex - 1) * self.MAX_SLOT_COUNT

	for i = 1, self.MAX_SLOT_COUNT do
		local item = self.signalItemMap[i + startIndex]

		self.OnRenderSignalCircleItem(self, i, item)
	end
end

M.OnRenderSignalCircleItem = function(self, index, item)
	local store = self.signalItemStore[index]

	if next(item) then
		store.iconId = item.icon
		store.QualityCtrl = 0
		store.UsingCtrl = self.SELECT_MODE.FALSE
		store.IsEmptyCtrl = self.SELECT_MODE.FALSE

		if item.type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Motion then
			local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(item.id)

			if cfg and not gCharMotionUtils.IsActionMatchCurSpirit(cfg.ActionItemId) then
				store.stateCtrl = 1
			else
				store.stateCtrl = 0
			end
		else
			store.stateCtrl = 0
		end
	else
		store.IsEmptyCtrl = self.SELECT_MODE.TRUE
		store.QualityCtrl = 0
		store.guideID = ""
		store.stateCtrl = 0
	end
end

M.RebuildSignalPageView = function(self)
	self.bindData.signalTabList:SetSimpleList(#self.signalTabList)
end

M.SetSignalSelect = function(self, index, force)
	if self.selectIndex == index or force then
		if self.selectIndex <= 0 then
			self.signalItemStore[self.selectIndex].SelectingActiveCtrl = self.SELECT_MODE.FALSE
		end

		self.selectIndex = index

		if self.selectIndex <= 0 then
			self.signalItemStore[self.selectIndex].SelectingActiveCtrl = self.SELECT_MODE.TRUE
			local dataIndex = self.selectIndex + (self.targetPageIndex - 1) * self.MAX_SLOT_COUNT

			self.SetSignalDetailInfo(self, dataIndex)
		else
			self.SetSignalDetailInfo(self, 0)
		end
	end
end

M.SetSignalDetailInfo = function(self, index)
	local item = self.signalItemMap[index]

	if item and next(item) then
		self.bindData.ShowSignalDetailCtrl = 1
		self.bindData.signalName = item.shortName or ""
		self.bindData.signalDesc = item.desc or ""
		self.bindData.signalType = LTConfig.LinkShortChatTypeConfig.GetConfig(item.type).Title or ""
	else
		self.bindData.ShowSignalDetailCtrl = self.SELECT_MODE.FALSE
	end
end

M.ResetMousePosition = function(self)
	if gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		local initScreenPos = Vector2.New(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2)

		LX6.Manager.GameInputManager.SetCursorPositionInPC(initScreenPos.x, initScreenPos.y)
	end
end

M.TryConsumeShortChatCD = function(self)
	local canSend, remainingTime = gLinkManager:CheckAndConsumeShortChatCD()

	if not canSend then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SendShortChatTooFast, nil, , remainingTime)
	end

	return canSend
end

M.UseCurChatWheelItem = function(self)
	if self.selectIndex == 0 then
		local startIndex = (self.targetPageIndex - 1) * self.MAX_SLOT_COUNT
		local id = self.signalItemMap[self.selectIndex + startIndex].id
		local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(id)

		if cfg then
			local type = cfg.Type

			if type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Mark then
				gMapSubSystem_ChatMark:SetMyPin()
			elseif type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Voice then
				if not self.TryConsumeShortChatCD(self) then
					return
				end

				slot5 = gClientToGameSceneDelegate

				slot5:SendShortChat(id).Callback = function (err)
					if err == LTConfig.MessageConfig.Ok then
						print_notice("@xq# SendShortChat error number:", err)

						return
					end

					gMapSubSystem_ChatMark:SendChatMsg(id)
				end
			elseif type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Expression then
				if not self.TryConsumeShortChatCD(self) then
					return
				end

				slot5 = gClientToGameSceneDelegate

				slot5:SendShortChat(id).Callback = function (err)
					if err == LTConfig.MessageConfig.Ok then
						return
					end
				end
			elseif type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Motion then
				if not gCharMotionUtils.IsActionMatchCurSpirit(cfg.ActionItemId) then
					gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.CurrentSpiritNotAvailableTips)

					return
				end

				if not self.TryConsumeShortChatCD(self) then
					return
				end

				local actionCfg = LTConfig.ActionItemConfig.GetConfig(cfg.ActionItemId)

				if actionCfg then
					gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, actionCfg.GameplayEvent)
				end
			end
		end
	end
end
