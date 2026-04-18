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