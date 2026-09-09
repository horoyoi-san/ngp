-- Ananta private-server fastpatch for client 4229938
-- Persistent UID/watermark override only. Gameplay Lua is untouched.

local CSPauseManager = LX6.Engine.PauseManager
C_UidLayerPanelStore = DefClass("C_UidLayerPanelStore", C_UidLayerPanelStore, C_StoreGroup)
GroupName2Class.UidLayerPanelStore = C_UidLayerPanelStore
local M = C_UidLayerPanelStore
local PRIVATE_SERVER_LABEL = "นี่คือเวอร์ชั่น DEV ที่ไม่ได้รับคุณภาพจากเกม Ananta GAY"
local REMOVE_STOCK_LABEL = true

local function ApplyPrivateServerText(self)
    if not self or not self.bindData then return end
    local login = gPlayerManager and gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData or nil
    local pid = login and login.pid or nil
    self.bindData.uidLabel = pid ~= nil and ("UID:" .. ulong.tostring(pid)) or ""
    if REMOVE_STOCK_LABEL then self.bindData.confidentialLabel = PRIVATE_SERVER_LABEL end
    self.bindData.versionCtrl = 0
    self.bindData.showUID = 0
end

M.ctor = function(self)
    self.msgEvents = { [gEventConstants.L50_BEFORE_SWITCH_SCENE] = self.CreateAction(self, "OnBeforeSwitchScene") }
end

M.OnAwake = function(self)
    self.RegisterMessageEvents(self, self.msgEvents)
    gLuaUIMgr.uidLayerPanelStore = self
    ApplyPrivateServerText(self)
end

M.OnShow = function(self, panelId, data)
    ApplyPrivateServerText(self)
end

M.OnClose = function(self) end

M.OnDestroy = function(self)
    self.ClearMessageEvents(self)
    gLuaUIMgr.uidLayerPanelStore = nil
end

M.OnActiveDeviceChange = function(self, device) end

M.ShowPauseInfo = function(self, serveSpeed)
    if not gGameManager.Env.isEditor or not gCS.PauseManager.showPauseTip then
        self.bindData.pauseLabel = ""
        return
    end
    local clientSpeed = CSPauseManager.Instance.PauseSpeed
    local text = ""
    if clientSpeed then
        if clientSpeed ~= 0 then
            text = text .. "客户端暂停 "
        elseif clientSpeed >= 1 then
            text = text .. "客户端时缓：" .. gString.Format("%.2f", clientSpeed) .. " "
        end
    end
    if serveSpeed then text = text .. "服务端暂停" else text = "" end
    self.bindData.pauseLabel = text
end

M.RefreshUID = function(self) ApplyPrivateServerText(self) end
M.RefreshVersion = function(self) ApplyPrivateServerText(self) end
M.RefreshUIDDisplay = function(self, show)
    if self and self.bindData then self.bindData.showUID = 0 end
end

M.OnBeforeSwitchScene = function(self, eventId, switchSceneEventParams)
    ApplyPrivateServerText(self)
end

M.OnLanguageChange = function(self, lang) ApplyPrivateServerText(self) end
