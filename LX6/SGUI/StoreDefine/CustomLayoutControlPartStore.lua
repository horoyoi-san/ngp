-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CustomLayoutControlPartStore.lua
-- Decompiled from: 01510_CustomLayoutControlPartStore.lua_b4a1a42fb6bb.luajit

C_CustomLayoutControlPartStore = DefClass("C_CustomLayoutControlPartStore", C_CustomLayoutControlPartStore, C_StoreGroup)
GroupName2Class.CustomLayoutControlPartStore = C_CustomLayoutControlPartStore
local M = C_CustomLayoutControlPartStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.rightVec = Vector2.New(10, 0)
	self.leftVec = Vector2.New(-10, 0)
	self.upVec = Vector2.New(0, 10)
	self.downVec = Vector2.New(0, -10)
	self.mgr = SGUI.UCustomLayoutMgr.Instance
	self.originalBtnX = 0
	self.originalBtnY = 0
	self.originalRootX = 0
	self.originalRootY = 0
	self.dragStarted = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.FoldCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isSelectingBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.FoldCtrlEnum = nil
	self.isSelectingBtnCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.rightVec = nil
	self.leftVec = nil
	self.upVec = nil
	self.downVec = nil
	self.mgr = nil
	self.panelId = nil
	self.originalBtnX = nil
	self.originalBtnY = nil
	self.originalRootX = nil
	self.originalRootY = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.InitControl = function(self, panelId)
	self.panelId = panelId
	self.fold = false
	self.bindData.ctrlSliderAlpha.value = 100
	self.bindData.ctrlSliderScale.value = 100
	self.bindData.ctrlBtnName = ""
	self.bindData.isSelectingBtnCtrl = self.isSelectingBtnCtrlEnum._false
	self.bindData.FoldCtrl = self.fold and 1 or 0
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.ctrlRightBtn.luaClick = self.CreateAction(self, "OnClickCtrlRightBtn")
	self.bindData.ctrlLeftBtn.luaClick = self.CreateAction(self, "OnClickCtrlLeftBtn")
	self.bindData.ctrlTopBtn.luaClick = self.CreateAction(self, "OnClickCtrlTopBtn")
	self.bindData.ctrlBottomBtn.luaClick = self.CreateAction(self, "OnClickCtrlBottomBtn")
	self.bindData.ctrlExitBtn.luaClick = self.CreateAction(self, "OnClickCtrlExitBtn")
	self.bindData.ctrlResetBtn.luaClick = self.CreateAction(self, "OnClickCtrlResetBtn")
	self.bindData.ctrlSaveBtn.luaClick = self.CreateAction(self, "OnClickCtrlSaveBtn")
	self.bindData.ctrlFoldBtn.luaClick = self.CreateAction(self, "OnClickCtrlFoldBtn")
	self.bindData.ctrlDragBtn.luaBeginDrag = self.CreateAction(self, "OnBtnDragBegin")
	self.bindData.ctrlDragBtn.luaDrag = self.CreateAction(self, "OnBtnDrag")
	self.bindData.ctrlDragBtn.luaEndDrag = self.CreateAction(self, "OnBtnDragEnd")
	self.bindData.ctrlSliderScale.luaValueChanged = self.CreateAction(self, "OnSliderScaleValueChanged")
	self.bindData.ctrlSliderAlpha.luaValueChanged = self.CreateAction(self, "OnSliderAlphaValueChanged")
	self.mgr.luaSelectionChanged = self.CreateAction(self, "OnSelectionChanged")
	self.mgr.luaPinchScaleChanged = self.CreateAction(self, "OnPinchScaleChanged")
end

M.OnClickCtrlRightBtn = function(self)
	self.mgr:NudgeSelected(self.rightVec)
end

M.OnClickCtrlLeftBtn = function(self)
	self.mgr:NudgeSelected(self.leftVec)
end

M.OnClickCtrlTopBtn = function(self)
	self.mgr:NudgeSelected(self.upVec)
end

M.OnClickCtrlBottomBtn = function(self)
	self.mgr:NudgeSelected(self.downVec)
end

M.OnClickCtrlExitBtn = function(self)
	if self.mgr:HasAnyModified() then
		slot1 = gDisplayMessageMgr

		slot1:ShowMessage(LTConfig.MessageConfig.CustomLayoutEdited, function ()
			self.mgr:SaveAll()

			if self.panelId then
				gPanelManager:Close(self.panelId)
			end
		end, function ()
			if self.panelId then
				gPanelManager:Close(self.panelId)
			end
		end)
	elseif self.panelId then
		gPanelManager:Close(self.panelId)
	end
end

M.OnClickCtrlResetBtn = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(LTConfig.MessageConfig.CustomLayoutReset, function ()
		self.mgr:ResetAllToDefault()

		self.bindData.ctrlSliderAlpha.value = 100
		self.bindData.ctrlSliderScale.value = 100
	end)
end

M.OnClickCtrlSaveBtn = function(self)
	self.mgr:SaveAll()
	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CustomLayoutSaved)
end

M.OnClickCtrlFoldBtn = function(self)
	self.fold = not self.fold
	self.bindData.FoldCtrl = self.fold and 1 or 0
end

M.OnSliderScaleValueChanged = function(self)
	self.mgr:SetSelectedScale(self.bindData.ctrlSliderScale.value / 100)
end

M.OnSliderAlphaValueChanged = function(self)
	self.mgr:SetSelectedAlpha(self.bindData.ctrlSliderAlpha.value / 100)
end

M.OnSelectionChanged = function(self, item)
	local alphaRange = self.mgr:GetSelectedAlphaRange()
	local scaleRange = self.mgr:GetSelectedScaleRange()
	local selectedScale = self.mgr:GetSelectedScale()
	local selectedAlpha = self.mgr:GetSelectedAlpha()
	self.bindData.ctrlSliderAlpha.minValue = alphaRange.x * 100
	self.bindData.ctrlSliderAlpha.maxValue = alphaRange.y * 100
	self.bindData.ctrlSliderScale.minValue = scaleRange.x * 100
	self.bindData.ctrlSliderScale.maxValue = scaleRange.y * 100
	self.bindData.ctrlSliderAlpha.value = selectedAlpha * 100
	self.bindData.ctrlSliderScale.value = selectedScale * 100
	local id = self.mgr:GetSelectedNameId()
	local cfg = LTConfig.InputButtonNameConfig.GetConfig(id)
	self.bindData.ctrlBtnName = cfg and cfg.Name or ""
	self.bindData.isSelectingBtnCtrl = self.isSelectingBtnCtrlEnum._true
end

M.OnPinchScaleChanged = function(self, scale)
	self.bindData.ctrlSliderScale.value = scale * 100
end

M.OnBtnDragBegin = function(self)
	self.originalBtnX = self.bindData.dragBtnTrans.localPosition.x
	self.originalBtnY = self.bindData.dragBtnTrans.localPosition.y
	self.originalRootX = self.bindData.rootTrans.localPosition.x
	self.originalRootY = self.bindData.rootTrans.localPosition.y
	self.dragStarted = true
end

M.OnBtnDrag = function(self)
	if self.dragStarted then
		local relativeMoveX = self.bindData.dragBtnTrans.localPosition.x - self.originalBtnX
		local relativeMoveY = self.bindData.dragBtnTrans.localPosition.y - self.originalBtnY

		self.bindData.rootTrans:SetLocalPositionXY(self.originalRootX + relativeMoveX, self.originalRootY + relativeMoveY)
	end
end

M.OnBtnDragEnd = function(self)
	self.dragStarted = false
end
