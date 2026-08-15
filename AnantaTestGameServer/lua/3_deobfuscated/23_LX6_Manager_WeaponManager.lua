local MessageConfig = LTConfig.MessageConfig
local WeaponConfig = LTConfig.WeaponConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local bit = require("bit")
C_WeaponManager = DefClass("C_WeaponManager", C_WeaponManager, nil)
local M = C_WeaponManager
local FistWeaponIndex = 1
local PrivateWeaponIndex = 2

function M:ctor()
	self.banOperation = false
	self.WEAPON_TYPE = {
		END = 3,
		PAGE1 = 1,
		START = 0,
		PAGE2 = 2
	}
	self.MAX_SELECT_INDEX = 8
	self.MIN_SELECT_INDEX = 1
	self.ExtraWeapon = nil
	self.CurrWeaponSlots = nil
	self.TempWeaponMode = false
	self.CurrTempWeaponData = nil
	self.weaponRedDotQueue = {}
	self.redDotStartTime = 0
	self.loadData = {}
	self.currLoadWeaponId = -1
	self.MAX_CACHE_NUM = 5
	self.loadCount = 0
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.METRO_ENTER_INSIDE, self.OnEnterMetro)

	self.rankText = {
		"D",
		"C",
		"B",
		"A",
		"S",
		"SS"
	}
	self.rankSplit = LTConfig.WeaponConfig.WeaponAttrThreshold
end

function M.OnEnterMetro(_, _)
	gWeaponManager:AskSwitchWeaponToFistWeapon()
end

function M:SyncCurrWeaponSlots(weaponSlots)
	self.CurrWeaponSlots = table.clone(weaponSlots)
end

function M:SyncSpiritWeaponSlot(templateId, weaponSlots)
	if gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId] then
		gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId] = weaponSlots
	end
end

function M:SyncCurrWeaponSlotsAdd(index, weapon)
	self.CurrWeaponSlots[index + 1] = weapon

	gStoreManager:GetStoreGroup("CoreHudCircleStore"):AddWeaponSlot(index + 1, weapon)
	gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_SLOT_ADD, {
		SlotIndex = index + 1,
		Weapon = weapon
	})
end

function M:SyncSpiritWeaponSlotsAdd(templateId, index, weapon)
	if gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId] then
		gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId][index + 1] = weapon

		gMessageManager:SendMessage(gEventConstants.SPIRIT_WEAPON_SLOT_ADD, {
			TemplateId = templateId,
			SlotIndex = index + 1,
			Weapon = weapon
		})
	end
end

function M:SyncCurrWeaponSlotsRemove(weaponId, discardType)
	for i = 1, self.CurrWeaponSlots.Length do
		local weaponDetail = self.CurrWeaponSlots[i]

		if weaponDetail and weaponDetail.InstanceId == weaponId then
			self.CurrWeaponSlots[i] = nil

			gStoreManager:GetStoreGroup("CoreHudCircleStore"):RemoveWeaponSlot(i)
			gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_SLOT_REMOVE, {
				SlotIndex = i,
				TemplateId = weaponDetail.TemplateId,
				InstanceId = weaponId
			})

			break
		end
	end
end

function M:SyncSpiritWeaponSlotsRemove(templateId, weaponId, discardType)
	local weapons = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId]

	if weapons then
		for i = 1, weapons.Length do
			local weaponDetail = weapons[i]

			if weaponDetail and weaponDetail.InstanceId == weaponId then
				weapons[i] = nil

				gMessageManager:SendMessage(gEventConstants.SPIRIT_WEAPON_SLOT_REMOVE, {
					TemplateId = templateId,
					InstanceId = weaponId
				})

				break
			end
		end
	end
end

