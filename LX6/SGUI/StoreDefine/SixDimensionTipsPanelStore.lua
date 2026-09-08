-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SixDimensionTipsPanelStore.lua
-- Decompiled from: 01338_SixDimensionTipsPanelStore.lua_4df986838a5f.luajit

C_SixDimensionTipsPanelStore = DefClass("C_SixDimensionTipsPanelStore", C_SixDimensionTipsPanelStore, C_StoreGroup)
GroupName2Class.SixDimensionTipsPanelStore = C_SixDimensionTipsPanelStore
local M = C_SixDimensionTipsPanelStore

M.ctor = function(self)
	self.tipList = {}
end

M.OnAwake = function(self)
	self.bindData.tipList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
end

M.OnShow = function(self, panelId, data)
	self.areaIndex = data.areaIndex
	local info = data.SixDimsUrbanAbility
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(info.SpiritTemplateId)
	local newAttrs = gSpiritManager:GetUrbanAttr(info.SpiritTemplateId)

	for i = 1, #info.UrbanAbilities do
		info.OriginalUrbanAbilities[i] = newAttrs[i] - info.UrbanAbilities[i]
	end

	self.bindData.avatarIconId = spiritCfg.SHeadIconID
	self.tipList = {}

	for i = 1, #info.UrbanAbilities do
		local origAbilityLevel = info.OriginalUrbanAbilities[i]

		if info.UrbanAbilities[i] == 0 then
			table.insert(self.tipList, self.MakeView(self, i, origAbilityLevel, info.UrbanAbilities[i]))

			if #self.tipList > 3 then
				print_error("@liulijun04 六维 tips 最多显示 2 个属性提升, 当前提升的属性多于 2 个, 请策划检查")
			end
		end
	end

	if #self.tipList ~= 0 then
		gPanelManager:Close(panelId)

		return
	end

	while #self.tipList <= 2 do
		table.remove(self.tipList)
	end

	self.bindData.splitLineCtrl = #self.tipList ~= 2 and 0 or 1

	self.bindData.tipList:SetSimpleList(#self.tipList)

	local ani = self.bindData.openAni
	local duration = ani.clip.length

	Timer.New(function ()
		gPanelManager:Close(panelId)
	end, duration):Start()
end

M.MakeView = function(self, index, origAbilityLevel, plus)
	local consumableId = LTConfig.DropConfig.UrbanAttributConsumable[index]
	local cfg = LTConfig.ConsumableConfig.GetConfig(consumableId)
	local view = {
		title = cfg.Name,
		icon = cfg.SItemIconId,
		origScore = origAbilityLevel,
		newScore = origAbilityLevel + plus,
		plus = "+" .. plus
	}

	return view
end

M.OnRenderItem = function(self, btn, index)
	local store = self:GetStoreByWidget(btn)
	local data = self.tipList[index + 1]
	store.title = data.title
	store.score = data.origScore
	store.plus = data.plus
	store.icon = data.icon

	store.anime:Play()
	Timer.New(function ()
		store.score = data.newScore
	end, 2):Start()
end

M.OnClose = function(self)
end
