C_FSM = DefClass("C_FSM", C_FSM)
local FSM = C_FSM

local function EMPTY_FUNC()
	return
end

local function DEFAULT_CHECK()
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

local function GET_STATE_FROM_POOL()
	return #STATE_POOL > 0 and table.remove(STATE_POOL) or table.clone(STATE_TEMPLATE)
end

local function CLEAR_STATE(state)
	if not state then
		return
	end

	state.SType = nil
	state.OnEnter = EMPTY_FUNC
	state.OnExit = EMPTY_FUNC
	state.OnUpdate = nil

	table.insert(STATE_POOL, state)
end

local function GET_TRANSITION_FROM_POOL()
	return #TRANSITION_POOL > 0 and table.remove(TRANSITION_POOL) or table.clone(TRANSITION_TEMPLATE)
end

local function CLEAR_TRANSITION(transition)
	if not transition then
		return
	end

	transition.To = nil
	transition.Check = DEFAULT_CHECK
	transition.OnTransition = EMPTY_FUNC

	table.insert(TRANSITION_POOL, transition)
end

function FSM:ctor(FSMType, owner)
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

function FSM:_GetStateFromPool()
	return GET_STATE_FROM_POOL()
end

function FSM:_GetTransitionFromPool()
	return GET_TRANSITION_FROM_POOL()
end

function FSM:_ClearState(state)
	CLEAR_STATE(state)
end

function FSM:_ClearTransition(transition)
	CLEAR_TRANSITION(transition)
end

function FSM:_CustomInitState(state, ...)
	return
end

function FSM:_CustomInitTransition(transition, ...)
	return
end

function FSM:_GetFSMStateInitParams(stateTypes, name)
	return stateTypes[name], self.owner[string.format("On%sEnter", name)], self.owner[string.format("On%sExit", name)], self.owner[string.format("On%sUpdate", name)]
end

local result = {}

function FSM:_GetFSMTransitionInitParams(stateTypes, transitionTypes, name)
	table.clear(result)

	for word in string.gmatch(name, "([^_]+)") do
		table.insert(result, word)
	end

	return stateTypes[result[1]], stateTypes[result[2]], transitionTypes[name], self.owner[string.format("On%sTo%sCheck", result[1], result[2])], self.owner[string.format("On%sTo%sTransition", result[1], result[2])]
end

function FSM:AddStates(stateTypes)
	for name, _ in pairs(stateTypes) do
		self:AddState(self:_GetFSMStateInitParams(stateTypes, name))
	end

	self.stateTypes = stateTypes
end

function FSM:AddState(stateType, OnEnter, OnExit, OnUpdate, ...)
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

function FSM:AddTransitions(stateTypes, transitionTypes)
	for name, _ in pairs(transitionTypes) do
		self:AddTransition(self:_GetFSMTransitionInitParams(stateTypes, transitionTypes, name))
	end

	self.transitionTypes = transitionTypes
end

function FSM:AddTransition(from, to, signal, check, transitionFunc, ...)
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

function FSM:SetOwner(owner)
	self.owner = owner
end

function FSM:SetInitState(stateType)
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

function FSM:SendSignalSmart(state)
	local ok, signal = self:GetSignalSmart(state)

	if ok then
		self:SendSignal(signal)
	end
end

function FSM:SendSignalSmartImmediately(state)
	local ok, signal = self:GetSignalSmart(state)

	if ok then
		self:SendSignalImmediately(signal)
	end
end

function FSM:GetSignalSmart(state)
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

function FSM:SendSignal(signal)
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

function FSM:SendSignalImmediately(signal)
	if not self.isInit then
		print_error("状态机未初始化!")

		return
	end

	if not self.transitions[self.currentState] or not self.transitions[self.currentState][signal] then
		print_error("当前状态:" .. self.currentState .. "不存在transition:" .. signal)

		return
	end

	self:_HandleSignal(signal)
end

function FSM:_HandleSignal(signal)
	local transition = self.transitions[self.currentState][signal]

	if transition.To == self.currentState then
		return
	end

	if not transition.Check(self.owner) then
		return
	end

	self.nowSignal = nil

	self:_DoTransition(self.currentState, transition.To, transition)
end

function FSM:_DoTransition(from, to, transition)
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

	self:_CheckUpdate()
end

function FSM:_CheckUpdate()
	if self.states[self.currentState].OnUpdate then
		self.needUpdate = true
	else
		self.needUpdate = false
	end
end

function FSM:GetCurrentState()
	return self.currentState
end

function FSM:_Update()
	if not self.isInit then
		return
	end

	if self.nowSignal then
		self:_HandleSignal(self.nowSignal)

		return
	end

	if self.needUpdate then
		self.states[self.currentState].OnUpdate(self.owner)
	end
end

function FSM:Dispose()
	gFSMManager:UnRegisterFromManager(self)
	gFSMManager:ReturnToPool(self)

	self.__uuid = -1

	for _, state in pairs(self.states) do
		self:_ClearState(state)
	end

	for _, stateSet in pairs(self.transitions) do
		for _, transition in pairs(stateSet) do
			self:_ClearTransition(transition)
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
