# Filter for throttling size

This filter for throttling size is written in lua and is intended to be used in the fluent-bit's lua plugin.

# How to configure it

To make this plugin work as you wish you have to alter the global variables at the begging of the script.

### WINDOW_SIZE
This denote how much panes must be created to monitoring the load.
Each different stream from which the record is generated will be moniter by a window consist of panes.
Each pane represent a time interval during which all of the load from all records( record of only one specific stream) will be considered as one.
For example if during this interval 10 record passed each of which with load 10kb then we assume that during this interval 100kb of data have been passed.

### SLIDE_INTERVAL_IN_SEC
The actual time duration of each interval in seconds. This interval is represented as window pane.
If we have `WINDOW_SIZE=5` and `SLIDE_INTERVAL_IN_SEC=1` this means that we will distribute the records load between 5 panes for the time of the last 5 seconds.
And the actual load rate will be calculated base on the total load for the last 5 seconds divided by the number of the panes(5).

### MAX_LOAD_RATE_IN_BYTES
The maximum allowed load rate for the last `WINDOW_SIZE` * `SLIDE_INTERVAL_IN_SEC` seconds.

### WINDOW_TIME_DURATION_IN_SEC
The time after which the window will be deleted without having new records load passing trough it.
It can't be less than `WINDOW_SIZE` * `SLIDE_INTERVAL_IN_SEC`.

### STREAM 
This is the stream from which the records are generated. For each stream there will be created a new dedicated window to throttle the load.
This can be only a key field from the record.
Because some records can be with nested keys(or lets say nested JSON) the variable is a list.
The first element is the most alter key and the last element is the inner most element wich holds the name of the stream as value.
For the nested stream `{"kubernetes":{"pod_name":"kube-apiserver"}}` the properly `STREAM` will be `{"kubernetes","pod_name"}`.
If you let this field as empty list all records will be considered as generated form one stream and will be monitored by only one window.

### USE_TAG_AS_STREAM
Instead of specifying the `STREAM` variable use this one and the tag will be usedas a stream.
If you used it don't forget to set `STREAM={}`.

### LOG
If you want to take into account the size of the entire record live this variable as an empty list.
But if you wich to watch only the size of the specific field in the record set it.
Logic how to set is the same as `STREAM`

### PRINT_STATUS
Set to true if you want to monitor the status of the existing windows.

### DEBUG, INFO, WARNING
Used for log severity.

# How to used in fluent-bit
```
[FILTER]
        Name                lua
        Match               <your tag or *(better use *)>
        script              size_throttling.lua
        call                filter
```

