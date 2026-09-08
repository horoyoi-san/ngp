-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerTetrisHUDPanelStore.lua
-- Decompiled from: 01705_HackerTetrisHUDPanelStore.lua_c94132da0279.luajit

C_HackerTetrisHUDPanelStore = DefClass("C_HackerTetrisHUDPanelStore", C_HackerTetrisHUDPanelStore, C_StoreGroup)
GroupName2Class.HackerTetrisHUDPanelStore = C_HackerTetrisHUDPanelStore
local M = C_HackerTetrisHUDPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.needUpdateLeftHold = false
	self.leftHoldTime = 0
	self.leftHoldInterval = 0.1
	self.needUpdateRightHold = false
	self.rightHoldTime = 0
	self.rightHoldInterval = 0.1
	self.needUpdateDownHold = false
	self.downHoldTime = 0
	self.downHoldInterval = 0.1
	self.accelerateDownDragX = 0
	self.accelerateDownDragStartY = 0
	self.buttonBanId = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.ResetAccelerateDownDrag(self)
end

M.OnDestroy = function(self)
end

M.OnUpdate = function(self)
	if self.needUpdateLeftHold then
		self.leftHoldTime = self.leftHoldTime + Time.deltaTime

		if self.leftHoldInterval < self.leftHoldTime then
			self.leftHoldTime = 0

			gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_MOVE_LEFT)
		end
	end

	if self.needUpdateRightHold then
		self.rightHoldTime = self.rightHoldTime + Time.deltaTime

		if self.rightHoldInterval < self.rightHoldTime then
			self.rightHoldTime = 0

			gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_MOVE_RIGHT)
		end
	end

	if self.needUpdateDownHold then
		self.downHoldTime = self.downHoldTime + Time.deltaTime

		if self.downHoldInterval < self.downHoldTime then
			self.downHoldTime = 0

			gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_MOVE_DOWN)
		end
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "hackerTetris", true, true)
	gMapUtils:CloseMiniMap()

	self.buttonBanId = gStoreButtonMgr:RegisterOperation({
		["\\xca\\xcf\t\r\\xf5"] = 5,
		["\\xbb\\xa3\\xa4x7\\xea*"] = 0,
		groupId = LTConfig.HudDescGroupConfig.HackerTetris
	})
end

M.OnClose = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "hackerTetris", false, true)
	gMapUtils:ShowMiniMap()

	if self.buttonBanId then
		gStoreButtonMgr:UnRegisterOperation(self.buttonBanId)

		self.buttonBanId = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.rotateButton.luaClick = self.CreateAction(self, "OnClickRotateButton")
	self.bindData.accelerateDownButton.luaBeginLongPress = self.CreateAction(self, "OnBeginLongPressAccelerateDownButton")
	self.bindData.accelerateDownButton.luaLongPress = self.CreateAction(self, "OnLongPressAccelerateDownButton")
	self.bindData.accelerateDownButton.luaEndLongPress = self.CreateAction(self, "OnEndLongPressAccelerateDownButton")
	self.bindData.accelerateDownButton.luaBeginDrag = self.CreateAction(self, "OnBeginDragAccelerateDownButton")
	self.bindData.accelerateDownButton.luaDrag = self.CreateAction(self, "OnDragAccelerateDownButton")
	self.bindData.accelerateDownButton.luaEndDrag = self.CreateAction(self, "OnEndDragAccelerateDownButton")
	self.bindData.leftButton.luaBeginLongPress = self.CreateAction(self, "OnBeginLongPressLeftButton")
	self.bindData.leftButton.luaLongPress = self.CreateAction(self, "OnLongPressLeftButton")
	self.bindData.leftButton.luaEndLongPress = self.CreateAction(self, "OnEndLongPressLeftButton")
	self.bindData.rightButton.luaBeginLongPress = self.CreateAction(self, "OnBeginLongPressRightButton")
	self.bindData.rightButton.luaLongPress = self.CreateAction(self, "OnLongPressRightButton")
	self.bindData.rightButton.luaEndLongPress = self.CreateAction(self, "OnEndLongPressRightButton")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnClickExitButton")
	self.bindData.downButton.luaClick = self.CreateAction(self, "OnClickDownButton")
end

M.OnClickRotateButton = function(self)
	gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_ROTATE)
end

M.OnClickDownButton = function(self)
	gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_HARD_DROP)
end

M.OnBeginLongPressAccelerateDownButton = function(self)
	gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_MOVE_DOWN)
end

M.OnLongPressAccelerateDownButton = function(self)
	self.downHoldTime = 0
	self.needUpdateDownHold = true
end

M.OnEndLongPressAccelerateDownButton = function(self)
	self.needUpdateDownHold = false
	self.downHoldTime = 0
end

M.OnBeginDragAccelerateDownButton = function(self)
	self:OnEndLongPressAccelerateDownButton()

	local position = self.bindData.accelerateDownButton.rectTransform.position
	self.accelerateDownDragX = position.x
	self.accelerateDownDragStartY = position.y

	self.rootWidget:TryChangePage("OnDrag", "active")
end

M.OnDragAccelerateDownButton = function(self)
	local rectTransform = self.bindData.accelerateDownButton.rectTransform
	local position = rectTransform.position
	rectTransform.position = Vector3.New(self.accelerateDownDragX, math.min(position.y, self.accelerateDownDragStartY), position.z)
end

M.OnEndDragAccelerateDownButton = function(self, dropWidget)
	if dropWidget ~= self.bindData.quickBottomMobile then
		gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_HARD_DROP)
	end

	self.ResetAccelerateDownDrag(self)
end

M.ResetAccelerateDownDrag = function(self)
	self.needUpdateDownHold = false
	self.downHoldTime = 0

	self.rootWidget:TryChangePage("OnDrag", "normal")
end

M.OnBeginLongPressLeftButton = function(self)
	gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_MOVE_LEFT)
end

M.OnLongPressLeftButton = function(self)
	self.leftHoldTime = 0
	self.needUpdateLeftHold = true
end

M.OnEndLongPressLeftButton = function(self)
	self.needUpdateLeftHold = false
	self.leftHoldTime = 0
end

M.OnBeginLongPressRightButton = function(self)
	gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_MOVE_RIGHT)
end

M.OnLongPressRightButton = function(self)
	self.rightHoldTime = 0
	self.needUpdateRightHold = true
end

M.OnEndLongPressRightButton = function(self)
	self.needUpdateRightHold = false
	self.rightHoldTime = 0
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
	gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_PAUSE)
end
