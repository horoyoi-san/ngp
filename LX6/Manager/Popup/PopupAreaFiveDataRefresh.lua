-- Original chunk: @Lua\LuaFiles\LX6\Manager\Popup\PopupAreaFiveDataRefresh.lua
-- Decompiled from: 00724_PopupAreaFiveDataRefresh.lua_9da09781e2bb.luajit

local MomentsNotifyType = UX.Game.MomentsNotifyType
local SocialMediaConfig = LTConfig.SocialMediaConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local TextConfig = LTConfig.TextConfig
local UrbanJobConfig = LTConfig.UrbanJobConfig
local UrbanJobJobClassConfig = LTConfig.UrbanJobJobClassConfig
local TalentTreeLevelConfig = LTConfig.TalentTreeLevelConfig
C_PopupAreaFiveDataRefresh = DefClass("C_PopupAreaFiveDataRefresh", C_PopupAreaFiveDataRefresh)
local M = C_PopupAreaFiveDataRefresh

M.ctor = function(self)
	self.DEFAULT_ICON = LTConfig.PopupConfig.AreaFiveDefaultIcon
end

M.DoCommonRefresh = function(self, store, data, info)
	self:CommonRefreshShortcutKey(store, data, info)
end

M.CommonRefreshShortcutKey = function(self, store, data, info)
	local cfg = info.cfg

	if cfg.TemplateIndex ~= 2 then
		store.ShortcutPcCtrl = cfg.HasShortcutPc and 1 or 0

		if cfg.HasShortcutPc then
			store.shortcutSwitchPc:ChangeDevicePCKeyAction(cfg.ActionMapPc, cfg.ActionIdPc)
		end

		store.ShortcutPadCtrl = cfg.HasShortcutPad and 1 or 0

		if cfg.HasShortcutPad then
			store.shortcutSwitchPad:ChangeDeviceGamePadAction(cfg.ActionMapPad, cfg.ActionIdPad)
		end
	end
end

M.RefreshAgentAcquainted = function(self, store, data, info)
	local profileId = data.ProfileId
	local config = LTConfig.ProfileAgentProfileConfig.GetConfig(profileId)

	if not config then
		return
	end

	store.ShowTypeCtrl = 0
	store.leftIconId = config.HeadIcon or self.DEFAULT_ICON
	store.mainTitle = LTConfig.TextConfig.GetConfig(LTConfig.TextConfig.AddProfile).Text
	store.content = config.Name
	store.rightIconId = 28000582
end

M.RefreshAgentAcquaintedTotal = function(self, store, data, info)
	local count = data.count
	store.ShowTypeCtrl = 0
	store.leftIconId = 28000582
	store.mainTitle = LTConfig.TextScriptTextConfig.GetConfig(89901336).Text
	local text = LTConfig.TextScriptTextConfig.GetConfig(89901248).Text
	store.content = string.format(text, count)
	store.rightIconId = 0
end

M.RefreshAgentProfileTargetUnlock = function(self, store, data, info)
	local tgId = data.targetId
	local profileId = gAgentTrustManager:GetProfileIdByTargetId(tgId)
	local config = LTConfig.ProfileAgentProfileConfig.GetConfig(profileId)
	store.ShowTypeCtrl = 0
	store.leftIconId = config.HeadIcon or self.DEFAULT_ICON
	store.mainTitle = config.Name
	store.content = LTConfig.TextScriptTextConfig.GetConfig(89901437).Text
	store.rightIconId = 0
end

M.RefreshCityPediaUnlocked = function(self, store, data, info)
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(LTConfig.MobileMenuSGuiConfig.BaiKeId)

	if not mobileMenuSGuiCfg then
		print_error("MobileMenuSGuiConfig配置找不到，id=LTConfig.MobileMenuSGuiConfig.BaiKeId", LTConfig.MobileMenuSGuiConfig.BaiKeId)

		return
	end

	store.ShowTypeCtrl = 0
	store.mainTitle = mobileMenuSGuiCfg.Name
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(data.id)

	if not cityPediaCfg then
		print_error("CityPediaConfig配置找不到，id=", data.id)

		return
	end

	local itemData = gBaiKeArchiveManager:GetCityPediaItem(data.id)
	store.leftIconId = itemData and itemData.popupIconId == 0 and itemData.popupIconId or cityPediaCfg.ImagePopup or cityPediaCfg.Image or self.DEFAULT_ICON
	store.content = self:GetCityPediaUnlockText(itemData and itemData.popupName or cityPediaCfg.Name)
	store.rightIconId = 0
end

M.GetCityPediaUnlockText = function(self, name)
	local text = LTConfig.TextScriptTextConfig.GetConfig(89901187).Text

	return string.format(text, name)
end

M.RefreshNewContactAdded = function(self, store, data, info)
	local phoneNumber = data.phoneNumber
	local configId = gCallPhoneUtils.GetConfigIdByPhoneNumber(nil, phoneNumber)
	local name = gCallPhoneUtils.GetContactNameByConfigId(configId)
	local avatarId = gCallPhoneUtils.GetSAvatarByConfigId(configId)
	store.ShowTypeCtrl = 0
	store.mainTitle = LTConfig.TextScriptTextConfig.GetConfig(89901189).Text
	store.content = name
	store.leftIconId = avatarId or self.DEFAULT_ICON
	store.rightIconId = LTConfig.PhoneConfig.PopupContactIcon
end

