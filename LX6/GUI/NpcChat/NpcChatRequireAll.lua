-- Original chunk: @Lua\LuaFiles\LX6\GUI\NpcChat\NpcChatRequireAll.lua
-- Decompiled from: 00299_NpcChatRequireAll.lua_597816d21801.luajit

require("LX6/GUI/NpcChat/NpcChatConst")
require("LX6/Manager/NpcChat/NpcChatTabs")
require("LX6/Manager/NpcChat/NpcChatManager")
require("LX6/Manager/NpcChat/NpcChatManager_Channel")
require("LX6/Manager/NpcChat/NpcChatManager_Story")
require("LX6/Manager/NpcChat/NpcChatManager_RedDot")

gNpcChatManager = gNpcChatManager or C_NpcChatManager.new()

require("LX6/GUI/NpcChat/NpcChatNpcsPhoneManager")
require("LX6/GUI/NpcChat/NpcChatUtils")
require("LX6/GUI/NpcChat/NpcChatAvatarUtils")
require("LX6/GUI/NpcChat/NpcChatSenderId")
require("LX6/GUI/NpcChat/NpcChatMessage")
require("LX6/GUI/Dialog/DialogMainChatManager")
