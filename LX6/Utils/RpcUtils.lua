-- Original chunk: @Lua\LuaFiles\LX6\Utils\RpcUtils.lua
-- Decompiled from: 00174_RpcUtils.lua_de115a915672.luajit

local MessageConfig = LTConfig.MessageConfig
local RaidUtils = UX.Game.RaidUtils
local M = {
	isSendingSwitchRaidRpc = false
}

DoCallBack = function(callBack)
	if callBack ~= nil then
		return
	end

	if type(callBack) ~= "userdata" then
		callBack.DynamicInvoke(callBack)
	elseif type(callBack) ~= "function" then
		callBack()
	end
end

M.AskEnterHouse = function(self, callBack)
end

M.AskPublicSwitchToPublicScene = function(self, raidId, mapEntranceId, successCb, failedCb)
	if not RaidUtils.CanSwitchPublicScene(raidId) then
		if failedCb then
			failedCb()
		end

		return
	end

	slot5 = gUIUtils

	slot5:CheckCanSwitchScene(function ()
		if self.isSendingSwitchRaidRpc then
			if failedCb then
				failedCb()
			end

			return
		end

		slot0 = gCS.MyPlayerManager.PlayerUnit

		slot0:StopMove()

		self.isSendingSwitchRaidRpc = true
		slot0 = gClientToGameDelegate

		slot0:AskPublicSwitchToPublicScene(raidId, false, mapEntranceId).Callback = function (err)
			self.isSendingSwitchRaidRpc = false

			if err ~= MessageConfig.Ok then
				if successCb then
					successCb()
				end
			else
				gDisplayMessageMgr:ShowMessage(err)

				if failedCb then
					failedCb()
				end
			end
		end
	end)
end

M.AskEnterRaidByRaidId = function(self, RaidId, wayPoint, xAxis, yAxis)
	if self.isSendingSwitchRaidRpc then
		return
	end

	for i = 0, LTConfig.MapentranceConfig.count - 1 do
		local entranceConfig = LTConfig.MapentranceConfig.LoadAt(i)

		if entranceConfig.RaidId ~= gSceneDataMgr.CurrentRaidId and entranceConfig.JiguanRaidID ~= RaidId then
			self.AskEnterRaidByMapEntrance(self, entranceConfig.Id, wayPoint, xAxis, yAxis)

			return
		end
	end

	print_error("RpcUtils AskEnterRaidByRaidId: Cannot find raidMapEntrance by targetRaidId", RaidId, wayPoint)
end

M.AskEnterRaidByMapEntrance = function(self, mapEntranceId, wayPoint, xAxis, yAxis)
	local cfg = LTConfig.MapentranceConfig.GetConfig(mapEntranceId)
	local extParams = LX6.GUI.LoadingManager.AskTeleportExtParams.New()
	local preTeleportOption = UX.Game.PreTeleportOption.New()

	if cfg then
		preTeleportOption.beforeResName = cfg.JiguanStartTimeline
		local coordinate = cfg.Coordinate

		if coordinate and #coordinate > 3 then
			preTeleportOption.customBeforeTrans = true
			preTeleportOption.beforePosition = UX.Game.UXVector3.New(coordinate[1], coordinate[2], coordinate[3])
			preTeleportOption.beforeRot = UX.Game.UXVector3.New(0, cfg.EntranceFacing, 0)
		end

		preTeleportOption.loadingResName = cfg.JiguanLoadingTimeline
		preTeleportOption.afterResName = cfg.JiguanEndTimeline
		extParams.mapEntranceId = mapEntranceId
	end

	slot8 = gLoadingManager

	slot8:AskTeleport(LTConfig.LoadingConfig.EnterExitRoomId, preTeleportOption, extParams, function (loadingInfoIndex)
		slot1 = gCS.MyPlayerManager.PlayerUnit

		slot1:StopMove()

		self.isSendingSwitchRaidRpc = true
		slot1 = gClientToGameDelegate

		slot1:AskEnterRaidByMapEntrance(mapEntranceId).Callback = function (err)
			self.isSendingSwitchRaidRpc = false

			if err ~= MessageConfig.Ok then
				gCS.CameraDataMgr.cinemachineManager:SetPrepareCameraXYAxis(xAxis, yAxis)
				gCS.CameraDataMgr.cinemachineManager:SetCameraXYAxisValue(xAxis, yAxis, 0)
			else
				gLoadingManager:StopLoading(loadingInfoIndex)
				gDisplayMessageMgr:ShowMessage(err)
			end
		end
	end)
end

M.AskEnterQuestSceneRaid = function(self)
	gClientToGameDelegate:AskEnterQuestSceneRaid()
end

local CommandQueueList = {}

M.UpdateRetryRpc = function(self)
	for _, v in pairs(CommandQueueList) do
		local CommandQueue = v

		for m, n in pairs(v) do
			self.RetryRpc(self, CommandQueue, m)
		end
	end
end

