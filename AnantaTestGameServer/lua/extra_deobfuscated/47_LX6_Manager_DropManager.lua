local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local DropTemplateConfig = LTConfig.DropTemplateConfig
local DropConfig = LTConfig.DropConfig
local UrbanJobJobClassConfig = LTConfig.UrbanJobJobClassConfig
local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
local StaticProps = {
	DEFAULT_SHOW_TYPE = {
		ShowSpecial = true,
		RewardAction = "ShowCornerRewardType2"
	}
}
C_DropManager = DefClass("C_DropManager", C_DropManager, nil, StaticProps)
local M = C_DropManager

function M:ctor()
	self.openDebugLog = false
	self.debugCompelteCount = 0
	self.gmDisable = false
	self.gmDisableTimer = nil
	self.RewardType = {
		First = 1,
		Normal = 0
	}
	self.DropItemQuality2Effect = {
		LTConfig.EffectConfig.InciteWhite,
		LTConfig.EffectConfig.InciteBlue,
		LTConfig.EffectConfig.IncitePurple,
		LTConfig.EffectConfig.InciteGolden
	}
	self.DropItemQuality2MonsterEffect = {
		LTConfig.GameConfig.MonsterDropAutoPickEffectWhite[3],
		LTConfig.GameConfig.MonsterDropAutoPickEffectBlue[3],
		LTConfig.GameConfig.MonsterDropAutoPickEffectPurple[3],
		LTConfig.GameConfig.MonsterDropAutoPickEffectGold[3]
	}
	self.dropLimitDict = {}
	self.EventHandler = {}
end

function M:SetDebugOpen(open)
	self.openDebugLog = open
end

function M:OnInit()
	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end

	self.blockItem = {}

	for i = 1, #ConsumableConfig.BlockCornerWindowItem do
		self.blockItem[ConsumableConfig.BlockCornerWindowItem[i]] = true
	end
end

function M:OnBeforeSwitchScene(switchType)
	self.WaitEnterScene = true

	if switchType == gSwitchSceneType.KickToLogin then
		self:RemoveAll()

		return
	end
end

function M:RemoveAll()
	self:ClearGmDisable()
end

function M:OnSyncRewardOnTheGround(rewardDetail)
	local rewardItems = self:GetDropItemList(rewardDetail)
	local pos = rewardDetail.ExtraInfo.Pos
	local isDropAndPick, position = self:GetDropTypeInfo(pos)

	if table.isNilOrEmpty(rewardItems) then
		return
	end

	local dropAndPickCount = 0

	for i = 1, #rewardItems do
		local itemId = rewardItems[i].TemplateId

		if itemId ~= ConsumableConfig.RewardGold and isDropAndPick then
			dropAndPickCount = dropAndPickCount + 1
		end
	end

	for i = 1, #rewardItems do
		local itemId = rewardItems[i].TemplateId

		local function afterGetFunc()
			gDropManager:AddToNextFrameList({
				Rewards = {
					{
						Count = rewardItems[i].Count,
						ItemId = itemId
					}
				}
			}, {
				ShowSpecial = true,
				RewardAction = "ShowCornerRewardType2"
			})
		end

		if isDropAndPick then
			if afterGetFunc then
				afterGetFunc()
			end
		else
			self:DropItem(position, itemId, itemId == ConsumableConfig.RewardGold, false, afterGetFunc)
		end
	end
end

function M:DropItem(position, itemId, isMoney, isFromMonster, AfterPickFunc)
	if AfterPickFunc then
		AfterPickFunc()
	end
end

function M:ShowReceiveRewardDetail(detail)
	if self.gmDisable then
		return
	end

	if detail.ExtraInfo then
		local pos = detail.ExtraInfo.Pos

		if pos.X ~= 0 or pos.Y ~= 0 or pos.Z ~= 0 then
			self:OnSyncRewardOnTheGround(detail)

			return
		end
	end

	local popupParam = gItemUtils:ConvertRewardDetail(detail)

	self:EnqueueByTemplate(detail.RewardTemplate, popupParam)
end

function M:SetGmDisable(time)
	self:ClearGmDisable()

	self.gmDisable = true
	self.gmDisableTimer = Timer.New(function ()
		self.gmDisable = false
		self.gmDisableTimer = nil
	end, time):Start()
end

function M:ClearGmDisable()
	if self.gmDisableTimer then
		self.gmDisableTimer:Stop()

		self.gmDisableTimer = nil
	end
end

function M:EnqueueByTemplate(templateId, popupParam)
	local dropTemplate = DropTemplateConfig.GetConfig(templateId)
	dropTemplate = dropTemplate or M.DEFAULT_SHOW_TYPE

	if popupParam.Param and popupParam.Param.taskState == gTaskManager.TaskState.Finish and popupParam.Param.name then
		if not popupParam.Param.taskId then
			if popupParam.Param.TipType == TaskTipsType.Tower then
				gPanelManager:CheckShow(gPanelId.S_MAP_TOWER_PANEL, popupParam)
			end
		else
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, popupParam)
		end
	end

	if popupParam.JobExpInfo and dropTemplate.RewardAction ~= "ShowProRewardWindow" then
		local isPromote = false

		for k, v in pairs(popupParam.JobExpInfo) do
			if gSpiritJobManager:CheckJobIsPromote(k, v) then
				isPromote = true
			end
		end

		if not isPromote then
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.UrbanAbilityEXP, {
				JobExpInfo = popupParam.JobExpInfo
			})
		end
	end

	if popupParam.InvestigatorGalleryId and gInvestigatorManager:CheckIsUnlock() then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.InvestigatorGalleryUnlocked, {
			id = popupParam.InvestigatorGalleryId
		})

		return
	end

	if popupParam.AllItems or popupParam.Rewards then
		self:AddToNextFrameList(popupParam, dropTemplate)
	end
end

function M:CheckItem(itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)

	return cfg and cfg.ShowDropResult
end

function M:AddToNextFrameList(popupParam, dropTemplate)
	if dropTemplate == nil then
		return
	end

	local showList = {}
	local itemList = table.isNilOrEmpty(popupParam.Rewards) and popupParam.AllItems or popupParam.Rewards

	if dropTemplate.ShowSpecial then
		if not table.isNilOrEmpty(itemList) then
			for i = 1, #itemList do
				local item = itemList[i]
				local cfg = ConsumableConfig.GetConfig(item.ItemId)
				local type = cfg and cfg.SubType or 0
				local typeConfig = ConsumableTypeConfig.GetConfig(type)
				local showSp = typeConfig and typeConfig.ShowInSpecialDrop or false

				if showSp then
					local msg = {
						itemInfo = item
					}

					self:ShowSpecialDrop(msg)
				else
					table.insert(showList, item)
				end
			end
		end
	else
		showList = itemList
	end

	local index = 1

	for i = 1, #showList do
		if self:CheckItem(showList[i].ItemId) == true then
			showList[index] = showList[i]
			index = index + 1
		end
	end

	for i = index, #showList do
		showList[i] = nil
	end

	if #showList > 0 then
		local actionArgs = {
			specialType = 0,
			Param = showList,
			RawParam = popupParam
		}

		self:RegisterAction(dropTemplate.RewardAction, actionArgs)
	end
end

function M:RegisterAction(actionName, actionArgs)
	local action = self:CreateActionWithArgs(actionName, actionArgs)

	if action then
		action()
	end
end

function M:GetDropTypeInfo(pos)
	local position = nil
	local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

	if not myPlayerCSUnit then
		position = Vector3.zero
	else
		position = myPlayerCSUnit.LocalPosition
	end

	if pos then
		position = Vector3.New(pos.X, pos.Y, pos.Z)
	end

	local distance = gUtils:GetDistance(myPlayerCSUnit.PlayerObj.position, position)
	local pickUpImmediatelyRange = LTConfig.GameConfig.DropAutoPickRange[1]

	return pickUpImmediatelyRange < distance, position
end

function M:GetDropItemList(rewardDetail)
	local normalDetail = rewardDetail.Reward[gDropManager.RewardType.Normal]
	local firstDetail = rewardDetail.Reward[gDropManager.RewardType.First]
	local rewardItems = normalDetail.Items or {}

	if firstDetail and firstDetail.Items then
		array.concat(rewardItems, firstDetail.Items)
	end

	local money = normalDetail.Money
	local bindingGold = normalDetail.BindingGold
	local freeGold = normalDetail.FreeGold

	if money > 0 then
		table.insert(rewardItems, {
			TemplateId = ConsumableConfig.RewardMoney,
			Count = money
		})
	end

	if bindingGold > 0 then
		table.insert(rewardItems, {
			TemplateId = ConsumableConfig.RewardBindingGold,
			Count = bindingGold
		})
	end

	if freeGold > 0 then
		table.insert(rewardItems, {
			TemplateId = ConsumableConfig.RewardGold,
			Count = freeGold
		})
	end

	return rewardItems
end

function M:ShowProRewardWindow(param)
	if table.isNilOrEmpty(param.RawParam.JobExpInfo) then
		return
	end

	local showBody = {
		JobExpInfo = param.RawParam.JobExpInfo,
		itemList = param.Param,
		Money = param.RawParam.Money
	}

	if param.RawParam.JobExpInfo[UrbanJobJobClassConfig.Police] then
		gMessageManager:SendMessage(gEventConstants.POLICE_DROP_EVENT, showBody)
	end
end

function M:ShowRewardWindow(param)
	gPopupPauseManager:PausePopup(gPopupPauseManager.PAUSE_REASON.COMMON_REWARD_OPEN)
	gPanelManager:CheckShow(gPanelId.S_COMMON_REWARD_WINDOW, param)
end

function M:ShowSpecialDrop(param)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_SpecialRewardPanel, param)
end

function M:ShowCornerRewardType2(param)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.CommonDrop, param)
end

function M:OnSyncDropLimitInfo(dropLimitCount)
	self.dropLimitDict = dropLimitCount
end

function M:OnSyncDropLimitNewInfo(dropId, info)
	self.dropLimitDict[dropId] = info
end

function M:CheckDropLimit(dropId)
	local cfg = DropConfig.GetConfig(dropId)

	if not cfg then
		return false
	end

	local limitCount = self.dropLimitDict[dropId] and self.dropLimitDict[dropId].Count or 0

	return cfg.LimitNum <= limitCount
end

gDropManager = gDropManager or C_DropManager.new()

return gDropManager