function M:SyncCurrWeaponSlotsDurability(weaponId, durability, isToLowLimit)
	if table.isNilOrEmpty(self.CurrWeaponSlots) then
		print_warn("gWeaponManager SyncCurrWeaponSlotsDurability self.CurrWeaponSlots is nil")

		return
	end

	for i = 1, self.CurrWeaponSlots.Length do
		local weaponDetail = self.CurrWeaponSlots[i]

		if weaponDetail and weaponDetail.InstanceId == weaponId then
			weaponDetail.Durability = durability

			break
		end
	end

	local weapons = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[gBattleSpiritMgr.currentSpiritTemplateId]

	if weapons then
		for i = 1, weapons.Length do
			local weaponDetail = weapons[i]

			if weaponDetail and weaponDetail.InstanceId == weaponId then
				weaponDetail.Durability = durability

				break
			end
		end
	end

	if self.TempWeaponMode then
		local tempWeapons = self.CurrTempWeaponData.WeaponSlots

		if tempWeapons then
			for i = 1, tempWeapons.Length do
				local weaponDetail = tempWeapons[i]

				if weaponDetail and weaponDetail.InstanceId == weaponId then
					weaponDetail.Durability = durability

					break
				end
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.WEAPON_DURABILITY_CHANGE, {
		weaponId = weaponId,
		durability = durability,
		isToLowLimit = isToLowLimit
	})
end

function M:SyncOperatorFlags(weaponId, operatorFlags)
	if table.isNilOrEmpty(self.CurrWeaponSlots) then
		print_warn("gWeaponManager SyncCurrWeaponSlotsDurability self.CurrWeaponSlots is nil")

		return
	end

	for i = 1, self.CurrWeaponSlots.Length do
		local weaponDetail = self.CurrWeaponSlots[i]

		if weaponDetail and weaponDetail.InstanceId == weaponId then
			weaponDetail.OperatorFlags = operatorFlags

			break
		end
	end

	local weapons = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[gBattleSpiritMgr.currentSpiritTemplateId]

	if weapons then
		for i = 1, weapons.Length do
			local weaponDetail = weapons[i]

			if weaponDetail and weaponDetail.InstanceId == weaponId then
				weaponDetail.OperatorFlags = operatorFlags

				break
			end
		end
	end

	if self.TempWeaponMode then
		local tempWeapons = self.CurrTempWeaponData.WeaponSlots

		if tempWeapons then
			for i = 1, tempWeapons.Length do
				local weaponDetail = tempWeapons[i]

				if weaponDetail and weaponDetail.InstanceId == weaponId then
					weaponDetail.OperatorFlags = operatorFlags

					break
				end
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_OPERATORFLAGS_CHANGED, {
		weaponId = weaponId,
		operatorFlags = operatorFlags
	})
end

function M:OnSwitchCurrentWeapon(weaponInstanceId)
	local find = false
	local weapon = nil

	if self.ExtraWeapon and self.ExtraWeapon.InstanceId == weaponInstanceId then
		find = true
		weapon = self.ExtraWeapon
	end

	if self.TempWeaponMode then
		local tempWeapons = self.CurrTempWeaponData.WeaponSlots

		if tempWeapons then
			for i = 0, tempWeapons.Length do
				local detail = tempWeapons[i]

				if detail and detail.InstanceId == weaponInstanceId then
					weapon = detail
					find = true

					break
				end
			end
		end
	end

	if not find then
		local weapons = self.CurrWeaponSlots

		if weapons then
			for i = 0, weapons.Length do
				local detail = weapons[i]

				if detail and detail.InstanceId == weaponInstanceId then
					weapon = detail
					find = true

					break
				end
			end
		end
	end

	if gPlayerManager.infoSpirit.bindData.currentWeapon ~= weapon then
		gPlayerManager.infoSpirit.bindData.currentWeapon = weapon

		gMessageManager:SendMessage(gEventConstants.CURRENT_SPIRIT_WEAPON_CHANGE, weapon)
		gStoreManager:GetStoreGroup("CoreHudCircleStore"):OnCurrentWeaponChange()
	end

	if not find then
		-- Nothing
	end
end

function M:SyncCurrTempWeaponSlots(weaponWheelData)
	self.CurrTempWeaponData = weaponWheelData

	if weaponWheelData then
		self.TempWeaponMode = true
	else
		self.TempWeaponMode = false
	end
end

function M:SyncCurrTempWeaponSlotsAdd(index, weapon)
	if not self.TempWeaponMode then
		return
	end

	self.CurrTempWeaponData.WeaponSlots[index + 1] = weapon

	gStoreManager:GetStoreGroup("CoreHudCircleStore"):AddWeaponSlot(index + 1, weapon)
	gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_SLOT_ADD, {
		SlotIndex = index + 1,
		Weapon = weapon
	})
end

