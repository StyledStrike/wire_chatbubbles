local checkluatype = SF.CheckLuaType

--- ChatBubbles support for Starfall.
-- @name chatbubbles
-- @class library
-- @libtbl chatbubbles_library
SF.RegisterLibrary( 'chatbubbles' )

return function( instance )

local chatbubbles_library = instance.Libraries.chatbubbles
local cunwrap = instance.Types.Color.Unwrap
local eunwrap = instance.Types.Entity.Unwrap

local function checkNumberParameter( v, min, max )
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
--	Color / textColor        - The text color
--	Color / backgroundColor  - The background color
--	Number / lifetime        - How long (in seconds) the bubble will last
--	Number / scale           - Bubble scale
--	Number / offsetZ         - The Z offset (in units)
--	Number / align           - (Only visible with mutiline text) The text alignment
-- @server
-- @param Entity ent Target entity to display a bubble on top of.
-- @param string text Text to be displayed.
-- @param table? params An optional table of the bubble parameters.
function chatbubbles_library.show( ent, text, params )
    checkluatype( text, TYPE_STRING )
    ent = eunwrap( ent )

    if not ent:IsValid() or ent:IsWorld() then
        SF.Throw( 'Entity is not valid.', 3 )
    end

    local p = {}

    if params then
        checkluatype( params, TYPE_TABLE )

        p.fg = params.textColor and cunwrap( params.textColor )
        p.bg = params.backgroundColor and cunwrap( params.backgroundColor )

        p.lifetime = checkNumberParameter( params.lifetime, 1, 10 )
        p.scale = checkNumberParameter( params.scale, 0.1, 2 )
        p.offset = checkNumberParameter( params.offsetZ, -500, 500 )
        p.align = checkNumberParameter( params.align, 0, 2 )

        if p.align then
            p.align = math.Round( p.align )
        end
    end

    if instance.player == SF.Superuser then
        ChatBubbles:ShowOnEntity( ent, text, p )
    else
        ChatBubbles:OwnedShowOnEntity( instance.player, ent, text, p )
    end
end

end