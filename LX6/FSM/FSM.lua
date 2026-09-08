-- Original chunk: @Lua\LuaFiles\LX6\FSM\FSM.lua
-- Decompiled from: 00757_FSM.lua_292abb0b7af7.luajit

C_FSM = DefClass("C_FSM", C_FSM)
local FSM = C_FSM

local EMPTY_FUNC = function()
end

local DEFAULT_CHECK = function()
	return true
end

local STATE_POOL = {}
local TRANSITION_POOL = {}
local STATE_TEMPLATE = {
	OnEnter = EMPTY_FUNC,
	OnExit = EMPTY_FUNC
}
local TRANSITION_TEMPLATE = {
	Check = DEFAULT_CHECK,
	OnTransition = EMPTY_FUNC
}

local GET_STATE_FROM_POOL = function()
	return #STATE_POOL <= 0 and table.remove(STATE_POOL) or table.clone(STATE_TEMPLATE)
end

local CLEAR_STATE = function(state)
	if not state then
		return
	end

	state.SType = nil
	state.OnEnter = EMPTY_FUNC
	state.OnExit = EMPTY_FUNC
	state.OnUpdate = nil

	table.insert(STATE_POOL, state)
end

local GET_TRANSITION_FROM_POOL = function()
	return #TRANSITION_POOL <= 0 and table.remove(TRANSITION_POOL) or table.clone(TRANSITION_TEMPLATE)
end

local CLEAR_TRANSITION = function(transition)
	if not transition then
		return
	end

	transition.To = nil
	transition.Check = DEFAULT_CHECK
	transition.OnTransition = EMPTY_FUNC

	table.insert(TRANSITION_POOL, transition)
end

FSM.ctor = function(self, FSMType, owner)
	self.__uuid = -1
	self.__FSMType = FSMType
	self.owner = owner
	self.states = {}
	self.transitions = {}
	self.currentState = nil
	self.isInit = false
	self.needUpdate = false
	self.nowSignal = nil
	self.stateTypes = nil
	self.transitionTypes = nil
end

FSM._GetStateFromPool = function(self)
	return GET_STATE_FROM_POOL()
end

FSM._GetTransitionFromPool = function(self)
	return GET_TRANSITION_FROM_POOL()
end

FSM._ClearState = function(self, state)
	CLEAR_STATE(state)
end

FSM._ClearTransition = function(self, transition)
	CLEAR_TRANSITION(transition)
end

FSM._CustomInitState = function(self, state, ...)
end

FSM._CustomInitTransition = function(self, transition, ...)
end

FSM._GetFSMStateInitParams = function(self, stateTypes, name)
	return stateTypes[name], self.owner[string.format("On%sEnter", name)], self.owner[string.format("On%sExit", name)], self.owner[string.format("On%sUpdate", name)]
end

local result = {}

FSM._GetFSMTransitionInitParams = function(self, stateTypes, transitionTypes, name)
	table.clear(result)

	for word in string.gmatch(name, "([^_]+)") do
		table.insert(result, word)
	end

	return stateTypes[result[1]], stateTypes[result[2]], transitionTypes[name], self.owner[string.format("On%sTo%sCheck", result[1], result[2])], self.owner[string.format("On%sTo%sTransition", result[1], result[2])]
end

FSM.AddStates = function(self, stateTypes)
	for name, _ in pairs(stateTypes) do
		self.AddState(self, self._GetFSMStateInitParams(self, stateTypes, name))
	end

	self.stateTypes = stateTypes
end

FSM.AddState = function(self, stateType, OnEnter, OnExit, OnUpdate, ...)
	if self.states[stateType] then
		print_error("向状态机内重复添加状态, stateType = ", stateType)

		return
	end

	local state = self:_GetStateFromPool()
	state.SType = stateType
	state.OnEnter = OnEnter or state.OnEnter
	state.OnExit = OnExit or state.OnExit
	state.OnUpdate = OnUpdate

	self:_CustomInitState(state, ...)

	self.states[stateType] = state
end

FSM.AddTransitions = function(self, stateTypes, transitionTypes)
	for name, _ in pairs(transitionTypes) do
		self.AddTransition(self, self._GetFSMTransitionInitParams(self, stateTypes, transitionTypes, name))
	end

	self.transitionTypes = transitionTypes
end

