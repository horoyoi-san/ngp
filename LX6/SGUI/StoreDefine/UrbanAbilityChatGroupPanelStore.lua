-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityChatGroupPanelStore.lua
-- Decompiled from: 01199_UrbanAbilityChatGroupPanelStore.lua_5f76a0245f41.luajit

C_UrbanAbilityChatGroupPanelStore = DefClass("C_UrbanAbilityChatGroupPanelStore", C_UrbanAbilityChatGroupPanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityChatGroupPanelStore = C_UrbanAbilityChatGroupPanelStore
local M = C_UrbanAbilityChatGroupPanelStore

M.ctor = function(self)
	self.CHAT_TYPE = {
		["/Q\\x82\\x9a\\x86L"] = 3,
		["1Q\\xb2\\x86\\x82U"] = 2,
		["lSdl\\=,"] = 1
	}
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")

	self.bindData.list.onGetTIndex = function(csIndex)
		return self._groupListData[csIndex + 1].tIndex
	end

	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.closeChatBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
end

M.OnEnable = function(self)
	self.bindData.num = #gUrbanAbilityManager:GetAllLingList()

	self:InitGroupList()
end

M.InitGroupList = function(self)
	local list = {}
	local spiritGroupChatList = gUrbanAbilityManager:GetSpiritGroupChatInfos()

	for i, v in pairs(spiritGroupChatList) do
		local cfg = LTConfig.FightSpiritGroupChatConfig.GetConfig(v.Id)

		if cfg then
			local info = {
				id = v.Id,
				selected = false,
				tIndex = cfg.ChatType - 1,
				cfg = cfg
			}

			table.insert(list, info)
		end
	end

	self._groupListData = list

	self.bindData.list:SetSimpleList(#self._groupListData)
end

M.OnRenderItem = function(self, btn, index)
	local data = self._groupListData[index + 1]
	local store = nil
	local type = data.tIndex + 1

	if type ~= self.CHAT_TYPE.System then
		store = gStoreManager:GetStoreGroup("UrbanAbilityChatInviteTemplateStore"):GetStoreByWidget(btn)
		store.msg = data.cfg.ChatDialog

		return
	end

	if type ~= self.CHAT_TYPE.OtherChat then
		store = gStoreManager:GetStoreGroup("UrbanAbilityChatTextTemplateLStore"):GetStoreByWidget(btn)
	elseif type ~= self.CHAT_TYPE.MyChat then
		store = gStoreManager:GetStoreGroup("UrbanAbilityChatTextTemplateRStore"):GetStoreByWidget(btn)
	else
		return
	end

	store.content = data.cfg.ChatDialog
	local fsId = 0

	if #data.cfg.FightSpiritId <= 1 then
		fsId = data.cfg.FightSpiritId[gPlayerManager.infoLogin.bindData.sexType]
	else
		fsId = data.cfg.FightSpiritId[1]
	end

	local cfg = LTConfig.FightSpiritConfig.GetConfig(fsId)
	store.icon = cfg.SHeadIconID
end

M.OnBackBtnClick = function(self)
	self.bindData.panel:SetActive(false)
end
