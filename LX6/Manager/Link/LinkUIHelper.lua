-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkUIHelper.lua
-- Decompiled from: 00701_LinkUIHelper.lua_123f783372ae.luajit

local RobAssessmentsConfig = LTConfig.LinkRobAssessmentsConfig
gLinkUIHelper = gLinkUIHelper or {}
local M = gLinkUIHelper

M.OnRenderAssessmentDescListTooltip = function(self, btn, tooltip, index, assessmentIds)
	local store = gStoreManager:GetStoreGroup(tooltip.Store):GetStoreByWidget(tooltip)

	if not store then
		return
	end

	local list = store.list

	list.luaSimpleRenderItem = function(itemBtn, itemIndex)
		local assessmentId = assessmentIds[itemIndex + 1]

		if not assessmentId then
			return
		end

		self:RenderAssessmentById(itemBtn, assessmentId)
	end

	list:SetSimpleList(#assessmentIds)
end

M.RenderAssessmentById = function(self, itemBtn, assessmentId)
	local cfg = RobAssessmentsConfig.GetConfig(assessmentId)

	if not cfg then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(itemBtn.Store):GetStoreByWidget(itemBtn)

	if not itemStore then
		return
	end

	itemStore.name = cfg.AssessmentName
	itemStore.icon = cfg.SGUIImageID
	itemStore.desc = cfg.AssessmentDescription
end

M.OnRenderAssessmentDescTooltip = function(self, btn, tooltip, index, assessmentId)
	local cfg = RobAssessmentsConfig.GetConfig(assessmentId)

	if not cfg then
		return
	end

	local store = gStoreManager:GetStoreGroup(tooltip.Store):GetStoreByWidget(tooltip)

	if not store then
		return
	end

	store.name = cfg.AssessmentName
	store.icon = cfg.SGUIImageID
	store.desc = cfg.AssessmentDescription
end

M.MakePrepareRoomTransformInfo = function(self, data)
	for _, transformInfo in pairs(data) do
		if transformInfo.Camera and transformInfo.Camera.Main then
			if transformInfo.Player then
				self:ConvertTransformInfo(transformInfo.Camera.Main)

				slot7 = pairs
				slot9 = transformInfo.Camera.GroupFocus or {}

				for _, groupFocusInfo in slot7(slot9) do
					self:ConvertTransformInfo(groupFocusInfo)
				end

				slot7 = pairs
				slot9 = transformInfo.Player or {}

				for _, playerInfo in slot7(slot9) do
					self:ConvertTransformInfo(playerInfo)
				end

				if transformInfo.Vehicle then
					self:ConvertTransformInfo(transformInfo.Vehicle)
				end
			end
		end
	end

	return data
end

M.ConvertTransformInfo = function(self, transformInfo)
	local posArr = transformInfo.Position or {}
	local rotArr = transformInfo.Rotation or {}
	transformInfo.Position = Vector3.New(posArr[1] or 0, posArr[2] or 0, posArr[3] or 0)
	transformInfo.Rotation = Vector3.New(rotArr[1] or 0, rotArr[2] or 0, rotArr[3] or 0)
end
