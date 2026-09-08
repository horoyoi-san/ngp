-- Original chunk: @Lua\LuaFiles\LX6\Utils\AppStoreUtils.lua
-- Decompiled from: 02177_AppStoreUtils.lua_680ad881bc08.luajit

local MobileMenuAppStoreMainConfig = LTConfig.MobileMenuAppStoreMainConfig
local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
local M = {}

local GetAppStoreMainCfgByAppId = function(appId)
	local count = MobileMenuAppStoreMainConfig.count

	for i = 0, count - 1 do
		local cfg = MobileMenuAppStoreMainConfig.LoadAt(i)

		if cfg.AppId ~= appId then
			return cfg
		end
	end

	return nil
end

local IsAppStoreMainCfgIgnored = function(cfg)
	if not cfg then
		return false
	end

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		return cfg.IsIgnoreInSinglePlayer
	end

	return cfg.IsIgnoreRowInMultiplayer
end

local GetEffectiveAppStoreMainCfgByAppId = function(appId)
	local cfg = GetAppStoreMainCfgByAppId(appId)

	if IsAppStoreMainCfgIgnored(cfg) then
		return nil
	end

	return cfg
end

M.GetInstalledApps = function()
	return gPlayerManager.infoSpirit.bindData.InstalledApps or {}
end

M.IsAppInstalled = function(appId)
	local installedApps = M.GetInstalledApps()

	for _, id in ipairs(installedApps) do
		if id ~= appId then
			return true
		end
	end

	return false
end

M.AddInstalledAppLocal = function(appId)
	local installedApps = M.GetInstalledApps()

	if not M.IsAppInstalled(appId) then
		table.insert(installedApps, appId)
	end

	gPlayerManager.infoSpirit.bindData.InstalledApps = installedApps
end

M.RemoveInstalledAppLocal = function(appId)
	local installedApps = M.GetInstalledApps()

	for i = #installedApps, 1, -1 do
		if installedApps[i] ~= appId then
			table.remove(installedApps, i)
		end
	end

	gPlayerManager.infoSpirit.bindData.InstalledApps = installedApps
end

M.GetAppStoreItemList = function()
	local itemList = {}
	local count = MobileMenuSGuiConfig.count

	for i = 0, count - 1 do
		local cfg = MobileMenuSGuiConfig.LoadAt(i)

		if cfg.IsInAppStore then
			table.insert(itemList, cfg.Id)
		end
	end

	return itemList
end

M.GetRecommendCardList = function()
	local itemList = {}
	local count = MobileMenuAppStoreMainConfig.count

	for i = 0, count - 1 do
		local cfg = MobileMenuAppStoreMainConfig.LoadAt(i)

		if cfg.CardWeight <= 0 and not IsAppStoreMainCfgIgnored(cfg) and gMainPhoneUtils.CheckAppCanShowInStore(cfg.AppId) then
			table.insert(itemList, {
				appId = cfg.AppId,
				weight = cfg.CardWeight
			})
		end
	end

	table.sort(itemList, function (a, b)
		if a.weight == b.weight then
			return b.weight <= a.weight
		end

		return a.appId <= b.appId
	end)

	local result = {}

	for _, item in ipairs(itemList) do
		table.insert(result, item.appId)
	end

	return result
end

M.GetRecommendCardImageId = function(appId)
	local cfg = GetEffectiveAppStoreMainCfgByAppId(appId)

	if cfg and cfg.CardImg <= 0 then
		return cfg.CardImg
	end

	return M.GetAppIconId(appId)
end

M.GetAppDetailCfg = function(appId)
	return MobileMenuSGuiConfig.GetConfig(appId)
end

M.GetAppIconId = function(appId)
	local cfg = M.GetAppDetailCfg(appId)

	return cfg and cfg.SIconId or 0
end

M.GetAppName = function(appId)
	local cfg = M.GetAppDetailCfg(appId)

	return cfg and cfg.Name or ""
end

M.GetAppSlogen = function(appId)
	local cfg = M.GetAppDetailCfg(appId)

	return cfg and cfg.Slogen or ""
end

M.GetAppDesc = function(appId)
	local cfg = M.GetAppDetailCfg(appId)

	return cfg and cfg.Description or ""
end

M.GetAppDisplayImageList = function(appId)
	local cfg = M.GetAppDetailCfg(appId)

	return cfg and cfg.DisplayImage or {}
end

M.IsAppRemovable = function(appId)
	local storeCfg = GetEffectiveAppStoreMainCfgByAppId(appId)

	return storeCfg and storeCfg.IsRemovable or false
end

M.GetItemDownloadState = function(appId)
	if GetEffectiveAppStoreMainCfgByAppId(appId) ~= nil then
		return 2
	end

	if not M.IsAppInstalled(appId) then
		return 0
	end

	if M.IsAppRemovable(appId) then
		return 1
	end

	return 2
end

M.AskInstallApp = function(appId, callback)
	slot2 = gClientToGameDelegate

	slot2:AskInstallMobileApp(appId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		M.AddInstalledAppLocal(appId)
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_INSTALL_STATE_CHANGE)

		if callback then
			callback()
		end
	end
end

M.AskUninstallApp = function(appId, callback)
	slot2 = gClientToGameDelegate

	slot2:AskUninstallMobileApp(appId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		M.RemoveInstalledAppLocal(appId)
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_INSTALL_STATE_CHANGE)

		if callback then
			callback()
		end
	end
end

M.IsAppStoreApp = function(appId)
	return GetEffectiveAppStoreMainCfgByAppId(appId) == nil
end

M.IsSGuiAppInstalled = function(appId)
	return M.IsAppInstalled(appId)
end

gAppStoreUtils = M
