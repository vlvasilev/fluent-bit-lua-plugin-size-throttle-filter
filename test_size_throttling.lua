-- Unit testing starts
lu = require('luaunit') 
size_throttling = require('size_throttling')

SIMPLE_LOG_TEST_DATA = {
	["tag"] = "simple_log_test",
	["timestamp"] = 1519233660.000000,
	["record"] =  {
		["log"] = "LOG_PLACEHOLDER",
		["stream"] = "STREAM_PLACEHOLDER",
		["time"] = "2018-02-21T17:26:53.360920913Z",
		["log_number"] = "LOG_NUMBER_PLACEHOLDER"
	}
}

SIMPLE_LOG_WITH_MISSING_LOG_FIELD_TEST_DATA = {
	["tag"] = "simple_log_with_missing_log_field",
	["timestamp"] = 1519233660.000000,
	["record"] = {
		["msg"] = "LOG_PLACEHOLDER",
		["stream"] = "STREAM_PLACEHOLDER",
		["time"] = "2018-02-21T17:26:53.360920913Z",
		["log_number"] = "LOG_NUMBER_PLACEHOLDER"
	}
}

SIMPLE_LOG_WITH_MISSING_STREAM_FIELD_TEST_DATA = {
	["tag"] = "simple_log_with_missing_stream_field",
	["timestamp"] = 1519233660.000000,
	["record"] = {
		["log"] = "LOG_PLACEHOLDER",
		["source"] = "STREAM_PLACEHOLDER",
		["time"] = "2018-02-21T17:26:53.360920913Z",
		["log_number"] = "LOG_NUMBER_PLACEHOLDER"
	}	
}

NESTED_LOG_FIELDS_TEST_DATA = {
	["tag"] = "nested_log_fields",
	["timestamp"] = 1519234013.360921,
	["record"] = {
		["log_entry"] = {
			["log"] = "LOG_PLACEHOLDER"
		},
		["stream"] = "stdout",
		["time"] = "2018-02-21T17:26:53.360920913Z",
		["kubernetes"] = {
			["pod_name"] = "STREAM_PLACEHOLDER",
			["namespace_name"] = "default",
			["pod_id"] = "64f7da23-172c-11e8-bfad-080027749cbc",
			["lables"] = {
				["run"] = "apache-logs",
			},
			["host"] = "minikube",
			["container_name"] = "apache-logs",
			["docker_id"] = "ac6095b6c715d823d732dcc9067f75b1299de5cc69a012b08d616a6058bdc0ad"
		},
		["log_number"] = "LOG_NUMBER_PLACEHOLDER"
	}	
}

SWAPED_NESTED_LOG_FIELDS_TEST_DATA = {
	["tag"] = "swaped_nested_log_fields",
	["timestamp"] = 1519234013.360921,
	["record"] = {
		["log"] = {
			["log_entry"] = "LOG_PLACEHOLDER"
		},
		["stream"] = "stdout",
		["time"] = "2018-02-21T17:26:53.360920913Z",
		["kubernetes"] = {
			["pod_name"] = "STREAM_PLACEHOLDER",
			["namespace_name"] = "default",
			["pod_id"] = "64f7da23-172c-11e8-bfad-080027749cbc",
			["lables"] = {
				["run"] = "apache-logs",
			},
			["host"] = "minikube",
			["container_name"] = "apache-logs",
			["docker_id"] = "ac6095b6c715d823d732dcc9067f75b1299de5cc69a012b08d616a6058bdc0ad"
		},
		["log_number"] = "LOG_NUMBER_PLACEHOLDER"
	}	
}

SWAPED_NESTED_STREAM_FIELDS_TEST_DATA = {
	["tag"] = "swaped_nested_stream_fields",
	["timestamp"] = 1519234013.360921,
	["record"] = {
		["log_entry"] = {
			["log"] = "LOG_PLACEHOLDER"
		},
		["stream"] = "stdout",
		["time"] = "2018-02-21T17:26:53.360920913Z",
		["pod_name"] = {
			["kubernetes"] = "STREAM_PLACEHOLDER",
			["namespace_name"] = "default",
			["pod_id"] = "64f7da23-172c-11e8-bfad-080027749cbc",
			["lables"] = {
				["run"] = "apache-logs",
			},
			["host"] = "minikube",
			["container_name"] = "apache-logs",
			["docker_id"] = "ac6095b6c715d823d732dcc9067f75b1299de5cc69a012b08d616a6058bdc0ad"
		},
		["log_number"] = "LOG_NUMBER_PLACEHOLDER"
	}	
}

