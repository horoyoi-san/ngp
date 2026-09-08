-- Original chunk: @Lua\LuaFiles\LX6\Guide\NewGuideMgr.lua
-- Decompiled from: 00365_NewGuideMgr.lua_07d0f14d6ae8.luajit

local GuideConfig = LTConfig.GuideGuideGroupConfig
local MessageConfig = LTConfig.MessageConfig
local GuideTextConfig = LTConfig.GuideGuideTextConfig
local GuideBTPath = "LuaGen/GuideFlow/GuideBT/"
C_NewGuideMgr = DefClass("C_NewGuideMgr", C_NewGuideMgr, nil)
local M = C_NewGuideMgr
local guideMgrSharp = LX6.Guide.GuideManager

M.ctor = function(self)
	self:_InitSGUIFields()

	self.delayedActiveGuideData = nil
	self.activeGuideBT = nil
	self.preLoadResourcesDic = {}
	self.panelPreLoadRefCount = {}
	self.patchBTCreatorDic = self.patchBTCreatorDic or {}
	self.globalPauseUUID = nil
	self.enableDebug = false
	self.eventHandler = nil
	self.deviceChangeHandlers = {}
end

M.OnInit = function(self)
	gGuideGlyph:RefreshAllButtonNameDic()

	self.lastDeviceSwitchTime = -1
	self.deviceSwitchDelay = 0.5

	if self.eventHandler then
		gMessageManager:UnregisterEventHandlers(self.eventHandler)
	end

	self.eventHandler = {
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = function ()
			self:OnControlSchemeChange()
			self:OnDeviceChangeCheckUsage(false)
		end,
		[gEventConstants.LANGUAGE_CHANGE] = function ()
			self:OnLanguageChange()
		end,
		[gEventConstants.ON_KICK_TO_LOGIN] = function ()
			self:StopGuide()
		end,
		[gEventConstants.DO_CHECK_SHOW] = function (_, panelId)
			self:NotifySignal(EGuideSignal.ShowPanel, tostring(panelId))
		end,
		[gEventConstants.DO_CLOSE] = function (_, panelId)
			self:NotifySignal(EGuideSignal.ClosePanel, tostring(panelId))
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandler)
	self:InitAllSGUIEventTrigger()
end

M.OnUpdate = function(self)
	local runnable = self:IsRunnable()

	if runnable then
		if self.delayedActiveGuideData then
			self:_InternalActiveGuide(self.delayedActiveGuideData.guideId, self.delayedActiveGuideData.counter)
		end

		if self.pendingDeviceCheckNoMessage == nil then
			local noMessage = self.pendingDeviceCheckNoMessage
			self.pendingDeviceCheckNoMessage = nil

			self:OnDeviceChangeCheckUsage(noMessage)
		end

		if self.pendingDeviceNotify then
			local targetPage = self.pendingDeviceNotify
			self.pendingDeviceNotify = nil

			if not gPanelManager:IsPanelShowing(gPanelId.S_SETTINGS_PANEL) then
				gDisplayMessageMgr:ShowMessage(MessageConfig.DeviceSwitchGuideNotify, function ()
					gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL, {
						page = targetPage
					})
				end)
			end
		end

		if self.activeGuideBT and self.activeGuideBT.finishByBT then
			self:StopGuide(true)
		end

		if self.activeGuideBT then
			self.activeGuideBT:DoTick()
		end

		if self.activeGuideBT and self.activeGuideBT.finishByBT then
			self:StopGuide(true)
		end
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	self:EndPlayerVehicleColliderCheck()

	if switchType ~= gSwitchSceneType.KickToLogin then
		print_debug("[NewGuideMgr]:踢出到登陆界面停止引导", switchType)
		self:StopGuide()

		self.hasSyncedInputDeviceUsage = false
		self.syncedInputDeviceUsage = {}
		self.lastDeviceSwitchTime = -1
	elseif switchType ~= gSwitchSceneType.Reconnect then
		-- Nothing
	end
end

M.HasGuide = function(self, guideId)
	if gGameManager.Env.isEditor or not self.registerTable then
		self:ReloadRegisterTable()
	end

	if self.registerTable[guideId] then
		return true
	else
		return false
	end
end

M.ReloadRegisterTable = function(self)
	local data = dofile("LuaGen/GuideFlow/Register/NewGuideRegister")
	self.registerTable = {}

	for _, guideData in ipairs(data) do
		local guideId = guideData.guideId
		local counter = guideData.counter

		if not self.registerTable[guideId] then
			self.registerTable[guideId] = {}
		end

		self.registerTable[guideId][counter] = true
	end
