-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCDialogReviewStore.lua
-- Decompiled from: 01415_OCDialogReviewStore.lua_69b5dffdf8f1.luajit

local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_OCDialogReviewStore = DefClass("C_OCDialogReviewStore", C_OCDialogReviewStore, C_StoreGroup)
GroupName2Class.OCDialogReviewStore = C_OCDialogReviewStore
local M = C_OCDialogReviewStore

M.ctor = function(self)
	self.parentStore = nil
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
	self.allDialogItems = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.editmodeEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.editmodeEnum = nil
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
	self.bindData.titleLabel = gString.Format(TextScriptTextConfig.GetConfig(89901363).Text, self.mgr.baseData.name)
	slot3 = self.mgr

	slot3:GetSessionMemory(nil, function (res)
		self:RefreshPage(res)
	end)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.shareBtn.luaClick = self.CreateAction(self, self.OnClickShareBtn)
	self.bindData.deleteBtn.luaClick = self.CreateAction(self, self.OnClickDeleteBtn)
	self.bindData.editCloseBtn.luaClick = self.CreateAction(self, self.OnChangeEditMode)
	self.bindData.editBtn.luaClick = self.CreateAction(self, self.OnChangeEditMode)
	self.bindData.chatList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderChatListItem)
	self.bindData.chatList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderChatListItem)
end

M.OnClickExitBtn = function(self)
	self.parentStore:OnBack()
end

M.OnClickShareBtn = function(self)
end

M.OnClickDeleteBtn = function(self)
end

M.OnChangeEditMode = function(self)
	local isEditMode = self.bindData.editmode ~= self.editmodeEnum._true
	self.bindData.editmode = isEditMode and self.editmodeEnum._false or self.editmodeEnum._true
end

M.OnSimpleRenderChatListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.mgr:OnSimpleRenderDialogListItem(store, self.allDialogItems[index + 1])
end

M.RefreshPage = function(self, content)
	local infos = content.ToTable(content)
	self.allDialogItems = {}

	for i = 1, #infos do
		local ele = infos[i]

		if i == 1 then
			self.mgr:_AddDialogItem(self.allDialogItems, ele.SessionId, ele.Utterance, true)
		end

		self.mgr:_AddDialogItem(self.allDialogItems, ele.SessionId, ele.Reply, false)
	end

	self.bindData.chatList:SetSimpleList(#self.allDialogItems)
end
