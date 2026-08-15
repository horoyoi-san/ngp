local BeggarConfig = LTConfig.BeggarConfig
C_BeggarPayPanelStore = DefClass("C_BeggarPayPanelStore", C_BeggarPayPanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.BeggarPayPanelStore = C_BeggarPayPanelStore
local M = C_BeggarPayPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.PAY_STAGE = {
		PAY_VFX = 2,
		PAY_INFO = 1,
		PAY_WAIT = 0
	}
	self.bindData.payList.luaClick = self:CreateAction("OnDonationItemClick")
	self.bindData.payList.luaSimpleRenderItem = self:CreateAction("OnRenderDonationItem")
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:InitModel(args)
	M.base.InitModel(args)

	self.donationChoice = {}
	self.switchTimer = nil
	local choices = BeggarConfig.DonationChoice

	if choices then
		for k, v in pairs(choices) do
			table.insert(self.donationChoice, {
				tIndex = 0,
				donation = v,
				choice = k - 1
			})
		end
	end
end

function M:InitView()
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

function M:OnClose()
	self.lastShowTime = nil
	self.isShow = false
	gBeggarManager.payPanel = nil
	self.donationChoice = nil
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnUpdate()
	if self.lastShowTime then
		local delta = os.time() - self.lastShowTime

		if delta > 2 then
			self.bindData.payStage = self.PAY_STAGE.PAY_WAIT
			self.lastShowTime = nil
		end
	end
end

function M:OnRenderDonationItem(btn, index)
	local data = self.donationChoice[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		store.payNum = data.donation
	end
end

function M:OnDonationItemClick(btn, data)
	if gBeggarManager.donationPlayerId and data and data.donation > 0 then
		local payNum = data.donation

		gClientToGameDelegate:AskGiveToBeggar(gBeggarManager.donationPlayerId, data.choice).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			else
				self:OnDonationSuccess(payNum)
			end
		end
	end
end

function M:OnDonationSuccess(data)
	self.bindData.payStage = self.PAY_STAGE.PAY_INFO
	self.bindData.payedNum = data
	self.lastShowTime = os.time()
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end
