local bit = require("bit")
EBigMapFSMState = {
	Indoor = 3,
	MetroMode = 12,
	Filter_Enable = 41,
	BigWorld = 2,
	TaxiMode = 11,
	CommonMode = 15,
	Interaction_Selected = 22,
	FactionMode = 13,
	Filter_Disable = 42,
	JiaMuView_Close = 32,
	OtherRaid = 4,
	LegendMode = 16,
	EmptyArea = 5,
	Interaction_IdleKBM = 21,
	Interaction_ControllerIndicatorMenu = 25,
	JiaMuView_Open = 31,
	Interaction_ControllerHover = 24
}
EBigMapFSMSignal = {
	SwitchModeGangster = 15,
	Interaction_Reset = 21,
	SwitchModeFaction = 14,
	CloseJiaMuView = 32,
	EnterBigWorld = 1,
	SwitchModeLegend = 16,
	SwitchModeMetro = 13,
	OpenJiaMuView = 31,
	SwitchModeTaxi = 12,
	Interaction_Select = 22,
	SwitchModeCommon = 11,
	EnableFilter = 41,
	DisableFilter = 42,
	EnterOtherRaid = 3,
	EnterIndoor = 2
}
EBigMapPlatformMask = {
	PC = 1,
	All = 7,
	Mobile = 2,
	PS = 4,
	None = 0
}

dofile("LX6/Manager/Map/Utils/BigMapState")
dofile("LX6/Manager/Map/Utils/BigMapComponents")

local M = C_NewMapPanelStore

function M:InitComponents()
	self._activeCompsCache = {}
	self._needNotifyAddElemComps = {}
	self._needNotifyRemoveElemComps = {}
	self._needNotifyAttachElementComps = {}
	self._needNotifyClearAttachElementComps = {}
	self._needNotifyNavAreaChangeComps = {}
	self._needNotifyFilterSpiritChangeComps = {}
	self.comps = {}

	for compType, _ in pairs(gBigMapComponentConfigs) do
		local config = gBigMapComponentConfigs[compType]
		local comp = setmetatable({}, config.cls)
		comp.config = config
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

	self:InitComponentRefs()
end

function M:DestroyComponents()
	if not self.comps then
		return
	end

	for compType, comp in pairs(self.comps) do
		if comp.actived then
			comp.actived = false

			if comp.OnInactive then
				comp:OnInactive()
			end
		end

		if comp.started and comp.OnEnd then
			comp:OnEnd()
		end

		if comp.OnDestroy then
			comp:OnDestroy()
		end

		self.comps[compType] = nil
	end

	self.compRefs = nil
end

function M:DoComponentsOnUpdate()
	for _, comp in pairs(self.comps) do
		if comp.actived and comp.OnUpdate then
			comp:OnUpdate()
		end
	end
end

function M:DoComponentsOnDeviceChange(device)
	for _, comp in pairs(self.comps) do
		if comp.actived and comp.OnActiveDeviceChange then
			comp:OnActiveDeviceChange(device)
		end
	end
end

function M:InitComponentRefs()
	self.compRefs = {
		SwitchMapMode = self.comps[EBigMapComponentType.SwitchMapMode],
		Tooltip = self.comps[EBigMapComponentType.Tooltip],
		FactionOverride = self.comps[EBigMapComponentType.FactionOverride],
		LegendOverride = self.comps[EBigMapComponentType.LegendOverride],
		FilterMenu = self.comps[EBigMapComponentType.FilterMenu],
		SwitchBigMapSpirit = self.comps[EBigMapComponentType.SwitchBigMapSpirit],
		InScreenElementsList = self.comps[EBigMapComponentType.InScreenElementsList],
		GangsterArea = self.comps[EBigMapComponentType.GangsterArea],
		RightTopFilterList = self.comps[EBigMapComponentType.RightTopFilterList],
		MetroView = self.comps[EBigMapComponentType.MetroView]
	}
end

