# Rideau Canal Skateway - IoT Simulation & Dashboard

A real‑time safety dashboard powered by IoT Hub, Azure Stream Analytics, Cosmos DB, and Blob Storage. Sensor data flows from IoT devices congregated into IoT Hub, through Stream Analytics, into Cosmos DB for live aggregation, and archived in Blob Storage for historical records. The dashboard, built with Angular and Node.js.
---

## Student Information
- **Name:** Akash Patel
- **Student ID:** 041269598
- **Course:** CST8916 - Winter 2026


## Scenario Overview

Once the Rideau Canal is ice covered in the winter, thousands of citizens in the city go there. Yet, skating safety is all over the place, though, it depends on such factors as the ice depth, and the surface temperature. Without the real-time monitoring, skaters will not receive timely information and will find themselves on the ice under unsafe conditions. Also, the city would not be able to see the historic trends to shape the municipal decisions on how to either open or close the canal.


## System Architecture
```ascii
+-------------------+
| IoT Devices       |
| (Simulated:       |
|  Dow's Lake,      |
|  Fifth Ave, NAC)  |
+---------+---------+
          |
          v
+-------------------+
| Azure IoT Hub     |
| (telemetry ingest)|
+---------+---------+
          |
          v
+-------------------+
| Azure Stream      |
| Analytics         |
| (5-min tumbling   |
|  window agg)      |
+---------+---------+
          |
          +-------------------+
          |                   |
          v                   v
+-------------------+   +-------------------+
| Cosmos DB         |   | Blob Storage      |
| (fast query for   |   | (historical data  |
|  dashboard)       |   |  archive)         |
+---------+---------+   +---------+---------+
          |                       
          v                       
+-------------------+             
| Angular App       |             
| (Dashboard        |             
|  visualization)   |             
+-------------------+             
```

## Implementation Overview

### IoT Sensor Simulation (link to repo)

**URL:** [sensor simulation repo](https://github.com/Akash705-hub/rideau-canal-sensor-simulation)

I adapted the code of the IoT Hub demo of class to have 1 simulated device connected to 3 devices to the IoT Hub, dows-lake, fifth-avenue, and nac. The Python code is a simulation of telemetry data in three places, which are the Lake, Fifth Avenue and NAC of Dow, and sends the data to the Azure IoT Hub after a time interval of 10 s every time, and a cycle of data transfer continues until the connection is interrupted by keyboard. Connection strings of both locations are read in a file named env in the directory where this script is found.

### Azure IoT Hub configuration

I registered the 3 devices, `dows-lake`, `fifth-avenue`, and `nac`, in IoT hub and retrieved their connection strings for my script.

### Stream Analytics job (include query)

The query is included under `/stream-analytics` and can be seen below:
```sql
SELECT 
    CONCAT(c.location, '-', MAX(TRY_CAST(c.timestamp AS datetime))) as id,
    c.location,
    MAX(TRY_CAST(c.timestamp AS datetime)) as timestamp,
    AVG(c.ice_thickness) AS avg_ice_thickness,
    MIN(c.ice_thickness) AS min_ice_thickness,
    MAX(c.ice_thickness) AS max_ice_thickness,
    AVG(c.surface_temperature) AS avg_surface_temperature,
    MIN(c.surface_temperature) AS min_surface_temperature,
    MAX(c.surface_temperature) AS max_surface_temperature,
    MAX(c.snow_accumulation) AS max_snow_accumulation,
    AVG(c.external_temperature) AS avg_external_temperature,
    COUNT(1) AS reading_count
INTO SensorAggregations
FROM "rideau-canal-iot-hub-final-assignment" AS c
GROUP BY TumblingWindow( minute , 5 ), c.location

SELECT 
    CONCAT(c.location, '-', MAX(TRY_CAST(c.timestamp AS datetime))) as id,
    c.location,
    MAX(TRY_CAST(c.timestamp AS datetime)) as timestamp,
    AVG(c.ice_thickness) AS avg_ice_thickness,
    MIN(c.ice_thickness) AS min_ice_thickness,
    MAX(c.ice_thickness) AS max_ice_thickness,
    AVG(c.surface_temperature) AS avg_surface_temperature,
    MIN(c.surface_temperature) AS min_surface_temperature,
    MAX(c.surface_temperature) AS max_surface_temperature,
    MAX(c.snow_accumulation) AS max_snow_accumulation,
    AVG(c.external_temperature) AS avg_external_temperature,
    COUNT(1) AS reading_count
INTO "historical-data"
FROM "rideau-canal-iot-hub-final-assignment" AS c
GROUP BY TumblingWindow( minute , 5 ), c.location
```

The two queries go `INTO` two different destination sinks; the `SensorAggregations` Cosmos DB container and the `historical-data` Blob Storage container. The same query is used on both to combine averages, minimums and maxes of the telemetry measures of ice thickness, surface temperature, snow accumulation and external temperature within a 5 min tumbling window of the IoT device messages. And I have an id per aggregation that is the {location}-{timestamp} in addition.

### Cosmos DB setup

I created a Cosmos DB named `RideauCanalDB` with the container `SensorAggregations` that serves as a output sink from Stream Analytics. It has a partition key, `/location`.

### Blob Storage configuration

I created a Storage Account called `rideaucanalstorage` with the container `historical-data` that serves as the second output sink from Stream Analytics.  has the file path pattern `aggregations/{date}/{time}` and with the format JSON (line separated).

### Web Dashboard (link to repo)

**URL:** [dashboard repo](https://github.com/Akash705-hub/rideau-canal-dashboard)

### Azure Services

1. IoT Hub
2. Stream Analytics
3. Cosmos DB
4. Blob Storage


## Repository Links

### 1. Main Documentation Repository
- **URL:** [documenation repo (here)](https://github.com/Akash705-hub/cst8916-final-project)
- **Description:** Complete project documentation, architecture, screenshots, and guides

### 2. Sensor Simulation Repository
- **URL:** [sensor simulation repo](https://github.com/Akash705-hub/rideau-canal-sensor-simulation)
- **Description:** IoT sensor simulator code

### 3. Web Dashboard Repository
- **URL:** [dashboard repo](https://github.com/Akash705-hub/rideau-canal-dashboard)
- **Description:** Web dashboard application


## AI Tools Disclosure

I used Copilot to create dashboard, to debug (when I was attempting to deploy to App Service), and to summarize sections of the report, such as the overview or troubleshooting section. The reason was that I wanted to incorporate the possible troubleshooting scenarios that I did not experience myself, but others might. I also tried to paraphrase the summaries to reflect more closely my thoughts.
