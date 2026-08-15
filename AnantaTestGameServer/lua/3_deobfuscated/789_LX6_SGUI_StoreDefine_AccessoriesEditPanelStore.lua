require("LX6/Manager/Dress/DressSetPanelCamera")

local FashionConfig = LTConfig.FashionConfig
local FashionEditConfig = LTConfig.FashionEditConfig
local UXVector3 = UX.Game.UXVector3
local MessageConfig = LTConfig.MessageConfig
local FashionBaseConfig = LTConfig.FashionBaseConfig
C_AccessoriesEditPanelStore = DefClass("C_AccessoriesEditPanelStore", C_AccessoriesEditPanelStore, C_StoreGroup)
GroupName2Class.AccessoriesEditPanelStore = C_AccessoriesEditPanelStore
local M = C_AccessoriesEditPanelStore

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.resetBtn.luaClick = self:CreateAction("OnResetBtnClick")
	self.bindData.saveBtn.luaClick = self:CreateAction("OnSaveBtnClick")
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.scaleSliderDrag = 0
	self.fbOffsetSliderDrag = 0
	self.udOffsetSliderDrag = 0
	self.lrOffsetSliderDrag = 0
	self.lrRotateSliderDrag = 0
	self.fbRotateSliderDrag = 0
	self.udRotateSliderDrag = 0
	self.saveData = {}
	gDressManager.fashionProp = {}
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
		addValue = -1
	})
	self.contentStore.scaleLButton.luaRelease = self:CreateAction("OnScaleSliderDragRelease")
	self.contentStore.scaleRButton.luaPress = self:CreateActionWithArgs("OnScaleSliderDragPress", {
		addValue = 1
	})
	self.contentStore.scaleRButton.luaRelease = self:CreateAction("OnScaleSliderDragRelease")
	self.contentStore.fbOffsetLButton.luaPress = self:CreateActionWithArgs("OnFBOffsetSliderDragPress", {
		addValue = -1
	})
	self.contentStore.fbOffsetLButton.luaRelease = self:CreateAction("OnFBOffsetSliderDragRelease")
	self.contentStore.fbOffsetRButton.luaPress = self:CreateActionWithArgs("OnFBOffsetSliderDragPress", {
		addValue = 1
	})
	self.contentStore.fbOffsetRButton.luaRelease = self:CreateAction("OnFBOffsetSliderDragRelease")
	self.contentStore.lrOffsetLButton.luaPress = self:CreateActionWithArgs("OnLROffsetSliderDragPress", {
		addValue = -1
	})
	self.contentStore.lrOffsetLButton.luaRelease = self:CreateAction("OnLROffsetSliderDragRelease")
	self.contentStore.lrOffsetRButton.luaPress = self:CreateActionWithArgs("OnLROffsetSliderDragPress", {
		addValue = 1
	})
	self.contentStore.lrOffsetRButton.luaRelease = self:CreateAction("OnLROffsetSliderDragRelease")
	self.contentStore.udOffsetLButton.luaPress = self:CreateActionWithArgs("OnUDOffsetSliderDragPress", {
		addValue = -1
	})
	self.contentStore.udOffsetLButton.luaRelease = self:CreateAction("OnUDOffsetSliderDragRelease")
	self.contentStore.udOffsetRButton.luaPress = self:CreateActionWithArgs("OnUDOffsetSliderDragPress", {
		addValue = 1
	})
	self.contentStore.udOffsetRButton.luaRelease = self:CreateAction("OnUDOffsetSliderDragRelease")
	self.contentStore.rotateLRLButton.luaPress = self:CreateActionWithArgs("OnLRRotateSliderDragPress", {
		addValue = -1
	})
	self.contentStore.rotateLRLButton.luaRelease = self:CreateAction("OnLRRotateSliderDragRelease")
	self.contentStore.rotateLRRButton.luaPress = self:CreateActionWithArgs("OnLRRotateSliderDragPress", {
		addValue = 1
	})
	self.contentStore.rotateLRRButton.luaRelease = self:CreateAction("OnLRRotateSliderDragRelease")
	self.contentStore.rotateFBLButton.luaPress = self:CreateActionWithArgs("OnFBRotateSliderDragPress", {
		addValue = -1
	})
	self.contentStore.rotateFBLButton.luaRelease = self:CreateAction("OnFBRotateSliderDragRelease")
	self.contentStore.rotateFBRButton.luaPress = self:CreateActionWithArgs("OnFBRotateSliderDragPress", {
		addValue = 1
	})
	self.contentStore.rotateFBRButton.luaRelease = self:CreateAction("OnFBRotateSliderDragRelease")
	self.contentStore.rotateUDLButton.luaPress = self:CreateActionWithArgs("OnUDRotateSliderDragPress", {
		addValue = -1
	})
	self.contentStore.rotateUDLButton.luaRelease = self:CreateAction("OnUDRotateSliderDragRelease")
	self.contentStore.rotateUDRButton.luaPress = self:CreateActionWithArgs("OnUDRotateSliderDragPress", {
		addValue = 1
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

	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, true, cameraParams)
end

function M:InitDefaultInfo()
	local modelId = gCS.MyPlayerManager.PlayerUnit.ClientData.ModelId
	local modelCfg = LTConfig.GeneralModelConfig.GetConfig(modelId)

	if modelCfg == nil then
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

	local spriteFashionInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId]

	if table.isNilOrEmpty(spriteFashionInfo) then
		return
	end

	self.defaultEditInfo = {}
	local hasEditInfo = false
	local wearFashionEditInfoList = spriteFashionInfo.WearFashionEditInfoList

	for t = 1, #wearFashionEditInfoList do
		if wearFashionEditInfoList[t].FashionId == self.fashionId then
			hasEditInfo = true
			self.defaultEditInfo.Scale = wearFashionEditInfoList[t].Scale
			self.defaultEditInfo.LROffsetRadius = wearFashionEditInfoList[t].Offset.X
			self.defaultEditInfo.FBOffsetRadius = wearFashionEditInfoList[t].Offset.Y
			self.defaultEditInfo.UDOffsetRadius = wearFashionEditInfoList[t].Offset.Z
			self.defaultEditInfo.LRRotation = wearFashionEditInfoList[t].Rotation.X
			self.defaultEditInfo.FBRotation = wearFashionEditInfoList[t].Rotation.Y
			self.defaultEditInfo.UDRotation = wearFashionEditInfoList[t].Rotation.Z

			break
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

