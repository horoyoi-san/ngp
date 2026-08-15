C_PinHaoBanManager = DefClass("C_PinHaoBanManager", C_PinHaoBanManager)
local M = C_PinHaoBanManager
local PinHaoBanSlot = LX6.Share.PinHaoBanSlot
local PinHaoBanDefine = LX6.Share.PinhaobanDefine
local Rigidbody = UnityEngine.Rigidbody
local PHBSlot = LX6.Share.PHBSlot

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.INIT_PINHAOBAN_DATA, function (eventId, data)
		gPinHaoBanManager:OnInitPinhaobanData(eventId, data)
	end)
	gMessageManager:AddMessageListener(gEventConstants.PINHAOBAN_UI_CHANGE, function (eventId, data)
		gPinHaoBanManager:OnUIChange(eventId, data)
	end)
	gMessageManager:AddMessageListener(gEventConstants.PINHAOBAN_CLEAR, function (eventId, data)
		gPinHaoBanManager:ClearData(eventId, data)
	end)
	self:InitData()
end

function M:InitData()
	self.hasGoToEnd = false
	self.slotCount = 0
	self.type = {
		item = 0,
		slot = 1
	}
	self.itemIndexMap = {
		toiletGo = 3,
		armGo = 2,
		handGo = 1,
		headGo = 0
	}
	self.slotIndexMap = {
		handSlot = 1,
		headSlot = 0,
		shoulderSlot = 2
	}
	self.itemsContainer = {}
	self.slotContainer = {}
	self.slotSetMap = {}
	self.timelineName = "TL_TAF_010_Q010_S04"
	self.timer1 = 0
	self.timer2 = 0
	self.timer3 = 0
	self.timer45 = 0
	self.hasShowOnceDialog1 = false
	self.hasShowOnceDialog2 = false
	self.canShowDialog1 = false
	self.canShowDialog2 = false
	self.canShowDialog3 = false
	self.canShowDialog45 = false
	self.canShowDialog67 = false
	self.dialog1 = {
		{
			cd = 0,
			dialog = 100028714
		},
		{
			cd = 10,
			dialog = 100028713
		}
	}
	self.dialog2 = {
		{
			cd = 0,
			dialog = 100028719
		},
		{
			cd = 10,
			dialog = 100028718
		},
		{
			cd = 10,
			dialog = 100028717
		},
		{
			cd = 10,
			dialog = 100028716
		},
		{
			cd = 8,
			dialog = {
				100028726,
				100028725,
				100028724
			}
		}
	}
	self.dialog3 = {
		{
			cd = 10,
			dialog = 100028720
		}
	}
	self.dialog4 = {
		{
			cd = 10,
			dialog = 100032628
		},
		{
			cd = 10,
			dialog = 100032629
		},
		{
			cd = 10,
			dialog = 100032630
		}
	}
	self.dialog5 = {
		{
			cd = 10,
			dialog = 100032631
		},
		{
			cd = 10,
			dialog = 100032632
		},
		{
			cd = 10,
			dialog = 100032633
		}
	}
	self.dialog6 = {
		{
			cd = 10,
			dialog = 100032634
		},
		{
			cd = 10,
			dialog = 100032635
		},
		{
			cd = 10,
			dialog = 100032636
		}
	}
	self.dialog7 = {
		{
			cd = 10,
			dialog = 100032638
		},
		{
			cd = 10,
			dialog = 100032639
		},
		{
			cd = 10,
			dialog = 100032640
		}
	}
	self.freeDialog = {
		[0] = 100041031,
		100041032,
		nil,
		100041030
	}
	self.enterRotateFreeDialog = 100041033
end

function M:ShowFreeDialog(index, cb)
	if not self.hasGoToEnd and not gDialogManager:IsDialogRunning() then
		local param = gDialogManager:CreateDialogParam()
		param.speakGo = self.headGo.gameObject

		if index == 2 then
			gDialogManager:ShowGeneralDialog(self.freeDialog[1], gDialogSource.InteractGame, nil, param, cb)
		else
			gDialogManager:ShowGeneralDialog(self.freeDialog[index], gDialogSource.InteractGame, nil, param, cb)
		end
	end
end

function M:ShowEnterRotateFreeDialog(cb)
	if not self.hasGoToEnd and not gDialogManager:IsDialogRunning() then
		local param = gDialogManager:CreateDialogParam()
		param.speakGo = self.headGo.gameObject

		gDialogManager:ShowGeneralDialog(self.enterRotateFreeDialog, gDialogSource.InteractGame, nil, param, nil)
	end
