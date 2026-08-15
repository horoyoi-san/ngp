C_NewAddedNoticeStore = DefClass("C_NewAddedNoticeStore", C_NewAddedNoticeStore, C_StoreGroup)
GroupName2Class.NewAddedNoticeStore = C_NewAddedNoticeStore
local M = C_NewAddedNoticeStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.button.luaClick = self:CreateAction("OnAddContactClick")
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

function M:OnShow(panelId, args)
	self.panelId = panelId

	self:InitModel(args)
	self:InitView()
end

function M:InitModel(args)
	self.areaIndex = args.areaIndex
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()

	self.popUpQueue:Push(args)
end

function M:InitView()
	if not self.checkQueueCo then
		self:ExecuteShowQueue()
	end
end

function M:ExecuteShowQueue()
	self.checkQueueCo = coroutine.start(function ()
		while self.popUpQueue.count > 0 do
			local args = self.popUpQueue:Pop()
			local phoneNumber = args.phoneNumber

			self:RefreshPanelView(phoneNumber)
			coroutine.wait(2)
		end

		self:ClosePanel()

		self.checkQueueCo = nil
	end)
end

function M:RefreshPanelView(phoneNumber)
	local configId = gCallPhoneUtils.GetConfigIdByPhoneNumber(nil, phoneNumber)
	self.currentPhoneNumber = phoneNumber
	local name = gCallPhoneUtils.GetContactNameByConfigId(configId)
	local avatarId = gCallPhoneUtils.GetSAvatarByConfigId(configId)
	self.bindData.name = name
	self.bindData.avatarId = avatarId
end

function M:OnAddContactClick()
	gCallPhoneUtils.ShowContactDetailPanel(gBattleSpiritMgr.currentSpiritTemplateId, self.currentPhoneNumber)
end

function M:ClosePanel()
	local closeAnimationName = "S_Vx_NewAddNotice_close"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)

	self.playCloseAnimationCo = coroutine.start(function ()
		coroutine.wait(clipTime)
		gPanelManager:Close(self.panelId)
	end)
end

function M:OnClose()
	self.checkQueueCo = coroutine.stop(self.checkQueueCo)
end
