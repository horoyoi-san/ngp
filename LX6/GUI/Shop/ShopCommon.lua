-- Original chunk: @Lua\LuaFiles\LX6\GUI\Shop\ShopCommon.lua
-- Decompiled from: 01317_ShopCommon.lua_75735159c64e.luajit

local MoneyType = UX.Game.MoneyType
local MallCommodityConfig = LTConfig.MallCommodityConfig
local MessageConfig = LTConfig.MessageConfig
local ShopCommon = {
	["W#qW"] = 2,
	["Ly\\xa2c^\\xbb\\xf0R~sqB"] = 3,
	["\\xa0xe"] = 1,
	ExchangeMoney = function (from, to, count, cb, reason)
		if to ~= MoneyType.Gold then
			slot5 = gClientToGameDelegate

			slot5:AskMallQuickBuyCommodity(MallCommodityConfig.Gold, count).Callback = function (errId)
				if errId == 0 then
					print_error("AskMallQuickBuyCommodity 请求失败，err = " .. gCS.Error.GetNameById(errId))
				end

				if cb then
					cb()
				end
			end
		end
	end,
	ExchangeMoneyByGold = function (goldcount, bindinggoldcount, cb)
		slot3 = gClientToGameDelegate

		slot3:ExchangeMoneyByGold(goldcount, bindinggoldcount).Callback = function (err)
			if err ~= MessageConfig.Ok and cb then
				cb()
			elseif err ~= MessageConfig.GameSwitchFunctionDisabled then
				gDisplayMessageMgr:ShowMessage(MessageConfig.GameSwitchFunctionDisabled)
			else
				print_error("兑换失败 err = " .. err .. "，goldcount = " .. goldcount .. " ,bindinggoldcount = " .. bindinggoldcount)
			end
		end
	end,
	OnNewDay = function ()
	end
}

return ShopCommon
