-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineSequenceTapPanelStore.lua
-- Decompiled from: 01363_TimelineSequenceTapPanelStore.lua_953c3df0d849.luajit

C_TimelineSequenceTapPanelStore = DefClass("C_TimelineSequenceTapPanelStore", C_TimelineSequenceTapPanelStore, C_StoreGroup)
GroupName2Class.TimelineSequenceTapPanelStore = C_TimelineSequenceTapPanelStore
local M = C_TimelineSequenceTapPanelStore

M.ctor = function(self)
	self.readyAnimName = "S_Vx_TokusatsuQTETemplate_ready"
	self.successAnimName = "S_Vx_TokusatsuQTETemplate_success"
	self.failAnimName = "S_Vx_TokusatsuQTETemplate_fail"
	self.triangleSuccessAnimName = "S_Vx_TokusatsuQTETemplate_success02"
end

M.OnShow = function(self, panelId, data)
	local panelData = data:ToTable()
	self.adaptive = panelData.Adaptive
	self.finish = false
	local keys = panelData.keys:ToTable()
	self.keys = self:InitKeys(keys)
	self.currentIndex = 0
	self.bindData.BtnList.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.BtnList.luaSimpleClick = self:CreateAction("OnListClick")
	self.bindData.BtnList.onGetTIndex = self:CreateAction("OnGetTIndex")

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.mobileUpBtn.luaClick = self.CreateActionWithArgs(self, "OnMobileBtnClick", 4)
		self.bindData.mobileDownBtn.luaClick = self.CreateActionWithArgs(self, "OnMobileBtnClick", 1)
		self.bindData.mobileLeftBtn.luaClick = self.CreateActionWithArgs(self, "OnMobileBtnClick", 0)
		self.bindData.mobileRightBtn.luaClick = self.CreateActionWithArgs(self, "OnMobileBtnClick", 3)
		self.bindData.mobileConfirmBtn.luaClick = self.CreateActionWithArgs(self, "OnMobileBtnClick", 2)
	end

	self.leftStickState = -1
	self.bindData.leftJoyStick.luaGamePadInputChanged = self:CreateAction("OnJoyStickInputChanged")

	self.bindData.BtnList:SetSimpleList(#self.keys)
end

M.InitKeys = function(self, keys)
	local keyViews = {}

	for index, value in ipairs(keys) do
		local view = {
			index = index,
			btnType = value,
			btnMode = 0
		}

		table.insert(keyViews, view)
	end

	return keyViews
end

M.GetBtnStoreByWidget = function(self, widget)
	if not widget then
		return nil
	end

	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end

M.OnRenderItem = function(self, btn, index)
	local store = self.GetBtnStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.keys[index + 1]
	data.btn = btn
	store.btnMode = data.btnMode
	store.btnType = data.btnType

	if index ~= self.currentIndex then
		if self.adaptive ~= 0 or self.adaptive ~= 2 then
			self.SetPcKey(self, data.btn, data.btnType)
		elseif self.adaptive ~= 1 then
			self.SetControllerKey(self, data.btn, data.btnType)
		end
	end
end

M.SetPcKey = function(self, btn, type)
	local pcKey = 0

	if type ~= 0 then
		pcKey = 12
	elseif type ~= 1 then
		pcKey = 13
	elseif type ~= 2 then
		pcKey = 38
	end

	btn:SetPCKeyInfoWithOutTip(pcKey, 0, 0, 0, 20)

	local store = self:GetBtnStoreByWidget(btn)
	store.btnMode = 4

	store.animation:Play(self.readyAnimName)
end

M.SetControllerKey = function(self, btn, type)
	local store = self:GetBtnStoreByWidget(btn)
	store.btnMode = 4

	store.animation:Play(self.readyAnimName)

	if type ~= 2 then
		self.bindData.controllerKey.luaClick = self.CreateActionWithArgs(self, "OnBtnClick", self.currentIndex + 1)
	end
end

M.OnListClick = function(self, btn, index)
	if self.finish then
		return
	end

	local data = self.keys[index + 1]

	self.OnBtnClick(self, data.index)
end

M.OnMobileBtnClick = function(self, btnType)
	local curData = self.keys[self.currentIndex + 1]

	if curData.btnType ~= btnType then
		self.OnBtnClick(self, self.currentIndex + 1)
	else
		gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 0)
	end
