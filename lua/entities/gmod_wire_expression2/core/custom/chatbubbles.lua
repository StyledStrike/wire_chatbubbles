--[[
	ChatBubbles support for Expression 2
]]
E2Lib.RegisterExtension('chatbubbles', true)

local function ShowBubble(self, ent, text)
	if not E2Lib.isOwner(self, ent) then
		error('You cannot show a chat bubble on a entity you do not own!')
	end

	ChatBubbles:OwnedShowOnEntity(self.player, ent, text, self.data.cbbl_params)
end

__e2setcost(5)

e2function number canShowChatBubbles()
	return ChatBubbles:CanPlayerShowBubbles(self.player) and 1 or 0
end

e2function number getChatBubbleBurstLimit()
	return ChatBubbles.SHOW_BURST_LIMIT
end

e2function void chatBubbleTextColor(r, g, b, a)
	self.data.cbbl_params.fg = Color(r, g, b, a)
end

e2function void chatBubbleBackgroundColor(r, g, b, a)
	self.data.cbbl_params.bg = Color(r, g, b, a)
end

e2function void chatBubbleLifetime(lifetime)
	self.data.cbbl_params.lifetime = math.Clamp(lifetime, 1, 10)
end

e2function void chatBubbleScale(scale)
	self.data.cbbl_params.scale = math.Clamp(scale, 0.1, 2)
end

e2function void chatBubbleOffsetZ(offset)
	self.data.cbbl_params.offset = math.Clamp(offset, -500, 500)
end

e2function void chatBubbleAlign(align)
	align = math.Clamp(math.Round(align), 0, 2)
	self.data.cbbl_params.align = align
end

__e2setcost(50)

e2function void entity:showChatBubble(string text)
	ShowBubble(self, this, text)
end

e2function void showChatBubble(string text)
	ShowBubble(self, self.player, text)
end

registerCallback('construct', function(self)
	self.data = self.data or {}

	self.data.cbbl_params = {
		fg = Color(255, 255, 255, 255),
		bg = Color(0, 0, 0, 200),
		lifetime = 5,
		scale = 1.0,
		offset = 0,
		align = 1
	}
end)