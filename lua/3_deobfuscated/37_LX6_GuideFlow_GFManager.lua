require("LX6/GuideFlow/GFCondition")
require("LX6/GuideFlow/GFConstant")
require("LX6/GuideFlow/New/RequireAllGuide")

local DataSet = require("LX6/DataBind/DataSet")
local GameObject = UnityEngine.GameObject
local MessageConfig = LTConfig.MessageConfig
local GuideConfig = LTConfig.GuideGuideGroupConfig
local LayerConstants = LX6.Constants.LayerConstants
C_GFManager = DefClass("C_GFManager", C_GFManager)
local M = C_GFManager

function M:ctor()
	self.SEventType = {
		CloseGuide = 2,
		RenderGuideSmartLine = 9,
		BeginMatchGuide = 7,
		SkipGuide = 5,
		EndMatchGuide = 8,
		OpenGuide = 1,
		RenderGuidePopup = 6,
		IncorrectCloseGuide = 3,
		NextGuide = 4
	}
	self.sguiEventHandlers = {}
	self.start = false
	self.ready = false
	self.count = 0
	self.typeListGuideIdToGuideData = {}
	self.typeListGuideDataToGuideId = {}
	self.guideIdToGuideType = {}
	self.triggerCount = 0
	self.panelId2GuideId = {}
	self.guideTreePathPrefix = "LuaGen/GuideFlow/GFBehaviourTree/GuideTree_"
	self.eventCell = {}
	self.currentGuideId = -1
	self.currentCounterId = -1
	self.activeTree = false
	self.nodeNameToFreeClickMaskParamList = {}
	self.nodeIdDict = {}
	self.prefabPath = "Assets/Res/Prefab/GUI/V3GuideFreeClickMask.prefab"
	self.guideFreeClickMaskPrefabLoadOp = nil
	self.Debug = false
	self.ClientDebug = false
	self.DebugActions = {}
	self.TypeNameDict = {
		[gGFConstant.StartType.Server] = "Server"
	}
	self.isUIMaskState = false
	self.isForceOpenEasyTouch = false
	self.isEasyTouchMaskState = false
	self.CanClickInGuidePanelIds = {}
	self.clickGuidePanelInit = false
	self.uiMaskCount = 0
	self.uiMaskDict = {}
	self.etMaskCount = 0
	self.etMaskDict = {}
	self.gmEnableGuide = true
	self.openedPanelId = {}
end

function M:OnInit()
	gNewGuideMgr:OnInit()
	self:ReLoadAllRegisters()
	self:AddListeners()
	self:MapPanelIdToGuideId()

	function SGUI.GuideMgr.onCloseGuide(uGuide)
		gNewGuideMgr:ResolveCloseUGuide(uGuide)
		self:OnSGUIGuideEvent(self.SEventType.CloseGuide, uGuide)
	end

	function SGUI.GuideMgr.onNextGuide(guideId)
		self:OnSGUIGuideEvent(self.SEventType.NextGuide, guideId)
	end

	function SGUI.GuideMgr.onSkipGuide(guideId)
		self:OnSGUIGuideEvent(self.SEventType.SkipGuide, guideId)
	end

	function SGUI.GuideMgr.onOpenGuide(uGuide)
		gNewGuideMgr:ResolveOpenUGuide(uGuide)
		self:OnSGUIGuideEvent(self.SEventType.OpenGuide, uGuide)
	end

	function SGUI.GuideMgr.onDestroyUsedGuide(uGuide)
		gNewGuideMgr:ResolveDestroyUsedUGuide(uGuide)
		self:OnSGUIGuideEvent(self.SEventType.DestroyGuide, uGuide)
	end

	function SGUI.GuideMgr.onIncorrectCloseGuide(guideId)
		self:OnSGUIGuideEvent(self.SEventType.IncorrectCloseGuide, guideId)
	end

	function SGUI.GuideMgr.onRenderGuidePopup(guideId, component)
		self:OnSGUIGuideEvent(self.SEventType.RenderGuidePopup, guideId, component)
	end

	function SGUI.GuideMgr.onBeginMatchGuide(guideId)
		self:OnSGUIGuideEvent(self.SEventType.BeginMatchGuide, guideId)
	end

	function SGUI.GuideMgr.onEndMatchGuide(guideId)
		self:OnSGUIGuideEvent(self.SEventType.EndMatchGuide, guideId)
	end

	function SGUI.GuideMgr.onRenderGuideSmartLine(guideId, component)
		self:OnSGUIGuideEvent(self.SEventType.RenderGuideSmartLine, guideId, component)
	end
