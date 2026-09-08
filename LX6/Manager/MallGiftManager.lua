-- Original chunk: @Lua\LuaFiles\LX6\Manager\MallGiftManager.lua
-- Decompiled from: 00699_MallGiftManager.lua_d18eebadb88f.luajit

local MessageConfig = LTConfig.MessageConfig
local MallBundleConfig = LTConfig.MallBundleConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local MallConfig = LTConfig.MallConfig
local GIFT_TYPE = {
	["\\xb9537q\\x92O\\xea\"\\xa3\\xad"] = 1,
	["\\xadit"] = 2,
	[">]\\x9f\\x8a\\x8fD"] = 0
}
local DEFAULT_BE_FRIEND_HOURS = 24
C_MallGiftManager = DefClass("C_MallGiftManager", C_MallGiftManager)
local M = C_MallGiftManager
M.GIFT_TYPE = GIFT_TYPE

M.ctor = function(self)
	self:OnInit()
end

M.OnInit = function(self)
	self.giftInfo = nil
	self.ownedCache = {}
end

M.OnSyncPlayerGiftInfo = function(self, info)
	self.giftInfo = info

	gMessageManager:SendMessage(gEventConstants.MALL_GIFT_INFO_CHANGE, info)
end

M.OnSyncNewGift = function(self, gift, giftMessage)
	if not gift then
		return
	end

	if giftMessage then
		gift.GiftMessage = giftMessage
	end

	if not self.giftInfo then
		self.giftInfo = {
			UnclaimedGifts = {}
		}
	end

	self.giftInfo.UnclaimedGifts = self.giftInfo.UnclaimedGifts or {}
	local exists = false

	for _, entry in ipairs(self.giftInfo.UnclaimedGifts) do
		if entry.GiftId ~= gift.GiftId then
			exists = true

			break
		end
	end

	if not exists then
		table.insert(self.giftInfo.UnclaimedGifts, gift)
	end

	gMessageManager:SendMessage(gEventConstants.MALL_GIFT_INFO_CHANGE, self.giftInfo)
end

