-- Original chunk: @Lua\LuaFiles\LX6\Manager\WeaponManager.lua
-- Decompiled from: 00314_WeaponManager.lua_e4b3d3b808e4.luajit

local MessageConfig = LTConfig.MessageConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local SceneitemweaponrepairConfig = LTConfig.SceneitemweaponrepairConfig
local CategoryType = LTConfig.SceneitemConfig.CategoryType
local WeaponShootConfig = LTConfig.WeaponShootConfig
local DurabilityUIModeType = LTConfig.SceneitemConfig.DurabilityUIModeType
local bit = require("bit")
C_WeaponManager = DefClass("C_WeaponManager", C_WeaponManager, nil)
local M = C_WeaponManager
local FistWeaponIndex = 1
local PrivateWeaponIndex = 2

M.ctor = function(self)
	self.banOperation = false
	self.WEAPON_TYPE = {
		["\\xabFB"] = 3,
		["}\\x8f\\x85\\x8a\\xe7"] = 1,
		["~\\x9a\\x83\\x9d\\x82"] = 0,
		["}\\x8f\\x85\\x8a\\xe4"] = 2
	}
	self.MAX_SELECT_INDEX = 8
	self.MIN_SELECT_INDEX = 1
	self.ExtraWeapon = nil
	self.CurrWeaponSlots = nil
	self.VirtualWeaponSlots = nil
	self.TempWeaponMode = false
	self.LockMaxSlotCounts = 0
	self.CurrTempWeaponData = nil
	self.weaponRedDotQueue = {}
	self.redDotStartTime = 0
	self.loadData = {}
	self.currLoadWeaponId = -1
	self.MAX_CACHE_NUM = 5
	self.loadCount = 0
	self.weaponDict = {}
	self.weaponTypeToTabConfig = {}
	self.BROKEN_STATE = {
		[">z\\xbe\\xa5\\xa6o"] = 2,
		["2g\\xa3\\xa3\\xa2m"] = 0,
		[",\\xc6~&\\xe9#\\x94s\\x8e}\\x95\\x98"] = 1
	}
	self.armoryDict = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.METRO_ENTER_INSIDE, self.OnEnterMetro)

	self.rankText = {
		"\\xe9",
		"\\xee",
		"\\xef",
		"\\xec",
		"\\xfe",
		"3:"
	}
	self.rankSplitWeapon = LTConfig.SceneitemConfig.WeaponAttrThreshold
	self.rankSplitGun = LTConfig.SceneitemConfig.WeaponAttrThreshold

	self:InitWeaponTabMap()

	self.durabilityLowPoint = LTConfig.SceneitemConfig.WeaponDurabilityLow * 100
end

M.InitWeaponTabMap = function(self)
	table.clear(self.weaponTypeToTabConfig)

	for i = 1, LTConfig.SceneitemFightStyleConfig.count - 1 do
		local cfg = LTConfig.SceneitemFightStyleConfig.GetConfig(i)

		if cfg and cfg.SceneitemTypes then
			for j = 1, #cfg.SceneitemTypes do
				self.weaponTypeToTabConfig[cfg.SceneitemTypes[j]] = cfg
			end
		end
	end
end

M.GetTabConfigByType = function(self, weaponType)
	return self.weaponTypeToTabConfig[weaponType]
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self:DictClear()
	end
end

M.DictClear = function(self)
	table.clear(self.weaponDict)
end

M.OnEnterMetro = function(_, _)
	gWeaponManager:AskSwitchWeaponToFistWeapon()
end

M.DictAdd = function(self, weapon)
	if not weapon then
		return
	end

	self.weaponDict[weapon.InstanceId] = weapon
end

M.DictRemove = function(self, weapon)
	if not weapon then
		return
	end

	self.weaponDict[weapon.InstanceId] = nil
end

M.SyncCurrWeaponSlots = function(self, weaponSlots)
	if self.CurrWeaponSlots then
		for i = 1, self.CurrWeaponSlots.Length do
			self:DictRemove(self.CurrWeaponSlots[i])
		end
	end

	self.CurrWeaponSlots = weaponSlots

	if self.CurrWeaponSlots then
		for i = 1, self.CurrWeaponSlots.Length do
			self:DictAdd(self.CurrWeaponSlots[i])
		end
	end
end

M.SyncSpiritWeaponSlot = function(self, templateId, weaponSlots)
	local preSlots = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId]

	if preSlots then
		for i = 1, preSlots.Length do
			self:DictRemove(preSlots[i])
		end
	end

	gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId] = weaponSlots

	if weaponSlots then
		for i = 1, weaponSlots.Length do
			self:DictAdd(weaponSlots[i])
		end
	end
end

M.SyncCurrWeaponSlotsAdd = function(self, index, weapon)
	self.CurrWeaponSlots[index + 1] = weapon

	self:DictAdd(weapon)
	gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_SLOT_ADD, {
		SlotIndex = index + 1,
		Weapon = weapon
	})
end

M.SyncSpiritWeaponSlotsAdd = function(self, templateId, index, weapon)
	if gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId] then
		gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId][index + 1] = weapon

		self:DictAdd(weapon)
		gMessageManager:SendMessage(gEventConstants.SPIRIT_WEAPON_SLOT_ADD, {
			SpiritId = templateId,
			SlotIndex = index + 1,
			Weapon = weapon
		})
	end
end

M.SyncCurrWeaponSlotsRemove = function(self, weaponId, discardType)
	for i = 1, self.CurrWeaponSlots.Length do
		local weaponDetail = self.CurrWeaponSlots[i]

		if weaponDetail and weaponDetail.InstanceId ~= weaponId then
			self.CurrWeaponSlots[i] = nil

			self:DictRemove(weaponDetail)
			gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_SLOT_REMOVE, {
				SlotIndex = i,
				TemplateId = weaponDetail.TemplateId,
				InstanceId = weaponId
			})
			gMessageManager:SendMessage(gEventConstants.SPIRIT_WEAPON_SLOT_REMOVE, {
				SpiritId = gBattleSpiritMgr.currentSpiritTemplateId,
				SlotIndex = i,
				InstanceId = weaponId
			})

			break
		end
	end
end

