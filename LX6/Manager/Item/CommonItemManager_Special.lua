-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_Special.lua
-- Decompiled from: 02204_CommonItemManager_Special.lua_0a7b38bbd6d3.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local FashionConfig = LTConfig.FashionConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local VehicleConfig = LTConfig.VehicleConfig
local VehicleTypeConfig = LTConfig.VehicleTypeConfig
local HouseConfig = LTConfig.HouseConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local AgentConfig = LTConfig.AgentConfig
local AgentSpecificTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local PhoneConfig = LTConfig.PhoneContactConfig
local M = C_CommonItemManager

M.ExchangeMoney = function(self, targetMoney)
	if not self.enableExchange then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_SHOP_EXCHANGE_PANEL, {
		ToMoney = targetMoney
	})
end

M.SwitchExchange = function(self, flag)
	self.enableExchange = flag
end

M.TryGetSpecialItemInfo = function(self, data)
	local itemId = self.GetTemplateId(self, data)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		return nil
	end

	local info = self._TryGetSpCharacter(self, cfg)

	if not table.isNilOrEmpty(info) then
		return info
	end

	info = self._TryGetSpFashion(self, cfg)

	if not table.isNilOrEmpty(info) then
		return info
	end

	info = self._TryGetVechicle(self, cfg)

	if not table.isNilOrEmpty(info) then
		return info
	end

	info = self._TryGetHouseInfo(self, cfg)

	if not table.isNilOrEmpty(info) then
		return info
	end

	return nil
end

M._TryGetSpCharacter = function(self, itemConfig)
	local bId = itemConfig.BindId
	local cfg = FightSpiritConfig.GetConfig(bId)

	if not cfg then
		return nil
	end

	local agentCfg = AgentConfig.GetConfig(cfg.AgentId)
	local specialType = AgentSpecificTypeConfig.GetConfig(agentCfg.AgentSpecificType)
	local headIcon = specialType.HeadIcon
	local phoneCfg = PhoneConfig.GetConfig(specialType.PhoneId)
	local ele = {
		["JT_yK4"] = false,
		["nr\\xa8~X\\xbb\\xfdICyqB"] = 0,
		id = itemConfig.Id,
		bId = bId,
		icon = agentCfg.HeadIcon,
		subIcon = table.isNilOrEmpty(headIcon) and 0 or headIcon[1],
		subType = itemConfig.SubType,
		name = cfg.Name,
		desc = phoneCfg and phoneCfg.PhoneNumber or "",
		quality = itemConfig.Quality
	}

	return ele
end

M._TryGetSpFashion = function(self, itemConfig)
	local bId = itemConfig.BindId
	local cfg, isSpecial = self._TryGetFashinConfig(self, bId)

	if not cfg then
		return nil
	end

	local brandId = nil

	if isSpecial then
		local fCfg = FashionConfig.GetConfig(cfg.FashionIdList[1])
		brandId = fCfg and fCfg.BelongBrand or 0
	else
		brandId = cfg.BelongBrand
	end

	local brandCfg = ShopBrandConfig.GetConfig(brandId)
	local ele = {
		["\\xca\\xce4+\\xff"] = 0,
		["nr\\xa8~X\\xbb\\xfdICyqB"] = 0,
		id = itemConfig.Id,
		bId = bId,
		icon = cfg.Icon,
		subType = itemConfig.SubType,
		name = cfg.Name,
		desc = brandCfg and brandCfg.BrandName or "",
		isSpecial = isSpecial,
		quality = itemConfig.Quality
	}

	return ele
end

M._TryGetVechicle = function(self, itemConfig)
	local bId = itemConfig.BindId
	local cfg = VehicleConfig.GetConfig(bId)

	if not cfg then
		return nil
	end

	local vType = cfg.VehicleType
	local vCfg = VehicleTypeConfig.GetConfig(vType)
	local ele = {
		["JT_yK4"] = false,
		id = itemConfig.Id,
		bId = bId,
		icon = cfg.SVehicleIconId,
		subIcon = cfg.VehicleBrandPicIcon,
		subType = itemConfig.SubType,
		name = cfg.VehicleName,
		desc = vCfg and vCfg.DisplayName or "",
		additionIcon = cfg.VehicleLightPic,
		quality = itemConfig.Quality
	}

	return ele
end

M._TryGetHouseInfo = function(self, itemConfig)
	local bId = itemConfig.BindId
	local cfg = HouseConfig.GetConfig(bId)

	if not cfg then
		return nil
	end

	local desc = table.concat(cfg.Tags, ";")
	local ele = {
		["JT_yK4"] = false,
		["\\xca\\xce4+\\xff"] = 0,
		["nr\\xa8~X\\xbb\\xfdICyqB"] = 0,
		id = itemConfig.Id,
		bId = bId,
		icon = cfg.HouseImage,
		subType = itemConfig.SubType,
		name = cfg.Name,
		desc = desc,
		quality = itemConfig.Quality
	}

	return ele
end

M._TryGetVechicleInfo = function(self, data)
	local itemId = self.GetTemplateId(self, data)
	local cfg = self._TryGetVechicleConfig(self, itemId)

	if not cfg then
		return nil
	end

	local ret = {
		["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "",
		["POc~m,"] = false,
		name = cfg.VehicleName,
		iconId = cfg.SVehicleIconId,
		shortDesc = cfg.VehicleIntro,
		itemId = itemId,
		quality = cfg.VehicleQuality,
		subType = ConsumableTypeConfig.Vehicle,
		rewardList = {}
	}

	return ret
end

M._TryGetVechicleConfig = function(self, id)
	local cfg = VehicleConfig.GetConfig(id)

	if cfg then
		return cfg
	end

	cfg = ConsumableConfig.GetConfig(id)

	if not cfg then
		return nil
	end

	return self._TryGetVechicleConfig(self, cfg.BindId)
end

M._TryGetFashinConfig = function(self, id)
	local cfg = FashionConfig.GetConfig(id)

	if cfg then
		return cfg, false
	end

	cfg = FashionSuitConfig.GetConfig(id)

	if cfg then
		return cfg, true
	end

	cfg = ConsumableConfig.GetConfig(id)

	if not cfg then
		return nil, false
	end

	return self._TryGetFashinConfig(self, cfg.BindId)
end

M.OnRenderCommonFashion = function(self, btn, index, id)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg, isSuit = self._TryGetFashinConfig(self, id)

	if not cfg then
		return
	end

	store.icon = cfg.Icon

	if isSuit then
		cfg = self:_TryGetFashinConfig(cfg.FashionIdList[1])
		local brandCfg = ShopBrandConfig.GetConfig(cfg.BelongBrand)
		store.iconBg = brandCfg and brandCfg.SuitBG or 0
	end

	store.quality = cfg.Quality
	btn.luaRenderTooltip = self.CreateActionWithArgs(self, self.OnRenderToolTips, {
		TemplateId = id
	})
	btn.luaTooltipPopup = self.CreateAction(self, self.OnToolTipsClose)
end
