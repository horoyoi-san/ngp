-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameAchievementPanelStore.lua
-- Decompiled from: 01085_PetGameAchievementPanelStore.lua_721bdd11d4de.luajit

local achievementConf = require("LX6/MiniGame/PetGame/data/tbachievement")
local GameObject = UnityEngine.GameObject
C_PetGameAchievementPanelStore = DefClass("C_PetGameAchievementPanelStore", C_PetGameAchievementPanelStore, C_StoreGroup)
GroupName2Class.PetGameAchievementPanelStore = C_PetGameAchievementPanelStore
local M = C_PetGameAchievementPanelStore
local viewState = {
	["W_ڼ\\x8d\\x8e\r\\xcc\\xff"] = 2,
	["\")(\\xedv\\x8e\\xf29\\xad!\\xf2\\xc4\\xefq\\xec"] = 1
}
local pageColumnCount = 3
local pageRowCount = 3
local pageItemCount = pageColumnCount * pageRowCount

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
	self.UnBindSystemBtn(self)
	self.ClearDetailIcon(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.UnBindSystemBtn(self)
end

M.OnShow = function(self, panelId, data)
	self.parentPanel = data.parent
	self.panelId = panelId

	self:BindSystemBtn()

	self.achievementManager = gPetGameManager.currentGame:GetAchievementManager()
	self.contentTrans = self.bindData.content
	local contentPos = self.contentTrans.localPosition
	self.contentTrans.localPosition = Vector3(0, contentPos.y, contentPos.z)
	self.bindData.nextPageBtn.luaClick = self:CreateAction(self.ShowNextPage, self)
	self.bindData.frontPageBtn.luaClick = self:CreateAction(self.ShowLastPage, self)
	self.bindData.showInfoBtn.luaClick = self:CreateAction(self.OnShowDetailInfoBtnClick, self)

	self:InitAchievementListView()
	self:ShowView(viewState.achievementView)
end

M.OnClose = function(self)
	self.achievementManager = nil

	self.UnBindSystemBtn(self)
end

M.InitAchievementListView = function(self)
	local prefab = self.bindData.item.gameObject

	prefab.SetActive(prefab, false)

	local parent = self.bindData.content
	local achievementDataList = table.to_array(achievementConf)
	self.itemObjectList = {}
	self.itemPageList = {}
	self.currentPageIndex = 1
	self.lastItemId = nil

	table.sort(achievementDataList, function (a, b)
		return a.id <= b.id
	end)

	for _, conf in ipairs(achievementDataList) do
		self.AddItem(self, conf.id, conf, prefab, parent)
	end

	self.ShowCurrentPage(self)
end

M.AddItem = function(self, id, conf, prefab, parent)
	local itemIns = GameObject.Instantiate(prefab, parent)
	itemIns.transform.localScale = Vector3.one

	itemIns:SetActive(true)

	local itemTrans = itemIns.transform
	local itemIconTrans = itemTrans:Find("icon")
	local itemLockTag = itemTrans:Find("lockTag").gameObject
	local itemSelectedObj = itemTrans:Find("selected").gameObject

	itemSelectedObj:SetActive(false)

	local achievementInfo = self.achievementManager:GetAchievementInfo(id)

	itemLockTag:SetActive(achievementInfo ~= nil)

	local itemButton = itemIns:GetComponent("UButton")

	if itemButton then
		itemButton.luaClick = self.CreateActionWithArgs(self, self.OnItemClick, id, self)
	end

	local itemInfo = {
		id = id,
		itemObj = itemIns,
		selectedObj = itemSelectedObj
	}
	self.itemObjectList[id] = itemInfo

	table.insert(self.itemPageList, itemInfo)
	self.LoadIcon(self, conf.badge, itemIconTrans)
end

M.LoadIcon = function(self, prefabPath, parent)
	slot3 = gResourceManager

	slot3:LoadAssetWithCallBack(prefabPath, typeof(GameObject), function (loadOp)
		if loadOp and loadOp.asset then
			local itemIconIns = GameObject.Instantiate(loadOp.asset, parent)
			itemIconIns.transform.localScale = Vector3.one
			itemIconIns.transform.localPosition = Vector3.zero
		end
	end)
end

M.OnItemClick = function(self, id)
	if id == self.lastItemId then
		self.SelectItem(self, id)

		return
	end

	self.ShowView(self, viewState.detailView)
end

M.SelectItem = function(self, id)
	local itemObj = self.itemObjectList[id]

	if itemObj then
		itemObj.selectedObj:SetActive(true)
	end

	if self.lastItemId then
		local lastItemObj = self.itemObjectList[self.lastItemId]

		if lastItemObj then
			lastItemObj.selectedObj:SetActive(false)
		end
	end

	self.lastItemId = id
end

M.OnShowDetailInfoBtnClick = function(self)
	self.SetProcessInfoVisible(self, not self.showProcessInfo)
end

M.BindSystemBtn = function(self)
	if not self.parentPanel then
		return
	end

	local eventHandler = {
		panelId = self.panelId,
		OnMenuBtnClick = self.OnMenuBtnClick,
		OnConfirmBtnClick = self.OnConfirmBtnClick,
		OnCancleBtnClick = self.OnCancleBtnClick,
		target = self
	}

	self.parentPanel:RegisterSystemBtnEvent(eventHandler)
end

M.UnBindSystemBtn = function(self)
	if self.parentPanel and self.panelId then
		self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
	end
end

M.OnMenuBtnClick = function(self)
	if self.currentViewState ~= viewState.achievementView then
		self.ShowNextPage(self)
	elseif self.currentViewState ~= viewState.detailView then
		self.OnShowDetailInfoBtnClick(self)
	end
end

M.OnConfirmBtnClick = function(self)
	if self.currentViewState ~= viewState.achievementView then
		self.ShowView(self, viewState.detailView)
	elseif self.currentViewState ~= viewState.detailView then
		self.OnShowDetailInfoBtnClick(self)
	end
end

M.OnCancleBtnClick = function(self)
	if self.currentViewState ~= viewState.detailView then
		self.ShowView(self, viewState.achievementView)

		return
	end

	self.parentPanel:CloseChildPanel(self.panelId)
end

M.ShowView = function(self, viewType)
	self.currentViewState = viewType

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_SHOW_UI_MASK)
	self.bindData.achievementListView.gameObject:SetActive(viewType ~= viewState.achievementView)
	self.bindData.detailView.gameObject:SetActive(viewType ~= viewState.detailView)

	if viewType ~= viewState.detailView then
		self.ShowDetailView(self)
	else
		self.ClearDetailInfo(self)
	end