M.SyncSpiritWeaponSlotsRemove = function(self, templateId, weaponId, discardType)
	local weapons = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[templateId]

	if weapons then
		for i = 1, weapons.Length do
			local weaponDetail = weapons[i]

			if weaponDetail and weaponDetail.InstanceId ~= weaponId then
				weapons[i] = nil

				self:DictRemove(weaponDetail)
				gMessageManager:SendMessage(gEventConstants.SPIRIT_WEAPON_SLOT_REMOVE, {
					SpiritId = templateId,
					SlotIndex = i,
					InstanceId = weaponId
				})

				break
			end
		end
	end
end

M.SyncCurrWeaponSlotsDurability = function(self, weaponId, durability, isToLowLimit)
end

M.SyncWeaponDurabilityChange = function(self, weaponInstanceId, durability, magazineAmmo, bulletId)
	local weapon = self:GetWeaponByInstanceId(weaponInstanceId)

	if weapon then
		weapon.Durability = durability
		weapon.MagazineAmmo = magazineAmmo
		weapon.BulletDatas.BulletId = bulletId
	end

	gMessageManager:SendMessage(gEventConstants.WEAPON_DURABILITY_CHANGE, {
		weaponId = weaponInstanceId,
		durability = durability,
		magazineAmmo = magazineAmmo,
		bulletId = bulletId
	})
end

M.SyncSpiritUpdateWeapon = function(self, weaponId, weapon, spiritTid)
	if table.isNilOrEmpty(self.CurrWeaponSlots) then
		print_warn("gWeaponManager SyncCurrWeaponSlotsDurability self.CurrWeaponSlots is nil")

		return
	end

	if gBattleSpiritMgr.currentSpiritTemplateId ~= spiritTid then
		if self.ExtraWeapon and self.ExtraWeapon.InstanceId ~= weaponId then
			self:DictRemove(self.ExtraWeapon)

			self.ExtraWeapon = weapon

			self:DictAdd(weapon)
		end

		for i = 1, self.CurrWeaponSlots.Length do
			local weaponDetail = self.CurrWeaponSlots[i]

			if weaponDetail and weaponDetail.InstanceId ~= weaponId then
				self:DictRemove(weaponDetail)

				self.CurrWeaponSlots[i] = weapon

				self:DictAdd(weapon)

				break
			end
		end

		if self.TempWeaponMode then
			local tempWeapons = self.CurrTempWeaponData.WeaponSlots

			if tempWeapons then
				for i = 1, tempWeapons.Length do
					local weaponDetail = tempWeapons[i]

					if weaponDetail and weaponDetail.InstanceId ~= weaponId then
						self:DictRemove(weaponDetail)

						tempWeapons[i] = weapon

						self:DictAdd(weapon)

						break
					end
				end
			end
		end
	end

	local weapons = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[spiritTid]

	if weapons then
		for i = 1, weapons.Length do
			local weaponDetail = weapons[i]

			if weaponDetail and weaponDetail.InstanceId ~= weaponId then
				self:DictRemove(weaponDetail)

				weapons[i] = weapon

				self:DictAdd(weapon)

				break
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_DETAIL_CHANGED, {
		weaponId = weaponId,
		weapon = weapon
	})
end

M.OnSwitchCurrentWeapon = function(self, weaponInstanceId)
	local find = false
	local weapon = self:GetWeaponByInstanceId(weaponInstanceId)

	if weapon then
		find = true
	end

	if not find and self.ExtraWeapon and self.ExtraWeapon.InstanceId ~= weaponInstanceId then
		find = true
		weapon = self.ExtraWeapon
	end

	if not find and self.TempWeaponMode then
		local tempWeapons = self.CurrTempWeaponData.WeaponSlots

		if tempWeapons then
			for i = 0, tempWeapons.Length do
				local detail = tempWeapons[i]

				if detail and detail.InstanceId ~= weaponInstanceId then
					weapon = detail
					find = true

					break
				end
			end
		end
	end

	if not find and self.VirtualWeaponSlots then
		for _, virtualWeapon in pairs(self.VirtualWeaponSlots) do
			if virtualWeapon.InstanceId ~= weaponInstanceId then
				weapon = virtualWeapon
				find = true

				break
			end
		end
	end

	if not find then
		local weapons = self.CurrWeaponSlots

		if weapons then
			for i = 0, weapons.Length do
				local detail = weapons[i]

				if detail and detail.InstanceId ~= weaponInstanceId then
					weapon = detail
					find = true

					break
				end
			end
		end
	end

	if gPlayerManager.infoSpirit.bindData.currentWeapon == weapon then
		gPlayerManager.infoSpirit.bindData.currentWeapon = weapon

		gMessageManager:SendMessage(gEventConstants.CURRENT_SPIRIT_WEAPON_CHANGE, weapon)
	end

	if not find then
		print_error("Not Find Current Weapon , InstId=", weaponInstanceId)
	end
end

M.SyncCurrTempWeaponSlots = function(self, weaponWheelData)
	if self.CurrTempWeaponData then
		local slots = self.CurrTempWeaponData.WeaponSlots

		if slots then
			for i = 1, slots.Length do
				self:DictRemove(slots[i])
			end
		end
	end

	self.CurrTempWeaponData = weaponWheelData

	if weaponWheelData then
		self.TempWeaponMode = true
		self.LockMaxSlotCounts = weaponWheelData.LockMaxSlotCounts
		local slots = weaponWheelData.WeaponSlots

		if slots then
			for i = 1, slots.Length do
				self:DictAdd(slots[i])
			end
		end
	else
		self.TempWeaponMode = false
		self.LockMaxSlotCounts = 0
	end
end

M.SyncCurrTempWeaponSlotsAdd = function(self, index, weapon)
	if not self.TempWeaponMode then
		return
	end

	self:DictRemove(self.CurrTempWeaponData.WeaponSlots[index + 1])

	self.CurrTempWeaponData.WeaponSlots[index + 1] = weapon

	self:DictAdd(weapon)
	gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_SLOT_ADD, {
		SlotIndex = index + 1,
		Weapon = weapon
	})
end

M.SyncCurrTempWeaponSlotsRemove = function(self, weaponId, discardType)
	if not self.TempWeaponMode then
		return
	end

	local weaponSlots = self.CurrTempWeaponData.WeaponSlots

	for i = 1, weaponSlots.Length do
		local weaponDetail = weaponSlots[i]

		if weaponDetail and weaponDetail.InstanceId ~= weaponId then
			self:DictRemove(weaponDetail)

			weaponSlots[i] = nil

			gMessageManager:SendMessage(gEventConstants.CURRENT_WEAPON_SLOT_REMOVE, {
				SlotIndex = i,
				TemplateId = weaponDetail.TemplateId,
				InstanceId = weaponId
			})

			break
		end
	end
