-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleImageDetailPanel.lua
-- Decompiled from: 01627_BubbleImageDetailPanel.lua_130ed292b4c2.luajit

C_BubbleImageDetailPanel = DefClass("C_BubbleImageDetailPanel", C_BubbleImageDetailPanel, C_StoreGroup)
GroupName2Class.BubbleImageDetailPanel = C_BubbleImageDetailPanel
local M = C_BubbleImageDetailPanel

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
	gNewBubbleMgr:RenderImageDetail(self.bindData, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.downloadBtn.luaClick = self.CreateAction(self, "OnClickDownloadBtn")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickDownloadBtn = function(self)
	local tex = self.bindData.webTexture:GetCurrentTexture2D()

	if tex then
		local photoName = self.GeneratePhotoName(self)

		LX6.Utils.PhotoUtils.SavePhoto(tex, photoName)
	end
end

M.GeneratePhotoName = function(self)
	return "bubblePhoto_" .. os.date("%Y-%m-%d-%H-%M-%S")
end
