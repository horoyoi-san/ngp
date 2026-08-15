C_SocialNetworkPopupManager = DefClass("C_SocialNetworkPopupManager", C_SocialNetworkPopupManager, nil, nil)
local M = C_SocialNetworkPopupManager

function M:ctor()
	self.popupInfoList = {}
end

function M:PushPopupInfo(popupInfo)
	table.insert(self.popupInfoList, popupInfo)

	self.waitCo = coroutine.stop(self.waitCo)
	self.waitCo = coroutine.start(function ()
		coroutine.wait(3)

		if LTConfig.PopupConfig.AreaFivePopUpLimitCount <= #self.popupInfoList then
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

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.popupInfoList = {}
		self.waitCo = coroutine.stop(self.waitCo)
	end
end

gSocialNetworkPopupManager = gSocialNetworkPopupManager or C_SocialNetworkPopupManager.new()