function M:ResolveComponentActiveState(compType)
	local comp = self.comps[compType]

	if not comp then
		return
	end

	local actived = true

	if comp.config.systemUnlock then
		for _, sysID in ipairs(comp.config.systemUnlock) do
			if not gSystemUnlockMgr:IsUnlock(sysID) then
				actived = false

				break
			end
		end
	end

	if comp.config.requireState then
		for _, state in ipairs(comp.config.requireState) do
			if not self._activeStates[state] then
				actived = false

				break
			end
		end
	end

	if comp.config.conflictState then
		for _, state in ipairs(comp.config.conflictState) do
			if self._activeStates[state] then
				actived = false

				break
			end
		end
	end

	if comp.config.platform and bit.band(comp.config.platform, self.platformMask) == 0 then
		actived = false
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
			comp:OnActive()
		end
	else
		if comp.__initFail or not comp.actived then
			return
		end

		comp.actived = false

		if comp.OnInactive then
			comp:OnInactive()
		end
	end
end

function M:ResolveComponentsByFSM()
	for compType, _ in pairs(self.comps) do
		self:ResolveComponentActiveState(compType)
	end
end

function M:GetComp(compType)
	return self.comps[compType]
end

function M:InitFSM()
	self.fsms = {
		self:GetAreaTypeFSM(),
		self:GetModeFSM(),
		self:GetInteractionFSM(),
		self:GetJiaMuViewFsm(),
		self:GetFilterFsm()
	}
	self._activeStates = {}

	for _, fsm in ipairs(self.fsms) do
		if fsm.currentState then
			self._activeStates[fsm.currentState] = true
		end
	end

	self.fsmSignalFence = false
end

function M:ClearFSM()
	self.fsms = nil
	self._activeStates = nil
end

function M:GetAreaTypeFSM()
	local fsm = self:GetInitFSM()
	fsm.globalTransitions[EBigMapFSMSignal.EnterBigWorld] = EBigMapFSMState.BigWorld
	fsm.globalTransitions[EBigMapFSMSignal.EnterIndoor] = EBigMapFSMState.Indoor
	fsm.globalTransitions[EBigMapFSMSignal.EnterOtherRaid] = EBigMapFSMState.OtherRaid
	fsm.states[EBigMapFSMState.BigWorld] = self:MakeFSMState("BigWorld")
	fsm.states[EBigMapFSMState.Indoor] = self:MakeFSMState("Indoor")
	fsm.states[EBigMapFSMState.OtherRaid] = self:MakeFSMState("OtherRaid")

	return fsm
end

function M:GetModeFSM()
	local fsm = self:GetInitFSM()
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeCommon] = EBigMapFSMState.CommonMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeTaxi] = EBigMapFSMState.TaxiMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeMetro] = EBigMapFSMState.MetroMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeFaction] = EBigMapFSMState.FactionMode
	fsm.globalTransitions[EBigMapFSMSignal.SwitchModeLegend] = EBigMapFSMState.LegendMode
	fsm.states[EBigMapFSMState.TaxiMode] = self:MakeFSMState("TaxiMode")
	fsm.states[EBigMapFSMState.MetroMode] = self:MakeFSMState("MetroMode")
	fsm.states[EBigMapFSMState.FactionMode] = self:MakeFSMState("FactionMode")
	fsm.states[EBigMapFSMState.CommonMode] = self:MakeFSMState("BigMapMode")
	fsm.states[EBigMapFSMState.LegendMode] = self:MakeFSMState("LegendMode")
	fsm.currentState = EBigMapFSMState.CommonMode

	return fsm
end

function M:GetInteractionFSM()
	local fsm = self:GetInitFSM()
	fsm.globalTransitions[EBigMapFSMSignal.Interaction_Reset] = EBigMapFSMState.Interaction_IdleKBM
	fsm.globalTransitions[EBigMapFSMSignal.Interaction_Select] = EBigMapFSMState.Interaction_Selected
	fsm.states[EBigMapFSMState.Interaction_IdleKBM] = self:MakeFSMState("Interaction_IdleKBM")
	fsm.states[EBigMapFSMState.Interaction_Selected] = self:MakeFSMState("Interaction_Selected", BigMapFSMState_Selected)
	fsm.currentState = EBigMapFSMState.Interaction_IdleKBM

	return fsm
