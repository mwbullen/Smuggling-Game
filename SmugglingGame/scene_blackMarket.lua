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
	
	local newTextParams = { text = "Show Available Jobs, Agents for Hire, Passports for Sale", 
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

local openContracts = {}

local function displayMarketRow (event)
	local row = event.row
	
	-- row:setFillColor(144,195,212)

	-- Route
	local tripDesc = display.newText(row, openContracts[row.index].origin.." to "..openContracts[row.index].destination,10, 0 ,nil ,20)
	tripDesc:setFillColor( 0)
	tripDesc.anchorX = 0;
	tripDesc.y= 25

	--Payment
	local contractValueTxt = display.newText(row, "$"..openContracts[row.index].value, 300, 55, nil, 16)
	contractValueTxt:setFillColor(0.133333, 0.545098 ,0.133333)
	contractValueTxt.anchorX = row.contentWidth
	

	--Risk
	local riskTxt = display.newText(row,  openContracts[row.index].risk, 15, 55, nil, 14)
	riskTxt.anchorX = 0
	riskTxt:setFillColor(0.545098, 0, 0)

	--Time
	local contractTime = display.newText(row, openContracts[row.index].durationHours.."h", 150, 55, nil, 14)
	contractTime:setFillColor(0.545098, 0, 0)
	contractTime.anchorX = 0
	

end

function selectMarketRow(event) 
	-- local row = event.row
	-- composer.showOverlay( "popup_createShipment")

	local options = {params = {openContractID = openContracts[event.row.index].id}}
	composer.gotoScene("popup_createShipment", options)
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
		deleteExpiredContracts()
		createNewContracts()

		local tableView = widget.newTableView
		{
			-- height=300,
			onRowRender = displayMarketRow,
			onRowTouch = selectMarketRow
			-- noLines = true			
		}
		sceneGroup:insert(tableView)

		openContracts = getAvailableContracts()

		for i=1, #openContracts, 1 do
			tableView:insertRow{ topPadding=10, bottomPadding=10, rowHeight = 70, rowColor = {default = {1, 0.980392 ,0.803922}}}
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
		composer.removeScene("scene_blackMarket", true)
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
