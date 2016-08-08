require "sqlite3"
require "settings"
require "loadAssets"

local  dbPath = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open(dbPath)

local contractLimit = 6

local widget = require "widget"

----------System operations

--------Display objects


local function displayAgentRow (event)
  local row = event.row
  
  local agentNameTxt = display.newText(row, agents[row.index].name,80, 25 ,nil ,mainItemFontSize)
  agentNameTxt:setFillColor(0); 
  agentNameTxt.anchorX = 0
  
  local agentLevelTxt = display.newText(row, "lvl "..agents[row.index].level,80, 50 ,nil ,12)
  agentLevelTxt:setFillColor(0)
  agentLevelTxt.anchorX = 0;
  
  local agentStatusTxt = display.newText(row,"", row.contentWidth/2, 50, nil, 12)
  agentStatusTxt:setFillColor(0,.5,0);  

  local agentLocation = getLocationforAgent(agents[row.index].id)

  local agentLocationTxt = display.newText(row,agentLocation.RegionName, display.contentWidth - 10, 50, nil, 14)
  agentLocationTxt.anchorX = 1
  agentLocationTxt:setFillColor(0,0,.5)

  local agentHeatTxt = display.newText(row, agents[row.index].heat, display.contentWidth-10, 25, nil, 16)
  agentHeatTxt.anchorX = 1
  agentHeatTxt:setFillColor(.75,0,0)
  
  local agentPortaitIndex = getAgentPortraitIndex(agents[row.index].id)

  local agentPortrait = display.newImage(row, portaitSheet,agentPortaitIndex,0,0)
  agentPortrait.width= 65
  agentPortrait.height  = 65
  agentPortrait.anchorX = 0
  agentPortrait.anchorY = 0

end


function getAgentTableView() 
    local tableView = widget.newTableView
    {
      onRowRender = displayAgentRow,
      top = menuBarHeight *.5,
      height=display.contentHeight -100
    }

    agents = getAllOwnedAgents()

    -- for row in db:nrows("select * from Agents where Owned = 1")  do
    for index, value in ipairs (agents) do
      tableView:insertRow{ topPadding=10, bottomPadding=10, rowHeight = 70, rowColor = {default = {.678431, 0.847059,0.901961}}}
    end

    return tableView
end



--------Art operations

function getPortrait(portraitIndex)
  return display.newImage(portraitSheet, portraitIndex)
end

function getAgentPortraitIndex(agentID)
  local selectStr = "SELECT PORTRAIT_INDEX FROM AGENTS WHERE AGENTID = "..agentID

  for row in db:nrows(selectStr) do
    return row.PORTRAIT_INDEX
  end
end

---------New Game

function createAgents()
   local  dbPath = system.pathForFile("data.db", system.DocumentsDirectory)
   local db = sqlite3.open(dbPath)

     local randomNames = {"Ghost", "Iceman", "Nighthawk", "Red Fox"}

  
    local InsertStr = "INSERT INTO AGENTS (AGENTNAME) VALUES ('Ghost')"
    print (InsertStr)
    db:exec(InsertStr)
  
end


----------Money operations
function getCurrentCash() 	
	for row in db:nrows("SELECT CURRENTMONEY FROM PLAYERSTATUS") do
			return row.CURRENTMONEY
	end
end

-- function addCash(newCash )
-- 	db:exec("update PlayerStatus set CurrentMoney = CurrentMoney +"..newCash)
-- end

----------Shipment operations

function completeShipment(Jobid)
	--get cash value of shipment, add to current chash
  local updateStr ="UPDATE PLAYERSTATUS SET CURRENTMONEY = CURRENTMONEY + (SELECT VALUE FROM JOBS WHERE JOBID = "..Jobid..")" 
  print(updateStr)
	print(db:exec(updateStr))


  local updateStr2 = "UPDATE AGENTS SET CITYID = (SELECT DESTINATION FROM JOBS WHERE JOBID = "..Jobid..") WHERE AGENTID = (SELECT AGENTID FROM JOBS WHERE JOBID="..Jobid..")"
  print(updateStr2)
  db:exec(updateStr2)

  deleteJob(Jobid)
  
  updateStatusBar()
