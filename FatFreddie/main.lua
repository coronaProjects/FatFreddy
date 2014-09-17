-- Hide the status bar.
display.setStatusBar( display.HiddenStatusBar )  

-- Set the background color to white
local background = display.newRect( 0, 0, 960, 590 )
background:setFillColor( 255, 255, 255 )  

-- Add a score label
local score = 0
local scoreLabel = display.newText( score, 0, 0, native.systemFontBold, 120 )
scoreLabel.x = display.viewableContentWidth / 2
scoreLabel.y = display.viewableContentHeight / 2
scoreLabel:setTextColor( 0, 0, 0, 10 )  

-- Setup the physics wolrd
local physics = require( "physics" )
physics.start()
-- physics.setDrawMode( "hybrid" )

-- Creates and returns a new player.
local function createPlayer( x, y, width, height, rotation )
    --  Player is a black square.
    local p = display.newRect( x, y, width, height )
    p:setFillColor( 0, 0, 0 )
    p.rotation = rotation

    local playerCollisionFilter  = { categoryBits = 2, maskBits = 5}
    local playerBodyElement = { filter = playerCollisionFilter }

    p.isBullet = true
    p.objectType = "player"
    physics.addBody( p, "dinamic", playerBodyElement)
    p.isSleppingAllowed = false

    return p
end

local player = createPlayer( display.viewableContentWidth / 2, display.viewableContentHeight / 2, 20, 20, 0 )

local playerRotation = function()
    player.rotation = player.rotation + 1
end

Runtime:addEventListener( "enterFrame", playerRotation )

-- Forces the object to stay within the visible screen bounds.
local function coerceOnScreen( object )
    if object.x < object.width then
        object.x = object.width
    end
    if object.x > display.viewableContentWidth - object.width then
        object.x = display.viewableContentWidth - object.width
    end
    if object.y < object.height then
        object.y = object.height
    end
    if object.y > display.viewableContentHeight - object.height then
        object.y = display.viewableContentHeight - object.height
    end
end

local function onTouch( event )
    if "began" == event.phase then
        player.isFocus = true

        player.x0 = event.x - player.x
        player.y0 = event.y - player.y
    elseif player.isFocus then
        if "moved" == event.phase then
            player.x = event.x - player.x0
            player.y = event.y - player.y0
            coerceOnScreen( player )

        elseif "ended" == phase or "cancelled" == phase then
            player.isFocus = false
        end
    end

    -- Return true if the touch event has been handled.
    return true
end

-- Only the background receives touches.
background:addEventListener( "touch", onTouch)

-- Overhead view, like looking at a pool table from above.
physics.setGravity( 0, 0 )

local function spawn( objectType, x, y )
    local object
    local sizeXY = math.random( 20,100 )
    local collisionFilter = { categoryBits = 4, maskBits = 2 } --collites with player only
    local body = { filter =collisionFilter, isSensor = true }
    object = display.newRect( x, y, sizeXY, sizeXY )
    if "food" == objectType then
        object:setFillColor( 0, 255, 0)
    else
        object:setFillColor( 0, 0 ,255)
    end
    object.objectType = objectType
    physics.addBody( object, body)
    object.isFixedRotation = true
    return object
end 

local  green = spawn( "food", 50, 50)
local blue = spawn( "enemy", 100, 200)

-- We want to get notified when a collision occurs
local function onCollision( event )
    local type1 = event.object1.objectType
    local type2 = event.object2.objectType
    print( "collision between".. type1 .. " and "..type2)
    if type1 == "food" or type2 == "food" then 
        score = score +1
    else 
        score = score -1
    end
    scoreLabel.text = score
end 

Runtime:addEventListener( "collision", onCollision)

















