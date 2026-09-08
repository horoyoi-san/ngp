-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineInteractionPanelStore.lua
-- Decompiled from: 01353_TimelineInteractionPanelStore.lua_1b8f30dd64cb.luajit

C_TimelineInteractionPanelStore = DefClass("C_TimelineInteractionPanelStore", C_TimelineInteractionPanelStore, C_StoreGroup)
GroupName2Class.TimelineInteractionPanelStore = C_TimelineInteractionPanelStore
local M = C_TimelineInteractionPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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

	self.SetPos(self, panelData)
	self.BindClickCb(self, panelData)
	self.SetText(self, panelData)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
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

M.SetText = function(self, panelData)
	self.bindData.buttonTip.text = self.GetTextById(self, panelData.textId)
	self.bindData.mobileTip.text = self.GetTextById(self, panelData.textId)
end

M.GetTextById = function(self, textId)
	if not textId or textId ~= 0 then
		return nil
	end

	local cfg = LTConfig.TextConfig.GetConfig(textId)

	if not cfg then
		return nil
	end

	return cfg.Text
end

M.BindClickCb = function(self, panelData)
	if self.bindData.Btn then
		self.bindData.Btn.luaClick = self.CreateAction(self, "OnBtnClick")
	end

	if self.bindData.MobileBtn then
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
