-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BeggarPayPanelStore.lua
-- Decompiled from: 02092_BeggarPayPanelStore.lua_b8d924bdbd05.luajit

local BeggarConfig = LTConfig.BeggarConfig
C_BeggarPayPanelStore = DefClass("C_BeggarPayPanelStore", C_BeggarPayPanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.BeggarPayPanelStore = C_BeggarPayPanelStore
local M = C_BeggarPayPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.PAY_STAGE = {
		["\\xe9\\xfa-\"(\\xc9"] = 2,
		["\\x9b\\x90<\\x94C\\xd8"] = 1,
		["\\x9b\\x90<\\x94]\\xd7"] = 0
	}
	self.bindData.payList.luaClick = self.CreateAction(self, "OnDonationItemClick")
	self.bindData.payList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderDonationItem")
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

M.InitModel = function(self, args)
	M.base.InitModel(args)

	self.donationChoice = {}
	self.switchTimer = nil
	local choices = BeggarConfig.DonationChoice

	if choices then
		for k, v in pairs(choices) do
			table.insert(self.donationChoice, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				donation = v,
				choice = k - 1
			})
		end
	end
end

M.InitView = function(self)
	self.bindData.payList:SetSimpleList(#self.donationChoice)

	local targetPlayerInfo = gLinkManager.LinkMember[gBeggarManager.donationPlayerId]

	if targetPlayerInfo then
		local spiritTemplateId = gCS.BattleNetcodeUtils.GetCurrentSpiritTemplateId(gBeggarManager.donationPlayerId)

		if spiritTemplateId then
			local fsConfig = LTConfig.FightSpiritConfig.GetConfig(spiritTemplateId)

			if fsConfig then
				self.bindData.playerName = string.format("%s\n<alpha=##AA>#F(20)（%s）#z", targetPlayerInfo.Name, fsConfig.Name)
				self.bindData.playerIcon = fsConfig.SHeadIconID
			end
		else
			print_error("获取玩家当前角色信息失败, pid : ", gBeggarManager.donationPlayerId)
		end
	end

	local selfTemplateId = gCS.BattleNetcodeUtils.GetCurrentSpiritTemplateId(gPlayerManager:GetLoginRolePid())

	if selfTemplateId then
		local fsConfig = LTConfig.FightSpiritConfig.GetConfig(selfTemplateId)

		if fsConfig then
			self.bindData.selfIcon = fsConfig.SHeadIconID
		end
	else
		print_error("获取当前玩家角色信息失败, pid : ", gBeggarManager.donationPlayerId)
	end

	self.isShow = true
	gBeggarManager.payPanel = self
end

M.OnClose = function(self)
	self.lastShowTime = nil
	self.isShow = false
	gBeggarManager.payPanel = nil
	self.donationChoice = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnUpdate = function(self)
	if self.lastShowTime then
		local delta = os.time() - self.lastShowTime

		if delta <= 2 then
			self.bindData.payStage = self.PAY_STAGE.PAY_WAIT
			self.lastShowTime = nil
		end
	end
end

M.OnRenderDonationItem = function(self, btn, index)
	local data = self.donationChoice[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if store and data then
		store.payNum = data.donation
	end
end

M.OnDonationItemClick = function(self, btn, data)
	if gBeggarManager.donationPlayerId and data and data.donation <= 0 then
		local payNum = data.donation
		slot4 = gClientToGameDelegate

		slot4:AskGiveToBeggar(gBeggarManager.donationPlayerId, data.choice).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			else
				self:OnDonationSuccess(payNum)
			end
		end
	end
end

M.OnDonationSuccess = function(self, data)
	self.bindData.payStage = self.PAY_STAGE.PAY_INFO
	self.bindData.payedNum = data
	self.lastShowTime = os.time()
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end
