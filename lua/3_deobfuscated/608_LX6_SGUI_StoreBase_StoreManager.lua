C_StoreManager = DefClass("C_StoreManager", C_StoreManager)
local StoreManager = C_StoreManager
local StoreIndex = 0

function StoreManager:ctor()
	self.m_StoreName2Group = {}
	self.m_ActiveStoreProxyMap = {}
	self.m_UpdatedStoreMap = {}
	self.m_UpdatedStoreBackMap = {}
	self.m_ActiveGroupMap = {}
	self.m_ForceUpdateGroupMap = {}
	self.m_UpdateGroupMap = {}
	self.m_LateUpdateGroupMap = {}
	self.m_CameraUpdateGroupMap = {}
	self.m_DynamicOnUpdateGroupMap = {}
	self.m_DynamicOnLateUpdateGroupMap = {}
	self.m_DynamicOnCameraUpdateGroupMap = {}
	self.Debug = false
	self.m_EditorStoreDict = {}
	self.m_EnableAutoPatch = true
	self.m_PatchFrameDict = {}
	self.StoreMode = {
		Storage = 0,
		Parallel = 2,
		Root = 1
	}
	self.LoadMode = {
		ASYNC = 2,
		DEFAULT = 0,
		SYNC = 1
	}
	self.DEBUG_UI_INPUT = false
end

function StoreManager:OnInit()
	for storeName, _ in pairs(GroupName2Class) do
		self:GetOrAddStoreGroup(storeName)
	end

	function SGUI.UWidget.onBindingWidget(widget)
		self:RegisterDataBinding(widget)
	end

	function SGUI.UWidget.onBindingWidgetEnable(widget)
		self:OnWidgetStoreEnable(widget)
	end

	function SGUI.UWidget.onBindingWidgetShow(widget)
		self:OnWidgetStoreShow(widget)
	end

	function SGUI.UWidget.onBindingWidgetDisable(widget)
		self:OnWidgetStoreDisable(widget)
	end

	function SGUI.UWidget.onBindingHotfix(widget)
		self:OnWidgetHotfix(widget)
	end

	function SGUI.UWidget.onUnBindingWidget(widget)
		self:UnRegisterDataBinding(widget)
	end

	function SGUI.UWidget.onBindingCustomDataChange(widget)
		self:OnWidgetCustomDataChange(widget)
	end

	gMessageManager:AddMessageListener(gEventConstants.PANEL_SHOW, self:CreateAction("OnPanelShow"))
	gMessageManager:AddMessageListener(gEventConstants.PANEL_CLOSE, self:CreateAction("OnPanelClose"))
	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, self:CreateAction("OnLanguageChange"))
	gMessageManager:AddMessageListener(gEventConstants.ON_ACTIVE_DEVICE_CHANGED, self:CreateAction("OnActiveDeviceChange"))
	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_PRELOADED, self:CreateAction("OnPanelPreloaded"))
end

function StoreManager:OnApplicationQuit()
	SGUI.UWidget.onBindingWidget = nil
	SGUI.UWidget.onBindingWidgetEnable = nil
	SGUI.UWidget.onBindingWidgetShow = nil
	SGUI.UWidget.onBindingWidgetDisable = nil
	SGUI.UWidget.onBindingHotfix = nil
	SGUI.UWidget.onUnBindingWidget = nil
	SGUI.UWidget.onBindingCustomDataChange = nil
end

function StoreManager:GetOrAddStoreGroup(storeName, storeNameForBinding, isSub)
	local key = storeNameForBinding or storeName
	local storeGroup = self.m_StoreName2Group[key]

	if not storeGroup then
		if GroupName2Class[storeName] then
			storeGroup = GroupName2Class[storeName].new(key, GroupName2Id[string.trim_end(storeName, "_PC")], isSub)
		else
			storeGroup = C_StoreGroup.new(key, GroupName2Id[string.trim_end(storeName, "_PC")], isSub)
		end

		self.m_StoreName2Group[key] = storeGroup

		if storeGroup.DEFINE_ForceUpdate and storeGroup.OnUpdateForce then
			self.m_ForceUpdateGroupMap[key] = storeGroup
		end

		if self.Debug then
			print_notice("StoreManager => Add New StoreGroup ", key, UnityEngine.Time.frameCount)
		end
	end

	return storeGroup
end

function StoreManager:GetStoreGroup(name)
	return self.m_StoreName2Group[name]
end

function StoreManager:RemoveStoreGroup(name)
	self.m_StoreName2Group[name] = nil
	self.m_ForceUpdateGroupMap[name] = nil

	if self.Debug then
		print_notice("StoreManager => Remove StoreGroup ", name, UnityEngine.Time.frameCount)
	end
end

StoreManager_CommonMT = {
	__newindex = function (t, key, value)
		local store = t.m_Store
		local lastValue = store.bindData[key]
		local bChanged = value ~= lastValue

		if not bChanged then
			return
		end

		store.bindData[key] = value

		if store.m_ImmediatelyCommit then
			local map = store.m_FieldMap[key] or STORE_EMPTY_TABLE

			if #map > 0 then
				for i, v in ipairs(map) do
					store:__ApplyBindingData(v)
				end

				return
			end
		end

		store:__AddToUpdateMap(key)
	end,
	__index = function (t, key)
		return t.m_Store[key] or t.m_Store.bindData[key]
	end
}

function StoreManager:NewStoreProxy(name)
	StoreIndex = StoreIndex + 1
	local store = C_Store.new(name, StoreIndex)
	local storeProxy = {
		m_Store = store
	}

	setmetatable(storeProxy, StoreManager_CommonMT)

	return storeProxy
end

function StoreManager:GetOrAddStoreProxy(widget, name)
	local count, storeName, subStoreName, subStoreKey = self:ParseStoreName(name)

	if count == 1 then
		local storeGroup = self:GetOrAddStoreGroup(storeName)
		local id = widget.gameObject:GetInstanceID()
		local proxy = storeGroup:GetStoreById(id)

		if not proxy then
			proxy = widget.storeMode == self.StoreMode.Root and storeGroup.bindData or self:NewStoreProxy(storeName)

			proxy:EnableImmediatelyCommit(widget.EnableImmediatelyCommit)
			proxy:BindWidget(widget)
			storeGroup:AddStoreProxy(id, proxy)
		end

		if gGameManager.Env.isEditor then
			self.m_EditorStoreDict[id] = proxy
		end

		return proxy, storeGroup
	elseif count == 2 then
		local subStoreGroup = self:GetStoreGroup(name)

		if not subStoreGroup then
			local storeGroup = self:GetOrAddStoreGroup(storeName)
			subStoreGroup = self:GetOrAddStoreGroup(subStoreName, name, true)

			storeGroup:RegisterSubGroup(subStoreKey, subStoreGroup)
		end

		local id = widget.gameObject:GetInstanceID()
		local proxy = subStoreGroup:GetStoreById(id)

		if not proxy then
			proxy = widget.storeMode == self.StoreMode.Root and subStoreGroup.bindData or self:NewStoreProxy(subStoreName)

			proxy:EnableImmediatelyCommit(widget.EnableImmediatelyCommit)
			proxy:BindWidget(widget)
			subStoreGroup:AddStoreProxy(id, proxy)
		end

		if gGameManager.Env.isEditor then
			self.m_EditorStoreDict[id] = proxy
		end

		return proxy, subStoreGroup
	end
end

function StoreManager:TryGetStoreProxy(widget, name)
	local storeGroup = self:GetStoreGroup(name)

	if not storeGroup then
		return false
	end

	local proxy = storeGroup:GetStoreByWidget(widget)

	if not proxy then
		return false
	end

	return true, proxy, storeGroup
end

function StoreManager:RemoveStoreProxy(widget, name)
	local storeGroup = self:GetOrAddStoreGroup(name)
	local id = widget.gameObject:GetInstanceID()
	local proxy = storeGroup:GetStoreById(id)

	if gGameManager.Env.isEditor then
		self.m_EditorStoreDict[id] = nil
	end

	if not proxy then
		return
	end

	storeGroup:RemoveStoreProxy(id, proxy)

	return proxy
end

function StoreManager:RegisterDataBinding(widget)
	local dataList = widget.bindingDataList
	local widgetList = widget.bindingWidgetList
	local componentList = widget.bindingComponentList
	local storeMode = widget.storeMode

	if (not dataList or dataList.Length == 0) and (not widgetList or widgetList.Length == 0) and (not componentList or componentList.Length == 0) and storeMode == self.StoreMode.Storage then
		return
	end

	local store = widget.Store

	if storeMode == self.StoreMode.Root then
		self:UnRegisterCurrent(store)
	end

	local storeProxy, storeGroup = self:GetOrAddStoreProxy(widget, store)

	if widgetList then
		for i = 0, widgetList.Length - 1 do
			local wgt = widgetList[i].widget
			local field = widgetList[i].field

			storeProxy:__RegisterToWidgetMap(field, wgt)
		end
	end

	if componentList then
		for i = 0, componentList.Length - 1 do
			local comp = componentList[i].component
			local field = componentList[i].field

			storeProxy:__RegisterToWidgetMap(field, comp)
		end
	end

	if dataList then
		for i = 0, dataList.Length - 1 do
			local data = dataList[i]
			local field = dataList[i].field

			storeProxy:__RegisterToMap(data, field)
		end
	end

	if storeMode == self.StoreMode.Root then
		storeGroup:BindRoot(widget)
		storeGroup:OnBeforeAwake()
		storeGroup:OnAwake()
	elseif storeMode == self.StoreMode.Parallel then
		storeGroup:OnAwake(widget)

		if storeGroup.storeCount == 1 then
			storeGroup:OnBeforeAwake()
		end
	end
end

function StoreManager:UnRegisterDataBinding(widget)
	local dataList = widget.bindingDataList
	local widgetList = widget.bindingWidgetList
	local componentList = widget.bindingComponentList
	local storeMode = widget.storeMode

	if (not dataList or dataList.Length == 0) and (not widgetList or widgetList.Length == 0) and (not componentList or componentList.Length == 0) and storeMode == self.StoreMode.Storage then
		return
	end

	local store = widget.Store
	local valid, storeProxy, storeGroup = self:TryGetStoreProxy(widget, store)

	if not valid then
		print_warn("找不到store的数据 ", store, "widgetName=", widget.name)

		return
	end

	if storeMode == self.StoreMode.Root and storeGroup.rootId ~= widget.gameObject:GetInstanceID() then
		if self.Debug then
			print_notice("StoreManager => 要移除得Root当前不是自己 ", store, "rootWidget=", storeGroup.rootWidget, storeGroup.rootId, "removeWidget=", widget, widget.gameObject:GetInstanceID())
		end

		return
	end

	if storeMode == self.StoreMode.Root then
		if storeGroup.STATE_EnableOnce then
			storeGroup.STATE_EnableOnce = false

			storeGroup:OnGroupDisable()
		end

		storeGroup:OnDestroy()
		storeGroup:UnBindRoot(widget)
		storeGroup:ResetPanelData()
	elseif storeMode == self.StoreMode.Parallel then
		storeGroup:OnDestroy(widget)
	end

	storeGroup:RemoveStoreProxy(widget.gameObject:GetInstanceID(), storeProxy)
	storeProxy:Clear()

	if storeMode == self.StoreMode.Root then
		self:RemoveFromActiveStoreGroup(storeGroup)
		self:RemoveDynamicRegister(storeGroup)
		storeGroup:OnAfterDestroy()
	elseif storeMode == self.StoreMode.Parallel and storeGroup.storeCount == 0 then
		self:RemoveFromActiveStoreGroup(storeGroup)
		self:RemoveDynamicRegister(storeGroup)
		storeGroup:OnAfterDestroy()
	end
