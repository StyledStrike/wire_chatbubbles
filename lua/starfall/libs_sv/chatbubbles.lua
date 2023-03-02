local checkluatype = SF.CheckLuaType

--- ChatBubbles support for Starfall.
-- @name chatbubbles
-- @class library
-- @libtbl chatbubbles_library
SF.RegisterLibrary( "chatbubbles" )

return function( instance )

local chatbubbles_library = instance.Libraries.chatbubbles
local cunwrap = instance.Types.Color.Unwrap
local eunwrap = instance.Types.Entity.Unwrap

local function validateNumber( v, default, min, max )
    v = v or default
    checkluatype( v, TYPE_NUMBER )

    return math.Clamp( v, min, max )
end

--- Checks if you can show a chat bubble, or if you hit the burst limit.
-- @server
-- @return boolean true if you can show a chat bubble.
function chatbubbles_library.canShowChatBubbles()
    if instance.player == SF.Superuser then return true end

    return ChatBubbles:CanPlayerShowBubbles( instance.player )
end

--- Shows a chat bubble on top of a entity.
-- 
-- The optional "params" argument can have the following keys:
--	textColor       - (Color) The text color
--	backgroundColor - (Color) The background color
--	lifetime        - (number) How long (in seconds) the bubble will last
--	scale           - (number) Bubble scale
--	offsetZ         - (number) The Z offset (in units)
--	align           - (number) (Only visible with mutiline text) The text alignment
-- @server
-- @param Entity ent Target entity to display a bubble on top of.
-- @param string text Text to be displayed.
-- @param table? params An optional table of the bubble parameters.
function chatbubbles_library.show( ent, text, params )
    checkluatype( text, TYPE_STRING )
    ent = eunwrap( ent )

    if not ent:IsValid() or ent:IsWorld() then
        SF.Throw( "Entity is not valid.", 3 )
    end

    local p = {}

    if params then
        checkluatype( params, TYPE_TABLE )

        p.fg = params.textColor and cunwrap( params.textColor )
        p.bg = params.backgroundColor and cunwrap( params.backgroundColor )

        p.lifetime = validateNumber( params.lifetime, 5, 1, 10 )
        p.scale = validateNumber( params.scale, 1, 0.1, 2 )
        p.offset = validateNumber( params.offsetZ, 0, -500, 500 )
        p.align = validateNumber( params.align, 1, 0, 2 )
        p.align = math.Round( p.align )
    end

    if instance.player == SF.Superuser then
        ChatBubbles:ShowOnEntity( ent, text, p )
    else
        ChatBubbles:OwnedShowOnEntity( instance.player, ent, text, p )
    end
end

end