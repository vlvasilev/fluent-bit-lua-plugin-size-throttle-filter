local size_throttling = {}
math = require('math')

PLUGIN = "filter_throttle_size" 
DEBUG = true
INFO = true
WARNING = true
MAX_LOAD_RATE_IN_BYTES = 30
WINDOW_SIZE = 5
SLIDE_INTERVAL_IN_SEC = 1
WINDOW_TIME_DURATION_IN_SEC = 60
STREAM = {"stream"} --[[cannot be set together with USE_TAG_AS_STREAM = true--]]
LOG = {"log"}
USE_TAG_AS_STREAM = false
PRINT_STATUS = false

--[[START Utils--]]
function getCurrentTimestamp()
	return os.time(os.date("!*t"))
end


Pane = {timestamp = 0, size = 0}

function Pane:new(obj, timestamp)
	obj = obj or {}
	if (not obj) then
		if (WARNING) then 
			print(string.format("[%s] Now enought memory for Pane.", PLUGIN))
		end
		return nil
	end
	setmetatable(obj, self)
	self.__index = self
	obj.timestamp = timestamp or self.name
	obj.size = self.size
	return obj
end

Window = { name = "", size = 0, total = 0, timestamp = 0, head = 1, tail = 1, panes = {}}

function Window:new(obj, name, size)
	if( size <= 0 ) then
		if (DEBUG) then
			print(string.format("[%s] Invoke Window:new with size %d.", PLUGIN, size))
		end
	    return nil
	end
	obj = obj or {}
	if (not obj) then 
		if (WARNING) then 
			print(string.format("[%s] Now enought memory for window.", PLUGIN))
		end
		return nil
	end
	setmetatable(obj, self)
	self.__index = self
	obj.name = name or self.name
	obj.size = size or self.size
	obj.head = obj.size
	obj.tail = self.tail
	obj.timestamp = getCurrentTimestamp()
	obj.panes = {}
	if (not obj.panes) then
		if (WARNING) then 
			print(string.format("[%s] Now enought memory for panes.", PLUGIN))
		end
		return nil
	end
	for i = 1, obj.size, 1 do 
	    obj.panes[i] = Pane:new(nil, obj.timestamp)
	    if (not obj.panes[i]) then
		    return nil
	    end
	end
	if (DEBUG) then
		print(string.format("[%s] New size throttling window named \"%s\" was created.", PLUGIN, self.name))
	end
	return obj
end

--[[This function adds new pane on top of the pane stack by overwriting the oldes one
  which @timestamp and load size of 0 bytes. The oldes pane's amount of load size
  is subtracted of the total amount.--]]
function Window:addNewPane(timestamp)
	local lastPaneSize = self.panes[self.tail].size
	if (self.size == self.head) then
		--[the head will exceed the end of the inner array end must be put at the begging.--]
		self.head = 0
	end
	self.head = self.head + 1
	--[add new pane in the queue--]]
	self.panes[self.head].timestamp = timestamp
	self.panes[self.head].size = 0
	
	--[update the window total size--]
	self.total = self.total - lastPaneSize
	
	if (self.size == self.tail) then
		--[the tail will exceed the end of the inner array end must be put at the begging.--]
		self.tail = 0
	end
	self.tail = self.tail  + 1
end

--[[This function adds @load to the latest pane which is on top of the pane stack.
  @load is added to the total amount of the size throttling window.
  If @load is not 0 then the size throttling window's timestamp will be updated to the
  one which is on top of the pane stack(latest)--]]
function Window:addLoad(load)
	self.panes[self.head].size = self.panes[self.head].size + load
	self.total = self.total + load
	if (load > 0) then
		self.timestamp = self.panes[self.head].timestamp
	end
end

ThrottlingTable = {windows = {}}

function ThrottlingTable:new(obj)
	obj = obj or {}
	if (not obj) then
		if (WARNING) then
			io.write(string.format("[%s] Not enought memory.Can create table.\n", PLUGIN, self.name))
		end
		return nil
	end
	setmetatable(obj, self)
	self.__index = self
	obj.windows = {}
	return obj
end

function ThrottlingTable:find(name)
	return self.windows[name]
end

function ThrottlingTable:add(window)
	self.windows[window.name] = window
end

function ThrottlingTable:addNewPaneToAllWindows(timestamp)
	for name , window in pairs(self.windows) do
		window:addNewPane(timestamp)
	end
