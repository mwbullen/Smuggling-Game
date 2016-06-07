-----------------------------------------------------------------------------------------
--
-- scene_operatives.lua
--
-----------------------------------------------------------------------------------------


local widget = require "widget"

local path = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open(path)

local composer = require( "composer" )
local scene = composer.newScene()

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
	
	local newTextParams = { text = "Show Operatives Here", 
							x = 0, y = 0, 
							width = 310, height = 310, 
							font = native.systemFont, fontSize = 14, 
							align = "center" }
	local summary = display.newText( newTextParams )
	summary:setFillColor( 0 ) -- black
	summary.x = display.contentWidth * 0.5 + 10
	summary.y = title.y + 215
	
	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( bg )
	sceneGroup:insert( title )
	sceneGroup:insert( summary )
end

local agents = {}

local function displayAgentRow (event)
	local row = event.row
	
	local agentNameTxt = display.newText(row, agents[row.index].name,row.contentWidth*.6, 0 ,nil ,20)
	agentNameTxt:setFillColor(0);	
	agentNameTxt.y= 20

	local agentLevelTxt = display.newText(row, agents[row.index].level,row.contentWidth*.3, 0 ,nil ,14)
	agentLevelTxt:setFillColor(0)
	agentLevelTxt.anchorX = 0;
	agentLevelTxt.y= 40
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

		
		local tableView = widget.newTableView
		{
			height=300,
			onRowRender = displayAgentRow
		}
		sceneGroup:insert(tableView)

		for row in db:nrows("select * from Agents where Owned = 1")	do
			agents[#agents+1] = 
			{
				id = row.AgentId,
				name = row.AgentName,
				heat = row.Heat,
				level= row.Level,
				experience = row.Experience
			}

			
			tableView:insertRow{ topPadding=10, bottomPadding=10, rowHeight = 70, rowColor = {default = {.678431, 0.847059,0.901961}}}
		end


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
