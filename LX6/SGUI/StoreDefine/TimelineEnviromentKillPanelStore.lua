-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineEnviromentKillPanelStore.lua
-- Decompiled from: 01351_TimelineEnviromentKillPanelStore.lua_ee9b3f4d4f16.luajit

C_TimelineEnviromentKillPanelStore = DefClass("C_TimelineEnviromentKillPanelStore", C_TimelineEnviromentKillPanelStore, C_StoreGroup)
GroupName2Class.TimelineEnviromentKillPanelStore = C_TimelineEnviromentKillPanelStore
local M = C_TimelineEnviromentKillPanelStore

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
	local panelData = data.ToTable(data)

	self.SetAdaptive(self, panelData)
	self.SetPos(self, panelData)
	self.BindClickCb(self, panelData)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnUpdate = function(self)
	self.UpdatePos(self)
end

M.SetAdaptive = function(self, panelData)
	self.bindData.adaptive = panelData.adaptive
end

M.SetPos = function(self, panelData)
	self.posType = panelData.btn1_pos

	if self.posType ~= "Custom" then
		self.targetPos = panelData.btn1_customPos
		self.customPosOffset = panelData.btn1_customPosOffset
	else
		self.targetPos = self.bindData[self.posType]
	end

	if self.targetPos then
		if self.posType ~= "Custom" then
			local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRTParent, self.targetPos.position)
			self.bindData.BtnOffset.anchoredPosition = uiPos + self.customPosOffset
		else
			self.bindData.BtnOffset.anchoredPosition = self.targetPos.anchoredPosition
		end
	end
end

M.UpdatePos = function(self)
	if self.posType == "Custom" or gClientUtils.IsNil(self.targetPos) then
		return
	end

	local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRTParent, self.targetPos.position)

	if self.customPosOffset then
		self.bindData.BtnOffset.anchoredPosition = uiPos + self.customPosOffset
	else
		self.bindData.BtnOffset.anchoredPosition = uiPos
	end
end

M.BindClickCb = function(self, panelData)
	if self.bindData.Btn then
		self.bindData.Btn.luaClick = self.CreateAction(self, "OnBtnClick")
		self.bindData.MobileBtn.luaClick = self.CreateAction(self, "OnBtnClick")
	end
end

M.OnBtnClick = function(self)
	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)
end

M.PlayClickAnimByCS = function(self, btn2)
end

M.PlaySuccessEndAnim = function(self)
	return 0
end

M.PlaySuccessEndAnim2 = function(self)
	return 0
end

M.ClosePanelFailed = function(self)
	return 0
end

M.SetProgress0 = function(self, progress)
end

M.SetProgress1 = function(self, progress)
end
