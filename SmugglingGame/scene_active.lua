-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------
require("functions")
local widget = require "widget"
local composer = require( "composer" )

local scene = composer.newScene()

local jobs = {}

local tableView

local function displayJobRow(event)
	local row = event.row

	local agentNameTxt = display.newText(row, jobs[row.index].AgentName, 10, 20, nil, mainItemFontSize)
	agentNameTxt.anchorX =0 
	agentNameTxt:setFillColor(0)


	local agentHeat = display.newText(row, jobs[row.index].agentHeat.."/"..jobs[row.index].agentMaxHeat, display.contentWidth*.9, 20, nil, 16)
	agentHeat:setFillColor(.75,0,0)

	local secondsRemaining = jobs[row.index].eta - os.time()
	if secondsRemaining > 0 then
		local jobProgress = widget.newProgressView({left = 20, top = 40, width = 250, isAnimated = true })
		row:insert(jobProgress)		
		jobs[row.index].progressView = jobProgress

		local remainingTimeTxt = display.newText(row,math.round(secondsRemaining/60,2.2).." min", display.contentWidth - 30, 45, nil, 12)
		jobs[row.index].remainingTimeTxt = remainingTimeTxt
		remainingTimeTxt:setFillColor(0)

		local originTxt = display.newText(row,jobs[row.index].origin, 20, 55, nil, 12)
		originTxt:setFillColor(0)
		originTxt.anchorX =0

		local destTxt = display.newText(row,jobs[row.index].destination, 270, 55, nil, 12)
		destTxt:setFillColor(0)
		destTxt.anchorX =1
	
	else
		local jobReadyMsg = display.newText(row, "Ready for Customs",row.contentWidth/2, 50, nil, 15)	
		jobReadyMsg:setFillColor(.0,.6,.0)

	end	
	
end

local function updateJobProgress()
	for i=1, #jobs, 1 do		
		local tripProgress = jobs[i].progressView
		local secondsRemaining = jobs[i].eta - os.time()

		if secondsRemaining > 0 then
			local totalJobSeconds = jobs[i].eta - jobs[i].starttime 
			local elapsedSeconds = totalJobSeconds - secondsRemaining
			local percentComplete = elapsedSeconds / totalJobSeconds
			
			tripProgress:setProgress(percentComplete)

			jobs[i].remainingTimeTxt.text = math.round(secondsRemaining/60,2.2).." min"
			-- jobs[i].remainingTimeTxt.text:setFillColor(0)
		else
			if  tripProgress == nil then else tripProgress.isVisible = false end
		end
	end

	timer.performWithDelay(1000,updateJobProgress)
end

local function selectJobRow(event)	

	--Launch security form
	 local options = {params={Jobid = jobs[event.row.index].Jobid}}
	 print(options.params.Jobid)
	 composer.gotoScene("popup_enterCustoms", options)

	--Confirm ready for customs, if so complete run and get paid
	local secondsRemaining = jobs[event.row.index].eta - os.time()
	if secondsRemaining <= 0 then
				
		-- completeShipment(jobs[event.row.index].Jobid)	
		-- updateStatusBar()
		-- composer.gotoScene("scene_active")
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
		
	
	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( bg )
	
	tableView = widget.newTableView
		{		 height=display.contentHeight -100,
			onRowRender = displayJobRow,
			onRowTouch = selectJobRow,
			 top = menuBarHeight *.5
			-- height = 300
			-- noLines = true			
		}
	sceneGroup:insert(tableView)

	jobs = getAllActiveJobs()

	for index, value in ipairs(jobs) do
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

			updateJobProgress()
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