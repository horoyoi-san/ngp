local ImageAvatar = LTConfig.ImageAvatarConfig
local WrapMode = UnityEngine.WrapMode
local Animation = UnityEngine.Animation
local LayerConstants = LX6.Constants.LayerConstants
local MeshRenderer = UnityEngine.MeshRenderer
local SkinnedMeshRenderer = UnityEngine.SkinnedMeshRenderer
local UnitModelManager = LX6.Units.UnitModelManager
local SguiImageConfig = LTConfig.SguiImageConfig
local StoreBindMethod = {
	BindBoolToActive = function (self, widget, active)
		if active then
			widget:SetActive(true)
		else
			widget:SetActive(false)
		end
	end,
	BindBoolToInActive = function (self, widget, active)
		if active then
			widget:SetActive(false)
		else
			widget:SetActive(true)
		end
	end,
	BindIconIdToImage = function (self, uimage, iconId)
		local cfg = SguiImageConfig.GetConfig(iconId)

		if cfg then
			uimage.url = cfg.ImgPath
		else
			uimage.url = nil
		end
	end,
	BindPzHeadInfoToImage = function (self, uimage, pzHeadInfo)
		if pzHeadInfo.SystemHeadId then
			local cfg = ImageAvatar.GetConfig(pzHeadInfo.SystemHeadId)

			self:BindIconIdToImage(uimage, cfg.SguiImageId)
		else
			uimage.url = nil
		end
	end,
	BindLocalRotationZ = function (self, widget, rotateZ)
		widget.transform:SetLocalEulerAnglesZ(rotateZ)
	end,
	BindModel = function (self, widget, value)
		local cell = {
			value = value,
			gameObject = widget.gameObject,
			transform = widget.transform
		}

		if not cell.value then
			return
		end

		local modelId = cell.value.modelId
		local callback = cell.value.callback
		local beforeLoadCallback = cell.value.beforeLoadCallback
		local renderQueue = cell.value.renderQueue
		local isSetTrueRenderQueue = cell.value.isSetTrueRenderQueue
		local unitAction = cell.value.unitAction
		local unitActionTable = cell.value.unitActionTable
		local emoAction = cell.value.emoAction
		local loadCompletePlayEffectId = cell.value.loadCompletePlayEffectId
		local loadCompleteSwitchRenderQueue = cell.value.loadCompleteSwitchRenderQueue
		local simpleInfo = cell.value.simpleInfo
		local isSetFacing = cell.value.isSetFacing
		local customFacing = cell.value.customFacing
		local gammaCorrection = cell.value.gammaCorrection

		if isSetFacing == nil then
			isSetFacing = true
		end

		local layer = cell.value.layer
		local ignoreLayer = cell.value.ignoreLayer

		if layer == nil and not ignoreLayer then
			layer = LayerConstants.Ui
		end

		if (not modelId or modelId == 0) and cell.unit ~= nil then
			cell.unit:DestroyUnit(false)

			cell.unit = nil
			cell.value.unit = nil
		elseif modelId and modelId > 0 then
			local cb = nil

			function cb(unit, noLoad)
				if noLoad ~= true then
					unit.OnLoadCompleteHandler = unit.OnLoadCompleteHandler - cb
				end

				if cell.gameObject == nil or cell.gameObject:IsDestroyed() then
					return
				end

				unit.PlayerObj.parent = cell.transform
				unit.PlayerObj.localPosition = Vector3.zero

				if customFacing then
					unit:SetFacing(customFacing)
				elseif isSetFacing then
					unit:SetFacing(-180)
				end

				if not ignoreLayer then
					UnitModelManager.SetRenderLayer(unit, layer)
				end

				if renderQueue then
					if isSetTrueRenderQueue then
						local renderers = unit.PlayerObj.transform:GetComponentsInChildren(typeof(MeshRenderer))
						local skinMeshRenderers = unit.PlayerObj.transform:GetComponentsInChildren(typeof(SkinnedMeshRenderer))

						for i = 0, renderers.Length - 1 do
							if isSetTrueRenderQueue then
								renderers[i].material.renderQueue = renderQueue
							end
						end

						for i = 0, skinMeshRenderers.Length - 1 do
							if isSetTrueRenderQueue then
								skinMeshRenderers[i].material.renderQueue = renderQueue
							end
						end
					else
						local i = MeshRenderer
						local renderers = unit.PlayerObj.transform:GetComponentsInChildren(typeof(i))
						local skinMeshRenderers = unit.PlayerObj.transform:GetComponentsInChildren(typeof(SkinnedMeshRenderer))

						for i = 0, renderers.Length - 1 do
						end

						for i = 0, skinMeshRenderers.Length - 1 do
						end
					end
				end

				if unitActionTable and unit.ModelSlot.action then
					local state = unit.ModelSlot.action:get_Item(unitActionTable[1])
					state.wrapMode = unitActionTable[2] and WrapMode.Loop or WrapMode.Default

					unit.ModelSlot.action:Play(unitActionTable[1])
				end

				if emoAction and emoAction ~= "" and unit.ModelSlot.action then
					local emoNode = unit.ModelSlot.action.transform:Find("biaoqing")

					if emoNode then
						local ani = emoNode:GetComponent(typeof(Animation))

						if ani then
							ani:Play(emoAction)
						end
					end
				end

				if layer == LayerConstants.Ui then
					UnitModelManager.CloseModelSlotCollider(unit)
				end

				if gammaCorrection then
					unit.PlayerObj.gameObject:SetGammaCorrection(true)
				end

				if callback then
					callback(unit)
				end
			end

			if cell.unit == nil then
				cell.unit = gUIUtils:LoadModel("", modelId, unitAction, loadCompletePlayEffectId, loadCompleteSwitchRenderQueue, simpleInfo, cb, beforeLoadCallback, cell.value.otherData)
			else
				local needChangeModel = false

				if cell.lastOtherData == nil and cell.value.otherData ~= nil and cell.value.otherData.horseTextureId ~= nil then
					needChangeModel = true
				end

				if cell.lastOtherData ~= nil and cell.lastOtherData.horseTextureId ~= nil and cell.value.otherData == nil then
					needChangeModel = true
				end

				if cell.value.otherData ~= nil and cell.value.otherData.horseTextureId ~= nil and cell.lastOtherData ~= nil and cell.lastOtherData.horseTextureId ~= nil and cell.value.otherData.horseTextureId ~= cell.lastOtherData.horseTextureId then
					needChangeModel = true
				end

				if cell.lastOtherData and cell.value.otherData and cell.value.otherData.fashionAppearanceInfo then
					needChangeModel = true
				end

				if cell.value.otherData ~= nil and cell.value.otherData.needChangeModel then
					needChangeModel = true
				end

				if cell.unit.CanUseRes and cell.lastModelID == modelId and not needChangeModel then
					cb(cell.unit, true)
				else
					cell.unit:DestroyUnit(false)

					cell.unit = gUIUtils:LoadModel("", modelId, unitAction, loadCompletePlayEffectId, loadCompleteSwitchRenderQueue, simpleInfo, cb, beforeLoadCallback, cell.value.otherData)
				end
			end

			if cell.root then
				cell.unit.uiSourcePanelId = cell.root.panelID
			end

			cell.lastOtherData = cell.value.otherData
			cell.lastModelID = modelId
			cell.value.unit = cell.unit
		end
	end,
	BindScale = function (self, widget, value)
		widget.transform.localScale = value
	end,
	BindTexture = function (self, rawImage, value)
		if not value or type(value) == "string" then
			return
		end

		rawImage.texture = value
	end
}
gStoreBindMethod = StoreBindMethod
