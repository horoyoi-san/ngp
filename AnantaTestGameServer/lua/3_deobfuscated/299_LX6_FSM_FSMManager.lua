C_FSMManager = DefClass("C_FSMManager", C_FSMManager)
local FSMManager = C_FSMManager
local FSMPool = {}
local INCREASE_ID = -1

function FSMManager:ctor()
	self.managedFSMList = {}
end

function FSMManager:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, function (eventId, switchType)
		self:OnBeforeSwitchScene(switchType)
	end)
end

function FSMManager:GetFSM(owner, FSMType)
	if FSMType == gFSMConst.FSMType.Normal then
		return self:_GetFSMFromPool(FSMType) or C_FSM.new(FSMType)
	else
		local fsm = self:_GetFSMFromPool(gFSMConst.FSMType.Normal)

		if fsm then
			fsm:SetOwner(owner)

			return fsm
		else
			return C_FSM.new(gFSMConst.FSMType.Normal, owner)
		end
	end
end

function FSMManager:_GetFSMFromPool(FSMType)
	if FSMPool[FSMType] and next(FSMPool[FSMType]) then
		return table.remove(FSMPool[FSMType])
	else
		return nil
	end
end

function FSMManager:RegisterToManager(FSM)
	table.insert(self.managedFSMList, FSM)
	self:RefreshDynamicUpdate()

	INCREASE_ID = INCREASE_ID + 1

	return INCREASE_ID
end

function FSMManager:UnRegisterFromManager(FSM)
	local index = nil

	for i, mFSM in ipairs(self.managedFSMList) do
		if mFSM.__uuid == FSM.__uuid then
			index = i
		end
	end

	if index then
		table.remove(self.managedFSMList, index)
		self:RefreshDynamicUpdate()
	end
end

function FSMManager:ReturnToPool(FSM)
	local FSMType = FSM.__FSMType
	FSMPool[FSMType] = FSMPool[FSMType] or {}

	table.insert(FSMPool[FSMType], FSM)
end

function FSMManager:RefreshDynamicUpdate()
	if table.isNilOrEmpty(self.managedFSMList) then
		gLuaClient:UnregisterDynamicUpdate("gFSMManager")
	else
		gLuaClient:RegisterDynamicUpdate("gFSMManager", self)
	end
end

function FSMManager:OnUpdate()
	for _, FSM in ipairs(self.managedFSMList) do
		FSM:_Update()
	end
end

function FSMManager:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:ClearAll()
	end
end

function FSMManager:ClearAll()
	table.clear(self.managedFSMList)

	INCREASE_ID = -1

	table.clear(FSMPool)
	self:RefreshDynamicUpdate()
end

gFSMManager = gFSMManager or C_FSMManager.new()
