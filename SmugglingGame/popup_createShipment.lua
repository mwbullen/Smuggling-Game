local widget = require "widget"

local path = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open(path)


local composer = require( "composer" )
local scene = composer.newScene()

local openContractID
local agentId
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------


local function backBtnClick(event)          
   print"create shipment back"
      composer.gotoScene("scene_blackMarket")      
end

local function confirmBtnClick(event) 
      --Create new shipment
      createShipment(openContractID, agentId)
      composer.gotoScene("scene_active")

      
end

local function selectAgentClick(event)
   --show agent select scene
   local options = {params = {openContractID = openContractID}}
   composer.gotoScene("popup_agentSelect", options)
end

-- "scene:create()"
function scene:create( event )

   local sceneGroup = self.view

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.

   -- local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
   -- bg.anchorX = 0
   -- bg.anchorY = 0
   -- -- bg:setFillColor( 1 )
   -- sceneGroup:insert(bg)
   openContractID = event.params.openContractID
   agentId = event.params.agentId

   for row in db:nrows("select * from opencontracts where openContractID = "..openContractID) do
         print "record found"
         local openContract = 
            {  id = row.OpenContractID,
               origin = row.Origin,
               destination = row.Destination,
               value= row.Value,
               destinationRegion = row.DestinationRegion,
               durationHours = row.Duration
            }
      
      
      local tripItintxt = display.newText(openContract.origin.." to "..openContract.destination, 150, 20, native.systemFont, 32)
      sceneGroup:insert(tripItintxt)

      local tripTimetxt = display.newText("Time: "..openContract.durationHours.."h", 150, 60,native.systemFont, 16)
      sceneGroup:insert(tripTimetxt)      

      
      local agentSelecttext = "Select Agent"

      
      if agentId == nil then        
      else
         agentSelecttext = getAgentName(agentId)

         local confirmBtm = display.newText( "Do It", 0, 400, native.systemFont, 32 )
      confirmBtm:addEventListener("tap", confirmBtnClick)
      confirmBtm.x = 200
      sceneGroup:insert(confirmBtm)

      end

      local selectAgent = display.newText(agentSelecttext, 150, 150, native.systemFont, 24 )
      

      sceneGroup:insert(selectAgent)    
      selectAgent:addEventListener("tap", selectAgentClick)  

      local backBtn = display.newText( "Back", 0, 400, native.systemFont, 32 )
      backBtn:addEventListener("tap", backBtnClick)
      backBtn.x = 75
      sceneGroup:insert(backBtn)

      
      end
end

-- "scene:show()"
function scene:show( event )
   
   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
           
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.

     
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   -- composer.gotoScene(event.parent)

   composer.removeScene("popup_createShipment", true)
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
      -- sceneGroup:removeSelf()
      -- display.remove(sceneGroup)
   end
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene