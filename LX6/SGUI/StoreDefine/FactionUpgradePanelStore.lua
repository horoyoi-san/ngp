-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FactionUpgradePanelStore.lua
-- Decompiled from: 01861_FactionUpgradePanelStore.lua_5bac2796ebe1.luajit

local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
C_FactionUpgradePanelStore = DefClass("C_FactionUpgradePanelStore", C_FactionUpgradePanelStore, C_StoreGroup)
GroupName2Class.FactionUpgradePanelStore = C_FactionUpgradePanelStore
local M = C_FactionUpgradePanelStore
local DispositionConfig = LTConfig.FactionDispositionConfig
local FactionConfig = LTConfig.FactionConfig
local ScriptTextConfig = LTConfig.TextScriptTextConfig
local TextConfig = LTConfig.TextConfig
local Time = Time
local POLICE_ID = 18000110
EFactionUpgradeTableItem = {
	["\\x89\\xa4\\xad^'\\xee6"] = 2,
	["\\xbb=3/w\\x8eH\\xcd>\\xa5\\xb7"] = 0,
	["X7{]"] = 1,
	["h\\xa3\\xb2\\xbb\\xaf"] = 3
}

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.levelChangeHandler = self.CreateAction(self, "OnFactionLevelChanged")
	self.bindData.attitudeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderAttitudeItem")
	self.bindData.effectNameList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderEffectNameItem")
	self.bindData.effectContentList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderEffectItem")
	self.bindData.clickLeft = self.CreateAction(self, "OnClickControllerLeft")
	self.bindData.clickRight = self.CreateAction(self, "OnClickControllerRight")
	self.bindData.clickPcAttitudeLeft = self.CreateAction(self, "OnClickAttitudeToLeftest")
	self.bindData.clickPcAttitudeRight = self.CreateAction(self, "OnClickAttitudeToRightest")
	self.bindData.customLeftStick.luaGamePadInputChanged = self.CreateAction(self, "OnLeftJoyStickMove")
end

M.OnShow = function(self, panelId, data)
	self.RegisterSingleEvent(self, gEventConstants.FACTION_LEVEL_CHANGE, self.levelChangeHandler)

	local factionId = data.factionId
	self.factionId = factionId
	self.selectedPanelInited = false
	self.leftJsTriggerTime = nil

	self.Refresh(self)
end

M.OnClose = function(self)
	self.attitudeBtnCache = nil
	self.effectInnerData = nil
	self.attitudeList = nil
	self.effectNameList = nil
	self.effectContentList = nil

	self.ClearMessageEvents(self)
end

M.Refresh = function(self)
	local cfg = FactionConfig.GetConfig(self.factionId)
	self.bindData.desc = cfg.ChangeDescription
	self.factionInfo = gClientUtils.GetFactionInfo(self.factionId)
	local curLevel = self.factionInfo.DispositionLevel
	local levelCfg = DispositionConfig.GetConfig(curLevel)
	self.bindData.curAttitude = levelCfg and levelCfg.name or ""
	self.bindData.attitudeIcon = levelCfg.DispositionIcon
	self.bindData.title = cfg.LevelEffectTitle
	local levelEffects = cfg.LevelEffect

	self:SetUpListsData(levelEffects)
end

local ONLY_LEFT = 1
local ONLY_RIGHT = 2
local SHOW_BOTH = 0
local BG_ODD = 1
local BG_EVEN = 0

M.OnLateUpdate = function(self)
	if not self.selectedPanelInited then
		if not self.attitudeList or not self.bindData.attitudeList or self.bindData.attitudeList.items.Count ~= 0 or not self.effectContentList or not self.bindData.effectContentList or self.bindData.effectContentList.items.Count ~= 0 then
			return
		end

		self.bindData.attitudeList:GoToIndex(self.factionInfo.DispositionLevel - 1, true)
		self.bindData.effectContentList:GoToIndex((self.factionInfo.DispositionLevel - 1) * self.bindData.effectContentList.rowCount + 1, true)
		self:SetSelectedPanel(self.factionInfo.DispositionLevel)

		self.selectedPanelInited = true
	else
		if not self.referBtn then
			return
		end

		local list = self.bindData.attitudeList
		local paddingx = list.items[1].transform.position.x - list.items[0].transform.position.x
		local posX = self.referBtn.transform.position.x
		local posY = self.referBtn.transform.position.y
		posX = posX + paddingx * (self.selectedLevel + 0.5 - self.referIndex)

		self.bindData.selectedPanel.rectTransform:SetPositionXY(posX, posY)

		local attitudePos = list.normalizedScrollPosition.x

		if attitudePos >= 0.05 then
			self.bindData.attitudeArrowState = ONLY_RIGHT
		elseif attitudePos <= 0.95 then
			self.bindData.attitudeArrowState = ONLY_LEFT
		else
			self.bindData.attitudeArrowState = SHOW_BOTH
		end
	end

	if self.leftJsInput and math.abs(self.leftJsInput.x) <= 0.3 then
		if not self.leftJsTriggerTime or self.leftJsTriggerTime < Time.time then
			if self.leftJsInput.x <= 0 then
				self.OnClickControllerRight(self)
			else
				self.OnClickControllerLeft(self)
			end

			if not self.leftJsTriggerTime then
				self.leftJsTriggerTime = Time.time + 0.5
			else
				self.leftJsTriggerTime = Time.time + 0.2
			end
		end
	else
		self.leftJsTriggerTime = nil
	end
