-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ThreeLevelTreeDemoStore.lua
-- Decompiled from: 01362_ThreeLevelTreeDemoStore.lua_39f27ebe1838.luajit

local CAMP_TYPE = {
	["h\\x98\\x87\\x81\\x82"] = 3,
	["YPk"] = 2,
	["X\rNh"] = 1
}
C_ThreeLevelTreeDemoStore = DefClass("C_ThreeLevelTreeDemoStore", C_ThreeLevelTreeDemoStore, C_StoreGroup)
GroupName2Class.ThreeLevelTreeDemoStore = C_ThreeLevelTreeDemoStore
local ThreeLevelTreeDemoStore = C_ThreeLevelTreeDemoStore

ThreeLevelTreeDemoStore.OnAwake = function(self)
	self.bindData.btnBack.luaClick = self.CreateAction(self, "ClosePanel")
	self.bindData.tree.luaRenderItem = self.CreateAction(self, "OnRenderTreeItem")
	self.bindData.tree.luaClick = self.CreateAction(self, "OnTreeItemClick")
end

ThreeLevelTreeDemoStore.OnShow = function(self, panelId, data)
	SGUI.RedDotMgr.LuaSetRedDot(true, "ThreeLevelTree:1")

	local treeView = {}

	table.insert(treeView, {
		["\\xae\\xa9\\xaad:\\xfb7"] = true,
		["I\\xab\\xb2\\xbb\\xbe"] = 0,
		["\\xcd\\xda3)\\xf4"] = "\\xa7\\xf2\\xc0c\\xa9_q\\xf4O\\xa6$\n\\xab9\\xda",
		["\t\r"] = 1,
		["a\\x9f\\x8a\\x86Y"] = 0
	})
	table.insert(treeView, {
		["\\xae\\xa9\\xaad:\\xfb7"] = true,
		["I\\xab\\xb2\\xbb\\xbe"] = 1,
		["\\xcd\\xda3)\\xf4"] = "'w\\xddiqKo|}\\xbbbm\\xd2\\xc3",
		["\t\r"] = 2,
		["a\\x9f\\x8a\\x86Y"] = 1
	})
	table.insert(treeView, {
		["\t\r"] = 3,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = ".{\\xf9\\xc1r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xaf",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 4,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = ".{\\xf9\\xc1r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xac",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 5,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = ".{\\xf9\\xc1r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xad",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 6,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = ".{\\xf9\\xc1r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xaa",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\\xae\\xa9\\xaad:\\xfb7"] = false,
		["I\\xab\\xb2\\xbb\\xbe"] = 1,
		["\\xcd\\xda3)\\xf4"] = "'w\\xddiqKo|}\\xbbbm\\xd2\\xc0",
		["\t\r"] = 7,
		["a\\x9f\\x8a\\x86Y"] = 1
	})
	table.insert(treeView, {
		["\t\r"] = 8,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = ".{\\xf9\\xc2r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xaf",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 9,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = ".{\\xf9\\xc2r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xac",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 10,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = ".{\\xf9\\xc2r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xad",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 11,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = ".{\\xf9\\xc2r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xaa",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\\xae\\xa9\\xaad:\\xfb7"] = true,
		["I\\xab\\xb2\\xbb\\xbe"] = 0,
		["\\xcd\\xda3)\\xf4"] = "\\xa7\\xf2\\xc0c\\xa9_q\\xf4O\\xa6$\n\\xab9\\xd9",
		["\t\r"] = 12,
		["a\\x9f\\x8a\\x86Y"] = 0
	})
	table.insert(treeView, {
		["\\xae\\xa9\\xaad:\\xfb7"] = true,
		["I\\xab\\xb2\\xbb\\xbe"] = 1,
		["\\xcd\\xda3)\\xf4"] = "$w\\xddiqKo|}\\xbbbm\\xd2\\xc3",
		["\t\r"] = 13,
		["a\\x9f\\x8a\\x86Y"] = 1
	})
	table.insert(treeView, {
		["\t\r"] = 14,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = "-{\\xf9\\xc1r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xaf",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 15,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = "-{\\xf9\\xc1r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xac",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 16,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = "-{\\xf9\\xc1r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xad",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 17,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = "-{\\xf9\\xc1r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xaa",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\\xae\\xa9\\xaad:\\xfb7"] = false,
		["I\\xab\\xb2\\xbb\\xbe"] = 1,
		["\\xcd\\xda3)\\xf4"] = "$w\\xddiqKo|}\\xbbbm\\xd2\\xc0",
		["\t\r"] = 18,
		["a\\x9f\\x8a\\x86Y"] = 1
	})
	table.insert(treeView, {
		["\t\r"] = 19,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = "-{\\xf9\\xc2r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xaf",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 20,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = "-{\\xf9\\xc2r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xac",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 21,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = "-{\\xf9\\xc2r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xad",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\t\r"] = 22,
		["I\\xab\\xb2\\xbb\\xbe"] = 2,
		["\\xcd\\xda3)\\xf4"] = "-{\\xf9\\xc2r\\\\x80\\xab\\xe0\\xb8L\\xf3\\xaf\r{\\xf1aڄ\\xaa",
		["a\\x9f\\x8a\\x86Y"] = 2
	})
	table.insert(treeView, {
		["\\xae\\xa9\\xaad:\\xfb7"] = true,
		["I\\xab\\xb2\\xbb\\xbe"] = 0,
		["\\xcd\\xda3)\\xf4"] = "\\xa7\\xf2\\xc0c\\xa9_q\\xf4O\\xa6$\n\\xab9\\xd8",
		["\t\r"] = 23,
		["a\\x9f\\x8a\\x86Y"] = 0
	})
	self.bindData.tree:SetList(treeView)
end

ThreeLevelTreeDemoStore.ClosePanel = function(self)
	gPanelManager:Close(gPanelId.S_THREE_LEVEL_TREE_DEMO)
end

ThreeLevelTreeDemoStore.OnRenderTreeItem = function(self, btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		store.tabName = data.tabName .. index
	end
end

ThreeLevelTreeDemoStore.OnTreeItemClick = function(self, btn, data)
	self.bindData.imgPath = gUIUtils:GetSguiImagePath(math.random(28000001, 28000010))
	self.bindData.content = data.tabName
end
