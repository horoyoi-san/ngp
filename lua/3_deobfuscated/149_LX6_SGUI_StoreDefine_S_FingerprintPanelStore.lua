C_S_FingerprintPanelStore = DefClass("C_S_FingerprintPanelStore", C_S_FingerprintPanelStore, C_StoreGroup)
GroupName2Class.S_FingerprintPanelStore = C_S_FingerprintPanelStore
local M = C_S_FingerprintPanelStore
local fingerprintPrefix = "S_img_fgp0"
local texturePath = "Assets/Res/SGUI/Texture/FingerPrint/"

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.FingerPrintPieceArray.luaSimpleRenderItem = self:CreateAction("OnRenderTabItem")
	self.bindData.FingerPrintPieceResultArray.luaSimpleRenderItem = self:CreateAction("OnRenderResultTabItem")
	self.bindData.FingerPrintPieceResultArray.onGetTIndex = self:CreateAction("OnGetResultTIndex")
	self.bindData.ErrorCountList.luaSimpleRenderItem = self:CreateAction("OnRenderErrorTabItem")
	self.bindData.ErrorCountList.onGetTIndex = self:CreateAction("OnGetErrorTIndex")
	self.bindData.CloseBtn.luaClick = self:CreateAction("OnCloseBtnClick")
end

function M:OnGetResultTIndex(index)
	local luaIndex = index + 1

	if luaIndex <= #self.resultArray then
		return self.resultArray[luaIndex].tIndex or 1
	else
		return 1
	end
end

function M:OnGetErrorTIndex(index)
	local luaIndex = index + 1

	if luaIndex <= #self.tryArray then
		return self.tryArray[luaIndex].tIndex or 0
	else
		return 0
	end
end

function M:OnCloseBtnClick()
	if self.triggerEntity then
		self.triggerEntity:TryCallInnerSignal(self.interruptSignal)
	end

	gPanelManager:Close(gPanelId.S_FINGERPRINT_PANEL)
end