NESTED_LOG_WITH_MISSING_LOG_FIELD_TEST_DATA = {
	["tag"] = "swaped_nested_log_fields",
	["timestamp"] = 1519234013.360921,
	["record"] = {
		["log_entry"] = {
			["msg"] = "LOG_PLACEHOLDER"
		},
		["stream"] = "stdout",
		["time"] = "2018-02-21T17:26:53.360920913Z",
		["kubernetes"] = {
			["pod_name"] = "STREAM_PLACEHOLDER",
			["namespace_name"] = "default",
			["pod_id"] = "64f7da23-172c-11e8-bfad-080027749cbc",
			["lables"] = {
				["run"] = "apache-logs",
			},
			["host"] = "minikube",
			["container_name"] = "apache-logs",
			["docker_id"] = "ac6095b6c715d823d732dcc9067f75b1299de5cc69a012b08d616a6058bdc0ad"
		},
		["log_number"] = "LOG_NUMBER_PLACEHOLDER"
	}	
}

NESTED_LOG_WITH_MISSING_STREAM_FIELD_TEST_DATA = {
	["tag"] = "swaped_nested_log_fields",
	["timestamp"] = 1519234013.360921,
	["record"] = {
		["log_entry"] = {
			["log"] = "LOG_PLACEHOLDER"
		},
		["stream"] = "stdout",
		["time"] = "2018-02-21T17:26:53.360920913Z",
		["kubernetes"] = {
			["pod_alias"] = "STREAM_PLACEHOLDER",
			["namespace_name"] = "default",
			["pod_id"] = "64f7da23-172c-11e8-bfad-080027749cbc",
			["lables"] = {
				["run"] = "apache-logs",
			},
			["host"] = "minikube",
			["container_name"] = "apache-logs",
			["docker_id"] = "ac6095b6c715d823d732dcc9067f75b1299de5cc69a012b08d616a6058bdc0ad"
		},
		["log_number"] = "LOG_NUMBER_PLACEHOLDER"
	}	
}


_32_bytes_msg = "This meeesage is 32 symbols long";
_11_bytes_msg = "I will pass";
_6_bytes_msg = "I pass";
_180_bytes_msg = "This message is 180 bytes long, so it will be used where we are sure that this message will pass every time or not at all. So used it carefully and at the proper place. Understand?";
stdout_str = "stdout";
stderr_str = "stderr";
apiserver = "kube-apiserver";
alertmanager = "alertmanager";

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function loadPlaceholders(testData, logPlaceholder, streamPlaceholder, numberPlaceholder)
	if (type(testData) ~= "table") then 
		return nil
	end
	
	testData = deepcopy(testData)
	
	for key, value in pairs(testData) do
		if (type(value) == "table") then 
			testData[key] = loadPlaceholders(value, logPlaceholder, streamPlaceholder, numberPlaceholder)
		elseif (value == "LOG_PLACEHOLDER") then 	
			testData[key] = logPlaceholder
		elseif (value == "STREAM_PLACEHOLDER") then	
			testData[key] = streamPlaceholder
		elseif (value == "LOG_NUMBER_PLACEHOLDER") then
			testData[key] = numberPlaceholder
		end
	end
	return testData
end

function checkIfMessagePassThroughEngine(filter, testData)
		local result = 1
		local tag = testData["tag"]
		local timestamp = testData["timestamp"]
		local record  = testData["record"]
		result, timestamp, record = filter:processRecord(tag, timestamp, record)
		lu.assertEquals( result, 0 )
		lu.assertEquals( type(timestamp), 'number' )
		lu.assertEquals( type(record), 'table' )
end 

function checkIfMessageDoesntPassThroughEngine(filter, testData)
		local result = 1
		local tag = testData["tag"]
		local timestamp = testData["timestamp"]
		local record  = testData["record"]
		result, timestamp, record = filter:processRecord(tag, timestamp, record)
		lu.assertEquals( result, -1 )
		lu.assertEquals( type(timestamp), 'number' )
		lu.assertEquals( type(record), 'table' )
end 


