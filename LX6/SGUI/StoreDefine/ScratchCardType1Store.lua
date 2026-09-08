-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ScratchCardType1Store.lua
-- Decompiled from: 00889_ScratchCardType1Store.lua_20c85fbec905.luajit

C_ScratchCardType1Store = DefClass("C_ScratchCardType1Store", C_ScratchCardType1Store, C_StoreGroup)
GroupName2Class.ScratchCardType1Store = C_ScratchCardType1Store
local M = C_ScratchCardType1Store

M.ctor = function(self)
	self.ScratchCardStartInwardSignal = 10001
	self.ScratchCardEndInwardSignal = 10002
	self.ScratchCardLiftFollowTime = 0.3
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")

	self.InitMessages(self)
end

M.InitMessages = function(self)
	self.RegisterMessageEvents(self, {
		[gEventConstants.ON_SCRATCH_CARD_GAMEPAD_DRAW_AT] = self.CreateAction(self, "OnGamePadDrawAt")
	})
end

M.ShowPanel = function(self, args)
	self.already = false
	self.isScratch = false
	self.lastScratchRevealSoundTime = nil
	self.revealedRewardIndexSet = {}
	self.playedTargetAniMap = {}
	self.scratchItemStoreByIndex = {}
	self.hasSentScratchStartSignal = false
	self.hasSentScratchEndSignal = false
	self.lastScratchHandSignal = nil
	self.scratchLiftFollowPosition = nil
	self.scratchLiftFollowEndTime = nil
	self.scratchLiftFollowSource = nil
	self.scratchInputSource = "mouse"
	self.lastGamePadScratchPosition = nil
	self.lastMouseScratchPosition = nil
	self.isScratchSoundActive = false
	self.lastScratchGamePadMode = nil

	self.InitModel(self, args)
	self.InitView(self)
end

M.InitModel = function(self, args)
	self.entity = args[3]
	self.gamePlayId = args.gamePlayId

	self.InitDataList(self, args)
end

M.GetShowCount = function(self)
	return 8
end

M.GetMaxReward = function(self)
	return LTConfig.PoiGameConfig.ScratchType1MaxReward
end

M.InitDataList = function(self, args)
	local result = args.scratchStartResult
	self.serverTotalReward = result.TotalReward
	self.dataList = {}

	for _, cell in ipairs(result.CellDataList) do
		table.insert(self.dataList, {
			id = cell.Id,
			multiple = cell.Multiple,
			baseScore = cell.BaseScore
		})
	end
end

