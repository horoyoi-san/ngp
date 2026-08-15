local UnitState = UX.Game.TwoDimConfig.UnitState
local M = {
	GetTimeTask = function (self)
		local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]
		local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)

		if taskCfg then
			local startTime = taskCfg.TimeInterval.startTime
			local endTime = taskCfg.TimeInterval.endTime

			if startTime ~= 0 and endTime ~= 0 then
				return taskCfg
			end
		end
	end,
	CheckIsTaskForbiddenChangeTime = function ()
		if gCS.UnitStateMgr:IsEventForbidden(gCS.MyPlayerManager.PlayerUnit, UnitState.TimeJump) then
			return true
		end

		if gCS.AtmosphereManager.Instance.IsTimeLocked then
			return true
		end

		if not gCS.AtmosphereManager.Instance.CanChangeTime then
			return true
		end

		return false
	end,
	StartRestTime = function (hour, min, ignoreAskPassingTimeRpc, callback, startGameTime, gameVideoId)
		startGameTime = startGameTime or gCS.AtmosphereManager.Instance:GetGameTime()

		gPanelManager:CheckShow(gPanelId.S_TIME_COUNT_DOWN_PANEL, {
			ignoreAskPassingTimeRpc = ignoreAskPassingTimeRpc,
			startGameTime = startGameTime,
			callback = callback,
			hour = hour,
			minute = min,
			gameVideoId = gameVideoId
		})
	end,
	AddPersonalTimeSetting = function (personalTimeSetting)
		gClientToGameDelegate:AddPersonalTimeSetting(personalTimeSetting).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
				gMessageManager:SendMessage(gEventConstants.ON_ADD_PERSONAL_SETTING_TIME_FAIL)
			else
				gMessageManager:SendMessage(gEventConstants.ON_ADD_PERSONAL_SETTING_TIME_SUCCESS, personalTimeSetting)
			end
		end
	end
}

function M.AskTimePanelInfo()
	gClientToGameDelegate:AskTimePanelInfo().Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		local personalTimeList = data and data.PersonalTimeSettings

		gMessageManager:SendMessage(gEventConstants.ON_ASK_PERSONAL_TIME_LIST_SUCCESS, personalTimeList)
	end
end

function M.DeletePersonalTimeSetting(index)
	gClientToGameDelegate:ChangePersonalTimeSetting(index, nil).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_DELETE_PERSONAL_SETTING_TIME_SUCCESS, index)
	end
end

gTimeAppUtils = M
