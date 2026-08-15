local SguiImageConfig = LTConfig.SguiImageConfig
local CAMP_TYPE = {
	EVENT = 3,
	CAMP = 2,
	BOSS = 1
}
C_ThreeLevelTreeDemoStore = DefClass("C_ThreeLevelTreeDemoStore", C_ThreeLevelTreeDemoStore, C_StoreGroup)
GroupName2Class.ThreeLevelTreeDemoStore = C_ThreeLevelTreeDemoStore
local ThreeLevelTreeDemoStore = C_ThreeLevelTreeDemoStore

function ThreeLevelTreeDemoStore:OnAwake()
	self.bindData.btnBack.luaClick = self:CreateAction("ClosePanel")
	self.bindData.tree.luaRenderItem = self:CreateAction("OnRenderTreeItem")
	self.bindData.tree.luaClick = self:CreateAction("OnTreeItemClick")
end

function ThreeLevelTreeDemoStore:OnShow(panelId, data)
	SGUI.RedDotMgr.LuaSetRedDot(true, "ThreeLevelTree:1")

	local treeView = {}

	table.insert(treeView, {
		expanded = true,
		depth = 0,
		tabName = "一级标题--A",
		id = 1,
		tIndex = 0
	})
	table.insert(treeView, {
		expanded = true,
		depth = 1,
		tabName = "A--二级标题--A",
		id = 2,
		tIndex = 1
	})
	table.insert(treeView, {
		id = 3,
		depth = 2,
		tabName = "A--A--三级标题--A",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 4,
		depth = 2,
		tabName = "A--A--三级标题--B",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 5,
		depth = 2,
		tabName = "A--A--三级标题--C",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 6,
		depth = 2,
		tabName = "A--A--三级标题--D",
		tIndex = 2
	})
	table.insert(treeView, {
		expanded = false,
		depth = 1,
		tabName = "A--二级标题--B",
		id = 7,
		tIndex = 1
	})
	table.insert(treeView, {
		id = 8,
		depth = 2,
		tabName = "A--B--三级标题--A",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 9,
		depth = 2,
		tabName = "A--B--三级标题--B",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 10,
		depth = 2,
		tabName = "A--B--三级标题--C",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 11,
		depth = 2,
		tabName = "A--B--三级标题--D",
		tIndex = 2
	})
	table.insert(treeView, {
		expanded = true,
		depth = 0,
		tabName = "一级标题--B",
		id = 12,
		tIndex = 0
	})
	table.insert(treeView, {
		expanded = true,
		depth = 1,
		tabName = "B--二级标题--A",
		id = 13,
		tIndex = 1
	})
	table.insert(treeView, {
		id = 14,
		depth = 2,
		tabName = "B--A--三级标题--A",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 15,
		depth = 2,
		tabName = "B--A--三级标题--B",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 16,
		depth = 2,
		tabName = "B--A--三级标题--C",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 17,
		depth = 2,
		tabName = "B--A--三级标题--D",
		tIndex = 2
	})
	table.insert(treeView, {
		expanded = false,
		depth = 1,
		tabName = "B--二级标题--B",
		id = 18,
		tIndex = 1
	})
	table.insert(treeView, {
		id = 19,
		depth = 2,
		tabName = "B--B--三级标题--A",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 20,
		depth = 2,
		tabName = "B--B--三级标题--B",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 21,
		depth = 2,
		tabName = "B--B--三级标题--C",
		tIndex = 2
	})
	table.insert(treeView, {
		id = 22,
		depth = 2,
		tabName = "B--B--三级标题--D",
		tIndex = 2
	})
	table.insert(treeView, {
		expanded = true,
		depth = 0,
		tabName = "一级标题--C",
		id = 23,
		tIndex = 0
	})
	self.bindData.tree:SetList(treeView)
end

function ThreeLevelTreeDemoStore:ClosePanel()
	gPanelManager:Close(gPanelId.S_THREE_LEVEL_TREE_DEMO)
end

function ThreeLevelTreeDemoStore:OnRenderTreeItem(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		store.tabName = data.tabName .. index
	end
end

function ThreeLevelTreeDemoStore:OnTreeItemClick(btn, data)
	self.bindData.imgPath = LTConfig.SguiImageConfig.GetConfig(math.random(28000001, 28000010)).ImgPath
	self.bindData.content = data.tabName
end
