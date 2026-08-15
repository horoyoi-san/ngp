MapSubSystem_Doctor = DefClass("MapSubSystem_Doctor", MapSubSystem_Doctor, MapSubSystemBase)
local M = MapSubSystem_Doctor

function M:OnInit()
	self._patients = {}

	self:InitEventHandlers()
end

function M:InitEventHandlers()
	self.eventHandlers = {
		[gEventConstants.MINIMAP_PATIENT_APPEAR] = function (eventId, agentId)
			self:AddPatientElement(agentId)
		end,
		[gEventConstants.MINIMAP_PATIENT_HIDE] = function (eventId, agentId)
			self:RemovePatientElement(agentId)
		end,
		[gEventConstants.UNIT_DESTROY] = function (eventId, agentId)
			self:RemovePatientElement(agentId)
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.Reconnect then
		for _, info in pairs(self._patients) do
			info.mapElement:Dispose()
		end

		table.clear(self._patients)
	end
end

function M:AddPatientElement(agentId)
	if type(agentId) == "number" then
		agentId = ulong.new(agentId, 0)
	end

	if self._patients[agentId] then
		return
	end

	local info = {}
	local unit = gCS.SceneDataMgr.GetUnit(agentId)

	if L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
		return
	end

	local element = MapElement.CreateLegacy(EMapElementType.Patient, agentId, EMapSubSystemType.Doctor, EMapViewMask.MiniMap, gRaidDataManager.RaidId, 0)
	element.mData.name = "PatientUnit" .. ulong.tostring(agentId)
	element.mData.sIconId = LTConfig.DoctorConfig.DiseaseSGUIid

	element:SetPosition(unit.LocalPosition)
	element:SetVisible(true)

	info.mapElement = element
	self._patients[agentId] = info
end

function M:RemovePatientElement(agentId)
	if type(agentId) == "number" then
		agentId = ulong.new(agentId, 0)
	end

	if not self._patients[agentId] then
		return
	end

	local info = self._patients[agentId]

	if info.mapElement then
		print("MapSubSystem_Doctor:RemovePatientElement", agentId)
		info.mapElement:Dispose()

		info.mapElement = nil
	end

	self._patients[agentId] = nil
end

return M