-- hrottleFilter:new(nil, MAX_LOAD_RATE_IN_BYTES, WINDOW_SIZE, SLIDE_INTERVAL_IN_SEC, WINDOW_TIME_DURATION_IN_SEC, STREAM, LOG, USE_TAG_AS_STREAM, PRINT_STATUS)
TestSizeThrottling = {}
function TestSizeThrottling:test_simple_log()
	local MAX_LOAD_RATE_IN_BYTES = 10
	local WINDOW_SIZE = 30 
	local SLIDE_INTERVAL_IN_SEC = 3
	local WINDOW_TIME_DURATION_IN_SEC = 10
	local STREAM = {"stream"}
	local LOG = {"log"}
	local USE_TAG_AS_STREAM = false 
	local PRINT_STATUS = true
	local filter = size_throttling:new(nil, MAX_LOAD_RATE_IN_BYTES, WINDOW_SIZE, SLIDE_INTERVAL_IN_SEC, WINDOW_TIME_DURATION_IN_SEC, STREAM, LOG, USE_TAG_AS_STREAM, PRINT_STATUS)
	local testData = {}
	
	print("-----------------START test test_simple_log-------------------------")
	
	--[[Verify that the size throttle plugin differentiates logs by a non nested name_field.
        We put 9 logs 32 bytes long which is 288 bytes of total or rate of 9.6.
        If all logs passed this means that the the plugin sees them as two seperates types or
        does now work at all.Or each logs is seen as different group of logs. --]]
	for i = 1, 9, 1 do 
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stderr_str, i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[Verify that the plugin cut logs wen rate exceeds 10.
       By add next message which is 32 bytes log the total must become 320 which
       makes the rate 10.66. If the messege is dropped this means that the plugin
       works properly. --]]
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, 10)
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stderr_str, 10)
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	--[[Now we will pass two messages with 11 bytes of lenght an they will make the
       rate 9.96 which is less than 10 and they must pass--]]
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _11_bytes_msg, stdout_str, 11)
	checkIfMessagePassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _11_bytes_msg, stderr_str, 11)
	checkIfMessagePassThroughEngine(filter, testData)
	
	--[[check that if log field is missing then the messages will pass throughout the engine.--]]
	for i = 1, 2, 1 do
		testData = loadPlaceholders(SIMPLE_LOG_WITH_MISSING_LOG_FIELD_TEST_DATA, _180_bytes_msg, stdout_str, 11 + i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SIMPLE_LOG_WITH_MISSING_LOG_FIELD_TEST_DATA, _180_bytes_msg, stderr_str, 11 + i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[check that if stream field is missing then the messages will pass throughout the engine .--]]
	for i = 1, 2, 1 do
		testData = loadPlaceholders(SIMPLE_LOG_WITH_MISSING_STREAM_FIELD_TEST_DATA, _180_bytes_msg, stdout_str, 13 + i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SIMPLE_LOG_WITH_MISSING_STREAM_FIELD_TEST_DATA, _180_bytes_msg, stderr_str, 13 + i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	print("-----------------END test test_simple_log-------------------------")
end

function TestSizeThrottling:test_nestest_name_fields()
	local MAX_LOAD_RATE_IN_BYTES = 10
	local WINDOW_SIZE = 30 
	local SLIDE_INTERVAL_IN_SEC = 3
	local WINDOW_TIME_DURATION_IN_SEC = 10
	local STREAM = {"kubernetes", "pod_name"}
	local LOG = {"log_entry","log"}
	local USE_TAG_AS_STREAM = false 
	local PRINT_STATUS = true
	local filter = size_throttling:new(nil, MAX_LOAD_RATE_IN_BYTES, WINDOW_SIZE, SLIDE_INTERVAL_IN_SEC, WINDOW_TIME_DURATION_IN_SEC, STREAM, LOG, USE_TAG_AS_STREAM, PRINT_STATUS)
	local testData = {}
	
	print("-----------------START test test_nestest_name_fields-------------------------")
	
	--[[Verify that the size throttle plugin differentiates logs by a nested stream_field and nested log_field.
       We put 9 logs 32 bytes long which is 288 bytes of total or rate of 9.6.
       If all logs passed this means that the the plugin sees them as two seperates types or
       does now work at all.Or each logs is seen as different group of logs.--]]
	for i = 1, 9, 1 do 
		testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _32_bytes_msg, apiserver, i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _32_bytes_msg, alertmanager, i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[Verify that the plugin cut logs when rate exceeds 10.
       By add next message which is 32 bytes log the total must become 320 which
       makes the rate 10.66. If the message is dropped this means that the plugin
       works properly. --]]
	testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _32_bytes_msg, apiserver, 10)
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _32_bytes_msg, alertmanager, 10)
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	--[[Now we will pass two messages with 11 bytes of lenght an they will make the
       rate 9.96 which is less than 10 and they must pass.--]]
	testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _11_bytes_msg, apiserver, 11)
	checkIfMessagePassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _11_bytes_msg, alertmanager, 11)
	checkIfMessagePassThroughEngine(filter, testData)
	
	--[[check that if log field is missing then the messages will pass throughout the engine.--]]
	for i = 1, 2, 1 do
		testData = loadPlaceholders(NESTED_LOG_WITH_MISSING_LOG_FIELD_TEST_DATA, _180_bytes_msg, apiserver, 11 + i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(NESTED_LOG_WITH_MISSING_LOG_FIELD_TEST_DATA, _180_bytes_msg, alertmanager, 11 + i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[check that if pod_name field is missing then the messages will pass throughout the engine.--]]
	for i = 1, 2, 1 do
		testData = loadPlaceholders(NESTED_LOG_WITH_MISSING_STREAM_FIELD_TEST_DATA, _180_bytes_msg, apiserver, 13 + i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(NESTED_LOG_WITH_MISSING_STREAM_FIELD_TEST_DATA, _180_bytes_msg, alertmanager, 13 + i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[check that if pod_name is not in the right order then the messages will pass throughout the engine--]]
	for i = 1, 2, 1 do
		testData = loadPlaceholders(SWAPED_NESTED_STREAM_FIELDS_TEST_DATA, _180_bytes_msg, apiserver, 15 + i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SWAPED_NESTED_STREAM_FIELDS_TEST_DATA, _180_bytes_msg, alertmanager, 15 + i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[check that if log field is wrong order then the messages will pass throughout the engine--]]
	for i = 1, 2, 1 do
		testData = loadPlaceholders(SWAPED_NESTED_LOG_FIELDS_TEST_DATA, _180_bytes_msg, apiserver, 17 + i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SWAPED_NESTED_LOG_FIELDS_TEST_DATA, _180_bytes_msg, alertmanager, 17 + i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	print("-----------------END test test_nestest_name_fields-------------------------")
end

function TestSizeThrottling:test_default_log_field()
	local MAX_LOAD_RATE_IN_BYTES = 43
	local WINDOW_SIZE = 30 
	local SLIDE_INTERVAL_IN_SEC = 3
	local WINDOW_TIME_DURATION_IN_SEC = 10
	local STREAM = {"kubernetes", "pod_name"}
	local LOG = {}
	local USE_TAG_AS_STREAM = false 
	local PRINT_STATUS = true
	local filter = size_throttling:new(nil, MAX_LOAD_RATE_IN_BYTES, WINDOW_SIZE, SLIDE_INTERVAL_IN_SEC, WINDOW_TIME_DURATION_IN_SEC, STREAM, LOG, USE_TAG_AS_STREAM, PRINT_STATUS)
	local testData = {}
	
	print("-----------------START test test_default_log_field-------------------------")
	
	--[[Verify that fluent-bit take in account all of the message payload when log_field is missing.
       We shall put two messages with different kubernetes.podname which will pass.
       One message is about 463 bytes long and two makes the rate about 30.87--]]
	for i = 1, 2, 1 do 
		testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _180_bytes_msg, apiserver, i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _180_bytes_msg, alertmanager, i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[Verify that the plugin cut logs when rate exceeds 37.
       We shall add again two messages with size 463 and they will
       fail passing.--]]
	testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _180_bytes_msg, apiserver, 3)
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _180_bytes_msg, alertmanager, 3)
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	--[[The next two must pass--]]
	testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _32_bytes_msg, apiserver, 4)
	checkIfMessagePassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(NESTED_LOG_FIELDS_TEST_DATA, _32_bytes_msg, alertmanager, 4)
	checkIfMessagePassThroughEngine(filter, testData)
	
	print("-----------------END test test_default_log_field-------------------------")
