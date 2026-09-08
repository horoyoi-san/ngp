-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RoguelikeStartPanelStore.lua
-- Decompiled from: 00860_RoguelikeStartPanelStore.lua_d4f14539779b.luajit

C_RoguelikeStartPanelStore = DefClass("C_RoguelikeStartPanelStore", C_RoguelikeStartPanelStore, C_StoreGroup)
GroupName2Class.RoguelikeStartPanelStore = C_RoguelikeStartPanelStore
local M = C_RoguelikeStartPanelStore
local RogueRaidConfig = LTConfig.RogueRaidConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.TEMPLATE_INDEX = {
		["y\\x87\\x96\\x83\\x93"] = 0,
		["jsIDq28!"] = 4,
		["\\xfa\\xf4:);\n\\xc5"] = 1,
		["wbT]q9#7"] = 3,
		["~\\x9e\\x8e\\x86\\x82"] = 2
	}
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
	self.InitRoguelikeInfo(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.goBtn.luaClick = self.CreateAction(self, self.OnClickGoBtn)
	self.bindData.talentBtn.luaClick = self.CreateAction(self, self.OnClickTalentBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.contentList.onGetTIndex = self.CreateAction(self, self.OnGetContentListTIndex)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderContentListItem)
	self.bindData.contentList.luaDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderContentListItem)
end

M.OnClickGoBtn = function(self)
	local id = self.tabData[self.currentTab].id
	local rogueConfig = RogueRaidConfig.GetConfig(id)

	if rogueConfig and rogueConfig.RaidId <= 0 then
		gRoguelikeManager:EnterRogueLikeGame(id)
	end
end

M.OnClickTalentBtn = function(self)
	gDialogScriptFunc.ShowCommonGameplayTalentTree(5)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderContentListItem = function(self, btn, index)
	local data = self.rightListData[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= self.TEMPLATE_INDEX.SPLIT then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= self.TEMPLATE_INDEX.ITEM_LIST then
		store.list.luaSimpleRenderItem = function(rewardBtn, rewardIndex)
			local awardId = self.rewardItemList[rewardIndex + 1]
			local renderData = gCommonItemManager:GetItemRenderData({
				itemId = awardId
			})

			gCommonItemManager:OnCommonItemRender(rewardBtn, rewardIndex, renderData)
		end

		store.list:SetSimpleList(#self.rewardItemList)
	else
		store:Commit("content", data.content or "", COMMIT_IMMEDIATELY)
	end
end

M.OnGetContentListTIndex = function(self, index)
	local data = self.rightListData[index + 1]

	if not data then
		return 0
	end

	return data.tIndex or 0
end

M.InitRoguelikeInfo = function(self)
	self.tabData = {}

	for i = 0, RogueRaidConfig.count - 1 do
		local rogueConfig = RogueRaidConfig.LoadAt(i)
		local unlock = rogueConfig.SystemUnlockId ~= 0 or gSystemUnlockMgr:IsUnlock(rogueConfig.SystemUnlockId)

		table.insert(self.tabData, {
			id = rogueConfig.Id,
			unlock = unlock,
			title = rogueConfig.DifficultyTitle
		})
	end

	self.currentTab = 0

	self.SubGroup.CommonTabSingleStore:SetData(self.tabData, nil, self.currentTab, nil, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderCallback))
end

M.OnRenderCallback = function(self, btn, index, itemData, store, isSub, uList)
	btn.interactable = itemData.unlock
end

M.OnChangeTab = function(self, uList, isSub)
	self.currentTab = uList.selectedIndex + 1

	self.RefreshRightContent(self, self.tabData[self.currentTab].id)
end

M.RefreshRightContent = function(self, id)
	local rogueConfig = RogueRaidConfig.GetConfig(id)

	if rogueConfig then
		self.bindData.name = rogueConfig.Name
		local formatText = TextScriptTextConfig.GetConfig(89901557).Text
		self.bindData.difficulty = string.format(formatText, rogueConfig.DifficultyTitle)
		self.bindData.icon = rogueConfig.Icon
		self.rightListData = {
			{
				tIndex = self.TEMPLATE_INDEX.TEXT_GREY,
				content = rogueConfig.Description
			},
			{
				tIndex = self.TEMPLATE_INDEX.TITLE,
				content = TextScriptTextConfig.GetConfig(89901556).Text
			},
			{
				tIndex = self.TEMPLATE_INDEX.CONTENT,
				content = rogueConfig.DifficultyDescription
			},
			{
				tIndex = self.TEMPLATE_INDEX.SPLIT
			},
			{
				tIndex = self.TEMPLATE_INDEX.TITLE,
				content = TextScriptTextConfig.GetConfig(89900352).Text
			},
			{
				tIndex = self.TEMPLATE_INDEX.ITEM_LIST
			}
		}
		self.rewardItemList = {}

		if #rogueConfig.Reward <= 0 then
			for i = 1, #rogueConfig.Reward do
				table.insert(self.rewardItemList, rogueConfig.Reward[i])
			end
		end
	end

	self.bindData.contentList:SetSimpleList(#self.rightListData)
end