end

ThrottleFilter = {maxLoadRate = 0, windowsSize = 0, slideInterval = 0, windowTimeDuration = 0, streamField = {}, logField = {}, printStatus = false, throttleTable = "nil", useTagAsStream = false, lastOprationTimestamp = 0}

function getSize(record)
	local recorType = type(record)
	
	if (recorType == "string") then 
		return string.len(record)
	end
	if (recorType == "number" or recorType == "boolean") then 
		return string.len(tostring(record))
	end
	if (recorType == "table") then
		local size = 0 
		for key, value in pairs(record) do
			size = size + getSize(key)
			size = size + getSize(value)
		end
		return size
	end
	
	return 0
end

function getField(field, record)
	local currentField = record
	for i, stream in pairs(field) do
		if (type(currentField) ~= "table") then
			return nil
		end
		currentField = currentField[stream]
	end
	return currentField
end

function ThrottleFilter:getStream(record, tag)
	if (self.useTagAsStream) then
		return tag
	end
	return getField(self.streamField, record)
end

function ThrottleFilter:getLog(record)
	return getField(self.logField, record)
end

function ThrottleFilter:getLogSize(record, tag)
	if (#self.logField > 0) then 
		local logField = self:getLog(record)
		if (INFO and not logField)
		then
			print(string.format("[%s] Missing log field in \"%s\" recod. The record will not be filtered", PLUGIN, tag))
		end
		return getSize(logField)
	else
		return getSize(record)
	end
end

function ThrottleFilter:getStreamWindow(record, tag)
	if (self.useTagAsStream or #self.streamField > 0) then
		local stream = self:getStream(record, tag)
		
		if(INFO and not stream) then 
			print(string.format("[%s] Missing stream field in \"%s\" recod. The record will not be filtered", PLUGIN, tag))
		end
		if (not stream) then 
			return nil
		end
	
		local streamWindow = self.throttleTable.windows[stream] --:find(stream)

		if (not streamWindow) then 
			streamWindow = Window:new(nil, stream, self.windowsSize)
			if (streamWindow) then
				self.throttleTable.windows[streamWindow.name] = streamWindow --:add(streamWindow)
			end
		end
		
		if ( (not streamWindow) and WARNING) then 
			print(string.format("[%s] Not enought memory. The record \"%s\" will not be filtered", PLUGIN, tag))
		end
		
		return streamWindow
	else
		return self.throttleTable
	end
end

function ThrottleFilter:filter(tag, timestamp, record)
	local logSize = self:getLogSize(record, tag)
	if (logSize == 0) then
		if (DEBUG) then 
			print(string.format("[%s] Record \"%s\" does not have log payload. The record will not be filtered", PLUGIN, tag))
		end
		return 0, timestamp, record
	end
	
	local streamWindow = self:getStreamWindow(record, tag)

	if( not streamWindow) then
		return 0, timestamp, record
	end
	
	local newLogRate = (streamWindow.total + logSize) / self.windowsSize
	if (DEBUG) then 
		print(string.format("[%s] Record \"%s\" has log rate of %f.", PLUGIN, tag, newLogRate))
	end
	--[[TODO: add the deviation--]]
	if (newLogRate > self.maxLoadRate) then 
		if (INFO) then 
			print(string.format("[%s] Record \"%s\" exceed the maximum log rate. Record will be skipped", PLUGIN, tag))
		end
		return -1, timestamp, record
	end
	
	streamWindow:addLoad(logSize)
	
	if (DEBUG) then 
		print(string.format("[%s] Record \"%s\" will be kept.", PLUGIN, tag))
	end
	
	return 0, timestamp, record
end

function ThrottleFilter:addNewPaneToAllWindows(timestamp)
	if (self.useTagAsStream or #self.streamField > 0) then
		self.throttleTable:addNewPaneToAllWindows(timestamp)
	else
		self.throttleTable:addNewPane(timestamp)
	end
end

function ThrottleFilter:deleteOlderWindows(timestamp)
	if (self.useTagAsStream or #self.streamField > 0) then
		for name , window in pairs(self.throttleTable.windows) do
			if (window.timestamp + self.windowTimeDuration < timestamp) then 
				self.throttleTable.windows[name] = nil
				if (DEBUG) then 
					print(string.format("[%s] Window \"%s\" was too old and thus deleted", PLUGIN, name))
				end 
			end
		end
	else
		--[[we are using the default stream and we have only one window which we will not delete never until the end of the pluging instance--]]
	end
end

function ThrottleFilter:printAll()
	if self.printStatus then
		if (self.useTagAsStream or #self.streamField > 0) then
			for name , window in pairs(self.throttleTable.windows) do
				print(string.format("[%s] Window \"%s\":", PLUGIN, window.name))
				print(string.format("[%s] 	total %d", PLUGIN, window.total))
				print(string.format("[%s] 	rate %d", PLUGIN, window.total/window.size))
				print(string.format("[%s] 	last record \"%s\"\n", PLUGIN, os.date('%Y-%m-%d %H:%M:%S', window.timestamp)))	
			end
		else
			print(string.format("[%s] Window \"%s\":", PLUGIN, self.throttleTable.name))
			print(string.format("[%s] 	total %d", PLUGIN, self.throttleTable.total))
			print(string.format("[%s] 	rate %d", PLUGIN, self.throttleTable.total/self.throttleTable.size))
			print(string.format("[%s] 	last record \"%s\"\n", PLUGIN, os.date('%Y-%m-%d %H:%M:%S', self.throttleTable.timestamp)))	
		end
	end
end

function ThrottleFilter:processRecord(tag, timestamp, record)
	local currentTimestamp = getCurrentTimestamp()
	--[[determine how much slides are to be considered after the last received record--]]
	local slides = math.floor((currentTimestamp - self.lastOprationTimestamp) / self.slideInterval)	
	
	--[[first delete older entries not skip working on then--]]
	self:deleteOlderWindows(currentTimestamp)
	
	--[[add as much panes as many slides have been passed--]]
	for i = 1, slides, 1 do
		self.lastOprationTimestamp = self.lastOprationTimestamp + self.slideInterval
		self:addNewPaneToAllWindows(self.lastOprationTimestamp)
	end
	
	--[[update the lastOprationTimestamp to floor(currentTimestamp // self.slideInterval.--]]
	--self.lastOprationTimestamp = (slides * self.slideInterval) + self.lastOprationTimestamp
	
	if (self.printStatus and slides > 1) then 
		self:printAll()
	end
	
	
	
	return self:filter(tag, timestamp, record)
end

function ThrottleFilter:new(obj, maxLoadRate, windowsSize, slideInterval, windowTimeDuration, streamField, logField, useTagAsStream, printStatus)
	obj = obj or {}
	if (not obj) then 
		if (WARNING) then
			io.write(string.format("[%s] Not enought memory.Can create filter.\n", PLUGIN, self.name))
		end
		return nil
	end
	setmetatable(obj, self)
	self.__index = self
	obj.maxLoadRate = maxLoadRate or 1024*1024 --[[bytes--]]
	obj.windowsSize = windowsSize or 5
	obj.slideInterval = slideInterval or 1 --[[seconds--]]
	obj.windowTimeDuration = windowTimeDuration or 60 --[[seconds--]]
	if (obj.windowTimeDuration < obj.windowsSize * obj.slideInterval) then
		obj.windowTimeDuration = obj.windowsSize * obj.slideInterval
	end
	obj.streamField = streamField or {}
	obj.logField = logField or {}
	obj.useTagAsStream = useTagAsStream or false
	obj.printStatus = printStatus or false
	obj.lastOprationTimestamp = getCurrentTimestamp()
	if (#obj.streamField == 0 and not obj.useTagAsStream) then
		obj.throttleTable = Window:new(nil, "no stream", obj.windowsSize)
	else
		obj.throttleTable = ThrottlingTable:new(nil)
	end
	if (not obj.throttleTable) then
		if (WARNING) then
			io.write(string.format("[%s] Can create table.\n", PLUGIN, self.name))
		end
		return nil
	end
	return obj
end

THROTTLE_FILTER = ThrottleFilter:new(nil, MAX_LOAD_RATE_IN_BYTES, WINDOW_SIZE, SLIDE_INTERVAL_IN_SEC, WINDOW_TIME_DURATION_IN_SEC, STREAM, LOG, USE_TAG_AS_STREAM, PRINT_STATUS)

--[Entry point for the fluent-bit lua plugin--]
function filter(tag, timestamp, record)	
	return THROTTLE_FILTER:processRecord(tag, timestamp, record)
end

return ThrottleFilter