M.RetryRpc = function(self, CommandQueue, funcName, isReconnect)
	if table.isNilOrEmpty(CommandQueue[funcName]) then
		if CommandQueue[funcName] then
			CommandQueue[funcName].isInvoking = nil
		end

		CommandQueue[funcName] = nil

		return
	end

	local funcInfo = CommandQueue[funcName][1]

	if funcInfo ~= nil then
		CommandQueue[funcName].isInvoking = nil
		CommandQueue[funcName].isWaitingReconnect = nil

		return
	end

	if CommandQueue[funcName].isWaitingReconnect and not isReconnect then
		return
	end

	if not CommandQueue[funcName].isWaitingReconnect and isReconnect then
		return
	end

	if CommandQueue[funcName].isInvoking then
		return
	end

	self.TryInvokeNextFunc(self, CommandQueue, funcName)
end

M.SendLostPackAgain = function(self)
	for _, v in pairs(CommandQueueList) do
		local CommandQueue = v

		for m, n in pairs(v) do
			self.RetryRpc(self, CommandQueue, m, true)
		end
	end
end

M.SafeQueueAsk = function(self, target, funcName, cb, otherSettings, ...)
	local canCombine = false
	local reconnectSendAgainTime = false
	local dontSendWhenPanelClose = nil
	local argsCanNil = false
	local args = {
		...
	}
	local argsCount = select("#", ...)

	if otherSettings then
		canCombine = otherSettings.canCombine
		reconnectSendAgainTime = otherSettings.reconnectSendAgainTime
		dontSendWhenPanelClose = otherSettings.dontSendWhenPanelClose
		argsCanNil = otherSettings.argsCanNil
	end

	local CommandQueue = {}

	if CommandQueueList[target] == nil then
		CommandQueue = CommandQueueList[target]
	else
		CommandQueueList[target] = CommandQueue
	end

	if not table.isNilOrEmpty(CommandQueue[funcName]) then
		if CommandQueue[funcName].isInvoking then
			local value = {
				funcName = funcName,
				target = target,
				Callback = cb,
				canCombine = canCombine,
				reconnectSendAgainTime = reconnectSendAgainTime,
				dontSendWhenPanelClose = dontSendWhenPanelClose,
				argsCanNil = argsCanNil,
				args = args,
				argsCount = argsCount
			}

			table.insert(CommandQueue[funcName], value)

			return value
		else
			local value = {
				funcName = funcName,
				target = target,
				Callback = cb,
				canCombine = canCombine,
				reconnectSendAgainTime = reconnectSendAgainTime,
				dontSendWhenPanelClose = dontSendWhenPanelClose,
				argsCanNil = argsCanNil,
				args = args,
				argsCount = argsCount
			}

			table.insert(CommandQueue[funcName], value)
			self.TryInvokeNextFunc(self, CommandQueue, funcName)

			return value
		end
	else
		local value = {
			funcName = funcName,
			target = target,
			Callback = cb,
			canCombine = canCombine,
			reconnectSendAgainTime = reconnectSendAgainTime,
			dontSendWhenPanelClose = dontSendWhenPanelClose,
			argsCanNil = argsCanNil,
			args = args,
			argsCount = argsCount
		}
		CommandQueue[funcName] = {
			value
		}

		self.TryInvokeNextFunc(self, CommandQueue, funcName)

		return value
	end
end

M.TryInvokeNextFunc = function(self, CommandQueue, funcName)
	if table.isNilOrEmpty(CommandQueue[funcName]) then
		if CommandQueue[funcName] then
			CommandQueue[funcName].isInvoking = nil
		end

		return
	end

	local funcInfo = CommandQueue[funcName][1]

	if funcInfo ~= nil then
		CommandQueue[funcName].isInvoking = nil
		CommandQueue[funcName].isWaitingReconnect = nil

		return
	end

	if funcInfo.dontSendWhenPanelClose and not gPanelManager:IsPanelShowing(funcInfo.dontSendWhenPanelClose) then
		table.remove(CommandQueue[funcName], 1)
		self.TryInvokeNextFunc(self, CommandQueue, funcName)

		return
	end

	if funcInfo.canCombine then
		self.CombineInvoke(self, CommandQueue, funcName)
	else
		self.InvokeFunc(self, CommandQueue, funcName)
	end
end