end

function M:IsRunnable()
	local runnable = gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene and not gPanelManager:IsPanelShowing(gPanelId.PVP_LOADING_PANEL) and not LX6.Scene.SwitchSceneManager.AfterSwitchShow_CheckShowPlaying()

	if gCS.LuaUtils.IsOnEditor and not gLuaDataManager.isNetworkAvailable then
		runnable = false
	end

	return runnable
end

function M:OnUpdate()
	if not self.gmEnableGuide then
		return
	end

	local runnable = self:IsRunnable()

	if runnable then
		if self.delayedActiveGuideData then
			self:_InternalActiveGuide(self.delayedActiveGuideData.guideId, self.delayedActiveGuideData.counter)
		end

		gNewGuideMgr:OnUpdate()
	end

	if self.start and runnable then
		self.count = 0

		if self.activeTree then
			local state = self.activeTree:DoUpdateState()

			if gGFConstant.State.Running < state then
				local guideId = self.activeTree:GetId()
				local counter = self.activeTree:GetCounter()

				print_notice("GF Debug => 引导正常运行结束, GuideId=", guideId, " CounterId=", counter, " Desc=", self.activeTree:GetDesc(), Time.time, Time.frameCount)
				self:StopCurrentGuide()

				local cfg = GuideConfig.GetConfig(guideId)

				if cfg then
					if counter < cfg.GroupNum then
						if not self.ClientDebug then
							print_notice("GF Debug => AskDoGuide 请求触发下一个引导, GuideId=", guideId, " CounterId=", counter + 1, Time.time, Time.frameCount)

							gClientToGameDelegate:AskDoGuide(guideId, counter + 1).Callback = function (err)
								print_notice("GF Debug => AskDoGuide CallBack, GuideId=", guideId, " CounterId=", counter + 1, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)

								if err == MessageConfig.Ok then
									self:ActiveGuide(guideId, counter + 1)
								end
							end
						end
					elseif cfg.GroupNum == counter and not self.ClientDebug then
						print_notice("GF Debug => AskFinishGuide 请求结束引导, GuideId=", guideId, Time.time, Time.frameCount)

						gClientToGameDelegate:AskFinishGuide(guideId, true).Callback = function (err)
							print_notice("GF Debug => AskFinishGuide CallBack, GuideId=", guideId, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)
						end
					end
				end
			else
				self.count = self.count + 1
			end
		end

		for id, action in pairs(self.DebugActions) do
			local state = action:DoUpdateState()

			if gGFConstant.State.Running < state then
				print_notice("GF Debug => 调试Action执行结束, Finish, Action节点uuid=", id)
				action:StopNode()

				self.DebugActions[id] = nil
			else
				self.count = self.count + 1
			end
		end

		if self.count == 0 then
			self.start = false
		end
	end
end

function M.Reset()
	print_notice("GF Debug => 刷新引导注册", Time.time, Time.frameCount)
	gGFManager:ClearAllActiveGuide()
	gGFManager:ReLoadAllRegisters()
end

function M:AddListeners()
	gMessageManager:AddMessageListener(gEventConstants.CONFIG_HOT_FIX, self.Reset)
	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_SHOW, function (eventId, data)
		self:OnPanelShow(eventId, data)
	end)
	gMessageManager:AddMessageListener(gEventConstants.ON_KICK_TO_LOGIN, function ()
		self:StopCurrentGuide()
	end)
end

function M:ReLoadAllRegisters()
	if self.ready then
		for eventName, cell in pairs(self.eventCell) do
			gPlayerManager.guideEvents.bindData:UnBindCell(cell)

			gPlayerManager.guideEvents.bindData[eventName] = DataSet.INIT_EMPTY_VALUE
		end
	end

	self.typeListGuideIdToGuideData = {}
	self.guideIdToGuideType = {}
	self.triggerCount = 0
	self.activeTree = false
	self.eventCell = {}
	self.ready = false
	self.start = false

	dofile("LuaGen/GuideFlow/Register/GuideRegisters")
	print_notice("GF Debug => 引导注册完成,共注册了", self.triggerCount, "条引导", Time.time, Time.frameCount)
