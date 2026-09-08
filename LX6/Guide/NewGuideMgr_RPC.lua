-- Original chunk: @Lua\LuaFiles\LX6\Guide\NewGuideMgr_RPC.lua
-- Decompiled from: 00367_NewGuideMgr_RPC.lua_b8152f5c3219.luajit

local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local M = C_NewGuideMgr
local MessageConfig = LTConfig.MessageConfig

M.AskDoGuide = function(self, guideId, counter)
	slot3 = gClientToGameDelegate

	slot3:AskDoGuide(guideId, counter).Callback = function (err)
		print_notice("[NewGuideMgr]:AskDoGuide CallBack, GuideId=", guideId, " CounterId=", counter, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)
	end
end

M.OnSyncShowGuide = function(self, guide, counter)
	print_notice("[NewGuideMgr]:Rpc SyncShowGuide guideId=", guide, " counter=", counter, Time.time, Time.frameCount)

	if guide ~= 0 then
		print_notice("[NewGuideMgr]:Rpc SyncShowGuide 清理当前引导", counter, Time.time, Time.frameCount)

		gNewGuideMgr.delayedActiveGuideData = nil

		gNewGuideMgr:StopGuide()
	else
		print_notice("[NewGuideMgr]:Rpc SyncShowGuide 激活新引导", counter, Time.time, Time.frameCount)
		gNewGuideMgr:ActiveGuide(guide, counter)
	end
end

M.OnSyncInputDeviceUsage = function(self, inputDeviceUsage)
	print_debug("[NewGuideMgr]:Rpc SyncInputDeviceUsage", inputDeviceUsage)

	self.hasSyncedInputDeviceUsage = true
	local merged = inputDeviceUsage or {}

	if self.syncedInputDeviceUsage then
		for k, v in pairs(self.syncedInputDeviceUsage) do
			if v then
				merged[k] = true
			end
		end
	end

	self.syncedInputDeviceUsage = merged

	self.OnDeviceChangeCheckUsage(self, true)
end

M.OnDeviceChangeCheckUsage = function(self, noMessage)
	if not self.hasSyncedInputDeviceUsage then
		return
	end

	local deviceType = self._GetCurrentInputDeviceType(self)

	if not deviceType then
		return
	end

	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	if SGUI.GuideMgr.IsForceGuiding() then
		return
	end

	if Time.time >= (self.lastDeviceSwitchTime or -1) + (self.deviceSwitchDelay or 0.5) then
		return
	end

	self.lastDeviceSwitchTime = Time.time
	self.syncedInputDeviceUsage[deviceType] = true
	slot3 = gReliableRpcManager

	slot3:RegisterRPC(gClientToGameDelegate.AskSetInputDeviceType, deviceType, function (err, isFirstTime)
		if err == MessageConfig.Ok then
			print_error("[NewGuideMgr]:AskSetInputDeviceType 失败, deviceType=", deviceType, "err=", gCS.Error.GetNameById(err))

			return
		end

		if not isFirstTime then
			return
		end

		if noMessage then
			return
		end

		if deviceType ~= UX.Game.InputDeviceType.Mobile then
			return
		end

		local targetPage = deviceType ~= UX.Game.InputDeviceType.Keyboard and ShezhiPanelConfig.PCButtonPage or ShezhiPanelConfig.ControllerPage

		if self:IsRunnable() then
			if not gPanelManager:IsPanelShowing(gPanelId.S_SETTINGS_PANEL) then
				slot3 = gDisplayMessageMgr

				slot3:ShowMessage(MessageConfig.DeviceSwitchGuideNotify, function ()
					gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL, {
						page = targetPage
					})
				end)
			end
		else
			self.pendingDeviceNotify = targetPage

			self:RefreshDynamicUpdate()
		end
	end)
end

M._GetCurrentInputDeviceType = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return UX.Game.InputDeviceType.Mobile
	end

	local device = gCS.LuaUtils.GetActiveDevice()

	if device ~= SGUI.GameDevice.KeyboardMouse then
		return UX.Game.InputDeviceType.Keyboard
	elseif SGUI.GameDevice.KeyboardMouse >= device then
		return UX.Game.InputDeviceType.Controller
	end

	return nil
end