end

M.SyncTempExtraWeapon = function(self, weapon)
	self:DictRemove(self.ExtraWeapon)

	self.ExtraWeapon = weapon

	self:DictAdd(weapon)
end

M.TryRemoveTempExtraWeapon = function(self, weaponInstanceId)
	if self.ExtraWeapon and self.ExtraWeapon.InstanceId ~= weaponInstanceId then
		self:DictRemove(self.ExtraWeapon)

		self.ExtraWeapon = nil
	end
end

M.SyncVirtualWeaponSlots = function(self, weaponSlots)
	if self.VirtualWeaponSlots then
		for _, virtualWeapon in pairs(self.VirtualWeaponSlots) do
			self:DictRemove(virtualWeapon)
		end
	end

	self.VirtualWeaponSlots = table.clone(weaponSlots)

	if self.VirtualWeaponSlots then
		for _, virtualWeapon in pairs(self.VirtualWeaponSlots) do
			self:DictAdd(virtualWeapon)
		end
	end
end

M.SyncVirtualWeaponSlotsAdd = function(self, index, weapon)
	self.VirtualWeaponSlots = self.VirtualWeaponSlots or {}
	self.VirtualWeaponSlots[index] = weapon

	self:DictAdd(weapon)
end

M.TryRemoveVirtualWeaponSlots = function(self, weaponInstanceId)
	if self.VirtualWeaponSlots then
		for k, v in pairs(self.VirtualWeaponSlots) do
			if v.InstanceId ~= weaponInstanceId then
				self:DictRemove(v)

				self.VirtualWeaponSlots[k] = nil

				break
			end
		end
	end
end

M.GetCurrentWeapons = function(self)
	if self.TempWeaponMode then
		return self.CurrTempWeaponData.WeaponSlots
	else
		return self.CurrWeaponSlots
	end
end

M.GetWeaponIndexRangeByType = function(self, type)
	local start = type - 1

	if start >= 0 then
		start = 0
	end

	return start * 8, type * 8
end

M.ConvertSelectIndex = function(self, selectIndex, weaponType)
	if selectIndex <= self.MIN_SELECT_INDEX or self.MAX_SELECT_INDEX >= selectIndex then
		return -1
	end

	local startIdx, endIdx = self:GetWeaponIndexRangeByType(weaponType)
	local idx = startIdx + selectIndex

	return endIdx > idx and idx or -1
end

M.AskDiscardSpiritWeapon = function(self, spiritid, instanceId, iddropOut, callback)
	self.banOperation = true

	gClientToGameSceneDelegate:AskDiscardWeaponByInstanceId(instanceId, spiritid, iddropOut).Callback = function (err)
		self.banOperation = false

		if err ~= MessageConfig.Ok then
			if callback then
				callback(true)
			end
		else
			if callback then
				callback(false)
			end

			print_warn("AskDiscardWeaponByInstanceId Fail, spiritid=", spiritid, " instanceId=", instanceId, "iddropOut=", iddropOut, gCS.Error.GetNameById(err))
		end
	end
end

M.AskDepositSpiritWeapon = function(self, spiritid, slotindex, callback)
	self.banOperation = true

	gClientToGameDelegate:AskDepositSpiritWeapon(spiritid, slotindex).Callback = function (err)
		self.banOperation = false

		if err ~= MessageConfig.Ok then
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

M.AskSetWeaponLock = function(self, instanceId, isLocked, callback)
	self.banOperation = true

	gClientToGameDelegate:AskSetWeaponLock(instanceId, isLocked).Callback = function (err)
		self.banOperation = false

		if err ~= MessageConfig.Ok then
			local packItem = gCommonItemManager.packItemDict[instanceId]

			if packItem and packItem.WeaponData then
				packItem.WeaponData.IsPlayerLocked = isLocked
			end

			if callback then
				callback(true)
			end
		else
			if callback then
				callback(false)
			end

			print_warn("AskSetWeaponLock Fail, instanceId=", instanceId, " isLocked=", isLocked, gCS.Error.GetNameById(err))
		end
	end
end

M.AskLoadWeaponToSlot = function(self, spiritid, weaponid, slotindex, callback)
	self.banOperation = true

	gClientToGameDelegate:AskLoadWeaponToSlot(spiritid, weaponid, slotindex).Callback = function (err)
		self.banOperation = false

		if err ~= MessageConfig.Ok then
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

M.AskExchangeWeaponSlot = function(self, tospirit, fromWeapon, toCircleItem, callback)
	self.banOperation = true

	gClientToGameDelegate:AskExchangeWeaponSlot(fromWeapon.BelongSpirit, fromWeapon.SlotIndex, tospirit, toCircleItem.SlotIndex).Callback = function (err)
		self.banOperation = false

		if err ~= MessageConfig.Ok then
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

M.AskExchangeWeaponSlotNew = function(self, tospirit, fromWeapon, toCircleItem, callback)
	self.banOperation = true

	gClientToGameDelegate:AskExchangeWeaponSlot(tospirit, fromWeapon.SlotIndex, tospirit, toCircleItem.SlotIndex).Callback = function (err)
		self.banOperation = false

		if err ~= MessageConfig.Ok then
			self:SwapSlotWeaponNew(fromWeapon, toCircleItem, tospirit)

			if callback then
				callback(true)
			end
		else
			if callback then
				callback(false)
			end

			print_warn("AskExchangeWeaponSlot Fail, fromId=", tospirit, " fromWeapon=", fromWeapon.SlotIndex, " toId=", tospirit, " toWeapon=", toCircleItem.SlotIndex, gCS.Error.GetNameById(err))
		end
	end
end

M.AskSwitchWeaponToFistWeapon = function(self)
	local weapons = self.CurrWeaponSlots

	if table.isNilOrEmpty(weapons) then
		print_warn("gWeaponManager AskSwitchWeaponToFistWeapon weapons is nil")

		return
	end

	if FistWeaponIndex < weapons.Length then
		if weapons[FistWeaponIndex] ~= nil then
			print_warn("gWeaponManager AskSwitchWeaponToFistWeapon fist weapons is nil")

			return
		end

		gClientToGameSceneDelegate:AskSwitchWeapon(FistWeaponIndex - 1)
	end
end

