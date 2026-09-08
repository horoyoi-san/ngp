-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\SocialNetworkPopupManager.lua
-- Decompiled from: 02194_SocialNetworkPopupManager.lua_e54f0b5564de.luajit

C_SocialNetworkPopupManager = DefClass("C_SocialNetworkPopupManager", C_SocialNetworkPopupManager, nil, )
local M = C_SocialNetworkPopupManager

M.ctor = function(self)
	self.popupInfoList = {}
end

M.PushPopupInfo = function(self, popupInfo)
	table.insert(self.popupInfoList, popupInfo)

	self.waitCo = coroutine.stop(self.waitCo)
	self.waitCo = coroutine.start(function ()
		coroutine.wait(3)

		if LTConfig.PopupConfig.AreaFivePopUpLimitCount < #self.popupInfoList then
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.SocialNetworkAddedTotal, {
				count = #self.popupInfoList
			})
		else
			for _, popupInfo in ipairs(self.popupInfoList) do
				gNewPopupManager:PushPopup(LTConfig.PopupConfig.SocialNetworkAdded, popupInfo)
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

gSocialNetworkPopupManager = gSocialNetworkPopupManager or C_SocialNetworkPopupManager.new()
