--[[
%% properties
%% events
%% globals
--]]

--=================================================
-------- Declaration: Local Variables 
--=================================================
local debug = false
local http = net.HTTPClient()
local args = fibaro:args()
local access_token
local send_data
local api_type
local ThingsBoardIP = "192.168.x.x:8080"

----------------------------------------------------------------------------------------------------------
-- parameters
----------------------------------------------------------------------------------------------------------
if args[1] == nil then access_token = '' else access_token = args[1] end
if args[2] == nil then send_data = '' else send_data = args[2] end
if args[3] == nil then api_type = '' else api_type = args[3] end

--=================================================
-------- Functions
--=================================================
local function log(str) if debug then fibaro:debug(str); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..str.."</font>"); end

--=================================================
-------- Main Code
--=================================================
log(send_data)

if access_token ~= "" and send_data ~= "" then
    http:request('http://' .. ThingsBoardIP .. '/api/v1/' .. access_token .. '/' .. api_type,{ 
        options={
        headers = {['Content-Type'] = 'application/json'},
        data = send_data,
        method = 'POST',
        timeout = 5000
        },
     
		    
        success = function(status)                    
                    if status.data == "" then
                        log("successful send")
                        --print(status.data)
                    else
                        errorlog("Failed to Send Data to ThingsBoard")
                        errorlog(status.data)
                    end
                end,
     
     
        error = function(error)
                    errorlog("ERROR with HTTP call")
                    errorlog(error)
                end
     
    })
end 