FSM.AddTransition = function(self, from, to, signal, check, transitionFunc, ...)
	if not from or not self.states[from] then
		print_error("不存在的from stateType, stateType = ", from)

		return
	end

	if not to or not self.states[to] then
		print_error("不存在的to stateType, stateType = ", to)

		return
	end

	if not signal then
		print_error("添加状态信号不能为空!")

		return
	end

	self.transitions[from] = self.transitions[from] or {}
	local transition = self:_GetTransitionFromPool()
	transition.TType = signal
	transition.To = to
	transition.Check = check or transition.Check
	transition.OnTransition = transitionFunc or transition.OnTransition

	self:_CustomInitTransition(transition, ...)

	self.transitions[from][signal] = transition
end

FSM.SetOwner = function(self, owner)
	self.owner = owner
end

FSM.SetInitState = function(self, stateType)
	if not self.owner then
		print_error("请传入状态机持有对象，否则回调函数会没有self!")

		return
	end

	if not self.states[stateType] then
		print_error("初始状态不存在, stateType = ", stateType)

		return
	end

	self.currentState = stateType
	self.isInit = true

	self.states[stateType].OnEnter(self.owner)
	self:_CheckUpdate()

	self.__uuid = gFSMManager:RegisterToManager(self)
end

FSM.SendSignalSmart = function(self, state)
	local ok, signal = self.GetSignalSmart(self, state)

	if ok then
		self.SendSignal(self, signal)
	end
end

FSM.SendSignalSmartImmediately = function(self, state)
	local ok, signal = self.GetSignalSmart(self, state)

	if ok then
		self.SendSignalImmediately(self, signal)
	end
end

FSM.GetSignalSmart = function(self, state)
	if not self.isInit then
		print_error("[FSM SendSignalSmart]状态机未初始化!")

		return false, nil
	end

	local _, fromName = table.find(self.stateTypes, self.currentState)
	local _, toName = table.find(self.stateTypes, state)

	if not toName then
		print_error("[FSM SendSignalSmart]目标状态不存在, stateType = ", state)

		return false, nil
	end

	local signalName = fromName .. "_" .. toName
	local signal = self.transitionTypes[signalName]

	if not signal then
		print_error("[FSM SendSignalSmart]不存在transition:" .. signalName)

		return false, nil
	end

	return true, signal
end

FSM.SendSignal = function(self, signal)
	if not self.isInit then
		print_error("状态机未初始化!")

		return
	end

	if not self.transitions[self.currentState] or not self.transitions[self.currentState][signal] then
		print_error("当前状态:" .. self.currentState .. "不存在transition:" .. signal)

		return
	end

	self.nowSignal = signal
end

FSM.SendSignalImmediately = function(self, signal)
	if not self.isInit then
		print_error("状态机未初始化!")

		return
	end

	if not self.transitions[self.currentState] or not self.transitions[self.currentState][signal] then
		print_error("当前状态:" .. self.currentState .. "不存在transition:" .. signal)

		return
	end

	self._HandleSignal(self, signal)
end

FSM._HandleSignal = function(self, signal)
	local transition = self.transitions[self.currentState][signal]

	if transition.To ~= self.currentState then
		return
	end

	if not transition.Check(self.owner) then
		return
	end

	self.nowSignal = nil

	self._DoTransition(self, self.currentState, transition.To, transition)
end

FSM._DoTransition = function(self, from, to, transition)
	self.states[from].OnExit(self.owner)

	if not self.isInit then
		return
	end

	transition.OnTransition(self.owner)

	self.currentState = to

	self.states[to].OnEnter(self.owner)

	if not self.isInit then
		return
	end

	self._CheckUpdate(self)
end

FSM._CheckUpdate = function(self)
	if self.states[self.currentState].OnUpdate then
		self.needUpdate = true
	else
		self.needUpdate = false
	end
end

FSM.GetCurrentState = function(self)
	return self.currentState
end

FSM._Update = function(self)
	if not self.isInit then
		return
	end

	if self.nowSignal then
		self._HandleSignal(self, self.nowSignal)

		return
	end

	if self.needUpdate then
		self.states[self.currentState].OnUpdate(self.owner)
	end
end

FSM.Dispose = function(self)
	gFSMManager:UnRegisterFromManager(self)
	gFSMManager:ReturnToPool(self)

	self.__uuid = -1

	for _, state in pairs(self.states) do
		self._ClearState(self, state)
	end

	for _, stateSet in pairs(self.transitions) do
		for _, transition in pairs(stateSet) do
			self._ClearTransition(self, transition)
		end
	end

	table.clear(self.states)
	table.clear(self.transitions)

	self.owner = nil
	self.currentState = nil
	self.isInit = false
	self.needUpdate = false
	self.nowSignal = nil
end