end

function M:ClearAllActiveGuide()
	self:UnActiveCurrentGuide()
	self:ClearDebugActions()

	self.start = false
end

function M:Prepare()
	for i = 0, gGFConstant.StartType.Count - 1 do
		self.typeListGuideIdToGuideData[i] = {}
		self.typeListGuideDataToGuideId[i] = {}
	end

	self.guideIdToGuideType = {}
	self.ready = true
end

function M:RegisterGBTree(guideType, guideId, data)
	if not self.ready then
		self:Prepare()
	end

	local cfg = GuideConfig.GetConfig(guideId)

	if cfg then
		self.typeListGuideIdToGuideData[guideType][guideId] = data
		self.guideIdToGuideType[guideId] = guideType
		self.triggerCount = self.triggerCount + 1

		if self.Debug then
			print_notice("GF Debug => ---注册引导 guideId=", guideId, " guideType=", self:GetTypeName(guideType), "guideData=", data, "dataType=", type(data), Time.time, Time.frameCount)
		end
	elseif self.Debug then
		print_notice("GF Debug => ---【注册失败】 配表中没有配置该引导 guideId=", guideId, " guideType=", self:GetTypeName(guideType), "guideData=", data, "dataType=", type(data), Time.time, Time.frameCount)
	end
end

function M:ActiveGuideAndNotify(guideId, counter, taskId)
	if not self:IsRunnable() then
		return
	end

	if taskId and taskId > 0 then
		gClientToGameDelegate:AskStartGuideByClient(guideId, taskId).Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_debug("GF Debug => AskStartGuideByClient 请求失败, GuideId=", guideId, "taskId=", taskId, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)
			end
		end
	end

	self:ActiveGuide(guideId, counter)
end

function M:ActiveGuide(guideId, counter, gmNoCheck)
	if not self.gmEnableGuide then
		print_notice("GF Debug => 引导激活失败，未开启引导功能 ", guideId, counter)

		return
	end

	print_notice("GF Debug => 尝试激活引导,guideId=", guideId, "counterId=", counter, Time.time, Time.frameCount)
	gNewGuideMgr:StopGuide()

	if self.activeTree then
		if not self.ClientDebug then
			print_notice("GF Debug => 激活引导冲突,当前有正在运行的引导,不影响正常使用,但是请排查冲突原因,guideId=", self.currentGuideId, "counterId=", self.currentCounterId, Time.time, Time.frameCount)
		end

		self:UnActiveCurrentGuide()
	end

	local cfg = GuideConfig.GetConfig(guideId)

	if gmNoCheck or cfg then
		if gmNoCheck or counter <= cfg.GroupNum then
			if gNewGuideMgr:HasGuide(guideId) then
				if self:IsRunnable() or gmNoCheck then
					self:_InternalActiveGuide(guideId, counter)
				else
					self.delayedActiveGuideData = {
						guideId = guideId,
						counter = counter
					}
				end

				self:RefreshDynamicUpdate()
			else
				print_error("@huangzhecong 没有找到引导（引导文件不存在或只有旧引导）, guideId=" .. guideId)
			end
		else
			print_error("GF Debug => 激活引导失败,引导GroupNum < counter,请检查配置: guideId=", guideId, "GroupNum=", cfg.GroupNum, "counterId=", counter, Time.time, Time.frameCount)
		end
	else
		print_error("GF Debug => 激活引导失败,引导Id在表里不存在,请检查配表: guideId=", guideId, Time.time, Time.frameCount)
	end
end

function M:_InternalActiveGuide(guideId, counter)
	self.delayedActiveGuideData = nil

	self:RefreshOpenedPanelId(guideId)
	gNewGuideMgr:ActiveGuide(guideId, counter)
end

function M:UnActiveCurrentGuide()
	gNewGuideMgr:StopGuide()

	if self.activeTree then
		self.activeTree:Destroy()

		self.activeTree = false
		self.currentGuideId = -1
		self.currentCounterId = -1
	end
end

function M:StopCurrentGuide()
	gNewGuideMgr:StopGuide()

	if self.activeTree then
		local guideId = self.activeTree.mGuideId
		local counterId = self.activeTree.mCounterId

		self.activeTree:StopNode()
		print_debug("[GuideFlow]: StopGuide", guideId, counterId)
		gMessageManager:SendMessage(gEventConstants.GUIDE_FLOW_FINISH, {
			guideId = guideId,
			counterId = counterId
		})
	end

	if self.ClientDebug then
		for id, _ in pairs(self.DebugActions) do
			self.DebugActions[id]:StopNode()
		end
	end
