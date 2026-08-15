C_CommonDebugPanelStore = DefClass("C_CommonDebugPanelStore", C_CommonDebugPanelStore, C_StoreGroup)
GroupName2Class.CommonDebugPanelStore = C_CommonDebugPanelStore
local M = C_CommonDebugPanelStore

function M:ctor()
	self.debugInfoList = {
		{
			value = "#CFF000B通用调试信息↑↑↑#z",
			key = ""
		}
	}
end

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.dragBtn.luaBeginDrag = self:CreateAction("OnBtnDragBegin")
	self.bindData.dragBtn.luaDrag = self:CreateAction("OnBtnDrag")
	self.bindData.dragBtn.luaEndDrag = self:CreateAction("OnBtnDragEnd")
	self.originalBtnX = 0
	self.originalBtnY = 0
	self.originalListX = 0
	self.originalListY = 0
end

function M:OnShow(panelId, data)
	self.bindData.list:SetSimpleList(#self.debugInfoList)
end

function M:OnClose()
	self.dragStarted = false
end

function M:SetDebugInfo(key, value)
	local info, idx = self:GetDebugInfo(key)

	if info then
		info.value = key .. " : " .. value
	else
		info = {
			key = key,
			value = key .. " : " .. value
		}

		table.insert(self.debugInfoList, info)
	end

	if self.STATE_OnShowOnce then
		if idx == -1 then
			self.bindData.list:AddSimpleElement(0)
		else
			self.bindData.list:RefreshElement(idx - 1)
		end
	end
end

function M:RemoveDebugInfo(key)
	local info, idx = self:GetDebugInfo(key)

	if info then
		table.remove(self.debugInfoList, idx)

		if self.STATE_OnShowOnce then
			self.bindData.list:RemoveElement(idx - 1)
		end
	end
end

function M:GetDebugInfo(key)
	for idx, v in ipairs(self.debugInfoList) do
		if self.debugInfoList[idx].key == key then
			return self.debugInfoList[idx], idx
		end
	end

	return false, -1
end

function M:OnRenderItem(btn, index)
	local data = self.debugInfoList[index + 1]
	local store = self:GetStoreByWidget(btn)

	if store and data then
		store.debugText = data.value
	end
end

function M:OnBtnDragBegin()
	self.originalBtnX = self.bindData.btnTrans.localPosition.x
	self.originalBtnY = self.bindData.btnTrans.localPosition.y
	self.originalListX = self.bindData.listTrans.localPosition.x
	self.originalListY = self.bindData.listTrans.localPosition.y
	self.dragStarted = true
end

function M:OnBtnDrag()
	if self.dragStarted then
		local relativeMoveX = self.bindData.btnTrans.localPosition.x - self.originalBtnX
		local relativeMoveY = self.bindData.btnTrans.localPosition.y - self.originalBtnY

		self.bindData.listTrans:SetLocalPositionXY(self.originalListX + relativeMoveX, self.originalListY + relativeMoveY)
	end
end

function M:OnBtnDragEnd()
	self.dragStarted = false
end
