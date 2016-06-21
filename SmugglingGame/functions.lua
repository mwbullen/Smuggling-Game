require "sqlite3"

local  path = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open(path)

local contractLimit = 6

----------Money operations
function getCurrentCash() 	
	for row in db:nrows("select CurrentMoney from PlayerStatus") do
			return row.CurrentMoney
	end
end

-- function addCash(newCash )
-- 	db:exec("update PlayerStatus set CurrentMoney = CurrentMoney +"..newCash)
-- end

----------Shipment operations

function completeShipment(Jobid)
	--get cash value of shipment, add to current chash
	db:exec("update PlayerStatus set CurrentMoney = CurrentMoney + (select Value from Jobs where JobId = "..Jobid..")")
	db:exec("delete from Jobs where JobId="..Jobid)


end


----------
function getAllOwnedAgents( )
	local agents = {}

	for row in db:nrows("select * from Agents where Owned = 1")	do		
		agents[#agents+1] = 
		{
			id = row.AgentId,
			name = row.AgentName,
			heat = row.Heat,
			level= row.Level,
			experience = row.Experience
		}
	end

	return agents
end

function getAllAvailableAgents( )
	local agents = {}

	for row in db:nrows("select * from Agents where Owned = 1 and agentid not in (Select agentid from jobs)")	do
			agents[#agents+1] = 
			{
				id = row.AgentId,
				name = row.AgentName,
				heat = row.Heat,
				level= row.Level,
				experience = row.Experience
			}
	end

	return agents
end

function getAvailableContracts() 
	openContracts = {}
	for row in db:nrows("select openContractID, (select Name from Cities where CityID = Origin) Origin, (select Name from Cities where CityID = Destination) Destination, Value, Duration, Risk  from opencontracts order by Value desc")	do
		openContracts[#openContracts+1] = 
		{
			id = row.OpenContractID,
			origin = row.Origin,
			destination = row.Destination,
			value= row.Value,				
			durationHours = row.Duration,
			risk = row.Risk
		}
	end
	return openContracts
end

function getContract(openContractID)
 for row in db:nrows("select openContractID, (select Name from Cities where CityID = Origin) Origin, (select Name from Cities where CityID = Destination) Destination, Value, Duration, Risk  from opencontracts where openContractID = "..openContractID) do         
         local openContract = 
            {  id = row.OpenContractID,
               origin = row.Origin,
               destination = row.Destination,
               value= row.Value,
               destinationRegion = row.DestinationRegion,
               durationHours = row.Duration
            }
         return openContract
  end
end



function getAllActiveJobs()
	local jobs = {}

	local selectStr = "select JobId, AgentID, (select AgentName from Agents where AgentId = Jobs.AgentID) AgentName, (Select Heat from Agents where AgentId = Jobs.AgentID) Heat, (select maxHeat from Agents where Agentid = Jobs.AgentID ) maxHeat,  (select Name from Cities where CityID = Origin) Origin, (select Name from Cities where CityID = Destination) Destination, Value, ETA, StartTime from Jobs"

		for row in db:nrows(selectStr)	do
			jobs[#jobs+1] = 
			{
				Jobid= row.JobId,
				agentId = row.AgentId,
				AgentName = row.AgentName,
				Complete = row.Complete,
				origin = row.Origin,
				destination = row.Destination,
				value = row.Value,
				eta = row.ETA,				
				starttime = row.StartTime,
				agentHeat = row.Heat,
				agentMaxHeat = row.maxHeat
			}
		end

	return jobs
end


function getAgentName(lookup_agentId)
   if lookup_agentId == nil then
         return "Test"
   end

   for row in db:nrows("select AgentName from Agents where AgentId = "..lookup_agentId) do      
      return row.AgentName
   end   
end

function createShipment(openContractID, agentId)
	--insert into Jobs

	local insertStr = "insert into Jobs(agentId, origin, destination, value, eta,  starttime) select "..agentId..", origin, destination, value, (duration*3600) +"..os.time()..", "..os.time().." from OpenContracts where OpenContractid = "..openContractID

	db:exec(insertStr)

	print (insertStr)
	
	--delete from openContracts
	local deleteStr = "delete from openContracts where openContractID = "..openContractID
	 db:exec(deleteStr)

	print (deleteStr)
end

function deleteExpiredContracts()
    local deleteStr = "delete from openContracts where expiration <"..os.time()
    db:exec(deleteStr)
end

function createNewContracts()
    local checkCount = "select count(*) contractCount from openContracts"

    for row in db:nrows(checkCount) do
        if row.contractCount < contractLimit then
            for i=row.contractCount, contractLimit-1, 1 do
                addRandomContract()
            end
        end
    end
end


function addRandomContract()   

    --get all cities 
    local citySelectStr = "select * from Cities"

    local cities = {}
    for row in db:nrows(citySelectStr) do
        cities[#cities+1] = 
        {
            cityID = row.CityID,
            regionID = row.RegionID,
            security = row.Security
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
    local travelTimeSelectStr = "select BaseTime from RegionTravelTimes where (point1 = "..originRegionID.." and point2 = "..destRegionID..") or (point1 = "..destRegionID.." and point2 = "..originRegionID..")"

    -- print (travelTimeSelectStr)
    local travelTime = nil
    for row in db:nrows(travelTimeSelectStr) do
         travelTime = row.BaseTime /100	--REduce time for testing
    end

    local contractValue = 100*travelTime*(destSecurity^2) * math.random(1, 2)
    local contractRisk = destSecurity 

    -- print (travelTime)
     local insertStr = "insert into OpenContracts (Origin, Destination, Value, Duration, Expiration, Risk) values ("..originCityID..", "..destCityID..","..contractValue..","..(travelTime*.5)..", "..7200+os.time()..", "..contractRisk..")"

     -- print (insertStr)

     db:exec(insertStr)
        
end

function copyFile( srcName, srcPath, dstName, dstPath, overwrite )

    local results = false

    local fileExists = doesFileExist( srcName, srcPath )
    if ( fileExists == false ) then
        return nil  -- nil = Source file not found
    end

    -- Check to see if destination file already exists
    if not ( overwrite ) then
        if ( fileLib.doesFileExist( dstName, dstPath ) ) then
            return 1  -- 1 = File already exists (don't overwrite)
        end
    end

    -- Copy the source file to the destination file
    local rFilePath = system.pathForFile( srcName, srcPath )
    local wFilePath = system.pathForFile( dstName, dstPath )

    local rfh = io.open( rFilePath, "rb" )
    local wfh, errorString = io.open( wFilePath, "wb" )

    if not ( wfh ) then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Read the file and write to the destination directory
        local data = rfh:read( "*a" )
        if not ( data ) then
            print( "Read error!" )
            return false
        else
            if not ( wfh:write( data ) ) then
                print( "Write error!" )
                return false
            end
        end
    end

    results = 2  -- 2 = File copied successfully!

    -- Close file handles
    rfh:close()
    wfh:close()

    return results
end