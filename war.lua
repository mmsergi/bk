local scene = composer.newScene()
local StickLib   = require("scripts.lib_analog_stick")
local localGroup
system.activate( "multitouch" )
physics.start( )
physics.setDrawMode( "hybrid" )
physics.setGravity( 0, 0 )

local scoreHero1 = 0
local scoreHero2 = 0

local normalSpeed = 7
local goldSpeed = 5

local randx
local randy
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- local forward references should go here

local function distance(obj1, obj2)
    local incxpow = math.pow( obj1.x - obj2.x, 2 ) 
    local incypow = math.pow( obj1.y - obj2.y, 2 ) 
    local d = math.sqrt(incxpow+incypow)
    return d
end

local function distancePointObj(x, y, obj2)
    local incxpow = math.pow( x - obj2.x, 2 ) 
    local incypow = math.pow( y - obj2.y, 2 ) 
    local d = math.sqrt(incxpow+incypow)
    return d
end

local function checkPos()
    randx = math.random(_W)
    randy = _H*40/100 + math.random(_H - _H*80/100)
    if (distancePointObj(randx, randy, hero1) > 128 and distancePointObj(randx, randy, hero2) > 128) then
        return true
    else
        return false
    end
end

-- Local collision handling
local function onGoldCollision(self, event)
    if (event.other.id == "hero1" and event.other.state==nil) then
        speedHero1 = goldSpeed
        hero1.state = "goldOn"
        goldOnHero1 = display.newImage("images/gold.png", hero1.x, hero1.y - 10)  
        self:removeSelf( )     
    elseif (event.other.id == "hero2" and event.other.state==nil) then
        speedHero2 = goldSpeed
        hero2.state = "goldOn"      
        goldOnHero2 = display.newImage("images/gold.png", hero2.x, hero2.y - 10)
        self:removeSelf( )   
    end
end

local function onCastleCollision (self, event)
    print ("collision "..self.id)
    if (self.id=="castle1" and event.other.id=="hero1" and event.other.state=="goldOn") then
        goldOnHero1:removeSelf( )
        hero1.state=nil
        print ("hero1 GOLD")
        scoreHero1 = scoreHero1 + 1 
        score1.text = scoreHero1
        speedHero1 = normalSpeed
    elseif (self.id=="castle2" and event.other.id=="hero2" and event.other.state=="goldOn") then
        goldOnHero2:removeSelf( )
        hero2.state=nil
        print ("hero2 GOLD")
        scoreHero2 = scoreHero2 + 1 
        score2.text = scoreHero2
        speedHero2 = normalSpeed
    end
end

local function positionGold(posX, posY)
    gold = display.newImage("images/gold.png", posX, posY)
    physics.addBody( gold, {radius=40} )
    gold.collision = onGoldCollision
    gold:addEventListener( "collision", gold )
end

-- Global collision handling
local function onGlobalCollision( event )
    if (event.phase == "began") then
        if (event.object1.id=="hero1" and event.object2.id=="hero2") then
            if (math.random()>0.5) then 
                inc = 200
            else 
                inc = -200
            end
            print("heros collision")
            if (hero1.state=="goldOn" and hero2.state==nil) then
                print("hero 2 attack")
                goldOnHero1:removeSelf( )
                hero1.state=nil
                speedHero1 = normalSpeed
                speedHero2 = goldSpeed
                hero2.state = "goldOn"      
                goldOnHero2 = display.newImage("images/gold.png", hero2.x, hero2.y - 10)
                --timer.performWithDelay(20, function() positionGold(hero1.x + inc, hero1.y) end)
            elseif (hero1.state==nil and hero2.state=="goldOn") then
                print("hero 1 attack")
                goldOnHero2:removeSelf( )
                hero2.state=nil
                speedHero2 = normalSpeed
                speedHero1 = goldSpeed
                hero1.state = "goldOn"      
                goldOnHero1 = display.newImage("images/gold.png", hero1.x, hero1.y - 10)
                --timer.performWithDelay(20, function() positionGold(hero2.x + inc, hero2.y) end)
            end
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

    if scoreHero1 > 4 or scoreHero2 > 4 then
        composer.gotoScene("menu")
    end
end
        
function scene:create( event )
    localGroup = self.view
    
    -- local hero
    localGroup = display.newGroup() -- remember this for farther down in the code
    motionx = 0 -- Variable used to move character along x axis
    motiony = 0 -- Variable used to move character along y axis
    speedHero1 = normalSpeed -- Set Walking Speed 
    speedHero2 = normalSpeed

    -- CREATE ANALOG STICK
    MyStick = StickLib.NewStick( 
            {
            x             = rightMarg-_W*20/100,
            y             = bottomMarg-_H*12.5/100,
            thumbSize     = 32,
            borderSize    = 32, 
            snapBackSpeed = .2, 
            R             = 255,
            G             = 255,
            B             = 255
            } )

    MyStick2 = StickLib.NewStick( 
            {
            x             = leftMarg+_W*20/100,
            y             = topMarg+_H*12.5/100,
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
        MyStick:move(hero1, speedHero1, false) -- se a opção for true o objeto se move com o joystick

        MyStick2:move(hero2, speedHero2, false) -- se a opção for true o objeto se move com o joystick

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
    hero1.y = cy + 70
    hero1.id = "hero1"
    physics.addBody( hero1, { density=0.5, friction=0, bounce=0.2, radius=70 } )

    hero2 = display.newSprite(localGroup, mySheet, sequenceData)
    hero2:setSequence("back")
    hero2.x = cx
    hero2.y = cy - 70
    hero2.id = "hero2"
    physics.addBody( hero2, { density=0.5, friction=0, bounce=0.2, radius=70 } )

    castle = display.newRect(localGroup, leftMarg, bottomMarg, 200, 200 )
    physics.addBody( castle, "static")
    castle.id="castle1"
    castle.collision = onCastleCollision
    castle:addEventListener( "collision", castle )

    castle2 = display.newRect(localGroup, rightMarg, topMarg, 200, 200 )
    physics.addBody( castle2, "static")
    castle2.id="castle2"
    castle2.collision = onCastleCollision
    castle2:addEventListener( "collision", castle2 )

    score1 = display.newText( localGroup, scoreHero1, leftMarg + 30, bottomMarg - 30 )
    score1:setFillColor( black )
    score2 = display.newText( localGroup, scoreHero2, rightMarg - 30, topMarg + 30 )
    score2:setFillColor( black )

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
        timer.performWithDelay( 100, 
            function () 
                while (checkPos()==false) do 
                    checkPos() 
                end 
                positionGold(randx, randy) 
                print(randx.."   "..randy)
            end
        , 0)
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