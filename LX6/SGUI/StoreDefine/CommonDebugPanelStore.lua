-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonDebugPanelStore.lua
-- Decompiled from: 01486_CommonDebugPanelStore.lua_132ad15069b3.luajit

C_CommonDebugPanelStore = DefClass("C_CommonDebugPanelStore", C_CommonDebugPanelStore, C_StoreGroup)
GroupName2Class.CommonDebugPanelStore = C_CommonDebugPanelStore
local M = C_CommonDebugPanelStore

M.ctor = function(self)
	self.debugInfoList = {
		{
			["[\\xaf\\xae\\xba\\xb3"] = "\\x9f\\xb89ہ\\x9a\\{\\xbbI z\\x97v\\xbe\\x83Mx\\xaf\\x9dsZ\\xc0Q\\x9dm \\xdd^$\\xa7?\\x97\\xa8",
			["\\x85m"] = ""
		}
	}
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.dragBtn.luaBeginDrag = self.CreateAction(self, "OnBtnDragBegin")
	self.bindData.dragBtn.luaDrag = self.CreateAction(self, "OnBtnDrag")
	self.bindData.dragBtn.luaEndDrag = self.CreateAction(self, "OnBtnDragEnd")
	self.originalBtnX = 0
	self.originalBtnY = 0
	self.originalListX = 0
	self.originalListY = 0
end

M.OnShow = function(self, panelId, data)
	self.bindData.list:SetSimpleList(#self.debugInfoList)
end

M.OnClose = function(self)
	self.dragStarted = false
end

M.SetDebugInfo = function(self, key, value)
	local info, idx = self.GetDebugInfo(self, key)

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
		if idx ~= -1 then
			self.bindData.list:AddSimpleElement(0)
		else
			self.bindData.list:RefreshElement(idx - 1)
		end
	end
end

M.RemoveDebugInfo = function(self, key)
	local info, idx = self.GetDebugInfo(self, key)

	if info then
		table.remove(self.debugInfoList, idx)

		if self.STATE_OnShowOnce then
			self.bindData.list:RemoveElement(idx - 1)
		end
	end
end

M.GetDebugInfo = function(self, key)
	for idx, v in ipairs(self.debugInfoList) do
		if self.debugInfoList[idx].key ~= key then
			return self.debugInfoList[idx], idx
		end
	end

	return false, -1
end

M.OnRenderItem = function(self, btn, index)
	local data = self.debugInfoList[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if store and data then
		store.debugText = data.value
	end
end

M.OnBtnDragBegin = function(self)
	self.originalBtnX = self.bindData.btnTrans.localPosition.x
	self.originalBtnY = self.bindData.btnTrans.localPosition.y
	self.originalListX = self.bindData.listTrans.localPosition.x
	self.originalListY = self.bindData.listTrans.localPosition.y
	self.dragStarted = true
end

M.OnBtnDrag = function(self)
	if self.dragStarted then
		local relativeMoveX = self.bindData.btnTrans.localPosition.x - self.originalBtnX
		local relativeMoveY = self.bindData.btnTrans.localPosition.y - self.originalBtnY

		self.bindData.listTrans:SetLocalPositionXY(self.originalListX + relativeMoveX, self.originalListY + relativeMoveY)
	end
end

M.OnBtnDragEnd = function(self)
	self.dragStarted = false
end