M.InitView = function(self)
	self.bindData.list:SetSimpleList(#self.dataList)

	self.bindData.scratchCardMask.OnEndDragAction = self:CreateAction("OnEndDrag")
	self.bindData.scratchCardMask.OnPointerDownAction = self:CreateAction("OnPointerDown")
	self.bindData.scratchCardMask.OnPointerUpAction = self:CreateAction("OnPointerUp")
	self.bindData.scratchCardMask.RevealProgressChanged = self:CreateAction("OnRevealProgressChanged")
	self.bindData.scratchCardMask.ZoneRevealed = self:CreateAction("OnZoneRevealed")
	local scratchCardMaskSafeArea = self.bindData.scratchCardMaskSafeArea

	if scratchCardMaskSafeArea then
		scratchCardMaskSafeArea.OnEndDragAction = self.CreateAction(self, "OnEndDrag")
		scratchCardMaskSafeArea.OnPointerDownAction = self.CreateAction(self, "OnPointerDown")
		scratchCardMaskSafeArea.OnPointerUpAction = self.CreateAction(self, "OnPointerUp")
		scratchCardMaskSafeArea.RevealProgressChanged = self.CreateAction(self, "OnSafeAreaRevealProgressChanged")
	end
end

M.DrawScratchSafeAreaAt = function(self, position)
	local scratchCardMaskSafeArea = self.bindData.scratchCardMaskSafeArea

	if scratchCardMaskSafeArea and scratchCardMaskSafeArea == self.bindData.scratchCardMask then
		return scratchCardMaskSafeArea.DrawAtByLua(scratchCardMaskSafeArea, position)
	end

	return false
end

M.ResetScratchMaskDrawPosition = function(self)
	self.bindData.scratchCardMask:ResetDrawPosition()

	local scratchCardMaskSafeArea = self.bindData.scratchCardMaskSafeArea

	if scratchCardMaskSafeArea and scratchCardMaskSafeArea == self.bindData.scratchCardMask then
		scratchCardMaskSafeArea.ResetDrawPosition(scratchCardMaskSafeArea)
	end
end

M.TryShowResultView = function(self, scratchCardMask)
	if scratchCardMask and scratchCardMask.IsRevealed then
		self.ShowResultView(self)

		return true
	end

	return false
end

M.TryShowLoseView = function(self, scratchCardMask)
	if scratchCardMask and scratchCardMask.IsRevealed then
		self.ShowLoseView(self)

		return true
	end

	return false
end

M.OnGamePadDrawAt = function(self, _, arg)
	if not self.bindData.scratchCardMask or not self.bindData.controllerArea then
		return
	end

	local scaledPosition = self.GetGamePadScaledPosition(self, arg)

	if arg.isScratch ~= false then
		self.SetScratchSoundActive(self, false)

		self.lastGamePadScratchPosition = scaledPosition

		if self.scratchInputSource ~= "gamepad" and not gClientUtils.CheckIsGamePadMode() then
			self.SetScratchGameplayActive(self, false)
			self.SwitchScratchInputToMouse(self, scaledPosition)
		end

		return
	end

	self:SetScratchGameplayActive(true, "gamepad")

	self.lastGamePadScratchPosition = scaledPosition

	self:PlayPlayerAni(scaledPosition)

	local progressChanged = self.bindData.scratchCardMask:DrawAtByLua(scaledPosition)
	progressChanged = self:DrawScratchSafeAreaAt(scaledPosition) or progressChanged

	self:SetScratchSoundActive(progressChanged)

	if self:TryShowLoseView(self.bindData.scratchCardMaskSafeArea) then
		return
	end

	if self.TryShowResultView(self, self.bindData.scratchCardMask) then
		return
	end
end

M.GetControllerAreaScreenBounds = function(self)
	local rectTransform = self.bindData.controllerArea
	local position = rectTransform.position
	local sizeDelta = rectTransform.sizeDelta
	local pivot = rectTransform.pivot
	local rotation = rectTransform.rotation
	local scale = rectTransform.lossyScale
	local halfWidth = sizeDelta.x * 0.5
	local halfHeight = sizeDelta.y * 0.5
	local localCorners = {
		Vector3.New(-halfWidth, -halfHeight, 0),
		Vector3.New(-halfWidth, halfHeight, 0),
		Vector3.New(halfWidth, halfHeight, 0),
		Vector3.New(halfWidth, -halfHeight, 0)
	}

	for i, corner in ipairs(localCorners) do
		localCorners[i] = Vector3.New(corner.x + sizeDelta.x * (0.5 - pivot.x), corner.y + sizeDelta.y * (0.5 - pivot.y), corner.z)
	end

	local worldCorners = {}

	for _, corner in ipairs(localCorners) do
		table.insert(worldCorners, position + rotation * Vector3.Scale(corner, scale))
	end

	local mainCamera = gCS.CameraDataMgr.MainCamera
	local screenMin = Vector2.New(math.huge, math.huge)
	local screenMax = Vector2.New(-math.huge, -math.huge)

	for _, worldCorner in ipairs(worldCorners) do
		local screenPoint = mainCamera.WorldToScreenPoint(mainCamera, worldCorner)
		screenMin = Vector2.New(math.min(screenMin.x, screenPoint.x), math.min(screenMin.y, screenPoint.y))
		screenMax = Vector2.New(math.max(screenMax.x, screenPoint.x), math.max(screenMax.y, screenPoint.y))
	end

	return screenMin, screenMax
end

M.GetGamePadScaledPosition = function(self, arg)
	local screenMin, screenMax = self.GetControllerAreaScreenBounds(self)
	local screenWidth = UnityEngine.Screen.width
	local screenHeight = UnityEngine.Screen.height
	local normalizedX = arg.screenPos.x / screenWidth
	local normalizedY = arg.screenPos.y / screenHeight
	local scaledPosX = screenMin.x + normalizedX * (screenMax.x - screenMin.x)
	local scaledPosY = screenMin.y + normalizedY * (screenMax.y - screenMin.y)
	local scaledPosition = Vector2.New(scaledPosX, scaledPosY)

	return scaledPosition
end

M.GetGamePadOffsetByScreenPosition = function(self, position)
	local screenMin, screenMax = self.GetControllerAreaScreenBounds(self)
	local screenWidth = UnityEngine.Screen.width
	local screenHeight = UnityEngine.Screen.height
	local normalizedX = (position.x - screenMin.x) / (screenMax.x - screenMin.x)
	local normalizedY = (position.y - screenMin.y) / (screenMax.y - screenMin.y)

	return Vector2.New(normalizedX * screenWidth, normalizedY * screenHeight)
end

M.GetGamePadOffsetByLastMousePosition = function(self)
	local position = self.lastMouseScratchPosition or UnityEngine.Input.mousePosition

	return self:GetGamePadOffsetByScreenPosition(position)
end

M.SwitchScratchInputToMouse = function(self, position)
	local mousePosition = position or self.lastGamePadScratchPosition or self.lastMouseScratchPosition or UnityEngine.Input.mousePosition

	self:ResetScratchMaskDrawPosition()
	LX6.Manager.GameInputManager.SetCursorPositionInPC(mousePosition.x, mousePosition.y)

	self.lastMouseScratchPosition = mousePosition
	self.scratchInputSource = "mouse"

	return mousePosition
end

M.OnUpdate = function(self)
	local isGamePadMode = gClientUtils.CheckIsGamePadMode()

	if self.lastScratchGamePadMode == isGamePadMode then
		self.lastScratchGamePadMode = isGamePadMode
	end

	local mousePosition = UnityEngine.Input.mousePosition

	if isGamePadMode then
		if self.scratchInputSource == "gamepad" then
			self.SetScratchSoundActive(self, false)

			self.scratchInputSource = "gamepad"
		end
	elseif self.scratchInputSource ~= "gamepad" then
		self.SetScratchSoundActive(self, false)

		if self.isScratch then
			self.SetScratchGameplayActive(self, false)
		end

		mousePosition = self.SwitchScratchInputToMouse(self)
	end

	if self.UpdateScratchLiftFollow(self) then
		return
	end

	if self.scratchInputSource ~= "mouse" then
		self.lastMouseScratchPosition = mousePosition

		self.PlayPlayerAni(self, self.lastMouseScratchPosition)
	end

	if not self.isScratch then
		return
	end

	if self.TryShowLoseView(self, self.bindData.scratchCardMaskSafeArea) then
		return
	end

	if self.TryShowResultView(self, self.bindData.scratchCardMask) then
		return
	end
end

M.SetScratchGameplayActive = function(self, isScratch, source)
	if self.isScratch ~= isScratch and (not isScratch or self.scratchInputSource ~= source) then
		return
	end

	self.isScratch = isScratch

	if source then
		self.scratchInputSource = source
	end

	local signal = isScratch and self.ScratchCardStartInwardSignal or self.ScratchCardEndInwardSignal

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, signal)
	gMessageManager:SendMessage(gEventConstants.ON_SCRATCH_CARD_CHANGE_CURSOR, isScratch)

	if isScratch and not self.hasSentScratchStartSignal then
		self.hasSentScratchStartSignal = true

		self.SendScratchSignal(self, "scratch_start")
	end

	if isScratch then
		self.scratchLiftFollowPosition = nil
		self.scratchLiftFollowEndTime = nil
		self.scratchLiftFollowSource = nil
	end