M.AskSwitchWeaponToPrivateWeapon = function(self)
	local weapons = self.CurrWeaponSlots

	if table.isNilOrEmpty(weapons) then
		print_warn("gWeaponManager AskSwitchWeaponToFistWeapon weapons is nil")

		return
	end

	if PrivateWeaponIndex < weapons.Length then
		if weapons[PrivateWeaponIndex] ~= nil then
			print_warn("gWeaponManager AskSwitchWeaponToFistWeapon private weapons is nil")

			return
		end

		gClientToGameSceneDelegate:AskSwitchWeapon(PrivateWeaponIndex - 1)
	end
end

M.AskSwitchFightStyle = function(self, spiritid, fsTypeId, fsId, callback, success, fail)
	self.banOperation = true

	gClientToGameDelegate:AskSwitchFightStyle(spiritid, fsTypeId, fsId).Callback = function (err)
		self.banOperation = false

		if err ~= MessageConfig.Ok then
			if callback then
				callback(success)
			end
		elseif err ~= MessageConfig.SpiritFightStyleNotMatch then
			if callback then
				callback(fail)
			end
		else
			print_warn("AskSwitchFightStyle Fail, id=", spiritid, "fsTypeId=", fsTypeId, " fsId=", fsId, gCS.Error.GetNameById(err))
		end
	end
end

M.AskSetWeaponFightStyle = function(self, weaponInstanceId, fsId, callback, success, fail)
	self.banOperation = true

	gClientToGameDelegate:AskSetWeaponFightStyle(weaponInstanceId, fsId).Callback = function (err)
		self.banOperation = false

		if err ~= MessageConfig.Ok then
			if callback then
				callback(success)
			end
		elseif err ~= MessageConfig.SpiritFightStyleNotMatch then
			if callback then
				callback(fail)
			end
		else
			print_warn("AskSetWeaponFightStyle Fail, weaponInstanceId=", weaponInstanceId, " fsId=", fsId, gCS.Error.GetNameById(err))
		end
	end
end

M.SwapSlotWeapon = function(self, itemA, itemB)
	local tmpA = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[itemA.BelongSpirit][itemA.SlotIndex + 1]

	self:DictRemove(tmpA)

	tmpA = table.clone(tmpA)

	self:DictAdd(tmpA)

	local tmpB = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[itemB.BelongSpirit][itemB.SlotIndex + 1]

	self:DictRemove(tmpB)

	tmpB = table.clone(tmpB)

	self:DictAdd(tmpB)

	gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[itemA.BelongSpirit][itemA.SlotIndex + 1] = tmpB
	gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[itemB.BelongSpirit][itemB.SlotIndex + 1] = tmpA

	if itemA.BelongSpirit ~= gBattleSpiritMgr.currentSpiritTemplateId or itemB.BelongSpirit ~= gBattleSpiritMgr.currentSpiritTemplateId then
		local tmpCurrA = self.CurrWeaponSlots[itemA.SlotIndex + 1]

		self:DictRemove(tmpCurrA)

		tmpCurrA = table.clone(tmpCurrA)

		self:DictAdd(tmpCurrA)

		local tmpCurrB = self.CurrWeaponSlots[itemB.SlotIndex + 1]

		self:DictRemove(tmpCurrB)

		tmpCurrB = table.clone(tmpCurrB)

		self:DictAdd(tmpCurrB)

		self.CurrWeaponSlots[itemA.SlotIndex + 1] = tmpCurrB
		self.CurrWeaponSlots[itemB.SlotIndex + 1] = tmpCurrA
	end
end

M.SwapSlotWeaponNew = function(self, itemA, itemB, BelongSpirit)
	local tmpA = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[BelongSpirit][itemA.SlotIndex + 1]
	local tmpB = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[BelongSpirit][itemB.SlotIndex + 1]
	gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[BelongSpirit][itemA.SlotIndex + 1] = tmpB
	gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[BelongSpirit][itemB.SlotIndex + 1] = tmpA
end

M.GetWeaponDurability = function(self, item, info)
	local MaxDurability = item.Cfg.Durability

	if item.Cfg.Category ~= CategoryType.Gun then
		if self:IsWeaponUseBulletByCfg(item.Cfg) then
			local a = info.MagazineAmmo
			local b = gCommonItemManager:GetPackItemNum(info.BulletDatas.BulletId)
			item.DurablePercent = a .. "|" .. b
		else
			local a = info.MagazineAmmo
			local b = info.Durability

			if a == -1 and b == -1 then
				b = b - a
			else
				if a ~= -1 then
					a = "∞"
				end

				if b ~= -1 then
					b = "∞"
				end
			end

			item.DurablePercent = a .. "|" .. b
		end

		item.DurablePercentValue = 100
		item.DurableNotFull = MaxDurability <= 0 and info.Durability <= MaxDurability
	elseif item.Cfg.WeaponStackMaxCount == 0 then
		item.DurablePercent = math.floor(info.Durability)
		item.DurablePercentValue = 100
		item.DurableNotFull = false
	else
		if MaxDurability < 0 then
			item.DurablePercent = ""
			item.DurablePercentValue = 100
		else
			local percent = math.floor(info.Durability / MaxDurability * 100)
			item.DurablePercent = percent .. "#F(14)%#Z"

			if item.Cfg.Category ~= CategoryType.Weapon then
				item.DurablePercentValue = percent
			else
				item.DurablePercentValue = 100
			end
		end

		item.DurableNotFull = MaxDurability <= 0 and info.Durability <= MaxDurability
	end
end

