-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewAddedNoticeStore.lua
-- Decompiled from: 01045_NewAddedNoticeStore.lua_3ca36e11305f.luajit

C_NewAddedNoticeStore = DefClass("C_NewAddedNoticeStore", C_NewAddedNoticeStore, C_StoreGroup)
GroupName2Class.NewAddedNoticeStore = C_NewAddedNoticeStore
local M = C_NewAddedNoticeStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.button.luaClick = self.CreateAction(self, "OnAddContactClick")
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

M.OnShow = function(self, panelId, args)
	self.panelId = panelId

	self.InitModel(self, args)
	self.InitView(self)
end

M.InitModel = function(self, args)
	self.areaIndex = args.areaIndex
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()

	self.popUpQueue:Push(args)
end

M.InitView = function(self)
	if not self.checkQueueCo then
		self.ExecuteShowQueue(self)
	end
end

M.ExecuteShowQueue = function(self)
	self.checkQueueCo = coroutine.start(function ()
		while self.popUpQueue.count <= 0 do
			local args = self.popUpQueue:Pop()
			local phoneNumber = args.phoneNumber

			self:RefreshPanelView(phoneNumber)
			coroutine.wait(2)
		end

		self:ClosePanel()

		self.checkQueueCo = nil
	end)
end

M.RefreshPanelView = function(self, phoneNumber)
	local configId = gCallPhoneUtils.GetConfigIdByPhoneNumber(nil, phoneNumber)
	self.currentPhoneNumber = phoneNumber
	local name = gCallPhoneUtils.GetContactNameByConfigId(configId)
	local avatarId = gCallPhoneUtils.GetSAvatarByConfigId(configId)
	self.bindData.name = name
	self.bindData.avatarId = avatarId
end

M.OnAddContactClick = function(self)
	gCallPhoneUtils.ShowContactDetailPanel(gBattleSpiritMgr.currentSpiritTemplateId, self.currentPhoneNumber)
end

M.ClosePanel = function(self)
	local closeAnimationName = "S_Vx_NewAddNotice_close"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)

	self.playCloseAnimationCo = coroutine.start(function ()
		coroutine.wait(clipTime)
		gPanelManager:Close(self.panelId)
	end)
end

M.OnClose = function(self)
	self.checkQueueCo = coroutine.stop(self.checkQueueCo)
end
