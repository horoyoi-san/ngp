local FactionConfig = LTConfig.FactionConfig
local TextConfig = LTConfig.TextConfig
local FactionDispositionConfig = LTConfig.FactionDispositionConfig
local Ease = DG.Tweening.Ease
local EInvokeTime = SGUI.EInvokeTime
C_PowerMapHUDStore = DefClass("C_PowerMapHUDStore", C_PowerMapHUDStore, C_StoreGroup)
GroupName2Class.PowerMapHUDStore = C_PowerMapHUDStore
local M = C_PowerMapHUDStore
local ANI_TIME = 1
local LEVEL2PROGRESS = {
	0,
	0.27,
	0.5,
	0.73,
	1
}

function M:ctor()
	self.areaIndex = 0
	self.mgr = gFactionManager
end

function M:OnDropBtnClick()
	gPanelManager:Close(gPanelId.POWER_MAP)
end

function M:OnAwake()
	return
end

function M:OnShow(panelId, data)
	if not data then
		self:OnDropBtnClick()

		return
	end

	local factionId = data.FactionId[1]
	self.cfg = FactionConfig.GetConfig(factionId)

	if not self.cfg then
		print_error("[PowerMapHUDStore] OnShow error, FactionConfig 找不到配表数据，id=", factionId)

		return
	end

	self.data = data
	self.bindData.iconId = self.cfg.imageId
	self.bindData.detailBtn.luaClick = self:CreateActionWithArgs("OpenFactionMapWithSelection", factionId, self.mgr)

	self:RunLevelFrame(false)
end

function M:RunLevelFrame(isNew)
	local level = isNew and self.data.nlv or self.data.clv
	self.bindData.level = level
	self.bindData.nameLabel = self.cfg.name

	if isNew then
		local lvCfg = FactionDispositionConfig.GetConfig(level)
		self.bindData.descLabel = lvCfg.name

		self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)

		self.timer = Timer.New(function ()
			self:OnDropBtnClick()
		end, FactionConfig.FactionPopupProgressDuration - ANI_TIME):Start()
	else
		local diff = self.data.Disposition
		local preTxt = diff > 0 and TextConfig.GetConfig(73970622) or TextConfig.GetConfig(73970623)
		self.bindData.descLabel = preTxt.Text .. diff
		self.bindData.progress.value = LEVEL2PROGRESS[self.data.clv]

		self.bindData.progress:ProgressToValueWithCallBack(LEVEL2PROGRESS[self.data.nlv], ANI_TIME, 1, Ease.OutQuad, function ()
			self:RunLevelFrame(true)
		end)
	end
end

function M:OnClose()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
