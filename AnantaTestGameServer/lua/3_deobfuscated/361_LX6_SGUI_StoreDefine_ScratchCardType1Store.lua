C_ScratchCardType1Store = DefClass("C_ScratchCardType1Store", C_ScratchCardType1Store, C_StoreGroup)
GroupName2Class.ScratchCardType1Store = C_ScratchCardType1Store
local M = C_ScratchCardType1Store

function M:ctor()
	self.ScratchCardStartInwardSignal = 10001
	self.ScratchCardEndInwardSignal = 10002
end

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")

	self:InitMessages()
end

function M:InitMessages()
	self:RegisterMessageEvents({
		[gEventConstants.ON_SCRATCH_CARD_GAMEPAD_DRAW_AT] = self:CreateAction("OnGamePadDrawAt")
	})
end

function M:ShowPanel(args)
	self.already = false
	self.isScratch = false

	self:InitModel(args)
	self:InitView()
end

function M:InitModel(args)
	self.gamePlayId = args.gamePlayId

	self:InitDataList(args)
end

function M:GetShowCount()
	return 8
end

function M:GetMaxReward()
	return LTConfig.PoiGameConfig.ScratchType1MaxReward
end

function M:InitDataList(args)
	self.regularItemList = {}
	self.baseScoreItemList = {}
	self.noRewardItemIdList = {}
	local count = LTConfig.PoiGameScratchConfig.count

	for i = 0, count - 1 do
		local scratchCfg = LTConfig.PoiGameScratchConfig.LoadAt(i)

		if scratchCfg.GameplayID == self.gamePlayId then
			if scratchCfg.Score > 0 then
				table.insert(self.baseScoreItemList, {
					id = scratchCfg.Id,
					score = scratchCfg.Score,
					weight = scratchCfg.Weight
				})
			else
				if scratchCfg.Multiple == 0 then
					table.insert(self.noRewardItemIdList, scratchCfg.Id)
				end

				table.insert(self.regularItemList, {
					id = scratchCfg.Id,
					multiple = scratchCfg.Multiple,
					weight = scratchCfg.Weight
				})
			end
		end
	end

	self.dataList = self:GenerateRewardList(args.targetRewardMin, args.targetRewardMax)
end

function M:CalculateTotalWeight(itemList)
	local totalWeight = 0

	for _, item in ipairs(itemList) do
		totalWeight = totalWeight + item.weight
	end

	return totalWeight
end

function M:PickRandomItem(itemList, totalWeight)
	local rand = math.random() * totalWeight
	local cumulativeWeight = 0

	for _, item in ipairs(itemList) do
		cumulativeWeight = cumulativeWeight + item.weight

		if rand <= cumulativeWeight then
			return item
		end
	end

	return itemList[1]
end

function M:PickRandomBaseScore()
	local totalWeight = self:CalculateTotalWeight(self.baseScoreItemList)
	local scoreItem = self:PickRandomItem(self.baseScoreItemList, totalWeight)

	return scoreItem.score
end

function M:GenerateRewardList(targetRewardMin, targetRewardMax)
	if targetRewardMin and targetRewardMax then
		return self:GenerateTargetRangeRewardList(targetRewardMin, targetRewardMax)
	elseif targetRewardMin then
		return self:GenerateTargetMinRewardList(targetRewardMin)
	elseif targetRewardMax then
		return self:GenerateTargetMaxRewardList(targetRewardMax)
	else
		return self:RandomGenerateRewardList()
	end
end

function M:GenerateTargetRangeRewardList(targetRewardMin, targetRewardMax)
	local maxReward = self:GetMaxReward()
	targetRewardMax = math.min(targetRewardMax, maxReward)
	local maxAttempts = 1000

	for _ = 1, maxAttempts do
		local rewardList, totalReward = self:RandomGenerateRewardList()

		if targetRewardMin <= totalReward and totalReward <= targetRewardMax then
			return rewardList
		end
	end

	return self:RandomGenerateRewardList()
end

function M:GenerateTargetMinRewardList(targetRewardMin)
	local maxAttempts = 1000

	for _ = 1, maxAttempts do
		local rewardList, totalReward = self:RandomGenerateRewardList()

		if targetRewardMin <= totalReward then
			return rewardList
		end
	end

	return self:RandomGenerateRewardList()
end

function M:GenerateTargetMaxRewardList(targetRewardMax)
	local maxReward = self:GetMaxReward()
	targetRewardMax = math.min(targetRewardMax, maxReward)
	local maxAttempts = 1000

	for _ = 1, maxAttempts do
		local rewardList, totalReward = self:RandomGenerateRewardList()

		if totalReward <= targetRewardMax then
			return rewardList
		end
	end

	return self:RandomGenerateRewardList()
end

function M:RandomGenerateRewardList()
	local regularItemsTotalWeight = self:CalculateTotalWeight(self.regularItemList)
	local showCount = self:GetShowCount()
	local maxReward = self:GetMaxReward()
	local totalReward = 0
	local rewardList = {}

	for _ = 1, showCount do
		local item = self:PickRandomItem(self.regularItemList, regularItemsTotalWeight)
		local baseScore = self:PickRandomBaseScore()

		if maxReward < totalReward + baseScore * item.multiple then
			local noRewardItemId = self:GetNoRewardItemId()

			table.insert(rewardList, {
				multiple = 0,
				reward = 0,
				id = noRewardItemId,
				baseScore = baseScore
			})
		else
			table.insert(rewardList, {
				id = item.id,
				multiple = item.multiple,
				baseScore = baseScore,
				reward = baseScore * item.multiple
			})

			totalReward = totalReward + baseScore * item.multiple
		end
	end

	return rewardList, totalReward