M.RefreshPayTips = function(self, store, data, info)
	local params = data.Param
	store.ShowTypeCtrl = 0
	store.leftIconId = params.logoId or self.DEFAULT_ICON
	local nameCfg = LTConfig.TextCommonTextConfig.GetConfig(params.textId)
	store.mainTitle = nameCfg and nameCfg.Text or "#获取数据失败 id=" .. params.textId
	store.content = params.moneyEnough and "-" .. gCommonItemManager:GetCurrMoneyRichText() .. gCommonItemManager:GetExchangeRate(params.value) or LTConfig.TextScriptTextConfig.GetConfig(89900852).Text
	store.rightIconId = 0
end

M.RefreshHackerNewTips = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.leftIconId = LTConfig.HackerConfig.HackBBSNoticeIcon or self.DEFAULT_ICON
	store.mainTitle = LTConfig.HackerConfig.HackBBSNoticeTitle
	store.content = LTConfig.HackerConfig.HackBBSNoticeNewText
	store.rightIconId = 0
end

M.RefreshHackerRankUp = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.leftIconId = LTConfig.HackerConfig.HackBBSNoticeIcon or self.DEFAULT_ICON
	store.mainTitle = LTConfig.HackerConfig.HackBBSNoticeTitle
	store.content = string.format(LTConfig.HackerConfig.HackBBSNoticeRankText, "测试")
	store.rightIconId = 0
end

M.RefreshFriendShipUnlocked = function(self, store, data, info)
	local params = data.Param

	if not params or not params.NpcId then
		print_error("RefreshFriendShipUnlocked error! data is nil,or not NpcId")

		return
	end

	store.ShowTypeCtrl = 0
	local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(params.NpcId)

	if not npcCfg then
		print_error("RefreshFriendShipUnlocked error! NpcCultivationConfig找不到,id=", params.NpcId)

		return
	end

	store.leftIconId = npcCfg.SChatHeadId or self.DEFAULT_ICON
	store.mainTitle = LTConfig.TextScriptTextConfig.GetConfig(89901191).Text
	store.content = npcCfg.Name
	store.rightIconId = LTConfig.NpcCultivationConfig.FavorIcon or self.DEFAULT_ICON
end

M.RefreshFriendShipUnlockedTotal = function(self, store, data, info)
	local count = data.count
	store.leftIconId = 28001032
	store.mainTitle = LTConfig.TextScriptTextConfig.GetConfig(89901255).Text
	store.content = string.format(LTConfig.TextScriptTextConfig.GetConfig(89901249).Text, count)
	store.rightIconId = 0
end

M.RefreshSystemUnlocked = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.leftIconId = data.PopupPic or self.DEFAULT_ICON
	store.mainTitle = data.PopupName
	store.content = LTConfig.TextScriptTextConfig.GetConfig(89901190).Text
	store.rightIconId = 0
end

M.RefreshNewParty = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.leftIconId = data.PopupPic or self.DEFAULT_ICON
	store.mainTitle = data.PopupName
	store.content = data.PopupContent
	store.rightIconId = 0
end

M.RefreshUrbanAbilityLUEXP = function(self, store, data, info)
	local aCfg = LTConfig.UrbanAbilityConfig.GetConfig(data.info.TemplateId)

	if not aCfg then
		print_error("RefreshUrbanAbilityLUEXP error! UrbanAbilityConfig 找不到,id=", data.info.TemplateId)

		return
	end

	local maxExp = gUrbanAbilityManager:GetAbilityInfoMaxExp(data.info.TemplateId)
	store.ShowTypeCtrl = 0
	store.leftIconId = aCfg.Icon or self.DEFAULT_ICON
	store.mainTitle = aCfg.Name
	store.content = " + " .. data.info.Exp - data.lastInfo.Exp .. "  " .. data.info.Exp .. "/" .. maxExp
	store.rightIconId = 0
end

M.RefreshUrbanAbilityEXP = function(self, store, data, info)
	local jobClassId = 0
	local exp = 0

	for k, v in pairs(data.JobExpInfo) do
		jobClassId = k
		exp = v
	end

	local curJob = data.curJob
	local cfg = data.cfg

	if not curJob then
		curJob, cfg = gSpiritJobManager:GetAvailableJobByClass(jobClassId)
	end

	if not curJob then
		return
	end

	local levelCfg, levelData = gSpiritJobManager:GetLevelData(cfg, gBattleSpiritMgr.currentSpiritTemplateId)

	if not levelCfg or not levelData then
		return
	end

	store.ShowTypeCtrl = 0
	store.leftIconId = cfg.Icon or self.DEFAULT_ICON
	store.mainTitle = cfg.Name .. " " .. gString.Format(TextScriptTextConfig.GetConfig(89901298).Text, levelData.Level)
	store.content = " + " .. exp .. "  " .. levelData.Exp .. "/" .. levelCfg.Exp
	store.rightIconId = 0
end

M.RefreshPopularityReward = function(self, store, data, info)
	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderPopularityRewardItem", {
		data
	})

	store.list:SetSimpleList(1)
end

M.OnRenderPopularityRewardItem = function(self, list, btn, index)
	local store = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):GetStoreByWidget(btn)
	local data = list[index + 1]

	if store and data then
		store.iconId = self.DEFAULT_ICON
		store.leftContent = gHotCenterManager:GetPopularitySourceTitle(data.DropId)
		store.rightContent = string.format("%+d", data.Popularity or 0)
	end
end

