-- Original chunk: @Lua\LuaFiles\LX6\GUI\Manager\ImageManager.lua
-- Decompiled from: 00155_ImageManager.lua_783285fdb0f1.luajit

local PersonalZoneHeadType = UX.Game.PersonalZoneHeadType
local ImageAvatarConfig = LTConfig.ImageNewAvatarConfig
local M = {
	["[\\xb8\\x80\\x8aU"] = false,
	Init = function (self)
		if not self.isInit then
			gMessageManager:AddMessageListener(gEventConstants.UPDATE_HEADINFO, self.UpdateHeadInfo)
		end

		self.isInit = true
	end
}

M.UpdateHeadInfo = function(eventId, data)
	if data == gPlayerManager.infoLogin.bindData.pid then
		return
	end

	M:GetMyHeadIconInfo()
end

M.GetMyHeadIconInfo = function(self)
	slot1 = gClientToGameDelegate

	slot1:QueryPersonalZoneHeadExtendInfo().Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			self.myHeadIconInfo = data.PzHeadInfo
			gPlayerManager.infoLogin.bindData.infoPzHeadInfo = self.myHeadIconInfo

			gLinkPlayerHub:UpdatePlayerInfo(gPlayerManager.infoLogin.bindData.pid, gPlayerManager.infoLogin.bindData.sexType, data.PzHeadInfo, data.LinkPzHeadInfo)
			gMessageManager:SendMessage(gEventConstants.UPDATE_HEADINFO_REFRESHVIEW)
		end
	end
end

M.GetHeadIconByHeadIconInfo = function(self, headIconInfo, sexType, isMe)
	if headIconInfo ~= nil then
		if sexType ~= UX.Game.SexType.Male or sexType ~= UX.Game.SexType.UnKnow then
			return PersonalZoneHeadType.System, ImageAvatarConfig.AdultMH
		else
			return PersonalZoneHeadType.System, ImageAvatarConfig.AdultFH
		end
	end

	if headIconInfo.HeadType ~= PersonalZoneHeadType.Custom then
		if isMe then
			if not string.is_null_or_empty(self.avatar) then
				return PersonalZoneHeadType.Custom, self.avatar
			end
		elseif not string.is_null_or_empty(headIconInfo.CustomHeadPath) then
			return PersonalZoneHeadType.Custom, headIconInfo.CustomHeadPath
		end
	end

	if headIconInfo.SystemHeadId == nil and not ulong.equals(headIconInfo.SystemHeadId, 0) then
		return PersonalZoneHeadType.System, headIconInfo.SystemHeadId
	end

	if sexType ~= UX.Game.SexType.Male or sexType ~= UX.Game.SexType.UnKnow then
		return PersonalZoneHeadType.System, ImageAvatarConfig.AdultMH
	else
		return PersonalZoneHeadType.System, ImageAvatarConfig.AdultFH
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self.avatar = nil
	self.myHeadIconInfo = nil
end

gImageManager = M
