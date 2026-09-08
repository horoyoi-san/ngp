-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WeaponRepairPanelStore.lua
-- Decompiled from: 01158_WeaponRepairPanelStore.lua_768a9d4e5ea7.luajit

local SceneitemweaponrepairConfig = LTConfig.SceneitemweaponrepairConfig
C_WeaponRepairPanelStore = DefClass("C_WeaponRepairPanelStore", C_WeaponRepairPanelStore, C_StoreGroup)
GroupName2Class.WeaponRepairPanelStore = C_WeaponRepairPanelStore
local M = C_WeaponRepairPanelStore

M.DefineAllVariables = function(self)
	self.COLOR_TEXT = {
		["j\\x9c\\x87\\x8a\\x98"] = "\\xe8\\xb2U\\xfbL\\xaec",
		["\\xbcMB"] = "\\xe8\\xb2#\\x8d:n\\xaec"
	}
	self.materialList = nil
	self.moneyEnough = false
	self.weapon = nil
	self.isEmpty = true
	self.materialDict = {}
	self.consumeDict = {}
	self.consumeList = {}
	self.weaponList = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.emptyCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.oneOrMoreCtrlEnum = {
		["w-o^"] = 1,
		["\\x81fc"] = 0
	}
	self.checkBoxSelectedCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.qualityEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.emptyCtrlEnum = nil
	self.oneOrMoreCtrlEnum = nil
	self.checkBoxSelectedCtrlEnum = nil
	self.qualityEnum = nil
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
	self.materialDict = nil
	self.consumeDict = nil
	self.consumeList = nil
	self.weaponList = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, list)
	self.moneyEnough = false

	table.clear(self.weaponList)

	if list and #list <= 0 then
		for i = 1, #list do
			local weapon = gWeaponManager:GetWeaponByInstanceId(list[i])

			if weapon then
				local cfg = LTConfig.SceneitemConfig.GetConfig(weapon.TemplateId)

				if cfg then
					local info = {
						cfg = cfg,
						InstanceId = list[i],
						totalRepairVal = cfg.Durability - weapon.Durability
					}
					info.remainRepairVal = info.totalRepairVal
					info.active = true
					info.materials = {}

					table.insert(self.weaponList, info)
				end
			end
		end
	end

	self.InitMaterialTotalCount(self)
	self.RefreshView(self)
	self.RefreshMoneyInfo(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged")
	}
end

M.RegisterWidget = function(self)
	self.bindData.btnBack.luaClick = self.CreateAction(self, "OnClickBtnBack")
	self.bindData.btnRepair.luaClick = self.CreateAction(self, "OnClickBtnRepair")
	self.bindData.checkBoxBtn.luaClick = self.CreateAction(self, "OnClickBtnSelectAll")
	self.bindData.materialList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderMaterialListItem")
	self.bindData.moreList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderMoreListItem")
end

M.OnClickBtnBack = function(self)
	gPanelManager:Close(gPanelId.WEAPON_REPAIR_PANEL)
end

M.OnClickBtnRepair = function(self)
	if self.isEmpty or not self.moneyEnough then
		return
	end

	for i = 1, #self.weaponList do
		local info = self.weaponList[i]

		if not table.isNilOrEmpty(info.materials) then
			slot6 = gClientToGameSceneDelegate

			slot6:AskRepairWeaponWithMaterials(info.InstanceId, info.materials).Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		end
	end

	gPanelManager:Close(gPanelId.WEAPON_REPAIR_PANEL)
end

M.OnClickBtnSelectAll = function(self)
	for i = 1, #self.weaponList do
		self.weaponList[i].active = true
	end

	self.RefreshView(self)
end

M.OnRenderMaterialListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local data = self.consumeList[index + 1]

	if store and data then
		store.iconId = data.cfg.SItemIconId
		store.quality = data.cfg.Quality
		store.consume = data.count
		store.total = gCommonItemManager:GetPackItemNum(data.cfg.Id)
		btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", data.cfg.Id)
	else
		btn.luaRenderTooltip = nil
	end
end

M.OnRenderToolTips = function(self, id, btn, popup)
	local toolTipStore = gStoreManager:GetStoreGroup(popup.Store)

	if toolTipStore then
		toolTipStore.SetSelectedItem(toolTipStore, {
			TemplateId = id
		})
	end
end

M.OnRenderMoreListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local info = self.weaponList[index + 1]

	if store and info then
		store.iconId = info.cfg.SWeaponWheelsIconId
		local fillBefore = (info.cfg.Durability - info.totalRepairVal) / info.cfg.Durability
		local fillAfter = (info.cfg.Durability - info.remainRepairVal) / info.cfg.Durability
		store.fillAmountBefore = fillBefore
		store.fillAmountAfter = info.active and fillAfter or fillBefore
		store.fillPercentBefore = string.format("%d%%", math.floor(fillBefore * 100))
		store.fillPercentAfter = string.format("%d%%", math.floor((info.active and fillAfter or fillBefore) * 100))
		store.checkBoxSelectedCtrl = info.active and self.checkBoxSelectedCtrlEnum._true or self.checkBoxSelectedCtrlEnum._false
		store.checkBoxBtn.luaClick = self:CreateActionWithArgs("OnClickCheckBox", index + 1)
	end
end

M.OnClickCheckBox = function(self, idx)
	local weapon = self.weaponList[idx]

	if weapon then
		weapon.active = not weapon.active

		self.RefreshView(self)
	end
