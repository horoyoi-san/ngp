-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangNewFinalPanelStore.lua
-- Decompiled from: 01210_MajiangNewFinalPanelStore.lua_430e487464e8.luajit

C_MajiangNewFinalPanelStore = DefClass("C_MajiangNewFinalPanelStore", C_MajiangNewFinalPanelStore, C_StoreGroup)
GroupName2Class.MajiangNewFinalPanelStore = C_MajiangNewFinalPanelStore
local M = C_MajiangNewFinalPanelStore

M.OnAwake = function(self)
	self.TabIndex = {
		["\\xeb\\xda*%\\xf3"] = 0,
		["\\x98\\xb2\n\\xb9o\n\\xff1"] = 1
	}
	self.bindData.tabRect.OnGenerateTab = self.CreateAction(self, self.OnGenerateTab)
	self.bindData.tabBtn1.luaClick = self.CreateAction(self, self.OnTabBtn1Click)
	self.bindData.tabBtn2.luaClick = self.CreateAction(self, self.OnTabBtn2Click)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTabListItem)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, self.OnListSelectedChanged)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	self.bindData.playAgainBtn.luaClick = self.CreateAction(self, self.OnPlayAgainBtnClick)
end

M.OnShow = function(self, panelId, data)
	self.data = data
	local views = {}

	for i, v in ipairs(LTConfig.MahjongConfig.FinalPanelTabsName) do
		views[i] = {
			label = v
		}
	end

	self.tabListData = views

	self.bindData.tabList:SetSimpleList(#views)
	self.bindData.tabList:SelectItem(self.TabIndex.RankTab)

	local game = gMaJiangManager:GetGameOrEmpty()

	if game.serverRoomInfo ~= nil or game.serverRoomInfo.RoomType ~= UX.Game.MahjongRoomType.Friend then
		self.bindData.playAgainBtn:SetActive(false)
	end
end

M.OnDestroy = function(self)
	self.data = nil
	self.tabListData = nil
end

M.OnRenderTabListItem = function(self, btn, index)
	local data = self.tabListData[index + 1]
	btn.title.text = data.label
end

M.OnGenerateTab = function(self, index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	if index ~= self.TabIndex.RankTab then
		store.SetDataAndRefresh(store, self.data)
	else
		store.RefreshAll(store)
	end
end

M.OnListSelectedChanged = function(self, list)
	self.bindData.tabRect.selectedIndex = list.selectedIndex
end

M.OnTabBtn1Click = function(self)
	self.bindData.tabList:SelectItem(self.TabIndex.RankTab)
end

M.OnTabBtn2Click = function(self)
	self.bindData.tabList:SelectItem(self.TabIndex.ScoreTab)
end

M.OnExitBtnClick = function(self)
	gMaJiangManager:RequestExitFinishedMahjongGame()
end

M.OnPlayAgainBtnClick = function(self)
	gMaJiangManager:StartNextRound()
end
