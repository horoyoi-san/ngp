-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AccessoriesEditPanelStore.lua
-- Decompiled from: 01587_AccessoriesEditPanelStore.lua_80cae551e056.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionEditConfig = LTConfig.FashionEditConfig
local UXVector3 = UX.Game.UXVector3
local MessageConfig = LTConfig.MessageConfig
local FashionBaseConfig = LTConfig.FashionBaseConfig
C_AccessoriesEditPanelStore = DefClass("C_AccessoriesEditPanelStore", C_AccessoriesEditPanelStore, C_StoreGroup)
GroupName2Class.AccessoriesEditPanelStore = C_AccessoriesEditPanelStore
local M = C_AccessoriesEditPanelStore

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.resetBtn.luaClick = self.CreateAction(self, "OnResetBtnClick")
	self.bindData.saveBtn.luaClick = self.CreateAction(self, "OnSaveBtnClick")
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if data and data.spiritContext then
		self.spiritContext = data.spiritContext
	else
		self.spiritContext = gDressManager:GetSpiritContext()
	end

	self.isDummyMode = data and data.isDummyMode or false
	self.skipMovementState = data and data.skipMovementState or false
	self.scaleSliderDrag = 0
	self.fbOffsetSliderDrag = 0
	self.udOffsetSliderDrag = 0
	self.lrOffsetSliderDrag = 0
	self.lrRotateSliderDrag = 0
	self.fbRotateSliderDrag = 0
	self.udRotateSliderDrag = 0
	self.saveData = {}
	self.fashionId = data and data.fashionId
	self.callBack = data and data.callBack
	self.fashionType = data and data.fashionType or 0
	self.contentStore = gStoreManager:GetStoreGroup("AccessoriesEditContentStore"):GetStoreByWidget(self.bindData.scroll.content)
	self.contentStore.scaleSlider.luaValueChanged = self:CreateAction("OnScaleSliderDrag")
	self.contentStore.lrOffsetSlider.luaValueChanged = self:CreateAction("OnLROffsetSliderDrag")
	self.contentStore.fbOffsetSlider.luaValueChanged = self:CreateAction("OnFBOffsetSliderDrag")
	self.contentStore.udOffsetSlider.luaValueChanged = self:CreateAction("OnUDOffsetSliderDrag")
	self.contentStore.lrRotateSlider.luaValueChanged = self:CreateAction("OnLRRotateSliderDrag")
	self.contentStore.fbRotateSlider.luaValueChanged = self:CreateAction("OnFBRotateSliderDrag")
	self.contentStore.udRotateSlider.luaValueChanged = self:CreateAction("OnUDRotateSliderDrag")
	self.contentStore.scaleLButton.luaPress = self:CreateActionWithArgs("OnScaleSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = -1
	})
	self.contentStore.scaleLButton.luaRelease = self:CreateAction("OnScaleSliderDragRelease")
	self.contentStore.scaleRButton.luaPress = self:CreateActionWithArgs("OnScaleSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = 1
	})
	self.contentStore.scaleRButton.luaRelease = self:CreateAction("OnScaleSliderDragRelease")
	self.contentStore.fbOffsetLButton.luaPress = self:CreateActionWithArgs("OnFBOffsetSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = -1
	})
	self.contentStore.fbOffsetLButton.luaRelease = self:CreateAction("OnFBOffsetSliderDragRelease")
	self.contentStore.fbOffsetRButton.luaPress = self:CreateActionWithArgs("OnFBOffsetSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = 1
	})
	self.contentStore.fbOffsetRButton.luaRelease = self:CreateAction("OnFBOffsetSliderDragRelease")
	self.contentStore.lrOffsetLButton.luaPress = self:CreateActionWithArgs("OnLROffsetSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = -1
	})
	self.contentStore.lrOffsetLButton.luaRelease = self:CreateAction("OnLROffsetSliderDragRelease")
	self.contentStore.lrOffsetRButton.luaPress = self:CreateActionWithArgs("OnLROffsetSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = 1
	})
	self.contentStore.lrOffsetRButton.luaRelease = self:CreateAction("OnLROffsetSliderDragRelease")
	self.contentStore.udOffsetLButton.luaPress = self:CreateActionWithArgs("OnUDOffsetSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = -1
	})
	self.contentStore.udOffsetLButton.luaRelease = self:CreateAction("OnUDOffsetSliderDragRelease")
	self.contentStore.udOffsetRButton.luaPress = self:CreateActionWithArgs("OnUDOffsetSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = 1
	})
	self.contentStore.udOffsetRButton.luaRelease = self:CreateAction("OnUDOffsetSliderDragRelease")
	self.contentStore.rotateLRLButton.luaPress = self:CreateActionWithArgs("OnLRRotateSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = -1
	})
	self.contentStore.rotateLRLButton.luaRelease = self:CreateAction("OnLRRotateSliderDragRelease")
	self.contentStore.rotateLRRButton.luaPress = self:CreateActionWithArgs("OnLRRotateSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = 1
	})
	self.contentStore.rotateLRRButton.luaRelease = self:CreateAction("OnLRRotateSliderDragRelease")
	self.contentStore.rotateFBLButton.luaPress = self:CreateActionWithArgs("OnFBRotateSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = -1
	})
	self.contentStore.rotateFBLButton.luaRelease = self:CreateAction("OnFBRotateSliderDragRelease")
	self.contentStore.rotateFBRButton.luaPress = self:CreateActionWithArgs("OnFBRotateSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = 1
	})
	self.contentStore.rotateFBRButton.luaRelease = self:CreateAction("OnFBRotateSliderDragRelease")
	self.contentStore.rotateUDLButton.luaPress = self:CreateActionWithArgs("OnUDRotateSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = -1
	})
	self.contentStore.rotateUDLButton.luaRelease = self:CreateAction("OnUDRotateSliderDragRelease")
	self.contentStore.rotateUDRButton.luaPress = self:CreateActionWithArgs("OnUDRotateSliderDragPress", {
		["\\xaa\\xb5\\x9dk2\\xeb6"] = 1
	})
	self.contentStore.rotateUDRButton.luaRelease = self:CreateAction("OnUDRotateSliderDragRelease")

	self:InitDefaultInfo()

	local cameraParams = {
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond
	}

	if not self.skipMovementState then
		cameraParams.movementState = LX6.Cinemachine.EMovementCamState.TryFashion
	end

	cameraParams.unitProvider = function()
		return self.spiritContext.unit
	end

	gDressStack:SetDressStack(self.m_Id, true, cameraParams)
