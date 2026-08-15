C_FakePhoneAlbumHomePanelStore = DefClass("C_FakePhoneAlbumHomePanelStore", C_FakePhoneAlbumHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.FakePhoneAlbumHomePanelStore = C_FakePhoneAlbumHomePanelStore
local M = C_FakePhoneAlbumHomePanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_FAKE_PHONE_ALBUM_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end
	}
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:PlayBackToMainAnimation()
	return
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