end

M.SetScratchSoundActive = function(self, isActive)
	if self.isScratchSoundActive ~= isActive then
		return
	end

	self.isScratchSoundActive = isActive

	if isActive then
		self.PlaySound(self)

		return
	end

	self.StopSound(self)
end

M.PlaySound = function(self)
	self.scratchVibrateCo = coroutine.stop(self.scratchVibrateCo)
	self.scratchVibrateCo = coroutine.start(function ()
		while true do
			gSoundMgr:StopSoundByNid(self.shakeId)

			self.shakeId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)

			coroutine.wait(2)
		end
	end)
end

M.StopSound = function(self)
	self.isScratchSoundActive = false
	self.scratchVibrateCo = coroutine.stop(self.scratchVibrateCo)

	if self.shakeId then
		gSoundMgr:StopSoundByNid(self.shakeId)

		self.shakeId = nil
	end
end

M.BeginScratchLiftFollow = function(self, position, source)
	self.scratchLiftFollowPosition = position
	self.scratchLiftFollowSource = source or self.scratchInputSource
	self.scratchLiftFollowEndTime = Time.time + self.ScratchCardLiftFollowTime
end

M.IsScratchLiftFollowing = function(self)
	return self.scratchLiftFollowEndTime and Time.time > self.scratchLiftFollowEndTime
end

M.UpdateScratchLiftFollowPosition = function(self, position, source)
	self.scratchLiftFollowPosition = position
	self.scratchLiftFollowSource = source or self.scratchLiftFollowSource
end

M.GetScratchLiftFollowPosition = function(self)
	if self.scratchLiftFollowSource ~= "mouse" then
		self.scratchLiftFollowPosition = UnityEngine.Input.mousePosition
	elseif self.scratchLiftFollowSource ~= "gamepad" then
		self.scratchLiftFollowPosition = self.lastGamePadScratchPosition
	end

	return self.scratchLiftFollowPosition
