-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InterrogationPanelStore.lua
-- Decompiled from: 01816_InterrogationPanelStore.lua_b7f406e2be83.luajit

C_InterrogationPanelStore = DefClass("C_InterrogationPanelStore", C_InterrogationPanelStore, C_StoreGroup)
GroupName2Class.InterrogationPanelStore = C_InterrogationPanelStore
local M = C_InterrogationPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
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
	if data and data.clearData then
		gGadgetManager:ClearInterrogation()
	end

	if not gGadgetManager:CanInterrogation() then
		gPanelManager:Close(gPanelId.S_INTERROGATION)
		print_error("CanInterrogation false 没有可审问道具")

		return
	end

	self.curSelect = 0

	self.OnClickRight(self)

	self.bindData.leftBtn.luaClick = self.CreateAction(self, self.OnClickLeft)
	self.bindData.rightBtn.luaClick = self.CreateAction(self, self.OnClickRight)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirm)
	self.bindData.confirmBtn2.luaClick = self.CreateAction(self, self.OnClickConfirm)
end

M.OnClose = function(self)
end

M.OnClickRight = function(self)
	local newIndex = gGadgetManager:GetNextInterrogation(self.curSelect, true)

	if newIndex ~= self.curSelect then
		return
	end

	self.curSelect = newIndex

	gMessageManager:SendMessage(gEventConstants.SELECT_SHEEP, self.curSelect)
	gCS.BaseUnitModuleUtils.SetTortureLambBlendParam(self.curSelect)
end

M.OnClickConfirm = function(self)
	local success = gGadgetManager:OnSelectInterrogation(self.curSelect)

	if success then
		gMessageManager:SendMessage(gEventConstants.SELECT_SHEEP, "")
	else
		print_error("OnSelectInterrogation false 当前选择道具已拿走，不可使用")
	end
end

M.OnClickLeft = function(self)
	local newIndex = gGadgetManager:GetNextInterrogation(self.curSelect, false)

	if newIndex ~= self.curSelect then
		return
	end

	self.curSelect = newIndex

	gMessageManager:SendMessage(gEventConstants.SELECT_SHEEP, self.curSelect)
	gCS.BaseUnitModuleUtils.SetTortureLambBlendParam(self.curSelect)
end

M.OnActiveDeviceChange = function(self, device)
end