function M:SyncCurrTempWeaponSlotsRemove(weaponId, discardType)
	if not self.TempWeaponMode then
		return
	end

	local weaponSlots = self.CurrTempWeaponData.WeaponSlots

	for i = 1, weaponSlots.Length do
		local weaponDetail = weaponSlots[i]

		if weaponDetail and weaponDetail.InstanceId == weaponId then
			weaponSlots[i] = nil

			gStoreManager:GetStoreGroup("CoreHudCircleStore"):RemoveWeaponSlot(i)
			gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_SLOT_REMOVE, {
				SlotIndex = i,
				TemplateId = weaponDetail.TemplateId,
				InstanceId = weaponId
			})

			break
		end
	end
end

function M:SyncTempExtraWeapon(weapon)
	self.ExtraWeapon = weapon
end

function M:TryRemoveTempExtraWeapon(weaponInstanceId)
	if self.ExtraWeapon and self.ExtraWeapon.InstanceId == weaponInstanceId then
		self.ExtraWeapon = nil
	end
end

function M:GetCurrentWeapons()
	if self.TempWeaponMode then
		return self.CurrTempWeaponData.WeaponSlots
	else
		return self.CurrWeaponSlots
	end
end

function M:GetWeaponIndexRangeByType(type)
	local start = type - 1

	if start < 0 then
		start = 0
	end

	return start * 8, type * 8
end

function M:ConvertSelectIndex(selectIndex, weaponType)
	if selectIndex < self.MIN_SELECT_INDEX or self.MAX_SELECT_INDEX < selectIndex then
		return -1
	end

	local startIdx, endIdx = self:GetWeaponIndexRangeByType(weaponType)
	local idx = startIdx + selectIndex

	return endIdx >= idx and idx or -1
end

function M:AskDepositSpiritWeapon(spiritid, slotindex, callback)
	self.banOperation = true

	gClientToGameDelegate:AskDepositSpiritWeapon(spiritid, slotindex).Callback = function (err)
		self.banOperation = false

		if err == MessageConfig.Ok then
			if callback then
				callback(true)
			end
		else
			if callback then
				callback(false)
			end

			print_warn("AskDepositSpiritWeapon Fail, id=", spiritid, " slotIndex=", slotindex, gCS.Error.GetNameById(err))
		end
	end
end

function M:AskLoadWeaponToSlot(spiritid, weaponid, slotindex, callback)
	self.banOperation = true

	gClientToGameDelegate:AskLoadWeaponToSlot(spiritid, weaponid, slotindex).Callback = function (err)
		self.banOperation = false

		if err == MessageConfig.Ok then
			if callback then
				callback(true)
			end
		else
			if callback then
				callback(false)
			end

			print_warn("AskLoadWeaponToSlot Fail, id=", spiritid, "weapon=", weaponid, " slotIndex=", slotindex, gCS.Error.GetNameById(err))
		end
	end
end

function M:AskExchangeWeaponSlot(tospirit, fromWeapon, toCircleItem, callback)
	self.banOperation = true

	gClientToGameDelegate:AskExchangeWeaponSlot(fromWeapon.BelongSpirit, fromWeapon.SlotIndex, tospirit, toCircleItem.SlotIndex).Callback = function (err)
		self.banOperation = false

		if err == MessageConfig.Ok then
			self:SwapSlotWeapon(fromWeapon, toCircleItem)

			if callback then
				callback(true)
			end
		else
			if callback then
				callback(false)
			end

			print_warn("AskExchangeWeaponSlot Fail, fromId=", fromWeapon.BelongSpirit, " fromWeapon=", fromWeapon.SlotIndex, " toId=", tospirit, " toWeapon=", toCircleItem.SlotIndex, gCS.Error.GetNameById(err))
		end
	end
end

function M:AskSwitchWeaponToFistWeapon()
	local weapons = self.CurrWeaponSlots

	if table.isNilOrEmpty(weapons) then
		print_warn("gWeaponManager AskSwitchWeaponToFistWeapon weapons is nil")

		return
	end

	if FistWeaponIndex <= weapons.Length then
		if weapons[FistWeaponIndex] == nil then
			print_warn("gWeaponManager AskSwitchWeaponToFistWeapon fist weapons is nil")

			return
		end

		gClientToGameSceneDelegate:AskSwitchWeapon(FistWeaponIndex - 1)
	end
end

