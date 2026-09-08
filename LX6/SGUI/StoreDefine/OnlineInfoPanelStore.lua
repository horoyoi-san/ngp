-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineInfoPanelStore.lua
-- Decompiled from: 01109_OnlineInfoPanelStore.lua_303f46103e5b.luajit

C_OnlineInfoPanelStore = DefClass("C_OnlineInfoPanelStore", C_OnlineInfoPanelStore, C_StoreGroup)
GroupName2Class.OnlineInfoPanelStore = C_OnlineInfoPanelStore
local M = C_OnlineInfoPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	local explainCfg = LTConfig.MessageExplainConfig.GetConfig(data.id)
	local showList = gUIUtils:ParseMessageExplain(explainCfg.Content)
	self.bindData.title = explainCfg.Title or ""

	self.bindData.list:InitSimpleList()

	for i = 1, #showList do
		self.bindData.list:AddSimpleLabel(0, showList[i].title)
		self.bindData.list:AddSimpleLabel(1, showList[i].content)
	end

	self.bindData.list:RefreshList()

	self.bindData.exitBtn.interactable = true

	if self.bindData.exitBtn2 then
		self.bindData.exitBtn2.interactable = true
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)

	if self.bindData.exitBtn2 then
		self.bindData.exitBtn2.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	end
end

M.OnClickExitBtn = function(self)
	if self.m_Id ~= nil or self.m_Id ~= 0 then
		print_error("这个界面没有 ID", gUtils.GetFindPath(self.rootWidget))

		return
	end

	self.bindData.exitBtn.interactable = false

	if self.bindData.exitBtn2 then
		self.bindData.exitBtn2.interactable = false
	end

	self.PlayCloseAnimAndClose(self)
end

M.PlayCloseAnimAndClose = function(self)
	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end

	local clip = self.bindData.panelAnimation and self.bindData.panelAnimation:GetClip("S_vx_InspireInfoPanel_close")
	local duration = clip and clip.length or 0

	if duration <= 0 then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_vx_InspireInfoPanel_close")

		self.closeTimer = Timer.New(function ()
			self.closeTimer = nil

			gPanelManager:Close(self.m_Id)
		end, duration):Start()
	else
		gPanelManager:Close(self.m_Id)
	end
end