end

M.OnBtnClick = function(self, index)
	if self.finish then
		return
	end

	if index ~= self.currentIndex + 1 then
		local curData = self.keys[index]
		local store = self:GetBtnStoreByWidget(curData.btn)
		store.btnMode = 2

		gSoundMgr:PlaySoundByExternalSource("exhandle_qtecommonheavy1", LX6.Audio.ExternalSourceType.Motion_2D)

		if self.adaptive ~= 1 and store.btnType ~= 2 then
			store.animation:Play(self.triangleSuccessAnimName)
		else
			store.animation:Play(self.successAnimName)
		end

		self.currentIndex = self.currentIndex + 1

		gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)

		local data = self.keys[index + 1]

		if data then
			self.SetPcKey(self, data.btn, data.btnType)
		end
	end
end

M.OnGetTIndex = function(self, index)
	return self.adaptive
end

M.OnJoyStickInputChanged = function(self, context)
	local value = context.ReadValueVector2(context)
	local targetStickState = -1

	if value.x * value.x + value.y * value.y <= 0.64 then
		if Mathf.Abs(value.y) >= Mathf.Abs(value.x) then
			if value.x <= 0 then
				targetStickState = 3
			else
				targetStickState = 0
			end
		elseif value.y <= 0 then
			targetStickState = 4
		else
			targetStickState = 1
		end
	end

	if targetStickState == self.leftStickState then
		if targetStickState == -1 then
			local curData = self.keys[self.currentIndex + 1]

			if curData.btnType ~= targetStickState then
				local store = self:GetBtnStoreByWidget(curData.btn)
				store.btnMode = 2

				store.animation:Play(self.successAnimName)
				gSoundMgr:PlaySoundByExternalSource("exhandle_qtecommonheavy1", LX6.Audio.ExternalSourceType.Motion_2D)

				self.currentIndex = self.currentIndex + 1

				gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)

				local data = self.keys[self.currentIndex + 1]

				if data then
					self.SetControllerKey(self, data.btn, data.btnType)
				end
			else
				gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 0)
			end
		end

		self.leftStickState = targetStickState
	end
end

M.PlayClickAnimByCS = function(self, btn2)
end

M.PlaySuccessEndAnim = function(self)
	self.finish = true

	if #self.keys < 0 then
		return 0
	end

	local btn = self.keys[1].btn

	if not btn then
		return 0
	end

	local store = self.GetBtnStoreByWidget(self, btn)
	local targetAnim = self.successAnimName

	if self.adaptive ~= 1 and store.btnType ~= 2 then
		targetAnim = self.triangleSuccessAnimName
	end

	local clip = store.animation:GetClip(targetAnim)

	if clip then
		return clip.length
	end

	return 0
end

M.PlaySuccessEndAnim2 = function(self)
	return 0
end

M.ClosePanelFailed = function(self)
	gSoundMgr:PlaySoundByExternalSource("exhandle_qtecommon1", LX6.Audio.ExternalSourceType.Motion_2D)

	self.finish = true

	if #self.keys < 0 then
		return 0
	end

	local btn = self.keys[1].btn

	if not btn then
		return 0
	end

	local store = self:GetBtnStoreByWidget(btn)
	local clip = store.animation:GetClip(self.failAnimName)

	if clip then
		for i = self.currentIndex + 1, #self.keys do
			local store2 = self:GetBtnStoreByWidget(self.keys[i].btn)

			store2.animation:Play(self.failAnimName)
		end

		return clip.length
	end

	return 0
end

M.SetProgress0 = function(self, progress)
end

M.SetProgress1 = function(self, progress)
end
