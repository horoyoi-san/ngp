local QueryUnitUtils = LX6.Utils.QueryUnitUtils
C_SceneHintStore = DefClass("C_SceneHintStore", C_SceneHintStore, C_StoreGroup)
GroupName2Class.SceneHintStore = C_SceneHintStore
local M = C_SceneHintStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.GO.gameObject:SetActive(true)
	self:HideAll()
	self:InitMessageEvents()

	self.gpsList = {}
end

function M:InitMessageEvents()
	local msgEvents = {
		[gEventConstants.Add_GPS] = self:CreateAction("AddGPS"),
		[gEventConstants.REMOVE_GPS] = self:CreateAction("RemoveGPS"),
		[gEventConstants.UPDATE_GPS] = self:CreateAction("UpdateGPS"),
		[gEventConstants.UPDATE_FEISUO_GPS] = self:CreateAction("UpdateFeiSuoGPS")
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:HideAll()
	self.bindData.feiSuoAttackTem:SetActive(false)
	self.bindData.floorJumpTem:SetActive(false)
	self.bindData.feiSuoTem:SetActive(false)
	self.bindData.responsiveTem:SetActive(false)
	self.bindData.spaceThrowTem:SetActive(false)
end

function M:OnCameraUpdate()
	for i, v in pairs(self.gpsList) do
		self:SetGPSPos(v)
	end
end

function M:AddGPS(eventId, data)
	self:UpdateGPSData(data)

	if data.GpsType == gTaskGpsType.FeiSouAttack then
		gCoreHudUIManager:SetCanFeiSuoAttack(true)
	end
end

function M:UpdateGPS(eventId, data)
	self:UpdateGPSData(data)
end

function M:RemoveGPS(eventId, data)
	local go = self:GetGPSGameObject(data)

	if go then
		go:SetActive(false)

		if data.GpsType == gTaskGpsType.FeiSouAttack then
			gCoreHudUIManager:SetCanFeiSuoAttack(false)
		end
	end

	self.gpsList[data.GpsType] = nil
end

function M:UpdateFeiSuoGPS(eventId, data)
	self:UpdateGPSData(data)
	self:SetGPSPos(data)
end

function M:UpdateGPSData(data)
	if data.GpsType ~= gTaskGpsType.FeiSouAttack and data.GpsType ~= gTaskGpsType.WallUpOverJump and data.GpsType ~= gTaskGpsType.FeiSuo and data.GpsType ~= gTaskGpsType.TaskPlayFeiSuo and data.GpsType ~= gTaskGpsType.SpaceThrow then
		return
	end

	if self.gpsList[data.GpsType] == nil then
		self.gpsList[data.GpsType] = {}
	end

	self.gpsList[data.GpsType] = data

	self:SetGPSPos(data)
end

function M:GetGPSGameObject(data)
	local gameObject = nil

	if data.GpsType == gTaskGpsType.FeiSouAttack then
		gameObject = self.bindData.feiSuoAttackTem
	elseif data.GpsType == gTaskGpsType.WallUpOverJump then
		gameObject = self.bindData.floorJumpTem
	elseif data.GpsType == gTaskGpsType.FeiSuo then
		gameObject = self.bindData.feiSuoTem
	elseif data.GpsType == gTaskGpsType.TaskPlayFeiSuo then
		gameObject = self.bindData.responsiveTem
	elseif data.GpsType == gTaskGpsType.SpaceThrow then
		gameObject = self.bindData.spaceThrow
	end

	return gameObject
end

function M:SetGPSPos(data)
	if not data then
		return
	end

	local isShow, gameObject, targetPos = self:IsShowGPS(data)

	if not gameObject then
		return
	end

	gameObject:SetActive(isShow)

	if not isShow then
		return
	end

	local isInView, pos, eulerZ = self:CalculatePosition(targetPos, gameObject)
	gameObject.localPosition = pos

	self:SetGPSRot(data, isInView, eulerZ)
end

function M:IsShowGPS(data)
	local isShow = false
	local gameObject = nil
	local targetPos = data.TargetPos

	if data.GpsType == gTaskGpsType.FeiSouAttack then
		gameObject = self.bindData.feiSuoAttackTem
		isShow = not data.ForceHide

		if isShow then
			targetPos = self:GetFeiSuoAttackTargetPos(data)
		end
	elseif data.GpsType == gTaskGpsType.WallUpOverJump then
		gameObject = self.bindData.floorJumpTem
		isShow = data.CanShow ~= 0
	elseif data.GpsType == gTaskGpsType.FeiSuo then
		gameObject = self.bindData.feiSuoTem
		isShow = not data.ForceHide
	elseif data.GpsType == gTaskGpsType.TaskPlayFeiSuo then
		gameObject = self.bindData.responsiveTem
		isShow = data.show

		if isShow and not gCS.LuaUtils.IsNull(data.TargetTrans) then
			targetPos = data.TargetTrans.position
		end
	elseif data.GpsType == gTaskGpsType.SpaceThrow then
		gameObject = self.bindData.spaceThrowTem
		isShow = data.show

		if isShow then
			targetPos = data.GetNearPos(data.startPos1, data.startPos2)
		end
	end

	return isShow, gameObject, targetPos
end

function M:CalculatePosition(targetPos, gameObject)
	local vecTem = Vector3.zero
	local value = Vector3.zero
	local defaultPos = targetPos or value

	value:Set(defaultPos.x, defaultPos.y, defaultPos.z)
	vecTem:Set(value.x, value.y, value.z)

	local isInView, x, y, eulerZ = QueryUnitUtils.GetHintsHudStoreEllipseInfoRect(vecTem, gameObject.parentWidget.rectTransform, false, _, _, _)

	return isInView, Vector3.New(x, y, 0), eulerZ
end

function M:GetFeiSuoAttackTargetPos(data)
	if not data.UnitPid then
		return data.TargetPos
	end

	local unit = gCS.SceneDataMgr.GetUnit(data.UnitPid)

	if not unit or not unit.CanUseRes then
		return data.TargetPos
	end

	local isTargetPos, x, y, z = gCS.UnitSlotFollower.TryGetTargetPos(unit, 4, 0, 0, 0, nil)

	if isTargetPos then
		return Vector3.New(x, y, z)
	end

	if data.UseFeiSuoPoint then
		if not unit.ModelSlot or not unit.ModelSlot.feisuoPoint then
			print_error("@shenrui 策划配置有误，飞索点没有配ModelSlot或者feisuoPoint！")
		end

		data.UnitTransform = unit.ModelSlot.feisuoPoint
	else
		data.UnitTransform = unit.ModelSlot.headSlot
	end

	if data.UnitTransform and data.UnitTransform.position then
		return data.UnitTransform.position
	end

	return data.TargetPos
end

function M:SetGPSRot(data, isInView, eulerZ)
	if data.GpsType == gTaskGpsType.FeiSuo then
		if isInView then
			self.bindData.feiSuoRotation:SetActive(false)
		else
			self.bindData.feiSuoRotation:SetActive(true)

			self.bindData.feiSuoRotation.rectTransform.localEulerAngles = Vector3.New(0, 0, eulerZ)
		end
	elseif data.GpsType == gTaskGpsType.TaskPlayFeiSuo then
		if isInView then
			self.bindData.responsiveTemRot:SetActive(false)
		else
			self.bindData.responsiveTemRot:SetActive(true)

			self.bindData.responsiveTemRot.rectTransform.localEulerAngles = Vector3.New(0, 0, eulerZ)
		end
	elseif data.GpsType == gTaskGpsType.SpaceThrow then
		if isInView then
			self.bindData.spaceThrowTemRot:SetActive(false)
		else
			self.bindData.spaceThrowTemRot:SetActive(true)

			self.bindData.spaceThrowTemRot.rectTransform.localEulerAngles = Vector3.New(0, 0, eulerZ)
		end
	end
end
