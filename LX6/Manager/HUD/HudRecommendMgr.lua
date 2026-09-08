-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\HudRecommendMgr.lua
-- Decompiled from: 02226_HudRecommendMgr.lua_b7c053fdf4c9.luajit

C_HudRecommendMgr = DefClass("C_HudRecommendMgr", C_HudRecommendMgr)
local M = C_HudRecommendMgr

M.ctor = function(self)
	self.targetToInfo = {}
	self.SHOP_TARGET = 1
	self.redKeyBase = "HUDRecommend/TargetApp"
	self.hudTopRightRecommend = false
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		table.clear(self.targetToInfo)

		self.hudTopRightRecommend = false
	end
end

M.SyncAllRecommend = function(self, dict)
	table.clear(self.targetToInfo)

	if dict then
		for targetApp, info in pairs(dict) do
			self.targetToInfo[targetApp] = info

			gRedPointMgr:RegisterRedDot(not info.Read, self:GetTargetAppRedKey(targetApp))

			if targetApp ~= self.SHOP_TARGET then
				gMessageManager:SendMessage(gEventConstants.HUD_RECOMMEND_CHANGE, targetApp)
			end
		end
	end
end

M.SyncHUDRecommendUpsert = function(self, targetApp, info)
	self.targetToInfo[targetApp] = info

	gRedPointMgr:RegisterRedDot(not info.Read, self:GetTargetAppRedKey(targetApp))

	if targetApp ~= self.SHOP_TARGET then
		gMessageManager:SendMessage(gEventConstants.HUD_RECOMMEND_CHANGE, targetApp)
	end
end

M.SyncHUDRecommendRemove = function(self, targetApp)
	self.targetToInfo[targetApp] = nil

	gRedPointMgr:ClearRedDot(self:GetTargetAppRedKey(targetApp))

	if targetApp ~= self.SHOP_TARGET then
		gMessageManager:SendMessage(gEventConstants.HUD_RECOMMEND_CHANGE, targetApp)
	end
end

M.ClearAppRedDot = function(self, targetApp)
	gClientToGameDelegate:AskReadHUDRecommend(targetApp).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		local info = self.targetToInfo[targetApp]

		if info then
			info.Read = true

			gRedPointMgr:RegisterRedDot(false, self:GetTargetAppRedKey(targetApp))

			if targetApp ~= self.SHOP_TARGET then
				gMessageManager:SendMessage(gEventConstants.HUD_RECOMMEND_CHANGE, targetApp)
			end
		end
	end
end

M.GetHUDRecommendInfo = function(self, targetApp)
	return self.targetToInfo[targetApp] or false
end

M.GetTargetAppRedKey = function(self, targetApp)
	return self.redKeyBase .. targetApp
end

M.SetHudTopRightRecommend = function(self, isShow)
	if self.hudTopRightRecommend == isShow then
		self.hudTopRightRecommend = isShow

		gMessageManager:SendMessage(gEventConstants.SYSTEM_CONTROLS_TR_RECOMMEND_CHANGE, isShow)
	end
end

M.GetHudTopRightRecommend = function(self)
	return self.hudTopRightRecommend
end

gHudRecommendMgr = gHudRecommendMgr or C_HudRecommendMgr.new()
