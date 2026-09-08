-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatChattingPanelStore_AnimUtils.lua
-- Decompiled from: 01935_ChatChattingPanelStore_AnimUtils.lua_6714694ac7e6.luajit

local M = C_ChatChattingPanelStore

M.AnimUtilsInit = function(self)
	self.anim = {
		["OF}g "] = -1,
		State = {}
	}
end

M.EnableItemAnim = function(self, enable)
	self.anim.enable = enable
end

M.SetItemAnimLastIndex = function(self, index)
	self.anim.lastIndex = index
end

M.PlayChatItemAnim = function(self, btn, index)
	if not self.anim.enable or index < self.anim.lastIndex then
		return
	end

	local state = self.anim.State[index] or {}
	local name = btn.name
	local isEllipsis = string.starts_with(name, "S_ChatTypingMsgTemplate")
	local isText = not isEllipsis and string.starts_with(name, "S_ChatTextMsgTemplate")
	local transform = btn.transform

	if isEllipsis then
		local ellipsisGo = transform:Find("Button")
		local anim = ellipsisGo and ellipsisGo:GetComponent(typeof(UnityEngine.Animation))
		local ellipsisWidget = ellipsisGo and ellipsisGo:GetComponent(typeof(SGUI.UWidget))

		if ellipsisWidget then
			ellipsisWidget.renderOpacity = 0
		end

		anim.Stop(anim)
		anim.Play(anim)

		state.ellipsisAnimPlayed = true
	elseif isText then
		local contentGo = transform.Find(transform, "MsgBubble")

		if state.ellipsisAnimPlayed then
			self._TryPlayAnimOnNode(self, contentGo, false)

			if not state.contentAnimPlayed then
				state.contentAnimPlayed = true
			end
		else
			state.contentAnimPlayed = state.contentAnimPlayed or self:_TryPlayAnimOnNode(contentGo, not state.contentAnimPlayed)
		end
	else
		local contentGo = transform:Find("Button") or transform:Find("MsgBubble")
		state.contentAnimPlayed = state.contentAnimPlayed or self:_TryPlayAnimOnNode(contentGo, not state.contentAnimPlayed)
	end

	local avatarGo = transform:Find("ChatHead")
	state.avatarAnimPlayed = state.avatarAnimPlayed or self:_TryPlayAnimOnNode(avatarGo, not state.avatarAnimPlayed)
	self.anim.State[index] = state
end

M._TryPlayAnimOnNode = function(self, transform, isPlay)
	local anim = transform and transform:GetComponent(typeof(UnityEngine.Animation))

	if anim then
		if isPlay then
			local widget = transform.GetComponent(transform, typeof(SGUI.UWidget))

			if widget then
				widget.renderOpacity = 0
			end

			anim.enabled = true

			anim.Play(anim)

			return true
		else
			anim.Stop(anim)

			anim.enabled = false

			return false
		end
	end

	return false
end
