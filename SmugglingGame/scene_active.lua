-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------
local widget = require "widget"
local composer = require( "composer" )

local scene = composer.newScene()

local jobs = {}

local tableView = nil

local function displayJobRow(event)
	local row = event.row

	local jobDesc = display.newText(row,jobs[row.index].origin.." to ".. jobs[row.index].destination,row.contentWidth/2, 0 ,nil ,20)
	jobDesc:setFillColor( 0)	
	jobDesc.y= 25
	-- sceneGroup:insert(jobDesc)

	

	local secondsRemaining = jobs[row.index].eta - os.time()
	if secondsRemaining > 0 then
		local jobProgress = widget.newProgressView({left = 10, top = 50, width = 300 })
		row:insert(jobProgress)

		local totalJobSeconds = jobs[row.index].eta - jobs[row.index].starttime 
		local elapsedSeconds = totalJobSeconds - secondsRemaining
		local percentComplete = elapsedSeconds / totalJobSeconds

		jobProgress:setProgress(percentComplete)
	else
		local jobReadyMsg = display.newText(row, "Ready for Customs",row.contentWidth/2, 50, nil, 15)	
			jobReadyMsg:setFillColor(.0,.6,.0)

	end
	
	
	 -- sceneGroup:insert(jobProgress)

	--add progress bar
	--calculate time remaining
end

local function updateJobProgress()
	
end

local function selectJobRow(event)	
	for i=1,tableView:getNumRows(), 1
	do
		
	end
end

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
	
	jobs = {}
	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( bg )
	
	 tableView = widget.newTableView
		{
			-- height=300,
			onRowRender = displayJobRow,
			onRowTouch = selectJobRow,
			-- top = 45
			-- noLines = true			
		}
		sceneGroup:insert(tableView)

		for row in db:nrows("select Jobid, AgentID, Complete,  (select Name from Cities where CityID = Origin) Origin, (select Name from Cities where CityID = Destination) Destination, Value, ETA, StartTime from Jobs")	do
			jobs[#jobs+1] = 
			{
				id= row.Jobid,
				agentId = row.AgentId,
				Complete = row.Complete,
				origin = row.Origin,
				destination = row.Destination,
				value = row.Value,
				eta = row.ETA,				
				starttime = row.StartTime
			}
			
			tableView:insertRow{ topPadding=10, bottomPadding=10, rowHeight = 70, rowColor = {default = {1, 0.980392 ,0.803922}}}
		end

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

		composer.removeScene("scene_active", true)
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