end

M.UpdateScratchLiftFollow = function(self)
	if not self.scratchLiftFollowEndTime then
		return false
	end

	if self.scratchLiftFollowEndTime >= Time.time then
		self.scratchLiftFollowPosition = nil
		self.scratchLiftFollowEndTime = nil
		self.scratchLiftFollowSource = nil

		return false
	end

	self.PlayPlayerAni(self, self.GetScratchLiftFollowPosition(self))

	return true
end

M.PlayPlayerAni = function(self, position)
	if not self.bindData.handRect then
		return
	end

	gNewGuideMgr:NotifySignal(EGuideSignal.ScratchCardGuide)

	self.tmppos = SGUI.Utils.ScreenPointToLocalPoint(gCS.CameraDataMgr.MainCamera, self.bindData.handRect, position)
	local vec2 = Vector2.New(self.tmppos.x / (self.bindData.handRect.rect.width / 2), self.tmppos.y / (self.bindData.handRect.rect.height / 2))

	gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, vec2.x, vec2.y, 0)

	if self.isScratch then
		self.UpdateScratchHandSignal(self, vec2)
	end
end

M.SendScratchSignal = function(self, signalKey)
	print_debug("[ScratchCard] SendScratchSignal", signalKey, self.entity.entityInstanceId)
	gSpoonClientMgr:ReleaseContextEvent(self.entity.entityInstanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
		signalKey = signalKey,
		entityInstanceId = self.entity.entityInstanceId
	})
end

M.GetScratchHandSignal = function(self, vec2)
	if vec2.x >= 0 then
		return vec2.y > 0 and "scratch_leftup" or "scratch_leftdown"
	end

	return vec2.y > 0 and "scratch_rightup" or "scratch_rightdown"
end

M.UpdateScratchHandSignal = function(self, vec2)
	local signalKey = self.GetScratchHandSignal(self, vec2)

	if self.lastScratchHandSignal ~= signalKey then
		return
	end

	self.lastScratchHandSignal = signalKey

	self.SendScratchSignal(self, signalKey)
end

M.GetMoneyDisplayText = function(self, price)
	local exchangePrice = gCommonItemManager:GetExchangeRate(price)

	return string.format("%s %d", gCommonItemManager:GetCurrMoneyRichText(), exchangePrice)
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.dataList[luaIndex]
	local id = data.id
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local scratchCfg = LTConfig.PoiGameScratchConfig.GetConfig(id)
	store.iconId = scratchCfg.SguiID
	store.vxIconId = scratchCfg.SguiID
	store.text = scratchCfg.Text
	store.money = self:GetMoneyDisplayText(data.baseScore)
	store.vxText = scratchCfg.Text
	store.vxMoney = self:GetMoneyDisplayText(data.baseScore)
	store._scratchMultiple = scratchCfg.Multiple
	self.scratchItemStoreByIndex[luaIndex] = store
	local targetControl = self:GetTargetControl(data, luaIndex)
	store.isTargetControl = targetControl

	self:TryPlayTargetAni(store, targetControl, luaIndex)
end

M.IsTargetItem = function(self, data)
	return data.multiple >= 0
end

M.GetTargetControl = function(self, data, luaIndex)
	if (self.bindData.stateControl ~= 1 or self.revealedRewardIndexSet[luaIndex]) and self.IsTargetItem(self, data) then
		return 1
	end

	return 0
end

M.TryPlayTargetAni = function(self, store, targetControl, aniKey)
	if targetControl ~= 1 then
		self.PlayTargetAni(self, store, aniKey)
	end
end

M.PlayTargetAni = function(self, store, aniKey)
	self.PlayScratchTargetAni(self, store.Ani, "S_Vx_ScratchPattern", aniKey)
end

M.PlayScratchTargetAni = function(self, ani, clipNamePrefix, aniKey)
	local key = aniKey or ani

	if self.playedTargetAniMap[key] then
		return
	end

	self.playedTargetAniMap[key] = true

	gSoundMgr:PlaySoundByTid(70650716)
	self:PlayAniChain(ani, clipNamePrefix .. "_In", 1.1):PlayAniChain(ani, clipNamePrefix .. "_Loop", 0)
end

M.GetZoneRowCount = function(self)
	return 2
end

M.GetZoneItemIndex = function(self, zoneIndex)
	if zoneIndex <= 0 or self.GetShowCount(self) < zoneIndex then
		return nil
	end

	local rowCount = self.GetZoneRowCount(self)
	local colCount = math.floor(self.GetShowCount(self) / rowCount)
	local row = math.floor(zoneIndex / colCount)
	local col = zoneIndex % colCount

	return col * rowCount + row + 1