end

M.AddPatch = function(self, guideId, counterId, bt)
	if not guideId or not counterId then
		print_error("AddPatch guideId or counterId is nil, guideId=", guideId, " counterId=", counterId)

		return
	end

	if not self.patchBTCreatorDic[guideId] then
		self.patchBTCreatorDic[guideId] = {}
	end

	if not bt then
		print_error("AddPatch bt is nil, guideId=", guideId, " counterId=", counterId)

		return
	end

	if not bt.Create then
		print_error("AddPatch bt.Create is nil, guideId=", guideId, " counterId=", counterId)

		return
	end

	self.patchBTCreatorDic[guideId][counterId] = bt

	print_notice("AddPatch success, guideId=", guideId, " counterId=", counterId)
end

M.RemovePatch = function(self, guideId, counterId)
	if self.patchBTCreatorDic[guideId] then
		if counterId then
			if self.patchBTCreatorDic[guideId][counterId] then
				self.patchBTCreatorDic[guideId][counterId] = nil

				print_notice("RemovePatch success, guideId=", guideId, " counterId=", counterId)
			else
				print_warn("RemovePatch fail, not found patch, guideId=", guideId, " counterId=", counterId)
			end
		else
			self.patchBTCreatorDic[guideId] = nil

			print_notice("RemovePatch allCounter success, guideId=", guideId)
		end
	else
		print_warn("RemovePatch fail, not found patch, guideId=", guideId)
	end
end

M.PreLoadGuide = function(self, guideId)
	if self.preLoadResourcesDic[guideId] then
		return
	end

	print_notice("[NewGuideMgr]预载引导资源, guideId=" .. guideId)

	local counterId = 1
	local btCreator = nil
	local patch = self.patchBTCreatorDic[guideId] and self.patchBTCreatorDic[guideId][counterId]

	if patch then
		btCreator = patch

		print_notice("PreLoadGuide use patch, guideId=", guideId, " counterId=", counterId)
	else
		local path = "LuaGen/GuideFlow/GuideBT/GuideBT_" .. guideId .. "_" .. counterId
		local ok, res = xpcall(dofile, tolua.traceback, path)

		if not ok then
			print_error("@huangzhecong: [NewGuide]: PreLoadGuide, 引导lua文件不存在", guideId, counterId, res)

			return
		end

		btCreator = res
	end

	local bt = btCreator.Create()
	bt.guideId = guideId
	bt.counterId = counterId
	local preLoadData = self:_InternalPreLoadGuide(bt)

	if preLoadData then
		self.preLoadResourcesDic[guideId] = preLoadData
	end
end

M.UnPreLoadGuide = function(self, guideId)
	local preLoadData = self.preLoadResourcesDic[guideId]

	if preLoadData then
		print_notice("[NewGuideMgr]释放预载资源, guideId=" .. guideId)

		local loadOps = preLoadData.loadOps or preLoadData
		local panelIds = preLoadData.panelIds

		if loadOps then
			for _, loadOp in pairs(loadOps) do
				if loadOp then
					gResourceManager:UnloadAssetLoadOp(loadOp)
				end
			end
		end

		if panelIds then
			for _, panelId in pairs(panelIds) do
				if panelId then
					local refCount = self:DecGuidePanelPreLoadRef(panelId)

					if refCount <= 0 then
						print_notice("[NewGuideMgr]界面仍有预载引用，跳过释放, panelId=" .. panelId .. ", refCount=" .. refCount)
					elseif gPanelManager:IsPanelShowing(panelId) then
						print_notice("[NewGuideMgr]界面仍在显示，等待关闭时释放, panelId=" .. panelId)
					else
						gPanelManager:Destroy(panelId)
					end
				end
			end
		end

		self.preLoadResourcesDic[guideId] = nil
	end
end