M.InvokeFunc = function(self, CommandQueue, funcName)
	local funcInfo = CommandQueue[funcName][1]
	local func = funcInfo.target[funcName]

	local callBack = function(err, ...)
		if funcInfo.Callback then
			funcInfo.Callback(err, ...)
		end

		if err ~= MessageConfig.Disconnect or err ~= MessageConfig.TimeOut or err ~= MessageConfig.PeerTimeOut then
			if funcInfo.reconnectSendAgainTime == nil and funcInfo.reconnectSendAgainTime and funcInfo.reconnectSendAgainTime == true then
				funcInfo.reconnectSendAgainTime = funcInfo.reconnectSendAgainTime - 1
			end

			local funcList = CommandQueue[funcName]
			funcList.isInvoking = nil

			if err ~= MessageConfig.Disconnect then
				funcList.isWaitingReconnect = true
			end

			return
		end

		table.remove(CommandQueue[funcName], 1)
		self:TryInvokeNextFunc(CommandQueue, funcName)
	end

	if not funcInfo.argsCanNil and funcInfo.argsCount <= 0 then
		local firstArg = funcInfo.args[1]

		if firstArg ~= nil or funcInfo.canCombine and table.isNilOrEmpty(firstArg) then
			print_error("发现空数据，查看堆栈注意传入的参数是否为空,无法定位请@jzc")
			print_error("发现空数据，多输出一条info", firstArg)
			callBack(MessageConfig.Ok, {})

			return
		end
	end

	CommandQueue[funcName].isInvoking = true
	func(funcInfo.target, unpack(funcInfo.args, 1, funcInfo.argsCount)).Callback = callBack
end

M.CombineInvoke = function(self, CommandQueue, funcName)
	local funcList = CommandQueue[funcName]
	local funcInfo = CommandQueue[funcName][1]

	if #funcList ~= 1 then
		self.InvokeFunc(self, CommandQueue, funcName)

		return
	end

	local toCombineList = {}

	for i = 1, #funcList do
		if funcList[i].canCombine then
			table.insert(toCombineList, i)
		end
	end

	local argCombine = {}
	local CombineMap = {}

	for i = 1, #toCombineList do
		local Idx = toCombineList[i]
		local funcInfo = funcList[Idx]
		local args = funcInfo.args[1]

		if args == nil then
			for j, k in ipairs(args) do
				if CombineMap[tostring(k)] ~= nil then
					CombineMap[tostring(k)] = {
						original = k
					}
				end

				table.insert(CombineMap[tostring(k)], {
					toCombineListIdx = i,
					argsId = j
				})
			end
		end
	end

	local dataPack = {}

	for _, v in pairs(CombineMap) do
		local dataIdx = 0

		for i = 1, #argCombine do
			if argCombine[i] ~= v.original then
				dataIdx = i

				break
			end
		end

		if dataIdx ~= 0 then
			table.insert(argCombine, v.original)

			dataIdx = #argCombine
		end

		for _, value in ipairs(v) do
			if dataPack[value.toCombineListIdx] ~= nil then
				dataPack[value.toCombineListIdx] = {}
			end

			dataPack[value.toCombineListIdx][value.argsId] = dataIdx
		end
	end

	funcList.isInvoking = true
	local func = funcInfo.target[funcName]

	local callBack = function(err, data)
		local packData = self:PackData(data, dataPack)

		for toCombineListIdx, funcListId in ipairs(toCombineList) do
			local unPackData = packData[toCombineListIdx]
			local funcInfo = funcList[funcListId]

			if funcInfo == nil then
				if funcInfo.Callback then
					funcInfo.Callback(err, unPackData)
				else
					print_error(funcInfo, "callback 不存在，请联系Jzc Debug")
				end
			else
				print_error(funcName, funcListId, "不存在，请联系Jzc Debug")
			end
		end

		if err ~= MessageConfig.Disconnect or err ~= MessageConfig.TimeOut or err ~= MessageConfig.PeerTimeOut then
			for i = #toCombineList, 1, -1 do
				local funcInfo = CommandQueue[funcName][i]

				if funcInfo.reconnectSendAgainTime ~= nil or funcInfo.reconnectSendAgainTime ~= false or funcInfo.reconnectSendAgainTime < 0 then
					table.remove(CommandQueue[funcName], toCombineList[i])
				elseif funcInfo.reconnectSendAgainTime == true and funcInfo.reconnectSendAgainTime <= 0 then
					funcInfo.reconnectSendAgainTime = funcInfo.reconnectSendAgainTime - 1
				end
			end

			local funcList = CommandQueue[funcName]
			funcList.isInvoking = nil

			if err ~= MessageConfig.Disconnect then
				funcList.isWaitingReconnect = true
			end

			return
		end

		for i = #toCombineList, 1, -1 do
			table.remove(CommandQueue[funcName], toCombineList[i])
		end

		self:TryInvokeNextFunc(CommandQueue, funcName)
	end

	if table.isNilOrEmpty(argCombine) then
		print_error("发现空数据，查看堆栈注意传入的参数是否为空,无法定位请@jzc")
		print_error("发现空数据，多输出一条info", funcInfo.args, funcName)
		callBack(MessageConfig.Ok, {})

		return
	end

	func(funcInfo.target, argCombine).Callback = callBack
end

M.PackData = function(self, cbData, packMap)
	for dataIdx = 1, #packMap do
		local argsList = packMap[dataIdx]

		for argId = 1, #argsList do
			local cbDataId = argsList[argId]
			local argCbData = cbData[cbDataId]
			packMap[dataIdx][argId] = argCbData
		end
	end

	if table.isNilOrEmpty(packMap) then
		if cbData ~= nil then
			return {}
		end

		return cbData
	end

	return packMap
end

gRpcUtils = M