M.GetWeaponDurabilityData = function(self, item, info)
	local MaxDurability = item.Cfg.Durability
	local typeUIMode = item.Cfg.DurabilityUIMode or DurabilityUIModeType.Free
	item.WeaponUIType = typeUIMode
	item.MaxDurability = MaxDurability

	if typeUIMode ~= DurabilityUIModeType.Default then
		item.DurabilityValue1 = math.floor(info.Durability)
		item.DurabilityText1 = item.DurabilityValue1
		item.DurabilityValue2 = 100
		item.DurabilityText2 = ""
		item.DurableNotFull = false
	elseif typeUIMode ~= DurabilityUIModeType.Gun then
		if self:IsWeaponUseBulletByCfg(item.Cfg) then
			item.DurabilityValue1 = info.MagazineAmmo
			item.DurabilityValue2 = gCommonItemManager:GetPackItemNum(info.BulletDatas.BulletId)
			item.DurabilityText1 = item.DurabilityValue1
			item.DurabilityText2 = item.DurabilityValue2
		else
			local a = info.MagazineAmmo
			local b = info.Durability

			if a == -1 and b == -1 then
				b = b - a
			end

			item.DurabilityValue1 = a
			item.DurabilityValue2 = b
			item.DurabilityText1 = item.DurabilityValue1
			item.DurabilityText2 = item.DurabilityValue2
		end

		item.DurableNotFull = MaxDurability <= 0 and info.Durability <= MaxDurability
	elseif typeUIMode ~= DurabilityUIModeType.Percent then
		local percent = math.floor(info.Durability / MaxDurability * 100)
		item.DurabilityValue1 = percent
		item.DurabilityValue2 = 100
		item.DurabilityText1 = percent .. "%"
		item.DurabilityText2 = ""
		item.DurableNotFull = MaxDurability <= 0 and info.Durability <= MaxDurability
	elseif typeUIMode ~= DurabilityUIModeType.Free then
		item.DurabilityValue1 = 100
		item.DurabilityValue2 = 100
		item.DurabilityText1 = ""
		item.DurabilityText2 = ""
		item.DurableNotFull = false
	elseif typeUIMode ~= DurabilityUIModeType.InfiniteAmmo then
		item.DurabilityValue1 = info.MagazineAmmo
		item.DurabilityValue2 = 100
		item.DurabilityText1 = item.DurabilityValue1
		item.DurabilityText2 = ""
		item.DurableNotFull = false
	elseif typeUIMode ~= DurabilityUIModeType.InfinitePercent then
		local bulletNum = item.Cfg.BulletNum or 1

		if bulletNum >= 0 then
			bulletNum = 1
		end

		item.DurabilityValue1 = info.MagazineAmmo / bulletNum * 100
		item.DurabilityValue2 = 100
		item.DurabilityText1 = item.DurabilityValue1 .. "%"
		item.DurabilityText2 = ""
		item.DurableNotFull = false
	else
		item.DurabilityValue1 = 100
		item.DurabilityValue2 = 100
		item.DurabilityText1 = ""
		item.DurabilityText2 = ""
		item.DurableNotFull = false
	end

	item.BrokenState = self.BROKEN_STATE.NORMAL

	if item.Cfg.WeaponStackMaxCount ~= 0 and item.Cfg.Category ~= CategoryType.Weapon then
		if item.DurabilityValue1 ~= 0 then
			item.BrokenState = self.BROKEN_STATE.BROKEN
		elseif item.DurabilityValue1 < self.durabilityLowPoint then
			item.BrokenState = self.BROKEN_STATE.NEARLY_BROKEN
		end
	end
end

M.GetWeaponAttrRank = function(self, point)
	local rank = 6

	for i = 1, #self.rankSplitWeapon do
		if point >= self.rankSplitWeapon[i] then
			rank = i

			break
		end
	end

	return self.rankText[rank] or ""
end

M.GetGunAttrRank = function(self, point)
	local rank = 6

	for i = 1, #self.rankSplitGun do
		if point >= self.rankSplitGun[i] then
			rank = i

			break
		end
	end

	return self.rankText[rank] or ""
end

M.GetWeaponByInstanceId = function(self, weaponInstanceId)
	local find = false
	local weapon = nil

	if self.weaponDict[weaponInstanceId] then
		find = true
		weapon = self.weaponDict[weaponInstanceId]

		return weapon
	end

	if not find then
		for _, armory in pairs(self.armoryDict) do
			if armory[weaponInstanceId] then
				find = true
				weapon = armory[weaponInstanceId]

				return weapon
			end
		end
	end

	if not find and self.ExtraWeapon and self.ExtraWeapon.InstanceId ~= weaponInstanceId then
		find = true
		weapon = self.ExtraWeapon

		return weapon
	end

	if not find and self.TempWeaponMode then
		local tempWeapons = self.CurrTempWeaponData.WeaponSlots

		if tempWeapons then
			for i = 0, tempWeapons.Length do
				local detail = tempWeapons[i]

				if detail and detail.InstanceId ~= weaponInstanceId then
					weapon = detail
					find = true

					return weapon
				end
			end
		end
	end

	if not find and self.VirtualWeaponSlots then
		for _, virtualWeapon in pairs(self.VirtualWeaponSlots) do
			if virtualWeapon.InstanceId ~= weaponInstanceId then
				weapon = virtualWeapon
				find = true

				return weapon
			end
		end
	end

	if not find then
		local weapons = self.CurrWeaponSlots

		if weapons then
			for i = 0, weapons.Length do
				local detail = weapons[i]

				if detail and detail.InstanceId ~= weaponInstanceId then
					weapon = detail
					find = true

					return weapon
				end
			end
		end
	end

	return weapon
end

M.CheckWeaponCantDiscard = function(self, weaponData)
	return gWeaponManager:GetFlag(weaponData.OperatorFlags, 1) ~= 1 or weaponData.IsPlayerLocked
end

M.IsWeaponPileUp = function(self, templateId)
	if not templateId then
		return false
	end

	local cfg = SceneitemConfig.GetConfig(templateId)

	return cfg == nil and cfg.WeaponStackMaxCount == 0
end

M.IsWeaponUseBulletById = function(self, templateId)
	local shootCfg = self:GetWeaponShootConfig(templateId)

	if not shootCfg then
		return false
	end

	return shootCfg.SeparateBullets
end

M.IsWeaponUseBulletByCfg = function(self, cfg)
	if not cfg or not cfg.ShootId or cfg.ShootId < 0 then
		return false
	end

	local shootCfg = LTConfig.WeaponShootConfig.GetConfig(cfg.ShootId)

	if not shootCfg then
		return false
	end

	return shootCfg.SeparateBullets
end

M.GetWeaponShootConfig = function(self, templateId)
	local cfg = LTConfig.SceneitemConfig.GetConfig(templateId)

	return LTConfig.WeaponShootConfig.GetConfig(cfg.ShootId)
end

M.GetWeaponAppropriateBulletsTypeByCfg = function(self, cfg)
	if not cfg or not cfg.ShootId or cfg.ShootId < 0 then
		return ""
	end

	local shootCfg = LTConfig.WeaponShootConfig.GetConfig(cfg.ShootId)

	if not shootCfg then
		return ""
	end

	return shootCfg.AppropriateBulletsType
end

M.InitRenderList = function(self, list, customRenderFunc)
	list.luaRenderItem = customRenderFunc or self:CreateAction("OnCommonItemRender")
end