M._InternalPreLoadGuide = function(self, bt)
	if not bt.allResNode then
		print_warn("需要预加载的引导是老版本，请重新导出，guideId=", bt.guideId)

		return nil
	end

	local textList = {}
	local imageSet = {}
	local opList = {}
	local panelIds = {}

	for name, node in pairs(bt.allResNode) do
		if node.GetClassType() ~= C_GuideBT_GuideText then
			self:PreLoadGuideTextById(node.textId, textList, imageSet)
			self:PreLoadGuideTextById(node.controllerId, textList, imageSet)
			self:PreLoadGuideTextById(node.dualSenseId, textList, imageSet)
			self:PreLoadGuideTextById(node.mobileId, textList, imageSet)
		end
	end

	local combineStr = table.concat(textList)

	print_notice("[NewGuideMgr]预载字符" .. combineStr)
	SGUI.SDF.SDFAsyncFontAssetManager.CacheCharactersAddRefByFontName("MiSans-Medium_SDF", combineStr)

	for image, _ in pairs(imageSet) do
		local isSuccess, data = SGUI.UIConfig.instance:TryGetIconData(image, nil)

		if isSuccess then
			if not data or not data.url or data.url ~= "" then
				print_error("[NewGuideMgr]预载富文本图标时获取路径失败,data=", image)
			else
				local loadOp = gCS.LuaUtils.LoadSpriteAssetWithCallBack(data.url, function ()
					print_notice("[NewGuideMgr]预载富文本图标Sprite完成" .. data.url)
				end, LX6.Engine.ResourceManager.LOAD_PRIORITY.PRIORITY_LEVEL4)

				table.insert(opList, loadOp)
				print_notice("[NewGuideMgr]开始预载富文本图标Sprite" .. data.url)
			end
		else
			print_error("[NewGuideMgr]@huangzhecong 预载富文本图标时获取数据失败，检查是否漏导出,iconName=", image)
		end
	end

	panelIds = self:CollectGuidePanelIds(bt)

	for _, panelId in pairs(panelIds) do
		if panelId then
			self:IncGuidePanelPreLoadRef(panelId)
		end
	end

	return {
		loadOps = opList,
		panelIds = panelIds
	}
end

M.CollectGuidePanelIds = function(self, bt)
	local panelIds = {}
	local panelIdSet = {}

	if not bt.allPanelNode then
		print_warn("需要预加载UI的引导是老版本，请重新导出，guideId=", bt.guideId)

		return panelIds
	end

	for _, node in pairs(bt.allPanelNode) do
		if node and node.GetPreLoadPanelIds then
			local ids = node:GetPreLoadPanelIds()

			if type(ids) ~= "table" then
				for _, panelId in pairs(ids) do
					if panelId then
						panelIdSet[panelId] = true
					end
				end
			elseif type(ids) ~= "number" then
				panelIdSet[ids] = true
			end
		end
	end

	for panelId, _ in pairs(panelIdSet) do
		table.insert(panelIds, panelId)
	end

	return panelIds
end

M.IncGuidePanelPreLoadRef = function(self, panelId)
	local refCount = (self.panelPreLoadRefCount[panelId] or 0) + 1
	self.panelPreLoadRefCount[panelId] = refCount

	if refCount ~= 1 then
		print_notice("[NewGuideMgr]预载界面, panelId=" .. panelId)
		gPanelManager:Preload(panelId)
	else
		print_notice("[NewGuideMgr]增加界面预载引用, panelId=" .. panelId .. ", refCount=" .. refCount)
	end

	return refCount
end

M.DecGuidePanelPreLoadRef = function(self, panelId)
	local refCount = self.panelPreLoadRefCount[panelId]

	if not refCount or refCount < 0 then
		print_warn("[NewGuideMgr]减少界面预载引用失败，未找到引用, panelId=" .. tostring(panelId))

		self.panelPreLoadRefCount[panelId] = nil

		return 0
	end

	refCount = refCount - 1

	if refCount < 0 then
		self.panelPreLoadRefCount[panelId] = nil

		print_notice("[NewGuideMgr]界面预载引用归零, panelId=" .. panelId)

		return 0
	end

	self.panelPreLoadRefCount[panelId] = refCount

	print_notice("[NewGuideMgr]减少界面预载引用, panelId=" .. panelId .. ", refCount=" .. refCount)

	return refCount
end

M.GetGuidePanelPreLoadRefCount = function(self, panelId)
	return self.panelPreLoadRefCount[panelId] or 0
end

M.ShouldDestroyGuidePanel = function(self, panelId)
	return self:GetGuidePanelPreLoadRefCount(panelId) > 0
end

M.TryCleanupGuidePanels = function(self, panelIds)
	if not panelIds then
		return
	end

	for _, panelId in pairs(panelIds) do
		if panelId then
			if self:ShouldDestroyGuidePanel(panelId) then
				print_notice("[NewGuideMgr]回收引导界面, panelId=" .. panelId)
				gPanelManager:Destroy(panelId)
			elseif gPanelManager:IsPanelShowing(panelId) then
				print_notice("[NewGuideMgr]界面仍被其他预载持有，仅关闭显示, panelId=" .. panelId)
				gPanelManager:Close(panelId)
			else
				print_notice("[NewGuideMgr]界面仍被其他预载持有，保留预载, panelId=" .. panelId)
			end
		end
	end