end

function TestSizeThrottling:test_default_stream_field()
	local MAX_LOAD_RATE_IN_BYTES = 10
	local WINDOW_SIZE = 30 
	local SLIDE_INTERVAL_IN_SEC = 3
	local WINDOW_TIME_DURATION_IN_SEC = 10
	local STREAM = {}
	local LOG = {"log"}
	local USE_TAG_AS_STREAM = false 
	local PRINT_STATUS = true
	local filter = size_throttling:new(nil, MAX_LOAD_RATE_IN_BYTES, WINDOW_SIZE, SLIDE_INTERVAL_IN_SEC, WINDOW_TIME_DURATION_IN_SEC, STREAM, LOG, USE_TAG_AS_STREAM, PRINT_STATUS)
	local testData = {}
	
	print("-----------------START test test_default_stream_field-------------------------")
	
	--[[Verify that the size throttle plugin do not differentiates logs by stream_field.
       We put 8 logs 32 bytes long which is 256 bytes of total or rate of 8.53.
       If all logs passed this means that the the plugin sees them as one or
       does now work at all.Or each logs is seen as different group of logs.--]]
	for i = 1, 4, 1 do 
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, i)
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stderr_str, i)
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[Add one exra message with lenght of 32 bytes to make the total 288 or rate of 9.6--]]
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, 5)
	checkIfMessagePassThroughEngine(filter, testData)
	
	--[[Verify that the plugin cut logs when rate exceeds 10.
       By add next message which is 32 bytes log the total must become 320 which
       makes the rate 10.66. If the messege is dropped this means that the plugin
       works properly. --]]
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, 6)
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stderr_str, 5)
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	--[[Now we will pass two messages with 6 bytes of lenght an they will make the
       rate 10 whch is the limit and the message must pass.--]]
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _6_bytes_msg, stdout_str, 7)
	checkIfMessagePassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _6_bytes_msg, stderr_str, 6)
	checkIfMessagePassThroughEngine(filter, testData)
	
	print("-----------------END test test_default_stream_field-------------------------")
