# ThingsBoard
Code related to publishing Things Data to the ThingsBoard


Create get_pi_health_stats.py:-

Runs every 5 seconds on a Raspberry Pi and get the CPU, Memory, Storage and Networking statistics and uploads them to the ThingsBoard solution.
This is then used by the ThingsBoard to show on a dashboard to allow many Raspberry Pi's to be monitored in near real-time.


Fibaro_send_to_ThingsBoards.lua

This Fibaro scene receives the data, one message at a time and sends it to ThingsBoard. Because the HTTP process in Fibaro scene's works in Asynchronous fashion, other scenes in Fibaro gather and format the data that needs to be sent and call this scene with the arguments.

Example of calling a this scene from another scene  fibaro:startScene(sceneID ,{device_access_token, value_to_send, "telemetry" or "attribute"}) 


Collect_Fibaro_Diagnostics.lua
This gathers CPU, Memory and Storage data from Fibaro's api and send calls the "Fibaro_send_to_ThingsBoards.lua" scene using it's "ID" and passes the arguments. This scense itself is call from my main loop, which runs every minute. I run the Fibaro loop every minute as not much changes on this server. If it does then I will know in about 1 min.
