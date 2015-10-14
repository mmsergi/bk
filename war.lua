local scene = composer.newScene()
local StickLib   = require("scripts.lib_analog_stick")
local localGroup
system.activate( "multitouch" )
physics.start( )
physics.setDrawMode( "hybrid" )
physics.setGravity( 0, 0 )
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- local forward references should go here

local function checkGoldCollision(gold, char)
    local incxpow = math.pow( gold.x - char.x, 2 ) 
    local incypow = math.pow( gold.y - char.y, 2 ) 
    local d = math.sqrt(incxpow+incypow)
    return d
end

-- Local collision handling
local function onGoldCollision(gold, event)
    if (event.other.id == "hero1") then
        hero1.state = "goldOn"
        goldOnHero1 = display.newImage("images/gold.png", hero1.x, hero1.y - 10)  
        gold:removeSelf( )     
    elseif (event.other.id == "hero2") then
        hero2.state = "goldOn"      
        goldOnHero2 = display.newImage("images/gold.png", hero2.x, hero2.y - 10)
        gold:removeSelf( )   
    end
end

local function positionGold(posX, posY)
    gold = display.newImage("images/gold.png", posX, posY)
    physics.addBody( gold )
    gold.collision = onGoldCollision
    gold:addEventListener( "collision", gold )
end

-- Global collision handling
local function onGlobalCollision( event )
    if (event.object1.id=="hero1" and event.object2.id=="hero2") then
        print("heros collision")
        if (hero1.state=="goldOn" and hero2.state==nil) then
            print("hero 2 attack")
            goldOnHero1:removeSelf( )
            hero1.state=nil
            timer.performWithDelay(20, function() positionGold(hero1.x - 100, hero1.y) end)
        elseif (hero1.state==nil and hero2.state=="goldOn") then
            print("hero 1 attack")
            goldOnHero2:removeSelf( )
            hero2.state=nil
            timer.performWithDelay(20, function() positionGold(hero2.x - 100, hero2.y) end)
        end
    end
end


local function frameUpdates ()
    if (goldOnHero1~=nil) then
        goldOnHero1.x, goldOnHero1.y = hero1.x, hero1.y - 10
    end

    if (goldOnHero2~=nil) then
        goldOnHero2.x, goldOnHero2.y = hero2.x, hero2.y - 10
    end
end
        
function scene:create( event )
    localGroup = self.view
    
    local Text = display.newText( " ", _W*.6, _H-20, native.systemFont, 15 )

    -- local hero
    localGroup = display.newGroup() -- remember this for farther down in the code
    motionx = 0; -- Variable used to move character along x axis
    motiony = 0; -- Variable used to move character along y axis
    speed = 2; -- Set Walking Speed 
     
    -- CREATE ANALOG STICK
    MyStick = StickLib.NewStick( 
            {
            x             = cx,
            y             = bottomMarg-50,
            thumbSize     = 16,
            borderSize    = 32, 
            snapBackSpeed = .2, 
            R             = 255,
            G             = 255,
            B             = 255
            } )

    MyStick2 = StickLib.NewStick( 
            {
            x             = cx,
            y             = topMarg + 50,
            thumbSize     = 16,
            borderSize    = 32, 
            snapBackSpeed = .2, 
            R             = 255,
            G             = 255,
            B             = 255
            } )
     -- MAIN LOOP
    ----------------------------------------------------------------
    local function main( event )
            
        -- MOVE THE SHIP
        MyStick:move(hero1, speed, false) -- se a opção for true o objeto se move com o joystick

        MyStick2:move(hero2, speed, false) -- se a opção for true o objeto se move com o joystick

        -- -- SHOW STICK INFO
        -- Text.text = "ANGLE = "..MyStick:getAngle().."   DIST = "..math.ceil(MyStick:getDistance()).."   PERCENT = "..math.ceil(MyStick:getPercent()*100).."%"
        
        --print("MyStick:getAngle = "..MyStick:getAngle())
        --print("MyStick:getDistance = "..MyStick:getDistance())
        -- print("MyStick:getPercent = "..MyStick:getPercent()*100)
        --print("POSICAO X / Y  " ..hero.x,hero.y)
        
        angle = MyStick:getAngle() 
        moving = MyStick:getMoving()

        angle2 = MyStick2:getAngle() 
        moving2 = MyStick2:getMoving()

        --Determine which animation to play based on the direction of the analog stick  
        -- 
        if(angle <= 45 or angle > 315) then
            seq = "forward"
            atackseq = "attackForward"
        elseif(angle <= 135 and angle > 45) then
            seq = "right"
            atackseq = "attackRight"
        elseif(angle <= 225 and angle > 135) then 
            seq = "back" 
            atackseq = "attackBack"
        elseif(angle <= 315 and angle > 225) then 
            seq = "left" 
            atackseq = "attackLeft"
        end

        if(angle2 <= 45 or angle2 > 315) then
            seq2 = "forward"
            atackseq = "attackForward"
        elseif(angle2 <= 135 and angle2 > 45) then
            seq2 = "right"
            atackseq = "attackRight"
        elseif(angle2 <= 225 and angle2 > 135) then 
            seq2 = "back" 
            atackseq = "attackBack"
        elseif(angle2 <= 315 and angle2 > 225) then 
            seq2 = "left" 
            atackseq = "attackLeft"
        end
        
        --Change the sequence only if another sequence isn't still playing 
        if(not (seq == hero1.sequence) and moving) then -- and not attacking
            hero1:setSequence(seq)
        end
        
        if(not (seq2 == hero2.sequence) and moving2) then -- and not attacking
            hero2:setSequence(seq2)
        end

        --If the analog stick is moving, animate the sprite
        if(moving) then 
            hero1:play() 
        end

            --If the analog stick is moving, animate the sprite
        if(moving2) then 
            hero2:play() 
        end
        
    end
     timer.performWithDelay(2000, function()
     --MyStick:delete()
     end, 1)
    Runtime:addEventListener( "enterFrame", main )    

    local bg = display.newImage(localGroup,"images/background.png")
    bg.x = cx
    bg.y = cy

    -- Display the new sprite at the coordinates passed
    hero1 = display.newSprite(localGroup, mySheet, sequenceData)
    hero1:setSequence("forward")
    hero1.x = cx
    hero1.y = cy + 30
    hero1.id = "hero1"
    physics.addBody( hero1, { density=1.0, friction=0.3, bounce=0.2, radius=25 } )

    hero2 = display.newSprite(localGroup, mySheet, sequenceData)
    hero2:setSequence("back")
    hero2.x = cx
    hero2.y = cy - 30
    hero2.id = "hero2"
    physics.addBody( hero2, { density=1.0, friction=0.3, bounce=0.2, radius=25 } )

    gold = display.newImage(localGroup, "images/gold.png", cx, cy + 120 )
    physics.addBody( gold )
    gold.collision = onGoldCollision
    gold:addEventListener( "collision", gold )


end-- "scene:create()"


function scene:show( event )

    local localGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).


    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        Runtime:addEventListener( "enterFrame", frameUpdates )
        Runtime:addEventListener( "collision", onGlobalCollision )
    end-- "scene:show()"
end-- "scene:show()"


function scene:hide( event )

    local localGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.

    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.

    end-- "scene:hide()"
end-- "scene:hide()"


function scene:destroy( event )

    local localGroup = self.view

    -- Called prior to the removal of scene's view ("localGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.


end-- "scene:destroy()"


---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene