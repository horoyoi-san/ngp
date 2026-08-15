C_StoreGroup = DefClass("C_StoreGroup", C_StoreGroup)
local StoreGroup = C_StoreGroup

function StoreGroup:ctor(name, id, isSub)
	self.m_Id = id
	self.m_Name = name
	self.bindData = gStoreManager:NewStoreProxy(name)
	self.bActive = false
	self.DEFINE_ForceUpdate = false
	self.DEFINE_PanelCloseClearBindData = true
	self.DEFINE_LogOutClearBindData = true
	self.DEFINE_DynamicOnUpdate = false
	self.DEFINE_DynamicOnLateUpdate = false
	self.DEFINE_DynamicOnCameraUpdate = false
	self.storeDic = {}
	self.storeCount = 0
	self.SubGroup = {}
	self.subGroupCount = 0
	self.isSub = isSub
	self.rootId = -1
	self.rooted = false
	self.rootGo = nil
	self.rootWidget = nil
	self.STATE_EnableOnce = false
	self.STATE_Started = false
	self.STATE_WaitOnShow = false
	self.STATE_OnShowOnce = false
	self.STATE_ShowData = nil
	self._MsgEvents = {}
end

function StoreGroup:GetStoreByWidget(widget)
	return widget.storeMode == gStoreManager.StoreMode.Root and self.bindData or self.storeDic[widget.gameObject:GetInstanceID()]
end

function StoreGroup:GetStoreById(id)
	return self.storeDic[id]
end

function StoreGroup:AddStoreProxy(id, store)
	if not self.storeDic[id] then
		store.m_Store.group = self
		self.storeDic[id] = store
		self.storeCount = self.storeCount + 1

		if gStoreManager.Debug then
			print_notice("StoreManager-StoreGroup => AddStoreProxy ", self.m_Name, "  totalCount=", self.storeCount)
		end
	end
end

function StoreGroup:RemoveStoreProxy(id, store)
	store.m_Store.group = nil

	if self.storeDic[id] then
		self.storeDic[id] = nil
		self.storeCount = self.storeCount - 1

		if gStoreManager.Debug then
			print_notice("StoreManager-StoreGroup => RemoveStoreProxy ", self.m_Name, " remainCount=", self.storeCount)
		end
	end
end

function StoreGroup:BindRoot(widget)
	self.rootGo = widget.gameObject
	self.rootWidget = widget
	self.rootId = widget.gameObject:GetInstanceID()
	self.rooted = true
end

function StoreGroup:UnBindRoot(widget)
	if not self.rooted then
		return
	end

	self.rootGo = nil
	self.rootWidget = nil
	self.rooted = false
	self.rootId = -1
end

function StoreGroup:RegisterSubGroup(name, group)
	if self.SubGroup[name] then
		print_error("RegisterSubGroup 重复 groupName=", group.m_Name, "subName=", name, UnityEngine.Time.frameCount)

		self.SubGroup[name] = nil
		self.subGroupCount = self.subGroupCount - 1
	end

	self.SubGroup[name] = group
	self.subGroupCount = self.subGroupCount + 1

	if gStoreManager.Debug then
		print_notice("StoreManager-StoreGroup => RegisterSubGroup ", self.m_Name, " => ", name, self.subGroupCount, UnityEngine.Time.frameCount)
	end
end

function StoreGroup:OnBeforeAwake()
	if self.DefineAllEnumsAutoGen then
		self:DefineAllEnumsAutoGen()
	end
end

function StoreGroup:OnAwake()
	return
end

function StoreGroup:OnPreload()
	return
end

function StoreGroup:OnGroupEnable()
	return
end

function StoreGroup:OnEnable()
	return
end

function StoreGroup:OnStart()
	return
end

function StoreGroup:OnDisable()
	return
end

function StoreGroup:OnGroupDisable()
	return
end

function StoreGroup:OnShow()
	return
end

function StoreGroup:OnClose()
	return
end

function StoreGroup:OnDestroy()
	return
end

function StoreGroup:OnAfterDestroy()
	if self.ClearAllEnumsAutoGen then
		self:ClearAllEnumsAutoGen()
	end
end

function StoreGroup:ResetPanelData()
	self.STATE_EnableOnce = false
	self.STATE_WaitOnShow = false
	self.STATE_ShowData = nil
	self.STATE_OnShowOnce = false
	self.STATE_Started = false

	if self.DEFINE_PanelCloseClearBindData then
		self.bindData:ClearData()
	end
end

function StoreGroup:OnGroupLogOut()
	if self.DEFINE_LogOutClearBindData then
		self.bindData:ClearData()
	end

	self:OnLogOut()
end

function StoreGroup:OnLogOut()
	return
end

function StoreGroup:OnLanguageChange(lang)
	return
end

function StoreGroup:OnActiveDeviceChange(device)
	return
end

function StoreGroup:OnCustomBindDataChange(widget)
	return
end

function StoreGroup:RegisterSingleEvent(enentId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

function StoreGroup:RegisterMessageEvents(eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

function StoreGroup:ClearMessageEvents()
	for i, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

function StoreGroup:RegisterDataSetEvents(eventHandlers)
	if #eventHandlers == 0 then
		return
	end

	if self._DataSetEvents == nil then
		self._DataSetEvents = C_DataEventSet.New()
	end

	for i = 1, #eventHandlers do
		local handler = eventHandlers[i]

		self._DataSetEvents:BindHandler(unpack(handler))
	end
end

function StoreGroup:ClearDataSetEvents()
	if self._DataSetEvents then
		self._DataSetEvents:Clear()
	end
end

function StoreGroup:PlayAniChain(animation, stateName, duration, belongPanel)
	local queue = {}
	local chain = {}
	local skipFlag = false
	local stopped = false

	local function addPlay(animObj, name, playDuration)
		table.insert(queue, {
			animation = animObj,
			stateName = name,
			duration = playDuration
		})
	end

	function chain:PlayAniChain(animObj, name, playDuration)
		if not stopped then
			addPlay(animObj, name, playDuration)
		end

		return chain
	end

	function chain:OnComplete(cb)
		if not stopped and #queue > 0 then
			queue[#queue].onComplete = cb
		end

		return chain
	end

	function chain:Skip()
		skipFlag = true

		if queue._lastAnimation then
			queue._lastAnimation:Stop()
		end

		return chain
	end

	function chain:Stop()
		stopped = true

		if queue._lastAnimation then
			queue._lastAnimation:Stop()
		end

		for i = 1, #queue do
			queue[i].onComplete = nil
		end

		queue = {}

		return chain
	end

	addPlay(animation, stateName, duration)

	queue._lastAnimation = animation

	local function coroutineFunc()
		while not stopped and #queue > 0 do
			local checkId = belongPanel or self.m_Id

			if checkId and not gPanelManager:IsPanelShowing(checkId) then
				return
			end

			local cur = queue[1]
			queue._lastAnimation = cur.animation

			cur.animation:Play(cur.stateName)

			local clip = cur.animation:GetClip(cur.stateName)
			local playDuration = cur.duration

			if not playDuration or playDuration <= 0 then
				playDuration = clip and clip.length and clip.length > 0 and clip.length or 0.01
			end

			skipFlag = false
			local timer = 0

			while playDuration > timer and not skipFlag and not stopped do
				coroutine.yield(nil)

				timer = timer + UnityEngine.Time.deltaTime
			end

			if checkId and not gPanelManager:IsPanelShowing(checkId) then
				return
			end

			if cur.onComplete then
				local cb = cur.onComplete
				cur.onComplete = nil

				cb()
			end

			table.remove(queue, 1)
		end

		for i = 1, #queue do
			queue[i].onComplete = nil
		end

		queue = {}
		stopped = true

		if queue._lastAnimation then
			queue._lastAnimation:Stop()
		end
	end

	gCoroutineManager:StartCoroutine(coroutineFunc)

	return chain
end