M.OnCommonItemRender = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup("CommonWeaponStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local info = gCommonItemManager:TryGetWeaponInfo(data)
	store.iconId = info.iconId
	store.quality = info.quality
	btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", info, gCommonItemManager)
	btn.luaTooltipPopup = self:CreateAction("OnToolTipsClose", gCommonItemManager)

	return store
end

M.GetFlag = function(self, unit, position)
	if position <= 0 or position > 4 then
		return -1
	end

	return bit.band(bit.rshift(unit, position * 8), 255)
end

M.CheckCanUseByTask = function(self, taskId, cfg)
	return cfg and cfg.StoreTopTasks and table.contains(cfg.StoreTopTasks, taskId)
end

M.CheckWheelTaskGuide = function(self, taskId, cfg)
	return cfg and cfg.WheelGuideTaskId and cfg.WheelGuideTaskId ~= taskId
end

M.CheckStoreTaskGuide = function(self, taskId, cfg)
	return cfg and cfg.StoreGuideTaskId and cfg.StoreGuideTaskId ~= taskId
end

M.GetWeaponFightSkill = function(self, spiritId, weaponDetail)
	local find = false
	local fightSkillId = 0
	find, fightSkillId = self:FindFightSkillStep1(spiritId, weaponDetail)

	if find then
		return fightSkillId, 1
	end

	local cfg = SceneitemConfig.GetConfig(weaponDetail.TemplateId)
	find, fightSkillId = self:FindFightSkillStep2(cfg)

	if find then
		return fightSkillId, 2
	end

	find, fightSkillId = self:FindFightSkillStep3(spiritId, cfg)

	if find then
		return fightSkillId, 3
	end

	find, fightSkillId = self:FindFightSkillStep4(cfg)

	if find then
		return fightSkillId, 4
	end

	return 0, 5
end

M.FindFightSkillStep1 = function(self, spiritId, weaponDetail)
	if weaponDetail.FightStyleId ~= 0 then
		return false
	end

	local cfg = LTConfig.FightSkillConfig.GetConfig(weaponDetail.FightStyleId)

	if not cfg then
		return false
	end

	if not table.isNilOrEmpty(cfg.SpiritId) and not table.contains(cfg.SpiritId, spiritId) then
		return false
	end

	return true, weaponDetail.FightStyleId
end

M.FindFightSkillStep2 = function(self, cfg)
	if cfg and cfg.FixedFightSkill <= 0 then
		return true, cfg.FixedFightSkill
	end

	return false
end

M.FindFightSkillStep3 = function(self, spiritId, cfg)
	local id = gCS.FightStyleManager.Instance:GetFightStyleByTemplateAndFightStyleCatFromServer(spiritId, cfg and cfg.FightSkillType or 0)

	if id <= 0 then
		return true, id
	end

	return false
end

M.FindFightSkillStep4 = function(self, cfg)
	if cfg and cfg.FightSkillType then
		local typeCfg = LTConfig.FightSkillFightSkillTypeConfig.GetConfig(cfg.FightSkillType)

		if typeCfg and typeCfg.DefaultFightSkill then
			local fsCfg = LTConfig.FightSkillConfig.GetConfig(typeCfg.DefaultFightSkill)

			if fsCfg and fsCfg.FightSkillType == cfg.FightSkillType then
				print_error("[WeaponManager_FindFightSkillStep4] 武学流派对应不上，FightSkillFightSkillTypeConfig id=", cfg.FightSkillType, "DefaultFightSkill=", typeCfg.DefaultFightSkill, "DefaultFightSkill.FightSkillType=", fsCfg.FightSkillType, "找策划 @huangzijun01@corp.netease.com 去修配表")
			end

			return true, typeCfg.DefaultFightSkill
		end
	end

	return false
end

M.ClearWeaponRedDot = function(self, weaponInstId)
	if not table.contains(self.weaponRedDotQueue, weaponInstId) then
		table.insert(self.weaponRedDotQueue, weaponInstId)

		if not self.needPushQueue then
			self.needPushQueue = true
			self.redDotStartTime = Time.unscaledTime

			gLuaClient:RegisterDynamicUpdate("gWeaponManager", self)
		end
	end
end

M.PushRedDotQueue = function(self)
	gClientToGameSceneDelegate:AskReadWeaponRedDots(self.weaponRedDotQueue)
	table.clear(self.weaponRedDotQueue)

	if self.needPushQueue then
		self.needPushQueue = false

		gLuaClient:UnregisterDynamicUpdate("gWeaponManager")
	end
end

M.OnUpdate = function(self)
	if self.needPushQueue and Time.unscaledTime - self.redDotStartTime <= 1 then
		self:PushRedDotQueue()
	end
end

M.LoadWeaponWithCallback = function(self, weaponId, callback)
	self:UnloadWeapon(self.currLoadWeaponId)

	self.currLoadWeaponId = weaponId

	if not self.loadData[weaponId] then
		local cfg = LTConfig.SceneitemConfig.GetConfig(weaponId)

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

			local loadFunc = function()
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

				if self.currLoadWeaponId ~= weaponId then
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

M.UnloadWeapon = function(self, weaponId)
	if self.currLoadWeaponId ~= weaponId then
		self.currLoadWeaponId = -1
	end

	if self.loadData[weaponId] and self.loadData[weaponId].instantiated then
		local go = self.loadData[weaponId].go

		go:SetActive(false)
		go.transform:SetParent(nil, false)
	end
end

M.AddLoadData = function(self, weaponId, loadData)
	if self.MAX_CACHE_NUM < self.loadCount then
		local time = Time.frameCount + 1
		local remove = -1

		for k, v in pairs(self.loadData) do
			if v.timeStamp >= time then
				time = v.timeStamp
				remove = k
			end
		end

		if remove <= 0 then
			self:ClearLoadData(remove)
		end
	end

	self.loadData[weaponId] = loadData
	self.loadCount = self.loadCount + 1
end

M.ClearLoadData = function(self, weaponId)
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

M.ClearAllLoad = function(self)
	self.currLoadWeaponId = -1

	for k, v in pairs(self.loadData) do
		self:ClearLoadData(k)
	end

	self.loadCount = 0

	table.clear(self.loadData)
end

M.GetFightSkillStyleCfg = function(self, fightSkillId)
	local cfg = nil
	local fsCfg = LTConfig.FightSkillConfig.GetConfig(fightSkillId)

	if fsCfg and fsCfg.FightSkillType and fsCfg.FightSkillType <= 0 then
		for i = 1, LTConfig.WeaponFightStyleConfig.count - 1 do
			local wfsCfg = LTConfig.WeaponFightStyleConfig.GetConfig(i)

			if wfsCfg and wfsCfg.FightSkillTypes then
				for i = 1, #wfsCfg.FightSkillTypes do
					if wfsCfg.FightSkillTypes[i] ~= fsCfg.FightSkillType then
						cfg = wfsCfg

						break
					end
				end
			end
		end
	end

	return cfg
end

M.GetAttrInfo = function(self, cfg)
	local infos = {}

	if cfg.Category ~= SceneitemConfig.CategoryType.Weapon then
		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 0,
			name = SceneitemConfig.WeaponData1,
			value = Mathf.Ceil(cfg.AttackPower),
			valueFill = Mathf.Clamp01(cfg.AttackPower / SceneitemConfig.MaxWeaponAttackPower)
		})
		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 0,
			name = SceneitemConfig.WeaponData3,
			value = Mathf.Ceil(cfg.PoiseAbility),
			valueFill = Mathf.Clamp01(cfg.PoiseAbility / SceneitemConfig.MaxWeaponPoiseAbility)
		})

		local dura = cfg.Durability / SceneitemConfig.MaxWeaponDurability * 100
		local duraThres = SceneitemConfig.WeaponDuraLevelThreshold
		local duraIdx = 1

		if duraThres[2] >= dura then
			duraIdx = 3
		elseif duraThres[1] >= dura then
			duraIdx = 2
		end

		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 1,
			name = SceneitemConfig.WeaponData4,
			value = SceneitemConfig.WeaponDuraLevel[duraIdx]
		})
	elseif cfg.Category ~= SceneitemConfig.CategoryType.Gun then
		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 0,
			name = SceneitemConfig.GunData1,
			value = Mathf.Ceil(cfg.AttackPower),
			valueFill = Mathf.Clamp01(cfg.AttackPower / SceneitemConfig.GunMaxAtt)
		})
		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 0,
			name = SceneitemConfig.GunData2,
			value = Mathf.Ceil(cfg.AttackSpeed),
			valueFill = Mathf.Clamp01(cfg.AttackSpeed / SceneitemConfig.GunMaxShootSpeed)
		})
		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 0,
			name = SceneitemConfig.GunData3,
			value = Mathf.Ceil(cfg.ReloadSpeed),
			valueFill = Mathf.Clamp01(cfg.ReloadSpeed / SceneitemConfig.GunMaxReloadSpeed)
		})
		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 1,
			name = SceneitemConfig.GunData4,
			value = string.format("%d%%", cfg.HeadShotDamRate * 100)
		})
		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 1,
			name = SceneitemConfig.GunData5,
			value = string.format("%d%%", cfg.IgnoreArmorDefRate * 100)
		})
		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 1,
			name = SceneitemConfig.GunData6,
			value = cfg.BulletNum
		})
		table.insert(infos, {
			["\\xbf\\xb4\\xbbf?\\xea6"] = 1,
			name = SceneitemConfig.GunData7,
			value = string.format("%dm", cfg.EffectiveRange)
		})

		if cfg.Durability <= 0 then
			local dura = cfg.Durability / SceneitemConfig.MaxGunDurability * 100
			local duraThres = SceneitemConfig.WeaponDuraLevelThreshold
			local duraIdx = 1

			if duraThres[2] >= dura then
				duraIdx = 3
			elseif duraThres[1] >= dura then
				duraIdx = 2
			end

			table.insert(infos, {
				["\\xbf\\xb4\\xbbf?\\xea6"] = 1,
				name = SceneitemConfig.WeaponData4,
				value = SceneitemConfig.WeaponDuraLevel[duraIdx]
			})
		end

		local bulletType = gWeaponManager:GetWeaponAppropriateBulletsTypeByCfg(cfg)

		if not string.is_null_or_empty(bulletType) then
			table.insert(infos, {
				["\\xbf\\xb4\\xbbf?\\xea6"] = 1,
				name = SceneitemConfig.GunData8,
				value = bulletType
			})
		end
	end

	return infos
