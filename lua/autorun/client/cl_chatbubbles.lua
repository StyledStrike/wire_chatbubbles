local bubbles = {}
local border = 28

local DRAW_DISTANCE_SQR = 2000 ^ 2

surface.CreateFont( "ChatBubbleFont", {
    font = "Roboto",
    extended = false,
    size = 80,
    weight = 600,
    blursize = 0,
    scanlines = 0,
    antialias = true
} )

local function drawBubble( b )
    if not b.w then
        surface.SetFont( "ChatBubbleFont" )
        b.w, b.h = surface.GetTextSize( b.text )
        b.textX = 0
        b.y = -b.h

        if b.align == 0 then
            b.textX = b.w * -0.5
        elseif b.align == 2 then
            b.textX = b.w * 0.5
        end
    end

    draw.RoundedBox( 4, ( b.w * -0.5 ) - ( border * 0.5 ), b.y - ( border * 0.5 ), b.w + border, b.h + border, b.bg )
    draw.DrawText( b.text, "ChatBubbleFont", b.textX, b.y, b.fg, b.align )
end

hook.Add( "PostDrawTranslucentRenderables", "chatbubbles.RenderActiveBubbles",
    function( _, drawingSkybox, drawing3DSkybox )

    if drawingSkybox or drawing3DSkybox then return end

    local ft = FrameTime()
    local eyePos = EyePos()
    local pos, ang

    for id, b in pairs( bubbles ) do
        if IsValid( b.ent ) then
            pos = b.ent:GetPos() + b.offset
            ang = ( eyePos - pos ):Angle()
            ang = Angle( 0, ang[2] + 90, 90 )

            if eyePos:DistToSqr( pos ) < DRAW_DISTANCE_SQR then
                cam.Start3D2D( pos, ang, b.scale * b.anim )
                    drawBubble( b )
                cam.End3D2D()
            end

            b.lifetime = b.lifetime - ft

            if b.lifetime > 0 then
                b.anim = Lerp( ft * 15, b.anim, 1 )
            else
                b.anim = b.anim - ( ft * 5 )

                if b.anim < 0 then
                    b.ent = nil
                end
            end
        else
            bubbles[id] = nil
        end
    end
end )

net.Receive( "chatbubbles.show", function()
    local ent = net.ReadEntity()
    local str = net.ReadString()

    if not IsValid( ent ) then return end

    local fg = Color(
        net.ReadUInt( 8 ),
        net.ReadUInt( 8 ),
        net.ReadUInt( 8 ),
        net.ReadUInt( 8 )
    )

    local bg = Color(
        net.ReadUInt( 8 ),
        net.ReadUInt( 8 ),
        net.ReadUInt( 8 ),
        net.ReadUInt( 8 )
    )

    local lifetime = net.ReadFloat()
    local scale = net.ReadFloat()
    local offset = net.ReadFloat()
    local align = net.ReadUInt( 2 )

    local id = ent:EntIndex()
    local obbSize = Either( ent:IsPlayer(), Vector( 0, 0, 70 ), ent:OBBMaxs() - ent:OBBMins() )

    bubbles[id] = {
        text = str,
        ent = ent,
        fg = fg,
        bg = bg,

        align = align,
        lifetime = lifetime,
        offset = Vector( 0, 0, math.abs( obbSize[3] ) + offset ),
        scale = scale * 0.06,
        anim = 0
    }
end )
