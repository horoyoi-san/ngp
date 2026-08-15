BigMapComp_FactionOverride = BigMapComp_FactionOverride or {}
local M = BigMapComp_FactionOverride
M.__index = M
local FactionConfig = LTConfig.FactionConfig
local FactionDispositionConfig = LTConfig.FactionDispositionConfig
local FactionTextConfig = LTConfig.FactionDetailChatTextConfig
local BUBBLE_PADDING = 5
local BUBBLE_ANIMATING_TIME = 0.35

function M:OnInit()
	self.tab = self.bindData.factionOverride
	self.currentDisturbEventPeopleInfos = {}
	self.currentFactionPeopleInfos = {
		widgets = {}
	}
	self.askedFactionInteractionInfo = {}
	self.factionPeopleDataCache = {}

	self:InitLevelBubbleTexts()
end

function M:OnStart()
	self.tab.OnRenderTab = self.bigMap:CreateAction("OnRenderFactionTab", self)
	self.tab.selectedIndex = 0
end

function M:OnEnd()
	self.tab.selectedIndex = -1

	self.tab:ClearUnusedTabInstances()
end

function M:OnActive()
	self:TryActive()
	self.bigMap:RefreshPinBtnState()
	self:RegisterEvent()
end

function M:OnInactive()
	if self.store then
		self.rootWidget:SetActive(false)
		self:ClearBubbleOnMap()
		self:HideFactionPeople()
		self:HideDisturbEventPeople()
	end

	self:UnRegisterEvent()
end

function M:RegisterEvent()
	if self._eventRegistered == true then
		return
	end

	if not self._factionEventHandler then
		function self._factionEventHandler(eventId, factionId)
			self.factionPeopleDataCache[factionId] = nil

			if self.curPeopleShowFactionId == factionId then
				self:ShowFactionPeople(factionId)
			end
		end
	end

	self._eventRegistered = true

	gMessageManager:AddMessageListener(gEventConstants.FACTION_INFO_CHANGE, self._factionEventHandler)
end

function M:UnRegisterEvent()
	if self._eventRegistered ~= true then
		return
	end

	self._eventRegistered = false

	gMessageManager:RemoveMessageListener(gEventConstants.FACTION_INFO_CHANGE, self._factionEventHandler)
end

function M:OnRenderFactionTab(index, tab)
	local store = gStoreManager:GetStoreGroup("BigMap_Faction"):GetStoreByWidget(tab)
	self.rootWidget = tab
	self.store = store
	self.bindData.peopleList.luaRenderItem = self.bigMap:CreateAction("OnRenderFactionPeople", self)
	self.bindData.peopleList.onGetTIndex = self.bigMap:CreateAction("OnGetFactionPeopleTIndex", self)
	self.bindData.eventPeopleList.luaRenderItem = self.bigMap:CreateAction("OnRenderDistrubEventPeople", self)
	self.bindData.eventPeopleList.onGetTIndex = self.bigMap:CreateAction("OnGetDistrubEventPeopleTIndex", self)

	self:TryActive()
	self.bigMap:RefreshPinBtnState()
end

function M:TryActive()
	if not self.store then
		return
	end

	if not self.actived then
		self.rootWidget:SetActive(false)

		return
	end

	self.rootWidget:SetActive(true)
	self.bigMap:SetViewMask(EMapViewMask.Faction)
	self.bigMap.compRefs.SwitchMapMode:SetMode("Faction")
	self:ShowDisturbEventPeople()
end

function M:OnUpdate()
	if self.actived and not self.bubbleActive then
		self:TryAddInitBubbles()
	end

	if not self.actived and self.bubbleActive then
		self:ClearBubbleOnMap()
	end

	self:TickChatBubbles()
	self:TickDisturbEventPeopleScale()
	self:TickFactionPeopleScale()
end