function M:OnUpdate()
	self:OnSetSliderUpdate()
end

function M:OnClose()
	gDressManager.fashionProp = {}

	if self.callBack then
		self.callBack()
	end

	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, false)
end

function M:OnBackBtnClick()
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

	if not self:CompareTableIsSame(self.editInfoList) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.FashionPropEditExitReconfirm, function ()
			self.saveData.scale = self.defaultEditInfo.Scale
			self.saveData.offset = Vector3.New(self.defaultEditInfo.LROffsetRadius, self.defaultEditInfo.FBOffsetRadius, self.defaultEditInfo.UDOffsetRadius)
			self.saveData.rotate = Vector3.New(self.defaultEditInfo.LRRotation, self.defaultEditInfo.FBRotation, self.defaultEditInfo.UDRotation)

			gDressManager:DoChange(self.fashionId, self.saveData.rotate, self.saveData.offset, self.saveData.scale)
			gPanelManager:Close(gPanelId.S_ACCESSORIES_EDIT)
		end)
	else
		gPanelManager:Close(gPanelId.S_ACCESSORIES_EDIT)
	end
end

function M:OnResetBtnClick()
	self.contentStore.scaleSlider.value = 1
	self.contentStore.lrOffsetSlider.value = 0
	self.contentStore.fbOffsetSlider.value = 0
	self.contentStore.udOffsetSlider.value = 0
	self.contentStore.lrRotateSlider.value = 0
	self.contentStore.fbRotateSlider.value = 0
	self.contentStore.udRotateSlider.value = 0
end

