native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
display.setStatusBar( display.HiddenStatusBar )


local physics = require ("physics")
physics.start()
composer = require "composer"
json = require "json" 
widget = require "widget" 


cx, cy = display.contentCenterX, display.contentCenterY
_W, _H  = display.contentWidth, display.contentHeight
leftMarg, rightMarg = display.screenOriginX, display.contentWidth - display.screenOriginX
topMarg, bottomMarg = display.screenOriginY, display.contentHeight - display.screenOriginY


composer.gotoScene( "war")