end

function M:SetCanShowDialog3(enable)
	self.canShowDialog3 = enable
end

function M:ShowDialog1(idx)
	if self.canShowDialog1 and not self.hasGoToEnd and not gDialogManager:IsDialogRunning() then
		local param = gDialogManager:CreateDialogParam()
		param.speakGo = self.headGo.gameObject

		if idx ~= 1 then
			gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog1[idx].dialog, gDialogSource.InteractGame, nil, param)

			gPinHaoBanManager.timer1 = gPinHaoBanManager.dialog1[idx].cd
		else
			gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog1[idx].dialog, gDialogSource.InteractGame, nil, param)

			self.hasShowOnceDialog1 = true
		end
	end
end

function M:ShowDialog2(idx)
	if gPinHaoBanManager.canShowDialog2 and not self.hasGoToEnd and not gDialogManager:IsDialogRunning() then
		if idx ~= 5 then
			local param = gDialogManager:CreateDialogParam()
			param.speakGo = self.headGo.gameObject

			gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog2[idx].dialog, gDialogSource.InteractGame, nil, param)

			gPinHaoBanManager.timer2 = gPinHaoBanManager.dialog2[idx].cd
		else
			local randomIdx = math.random(1, #gPinHaoBanManager.dialog2[5].dialog)

			gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog2[5].dialog[randomIdx], gDialogSource.InteractGame)

			gPinHaoBanManager.timer2 = gPinHaoBanManager.dialog2[5].cd
		end
	end
end

function M:ShowDialog3()
	if gPinHaoBanManager.canShowDialog3 and not self.hasGoToEnd and not gDialogManager:IsDialogRunning() then
		local param = gDialogManager:CreateDialogParam()
		param.speakGo = self.headGo.gameObject

		gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog3[1].dialog, gDialogSource.InteractGame, nil, param)

		gPinHaoBanManager.timer3 = gPinHaoBanManager.dialog3[1].cd
	end
end

function M:ShowDialog45(isCorrect)
	if gPinHaoBanManager.canShowDialog45 and not self.hasGoToEnd and not gDialogManager:IsDialogRunning() then
		local param = gDialogManager:CreateDialogParam()
		param.speakGo = self.headGo.gameObject

		if isCorrect then
			local randomIdx = math.random(1, #gPinHaoBanManager.dialog4)

			gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog4[randomIdx].dialog, gDialogSource.InteractGame, nil, param)

			gPinHaoBanManager.timer45 = gPinHaoBanManager.dialog4[randomIdx].cd
		else
			local randomIdx = math.random(1, #gPinHaoBanManager.dialog5)

			gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog5[randomIdx].dialog, gDialogSource.InteractGame, nil, param)

			gPinHaoBanManager.timer45 = gPinHaoBanManager.dialog5[randomIdx].cd
		end
	end
end

function M:ShowDialog67(isCorrect)
	if not self.hasGoToEnd and not not gDialogManager:IsDialogRunning() then
		local param = gDialogManager:CreateDialogParam()
		param.speakGo = self.headGo.gameObject

		if isCorrect then
			local randomIdx = math.random(1, #gPinHaoBanManager.dialog6)

			gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog6[randomIdx].dialog, gDialogSource.InteractGame, nil, param)
		else
			local randomIdx = math.random(1, #gPinHaoBanManager.dialog7)

			gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog7[randomIdx].dialog, gDialogSource.InteractGame, nil, param)
		end
	end
end

function M:GetInitPosRot(index)
	if index == 0 then
		return self.headInitPos, self.initLocalHeadRot
	elseif index == 1 then
		return self.handInitPos, self.initLocalHandRot
	elseif index == 2 then
		return self.armInitPos, self.initLocalArmRot
	elseif index == 3 then
		return self.toiletInitPos, self.initLocalToiletRot
	end

	return nil, nil
end

