local MoneyType = UX.Game.MoneyType
local MallCommodityConfig = LTConfig.MallCommodityConfig
local MessageConfig = LTConfig.MessageConfig
local ShopCommon = {
	Mall = 2,
	Contribution = 3,
	Npc = 1,
	ExchangeMoney = function (from, to, count, cb, reason)
		if to == MoneyType.Gold then
			gClientToGameDelegate:AskMallQuickBuyCommodity(MallCommodityConfig.Gold, count).Callback = function (errId)
				if errId ~= 0 then
					print_error("AskMallQuickBuyCommodity 请求失败，err = " .. gCS.Error.GetNameById(errId))
				end

				if cb then
					cb()
				end
			end
		end
	end,
	ExchangeMoneyByGold = function (goldcount, bindinggoldcount, cb)
		gClientToGameDelegate:ExchangeMoneyByGold(goldcount, bindinggoldcount).Callback = function (err)
			if err == MessageConfig.Ok and cb then
				cb()
			elseif err == MessageConfig.GameSwitchFunctionDisabled then
				gDisplayMessageMgr:ShowMessage(MessageConfig.GameSwitchFunctionDisabled)
			else
				print_error("兑换失败 err = " .. err .. "，goldcount = " .. goldcount .. " ,bindinggoldcount = " .. bindinggoldcount)
			end
		end
	end,
	OnNewDay = function ()
		return
	end
}

return ShopCommon
