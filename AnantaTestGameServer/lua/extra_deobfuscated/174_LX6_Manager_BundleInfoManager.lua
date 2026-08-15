local M = {
	infos = {}
}

function M:Add(itemMsg)
	self.infos[tostring(itemMsg.Id)] = itemMsg
end

function M:Get(id)
	return self.infos[tostring(id)]
end

function M:Remove(id)
	self.infos[tostring(id)] = nil
end

function M:GetItemInfoByTemplateId(id, templateId)
	local info = self:Get(id)

	if not info then
		return nil
	end

	local items = info.Items

	for i, item in ipairs(items) do
		if item.TemplateId == templateId then
			return item
		end
	end

	return nil
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.infos = {}
	end
end

gBundleInfoManager = M