function M:OnSaveBtnClick()
	gDressManager.fashionProp = {}
	local Offset = UXVector3.New(self.contentStore.lrOffsetSlider.value, self.contentStore.fbOffsetSlider.value, self.contentStore.udOffsetSlider.value)
	local Rotation = UXVector3.New(self.contentStore.lrRotateSlider.value, self.contentStore.fbRotateSlider.value, self.contentStore.udRotateSlider.value)

	gDressManager:SaveFashionListEdit(self.fashionId, self.contentStore.scaleSlider.value, Offset, Rotation)

	local stepEditInfoList = {
		FashionId = self.fashionId,
		Scale = self.contentStore.scaleSlider.value,
		Offset = Offset,
		Rotation = Rotation
	}
	local stepData = {
		fashionList = {
			self.fashionId
		},
		stepType = gDressManager.STEP_TYPE.EDIT,
		editInfoList = stepEditInfoList
	}

	gDressManager:AddStep(stepData)
	self:InitDefaultInfo()
	gDisplayMessageMgr:ShowMessage(MessageConfig.FashionPropEditSaveSuccess)

	if self.fashionType == nil or self.fashionType == 0 then
		gDressData:AskSetSpiritFashions()
	end
end

function M:CompareTableIsSame(table2)
	local table1 = nil
	local spriteFashionInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId]

	if spriteFashionInfo then
		for i = 1, #spriteFashionInfo.WearFashionEditInfoList do
			if spriteFashionInfo.WearFashionEditInfoList[i].FashionId == self.fashionId then
				table1 = spriteFashionInfo.WearFashionEditInfoList[i]

				break
			end
		end
	end

	if table1 == table2 then
		return true
	end

	if table1 == nil then
		if self:IsDefaultEditInfo(table1, table2) then
			return true
		end

		return false
	else
		for key, value in pairs(table1) do
			if table2[key] ~= value then
				return false
			end
		end

		for key, value in pairs(table2) do
			if table1[key] ~= value then
				return false
			end
		end
	end

	return true
end

function M:IsDefaultEditInfo(table1, table2)
	local isDefault = true

	if table1 == nil and table2 ~= nil and (table2.Offset ~= Vector3.zero or table2.Rotation ~= Vector3.zero or table2.Scale ~= 1) then
		isDefault = false
	end

	return isDefault
end

local scaleUpdateValue = 0.1
local offsetUpdateValue = 0.1
local rotateUpdateValue = 50

function M:OnSetSliderUpdate()
	self:OnScaleSliderUpdate()
	self:OnLROffsetSliderDragUpdate()
	self:OnFBOffsetSliderDragUpdate()
	self:OnUDOffsetSliderDragUpdate()
	self:OnLRRotateSliderDragUpdate()
	self:OnFBRotateSliderDragUpdate()
	self:OnUDRotateSliderDragUpdate()
end

function M:OnScaleSliderDrag(data)
	local scale = nil

	if type(data) == "table" and data.addValue then
		scale = self.saveData.scale + data.addValue
	else
		scale = data
	end

	if scale < 0 then
		scale = 0
	end

	if scale > 2 then
		scale = 2
	end

	self.contentStore.scaleSlider.value = scale

	gDressManager:DoChange(self.fashionId, self.saveData.rotate, self.saveData.offset, scale)

	self.saveData.scale = scale
end

function M:OnScaleSliderDragPress(data)
	self.scaleSliderDrag = data and data.addValue or 0
end

function M:OnScaleSliderDragRelease()
	self.scaleSliderDrag = 0
end

function M:OnScaleSliderUpdate()
	if self.scaleSliderDrag ~= 0 then
		local scale = self.saveData.scale + Time.deltaTime * scaleUpdateValue * self.scaleSliderDrag

		if scale < 0 then
			scale = 0
		end

		if scale > 2 then
			scale = 2
		end

		self.contentStore.scaleSlider.value = scale

		gDressManager:DoChange(self.fashionId, self.saveData.rotate, self.saveData.offset, scale)

		self.saveData.scale = scale
	end
end

local offsetVec = Vector3.New(0, 0, 0)

function M:OnLROffsetSliderDrag(data)
	local offset = nil

	if type(data) == "table" and data.addValue then
		offset = self.saveData.offset.x + data.addValue
	else
		offset = data
	end

	if offset < -0.1 then
		offset = -0.1
	end

	if offset > 0.1 then
		offset = 0.1
	end

	self.contentStore.lrOffsetSlider.value = offset

	offsetVec:Set(offset, self.contentStore.fbOffsetSlider.value, self.contentStore.udOffsetSlider.value)
	gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale)

	self.saveData.offset = offsetVec
