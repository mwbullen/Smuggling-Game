local widget = require "widget"

local path = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open(path)


local composer = require( "composer" )
local scene = composer.newScene()


local Job
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

   JobId = event.params.Jobid
   -- print("jobid")
   -- print(JobId)
   Job = getJobInfo(JobId)
   local cityText = display.newText(sceneGroup,Job.destination, display.contentWidth/2, 50, nil, 40)
   cityText:setFillColor(0)
   
   -- local backBtn = display.newText( "Back", 0, 350, native.systemFont, 32 )
   -- backBtn:addEventListener("tap", backBtnClick)
   -- backBtn.x = 75
   -- backBtn:setFillColor(0)
   -- sceneGroup:insert(backBtn)

   -- local agentInfoTxt = display.newText({
   --    text = 
   --    })

   local securityLevel = display.newText({
      text = "Security level:  "..Job.security,            
      x = display.contentWidth*.5,
      y = 100,
      parent = sceneGroup,
      font = nil,
      fontSize = 25
    })
   securityLevel:setFillColor(0)
   sceneGroup:insert(securityLevel)

   local agentNameTxt = display.newText(Job.AgentName, 10, 150, nil, 18)
   agentNameTxt.anchorX =0
   agentNameTxt:setFillColor(0)
   sceneGroup:insert(agentNameTxt)

   local agentHeatText = display.newText(Job.AgentHeat.."/"..Job.AgentMaxHeat, display.contentWidth-10, 150, nil, 16)
   agentHeatText.anchorX = 1
   agentHeatText:setFillColor(.75,0,0)
   sceneGroup:insert(agentHeatText)


   -- showSecurityRoll()
   
   local securityLbl = display.newText("Security check", 10, 175, nil, 18)
   securityLbl.anchorX =0
   securityLbl:setFillColor(.75,0,0)
   sceneGroup:insert(securityLbl)

   local securityRoll = getRandomSecurityscore()

   local securityRolltxt = display.newText({
      text = securityRoll,
      x = display.contentWidth-40,      
      y= 175, 
      parent = sceneGroup,
      font = nil,
      fontSize = 16
      })
   securityRolltxt.anchorX =1
   securityRolltxt:setFillColor(.75,0,0)         
     
   local resultTxt = display.newText("Result", display.contentWidth/2, 250, nil, 32)
   sceneGroup:insert(resultTxt)
   
   local heatTotal = Job.AgentHeat + securityRoll

   if heatTotal > Job.AgentMaxHeat then
      --Busted!
      resultTxt.text = "Busted!"
      resultTxt:setFillColor(.75,0,0)

      deleteJob(JobId)
      deleteAgent(Job.AgentId)
   else
      --Passed!
      resultTxt.text = "Passed Security!"
      resultTxt:setFillColor(0,.75,0) 

      print(Job.AgentId)
      setHeatforAgent(Job.AgentId, heatTotal)

      completeShipment(JobId)     
   end

   -- local doneGroup
   -- local doneRect = display.newRect(20, display.contentWidth/2, 350, 100, 24)
   -- doneRect:setStrokeColor(.5,.5,.5)
   
   local doneBtn = display.newText("Done", display.contentWidth/2, 350, nil, 24)
   doneBtn:setFillColor(0)
   doneBtn:addEventListener("tap", confirmBtnClick)
   sceneGroup:insert(doneBtn)
end

function showSecurityRoll()

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

   composer.removeScene("popup_enterCustoms", true)
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