-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefSeasoningStore.lua
-- Decompiled from: 01424_ChefSeasoningStore.lua_b23d25144c44.luajit

local ChefSeasoningConfig = LTConfig.ChefSeasoningConfig
C_ChefSeasoningStore = DefClass("C_ChefSeasoningStore", C_ChefSeasoningStore, C_StoreGroup)
GroupName2Class.ChefSeasoningStore = C_ChefSeasoningStore
local M = C_ChefSeasoningStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.seasoningId = 0
	self.game = nil
	self.closeCb = nil
	self.mouseAction = nil
	self.lastTouch = nil
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
	self.ClearInput(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.interactBtn.luaClick = self.CreateAction(self, "OnClickInteractBtn")
	self.bindData.seasonBtn.luaBeginLongPress = self.CreateAction(self, "OnBeginLongPressSeasonBtn")
	self.bindData.seasonBtn.luaEndLongPress = self.CreateAction(self, "OnEndLongPressSeasonBtn")
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, "OnClickCancelBtn")
end

M.OnClickInteractBtn = function(self)
end

M.OnBeginLongPressSeasonBtn = function(self)
	if self.seasoningType ~= ChefSeasoningConfig.CondimentTypeType.powder then
		self.game:SprinkleSeasoning()
	elseif self.seasoningType ~= ChefSeasoningConfig.CondimentTypeType.liquid then
		self.game:StartPourSeasoning()
	end
end

M.OnEndLongPressSeasonBtn = function(self)
	if self.seasoningType ~= ChefSeasoningConfig.CondimentTypeType.liquid then
		self.game:StopPourSeasoning()
	end
end

M.OnClickCancelBtn = function(self)
	self.game:DestroySeasoningBottle()

	self.game = nil

	if self.closeCb then
		self.closeCb()
	end
end

M.SetData = function(self, data)
	self.seasoningId = data.seasoningId

	if self.seasoningId ~= 0 then
		print_error("无效的seasoningId !", self.seasoningId)
	end

	self.seasoningType = ChefSeasoningConfig.GetConfig(self.seasoningId).CondimentType
	self.game = data.game
	self.closeCb = data.closeCb

	self:InitInput()
	self.game:CreateSeasoningBottle(self.seasoningId)
end

M.InitInput = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.mouseAction = self:CreateAction("MouseMovePlay")

		gMessageManager:AddMessageListener(gEventConstants.MOUSE_MOVE, self.mouseAction)
	else
		self.bindData.interactBtn.onDrag = self.CreateAction(self, "DragMovePlay")

		self.bindData.interactBtn.onBeginDrag = function()
			self.lastTouch = gUtils:GetTouchPosition()
		end

		self.bindData.interactBtn.onEndDrag = function()
			self.lastTouch = nil
		end
	end
end

M.ClearInput = function(self)
	if self.mouseAction then
		gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.mouseAction)
	end
end

M.MouseMovePlay = function(self, _, data)
	local x = data.x
	local y = data.y

	self.HandleInput(self, x, y)
end

M.DragMovePlay = function(self, delta)
	local x = delta.x
	local y = delta.y

	self.HandleInput(self, x, y)
end

M.HandleInput = function(self, x, y)
	self.hasInput = true

	if self.game then
		self.game:UpdateSeasoningPosition(y * 0.001, -x * 0.001)
	end
end