function M:AskSwitchWeaponToPrivateWeapon()
	local weapons = self.CurrWeaponSlots

	if table.isNilOrEmpty(weapons) then
		print_warn("gWeaponManager AskSwitchWeaponToFistWeapon weapons is nil")

		return
	end

	if PrivateWeaponIndex <= weapons.Length then
		if weapons[PrivateWeaponIndex] == nil then
			print_warn("gWeaponManager AskSwitchWeaponToFistWeapon private weapons is nil")

			return
		end

		gClientToGameSceneDelegate:AskSwitchWeapon(PrivateWeaponIndex - 1)
	end
end

function M:AskSwitchFightStyle(spiritid, fsTypeId, fsId, callback, success, fail)
	self.banOperation = true

	gClientToGameDelegate:AskSwitchFightStyle(spiritid, fsTypeId, fsId).Callback = function (err)
		self.banOperation = false

		if err == MessageConfig.Ok then
			if callback then
				callback(success)
			end
		elseif err == MessageConfig.SpiritFightStyleNotMatch then
			if callback then
				callback(fail)
			end
		else
			print_warn("AskSwitchFightStyle Fail, id=", spiritid, "fsTypeId=", fsTypeId, " fsId=", fsId, gCS.Error.GetNameById(err))
		end
	end
end

function M:SwapSlotWeapon(itemA, itemB)
	local tmp = table.clone(gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[itemA.BelongSpirit][itemA.SlotIndex + 1])
	gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[itemA.BelongSpirit][itemA.SlotIndex + 1] = table.clone(gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[itemB.BelongSpirit][itemB.SlotIndex + 1])
	gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[itemB.BelongSpirit][itemB.SlotIndex + 1] = tmp

	if itemA.BelongSpirit == gBattleSpiritMgr.currentSpiritTemplateId or itemB.BelongSpirit == gBattleSpiritMgr.currentSpiritTemplateId then
		local tmpCurr = table.clone(self.CurrWeaponSlots[itemA.SlotIndex + 1])
		self.CurrWeaponSlots[itemA.SlotIndex + 1] = table.clone(self.CurrWeaponSlots[itemB.SlotIndex + 1])
		self.CurrWeaponSlots[itemB.SlotIndex + 1] = tmpCurr
	end
end

function M:TryGetWeaponInfo(data, fromConsume)
	local itemId = gCommonItemManager:GetTemplateId(data)
	local cfg = WeaponConfig.GetConfig(itemId)

	if not cfg then
		return nil
	end

	local ret = {
		showSource = false,
		showGiftTag = false,
		shortDesc = "",
		showCount = false,
		name = cfg.Name,
		iconId = fromConsume and cfg.WeaponConsumableIcon or cfg.SWeaponWheelsIconId,
		description = cfg.Description,
		itemId = itemId,
		quality = cfg.Quality,
		subType = ConsumableTypeConfig.Fashion,
		additionType = C_CommonItemManager.ITEM_TYPE.COMMON_ITEM,
		attrList = {}
	}

	return ret
end

function M:GetWeaponDurability(item, info)
	local MaxDurability = item.Cfg.Durability

	if MaxDurability <= 0 then
		item.DurablePercent = ""
		item.DurablePercentValue = 100
	else
		local percent = math.floor(info.Durability / MaxDurability * 100)
		item.DurablePercent = percent .. "#F(14)%#Z"
		item.DurablePercentValue = percent
	end
end

function M:GetWeaponAttrRank(point)
	local rank = 6

	for i = 1, #self.rankSplit do
		if point < self.rankSplit[i] then
			rank = i

			break
		end
	end

	return self.rankText[rank] or ""
end

function M:InitRenderList(list, customRenderFunc)
	list.luaRenderItem = customRenderFunc or self:CreateAction("OnCommonItemRender")
end

