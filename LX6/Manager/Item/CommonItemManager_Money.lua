-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_Money.lua
-- Decompiled from: 02205_CommonItemManager_Money.lua_3d5512ce5e65.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local MoneyType = UX.Game.MoneyType
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ProfileManager = LX6.Engine.ProfileManager
local LanguageConfig = LTConfig.ShezhiPanelLanguagesConfig
local CountryConfig = LTConfig.CollectionCountryConfig
local MultiverseMetaConfig = LTConfig.MultiverseMultiverseMetaConfig
local M = C_CommonItemManager

M.OnInitMoney = function(self)
	self.moneyDict = {}
	self.countryByCurrencyItem = {}

	for i = 0, CountryConfig.count - 1 do
		local cfg = CountryConfig.LoadAt(i)
		self.moneyDict[cfg.CurrencyItem] = true
		self.countryByCurrencyItem[cfg.CurrencyItem] = cfg
	end

	if MultiverseMetaConfig then
		for i = 0, MultiverseMetaConfig.count - 1 do
			local metaCfg = MultiverseMetaConfig.LoadAt(i)
			slot6 = ipairs
			slot8 = metaCfg.AvailableCurrencies or {}

			for _, itemId in slot6(slot8) do
				self.moneyDict[itemId] = true
			end
		end
	end
end

M.GetExchangeRate = function(self, value)
	local money = value or gPlayerManager.infoItem.bindData.money
	local cfg = self:GetDisplayCountry()

	if not cfg then
		return money
	end

	return math.floor(money * cfg.ExchangeRate)
end

local SWITCH_MONEY_PREFS_KEY = "SwitchMoneyItemId"

M.GetSwitchMoneyAvailableList = function(self)
	if not gMultiverseMgr then
		return nil
	end

	local verseId = gMultiverseMgr.curVerseMetaId

	if not verseId or verseId ~= 0 then
		return nil
	end

	local cfg = MultiverseMetaConfig.GetConfig(verseId)
	local list = cfg and cfg.AvailableCurrencies

	if not list or #list ~= 0 then
		return {
			ConsumableConfig.RewardMoney
		}
	end

	return list
end

M.GetSelectedSwitchMoneyItemId = function(self)
	local itemId = gUtils:GetPlayerPrefsInt(SWITCH_MONEY_PREFS_KEY, 0)

	if itemId == 0 then
		local list = self.GetSwitchMoneyAvailableList(self)

		if list and table.contains(list, itemId) then
			return itemId
		end
	end

	local raidCfg = gRaidDataManager and gRaidDataManager:GetCurrentCountry()

	return raidCfg and raidCfg.CurrencyItem or ConsumableConfig.RewardMoney
end

M.SetSwitchMoneyItemId = function(self, itemId)
	gUtils:SetPlayerPrefsInt(SWITCH_MONEY_PREFS_KEY, itemId or 0)
	gUtils:SavePlayerPrefs()
	gMessageManager:SendMessage(gEventConstants.SWITCH_MONEY_CHANGE)
end

M.GetCountryByCurrencyItem = function(self, itemId)
	if not self.countryByCurrencyItem then
		self.countryByCurrencyItem = {}

		for i = 0, CountryConfig.count - 1 do
			local cfg = CountryConfig.LoadAt(i)
			self.countryByCurrencyItem[cfg.CurrencyItem] = cfg
		end
	end

	return self.countryByCurrencyItem[itemId]
end

M.GetSwitchMoneyExchangeRate = function(self, itemId)
	local cfg = self:GetCountryByCurrencyItem(itemId)

	return cfg and cfg.ExchangeRate or 1
end

M.CheckCanSwitchMoney = function(self, templateId)
	if templateId == self.GetItemIdByMoneyType(self, MoneyType.Money) then
		return false
	end

	return self:GetSwitchMoneyAvailableList() == nil
end

M.GetDisplayCountry = function(self)
	local itemId = self.GetSelectedSwitchMoneyItemId(self)

	if itemId then
		local cfg = self.GetCountryByCurrencyItem(self, itemId)

		if cfg then
			return cfg
		end

		local itemCfg = ConsumableConfig.GetConfig(itemId)

		if itemCfg then
			return {
				["Jn\\xafM\\xbc\\xf5BX{jI"] = 1,
				CurrencyItem = itemId,
				MoneyRichText = itemCfg.MoneyRichTextIcon
			}
		end
	end

	return gRaidDataManager:GetCurrentCountry()