M.RefreshFansReward = function(self, store, data, info)
	store.ShowTypeCtrl = 0

	if self.fansRewardNpcIconIndex ~= nil then
		self.fansRewardNpcIconIndex = math.random(0, LTConfig.PopupAiHeadIconConfig.count - 1)
	end

	if self.fansRewardNameIndex ~= nil then
		self.fansRewardNameIndex = math.random(0, LTConfig.OnlineNameConfig.count - 1)
	end

	self.fansRewardNpcIconIndex = self.fansRewardNpcIconIndex
	local headIconCount = LTConfig.PopupAiHeadIconConfig.count
	self.fansRewardNpcIconIndex = self.fansRewardNpcIconIndex % (headIconCount - 1)
	local headIconCfg = LTConfig.PopupAiHeadIconConfig.LoadAt(self.fansRewardNpcIconIndex)

	if not headIconCfg then
		self.fansRewardNpcIconIndex = 0
		headIconCfg = LTConfig.PopupAiHeadIconConfig.LoadAt(self.fansRewardNpcIconIndex)
	end

	store.leftIconId = headIconCfg.ImageId
	local diff = gClientUtils.FormatWithThousandsSeparator(data.currentExp - data.preExp)
	store.mainTitle = LTConfig.PopupConfig.FansPopupText1:format(diff)
	local onlineNameCount = LTConfig.OnlineNameConfig.count
	self.fansRewardNameIndex = self.fansRewardNameIndex or 0
	self.fansRewardNameIndex = self.fansRewardNameIndex % (onlineNameCount - 1)
	local onlineNameCfg = LTConfig.OnlineNameConfig.LoadAt(self.fansRewardNameIndex)

	if not onlineNameCfg then
		self.fansRewardNameIndex = 0
		onlineNameCfg = LTConfig.OnlineNameConfig.LoadAt(self.fansRewardNameIndex)
	end

	store.content = ("@%s%s"):format(onlineNameCfg.LilName, LTConfig.PopupConfig.FansPopupText2)
	store.rightIconId = LTConfig.TuiteConfig.PopupSocialNetworkIcon
	self.fansRewardNameIndex = self.fansRewardNameIndex + 1
	self.fansRewardNpcIconIndex = self.fansRewardNpcIconIndex + 1
end

M.OnRenderFansRewardItem = function(self, list, btn, index)
	local store = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):GetStoreByWidget(btn)
	local data = list[index + 1]

	if store and data then
		local isUpExp = data.preExp > data.currentExp
		local diff = gClientUtils.FormatWithThousandsSeparator(data.currentExp - data.preExp)
		store.iconId = LTConfig.TuiteConfig.FansPopupIcon or self.DEFAULT_ICON
		store.leftContent = string.format(LTConfig.TuiteConfig.FansPopupText, isUpExp and "+" .. diff or diff)
		store.rightContent = ""
	end
end

M.RefreshFactionChange = function(self, store, data, info)
	local diff = data.Disposition
	local isMul = #data.FactionId >= 1
	local factionId = data.FactionId[1]
	local textId = isMul and 89901339 or 89901337
	local cfg = LTConfig.FactionConfig.GetConfig(factionId)
	local textCfg = TextConfig.GetConfig(data.textId)
	store.ShowTypeCtrl = 0
	store.leftIconId = cfg and cfg.imageId or LTConfig.FactionConfig.MergeDropIcon
	store.mainTitle = textCfg and textCfg.Text or ""
	store.content = gString.Format(TextScriptTextConfig.GetConfig(textId).Text, cfg.name, gUIUtils:GetNumberStr(diff))
	store.rightIconId = diff > 0 and LTConfig.FactionConfig.LeftPopUpHighIcon or LTConfig.FactionConfig.LeftPopUpDownIcon
end

M.RefreshPoliceEnd = function(self, store, data, info)
	local serviceData = data.serviceData
	local listData = {
		{
			name = LTConfig.PoliceConfig.DispatchTimesText,
			count = serviceData.DispatchTimes
		},
		{
			name = LTConfig.PoliceConfig.PatrolTimesText,
			count = serviceData.PatrolTimes
		},
		{
			name = LTConfig.PoliceConfig.ArrestTimesText,
			count = serviceData.ArrestTimes
		},
		{
			name = LTConfig.PoliceConfig.FineCountText,
			count = serviceData.FineCount
		}
	}
	local _, addExp = self:CalculateAllDrop(serviceData.TotalDrops)
	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnPoliceEndRenderItem", listData)

	store.list:SetSimpleList(#listData)

	store.LineModeCtrl = 1
	store.mainTitle = LTConfig.PoliceConfig.PopupMainTitle
	store.subTitle = LTConfig.PoliceConfig.PopupSubTitle
	store.iconId = LTConfig.PoliceConfig.PopupIcon or self.DEFAULT_ICON

	self:CalculateJobData(store, data.spiritId, addExp)
end

M.OnPoliceEndRenderItem = function(self, list, btn, index)
	local store = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):GetStoreByWidget(btn)
	local data = list[index + 1]

	if store and data then
		store.leftContent = data.name
		local n = tonumber(data.count)
		local content = nil

		if not n then
			content = tostring(data.count)
		end

		if n <= 0 then
			content = "+" .. n
		else
			content = n
		end

		store.rightContent = content
	end
end

M.GetJobExp = function(self, tid)
	local spirit = gSpiritManager:GetSpirit(tid)
	local jobId, spiritJob = nil

	for index, val in pairs(spirit.SpiritInfo.SpiritJobInfo.AvailableJobs) do
		if index > 300 and index >= 400 then
			jobId = index
			spiritJob = val
		end
	end

	return spiritJob, jobId
end

