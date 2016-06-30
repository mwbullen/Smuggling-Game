-----------------------------------------------------------------------------------------
--
-- scene_game.lua
--
-----------------------------------------------------------------------------------------
require "sqlite3"
-- require "functions"
require "io"
-- -- show default status bar (iOS)
display.setStatusBar( display.DefaultStatusBar )


-- -- include Corona's "widget" library
local widget = require "widget"
local composer = require "composer"

local statusBarArea

local dbPath = system.pathForFile("data.db", system.DocumentsDirectory)
 

function doesDBExist()
  local dbFile = io.open(dbPath, "r") 

  if (dbFile ) then
  		return true
  else 
  		return false
  end
end

-- event listeners for tab buttons:
local function onFirstView( event )
	composer.gotoScene( "scene_active" )
end

local function onSecondView( event )
	composer.gotoScene( "scene_operatives" )
end

local function onThirdView( event )
	
end

local function onFourthView( event )
	composer.showOverlay( "scene_blackMarket",{isModal = true} )
end
--------------

local cashTxt
function updateStatusBar() 
   cashTxt.text = "$ "..getCurrentCash()
end

-----------------
-- create a tabBar widget with two buttons at the bottom of the screen

-- table to setup buttons
local tabButtons = {
	{ label="Shipments", defaultFile="icons/icon1.png", overFile="icons/icon1-down.png", width = 32, height = 32, onPress=onFirstView, selected=true },
	{ label="Agents", defaultFile="icons/icon2.png", overFile="icons/icon2-down.png", width = 32, height = 32, onPress=onSecondView },
	-- { label="Passports", defaultFile="icons/icon2.png", overFile="icons/icon2-down.png", width = 32, height = 32, onPress=onThirdView },
	{ label="Black Market", defaultFile="icons/icon2.png", overFile="icons/icon2-down.png", width = 32, height = 32, onPress=onFourthView }
}

-- create the actual tabBar widget

print(dbPath)
print (doesDBExist())
if doesDBExist() == true  then
	require "functions"

	local tabBar = widget.newTabBar{
	top = display.contentHeight - 50,	-- 50 is default height for tabBar widget
	buttons = tabButtons
}


	db = sqlite3.open(dbPath)

	statusBarGroup = display.newGroup()

	statusBarArea = display.newRect(0, display.contentHeight - 65, display.contentWidth, 35)
	statusBarArea.anchorX= 0
	statusBarArea:setFillColor(.4,.4,.4)
	statusBarGroup:insert(statusBarArea)


	cashTxt = display.newText( "$ "..getCurrentCash(),display.contentWidth-20, display.contentHeight - 65 , nil, 24)
	cashTxt.anchorX = 1
	cashTxt:setFillColor(1)
	statusBarGroup:insert(cashTxt)

	onFirstView()	-- invoke first tab button's onPress event manually

	updateStatusBar()
else
	 composer.showOverlay("popup_menu")		
end

