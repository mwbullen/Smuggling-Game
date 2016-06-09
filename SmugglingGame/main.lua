-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require "sqlite3"
-- show default status bar (iOS)
display.setStatusBar( display.DefaultStatusBar )

-- include Corona's "widget" library
local widget = require "widget"
local composer = require "composer"


local path = system.pathForFile("data.db", system.DocumentsDirectory)
 db = sqlite3.open(path)

print (path)
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
-- Utility functions

function getAgentName(lookup_agentId)
   if lookup_agentId == nil then
         return "Test"
   end

   for row in db:nrows("select AgentName from Agents where AgentId = "..lookup_agentId) do      
      return row.AgentName
   end   
end

function createShipment(openContractID, agentId)
	--insert into Jobs

	local insertStr = "insert into Jobs(agentId, origin, destination, value, eta, DestinationRegion, starttime) select "..agentId..", origin, destination, value, (duration*3600) +"..os.time()..", DestinationRegion, "..os.time().." from OpenContracts where OpenContractid = "..openContractID

	db:exec(insertStr)

	print (insertStr)
	
	--delete from openContracts
	local deleteStr = "delete from openContracts where openContractID = "..openContractID
	db:exec(deleteStr)

	print (deleteStr)
end

function copyFile( srcName, srcPath, dstName, dstPath, overwrite )

    local results = false

    local fileExists = doesFileExist( srcName, srcPath )
    if ( fileExists == false ) then
        return nil  -- nil = Source file not found
    end

    -- Check to see if destination file already exists
    if not ( overwrite ) then
        if ( fileLib.doesFileExist( dstName, dstPath ) ) then
            return 1  -- 1 = File already exists (don't overwrite)
        end
    end

    -- Copy the source file to the destination file
    local rFilePath = system.pathForFile( srcName, srcPath )
    local wFilePath = system.pathForFile( dstName, dstPath )

    local rfh = io.open( rFilePath, "rb" )
    local wfh, errorString = io.open( wFilePath, "wb" )

    if not ( wfh ) then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Read the file and write to the destination directory
        local data = rfh:read( "*a" )
        if not ( data ) then
            print( "Read error!" )
            return false
        else
            if not ( wfh:write( data ) ) then
                print( "Write error!" )
                return false
            end
        end
    end

    results = 2  -- 2 = File copied successfully!

    -- Close file handles
    rfh:close()
    wfh:close()

    return results
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
local tabBar = widget.newTabBar{
	top = display.contentHeight - 50,	-- 50 is default height for tabBar widget
	buttons = tabButtons
}

onFirstView()	-- invoke first tab button's onPress event manually

