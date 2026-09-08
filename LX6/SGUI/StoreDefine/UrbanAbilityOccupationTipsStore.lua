-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityOccupationTipsStore.lua
-- Decompiled from: 01148_UrbanAbilityOccupationTipsStore.lua_d2e4644e299e.luajit

C_UrbanAbilityOccupationTipsStore = DefClass("C_UrbanAbilityOccupationTipsStore", C_UrbanAbilityOccupationTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupationTipsStore = C_UrbanAbilityOccupationTipsStore
local M = C_UrbanAbilityOccupationTipsStore

M.ctor = function(self)
	self.State = {
		["\\xe0\\xd2.-\\xff"] = 0,
		["\\xea\\xd3\\xf8"] = 1
	}
	self.aniNameShengji = "S_Vx_UrbanAbilityOccupationTips_open_shengji"
	self.aniNameYingPin = "S_Vx_UrbanAbilityOccupationTips_open_yingpin"
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.button.luaClick = self.CreateAction(self, "OnBtnClick")
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex
	self.jobId = args.jobId
	self.lastJobId = args.lastJobId
	self.isHistoryJob = args.isHistoryJob
	self.selectedTid = args.selectedTid
	gSpiritManager.occupationTips_JobId = nil
	gSpiritManager.occupationTips_PopUpId = nil

	self:InitView()
	self:SetData()
	self.bindData.button:SetActive(gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Character))
end

M.OnClose = function(self)
end

M.SetData = function(self)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(self.jobId)

	if not cfg then
		return
	end

	local aniName = ""

	if not self.isHistoryJob and cfg.PreJob <= 0 then
		aniName = self.aniNameShengji
		local lastCfg = LTConfig.UrbanJobConfig.GetConfig(cfg.PreJob)
		self.bindData.title1.text = lastCfg.Name
		self.bindData.title2.text = cfg.Name
	else
		aniName = self.aniNameYingPin
		self.bindData.state = self.State.YingPin
		self.bindData.title.text = cfg.Name
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, aniName)

	local list = {}

	for i, v in pairs(cfg.BriefDescription) do
		local info = {
			id = v.Id,
			selected = false,
			des = v
		}

		table.insert(list, info)
	end

	self._listData = list

	self.bindData.list:SetSimpleList(#self._listData)

	local fsCfg = LTConfig.FightSpiritConfig.GetConfig(gSpiritManager:GetCurFirstSpiritTid())

	if not fsCfg then
		return
	end

	local head = gStoreManager:GetStoreGroup("HeadAvatarStore"):GetStoreByWidget(self.bindData.head)
	head.headIcon = fsCfg.SHeadIconID
	head.bgColor = Color.NewByStr(fsCfg.CharListTemplateBgColor)
end

M.InitView = function(self)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		gPanelManager:Close(self.panelId)
	end)
end

M.OnRenderItem = function(self, btn, index)
	local data = self._listData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationTemplateStore"):GetStoreByWidget(btn)
	store.text.text = data.des.description
end

M.OnBtnClick = function(self)
	local targetTid = self:GetTargetSpiritTid()

	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL, {
		tab = gUrbanAbilityManager.URBANABILITY_PAGE.OCCUPATION,
		jobId = self.jobId,
		selectedTid = targetTid
	})
end

M.GetTargetSpiritTid = function(self)
	local targetTid = nil

	gSpiritManager:Foreach(function (spirit)
		if spirit.SpiritInfo.SpiritJobInfo.AvailableJobs[self.jobId] then
			targetTid = targetTid or spirit.Id

			if spirit.Id ~= self.selectedTid then
				targetTid = spirit.Id
			end
		end
	end)

	return targetTid or self.selectedTid
end
