-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BeggarPaintingPanelStore.lua
-- Decompiled from: 01673_BeggarPaintingPanelStore.lua_c2d3feb52b9d.luajit

C_BeggarPaintingPanelStore = DefClass("C_BeggarPaintingPanelStore", C_BeggarPaintingPanelStore, C_StoreGroup)
GroupName2Class.BeggarPaintingPanelStore = C_BeggarPaintingPanelStore
local M = C_BeggarPaintingPanelStore
local BeggarDrawToolConfig = LTConfig.BeggarDrawToolConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.openAnimeName = "S_Vx_TimerPanel_open"
	self.alertAnimeName = "S_Vx_TimerPanel_red10s"
	self.closeAnimeName = "S_Vx_TimerPanel_close"
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
	self.bindData.undoBtn.luaClick = self.CreateAction(self, "OnClickUndoBtn")
	self.bindData.redoBtn.luaClick = self.CreateAction(self, "OnClickRedoBtn")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnClickConfirmBtn")
end

M.OnClickUndoBtn = function(self)
	self.bindData.drawingBoard:Undo()
	self:RefreshButtonState()
end

M.OnClickRedoBtn = function(self)
	self.bindData.drawingBoard:Redo()
	self:RefreshButtonState()
end

M.OnClickClearBtn = function(self)
	self.bindData.drawingBoard:Clear()
	self:RefreshButtonState()
end

M.OnClickConfirmBtn = function(self)
	local info = {
		drawOperationNum = self.bindData.drawingBoard:GetDrawOperationNum(),
		useColorNum = self.bindData.drawingBoard:GetUseColorNum(),
		base64 = self.bindData.drawingBoard:ExportToBase64()
	}

	gBeggarManager:AskCompletePaintTask(info)
end

M.ShowPanel = function(self, data)
	self.bindData.drawingBoard:ReInitialize()
	self:RefreshButtonState()
	self.SubGroup.PaintingToolStore:InitData(0, self:CreateAction(self.OnColorChangedCallback), self:CreateAction(self.OnBrushThicknessChangedCallback), self:CreateAction(self.OnBrushChangedCallback), self:CreateAction(self.OnEraserSelectCallback), self:CreateAction(self.OnClickClearBtn))
	gBeggarManager:RefreshPaintingTaskContent(self.bindData.task)
end

M.OnColorChangedCallback = function(self, hex)
	self.isEraser = false
	self.colorHex = hex

	self.bindData.drawingBoard:SetBrushColor(Color.NewByStr(hex))
end

M.OnBrushThicknessChangedCallback = function(self, px)
	self.bindData.drawingBoard:SetBrushSize(px)
end

M.OnBrushChangedCallback = function(self, id)
	local brushCfg = BeggarDrawToolConfig.GetConfig(id)

	if brushCfg then
		self.bindData.drawingBoard:TrySetBrushByName(brushCfg.Name)
	end
end

M.OnEraserSelectCallback = function(self, isEraser)
	self.isEraser = isEraser
	local color = self.isEraser and Color.New(1, 1, 1, 1) or Color.NewByStr(self.colorHex)

	self.bindData.drawingBoard:SetBrushColor(color)
end

M.OnUpdate = function(self)
	self.RefreshButtonState(self)
end

M.RefreshButtonState = function(self)
	self.bindData.redoBtn.interactable = self.bindData.drawingBoard:CanRedo()
	self.bindData.undoBtn.interactable = self.bindData.drawingBoard:CanUndo()
	self.bindData.confirmBtn.interactable = self.bindData.drawingBoard:GetDrawOperationNum() >= 0
	self.bindData.controllerEmptyCtrl = self.bindData.drawingBoard:CanUndo() and 0 or 1
end