M.CalculateJobData = function(self, store, tid, addExp)
	local spiritJob, jobId = self:GetJobExp(tid)
	local rContent = "+" .. addExp
	local lContent = ""
	local progressFill = 0

	if spiritJob == nil and jobId == nil then
		local curExp = spiritJob.Exp
		local cfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
		local spiritTid = gSpiritManager:GetCurFirstSpiritTid()
		local levelCfg = gSpiritJobManager:GetLevelData(cfg, spiritTid)

		if cfg == nil and levelCfg then
			if levelCfg.Exp ~= nil or levelCfg.Exp ~= 0 then
				progressFill = 1
				rContent = rContent .. "   MAX"
			else
				rContent = rContent .. "   " .. curExp .. "/" .. levelCfg.Exp
				local jobExpList = {}
				local startExp = self:CalculateJobExp(jobExpList, curExp, addExp, jobId)
				local expIndex = #jobExpList
				progressFill = Mathf.Clamp(startExp / jobExpList[expIndex], 0, 1)
			end

			lContent = cfg.Name
		end
	end

	store.leftContent = lContent
	store.rightContent = rContent
	store.progressValue = progressFill
end

M.CalculateJobExp = function(self, jobExpList, curExp, addExp, jobId)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)

	if not levelCfg then
		return 0
	end

	table.insert(jobExpList, levelCfg.Exp)

	if curExp >= addExp and cfg and levelCfg then
		addExp = addExp - curExp
		jobId = jobId - 1
		local lastCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
		local lastlevelCfg = gSpiritJobManager:GetLevelConfig(lastCfg)

		if lastlevelCfg == nil and levelCfg then
			curExp = lastlevelCfg.Exp

			return self:CalculateJobExp(jobExpList, curExp, addExp, jobId)
		else
			return 0
		end
	else
		return curExp - addExp
	end
end

M.CalculateAllDrop = function(self, TotalDrops)
	local money = 0
	local exp = 0

	for i = 1, #TotalDrops do
		local id = TotalDrops[i]
		local cfg = LTConfig.DropConfig.GetConfig(id)

		if cfg and cfg.JobExp and cfg.Money then
			exp = self:GetPoliceExp(cfg) + exp
			money = money + cfg.Money
		end
	end

	return money, exp
end

M.GetPoliceExp = function(self, cfg)
	for _, v in pairs(cfg.JobExp) do
		if v.Jobclassid ~= LTConfig.UrbanJobJobClassConfig.Police then
			return v.count
		end
	end

	return 0
end

M.RefreshDeliveryEnd = function(self, store, data, info)
	local truckJobOrderWrap = data.data
	local drop = data.drop
	local jobName = ""
	local progressValue = 0
	local addExp = drop and drop.jobExpInfo or self:GetDeliveryOrderExp(truckJobOrderWrap)
	local rContent = addExp > 0 and "+" .. addExp or "-" .. addExp
	local spiritJob = data.spiritJob
	local levelCfg = data.levelCfg
	local cfg = data.cfg

	if spiritJob == nil and levelCfg == nil and cfg == nil then
		local curExp = spiritJob.Exp
		local maxExp = levelCfg.Exp

		if maxExp ~= nil or maxExp ~= 0 then
			progressValue = 1
			rContent = rContent .. "   MAX"
		else
			rContent = rContent .. "   " .. curExp .. "/" .. maxExp
			progressValue = math.min(curExp, maxExp) / maxExp
		end

		jobName = cfg.Name
	end

	store.LineModeCtrl = 1
	local iconId = 0

	if truckJobOrderWrap.ResultInfo and truckJobOrderWrap.ResultInfo.Evaluation then
		iconId = LTConfig.UberSimConfig.RankIcon[truckJobOrderWrap.ResultInfo.Evaluation + 1]
	end

	store.iconId = iconId or self.DEFAULT_ICON
	store.mainTitle = LTConfig.UberSimConfig.PopupMainTitle
	local randomGoodsCfg = LTConfig.UberSimRandomGoodsConfig.GetConfig(truckJobOrderWrap.OrderInfo.CargoId)
	store.subTitle = string.format(LTConfig.UberSimConfig.PopupSubTitle, randomGoodsCfg.information)
	store.progressValue = progressValue
	store.leftContent = jobName
	store.rightContent = rContent
	local list = {}

	table.insert(list, {
		lContent = LTConfig.UberSimConfig.IntegralDescription[4],
		rContent = drop and drop.fineMoney or 0
	})

	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderDeliveryEndItem", list)

	store.list:SetSimpleList(#list)
end

M.GetDeliveryOrderExp = function(self, truckJobOrderWrap)
	local resultInfo = truckJobOrderWrap.ResultInfo

	if resultInfo ~= nil then
		print_warn(truckJobOrderWrap)

		return 0
	end

	local dropId = LTConfig.UberSimConfig.OrderRewardDropId
	local jobExpInfo = LTConfig.DropConfig.GetConfig(dropId).JobExp[1]
	local jobExp = jobExpInfo and jobExpInfo.count * resultInfo.DropCoefficient or 0

	return math.ceil(jobExp)
end

M.GetDeliveryLevelExp = function(self, config)
	local levelCfg = gSpiritJobManager:GetLevelConfig(config)

	if levelCfg then
		return levelCfg.Exp
	end

	return 0
end

M.OnRenderDeliveryEndItem = function(self, list, btn, index)
	local store = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):GetStoreByWidget(btn)
	local data = list[index + 1]

	if store and data then
		store.leftContent = data.lContent
		store.rightContent = data.rContent
	end
end

M.RefreshFriendShipChange = function(self, store, param, info)
	local NpcCultivationConfig = LTConfig.NpcCultivationConfig
	local data = param.Param
	local npcCultivationId = data.NpcId
	local npcCfg = NpcCultivationConfig.GetConfig(npcCultivationId)
	local favor = data.favor
	local delta = data.delta
	local favorBefore = delta <= 0 and favor - delta or favor
	local favorLevelBefore = gNpcFavorManager:GetLevelFromFavor(favorBefore)
	local favorLevelNow = gNpcFavorManager:GetLevelFromFavor(favor)
	local isLevelUp = favorLevelBefore <= favorLevelNow
	store.ShowTypeCtrl = 0
	store.leftIconId = npcCfg.SChatHeadId or self.DEFAULT_ICON
	store.mainTitle = isLevelUp and LTConfig.TextScriptTextConfig.GetConfig(89901194).Text or LTConfig.TextScriptTextConfig.GetConfig(89901193).Text
	store.content = isLevelUp and string.format(LTConfig.TextScriptTextConfig.GetConfig(89901195).Text, "  LV" .. favorLevelNow) or delta > 0 and "+" .. delta or delta
	store.rightIconId = 0
end

M.RefreshAnimalFavorability = function(self, store, data, info)
	local cfg = LTConfig.PetAnimalConfig.GetConfig(data.Id)

	if not cfg then
		print_error("PetAnimalConfig配表找不到, id=", data.Id)

		return
	end

	local isLevelUp = data.PrevFavorLevel <= data.FavorLevel
	local delta = data.Favor - data.PrevFavor
	store.ShowTypeCtrl = 0
	store.leftIconId = cfg.SImage or self.DEFAULT_ICON
	store.mainTitle = isLevelUp and LTConfig.TextScriptTextConfig.GetConfig(89901194).Text or LTConfig.TextScriptTextConfig.GetConfig(89901193).Text
	store.content = isLevelUp and string.format(LTConfig.TextScriptTextConfig.GetConfig(89901195).Text, "  LV" .. data.FavorLevel) or delta > 0 and "+" .. delta or delta
	store.rightIconId = 0
end

M.RefreshAchievementUnlocked = function(self, store, data, info)
	local AchievementConfig = LTConfig.AchievementConfig
	local cfg = AchievementConfig.GetConfig(data.Param.achieveId)

	if not cfg then
		print_error("Achievement 中不存在 id=", data.Param.achieveId)

		return
	end

	store.ShowTypeCtrl = 0

	if cfg.Hide then
		store.mainTitle = AchievementConfig.HiddenAchievementPopupTitle
	else
		store.mainTitle = AchievementConfig.AchievementPopupTitle
	end

	store.leftIconId = AchievementConfig.AchievementLevelIcon[cfg.Quality] or self.DEFAULT_ICON
	store.content = cfg.Name
	store.rightIconId = 0
end

M.RefreshCommonDrop = function(self, store, data, info)
	local drops = {}
	local isAdd = true

	for i = 1, #data.Param do
		local itemInfo = gCommonItemManager:TryGetItemInfo(data.Param[i])

		if itemInfo then
			itemInfo.tIndex = 0
			itemInfo.isShow = false
			itemInfo.count = data.Param[i].Count or 0
			isAdd = isAdd and itemInfo.count >= 0
		end

		table.insert(drops, itemInfo)
	end

	table.sort(drops, self:CreateAction("SortRenderItem", gCommonItemManager))

	if #drops <= 5 then
		for i = #drops, 6, -1 do
			drops[i] = nil
		end

		table.insert(drops, {
			["K\\x9e\\x80\\xaaE"] = 0,
			["t#p^"] = "",
			["N\\xa1\\xb7\\xa1\\xa2"] = "R\\xdf\\xc0\\xcd"
		})
	end

	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderCommonDropItem", drops)

	store.list:SetSimpleList(#drops)
end

M.OnRenderCommonDropItem = function(self, list, btn, index)
	local store = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):GetStoreByWidget(btn)
	local data = list[index + 1]

	if store and data then
		store.iconId = data.iconId or self.DEFAULT_ICON
		store.leftContent = data.name
		store.rightContent = gUIUtils:GetNumberStr(data.count)
	end
end

M.RefreshInvestigatorGalleryUnlocked = function(self, store, data, info)
	if not data or not data.id then
		print_error("RefreshInvestigatorGalleryUnlocked 错误的调用 缺少参数 id")

		return
	end

	local cfg = LTConfig.LegendaryInvestigatorGalleryConfig.GetConfig(data.id)

	if not cfg then
		print_error("【配置错误】LegendaryInvestigatorGallery表不存在id", data.id)

		return
	end

	store.ShowTypeCtrl = 0
	store.mainTitle = LTConfig.TextScriptTextConfig.GetConfig(89901216).Text
	store.leftIconId = cfg.IconId or self.DEFAULT_ICON
	store.content = cfg.DisasterName
	store.rightIconId = 0
end

M.RefreshFactionInfluenceChange = function(self, store, data, info)
	store.LineModeCtrl = 0
	local cfg = LTConfig.FactionConfig.GetConfig(data.FactionId)

	if not cfg then
		print_error("RefreshFactionChange error, FactionConfig 找不到配表数据，id=", data.FactionId)

		return
	end

	store.mainTitle = cfg.name
	store.iconId = cfg.imageId
	store.leftContent = LTConfig.TextScriptTextConfig.GetConfig(89901217).Text
	store.rightContent = data.nInfluence .. "/" .. LTConfig.FactionConfig.InfluenceMaxValue
	store.progressValue = data.nInfluence / LTConfig.FactionConfig.InfluenceMaxValue
	local ret = {}

	table.insert(ret, {
		lContent = LTConfig.TextScriptTextConfig.GetConfig(89901218).Text,
		rContent = data.nInfluence - data.cInfluence
	})

	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderDeliveryEndItem", ret)

	store.list:SetSimpleList(#ret)
end

M.RefreshNewBubbleMessage = function(self, store, data, info)
	local info = data.info
	local text = ""
	store.ShowTypeCtrl = 0
	local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(LTConfig.MobileMenuSGuiConfig.SocialMediaId)

	if info.Type ~= MomentsNotifyType.Npc then
		text = SocialMediaConfig.NpcNewPostTipText
	elseif info.Type ~= MomentsNotifyType.Player then
		text = gString.Format(SocialMediaConfig.PlayerNewPostTipText, info.LikeCount)
	elseif info.Type ~= MomentsNotifyType.Daily then
		text = gString.Format(SocialMediaConfig.DailyNewPostTipText, info.PostCount)
		store.leftIconId = mobileMenuSGuiCfg and mobileMenuSGuiCfg.SIconId or 0
		store.rightIconId = 0
		store.content = text
		store.mainTitle = SocialMediaConfig.DailyNewPostTipTitle

		return
	end

	if data.withMeCount <= 0 then
		text = SocialMediaConfig.NewPostWithMe
	end

	local npccount = info.NpcIds and #info.NpcIds or 0

	for i = 1, npccount do
		local headIcon, _ = gNpcFavorManager:GetAgentTypeHeadInfo(info.NpcIds[i], 0)
		store.leftIconId = headIcon or self.DEFAULT_ICON
		store.mainTitle = gNpcFavorManager:GetAgentName(info.NpcIds[i])
	end

	store.content = text
	store.rightIconId = mobileMenuSGuiCfg and mobileMenuSGuiCfg.SIconId or 0
end

M.RefreshNewNpcChatMessage = function(self, store, data, _)
	local info = data.info

	if data.popupKey then
		gNpcChatUtils.MarkPopupRendered(data.popupKey)
	end

	local top = info.topChannelId
	local sub = info.subChannelId
	local cfg = info.chatCfg
	local rawText = gNpcChatUtils.GetMessage(cfg) or cfg.MessageText or ""
	local previewText = gClientUtils.RichTextToPlain(rawText)
	store.content = previewText

	if top ~= gNpcChatConst.ChatTopChannel.Npc then
		if sub ~= gNpcChatConst.PlayerSelfIndex then
			local playerInfo = gPlayerManager.infoLogin.bindData
			store.mainTitle = playerInfo.name
			local _, path = gImageManager:GetHeadIconByHeadIconInfo(playerInfo.infoPzHeadInfo, playerInfo.sexType, true)
			local imgCfg = LTConfig.ImageNewAvatarConfig.GetConfig(path)
			store.leftIconId = (imgCfg or LTConfig.ImageNewAvatarConfig.GetConfig(LTConfig.ImageNewAvatarConfig.AdultMH)).SguiImageId
		else
			local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(sub)
			store.mainTitle = npcChatInfo:GetName()
			store.leftIconId = gNpcChatAvatarUtils:GetIconIdByNpcId(sub)
		end
	elseif top ~= gNpcChatConst.ChatTopChannel.NpcGroup then
		local groupCfg = LTConfig.NPCChatGroupConfig.GetConfig(sub)
		local iconId = LTConfig.NPCChatConfig.DefaultChatGroupNoticeIcon or 0

		if groupCfg.SIcon == 0 then
			iconId = groupCfg.SIcon
		end

		store.mainTitle = gNpcChatUtils.GetNpcGroupDisplayName(sub, false)
		store.leftIconId = iconId
	end

	store.rightIconId = LTConfig.NPCChatConfig.PopUpIconId
end

M.RefreshNewNpcChatMessageTotal = function(self, store, data, _)
	if data.popupKey then
		gNpcChatUtils.MarkPopupRendered(data.popupKey)
	end

	local info = data.info
	local num = #info
	store.leftIconId = LTConfig.NPCChatConfig.PopUpTotalIconId
	store.rightIconId = 0
	store.mainTitle = LTConfig.NPCChatConfig.PopUpTotalMainTitle
	store.content = string.format(LTConfig.NPCChatConfig.PopUpTotalContent, num)
end

M.OnClickNpcChatMessageTotal = function(self, info)
	gNpcChatUtils.OpenChatPanel()
end

M.RefreshNewNpcGroupChatMessage = function(self, store, data, _)
	local info = data.info

	if data.popupKey then
		gNpcChatUtils.MarkPopupRendered(data.popupKey)
	end

	local top = info.topChannelId
	local sub = info.subChannelId
	local cfg = info.chatCfg
	local rawText = gNpcChatUtils.GetMessage(cfg) or cfg.MessageText or ""
	local previewText = gClientUtils.RichTextToPlain(rawText)
	store.content = previewText

	if top ~= gNpcChatConst.ChatTopChannel.NpcGroup then
		local groupCfg = LTConfig.NPCChatGroupConfig.GetConfig(sub)

		if groupCfg.SIcon == 0 then
			print_error("RefreshNewNpcGroupChatMessage error, SIcon is not 0, id=", groupCfg.SIcon)
		else
			local groupMember = gNpcChatAvatarUtils:GetGroupMembersFromCfg(groupCfg)

			if #groupMember ~= 3 then
				store.groupIconCtrl = 0
			elseif #groupMember ~= 4 then
				store.groupIconCtrl = 1
			elseif #groupMember <= 4 then
				store.groupIconCtrl = 2
			end

			for i = 1, math.min(#groupMember, 4) do
				local senderId = groupMember[i]

				gNpcChatAvatarUtils:SetIconBySenderIdNew(store, "groupIcon" .. i, senderId)
			end
		end

		store.mainTitle = gNpcChatUtils.GetNpcGroupDisplayName(sub, false)
	end

	store.rightIconId = LTConfig.NPCChatConfig.PopUpIconId
end

M.RefreshSocialNetworkAdded = function(self, store, _)
	store.ShowTypeCtrl = 0
	store.mainTitle = LTConfig.TextScriptTextConfig.GetConfig(89901229).Text
	store.content = LTConfig.TextScriptTextConfig.GetConfig(89901230).Text
	store.leftIconId = LTConfig.TuiteConfig.PopupSocialNetworkIcon
	store.rightIconId = 0
end

M.RefreshSocialNetworkAddedTotal = function(self, store, data)
	store.ShowTypeCtrl = 0
	store.mainTitle = LTConfig.TextScriptTextConfig.GetConfig(89901225).Text
	store.content = LTConfig.TextScriptTextConfig.GetConfig(89901226).Text:format(data.count)
	store.leftIconId = LTConfig.TuiteConfig.PopupSocialNetworkIcon
	store.rightIconId = 0
end

M.RefreshNewContactAddedTotal = function(self, store, data)
	local count = data.count
	store.ShowTypeCtrl = 0
	store.mainTitle = LTConfig.TextScriptTextConfig.GetConfig(89901227).Text
	store.content = LTConfig.TextScriptTextConfig.GetConfig(89901228).Text:format(count)
	store.leftIconId = LTConfig.PhoneConfig.PopupContactIcon
	store.rightIconId = 0
end

M.RefreshFakeDeliveryEnd = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.leftIconId = data.leftIconId
	store.rightIconId = 0
	store.content = data.content
	store.mainTitle = data.mainTitle
end

M.RefreshBaseVehicleInfo = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.leftIconId = data.SVehicleBrandSmallIcon or info.cfg.IconList[1] or self.DEFAULT_ICON
	store.rightIconId = 0
	local typeCfg = gDriveVehiclesManager:GetVehicleTypeConfig(data.VehicleType)
	store.mainTitle = data.VehicleName
	store.content = typeCfg and typeCfg.DisplayName or ""
end

M.RefreshPoliceArchiveNormalTip = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	local agentId = data and data.agentId or 0
	local info = gPoliceJobManager.panelMgr:GetAgentInfo(agentId)
	store.leftIconId = not table.isNilOrEmpty(info) and info.icon or self.DEFAULT_ICON
	store.rightIconId = 0
	store.mainTitle = info and info.name or ""
	store.content = LTConfig.PoliceConfig.FakeFileTipDisplayTitle or ""
end

M.RefreshTalentPointTip = function(self, store, data, info)
	local jobId = data.jobId
	local cfg = UrbanJobConfig.GetConfig(jobId)

	if not cfg and jobId == 0 then
		return
	end

	store.ShowTypeCtrl = 0
	store.rightIconId = 0
	store.mainTitle = TextScriptTextConfig.GetConfig(89901252).Text

	if jobId ~= 0 then
		local headIcon = gNpcFavorManager:GetAgentTypeHeadInfo(data.agentType, 0)
		store.leftIconId = headIcon ~= 0 and self.DEFAULT_ICON or headIcon
		store.content = gString.Format(TextScriptTextConfig.GetConfig(89901253).Text, gNpcFavorManager:GetAgentName(data.agentType), data.diff)
	else
		local cCfg = UrbanJobJobClassConfig.GetConfig(cfg.JobClass)
		store.leftIconId = cfg.Icon or self.DEFAULT_ICON
		store.content = gString.Format(TextScriptTextConfig.GetConfig(89901253).Text, cCfg.ClassName, data.diff)
	end
end

M.RefreshPoliceArchiveNewPointTip = function(self, store, data, info)
	store.content = gString.Format(TextScriptTextConfig.GetConfig(89901254).Text, gUIUtils:GetNumberStr(data.point))
end

M.RefreshDivinerReward = function(self, store, data, info)
	store.mainTitle = data.mainTitle
	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderDivinerRewardItem", data.listData)

	store.list:SetSimpleList(#data.listData)
end

M.OnRenderDivinerRewardItem = function(self, list, btn, index)
	local store = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):GetStoreByWidget(btn)
	local data = list[index + 1]

	if store and data then
		store.iconId = 0
		store.leftContent = data.leftContent
		store.rightContent = data.rightContent
	end
end

M.RefreshUrbanAbilityJobBadgeTips = function(self, store, data, info)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.TemplateId)
	store.ShowTypeCtrl = 0
	store.leftIconId = cfg.Image
	store.mainTitle = cfg.Name
	store.content = gString.Format(TextScriptTextConfig.GetConfig(89901256).Text)
	store.rightIconId = 0
end

M.RefreshPOIArea = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.rightIconId = 0
	store.leftIconId = info.cfg.IconList[1] or self.DEFAULT_ICON
	store.content = data.poiName
	store.mainTitle = LTConfig.TextConfig.GetConfig(73970626).Text
end

M.RefreshMapSafeArea = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.rightIconId = 0
	store.leftIconId = info.cfg.IconList[1] or self.DEFAULT_ICON
	store.content = LTConfig.TextCommonTextConfig.GetConfig(74000909).Text
	store.mainTitle = LTConfig.TextConfig.GetConfig(73970626).Text
end

M.RefreshMapDangerArea = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.rightIconId = 0
	store.leftIconId = info.cfg.IconList[1] or self.DEFAULT_ICON
	store.content = LTConfig.TextCommonTextConfig.GetConfig(74000910).Text
	store.mainTitle = LTConfig.TextCommonTextConfig.GetConfig(74000911).Text
end

M.GetSpiritTalentExpInfoByMsg = function(self, data)
	if data.exp ~= nil or data.level ~= nil then
		return gTalentTreeMgr:GetCurrentExpInfo(data.spiritId)
	end

	local cfg = TalentTreeLevelConfig.GetConfig(data.level)

	if not cfg or data.level ~= TalentTreeLevelConfig.count then
		return 0, 0, data.level
	end

	return data.exp, cfg.Exp, data.level
end

M.RefreshAgentTalentExpTip = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.rightIconId = 0

	if data.spiritId ~= 0 then
		store.leftIconId = LTConfig.TalentTreeConfig.CommonTalentPopupIcon
		store.mainTitle = LTConfig.TalentTreeConfig.CommonTalentPopupStr
		store.content = gUIUtils:GetNumberStr(data.diff)

		return
	end

	local currentExp, maxExp, level = self:GetSpiritTalentExpInfoByMsg(data)
	store.mainTitle = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901296).Text, level)
	local headIcon, _ = gNpcFavorManager:GetAgentFightSpiritHeadInfo(data.spiritId, 0)
	store.leftIconId = headIcon ~= 0 and self.DEFAULT_ICON or headIcon

	if currentExp ~= maxExp then
		store.content = TextScriptTextConfig.GetConfig(89901297).Text
	else
		store.content = currentExp .. "/" .. maxExp
	end
end

M.RefreshEvacuationPlace = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.rightIconId = 0
	store.leftIconId = info.cfg.IconList[1] or self.DEFAULT_ICON
	store.content = LTConfig.ExtractionShooterConfig.EnterEvacuationPlaceDesc
	store.mainTitle = LTConfig.ExtractionShooterConfig.EnterEvacuationPlaceTitle
end

M.RefreshBeggarReward = function(self, store, data, info)
	local jobName = ""
	local progressValue = 0
	local addExp = data.jobExp
	local rContent = addExp > 0 and "+" .. addExp or "-" .. addExp
	local spiritJob = data.spiritJob
	local levelCfg = data.levelCfg
	local cfg = data.cfg

	if spiritJob == nil and levelCfg == nil and cfg == nil then
		local curExp = spiritJob.Exp
		local maxExp = levelCfg.Exp

		if maxExp ~= nil or maxExp ~= 0 then
			progressValue = 1
			rContent = rContent .. "   MAX"
		else
			rContent = rContent .. "   " .. curExp .. "/" .. maxExp
			progressValue = math.min(curExp, maxExp) / maxExp
		end

		jobName = cfg.Name
	end

	store.LineModeCtrl = 1
	store.iconId = LTConfig.BeggarConfig.PopupRewardIcon
	store.mainTitle = LTConfig.BeggarConfig.PopupRewardMainTitle
	store.subTitle = LTConfig.BeggarConfig.PopupRewardSubTitle
	store.progressValue = progressValue
	store.leftContent = jobName
	store.rightContent = rContent
	local list = {}

	table.insert(list, {
		lContent = LTConfig.BeggarConfig.PopupRewardMoneyTitle,
		rContent = data.money or 0
	})

	local minutes = math.floor(data.time / gClientConst.SECONDS_PER_MINUTE)
	local seconds = data.time % gClientConst.SECONDS_PER_MINUTE

	table.insert(list, {
		lContent = LTConfig.BeggarConfig.PopupRewardTimeTitle,
		rContent = string.format("%02d:%02d", minutes, seconds)
	})

	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderBeggarRewardItem", list)

	store.list:SetSimpleList(#list)
end

M.GetBeggarLevelExp = function(self, config)
	local levelCfg = gSpiritJobManager:GetLevelConfig(config)

	if levelCfg then
		return levelCfg.Exp
	end

	return 0
end

M.OnRenderBeggarRewardItem = function(self, list, btn, index)
	local store = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):GetStoreByWidget(btn)
	local data = list[index + 1]

	if store and data then
		store.leftContent = data.lContent
		store.rightContent = data.rContent
	end