end

function M:OnLROffsetSliderDragPress(data)
	self.lrOffsetSliderDrag = data and data.addValue or 0
end

function M:OnLROffsetSliderDragRelease()
	self.lrOffsetSliderDrag = 0
end

function M:OnLROffsetSliderDragUpdate()
	if self.lrOffsetSliderDrag ~= 0 then
		local offset = self.saveData.offset.x + Time.deltaTime * offsetUpdateValue * self.lrOffsetSliderDrag

		if offset < -0.1 then
			offset = -0.1
		end

		if offset > 0.1 then
			offset = 0.1
		end

		self.contentStore.lrOffsetSlider.value = offset

		offsetVec:Set(offset, self.contentStore.fbOffsetSlider.value, self.contentStore.udOffsetSlider.value)
		gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale)

		self.saveData.offset = offsetVec
	end
end

function M:OnFBOffsetSliderDrag(data)
	local offset = nil

	if type(data) == "table" and data.addValue then
		offset = self.saveData.offset.y + data.addValue
	else
		offset = data
	end

	if offset < -0.1 then
		offset = -0.1
	end

	if offset > 0.1 then
		offset = 0.1
	end

	self.contentStore.fbOffsetSlider.value = offset

	offsetVec:Set(self.contentStore.lrOffsetSlider.value, offset, self.contentStore.udOffsetSlider.value)
	gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale)

	self.saveData.offset = offsetVec
end

function M:OnFBOffsetSliderDragPress(data)
	self.fbOffsetSliderDrag = data and data.addValue or 0
end

function M:OnFBOffsetSliderDragRelease()
	self.fbOffsetSliderDrag = 0
end

function M:OnFBOffsetSliderDragUpdate()
	if self.fbOffsetSliderDrag ~= 0 then
		local offset = self.saveData.offset.y + Time.deltaTime * offsetUpdateValue * self.fbOffsetSliderDrag

		if offset < -0.1 then
			offset = -0.1
		end

		if offset > 0.1 then
			offset = 0.1
		end

		self.contentStore.fbOffsetSlider.value = offset

		offsetVec:Set(self.contentStore.lrOffsetSlider.value, offset, self.contentStore.udOffsetSlider.value)
		gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale)

		self.saveData.offset = offsetVec
	end
end

function M:OnUDOffsetSliderDrag(data)
	local offset = nil

	if type(data) == "table" and data.addValue then
		offset = self.saveData.offset.z + data.addValue
	else
		offset = data
	end

	if offset < -0.1 then
		offset = -0.1
	end

	if offset > 0.1 then
		offset = 0.1
	end

	self.contentStore.udOffsetSlider.value = offset

	offsetVec:Set(self.contentStore.lrOffsetSlider.value, self.contentStore.fbOffsetSlider.value, offset)
	gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale)

	self.saveData.offset = offsetVec
end

function M:OnUDOffsetSliderDragPress(data)
	self.udOffsetSliderDrag = data and data.addValue or 0
end

function M:OnUDOffsetSliderDragRelease()
	self.udOffsetSliderDrag = 0
end

function M:OnUDOffsetSliderDragUpdate()
	if self.udOffsetSliderDrag ~= 0 then
		local offset = self.saveData.offset.z + Time.deltaTime * offsetUpdateValue * self.udOffsetSliderDrag

		if offset < -0.1 then
			offset = -0.1
		end

		if offset > 0.1 then
			offset = 0.1
		end

		self.contentStore.udOffsetSlider.value = offset

		offsetVec:Set(self.contentStore.lrOffsetSlider.value, self.contentStore.fbOffsetSlider.value, offset)
		gDressManager:DoChange(self.fashionId, self.saveData.rotate, offsetVec, self.saveData.scale)

		self.saveData.offset = offsetVec
	end
end

local rotate = Vector3.New(0, 0, 0)

