-- Original chunk: @Lua\LuaFiles\LX6\Manager\DropManager.lua
-- Decompiled from: 00237_DropManager.lua_12ae3813c86e.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local DropTemplateConfig = LTConfig.DropTemplateConfig
local DropConfig = LTConfig.DropConfig
local UrbanJobJobClassConfig = LTConfig.UrbanJobJobClassConfig
local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
local StaticProps = {
	DEFAULT_SHOW_TYPE = {
		["\\xac</(K\\x8dD\\xda>\\xab\\xb5"] = true,
		["]s\\xbbv^\\xb6\\xd3D~sqB"] = "<>\\xbb\\xf7}-\\xa41>̎\\x91\\x80\\x87\\xcc\\xdc"
	}
}
C_DropManager = DefClass("C_DropManager", C_DropManager, nil, StaticProps)
local M = C_DropManager

M.ctor = function(self)
	self.openDebugLog = false
	self.debugCompelteCount = 0
	self.gmDisable = false
	self.gmDisableTimer = nil
	self.rewardWindowDisable = false
	self.RewardType = {
		["k\\xa7\\xb0\\xbc\\xa2"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
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

M.SetDebugOpen = function(self, open)
	self.openDebugLog = open
end

M.OnInit = function(self)
	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	self.WaitEnterScene = true

	if switchType ~= gSwitchSceneType.KickToLogin then
		self:RemoveAll()

		return
	end
end

M.RemoveAll = function(self)
	self:ClearGmDisable()
end

M.OnSyncRewardOnTheGround = function(self, rewardDetail)
	local rewardItems = self:GetDropItemList(rewardDetail)
	local pos = rewardDetail.ExtraInfo.Pos
	local isDropAndPick, position = self:GetDropTypeInfo(pos)

	if table.isNilOrEmpty(rewardItems) then
		return
	end

	local dropAndPickCount = 0

	for i = 1, #rewardItems do
		local itemId = rewardItems[i].TemplateId

		if itemId == ConsumableConfig.RewardGold and isDropAndPick then
			dropAndPickCount = dropAndPickCount + 1
		end
	end

	for i = 1, #rewardItems do
		local itemId = rewardItems[i].TemplateId

		local afterGetFunc = function()
			gDropManager:AddToNextFrameList({
				Rewards = {
					{
						Count = rewardItems[i].Count,
						ItemId = itemId
					}
				}
			}, {
				["\\xac</(K\\x8dD\\xda>\\xab\\xb5"] = true,
				["]s\\xbbv^\\xb6\\xd3D~sqB"] = "<>\\xbb\\xf7}-\\xa41>̎\\x91\\x80\\x87\\xcc\\xdc"
			})
		end

		if isDropAndPick then
			if afterGetFunc then
				afterGetFunc()
			end
		else
			self:DropItem(position, itemId, itemId ~= ConsumableConfig.RewardGold, false, afterGetFunc)
		end
	end
end

M.DropItem = function(self, position, itemId, isMoney, isFromMonster, AfterPickFunc)
	if AfterPickFunc then
		AfterPickFunc()
	end
end

M.ShowReceiveRewardDetail = function(self, detail)
	if self.gmDisable then
		return
	end

	if detail.ExtraInfo then
		local pos = detail.ExtraInfo.Pos

		if pos.X == 0 or pos.Y == 0 or pos.Z == 0 then
			self:OnSyncRewardOnTheGround(detail)

			return
		end
	end

	local popupParam = gItemUtils:ConvertRewardDetail(detail)

	self:EnqueueByTemplate(detail.RewardTemplate, popupParam)
end

M.SetGmDisable = function(self, time)
	self:ClearGmDisable()

	self.gmDisable = true
	self.gmDisableTimer = Timer.New(function ()
		self.gmDisable = false
		self.gmDisableTimer = nil
	end, time):Start()
end

M.ClearGmDisable = function(self)
	if self.gmDisableTimer then
		self.gmDisableTimer:Stop()

		self.gmDisableTimer = nil
	end
end

M.EnqueueByTemplate = function(self, templateId, popupParam)
	local dropTemplate = DropTemplateConfig.GetConfig(templateId)
	dropTemplate = dropTemplate or M.DEFAULT_SHOW_TYPE

	if popupParam.Param and popupParam.Param.taskState ~= gTaskManager.TaskState.Finish and popupParam.Param.name then
		if not popupParam.Param.taskId then
			if popupParam.Param.TipType ~= TaskTipsType.Tower then
				gPanelManager:CheckShow(gPanelId.S_MAP_TOWER_PANEL, popupParam)
			end
		else
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, popupParam)
		end
	end

	if popupParam.JobExpInfo and dropTemplate.RewardAction == "ShowProRewardWindow" then
		local isPromote = false

		for k, v in pairs(popupParam.JobExpInfo) do
			if gSpiritJobManager:CheckJobIsPromote(k, v) then
				isPromote = true
			end
		end

		if not isPromote then
			local validJobs = gSpiritJobManager:GetAvailableJobByClassList(popupParam.JobExpInfo)

			for jobClassId, jobInfo in pairs(validJobs) do
				gNewPopupManager:PushPopup(LTConfig.PopupConfig.UrbanAbilityEXP, {
					JobExpInfo = {
						[jobClassId] = popupParam.JobExpInfo[jobClassId]
					},
					curJob = jobInfo.curJob,
					cfg = jobInfo.cfg
				})
			end
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

M.CheckItem = function(self, itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)

	return cfg and cfg.ShowDropResult
end

M.AddToNextFrameList = function(self, popupParam, dropTemplate)
	if dropTemplate ~= nil then
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
		if self:CheckItem(showList[i].ItemId) ~= true then
			showList[index] = showList[i]
			index = index + 1
		end
	end

	for i = index, #showList do
		showList[i] = nil
	end

	if #showList <= 0 then
		local actionArgs = {
			["\\x8c$%<q\\x9cM\\xed.\\xba\\xbc"] = 0,
			Param = showList,
			RawParam = popupParam
		}

		self:RegisterAction(dropTemplate.RewardAction, actionArgs)
	end
end

M.RegisterAction = function(self, actionName, actionArgs)
	local action = self:CreateActionWithArgs(actionName, actionArgs)

	if action then
		action()
	end
end

M.GetDropTypeInfo = function(self, pos)
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

	return pickUpImmediatelyRange <= distance, position
end

M.GetDropItemList = function(self, rewardDetail)
	local normalDetail = rewardDetail.Reward[gDropManager.RewardType.Normal]
	local firstDetail = rewardDetail.Reward[gDropManager.RewardType.First]
	local rewardItems = normalDetail.Items or {}

	if firstDetail and firstDetail.Items then
		array.concat(rewardItems, firstDetail.Items)
	end

	local moneyItem = gCommonItemManager:GetItemIdByMoneyType(UX.Game.MoneyType.Money)
	local money = normalDetail.Money
	local bindingGold = normalDetail.BindingGold
	local freeGold = normalDetail.FreeGold

	if money <= 0 then
		table.insert(rewardItems, {
			TemplateId = moneyItem,
			Count = money
		})
	end

	if bindingGold <= 0 then
		table.insert(rewardItems, {
			TemplateId = ConsumableConfig.RewardBindingGold,
			Count = bindingGold
		})
	end

	if freeGold <= 0 then
		table.insert(rewardItems, {
			TemplateId = ConsumableConfig.RewardGold,
			Count = freeGold
		})
	end

	return rewardItems
end

M.ShowProRewardWindow = function(self, param)
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

M.ShowRewardWindow = function(self, param)
	if self.rewardWindowDisable then
		return
	end

	gPopupPauseManager:PausePopup(gPopupPauseManager.PAUSE_REASON.COMMON_REWARD_OPEN)
	gPanelManager:CheckShow(gPanelId.S_COMMON_REWARD_WINDOW, param)
end

M.ShowRewardWindowTimer = function(self, param)
	Timer.New(function ()
		self:ShowRewardWindow(param)
	end, 1.5):Start()
end

M.ShowSpecialDrop = function(self, param)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_SpecialRewardPanel, param)
end

M.ShowCornerRewardType2 = function(self, param)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.CommonDrop, param)
end

M.OnSyncDropLimitInfo = function(self, dropLimitCount)
	self.dropLimitDict = dropLimitCount
end

M.OnSyncDropLimitNewInfo = function(self, dropId, info)
	self.dropLimitDict[dropId] = info
end

M.CheckDropLimit = function(self, dropId)
	local cfg = DropConfig.GetConfig(dropId)

	if not cfg then
		return false
	end

	local limitCount = self.dropLimitDict[dropId] and self.dropLimitDict[dropId].Count or 0

	return cfg.LimitNum > limitCount
end

gDropManager = gDropManager or C_DropManager.new()

return gDropManager