end

M.OnZoneRevealed = function(self, zoneIndex)
	local luaIndex = self.GetZoneItemIndex(self, zoneIndex)

	if not luaIndex then
		return
	end

	if self.revealedRewardIndexSet[luaIndex] then
		return
	end

	self.revealedRewardIndexSet[luaIndex] = true
	local data = self.dataList[luaIndex]

	if not data then
		print_debug("[ScratchCard] OnZoneRevealed", zoneIndex, luaIndex, false)

		return
	end

	local isTarget = self.IsTargetItem(self, data)

	print_debug("[ScratchCard] OnZoneRevealed", zoneIndex, luaIndex, isTarget)

	if not isTarget then
		return
	end

	self.bindData.list:RefreshList()

	local store = self.scratchItemStoreByIndex[luaIndex]
	store.isTargetControl = 1

	self:TryPlayTargetAni(store, 1, luaIndex)

	if store.list then
		store.list:RefreshList()
	end
end

M.OnRevealProgressChanged = function(self, _, isRevealed)
	if isRevealed then
		self.ShowResultView(self)
	end

	self.PlayScratchRevealSound(self)
end

M.OnSafeAreaRevealProgressChanged = function(self, _, isRevealed)
	if isRevealed then
		self.ShowLoseView(self)
	end

	self.PlayScratchRevealSound(self)
end

M.PlayScratchRevealSound = function(self)
	local now = UnityEngine.Time.unscaledTime
	local interval = 0.3

	if self.lastScratchRevealSoundTime and interval <= now - self.lastScratchRevealSoundTime then
		return
	end

	self.lastScratchRevealSoundTime = now

	gSoundMgr:PlaySoundByTid(70650433)
	print_debug("OnRevealProgressChanged")
end

M.ShowLoseView = function(self)
	if self.already then
		return
	end

	self.already = true
	self.totalReward = 0

	if not self.hasSentScratchEndSignal then
		self.hasSentScratchEndSignal = true

		self.SendScratchSignal(self, "scratch_endToCircle")
	end

	gMessageManager:SendMessage(gEventConstants.ON_SCRATCH_CARD_GAME_LOSE)
end

M.ShowResultView = function(self)
	if self.already then
		return
	end

	self.already = true

	if not self.hasSentScratchEndSignal then
		self.hasSentScratchEndSignal = true

		self.SendScratchSignal(self, "scratch_endToCircle")
	end

	self.bindData.stateControl = 1
	local totalReward, rewardTipsControl = self:GetResultInfo()
	self.totalReward = totalReward

	gMessageManager:SendMessage(gEventConstants.ON_SHOW_SCRATCH_CARD_RESULT, {
		totalReward = totalReward,
		rewardTipsControl = rewardTipsControl
	})
	self.bindData.list:RefreshList()
end

M.GetResultInfo = function(self)
	local totalReward = self.GetTotalReward(self)
	local rewardTipsControl = 0

	if totalReward <= 0 then
		local rewardTipsList = self.GetRewardTipsList(self)
		local count = #rewardTipsList

		for i = count, 1, -1 do
			if rewardTipsList[i] < totalReward then
				rewardTipsControl = i - 1

				break
			end
		end
	end

	return totalReward, rewardTipsControl
end

M.GetTotalReward = function(self)
	return self.serverTotalReward
end

M.GetRewardTipsList = function(self)
	return LTConfig.PoiGameConfig.ScratchType1RewardTipsList
end

M.OnPointerDown = function(self)
	print_debug("ScratchCard OnPointerDown")
	self.SetScratchGameplayActive(self, true, "mouse")
end

M.OnEndDrag = function(self)
	print_debug("ScratchCard OnEndDrag")
	self.SetScratchGameplayActive(self, false)
	self.BeginScratchLiftFollow(self, UnityEngine.Input.mousePosition, "mouse")
end

M.OnPointerUp = function(self)
	print_debug("ScratchCard OnPointerUp")
	self.SetScratchGameplayActive(self, false)
	self.BeginScratchLiftFollow(self, UnityEngine.Input.mousePosition, "mouse")
end

M.OnDestroy = function(self)
	self.StopSound(self)
	self.ClearMessageEvents(self)

	if self.totalReward then
		gSpoonClientMgr:ReleaseContextEvent(self.entity.entityInstanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnGamePlayDropReward, {
			rewardMoney = self.totalReward
		})
	end

	self.totalReward = nil
end