function M:InitSlots(isFirstTime, sceneNodeGo)
	if isFirstTime then
		self.headInitPos = sceneNodeGo.transform:Find("headInitPos").transform.position
		local headGo = sceneNodeGo.transform:Find("head")

		headGo.transform:SetPosition(self.headInitPos.x, self.headInitPos.y, self.headInitPos.z)

		self.initLocalHeadRot = headGo.transform.rotation.eulerAngles
		self.headGo = headGo
	else
		self.headGo.transform:SetParent(self.sceneNodeGo.transform)

		self.headGo.gameObject:GetComponent(typeof(PinHaoBanDefine)).installedSlotIndex = -1
		self.headGo.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true
	end

	if self.headGo and not isFirstTime then
		self.itemsContainer[self.itemIndexMap.headGo] = self.headGo.gameObject

		self.headGo.transform:SetPosition(self.headInitPos.x, self.headInitPos.y, self.headInitPos.z)

		self.headGo.transform.rotation = Quaternion.Euler(self.initLocalHeadRot.x, self.initLocalHeadRot.y, self.initLocalHeadRot.z)
	end

	if isFirstTime then
		self.handInitPos = sceneNodeGo.transform:Find("handInitPos").transform.position
		local handGo = sceneNodeGo.transform:Find("hand")

		handGo.transform:SetPosition(self.handInitPos.x, self.handInitPos.y, self.handInitPos.z)

		self.initLocalHandRot = handGo.transform.rotation.eulerAngles
		self.handGo = handGo
	else
		self.handGo.transform:SetParent(self.sceneNodeGo.transform)

		self.handGo.gameObject:GetComponent(typeof(PinHaoBanDefine)).installedSlotIndex = -1
		self.handGo.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true
	end

	if self.handGo and not isFirstTime then
		self.itemsContainer[self.itemIndexMap.handGo] = self.handGo

		self.handGo.transform:SetPosition(self.handInitPos.x, self.handInitPos.y, self.handInitPos.z)

		self.handGo.transform.rotation = Quaternion.Euler(self.initLocalHandRot.x, self.initLocalHandRot.y, self.initLocalHandRot.z)
	end

	if isFirstTime then
		self.armInitPos = sceneNodeGo.transform:Find("armInitPos").transform.position
		local armGo = sceneNodeGo.transform:Find("arm")

		armGo.transform:SetPosition(self.armInitPos.x, self.armInitPos.y, self.armInitPos.z)

		self.initLocalArmRot = armGo.transform.rotation.eulerAngles
		self.armGo = armGo
	else
		self.armGo.transform:SetParent(self.sceneNodeGo.transform)

		self.armGo.gameObject:GetComponent(typeof(PinHaoBanDefine)).installedSlotIndex = -1
		self.armGo.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true
	end

	if self.armGo and not isFirstTime then
		self.itemsContainer[self.itemIndexMap.armGo] = self.armGo

		self.armGo.transform:SetPosition(self.armInitPos.x, self.armInitPos.y, self.armInitPos.z)

		self.armGo.transform.rotation = Quaternion.Euler(self.initLocalArmRot.x, self.initLocalArmRot.y, self.initLocalArmRot.z)
	end

	if isFirstTime then
		if sceneNodeGo.transform:Find("toiletInitPos") then
			self.toiletInitPos = sceneNodeGo.transform:Find("toiletInitPos").transform.position
			local toiletGo = sceneNodeGo.transform:Find("toilet")

			toiletGo.transform:SetPosition(self.toiletInitPos.x, self.toiletInitPos.y, self.toiletInitPos.z)

			self.initLocalToiletRot = toiletGo.transform.rotation.eulerAngles
			self.toiletGo = toiletGo
		end
	elseif self.toiletGo then
		self.toiletGo.transform:SetParent(self.sceneNodeGo.transform)

		self.toiletGo.gameObject:GetComponent(typeof(PinHaoBanDefine)).installedSlotIndex = -1
		self.toiletGo.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = false
	end

	if self.toiletGo and not isFirstTime then
		self.itemsContainer[self.itemIndexMap.toiletGo] = self.toiletGo

		self.toiletGo.transform:SetPosition(self.toiletInitPos.x, self.toiletInitPos.y, self.toiletInitPos.z)

		self.toiletGo.transform.rotation = Quaternion.Euler(self.initLocalToiletRot.x, self.initLocalToiletRot.y, self.initLocalToiletRot.z)
	end

	self.slotComp = gTimelineManager:GetTimeline("TL_TAF_010_Q010_S04").gameObject:GetComponent(typeof(PinHaoBanSlot))

	if self.slotComp then
		self.headSlot = self.slotComp.headSlot.gameObject:GetComponent(typeof(PHBSlot))
		self.handSlot = self.slotComp.handSlot.gameObject:GetComponent(typeof(PHBSlot))
		self.shoulderSlot = self.slotComp.shoulderSlot.gameObject:GetComponent(typeof(PHBSlot))
		self.slotContainer[self.slotIndexMap.handSlot] = -1
		self.slotContainer[self.slotIndexMap.headSlot] = -1
		self.slotContainer[self.slotIndexMap.shoulderSlot] = -1
		self.successLimit = {}
		self.itemsRotateLimits = {}
		self.installedRotation = {}
		self.slotOriginalRotation = {}
		self.PHBSlots = self.slotComp.gameObject:GetComponentsInChildren(typeof(PHBSlot)):ToTable()

		for i, v in pairs(self.PHBSlots) do
			self.successLimit[v.slotIndex] = v.m_successLimit
			self.itemsRotateLimits[v.slotIndex] = v.m_ItemsRotateLimits:ToTable()
			self.installedRotation[v.slotIndex] = v.m_ItemSlots:ToTable()
			self.slotOriginalRotation[v.slotIndex] = v.gameObject.transform.localRotation
		end
	end