function M:TryAddInitBubbles()
	local factionInfos = {}

	for _, info in pairs(self.bigMap._id2ElementInfo) do
		if info and info.element and info.element.type == EMapElementType.Faction and info.element.userdata and info.element.userdata.factionId then
			table.insert(factionInfos, info)
		end
	end

	if #factionInfos == 0 then
		return
	end

	self:ClearBubbleOnMap()

	for i = 1, #factionInfos do
		local info = factionInfos[i]
		local factionId = info.element.userdata.factionId

		if factionId then
			local maskWidget = self.bindData.chatMaskPool:GetItem(0)
			local factionChatsInfo = {
				curCd = 99,
				newBubbleCd = 99,
				animatingHeight = 0,
				remainAnimatingTime = 0,
				factionId = factionId,
				elementId = info.id,
				bubbles = {},
				baseTexPos = info.texPos,
				maskWidget = maskWidget
			}
			local factionInfo = gClientUtils.GetFactionInfo(factionId)
			local level = factionInfo.DispositionLevel
			local levelCfg = FactionDispositionConfig.GetConfig(level)
			local nextCfg = FactionDispositionConfig.GetConfig(level + 1)
			local maxDispositionValue = nextCfg and nextCfg.DispositionValue or 9999999
			local rate = (factionInfo.Disposition - levelCfg.DispositionValue) / (maxDispositionValue - levelCfg.DispositionValue)
			local needChatNum = 0

			for j = #levelCfg.chatNum, 1, -1 do
				if levelCfg.chatNum[j].rate <= rate then
					needChatNum = levelCfg.chatNum[j].num

					break
				end
			end

			for j = #FactionConfig.CommentRefreshCD, 1, -1 do
				if FactionConfig.CommentRefreshCD[j].disposition <= factionInfo.Disposition then
					factionChatsInfo.newBubbleCd = FactionConfig.CommentRefreshCD[j].cd
					factionChatsInfo.curCd = factionChatsInfo.newBubbleCd

					break
				end
			end

			maskWidget.rectTransform:SetLocalPositionXY(info.texPos.x, info.texPos.y + 60)

			maskWidget.rectTransform.sizeDelta = Vector2.New(400, needChatNum * 90)
			factionChatsInfo.maskHeight = needChatNum * 90

			for j = 1, needChatNum do
				self:AddNewBubble(factionChatsInfo)
			end

			self:LayoutBubbles(factionChatsInfo, 0)

			self.chatBubbleInfos[factionId] = factionChatsInfo
		end
	end

	self.bubbleActive = true
end

function M:TickChatBubbles()
	if not self.bubbleActive or not self.chatBubbleInfos or not next(self.chatBubbleInfos) then
		return
	end

	local factionsToRemove = nil
	local dT = Time.deltaTime

	for id, factionBubbleInfo in pairs(self.chatBubbleInfos) do
		local info = self.bigMap._id2ElementInfo[factionBubbleInfo.elementId]

		if not info then
			factionsToRemove = factionsToRemove or {}

			table.insert(factionsToRemove, id)
		else
			factionBubbleInfo.curCd = factionBubbleInfo.curCd - dT

			if factionBubbleInfo.curCd <= 0 then
				self:AddNewBubble(factionBubbleInfo, true)

				local bubbleHeight = factionBubbleInfo.bubbles[1].widget.rectTransform.rect.height
				factionBubbleInfo.curCd = factionBubbleInfo.newBubbleCd + math.random() * 2 - 1
				factionBubbleInfo.remainAnimatingTime = BUBBLE_ANIMATING_TIME + dT
				factionBubbleInfo.animatingHeight = BUBBLE_PADDING + bubbleHeight
			end

			local animateOffset = 0

			if factionBubbleInfo.remainAnimatingTime > 0 then
				factionBubbleInfo.remainAnimatingTime = factionBubbleInfo.remainAnimatingTime - dT

				if factionBubbleInfo.remainAnimatingTime <= 0 then
					factionBubbleInfo.remainAnimatingTime = 0
				end

				animateOffset = factionBubbleInfo.animatingHeight - self:SampleBubbleCurve(1 - factionBubbleInfo.remainAnimatingTime / BUBBLE_ANIMATING_TIME) * factionBubbleInfo.animatingHeight
			end

			self:LayoutBubbles(factionBubbleInfo, -animateOffset)
		end
	end

	if factionsToRemove then
		for _, removeId in pairs(factionsToRemove) do
			local removeInfo = self.chatBubbleInfos[removeId]

			if removeInfo then
				for _, chatBubble in pairs(removeInfo.bubbles) do
					if chatBubble and chatBubble.widget then
						self.bindData.chatBubblePool:DeleteItem(chatBubble.widget)
					end
				end

				self.chatBubbleInfos[removeId] = nil
			end
		end
	end
end

function M:ClearBubbleOnMap()
	if not self.chatBubbleInfos then
		self.chatBubbleInfos = {}
	end

	for _, factionBubbleInfo in pairs(self.chatBubbleInfos) do
		for _, chatBubble in pairs(factionBubbleInfo.bubbles) do
			if chatBubble and chatBubble.widget then
				self.bindData.chatBubblePool:DeleteItem(chatBubble.widget)
			end
		end

		self.bindData.chatMaskPool:DeleteItem(factionBubbleInfo.maskWidget)
	end

	table.clear(self.chatBubbleInfos)

	self.bubbleActive = false