end

function TestSizeThrottling:test_use_tag_as_strem()
	local MAX_LOAD_RATE_IN_BYTES = 10
	local WINDOW_SIZE = 30 
	local SLIDE_INTERVAL_IN_SEC = 3
	local WINDOW_TIME_DURATION_IN_SEC = 10
	local STREAM = {}
	local LOG = {"log"}
	local LOG = {"log"}
	local USE_TAG_AS_STREAM = true 
	local PRINT_STATUS = true
	local filter = size_throttling:new(nil, MAX_LOAD_RATE_IN_BYTES, WINDOW_SIZE, SLIDE_INTERVAL_IN_SEC, WINDOW_TIME_DURATION_IN_SEC, STREAM, LOG, USE_TAG_AS_STREAM, PRINT_STATUS)
	local testData = {}
	
	print("-----------------START test test_use_tag_as_strem-------------------------")
	
	--[[Verify that the size throttle plugin differentiates logs by a non nested name_field.
        We put 9 logs 32 bytes long which is 288 bytes of total or rate of 9.6.
        If all logs passed this means that the the plugin sees them as two seperates types or
        does now work at all.Or each logs is seen as different group of logs. --]]
	for i = 1, 9, 1 do 
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, i)
		testData["tag"] = "simple_log_test".."_"..stdout_str
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stderr_str, i)
		testData["tag"] = "simple_log_test".."_"..stderr_str
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[Verify that the plugin cut logs wen rate exceeds 10.
       By add next message which is 32 bytes log the total must become 320 which
       makes the rate 10.66. If the message is dropped this means that the plugin
       works properly. --]]
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, 10)
	testData["tag"] = "simple_log_test".."_"..stdout_str
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stderr_str, 10)
	testData["tag"] = "simple_log_test".."_"..stderr_str
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	--[[Now we will pass two messages with 11 bytes of lenght an they will make the
       rate 9.96 which is less than 10 and they must pass--]]
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _11_bytes_msg, stdout_str, 11)
	testData["tag"] = "simple_log_test".."_"..stdout_str
	checkIfMessagePassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _11_bytes_msg, stderr_str, 11)
	testData["tag"] = "simple_log_test".."_"..stderr_str
	checkIfMessagePassThroughEngine(filter, testData)
	
	--[[check that if log field is missing then the messages will pass throughout the engine.--]]
	for i = 1, 2, 1 do
		testData = loadPlaceholders(SIMPLE_LOG_WITH_MISSING_LOG_FIELD_TEST_DATA, _180_bytes_msg, stdout_str, 11 + i)
		testData["tag"] = "simple_log_test".."_"..stdout_str
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SIMPLE_LOG_WITH_MISSING_LOG_FIELD_TEST_DATA, _180_bytes_msg, stderr_str, 11 + i)
		testData["tag"] = "simple_log_test".."_"..stderr_str
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[check that if stream field is missing then the messages will not pass throughout the engine because we have tag stream .--]]
	for i = 1, 2, 1 do
		testData = loadPlaceholders(SIMPLE_LOG_WITH_MISSING_STREAM_FIELD_TEST_DATA, _180_bytes_msg, stdout_str, 13 + i)
		testData["tag"] = "simple_log_test".."_"..stdout_str
		checkIfMessageDoesntPassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SIMPLE_LOG_WITH_MISSING_STREAM_FIELD_TEST_DATA, _180_bytes_msg, stderr_str, 13 + i)
		testData["tag"] = "simple_log_test".."_"..stderr_str
		checkIfMessageDoesntPassThroughEngine(filter, testData)
	end
	print("-----------------END test test_use_tag_as_strem-------------------------")
