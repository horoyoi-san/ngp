-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreBase\StoreGroup.lua
-- Decompiled from: 00772_StoreGroup.lua_6f927c24a57c.luajit

C_StoreGroup = DefClass("C_StoreGroup", C_StoreGroup)
local StoreGroup = C_StoreGroup

StoreGroup.ctor = function(self, name, id, isSub)
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
	self.STATE_DoShowing = false
	self.STATE_NeedClose = false
	self._MsgEvents = {}
end

StoreGroup.GetStoreByWidget = function(self, widget)
	return widget.storeMode ~= gStoreManager.StoreMode.Root and self.bindData or self.storeDic[widget.gameObject:GetInstanceID()]
end

StoreGroup.GetStoreById = function(self, id)
	return self.storeDic[id]
end

StoreGroup.AddStoreProxy = function(self, id, store)
	if not self.storeDic[id] then
		store.m_Store.group = self
		self.storeDic[id] = store
		self.storeCount = self.storeCount + 1

		if gStoreManager.Debug then
			print_notice("StoreManager-StoreGroup => AddStoreProxy ", self.m_Name, "  totalCount=", self.storeCount)
		end
	end
end

StoreGroup.RemoveStoreProxy = function(self, id, store)
	store.m_Store.group = nil

	if self.storeDic[id] then
		self.storeDic[id] = nil
		self.storeCount = self.storeCount - 1

		if gStoreManager.Debug then
			print_notice("StoreManager-StoreGroup => RemoveStoreProxy ", self.m_Name, " remainCount=", self.storeCount)
		end
	end
end

StoreGroup.BindRoot = function(self, widget)
	self.rootGo = widget.gameObject
	self.rootWidget = widget
	self.rootId = widget.gameObject:GetInstanceID()
	self.rooted = true
end

StoreGroup.UnBindRoot = function(self, widget)
	if not self.rooted then
		return
	end

	self.rootGo = nil
	self.rootWidget = nil
	self.rooted = false
	self.rootId = -1
end

StoreGroup.RegisterSubGroup = function(self, name, group)
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

StoreGroup.OnBeforeAwake = function(self)
	if self.DefineAllEnumsAutoGen then
		self.DefineAllEnumsAutoGen(self)
	end
end

StoreGroup.OnAwake = function(self)
end

StoreGroup.OnPreload = function(self)
end

StoreGroup.OnGroupEnable = function(self)
end

StoreGroup.OnEnable = function(self)
end

StoreGroup.OnStart = function(self)
end

StoreGroup.OnDisable = function(self)
end

StoreGroup.OnGroupDisable = function(self)
end

StoreGroup.OnShow = function(self)
end

StoreGroup.OnClose = function(self)
end

StoreGroup.OnDestroy = function(self)
end

StoreGroup.OnAfterDestroy = function(self)
	if self.ClearAllEnumsAutoGen then
		self.ClearAllEnumsAutoGen(self)
	end
end

StoreGroup.ResetPanelData = function(self)
	self.STATE_EnableOnce = false
	self.STATE_WaitOnShow = false
	self.STATE_ShowData = nil
	self.STATE_OnShowOnce = false
	self.STATE_Started = false

	if self.DEFINE_PanelCloseClearBindData then
		self.bindData:ClearData()
	end
end

StoreGroup.OnGroupLogOut = function(self)
	if self.DEFINE_LogOutClearBindData then
		self.bindData:ClearData()
	end

	self.OnLogOut(self)
end

StoreGroup.OnLogOut = function(self)
end

StoreGroup.OnLanguageChange = function(self, lang)
	print_error_without_stack("@liulijun04 界面 " .. self.GetTypeName(self) .. " 未重写 StoreGroup:OnLanguageChange 事件。当语言切换时，可能存在其他语言文本残留", lang, self)
end

StoreGroup.OnActiveDeviceChange = function(self, device)
end

StoreGroup.OnCustomBindDataChange = function(self, widget)
end

StoreGroup.RegisterSingleEvent = function(self, enentId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

StoreGroup.RegisterMessageEvents = function(self, eventHandlers)
	for k, v in pairs(eventHandlers) do
		self.RegisterSingleEvent(self, k, v)
	end
end

StoreGroup.ClearMessageEvents = function(self)
	for i, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

StoreGroup.RegisterDataSetEvents = function(self, eventHandlers)
	if #eventHandlers ~= 0 then
		return
	end

	if self._DataSetEvents ~= nil then
		self._DataSetEvents = C_DataEventSet.New()
	end

	for i = 1, #eventHandlers do
		local handler = eventHandlers[i]

		self._DataSetEvents:BindHandler(unpack(handler))
	end
end

StoreGroup.ClearDataSetEvents = function(self)
	if self._DataSetEvents then
		self._DataSetEvents:Clear()
	end
end

StoreGroup.PlayAniChain = function(self, animation, stateName, duration, belongPanel)
	local queue = {}
	local chain = {}
	local skipFlag = false
	local stopped = false

	local addPlay = function(animObj, name, playDuration)
		table.insert(queue, {
			animation = animObj,
			stateName = name,
			duration = playDuration
		})
	end

	chain.PlayAniChain = function(self, animObj, name, playDuration)
		if not stopped then
			addPlay(animObj, name, playDuration)
		end

		return chain
	end

	chain.OnComplete = function(self, cb)
		if not stopped and #queue <= 0 then
			queue[#queue].onComplete = cb
		end

		return chain
	end

	chain.Skip = function(self)
		skipFlag = true

		if queue._lastAnimation then
			queue._lastAnimation:Stop()
		end

		return chain
	end

	chain.Stop = function(self)
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

	local coroutineFunc = function()
		while not stopped and #queue <= 0 do
			local checkId = belongPanel or self.m_Id

			if checkId and not gPanelManager:IsPanelShowing(checkId) then
				return
			end

			local cur = queue[1]
			queue._lastAnimation = cur.animation

			cur.animation:Play(cur.stateName)

			local clip = cur.animation:GetClip(cur.stateName)
			local playDuration = cur.duration

			if not playDuration or playDuration < 0 then
				playDuration = clip and clip.length and clip.length <= 0 and clip.length or 0.01
			end

			skipFlag = false
			local timer = 0

			while playDuration <= timer and not skipFlag and not stopped do
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
