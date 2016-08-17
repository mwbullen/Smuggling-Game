-----------------------------------------------------------------------------------------
--
-- scene_operatives.lua
--
-----------------------------------------------------------------------------------------


local widget = require "widget"
require("functions")

local path = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open(path)

local composer = require( "composer" )
local scene = composer.newScene()
local tableView

local updateTimer

local function selectJobRow(event)	
	--Confirm ready for customs, if so complete run and get paid
	-- local secondsRemaining = jobs[event.row.index].eta - os.time()

	local agentJob = getJobInfoforAgent(agents[event.row.index].id)
	-- print("Remaining time")
	-- print (secondsRemaining)

	if agentJob == nil then
	else
		local secondsRemaining = agentJob.eta - os.time()
		if secondsRemaining <= 0 then

			--Launch security form
		 	local options = {params={Jobid = agentJob.id}}
		 	-- print(options.params.Jobid)
		 	composer.gotoScene("popup_enterCustoms", options)				
			
		end
	end
end

local function updateJobProgress()
	-- for i=1, #agents, 1 do		
	for i =1, tableView:getNumRows(), 1 do
		-- print ( tableView:getRowAtIndex(i).params.agentid)
		local tmp_agentId = tableView:getRowAtIndex(i).params.agentid

		local agentJob = getJobInfoforAgent(tmp_agentId);
		--get remainingTime for job for agent = tmp_agentId
		--update progressview child of row?

		local progressView = tableView:getRowAtIndex(i).params[1]
		local readyForCustomsbtn =tableView:getRowAtIndex(i).params[2]
		local remainingTimeTxt =tableView:getRowAtIndex(i).params[3]

		if agentJob == nil then
		else
			local secondsRemaining = agentJob.eta - os.time()		
			local totalJobSeconds = agentJob.eta - agentJob.starttime 
	  		local elapsedSeconds = totalJobSeconds - secondsRemaining
	    	local percentComplete = elapsedSeconds / totalJobSeconds
	          
	        -- local progressView = tableView:getRowAtIndex(i)[10];

	        -- for k, v in pairs( tableView:getRowAtIndex(i).params) do
	        -- 		print("Tablevalue")
	        -- 		print (k, v)
	        -- end
	        -- print("update")
	        if secondsRemaining > 0 then
		        readyForCustomsbtn.isVisible = false
		        -- print ("progressview")
		        -- print (tableView:getRowAtIndex(i).params)
		        progressView.isVisible = true
		        progressView:setProgress(percentComplete)	

		        remainingTimeTxt.text = string.format("%4.2f",(secondsRemaining/60))
		        remainingTimeTxt.isVisible = true
		    	-- tableView:getRowAtIndex(i)[10]progressView:setProgress(percentComplete)	
		    	-- jobProgress:setProgress(percentComplete)	
		    	else
		    	progressView.isVisible = false
		    	readyForCustomsbtn.isVisible = true
		    	-- local jobReadyMsg = display.newText(tableView:getRowAtIndex(i), "Ready for Customs",tableView:getRowAtIndex(i).contentWidth/2, 50, nil, 15) 
         		-- jobReadyMsg:setFillColor(.0,.6,.0)
	    	end
    	end 
	end
	

	
end

-----------

function scene:create( event )
	local sceneGroup = self.view
	
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	-- create a white background to fill screen
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg.anchorX = 0
	bg.anchorY = 0
	bg:setFillColor( 1 )	-- white
	
	-- create some text
	local title = display.newText( "Operatives", 0, 0, native.systemFont, 32 )
	title:setFillColor( 0 )	-- black
	title.x = display.contentWidth * 0.5
	title.y = 125
	
	-- local newTextParams = { text = "Show Operatives Here", 
	-- 						x = 0, y = 0, 
	-- 						width = 310, height = 310, 
	-- 						font = native.systemFont, fontSize = 14, 
	-- 						align = "center" }
	-- local summary = display.newText( newTextParams )
	-- summary:setFillColor( 0 ) -- black
	-- summary.x = display.contentWidth * 0.5 + 10
	-- summary.y = title.y + 215
	
	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( bg )
	sceneGroup:insert( title )
	-- sceneGroup:insert( summary )
end

-- local agents = {}

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		-- print("will show")
	elseif phase == "did" then
		-- print("did show")
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	
		tableView = getAgentTableView(false, selectJobRow, nil)
		sceneGroup:insert(tableView)

		updateJobProgress()
		updateTimer = timer.performWithDelay(1000,updateJobProgress, 0)

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
	
			-- print("will hide")
			timer.cancel(updateTimer)
	elseif phase == "did" then
			-- print("did hide")
			timer.cancel(updateTimer)
			-- composer.removeScene("scene_operatives", true)
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	timer.cancel(updateTimer)
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
