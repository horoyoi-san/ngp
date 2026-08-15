C_SceneReadingPanelStore = DefClass("C_SceneReadingPanelStore", C_SceneReadingPanelStore, C_CommonInfoPanelsBaseStore)
GroupName2Class.SceneReadingPanelStore = C_SceneReadingPanelStore
local M = C_SceneReadingPanelStore

function M:OnAwake()
	self.items = {}
	self.listTransform = self.bindData.freeList.transform
	self.bindData.freeList.luaRenderItem = self:CreateAction(self.OnRenderItem)

	function self.bindData.freeList.onGetTIndex(_)
		return 0
	end

	self.bindData.exitBtn.luaClick = self:CreateAction(self.ClosePanel)
	self.bindData.fullscreenBtn.luaClick = self:CreateAction(self.CloseAllItems)
end

function M:InitOnShow(data, panelTypeCfg)
	self.isCloseUpType = data.isCloseUpType

	if not self.isCloseUpType then
		self.bindData.showExitBtnCtrl = 1

		self.bindData.fullscreenBtn:SetActive(false)

		self.bindData.rStickNavRespond.luaGamePadInputChanged = self:CreateAction(self.OnRStickRotateCamera)
	end

	self.camera = gCS.CameraDataMgr.MainCamera

	self.bindData.freeList:SetList(#self.data)
end

function M:ClearOnClose()
	self.isCloseUpType = nil
	self.camera = nil
	local blurs = self.rootGo:GetComponentsInChildren(typeof(SGUI.UStaticBlur))

	for i = 0, blurs.Length - 1 do
		if gClientUtils.NotNil(blurs[i]) then
			blurs[i]:DeactivateBlur()
		end
	end
end

function M:UpdateItemPos(item)
	local targetTransform = item.target.transform
	local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(targetTransform.position, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.ScreenPointUI(item.transform.parent, Vector3.New(x, y, 0))

	item.transform:SetLocalPositionXY(UIPos.x, UIPos.y)
end

function M:OnCameraUpdate()
	for _, item in ipairs(self.items) do
		self:UpdateItemPos(item)
	end
end

function M:CloseAllItems()
	for _, item in ipairs(self.items) do
		item.store.showTypeCtrl = 0
	end

	self.bindData.noMoveNavArea.gameObject:SetActive(false)
end

function M:ItemOnClick(item)
	if item.store.showTypeCtrl > 0 then
		item.store.showTypeCtrl = 0

		self.bindData.noMoveNavArea.gameObject:SetActive(false)
	else
		self:CloseAllItems()

		local targetTransform = item.target.transform
		local targetScreenPos = self.camera:WorldToScreenPoint(targetTransform.position)
		local pos = gUtils:ScreenToUIPosition(targetScreenPos)
		local posY = pos.y

		if item.lastY and math.abs(item.lastY - posY) < 1 then
			posY = item.lastY
		end

		item.lastY = posY

		item.transform:SetSiblingIndex(item.transform.parent.childCount - 1)

		local blurs = item.transform:GetComponentsInChildren(typeof(SGUI.UStaticBlur))

		for i = 0, blurs.Length - 1 do
			if gClientUtils.NotNil(blurs[i]) then
				blurs[i]:ActiveBlur()
			end
		end

		if self.delayShow then
			self.delayShow = self.delayShow:Stop()
		end

		self.delayShow = FrameTimer.New(function ()
			if gClientUtils.IsNil(item.transform) then
				return
			end

			if posY > 0 then
				item.store.showTypeCtrl = 1
			else
				item.store.showTypeCtrl = 2
			end
		end, 1)

		self.delayShow:Start()

		if self.isCloseUpType then
			self.bindData.noMoveNavArea.gameObject:SetActive(true)
		else
			item.store.btn.interactable = false
		end
	end
end

function M:OnRenderItem(btn, csIndex)
	local itemData = self.data[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local item = {
		target = itemData.target,
		transform = btn.transform,
		store = store
	}

	table.insert(self.items, item)

	local cfgId = itemData.id
	local cfg = LTConfig.InformationConfig.GetConfig(cfgId)

	self:InitItemView(store, cfg)

	if self.isCloseUpType then
		self:UpdateItemPos(item)

		store.btn.luaClick = self:CreateActionWithArgs(self.ItemOnClick, item)
	else
		self:ItemOnClick(item)
	end

	self:UpdateItemPos(item)

	if csIndex == 0 and not self.bindData.firstNav then
		store.btn:Navigate(store.btn)

		self.bindData.firstNav = true
	end
end

function M:InitItemView(store, cfg)
	store.hasTitle = not string.is_null_or_empty(cfg.Title)
	store.showTypeCtrl = 0
	store.title = cfg.Title
	store.content = cfg.Content
end

function M:OnUpdate()
	if self.isRotatingCamera then
		gCameraUtils:DoRotateCameraByGamePad(1, self.rotateParam.x, self.rotateParam.y)
	end
end

function M:OnRStickRotateCamera(ctx)
	if ctx.canceled then
		self.isRotatingCamera = false
		self.rotateParam = nil
	else
		self.isRotatingCamera = true
		self.rotateParam = ctx:ReadValueVector2()
	end
end
