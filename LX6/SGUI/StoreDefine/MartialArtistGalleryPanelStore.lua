-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MartialArtistGalleryPanelStore.lua
-- Decompiled from: 00968_MartialArtistGalleryPanelStore.lua_10ae014d776a.luajit

C_MartialArtistGalleryPanelStore = DefClass("C_MartialArtistGalleryPanelStore", C_MartialArtistGalleryPanelStore, C_StoreGroup)
GroupName2Class.MartialArtistGalleryPanelStore = C_MartialArtistGalleryPanelStore
local M = C_MartialArtistGalleryPanelStore
local FightSkillConfig = LTConfig.FightSkillConfig
local FightStyleManager = gCS.FightStyleManager

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.totalPageCount = 10
end

M.DefineAllEnumsAutoGen = function(self)
	self.leftArrowCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.rightArrowCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.UNLOCK_TYPE = {
		["ft⒧#\\x87#\\xec\\xdc"] = 0,
		["V\r^p"] = 1,
		[")f\\xbd\\xa1\\xa0j"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.leftArrowCtrlEnum = nil
	self.rightArrowCtrlEnum = nil
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
	self.InitContent(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.leftBtn.luaClick = self.CreateAction(self, self.OnClickLeftBtn)
	self.bindData.rightBtn.luaClick = self.CreateAction(self, self.OnClickRightBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.OnClickLeftBtn = function(self)
	if self.totalPageCount >= self.curStartIndex then
		self.curStartIndex = self.curStartIndex - self.totalPageCount

		self.RefreshCurrentPage(self)
	end
end

M.OnClickRightBtn = function(self)
	if self.curStartIndex + self.totalPageCount >= #self.allGallerySkill then
		self.curStartIndex = self.curStartIndex + self.totalPageCount

		self.RefreshCurrentPage(self)
	end
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.InitContent = function(self)
	self.allGallerySkill = {}
	self.skillMapInfo = {}
	self.curStartIndex = 1

	for i = 1, FightSkillConfig.count do
		local config = FightSkillConfig.LoadAt(i - 1)

		if config and (config.PassportType ~= FightSkillConfig.PassportTypeType.wushi or config.PassportType ~= FightSkillConfig.PassportTypeType.tujian) then
			table.insert(self.allGallerySkill, config.Id)

			local isTuJian = config.PassportType ~= FightSkillConfig.PassportTypeType.tujian
			local lockState = self.UNLOCK_TYPE.LOCK
			local wuxueMapState = gMartialArtistManager:GetFightSkillRelateWuxueMapUnLockType(config.Id)
			local icon = 0

			if wuxueMapState ~= gMartialArtistManager.FIGHT_SKILL_WUXUE_MAP_UNLOCK_TYPE.RELATE_WUXUE_MAP_UNLOCK then
				lockState = self.UNLOCK_TYPE.UNLOCK
				icon = config.PassportIconlocked
			end

			self.skillMapInfo[config.Id] = {
				["n+p^"] = 0,
				["\tF\\x9d\\x81\\x80J"] = false,
				id = config.Id,
				lockState = lockState,
				icon = icon,
				unlockIcon = config.PassportIcon,
				isTuJian = isTuJian
			}
		end
	end

	local skills = FightStyleManager.Instance:GetAllUnlockedFightStyles()
	local unlockNum = 0

	if skills.Length <= 0 then
		for i = 0, skills.Length - 1 do
			local id = skills[i]
			local info = self.skillMapInfo[id]

			if info then
				local time = FightStyleManager.Instance:GetFightStyleFirstUnlockTime(id)
				info.lockState = info.isTuJian and self.UNLOCK_TYPE.UNLOCK_GET or self.UNLOCK_TYPE.UNLOCK
				info.icon = info.unlockIcon
				info.unlock = true
				unlockNum = unlockNum + 1
				info.time = time
			end
		end
	end

	local allCount = #self.allGallerySkill
	self.bindData.unlockNum = unlockNum
	self.bindData.totalNum = allCount

	self.RefreshCurrentPage(self)
end

M.RefreshPageArrow = function(self)
	self.bindData.leftArrowCtrl = self.totalPageCount >= self.curStartIndex and self.leftArrowCtrlEnum.show or self.leftArrowCtrlEnum.hide
	self.bindData.rightArrowCtrl = self.curStartIndex + self.totalPageCount >= #self.allGallerySkill and self.rightArrowCtrlEnum.show or self.rightArrowCtrlEnum.hide
end

M.RefreshCurrentPage = function(self)
	local endIndex = self.curStartIndex + self.totalPageCount - 1

	for i = self.curStartIndex, endIndex do
		local skillId = self.allGallerySkill[i]
		local index = i - self.curStartIndex + 1

		self.OnRenderGalleryItem(self, self.bindData["template" .. tostring(index)], i, skillId)
	end

	self.RefreshPageArrow(self)
end

M.OnRenderGalleryItem = function(self, btn, index, skillId)
	if skillId then
		btn.SetActive(btn, true)

		local data = self.skillMapInfo[skillId]

		if not data then
			return
		end

		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		store.countText = "No." .. tostring(index)
		store.time = os.date("%Y.%m.%d", data.time)
		store.icon = data.icon
		store.lockIcon = FightSkillConfig.PassportLockedIcon
		store.modeCtrl = data.lockState
		btn.luaClick = self.CreateActionWithArgs(self, self.OnClickGalleryItem, index)
	else
		btn.SetActive(btn, false)

		btn.luaClick = nil
	end
end

M.OnClickGalleryItem = function(self, index)
	local id = self.allGallerySkill[index]

	if not id then
		return
	end

	local data = self.skillMapInfo[id]

	if not data then
		return
	end

	gPanelManager:CheckShowSync(gPanelId.WUXUE_DETAIL_GALLERY_PANEL, {
		["\\x99&/2_\\x9cM\\xd52\\xb8\\xa0"] = true,
		fightSkillId = data.id
	})
end
