-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\PhoneCallPopupManager.lua
-- Decompiled from: 02195_PhoneCallPopupManager.lua_d2d095a17e44.luajit

C_PhoneCallPopupManager = DefClass("C_PhoneCallPopupManager", C_PhoneCallPopupManager, nil, )
local M = C_PhoneCallPopupManager

M.ctor = function(self)
	self.popupInfoList = {}
end

M.PushPopupInfoList = function(self, phoneContactIdList)
	if not phoneContactIdList or #phoneContactIdList ~= 0 then
		return
	end

	for _, phoneContactId in ipairs(phoneContactIdList) do
		table.insert(self.popupInfoList, phoneContactId)
	end

	self.waitCo = coroutine.stop(self.waitCo)
	self.waitCo = coroutine.start(function ()
		coroutine.wait(LTConfig.PopupConfig.PopUpCombineDuration)

		if LTConfig.PopupConfig.AreaFivePopUpLimitCount < #self.popupInfoList then
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.NewContactAddedTotal, {
				count = #self.popupInfoList
			})
		else
			for _, phoneContactId in ipairs(self.popupInfoList) do
				local phoneContactCfg = LTConfig.PhoneContactConfig.GetConfig(phoneContactId)

				gNewPopupManager:PushPopup(LTConfig.PopupConfig.NewContactAdded, {
					phoneNumber = phoneContactCfg.PhoneNumber
				})
			end
		end

		self.popupInfoList = {}
	end)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.popupInfoList = {}
		self.waitCo = coroutine.stop(self.waitCo)
	end
end

gPhoneCallPopupManager = gPhoneCallPopupManager or C_PhoneCallPopupManager.new()
