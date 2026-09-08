-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Police\PoliceFinePanelStore.lua
-- Decompiled from: 01234_PoliceFinePanelStore.lua_cf2912e2a81a.luajit

C_PoliceFinePanelStore = DefClass("C_PoliceFinePanelStore", C_PoliceFinePanelStore, C_StoreGroup)
GroupName2Class.PoliceFinePanelStore = C_PoliceFinePanelStore
local M = C_PoliceFinePanelStore

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.panelId = nil
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.data = data

	self.ShowFineResult(self, data.list)
end

M.OnClose = function(self)
	self.fineViewList = nil
end

M.ShowFineResult = function(self, fineList, fineMoney, jobExpInfo)
	local money = 0
	local fineViewList = {}

	for _, v in ipairs(fineList) do
		local fineCfg = LTConfig.PoliceFineConfig.GetConfig(v)
		local dropCfg = LTConfig.DropConfig.GetConfig(fineCfg.Drop)

		if dropCfg ~= nil then
			print_error_without_stack("PoliceFineConfig=" .. tostring(v) .. " 找不到drop配置！请策划检查 dropId=", fineCfg.Drop)

			return
		end

		local item = {
			["a\\x9f\\x8a\\x86Y"] = 0,
			text = fineCfg.Title,
			money = dropCfg.Money
		}

		table.insert(fineViewList, item)

		money = money + dropCfg.Money
	end

	self.bindData.money = fineMoney or money
	self.fineViewList = fineViewList

	self.bindData.list:SetSimpleList(#self.fineViewList)
	Timer.New(function ()
		if self.STATE_EnableOnce then
			self:Close()
		end
	end, 4):Start()

	local jobClassId = LTConfig.UrbanJobJobClassConfig.Police
	local exp = 0

	if jobExpInfo then
		for k, v in pairs(jobExpInfo) do
			if jobClassId ~= k then
				exp = v
			end
		end
	end

	self.bindData.addexp = "+" .. exp
	local currentJob, jobCfg = gSpiritJobManager:GetAvailableJobByClass(LTConfig.UrbanJobJobClassConfig.Police)
	local spiritTid = gSpiritManager:GetCurFirstSpiritTid()
	local levelCfg = gSpiritJobManager:GetLevelData(jobCfg, spiritTid)
	local curExp = currentJob.Exp
	local maxExp = levelCfg.Exp
	self.bindData.title = jobCfg.Name

	self.bindData.progress:ProgressToValue(curExp / maxExp)

	self.bindData.progressText = curExp .. "/" .. maxExp
end

M.OnRenderItem = function(self, btn, index)
	local data = self.fineViewList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.text = data.text
end

M.SetCloseCallback = function(self, closeCallback)
	self.closeCallback = closeCallback
end

M.Close = function(self)
	if self.panelId then
		gPanelManager:Close(self.panelId)

		return
	end

	if self.closeCallback then
		self.closeCallback()
	end

	self.rootWidget:SetActive(false)
end
