-- Original chunk: @Lua\LuaFiles\LX6\Manager\SwitchFunctionManager.lua
-- Decompiled from: 00756_SwitchFunctionManager.lua_88c5cbf46eae.luajit

gSwitchFunctionId = {
	["ʻ=\\xc0##\\xc38ť\\xc0\\xa7"] = -2,
	["Y\\xdd\\xc0\\xeaB\\xeah\\xa4-p\\xe1\\xc3"] = -1,
	["Y\\xdd\\xc0\\xe0I\\xeax\\xb5?v\\xe3\\xcb"] = -6,
	["+\\xbc\\xc1\\x94\\x95ɂ\\x93\\xa9\\xf3\\xd6\r\\xe5\\xb2\\xac\\xd6"] = -4,
	["nf@Eq-0>"] = -3,
	["crᓡ7\\x9b%\\xe5\\xc4"] = -10,
	["2\\xcbp/\\xef>\\x94~\\x82~\\x91\\x82"] = -8,
	["\\xaf]\\xa2q\\xf8\\x9e\\x80"] = -9,
	["_^\\x83Yi\\x8d\\xd1rYNQa"] = -11,
	["M$\\x9d\\xd2F*\\x98N>C\\x8c\\xd7\\xf8\\xcb"] = -12,
	["D\\xd4\\xc2\\xe2U\\xf0s\\xbc>g\\xf5\\xd5"] = -13,
	["2\\xcbp/\\xef9\\x99o\\x9et\\x85\\x91"] = -14,
	["\\xb2G\\xbem\\xf6\\x8f\\x8d"] = -5,
	["2\\xcbp/\\xef6\\x97o\\x88b\\x9f\\x84"] = -15,
	["_^\\x83Yi\\x8d\\xd0rHXRi"] = -16,
	["crᓡ7\\x8c-\\xe4\\xcd"] = -7
}
gSwitchFunctionMap = {
	[gPanelId.HOT_CENTER_HOME] = "EnableBuzzCenter",
	[gPanelId.SHOP_HOME_PAGE] = "EnableMall",
	[gPanelId.SHOP_BUNDLE_PANEL] = "EnableMallBundle",
	[gPanelId.SHOP_CHARGE_PANEL] = "EnableCharge",
	[gSwitchFunctionId.MALL_QUICK_CHARGE] = "EnableCharge",
	[gSwitchFunctionId.MALL_RECOMMEND] = "EnableMallRecommend",
	[gSwitchFunctionId.MALL_SALE] = "EnableMallDirectSale",
	[gPanelId.ACTIVITY_BASE_PANEL] = "EnableCheckIn",
	[gSwitchFunctionId.PHONE_TIME] = "EnableTime",
	[gPanelId.NEW_AGENT_PROFILE_PANEL] = "EnableDossier",
	[gSwitchFunctionId.MALL_RADIANT_CHEST] = "EnableRadiantChest",
	[gSwitchFunctionId.MALL_CLOSET] = "EnableCloset",
	[gSwitchFunctionId.MALL_GACHA_SYSTEM] = "EnableGachaSystem",
	[gPanelId.BATTLE_PASS_PANEL] = "EnableSeasonalBattlePass",
	[gSwitchFunctionId.PHONE_BB_CHAT] = "EnableBBChat",
	[gPanelId.YANJIE_APP_HOME_PANEL] = "EnableScope",
	[gSwitchFunctionId.PHONE_PARTY] = "EnableParty",
	[gPanelId.TALENT_TREE_PANEL] = "EnableSpiritTalent",
	[gPanelId.S_PHOTO_PANEL] = "EnablePhoto",
	[gPanelId.S_MAIL_PANEL] = "EnableMail",
	[gSwitchFunctionId.PHONE_CALL] = "EnablePhone",
	[gPanelId.SOCIAL_CHAT_HOME_PANEL] = "EnableFriends",
	[gPanelId.S_ACHIEVEMENT_COVER] = "EnableAchievement",
	[gPanelId.S_GUIDE_MAIN_PANEL] = "EnableTutorial",
	[gPanelId.BAIKE_MAIN_PANEL] = "EnableCityPedia",
	[gPanelId.ANNOUNCEMENT_PANEL] = "EnableNotices",
	[gSwitchFunctionId.PHONE_CUSTOM] = "EnableCustom",
	[gPanelId.CHAR_MOTION_LIST_PANEL] = "EnableInteractionAction",
	[gSwitchFunctionId.PHONE_DUTY_TERMINAL] = "EnableDutyTerminal",
	[gSwitchFunctionId.PHONE_CAT_EXPRESS] = "EnableCatExpress",
	[gSwitchFunctionId.PHONE_EON_BUG] = "EnableEonBug",
	[gSwitchFunctionId.PHONE_JANITOR] = "EnableJanitor",
	[gPanelId.S_RADIO_PLAYER_PANEL] = "EnableRadioStation",
	[gSwitchFunctionId.PHONE_BUBBLE] = "EnableBubble",
	[gPanelId.S_BUY_DRESS_PANEL] = "EnableFashionStore",
	[gPanelId.CAR_STORE_PANEL] = "Enable4SStore",
	[gPanelId.PLAYER_PROFILE_PANEL] = "EnableProfile",
	[gPanelId.CLUB_MAIN_PANEL] = "EnableClub",
	[gPanelId.CLUB_APPLY_PANEL] = "EnableClub",
	[gPanelId.ONLINE_RANK_PANEL] = "EnableRanking",
	[gPanelId.AKASHA_CHAT_PANEL] = "EnableAkashicSystem"
}
C_SwitchFunctionManager = DefClass("C_SwitchFunctionManager", C_SwitchFunctionManager)
local M = C_SwitchFunctionManager

M.ctor = function(self)
	self.SWITCH_OPEN = true
end

M.CheckEnable = function(self, id)
	if not self.SWITCH_OPEN then
		return true
	end

	local switchName = gSwitchFunctionMap[id]

	if switchName then
		if gGameSwitch[switchName] ~= nil then
			print_error("[GameSwitch] GameSwitch客户端和服务端数据对不上，服务端GameSwitch中找不到对应的开关, switchName=", switchName, "switchId=", id)
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FunctionLocked)

			return false
		else
			if not gGameSwitch[switchName] then
				gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FunctionLocked)
			end

			return gGameSwitch[switchName]
		end
	else
		return true
	end
end

M.CheckEnableSilent = function(self, id)
	if not self.SWITCH_OPEN then
		return true
	end

	local switchName = gSwitchFunctionMap[id]

	if switchName then
		if gGameSwitch[switchName] ~= nil then
			print_error("[GameSwitch] GameSwitch客户端和服务端数据对不上，服务端GameSwitch中找不到对应的开关, switchName=", switchName, "switchId=", id)

			return false
		end

		return gGameSwitch[switchName]
	else
		return true
	end
end

M.SwitchEnable = function(self, enable)
	print_error("#NoCreateIssue [SwitchFunctionManager] SWITCH_OPEN=", enable)

	self.SWITCH_OPEN = enable
end

gSwitchFunctionManager = gSwitchFunctionManager or C_SwitchFunctionManager.new()
