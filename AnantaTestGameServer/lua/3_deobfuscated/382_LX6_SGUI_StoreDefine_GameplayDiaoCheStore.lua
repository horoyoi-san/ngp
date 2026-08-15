C_GameplayDiaoCheStore = DefClass("C_GameplayDiaoCheStore", C_GameplayDiaoCheStore, C_StoreGroup)
GroupName2Class.GameplayDiaoCheStore = C_GameplayDiaoCheStore
local M = C_GameplayDiaoCheStore

function M:ctor()
	self.crane = nil
end

function M:OnAwake()
	self.bindData.LeftRotate.luaClick = self:CreateAction(self.OnLeftRotate)
	self.bindData.RightRotate.luaClick = self:CreateAction(self.OnRightRotate)
	self.bindData.Up.luaClick = self:CreateAction(self.Up)
	self.bindData.Down.luaClick = self:CreateAction(self.Down)
	self.bindData.dpadXRespond.luaGamePadInputChanged = self:CreateAction(self.OnDpadX)
	self.bindData.dpadYRespond.luaGamePadInputChanged = self:CreateAction(self.OnDpadY)
	self.bindData.Exit.luaClick = self:CreateAction(self.ClickClose)
end

function M:OnDestroy()
	self.crane = nil
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	local entityInstance = data.params[3]

	if entityInstance then
		local slotGo = entityInstance.gameObject
		local crane = slotGo:GetComponentInChildren(typeof(LX6.Drive.Crane.CraneRotate))
		self.crane = crane

		self:Refresh(crane)
	else
		self.crane = nil
	end

	if self.crane and data.liftBox then
		self.crane:SetLiftBox(data.liftBox)
		self.bindData.Up:SetActive(true)
		self.bindData.Down:SetActive(true)
		self:RefreshUpDown(self.crane)
	else
		self.bindData.Up:SetActive(false)
		self.bindData.Down:SetActive(false)
	end
end

function M:OnClose()
	return
end

function M:OnStart()
	return
end

function M:GetCrane()
	return self.crane
end

function M:Refresh(crane)
	return
end

function M:OnLeftRotate()
	local crane = self:GetCrane()

	if crane then
		if crane.IsLeftMost then
			gDisplayMessageMgr:ShowMessageContentDebug("CraneLeftMost")
		else
			crane:LeftRotate()
			self:Refresh(crane)
		end
	else
		print_error("crane is nil")
	end
end

function M:OnRightRotate()
	local crane = self:GetCrane()

	if crane then
		if crane.IsRightMost then
			gDisplayMessageMgr:ShowMessageContentDebug("CraneRightMost")
		else
			crane:RightRotate()
			self:Refresh(crane)
		end
	else
		print_error("crane is nil")
	end
end

function M:RefreshUpDown(crane)
	if crane then
		self.bindData.Up:SetActive(not crane.IsUpMost)
		self.bindData.Down:SetActive(not crane.IsDownMost)
	end
end

function M:Up()
	local crane = self:GetCrane()

	if crane then
		crane:Up()
		self:RefreshUpDown(crane)
	else
		print_error("crane is nil")
	end
end

function M:Down()
	local crane = self:GetCrane()

	if crane then
		crane:Down()
		self:RefreshUpDown(crane)
	else
		print_error("crane is nil")
	end
end

function M:OnDpadX(ctx)
	if ctx.performed then
		local dir = ctx:ReadValueFloat()

		if dir > 0 then
			self:OnRightRotate()
		elseif dir < 0 then
			self:OnLeftRotate()
		end
	end
end

function M:OnDpadY(ctx)
	if ctx.performed then
		local dir = ctx:ReadValueFloat()

		if dir > 0 then
			self:Up()
		elseif dir < 0 then
			self:Down()
		end
	end
end

function M:ClickClose()
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = "EndCrane"
	})
	gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StopGameplayByName("DiaoChe")
end
