-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonWindowInfoStore.lua
-- Decompiled from: 01542_CommonWindowInfoStore.lua_cdb0151304c1.luajit

local MessageExplainConfig = LTConfig.MessageExplainConfig
C_CommonWindowInfoStore = DefClass("C_CommonWindowInfoStore", C_CommonWindowInfoStore, C_StoreGroup)
GroupName2Class.CommonWindowInfoStore = C_CommonWindowInfoStore
local M = C_CommonWindowInfoStore

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
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if not data then
		self.OnClickBackBtn(self)
		print_error("CommonWindowInfoStore:OnShow data is nil")

		return
	end

	self.closeCallback = data.closeCallback

	self.bindData.contentList:InitSimpleList()

	if data.id then
		local cfg = MessageExplainConfig.GetConfig(data.id)

		if not cfg then
			self.OnClickBackBtn(self)
			print_error("CommonWindowInfoStore:OnShow config not found for id: " .. tostring(data.id))

			return
		end

		self.bindData.titleLabel = cfg.Title
		local showList = gUIUtils:parseTitlesAndContents(cfg.Content)

		if table.isNilOrEmpty(showList) then
			self.bindData.contentList:AddSimpleLabel(1, cfg.Content)
		else
			for i = 1, #showList do
				if not string.is_null_or_empty(showList[i].title) then
					self.bindData.contentList:AddSimpleLabel(0, showList[i].title)
				end

				if not string.is_null_or_empty(showList[i].content) then
					self.bindData.contentList:AddSimpleLabel(1, showList[i].content)
				end
			end
		end
	else
		self.bindData.titleLabel = data.title or ""

		if data.content then
			for i = 1, #data.content do
				if not string.is_null_or_empty(data.content[i].title) then
					self.bindData.contentList:AddSimpleLabel(0, data.content[i].title)
				end

				if not string.is_null_or_empty(data.content[i].desc) then
					self.bindData.contentList:AddSimpleLabel(1, data.content[i].desc)
				end
			end
		end
	end

	self.bindData.contentList:RefreshList()

	if not gCS.LuaUtils.IsNull(self.bindData.anim) then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, "S_Vx_NewCommonWindow_Open")
	end
end

M.OnClose = function(self)
	if self.closeCallback then
		self.closeCallback()

		self.closeCallback = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.OnClickBackBtn = function(self)
	if not gCS.LuaUtils.IsNull(self.bindData.anim) then
		gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_NewCommonWindow_Close", self.m_Id)
	else
		gPanelManager:Close(self.m_Id)
	end
end
