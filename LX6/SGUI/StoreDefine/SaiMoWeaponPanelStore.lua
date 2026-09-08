-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SaiMoWeaponPanelStore.lua
-- Decompiled from: 00864_SaiMoWeaponPanelStore.lua_b6a3172c613b.luajit

C_SaiMoWeaponPanelStore = DefClass("C_SaiMoWeaponPanelStore", C_SaiMoWeaponPanelStore, C_StoreGroup)
GroupName2Class.SaiMoWeaponPanelStore = C_SaiMoWeaponPanelStore
local M = C_SaiMoWeaponPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.PATH_STATE = {
		["h\\x83\\x92\\x9b\\x8f"] = 0,
		["/m\\xbd\\xab\\xa0u"] = 1,
		["N^p"] = 2,
		["WNh"] = 3
	}
	self.DIRECTION = {
		["V[o"] = 0,
		["\\x87\\x85\\x87\\x82"] = 1
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.statusCtrlEnum = {
		["\\x98\\xb4\t\\xaei*\\xfb7"] = 1,
		["N+~P"] = 2,
		["B\\xbfx\\\\xb7\\xe0F~sqB"] = 3,
		["h\\xa3\\xb2\\xbb\\xaf"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.statusCtrlEnum = nil
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
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.InitPathInfo(self)
end

M.OnClose = function(self)
	self.StopAllTimer(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.pathList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderPathListItem")
	self.bindData.rightBtn.luaBeginLongPress = self.CreateAction(self, "OnRightBtnPress")
	self.bindData.leftBtn.luaBeginLongPress = self.CreateAction(self, "OnLeftBtnPress")
end

M.OnSimpleRenderPathListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local pathState = self.pathState[index + 1]
	store.statusCtrl = pathState and pathState.state or self.PATH_STATE.EMPTY

	if pathState and pathState.direction ~= self.DIRECTION.LEFT then
		store.content = "Q"
	else
		store.content = "E"
	end
end

M.OnRightBtnPress = function(self)
	self.PressDirection(self, self.DIRECTION.RIGHT)
end

M.OnLeftBtnPress = function(self)
	self.PressDirection(self, self.DIRECTION.LEFT)
end

M.InitPathInfo = function(self)
	self.pathSequence = {
		0,
		1,
		1,
		0,
		1
	}
	self.pathState = {}

	for i = 1, #self.pathSequence do
		table.insert(self.pathState, {
			direction = self.pathSequence[i],
			state = self.PATH_STATE.EMPTY
		})
	end

	if self.pathState[1] then
		self.pathState[1].state = self.PATH_STATE.SELECT
	end

	self.canInput = true

	self.bindData.pathList:SetSimpleList(#self.pathState)

	self.curSelectIndex = 1
	local clipName = "S_vx_SaiMoWeapon_Demo2_Open"
	local clip = self.bindData.successAnim:GetClip(clipName)

	if clip then
		self.bindData.successAnim:Play(clipName)
	end
end

M.PressDirection = function(self, direction)
	if not self.canInput then
		return
	end

	local selectState = self.pathState[self.curSelectIndex]

	if selectState then
		if selectState.direction ~= direction then
			selectState.state = self.PATH_STATE.TICK
			self.curSelectIndex = self.curSelectIndex + 1

			if self.updateTimer then
				self.updateTimer:Stop()

				self.updateTimer = nil
			end

			if self.curSelectIndex <= #self.pathState then
				local clipName = "S_vx_SaiMoWeapon_Demo2_Sucess"
				local clip = self.bindData.successAnim:GetClip(clipName)

				if clip then
					self.bindData.successAnim:Play(clipName)

					self.timer = Timer.New(function ()
						self.timer = nil

						gPanelManager:Close(gPanelId.SAI_MO_WEAPON_PANEL)
					end, clip.length):Start()
				else
					gPanelManager:Close(gPanelId.SAI_MO_WEAPON_PANEL)
				end

				gMessageManager:SendMessage(gEventConstants.ON_SAI_MO_WEAPON_GAME_SUCCESS)
			else
				self.pathState[self.curSelectIndex].state = self.PATH_STATE.SELECT
			end
		else
			self.canInput = false
			selectState.state = self.PATH_STATE.MISS

			if self.updateTimer then
				self.updateTimer:Stop()
			end

			self.updateTimer = Timer.New(function ()
				self.canInput = true
				self.updateTimer = nil

				if #self.pathState <= 1 then
					for i = 2, #self.pathState do
						self.pathState[i].state = self.PATH_STATE.EMPTY
					end
				end

				self.curSelectIndex = 1
				self.pathState[self.curSelectIndex].state = self.PATH_STATE.SELECT

				self.bindData.pathList:RefreshList()
			end, 0.3):Start()
		end
	end

	self.bindData.pathList:RefreshList()
end

M.StopAllTimer = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	if self.updateTimer then
		self.updateTimer:Stop()

		self.updateTimer = nil
	end
end