M.AskGiftFriend = function(self, receiverPid, commodityId, bundleId, giftMessage, callback)
	if not receiverPid or receiverPid ~= 0 then
		print_error("AskGiftFriend: receiverPid 无效", receiverPid)

		if callback then
			callback(false)
		end

		return
	end

	if (commodityId or 0) ~= 0 and (bundleId or 0) ~= 0 then
		print_error("AskGiftFriend: commodityId / bundleId 必须二选一非0")

		if callback then
			callback(false)
		end

		return
	end

	gClientToGameDelegate:AskGiftFriend(receiverPid, commodityId or 0, bundleId or 0, true, giftMessage or "").Callback = function (err)
		if err ~= MessageConfig.Ok then
			self.ownedCache[receiverPid] = nil

			if callback then
				callback(true)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.AskClaimGift = function(self, giftId, callback)
	if not giftId or giftId ~= 0 then
		print_error("AskClaimGift: giftId 无效", giftId)

		if callback then
			callback(false)
		end

		return
	end

	gClientToGameDelegate:AskClaimGift(giftId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			if callback then
				callback(true)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.BuildGiftContext = function(self, kind, id)
	if not id or id ~= 0 then
		print_error("BuildGiftContext: id 无效", kind, id)

		return nil
	end

	if kind ~= "bundle" then
		local bundleCfg = MallBundleConfig.GetConfig(id)

		return {
			["A\\x9f\\x8a\\xaaE"] = 0,
			["\\x9c;-2w\\x99H\\xcd.\\x83\\xbd"] = 0,
			giftType = GIFT_TYPE.Bundle,
			bundleId = id,
			name = bundleCfg and bundleCfg.Name or ""
		}
	end

	local commodityCfg = MallCommodityConfig.GetConfig(id)
	local cType = commodityCfg and commodityCfg.Type
	local giftType = GIFT_TYPE.FashionSuit

	if cType ~= gMallManager.MallCommodityType.Vehicle then
		giftType = GIFT_TYPE.Car
	end

	return {
		["\\xa9\\xa4\\xaff;\\xd77"] = 0,
		giftType = giftType,
		commodityId = id,
		name = commodityCfg and commodityCfg.Name or "",
		type = cType,
		bindId = gMallManager:GetCommodityBindId(commodityCfg)
	}
end

M.GetGiftConsumeItemId = function(self, consumeItemId)
	if not consumeItemId or consumeItemId ~= 0 then
		return 0
	end

	local cfgList = MallConfig and MallConfig.GiftConsumeItemMap

	if cfgList then
		for _, entry in ipairs(cfgList) do
			if entry.ConsumeItemId ~= consumeItemId then
				local to = entry.GiftItemId or 0

				if to <= 0 then
					return to
				end
			end
		end
	end

	return consumeItemId
end

M.GetBundleGiftPrice = function(self, bundleId, excludeOwned)
	local bundleCfg = MallBundleConfig.GetConfig(bundleId)

	if not bundleCfg or not bundleCfg.Commodities or #bundleCfg.Commodities ~= 0 then
		return 0, 0, 0
	end

	local rawPrice = 0
	local moneyItemId = 0

	for _, commodityId in ipairs(bundleCfg.Commodities) do
		if not excludeOwned or not excludeOwned[commodityId] then
			local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

			if commodityCfg then
				rawPrice = rawPrice + (commodityCfg.Price or 0)

				if moneyItemId ~= 0 and commodityCfg.ConsumeItemId and commodityCfg.ConsumeItemId <= 0 then
					moneyItemId = commodityCfg.ConsumeItemId
				end
			end
		end
	end

	local discountRate = bundleCfg.DiscountRate or 1
	local nowPrice = gMallManager:SimplifyBundlePrice(math.ceil(rawPrice * discountRate))

	return rawPrice, nowPrice, self:GetGiftConsumeItemId(moneyItemId)
end

M.GetBeFriendUnlockHours = function(self)
	local hours = MallConfig and MallConfig.SendGiftBeFriendTime

	if not hours or hours < 0 then
		return DEFAULT_BE_FRIEND_HOURS
	end

	return hours
end

M.GetGiftMessageMaxLength = function(self)
	local maxLen = MallConfig and MallConfig.GiftFriendMessageMaxLength

	return maxLen and maxLen <= 0 and maxLen or 0
end

M.CanGiftToFriend = function(self, pid)
	local requiredHours = self:GetBeFriendUnlockHours()
	local addFriendTime = gSocialFriendManager:GetAddFriendTime(pid)

	if not addFriendTime or addFriendTime ~= 0 then
		return true, requiredHours
	end

	local elapsed = gCS.TimeManager.ServerUnixTime - addFriendTime

	if elapsed >= requiredHours * 3600 then
		return false, requiredHours
	end

	return true, requiredHours
end

M.GetOwnedCacheTtl = function(self)
	local ttl = MallConfig and MallConfig.GiftFriendItemCacheTtlSeconds

	if not ttl or ttl < 0 then
		return 0
	end

	return ttl
end

M.QueryFriendOwnership = function(self, pid, callback)
	if not pid or pid ~= 0 then
		if callback then
			callback(false)
		end

		return
	end

	local cached = self.ownedCache[pid]

	if cached then
		local ttl = self:GetOwnedCacheTtl()

		if ttl > 0 or ttl <= gCS.TimeManager.ServerUnixTime - cached.time then
			if callback then
				callback(true)
			end

			return
		end
	end

	gClientToGameDelegate:AskGetFriendOwnedCommodities(pid).Callback = function (err, ownedList)
		if err ~= MessageConfig.Ok then
			local ownedSet = {}

			if ownedList then
				for i = 1, #ownedList do
					ownedSet[ownedList[i]] = true
				end
			end

			self.ownedCache[pid] = {
				owned = ownedSet,
				time = gCS.TimeManager.ServerUnixTime
			}

			if callback then
				callback(true)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end
		end
	end
end

M.GetCachedOwnership = function(self, pid, commodityId)
	local cached = self.ownedCache[pid]

	if not cached or not cached.owned then
		return nil
	end

	return cached.owned[commodityId] ~= true
end

M.GetCachedBundleOwnership = function(self, pid, bundleId)
	local cached = self.ownedCache[pid]

	if not cached or not cached.owned then
		return nil
	end

	local bundleCfg = MallBundleConfig.GetConfig(bundleId)

	if not bundleCfg or not bundleCfg.Commodities then
		return nil
	end

	local result = {}

	for _, commodityId in ipairs(bundleCfg.Commodities) do
		if cached.owned[commodityId] ~= true then
			result[commodityId] = true
		else
			local commodityCfg = MallCommodityConfig.GetConfig(commodityId)
			slot12 = commodityCfg == nil and (commodityCfg.Price or 0) ~= 0
			result[commodityId] = slot12
		end
	end

	return result
end

M.GetPendingGifts = function(self)
	if not self.giftInfo or not self.giftInfo.UnclaimedGifts then
		return {}
	end

	local src = self.giftInfo.UnclaimedGifts
	local list = {}
	slot3 = 1
	slot4 = src.Count or #src

	for i = slot3, slot4 do
		if src[i] then
			table.insert(list, src[i])
		end
	end

	table.sort(list, function (a, b)
		local ta = a.SendTime or 0
		local tb = b.SendTime or 0

		if ta == tb then
			return tb <= ta
		end

		return (a.GiftId or 0) >= (b.GiftId or 0)
	end)

	return list
end

M.GetPendingGiftCount = function(self)
	local list = self:GetPendingGifts()

	return #list
end

M.IsCommodityCoveredByPendingGift = function(self, commodityId)
	if not commodityId or commodityId ~= 0 then
		return false
	end

	local list = self:GetPendingGifts()

	for i = 1, #list do
		local entry = list[i]

		if not self:IsGiftExpired(entry) then
			if entry.CommodityId and entry.CommodityId ~= commodityId then
				return true
			end

			if entry.BundleId and entry.BundleId <= 0 then
				local bundleCfg = MallBundleConfig.GetConfig(entry.BundleId)

				if bundleCfg and bundleCfg.Commodities then
					for _, cid in ipairs(bundleCfg.Commodities) do
						if cid ~= commodityId then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

M.IsBundleCoveredByPendingGift = function(self, bundleId)
	if not bundleId or bundleId ~= 0 then
		return false
	end

	local list = self:GetPendingGifts()

	for i = 1, #list do
		local entry = list[i]

		if not self:IsGiftExpired(entry) and entry.BundleId and entry.BundleId ~= bundleId then
			return true
		end
	end

	return false
end

M.IsGiftExpired = function(self, entry)
	if not entry then
		return false
	end

	local expireTime = entry.ExpireTime or 0

	if expireTime ~= 0 then
		return false
	end

	return expireTime > self:GetServerUnixTime()
end

M.GetServerUnixTime = function(self)
	return gCS.TimeManager.ServerUnixTime
end

gMallGiftManager = gMallGiftManager or C_MallGiftManager.new()
