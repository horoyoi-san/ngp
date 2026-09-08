-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefCutPanelStore.lua
-- Decompiled from: 01446_ChefCutPanelStore.lua_ea610191c151.luajit

local ChefFoodPrepareConfig = LTConfig.ChefFoodPrepareConfig
local ChefConfig = LTConfig.ChefConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefManager = L50.Gameplay.ChefGame.ChefManager
C_ChefCutPanelStore = DefClass("C_ChefCutPanelStore", C_ChefCutPanelStore, C_StoreGroup)
GroupName2Class.ChefCutPanelStore = C_ChefCutPanelStore
local M = C_ChefCutPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.prepareIdList = {}
	self.panelId = nil
	self.currentIndex = 0
	self.qteSequence = {}
	self.qteResults = {}
	self.qteCurrentStep = 0
	self.correctCount = 0
	self.totalBtnCount = 0
	self.totalTime = 0
	self.elapsed = 0
	self.isInFailCooldown = false
	self.failCooldownTimer = nil
	self.nextDishTimer = nil
	self.isGameActive = false
	self.orderStates = {}
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.panelId = panelId
	self.prepareIdList = data.prepareIdList
	self.currentIndex = 0

	for i = 1, #self.prepareIdList do
		self.orderStates[i] = 0
	end

	self.bindData.orderList:SetSimpleList(#self.prepareIdList)
	self:StartNextDish()
end

M.OnClose = function(self)
	self.ClearAllTimers(self)

	self.isGameActive = false

	ChefManager.AskClearChefFoodPrepare()
end

M.OnUpdate = function(self)
	if not self.isGameActive then
		return
	end

	self.elapsed = self.elapsed + Time.deltaTime
	local progress = 1 - self.elapsed / self.totalTime

	if progress >= 0 then
		progress = 0
	end

	self.bindData.timeProgress:ProgressToValue(progress)

	if self.totalTime < self.elapsed then
		self.FinishCurrentDish(self, false)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.upBtn.luaClick = self.CreateAction(self, self.OnClickUpBtn)
	self.bindData.downBtn.luaClick = self.CreateAction(self, self.OnClickDownBtn)
	self.bindData.rightBtn.luaClick = self.CreateAction(self, self.OnClickRightBtn)
	self.bindData.leftBtn.luaClick = self.CreateAction(self, self.OnClickLeftBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.orderList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderOrderListItem)
	self.bindData.qteList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderQteListItem)
	self.bindData.orderList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickOrderList)
	self.bindData.qteList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickQteList)
end

M.OnClickUpBtn = function(self)
	self.HandleDirectionInput(self, 0)
end

M.OnClickDownBtn = function(self)
	self.HandleDirectionInput(self, 1)
end

M.OnClickLeftBtn = function(self)
	self.HandleDirectionInput(self, 2)
end

M.OnClickRightBtn = function(self)
	self.HandleDirectionInput(self, 3)
end

M.OnClickCloseBtn = function(self)
	self.isGameActive = false

	self:ClearAllTimers()
	gPanelManager:Close(self.panelId)
end

M.OnSimpleRenderOrderListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local id = self.prepareIdList[index + 1]

	if not id then
		return
	end

	local cfg = ChefFoodPrepareConfig.GetConfig(id)

	if not cfg then
		return
	end

	local beforeCfg = ConsumableConfig.GetConfig(cfg.BeforePrepareConsumableid)
	local afterCfg = ConsumableConfig.GetConfig(cfg.AfterPrepareConsumableid)

	if beforeCfg then
		store.beforeIconId = beforeCfg.SItemIconId
	end

	if afterCfg then
		store.afterIconId = afterCfg.SItemIconId
	end

	store.selectCtrl = index + 1 ~= self.currentIndex and 1 or 0
	store.stateCtrl = self.orderStates[index + 1] or 0
end

M.OnSimpleClickOrderList = function(self, btn, index)
end

M.OnSimpleRenderQteListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local step = index + 1
	store.dirCtrl = self.qteSequence[step] or 0
	store.stateCtrl = self.qteResults[step] or 0
end

M.OnSimpleClickQteList = function(self, btn, index)
end

M.StartNextDish = function(self)
	self.currentIndex = self.currentIndex + 1

	if self.currentIndex <= #self.prepareIdList then
		self.OnAllDishComplete(self)

		return
	end

	local range = ChefConfig.ChopGame_BtnNumRange
	self.totalBtnCount = math.random(range[1], range[2])
	self.totalTime = self.totalBtnCount * ChefConfig.ChopGame_BtnTime
	self.qteSequence = {}
	self.qteResults = {}

	for i = 1, self.totalBtnCount do
		self.qteSequence[i] = math.random(0, 3)
		self.qteResults[i] = 0
	end

	self.qteCurrentStep = 0
	self.correctCount = 0
	self.elapsed = 0
	self.isInFailCooldown = false

	self.bindData.orderList:RefreshList()
	self.bindData.qteList:SetSimpleList(self.totalBtnCount)
	self.bindData.timeProgress:ProgressToValue(1)

	self.isGameActive = true
end

M.HandleDirectionInput = function(self, dir)
	if not self.isGameActive then
		return
	end

	if self.isInFailCooldown then
		return
	end

	if self.totalBtnCount < self.qteCurrentStep then
		return
	end

	self.qteCurrentStep = self.qteCurrentStep + 1
	local expected = self.qteSequence[self.qteCurrentStep]

	if dir ~= expected then
		self.correctCount = self.correctCount + 1
		self.qteResults[self.qteCurrentStep] = 1
	else
		self.qteResults[self.qteCurrentStep] = 2
		self.isInFailCooldown = true
		self.failCooldownTimer = Timer.New(function ()
			self.failCooldownTimer = nil
			self.isInFailCooldown = false
		end, ChefConfig.ChopGame_FailTime):Start()
	end

	self.bindData.qteList:SetSimpleList(self.totalBtnCount)

	if self.totalBtnCount < self.qteCurrentStep then
		local threshold = math.floor(self.totalBtnCount * ChefConfig.ChopGame_SuccessPercentage)
		local success = threshold <= self.correctCount

		self:FinishCurrentDish(success)
	end
end

M.FinishCurrentDish = function(self, success)
	self.isGameActive = false
	self.orderStates[self.currentIndex] = success and 1 or 2

	if self.failCooldownTimer then
		self.failCooldownTimer:Stop()

		self.failCooldownTimer = nil
	end

	self.isInFailCooldown = false
	slot2 = self.bindData.orderList

	slot2:SetSimpleList(#self.prepareIdList)

	local prepareId = self.prepareIdList[self.currentIndex]

	ChefManager.AskFinishChefFoodPrepare(prepareId, success, function ()
		self.nextDishTimer = Timer.New(function ()
			self.nextDishTimer = nil

			self:StartNextDish()
		end, 0.5):Start()
	end)
end

M.OnAllDishComplete = function(self)
	Timer.New(function ()
		gPanelManager:Close(self.m_Id)
	end, 2):Start()
end

M.ClearAllTimers = function(self)
	if self.failCooldownTimer then
		self.failCooldownTimer:Stop()

		self.failCooldownTimer = nil
	end

	if self.nextDishTimer then
		self.nextDishTimer:Stop()

		self.nextDishTimer = nil
	end
end
