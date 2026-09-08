-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_FSM.lua
-- Decompiled from: 01001_NewMapPanelStore_FSM.lua_bcf4544517ca.luajit

EBigMapFSMState = {
	["5F\\x95\\x81\\x8cS"] = 3,
	["$\\xeaS8\\xc2#\\x93O\\xa0T\\xbc\\xb3"] = 41,
	["nBx{A3="] = 12,
	["tRt|K3="] = 17,
	["\\x89\\xb8\\x9ce,\\xf27"] = 2,
	["\\x9f\\xb0\\xa2G1\\xfa6"] = 11,
	["pUð\\x8b\\x95\\xcd\\xed"] = 15,
	["\\xab!\\xf9\\xb9A)\\xc5O\t\\xc7\\xe0\"RP\\xcf\"\\xa8\\xce"] = 22,
	["qFol\\3="] = 19,
	["*\\xe8\\x93 \\xcf^6\r\\xbf\\x8bc\\xbcQ\\xb9m$\\xb9Տ*\\xc0"] = 23,
	["\\xb95#+q\\x92O\\xf48\\xae\\xbc"] = 13,
	["\\xc1\\x93\\xf8\\xd9?\\xe3\\x9b\\xec\\x80,-"] = 42,
	["\t#!\\xc9f\\xae\\xfe1\\xbf\\xc5\\xfe\\xe9g\\xfe"] = 32,
	["lSdl\\,<"] = 4,
	["_ɸ\\x8a\\x95\\xcd\\xed"] = 16,
	["fJ|}W?9"] = 5,
	["T\\xa64\\xe5x\r\\xb9s.u\\xad\\xfb\\xfb\\xca"] = 21,
	["kHyzK3="] = 18,
	["\\xb1呏\n\\x8daW\\xc0\\xde\\xd5r]\\x97牏\n\\xa5lG\\xc0\\xd1\\xfe^?L\\x8d"] = 25,
	["͓\\xc1\t'\\xef\\xfd\\xb7%&"] = 31,
	["\\xe9\"6\\xfb\\x99\\xa6ఈ迱ࣟ0\\xc0\\x8a'\\x95\\x9b\\x94\\xc47\\xf5"] = 24
}
EBigMapFSMSignal = {
	["5-\\x99\\xf9\\xa8\\xafũ\\xbe\\x8d\\xfa\\xe3<\\xc1\\x894\\x9a\\xf0"] = 15,
	["T\\x93\\x84\\xbcԝ\\xca?\\xac\\xb58"] = 16,
	["&\\xeaL-\\xdc\\x90H\\xadB\\xb5\\xa4"] = 42,
	["=)\\xf0p\\x90\\xda;\\xac*\\xd4\\xf3\\xe5q\\xe9"] = 19,
	["Jx\\xadu@\\xb7\\xd4Nfn{^"] = 41,
	["]\\xf23\\xe9;6,\\xd7h/\\xdbt\\xbe\tQ\\xc3\\xf2"] = 21,
	["=)\\xf0p\\x90\\xda;\\xac*\\xd1\\xe7\\xfea\\xfe"] = 17,
	["=)\\xf0p\\x90\\xda;\\xac*\\xce\\xfd\\xf3g\\xfe"] = 18,
	["eo\\xe3@\\xd6\\xf8\\xf1{5\\xfbfz\\xc8\\xf8w\\xeaGs\\xd8\\xd4\\xf6ٝ\\xe6a"] = 23,
	["G\\xeb.\\xf8*?\\xcce%\\xf3J\\x8fK\\xc9\\xe8"] = 14,
	["Ė\\xff;\\xefǝۋ%?"] = 32,
	["'\\xedK)\\xf2\\xb1v\\xaeD\\xbc\\xb2"] = 1,
	["-\\xf3Z\" \\xd9\\x9bT\\x97_\\xb5\\xa1"] = 31,
	["=)\\xf0p\\x90\\xda;\\xac*\\xcb\\xf7\\xf2f\\xf4"] = 13,
	["ԍ\\xf8\\xcb\\xee\\x8dك8!"] = 12,
	["/4\\x84蹦벳\\x87\\xd3\\xddÖ%\\x9c\\xf6"] = 22,
	["T\\x93\\x84\\xbcԝ\\xca?\\xac\\xbf9"] = 11,
	["\\xe9>\\xf2\\xef\\x9a߃),"] = 3,
	["\\xba:4:j\\xb4O\\xdd8\\xa5\\xab"] = 2
}
EBigMapPlatformMask = {
	["0*"] = 1,
	["\\xafdj"] = 7,
	["1G\\x93\\x87\\x8fD"] = 2,
	["0:"] = 4,
	["T-s^"] = 0
}