end

M.ShowDetailView = function(self)
	local id = self.lastItemId

	if not id then
		return
	end

	local achievementInfo = self.achievementManager:GetAchievementInfo(id)
	local conf = achievementConf[id]

	if not conf then
		return
	end

	local curVal = achievementInfo and achievementInfo.curVal or 0
	local goalVal = conf.conditions.goalType ~= 1 and 1 or conf.conditions.goalVal
	self.bindData.detailText.text = self:FormatCSharp(conf.des, conf.conditions.goalVal)
	self.bindData.processInfoText.text = string.format("%d/%d", curVal, goalVal)
	self.bindData.processSlider.value = curVal / goalVal

	self:ClearDetailIcon()
	self:LoadIcon(conf.badge, self.bindData.detailIconTrans)
end

M.ClearDetailInfo = function(self)
	self.ClearDetailIcon(self)
	self.SetProcessInfoVisible(self, false)
end

M.SetProcessInfoVisible = function(self, visible)
	self.showProcessInfo = visible

	self.bindData.processInfoTrans.gameObject:SetActive(visible)
	self.bindData.describeTrans.gameObject:SetActive(not visible)
end

M.FormatCSharp = function(self, str, ...)
	local args = {
		...
	}

	return str.gsub(str, "{(%d+)}", function (index)
		return args[tonumber(index) + 1]
	end)
end

M.ClearDetailIcon = function(self)
	local iconParent = self.bindData and self.bindData.detailIconTrans

	if not iconParent then
		return
	end

	for i = iconParent.childCount - 1, 0, -1 do
		GameObject.Destroy(iconParent.GetChild(iconParent, i).gameObject)
	end
end

M.ShowNextPage = function(self)
	if self.currentViewState == viewState.achievementView then
		return
	end

	if self.GetMaxPage(self) < self.currentPageIndex then
		return
	end

	self.currentPageIndex = self.currentPageIndex + 1

	self.ShowCurrentPage(self)
end

M.ShowLastPage = function(self)
	if self.currentViewState == viewState.achievementView then
		return
	end

	if self.currentPageIndex < 1 then
		return
	end

	self.currentPageIndex = self.currentPageIndex - 1

	self.ShowCurrentPage(self)
end

M.ShowCurrentPage = function(self)
	local firstIndex = (self.currentPageIndex - 1) * pageItemCount + 1
	local lastIndex = firstIndex + pageItemCount - 1
	local firstItemId = nil
	slot4 = ipairs
	slot6 = self.itemPageList or {}

	for index, itemInfo in slot4(slot6) do
		local active = firstIndex < index and index > lastIndex

		itemInfo.itemObj:SetActive(active)

		if active then
			firstItemId = firstItemId or itemInfo.id
		end
	end

	if firstItemId then
		self.SelectItem(self, firstItemId)
	end

	self.UpdatePageDots(self)
end

M.GetMaxPage = function(self)
	return math.ceil(#(self.itemPageList or {}) / pageItemCount)
end

M.UpdatePageDots = function(self)
	local dotsRoot = self.bindData.pageDots

	if not dotsRoot then
		return
	end

	local maxPage = self.GetMaxPage(self)

	if dotsRoot.childCount >= maxPage and dotsRoot.childCount <= 0 then
		local dotTemplate = dotsRoot.GetChild(dotsRoot, 0).gameObject

		for _ = dotsRoot.childCount + 1, maxPage do
			local dot = GameObject.Instantiate(dotTemplate, dotsRoot)
			dot.transform.localScale = Vector3.one
		end
	end

	for index = 1, dotsRoot.childCount do
		local dot = dotsRoot:GetChild(index - 1)
		local active = index > maxPage

		dot.gameObject:SetActive(active)

		if active then
			local light = dot:Find("light")
			local dark = dot:Find("dark")
			local selected = index ~= self.currentPageIndex

			if light then
				light.gameObject:SetActive(selected)
			end

			if dark then
				dark.gameObject:SetActive(not selected)
			end
		end
	end
end