end

M.InitDefaultInfo = function(self)
	local modelId = self.spiritContext.unit.ClientData.ModelId
	local modelCfg = LTConfig.GeneralModelConfig.GetConfig(modelId)

	if modelCfg ~= nil then
		print_error("@libiao01 模型配表找不到，问题很严重！暂时换成空模型", "modelId = ", modelId, gCS.MyPlayerManager.PlayerUnit.ClientData.Name, "单位 配表ID ", gCS.MyPlayerManager.PlayerUnit.ClientData.SubType)

		modelCfg = LTConfig.GeneralModelConfig.GetConfig(LTConfig.GeneralModelConfig.EmptyModel)
		modelId = LTConfig.GeneralModelConfig.EmptyModel
	end

	local bodyType = modelCfg.BodyType
	local FashionBaseCfg = FashionBaseConfig.GetConfig(bodyType)

	if FashionBaseCfg then
		self.cameraOffset = FashionBaseCfg.CameraOffset
	end

	local cfg = FashionConfig.GetConfig(self.fashionId)

	if not cfg then
		print_warn("当前时装在配表中未找到,时装id来源于服务器PlayerFashionsInfo.FashionInfoDict   fashionId = " .. self.fashionId)

		return
	end

	self.defaultEditInfo = {}
	local hasEditInfo = false
	local wearFashionEditInfoList = gDressManager:GetCurrentSpritWearEditFashionInfoList(self.spiritContext)

	if wearFashionEditInfoList then
		for t = 0, wearFashionEditInfoList.Count - 1 do
			if wearFashionEditInfoList[t].FashionId ~= self.fashionId then
				hasEditInfo = true
				self.defaultEditInfo.Scale = wearFashionEditInfoList[t].Scale
				self.defaultEditInfo.LROffsetRadius = wearFashionEditInfoList[t].Offset.X
				self.defaultEditInfo.FBOffsetRadius = wearFashionEditInfoList[t].Offset.Y
				self.defaultEditInfo.UDOffsetRadius = wearFashionEditInfoList[t].Offset.Z
				self.defaultEditInfo.LRRotation = wearFashionEditInfoList[t].Rotation.X
				self.defaultEditInfo.FBRotation = wearFashionEditInfoList[t].Rotation.Y
				self.defaultEditInfo.UDRotation = wearFashionEditInfoList[t].Rotation.Z
				self.defaultEditInfo.Offset = UXVector3.New(self.defaultEditInfo.LROffsetRadius, self.defaultEditInfo.FBOffsetRadius, self.defaultEditInfo.UDOffsetRadius)
				self.defaultEditInfo.Rotation = UXVector3.New(self.defaultEditInfo.LRRotation, self.defaultEditInfo.FBRotation, self.defaultEditInfo.UDRotation)

				break
			end
		end
	end

	if not hasEditInfo then
		self.defaultEditInfo.Scale = FashionConfig.FashionEditDefaultParamType1[1]
		self.defaultEditInfo.LROffsetRadius = FashionConfig.FashionEditDefaultParamType1[2]
		self.defaultEditInfo.FBOffsetRadius = FashionConfig.FashionEditDefaultParamType1[2]
		self.defaultEditInfo.UDOffsetRadius = FashionConfig.FashionEditDefaultParamType1[2]
		self.defaultEditInfo.LRRotation = FashionConfig.FashionEditDefaultParamType1[3]
		self.defaultEditInfo.FBRotation = FashionConfig.FashionEditDefaultParamType1[4]
		self.defaultEditInfo.UDRotation = FashionConfig.FashionEditDefaultParamType1[5]
		self.defaultEditInfo.Offset = UXVector3.New(self.defaultEditInfo.LROffsetRadius, self.defaultEditInfo.FBOffsetRadius, self.defaultEditInfo.UDOffsetRadius)
		self.defaultEditInfo.Rotation = UXVector3.New(self.defaultEditInfo.LRRotation, self.defaultEditInfo.FBRotation, self.defaultEditInfo.UDRotation)
	end

	self.saveData.scale = self.defaultEditInfo.Scale
	self.saveData.offset = Vector3.New(self.defaultEditInfo.LROffsetRadius, self.defaultEditInfo.FBOffsetRadius, self.defaultEditInfo.UDOffsetRadius)
	self.saveData.rotate = Vector3.New(self.defaultEditInfo.LRRotation, self.defaultEditInfo.FBRotation, self.defaultEditInfo.UDRotation)
	local editCfg = FashionEditConfig.GetConfig(cfg.EditId)

	if editCfg then
		self.contentStore.scaleSlider.minValue = editCfg.MinScale
		self.contentStore.scaleSlider.maxValue = editCfg.MaxScale
		self.contentStore.lrOffsetSlider.minValue = editCfg.MinOffset.X
		self.contentStore.lrOffsetSlider.maxValue = editCfg.MaxOffset.X
		self.contentStore.fbOffsetSlider.minValue = editCfg.MinOffset.Y
		self.contentStore.fbOffsetSlider.maxValue = editCfg.MaxOffset.Y
		self.contentStore.udOffsetSlider.minValue = editCfg.MinOffset.Z
		self.contentStore.udOffsetSlider.maxValue = editCfg.MaxOffset.Z
		self.contentStore.lrRotateSlider.minValue = editCfg.MinRotation.X
		self.contentStore.lrRotateSlider.maxValue = editCfg.MaxRotation.X
		self.contentStore.fbRotateSlider.minValue = editCfg.MinRotation.Y
		self.contentStore.fbRotateSlider.maxValue = editCfg.MaxRotation.Y
		self.contentStore.udRotateSlider.minValue = editCfg.MinRotation.Z
		self.contentStore.udRotateSlider.maxValue = editCfg.MaxRotation.Z
	end

	self.contentStore.scaleSlider.value = self.defaultEditInfo.Scale
	self.contentStore.lrOffsetSlider.value = self.defaultEditInfo.LROffsetRadius
	self.contentStore.fbOffsetSlider.value = self.defaultEditInfo.FBOffsetRadius
	self.contentStore.udOffsetSlider.value = self.defaultEditInfo.UDOffsetRadius
	self.contentStore.lrRotateSlider.value = self.defaultEditInfo.LRRotation
	self.contentStore.fbRotateSlider.value = self.defaultEditInfo.FBRotation
	self.contentStore.udRotateSlider.value = self.defaultEditInfo.UDRotation
