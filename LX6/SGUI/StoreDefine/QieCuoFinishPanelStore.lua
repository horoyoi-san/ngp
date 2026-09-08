-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\QieCuoFinishPanelStore.lua
-- Decompiled from: 00803_QieCuoFinishPanelStore.lua_1b434bcde1a3.luajit

C_QieCuoFinishPanelStore = DefClass("C_QieCuoFinishPanelStore", C_QieCuoFinishPanelStore, C_StoreGroup)
GroupName2Class.QieCuoFinishPanelStore = C_QieCuoFinishPanelStore
local M = C_QieCuoFinishPanelStore

M.ctor = function(self)
	self.timer = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = {
		[":A\\x9f\\x87\\x90I"] = 0,
		["V-nO"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = nil
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
	self.bindData.typeCtrl = data.isFail and 1 or 0
	local animTime = nil

	if data.isFail then
		animeTime = self.bindData.openAnim:GetClip("S_vx_TaskTipPanel_Open").length

		self.bindData.openAnim:Play("S_vx_TaskTipPanel_Open")
	else
		animeTime = self.bindData.openAnim:GetClip("S_vx_TaskTipPanel_Finish").length

		self.bindData.openAnim:Play("S_vx_TaskTipPanel_Finish")
	end

	self.timer = Timer.New(function ()
		self.timer = nil

		gPanelManager:Close(gPanelId.QIE_CUO_FINISH_PANEL)
	end, animeTime or 2):Start()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