end

M.GetChipInfo = function(self, cfg, detail)
	local num = cfg.DecorationNum
	local chips = detail.Decorations
	local ret = {}

	if chips then
		for i = 1, num do
			local chip = chips[i]

			if not chip or chip.DecorationId ~= 0 then
				table.insert(ret, {
					["[\\xaf\\xae\\xa6\\xb2"] = false
				})
			else
				table.insert(ret, {
					["[\\xaf\\xae\\xa6\\xb2"] = true,
					info = chip
				})
			end
		end
	end

	return ret
end

M.GetEnchantInfo = function(self, detail, slotCount)
	local slots = detail and detail.EnchantSlots or nil
	local num = slots and slots.Count or 0
	local ret = {}

	for i = 1, slotCount do
		local slot = i < num and slots[i] or nil

		if slot and (slot.EnchantConfigId or 0) == 0 then
			table.insert(ret, {
				["[\\xaf\\xae\\xa6\\xb2"] = true,
				info = slot
			})
		else
			table.insert(ret, {
				["[\\xaf\\xae\\xa6\\xb2"] = false
			})
		end
	end

	return ret
end

M.GetWeaponRepairConsumableInOrder = function(self, cfg)
	local ret = {}

	if not cfg then
		return ret
	end

	local quality = cfg.Quality

	if cfg.CanRepair then
		for i = 0, SceneitemweaponrepairConfig.count - 1 do
			local rCfg = SceneitemweaponrepairConfig.LoadAt(i)

			if rCfg and quality < rCfg.limit then
				local filter = rCfg.weapontype

				if table.isNilOrEmpty(filter) or table.contains(filter, cfg.Type) then
					local consumableCfg = LTConfig.ConsumableConfig.GetConfig(rCfg.ConsumableID)

					if consumableCfg then
						table.insert(ret, {
							repairCfg = rCfg,
							consumableCfg = consumableCfg
						})
					end
				end
			end
		end
	end

	table.sort(ret, function (a, b)
		return a.consumableCfg.Quality <= b.consumableCfg.Quality
	end)

	return ret
end

