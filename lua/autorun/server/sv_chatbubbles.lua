--[[
    ChatBubbles - Display text bubbles on top of entities
]]

util.AddNetworkString( 'chatbubbles.show' )

ChatBubbles = {
    -- max. length for the text
    MAX_TEXT_LEN = 100,

    -- limit how many times showChatBubble can be called per second
    SHOW_BURST_LIMIT = 3
}

-- keep track of the burst limit for players
local burstLimit = {}

hook.Add( 'PlayerDisconnected', 'chatbubbles_CleanupBurstLimit', function( ply )
    burstLimit[ply] = nil
end )

function ChatBubbles:ShowOnEntity( ent, text, params )
    -- you can call this function without the last
    -- argument to use the default params
    params = params or {}

    local fg = params.fg or Color( 255, 255, 255, 255 )
    local bg = params.bg or Color( 0, 0, 0, 200 )

    net.Start( 'chatbubbles.show' )
        net.WriteEntity( ent )
        net.WriteString( text )

        net.WriteUInt( fg.r, 8 )
        net.WriteUInt( fg.g, 8 )
        net.WriteUInt( fg.b, 8 )
        net.WriteUInt( fg.a, 8 )

        net.WriteUInt( bg.r, 8 )
        net.WriteUInt( bg.g, 8 )
        net.WriteUInt( bg.b, 8 )
        net.WriteUInt( bg.a, 8 )

        net.WriteFloat( params.lifetime or 5 )
        net.WriteFloat( params.scale or 1 )
        net.WriteFloat( params.offset or 0 )
        net.WriteUInt( params.align or 1, 2 )
    net.Broadcast()
end

function ChatBubbles:CanPlayerShowBubbles( ply )
    local burst = burstLimit[ply]

    -- this player doesnt have a entry yet
    if not burst then
        return true
    end

    -- this player still has some bursts left
    if burst.left > 0 then
        return true
    end

    -- enough time has passed since the burst
    -- first started, so we can reset it
    if RealTime() > burst.resetAt then
        burstLimit[ply] = nil
        return true
    end

    return false
end

function ChatBubbles:OwnedShowOnEntity( owner, ent, text, params )
    if not IsValid( owner ) then return end
    if not IsValid( ent ) then return end
    if not self:CanPlayerShowBubbles( owner ) then return end

    text = string.Trim( text )

    -- ignore empty strings
    local len = string.len( text )
    if len < 1 then return end

    -- cap huge strings
    if len > self.MAX_TEXT_LEN then
        text = string.Left( text, self.MAX_TEXT_LEN - 3 ) .. '...'
    end

    local burst = burstLimit[owner]

    if burst then
        -- take one more from the burst limit
        burst.left = burst.left - 1
    else
        -- create a new burst limit
        burstLimit[owner] = {
            left = self.SHOW_BURST_LIMIT - 1,
            resetAt = RealTime() + 1
        }
    end

    self:ShowOnEntity( ent, text, params )
end