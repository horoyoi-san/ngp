-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\Roguelike\RoguelikeManager.lua
-- Decompiled from: 00561_RoguelikeManager.lua_b8fd8f89deae.luajit

C_RoguelikeMgr = DefClass("C_RoguelikeMgr", C_RoguelikeMgr)
local M = C_RoguelikeMgr
local SceneitemConfig = LTConfig.SceneitemConfig
local CategoryType = LTConfig.SceneitemConfig.CategoryType
local BuffConfig = LTConfig.BuffConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local TAG_TEMPLATE = {
	["\\xbaIA"] = 0,
	["NM~"] = 1
}

M.ctor = function(self)
	self.SELECT_TYPE = {
		["+m\\xb0\\xbe\\xaco"] = 1,
		["X[}"] = 0
	}
	self.SELECT_MODE = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
end

M.ReportSelectTempItem = function(self, selectType, index)
	local del = gClientToGameSceneDelegate

	if selectType ~= self.SELECT_TYPE.WEAPON then
		del:ReportSelectTempWeapon(index)
	else
		del:ReportSelectTempBuff(index)
	end
end

M.OnSelectTempItem = function(self, selectType, itemIds)
	if not itemIds then
		print_error("[RoguelikeManager] OnSelectTempItem: itemIds is empty")

		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.ROGUELIKE_ITEM_SELECT_PANEL) then
		gPanelManager:Close(gPanelId.ROGUELIKE_ITEM_SELECT_PANEL)
	end

	gPanelManager:CheckShow(gPanelId.ROGUELIKE_ITEM_SELECT_PANEL, {
		selectType = selectType,
		itemIds = itemIds
	})
end