end

function M:GetJiaMuViewFsm()
	local fsm = self:GetInitFSM()
	fsm.globalTransitions[EBigMapFSMSignal.OpenJiaMuView] = EBigMapFSMState.JiaMuView_Open
	fsm.globalTransitions[EBigMapFSMSignal.CloseJiaMuView] = EBigMapFSMState.JiaMuView_Close
	fsm.states[EBigMapFSMState.JiaMuView_Open] = self:MakeFSMState("JiaMuView_Open")
	fsm.states[EBigMapFSMState.JiaMuView_Close] = self:MakeFSMState("JiaMuView_Close")
	fsm.currentState = EBigMapFSMState.JiaMuView_Close

	return fsm
end

function M:GetFilterFsm()
	local fsm = self:GetInitFSM()
	fsm.globalTransitions[EBigMapFSMSignal.EnableFilter] = EBigMapFSMState.Filter_Enable
	fsm.globalTransitions[EBigMapFSMSignal.DisableFilter] = EBigMapFSMState.Filter_Disable
	fsm.states[EBigMapFSMState.Filter_Enable] = self:MakeFSMState("Filter_Enable")
	fsm.states[EBigMapFSMState.Filter_Disable] = self:MakeFSMState("Filter_Disable")
	fsm.currentState = EBigMapFSMState.Filter_Disable

	return fsm
end

function M:GetInitFSM()
	local fsm = {
		currentState = nil,
		states = {},
		globalTransitions = {},
		transitions = {}
	}

	return fsm
end

function M:MakeFSMState(stateName, cls)
	local state = (cls or BigMapFSMState).new()
	state.name = stateName
	state.bigMap = self
	state.bindData = self.bindData

	return state
end

function M:GetBigMapModeFSM()
	return
end

function M:SendFSMSignal(signal, param)
	for _, fsm in ipairs(self.fsms) do
		self:FSMHandleSingleSignal(fsm, signal, param)
	end

	self:ResolveComponentsByFSM()
end

function M:FSMHandleSingleSignal(fsm, signal, ...)
	local toState = fsm.globalTransitions[signal]

	if not toState then
		local transition = fsm.transitions[signal]

		if transition and transition.from == fsm.currentState then
			toState = transition.to
		end
	end

	if not toState then
		local stateObj = fsm.states[fsm.currentState]

		if stateObj and stateObj.ProcessSignal then
			toState = stateObj:ProcessSignal(signal, ...)
		end
	end

	if toState and toState ~= fsm.currentState then
		if fsm.currentState then
			self._activeStates[fsm.currentState] = nil
		end

		self._activeStates[toState] = true
		fsm.currentState = toState
	end
end

function M:NotifyCompsAddElement(id, info)
	for _, comp in pairs(self._needNotifyAddElemComps) do
		local ok, err = xpcall(comp.OnAddElement, tolua.traceback, comp, id, info)

		if not ok then
			print_error("BigMapComponent OnAddElement failed: " .. err)
		end
	end
end

function M:NotifyCompsRemoveElement(id, info)
	for _, comp in pairs(self._needNotifyRemoveElemComps) do
		local ok, err = xpcall(comp.OnRemoveElement, tolua.traceback, comp, id, info)

		if not ok then
			print_error("BigMapComponent OnRemoveElement failed: " .. err)
		end
	end
end

function M:NotifyCompsOnAttachElement(id, element, source)
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

function M:NotifyCompsOnClearAttachedElement()
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

function M:NotifyCompsOnNavAreaChange(oldArea, newArea)
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

function M:NotifyCompsOnFilterSpiritChange(tid)
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