function M:OnCommonItemRender(btn, index, data)
	local store = gStoreManager:GetStoreGroup("CommonWeaponStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local info = self:TryGetWeaponInfo(data)
	store.iconId = info.iconId
	store.quality = info.quality
	btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", info, gCommonItemManager)
	btn.luaTooltipPopup = self:CreateAction("OnToolTipsClose", gCommonItemManager)

	return store
end

function M:GetFlag(unit, position)
	if position < 0 or position >= 4 then
		return -1
	end

	return bit.band(bit.rshift(unit, position * 8), 255)
end

function M:CheckCanUseByTask(taskId, cfg)
	return cfg and cfg.StoreTopTasks and table.contains(cfg.StoreTopTasks, taskId)
end

function M:CheckWheelTaskGuide(taskId, cfg)
	return cfg and cfg.WheelGuideTaskId and cfg.WheelGuideTaskId == taskId
end

function M:CheckStoreTaskGuide(taskId, cfg)
	return cfg and cfg.StoreGuideTaskId and cfg.StoreGuideTaskId == taskId
end

function M:ClearWeaponRedDot(weaponInstId)
	if not table.contains(self.weaponRedDotQueue, weaponInstId) then
		table.insert(self.weaponRedDotQueue, weaponInstId)

		if not self.needPushQueue then
			self.needPushQueue = true
			self.redDotStartTime = Time.unscaledTime

			gLuaClient:RegisterDynamicUpdate("gWeaponManager", self)
		end
	end
end

function M:PushRedDotQueue()
	gClientToGameSceneDelegate:AskReadWeaponRedDots(self.weaponRedDotQueue)
	table.clear(self.weaponRedDotQueue)

	if self.needPushQueue then
		self.needPushQueue = false

		gLuaClient:UnregisterDynamicUpdate("gWeaponManager")
	end
end

function M:OnUpdate()
	if self.needPushQueue and Time.unscaledTime - self.redDotStartTime > 1 then
		self:PushRedDotQueue()
	end
end

function M:LoadWeaponWithCallback(weaponId, callback)
	self:UnloadWeapon(self.currLoadWeaponId)

	self.currLoadWeaponId = weaponId

	if not self.loadData[weaponId] then
		local cfg = LTConfig.WeaponConfig.GetConfig(weaponId)

		if cfg and cfg.ModelResPath then
			local loadData = {
				timeStamp = Time.frameCount,
				cfg = cfg,
				callback = callback,
				loaded = false,
				loadOps = {},
				instantiated = false,
				go = false
			}

			local function loadFunc()
				for i = 1, #cfg.ModelResPath do
					if string.is_null_or_empty(cfg.ModelResPath[i]) then
						loadData.loadOps[i] = false
					else
						loadData.loadOps[i] = gResourceManager:LoadAssetAsync(gCS.LuaUtils.GetWeaponResPath(cfg.ModelResPath[i]), typeof(GameObject))
					end
				end

				for i = 1, #loadData.loadOps do
					if loadData.loadOps[i] then
						coroutine.yield(loadData.loadOps[i])
					end
				end

				loadData.loaded = true

				if self.currLoadWeaponId == weaponId then
					local rootGo = GameObject.New("WeaponModel" .. weaponId)

					rootGo:SetActive(true)

					local pos = loadData.cfg.ShowInStorePos
					local rot = loadData.cfg.ShowInStoreRot
					local scale = loadData.cfg.ShowInStoreScale and loadData.cfg.ShowInStoreScale * 100 or 100

					for i = 1, #loadData.loadOps do
						if loadData.loadOps[i] then
							local go = GameObject.Instantiate(loadData.loadOps[i].asset, rootGo.transform, false)
							local lodGroup = go:GetComponent(typeof(LX6.Units.UnitLOD.ItemLODGroup))

							if lodGroup then
								lodGroup:SetItemInfo(LX6.Units.UnitLOD.UnitLODType.UI, LX6.Units.UnitLOD.UnitLODLevel.UnitLOD0)
							end

							local p = pos and pos[i] or pos[1]
							p = p and Vector3.New(p.x, p.y, p.z)
							go.transform.localPosition = p or Vector3.zero
							local r = rot and rot[i] or rot[1]
							r = r and Vector3.New(r.x, r.y, r.z)
							go.transform.localEulerAngles = r or Vector3.zero
							go.transform.localScale = Vector3.New(scale, scale, scale)

							go:SetActive(true)
							go:SetLayerRecursively(LX6.Constants.LayerConstants.Ui)
						end
					end

					loadData.go = rootGo
					loadData.instantiated = true

					if loadData.callback then
						loadData.callback(loadData.go)
					end
				end
			end

			loadData.loadCo = gCoroutineManager:StartCoroutine(loadFunc)

			self:AddLoadData(weaponId, loadData)

			return
		end
	end

	local loadData = self.loadData[weaponId]
	loadData.callback = callback
	loadData.timeStamp = Time.frameCount

	if loadData.instantiated then
		if loadData.callback then
			loadData.go:SetActive(true)
			loadData.callback(loadData.go)
		end

		return
	end

	if loadData.loaded then
		local rootGo = GameObject.New("WeaponModel_" .. weaponId)

		rootGo:SetActive(true)

		local pos = loadData.cfg.ShowInStorePos
		local rot = loadData.cfg.ShowInStoreRot
		local scale = loadData.cfg.ShowInStoreScale and loadData.cfg.ShowInStoreScale * 100 or 100

		for i = 1, #loadData.loadOps do
			if loadData.loadOps[i] then
				local go = GameObject.Instantiate(loadData.loadOps[i].asset, rootGo.transform, false)
				local lodGroup = go:GetComponent(typeof(LX6.Units.UnitLOD.ItemLODGroup))

				if lodGroup then
					lodGroup:SetItemInfo(LX6.Units.UnitLOD.UnitLODType.UI, LX6.Units.UnitLOD.UnitLODLevel.UnitLOD0)
				end

				local p = pos and pos[i] or pos[1]
				p = p and Vector3.New(p.x, p.y, p.z)
				go.transform.localPosition = p or Vector3.zero
				local r = rot and rot[i] or rot[1]
				r = r and Vector3.New(r.x, r.y, r.z)
				go.transform.localEulerAngles = r or Vector3.zero
				go.transform.localScale = Vector3.New(scale, scale, scale)

				go:SetActive(true)
				go:SetLayerRecursively(LX6.Constants.LayerConstants.Ui)
			end
		end

		loadData.go = rootGo
		loadData.instantiated = true

		if loadData.callback then
			loadData.callback(loadData.go)
		end

		return
	end
end

function M:UnloadWeapon(weaponId)
	if self.currLoadWeaponId == weaponId then
		self.currLoadWeaponId = -1
	end

	if self.loadData[weaponId] and self.loadData[weaponId].instantiated then
		local go = self.loadData[weaponId].go

		go:SetActive(false)
		go.transform:SetParent(nil, false)
	end
end

function M:AddLoadData(weaponId, loadData)
	if self.MAX_CACHE_NUM <= self.loadCount then
		local time = Time.frameCount + 1
		local remove = -1

		for k, v in pairs(self.loadData) do
			if v.timeStamp < time then
				time = v.timeStamp
				remove = k
			end
		end

		if remove > 0 then
			self:ClearLoadData(remove)
		end
	end

	self.loadData[weaponId] = loadData
	self.loadCount = self.loadCount + 1
end

function M:ClearLoadData(weaponId)
	local loadData = self.loadData[weaponId]
	self.loadData[weaponId] = nil
	self.loadCount = self.loadCount - 1

	if loadData.loadCo then
		gCoroutineManager:CancelCoroutine(loadData.loadCo)
	end

	if loadData.instantiated then
		local go = loadData.go

		GameObject.Destroy(go)
	end

	for i = 1, #loadData.loadOps do
		if loadData.loadOps[i] then
			gResourceManager:UnloadAssetLoadOp(loadData.loadOps[i])
		end
	end
end

function M:ClearAllLoad()
	self.currLoadWeaponId = -1

	for k, v in pairs(self.loadData) do
		self:ClearLoadData(k)
	end

	self.loadCount = 0

	table.clear(self.loadData)
end

function M:GetFightSkillStyleCfg(fightSkillId)
	local cfg = nil
	local fsCfg = LTConfig.FightSkillConfig.GetConfig(fightSkillId)

	if fsCfg and fsCfg.FightSkillType and fsCfg.FightSkillType > 0 then
		for i = 1, LTConfig.WeaponFightStyleConfig.count - 1 do
			local wfsCfg = LTConfig.WeaponFightStyleConfig.GetConfig(i)

			if wfsCfg and wfsCfg.FightSkillTypes then
				for i = 1, #wfsCfg.FightSkillTypes do
					if wfsCfg.FightSkillTypes[i] == fsCfg.FightSkillType then
						cfg = wfsCfg

						break
					end
				end
			end
		end
	end

	return cfg
end

gWeaponManager = gWeaponManager or C_WeaponManager.new()
