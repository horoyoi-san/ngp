-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\PhoneCallManager.lua
-- Decompiled from: 02193_PhoneCallManager.lua_61057f64b903.luajit

C_PhoneCallManager = DefClass("C_PhoneCallManager", C_PhoneCallManager, nil, )
local M = C_PhoneCallManager

M.ctor = function(self)
	self:RegisterMessages()
	self:InitData()
end

M.ExecuteCallInLogic = function(self)
	if self:CheckCanCallIn() then
		local contactOptionId = self.popUpQueue:Pop()
		local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(contactOptionId)
		local npcCultivationIdList = contactOptionCfg.NpcCultivationIdList
		local currentNpcCultivationId = gMainPhoneUtils.GetNpcCultivationId()
		local canShow = table.isNilOrEmpty(npcCultivationIdList) or table.contains(npcCultivationIdList, currentNpcCultivationId)

		if canShow then
			local dialogId = contactOptionCfg.UnlockDialogId

			if dialogId and LTConfig.DialogConfig.GetConfig(dialogId) then
				gDialogManager:OpenCallInPanel(dialogId, true)

				self.isPlayPhoneCallIn = true
			else
				print_warn("未找到DialogId配置，DialogId=" .. dialogId)
			end
		end
	end
end

M.CheckCanCallIn = function(self)
	if self.popUpQueue.count ~= 0 then
		return false
	end

	if gClientUtils.CheckIsLinkMode() then
		return
	end

	if gClientUtils.IsMainPhoneExist() then
		return false
	end

	if gPauseManager.isBreak then
		return false
	end

	if LX6.Manager.PanelManager.Instance:HasFullscreen() then
		return false
	end

	if not gPanelManager:VisibleModeAll() then
		return false
	end

	if gTimelineManager.isTimelinePlaying then
		return false
	end

	if gDialogManager:IsDialogRunning() and gDialogManager:GetFirstDialogType() ~= gDialogType.VIDEO_CLIENT_MULTI_MOVE then
		return false
	end

	if self.isPlayPhoneCallIn then
		return false
	end

	if self.waitQueueCo then
		return false
	end

	return true
end

M.InitData = function(self)
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()
end

M.RegisterMessages = function(self)
	self.mEventHandlers = {
		[gEventConstants.ON_PHONE_CALL_IN] = function (_, contactOptionId)
			self.popUpQueue:Push(contactOptionId)
			self:ExecuteCallInLogic()
		end,
		[gEventConstants.TIMELINE_START] = function (_)
			self:ExecuteCallInLogic()
		end,
		[gEventConstants.PANEL_ON_CLOSE] = function (_, panelId)
			if panelId ~= gPanelId.S_DIALOG_22N_PANEL then
				if self.popUpQueue.count <= 0 then
					self.waitQueueCo = coroutine.start(function ()
						coroutine.wait(LTConfig.PhoneConfig.PhoneCallInQueueWaitTime)

						self.waitQueueCo = nil

						self:ExecuteCallInLogic()
					end)
				end

				self.isPlayPhoneCallIn = nil
			else
				self.waitQueueCo = coroutine.start(function ()
					coroutine.step()

					self.waitQueueCo = nil

					self:ExecuteCallInLogic()
				end)
			end
		end
	}

	gMessageManager:RegisterEventHandlers(self.mEventHandlers)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self:ClearPopupQueue()
	elseif switchType ~= gSwitchSceneType.Image or switchType ~= gSwitchSceneType.SameImage then
		self:ExecuteCallInLogic()
	end
end

M.ClearPopupQueue = function(self)
	self.popUpQueue:Clear()

	self.waitQueueCo = coroutine.stop(self.waitQueueCo)
	self.isPlayPhoneCallIn = nil
end

gPhoneCallManager = gPhoneCallManager or C_PhoneCallManager.new()