end

function calculateHeatTime(AgentId)
  --based on current heat and heat loss rate, calculate time to heat-zero
    -- 
    local updateSql = "update AGENTS set HEATZEROTIME = "..os.time().." + (HEAT/HEATLOSSPERMIN)*60.. where AGENTID = "..AgentId

    db:exec(updateSql)
    
end

function deleteJob(Jobid)
  db:exec("DELETE FROM JOBS WHERE JOBID="..Jobid)
end

function deleteAgent(AgentID)
  local deleteStr = "DELETE FROM AGENTS WHERE AGENTID ="..AgentID
  db:exec(deleteStr)
end

function bustedShipment(Jobid)

end

function getJobInfo(Jobid)
    local selectStr = "SELECT JOBID, AGENTID, (SELECT AGENTNAME FROM AGENTS WHERE AGENTID = JOBS.AGENTID) AGENTNAME, COMPLETE,  (SELECT NAME FROM CITIES WHERE CITYID = ORIGIN) ORIGIN, (SELECT NAME FROM CITIES WHERE CITYID = DESTINATION) DESTINATION, VALUE, ETA, STARTTIME, (SELECT SECURITY FROM CITIES WHERE CITYID = DESTINATION) SECURITY, (SELECT HEAT FROM AGENTS WHERE AGENTID = JOBS.AGENTID) AGENTHEAT, (SELECT MAXHEAT FROM AGENTS WHERE AGENTID = JOBS.AGENTID) AGENTMAXHEAT FROM JOBS WHERE JOBID = "..Jobid

    print(selectStr)
      for row in db:nrows(selectStr)   do
         local Job = 
         {
            id= row.JOBID,
            AgentId = row.AGENTID,
            AgentName = row.AGENTNAME,
            AgentHeat = row.AGENTHEAT,
            AgentMaxHeat = row.AGENTMAXHEAT,
            Complete = row.COMPLETE,
            origin = row.ORIGIN,
            destination = row.DESTINATION,
            value = row.VALUE,
            eta = row.ETA,          
            starttime = row.STARTTIME, 
            security = row.SECURITY,

         }
         return Job
    end
end