end

M.RefreshMARumorNormalTip = function(self, store, data, info)
	store.ShowTypeCtrl = 0
	store.leftIconId = LTConfig.MartialArtistConfig.NewRumorIcon or 0
	store.mainTitle = LTConfig.MartialArtistConfig.NewRumorTitle
	local cfg = LTConfig.MartialArtistRumorConfig.GetConfig(data.rumorId)
	store.content = cfg.Title or ""
end

M.RefreshCombatPowerChanged = function(self, store, data, info)
	local tId = data.tId
	local pre = data.pre
	local curr = data.curr
	local cfg = LTConfig.FightSpiritConfig.GetConfig(tId)
	local up = pre <= curr
	store.ShowTypeCtrl = 0
	store.leftIconId = cfg and cfg.SHeadIconID or self.DEFAULT_ICON
	store.mainTitle = up and info.cfg.TextList[1] or info.cfg.TextList[2] or ""
	store.content = string.format("%s->%s", pre, curr)
	store.rightIconId = up and info.cfg.IconList[1] or info.cfg.IconList[2] or 0
end

M.RefreshNightRunSettlement = function(self, store, data, info)
	local rows = {
		{
			titleId = LTConfig.PopupConfig.NightRunDistanceTextId,
			content = gNightRunManager:FormatDistance(data.distance)
		},
		{
			titleId = LTConfig.PopupConfig.NightRunDurationTextId,
			content = gNightRunManager:FormatDuration(data.duration)
		},
		{
			titleId = LTConfig.PopupConfig.NightRunTrackTextId,
			contentTextId = data.trackNameTextId
		}
	}
	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderNightRunSettlementItem", rows)

	store.list:SetSimpleList(#rows)
end

M.OnRenderNightRunSettlementItem = function(self, list, btn, index)
	local store = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):GetStoreByWidget(btn)
	local data = list[index + 1]

	if not store or not data then
		return
	end

	store.leftContent = data.titleId or ""

	if data.contentTextId then
		local contentCfg = LTConfig.TextCommonTextConfig.GetConfig(data.contentTextId)
		store.rightContent = contentCfg and contentCfg.Text or ""
	else
		store.rightContent = data.content or ""
	end
end

gPopupAreaFiveDataRefresh = gPopupAreaFiveDataRefresh or C_PopupAreaFiveDataRefresh.new()
