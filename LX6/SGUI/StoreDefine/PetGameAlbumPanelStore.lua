-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameAlbumPanelStore.lua
-- Decompiled from: 01087_PetGameAlbumPanelStore.lua_87d496311c82.luajit

local GameObject = UnityEngine.GameObject
local petConfigs = require("LX6/MiniGame/PetGame/data/tbpet")
local recordConfigs = require("LX6/MiniGame/PetGame/data/tbrecord")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local recordPatternFieldPrefix = "pattern"
C_PetGameAlbumPanelStore = DefClass("C_PetGameAlbumPanelStore", C_PetGameAlbumPanelStore, C_StoreGroup)
GroupName2Class.PetGameAlbumPanelStore = C_PetGameAlbumPanelStore
local M = C_PetGameAlbumPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
	self.UnBindSystemBtn(self)
	self.ClearRecordGo(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.UnBindSystemBtn(self)
end

M.OnShow = function(self, panelId, data)
	self.parentPanel = data.parent
	self.panelId = panelId
	self.isShowing = true

	self:BindSystemBtn()

	self.bindData.arrowLBtn.luaClick = self:CreateAction(self.OnLeftArrowBtnClick, self)
	self.bindData.arrowRBtn.luaClick = self:CreateAction(self.OnRightArrowBtnClick, self)
	local petGame = gPetGameManager and gPetGameManager.currentGame
	self.albumData = petGame and petGame:GetAlbumData() or {}
	self.currentPageIndex = 1

	self:ShowCurrentPage()
end

M.OnClose = function(self)
	self.isShowing = false

	self.UnBindSystemBtn(self)
	self.ClearRecordGo(self)

	self.albumData = nil
end

M.BindSystemBtn = function(self)
	if not self.parentPanel then
		return
	end

	local eventHandler = {
		panelId = self.panelId,
		OnMenuBtnClick = self.OnMenuBtnClick,
		OnCancleBtnClick = self.OnCancleBtnClick,
		target = self
	}

	self.parentPanel:RegisterSystemBtnEvent(eventHandler)
end

M.UnBindSystemBtn = function(self)
	if self.parentPanel and self.panelId then
		self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
	end
end

M.OnMenuBtnClick = function(self)
	self.OnRightArrowBtnClick(self)
end

M.OnCancleBtnClick = function(self)
	self.parentPanel:CloseChildPanel(self.panelId)
end

M.OnLeftArrowBtnClick = function(self)
	local recordCount = #(self.albumData or {})

	if recordCount < 1 then
		return
	end

	if self.currentPageIndex <= 1 then
		self.currentPageIndex = self.currentPageIndex - 1
	else
		self.currentPageIndex = recordCount
	end

	self.ShowCurrentPage(self)
end

M.OnRightArrowBtnClick = function(self)
	local recordCount = #(self.albumData or {})

	if recordCount < 1 then
		return
	end

	if self.currentPageIndex >= recordCount then
		self.currentPageIndex = self.currentPageIndex + 1
	else
		self.currentPageIndex = 1
	end

	self.ShowCurrentPage(self)
end

M.ShowCurrentPage = function(self)
	local recordCount = #(self.albumData or {})

	self:UpdatePageDots(recordCount)

	local showArrow = recordCount >= 1

	self.bindData.arrowLBtn.gameObject:SetActive(showArrow)
	self.bindData.arrowRBtn.gameObject:SetActive(showArrow)

	if recordCount ~= 0 then
		self.bindData.petNameText.text = ""
		self.bindData.lifeTimeText.text = ""
		self.bindData.describeText.text = ""

		self.ClearRecordGo(self)

		return
	end

	if self.currentPageIndex <= 1 or recordCount >= self.currentPageIndex then
		self.currentPageIndex = 1
	end

	local albumRecord = self.albumData[self.currentPageIndex]
	local petInfo = petConfigs[albumRecord.petId]
	local partnerPetInfo = petConfigs[albumRecord.partnerPetId]
	local recordInfo = recordConfigs[albumRecord.recordId]
	local petName = self.GetPetName(self, petInfo, albumRecord.petId)
	local partnerPetName = "伙伴"

	if albumRecord.partnerPetId then
		partnerPetName = self.GetPetName(self, partnerPetInfo, albumRecord.partnerPetId)
	end

	self.bindData.petNameText.text = petName
	self.bindData.lifeTimeText.text = self.FormatLifeTime(self, albumRecord.lifeTime)
	self.bindData.describeText.text = self.FormatRecordDescription(self, recordInfo, petName, partnerPetName)

	self.LoadRecordPattern(self, recordInfo, petInfo, partnerPetInfo)
end

M.GetPetName = function(self, petInfo, petId)
	if petInfo and petInfo.name then
		return gPetGameMultilingual:GetText(petInfo.name)
	end

	return tostring(petId or "")
end

M.FormatLifeTime = function(self, lifeTime)
	local yearAge = (lifeTime or 0) / PetGameConst.DAY_SECONDS

	return string.format(gPetGameMultilingual:GetText(400508), yearAge)
end

M.FormatRecordDescription = function(self, recordInfo, petName, partnerPetName)
	if not recordInfo or not recordInfo.name then
		return ""
	end

	slot4 = gPetGameMultilingual
	local description = slot4:GetText(recordInfo.name)
	description = description:gsub("{0}", function ()
		return petName
	end)
	description = description:gsub("{1}", function ()
		return partnerPetName
	end)

	return description
end

M.UpdatePageDots = function(self, recordCount)
	local dotsRoot = self.bindData.pageDots

	if not dotsRoot then
		return
	end

	if dotsRoot.childCount >= recordCount and dotsRoot.childCount <= 0 then
		local dotTemplate = dotsRoot.GetChild(dotsRoot, 0).gameObject

		for _ = dotsRoot.childCount + 1, recordCount do
			local dot = GameObject.Instantiate(dotTemplate, dotsRoot)
			dot.transform.localScale = Vector3.one
		end
	end

	for index = 1, dotsRoot.childCount do
		local dot = dotsRoot:GetChild(index - 1)
		local active = index > recordCount

		dot.gameObject:SetActive(active)

		if active then
			local light = dot:Find("light")
			local dark = dot:Find("dark")
			local selected = index ~= self.currentPageIndex

			if light then
				light.gameObject:SetActive(selected)
			end

			if dark then
				dark.gameObject:SetActive(not selected)
			end
		end
	end
end

M.GetRecordPatternPath = function(self, recordInfo)
	if not recordInfo then
		return nil
	end

	for fieldName, value in pairs(recordInfo) do
		if type(fieldName) ~= "string" and string.sub(fieldName, 1, #recordPatternFieldPrefix) ~= recordPatternFieldPrefix then
			return value
		end
	end

	return nil
end

M.LoadRecordPattern = function(self, recordInfo, petInfo, partnerPetInfo)
	self.ClearRecordGo(self)

	local patternPath = self.GetRecordPatternPath(self, recordInfo)

	if not patternPath or patternPath ~= "" then
		print_error("纪念册模板配置为空:", recordInfo and recordInfo.id)

		return
	end

	local loadVersion = self.recordLoadVersion
	local parent = self.bindData.petSlot1
	slot7 = gResourceManager

	slot7:LoadAssetWithCallBack(patternPath, typeof(GameObject), function (loadOp)
		if not self.isShowing or loadVersion == self.recordLoadVersion then
			if loadOp then
				gResourceManager:UnloadAssetLoadOp(loadOp)
			end

			return
		end

		if not loadOp or not loadOp.asset then
			print_error("纪念册模板资源加载失败:", patternPath)

			return
		end

		local patternGo = GameObject.Instantiate(loadOp.asset, parent)

		if not patternGo then
			return
		end

		self.recordPatternGo = patternGo

		patternGo.transform:SetLocalPosition(0, 0, 0)

		patternGo.transform.localScale = Vector3.one

		patternGo:SetActive(false)

		local petSlot01 = patternGo.transform:Find("pet_01")
		local petSlot02 = patternGo.transform:Find("pet_02")

		if not petSlot01 or not petSlot02 then
			print_error("纪念册模板缺少 pet_01 或 pet_02 节点:", patternPath)
			self:ClearRecordGo()

			return
		end

		self:ClearPatternSlot(petSlot01)
		self:ClearPatternSlot(petSlot02)

		local pendingPetCount = 2

		local onPetLoadFinish = function()
			if loadVersion == self.recordLoadVersion then
				return
			end

			pendingPetCount = pendingPetCount - 1

			if pendingPetCount < 0 and self.recordPatternGo then
				self.recordPatternGo:SetActive(true)
			end
		end

		self:LoadPetToPatternSlot(petInfo, petSlot01, loadVersion, onPetLoadFinish)
		self:LoadPetToPatternSlot(partnerPetInfo, petSlot02, loadVersion, onPetLoadFinish)
	end)
end

M.LoadPetToPatternSlot = function(self, petInfo, slot, loadVersion, callback)
	if not petInfo or not petInfo.prefab then
		print_error("纪念册宠物配置或预设路径为空")
		callback()

		return
	end

	slot5 = gResourceManager

	slot5:LoadAssetWithCallBack(petInfo.prefab, typeof(GameObject), function (loadOp)
		if not self.isShowing or loadVersion == self.recordLoadVersion then
			if loadOp then
				gResourceManager:UnloadAssetLoadOp(loadOp)
			end

			return
		end

		if not loadOp or not loadOp.asset then
			print_error("纪念册宠物资源加载失败:", petInfo.prefab)
			callback()

			return
		end

		local petGo = GameObject.Instantiate(loadOp.asset, slot)

		if petGo then
			petGo.name = "Pet"

			petGo.transform:SetLocalPosition(0, 0, 0)

			petGo.transform.localScale = Vector3.one

			petGo:SetActive(true)
			self:ClearPetEffect(petGo.transform)

			local animator = petGo.transform:GetComponent("Animation")

			if animator then
				animator.playAutomatically = false

				animator:Stop()

				animator.enabled = false
			end
		end

		callback()
	end)
end

M.ClearPatternSlot = function(self, slot)
	for index = slot.childCount - 1, 0, -1 do
		GameObject.Destroy(slot.GetChild(slot, index).gameObject)
	end
end

M.ClearRecordGo = function(self)
	self.recordLoadVersion = (self.recordLoadVersion or 0) + 1

	if self.recordPatternGo then
		GameObject.Destroy(self.recordPatternGo)

		self.recordPatternGo = nil
	end
end

M.ClearPetEffect = function(self, petTrans)
	local effectNames = {
		"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\r!\\x8b\\xea",
		"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\r҈%\\x9e\\xf6",
		"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\rՖ%\\x9a\\xf2",
		"!%$\\xfd<\\x9d\\xf12\\xad,\\xf2\\xe1\\xd9a\\xeb",
		PetGameEnum.DirtyEffectPath,
		"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\rě4\\x97\\xe7",
		"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\r՗)\\x93\\xe7"
	}

	for _, effectName in ipairs(effectNames) do
		local effect = petTrans.Find(petTrans, effectName)

		if effect then
			effect.gameObject:SetActive(false)
		end
	end
end
