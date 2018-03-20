--[[
%% properties
%% events
%% globals
--]]

--=================================================
-------- Declaration: Local Variables 
--=================================================
local api_type = "telemetry"
local debug = false
local sceneID = 69 -- The Async process to send HTTP data to ThingsBoard Device
local access_token = "3bv6cBOITc74SrGudfaS" -- Device key


--=================================================
-------- Functions
--=================================================

local function log(str) if debug then fibaro:debug(str); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..str.."</font>"); end

local function sendToThingsBoard(send_data)
	fibaro:startScene(sceneID ,{access_token, send_data, api_type}) 
end

local function processDiagnosticData()
  local diagnosticsData = api.get("/diagnostics")
  
  totalUsedMemory = tonumber(diagnosticsData["memory"]["cache"]) + 
  					tonumber(diagnosticsData["memory"]["buffers"]) + 
  					tonumber(diagnosticsData["memory"]["used"])
  
  local requestBody1 = '{"FreeMemory":"' .. diagnosticsData["memory"]["free"] .. 
  						'", "CacheMemory":"' .. diagnosticsData["memory"]["cache"] .. 
  						'", "BuffersMemory":"' .. diagnosticsData["memory"]["buffers"] ..  
 						'", "TotalUsedsMemory":"' .. tostring(totalUsedMemory) ..
  						'", "UsedMemory":"' .. diagnosticsData["memory"]["used"] .. '"}'
  log("Send Memory: " .. requestBody1)
  sendToThingsBoard(requestBody1)
  
  for type, storages in pairs(diagnosticsData["storage"]) do
    for key, storageDevice in ipairs(storages) do
      requestBody2 = '{"' .. storageDevice["name"] .. '_used":"' .. storageDevice["used"] .. '"}'
      log("Send Storage: " .. requestBody2)
      fibaro:sleep(1000)
      sendToThingsBoard(requestBody2)
      
    end
  end
  
  for key, cpus in ipairs(diagnosticsData["cpuLoad"]) do
    for name, cpu in pairs(cpus) do
      requestBody3 = '{"' .. name .. '_user":' .. cpu["user"] .. 
      				', "' .. name .. '_nice":"' .. cpu["nice"] .. 
      				', "' .. name .. '_system":"' .. cpu["system"] .. 
      				', "' .. name .. '_idle":"' .. cpu["idle"] .. '"}'
      log("Send Individual CPU: " .. requestBody3)
      fibaro:sleep(1000)
      sendToThingsBoard(requestBody3)
    end
  end
  
  fibaro:sleep(600)
  local diagnosticsData2 = api.get("/diagnostics")

  for cpuCounter, cpus in ipairs(diagnosticsData["cpuLoad"]) do
    for name, cpu in pairs(cpus) do
      
      total1 = diagnosticsData["cpuLoad"][cpuCounter][name]["user"] + diagnosticsData["cpuLoad"][cpuCounter][name]["nice"] +
               diagnosticsData["cpuLoad"][cpuCounter][name]["idle"] + diagnosticsData["cpuLoad"][cpuCounter][name]["system"]
               
      total2 = diagnosticsData2["cpuLoad"][cpuCounter][name]["user"] + diagnosticsData2["cpuLoad"][cpuCounter][name]["nice"] +
               diagnosticsData2["cpuLoad"][cpuCounter][name]["idle"] + diagnosticsData2["cpuLoad"][cpuCounter][name]["system"]
               
      total = total2 - total1
      
      user = string.format("%.1f", (diagnosticsData2["cpuLoad"][cpuCounter][name]["user"] - diagnosticsData["cpuLoad"][cpuCounter][name]["user"]) * 100 / total)
      nice = string.format("%.1f", (diagnosticsData2["cpuLoad"][cpuCounter][name]["nice"] - diagnosticsData["cpuLoad"][cpuCounter][name]["nice"]) * 100 / total)
      idle = string.format("%.1f", (diagnosticsData2["cpuLoad"][cpuCounter][name]["idle"] - diagnosticsData["cpuLoad"][cpuCounter][name]["idle"]) * 100 / total)
      system = string.format("%.1f", (diagnosticsData2["cpuLoad"][cpuCounter][name]["system"] - diagnosticsData["cpuLoad"][cpuCounter][name]["system"]) * 100 / total)
      
      requestBody4 = '{"Total_' .. name .. '_user":"' .. user .. 
      				'", "Total_' .. name .. '_nice":"' .. nice .. 
      				'", "Total_' .. name .. '_system":"' .. system .. 
      				'", "Total_' .. name .. '_idle":"' .. idle .. '"}'
      log("Send Total CPU: " .. requestBody4)
      fibaro:sleep(1000)
      sendToThingsBoard(requestBody4)
    end
  end
end


--=================================================
-------- Main
--=================================================

-- Get the memory, storage and CPU usage information
log("Start")
processDiagnosticData()
log("End")
