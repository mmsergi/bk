local scene = composer.newScene()
local StickLib   = require("scripts.lib_analog_stick")
local localGroup
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- local forward references should go here
physics.start( )
physics.setDrawMode( "hybrid" )
physics.setGravity( 0, 0 )

local scoreHero = 0

local normalSpeed = 7
local goldSpeed = 5

local vx = 5
local vy = 5

local randx
local randy

local function distanceenemyObj(x, y, obj2)
    local incxpow = math.pow( x - obj2.x, 2 ) 
    local incypow = math.pow( y - obj2.y, 2 )
    local d = math.sqrt(incxpow+incypow)
    return d
end

local function checkPos()
    randx = math.random(_W)
    randy = _H/10 + math.random(_H - _H*50/100)
    if (distanceenemyObj(randx, randy, hero) > hero.height/2) then
        return true
    else
        return false
    end
end

-- Local collision handling
local function onGoldCollision(self, event)
    if (event.other.id == "hero" and event.other.state==nil) then
        speedhero = goldSpeed
        hero.state = "goldOn"
        goldOnhero = display.newImage("images/gold.png", hero.x, hero.y - 10)  
        self:removeSelf( )      
    end
end

local function onCastleCollision (self, event)
    print ("collision "..self.id)
    if (self.id=="castle1" and event.other.id=="hero" and event.other.state=="goldOn") then
        goldOnhero:removeSelf( )
        hero.state=nil
        print ("hero GOLD")
        scoreHero = scoreHero + 1 
        score.text = scoreHero
        speedhero = normalSpeed
    end
end

local function positionGold(posX, posY)
    gold = display.newImage(localGroup, "images/gold.png", posX, posY)
    gold.rotation = math.random(0, 360)
    physics.addBody( gold, {radius=gold.width/2} )
    gold.collision = onGoldCollision
    gold:addEventListener( "collision", gold )
    localGroup:insert( gold )
end

local function shotFire()
    if (math.random()>.5) then
        fire = display.newImage(localGroup, "images/fire.png", -_W/5, math.random(_H*10/100, _H*80/100))
        fire.rotation = -90
        physics.addBody( fire )
        fire:setLinearVelocity( 200, 0 )
    else
        fire = display.newImage(localGroup, "images/fire.png", _W +_W/5, math.random(_H*10/100, _H*80/100))
        fire.rotation = 90
        physics.addBody( fire )
        fire:setLinearVelocity( -200, 0 )
    end
end

-- Global collision handling
local function onGlobalCollision( event )
    if (event.phase == "began") then
        if (event.object1.id=="hero" and event.object2.id=="hero2") then
            print("heros collision")
            if (hero.state=="goldOn" and hero2.state==nil) then
                print("hero 2 attack")
                goldOnhero:removeSelf( )
                hero.state=nil
                speedhero = normalSpeed
                timer.performWithDelay(20, function() positionGold(hero.x - 100, hero.y) end)
            elseif (hero.state==nil and hero2.state=="goldOn") then
                print("hero 1 attack")
                goldOnHero2:removeSelf( )
                hero2.state=nil
                speedHero2 = normalSpeed
                timer.performWithDelay(20, function() positionGold(hero2.x - 100, hero2.y) end)
            end
        end
    end
end

local function frameUpdates ()

    if (goldOnhero~=nil) then
        goldOnhero.x, goldOnhero.y = hero.x, hero.y - 10
    end

    if (goldOnHero2~=nil) then
        goldOnHero2.x, goldOnHero2.y = hero2.x, hero2.y - 10
    end

    --[[ ENEMY CHASER
    local distanceX = hero.x - enemy.x
    local distanceY = hero.y - enemy.y
 
    local angleRadians = math.atan2(distanceY, distanceX)
    local angleDegrees = math.deg(angleRadians)
 
    local enemySpeed = 5
 
    local enemyMoveDistanceX = enemySpeed*math.cos(angleDegrees)
    local enemyMoveDistanceY = enemySpeed*math.sin(angleDegrees)
 
    enemy.x = enemy.x + enemyMoveDistanceX
    enemy.y = enemy.y + enemyMoveDistanceY
    ]]

    enemy.x = enemy.x + vx
    enemy.y = enemy.y + vy
    
    if enemy.x > _W or enemy.x < 0 then 
        vx = vx*-1
    end

    if enemy.y > _H - _H*20/100 or enemy.y < 0 then 
        vy = vy*-1
    end

    if scoreHero > 0 then
        print("entra")
        Runtime:removeEventListener( "enterFrame", frameUpdates )
        Runtime:removeEventListener( "collision", onGlobalCollision )
        Runtime:removeEventListener( "enterFrame", stickMove )  
        timer.cancel( timer1 )
        timer.cancel( timer2 )
        composer.removeScene( "warsingle" )
        composer.gotoScene("menu")
        physics.removeBody( gold )
        physics.removeBody( fire )
        physics.removeBody( hero )
        physics.removeBody( enemy )
    end
    
