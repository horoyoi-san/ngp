-- Original chunk: @Lua\LuaFiles\LX6\Guide\NewGuideMgr_SGUI.lua
-- Decompiled from: 00368_NewGuideMgr_SGUI.lua_63e8b09bfb95.luajit

local M = C_NewGuideMgr

M._InitSGUIFields = function(self)
	self.SEventType = {
		["pV\\xc1\\xae\\x81/\\xad\r\\xcd\\xed"] = 2,
		["\\xb0*\\xe3\\xb8V:\\xe1N\t\\xcc\\xebVN\\xde\r\\xb5\\xc5"] = 9,
		["/'\\xed}\\xb5\\xf6 \\xab'\\xc1\\xe7\\xefp\\xfe"] = 7,
		["pLeyi="] = 5,
		["'\\xed[\\xc4\\xbef\\xb4_\\xb4\\xb3"] = 8,
		["lWigi="] = 1,
		["U\\x94\\x94\\xbaΗ\\xd02\\xad:=\\xbd#"] = 6,
		[" \\xf6K8\\xde8\\xa4N\\xb1F\\xb5\\xb2"] = 10,
		["T\\xb1>\\xe5k\\xaen\r89t\\x86\\xeb,\\xdd\\xe2"] = 3,
		["mBt}i="] = 4
	}
	self.sguiEventHandlers = {}
	self.isPanelStateDirty = false
	self.isNeedRefreshUGuides = false
	self.panelCheckUpdateHandler = nil
	self.panelIdToUGuide = {}
	self.registeredUGuideCount = 0
	self.isRegisteredPanelShowStateChange = false
end

M.ResolveOpenUGuide = function(self, uGuide)
	local panelId = uGuide.panelId

	if not panelId or panelId ~= 0 then
		return
	end

	if not self.panelIdToUGuide[panelId] then
		self.panelIdToUGuide[panelId] = {}
	end

	if not table.contains(self.panelIdToUGuide[panelId], uGuide) then
		table.insert(self.panelIdToUGuide[panelId], uGuide)

		self.registeredUGuideCount = self.registeredUGuideCount + 1

		self.RefreshPanelShowStateRegister(self)
	end
end

M.ResolveDestroyUsedUGuide = function(self, uGuide)
end

M.ResolveCloseUGuide = function(self, uGuide)
	local panelId = uGuide.panelId

	if not panelId or panelId ~= 0 then
		return
	end

	if not self.panelIdToUGuide[panelId] then
		return
	end

	for i, uGuideInList in ipairs(self.panelIdToUGuide[panelId]) do
		if uGuideInList ~= uGuide then
			table.remove(self.panelIdToUGuide[panelId], i)

			self.registeredUGuideCount = self.registeredUGuideCount - 1

			self.RefreshPanelShowStateRegister(self)

			return
		end
	end
end

M.RefreshPanelShowStateRegister = function(self)
	if self.registeredUGuideCount <= 0 then
		if not self.isRegisteredPanelShowStateChange then
			gMessageManager:AddMessageListener(gEventConstants.PANEL_UI_SHOWSTATE_CHANGE, self.PanelShowStateChangeHandler)
			gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_SHOW, self.PanelShowStateChangeHandler)
			gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.PanelShowStateChangeHandler)

			if self.panelCheckUpdateHandler then
				print_error("RefreshPanelShowStateChangeHandler UpdateBeat重复注册")
				UpdateBeat:RemoveListener(self.panelCheckUpdateHandler)
			else
				self.panelCheckUpdateHandler = UpdateBeat:CreateListener(self.PanelCheckUpdate, self)

				UpdateBeat:AddListener(self.panelCheckUpdateHandler)
			end

			self.SetPanelStateDirty(self)

			self.isRegisteredPanelShowStateChange = true
		end
	elseif self.isRegisteredPanelShowStateChange then
		gMessageManager:RemoveMessageListener(gEventConstants.PANEL_UI_SHOWSTATE_CHANGE, self.PanelShowStateChangeHandler)
		gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_SHOW, self.PanelShowStateChangeHandler)
		gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_CLOSE, self.PanelShowStateChangeHandler)

		if self.panelCheckUpdateHandler then
			UpdateBeat:RemoveListener(self.panelCheckUpdateHandler)

			self.panelCheckUpdateHandler = nil
		else
			print_error("RefreshPanelShowStateChangeHandler UpdateBeat移除失败")
		end

		self.isRegisteredPanelShowStateChange = false
	end
end

M.SetPanelStateDirty = function(self)
	self.isPanelStateDirty = true
end

M.RefreshUGuides = function(self)
	for panelId, uGuideList in pairs(self.panelIdToUGuide) do
		if not uGuideList then
			return
		end

		local visible = gPanelManager:IsPanelVisible(panelId)

		for _, uGuide in ipairs(uGuideList) do
			if visible then
				uGuide.SetDisplayElementState(uGuide, true)
			else
				uGuide.SetDisplayElementState(uGuide, false)
			end
		end
	end
end

M.PanelShowStateChangeHandler = function(_, _)
	gNewGuideMgr:SetPanelStateDirty()
end

M.PanelCheckUpdate = function(self)
	if self.isNeedRefreshUGuide then
		self.isNeedRefreshUGuide = false

		self.RefreshUGuides(self)
	end

	if self.isPanelStateDirty then
		self.isPanelStateDirty = false
		self.isNeedRefreshUGuide = true
	end
end

M.RegisterSGUIGuideEvent = function(self, type, callback)
	local link = self.sguiEventHandlers[type]

	if link ~= nil then
		link = list:new()
		self.sguiEventHandlers[type] = link
	end

	link.push(link, callback)
end

M.UnRegisterSGUIGuideEvent = function(self, type, callback)
	local link = self.sguiEventHandlers[type]

	if link == nil then
		link.erase(link, callback)
	end
end

M.InitAllSGUIEventTrigger = function(self)
	SGUI.GuideMgr.onCloseGuide = function(uGuide)
		self:ResolveCloseUGuide(uGuide)
		self:OnSGUIGuideEvent(self.SEventType.CloseGuide, uGuide)
	end

	SGUI.GuideMgr.onNextGuide = function(guideId)
		self:OnSGUIGuideEvent(self.SEventType.NextGuide, guideId)
	end

	SGUI.GuideMgr.onSkipGuide = function(guideId)
		self:OnSGUIGuideEvent(self.SEventType.SkipGuide, guideId)
	end

	SGUI.GuideMgr.onOpenGuide = function(uGuide)
		self:ResolveOpenUGuide(uGuide)
		self:OnSGUIGuideEvent(self.SEventType.OpenGuide, uGuide)
	end

	SGUI.GuideMgr.onDestroyUsedGuide = function(uGuide)
		self:ResolveDestroyUsedUGuide(uGuide)
		self:OnSGUIGuideEvent(self.SEventType.DestroyGuide, uGuide)
	end

	SGUI.GuideMgr.onIncorrectCloseGuide = function(guideId)
		self:OnSGUIGuideEvent(self.SEventType.IncorrectCloseGuide, guideId)
	end

	SGUI.GuideMgr.onRenderGuidePopup = function(guideId, component)
		self:OnSGUIGuideEvent(self.SEventType.RenderGuidePopup, guideId, component)
	end

	SGUI.GuideMgr.onBeginMatchGuide = function(guideId)
		self:OnSGUIGuideEvent(self.SEventType.BeginMatchGuide, guideId)
	end

	SGUI.GuideMgr.onEndMatchGuide = function(guideId)
		self:OnSGUIGuideEvent(self.SEventType.EndMatchGuide, guideId)
	end

	SGUI.GuideMgr.onRenderGuideSmartLine = function(guideId, component)
		self:OnSGUIGuideEvent(self.SEventType.RenderGuideSmartLine, guideId, component)
	end

	SGUI.GuideMgr.onButtonDropped = function(dropGuideId)
		self:OnSGUIGuideEvent(self.SEventType.ButtonDropped, dropGuideId)
	end
end

M.OnSGUIGuideEvent = function(self, eventType, ...)
	local link = self.sguiEventHandlers[eventType]

	if link == nil then
		for _, value in ilist(link) do
			value(...)
		end
	end
end

M.RegisterGuideKeyLocations = function(self, list, locationMap)
	list.UnregisterAllGuideKeyLocations(list)
	LX6.GUI.UIExtension.RegisterGuideIdLocations(list, locationMap)
end

M.UpdateHUDLPPopupUI = function(self, guideId, component, ratio, pressTime)
	if not component or gCS.LuaUtils.IsNull(component) then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup("HUDlongpressStore")

	if not storeGroup then
		print_error("[GuideBT] UpdateHUDLPPopupUI: 找不到 HUDlongpressStore，guideId=", guideId)

		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, component)

	if not store then
		return
	end

	store.fill = ratio
	local remainTime = math.max(pressTime * (1 - ratio), 0)
	store.time = remainTime <= 0 and tostring(math.ceil(remainTime)) or ""
end