function M:OnLRRotateSliderDrag(data)
	local rotateValue = nil

	if type(data) == "table" and data.addValue then
		rotateValue = self.saveData.rotate.x + data.addValue
	else
		rotateValue = data
	end

	if rotateValue > 180 then
		rotateValue = 180
	end

	if rotateValue < -180 then
		rotateValue = -180
	end

	rotate:Set(rotateValue, self.contentStore.fbRotateSlider.value, self.contentStore.udRotateSlider.value)

	self.saveData.rotate = rotate
	self.contentStore.lrRotateSlider.value = rotateValue

	gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale)
end

function M:OnLRRotateSliderDragPress(data)
	self.lrRotateSliderDrag = data and data.addValue or 0
end

function M:OnLRRotateSliderDragRelease()
	self.lrRotateSliderDrag = 0
end

function M:OnLRRotateSliderDragUpdate()
	if self.lrRotateSliderDrag ~= 0 then
		local rotateValue = self.saveData.rotate.x + Time.deltaTime * rotateUpdateValue * self.lrRotateSliderDrag

		if rotateValue > 180 then
			rotateValue = 180
		end

		if rotateValue < -180 then
			rotateValue = -180
		end

		self.contentStore.lrRotateSlider.value = rotateValue

		rotate:Set(rotateValue, self.contentStore.fbRotateSlider.value, self.contentStore.udRotateSlider.value)

		self.saveData.rotate = rotate

		gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale)
	end
end

function M:OnFBRotateSliderDrag(data)
	local rotateValue = nil

	if type(data) == "table" and data.addValue then
		rotateValue = self.saveData.rotate.y + data.addValue
	else
		rotateValue = data
	end

	if rotateValue > 180 then
		rotateValue = 180
	end

	if rotateValue < -180 then
		rotateValue = -180
	end

	self.contentStore.fbRotateSlider.value = rotateValue

	rotate:Set(self.contentStore.lrRotateSlider.value, rotateValue, self.contentStore.udRotateSlider.value)

	self.saveData.rotate = rotate

	gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale)
end

function M:OnFBRotateSliderDragPress(data)
	self.fbRotateSliderDrag = data and data.addValue or 0
end

function M:OnFBRotateSliderDragRelease()
	self.fbRotateSliderDrag = 0
end

function M:OnFBRotateSliderDragUpdate()
	if self.fbRotateSliderDrag ~= 0 then
		local rotateValue = self.saveData.rotate.y + Time.deltaTime * rotateUpdateValue * self.fbRotateSliderDrag

		if rotateValue > 180 then
			rotateValue = 180
		end

		if rotateValue < -180 then
			rotateValue = -180
		end

		self.contentStore.fbRotateSlider.value = rotateValue

		rotate:Set(self.contentStore.lrRotateSlider.value, rotateValue, self.contentStore.udRotateSlider.value)

		self.saveData.rotate = rotate

		gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale)
	end
end

function M:OnUDRotateSliderDrag(data)
	local rotateValue = nil

	if type(data) == "table" and data.addValue then
		rotateValue = self.saveData.rotate.z + data.addValue
	else
		rotateValue = data
	end

	if rotateValue > 180 then
		rotateValue = 180
	end

	if rotateValue < -180 then
		rotateValue = -180
	end

	self.contentStore.udRotateSlider.value = rotateValue

	rotate:Set(self.contentStore.lrRotateSlider.value, self.contentStore.fbRotateSlider.value, rotateValue)

	self.saveData.rotate = rotate

	gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale)
end

function M:OnUDRotateSliderDragPress(data)
	self.udRotateSliderDrag = data and data.addValue or 0
end

function M:OnUDRotateSliderDragRelease()
	self.udRotateSliderDrag = 0
end

function M:OnUDRotateSliderDragUpdate()
	if self.udRotateSliderDrag ~= 0 then
		local rotateValue = self.saveData.rotate.z + Time.deltaTime * rotateUpdateValue * self.udRotateSliderDrag

		if rotateValue > 180 then
			rotateValue = 180
		end

		if rotateValue < -180 then
			rotateValue = -180
		end

		self.contentStore.udRotateSlider.value = rotateValue

		rotate:Set(self.contentStore.lrRotateSlider.value, self.contentStore.fbRotateSlider.value, rotateValue)

		self.saveData.rotate = rotate

		gDressManager:DoChange(self.fashionId, rotate, self.saveData.offset, self.saveData.scale)
	end
end