end

M.PreLoadGuideTextById = function(self, id, textList, imageSet)
	if not id or id ~= 0 then
		return
	end

	local str = self:GetGuideTextById(id)

	if not string.is_null_or_empty(str) then
		gGuideGlyph:CollectPreloadImages(str, imageSet)
		table.insert(textList, gGuideGlyph:ExtractPlainText(str))
	end
end

M.GetGuideTextById = function(self, id)
	local cfg = GuideTextConfig.GetConfig(id)

	if not cfg then
		print_error("GetGuideTextById cfg为空,id=", id, "请引导相关策划检查GuideText配表")

		return ""
	end

	return cfg.Text
end

M.IsRunnable = function(self)
	local runnable = gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene and not gPanelManager:IsPanelShowing(gPanelId.PVP_LOADING_PANEL) and not LX6.Scene.SwitchSceneManager.AfterSwitchShow_CheckShowPlaying()

	if gCS.LuaUtils.IsOnEditor and not gLuaDataManager.isNetworkAvailable then
		runnable = false
	end

	return runnable
end

M.ActiveGuideAndNotify = function(self, guideId, counter, taskId)
	if not self:IsRunnable() then
		return
	end

	if taskId and taskId <= 0 then
		gClientToGameDelegate:AskStartGuideByClient(guideId, taskId).Callback = function (err)
			if err == MessageConfig.Ok then
				print_debug("[NewGuideMgr]:AskStartGuideByClient 请求失败, GuideId=", guideId, "taskId=", taskId, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)
			end
		end
	end

	self:ActiveGuide(guideId, counter)
end

M.AskStartGuideByClient = function(self, guideId)
	gClientToGameDelegate:AskStartGuideByClient(guideId).Callback = function (err)
		if err == MessageConfig.Ok then
			print_debug("[NewGuideMgr]:AskStartGuideByClient 请求失败, GuideId=", guideId, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)
		end
	end
end

M.ActiveGuide = function(self, guideId, counterId)
	if self.gmEnableGuide ~= false then
		return
	end

	gNewGuideMgr:StopGuide()

	local cfg = GuideConfig.GetConfig(guideId)

	if cfg then
		if counterId < cfg.GroupNum then
			if gNewGuideMgr:HasGuide(guideId) then
				if self:IsRunnable() then
					self:_InternalActiveGuide(guideId, counterId)
				else
					self.delayedActiveGuideData = {
						guideId = guideId,
						counter = counterId
					}
				end

				self:RefreshDynamicUpdate()
			else
				print_error("[NewGuideMgr]:没有找到引导（引导文件不存在或只有旧引导）, guideId=" .. guideId)
			end
		else
			print_error("[NewGuideMgr]:激活引导失败,引导GroupNum < counter,请检查配置: guideId=", guideId, "GroupNum=", cfg.GroupNum, "counterId=", counterId, Time.time, Time.frameCount)
		end
	else
		print_error("[NewGuideMgr]:激活引导失败,引导Id在表里不存在,请检查配表: guideId=", guideId, Time.time, Time.frameCount)
	end
end

M._InternalActiveGuide = function(self, guideId, counterId)
	self.delayedActiveGuideData = nil

	if self.enableDebug then
		print_notice("[NewGuideMgr]:尝试激活引导, guideId=", guideId, "counterId=", counterId, Time.time, Time.frameCount)
	end

	local btCreator = nil
	local patch = self.patchBTCreatorDic[guideId] and self.patchBTCreatorDic[guideId][counterId]

	if patch then
		btCreator = patch

		print_notice("ActiveGuide use patch, guideId=", guideId, " counterId=", counterId)
	else
		local path = GuideBTPath .. "GuideBT_" .. guideId .. "_" .. counterId
		local ok, res = xpcall(dofile, tolua.traceback, path)

		if not ok then
			print_error("@huangzhecong: [NewGuideMgr]:尝试激活引导, 引导lua文件不存在", guideId, counterId, res)

			return
		end

		btCreator = res
	end

	local bt = btCreator.Create()
	bt.guideId = guideId
	bt.counterId = counterId

	if not self.preLoadResourcesDic[guideId] then
		print_notice("[NewGuideMgr]ActiveGuide预载引导资源, guideId=" .. guideId)

		local preLoadData = self:_InternalPreLoadGuide(bt)

		if preLoadData then
			self.preLoadResourcesDic[guideId] = preLoadData
		end
	end

	self.activeGuideBT = bt

	if self.enableDebug and self.activeGuideBT and self.activeGuideBT.MarkCounterDirty then
		self.activeGuideBT:MarkCounterDirty()
	end

	self:OnUpdate()
