local scene = composer.newScene()
local StickLib   = require("scripts.lib_analog_stick")
system.activate( "multitouch" )
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- local forward references should go here

function scene:create( event )

    local localGroup = self.view

    local Text = display.newText( " ", _W*.6, _H-20, native.systemFont, 15 )

    -- local hero
    local localGroup = display.newGroup() -- remember this for farther down in the code
    motionx = 0; -- Variable used to move character along x axis
    motiony = 0; -- Variable used to move character along y axis
    speed = 2; -- Set Walking Speed 
     
    -- CREATE ANALOG STICK
    MyStick = StickLib.NewStick( 
            {
            x             = leftMarg+50,
            y             = bottomMarg-50,
            thumbSize     = 32,
            borderSize    = 32, 
            snapBackSpeed = .2, 
            R             = 255,
            G             = 255,
            B             = 255
            } )

    MyStick2 = StickLib.NewStick( 
            {
            x             = rightMarg - 50,
            y             = topMarg + 50,
            thumbSize     = 32,
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
        MyStick:move(hero, speed, false) -- se a opção for true o objeto se move com o joystick

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
        if(not (seq == hero.sequence) and moving) then -- and not attacking
            hero:setSequence(seq)
        end
        
        if(not (seq2 == hero2.sequence) and moving2) then -- and not attacking
            hero2:setSequence(seq2)
        end

        --If the analog stick is moving, animate the sprite
        if(moving) then 
            hero:play() 
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
    hero = display.newSprite(mySheet, sequenceData)
    hero:setSequence("forward")
    hero.x = cx
    hero.y = cy + 30

    hero2 = display.newSprite(mySheet, sequenceData)
    hero2:setSequence("back")
    hero2.x = cx
    hero2.y = cy - 30


    localGroup:insert(bg)
    localGroup:insert(hero)
    localGroup:insert(hero2)

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