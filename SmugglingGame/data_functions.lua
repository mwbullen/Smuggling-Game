require "sqlite3"

local  path = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open(path)


-- local function getAllOwnedAgents( )
-- 	local agents = {}

-- 	for row in db:nrows("select * from Agents where Owned = 1")	do
-- 		agents[#agents+1] = 
-- 		{
-- 			id = row.AgentId,
-- 			name = row.agentname,
-- 			heat = row.heat,
-- 			level= row.level,
-- 			experience = row.Experience
-- 		}
-- 	end
-- 	return agents
-- end

