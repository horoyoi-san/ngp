C_PhoneCallManager = DefClass("C_PhoneCallManager", C_PhoneCallManager, nil, nil)
local M = C_PhoneCallManager

function M:ctor()
	self:RegisterMessages()
	self:InitData()
end

function M:ExecuteCallInLogic()
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

function M:CheckCanCallIn()
	if self.popUpQueue.count == 0 then
		return false
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

	if gDialogManager:IsDialogRunning() and gDialogManager:GetFirstDialogType() == gDialogType.VIDEO_CLIENT_MULTI_MOVE then
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

function M:InitData()
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()
end

function M:RegisterMessages()
	self.mEventHandlers = {
		[gEventConstants.ON_PHONE_CALL_IN] = function (_, contactOptionId)
			self.popUpQueue:Push(contactOptionId)
			self:ExecuteCallInLogic()
		end,
		[gEventConstants.TIMELINE_START] = function (_)
			self:ExecuteCallInLogic()
		end,
		[gEventConstants.PANEL_ON_CLOSE] = function (_, panelId)
			if panelId == gPanelId.S_DIALOG_22N_PANEL then
				if self.popUpQueue.count > 0 then
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

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.popUpQueue:Clear()

		self.waitQueueCo = coroutine.stop(self.waitQueueCo)
		self.isPlayPhoneCallIn = nil
	end
end

gPhoneCallManager = gPhoneCallManager or C_PhoneCallManager.new()
