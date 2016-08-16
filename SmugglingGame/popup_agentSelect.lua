-----------------------------------------------------------------------------------------
--
-- scene_operatives.lua
--
-----------------------------------------------------------------------------------------
require("functions")

local widget = require "widget"

local path = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open(path)

local composer = require( "composer" )
local scene = composer.newScene()

-- local agents = {}
local openContractID

local function backAgentSelBtnClick(event)       
	 local options = {params = {openContractID = openContractID}}
     composer.gotoScene("popup_createShipment",options)      
end

local function selectAgentRow(event) 
	-- local row = event.row
	-- composer.showOverlay( "popup_createShipment")
	
	local options = {params = {agentId = agents[event.row.index].id, openContractID = openContractID}}
	composer.gotoScene("popup_createShipment", options)
end

function scene:create( event )
	local sceneGroup = self.view
	
	local backBtn = display.newText( "Back", 0, 350, native.systemFont, 32 )
    backBtn:addEventListener("tap", backAgentSelBtnClick)
    backBtn.x = 75
    sceneGroup:insert(backBtn)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.


		openContractID = event.params.openContractID
		local jobSourceRegionid = getsSourceRegionForContract(openContractID)

		tableView = getAgentTableView(true, selectAgentRow, jobSourceRegionid)
		-- tableView.onRowTouch = selectAgentRow
		sceneGroup:insert(tableView)

	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