end

function M:GetNoRewardItemId()
	return self.noRewardItemIdList[math.random(1, #self.noRewardItemIdList)]
end

function M:InitView()
	self.bindData.list:SetSimpleList(#self.dataList)

	self.bindData.scratchCardMask.OnEndDragAction = self:CreateAction("OnEndDrag")
	self.bindData.scratchCardMask.OnPointerDownAction = self:CreateAction("OnPointerDown")
	self.bindData.scratchCardMask.OnPointerUpAction = self:CreateAction("OnPointerUp")
	self.bindData.scratchCardMask.RevealProgressChanged = self:CreateAction("OnRevealProgressChanged")
end

function M:OnGamePadDrawAt(_, arg)
	if not self.bindData.scratchCardMask or not self.bindData.controllerArea then
		return
	end

	local scaledPosition = self:GetGamePadScaledPosition(arg)

	self:PlayPlayerAni(scaledPosition)
	self.bindData.scratchCardMask:DrawAtByLua(scaledPosition)

	if self.bindData.scratchCardMask.IsRevealed then
		self:ShowResultView()
	end
end

function M:GetGamePadScaledPosition(arg)
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
		local screenPoint = mainCamera:WorldToScreenPoint(worldCorner)
		screenMin = Vector2.New(math.min(screenMin.x, screenPoint.x), math.min(screenMin.y, screenPoint.y))
		screenMax = Vector2.New(math.max(screenMax.x, screenPoint.x), math.max(screenMax.y, screenPoint.y))
	end

	local screenWidth = UnityEngine.Screen.width
	local screenHeight = UnityEngine.Screen.height
	local normalizedX = arg.screenPos.x / screenWidth
	local normalizedY = arg.screenPos.y / screenHeight
	local scaledPosX = screenMin.x + normalizedX * (screenMax.x - screenMin.x)
	local scaledPosY = screenMin.y + normalizedY * (screenMax.y - screenMin.y)

	return Vector2.New(scaledPosX, scaledPosY)
end

function M:OnUpdate()
	if not self.isScratch then
		return
	end

	self:PlayPlayerAni(UnityEngine.Input.mousePosition)

	if self.bindData.scratchCardMask.IsRevealed then
		self:ShowResultView()

		return
	end
end

function M:PlayPlayerAni(position)
	if not self.bindData.handRect then
		return
	end

	gNewGuideMgr:NotifySignal(EGuideSignal.ScratchCardGuide)

	self.tmppos = SGUI.Utils.ScreenPointToLocalPoint(gCS.CameraDataMgr.MainCamera, self.bindData.handRect, position)
	local vec2 = Vector2.New(self.tmppos.x / (self.bindData.handRect.rect.width / 2), self.tmppos.y / (self.bindData.handRect.rect.height / 2))

	gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, vec2.x, vec2.y, 0)
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.dataList[luaIndex]
	local id = data.id
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local scratchCfg = LTConfig.PoiGameScratchConfig.GetConfig(id)
	store.iconId = scratchCfg.SguiID
	store.text = scratchCfg.Text
	store.money = data.baseScore
	store.isTargetControl = self:GetTargetControl(id)
end

function M:GetTargetControl(id)
	local scratchCfg = LTConfig.PoiGameScratchConfig.GetConfig(id)

	if self.bindData.stateControl == 1 and scratchCfg.Multiple > 0 then
		return 1
	else
		return 0
	end
end

function M:OnRevealProgressChanged(_, isRevealed)
	gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
	print_debug("OnRevealProgressChanged")
end

function M:ShowResultView()
	if self.already then
		return
	end

	self.already = true
	self.bindData.stateControl = 1
	local totalReward, rewardTipsControl = self:GetResultInfo()
	self.totalReward = totalReward

	gMessageManager:SendMessage(gEventConstants.ON_SHOW_SCRATCH_CARD_RESULT, {
		totalReward = totalReward,
		rewardTipsControl = rewardTipsControl
	})
	self.bindData.list:RefreshList()
end

function M:GetResultInfo()
	local totalReward = self:GetTotalReward()
	local rewardTipsControl = 0

	if totalReward > 0 then
		local rewardTipsList = self:GetRewardTipsList()
		local count = #rewardTipsList

		for i = count, 1, -1 do
			if rewardTipsList[i] <= totalReward then
				rewardTipsControl = i - 1

				break
			end
		end
	end

	return totalReward, rewardTipsControl
end

function M:GetTotalReward()
	local totalReward = 0

	for _, data in ipairs(self.dataList) do
		totalReward = totalReward + data.reward
	end

	return totalReward
end

function M:GetRewardTipsList()
	return LTConfig.PoiGameConfig.ScratchType1RewardTipsList
end

function M:OnPointerDown()
	print_debug("ScratchCard OnPointerDown")

	self.isScratch = true

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, self.ScratchCardStartInwardSignal)
	gMessageManager:SendMessage(gEventConstants.ON_SCRATCH_CARD_CHANGE_CURSOR, true)
end

function M:OnEndDrag()
	print_debug("ScratchCard OnEndDrag")

	self.isScratch = false

	gMessageManager:SendMessage(gEventConstants.ON_SCRATCH_CARD_CHANGE_CURSOR, false)
end

function M:OnPointerUp()
	print_debug("ScratchCard OnPointerUp")

	self.isScratch = false

	gMessageManager:SendMessage(gEventConstants.ON_SCRATCH_CARD_CHANGE_CURSOR, false)
end

function M:OnDestroy()
	self:ClearMessageEvents()

	if self.totalReward then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnGamePlayDropReward, {
			rewardMoney = self.totalReward
		})
	end

	self.totalReward = nil
end