end

M.OnUpdate = function(self)
	self.OnSetSliderUpdate(self)
end

M.OnClose = function(self)
	if self.callBack then
		self.callBack()
	end

	gDressStack:SetDressStack(self.m_Id, false)
end

M.OnBackBtnClick = function(self)
	if table.isNilOrEmpty(self.defaultEditInfo) then
		print_error(" 没有默认编辑信息 fashionId = " .. self.fashionId)

		return
	end

	local editInfoList = {
		FashionId = self.fashionId,
		Scale = self.contentStore.scaleSlider.value,
		Offset = UXVector3.New(self.contentStore.lrOffsetSlider.value, self.contentStore.fbOffsetSlider.value, self.contentStore.udOffsetSlider.value),
		Rotation = UXVector3.New(self.contentStore.lrRotateSlider.value, self.contentStore.fbRotateSlider.value, self.contentStore.udRotateSlider.value)
	}
	self.editInfoList = editInfoList

	if not self.CompareIsEdited(self, self.editInfoList) then
		slot2 = gDisplayMessageMgr

		slot2:ShowMessage(MessageConfig.FashionPropEditExitReconfirm, function ()
			self.saveData.scale = self.defaultEditInfo.Scale
			self.saveData.offset = Vector3.New(self.defaultEditInfo.LROffsetRadius, self.defaultEditInfo.FBOffsetRadius, self.defaultEditInfo.UDOffsetRadius)
			self.saveData.rotate = Vector3.New(self.defaultEditInfo.LRRotation, self.defaultEditInfo.FBRotation, self.defaultEditInfo.UDRotation)

			gDressManager:DoChange(self.fashionId, self.saveData.rotate, self.saveData.offset, self.saveData.scale, self.spiritContext)
			gPanelManager:Close(gPanelId.S_ACCESSORIES_EDIT)
		end)
	else
		gPanelManager:Close(gPanelId.S_ACCESSORIES_EDIT)
	end
