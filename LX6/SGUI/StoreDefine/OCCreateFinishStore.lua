-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCCreateFinishStore.lua
-- Decompiled from: 00938_OCCreateFinishStore.lua_f7fdaa4e0b3e.luajit

local Consts = gClientConst
C_OCCreateFinishStore = DefClass("C_OCCreateFinishStore", C_OCCreateFinishStore, C_StoreGroup)
GroupName2Class.OCCreateFinishStore = C_OCCreateFinishStore
local M = C_OCCreateFinishStore

M.ctor = function(self)
	self.mgr = gOCMgr
	self.parentStore = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.inPhotoEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.inPhotoEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	self.m_Id = panelId

	self.RefreshPage(self)
end

M.OnClose = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.shareBtn.luaClick = self.CreateAction(self, self.OnClickShareBtn)
	self.bindData.tagList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTagItem)
end

M.OnClickConfirmBtn = function(self)
	slot1 = self.mgr

	slot1:OnFinish(function ()
		gPanelManager:Close(self.m_Id)
	end)
end

M.OnClickShareBtn = function(self)
	self.bindData.inPhoto = Consts.BOOL2CTL[true]
	self.parentStore.bindData.inPhoto = Consts.BOOL2CTL[true]
	slot1 = self.mgr

	slot1:BeginShare(function ()
		self.bindData.inPhoto = Consts.BOOL2CTL[false]
		self.parentStore.bindData.inPhoto = Consts.BOOL2CTL[false]
	end)
end

M.RefreshPage = function(self)
	self.bindData.nameLabel = self.mgr.baseData.name
	self.bindData.descLabel = self.mgr.personalityAndStory.desc
	local mbtiCfg = self.mgr:GetMBTI()

	if mbtiCfg then
		self.bindData.mbTiImg = mbtiCfg.Image
	end

	local labels = self.mgr.personalityAndStory and self.mgr.personalityAndStory.labels or {}

	self.bindData.tagList:SetSimpleList(#labels)
end

M.OnRenderTagItem = function(self, btn, index)
	local labels = self.mgr.personalityAndStory and self.mgr.personalityAndStory.labels or {}
	local label = labels[index + 1]

	if not label then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.text = label
		store.typeCtrl = 0
		store.delCtrl = 0
	end
end
