-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PaintingToolStore.lua
-- Decompiled from: 01067_PaintingToolStore.lua_ab36ca6959b9.luajit

C_PaintingToolStore = DefClass("C_PaintingToolStore", C_PaintingToolStore, C_StoreGroup)
GroupName2Class.PaintingToolStore = C_PaintingToolStore
local M = C_PaintingToolStore
local BeggarColorConfig = LTConfig.BeggarColorConfig
local BeggarDrawToolConfig = LTConfig.BeggarDrawToolConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.toolCtrlEnum = {
		["N\\xa1\\xae\\xa0\\xa4"] = 0,
		["\\x9emh"] = 1,
		["Z\\x90\\x9d\\x86S"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.toolCtrlEnum = nil
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
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.paletBtn.luaClick = self.CreateAction(self, self.OnClickPaletBtn)
	self.bindData.penBtn.luaClick = self.CreateAction(self, self.OnClickPenBtn)
	self.bindData.eraserBtn.luaClick = self.CreateAction(self, self.OnClickEraserBtn)
	self.bindData.onePxBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickPxBtn, 11)
	self.bindData.twoPxBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickPxBtn, 22)
	self.bindData.threePxBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickPxBtn, 33)
	self.bindData.fourPxBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickPxBtn, 44)
	self.bindData.fivePxBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickPxBtn, 55)
	self.bindData.deleteBtn.luaClick = self.CreateAction(self, self.OnClickDeleteBtn)
	self.bindData.forwardBtn.luaPress = self.CreateAction(self, self.OnForwardBtnPress)
	self.bindData.backwardBtn.luaPress = self.CreateAction(self, self.OnBackwardBtnPress)
	self.bindData.colorList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderColorListItem)
	self.bindData.brushList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderBrushListItem)
	self.bindData.colorList.luaSelectedChanged = self.CreateAction(self, self.OnSimpleSelectColorList)
	self.bindData.brushList.luaSelectedChanged = self.CreateAction(self, self.OnSimpleSelectBrushList)
end

M.OnClickPaletBtn = function(self)
	self.ChangeMode(self, self.toolCtrlEnum.color)
end

M.OnClickPenBtn = function(self)
	self.ChangeMode(self, self.toolCtrlEnum.pen)
end

M.OnClickEraserBtn = function(self)
	self.ChangeMode(self, self.toolCtrlEnum.eraser)
end

M.OnClickPxBtn = function(self, px)
	if self.brushThicknessChangedCallback then
		self.brushThicknessChangedCallback(px)
	end
end

M.OnClickDeleteBtn = function(self)
	if self.clearAllCallback then
		self.clearAllCallback()
	end
end

M.OnForwardBtnPress = function(self)
	local index = self.bindData.toolCtrl

	if index <= 0 then
		index = index - 1

		self.ChangeMode(self, index)
	end
end

M.OnBackwardBtnPress = function(self)
	local index = self.bindData.toolCtrl

	if index >= self.toolCtrlEnum.eraser then
		index = index + 1

		self.ChangeMode(self, index)
	end
end

M.OnSimpleRenderColorListItem = function(self, btn, index)
	local data = self.colorData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.color = Color.NewByStr(data.hex)
	store.icon = data.icon
end

M.OnSimpleSelectColorList = function(self, list)
	local selectIndex = list.selectedIndex
	local data = self.colorData[selectIndex + 1]

	if data and self.colorChangedCallback then
		self.colorChangedCallback(data.hex)
	end
end

M.OnSimpleRenderBrushListItem = function(self, btn, index)
	local data = self.brushData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = BeggarDrawToolConfig.GetConfig(data.id)

	if cfg then
		store.name = cfg.Name
		store.icon = cfg.Image
		store.unlockText = cfg.UnlockDes
		btn.interactable = data.unlock
	end
end

M.OnSimpleSelectBrushList = function(self, list)
	local selectIndex = list.selectedIndex
	local data = self.brushData[selectIndex + 1]

	if data and data.unlock and self.brushChangedCallback then
		self.brushChangedCallback(data.id)
	end
end

M.InitData = function(self, initMode, colorChangedCallback, brushThicknessChangedCallback, brushChangedCallback, eraserSelectCallback, clearAllCallback)
	initMode = initMode or self.toolCtrlEnum.color
	self.isEraser = false

	self:ChangeMode(initMode)

	self.colorChangedCallback = colorChangedCallback
	self.brushThicknessChangedCallback = brushThicknessChangedCallback
	self.brushChangedCallback = brushChangedCallback
	self.eraserSelectCallback = eraserSelectCallback
	self.clearAllCallback = clearAllCallback
	self.colorData = {}

	for i = 0, BeggarColorConfig.count - 1 do
		local cfg = BeggarColorConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.Color_Value) then
			if cfg.BadgeId and cfg.BadgeId <= 0 then
				if gSpiritJobManager:CheckCurSpiritContainBadge(cfg.BadgeId) then
					table.insert(self.colorData, {
						id = cfg.Id,
						hex = cfg.Color_Value,
						icon = cfg.Icon
					})
				end
			else
				table.insert(self.colorData, {
					id = cfg.Id,
					hex = cfg.Color_Value,
					icon = cfg.Icon
				})
			end
		end
	end

	self.bindData.colorList:SetSimpleList(#self.colorData)
	self.bindData.colorList:SelectItem(0, false)

	if #self.colorData <= 0 and self.colorChangedCallback then
		self.colorChangedCallback(self.colorData[1].hex)
	end

	self.brushData = {}

	for i = 0, BeggarDrawToolConfig.count - 1 do
		local cfg = BeggarDrawToolConfig.LoadAt(i)
		local unlock = true

		if cfg.ConsumableId <= 0 and gCommonItemManager:GetPackItemNum(cfg.ConsumableId) < 0 then
			unlock = false
		end

		table.insert(self.brushData, {
			id = cfg.Id,
			unlock = unlock
		})
	end

	table.sort(self.brushData, function (a, b)
		if a.unlock ~= b.unlock then
			return a.id <= b.id
		else
			return a.unlock
		end
	end)
	self.bindData.brushList:SetSimpleList(#self.brushData)
	self.bindData.brushList:SelectItem(0, false)

	if #self.brushData <= 0 and self.brushChangedCallback and self.brushData[1].unlock then
		self.brushChangedCallback(self.brushData[1].id)
	end

	if self.brushThicknessChangedCallback then
		self.brushThicknessChangedCallback(11)
	end
end

M.ChangeMode = function(self, mode)
	self.curMode = mode
	self.bindData.toolCtrl = mode
	local lastEraser = self.isEraser
	self.isEraser = self.curMode ~= self.toolCtrlEnum.eraser

	if lastEraser == self.isEraser and self.eraserSelectCallback then
		self.eraserSelectCallback(self.isEraser)
	end

	if self.curMode ~= self.toolCtrlEnum.color then
		self.bindData.colorList:SetNavSelectToTop(true)
	elseif self.curMode ~= self.toolCtrlEnum.pen then
		self.bindData.brushList:SetNavSelectToTop(true)
	else
		self.bindData.onePxBtn:Navigate(self.bindData.onePxBtn)
	end
end