end

function StoreManager:UnRegisterCurrent(store)
	local group = self:GetStoreGroup(store)

	if not group or not group.rooted then
		return
	end

	if self.Debug then
		print_notice("StoreManager => UnRegisterCurrent ", store, " RegisterBindingData重复，先移除已有数据去重 ", "rootWidget=", group.rootWidget, group.rootId)
	end

	local status, err = xpcall(self.UnRegisterDataBinding, tolua.traceback, self, group.rootWidget)

	if not status then
		print_error(status, "StoreManager.UnRegisterCurrent.UnRegisterDataBinding Failed,一般是同一帧先close再checkshow了", store, "\n", err)
	end
end

function StoreManager:OnWidgetStoreEnable(widget)
	local storeGroup = self:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	local storeProxy = storeGroup:GetStoreByWidget(widget)

	self:AddToActiveStoreMap(storeProxy)

	local storeMode = widget.storeMode

	if storeMode == self.StoreMode.Root then
		if not storeGroup.STATE_EnableOnce then
			storeGroup.STATE_EnableOnce = true

			storeGroup:OnGroupEnable()
		else
			self:AddToActiveStoreGroup(storeGroup)
		end

		storeGroup:OnEnable()
	elseif storeMode == self.StoreMode.Parallel then
		storeGroup:OnEnable(widget)
	end

	storeProxy.m_Store:__Update()
end

function StoreManager:OnWidgetStoreDisable(widget)
	local storeGroup = self:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	local storeProxy = storeGroup:GetStoreByWidget(widget)

	self:RemoveFromActiveStoreMap(storeProxy)

	local storeMode = widget.storeMode

	if storeMode == self.StoreMode.Root then
		self:RemoveFromActiveStoreGroup(storeGroup)
		storeGroup:OnDisable()
	elseif storeMode == self.StoreMode.Parallel then
		storeGroup:OnDisable(widget)
	end
end

function StoreManager:OnWidgetHotfix(widget)
	if not self.m_EnableAutoPatch then
		return
	end

	local store = widget.Store

	if self.m_PatchFrameDict[store] == gLogicTime.frameCount then
		return
	end

	self.m_PatchFrameDict[store] = gLogicTime.frameCount

	if string.find(store, "%.") or store == "" then
		return
	end

	for name, _ in pairs(GroupName2Class) do
		if string.find(name, store) then
			local storeName = name:match("[^" .. "%." .. "]+$")
			local realName = storeName:match("^(.-)_")

			if realName then
				self:ReloadLuaFile(realName)
			else
				self:ReloadLuaFile(storeName)
			end
		end
	end
end

function StoreManager:OnWidgetStoreShow(widget)
	local storeGroup = self:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("StoreManager.OnWidgetStoreShow." .. widget.Store)
	end

	local storeMode = widget.storeMode

	if storeMode == self.StoreMode.Root then
		storeGroup.STATE_Started = true

		storeGroup:OnStart()

		if storeGroup.STATE_WaitOnShow then
			if gGameManager.Env.IsENABLE_PROFILER then
				gCS.LuaUtils.BeginSample("StoreManager.OnShow." .. widget.Store)
			end

			storeGroup.STATE_WaitOnShow = false

			storeGroup:OnShow(storeGroup.STATE_ShowData.panelId, storeGroup.STATE_ShowData.data, storeGroup.STATE_ShowData.store)

			storeGroup.STATE_OnShowOnce = true
			storeGroup.STATE_ShowData = nil

			if gGameManager.Env.IsENABLE_PROFILER then
				gCS.LuaUtils.EndSample()
			end
		end

		self:AddToActiveStoreGroup(storeGroup)
		self:PushBindingData()
	elseif storeMode == self.StoreMode.Parallel then
		storeGroup:OnStart(widget)
		self:AddToActiveStoreGroup(storeGroup)

		local storeProxy = storeGroup:GetStoreByWidget(widget)

		storeProxy.m_Store:__Update()
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function StoreManager:OnWidgetCustomDataChange(widget)
	local storeGroup = self:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	storeGroup:OnCustomBindDataChange(widget)
end

function StoreManager:AddToActiveStoreMap(storeProxy)
	if storeProxy.m_Store.bActive then
		return
	end

	if self.Debug then
		print_notice("StoreManager => AddToActiveStoreMap ", storeProxy.m_Name, storeProxy.m_Id, UnityEngine.Time.frameCount)
	end

	storeProxy.m_Store.bActive = true
	self.m_ActiveStoreProxyMap[storeProxy.m_Id] = storeProxy

	if storeProxy.m_Store:IsDirty() then
		self.m_UpdatedStoreMap[storeProxy.m_Store.m_Id] = storeProxy.m_Store
	end
end

function StoreManager:AddToUpdatedStoreMap(store)
	if self.m_ActiveStoreProxyMap[store.m_Id] then
		self.m_UpdatedStoreMap[store.m_Id] = store
	end
end

function StoreManager:RemoveFromActiveStoreMap(storeProxy)
	if not storeProxy.m_Store.bActive then
		return
	end

	if self.Debug then
		print_notice("StoreManager => RemoveFromActiveStoreMap ", storeProxy.m_Name, storeProxy.m_Id, UnityEngine.Time.frameCount)
	end

	storeProxy.m_Store.bActive = false
	self.m_ActiveStoreProxyMap[storeProxy.m_Id] = nil
	self.m_UpdatedStoreMap[storeProxy.m_Store.m_Id] = nil
end

function StoreManager:ParseStoreName(source)
	local index = string.find(source, "%.")

	if index == nil then
		return 1, source
	end

	local index1 = string.find(source, "%_")

	if index1 == nil then
		return 2, string.sub(source, 0, index - 1), string.sub(source, index + 1), string.sub(source, index + 1)
	end

	return 2, string.sub(source, 0, index - 1), string.sub(source, index + 1, index1 - 1), string.sub(source, index + 1)
end

function StoreManager:AddToActiveStoreGroup(storeGroup)
	if storeGroup.bActive then
		return
	end

	storeGroup.bActive = true

	if self.Debug then
		print_notice("StoreManager => AddToActiveStoreGroup ", storeGroup.m_Name, UnityEngine.Time.frameCount)
	end

	self.m_ActiveGroupMap[storeGroup.m_Name] = storeGroup

	if storeGroup.OnUpdate and (not storeGroup.DEFINE_DynamicOnUpdate or self.m_DynamicOnUpdateGroupMap[storeGroup.m_Name]) then
		self.m_UpdateGroupMap[storeGroup.m_Name] = storeGroup
	end

	if storeGroup.OnLateUpdate and (not storeGroup.DEFINE_DynamicOnLateUpdate or self.m_DynamicOnLateUpdateGroupMap[storeGroup.m_Name]) then
		self.m_LateUpdateGroupMap[storeGroup.m_Name] = storeGroup
	end

	if storeGroup.OnCameraUpdate and (not storeGroup.DEFINE_DynamicOnCameraUpdate or self.m_DynamicOnCameraUpdateGroupMap[storeGroup.m_Name]) then
		self.m_CameraUpdateGroupMap[storeGroup.m_Name] = storeGroup
	end
end

