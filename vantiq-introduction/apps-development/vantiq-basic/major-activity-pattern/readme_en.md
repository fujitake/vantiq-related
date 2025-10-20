# Introduction to Major Activity Patterns

This document introduces the most commonly used Activity Patterns.  
For other Activity Patterns and more detailed information, please refer to the official reference guide.  

:globe_with_meridians: [App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/)

## Table of Contents

- [Introduction to Major Activity Patterns](#introduction-to-major-activity-patterns)
  - [Table of Contents](#table-of-contents)
  - [List of Major Activity Patterns](#list-of-major-activity-patterns)
  - [Enrich, Cached Enrich](#enrich-cached-enrich)
    - [EEnrich, Cached Enrich Example](#eenrich-cached-enrich-example)
  - [Join](#join)
    - [Join Example](#join-example)
  - [Transformation](#transformation)
    - [Transformation Example](#transformation-example)
  - [SplitByGroup](#splitbygroup)
  - [Dwell](#dwell)
    - [Dwell Example](#dwell-example)
  - [SaveToType](#savetotype)
  - [ComputeStatistics](#computestatistics)
    - [ComputeStatistics Example](#computestatistics-example)
  - [Unwind](#unwind)
    - [Unwind Example](#unwind-example)
  - [Procedure](#procedure)
    - [Procedure Example](#procedure-example)
  - [VAIL](#vail)
    - [VAIL Example](#vail-example)
  - [Filter](#filter)
    - [Filter Example](#filter-example)
  - [AccumulateState](#accumulatestate)
    - [AccumulateState Example: Counting the number of passing events \<1\>](#accumulatestate-example-counting-the-number-of-passing-events-1)
    - [AccumulateState Example: Counting the number of passing events \<2\>](#accumulatestate-example-counting-the-number-of-passing-events-2)
    - [AccumulateState Example: Counting the number of passing events \<3\>](#accumulatestate-example-counting-the-number-of-passing-events-3)

## List of Major Activity Patterns

- Enrich, Cached Enrich
- Join  
- Transformation  
- SplitByGroup  
- Dwell  
- SaveToType  
- ComputeStatistics
- Unwind  
- Procedure  
- VAIL
- Filter  
- AccumulateState

## Enrich, Cached Enrich

- Adds data stored in a Type to an event.
- `Cached Enrich` is an `Enrich` activity that improves performance by caching the Type's values.  
  However, if the Type's value changes, the change will not be reflected in the event until the next time the Type's value is fetched.  
  - When using `Cached Enrich`, it is necessary to split the stream beforehand using `SplitByGroup`.  

:globe_with_meridians: [Enrich | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#enrich)  
:globe_with_meridians: [Cached Enrich | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#cached-enrich)

### EEnrich, Cached Enrich Example

![slide12.png](./imgs/slide12.png)

1. Output from the previous task (Input)

```JSON
{
=>  "RPMSensorID": "rpmSensor3",
    "RPM": 3222,
    "Time": "2020-03-19T04:42:24.021Z"
}
```

*Set the common property between the Type and the event (`RPMSensorID`) as the key.*  

2. Output from `Enrich`  

```JSON
{
    "RPMSensorID": "rpmSensor3",            # 1. Result from the "RPMStream" task
    "RPM": 3222,                            # 1. Result from the "RPMStream" task
    "Time": "2020-03-19T04:42:24.021Z",     # 1. Result from the "RPMStream" task
    "Pumps": {                              # Data from the Type added to the event starts here
        "_id": "5e70949fc714e2125bbb8854",
        "Location": {
            "coordinates": [
                139.581,
                35.5442
            ],
            "type": "Point"
        },
        "PumpID": 3,
=>      "RPMSensorID": "rpmSensor3",
        "TempSensorID": "tempSensor3",
        "ars_namespace": "Test",
        "ars_version": 1,
        "ars_createdAt": "2020-03-17T09:13:03.371Z",
        "ars_createdBy": "446b7d1d-2d7a-45f0-b74c-ba60866ced11"
    }
}
```

## Join

- Joins events from multiple streams.
- Can join events even if they have different timestamps.
- The event from the stream on the left side serves as the base.

:globe_with_meridians: [Join | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#join)

### Join Example

![slide14.png](./imgs/slide14.png)

1. Output from the first previous task (Input 1)

```JSON
{
    "TempSensorID": "tempSensor2",
    "Temp": 184,
    "Time": "2020-03-19T05:18:22.020Z",
    "Pumps": {
        "_id": "5e70949fc714e2125bbb8853",
        "Location": {
            "coordinates": [
                139.5819,
                35.5448
            ],
            "type": "Point"
        },
=>      "PumpID": 2,
            - abbreviated -
```

2. Output from the second previous task (Input 2)  

```JSON
{
    "RPMSensorID": "rpmSensor2",
    "RPM": 3971,
    "Time": "2020-03-19T05:18:28.022Z",
    "Pumps": {
        "_id": "5e70949fc714e2125bbb8853",
        "Location": {
            "coordinates": [
                139.5819,
                35.5448
            ],
            "type": "Point"
        },
=>      "PumpID": 2,
            - abbreviated -
```  

*Use the common property between the two events (`PumpID`) as the key.*  

3. Output from `Join`

```JSON
{
    "EnrichTemp": {
        "TempSensorID": "tempSensor2",
        "Temp": 184,
        "Time": "2020-03-19T05:18:22.020Z",
        "Pumps": {
            "_id": "5e70949fc714e2125bbb8853",
            "Location": {
                "coordinates": [
                    139.5819,
                    35.5448
                ],
                "type": "Point"
            },
=>          "PumpID": 2,
                - abbreviated -
        }
    },
    "EnrichRPM": {
        "RPMSensorID": "rpmSensor2",
        "RPM": 3971,
        "Time": "2020-03-19T05:18:28.022Z",
        "Pumps": {
            "_id": "5e70949fc714e2125bbb8853",
            "Location": {
                "coordinates": [
                    139.5819,
                    35.5448
                ],
                "type": "Point"
            },
=>          "PumpID": 2,
                - abbreviated -
        }
    }
}
```

## Transformation

- Transforms the structure of an event.
- You can add/remove fields or call a `Procedure` to perform the transformation.

:globe_with_meridians: [Transformation | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#transformation)

### Transformation Example

![slide16.png](./imgs/slide16.png)

1. Output from the previous task (Input)

```JSON
{
    "EnrichTemp": {
        "TempSensorID": "tempSensor2",
        "Temp": 184,
        "Time": "2020-03-19T05:18:22.020Z",
        "Pumps": {
            "_id": "5e70949fc714e2125bbb8853",
            "Location": {
                "coordinates": [
                    139.5819,
                    35.5448
                ],
                "type": "Point"
            },
            "PumpID": 2,
                - abbreviated -
        }
    },
    "EnrichRPM": {
        "RPMSensorID": "rpmSensor2",
        "RPM": 3971,
        "Time": "2020-03-19T05:18:28.022Z",
        "Pumps": {
            "_id": "5e70949fc714e2125bbb8853",
            "Location": {
                "coordinates": [
                    139.5819,
                    35.5448
                ],
                "type": "Point"
            },
            "PumpID": 2,
                - abbreviated -
        }
    }
}
```

2. Transform to include only necessary fields

![slide16_1.png](./imgs/slide16_1.png)* Example of a Procedure call  

Output from `Transformation`  

```JSON
{
=>  "Location": {
        "coordinates": [
            139.581,
            35.5442
        ],
        "type": "Point"
    },
=>  "PumpID": 3,
=>  "RPM": 3152,
=>  "ReceivedAt": "2020-03-19T06:05:14.245Z",
=>  "Temp": 194
}
```

## SplitByGroup

- Splits a stream into groups.
- Used before activities that need to process events on a per-group basis, such as `Dwell`, `ComputeStatistics`, and `AccumulateState`.

:globe_with_meridians: [Split By Group | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#split-by-group)

![slide17.png](./imgs/slide17.png)

## Dwell

- Emits an event when an incoming event meets a specified condition for a specified duration.

:globe_with_meridians: [Dwell | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#dwell)

### Dwell Example

![slide18.png](./imgs/slide18.png)

1. Configured to emit an event if the temperature is >= 200 degrees and RPM is >= 4000 for 20 seconds.  
2. Output from `Dwell`  

```JSON
{
    "Location": {
        "coordinates": [
            139.5819,
            35.5448
        ],
        "type": "Point"
    },
    "PumpID": 2,
=>  "RPM": 4034,
    "ReceivedAt": "2020-03-19T11:59:33.227Z",
=>  "Temp": 210
}
```

## SaveToType

- Saves or updates an event to a Type.
- To update, an `Upsert` configuration is required.

:globe_with_meridians: [SaveToType | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#savetotype)

## ComputeStatistics

- Performs statistical calculations on a single property of events passing through the task.
- The statistical processing occurs in memory, and the task outputs the original input event.
- To retrieve the statistics, you use an auto-generated Procedure.
- The statistical values include event count, min, max, median, mean, and standard deviation.

:globe_with_meridians: [Compute Statistics | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#compute-statistics)

### ComputeStatistics Example

![ComputeStatistics](./imgs/computestatistics_01.png)

1. Output from the previous task (Input)  

```JSON
{
    "TempSensorID": "tempSensor2",
    "Time": "2021-10-04T06:48:19.218Z",
    "Temp": 211,
    "PumpID": "pumpId2"
}
```

2. Output from `ComputeStatistics` (Same as input <1>)

```JSON
{
    "TempSensorID": "tempSensor2",
    "Time": "2021-10-04T06:48:19.218Z",
    "Temp": 211,
    "PumpID": "pumpId2"
}
```

3. Auto-generated Procedures for accessing statistics

- Procedures named `<TaskName>StateGet`, `<TaskName>StateReset`, and `<TaskName>StateGetUpdate` are automatically created.
- To retrieve the statistics, execute `<TaskName>StateGet` from a VAIL code location (e.g., within a Procedure, Rule, or Transform task).
- If `SplitByGroup` was used beforehand, the statistics are maintained per partition. A `partitionKey` argument is required, and its value should be the one used in the `groupBy` property of the `SplitByGroup` task.
- If not used, the statistics are global.

![computestatistics_02.png](./imgs/computestatistics_02.png)

4. Result of executing `<TaskName>StateGet`

***In this example, statistics are being collected for `Temp`.***

```JSON
{
    "count": 2,                           # Count
    "mean": 211.5,                        # Mean
    "min": 211,                           # Minimum value
    "max": 212,                           # Maximum value
    "median": 211.5,                      # Median
    "stdDeviation": 0.7071067811865476    # Standard Deviation
}
```

## Unwind

- Splits a single event into multiple events.
- Instead of processing a large event as a whole, `Unwind` allows for load balancing by splitting it into individual events that can be processed in parallel.

:globe_with_meridians: [Unwind | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#unwind)

### Unwind Example

![slide22.png](./imgs/slide22.png)

1. Output from the previous task (Input)  

```JSON
{
    "PumpID": 1,
    "Status": [
        {
2.          "Temp": 190,
            "RPM": 3560,
            "ts": "2020-01-01T00:00:01Z"
        },
        {
3.          "Temp": 180,
            "RPM": 4560,
            "ts": "2020-01-01T00:00:02Z"
        },
        {
4.          "Temp": 170,
            "RPM": 5560,
            "ts": "2020-01-01T00:00:03Z"
        }
    ]
}
```

*Splitting one event into multiple events.*  
2. Output <1> from `Unwind`

```JSON
{
    "PumpID": 1,
    "Temp": 170,
    "RPM": 5560,
    "ts": "2020-01-01T00:00:03Z"
}
```

3. Output <2> from `Unwind`

```JSON
{
    "PumpID": 1,
    "Temp": 180,
    "RPM": 4560,
    "ts": "2020-01-01T00:00:02Z"
}
```

4. Output <3> from `Unwind`

```JSON
{
    "PumpID": 1,
    "Temp": 190,
    "RPM": 3560,
    "ts": "2020-01-01T00:00:01Z"
}
```

## Procedure

- Used when you need to perform processing in the App Builder that isn't available in the standard Activity Patterns.
- Allows you to call and use your own custom Procedure (written in VAIL code).

:globe_with_meridians: [Procedure | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#procedure)

### Procedure Example

![slide24.png](./imgs/slide24.png)

1. Output from the previous task (Input)  

```JSON
{
    "value": 1
}
```

2. Example of a custom Procedure being called

```JavaScript
PROCEDURE myProcedure(event)
event.value += 1
return event
```

3. Output from `Procedure`  

```JSON
{
    "value": 2
}
```

## VAIL

- Allows you to write custom processing logic freely using VAIL.
- You can write VAIL directly in the task's properties without needing to create a separate Procedure.
- `event.value` corresponds to the content of the input/output data.

:globe_with_meridians: [VAIL | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#vail)

### VAIL Example

![VAIL](./imgs/vail_01.png)

1. Output from the previous task (Input)  

```JSON
{
    "TempSensorID": "tempSensor2",
    "Time": "2021-10-04T06:48:19.218Z",
    "Temp": 211,
    "PumpID": "pumpId2"
}
```

2. Example of VAIL code

```JavaScript
// Add "℃" to Temp
event.value.Temp = event.value.Temp + "℃"

// Delete the Time key
deleteKey(event.value, "Time")

// Add a CurrentTime key
event.value.CurrentTime = now()
```

3. Output from `VAIL`  

```JSON
{
    "TempSensorID": "tempSensor2",
=>  "Temp": "211℃",
    "PumpID": "pumpId2",
=>  "CurrentTime": "2021-10-04T03:54:21.783Z"
}
```

## Filter

- Allows only events that match a specified condition to pass through.

:globe_with_meridians: [Filter | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#filter)

### Filter Example

![slide25.png](./imgs/slide25.png)

1. Output from the previous task (Input)  

```JSON
{
    "value": 200
}
```

2. Specified condition  

```JavaScript
event.value > 100
```

3. Specified condition  

```JavaScript
event.value == 100
```

## AccumulateState

- Continuously tracks events that pass through the task where this Activity Pattern is configured.
- Allows you to execute arbitrary logic on the passing events by creating and configuring a dedicated Procedure for `AccumulateState`.
- When using `AccumulateState`, it is necessary to split the stream beforehand using `SplitByGroup`.

:globe_with_meridians: [Accumulate State | App Builder Reference Guide](https://dev.vantiq.com/docs/system/apps/#accumulate-state)

### AccumulateState Example: Counting the number of passing events <1>

![slide27.png](./imgs/slide27.png)

- The ***1st*** event at `SampleAccumulateState`

```JSON
{
    "PumpID": 1,
    "Temp": 183,
    "RPM": 3063,
    "Location": {
        "coordinates": [
            139.5811,
            35.5445
        ],
        "type": "Point"
    },
    "ReceivedAt": "2020-11-30T08:18:18.441Z",
    "current_status": {
=>      "eventCount": 1
    }
}
```

- The ***5th*** event at `SampleAccumulateState`

```JSON
{
    "PumpID": 4,
    "Temp": 183,
    "RPM": 3896,
    "Location": {
        "coordinates": [
            139.5813,
            35.5447
        ],
        "type": "Point"
    },
    "ReceivedAt": "2020-11-30T08:18:18.464Z",
    "current_status": {
=>      "eventCount": 5
    }
}
```

### AccumulateState Example: Counting the number of passing events <2>

**The custom Procedure created for `AccumulateState`**

```JavaScript
PROCEDURESample.accumulateState(lastEvent Object, event Object)
if(lastEvent){
    // If an event has already passed through this task
    lastEvent.eventCount++
} else {
    // If no event has passed through this task yet
    lastEvent = {
=>      eventCount: 1
    }
}
return lastEvent
```

&nbsp;&nbsp; ***\* The eventCount is incremented each time an event passes through.***

### AccumulateState Example: Counting the number of passing events <3>

![slide29.png](./imgs/slide29.png)

1. _procedure_: The custom Procedure created for `AccumulateState`.  
2. _outboundProperty_: The property name for the `AccumulateState` object.  