end

function M:InitLevelBubbleTexts()
	self.factionLevelBubbleTexts = {}

	for i = 0, FactionConfig.count - 1 do
		local cfg = FactionConfig.LoadAt(i)

		if cfg.DetailDisposition then
			if #cfg.DetailDisposition ~= 0 then
				local factionId = cfg.Id
				local factionTextsInfo = {}
				self.factionLevelBubbleTexts[factionId] = factionTextsInfo

				for level = 1, cfg.MaxDispositionLevel do
					factionTextsInfo[level] = {}
				end

				for j = 1, #cfg.DetailDisposition do
					local detailCfg = cfg.DetailDisposition[j]
					local level = detailCfg.DispositionID

					if detailCfg.Chat and detailCfg.Chat ~= 0 then
						table.insert(factionTextsInfo[level], detailCfg.Chat)
					end
				end
			end
		end
	end
end

function M:GetNonExistRandomTextId(factionBubbleInfo)
	if not self.factionLevelBubbleTexts then
		self:InitLevelBubbleTexts()
	end

	local factionId = factionBubbleInfo.factionId
	local factionInfo = gClientUtils.GetFactionInfo(factionId)
	local level = factionInfo.DispositionLevel
	local factionTexts = self.factionLevelBubbleTexts[factionId]
	local availableTexts = factionTexts[level]
	local existingTextIds = gGpsTools.GetTable()

	table.clear(existingTextIds)

	for _, bubble in ipairs(factionBubbleInfo.bubbles) do
		if bubble.textId then
			existingTextIds[bubble.textId] = true
		end
	end

	local unusedTextIds = gGpsTools.GetTable()

	for _, textId in ipairs(availableTexts) do
		if not existingTextIds[textId] then
			table.insert(unusedTextIds, textId)
		end
	end

	gGpsTools.ReleaseTable(existingTextIds)

	if #unusedTextIds == 0 then
		gGpsTools.ReleaseTable(unusedTextIds)
		print_error("XXX_All faction bubble texts have been used for factionId:", factionId, "level:", level)

		return availableTexts[math.random(1, #availableTexts)]
	end

	local randomIndex = math.random(1, #unusedTextIds)
	local ret = unusedTextIds[randomIndex]

	gGpsTools.ReleaseTable(unusedTextIds)

	return ret
end

function M:AddNewBubble(factionBubbleInfo, addToFront)
	addToFront = addToFront or false
	local maskStore = gStoreManager:GetStoreGroup("BigMap_RectMaskTemplate"):GetStoreByWidget(factionBubbleInfo.maskWidget)
	local widget = self.bindData.chatBubblePool:GetItem(0)

	widget.transform:SetParent(maskStore.maskTrans)
	widget.rectTransform:SetLocalScaleXY(1, 1)

	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(widget)
	local textId = self:GetNonExistRandomTextId(factionBubbleInfo)
	local chatBubble = {
		widget = widget,
		store = store,
		textId = textId
	}
	local text = FactionTextConfig.GetConfig(textId).DetailChat
	store.text = text

	if store.genAnim then
		store.genAnim:Play("S_MapPowerIconDialog_open")
	end

	if addToFront then
		table.insert(factionBubbleInfo.bubbles, 1, chatBubble)
	else
		table.insert(factionBubbleInfo.bubbles, chatBubble)
	end
end

function M:DeleteLastBubble(factionBubbleInfo)
	local lastBubble = table.remove(factionBubbleInfo.bubbles)

	if lastBubble and lastBubble.widget then
		self.bindData.chatBubblePool:DeleteItem(lastBubble.widget)
	end
end

function M:LayoutBubbles(factionBubbleInfo, offsetY)
	offsetY = offsetY or 0
	local reverseScale = 1 / self.bigMap.scale
	local baseY = 0
	local maskWidget = factionBubbleInfo.maskWidget

	maskWidget.rectTransform:SetLocalScaleXY(reverseScale, reverseScale)
	maskWidget.rectTransform:SetLocalPositionXY(factionBubbleInfo.baseTexPos.x, factionBubbleInfo.baseTexPos.y + 60 * reverseScale)

	local accumulatedHeight = 0
	local needRemove = false

	for i, chatBubble in ipairs(factionBubbleInfo.bubbles) do
		local widget = chatBubble.widget

		if widget then
			local yPos = baseY + accumulatedHeight + offsetY

			widget.rectTransform:SetLocalPositionXY(0, yPos)

			if factionBubbleInfo.maskHeight < yPos then
				needRemove = true
			end

			accumulatedHeight = accumulatedHeight + widget.rectTransform.rect.height + BUBBLE_PADDING
		end
	end

	if needRemove then
		self:DeleteLastBubble(factionBubbleInfo)
	end
end

function M:SampleBubbleCurve(percent)
	return 1 - math.pow(1 - percent, 3)
end

function M:ShowDisturbEventPeople()
	table.clear(self.currentDisturbEventPeopleInfos)

	for _, eventInfo in pairs(gMapSubSystem_Faction.disturbEventInfos) do
		local info = {
			position = eventInfo.position,
			areaId = eventInfo.areaId,
			peopleType = eventInfo.peopleEnum
		}
		self.currentDisturbEventPeopleInfos[#self.currentDisturbEventPeopleInfos + 1] = info
	end

	self.bindData.eventPeopleList:SetList(#self.currentDisturbEventPeopleInfos)
end

function M:HideDisturbEventPeople()
	for _, info in pairs(self.currentDisturbEventPeopleInfos) do
		if info.widget and info.widget.rectTransform then
			info.widget.rectTransform:SetLocalPositionXY(-99999, -99999)
		end
	end

	self.bindData.eventPeopleList:SetList(0)
end

function M:OnGetDistrubEventPeopleTIndex(index)
	index = index + 1
	local data = self.currentDisturbEventPeopleInfos[index]

	return data.peopleType
end

function M:OnRenderDistrubEventPeople(btn, index)
	index = index + 1
	local data = self.currentDisturbEventPeopleInfos[index]
	local texPos = self.bigMap:TransformWorldToTex(data.position, data.areaId)
	local reverseScale = 1 / self.bigMap.scale

	btn.rectTransform:SetLocalPositionXY(texPos.x, texPos.y)
	btn.rectTransform:SetLocalScaleXY(reverseScale, reverseScale)

	self.currentDisturbEventPeopleInfos[index].widget = btn
end

function M:TickDisturbEventPeopleScale()
	local reverseScale = 1 / self.bigMap.scale

	for _, info in pairs(self.currentDisturbEventPeopleInfos) do
		if info.widget and info.widget.rectTransform then
			info.widget.rectTransform:SetLocalScaleXY(reverseScale, reverseScale)
		end
	end
end

local MapBlockMgr = LX6.Gps.MapBlockMgr

function M:ShowFactionPeople(factionId)
	self.curPeopleShowFactionId = factionId
	local cache = self:GetFactionPeopleData(factionId)
	self.currentFactionPeopleInfos.personTypeInfo = cache.personTypeInfo
	self.currentFactionPeopleInfos.positions = cache.positions

	table.clear(self.currentFactionPeopleInfos.widgets)
	self.bindData.peopleList:SetList(#self.currentFactionPeopleInfos.positions)
end

function M:GetFactionPeopleData(factionId)
	if not self.factionPeopleDataCache[factionId] then
		local factionInfo = gClientUtils.GetFactionInfo(factionId)

		if not factionInfo then
			print_error("#NoCreateIssue 势力地图:势力id为" .. tostring(factionId) .. "的FactionInfo不存在")

			return
		end

		local personTypeInfo = {
			totalWeight = 0,
			units = {}
		}
		local personTypes = FactionConfig.GetConfig(factionId).PersonImage

		for _, typeInfo in pairs(personTypes) do
			if typeInfo.EnableDisposition <= factionInfo.DispositionLevel then
				table.insert(personTypeInfo.units, {
					type = typeInfo.PerfabType,
					weight = typeInfo.weight
				})

				personTypeInfo.totalWeight = personTypeInfo.totalWeight + typeInfo.weight
			end
		end

		local positionsList = {}
		local personDistribution = FactionConfig.GetConfig(factionId).PersonDistribution

		for _, dist in pairs(personDistribution) do
			local positions = MapBlockMgr.GetFactionAreaPositions(23300888, dist.AreaID, dist.num)

			if not positions then
				print_error("#NoCreateIssue 势力地图:势力id为" .. tostring(factionId) .. " AreaId 为" .. tostring(dist.AreaID) .. "的范围信息不存在或配置有问题")
			else
				for i = 0, positions.Count - 1 do
					table.insert(positionsList, positions[i])
				end
			end
		end

		self.factionPeopleDataCache[factionId] = {
			personTypeInfo = personTypeInfo,
			positions = positionsList
		}
	end

	return self.factionPeopleDataCache[factionId]
end

function M:HideFactionPeople()
	self.curPeopleShowFactionId = nil

	for _, info in pairs(self.currentFactionPeopleInfos) do
		if info.widget and info.widget.rectTransform then
			info.widget.rectTransform:SetLocalPositionXY(-99999, -99999)
		end
	end

	table.clear(self.currentFactionPeopleInfos.widgets)

	self.currentFactionPeopleInfos.personTypeInfo = nil
	self.currentFactionPeopleInfos.positions = nil

	self.bindData.peopleList:SetList(0)
end

function M:OnGetFactionPeopleTIndex(index)
	local randomValue = math.random() * self.currentFactionPeopleInfos.personTypeInfo.totalWeight
	local currentWeight = 0

	for i, typeInfo in ipairs(self.currentFactionPeopleInfos.personTypeInfo.units) do
		currentWeight = currentWeight + typeInfo.weight

		if randomValue <= currentWeight then
			return typeInfo.type
		end
	end

	return 0
end

function M:OnRenderFactionPeople(btn, index)
	index = index + 1
	local data = self.currentFactionPeopleInfos.positions[index]
	local tx, ty = self.bigMap:TransformWorldXZToTexXY(data.x, data.y, self.bigMap.areaId)
	local reverseScale = 1 / self.bigMap.scale
	local texPos = Vector2.New(tx, ty)

	btn.rectTransform:SetLocalPositionXY(texPos.x, texPos.y)
	btn.rectTransform:SetLocalScaleXY(reverseScale, reverseScale)

	self.currentFactionPeopleInfos.widgets[index] = btn
end

function M:TickFactionPeopleScale()
	local reverseScale = 1 / self.bigMap.scale

	for i = 1, #self.currentFactionPeopleInfos.widgets do
		local widget = self.currentFactionPeopleInfos.widgets[i]

		if widget and widget.rectTransform then
			widget.rectTransform:SetLocalScaleXY(reverseScale, reverseScale)
		end
	end
end

function M:OnAttachElement(id, element, source)
	if not self.actived then
		return
	end

	if element.subSystemType ~= EMapSubSystemType.Faction then
		self:HideFactionPeople()

		return
	end

	local factionId = element.userdata.factionId

	if factionId and factionId ~= self.curPeopleShowFactionId then
		self:HideFactionPeople()
		self:ShowFactionPeople(factionId)
	end
end

function M:OnClearAttachedElement()
	self:HideFactionPeople()
end

local MAX_ASK_FACTION_INFO_RETRY = 3

function M:AskFactionInteractionInfo(factionId, sucCb)
	if self.askedFactionInteractionInfo[factionId] then
		local factionInfo = gClientUtils.GetFactionInfo(factionId)

		sucCb(factionId, factionInfo.InteractionCount, factionInfo.GreetCount)

		return
	end

	self:DoAskFactionInteractionInfo(factionId, sucCb, 0)
end

function M:DoAskFactionInteractionInfo(factionId, sucCb, retryCount)
	gClientToGameDelegate:AskFactionInfo(factionId).Callback = function (err, data)
		if not self.actived then
			return
		end

		self:OnAskFactionInteractionInfoCb(err, factionId, data, sucCb, retryCount)
	end
end

function M:OnAskFactionInteractionInfoCb(err, factionId, data, sucCb, retryCount)
	if err == LTConfig.MessageConfig.Ok then
		if not data then
			print_error("势力地图OnAskFactionInteractionInfoCb:势力id为" .. tostring(factionId) .. "的FactionInfo不存在")

			return
		end

		local factionInfo = gClientUtils.GetFactionInfo(factionId)
		factionInfo.InteractionCount = data.InteractionCount
		factionInfo.GreetCount = data.GreetCount
		self.askedFactionInteractionInfo[factionId] = true

		if sucCb then
			sucCb(factionId, data.InteractionCount, data.GreetCount)
		end
	else
		retryCount = retryCount + 1

		if retryCount < MAX_ASK_FACTION_INFO_RETRY then
			print_warn("势力地图AskFactionInteractionInfo:势力id=" .. tostring(factionId) .. " 请求失败，第" .. retryCount .. "次重试")
			self:DoAskFactionInteractionInfo(factionId, sucCb, retryCount)
		else
			print_error("势力地图AskFactionInteractionInfo:势力id=" .. tostring(factionId) .. " 请求失败，已达到最大重试次数" .. MAX_ASK_FACTION_INFO_RETRY)
		end
	end
end
