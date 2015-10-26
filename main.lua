native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
display.setStatusBar( display.HiddenStatusBar )

composer = require "composer"
json = require "json" 
widget = require "widget" 

cx, cy = display.contentCenterX, display.contentCenterY
_W, _H  = display.contentWidth, display.contentHeight
leftMarg, rightMarg = display.screenOriginX, display.contentWidth - display.screenOriginX
topMarg, bottomMarg = display.screenOriginY, display.contentHeight - display.screenOriginY

function saveTable(t, filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end

function loadTable(filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
         local contents = file:read( "*a" )
         myTable = json.decode( contents )
         io.close( file )
         return myTable 
    end
    return nil
end

local t = loadTable( "settings.json" )
	
	if t == nil then 
	    local settings = {}
	    settings.session = 0
	    saveTable(settings, "settings.json")
	end

function onSystemEvent( event )
    if (event.type=="applicationSuspend") then
        native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
    end
end

Runtime:addEventListener( "system", onSystemEvent )

--Declare and set up Sprite Image Sheet and sequence data
spriteOptions = {   
    height = 256, 
    width = 256, 
    numFrames = 273, 
    sheetContentWidth = 3328, 
    sheetContentHeight = 5376 
}
mySheet = graphics.newImageSheet("images/rectSmall.png", spriteOptions) 
sequenceData = {
    {name = "forward", frames={105,106,107,108,109,110,111,112}, time = 500, loopCount = 1},
    {name = "right", frames={144,145,146,147,148,149,150,151,152}, time = 500, loopCount = 1}, 
    {name = "back", frames= {131,132,133,134,135,136,137,138,139}, time = 500, loopCount = 1}, 
    {name = "left", frames={118,119,120,121,122,123,124,125,126}, time = 500, loopCount = 1},
    {name = "attackForward", frames={157,158,159,160,161,162,157}, time = 400, loopCount = 1},
    {name = "attackRight", frames={196,197,198,199,200,201,196}, time = 400, loopCount = 1},
    {name = "attackBack", frames={183,184,185,186,187,188,183}, time = 400, loopCount = 1},
    {name = "attackLeft", frames={170,171,172,173,174,175,170}, time = 400, loopCount = 1},
    {name = "death", frames={261,262,263,264,265,266}, time = 500, loopCount = 1}
}   

--composer.gotoScene("war")
composer.gotoScene("menu")