dofile("LX6/Manager/Map/Utils/BigMapState")
dofile("LX6/Manager/Map/Utils/BigMapComponents")

local M = C_NewMapPanelStore

M.InitComponents = function(self)
	self._activeCompsCache = {}
	self._needNotifyAddElemComps = {}
	self._needNotifyRemoveElemComps = {}
	self._needNotifyAttachElementComps = {}
	self._needNotifyClearAttachElementComps = {}
	self._needNotifyNavAreaChangeComps = {}
	self._needNotifyFilterSpiritChangeComps = {}
	self.comps = {}

	for i = 1, LTConfig.GpsBigMapComponentsConfig.count do
		local cfg = LTConfig.GpsBigMapComponentsConfig.LoadAt(i - 1)
		local comp = setmetatable({}, _G[cfg.Cls])
		local compType = cfg.Id
		comp.config = cfg
		comp.bigMap = self
		comp.actived = false
		comp.bindData = self.bindData
		self.comps[compType] = comp

		if not comp.__initFail and comp.OnInit then
			local ok, err = xpcall(comp.OnInit, tolua.traceback, comp)

			if not ok then
				comp.__initFail = true

				print_error("BigMapComponent " .. tostring(compType) .. " init failed: " .. err)
			end
		end

		if comp.OnAddElement then
			self._needNotifyAddElemComps[compType] = comp
		end

		if comp.OnRemoveElement then
			self._needNotifyRemoveElemComps[compType] = comp
		end

		if comp.OnAttachElement then
			self._needNotifyAttachElementComps[compType] = comp
		end

		if comp.OnClearAttachedElement then
			self._needNotifyClearAttachElementComps[compType] = comp
		end

		if comp.OnNavAreaChange then
			self._needNotifyNavAreaChangeComps[compType] = comp
		end

		if comp.OnFilterSpiritChange then
			self._needNotifyFilterSpiritChangeComps[compType] = comp
		end
	end

	self.InitComponentRefs(self)
end

M.DestroyComponents = function(self)
	if not self.comps then
		return
	end

	for compType, comp in pairs(self.comps) do
		if comp.actived then
			comp.actived = false

			if comp.OnInactive then
				comp.OnInactive(comp)
			end
		end

		if comp.started and comp.OnEnd then
			comp.OnEnd(comp)
		end

		if comp.OnDestroy then
			comp.OnDestroy(comp)
		end

		self.comps[compType] = nil
	end

	self.compRefs = nil
end

M.DoComponentsOnUpdate = function(self)
	for _, comp in pairs(self.comps) do
		if comp.actived and comp.OnUpdate then
			comp.OnUpdate(comp)
		end
	end
end

M.DoComponentsOnDeviceChange = function(self, device)
	for _, comp in pairs(self.comps) do
		if comp.actived and comp.OnActiveDeviceChange then
			comp.OnActiveDeviceChange(comp, device)
		end
	end
end

M.InitComponentRefs = function(self)
	self.compRefs = {}

	for i = 1, LTConfig.GpsBigMapComponentsConfig.count do
		local cfg = LTConfig.GpsBigMapComponentsConfig.LoadAt(i - 1)
		local compType = cfg.Id

		if cfg.RefName then
			self.compRefs[cfg.RefName] = self.comps[compType]
		end
	end
end

M.ResolveComponentActiveState = function(self, compType)
	local comp = self.comps[compType]

	if not comp then
		return
	end

	local actived = true

	if comp.config.SystemUnlock then
		for _, sysID in ipairs(comp.config.SystemUnlock) do
			if not gSystemUnlockMgr:IsUnlock(sysID) then
				actived = false

				break
			end
		end
	end

	local requireActived = true

	if comp.config.RequireState then
		for _, state in ipairs(comp.config.RequireState) do
			if not self._activeStates[state] then
				requireActived = false

				break
			end
		end
	end

	local requireActived2 = true

	if comp.config.RequireState2 then
		for _, state in ipairs(comp.config.RequireState2) do
			if not self._activeStates[state] then
				requireActived2 = false

				break
			end
		end
	else
		requireActived2 = false
	end

	actived = actived and (requireActived or requireActived2)

	if comp.config.ConflictState then
		for _, state in ipairs(comp.config.ConflictState) do
			if self._activeStates[state] then
				actived = false

				break
			end
		end
	end

	if actived then
		if comp.actived then
			return
		end

		if not comp.__initFail and not comp.started then
			if comp.OnStart then
				local ok, err = xpcall(comp.OnStart, tolua.traceback, comp)

				if not ok then
					comp.__initFail = true

					print_error("BigMapComponent " .. tostring(compType) .. " onStart failed: " .. err)
				else
					comp.started = true
				end
			else
				comp.started = true
			end
		end

		if comp.__initFail then
			return
		end

		comp.actived = true

		if comp.OnActive then
			comp.OnActive(comp)
		end
	else
		if comp.__initFail or not comp.actived then
			return
		end

		comp.actived = false

		if comp.OnInactive then
			comp.OnInactive(comp)
		end
	end
end

M.ResolveComponentsByFSM = function(self)
	for compType, _ in pairs(self.comps) do
		self.ResolveComponentActiveState(self, compType)
	end
end

M.GetComp = function(self, compType)
	return self.comps[compType]
end

M.InitFSM = function(self)
	self.fsms = {}

	for i = 1, LTConfig.GpsBigMapFSMModeConfig.count do
		local cfg = LTConfig.GpsBigMapFSMModeConfig.LoadAt(i - 1)
		local fsm = self.GetInitFSM(self)

		for _, info in pairs(cfg.SignalToState) do
			fsm.globalTransitions[info.signalId] = info.stateId
		end

		fsm.defaultState = cfg.DefaultState
		fsm.currentState = cfg.DefaultState
		self.fsms[cfg.Id] = fsm
	end

	self._activeStates = {}

	for _, fsm in ipairs(self.fsms) do
		if fsm.currentState then
			self._activeStates[fsm.currentState] = true
		end
	end

	self.fsmSignalFence = false
end

M.ClearFSM = function(self)
	self.fsms = nil
	self._activeStates = nil
end

M.GetAreaTypeFSM = function(self)
	local fsm = self.GetInitFSM(self)
	fsm.globalTransitions[EBigMapFSMSignal.EnterBigWorld] = EBigMapFSMState.BigWorld
	fsm.globalTransitions[EBigMapFSMSignal.EnterIndoor] = EBigMapFSMState.Indoor
	fsm.globalTransitions[EBigMapFSMSignal.EnterOtherRaid] = EBigMapFSMState.OtherRaid
	fsm.states[EBigMapFSMState.BigWorld] = self.MakeFSMState(self, "BigWorld")
	fsm.states[EBigMapFSMState.Indoor] = self.MakeFSMState(self, "Indoor")
	fsm.states[EBigMapFSMState.OtherRaid] = self.MakeFSMState(self, "OtherRaid")

	return fsm
end

M.GetModeFSM = function(self)
	local fsm = self.GetInitFSM(self)
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeCommon] = EBigMapFSMState.CommonMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeTaxi] = EBigMapFSMState.TaxiMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeMetro] = EBigMapFSMState.MetroMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeFaction] = EBigMapFSMState.FactionMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeLegend] = EBigMapFSMState.LegendMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeWuxue] = EBigMapFSMState.WuxueMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeHouse] = EBigMapFSMState.HouseMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeRacer] = EBigMapFSMState.RacerMode
	fsm.states[EBigMapFSMState.TaxiMode] = self.MakeFSMState(self, "TaxiMode")
	fsm.states[EBigMapFSMState.MetroMode] = self.MakeFSMState(self, "MetroMode")
	fsm.states[EBigMapFSMState.FactionMode] = self.MakeFSMState(self, "FactionMode")
	fsm.states[EBigMapFSMState.CommonMode] = self.MakeFSMState(self, "BigMapMode")
	fsm.states[EBigMapFSMState.LegendMode] = self.MakeFSMState(self, "LegendMode")
	fsm.states[EBigMapFSMState.WuxueMode] = self.MakeFSMState(self, "WuxueMode")
	fsm.states[EBigMapFSMState.HouseMode] = self.MakeFSMState(self, "HouseMode")
	fsm.currentState = EBigMapFSMState.CommonMode

	return fsm
end

M.GetInteractionFSM = function(self)
	local fsm = self.GetInitFSM(self)
	fsm.globalTransitions[EBigMapFSMSignal.Interaction_Reset] = EBigMapFSMState.Interaction_IdleKBM
	fsm.globalTransitions[EBigMapFSMSignal.Interaction_Select] = EBigMapFSMState.Interaction_Selected
	fsm.states[EBigMapFSMState.Interaction_IdleKBM] = self.MakeFSMState(self, "Interaction_IdleKBM")
	fsm.states[EBigMapFSMState.Interaction_Selected] = self.MakeFSMState(self, "Interaction_Selected", BigMapFSMState_Selected)
	fsm.currentState = EBigMapFSMState.Interaction_IdleKBM

	return fsm
end