end

M.OnResetBtnClick = function(self)
	self.contentStore.scaleSlider.value = 1
	self.contentStore.lrOffsetSlider.value = 0
	self.contentStore.fbOffsetSlider.value = 0
	self.contentStore.udOffsetSlider.value = 0
	self.contentStore.lrRotateSlider.value = 0
	self.contentStore.fbRotateSlider.value = 0
	self.contentStore.udRotateSlider.value = 0
end

M.OnSaveBtnClick = function(self)
	local Offset = UXVector3.New(self.contentStore.lrOffsetSlider.value, self.contentStore.fbOffsetSlider.value, self.contentStore.udOffsetSlider.value)
	local Rotation = UXVector3.New(self.contentStore.lrRotateSlider.value, self.contentStore.fbRotateSlider.value, self.contentStore.udRotateSlider.value)

	gDressManager:SaveFashionListEdit(self.fashionId, self.contentStore.scaleSlider.value, Offset, Rotation, self.spiritContext)

	local stepEditInfoList = {
		FashionId = self.fashionId,
		Scale = self.contentStore.scaleSlider.value,
		Offset = Offset,
		Rotation = Rotation
	}

	gDressManager:PushSnapshot(self.spiritContext, self.fashionId, nil)
	self:InitDefaultInfo()
	gDisplayMessageMgr:ShowMessage(MessageConfig.FashionPropEditSaveSuccess)

	if self.fashionType ~= nil or self.fashionType ~= 0 then
		if self.isDummyMode then
			local UnitFashionInfoModule = LX6.Units.Module.UnitFashionInfoModule
			local dummyModule = UnitFashionInfoModule.GetModule(self.spiritContext.unit)
			local playerUnit = gCS.MyPlayerManager.PlayerUnit
			local playerModule = UnitFashionInfoModule.GetModule(playerUnit)

			playerModule:SyncTryFashionsFrom(dummyModule, self.spiritContext.spiritId)
			gDressData:AskSetSpiritFashions(nil, self.spiritContext.spiritId, playerUnit)
		else
			gDressData:AskSetSpiritFashions(nil, self.spiritContext.spiritId, self.spiritContext.unit)
		end
	end