function M:onDrop(uWidget)
	if uWidget == nil then
		self.DragTemp.show = true

		self.bindData.FingerPrintPieceArray:SetSimpleList(#self.pieceArray)

		self.DragTemp = nil

		return
	end

	local dropId = uWidget.gameObject:GetInstanceID()
	local success = false

	for i = 1, #self.resultArray do
		local data = self.resultArray[i]

		if data.uWidgetId == dropId and self:DropItem(i) then
			success = true

			break
		end
	end

	if not success then
		self.DragTemp.show = true

		self.bindData.FingerPrintPieceArray:SetSimpleList(#self.pieceArray)
	end

	self.DragTemp = nil
end

function M:BeginDrag(dragIndex)
	self.DragTemp = self.pieceArray[dragIndex + 1]
	self.DragTemp.show = false

	self.bindData.FingerPrintPieceArray:SetSimpleList(#self.pieceArray)
end

function M:DropItem(index)
	if self.resultArray[index] == nil then
		return false
	end

	if not self.resultArray[index].isEmpty then
		return false
	end

	gSoundMgr:PlaySoundByTid(15001650)

	if self.DragTemp.targetId == index then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)

		local data = self.resultArray[index]
		data.tIndex = 1
		data.isEmpty = false
		data.pieceTexName = texturePath .. self.puzzleName .. "_0" .. index .. ".png"

		self.bindData.FingerPrintPieceResultArray:SetSimpleElement(index - 1, data.tIndex)

		local isAllClear = true

		for i = 1, #self.resultArray do
			if self.resultArray[i].isEmpty then
				isAllClear = false
			end
		end

		if isAllClear then
			self.bindData.Mission = "success"

			gCS.LuaUtils.PlayAnimationByName(self.bindData.PanelResultAnim, "S_Vx_FingerprintPanel_success")
			gSoundMgr:PlaySoundByTid(15001649)
			Timer.New(function ()
				if self.triggerEntity then
					self.triggerEntity:TryCallInnerSignal(self.successSignal)
				end

				gPanelManager:Close(gPanelId.S_FINGERPRINT_PANEL)
			end, 1):Start()
		end

		return true
	else
		gSoundMgr:PlaySoundByTid(15001651)

		self.errorCount = self.errorCount + 1

		if self.errorCount <= #self.tryArray then
			local data = self.tryArray[self.errorCount]
			local anim = self.tryArray[self.errorCount].store.ErrorCountAnim

			gCS.LuaUtils.PlayAnimation(anim)

			data.isError = true

			self.bindData.ErrorCountList:SetSimpleElement(self.errorCount - 1, 0)
		end

		if self.errorCount >= #self.tryArray then
			self.bindData.Mission = "failed"

			gCS.LuaUtils.PlayAnimationByName(self.bindData.PanelResultAnim, "S_Vx_FingerprintPanel_failed")
			Timer.New(function ()
				if self.triggerEntity then
					self.triggerEntity:TryCallInnerSignal(self.failSignal)
				end

				gPanelManager:Close(gPanelId.S_FINGERPRINT_PANEL)
			end, 1):Start()
		end

		return false
	end
end

function M:OnRenderResultTabItem(btn, index)
	if self.resultArray == nil then
		return
	end

	if index >= #self.resultArray then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local data = self.resultArray[index + 1]
	store.Id = data.Id
	self.resultArray[index + 1].uWidgetId = id
	store.ImagePath = data.pieceTexName

	if not data.isEmpty then
		store.ImageAlpha = 1
	else
		store.ImageAlpha = 0.5
	end

	store.Index = data.Index
end

function M:OnRenderTabItem(btn, index)
	local data = self.pieceArray[index + 1]

	if data.tIndex == 1 then
		return
	end

	if self.pieceArray == nil then
		return
	end

	if index >= #self.pieceArray then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	self.pieceArray[index + 1].uWidgetId = id
	store.Id = data.Id

	if not data.isEmpty then
		store.ImagePath = data.pieceTexName
	end

	store.Index = data.Index
	store.show = data.show and 1 or 0
	store.dropWidget.luaEndDrag = self:CreateAction("onDrop")
	store.dropWidget.luaBeginDrag = self:CreateActionWithArgs("BeginDrag", index)
end

function M:OnRenderErrorTabItem(btn, index)
	local data = self.tryArray[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	store.isError = data.isError
	data.store = store
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

function M:OnShow(panelId, data)
	self.qIndex = 1
	local rightCount = 3
	self.puzzleIndex = nil
	self.errorCount = 0

	if data then
		self.triggerEntity = gGadgetManager:GetEntitySearchByInstanceId(data.entityInstanceId)
		self.qIndex = data.puzzleName
		self.successSignal = data.successSignal
		self.failSignal = data.failSignal
		self.interruptSignal = data.interruptSignal
	end

	self.puzzleName = fingerprintPrefix .. self.qIndex
	local fgpCount = 4
	local errorTable = {}

	for i = 1, fgpCount do
		if i ~= self.qIndex then
			table.insert(errorTable, i)
		end
	end

	local resultArray = {}

	if self.puzzleIndex == nil then
		local pre = {}
		self.puzzleIndex = {}

		for i = 1, 9 do
			table.insert(pre, i)
		end

		for i = 1, rightCount do
			local r = math.random(1, #pre)

			table.insert(self.puzzleIndex, pre[r])
			table.remove(pre, r)
		end
	end

	local errorIndexTable = {}

	for i = 1, #errorTable do
		for j = 1, 9 do
			table.insert(errorIndexTable, {
				errorFgpIndex = errorTable[i],
				errorIndex = j
			})
		end
	end

	local errorCount = 9 - rightCount
	local randomError = {}

	for i = 1, errorCount do
		local r = math.random(1, #errorIndexTable)

		table.insert(randomError, errorIndexTable[r])
		table.remove(errorIndexTable, r)
	end

	for i = 1, 9 do
		local temp = {}

		if table.contains(self.puzzleIndex, i) then
			temp.isEmpty = true
			temp.pieceTexName = texturePath .. self.puzzleName .. "_0" .. i .. ".png"
			temp.tIndex = 1
		else
			temp.isEmpty = false
			temp.pieceTexName = texturePath .. self.puzzleName .. "_0" .. i .. ".png"
			temp.tIndex = 1
		end

		table.insert(resultArray, temp)
	end

	self.bindData.CompleteImgPath = texturePath .. self.puzzleName .. ".png"
	local array = {}

	for i = 1, 9 do
		local temp = {
			randomIndex = math.random(1, 100),
			show = true
		}

		if i <= rightCount then
			temp.rightId = i
			temp.targetId = self.puzzleIndex[i]
			temp.pieceTexName = texturePath .. self.puzzleName .. "_0" .. temp.targetId .. ".png"
			temp.tIndex = 0
		else
			temp.rightId = -1
			local errorInfo = randomError[i - rightCount]
			temp.pieceTexName = texturePath .. fingerprintPrefix .. errorInfo.errorFgpIndex .. "_0" .. errorInfo.errorIndex .. ".png"
			temp.tIndex = 0
		end

		table.insert(array, temp)
	end

	self.tryArray = {}
	local tryCount = 3

	for i = 1, tryCount do
		table.insert(self.tryArray, {
			isError = false
		})
	end

	self.bindData.ErrorCountList:SetSimpleList(#self.tryArray)
	table.sort(array, function (a, b)
		return a.randomIndex < b.randomIndex
	end)

	self.pieceArray = array
	self.resultArray = resultArray

	self.bindData.FingerPrintPieceArray:SetSimpleList(#self.pieceArray)
	self.bindData.FingerPrintPieceResultArray:SetSimpleList(#self.resultArray)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