end

M.StopGuide = function(self, isFinished)
	if self.activeGuideBT then
		local guideId = self.activeGuideBT.guideId
		local counterId = self.activeGuideBT.counterId
		local gmCleanupPanelIds = self.activeGuideBT._gmCleanupPanelIds

		self.activeGuideBT:Exit()

		self.activeGuideBT = nil

		if self.enableDebug then
			self:UpdateDebugInfo({
				i6rK = true
			})
		end

		if guideId then
			print_debug("[NewGuideMgr]:停止引导", guideId, counterId)
			self:UnPreLoadGuide(guideId)
			gMessageManager:SendMessage(gEventConstants.GUIDE_FLOW_FINISH, {
				guideId = guideId,
				counterId = counterId,
				isFinished = isFinished
			})

			if isFinished then
				self:TryRequestNextGuideCounter(guideId, counterId)
			end
		end

		if gmCleanupPanelIds then
			self:TryCleanupGuidePanels(gmCleanupPanelIds)
		end
	end

	self:RefreshDynamicUpdate()
end

M.TryRequestNextGuideCounter = function(self, guideId, counter)
	local cfg = GuideConfig.GetConfig(guideId)

	if not cfg then
		return
	end

	if counter >= cfg.GroupNum then
		if not self.ClientDebug then
			print_notice("[NewGuideMgr]:AskDoGuide 请求触发下一个引导, GuideId=", guideId, " CounterId=", counter + 1, Time.time, Time.frameCount)

			gClientToGameDelegate:AskDoGuide(guideId, counter + 1).Callback = function (err)
				print_notice("[NewGuideMgr]:AskDoGuide CallBack, GuideId=", guideId, " CounterId=", counter + 1, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)

				if err ~= LTConfig.MessageConfig.Ok then
					self:ActiveGuide(guideId, counter + 1)
				end
			end
		end
	elseif cfg.GroupNum ~= counter and not self.ClientDebug then
		print_notice("[NewGuideMgr]:AskFinishGuide 请求结束引导, GuideId=", guideId, Time.time, Time.frameCount)

		gClientToGameDelegate:AskFinishGuide(guideId, true).Callback = function (err)
			print_notice("[NewGuideMgr]:AskFinishGuide CallBack, GuideId=", guideId, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)
		end
	end
end

M.RefreshDynamicUpdate = function(self)
	if self.delayedActiveGuideData or self.activeGuideBT or self.pendingDeviceCheckNoMessage == nil or self.pendingDeviceNotify then
		gLuaClient:RegisterDynamicUpdate("gNewGuideMgr", self)
	else
		gLuaClient:UnregisterDynamicUpdate("gNewGuideMgr")
	end
end

M.OnControlSchemeChange = function(self)
end

M.OnLanguageChange = function(self)
end

M.EnableDebug = function(self, enable)
	self.enableDebug = enable

	if enable and self.activeGuideBT and self.activeGuideBT.MarkCounterDirty then
		self.activeGuideBT:MarkCounterDirty()
	end
end

M.UpdateDebugInfo = function(self, debugInfo)
	if debugInfo == nil then
		gMessageManager:SendMessage(gEventConstants.ON_GF_DEBUG_INFO_CHANGE, debugInfo)
	end
end

M.GetDebugInfo = function(self)
	return self.debugInfo
end

M.GetCurrentGuideStatus = function(self)
	if self.activeGuideBT then
		local gid = self.activeGuideBT.guideId
		local cid = self.activeGuideBT.counterId

		return "Active," .. (gid == nil and tostring(gid) or "noId") .. "," .. (cid == nil and tostring(cid) or "noCounter")
	else
		return "NoActive"
	end
end

M.IsGuideTriggerPanel = function(self, panelId)
	if not panelId or panelId ~= 0 then
		return false
	end

	for _, id in pairs(LTConfig.GuideConfig.AlphaTestPanel) do
		if id ~= panelId then
			return true
		end
	end

	return false
end

dofile("LX6/Guide/NewGuideMgr_GM")
dofile("LX6/Guide/NewGuideMgr_RPC")
dofile("LX6/Guide/NewGuideMgr_SGUI")
dofile("LX6/Guide/NewGuideMgr_VehicleCollider")
dofile("LX6/Guide/NewGuideMgr_Signal")

gNewGuideMgr = gNewGuideMgr or C_NewGuideMgr.new()