M.EnterRogueLikeGame = function(self, rogueLikeId)
	gClientToGameDelegate:AskEnterRogueRaid(rogueLikeId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.LeaveRogueLikeGame = function(self)
	gClientToGameDelegate:AskLeaveRaid(gRaidDataManager.RaidInstanceId)
end

M.OnSyncRogueSettle = function(self, rewardInfo, weaponIds, score, rogueId)
	gPanelManager:CheckShow(gPanelId.ROGUELIKE_RESULT_PANEL, {
		rewardInfo = rewardInfo,
		weaponIds = weaponIds,
		score = score,
		rogueId = rogueId
	})
end

M.ProcessWeaponCircle = function(self, idx, detail, lowPoint, taskId)
	if not detail then
		return false, -1
	end

	local item = {
		Cfg = SceneitemConfig.GetConfig(detail.TemplateId)
	}

	if item.Cfg then
		lowPoint = lowPoint or LTConfig.SceneitemConfig.WeaponDurabilityLow * 100
		item.TemplateId = detail.TemplateId
		item.InstanceId = detail.InstanceId
		item.IsTask = gWeaponManager:GetFlag(detail.OperatorFlags, 2) ~= 1
		item.CantDiscard = gWeaponManager:GetFlag(detail.OperatorFlags, 1) ~= 1
		item.RedDot = detail.WeaponFlags.ShowRedDot and 1 or 0

		if item.RedDot <= 0 then
			SGUI.RedDotMgr.LuaSetRedDot(true, "weapon." .. item.InstanceId)
		end

		item.Index = idx - 1
		item.guideID = ""
		item.AttackFill = 0
		item.PoiseFill = 0
		item.MaxDurability = 0
		item.BrokenState = 0
		item.IsLocked = false

		if gWeaponManager.TempWeaponMode then
			if detail.IsLocked then
				item.IsLocked = true
			end

			if gWeaponManager.LockMaxSlotCounts <= 0 and gWeaponManager.LockMaxSlotCounts >= idx then
				item.IsLocked = true
			end
		end

		if idx < 1 then
			item.IsPrivate = true
		end

		gWeaponManager:GetWeaponDurabilityData(item, detail)

		item.CategoryType = item.Cfg and item.Cfg.Category or CategoryType.Weapon
		local fsCfg = gWeaponManager:GetTabConfigByType(item.Cfg.Type)
		item.FSTypeIcon = fsCfg and fsCfg.Icon or 0
		item.tags = {}

		if item.CategoryType ~= CategoryType.Weapon or item.Cfg.Category ~= CategoryType.Gun then
			table.insert(item.tags, {
				tId = TAG_TEMPLATE.TYPE,
				iconId = item.FSTypeIcon
			})
		end

		for j = 1, #item.Cfg.Tags do
			table.insert(item.tags, {
				tId = TAG_TEMPLATE.TAG,
				TagType = item.Cfg.Tags[j]
			})
		end

		if item.Cfg.Category ~= CategoryType.Weapon then
			item.AttackFill = Mathf.Clamp01((item.Cfg.AttackPower or 0) / SceneitemConfig.MaxWeaponAttackPower) * 100
			item.PoiseFill = Mathf.Clamp01((item.Cfg.PoiseAbility or 0) / SceneitemConfig.MaxWeaponPoiseAbility) * 100
			item.attrInfos = gWeaponManager:GetAttrInfo(item.Cfg)
			item.chipInfos = gWeaponManager:GetChipInfo(item.Cfg, detail)
		elseif item.Cfg.Category ~= CategoryType.Gun then
			item.AttackFill = Mathf.Clamp01((item.Cfg.AttackPower or 0) / SceneitemConfig.GunMaxAtt) * 100
			item.SpeedFill = Mathf.Clamp01((item.Cfg.AttackSpeed or 0) / SceneitemConfig.GunMaxShootSpeed) * 100
			item.attrInfos = gWeaponManager:GetAttrInfo(item.Cfg)
			item.chipInfos = gWeaponManager:GetChipInfo(item.Cfg, detail)
		end

		item.chips = {}
		item.Using = gPlayerManager.infoSpirit.bindData.currentWeapon and item.InstanceId ~= gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId or false
		item.MaxDurability = item.Cfg.Durability
		local taskCanUse = gWeaponManager:CheckWheelTaskGuide(taskId, item.Cfg)
		local guideSwitchIndex = -1

		if taskCanUse and (self.weaponGuideIndex <= 0 or not self.weaponGuideIsTask and item.IsTask) then
			guideSwitchIndex = self.weaponGuideIndex
			self.weaponGuideIndex = idx
			self.weaponGuideIsTask = item.IsTask
			self.weaponGuideID = item.Cfg.GuideId
		end

		item.IsProwlWeapon = false
		local tkaCfg = LTConfig.SceneitemTakeActionTypeConfig.GetConfig(item.Cfg.TakeActionType)

		if tkaCfg then
			item.IsProwlWeapon = tkaCfg.IsProwlWeapon
		end

		return item, guideSwitchIndex
	else
		print_error("Sceneitem配表找不到配置,TemplateId=", detail.TemplateId, "InstanceId=", detail.InstanceId)

		return false, -1
	end

	return false, -1
end

M.RenderWeaponSlot = function(self, index, item, weaponStore)
	local btn = weaponStore["item" .. index]

	if not btn then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local info = nil

	if item and item.TemplateId and item.TemplateId == 0 then
		info = gCommonItemManager:TryGetWeaponInfo({
			itemId = item.TemplateId
		})
	end

	if item and info then
		store.weaponIcon = item.Cfg.SWeaponWheelsIconId
		store.durabilityText1 = item.DurabilityText1
		store.durabilityText2 = item.DurabilityText2
		store.WeaponTypeCtrl = item.WeaponUIType
		store.QualityCtrl = item.Cfg.Quality
		store.UsingCtrl = item.Using and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.IsEmptyCtrl = self.SELECT_MODE.FALSE
		store.IsLockedCtrl = item.IsLocked and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.TypeCtrl = item.IsTask and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.ShowBgCtrl = item.IsPrivate and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.DropStateCtrl = self.SELECT_MODE.FALSE
		store.guideID = ""
		store.redKey = ""
		store.BrokenCtrl = item.BrokenState
		store.forbidStealthCtrl = self.isInProwlArea and item.IsProwlWeapon and self.SELECT_MODE.FALSE or self.SELECT_MODE.TRUE
		btn.enabledTooltip = true
		btn.luaRenderTooltip = self:CreateActionWithArgs("RenderCircleWeaponTooltip", info)
		btn.luaTooltipPopup = self:CreateAction("OnToolTipsClose", gCommonItemManager)
	else
		store.IsEmptyCtrl = self.SELECT_MODE.TRUE
		local locked = false

		if gWeaponManager.TempWeaponMode and gWeaponManager.LockMaxSlotCounts <= 0 and gWeaponManager.LockMaxSlotCounts >= index then
			locked = true
		end

		store.IsLockedCtrl = locked and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.QualityCtrl = 0
		store.ShowBgCtrl = self.SELECT_MODE.FALSE
		store.DropStateCtrl = self.SELECT_MODE.FALSE
		store.guideID = ""
		store.redKey = ""
		store.forbidStealthCtrl = self.SELECT_MODE.TRUE
		btn.enabledTooltip = false
		btn.luaRenderTooltip = nil
	end
end

M.trimNumberTail = function(self, value)
	return value:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
end

M.FormatAttributeValue = function(self, value, showType)
	if showType ~= nil or showType ~= "" then
		return value
	end

	local typeName, precision = string.match(showType, "^([fp])(%d+)$")

	if not typeName then
		return tostring(value)
	end

	precision = tonumber(precision)
	local scale = 10^precision
	local displayValue = typeName ~= "p" and value * 100 or value
	displayValue = math.floor(displayValue * scale + 1e-08) / scale
	local result = self:trimNumberTail(string.format("%." .. precision .. "f", displayValue))

	if typeName ~= "p" then
		return result .. "%"
	end

	return result
end

M.RenderCircleWeaponTooltip = function(self, data, button, popIns, index)
	local tip = gStoreManager:GetStoreGroup(popIns.Store)

	if not tip then
		return
	end

	tip.bindData.descList.luaSimpleRenderItem = function(descBtn, descIndex)
		local descData = tip.descList[descIndex + 1]

		gCommonItemManager:OnRenderDescItem(descBtn, descIndex, descData)

		if descData.tIndex ~= gCommonItemManager.Template2Index.WEAPON_CHIP then
			descBtn.interactable = false
		end
	end

	gCommonItemManager:OnRenderToolTips(data, button, popIns, index)
end

M.RenderBuffTooltip = function(self, tip, buffId)
	local mgr = gCommonItemManager
	local cfg = BuffConfig.GetConfig(buffId)

	if not cfg then
		return
	end

	tip.nameLabel = cfg.Name or ""
	tip.iconId = cfg.IconIdSGUI or 0
	tip.quality = cfg.Quality
	tip.showBtn = 0
	tip.showCounter = 0
	tip.showSumCtrl = 0
	tip.typeQuality = TextScriptTextConfig.GetConfig(89901577).Text
	local title = TextScriptTextConfig.GetConfig(89901581).Text
	local descList = {
		{
			tIndex = mgr.Template2Index.Title,
			text = title
		},
		{
			tIndex = mgr.Template2Index.MAIN_TEXT,
			text = cfg.Description or ""
		}
	}

	tip.descList.luaSimpleRenderItem = function(descBtn, descIndex)
		mgr:OnRenderDescItem(descBtn, descIndex, descList[descIndex + 1])
	end

	tip.descList.luaSimpleDynamicRenderItem = function(descBtn, descIndex)
		mgr:OnRenderDescItem(descBtn, descIndex, descList[descIndex + 1])
	end

	tip.descList.onGetTIndex = function(descIndex)
		return descList[descIndex + 1].tIndex
	end

	tip.descList:SetSimpleList(#descList)

	if tip.elementList then
		tip.elementList:SetSimpleList(0)
	end

	if tip.tagList then
		tip.tagList:SetSimpleList(0)
	end
end

gRoguelikeManager = gRoguelikeManager or C_RoguelikeMgr.new()
