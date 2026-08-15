C_UrbanAbilityChatGroupPanelStore = DefClass("C_UrbanAbilityChatGroupPanelStore", C_UrbanAbilityChatGroupPanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityChatGroupPanelStore = C_UrbanAbilityChatGroupPanelStore
local M = C_UrbanAbilityChatGroupPanelStore

function M:ctor()
	self.CHAT_TYPE = {
		System = 3,
		MyChat = 2,
		OtherChat = 1
	}
end

function M:OnAwake()
	self.bindData.list.luaRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.closeChatBtn.luaClick = self:CreateAction("OnBackBtnClick")
end

function M:OnEnable()
	self.bindData.num = #gUrbanAbilityManager:GetAllLingList()

	self:InitGroupList()
end

function M:InitGroupList()
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

	self.bindData.list:SetList(list)
end

function M:OnRenderItem(btn, _, data)
	local store = nil
	local type = data.tIndex + 1

	if type == self.CHAT_TYPE.System then
		store = gStoreManager:GetStoreGroup("UrbanAbilityChatInviteTemplateStore"):GetStoreByWidget(btn)
		store.msg = data.cfg.ChatDialog

		return
	end

	if type == self.CHAT_TYPE.OtherChat then
		store = gStoreManager:GetStoreGroup("UrbanAbilityChatTextTemplateLStore"):GetStoreByWidget(btn)
	elseif type == self.CHAT_TYPE.MyChat then
		store = gStoreManager:GetStoreGroup("UrbanAbilityChatTextTemplateRStore"):GetStoreByWidget(btn)
	else
		return
	end

	store.content = data.cfg.ChatDialog
	local fsId = 0

	if #data.cfg.FightSpiritId > 1 then
		fsId = data.cfg.FightSpiritId[gPlayerManager.infoLogin.bindData.sexType]
	else
		fsId = data.cfg.FightSpiritId[1]
	end

	local cfg = LTConfig.FightSpiritConfig.GetConfig(fsId)
	store.icon = cfg.SHeadIconID
end

function M:OnBackBtnClick()
	self.bindData.panel:SetActive(false)
end