end

local COLOR_GREEN = 0
local COLOR_RED = 1

M.SetUpListsData = function(self, levelEffects)
	self.attitudeList = {}
	self.effectNameList = {}
	self.effectContentList = {}

	for i = 1, 5 do
		local data = {
			level = i,
			current = i ~= self.factionInfo.DispositionLevel
		}

		table.insert(self.attitudeList, data)
	end

	self.bindData.attitudeList:SetSimpleList(5)

	for i = 1, #levelEffects do
		local effect = levelEffects[i]
		local effectCfg = FactionConfig.GetConfig(effect)

		if effectCfg then
			local data = {
				title = effectCfg.EffectName,
				icon = effectCfg.EffectIcon
			}

			table.insert(self.effectNameList, data)
		else
			print_error("@yuzhichen Faction升级界面:不存在Id为" .. effect .. "的FactionLevelEffectConfig配置")
		end
	end

	self.bindData.effectNameList:SetSimpleList(#levelEffects)

	for i = 1, 5 do
		for j = 1, #levelEffects do
			local effect = levelEffects[j]
			local effectCfg = FactionConfig.GetConfig(effect)

			if effectCfg then
				local data = {
					level = i,
					row = j,
					title = self:GetLevelEffectContent(effectCfg, i),
					color = i < 2 and COLOR_RED or COLOR_GREEN
				}

				table.insert(self.effectContentList, data)
			else
				print_error("@yuzhichen Faction升级界面:不存在Id为" .. effect .. "的FactionLevelEffectConfig配置")
			end
		end
	end

	self.bindData.effectContentList.rowCount = #levelEffects
	self.bindData.effectContentList.colCount = 5

	self.bindData.effectContentList:SetSimpleList(5 * #levelEffects)
end

local SHOW_BTN = 0
local HIDE_BTN = 1
local TYPE_CURRENT = 0
local TYPE_PREV = 2
local TYPE_AFTER = 1
local UPGRADE_TEXT_ID = 89900242
local FANS_NOT_ENOUGH_TEXT_ID = 73971100
local MONEY_NOT_ENOUGH_TEXT_ID = 89901323

M.SetSelectedPanel = function(self, level)
	local store = gStoreManager:GetStoreGroup("FactionUpgradeSelected"):GetStoreByWidget(self.bindData.selectedPanel)
	local curLevel = self.factionInfo.DispositionLevel
	local levelCfg = DispositionConfig.GetConfig(level)
	local factionCfg = FactionConfig.GetConfig(self.factionId)
	local levelEffects = factionCfg.LevelEffect
	local upgradeText = ScriptTextConfig.GetConfig(UPGRADE_TEXT_ID).Text
	local fansNotEnoughText = TextConfig.GetConfig(FANS_NOT_ENOUGH_TEXT_ID).Text
	self.selectedBuffList = {}

	for i = 1, #levelEffects do
		local effect = levelEffects[i]
		local effectCfg = FactionConfig.GetConfig(effect)

		if effectCfg then
			table.insert(self.selectedBuffList, {
				title = self:GetLevelEffectContent(effectCfg, level),
				color = level < 2 and COLOR_RED or COLOR_GREEN
			})
		end
	end

	store.buffList.luaSimpleRenderItem = self:CreateAction("OnRenderSelectedBuffItem")

	store.buffList:SetSimpleList(#levelEffects)

	store.iconId = levelCfg.DispositionIcon
	store.attitude = levelCfg and levelCfg.name or ""

	if self.factionId ~= POLICE_ID then
		store.showUpgrade = HIDE_BTN
		store.type = TYPE_PREV
		self.selectedLevel = level

		return
	elseif curLevel >= level then
		local fanNum = gPlayerManager.infoMinor.bindData.fan123
		local requireFan = 0

		if factionCfg.DonateUnlockFan then
			for j = 1, #factionCfg.DonateUnlockFan do
				local fanCfg = factionCfg.DonateUnlockFan[j]

				if fanCfg.DispositonLevel ~= level then
					requireFan = fanCfg.Fan

					break
				end
			end
		end

		local cost = self.CalcMoney(self, self.factionInfo, level)
		store.cost = tostring(cost)
		store.showUpgrade = SHOW_BTN
		store.type = TYPE_AFTER
		store.upgradeBtn.luaClick = self.CreateActionWithArgs(self, "OnClickUpgrade", level)

		if fanNum >= requireFan then
			local fanCountText = gUIUtils:BuildLargeNumStr(requireFan)
			local fanNotEnoughText = string.gsub(fansNotEnoughText, "%[fans%]", fanCountText)
			store.mainBtnText = fanNotEnoughText
			store.btnState = 4
			store.interactable = false
		elseif gPlayerManager.infoItem.bindData.money >= cost then
			local moneyNotEnoughText = ScriptTextConfig.GetConfig(MONEY_NOT_ENOUGH_TEXT_ID).Text
			store.mainBtnText = moneyNotEnoughText
			store.btnState = 4
			store.interactable = false
		else
			store.mainBtnText = upgradeText
			store.btnState = 0
			store.interactable = true
		end
	elseif level ~= curLevel then
		store.showUpgrade = HIDE_BTN
		store.type = TYPE_CURRENT
	else
		store.showUpgrade = HIDE_BTN
		store.type = TYPE_PREV
	end

	self.selectedLevel = level
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.FACTION_UPGRADE_PANEL)
end

M.OnClickRightsBtn = function(self, level)
	self.SetSelectedPanel(self, level)
end

M.OnClickAttitudeItem = function(self, level)
	self.SetSelectedPanel(self, level)
end

M.OnClickUpgrade = function(self, targetLevel)
	local messageId = FactionConfig.DonationPopupText

	if not messageId or messageId ~= 0 then
		print_error("FactionUpgradePanel: DonationPopupText is empty")

		return
	end

	local cost, levelName = self:GetUpgradeMessageArgs(targetLevel)
	slot5 = gDisplayMessageMgr

	slot5:ShowMessage(messageId, function ()
		self:OnClickConfirmUpgrade(self.factionId, targetLevel)
	end, nil, cost, levelName)
end

M.OnClickConfirmUpgrade = function(self, factionId, targetLevel)
	slot3 = gClientToGameDelegate

	slot3:DonateFactionByCfgId(factionId, targetLevel).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			if err ~= LTConfig.MessageConfig.MoneyNotEnough then
				print_error("#NoCreateIssue:势力捐款升级:DonateFactionByCfgId error", gCS.Error.GetNameById(err))

				return
			else
				print_error("势力捐款升级:DonateFactionByCfgId error", gCS.Error.GetNameById(err))
			end
		else
			return
		end

		print("势力捐款升级:OnClickConfirmUpgrade success", factionId)
		self:Refresh()
	end
end

M.OnFactionLevelChanged = function(self)
	self.Refresh(self)
	self.SetSelectedPanel(self, self.selectedLevel)
end

M.OnRenderAttitudeItem = function(self, btn, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup("MapFactionAnonymousStore"):GetStoreByWidget(btn)
	store.attitude = self.attitudeList[index].level - 1
	store.current = self.attitudeList[index].current and 1 or 0
	btn.luaClick = self:CreateActionWithArgs("OnClickAttitudeItem", index)
	self.referBtn = btn
	self.referIndex = index
end

M.OnRenderEffectNameItem = function(self, btn, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup("MapFactionAnonymousStore"):GetStoreByWidget(btn)
	store.title = self.effectNameList[index].title
	store.iconId = self.effectNameList[index].icon
end

local EMPTY_TYPE = 0
local CONTENT_TYPE = 1

M.OnRenderEffectItem = function(self, btn, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup("MapFactionAnonymousStore"):GetStoreByWidget(btn)
	local data = self.effectContentList[index]
	btn.luaClick = self:CreateActionWithArgs("OnClickRightsBtn", data.level)

	if data.row % 2 ~= 0 then
		store.bgColor = BG_EVEN
	else
		store.bgColor = BG_ODD
	end

	if string.is_null_or_empty(data.title) then
		store.type = EMPTY_TYPE

		return
	end

	store.type = CONTENT_TYPE

	if not self.effectInnerData then
		self.effectInnerData = {}
	end

	self.effectInnerData[index] = data
	store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderEffectInnerListItem", index)

	store.list:SetSimpleList(1)
end

M.OnRenderEffectInnerListItem = function(self, dataIndex, btn, _)
	local store = gStoreManager:GetStoreGroup("MapFactionAnonymousStore"):GetStoreByWidget(btn)
	local data = self.effectInnerData[dataIndex]
	store.title = data.title
	store.color = data.color
end

local SELECT_EMPTY_COLOR = 2

M.OnRenderSelectedBuffItem = function(self, btn, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup("MapFactionAnonymousStore"):GetStoreByWidget(btn)
	local data = self.selectedBuffList[index]

	if not data or string.is_null_or_empty(data.title) then
		store.title = "-"
		store.color = SELECT_EMPTY_COLOR

		return
	end

	store.color = data.color
	store.title = data.title and data.title or "-"
end

M.OnClickControllerLeft = function(self)
	if not self.selectedPanelInited then
		return
	end

	local level = Mathf.Clamp(self.selectedLevel - 1, 1, 5)

	if level == self.selectedLevel then
		self:SetSelectedPanel(level)
		self.bindData.attitudeList:GoToIndex(level - 1, true)
		self.bindData.effectContentList:GoToIndex((level - 1) * self.bindData.effectContentList.rowCount + 1, true)
	end
end

M.OnClickControllerRight = function(self)
	local level = Mathf.Clamp(self.selectedLevel + 1, 1, 5)

	if level == self.selectedLevel then
		self:SetSelectedPanel(level)
		self.bindData.attitudeList:GoToIndex(level - 1, true)
		self.bindData.effectContentList:GoToIndex((level - 1) * self.bindData.effectContentList.rowCount + 1, true)
	end
end

M.OnClickAttitudeToRightest = function(self)
	self.bindData.attitudeList:GoToIndex(4, true)
end

M.OnClickAttitudeToLeftest = function(self)
	self.bindData.attitudeList:GoToIndex(0, true)
end

M.OnLeftJoyStickMove = function(self, ctx)
	if ctx.canceled then
		self.leftJsInput = nil
		self.leftJsTriggerTime = nil
	elseif ctx.performed then
		self.leftJsInput = ctx.ReadValueVector2(ctx)
	end
end

M.GetUpgradeMessageArgs = function(self, targetLevel)
	local levelCfg = DispositionConfig.GetConfig(targetLevel)

	if not levelCfg then
		print_error("FactionUpgradePanel: GetUpgradeMessageArgs: DispositionConfig is empty", targetLevel)

		return 0, ""
	end

	if not self.factionInfo then
		print_error("FactionUpgradePanel: GetUpgradeMessageArgs: factionInfo is empty")

		return 0, levelCfg.name or ""
	end

	local money = self:CalcMoney(self.factionInfo, targetLevel)

	return money, levelCfg.name or ""
end

M.GetLevelEffectContent = function(self, cfg, level)
	if level ~= 1 then
		return cfg.hatredDescription or nil
	elseif level ~= 2 then
		return cfg.hostilityDescription or nil
	elseif level ~= 3 then
		return cfg.indifferentDescription or nil
	elseif level ~= 4 then
		return cfg.friendlyDescription or nil
	elseif level ~= 5 then
		return cfg.worshipDescription or nil
	end

	print_error("FactionUpgradePanel: Wrong level: " .. level)

	return nil
end

M.CalcMoney = function(self, factionInfo, targetLevel)
	local curLevel = factionInfo.DispositionLevel

	if targetLevel < curLevel then
		print_error("FactionUpgradePanel: CalcMoney: 当前等级已经大于等于目标等级")

		return 0
	end

	local curDisposition = factionInfo.Disposition
	local dispositionCfg = DispositionConfig.GetConfig(targetLevel)

	if not dispositionCfg then
		print_error("FactionUpgradePanel: CalcMoney: 不存在目标等级的DispositionConfig配置")

		return 0
	end

	return Formula_cs:CalcDonateMoneyForFactionLevelUp(curDisposition, dispositionCfg.DispositionValue)
end
