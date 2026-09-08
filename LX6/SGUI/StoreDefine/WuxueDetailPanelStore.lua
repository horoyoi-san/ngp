-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WuxueDetailPanelStore.lua
-- Decompiled from: 01265_WuxueDetailPanelStore.lua_fbcb648e2892.luajit

local FightSkillConfig = LTConfig.FightSkillConfig
local FightSkillTypeConfig = LTConfig.FightSkillFightSkillTypeConfig
local FightSkillTagConfig = LTConfig.FightSkillFightSkillTagConfig
local FightSkillGlossaryConfig = LTConfig.FightSkillFightSkillGlossaryConfig
C_WuxueDetailPanelStore = DefClass("C_WuxueDetailPanelStore", C_WuxueDetailPanelStore, C_StoreGroup)
GroupName2Class.WuxueDetailPanelStore = C_WuxueDetailPanelStore
local M = C_WuxueDetailPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.baseData = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.showSkillInfoCtrlEnum = {
		["F\\x90\\x8c\\x8fD"] = 1,
		["\\xdd\\xd2(\\xf4"] = 0
	}
	self.showSkillInfoUnlockCtrlEnum = {
		["9F\\x90\\x8c\\x8fD"] = 1,
		["\\xfd\\xd2(\\xf4"] = 0
	}
	self.styleQualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.wuxueCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.tabList = {}
	self.tabFightStyleAll = {}
	self.weaponSelectData = {
		["\\xf4\\x9f\\xe9\\xd2\\xe8\\xa1\\xe3\\x86%0"] = 0,
		["\\x8c1,:{\\x89h\\xd73\\xaf\\xa1"] = 0,
		tabFightStyleDict = {}
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showSkillInfoCtrlEnum = nil
	self.showSkillInfoUnlockCtrlEnum = nil
	self.styleQualityCtrlEnum = nil
	self.wuxueCtrlEnum = nil
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
	self.baseData = nil
	self.TOOLTIP_TEMPLATE = nil
	self.tabList = nil
	self.tabFightStyleAll = nil
	self.weaponSelectData = nil
end

M.OnGroupEnable = function(self)
	self.comboInfoRoot = self.GetStoreByWidget(self, self.bindData.comboInfo)
end

M.OnGroupDisable = function(self)
	self.comboInfoRoot = nil
end

M.OnShow = function(self, panelId, data)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.mobileMode = not gCS.LuaUtils.IsNonMobileAdaptive()

	table.clear(self.baseData)
	self:ShowRight(data)
end

M.ShowRight = function(self, data)
	self.fightSkillId = data.fightSkillId
	local fightSkillCfg = FightSkillConfig.GetConfig(self.fightSkillId)
	self.baseData.fightSkillCfg = fightSkillCfg

	if fightSkillCfg ~= nil then
		return
	end

	self.bindData.styleQualityCtrl = fightSkillCfg.Quality
	self.bindData.maName = fightSkillCfg.Name
	self.bindData.maDesc = fightSkillCfg.DetailDesc

	self.bindData.maHyperLinkNavigator.luaInitHyperLinkButton = function(hyperLinkBtn, action, text)
		local termId = action

		hyperLinkBtn.luaRenderTooltip = function(lockBtn, popIns, idx)
			local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

			if not popStore then
				return
			end

			local glossaryCfg = FightSkillGlossaryConfig.GetConfig(termId)

			if not glossaryCfg then
				return
			end

			popStore.title = glossaryCfg.TermName
			popStore.content = glossaryCfg.TermDesc
		end
	end

	self.bindData.detailHyperLinkNavigator.luaInitHyperLinkButton = function(hyperLinkBtn, action, text)
		local termId = action

		hyperLinkBtn.luaRenderTooltip = function(lockBtn, popIns, idx)
			local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

			if not popStore then
				return
			end

			local glossaryCfg = FightSkillGlossaryConfig.GetConfig(termId)

			if not glossaryCfg then
				return
			end

			popStore.title = glossaryCfg.TermName
			popStore.content = glossaryCfg.TermDesc
		end
	end

	self.bindData.tagTitle = FightSkillConfig.FightSkillGuideTagName
	self.comboInfoRoot.tagTitle = FightSkillConfig.FightSkillGuideDescName
	local tags = ""

	for i = 1, #FightSkillConfig.ComboTagNames do
		tags = tags .. FightSkillConfig.ComboTagNames[i]
	end

	self.bindData.tags = tags

	self.InitFightSkillUnlockByWuxueMap(self, fightSkillCfg, data.fromGallery)

	if not data.fromGallery then
		self.InitTab(self)
	end

	local tagDataList = {}

	for i = 1, #fightSkillCfg.TagId do
		local tagCfg = FightSkillTagConfig.GetConfig(fightSkillCfg.TagId[i])

		if tagCfg then
			table.insert(tagDataList, {
				name = tagCfg.TagName,
				quality = tagCfg.TagType
			})
		else
			table.insert(tagDataList, {
				["\\xc8\\xce0\\xe8"] = 0,
				["t#p^"] = ""
			})
		end
	end

	self.baseData.comboList = {}
	local comboInputArray = nil

	if self.mobileMode then
		comboInputArray = fightSkillCfg.ComboInputMobile
	elseif self.gamepadMode then
		comboInputArray = fightSkillCfg.ComboInputController
	else
		comboInputArray = fightSkillCfg.ComboInputPC
	end

	local comboConfig = fightSkillCfg.ComboConfig

	if comboInputArray and comboConfig then
		local comboDescArray = fightSkillCfg.ComboDesc or {}
		local unlockConditionDescArray = fightSkillCfg.UnlockConditionDesc or {}
		local count = math.min(#comboInputArray, #comboConfig)

		for i = 1, count do
			local item = {
				comboInput = comboInputArray[i],
				comboDesc = comboDescArray[i] or "",
				unlockConditionDesc = unlockConditionDescArray[i] or "",
				unlockCondition = comboConfig[i].unlockCondition,
				videoId = comboConfig[i].videoId,
				specialComboTag = comboConfig[i].specialComboTag,
				isRecommendCombo = comboConfig[i].isRecommendCombo
			}

			table.insert(self.baseData.comboList, item)
		end
	end

	self.bindData.comboList:SetSimpleList(#self.baseData.comboList)

	if #self.baseData.comboList <= 0 then
		self.bindData.comboList:SelectItem(0, true)
		self:OnComboListItemClick(1)
	end
end

M.InitTab = function(self)
end

M.OnClose = function(self)
	self.gamepadMode = nil
	self.mobileMode = nil
	self.fightSkillId = nil
	self.baseData = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.comboList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderComboListItem)
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.WUXUE_DETAIL_PANEL)
end

M.OnComboListItemClick = function(self, index)
	self.bindData.showSkillInfoCtrl = 1
	local data = self.baseData and self.baseData.comboList and self.baseData.comboList[index]

	if not data then
		return
	end

	self.comboInfoRoot.comboDesc = data.comboDesc
	self.comboInfoRoot.comboUnlockDesc = data.unlockConditionDesc
	local indices = data.specialComboTag
	local tag = ""

	if indices == nil and indices == "" then
		for indexStr in string.gmatch(indices, "%d+") do
			local idx = tonumber(indexStr)

			if idx == nil then
				idx = idx + 1

				if idx <= 0 and idx < #FightSkillConfig.ComboTagNames then
					tag = tag .. FightSkillConfig.ComboTagNames[idx]
				end
			end
		end
	end

	self.comboInfoRoot.tag = tag

	if data.unlockCondition then
		self.bindData.showSkillInfoUnlock = 1
	else
		self.bindData.showSkillInfoUnlock = 0
	end

	self.comboInfoRoot.videoPlayer:Init()
	self.comboInfoRoot.videoPlayer:PlayVideo(data.videoId, true)
end

M.OnRenderTabListItemWeapon = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.tabList[index + 1]

	if store and data then
		store.icon = data.Icon
	end
end

M.OnSimpleRenderComboListItem = function(self, btn, index)
	local data = self.baseData and self.baseData.comboList and self.baseData.comboList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if not data then
		return
	end

	store.maText = data.comboInput
	store.LockCtrl = data.unlockCondition
	store.btn.luaClick = self.CreateActionWithArgs(self, self.OnComboListItemClick, index + 1)
end

M.InitFightSkillUnlockByWuxueMap = function(self, fightSkillCfg, fromGallery)
	local isUnlock = fromGallery and gCS.FightStyleManager.Instance:IsFightStyleUnlocked(self.fightSkillId)

	if isUnlock then
		self.bindData.wuxueCtrl = self.wuxueCtrlEnum.show

		if fightSkillCfg then
			self.bindData.title = fightSkillCfg.Name
			self.bindData.des = fightSkillCfg.PassportDes
			self.bindData.yinIcon = fightSkillCfg.PassportIconInner
			self.bindData.gotFrom = fightSkillCfg.SourceDesc
			local time = gCS.FightStyleManager.Instance:GetFightStyleFirstUnlockTime(self.fightSkillId)
			self.bindData.gotTime = os.date("%Y.%m.%d", time)
		end
	else
		self.bindData.wuxueCtrl = self.wuxueCtrlEnum.hide
	end
end
