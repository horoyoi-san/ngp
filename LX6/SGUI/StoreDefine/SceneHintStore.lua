-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SceneHintStore.lua
-- Decompiled from: 00868_SceneHintStore.lua_f6e6767e380e.luajit

local QueryUnitUtils = LX6.Utils.QueryUnitUtils
C_SceneHintStore = DefClass("C_SceneHintStore", C_SceneHintStore, C_StoreGroup)
GroupName2Class.SceneHintStore = C_SceneHintStore
local M = C_SceneHintStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.GO.gameObject:SetActive(true)
	self:HideAll()
	self:InitMessageEvents()

	self.gpsList = {}
	self.intelligentThrowHasTarget = false
	self.intelligentThrowWorldPos = Vector3.zero
end

M.InitMessageEvents = function(self)
	local msgEvents = {
		[gEventConstants.ADD_SCENE_HINT] = self.CreateAction(self, "AddGPS"),
		[gEventConstants.REMOVE_SCENE_HINT] = self.CreateAction(self, "RemoveGPS"),
		[gEventConstants.UPDATE_SCENE_HINT] = self.CreateAction(self, "UpdateGPS"),
		[gEventConstants.ON_CLIMB_POINT] = self.CreateAction(self, "OnClimbPointChange"),
		[gEventConstants.ON_HIGH_OBSTACLE] = self.CreateAction(self, "OnHighObstacleChange"),
		[gEventConstants.MIND_POWER_INTELLIGENT_SEARCH_CHANGE] = self.CreateAction(self, "OnIntelligentSearchChange")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnLanguageChange = function(self, lang)
end

M.HideAll = function(self)
	self.bindData.feiSuoAttackTem:SetActive(false)
	self.bindData.floorJumpTem:SetActive(false)
	self.bindData.feiSuoTem:SetActive(false)
	self.bindData.responsiveTem:SetActive(false)
	self.bindData.spaceThrowTem:SetActive(false)
	self.bindData.climbWallTem:SetActive(false)
	self.bindData.smartTargetTem:SetActive(false)
end

M.OnCameraUpdate = function(self)
	for i, v in pairs(self.gpsList) do
		self.SetGPSPos(self, v)
	end

	self.UpdateClimbWallTemPos(self)
	self.UpdateSmartTargetPos(self)
end

M.AddGPS = function(self, eventId, data)
	self.UpdateGPSData(self, data)

	if data.GpsType ~= gTaskGpsType.FeiSouAttack then
		gCoreHudUIManager:SetCanFeiSuoAttack(true)
	end
end

M.UpdateGPS = function(self, eventId, data)
	self.UpdateGPSData(self, data)
end

M.RemoveGPS = function(self, eventId, data)
	local go = self.GetGPSGameObject(self, data)

	if go then
		go.SetActive(go, false)

		if data.GpsType ~= gTaskGpsType.FeiSouAttack then
			gCoreHudUIManager:SetCanFeiSuoAttack(false)
		end
	end

	self.gpsList[data.GpsType] = nil
end

M.UpdateGPSData = function(self, data)
	if data.GpsType == gTaskGpsType.FeiSouAttack and data.GpsType == gTaskGpsType.WallUpOverJump and data.GpsType == gTaskGpsType.FeiSuo and data.GpsType == gTaskGpsType.TaskPlayFeiSuo and data.GpsType == gTaskGpsType.SpaceThrow then
		return
	end

	if self.gpsList[data.GpsType] ~= nil then
		self.gpsList[data.GpsType] = {}
	end

	self.gpsList[data.GpsType] = data

	self.SetGPSPos(self, data)
end

M.GetGPSGameObject = function(self, data)
	local gameObject = nil

	if data.GpsType ~= gTaskGpsType.FeiSouAttack then
		gameObject = self.bindData.feiSuoAttackTem
	elseif data.GpsType ~= gTaskGpsType.WallUpOverJump then
		gameObject = self.bindData.floorJumpTem
	elseif data.GpsType ~= gTaskGpsType.FeiSuo then
		gameObject = self.bindData.feiSuoTem
	elseif data.GpsType ~= gTaskGpsType.TaskPlayFeiSuo then
		gameObject = self.bindData.responsiveTem
	elseif data.GpsType ~= gTaskGpsType.SpaceThrow then
		gameObject = self.bindData.spaceThrow
	end

	return gameObject
end

M.SetGPSPos = function(self, data)
	if not data then
		return
	end

	local isShow, gameObject, targetPos = self.IsShowGPS(self, data)

	if not gameObject then
		return
	end

	gameObject.SetActive(gameObject, isShow)

	if not isShow then
		return
	end

	local isInView, pos, eulerZ = self.CalculatePosition(self, targetPos, gameObject)
	gameObject.localPosition = pos

	self.SetGPSRot(self, data, isInView, eulerZ)
end

M.IsShowGPS = function(self, data)
	local isShow = false
	local gameObject = nil
	local targetPos = data.TargetPos

	if data.GpsType ~= gTaskGpsType.FeiSouAttack then
		gameObject = self.bindData.feiSuoAttackTem
		isShow = not data.ForceHide

		if isShow then
			targetPos = self.GetFeiSuoAttackTargetPos(self, data)
		end
	elseif data.GpsType ~= gTaskGpsType.WallUpOverJump then
		gameObject = self.bindData.floorJumpTem
		isShow = data.CanShow == 0
	elseif data.GpsType ~= gTaskGpsType.FeiSuo then
		gameObject = self.bindData.feiSuoTem
		isShow = not data.ForceHide
	elseif data.GpsType ~= gTaskGpsType.TaskPlayFeiSuo then
		gameObject = self.bindData.responsiveTem
		isShow = data.show

		if isShow and not gCS.LuaUtils.IsNull(data.TargetTrans) then
			targetPos = data.TargetTrans.position
		end
	elseif data.GpsType ~= gTaskGpsType.SpaceThrow then
		gameObject = self.bindData.spaceThrowTem
		isShow = data.show

		if isShow then
			targetPos = data.GetNearPos(data.startPos1, data.startPos2)
		end
	end

	return isShow, gameObject, targetPos
end

M.CalculatePosition = function(self, targetPos, gameObject)
	local vecTem = Vector3.zero
	local value = Vector3.zero
	local defaultPos = targetPos or value

	value:Set(defaultPos.x, defaultPos.y, defaultPos.z)
	vecTem:Set(value.x, value.y, value.z)

	local isInView, x, y, eulerZ = QueryUnitUtils.GetHintsHudStoreEllipseInfoRect(vecTem, gameObject.parentWidget.rectTransform, false, _, _, _)

	return isInView, Vector3.New(x, y, 0), eulerZ
end

M.GetFeiSuoAttackTargetPos = function(self, data)
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

M.SetGPSRot = function(self, data, isInView, eulerZ)
	if data.GpsType ~= gTaskGpsType.FeiSuo then
		if isInView then
			self.bindData.feiSuoRotation:SetActive(false)
		else
			self.bindData.feiSuoRotation:SetActive(true)

			self.bindData.feiSuoRotation.rectTransform.localEulerAngles = Vector3.New(0, 0, eulerZ)
		end
	elseif data.GpsType ~= gTaskGpsType.TaskPlayFeiSuo then
		if isInView then
			self.bindData.responsiveTemRot:SetActive(false)
		else
			self.bindData.responsiveTemRot:SetActive(true)

			self.bindData.responsiveTemRot.rectTransform.localEulerAngles = Vector3.New(0, 0, eulerZ)
		end
	elseif data.GpsType ~= gTaskGpsType.SpaceThrow then
		if isInView then
			self.bindData.spaceThrowTemRot:SetActive(false)
		else
			self.bindData.spaceThrowTemRot:SetActive(true)

			self.bindData.spaceThrowTemRot.rectTransform.localEulerAngles = Vector3.New(0, 0, eulerZ)
		end
	end
end

M.OnClimbPointChange = function(self, eventId, worldPos)
	self.highObstaclePos = worldPos
end

M.OnHighObstacleChange = function(self, eventId, needShow)
	if self.highObstaclePos then
		self.highObstaclePos = nil

		self.bindData.climbWallTem:SetActive(false)
	end
end

M.UpdateClimbWallTemPos = function(self)
	if not self.highObstaclePos then
		return
	end

	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(self.highObstaclePos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.climbWallTem.parentWidget.rectTransform, Vector3.New(x, y, 0))

	self.bindData.climbWallTem:SetActive(true)

	self.bindData.climbWallTem.localPosition = Vector3.New(UIPos.x, UIPos.y, 0)
end

M.OnIntelligentSearchChange = function(self, eventId, hasTarget, worldPos, is2D)
	self.intelligentThrowHasTarget = hasTarget and is2D

	if hasTarget and worldPos then
		self.intelligentThrowWorldPos = worldPos
	end

	self.bindData.smartTargetTem:SetActive(self.intelligentThrowHasTarget)
end

M.UpdateSmartTargetPos = function(self)
	if not self.intelligentThrowHasTarget then
		return
	end

	local pos = self.intelligentThrowWorldPos
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.smartTargetTem.parentWidget.rectTransform, Vector3.New(x, y, 0))
	self.bindData.smartTargetTem.localPosition = Vector3.New(UIPos.x, UIPos.y, 0)
end