end

local function stickMove( event )
        
    -- MOVE THE SHIP
    MyStick:move(hero, normalSpeed, false) -- se a opção for true o objeto se move com o joystick

    -- -- SHOW STICK INFO
    -- Text.text = "ANGLE = "..MyStick:getAngle().."   DIST = "..math.ceil(MyStick:getDistance()).."   PERCENT = "..math.ceil(MyStick:getPercent()*100).."%"
    
    --print("MyStick:getAngle = "..MyStick:getAngle())
    --print("MyStick:getDistance = "..MyStick:getDistance())
    -- print("MyStick:getPercent = "..MyStick:getPercent()*100)
    --print("POSICAO X / Y  " ..hero.x,hero.y)
    
    angle = MyStick:getAngle()
    moving = MyStick:getMoving()

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
    
    --Change the sequence only if another sequence isn't still playing 
    if(not (seq == hero.sequence) and moving) then -- and not attacking
        hero:setSequence(seq)
    end
    
    --If the analog stick is moving, animate the sprite
    if(moving) then 
        hero:play() 
    end
    
end

function scene:create( event )

    localGroup = self.view

    -- local hero
    -- local localGroup = display.newGroup() -- remember this for farther down in the code
    motionx = 0; -- Variable used to move character along x axis
    motiony = 0; -- Variable used to move character along y axis
     
    -- CREATE ANALOG STICK
    if MyStick==nil then
        MyStick = StickLib.NewStick( 
            {
            x             = rightMarg-150,
            y             = bottomMarg-150,
            thumbSize     = 32,
            borderSize    = 32, 
            snapBackSpeed = .2, 
            R             = 255,
            G             = 255,
            B             = 255
            } )
    end

     -- MAIN LOOP
    ----------------------------------------------------------------

    Runtime:addEventListener( "enterFrame", stickMove )    

    bg = display.newImage(localGroup, "images/background.png")
    bg.x = cx
    bg.y = cy

    -- Display the new sprite at the coordinates passed
    hero = display.newSprite(localGroup, mySheet, sequenceData)
    hero:setSequence("forward")
    hero.id = "hero"
    hero.x = cx
    hero.y = cy
    physics.addBody( hero, { density=0.5, friction=0, bounce=0.2, radius=70 } )

    -- Display the new sprite at the coordinates passed
    enemy = display.newSprite(localGroup, mySheet, sequenceData)
    enemy:setSequence("forward")
    enemy.id = "enemy"
    enemy.x = cx
    enemy.y = cy - 500
    physics.addBody( enemy, { density=0.5, friction=0, bounce=0.2, radius=70 } )

    castle = display.newRect(localGroup, leftMarg, bottomMarg, 350, 350 )
    physics.addBody( castle, "static")
    castle.id = "castle1"
    castle.collision = onCastleCollision
    castle:addEventListener( "collision", castle )

    score = display.newText( localGroup, scoreHero, leftMarg + 30, bottomMarg - 30 )
    score:setFillColor( black )

end-- "scene:create()"

function scene:show( event )

    localGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).

    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.

        Runtime:addEventListener( "enterFrame", frameUpdates )
        Runtime:addEventListener( "collision", onGlobalCollision )

        timer1 = timer.performWithDelay( 5000, 
            function () 
                while (checkPos()==false) do 
                    checkPos() 
                end 
                positionGold(randx, randy) 
                print(randx.."   "..randy)
            end
        , 0)

        timer2 = timer.performWithDelay( 1000, shotFire, 0 )

    end-- "scene:show()"
end-- "scene:show()"

function scene:hide( event )

    localGroup = self.view
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

    localGroup = self.view

    -- Called prior to the removal of scene's view ("localGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.


end-- "scene:destroy()"

-- ------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene