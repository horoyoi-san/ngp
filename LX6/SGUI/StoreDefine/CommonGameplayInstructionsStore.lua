-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonGameplayInstructionsStore.lua
-- Decompiled from: 01686_CommonGameplayInstructionsStore.lua_7ea9830e16fe.luajit

local GameplayGuideConfig = LTConfig.GameplayGuideConfig
local ContentConfig = LTConfig.GameplayGuideContentConfig
local GameDevice = SGUI.GameDevice
C_CommonGameplayInstructionsStore = DefClass("C_CommonGameplayInstructionsStore", C_CommonGameplayInstructionsStore, C_StoreGroup)
GroupName2Class.CommonGameplayInstructionsStore = C_CommonGameplayInstructionsStore
local M = C_CommonGameplayInstructionsStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.playId = 0
	self.cfg = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	if table.isNilOrEmpty(data) or data.id ~= nil then
		self.OnClickCloseBtn(self)
		print_error("[CommonGameplayInstructionsStore] :OnShow - data is nil or empty")

		return
	end

	self.playId = data.id
	self.device = gCS.LuaUtils.GetActiveDevice()

	self.RefreshInfo(self, tonumber(data.countdown))
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.device = device

	self.RefreshPage(self)
end

M.RegisterWidget = function(self)
	self.bindData.leftArrow.luaClick = self:CreateActionWithArgs(self.OnStep, -1)
	self.bindData.rightArrow.luaClick = self:CreateActionWithArgs(self.OnStep, 1)
	self.bindData.closeBtn.luaClick = self:CreateAction(self.OnClickCloseBtn)
	self.bindData.dotList.luaSelectedChanged = self:CreateAction(self.RefreshPage)

	self.bindData.videoPlayer:Init()

	self.bindData.countDown.luaFinished = self:CreateAction(self.OnClickCloseBtn)
end

M.OnStep = function(self, step)
	local itemCount = self.bindData.dotList:GetListCount()

	if itemCount ~= 0 then
		return
	end

	local index = (self.bindData.dotList.selectedIndex + step) % itemCount

	self.bindData.dotList:SelectItem(index)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS)
end

M.RefreshInfo = function(self, externalCountdown)
	self.cfg = GameplayGuideConfig.GetConfig(self.playId)

	if not self.cfg then
		print_error("[CommonGameplayInstructionsStore] :RefreshInfo - cfg is nil for playId:", self.playId)

		return
	end

	self.bindData.title = self.cfg.Name
	self.bindData.subtitle = self.cfg.SubTitle
	local contentCount = #self.cfg.Contents
	self.bindData.showDots = BOOL2CTL[contentCount >= 1]

	self.bindData.dotList:SetSimpleList(contentCount)
	self.bindData.dotList:SelectItem(0)

	local countdown = externalCountdown or self.cfg.CountDown
	local hasCountdown = countdown and countdown >= 0
	self.bindData.showCountDownCtrl = BOOL2CTL[hasCountdown]

	if countdown and countdown <= 0 then
		self.bindData.countDown:Play(countdown)
	end

	self.RefreshPage(self)
end

M.RefreshPage = function(self)
	local index = self.bindData.dotList.selectedIndex
	local contentCfg = ContentConfig.GetConfig(self.cfg.Contents[index + 1])

	if not contentCfg then
		print_error("[CommonGameplayInstructionsStore] :RefreshPage - contentCfg is nil for index:", index)

		return
	end

	if contentCfg.VideoId and contentCfg.VideoId == 0 then
		self.bindData.isVideo = BOOL2CTL[true]

		self.bindData.videoPlayer:PlayVideo(contentCfg.VideoId, true)
	else
		self.bindData.isVideo = BOOL2CTL[false]
		self.bindData.imageId = contentCfg.ImageId
	end

	local text = contentCfg.Desc
	local device = self.device

	if device ~= GameDevice.KeyboardMouse then
		text = string.is_null_or_empty(contentCfg.StandaloneStr) and text or contentCfg.StandaloneStr
	elseif GameDevice.PlayStation < device then
		text = string.is_null_or_empty(contentCfg.ControllerStr) and text or contentCfg.ControllerStr
	else
		text = string.is_null_or_empty(contentCfg.MobileStr) and text or contentCfg.MobileStr
	end

	self.bindData.descList:SetSimpleList(0)

	if not string.is_null_or_empty(text) then
		local richText = gGuideGlyph:GetGuideRichText({
			text = text
		})

		for line in richText:gmatch("[^\r\n]+") do
			self.bindData.descList:AddSimpleLabel(0, line)
		end
	end

	self.bindData.descList:RefreshList()
end