M.GetJiaMuViewFsm = function(self)
	local fsm = self.GetInitFSM(self)
	fsm.globalTransitions[EBigMapFSMSignal.OpenJiaMuView] = EBigMapFSMState.JiaMuView_Open
	fsm.globalTransitions[EBigMapFSMSignal.CloseJiaMuView] = EBigMapFSMState.JiaMuView_Close
	fsm.states[EBigMapFSMState.JiaMuView_Open] = self.MakeFSMState(self, "JiaMuView_Open")
	fsm.states[EBigMapFSMState.JiaMuView_Close] = self.MakeFSMState(self, "JiaMuView_Close")
	fsm.currentState = EBigMapFSMState.JiaMuView_Close

	return fsm
end

M.GetFilterFsm = function(self)
	local fsm = self.GetInitFSM(self)
	fsm.globalTransitions[EBigMapFSMSignal.EnableFilter] = EBigMapFSMState.Filter_Enable
	fsm.globalTransitions[EBigMapFSMSignal.DisableFilter] = EBigMapFSMState.Filter_Disable
	fsm.states[EBigMapFSMState.Filter_Enable] = self.MakeFSMState(self, "Filter_Enable")
	fsm.states[EBigMapFSMState.Filter_Disable] = self.MakeFSMState(self, "Filter_Disable")
	fsm.currentState = EBigMapFSMState.Filter_Disable

	return fsm
end

M.GetInitFSM = function(self)
	local fsm = {
		currentState = nil,
		states = {},
		globalTransitions = {},
		transitions = {}
	}

	return fsm
end

M.MakeFSMState = function(self, stateName, cls)
	local state = (cls or BigMapFSMState).new()
	state.name = stateName
	state.bigMap = self
	state.bindData = self.bindData

	return state
end

M.SendFSMSignal = function(self, signal, param)
	for _, fsm in ipairs(self.fsms) do
		self.FSMHandleSingleSignal(self, fsm, signal, param)
	end

	self.ResolveComponentsByFSM(self)
end

M.FSMHandleSingleSignal = function(self, fsm, signal, enabled)
	local toState = fsm.globalTransitions[signal]

	if toState and enabled ~= false then
		toState = fsm.defaultState
	end

	if toState and toState == fsm.currentState then
		if fsm.currentState then
			self._activeStates[fsm.currentState] = nil
		end

		self._activeStates[toState] = true
		fsm.currentState = toState
	end
end

M.NotifyCompsAddElement = function(self, id, info)
	for _, comp in pairs(self._needNotifyAddElemComps) do
		local ok, err = xpcall(comp.OnAddElement, tolua.traceback, comp, id, info)

		if not ok then
			print_error("BigMapComponent OnAddElement failed: " .. err)
		end
	end
end

M.NotifyCompsRemoveElement = function(self, id, info)
	for _, comp in pairs(self._needNotifyRemoveElemComps) do
		local ok, err = xpcall(comp.OnRemoveElement, tolua.traceback, comp, id, info)

		if not ok then
			print_error("BigMapComponent OnRemoveElement failed: " .. err)
		end
	end
end

M.NotifyCompsOnAttachElement = function(self, id, element, source)
	for _, comp in pairs(self._needNotifyAttachElementComps) do
		if not comp.actived then
			-- Nothing
		else
			local ok, err = xpcall(comp.OnAttachElement, tolua.traceback, comp, id, element, source)

			if not ok then
				print_error("BigMapComponent OnAttachElement failed: " .. err)
			end
		end
	end
end

M.NotifyCompsOnClearAttachedElement = function(self)
	for _, comp in pairs(self._needNotifyClearAttachElementComps) do
		if not comp.actived then
			-- Nothing
		else
			local ok, err = xpcall(comp.OnClearAttachedElement, tolua.traceback, comp)

			if not ok then
				print_error("BigMapComponent OnClearAttachedElement failed: " .. err)
			end
		end
	end
end

M.NotifyCompsOnNavAreaChange = function(self, oldArea, newArea)
	for _, comp in pairs(self._needNotifyNavAreaChangeComps) do
		if not comp.actived then
			-- Nothing
		else
			local ok, err = xpcall(comp.OnNavAreaChange, tolua.traceback, comp, oldArea, newArea)

			if not ok then
				print_error("BigMapComponent OnNavAreaChange failed: " .. err)
			end
		end
	end
end

M.NotifyCompsOnFilterSpiritChange = function(self, tid)
	for _, comp in pairs(self._needNotifyFilterSpiritChangeComps) do
		if not comp.actived then
			-- Nothing
		else
			local ok, err = xpcall(comp.OnFilterSpiritChange, tolua.traceback, comp, tid)

			if not ok then
				print_error("BigMapComponent OnFilterSpiritChange failed: " .. err)
			end
		end
	end
end