function StoreManager:RemoveFromActiveStoreGroup(storeGroup)
	if not storeGroup.bActive then
		return
	end

	storeGroup.bActive = false

	if self.Debug then
		print_notice("StoreManager => RemoveFromActiveStoreGroup ", storeGroup.m_Name, UnityEngine.Time.frameCount)
	end

	self.m_ActiveGroupMap[storeGroup.m_Name] = nil
	self.m_UpdateGroupMap[storeGroup.m_Name] = nil
	self.m_LateUpdateGroupMap[storeGroup.m_Name] = nil
	self.m_CameraUpdateGroupMap[storeGroup.m_Name] = nil
end

function StoreManager:OnPanelShow(eventId, msg)
	local storeName = msg.store

	if string.is_null_or_empty(storeName) then
		print_debug("OnPanelShow,界面prefab根节点取不到对应的store。panelId=", msg.panelId)

		return
	end

	local group = self:GetStoreGroup(storeName)

	if group then
		local data = nil

		if msg.panelId then
			data = gPanelManager:RemovePanelData(msg.panelId)
		end

		if group.STATE_Started then
			if gGameManager.Env.IsENABLE_PROFILER then
				gCS.LuaUtils.BeginSample("StoreManager.OnShow." .. storeName)
			end

			group:OnShow(msg.panelId, data, storeName)

			group.STATE_OnShowOnce = true

			self:AddToActiveStoreGroup(group)

			group.STATE_WaitOnShow = false
			group.STATE_ShowData = nil

			if gGameManager.Env.IsENABLE_PROFILER then
				gCS.LuaUtils.EndSample()
			end
		else
			group.STATE_WaitOnShow = true
			group.STATE_ShowData = {
				panelId = msg.panelId,
				data = data,
				store = storeName
			}
		end
	end
end

function StoreManager:OnPanelClose(eventId, msg)
	local storeName = msg.store

	if string.is_null_or_empty(storeName) then
		print_debug("OnPanelClose,界面prefab根节点取不到对应的store。panelId=", msg.panelId)

		return
	end

	local group = self:GetStoreGroup(storeName)

	if group then
		self:RemoveFromActiveStoreGroup(group)

		if group.STATE_OnShowOnce then
			group:OnClose(msg)

			group.STATE_OnShowOnce = false
		end

		group.STATE_ShowData = nil
		group.STATE_WaitOnShow = false

		self:PushBindingData()
	end
end

function StoreManager:OnPanelPreloaded(eventId, storeName)
	if string.is_null_or_empty(storeName) then
		print_debug("OnPanelPreloaded,界面prefab根节点取不到对应的store。")

		return
	end

	local group = self:GetStoreGroup(storeName)

	if group and group.OnPreload then
		group:OnPreload()
	end
end

function StoreManager:OnUpdate()
	for k, v in pairs(self.m_ForceUpdateGroupMap) do
		v:OnUpdateForce()
	end

	for k, v in pairs(self.m_UpdateGroupMap) do
		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.BeginSample(k)
		end

		v:OnUpdate()

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.EndSample()
		end
	end
end

function StoreManager:OnCameraUpdate()
	for k, v in pairs(self.m_CameraUpdateGroupMap) do
		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.BeginSample(k)
		end

		local status, err = xpcall(v.OnCameraUpdate, tolua.traceback, v)

		if not status then
			print_error(k, " OnCameraUpdate Error", err)
		end

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.EndSample()
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("gStoreManager PushBindingData")
	end

	self:PushBindingData()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function StoreManager:OnLateUpdate()
	for k, v in pairs(self.m_LateUpdateGroupMap) do
		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.BeginSample(k)
		end

		v:OnLateUpdate()

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.EndSample()
		end
	end
end

function StoreManager:PushBindingData()
	local temp = self.m_UpdatedStoreMap
	self.m_UpdatedStoreMap = self.m_UpdatedStoreBackMap

	for k, v in pairs(temp) do
		temp[k] = nil

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.BeginSample(v.group ~= nil and v.group.m_Name or "nil")
		end

		v:__Update()

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.EndSample()
		end
	end

	self.m_UpdatedStoreBackMap = temp
