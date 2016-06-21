local widget = require "widget"

local path = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open(path)


local composer = require( "composer" )
local scene = composer.newScene()


local Job = {}
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

local function backBtnClick(event)          
   print"create shipment back"
      composer.gotoScene("scene_active")      
end

local function getRandomSecurityscore()
   return math.random(1,100)
end

-- "scene:create()"
function scene:create( event )

   local sceneGroup = self.view
 
      local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
   bg.anchorX = 0
   bg.anchorY = 0
   bg:setFillColor( 1, 0.980392 ,0.803922) 
   sceneGroup:insert(bg)
   JobId = event.params.JobId
   
   local selectStr = "select Jobid, AgentID, (select AgentName from Agents where AgentId = AgentID) AgentName, Complete,  (select Name from Cities where CityID = Origin) Origin, (select Name from Cities where CityID = Destination) Destination, Value, ETA, StartTime, (select Security from Cities where CityID = Destination) security, (select heat from Agents where Agentid = AgentID) agentHeat from Jobs"

      for row in db:nrows(selectStr)   do
         Job = 
         {
            id= row.Jobid,
            agentId = row.AgentId,
            AgentName = AgentName,
            Complete = row.Complete,
            origin = row.Origin,
            destination = row.Destination,
            value = row.Value,
            eta = row.ETA,          
            starttime = row.StartTime, 
            security = row.security
         }
   
         local cityText = display.newText(sceneGroup,Job.destination, display.contentWidth/2, 30, nil, 40)
         cityText:setFillColor(0)
         
         local backBtn = display.newText( "Back", 0, 400, native.systemFont, 32 )
         backBtn:addEventListener("tap", backBtnClick)
         backBtn.x = 75
         backBtn:setFillColor(0)
         sceneGroup:insert(backBtn)

         -- local agentInfoTxt = display.newText({
         --    text = 
         --    })

         local securityLevel = display.newText({
            text = "Security level:  "..Job.security,            
            x = display.contentWidth*.5,
            y = 75,
            parent = sceneGroup,
            font = nil,
            fontSize = 25
          })
         securityLevel:setFillColor(0)
         sceneGroup:insert(securityLevel)


         local securityRoll = getRandomSecurityscore()

         local securityRolltxt = display.newText({
            text = "Current Security:  "..securityRoll,
            x = display.contentWidth*.5,
            y= 125, 
            parent = sceneGroup,
            font = nil,
            fontSize = 25
            })

         securityRolltxt:setFillColor(.75,0,0)         
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