end

M.CompareIsEdited = function(self, table2)
	local table1 = nil
	local wearFashionEditInfoList = gDressManager:GetCurrentSpritWearEditFashionInfoList(self.spiritContext)

	if wearFashionEditInfoList then
		for i = 0, wearFashionEditInfoList.Count - 1 do
			if wearFashionEditInfoList[i].FashionId ~= self.fashionId then
				table1 = wearFashionEditInfoList[i]

				break
			end
		end
	end

	if table1 ~= nil then
		table1 = self.defaultEditInfo
	end

	if table1.Scale == table2.Scale then
		return false
	end

	if not table1.Offset:Equals(table2.Offset) then
		return false
	end

	if not table1.Rotation:Equals(table2.Rotation) then
		return false
	end

	return true
end

M.IsDefaultEditInfo = function(self, table1, table2)
	local isDefault = true

	if table1 ~= nil and table2 == nil and (table2.Offset == Vector3.zero or table2.Rotation == Vector3.zero or table2.Scale == 1) then
		isDefault = false
	end

	return isDefault
end

local scaleUpdateValue = 0.1
local offsetUpdateValue = 0.1
local rotateUpdateValue = 50

M.OnSetSliderUpdate = function(self)
	self.OnScaleSliderUpdate(self)
	self.OnLROffsetSliderDragUpdate(self)
	self.OnFBOffsetSliderDragUpdate(self)
	self.OnUDOffsetSliderDragUpdate(self)
	self.OnLRRotateSliderDragUpdate(self)
	self.OnFBRotateSliderDragUpdate(self)
	self.OnUDRotateSliderDragUpdate(self)
end

M.OnScaleSliderDrag = function(self, data)
	local scale = nil

	if type(data) ~= "table" and data.addValue then
		scale = self.saveData.scale + data.addValue
	else
		scale = data
	end

	if scale >= 0 then
		scale = 0
	end

	if scale <= 2 then
		scale = 2
	end

	self.contentStore.scaleSlider.value = scale

	gDressManager:DoChange(self.fashionId, self.saveData.rotate, self.saveData.offset, scale, self.spiritContext)

	self.saveData.scale = scale
end

M.OnScaleSliderDragPress = function(self, data)
	self.scaleSliderDrag = data and data.addValue or 0
end

M.OnScaleSliderDragRelease = function(self)
	self.scaleSliderDrag = 0
end

M.OnScaleSliderUpdate = function(self)
	if self.scaleSliderDrag == 0 then
		local scale = self.saveData.scale + Time.deltaTime * scaleUpdateValue * self.scaleSliderDrag

		if scale >= 0 then
			scale = 0
		end

		if scale <= 2 then
			scale = 2
		end

		self.contentStore.scaleSlider.value = scale

		gDressManager:DoChange(self.fashionId, self.saveData.rotate, self.saveData.offset, scale, self.spiritContext)

		self.saveData.scale = scale
	end
end

local offsetVec = Vector3.New(0, 0, 0)

M.OnLROffsetSliderDrag = function(self, data)
	local offset = nil

	if type(data) ~= "table" and data.addValue then
		offset = self.saveData.offset.x + data.addValue
	else
		offset = data
	end

	if offset >= -0.1 then
		offset = -0.1
	end

	if offset <= 0.1 then
		offset = 0.1
	end

	self.contentStore.lrOffsetSlider.value = offset

	offsetVec:Set(offset, self.contentStore.fbOffsetSlider.value, self.contentStore.udOffsetSlider.value)
	gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale, self.spiritContext)

	self.saveData.offset = offsetVec
end

M.OnLROffsetSliderDragPress = function(self, data)
	self.lrOffsetSliderDrag = data and data.addValue or 0
end

M.OnLROffsetSliderDragRelease = function(self)
	self.lrOffsetSliderDrag = 0
end

M.OnLROffsetSliderDragUpdate = function(self)
	if self.lrOffsetSliderDrag == 0 then
		local offset = self.saveData.offset.x + Time.deltaTime * offsetUpdateValue * self.lrOffsetSliderDrag

		if offset >= -0.1 then
			offset = -0.1
		end

		if offset <= 0.1 then
			offset = 0.1
		end

		self.contentStore.lrOffsetSlider.value = offset

		offsetVec:Set(offset, self.contentStore.fbOffsetSlider.value, self.contentStore.udOffsetSlider.value)
		gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale, self.spiritContext)

		self.saveData.offset = offsetVec
	end
end

M.OnFBOffsetSliderDrag = function(self, data)
	local offset = nil

	if type(data) ~= "table" and data.addValue then
		offset = self.saveData.offset.y + data.addValue
	else
		offset = data
	end

	if offset >= -0.1 then
		offset = -0.1
	end

	if offset <= 0.1 then
		offset = 0.1
	end

	self.contentStore.fbOffsetSlider.value = offset

	offsetVec:Set(self.contentStore.lrOffsetSlider.value, offset, self.contentStore.udOffsetSlider.value)
	gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale, self.spiritContext)

	self.saveData.offset = offsetVec
end

M.OnFBOffsetSliderDragPress = function(self, data)
	self.fbOffsetSliderDrag = data and data.addValue or 0
end

M.OnFBOffsetSliderDragRelease = function(self)
	self.fbOffsetSliderDrag = 0
end

M.OnFBOffsetSliderDragUpdate = function(self)
	if self.fbOffsetSliderDrag == 0 then
		local offset = self.saveData.offset.y + Time.deltaTime * offsetUpdateValue * self.fbOffsetSliderDrag

		if offset >= -0.1 then
			offset = -0.1
		end

		if offset <= 0.1 then
			offset = 0.1
		end

		self.contentStore.fbOffsetSlider.value = offset

		offsetVec:Set(self.contentStore.lrOffsetSlider.value, offset, self.contentStore.udOffsetSlider.value)
		gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale, self.spiritContext)

		self.saveData.offset = offsetVec
	end
end

M.OnUDOffsetSliderDrag = function(self, data)
	local offset = nil

	if type(data) ~= "table" and data.addValue then
		offset = self.saveData.offset.z + data.addValue
	else
		offset = data
	end

	if offset >= -0.1 then
		offset = -0.1
	end

	if offset <= 0.1 then
		offset = 0.1
	end

	self.contentStore.udOffsetSlider.value = offset

	offsetVec:Set(self.contentStore.lrOffsetSlider.value, self.contentStore.fbOffsetSlider.value, offset)
	gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale, self.spiritContext)

	self.saveData.offset = offsetVec
end

M.OnUDOffsetSliderDragPress = function(self, data)
	self.udOffsetSliderDrag = data and data.addValue or 0
end

M.OnUDOffsetSliderDragRelease = function(self)
	self.udOffsetSliderDrag = 0
end

M.OnUDOffsetSliderDragUpdate = function(self)
	if self.udOffsetSliderDrag == 0 then
		local offset = self.saveData.offset.z + Time.deltaTime * offsetUpdateValue * self.udOffsetSliderDrag

		if offset >= -0.1 then
			offset = -0.1
		end

		if offset <= 0.1 then
			offset = 0.1
		end

		self.contentStore.udOffsetSlider.value = offset

		offsetVec:Set(self.contentStore.lrOffsetSlider.value, self.contentStore.fbOffsetSlider.value, offset)
		gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale, self.spiritContext)

		self.saveData.offset = offsetVec
	end
end

local rotate = Vector3.New(0, 0, 0)

M.OnLRRotateSliderDrag = function(self, data)
	local rotateValue = nil

	if type(data) ~= "table" and data.addValue then
		rotateValue = self.saveData.rotate.x + data.addValue
	else
		rotateValue = data
	end

	if rotateValue <= 180 then
		rotateValue = 180
	end

	if rotateValue >= -180 then
		rotateValue = -180
	end

	rotate:Set(rotateValue, self.contentStore.fbRotateSlider.value, self.contentStore.udRotateSlider.value)

	self.saveData.rotate = rotate
	self.contentStore.lrRotateSlider.value = rotateValue

	gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale, self.spiritContext)
end

M.OnLRRotateSliderDragPress = function(self, data)
	self.lrRotateSliderDrag = data and data.addValue or 0
end

M.OnLRRotateSliderDragRelease = function(self)
	self.lrRotateSliderDrag = 0
end

M.OnLRRotateSliderDragUpdate = function(self)
	if self.lrRotateSliderDrag == 0 then
		local rotateValue = self.saveData.rotate.x + Time.deltaTime * rotateUpdateValue * self.lrRotateSliderDrag

		if rotateValue <= 180 then
			rotateValue = 180
		end

		if rotateValue >= -180 then
			rotateValue = -180
		end

		self.contentStore.lrRotateSlider.value = rotateValue

		rotate:Set(rotateValue, self.contentStore.fbRotateSlider.value, self.contentStore.udRotateSlider.value)

		self.saveData.rotate = rotate

		gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale, self.spiritContext)
	end
end

M.OnFBRotateSliderDrag = function(self, data)
	local rotateValue = nil

	if type(data) ~= "table" and data.addValue then
		rotateValue = self.saveData.rotate.y + data.addValue
	else
		rotateValue = data
	end

	if rotateValue <= 180 then
		rotateValue = 180
	end

	if rotateValue >= -180 then
		rotateValue = -180
	end

	self.contentStore.fbRotateSlider.value = rotateValue

	rotate:Set(self.contentStore.lrRotateSlider.value, rotateValue, self.contentStore.udRotateSlider.value)

	self.saveData.rotate = rotate

	gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale, self.spiritContext)
end

M.OnFBRotateSliderDragPress = function(self, data)
	self.fbRotateSliderDrag = data and data.addValue or 0
end

M.OnFBRotateSliderDragRelease = function(self)
	self.fbRotateSliderDrag = 0
end

M.OnFBRotateSliderDragUpdate = function(self)
	if self.fbRotateSliderDrag == 0 then
		local rotateValue = self.saveData.rotate.y + Time.deltaTime * rotateUpdateValue * self.fbRotateSliderDrag

		if rotateValue <= 180 then
			rotateValue = 180
		end

		if rotateValue >= -180 then
			rotateValue = -180
		end

		self.contentStore.fbRotateSlider.value = rotateValue

		rotate:Set(self.contentStore.lrRotateSlider.value, rotateValue, self.contentStore.udRotateSlider.value)

		self.saveData.rotate = rotate

		gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale, self.spiritContext)
	end
end

M.OnUDRotateSliderDrag = function(self, data)
	local rotateValue = nil

	if type(data) ~= "table" and data.addValue then
		rotateValue = self.saveData.rotate.z + data.addValue
	else
		rotateValue = data
	end

	if rotateValue <= 180 then
		rotateValue = 180
	end

	if rotateValue >= -180 then
		rotateValue = -180
	end

	self.contentStore.udRotateSlider.value = rotateValue

	rotate:Set(self.contentStore.lrRotateSlider.value, self.contentStore.fbRotateSlider.value, rotateValue)

	self.saveData.rotate = rotate

	gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale, self.spiritContext)
end

M.OnUDRotateSliderDragPress = function(self, data)
	self.udRotateSliderDrag = data and data.addValue or 0
end

M.OnUDRotateSliderDragRelease = function(self)
	self.udRotateSliderDrag = 0
end

M.OnUDRotateSliderDragUpdate = function(self)
	if self.udRotateSliderDrag == 0 then
		local rotateValue = self.saveData.rotate.z + Time.deltaTime * rotateUpdateValue * self.udRotateSliderDrag

		if rotateValue <= 180 then
			rotateValue = 180
		end

		if rotateValue >= -180 then
			rotateValue = -180
		end

		self.contentStore.udRotateSlider.value = rotateValue

		rotate:Set(self.contentStore.lrRotateSlider.value, self.contentStore.fbRotateSlider.value, rotateValue)

		self.saveData.rotate = rotate

		gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale, self.spiritContext)
	end
end