end

M.GetItemIdByMoneyType = function(self, moneyType)
	if moneyType ~= MoneyType.Money then
		local cfg = self:GetDisplayCountry()

		return cfg and cfg.CurrencyItem or ConsumableConfig.RewardMoney
	elseif moneyType ~= MoneyType.Gold then
		return ConsumableConfig.RewardGold
	elseif moneyType ~= MoneyType.BindingGold then
		return ConsumableConfig.RewardBindingGold
	end

	return 0
end

M.NormalizeMoneyItemId = function(self, itemId)
	if itemId ~= ConsumableConfig.RewardMoney then
		local cfg = self:GetDisplayCountry()

		return cfg and cfg.CurrencyItem or ConsumableConfig.RewardMoney
	end

	return itemId
end

M.GetMoneyImageConfigIdByType = function(self, moneyType)
	local cfg = ConsumableConfig.GetConfig(self:GetItemIdByMoneyType(moneyType))

	return cfg and cfg.SMoneyIconId or 0
end

M.IsMoneyItem = function(self, templateId)
	if templateId ~= ConsumableConfig.RewardMoney or self.moneyDict[templateId] ~= true then
		return true
	end

	local cfg = ConsumableConfig.GetConfig(templateId)

	return cfg == nil and cfg.SubType ~= ConsumableTypeConfig.Chip
end

M.GetMoneyIconAndCount = function(self, itemTypeOrId)
	local moneyType = table.contains(MoneyType, itemTypeOrId) and itemTypeOrId or gUIUtils:GetMoneyType(itemTypeOrId)

	if moneyType == MoneyType.Default then
		return self:GetMoneyImageConfigIdByType(moneyType), gUIUtils:GetMoneyByType(moneyType)
	end

	local cfg = ConsumableConfig.GetConfig(itemTypeOrId)

	return cfg and cfg.SMoneyIconId, self:GetItemNum(itemTypeOrId) or 0
end

M.BuildLargeNum = function(self, value)
	if value ~= nil then
		return 0
	end

	local curLang = ProfileManager.languageProfile.textLanguage
	local languageCfg = LanguageConfig.GetConfig(curLang)
	local formatMoneyThreshold = languageCfg.FormatMoneyThreshold
	local numberFormat = languageCfg.NumberFormat

	if formatMoneyThreshold ~= -1 or value >= formatMoneyThreshold then
		return math.floor(value)
	end

	local scaleIndex = 0

	for i, v in ipairs(numberFormat) do
		if value >= v.scale then
			break
		end

		scaleIndex = i
	end

	if scaleIndex ~= 0 then
		print_error("本地化的数字简写配置有误! 语言=", curLang, " 数字=", value)

		return math.floor(value)
	end

	local format = numberFormat[scaleIndex]
	local scaledValue = value / format.scale
	local decimalPlaces = scaledValue > 100 and 0 or scaledValue > 10 and 1 or 2
	local factor = 10^decimalPlaces
	local roundedValue = math.floor(scaledValue * factor + 0.5) / factor
	local numberText = string.format("%." .. decimalPlaces .. "f", roundedValue)

	if decimalPlaces <= 0 then
		numberText = string.gsub(numberText, "0+$", "")
		numberText = string.gsub(numberText, "%.$", "")
	end

	return numberText .. format.abbr
end

M.GetCurrMoneyRichText = function(self)
	local cfg = self:GetDisplayCountry()

	return cfg and cfg.MoneyRichText or ""
end

M.OnSyncQuantumWalletInfo = function(self, time)
	self.quantumWalletStartTime = time
end

M.GetQuantumWalletMoney = function(self)
	return Formula_cs:CalcQuantumWalletReward(self.quantumWalletStartTime, gCS.TimeManager.ServerUnixTime)
end

M.GetMoneyRichTextIcon = function(self, itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		itemId = self.GetItemIdByMoneyType(self, itemId)
		cfg = ConsumableConfig.GetConfig(itemId)
	end

	return cfg and cfg.MoneyRichTextIcon or ""
end