end

function M:RemoveGuideTriggerByTypeId(guideType, guideId)
	if self.Debug then
		print_notice("GF Debug => 移除已完成的引导,guideId=", guideId, "guideType=", self:GetTypeName(guideType), "guideData=", self.typeListGuideIdToGuideData[guideType][guideId], Time.time, Time.frameCount)
	end

	self.typeListGuideIdToGuideData[guideType][guideId] = nil
	self.guideIdToGuideType[guideId] = nil

	self:RefreshOpenedPanelId(guideId)
end

function M:RemoveGuideTriggerById(guideId)
	local guideType = self.guideIdToGuideType[guideId]

	if guideType then
		self:RemoveGuideTriggerByTypeId(guideType, guideId)
	end
end

function M:RemoveGuideTriggers(guideIds)
	for guideId, _ in pairs(guideIds) do
		self:RemoveGuideTriggerById(guideId)
	end

	if self.Debug then
		print_notice("GF Debug => 移除后剩余监听中的引导如下：", Time.time, Time.frameCount)

		local count = 0

		for guideId, type in pairs(self.guideIdToGuideType) do
			print_notice("GF Debug => ---guideId=", guideId, " guideType=", self:GetTypeName(type), "guideData=", self.typeListGuideIdToGuideData[type][guideId], Time.time, Time.frameCount)

			count = count + 1
		end

		print_notice("GF Debug => 移除后剩余监听中的引导总数为", count, "条 ", Time.time, Time.frameCount)
	end
end

function M:RefreshDynamicUpdate()
	if self.delayedActiveGuideData or gNewGuideMgr.activeGuideBT then
		gLuaClient:RegisterDynamicUpdate("gGFManager", self)
	else
		gLuaClient:UnregisterDynamicUpdate("gGFManager")
	end
end

