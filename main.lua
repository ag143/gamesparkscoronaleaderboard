-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local gs = nil
local gridView = require("grid")

local onGridEvent = function(event)
    local json = require "json"
    print("Auth Request Response:", json.prettify(response))

end

local retrieveLeaderboard = function(leaderboardName)
	--Build Request
	local requestBuilder = gs.getRequestBuilder()
	local getEntryRequest = requestBuilder.createLeaderboardDataRequest()

	--Set values
	getEntryRequest:setLeaderboardShortCode(leaderboardName)
	getEntryRequest:setEntryCount(10)

    getEntryRequest:send(function(response)
        local json = require "json"
        print("Auth Request Response:", json.prettify(response))

        local tableGridOptions = {
            --Entire Grid
            gridWidth = .80, -- As percentage of full width.
            gridHeight = .70, -- As percentage of full height.
      
            --Title name.
            showTitle = true,
            titleName = "top scores",
            
            --Header
            columnDisplayName = {" ", "name", "score"},
            showColumnHeader = true,
      
            --Columns row
            columnWidthPercent = {.10, .50, .40},
            columnDataName = {"rank", "userName", "score"}
        }

		gridView.DisplayGrid(response.data.data, tableGridOptions, onGridEvent)
	end)
end

local logEvent = function(eventKey, attributes)
    
    -- This is how all request start
    local requestBuilder = gs.getRequestBuilder()
    local logEventRequest = requestBuilder.createLogEventRequest()
    
    -- The event key
	logEventRequest:setEventKey(eventKey)

    -- Atributes
	if attributes ~= nil then
		for k,v in pairs( attributes ) do
			logEventRequest:setEventAttribute(k, v)
		end
	end

	logEventRequest:send(function(response)
		local json = require "json"
        print("Post event response:", json.prettify(response))

        retrieveLeaderboard("top_score")

	end)

end

local deviceAuthentication = function()
    -- This is how all request start
    local requestBuilder = gs.getRequestBuilder()
    local deviceAuthenticationRequest = requestBuilder.createDeviceAuthenticationRequest()

    -- I am setting the deviceId, platform and displayName
    deviceAuthenticationRequest:setDeviceId(system.getInfo( "deviceID" ))
    deviceAuthenticationRequest:setDeviceOS(system.getInfo( "platform" ))
    deviceAuthenticationRequest:setDisplayName("adrian")

    deviceAuthenticationRequest:send(function(response)
        local json = require "json"
        print("Auth Request Response:", json.prettify(response))

        -- Create the high score.
        local highScore = math.random(1, 1000)
        
        -- Send the score.
        logEvent("score_event", {score = highScore})
    end)
end

local availabilityCallback = function(event)
    if event == true then
        deviceAuthentication()
    end
end

-- Start Gamespark
local GS = require("plugin.gamesparks")
gs = createGS()

-- Add your secret
gs.setApiKey("") -- Use your apiKey
gs.setApiSecret("") -- Use your api secret
gs.setAvailabilityCallback(availabilityCallback)

--gs.setUseLiveServices(true) -- Add this for production
gs.connect()