end

function StoreManager:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		for _, group in pairs(self.m_StoreName2Group) do
			group:OnGroupLogOut()
		end
	end
end

function StoreManager:OnLanguageChange(eventId, lang)
	for _, group in pairs(self.m_ActiveGroupMap) do
		group:OnLanguageChange(lang)
	end
end

function StoreManager:OnActiveDeviceChange(eventId, device)
	for _, group in pairs(self.m_ActiveGroupMap) do
		group:OnActiveDeviceChange(device)
	end
end

function StoreManager:GetRuntimeValue(id, field)
	if gGameManager.Env.isEditor then
		local proxy = self.m_EditorStoreDict[id]

		if proxy then
			return table.tostring(proxy[field])
		end
	end

	return nil
end

function StoreManager:InvokeStoreMethod(storeName, methodName, ...)
	local group = self:GetStoreGroup(storeName)

	if group then
		group[methodName](group, ...)
	end
end

function StoreManager:SetAutoPatch(enable)
	self.m_EnableAutoPatch = enable
end

function StoreManager:ReloadLuaFile(fileName)
	local fullPath = ""
	local tab1 = nil
	local cur = ""
	local len = string.len(fileName)

	for key, _ in pairs(package.preload) do
		cur = tostring(key)

		if string.find(cur, fileName) then
			local len1 = string.len(cur)
			local s = string.sub(cur, len1 - len, len1 - len)

			if s == "." then
				tab1 = package.preload[key]
				fullPath = cur

				break
			end
		end
	end

	for key, _ in pairs(package.loaded) do
		cur = tostring(key)

		if string.find(cur, fileName) then
			local len1 = string.len(cur)
			local s = string.sub(cur, len1 - len, len1 - len)

			if s == "." then
				tab1 = package.loaded[key]
				fullPath = cur

				break
			end
		end
	end

	if fullPath ~= "" and tab1 then
		local tab2 = dofile(fullPath)

		if tab2 then
			for k, v in pairs(tab2) do
				tab1[k] = v
			end
		end
	end
end

function StoreManager:RegisterDynamicOnUpdate(storeGroup)
	if self.Debug then
		print_error("DynamicOnUpdate =>  RegisterDynamicOnUpdate 1", storeGroup.m_Name)
	end

	if self.m_DynamicOnUpdateGroupMap[storeGroup.m_Name] or not storeGroup.OnUpdate or not storeGroup.DEFINE_DynamicOnUpdate then
		return
	end

	if self.Debug then
		print_error("DynamicOnUpdate =>  RegisterDynamicOnUpdate 2", storeGroup.m_Name)
	end

	self.m_DynamicOnUpdateGroupMap[storeGroup.m_Name] = true

	if self.m_ActiveGroupMap[storeGroup.m_Name] then
		self.m_UpdateGroupMap[storeGroup.m_Name] = storeGroup
	end
end

function StoreManager:UnregisterDynamicOnUpdate(storeGroup)
	if self.Debug then
		print_error("DynamicOnUpdate =>  UnregisterDynamicOnUpdate 1", storeGroup.m_Name)
	end

	if not self.m_DynamicOnUpdateGroupMap[storeGroup.m_Name] then
		return
	end

	if self.Debug then
		print_error("DynamicOnUpdate =>  UnregisterDynamicOnUpdate 2", storeGroup.m_Name)
	end

	self.m_DynamicOnUpdateGroupMap[storeGroup.m_Name] = nil
	self.m_UpdateGroupMap[storeGroup.m_Name] = nil
end

