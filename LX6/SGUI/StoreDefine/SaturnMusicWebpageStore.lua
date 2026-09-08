-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SaturnMusicWebpageStore.lua
-- Decompiled from: 02098_SaturnMusicWebpageStore.lua_788240403bef.luajit

local SatrunSectionType = LTConfig.WebpageSatrunConfig.TypeType
local SatrunSubType = LTConfig.WebpageSatrunConfig.SubTypeType
C_SaturnMusicWebpageStore = DefClass("C_SaturnMusicWebpageStore", C_SaturnMusicWebpageStore, C_SaturnResourceWebpageBase)
GroupName2Class.SaturnMusicWebpageStore = C_SaturnMusicWebpageStore
local M = C_SaturnMusicWebpageStore
M.PlayBtlCtl = {
	["\\xe9\\xd7*\\xf6"] = 1,
	["\\xe9\\xda*\\xf6"] = 0
}

M.ctor = function(self)
	self.bgImage = 0
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderList)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
	self.bindData.btnPlayOrPause.luaClick = self.CreateAction(self, self.OnPlayOrPauseBtnClick)
	self.bindData.btnNextMusic.luaClick = self.CreateAction(self, self.OnNextMusicBtnClick)
	self.bindData.btnPrevMusic.luaClick = self.CreateAction(self, self.OnPrevMusicBtnClick)
	self.bindData.btnNextPage.luaClick = self.CreateAction(self, self.NextPage)
	self.bindData.btnPrevPage.luaClick = self.CreateAction(self, self.PrevPage)
	self.bindData.resource.luaOnPlay = self.CreateAction(self, self.OnAudioPlayOrResume)
	self.bindData.resource.luaOnResume = self.CreateAction(self, self.OnAudioPlayOrResume)
	self.bindData.resource.luaOnPause = self.CreateAction(self, self.OnAudioPauseOrStop)
	self.bindData.resource.luaOnStop = self.CreateAction(self, self.OnAudioPauseOrStop)
	self.bindData.btnGoHome.luaClick = self.CreateAction(self, self.GoToHomePage)

	self.InitNavBindData(self, self.bindData.nav, self.bindData.navbar)
end

M.RefreshPage = function(self)
	self.LoadData(self, SatrunSectionType.music, SatrunSubType.Music)
end

M.OnRenderPage = function(self, resources)
	self.bindData.list:SetSimpleList(#resources)
	self:SetResourceId(1)
	self.bindData.list:SelectItem(0)

	if self.bgImage == 0 then
		-- Nothing
	end

	self.LoadResource(self)

	self.bindData.btnPrevPage.interactable = self.HasPrevPage(self)
	self.bindData.btnNextPage.interactable = self.HasNextPage(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end

M.OnSimpleRenderList = function(self, widget, index)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local resource = self:GetResource(index + 1)

	store:Commit("image", resource.image, COMMIT_FORCE)
end

M.OnSimpleClickList = function(self, _, index)
	self.bindData.list:SelectItem(index)
	self:SetResourceId(index + 1)
	self:LoadResource()
end

M.OnNextMusicBtnClick = function(self)
	self:NextResource()
	self:LoadResource()

	local idx = self:GetResourceId()

	self.bindData.list:SelectItem(idx - 1)
end

M.OnPrevMusicBtnClick = function(self)
	self:PrevResource()
	self:LoadResource()

	local idx = self:GetResourceId()

	self.bindData.list:SelectItem(idx - 1)
end

M.OnLoadResource = function(self, resource)
	self.bindData.title.text = resource.title

	if resource.image then
		self.bindData:Commit("image", resource.image, COMMIT_FORCE)
	end

	self.bindData.resource.resourceId = resource.resourceId
	self.bindData.musicImageRotator.IsPause = true
end

M.OnPlayOrPauseBtnClick = function(self)
	self.bindData.resource:PlayOrPause()
end

M.OnAudioPlayOrResume = function(self)
	self.bindData.btnPlayCtl = self.PlayBtlCtl.Playing
	self.bindData.musicImageRotator.IsPause = false
end

M.OnAudioPauseOrStop = function(self)
	self.bindData.btnPlayCtl = self.PlayBtlCtl.Pausing
	self.bindData.musicImageRotator.IsPause = true
end