end

function M:GetUINextClip()
	if self.hasGoToEnd then
		return ""
	end

	return "Loop"
end

function M:GetInstalledRot(slotIndex, itemIndex)
	return self.installedRotation[slotIndex][itemIndex].rotation
end

function M:OnInitPinhaobanData(eventId, data)
	local sceneNodePath = "Res/MiniGame/Prefab/Pinhaoban/PinhaobanSceneNode.prefab"
	self.sceneNodeOp = gResourceManager:LoadAssetWithCallBack(sceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		self.sceneNodeGo = UnityEngine.GameObject.Instantiate(loadOp.asset)
		self.sceneNodeGo.gameObject.name = "PinHaoBanSceneNode"

		self:InitSlots(true, self.sceneNodeGo)
	end)
end

function M:OnUIChange(eventId, data)
	if gPanelManager:IsPanelShowing(gPanelId.PINHAOBAN_SELECT_PANEL) then
		return
	end

	gPanelManager:CheckShow(gPanelId.PINHAOBAN_SELECT_PANEL)
end

function M:ClearData(eventId, data)
	self:ClearLogicData()
	gResourceManager:UnloadAssetLoadOp(self.sceneNodeOp)

	if self.sceneNodeGo and not gCS.LuaUtils.IsNull(self.sceneNodeGo) then
		GameObject.Destroy(self.sceneNodeGo)
	end

	if self.headGo and not gCS.LuaUtils.IsNull(self.headGo) then
		GameObject.Destroy(self.headGo.gameObject)
	end

	if self.armGo and not gCS.LuaUtils.IsNull(self.armGo) then
		GameObject.Destroy(self.armGo.gameObject)
	end

	if self.handGo and not gCS.LuaUtils.IsNull(self.handGo) then
		GameObject.Destroy(self.handGo.gameObject)
	end

	if self.toiletGo and not gCS.LuaUtils.IsNull(self.toiletGo) then
		GameObject.Destroy(self.toiletGo.gameObject)
	end
end

function M:ClearLogicData()
	self.slotCount = 0
	self.itemsContainer = {}
	self.slotContainer = {}
end

function M:GetItemGoIndex(transform)
	local type, index = nil
	local item = transform.gameObject:GetComponentInParent(typeof(PinHaoBanDefine))

	if item then
		index = item.index
	end

	return item, index
end

function M:ShowOrHideItems(active)
	self.headGo.gameObject:SetActive(active)
	self.armGo.gameObject:SetActive(active)
	self.handGo.gameObject:SetActive(active)

	if self.toiletGo then
		self.toiletGo.gameObject:SetActive(active)
	end
end

function M:GetItemByIndex(index)
	if index == self.itemIndexMap.headGo then
		return self.headGo.gameObject
	end

	if index == self.itemIndexMap.armGo then
		return self.armGo.gameObject
	end

	if index == self.itemIndexMap.toiletGo then
		return self.toiletGo.gameObject
	end

	return self.handGo.gameObject
end

function M:GetSlotByIndex(index)
	if index == self.slotIndexMap.headSlot then
		return self.headSlot
	end

	if index == self.slotIndexMap.shoulderSlot then
		return self.shoulderSlot
	end

	return self.handSlot
end

gPinHaoBanManager = gPinHaoBanManager or C_PinHaoBanManager.new()