end

M.InitMaterialTotalCount = function(self)
	for i = 0, SceneitemweaponrepairConfig.count - 1 do
		local rCfg = SceneitemweaponrepairConfig.LoadAt(i)

		if rCfg then
			local consumableCfg = LTConfig.ConsumableConfig.GetConfig(rCfg.ConsumableID)

			if consumableCfg then
				self.materialDict[rCfg.ConsumableID] = gCommonItemManager:GetPackItemNum(rCfg.ConsumableID)
			end
		end
	end
end

M.CalcRepairResultGroup = function(self, weaponList)
	table.clear(self.consumeDict)

	for i = 1, #self.weaponList do
		local info = weaponList[i]

		if info.active then
			local cfg = info.cfg
			local remainRepair = info.totalRepairVal
			local quality = cfg.Quality
			local checkList = gWeaponManager:GetWeaponRepairConsumableInOrder(cfg)

			table.clear(info.materials)

			for j = 1, #checkList do
				local check = checkList[j]
				local id = check.consumableCfg.Id
				local count = self.GetRemainMaterialCount(self, id)
				local duarPerUnit = check.repairCfg.Durability[quality]

				if count <= 0 and duarPerUnit then
					local repairValPerUnit = math.floor(duarPerUnit * cfg.Durability)
					local need = math.ceil(remainRepair / repairValPerUnit)

					if need < count then
						info.materials[id] = need

						self.AddMaterialConsume(self, id, need)

						remainRepair = 0

						break
					else
						info.materials[id] = count

						self.AddMaterialConsume(self, id, need)

						remainRepair = remainRepair - count * repairValPerUnit
					end
				end
			end

			info.remainRepairVal = remainRepair
		end
	end

	self.isEmpty = table.is_empty(self.consumeDict)
end

M.GetRemainMaterialCount = function(self, id)
	local max = self.materialDict[id] or 0
	local consume = self.consumeDict[id] or 0

	return math.max(max - consume, 0)
end

M.AddMaterialConsume = function(self, id, count)
	if not self.consumeDict[id] then
		self.consumeDict[id] = 0
	end

	self.consumeDict[id] = self.consumeDict[id] + count
end

M.BuildConsumeList = function(self)
	table.clear(self.consumeList)

	for id, count in pairs(self.consumeDict) do
		local cfg = LTConfig.ConsumableConfig.GetConfig(id)

		table.insert(self.consumeList, {
			cfg = cfg,
			count = count
		})
	end

	table.sort(self.consumeList, function (a, b)
		return a.cfg.Quality <= b.cfg.Quality
	end)
	self.bindData.materialList:SetSimpleList(#self.consumeList)
end

M.RefreshView = function(self)
	if #self.weaponList <= 0 then
		self.CalcRepairResultGroup(self, self.weaponList)

		if #self.weaponList ~= 1 then
			self.bindData.oneOrMoreCtrl = self.oneOrMoreCtrlEnum.one
			local info = self.weaponList[1]
			self.bindData.iconId = info.cfg.SWeaponWheelsIconId
			local fillBefore = (info.cfg.Durability - info.totalRepairVal) / info.cfg.Durability
			local fillAfter = (info.cfg.Durability - info.remainRepairVal) / info.cfg.Durability
			self.bindData.fillAmountBefore = fillBefore
			self.bindData.fillAmountAfter = fillAfter
			self.bindData.fillPercentBefore = string.format("%d%%", math.floor(fillBefore * 100))
			self.bindData.fillPercentAfter = string.format("%d%%", math.floor(fillAfter * 100))
		else
			self.bindData.oneOrMoreCtrl = self.oneOrMoreCtrlEnum.more

			self.bindData.moreList:SetSimpleList(#self.weaponList)
		end

		self.BuildConsumeList(self)
		self.RefreshSelectAll(self)
	end
end

M.RefreshMoneyInfo = function(self)
	local count = LTConfig.SceneitemConfig.Repairconsumesgold
	local total = gCommonItemManager:GetPackItemNum(LTConfig.SceneitemConfig.WeaponRepairMoney)
	self.moneyEnough = count > total
	local countryCfg = gRaidDataManager:GetCurrentCountry()
	local id = countryCfg and countryCfg.CurrencyItem or 0
	local cfg = LTConfig.ConsumableConfig.GetConfig(id)
	self.bindData.moneyIcon = cfg and cfg.SItemIconId or 0
	self.bindData.moneyConsume = string.format("%s%d#z", self.moneyEnough and self.COLOR_TEXT.GREEN or self.COLOR_TEXT.RED, gCommonItemManager:GetExchangeRate(count))
	self.bindData.moneyTotal = gCommonItemManager:GetExchangeRate(total)

	self.SubGroup.MoneyTemplateStore:SetData(LTConfig.SceneitemConfig.WeaponRepairMoney)
end

M.RefreshSelectAll = function(self)
	local check = true

	for i = 1, #self.weaponList do
		if not self.weaponList[i].active then
			check = false

			break
		end
	end

	self.bindData.checkBoxSelectedCtrl = check and self.checkBoxSelectedCtrlEnum._true or self.checkBoxSelectedCtrlEnum._false
end

M.OnPackItemChanged = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.InitMaterialTotalCount(self)
	self.RefreshView(self)
	self.RefreshMoneyInfo(self)
end
