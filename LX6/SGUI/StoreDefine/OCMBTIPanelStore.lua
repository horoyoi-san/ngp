-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCMBTIPanelStore.lua
-- Decompiled from: 00948_OCMBTIPanelStore.lua_ba78572abe9c.luajit

local MBTIConfig = LTConfig.OriginalCharacterMBTIConfig
C_OCMBTIPanelStore = DefClass("C_OCMBTIPanelStore", C_OCMBTIPanelStore, C_StoreGroup)
GroupName2Class.OCMBTIPanelStore = C_OCMBTIPanelStore
local M = C_OCMBTIPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.mbtiList = {}
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
	self.panelId = panelId
	self.mbtiList = {}

	for i = 0, MBTIConfig.count - 1 do
		local config = MBTIConfig.LoadAt(i)

		table.insert(self.mbtiList, config)
	end

	self.bindData.mbtiList:SetSimpleList(#self.mbtiList)

	self.curMBTI = gOCMgr.MBTIId

	if self.curMBTI then
		for i, cfg in ipairs(self.mbtiList) do
			if cfg.Id ~= self.curMBTI then
				self.bindData.mbtiList:SetItemSelected(i - 1, true)

				break
			end
		end
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.clearBtn.luaClick = self.CreateAction(self, self.OnClickClearBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.mbtiList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderMbtiListItem)
	self.bindData.mbtiList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickMbtiList)
end

M.OnClickClearBtn = function(self)
	self.curMBTI = nil

	if self.bindData.mbtiList.selectedIndex == -1 then
		local curIndex = self.bindData.mbtiList.selectedIndex

		self.bindData.mbtiList:SetItemSelected(curIndex, false)
	end
end

M.OnClickBackBtn = function(self)
	if self.panelId then
		gPanelManager:Close(self.panelId)

		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_OC_MBTI_CHANGE)
end

M.OnClickConfirmBtn = function(self)
	gOCMgr:SetMBTIId(self.curMBTI)

	if self.panelId then
		gPanelManager:Close(self.panelId)

		return
	end
end

M.OnSimpleRenderMbtiListItem = function(self, btn, index)
	local data = self.mbtiList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.Title
	store.desc = data.Desc1 .. "\n" .. data.Desc2 .. "\n" .. data.Desc3
	store.image = data.Image
	store.type = data.MBTI

	if btn.SetSelected then
		btn:SetSelected(data.Id ~= self.curMBTI)
	else
		btn.isSelected = data.Id ~= self.curMBTI
	end
end

M.OnSimpleClickMbtiList = function(self, btn, index)
	self.curMBTI = self.mbtiList[index + 1].Id

	if not self.panelId then
		gOCMgr:SetMBTIId(self.curMBTI)
		gMessageManager:SendMessage(gEventConstants.ON_OC_MBTI_CHANGE)
	end
end
