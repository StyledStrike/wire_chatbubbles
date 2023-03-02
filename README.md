## wire_chatbubbles

A Expression 2 / Starfall extension to display bubbles of text on top of entities. Alternatively developers can use this to display bubbles with their own code.

### Installation

1. Download the source code `Code > Download Zip`
2. Extract the ZIP contents `wire_chatbubbles-master` to your Garry's Mod addons folder
3. Enable the extension *(Skip if enabled already, requires admin privileges)*
	* Using the console command `wire_expression2_extension_enable chatbubbles`, OR;
	* Through the Extensions menu on **Spawnlist > Utilities > Admin > E2 Extensions**.

### Expression 2 Functions

Cost | Function						| Description
---- | ---------------------------- | -----------
5    | canShowChatBubbles()			| Returns 1 if you can show a chat bubble, or 0 if you hit the burst limit
5    | getChatBubbleBurstLimit()	| Returns how many times you can call `showChatBubble` per second.
5    | chatBubbleTextColor(nnnn)		| Sets the text color to be used on the next showChatBubble call.
5    | chatBubbleBackgroundColor(nnnn)	| Sets the background color to be used on the next showChatBubble call.
5    | chatBubbleLifetime(n)	| Sets how long *(in seconds)* the next chat bubble will last. Clamped between 1.0 and 10.0
5    | chatBubbleScale(n)		| Sets the scale to apply to the next chat bubble. Clamped between 0.1 and 2.0
5    | chatBubbleOffsetZ(n)		| Sets the Z offset *(in units)* to apply to the next chat bubble. Clamped between -500.0 and 500.0
5    | chatBubbleAlign(n)		| **(Only visible with mutiline text)** Sets the text alignment of the next chat bubble. 0 - Left, 1 - Center, 2 - Right
50    | entity:showChatBubble(s)	| Shows a chat bubble on top of a entity.
50    | showChatBubble(s)			| Shows a chat bubble on top of the owner of the chip.

### Expression 2 Example

```perl
@name Chat Bubbles Example

if (first()) {
    # makes the chat bubbles last longer
    chatBubbleLifetime(10)

    # makes the text dark blue and fully opaque
    chatBubbleTextColor(0, 0, 150, 255)
    
    # makes the background white and a bit transparent
    chatBubbleBackgroundColor(255, 255, 255, 150)
}

event chat(Player:entity, Text:string, _) {
    if (Player == owner()) {
        # randomly choose the scale of the next chat bubble
        chatBubbleScale(random(0.2, 2.0))

        # shows a bubble on top of this chip containing what we said
        entity():showChatBubble(Text)
    }
}
```

### Starfall Example

```lua
--@name ChatBubblesExample
--@server

hook.add( "PlayerSay", "StarfallBubbleExample", function( _, text )

    -- lets show a red-ish chat bubble
    local params = {
        textColor = Color( 255, 200, 200, 255 ),
        backgroundColor = Color( 50, 0, 0, 200 ),
    
        lifetime = 5, -- in seconds
        scale = 2
    }

    -- Show a chat bubble on top of this chip when anyone says something
    -- The "params" table is optional.
    chatbubbles.show( chip(), text, params )

end )
```