M.CalcRepairResult = function(self, cfg, repairVal)
	if not cfg then
		return false, repairVal, {}
	end

	local quality = cfg.Quality
	local checkList = self:GetWeaponRepairConsumableInOrder(cfg)
	local remainRepair = repairVal
	local result = {}
	local finish = false

	for i = 1, #checkList do
		local check = checkList[i]
		local count = gCommonItemManager:GetPackItemNum(check.consumableCfg.Id)
		local duarPerUnit = check.repairCfg.Durability[quality]

		if count <= 0 and duarPerUnit then
			local repairValPerUnit = math.floor(check.repairCfg.Durability[quality] * cfg.Durability)
			local need = remainRepair / repairValPerUnit

			if count > need then
				table.insert(result, {
					count = need,
					total = count,
					cfg = check.consumableCfg
				})

				finish = true

				break
			else
				table.insert(result, {
					count = count,
					total = count,
					cfg = check.consumableCfg
				})

				remainRepair = remainRepair - count * repairValPerUnit
			end
		end
	end

	return finish, remainRepair, result
end

M.GetNextCircleWeapon = function(self, isNext, needHarmonyLimit)
	local offset = isNext and 1 or -1
	local startIdx = 0
	local endIdx = 16
	local nowWeaponIndex = 2 - offset
	local weapons = self:GetCurrentWeapons()

	if not weapons then
		print_warn("GetNextCircleWeapon weapon List is nil")

		return
	end

	local isWeaponValid = function(detail)
		if not needHarmonyLimit then
			return true
		end

		if detail.Durability ~= 0 then
			return false
		end

		if detail.MagazineAmmo ~= 0 then
			return false
		end

		local cfg = LTConfig.SceneitemConfig.GetConfig(detail.TemplateId)

		if cfg and cfg.BattlePeaceModeNoLimit then
			return false
		end

		return true
	end

	for i = startIdx, endIdx do
		local detail = weapons[i]

		if detail and gPlayerManager.infoSpirit.bindData.currentWeapon and detail.InstanceId ~= gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId then
			nowWeaponIndex = i
		end
	end

	local cnt = 0
	local nextIndex = nowWeaponIndex + offset

	while nextIndex == nowWeaponIndex and cnt >= endIdx do
		cnt = cnt + 1
		local detail = weapons[nextIndex]

		if detail and isWeaponValid(detail) then
			break
		end

		nextIndex = nextIndex + offset

		if isNext then
			if endIdx >= nextIndex then
				nextIndex = startIdx
			end
		elseif nextIndex >= startIdx then
			nextIndex = endIdx
		end
	end

	return nowWeaponIndex ~= nextIndex, nextIndex - 1
end

M.GetWeaponCircleIndex = function(self, weaponInstanceId, needHarmonyLimit)
	local weapons = self:GetCurrentWeapons()

	if not weapons then
		print_warn("GetNextCircleWeapon weapon List is nil")

		return -1
	end

	local isWeaponValid = function(detail)
		if not needHarmonyLimit then
			return true
		end

		if detail.Durability ~= 0 then
			return false
		end

		if detail.MagazineAmmo ~= 0 then
			return false
		end

		local cfg = LTConfig.SceneitemConfig.GetConfig(detail.TemplateId)

		if cfg and cfg.BattlePeaceModeNoLimit then
			return false
		end

		return true
	end

	local startIdx = 0
	local endIdx = 16
	local weaponIndex = -1
	local detail = nil

	for i = startIdx, endIdx do
		detail = weapons[i]

		if detail and detail.InstanceId ~= weaponInstanceId then
			weaponIndex = i

			break
		end
	end

	if detail and isWeaponValid(detail) then
		return weaponIndex - 1
	end

	return -1
end

M.ClearAllArmory = function(self)
	table.clear(self.armoryDict)
end

M.SyncArmoryWeapons = function(self, armoryId, weapons)
	local armory = self.armoryDict[armoryId]

	if not armory then
		armory = {}
		self.armoryDict[armoryId] = armory
	end

	table.clear(armory)

	for i = 1, weapons.Count do
		local weapon = weapons[i]

		if weapon then
			armory[weapon.InstanceId] = weapon

			gWeaponManager:DictAdd(weapon)
		end
	end
end

M.SyncArmoryAddWeaponEx = function(self, armoryId, weapon)
	local armory = self.armoryDict[armoryId]

	if not armory then
		armory = {}
		self.armoryDict[armoryId] = armory
	end

	armory[weapon.InstanceId] = weapon

	gWeaponManager:DictAdd(weapon)
	gMessageManager:SendMessage(gEventConstants.ARMORY_WEAPON_ADD, {
		ArmoryId = armoryId,
		Weapon = weapon,
		TemplateId = weapon.TemplateId,
		InstanceId = weapon.InstanceId
	})
end

M.SyncArmoryRemoveWeaponEx = function(self, armoryId, weaponInstanceId)
	local armory = self.armoryDict[armoryId]

	if not armory then
		return
	end

	local weapon = armory[weaponInstanceId]

	if weapon then
		gWeaponManager:DictRemove(weapon)

		armory[weaponInstanceId] = nil

		gMessageManager:SendMessage(gEventConstants.ARMORY_WEAPON_REMOVE, {
			ArmoryId = armoryId,
			Weapon = weapon,
			InstanceId = weaponInstanceId,
			TemplateId = weapon.TemplateId
		})
	end
end

M.SyncArmoryUpdateWeaponEx = function(self, armoryId, weapon)
	local armory = self.armoryDict[armoryId]

	if not armory then
		armory = {}
		self.armoryDict[armoryId] = armory
	end

	armory[weapon.InstanceId] = weapon

	gWeaponManager:DictAdd(weapon)
	gMessageManager:SendMessage(gEventConstants.ARMORY_WEAPON_UPDATE, {
		ArmoryId = armoryId,
		InstanceId = weapon.InstanceId,
		Weapon = weapon,
		TemplateId = weapon.TemplateId
	})
end

M.GetArmoryWeaponsById = function(self, armoryId)
	return self.armoryDict[armoryId]
end

M.GetMainArmoryWeapons = function(self)
	return self.armoryDict[LTConfig.SceneitemWeaponArmoryIndexConfig.WeaponArmoryIndex_World]
end

gWeaponManager = gWeaponManager or C_WeaponManager.new()

M.GetEnchantPendingPreview = function(self)
	local bd = gPlayerManager.infoScientist.bindData
	local instanceId = bd.PendingEnchantWeaponInstanceId

	if instanceId and instanceId == 0 then
		return {
			WeaponInstanceId = instanceId,
			NewSlots = bd.PendingEnchantSlots
		}
	end

	return nil
end

M.IsEnchantAffixUnlocked = function(self, affixId)
	if not affixId then
		return false
	end

	local bd = gPlayerManager.infoScientist.bindData

	return bd.UnlockedEnchantAffixIds and bd.UnlockedEnchantAffixIds[affixId]
end