function StoreManager:RegisterDynamicOnLateUpdate(storeGroup)
	if self.Debug then
		print_error("DynamicOnUpdate =>  RegisterDynamicOnLateUpdate 1", storeGroup.m_Name)
	end

	if self.m_DynamicOnLateUpdateGroupMap[storeGroup.m_Name] or not storeGroup.OnLateUpdate or not storeGroup.DEFINE_DynamicOnLateUpdate then
		return
	end

	if self.Debug then
		print_error("DynamicOnUpdate =>  RegisterDynamicOnLateUpdate 2", storeGroup.m_Name)
	end

	self.m_DynamicOnLateUpdateGroupMap[storeGroup.m_Name] = true

	if self.m_ActiveGroupMap[storeGroup.m_Name] then
		self.m_LateUpdateGroupMap[storeGroup.m_Name] = storeGroup
	end
end

function StoreManager:UnregisterDynamicOnLateUpdate(storeGroup)
	if self.Debug then
		print_error("DynamicOnUpdate =>  UnregisterDynamicOnLateUpdate 1", storeGroup.m_Name)
	end

	if not self.m_DynamicOnLateUpdateGroupMap[storeGroup.m_Name] then
		return
	end

	if self.Debug then
		print_error("DynamicOnUpdate =>  UnregisterDynamicOnLateUpdate 2", storeGroup.m_Name)
	end

	self.m_DynamicOnLateUpdateGroupMap[storeGroup.m_Name] = nil
	self.m_LateUpdateGroupMap[storeGroup.m_Name] = nil
end

function StoreManager:RegisterDynamicOnCameraUpdate(storeGroup)
	if self.Debug then
		print_error("DynamicOnUpdate =>  RegisterDynamicOnCameraUpdate 1", storeGroup.m_Name)
	end

	if self.m_DynamicOnCameraUpdateGroupMap[storeGroup.m_Name] or not storeGroup.OnCameraUpdate or not storeGroup.DEFINE_DynamicOnCameraUpdate then
		return
	end

	if self.Debug then
		print_error("DynamicOnUpdate =>  RegisterDynamicOnCameraUpdate 2", storeGroup.m_Name)
	end

	self.m_DynamicOnCameraUpdateGroupMap[storeGroup.m_Name] = true

	if self.m_ActiveGroupMap[storeGroup.m_Name] then
		self.m_CameraUpdateGroupMap[storeGroup.m_Name] = storeGroup
	end
end

function StoreManager:UnregisterDynamicOnCameraUpdate(storeGroup)
	if self.Debug then
		print_error("DynamicOnUpdate =>  UnregisterDynamicOnCameraUpdate 1", storeGroup.m_Name)
	end

	if not self.m_DynamicOnCameraUpdateGroupMap[storeGroup.m_Name] then
		return
	end

	if self.Debug then
		print_error("DynamicOnUpdate =>  UnregisterDynamicOnCameraUpdate 2", storeGroup.m_Name)
	end

	self.m_DynamicOnCameraUpdateGroupMap[storeGroup.m_Name] = nil
	self.m_CameraUpdateGroupMap[storeGroup.m_Name] = nil
end

function StoreManager:RemoveDynamicRegister(storeGroup)
	if self.Debug then
		print_notice("StoreManager => RemoveDynamicRegister ", storeGroup.m_Name, UnityEngine.Time.frameCount)
	end

	self.m_DynamicOnUpdateGroupMap[storeGroup.m_Name] = nil
	self.m_DynamicOnLateUpdateGroupMap[storeGroup.m_Name] = nil
	self.m_DynamicOnCameraUpdateGroupMap[storeGroup.m_Name] = nil
end

function StoreManager:SetCommonDebugInfo(key, value)
	self:GetStoreGroup("CommonDebugPanelStore"):SetDebugInfo(key, value)
end

function StoreManager:RemoveCommonDebugInfo(key)
	self:GetStoreGroup("CommonDebugPanelStore"):RemoveDebugInfo(key)
end

function StoreManager:SetDebugUIInput(debug)
	self.DEBUG_UI_INPUT = debug

	print_error("#NoCreateIssue SetDebugUIInput", debug)
end

gStoreManager = gStoreManager or C_StoreManager.new()
