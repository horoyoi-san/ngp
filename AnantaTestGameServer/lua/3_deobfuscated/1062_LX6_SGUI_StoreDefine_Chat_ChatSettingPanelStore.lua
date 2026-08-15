C_ChatSettingPanelStore = DefClass("C_ChatSettingPanelStore", C_ChatSettingPanelStore, C_AppFragmentStore)
GroupName2Class.ChatSettingPanelStore = C_ChatSettingPanelStore
local M = C_ChatSettingPanelStore

function M:OnAwake()
	self.bindData.list.luaRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.list.luaClick = self:CreateAction(self.OnClickItem)
end

function M:OnShow(_, data)
	self.bindData.list:SetList(self:GetBtnList())
end

function M:GetBtnList()
	local list = {}
	local rejectAllApply = {
		tIndex = 1,
		text = LTConfig.TextScriptTextConfig.GetConfig(89901131).Text,
		onRender = function (btn, store)
			store.toggleBtn.isSelected = gFriendManager:IsRejectAllFriendApply()

			function store.toggleBtn.luaClick()
				local new = not store.toggleBtn.isSelected

				gFriendManager:SetRejectAllFriendApply(new, function (err)
					if err == LTConfig.MessageConfig.Ok then
						store.toggleBtn.isSelected = gFriendManager:IsRejectAllFriendApply()
					end
				end)
			end
		end,
		onClick = function (btn, store)
			store.toggleBtn.luaClick()
		end
	}

	table.insert(list, rejectAllApply)

	local blackList = {
		tIndex = 0,
		onClick = function (btn, store)
			self.activity:ShowFragment(gChatConst.TabShowType.BlackList)
		end
	}

	table.insert(list, blackList)

	return list
end

function M:OnRenderItem(btn, csIndex, data)
	local store = self:GetStoreByWidget(btn)
	store.text = data.text

	if data.onRender then
		data.onRender(btn, store)
	end
end

function M:OnClickItem(btn, data)
	local store = self:GetStoreByWidget(btn)

	if data.onClick then
		data.onClick(btn, store)
	end
end