----------
function getAllOwnedAgents( )
	local AGENTS = {}

	for row in db:nrows("select * from AGENTS where OWNED = 1")	do		
		AGENTS[#AGENTS+1] = 
		{
			id = row.AGENTID,
			name = row.AGENTNAME,
			heat = row.HEAT,
			level= row.LEVEL,
			experience = row.EXPERIENCE
		}
	end

	return AGENTS
end

function getAllAvailableAgents( )
	local AGENTS = {}

	for row in db:nrows("SELECT * FROM AGENTS WHERE OWNED = 1 AND AGENTID NOT IN (SELECT AGENTID FROM JOBS)")	do
			AGENTS[#AGENTS+1] = 
			{
				id = row.AGENTID,
				name = row.AGENTNAME,
				heat = row.HEAT,
				level= row.LEVEL,
				experience = row.EXPERIENCE
			}
	end

	return AGENTS
end

function getLocationforAgent(agentId)
  local selectStr = "SELECT CITIES.NAME CITYNAME, REGIONS.NAME REGIONNAME FROM AGENTS, CITIES, REGIONS WHERE AGENTS.CITYID = CITIES.CITYID AND CITIES.REGIONID = REGIONS.REGIONID AND AGENTID = "..agentId
  print(selectStr)
  for row in db:nrows(selectStr)
    do
      local result = {
        CityName = row.CITYNAME,
        RegionName= row.REGIONNAME
      }

    return result
  end
end

function setHeatforAgent(AgentId, heat)
  local updateStr = "UPDATE AGENTS SET HEAT = "..heat.." WHERE AGENTID = "..AgentId

  db:exec(updateStr)

  calculateHeatTime(AgentId)
end

-------

function getAvailableContracts() 
	openContracts = {}
	for row in db:nrows("SELECT OPENCONTRACTID, (SELECT NAME FROM CITIES WHERE CITYID = ORIGIN) ORIGIN, (SELECT NAME FROM CITIES WHERE CITYID = DESTINATION) DESTINATION, VALUE, DURATION, RISK  FROM OPENCONTRACTS ORDER BY VALUE DESC")	do
		openContracts[#openContracts+1] = 
		{
			id = row.OPENCONTRACTID,
			origin = row.ORIGIN,
			destination = row.DESTINATION,
			value= row.VALUE,				
			durationHours = row.DURATION,
			risk = row.RISK
		}
	end
	return openContracts
end

function getContract(openContractID)
 for row in db:nrows("SELECT OPENCONTRACTID, (SELECT NAME FROM CITIES WHERE CITYID = ORIGIN) ORIGIN, (SELECT NAME FROM CITIES WHERE CITYID = DESTINATION) DESTINATION, VALUE, DURATION, RISK  FROM OPENCONTRACTS WHERE OPENCONTRACTID = "..openContractID) do         
         local openContract = 
            {  id = row.OPENCONTRACTID,
               origin = row.ORIGIN,
               destination = row.DESTINATION,
               value= row.VALUE,
               destinationRegion = row.DESTINATIONREGION,
               durationHours = row.DURATION
            }
         return openContract
  end
end


function getAgentHeat(Agentid)
  for row in db:nrows("SELECT HEAT FROM AGENTS WHERE AGENTID = "..agentId) do
      return row.Heat
  end
end


function getAllActiveJobs()
	local jobs = {}

	local selectStr = "SELECT JOBID, AGENTID, (SELECT AGENTNAME FROM AGENTS WHERE AGENTID = JOBS.AGENTID) AGENTNAME, (SELECT HEAT FROM AGENTS WHERE AGENTID = JOBS.AGENTID) HEAT, (SELECT MAXHEAT FROM AGENTS WHERE AGENTID = JOBS.AGENTID ) MAXHEAT,  (SELECT NAME FROM CITIES WHERE CITYID = ORIGIN) ORIGIN, (SELECT NAME FROM CITIES WHERE CITYID = DESTINATION) DESTINATION, VALUE, ETA, STARTTIME FROM JOBS"

		for row in db:nrows(selectStr)	do
			jobs[#jobs+1] = 
			{
				Jobid= row.JOBID,
				agentId = row.AGENTID,
				AgentName = row.AGENTNAME,
				Complete = row.COMPLETE,
				origin = row.ORIGIN,
				destination = row.DESTINATION,
				value = row.VALUE,
				eta = row.ETA,				
				starttime = row.STARTTIME,
				agentHeat = row.HEAT,
				agentMaxHeat = row.MAXHEAT
			}
		end

	return jobs
end


function getAgentName(lookup_agentId)
   if lookup_agentId == nil then
         return "Test"
   end

   for row in db:nrows("SELECT AGENTNAME FROM AGENTS WHERE AGENTID = "..lookup_agentId) do      
      return row.AGENTNAME
   end   
end

function createShipment(openContractID, agentId)
	--insert into Jobs

	local insertStr = "INSERT INTO JOBS(AGENTID, ORIGIN, DESTINATION, VALUE, ETA,  STARTTIME) select "..agentId..", ORIGIN, DESTINATION, VALUE, (DURATION*3600) +"..os.time()..", "..os.time().." FROM OPENCONTRACTS WHERE OPENCONTRACTID = "..openContractID

	db:exec(insertStr)

	print (insertStr)
	
	--delete from openContracts
	local deleteStr = "DELETE FROM OPENCONTRACTS WHERE OPENCONTRACTID = "..openContractID
	 db:exec(deleteStr)

	print (deleteStr)
end

-----------New game initialization




------------Update available contracts


function deleteExpiredContracts()
    local deleteStr = "DELETE FROM OPENCONTRACTS WHERE EXPIRATION <"..os.time()
    db:exec(deleteStr)
end

function createNewContracts()
    local checkCount = "SELECT COUNT(*) CONTRACTCOUNT FROM OPENCONTRACTS"

    for row in db:nrows(checkCount) do
        if row.CONTRACTCOUNT < contractLimit then
            for i=row.CONTRACTCOUNT, contractLimit-1, 1 do
                addRandomContract()
            end
        end
    end
end


function addRandomContract()   

    --get all cities 
    local citySelectStr = "SELECT * FROM CITIES"

    local cities = {}
    for row in db:nrows(citySelectStr) do
        cities[#cities+1] = 
        {
            cityID = row.CITYID,
            regionID = row.REGIONID,
            security = row.SECURITY
        }
    end

    --pick 2 random cities
    local originCitynum = math.random(1, #cities)
    local originCityID = cities[originCitynum].cityID
    local originRegionID = cities[originCitynum].regionID
    local originSecurity = cities[originCitynum].security

    local destCityNum = math.random(1, #cities)
    local destCityID =  cities[destCityNum].cityID
    local destRegionID = cities[destCityNum].regionID
    local destSecurity = cities[destCityNum].security
    
    --retry if same region selected twice
    while destRegionID == originRegionID do
         destCityNum = math.random(1, #cities)
         destCityID =  cities[destCityNum].cityID
         destRegionID = cities[destCityNum].regionID
         local destSecurity = cities[destCityNum].security
    end

    --get travel time from cities
    local travelTimeSelectStr = "SELECT BASETIME FROM REGIONTRAVELTIMES WHERE (POINT1 = "..originRegionID.." AND POINT2 = "..destRegionID..") or (POINT1 = "..destRegionID.." and POINT2 = "..originRegionID..")"

    -- print (travelTimeSelectStr)
    local travelTime = nil
    for row in db:nrows(travelTimeSelectStr) do
         travelTime = row.BASETIME /10	--REduce time for testing
    end

    local contractValue = 100*travelTime*(destSecurity^2) * math.random(1, 2)
    local contractRisk = destSecurity 

    -- print (travelTime)
     local insertStr = "insert into OPENCONTRACTS (ORIGIN, DESTINATION, VALUE, DURATION, EXPIRATION, RISK) values ("..originCityID..", "..destCityID..","..contractValue..","..(travelTime*.5)..", "..7200+os.time()..", "..contractRisk..")"

     -- print (insertStr)

     db:exec(insertStr)
        
end

-- function copyFile( srcName, srcPath, dstName, dstPath, overwrite )

--     local results = false

--     local fileExists = doesFileExist( srcName, srcPath )
--     if ( fileExists == false ) then
--         return nil  -- nil = Source file not found
--     end

--     -- Check to see if destination file already exists
--     if not ( overwrite ) then
--         if ( fileLib.doesFileExist( dstName, dstPath ) ) then
--             return 1  -- 1 = File already exists (don't overwrite)
--         end
--     end

--     -- Copy the source file to the destination file
--     local rFilePath = system.pathForFile( srcName, srcPath )
--     local wFilePath = system.pathForFile( dstName, dstPath )

--     local rfh = io.open( rFilePath, "rb" )
--     local wfh, errorString = io.open( wFilePath, "wb" )

--     if not ( wfh ) then
--         -- Error occurred; output the cause
--         print( "File error: " .. errorString )
--         return false
--     else
--         -- Read the file and write to the destination directory
--         local data = rfh:read( "*a" )
--         if not ( data ) then
--             print( "Read error!" )
--             return false
--         else
--             if not ( wfh:write( data ) ) then
--                 print( "Write error!" )
--                 return false
--             end
--         end
--     end

--     results = 2  -- 2 = File copied successfully!

--     -- Close file handles
--     rfh:close()
--     wfh:close()

--     return results
-- end
