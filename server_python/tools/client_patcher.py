"""
Client Lua Patcher Tool
Helps unlock hidden developer features in the client UI:
- Server selection button (canSelectServer)
- Test account input box (loginByCheat)
"""

import os
import re

LOGIN_PANEL_PATH = os.path.abspath(
    os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
        "lua",
        "lua",
        "LX6",
        "SGUI",
        "StoreDefine",
        "LoginPanelStore.lua",
    )
)


def patch_login_panel():
    if not os.path.exists(LOGIN_PANEL_PATH):
        print(f"[Error] File not found: {LOGIN_PANEL_PATH}")
        return False

    with open(LOGIN_PANEL_PATH, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    modified = False

    # 1. Force showServerBtn = 0 (visible)
    # Original: self.bindData.showServerBtn = BOOL2CTL[gCS.LoginManager.canSelectServer]
    if "self.bindData.showServerBtn = BOOL2CTL[gCS.LoginManager.canSelectServer]" in content:
        content = content.replace(
            "self.bindData.showServerBtn = BOOL2CTL[gCS.LoginManager.canSelectServer]",
            "self.bindData.showServerBtn = 0 -- PATCHED: Always show server button",
        )
        modified = True
        print("[+] Patched: Force showServerBtn = 0 (Always Visible)")

    # 2. Force showTestAccountBtn = 0 (visible)
    if "self.bindData.showTestAccountBtn = BOOL2CTL[not gCS.LoginManager.loginBySDK and not gCS.LoginManager.loginByOpenId]" in content:
        content = content.replace(
            "self.bindData.showTestAccountBtn = BOOL2CTL[not gCS.LoginManager.loginBySDK and not gCS.LoginManager.loginByOpenId]",
            "self.bindData.showTestAccountBtn = 0 -- PATCHED: Always show test account button",
        )
        modified = True
        print("[+] Patched: Force showTestAccountBtn = 0 (Always Visible)")

    # 3. Bypass publish check in OnClick_ConfirmTestAccount
    # Original: if gCS.LuaUtils.IsPublish or not gCS.LoginManager.loginByCheat then return end
    if "if gCS.LuaUtils.IsPublish or not gCS.LoginManager.loginByCheat then" in content:
        content = content.replace(
            "if gCS.LuaUtils.IsPublish or not gCS.LoginManager.loginByCheat then",
            "if false and (gCS.LuaUtils.IsPublish or not gCS.LoginManager.loginByCheat) then -- PATCHED: Bypass check",
        )
        modified = True
        print("[+] Patched: Bypassed loginByCheat check in ConfirmTestAccount")

    if modified:
        with open(LOGIN_PANEL_PATH, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"\nSuccessfully patched LoginPanelStore.lua!")
        print("Now the client will display the Server Selection button and Test Account input field!")
        return True
    else:
        print("[Info] LoginPanelStore.lua appears to be already patched or modified.")
        return True


if __name__ == "__main__":
    patch_login_panel()
