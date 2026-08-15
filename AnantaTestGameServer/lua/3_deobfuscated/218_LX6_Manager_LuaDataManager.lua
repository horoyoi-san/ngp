local coroutine = coroutine
local DRPFUtils = LX6.Utils.DRPFUtils
local M = {
	isServerConnected = false,
	isNormalConnected = false,
	isTakePhoto = false,
	needSyncEffect = false,
	needSyncActionDatas = true,
	AskFlag = false,
	loadingScene = false,
	isNetworkAvailable = false,
	TeamBroadCastTime = 0,
	TestNewPlayAction = true,
	isLoadingPanelOn = false,
	gameStage = LX6.Scene.SwitchSceneManager.GameStage.None,
	sceneUnitInfoList = {},
	receivedRewardEnemies = {},
	openedPanelList = {}
}
local mt = {}

function M:OnInit()
	self.guiMgr = LX6.GUI.GuiMgr.Instance
	self.gravityNormalized = Vector3.New(0, -1, 0)
	self.msgCoList = {}
	self.isShowDialogNpcPanel = false
	self.serverTime = 0
	self.serverUnixTime = 0

	setmetatable(M, mt)
	gPanelManager:Init()
	gMessageManager:AddMessageListener(gEventConstants.PLAYER_LEVEL_CHANGE, self.MyLevelChange)
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self.OnAfterSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.LOAD_SCENE_COMPLETED, self.OnLoadSceneComplete)
	gMessageManager:AddMessageListener(gEventConstants.ON_DISCONNECT, self.OnDisconnect)
	gMessageManager:AddMessageListener(gEventConstants.CONFIG_HOT_FIX, self.HotConfigChange)
	gLuaUIMgr:Init()
	gMapUtils:Init()
end

function M:OnBeforeSwitchScene(switchType)
	self.sceneUnitInfoList = {}
	local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

	if myPlayerCSUnit and not myPlayerCSUnit.IsDestroyed then
		gCS.MotionFlagManager.SetIsInRush(myPlayerCSUnit, false)
	end

	self.loadingScene = true

	if gSwitchSceneType.Image <= switchType then
		self.isShowDialogNpcPanel = false
	end

	if gSwitchSceneType.NewScene <= switchType then
		self.needSyncActionDatas = true
	end

	if switchType == gSwitchSceneType.KickToLogin then
		self.cacheDelegate = false
		self.loadingScene = false
		self.calcLoadTime = false
		self.receiveGlobalMessage = false

		self:ClearLoopMessage()

		self.myId = nil
		self.isActionEndPlay = false
	end
end

local lastCheckTime01 = 0

function M:OnUpdate()
	gTimeNotificationManager:Update()

	if Time.time - lastCheckTime01 > 0.1 then
		lastCheckTime01 = Time.time

		gRpcUtils:UpdateRetryRpc()
	end
end

function M.OnLoadSceneComplete()
	M.loadingScene = false
end

function M.OnDisconnect()
	M.sceneUnitInfoList = {}
end

function M.HotConfigChange(eventId, data)
	gCsToLuaHandler:HotConfigChange(eventId, data)
	gUIUtils:OnConfigHotfix(eventId, data)
	gNpcInteracsUtils.OnConfigHotfix(eventId, data)
	gCurveUtils.OnConfigHotfix(eventId, data)
	gHurtStiffManager:OnInit()
	gMainMenuMgr:InitClientStateConfig(eventId, data)
end

function M:CheckEnableShareScene()
	return
end

function M.MyLevelChange()
	M:CheckEnableShareScene()
end

function M.OnAfterSwitchScene(eventId, switchType)
	if switchType == gSwitchSceneType.Reconnect then
		gRpcUtils:SendLostPackAgain()
	elseif switchType == gSwitchSceneType.NewScene then
		M.relaxActionCount = 0

		gAntiAddictionManager:ShowNoIdentityUI()

		if not M.calcLoadTime then
			M.calcLoadTime = true

			DRPFUtils.SendLoadInfo()
		end

		gMessageManager:SendMessage(gEventConstants.SHOW_RAID_NAME, gRaidDataManager.RaidId)
	end
end

function M.MsgCo(data)
	local interTime = data.Interval
	local endTime = data.EndTime
	local startTime = data.StartTime

	while true do
		local curTime = M.gCS.TimeManager.ServerUnixTime

		if curTime < startTime then
			coroutine.wait(interTime)
		elseif curTime < endTime then
			if gLuaUIMgr.rollingMsgPanel then
				gLuaUIMgr.rollingMsgPanel.ShowMessage(data.Content)
			end

			coroutine.wait(interTime)
		else
			M:CloseLoopMessage(data.Id)

			break
		end
	end
end

function M:ShowLoopMessage(message)
	local isExist = false

	for i = 1, #self.msgCoList do
		if tostring(message.Id) == tostring(self.msgCoList[i].Id) then
			isExist = true
		end
	end

	if not isExist then
		local co = coroutine.start(self.MsgCo, message)

		table.insert(self.msgCoList, {
			Id = tostring(message.Id),
			Co = co
		})
	end
end

function M:CloseLoopMessage(messageId)
	local index = -1

	for i, kv in ipairs(self.msgCoList) do
		messageId = tostring(messageId)

		if kv.Id == messageId then
			index = i
		end
	end

	if index ~= -1 then
		local co = self.msgCoList[index].Co

		if co ~= nil then
			coroutine.stop(co)

			self.msgCoList[index].Co = nil

			table.remove(self.msgCoList, index)
		end
	end
end

function M:ClearLoopMessage()
	if self.msgCoList ~= nil then
		for i = #self.msgCoList, 1, -1 do
			if self.msgCoList[i] ~= nil then
				self:CloseLoopMessage(self.msgCoList[i].Id)
			end
		end

		self.msgCoList = {}
	end
end

function M:PlayTimeline(tlName, pos, rot, successCb, failedCb, endCb)
	local data = gTimelineManager:Timeline_CreateTimelineData()

	local function failedFunc()
		print_error("播放timeline 失败  name =" .. tlName)
		failedCb()
	end

	if successCb then
		data.onLoadDoneCb = successCb
	end

	if failedCb then
		data.onLoadFailedCb = failedFunc
	end

	if endCb then
		data.onFinishCb = endCb
	end

	data.pos = pos or Vector3.zero
	data.rot = rot or Vector3.zero

	gTimelineManager:Timeline_LoadAndPlay(tlName, data)
end

gLuaDataManager = M

return gLuaDataManager