function M:OnPanelShow(eventId, data)
	local panelId = data

	if not panelId or self.openedPanelId[panelId] then
		return
	end

	local guideId = self.panelId2GuideId[panelId]

	if guideId == nil then
		return
	end

	gClientToGameDelegate:AskDoGuide(guideId, 1).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_debug("GF Debug => AskStartGuideByClient 请求失败, GuideId=", guideId, "counter=", 1, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:UnActiveCurrentGuide()
		self:ClearTouchMask()
		self:ClearAllFreeClickMask()
		gResourceManager:UnloadAssetLoadOp(self.guideFreeClickMaskPrefabLoadOp)

		self.guideFreeClickMaskPrefabLoadOp = nil

		self:ReLoadAllRegisters()

		return
	end

	if gSwitchSceneType.Reconnect < switchType then
		gResourceManager:UnloadAssetLoadOp(self.guideFreeClickMaskPrefabLoadOp)

		self.guideFreeClickMaskPrefabLoadOp = nil

		self:StopCurrentGuide()
	end
end

function M:GetFreeClickMaskPrefab()
	if not self.guideFreeClickMaskPrefabLoadOp then
		self.guideFreeClickMaskPrefabLoadOp = gResourceManager:LoadAsset(gGFManager.prefabPath, typeof(GameObject))
	end

	return self.guideFreeClickMaskPrefabLoadOp
end

function M:AddGuideNodeFreeClickMask(nodeName, nodeId, maskParam)
	if self.nodeIdDict[nodeId] then
		return
	end

	local list = self.nodeNameToFreeClickMaskParamList[nodeName]

	if list == nil then
		list = {}
		self.nodeNameToFreeClickMaskParamList[nodeName] = list
	end

	table.insert(list, maskParam)

	self.nodeIdDict[nodeId] = true
	local obj = maskParam.freeClickMaskObj

	if obj then
		-- Nothing
	end
end

function M:RemoveGuideNodeFreeClickMaskById(nodeName, nodeId, nodeDestroy)
	if not self.nodeIdDict[nodeId] then
		return
	end

	self.nodeIdDict[nodeId] = nil
	local list = self.nodeNameToFreeClickMaskParamList[nodeName]

	if list == nil then
		return
	end

	if nodeDestroy then
		list = nil
	else
		for i = 1, #list do
			local isLast = i == #list
			local param = list[i]

			if param.nodeId == nodeId then
				table.remove(list, i)

				if #list == 0 then
					list = nil

					if not gCS.LuaUtils.IsNull(param.freeClickMaskObj) and not param.freeClickMaskObj:IsDestroyed() then
						GameObject.DestroyImmediate(param.freeClickMaskObj)

						param.freeClickMaskObj = nil
					end
				elseif isLast then
					param = list[#list]

					if not gCS.LuaUtils.IsNull(param.freeClickMaskObj) and not param.freeClickMaskObj:IsDestroyed() then
						-- Nothing
					end
				end

				return
			end
		end
	end
end

function M:ClearAllFreeClickMask()
	for nodeName, paramList in pairs(self.nodeNameToFreeClickMaskParamList) do
		for i = #paramList, 1, -1 do
			local param = paramList[i]

			if param.freeClickMaskObj and not param.freeClickMaskObj:IsDestroyed() then
				GameObject.Destroy(param.freeClickMaskObj)

				param.freeClickMaskObj = nil
			end

			table.remove(paramList, i)
		end
	end

	self.nodeNameToFreeClickMaskParamList = {}
	self.nodeIdDict = {}
end

function M:RemoveDebugAction(id)
	if self.DebugActions[id] then
		self.DebugActions[id]:DestroyNode()

		self.DebugActions[id] = nil
	end
end

function M:ClearDebugActions()
	for id, _ in pairs(self.DebugActions) do
		self.DebugActions[id]:DestroyNode()

		self.DebugActions[id] = nil
	end
end

function M:SetClientDebug()
	self.ClientDebug = true
	self.Debug = true

	print_notice("GFManager ClientDebug Enable True")
end

function M:SetDebugMode()
	self.Debug = true
	self.ClientDebug = false

	print_notice("GF Debug => SetDebugMode", self.Debug)
end

function M:CloseDebug()
	self.ClientDebug = false
	self.Debug = false

	self:ClearDebugActions()
end

function M:RefreshDebugInfo()
	for id, _ in pairs(self.DebugActions) do
		self.DebugActions[id]:RefreshDebugInfo()
	end

	if self.activeTree then
		self.activeTree:RefreshDebugInfo()
	end

	print_notice("GF Debug => GFManager RefreshDebugInfo()")
	self:PrintCurrentRunningState()
end

function M:SwitchGuide(isOpen)
	if self.gmEnableGuide == isOpen then
		return
	end

	print_notice("GF Debug => Switch Guide from ", self.gmEnableGuide, " to ", isOpen)

	if self.gmEnableGuide then
		self:ClearAllActiveGuide()
	else
		self:ReLoadAllRegisters()
	end

	self.gmEnableGuide = isOpen
end

function M:PrintCurrentRunningState()
	print_notice("GF Debug => CURRENT STATE: ", self.activeTree and "存在正在激活的引导 guideId=" .. self.activeTree.mGuideId .. " counterId=" .. self.activeTree.mCounterId .. " desc=" .. self.activeTree.mDescribe or "没有正在激活的引导")
	print_notice("GF Debug => CURRENT STATE: ---当前引导update状态=", self.start)

	if self.activeTree then
		print_notice("GF Debug => CURRENT STATE: --------各引导节点激活和运行情况--------")
		self.activeTree:PrintCurrentRunningState()
	end

	print_notice("GF Debug => CURRENT STATE: --------当前引导监听队列--------")

	local count = 0

	for guideId, type in pairs(self.guideIdToGuideType) do
		print_notice("GF Debug => ---guideId=", guideId, " guideType=", self:GetTypeName(type), "guideData=", self.typeListGuideIdToGuideData[type][guideId])

		count = count + 1
	end

	print_notice("GF Debug => --------监听中的引导总数为", count, "条--------")
	print_notice("GF Debug => CURRENT STATE: --------当前引导完成队列--------")

	count = 0

	for guideId, _ in pairs(gPlayerManager.infoMinor.bindData.FinishedGuides) do
		print_notice("GF Debug => ---guideId=", guideId)

		count = count + 1
	end

	print_notice("GF Debug => --------完成的引导总数为", count, "条--------")
end

function M:IsUIMask()
	return self.isUIMaskState
end

function M:SetTouchMask(isMask, maskId, notDragEnd)
	self:SetUITouchMask(isMask, maskId, notDragEnd)
	self:SetEasyTouchMask(isMask, maskId)
end

function M:SetUITouchMask(isMask, maskId, notDragEnd)
	if isMask then
		if not self.uiMaskDict[maskId] then
			self.uiMaskDict[maskId] = true
			self.uiMaskCount = self.uiMaskCount + 1

			self:RefreshUICamerasEventMask(notDragEnd)
		end
	elseif self.uiMaskDict[maskId] then
		self.uiMaskDict[maskId] = nil
		self.uiMaskCount = self.uiMaskCount - 1

		self:RefreshUICamerasEventMask(notDragEnd)
	end
end

function M:SetEasyTouchMask(isMask, maskId)
	if isMask then
		if not self.etMaskDict[maskId] then
			self.etMaskDict[maskId] = true
			self.etMaskCount = self.etMaskCount + 1

			self:RefreshEasyTouchState()
		end
	elseif self.etMaskDict[maskId] then
		self.etMaskDict[maskId] = nil
		self.etMaskCount = self.etMaskCount - 1

		self:RefreshEasyTouchState()
	end
end

function M:RefreshUICamerasEventMask(notDragEnd)
	if notDragEnd == nil then
		notDragEnd = false
	end

	local needMaskUI = self.uiMaskCount > 0

	if needMaskUI ~= self.isUIMaskState then
		self.isUIMaskState = needMaskUI

		self:RefreshGuideAllUICameraLayer()

		local cullingmask = math.pow(2, LayerConstants.Ui)

		if needMaskUI then
			cullingmask = cullingmask + math.pow(2, LayerConstants.Default)
		end

		if not self.clickGuidePanelInit then
			self.clickGuidePanelInit = true
		end

		for k, v in pairs(self.CanClickInGuidePanelIds) do
			local go = gLuaDataManager.guiMgr.panelCache:GetUICacheObject(k)

			if go then
				SGUITools.SetLayer(go, needMaskUI and LayerConstants.Default or LayerConstants.Ui)
			end
		end

		gMessageManager:SendMessage(gEventConstants.UI_REFRESH_CAMERA_EVENT_MASK)
	end
end

function M:RefreshEasyTouchState()
	local needMask = self.etMaskCount > 0

	if self.isEasyTouchMaskState ~= needMask then
		self.isEasyTouchMaskState = needMask
	end
end

function M:ClearTouchMask()
	if self.isUIMaskState then
		self.uiMaskDict = {}
		self.uiMaskCount = 0

		self:RefreshUICamerasEventMask()
	end

	if self.isEasyTouchMaskState then
		self.etMaskDict = {}
		self.etMaskCount = 0

		self:RefreshEasyTouchState()
	end
end

function M:RefreshGuideAllUICameraLayer()
	return
end

function M:GetTypeName(startType)
	return self.TypeNameDict[startType] or startType
end

function M:RegisterSGUIGuideEvent(type, callback)
	local link = self.sguiEventHandlers[type]

	if link == nil then
		link = list:new()
		self.sguiEventHandlers[type] = link
	end

	link:push(callback)
end

function M:UnRegisterSGUIGuideEvent(type, callback)
	local link = self.sguiEventHandlers[type]

	if link ~= nil then
		link:erase(callback)
	end
end

function M:OnSGUIGuideEvent(eventType, ...)
	local link = self.sguiEventHandlers[eventType]

	if link ~= nil then
		for _, value in ilist(link) do
			value(...)
		end
	end
end

function M:MapPanelIdToGuideId()
	self.panelId2GuideId = {}

	for i = 0, GuideConfig.count - 1 do
		local cfg = GuideConfig.LoadAt(i)

		if cfg.Tag == gGFConstant.GuideTagType.OnPanelOpen then
			self.panelId2GuideId[cfg.PanelId] = cfg.Id
		end
	end
end

function M:RefreshOpenedPanelId(guideId)
	local cfg = GuideConfig.GetConfig(guideId)

	if cfg ~= nil and cfg.Tag == gGFConstant.GuideTagType.OnPanelOpen then
		local panelId = cfg.PanelId

		if panelId ~= nil then
			self.openedPanelId[panelId] = true
		end
	end
end

gGFManager = gGFManager or C_GFManager.new()