end

function TestSizeThrottling:test_addition_of_new_pane_each_interval()
	local MAX_LOAD_RATE_IN_BYTES = 10
	local WINDOW_SIZE = 30 
	local SLIDE_INTERVAL_IN_SEC = 1
	local WINDOW_TIME_DURATION_IN_SEC = 300
	local STREAM = {"stream"}
	local LOG = {"log"}
	local USE_TAG_AS_STREAM = false 
	local PRINT_STATUS = true
	local filter = size_throttling:new(nil, MAX_LOAD_RATE_IN_BYTES, WINDOW_SIZE, SLIDE_INTERVAL_IN_SEC, WINDOW_TIME_DURATION_IN_SEC, STREAM, LOG, USE_TAG_AS_STREAM, PRINT_STATUS)
	local testData = {}
	
	print("-----------------START test test_addition_of_new_pane_each_interval-------------------------")
	
	--[[Verify that the size throttle plugin differentiates logs by a non nested name_field.
        We put 9 logs 32 bytes long which is 288 bytes of total or rate of 9.6.
        If all logs passed this means that the the plugin sees them as two seperates types or
        does now work at all.Or each logs is seen as different group of logs. --]]
	for i = 1, 9, 1 do 
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, i)
		testData["tag"] = "simple_log_test".."_"..stdout_str
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stderr_str, i)
		testData["tag"] = "simple_log_test".."_"..stderr_str
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	--[[Verify that the plugin cut logs wen rate exceeds 10.
       By add next message which is 32 bytes log the total must become 320 which
       makes the rate 10.66. If the messege is dropped this means that the plugin
       works properly. --]]
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, 10)
	testData["tag"] = "simple_log_test".."_"..stdout_str
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stderr_str, 10)
	testData["tag"] = "simple_log_test".."_"..stderr_str
	checkIfMessageDoesntPassThroughEngine(filter, testData)
	
	--[[verify that there will be added new 30 panes after 33 seconds--]]
	local clock = os.clock
	local t0 = clock()
	while clock() - t0 <= 33 do end

	--[[Verify that the size throttle plugin differentiates logs by a non nested name_field.
        We put 9 logs 32 bytes long which is 288 bytes of total or rate of 9.6.
        If all logs passed this means that the the plugin sees them as two seperates types or
        does now work at all.Or each logs is seen as different group of logs. --]]
	for i = 1, 9, 1 do 
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stdout_str, i)
		testData["tag"] = "simple_log_test".."_"..stdout_str
		checkIfMessagePassThroughEngine(filter, testData)
		
		testData = loadPlaceholders(SIMPLE_LOG_TEST_DATA, _32_bytes_msg, stderr_str, i)
		testData["tag"] = "simple_log_test".."_"..stderr_str
		checkIfMessagePassThroughEngine(filter, testData)
	end
	
	print("-----------------END test test_addition_of_new_pane_each_interval-------------------------")
end
os.exit( lu.LuaUnit.run() )